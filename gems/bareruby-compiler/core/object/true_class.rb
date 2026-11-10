# frozen_string_literal: true

class TrueClass
  # rubocop:disable-next Naming/MethodName -- TrueClass redefines __id__ because true has no address to read
  def __id__
    id = Array.new(Primitive.pointer_size + 1, 0.to_u8)
    id[0] = 2.to_u8
    id
  end
end
