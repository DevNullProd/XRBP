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
