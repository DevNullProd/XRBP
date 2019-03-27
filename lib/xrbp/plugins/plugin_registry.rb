module XRBP
  # Helper mixin providing list of plugins.
  #
  # @private
  module PluginRegistry
    module ClassMethods
      def plugins
        @plugins ||= {}
      end

      def register_plugin(label, cls)
        plugins[label] = cls
      end
    end # module ClassMethods

    def self.included(base)
      base.extend(ClassMethods)
    end
  end # module PluginRegistry
end # module XRBP
