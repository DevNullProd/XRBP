class Object
  # XXX: allow any object to be serialzed via yaml
  #      by overriding 'psych' serializer callback
  def force_serializable!
    class << self
      def encode_with(coder)
      end
    end
  end
end
