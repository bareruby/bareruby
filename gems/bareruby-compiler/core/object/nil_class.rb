# frozen_string_literal: true

class NilClass
  class << self
    undef_method :new
  end

  def nil? = true

  # rubocop:disable-next Naming/MethodName -- NilClass redefines __id__ because nil has no address to read
  def __id__
    id = Array.new(Primitive.pointer_size + 1, 0.to_u8)
    id[0] = 1.to_u8
    id
  end
end
