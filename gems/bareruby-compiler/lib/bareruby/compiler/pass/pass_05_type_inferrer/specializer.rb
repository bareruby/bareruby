# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        class Specializer
          def self.forwarding?(method) = method[:parameters] == [FORWARDING]

          def initialize(typed_ast, inferrer)
            @result = typed_ast
            @inferrer = inferrer
            @functions = {}
          end

          def specialize(owner, name, method, self_type, types)
            key = [owner, name, self_type, types]
            return @functions[key] if @functions.key?(key)

            function = @result.create_function("#{owner}_#{name}_#{@functions.size}", self_type,
                                               parameter_names(method, types).zip(types))
            @functions[key] = function
            fill_function(function, method)
          end

          private

          def parameter_names(method, types)
            Specializer.forwarding?(method) ? types.each_index.map { :"argument#{it}" } : method[:parameters]
          end

          def fill_function(function, method)
            scope = scope_of(function, method)
            body = method[:body].map { @inferrer.infer(it, scope) }
            function.merge!(body:, return_type: body.empty? ? :nil : @result.type_of(body.last),
                            allocates: scope[:allocates], locals: scope[:locals].except(*scope[:parameters]))
            @result.add_function(function)
            function
          end

          def scope_of(function, method)
            parameters = function[:parameters]
            forwarded = Specializer.forwarding?(method) ? parameters.map { @result.create_local(*it) } : nil
            { self: function[:self_type], locals: parameters.to_h, parameters: parameters.map(&:first), forwarded: }
          end
        end
      end
    end
  end
end
