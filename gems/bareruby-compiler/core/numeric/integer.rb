# frozen_string_literal: true

class Integer < Numeric
  Primitive.native_def :==, function: :eq_ovl_int, returns: Bool, parameters: { self: Int, other: Int }
  Primitive.native_def :==, function: :eq_ovl_u8, returns: Bool, parameters: { self: Byte, other: Byte }
  Primitive.native_def :<, function: :lt_ovl_int, returns: Bool, parameters: { self: Int, other: Int }
  Primitive.native_def :+, function: :plus_ovl_int, returns: Int, parameters: { self: Int, other: Int }
  Primitive.native_def :*, function: :mul_ovl_int, returns: Int, parameters: { self: Int, other: Int }
  Primitive.native_def :>>, function: :rshift_ovl_u64, returns: UInt64, parameters: { self: UInt64, other: Int }
  Primitive.native_def :to_u8, function: :to_u8_ovl_int, returns: Byte, parameters: { self: Int }
  Primitive.native_def :to_u8, function: :to_u8_ovl_u64, returns: Byte, parameters: { self: UInt64 }
  Primitive.native_def :>, function: :gt_ovl_int, returns: Bool, parameters: { self: Int, other: Int }
  Primitive.native_def :<=>, function: :cmp_ovl_int, returns: Int, parameters: { self: Int, other: Int }
  Primitive.native_def :abs, function: :abs_ovl_int, returns: Int, parameters: { self: Int }
  Primitive.native_def :zero?, function: :zero_p_ovl_int, returns: Bool, parameters: { self: Int }
  Primitive.native_def :<=, function: :le_ovl_int, returns: Bool, parameters: { self: Int, other: Int }
  Primitive.native_def :>=, function: :ge_ovl_int, returns: Bool, parameters: { self: Int, other: Int }

  def integer? = true
end
