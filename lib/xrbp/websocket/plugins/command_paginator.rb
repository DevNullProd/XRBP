module XRBP
  module WebSocket
    module Plugins
      # Handles multi-page responses, automatically issuing subsequent requests
      # when more data is available and concatinating results.
      #
      # This is most useful with account transaction and object lists where a
      # single account may be associated with more data than can returned in a
      # single result. In this case response will include pagination marker
      # which we leverage here to retrieve all data.
      class CommandPaginator < PluginBase
        def added
          raise "Must also include CommandDispatcher plugin" unless connection.plugin?(CommandDispatcher)
        end

        def unlock!(cmd, res)
          return true unless cmd.respond_to?(:paginate?) && cmd.paginate?
          return true unless res["result"] # unlock if we cannot get result

          marker = res["result"]["marker"]
          page   = res["result"][cmd.page_title]

          if marker && next_cmd = cmd.next_page(marker)
            connection.cmd next_cmd do
              page
            end

          else
            # XXX can't recursively use stack to unwind
            #     callbacks as there may be too many pages.
            #     Do it serially.
            res = Array.new(page)
            cmd.each_ancestor { |page_cmd|
              page_res = page_cmd.bl.call res
              res = page_res + res if page_cmd.prev_cmd
            }
          end

          false
        end
      end # class CommandPaginator

      WebSocket.register_plugin :command_paginator, CommandPaginator
    end # module Plugins
  end # module WebSocket
end # module XRBP
