module XRBP
  module NodeStore
    def self.xrp_currency
      @xrp_currency ||= 0
    end

    def self.no_currency
      @no_currency ||= 1
    end
  end # module NodeStore
end # module XRBP
