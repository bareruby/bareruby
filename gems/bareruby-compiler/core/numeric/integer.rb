# frozen_string_literal: true

class Integer
  Primitive.native_def :==, function: :eq_ovl_int, returns: Bool, parameters: { self: Int, other: Int }
  Primitive.native_def :<, function: :lt_ovl_int, returns: Bool, parameters: { self: Int, other: Int }
  Primitive.native_def :+, function: :plus_ovl_int, returns: Int, parameters: { self: Int, other: Int }
end
