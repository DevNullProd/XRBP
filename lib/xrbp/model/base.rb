module XRBP
  module Model
    # Base model definition, provides common logic to set connection & opts.
    class Base
      module ClassMethods
        attr_accessor :opts, :connection

        def set_opts(opts={})
          self.opts ||= {}
          self.opts.merge!(opts)
          self.connection = opts[:connection] if opts[:connection]
        end
      end

      attr_accessor :opts, :connection

      def initialize(opts={})
        set_opts(opts)
      end

      def set_opts(opts={})
        @opts ||= {}
        @opts.merge!(opts)
        @connection = opts[:connection] if opts[:connection]
      end

      def full_opts
        (self.class.opts || {}).merge(opts || {}).except(:connection)
      end
    end # class Base
  end # module Model
end # module XRBP
