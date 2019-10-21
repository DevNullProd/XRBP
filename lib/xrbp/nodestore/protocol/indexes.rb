module XRBP
  module NodeStore
    # Return DB lookup indices for the following artifacts
    module Indexes

      def self.get_quality(base)
        # FIXME: assuming native platform is big endian,
        #        need to account for all platforms
        base[-8..-1].to_bn
      end

      def self.get_quality_next(base)
        nxt = "10000000000000000".to_i(16)
        (base.to_bn + nxt).bytes
                          .reverse.pack("C*")
      end

      ###

      def self.dir_node_index(root, index)
        return root if index == 0

        sha512 = OpenSSL::Digest::SHA512.new
        sha512 << "\0"
        sha512 << Format::LEDGER_NAMESPACE[:dir_node]
        sha512 << root
        sha512 << index.bytes.rjust!(8, 0).pack("C*")

        sha512.digest[0..31]
      end

      def self.page(key, index)
        dir_node_index key, index
      end

      # Account index from id
      def self.account(id)
        id = Crypto.account_id(id)

        sha512 = OpenSSL::Digest::SHA512.new
        sha512 << "\0"
        sha512 << Format::LEDGER_NAMESPACE[:account]
        sha512 << id

        sha512.digest[0..31]
      end

      # Trust line for account/iou
      def self.line(account, iou)
        account = Crypto.account_id(account)
         issuer = Crypto.account_id(iou[:account])

        sha512  = OpenSSL::Digest::SHA512.new
        sha512 << "\0"
        sha512 << Format::LEDGER_NAMESPACE[:ripple]

        if account.to_bn < issuer.to_bn
          sha512 << account
          sha512 << issuer

        else
          sha512 << issuer
          sha512 << account
        end

        sha512 << Format.encode_currency(iou[:currency])

        sha512.digest[0..31]
      end

      # TODO: order book dir hash for ledger
      def self.order_book_dir()
      end

      # Order book index for given input/output
      def self.order_book(input, output)
         input = Hash[input]
        output = Hash[output]

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

        book_base = ["\0", Format::LEDGER_NAMESPACE[:book_dir],
                      input[:currency], output[:currency],
                      input[:account],  output[:account]].join

           sha512 = OpenSSL::Digest::SHA512.new
        book_base = sha512.digest(book_base)[0..31]

        # XXX: get_quality_index shorthand:
        book_base[-8..-1] = [0, 0, 0, 0, 0, 0, 0, 0].pack("C*")
        book_base
      end
    end # module Indexes
  end # module NodeStore
end # module XRBP
