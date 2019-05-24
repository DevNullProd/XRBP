require "bistro"
require_relative './ripple.proto'

module XRBP
  module Overlay
    # Overlay Message Frame, prefixes Protobuf based message in
    # with header describing size and type.
    #
    # @private
    class Frame
      TYPE_INFER = Bistro.new([
        'L>', 'size',
        'S>', 'type'
      ])

      def self.header_size
        TYPE_INFER.size
      end

      def header_size
        self.class.header_size
      end

      def self.type_name(t)
        Protocol::MessageType.lookup(t)
      end

      ###

      attr_reader :type, :size
      attr_accessor :data

      def initialize(type, size)
        @type = type
        @size = size

        @data = ""
      end

      def type_name
        @type_name ||= self.class.type_name(type)
      end

      def message
        @message ||= MESSAGES[type_name].decode(data)
      end

      def <<(data)
        remaining = size - @data.size
        @data += data[0..remaining-1]
        return @data, data[remaining..-1]
      end

      def complete?
        @data.size == size
      end
    end # class Frame
  end # module WebClient
end # module XRBP
