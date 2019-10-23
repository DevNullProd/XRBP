require_relative './amendments'
require_relative './fees'
require_relative './parser'


module XRBP
  module NodeStore
    class Ledger
      include Amendments
      include Parser

      def initialize(args={})
        @db = args[:db]
        @hash = args[:hash]

        if @hash
          state_map.fetch_root [info["account_hash"]].pack("H*")
             tx_map.fetch_root [info["tx_hash"]].pack("H*")
        end
      end

      def txs
        @txs ||= tx_map.collect { |tx| parse_tx_inner(tx.data) }
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

      # Returns boolean indicating if specified account
      # is flagged as globally frozen
      def global_frozen?(account)
        return false if account == Crypto.xrp_account
        sle = state_map.read(Indexes::account(account))
        return sle && sle.flag?(:global_freeze)
      end

      # Returns boolean indicating if specific account
      # has frozen trust-line for specified IOU
      def frozen?(account, iou)
        return false if iou[:currency] == 'XRP'

        sle = state_map.read(Indexes::account(iou[:account]))
        return true if sle && sle.flag?(:global_freeze)

        return false if iou[:account] == account

        sle = state_map.read(Indexes::line(account, iou))
        sle && sle.flag?(iou[:account] > account ? :high_freeze :
                                                   :low_freeze)
      end

      # Return IOU balance which owner account holds
      def account_holds(owner_id, iou)
        return xrp_liquid(owner_id, 0) if iou[:currency] == 'XRP'
        sle = state_map.read(Indexes::line(owner_id, iou))
        return STAmount.zero if !sle || frozen?(owner_id, iou)

        amount = sle.amount(:balance)
        amount.negate! if Crypto.account_id(owner_id).to_bn >
                          Crypto.account_id(iou[:account]).to_bn
        balance_hook(amount)
      end

      # Returns available (liquid) XRP account holds
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

      # Return TransferRate configured for IOU,
      # the percent of an amount sent that is charged
      # to the sender and paid to the issuer.o
      # https://xrpl.org/transfer-fees.html
      def transfer_rate(issuer)
        sle = state_map.read(Indexes::account(issuer))

        return Rate.new sle.field(:uint32,
                                  :transfer_rate) if sle &&
                                                     sle.field?(:transfer_rate)
        Rate.parity
      end

      ###

      public

      # TODO: helper method to get first funded high quailty
      #       offer from order book. Also market depth helper

      # Return all offers for the given input/output currency pair
      def order_book(input, output)
        offers = []

        # Start at order book index
        # Stop after max order book quality
        tip_index = Indexes::order_book(input, output)
         book_end = Indexes::get_quality_next(tip_index)

        global_freeze = global_frozen?(output[:account]) ||
                        global_frozen?(input[:account])

        # transfer rate multipled to offer output to pay issuer
        rate = transfer_rate(output[:account])

           balances = {}
               done = false # set true when we cannot traverse anymore
             direct = true  # set true when we need to find next dir
          offer_dir = nil   # current directory being travred
           dir_rate = nil   # current directory quality
        offer_index = nil   # index of current offer being processed
         book_entry = nil   # index of next offer directory record
        until done
          if direct
            direct = false
            # Return first index after tip
            ledger_index = state_map.succ(tip_index, book_end)
            if ledger_index
              # retrieve offer_dir SLE from db
              offer_dir = state_map.read(ledger_index)
            else
              offer_dir = nil
            end

            if !offer_dir
              done = true
            else
              # Set new tip, get first offer at new tip
              tip_index = offer_dir.key
              dir_rate = STAmount.from_quality(Indexes::get_quality(tip_index))
              offer_index, offer_dir, book_entry = state_map.cdir_first(tip_index)
            end
          end

          if !done
            # Read offer from db and process
            sle_offer = state_map.read(offer_index)
            if sle_offer
              # Direct info from nodestore offer
                owner_id = sle_offer.account_id(:account)
              taker_gets = sle_offer.amount(:taker_gets)
              taker_pays = sle_offer.amount(:taker_pays)

              # Owner / Output Calculation
                    owner_funds = nil  # how much of offer output the owner has
              first_owner_offer = true # owner_funds returned w/ first owner offer

              # issuer is offering it's own IOU, fully funded
              if output[:account] == owner_id
                owner_funds = taker_gets

              # all offers not ours are unfunded
              elsif global_freeze
                owner_funds.clear(output)

              else
                # if we have owner funds cached
                if balances[owner_id]
                  owner_funds = balances[owner_id]
                  first_owner_offer = false

                # did not find balance in cache
                else
                  # lookup from nodestore
                  owner_funds = account_holds(owner_id, output)

                  # treat negative funds as zero
                  owner_funds.clear if owner_funds < STAmount.zero
                end
              end

              offer = Hash[sle_offer.fields]   # copy the offer fields to return
              taker_gets_funded = nil          # how much offer owner will actually be able to fund
              owner_funds_limit = owner_funds  # how much the offer owner has limited by the output transfer fee
              offer_rate = Rate.parity         # offer base output transfer rate

              # Check if transfer fee applies,
              if            rate != Rate.parity      && # transfer fee
                       # TODO: provide support for 'taker_id' rpc param:
                       #taker_id != output[:account] && # not taking offers of own IOUs
                output[:account] != owner_id            # offer owner not issuing own funds
                  # Need to charge a transfer fee to offer owner.
                  offer_rate = rate
                  owner_funds_limit = owner_funds / offer_rate.rate
              end

              # Check if owner has enough funds to pay it all
              if owner_funds_limit >= taker_gets
                # Sufficient funds no shenanigans.
                taker_gets_funded = taker_gets

              else
                # Only set these fields, if not fully funded.
                taker_gets_funded = owner_funds_limit
                offer[:taker_gets_funded] = taker_gets_funded

                # the account that takes the offer will need to
                # pay the 'gets' amount actually funded times the dir_rate (quality)
                offer[:taker_pays_funded] = [taker_pays,
                                             taker_gets_funded *
                                                      dir_rate].min

                # XXX: done in multiply operation in rippled
                offer[:taker_pays_funded].issue = taker_pays.issue
              end

              # Calculate how much owner will pay after this offer,
              # if no transfer fee, then the amount funded,
              # else the minimum of what the owner has or the
              # amount funded w/ transfer fee
              owner_pays = (Rate.parity == offer_rate) ?
                                     taker_gets_funded :
                                           [owner_funds,
                         taker_gets_funded * offer_rate].min

              # Update balance cache w/ new owner balance
              balances[owner_id] = owner_funds - owner_pays

              # Set additional params and store the offer

              # include all offers funded and unfunded
              offer[:quality] = dir_rate
              offer[:owner_funds] = owner_funds if first_owner_offer
              offers << offer

            else
              puts "missing offer"
            end

            # Retrieve next offer in offer_dir,
            # updating offer_index, offer_dir, book_entry appropriately
            offer_index, offer_dir, book_entry = *state_map.cdir_next(tip_index, offer_dir, book_entry)

            # if next offer not retrieved find next record after tip
            direct = true if !offer_index
          end
        end

        return offers
      end
    end # class Ledger
  end # module NodeStore
end # module XRBP
