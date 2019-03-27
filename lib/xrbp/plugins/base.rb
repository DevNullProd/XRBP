module XRBP
  # Base plugin definition, common logic shared by all connection plugins.
  class PluginBase
    attr_accessor :connection

    def initialize(connection)
      @connection = connection
    end
  end # class PluginBase
end # module XRBP
