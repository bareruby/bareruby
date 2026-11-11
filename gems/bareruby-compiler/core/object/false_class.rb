# frozen_string_literal: true

class FalseClass
  class << self
    undef_method :new
  end

  # rubocop:disable-next Naming/MethodName -- FalseClass redefines __id__ because false has no address to read
  def __id__
    id = Array.new(Primitive.pointer_size + 1, 0.to_u8)
    id[0] = 3.to_u8
    id
  end
end
