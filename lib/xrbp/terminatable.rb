module XRBP
  # Helper mixin facilitating controlled termination of
  # asynchronous components.
  #
  # @private
  module Terminatable
    def terminate_queue
      @terminate_queue ||= Queue.new
    end

    def terminate?
      !!terminate_queue.pop_or_nil
    end

    def terminate!
      terminate_queue << true
    end
  end
end
