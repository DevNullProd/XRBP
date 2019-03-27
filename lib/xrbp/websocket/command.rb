require 'json'

module XRBP
  module WebSocket
    class Command < Message
      attr_accessor :id
      attr_reader :json

      def initialize(data)
        @@id ||= 0
        @id = (@@id += 1)

        json = Hash[data]
        json['id'] = id

        @json = json

        super(json.to_json)
      end

      def requesting
        @json[:command] || @json["command"]
      end

      def requesting?(tgt)
        requesting.to_s == tgt.to_s
      end
    end # class Command
  end # module WebSocket
end # module XRBP
