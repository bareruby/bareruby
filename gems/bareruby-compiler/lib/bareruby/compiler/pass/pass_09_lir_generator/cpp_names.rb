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
            end
          end

          def instance_method?(function) = function[:self_type].first == :instance

          def function_name(function) = "bareruby_#{function[:name]}"

          def variable_name(name) = "variable_#{name}"
        end
      end
    end
  end
end
