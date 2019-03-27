module XRBP
  # Helper mixin provding plugin management capabilities.
  #
  # @private
  module HasPlugin
    # should be overridden
    def plugin_namespace
      raise
    end

    def plugins
      @plugins ||= []
    end

    def add_plugin(*plgs)
      plgs.each { |plg|
        plg = plugin_namespace.plugins[plg] if plg.is_a?(Symbol)
        raise ArgumentError unless !!plg
        plg = plg.new(self)
        plugins << plg
        plg.added if plg.respond_to?(:added)
      }
    end

    def plugin?(plg)
      clss = plugins.collect { |plg| plg.class }
       cls = plugin_namespace.plugins[plg]
      clss.include?(plg) || clss.include?(cls)
    end

    def plugin(plg)
       cls = plugin_namespace.plugins[plg]
       plugins.find { |_plg|
         (plg.is_a?(Class) && _plg.kind_of?(plg)) ||
         (cls.is_a?(Class) && _plg.class.kind_of?(cls))
       }
    end

    def define_instance_method(name, &block)
      (class << self; self; end).class_eval do
        define_method name, &block
      end
    end
  end # module HasPlugin
end # module XRBP
