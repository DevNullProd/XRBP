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

  def all?(&bl)
    each_char { |c| return false unless bl.call(c) }
    return true
  end

  def zero?
    return self == "\0" if size == 1
    all? { |c| c.zero? }
  end

  # scan(regex) will not work as we need to process
  # binary strings (\n's seem to trip scan up)
  def chunk(size)
    ((self.length + size - 1) / size).times.collect { |i| self[i * size, size] }
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

  def byte_string
    bytes.reverse.pack("C*")
  end

  def to_int32
    self & (2**32-1)
  end

  alias :to_int :to_int32

  def from_xrp_time
    XRBP.from_xrp_time(self)
  end
end

# @private
class Array
  def rjust!(n, x)
    insert(0, *Array.new([0, n-length].max, x))
  end

  def ljust!(n, x)
    fill(x, length...n)
  end
end

# @private
class Time
  def to_xrp_time
    XRBP.to_xrp_time(self)
  end
end
