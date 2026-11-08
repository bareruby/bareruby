# frozen_string_literal: true

module Kernel
  def puts(value) # rubocop:disable Lint/UnusedMethodArgument -- native_def passes value to the C++ function
    Primitive.native_def function: :puts_ovl_bool, parameters: { value: Bool }, returns: nil
    Primitive.native_def function: :puts_ovl_int, parameters: { value: Int }, returns: nil
  end
end
