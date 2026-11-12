# frozen_string_literal: true

class Float < Numeric
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
end
