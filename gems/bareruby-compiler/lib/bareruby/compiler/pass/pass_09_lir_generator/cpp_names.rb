# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class LirGenerator
        class CppNames
          def initialize(int_width)
            @int_width = int_width
          end

          def cpp_type(type)
            case type
            in :Bool then "bool"
            in :Int then "int#{@int_width}_t"
            in :nil then "void"
            in [:instance, class_name] then "BareRuby::#{class_name}*"
            in [:array, element_type] then "#{array_type(element_type)}*"
            end
          end

          def array_type(element_type) = "BareRuby::Array<#{cpp_type(element_type)}>"

          def instance_method?(function) = %i[instance array].include?(function[:self_type].first)

          def function_name(function) = "bareruby_#{function[:name].gsub(/\W/) { format("_%02x", it.ord) }}"

          def variable_name(name) = "variable_#{name}"
        end
      end
    end
  end
end
