require 'concurrent'

module XRBP
  # Helper mixin providing internal thread management.
  #
  # @private
  module ThreadRegistry
    def thread_registry
      @thread_registry ||= Concurrent::Array.new
    end

    def rsleep(t)
      thread_registry << Thread.current
      sleep(t)
      thread_registry.delete(Thread.current)
    end

    def wake_all
      thread_registry.each { |th| th.wakeup }
    end
  end # module ThreadRegistry
end # module XRBP
