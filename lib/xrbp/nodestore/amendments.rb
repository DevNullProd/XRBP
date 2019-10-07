module XRBP
  module NodeStore
    module Amendments
      def fix1141_time
        @fix1141_time ||= Time.new(2016, 6, 1, 17, 0, 0, 0)
      end

      def fix1141?(time)
        time > fix1141_time
      end
    end
  end # module NodeStore
end # module XRBP
