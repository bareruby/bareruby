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
  Primitive.native_def :-, function: :minus_ovl_int, returns: Int, parameters: { self: Int, other: Int }
  Primitive.native_def :/, function: :div_ovl_int, returns: Int, parameters: { self: Int, other: Int }
  Primitive.native_def :%, function: :modulo_ovl_int, returns: Int, parameters: { self: Int, other: Int }
  Primitive.native_def :-@, function: :uminus_ovl_int, returns: Int, parameters: { self: Int }
  Primitive.native_def :+, function: :plus_ovl_int_float, returns: Float, parameters: { self: Int, other: Float }
  Primitive.native_def :-, function: :minus_ovl_int_float, returns: Float, parameters: { self: Int, other: Float }
  Primitive.native_def :*, function: :mul_ovl_int_float, returns: Float, parameters: { self: Int, other: Float }
  Primitive.native_def :/, function: :div_ovl_int_float, returns: Float, parameters: { self: Int, other: Float }
  Primitive.native_def :%, function: :modulo_ovl_int_float, returns: Float, parameters: { self: Int, other: Float }
  Primitive.native_def :==, function: :eq_ovl_int_float, returns: Bool, parameters: { self: Int, other: Float }
  Primitive.native_def :<, function: :lt_ovl_int_float, returns: Bool, parameters: { self: Int, other: Float }
  Primitive.native_def :<=, function: :le_ovl_int_float, returns: Bool, parameters: { self: Int, other: Float }
  Primitive.native_def :>, function: :gt_ovl_int_float, returns: Bool, parameters: { self: Int, other: Float }
  Primitive.native_def :>=, function: :ge_ovl_int_float, returns: Bool, parameters: { self: Int, other: Float }
  Primitive.native_def :to_f, function: :to_f_ovl_int, returns: Float, parameters: { self: Int }
  Primitive.native_def :fdiv, function: :fdiv_ovl_int, returns: Float, parameters: { self: Int, other: Int }
  Primitive.native_def :fdiv, function: :fdiv_ovl_int_float, returns: Float, parameters: { self: Int, other: Float }

  def integer? = true

  def equal?(other) = self == other
end
