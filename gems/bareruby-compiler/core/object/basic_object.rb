# frozen_string_literal: true

class BasicObject
  Primitive.native_def :object_address, function: :address, returns: UInt64, parameters: { self: BasicObject }

  # rubocop:disable-next Style/RedundantInitialize -- BasicObject has no superclass that defines initialize
  def initialize; end

  def ==(other) = equal?(other)

  def ! = self ? false : true

  def equal?(other) = __id__ == other.__id__

  # rubocop:disable-next Naming/MethodName -- BasicObject is the class that defines __id__
  def __id__
    address = object_address
    size = Primitive.pointer_size
    id = Array.new(size + 1, 0.to_u8)
    index = 0
    while index < size
      id[index + 1] = (address >> (index * 8)).to_u8
      index += 1
    end
    id
  end
end
