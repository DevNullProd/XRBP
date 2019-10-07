require_relative './amendments'
require_relative './fees'

module XRBP
  module NodeStore
    class Ledger
      include Amendments

      def initialize(args={})
        @db = args[:db]
        @hash = args[:hash]

        if @hash
          state_map.fetch_root [info["account_hash"]].pack("H*")
             tx_map.fetch_root [info["tx_hash"]].pack("H*")
        end
      end

      private

      attr_reader :db, :hash

      def state_map
        @state_map ||= SHAMap.new :db => db
      end

      def tx_map
        @tx_map ||= SHAMap.new :db => db
      end

      def info
        @info ||= db.ledger(hash)
      end

      def fees
        @fees ||= Fees.new
      end

      def global_frozen?(account)
        return false if account == Crypto.xrp_account
        sle = state_map.read(Indexes::account(account))
        return sle && sle.flag?(:global_freeze)
      end

      def frozen?(account, iou)
        return false if iou[:currency] == 'XRP'

        sle = state_map.read(Indexes::account(iou[:account]))
        return true if sle && sle.flag?(:global_freeze)

        return false if iou[:account] == account

        sle = state_map.read(Indexes::line(account, iou))
        sle && sle.flag?(iou[:account] > account ? :high_freeze :
                                                   :low_freeze)
      end

      def account_holds(owner_id, iou)
        return xrp_liquid(owner_id, 0) if iou[:currency] == 'XRP'
        sle = state_map.read(Indexes::line(owner_id, iou))
        return STAmount.zero if !sle || frozen?(owner_id, iou)

        amount = sle.amount(:balance)
        amount *= -1 if owner_id > iou[:account]
        balance_hook(amount)
      end

      def xrp_liquid(account, owner_count_adj)
        sle = state_map.read(Indexes::account(account))
        return STAmount.zero unless sle

        if fix1141? info['parent_close_time']
          owner_count = confine_owner_account(owner_count_hook(
                                      sle.field(:uint32, :owner_count)),
                                                       owner_count_adj)

          reserve = fees.account_reserve(owner_count)
          full_balance = sle.amount(:balance)
          balance = balance_hook(full_balance)
          amount = balance - reserve
          return STAmount.zero if balance < reserve
          return amount

        else
          owner_count = confine_owner_account(sle.field(:uint32, :owner_count),
                                                              owner_count_adj)
          reserve = fees.account_reserve(sle.field(:uint32, :owner_count))
          full_balance = sle.amount(:balance)
          amount = balance - reserve
          return STAmount.zero if balance < reserve
          return balance_hook(amount)
        end
      end

      def confine_owner_account(current, adjustment)
        adjusted = current + adjustment
        if adjustment > 0
          # XXX: std::numeric_limits<std::uint32_t>::max
          adjusted = 2**32-1 if adjusted < current
        else
          adjusted = 0 if adjusted > current
        end

        adjusted
      end

      def balance_hook(amount)
        # TODO currently implementing ReadView::balanceHook,
        #                   implement PaymentSandbox::balanceHook?
        amount
      end

      def owner_count_hook(count)
        # Same PaymentSandbox TODO as in balance_hook above
        count
      end

      def transfer_rate(issuer)
        sle = state_map.read(Indexes::account(issuer))
        return Rate.new sle.field(:uint32,
                                  :transfer_rate) if sle &&
                                                     sle.field?(:transfer_rate)
        Rate.parity
      end

      ###

      public

      def order_book(input, output)
        offers = []

        tip_index = Indexes::order_book(input, output)
         book_end = Indexes::get_quality_next(tip_index)

        global_freeze = global_frozen?(output[:account]) ||
                        global_frozen?(input[:account])

        rate = transfer_rate(output[:account])

        balances = {}
             ret = {:offers => []}

               done = false
             direct = true
           dir_rate = nil
          offer_dir = nil
        offer_index = nil
         book_entry = nil
        until done
          if direct
            direct = false
            ledger_index = state_map.succ(tip_index, book_end)
            if ledger_index
              offer_dir = state_map.read(ledger_index)
            else
              offer_dir = nil
            end

            if !offer_dir
              done = true
            else
              tip_index = offer_dir.key
              dir_rate = STAmount.from_quality(Indexes::get_quality(tip_index))
              offer_index, book_entry = state_map.cdir_first(tip_index)
            end
          end

          if !done
            sle_offer = state_map.read(offer_index)
            if sle_offer
                owner_id = sle_offer.account_id(:account)
              taker_gets = sle_offer.amount(:taker_gets)
              taker_pays = sle_offer.amount(:taker_pays)

                    owner_funds = nil
              first_owner_offer = true

              if output[:account] == owner_id
                # issuer is offering it's own IOU, fully funded
                owner_funds = taker_gets

              elsif global_freeze
                # all offers not ours are unfunded
                owner_funds.clear(output)

              else
                if balances[owner_id]
                  owner_funds = balances[owner_id]
                  first_owner_offer = false

                else
                  # did not find balance in table
                  owner_funds = account_holds(owner_id, output)

                  # treat negative funds as zero
                  owner_funds.clear if owner_funds < STAmount.zero
                end
              end

              offer = Hash[sle_offer.fields]
              taker_gets_funded = nil
              owner_funds_limit = owner_funds
              offer_rate = Rate.parity

              if            rate != Rate.parity      && # transfer fee
                       # TODO: provide support for 'taker_id' rpc param:
                       #taker_id != output[:account] && # not taking offers of own IOUs
                output[:account] != owner_id            # offer owner not issuing own funds
                  # Need to charge a transfer fee to offer owner.
                  offer_rate = rate
                  owner_funds_limit = owner_funds / offer_rate.rate
              end


              if owner_funds_limit >= taker_gets
                # Sufficient funds no shenanigans.
                taker_gets_funded = taker_gets

              else
                # Only provide, if not fully funded.
                taker_gets_funded = owner_funds_limit
                offer[:taker_gets_funded] = taker_gets_funded
                offer[:taker_pays_funded] = [taker_pays,
                                             taker_gets_funded *
                                                      dir_rate *
                                              taker_pays.issue].min
              end

              owner_pays = (Rate.parity == offer_rate) ?
                                     taker_gets_funded :
                                           [owner_funds,
                         taker_gets_funded * offer_rate].min

              balances[owner_id] = owner_funds - owner_pays

              offers << offer

              # include all offers funded and unfunded
              ret[:offers] << offer
              ret[:quality] = dir_rate
              ret[:owner_funds] = owner_funds if first_owner_offer

            else
              puts "missing offer"
            end

            offer_index, book_entry = *state_map.cdir_next(tip_index, offer_dir, book_entry)
            direct = true if !offer_index
          end
        end

        return offers
      end
    end # class Ledger
  end # module NodeStore
end # module XRBP
