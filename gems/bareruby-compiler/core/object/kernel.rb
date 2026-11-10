# frozen_string_literal: true

module Kernel
  Primitive.native_def :puts, function: :puts_ovl_bool, returns: nil, parameters: { value: Bool }
  Primitive.native_def :puts, function: :puts_ovl_int, returns: nil, parameters: { value: Int }

  def nil? = false

  def eql?(other) = __id__ == other.__id__
end
