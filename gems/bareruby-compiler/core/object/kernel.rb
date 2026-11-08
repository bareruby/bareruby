module Kernel
  def puts(value)
    Primitive.native_def function: :puts_ovl_bool, parameters: { value: Bool }, returns: nil
  end
end
