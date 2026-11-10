# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class NativeRows
          def initialize(bareruby_ast, definitions)
            @brast = bareruby_ast
            @definitions = definitions
          end

          def select(node, owner, method, self_type, types)
            row = method[:rows].map(&:last).rfind { accepts?(it, self_type, types) }
            name = @brast.children_of(node)[1]
            @definitions.error(node, "no native_def of #{owner}##{name} accepts (#{types.join(", ")})") unless row

            row
          end

          private

          def accepts?(row, self_type, types)
            parameters = row[:parameters]
            return false unless parameters.except(:self).values == types

            !parameters.key?(:self) || self_matches?(parameters[:self], self_type)
          end

          def self_matches?(row_type, self_type)
            return row_type == self_type unless row_type in [:instance, class_name]

            self_type in [:instance, actual] and @definitions.ancestors(actual).include?(class_name)
          end
        end
      end
    end
  end
end
