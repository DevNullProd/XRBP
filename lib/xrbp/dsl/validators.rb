module XRBP
  module DSL
    # Return list of all validators
    #
    # @return [Array<Hash>] list of validators retrieved
    def validators
      Model::Validator.all :connection => webclient
    end
  end # module DSL
end # module XRBP
