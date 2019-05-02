# Extend Hash class w/ some methods pulled from activesupport
# @private
class Hash
  def except(*keys)
    dup.except!(*keys)
  end

  def except!(*keys)
    keys.each { |key| delete(key) }
    self
  end
end

# @private
class Queue
  # Return next queue item or nil
  def pop_or_nil
    begin
      pop(true)
    rescue
      nil
    end
  end
end

# @private
class String
  # return bignum corresponding to string
  def to_bn
    bytes.inject(0) { |bn, b| (bn << 8) | b }
  end
end

# @private
class Integer
  # return bytes
  def bytes
    i = dup
    b = []
    until i == 0
      b << (i & 0xFF)
      i  = i >> 8
    end
    b
  end
end
