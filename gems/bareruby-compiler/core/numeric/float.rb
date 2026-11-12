# frozen_string_literal: true

class Float < Numeric
  Primitive.native_const :INFINITY, function: :infinity, returns: Float

  Primitive.native_def :==, function: :eq_ovl_float, returns: Bool, parameters: { self: Float, other: Float }
  Primitive.native_def :+, function: :plus_ovl_float, returns: Float, parameters: { self: Float, other: Float }
  Primitive.native_def :-, function: :minus_ovl_float, returns: Float, parameters: { self: Float, other: Float }
  Primitive.native_def :*, function: :mul_ovl_float, returns: Float, parameters: { self: Float, other: Float }
  Primitive.native_def :/, function: :div_ovl_float, returns: Float, parameters: { self: Float, other: Float }
  Primitive.native_def :-@, function: :uminus_ovl_float, returns: Float, parameters: { self: Float }
  Primitive.native_def :%, function: :modulo_ovl_float, returns: Float, parameters: { self: Float, other: Float }
  Primitive.native_def :<, function: :lt_ovl_float, returns: Bool, parameters: { self: Float, other: Float }
  Primitive.native_def :<=, function: :le_ovl_float, returns: Bool, parameters: { self: Float, other: Float }
  Primitive.native_def :>, function: :gt_ovl_float, returns: Bool, parameters: { self: Float, other: Float }
  Primitive.native_def :>=, function: :ge_ovl_float, returns: Bool, parameters: { self: Float, other: Float }
  Primitive.native_def :equal?, function: :equal_p_ovl_float, returns: Bool, parameters: { self: Float, other: Float }
  Primitive.native_def :zero?, function: :zero_p_ovl_float, returns: Bool, parameters: { self: Float }
  Primitive.native_def :positive?, function: :positive_p_ovl_float, returns: Bool, parameters: { self: Float }
  Primitive.native_def :negative?, function: :negative_p_ovl_float, returns: Bool, parameters: { self: Float }
  Primitive.native_def :abs, function: :abs_ovl_float, returns: Float, parameters: { self: Float }
  Primitive.native_def :finite?, function: :finite_p_ovl_float, returns: Bool, parameters: { self: Float }
  Primitive.native_def :+, function: :plus_ovl_float_int, returns: Float, parameters: { self: Float, other: Int }
  Primitive.native_def :-, function: :minus_ovl_float_int, returns: Float, parameters: { self: Float, other: Int }
  Primitive.native_def :*, function: :mul_ovl_float_int, returns: Float, parameters: { self: Float, other: Int }
  Primitive.native_def :/, function: :div_ovl_float_int, returns: Float, parameters: { self: Float, other: Int }
  Primitive.native_def :%, function: :modulo_ovl_float_int, returns: Float, parameters: { self: Float, other: Int }
  Primitive.native_def :==, function: :eq_ovl_float_int, returns: Bool, parameters: { self: Float, other: Int }
  Primitive.native_def :<, function: :lt_ovl_float_int, returns: Bool, parameters: { self: Float, other: Int }
  Primitive.native_def :<=, function: :le_ovl_float_int, returns: Bool, parameters: { self: Float, other: Int }
  Primitive.native_def :>, function: :gt_ovl_float_int, returns: Bool, parameters: { self: Float, other: Int }
  Primitive.native_def :>=, function: :ge_ovl_float_int, returns: Bool, parameters: { self: Float, other: Int }
end
