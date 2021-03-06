module XRBP
  module NodeStore
    class Issue
      attr_reader :currency, :account

      def initialize(currency, account)
        @currency = currency
        @account  = account
      end

      def to_h
        {:currency => currency, :account => account}
      end

      def xrp?
        self == NodeStore.xrp_issue
      end

      def inspect
        c = currency == NodeStore.no_currency  ? ''    :
            currency == NodeStore.xrp_currency ? 'XRP' :
                                         "#{currency}"

        a = account == Crypto.no_account  ? '' :
            account == Crypto.xrp_account ? '' :
                                 "@#{account}"
        "#{c}#{a}"
      end
    end # class Issue

    def self.xrp_issue
      @xrp_issue ||= Issue.new(NodeStore.xrp_currency,
                               Crypto.xrp_account)
    end

    def self.no_issue
      @no_issue ||=  Issue.new(NodeStore.no_currency,
                               Crypto.no_account)
    end
  end # module NodeStore
end # module XRBP
