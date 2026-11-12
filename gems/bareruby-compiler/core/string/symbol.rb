# frozen_string_literal: true

class Symbol
  include Comparable

  Primitive.native_def :==, function: :eq_ovl_symbol, returns: Bool, parameters: { self: Symbol, other: Symbol }
  Primitive.native_def :<=>, function: :cmp_ovl_symbol, returns: Int, parameters: { self: Symbol, other: Symbol }

  def ===(other) = self == other

  def equal?(other) = self == other
end
