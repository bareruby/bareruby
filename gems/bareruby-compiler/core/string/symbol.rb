# frozen_string_literal: true

class Symbol
  Primitive.native_def :==, function: :eq_ovl_symbol, returns: Bool, parameters: { self: Symbol, other: Symbol }
end
