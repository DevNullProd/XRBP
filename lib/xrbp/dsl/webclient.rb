module XRBP
  module DSL
    # Client which may be used to access HTTP resources
    def webclient
      @webclient ||= WebClient::Connection.new
    end
  end # module DSL
end # module XRBP
