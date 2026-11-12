# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class CppNames
          STRUCT_NAMESPACES = %w[BareRuby generated].freeze
          FIXED_TYPES = { Bool: "bool", UInt8: "uint8_t", UInt64: "uint64_t", Float: "float", nil: "void" }.freeze

          def initialize(int_width)
            @int_width = int_width
          end

          def cpp_type(type)
            case type
            in :Int then "int#{@int_width}_t"
            in Symbol then FIXED_TYPES.fetch(type)
            in [:instance, class_name] then "#{struct_name(class_name)}*"
            in [:array, element_type] then "#{array_type(element_type)}*"
            end
          end

          def struct_name(class_name) = "#{STRUCT_NAMESPACES.join("::")}::#{class_name}"

          def array_type(element_type) = "BareRuby::Array<#{cpp_type(element_type)}>"

          def instance_method?(function) = !(function[:self_type] in [:class, _] | :nil)

          def function_name(function) = "bareruby_#{function[:name].gsub(/\W/) { format("_%02x", it.ord) }}"

          def variable_name(name) = "variable_#{name}"
        end
      end
    end
  end
end
