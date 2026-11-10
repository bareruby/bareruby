# frozen_string_literal: true

class Array
  def length = Primitive.array_length

  def [](index) = Primitive.array_element(index)

  def ==(other)
    equal = length == other.length
    index = 0
    while equal && index < length
      equal = self[index] == other[index]
      index += 1
    end
    equal
  end
end
