# frozen_string_literal: true

class Integer
  Primitive.native_def :==, function: :eq_ovl_int, returns: Bool, parameters: { self: Int, other: Int }
end
