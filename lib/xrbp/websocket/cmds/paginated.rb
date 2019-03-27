require 'xrbp/core_ext'

module XRBP
  module WebSocket
    module Cmds
      # Helper mixin facilitating paginated command retrieval.
      #
      # @private
      module Paginated
        attr_reader :prev_cmd

        def root_cmd
          return self unless prev_cmd
          prev_cmd.root_cmd
        end

        def each_ancestor(&bl)
          bl.call self
          prev_cmd.each_ancestor &bl if prev_cmd
        end

        def parse_paginate(args)
          @paginate = args[:paginate]
          @prev_cmd = args[:prev_cmd]
        end

        def paginate_args
          return :prev_cmd #, :paginate # XXX need to forward paginate
        end

        def args_without_paginate
          args.except(*paginate_args)
        end

        def paginate?
          !!@paginate
        end

        def next_page(marker)
          self.class.from_h(to_h.merge({:marker   => marker,
                                        :prev_cmd => self}))
        end
      end # module Paginated
    end # module Cmds
  end # module WebSocket
end # module Wipple
