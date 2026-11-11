# frozen_string_literal: true

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        # The compiler is provisional and will be discarded and rebuilt,
        # so its classes are not split to meet the length limit.
        class Definitions # rubocop:disable Metrics/ClassLength
          OWNER = { methods: {}, singleton_methods: {}, includes: [], superclass: nil }.freeze

          attr_reader :statements

          def initialize(bareruby_ast, typed_ast)
            @brast = bareruby_ast
            @tast = typed_ast
          end

          def run
            @owners = Hash.new { |owners, name| owners[name] = OWNER.transform_values(&:dup) }
            @statements = []
            @brast.each_file { |path, statements| collect(path, statements) }
            self
          end

          def classes = @owners.filter_map { |name, definition| [name, definition[:superclass]] if definition[:class] }

          def each_native_method
            @owners.each do |owner, definition|
              definition[:methods].each_value do |method|
                next unless method[:rows]

                method[:rows].group_by(&:first).each { |path, rows| yield owner, path, rows.map(&:last) }
              end
            end
          end

          def lookup(name, method_name) = find_in(ancestors(name), :methods, method_name)

          def lookup_singleton(name, method_name)
            find_in(superclasses(name), :singleton_methods, method_name) || lookup(:Class, method_name)
          end

          def primitive_call?(node, name)
            return false unless @brast.node_type(node) == :call

            receiver, method_name, = @brast.children_of(node)
            receiver && @brast.children_of(receiver) == [:Primitive] && method_name == name
          end

          def error(node, message) = raise(Error, "#{location(node)}: #{message}")

          def location(node)
            span = @brast.span_of(node)
            "#{span[:filename]}:#{span[:start][:line]}"
          end

          private

          def find_in(owners, table, method_name)
            owner = owners.find { @owners[it][table].key?(method_name) }
            owner && [owner, @owners[owner][table][method_name]]
          end

          def collect(path, statements)
            statements.each do |node|
              case @brast.node_type(node)
              when :module_definition then collect_owner(path, *@brast.children_of(node))
              when :class_definition then collect_class(path, *@brast.children_of(node))
              else @statements << node
              end
            end
          end

          def collect_class(path, name, body)
            @owners[name].merge!(class: true, superclass: superclass_of(name))
            collect_owner(path, name, body)
          end

          def superclass_of(name) = { BasicObject: nil, Object: :BasicObject }.fetch(name, :Object)

          def collect_owner(path, name, body, table = :methods)
            body.each do |node|
              type = @brast.node_type(node)
              next collect_method(path, name, node, table) if type == :method_definition
              next unless table == :methods

              case type
              when :singleton_method_definition then collect_method(path, name, node, :singleton_methods)
              when :singleton_class then collect_owner(path, name, @brast.children_of(node).first, :singleton_methods)
              when :call then collect_call(path, name, node)
              end
            end
          end

          def collect_method(path, owner, node, table)
            name, parameters, body = @brast.children_of(node)
            @owners[owner][table][name] = { path:, parameters:, body:, rows: nil }
          end

          def collect_call(path, owner, node)
            return collect_native_def(path, owner, node) if primitive_call?(node, :native_def)

            @owners[owner][:includes] << include_target(node)
          end

          def collect_native_def(path, owner, node)
            name_node, options = @brast.children_of(node)[2]
            methods = @owners[owner][:methods]
            name = value_of(name_node)
            methods[name] = { rows: [] } unless methods[name]&.fetch(:rows)
            methods[name][:rows] << [path, native_row(options)]
          end

          def include_target(node)
            _receiver, name, arguments = @brast.children_of(node)
            error(node, "unsupported call #{name} in a class body") unless name == :include

            @brast.children_of(arguments.first).first
          end

          def native_row(node)
            options = entries(node)
            parameters = entries(options[:parameters]).transform_values { type_name(it) }
            @tast.create_native_row(value_of(options[:function]), parameters, type_name(options[:returns]))
          end

          def entries(node) = @brast.children_of(node).first.to_h { |key, value| [value_of(key), value] }

          def value_of(node) = @brast.children_of(node).first

          def type_name(node) = @brast.node_type(node) == :nil ? :nil : @tast.type_named(value_of(node))

          public

          def ancestors(name)
            definition = @owners[name]
            parents = definition[:includes].reverse.flat_map { ancestors(it) }
            parents += ancestors(definition[:superclass]) if definition[:superclass]
            ([name] + parents).uniq
          end

          def superclasses(name) = [name] + (@owners[name][:superclass]&.then { superclasses(it) } || [])
        end
      end
    end
  end
end
