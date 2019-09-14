module XRBP
  module NodeStore
    class Hasher
      # TODO: specific account hash from id, ledger, etc
      def self.account()
      end

      # TODO: order book dir hash for ledger
      def self.order_book_dir()
      end

      # TODO: specific order book for dir_hash, currency pair
      def self.order_book(input, output)
        # Currency always upcase
         input[:currency].upcase!
        output[:currency].upcase!

        # If currency == 'XRP' set corresponding issuer
         input[:account] = Crypto.xrp_account if  input[:currency] == 'XRP'
        output[:account] = Crypto.xrp_account if output[:currency] == 'XRP'

        # Convert currency to binary representation
         input[:currency] = Format.encode_currency(input[:currency])
        output[:currency] = Format.encode_currency(output[:currency])

        # convert input / output account to binary representation
         input[:account] = Crypto.account_id(input[:account])
        output[:account] = Crypto.account_id(output[:account])

        book_base = [Format::LEDGER_NAMESPACE[:book_dir],
                      input[:currency],  input[:account],
                     output[:currency], output[:account]].join

           sha512 = OpenSSL::Digest::SHA512.new
        book_base = sha512.digest(book_base)[0..31]
        book_base[-8..-1] = [0, 0, 0, 0, 0, 0, 0, 0]
        index = book_base

        nxt = "10000000000000000".to_i(16)
        book_end = index + nxt # ...

          done = false
        direct = true
        until done
          if direct
            direct = false
        #    ledger_index = view.succ(index, book_end);
        #    if ledgeR_index
        #      offer_dir  = view.read(keylet::page(*ledger_index));
        #    else
        #      offer_dir.reset
        #    end

        #    if !offer_dir
        #      done = true
        #    else
        #      # ...
        #      uTipIndex = sleOfferDir->key();
        #      saDirRate = amountFromQuality (getQuality (uTipIndex));

        #      cdirFirst (view,
        #          uTipIndex, sleOfferDir, uBookEntry, offerIndex, viewJ);
        #    end
          end

        #  if !done
        #    # ...
        #  end
        end
      end
    end # class Hasher
  end # module NodeStore
end # module XRBP
