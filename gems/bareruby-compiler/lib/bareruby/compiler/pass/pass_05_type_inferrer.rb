# frozen_string_literal: true

require_relative "../ir/typed_ast"

module BareRuby
  module Compiler
    module Pass
      class TypeInferrer
        TOP_LEVEL_CLASS = :Object

        attr_reader :result

        def initialize(bareruby_ast)
          @brast = bareruby_ast
        end

        def run
          @result = TypedAST.new
          @owners = Hash.new { |owners, name| owners[name] = { methods: {}, includes: [] } }
          @statements = []
          @brast.each_file { |path, statements| collect_definitions(path, statements) }
          add_native_methods
          @statements.each { @result.add_statement(infer(it)) }
          self
        end

        private

        def collect_definitions(path, statements)
          statements.each do |node|
            case @brast.node_type(node)
            when :module_definition, :class_definition then collect_owner(path, *@brast.children_of(node))
            else @statements << node
            end
          end
        end

        def collect_owner(path, name, body)
          body.each do |node|
            case @brast.node_type(node)
            when :method_definition then collect_method(path, name, node)
            when :call then @owners[name][:includes] << include_target(node)
            end
          end
        end

        def collect_method(path, owner, node)
          name, parameters, body = @brast.children_of(node)
          @owners[owner][:methods][name] = { path:, parameters:, rows: body.map { native_row(it) } }
        end

        def include_target(node)
          _receiver, name, arguments = @brast.children_of(node)
          raise Error, "#{location(node)}: unsupported call #{name} in a class body" unless name == :include

          @brast.children_of(arguments.first).first
        end

        def native_row(node)
          receiver, name, arguments = @brast.children_of(node)
          unless receiver && @brast.children_of(receiver) == [:Primitive] && name == :native_def
            raise Error, "#{location(node)}: unsupported method body"
          end

          options = entries(arguments.first)
          parameters = entries(options[:parameters]).transform_values { type_name(it) }
          @result.create_native_row(value_of(options[:function]), parameters, type_name(options[:returns]))
        end

        def entries(node) = @brast.children_of(node).first.to_h { |key, value| [value_of(key), value] }

        def value_of(node) = @brast.children_of(node).first

        def type_name(node) = @brast.node_type(node) == :nil ? :nil : value_of(node)

        def add_native_methods
          @owners.each do |owner, definition|
            definition[:methods].each_value do |method|
              @result.add_native_method(method[:path], "BareRuby::#{owner}", method[:rows])
            end
          end
        end

        def infer(node)
          case @brast.node_type(node)
          when :call then infer_call(node)
          when :boolean then @result.create_boolean(@brast.children_of(node).first)
          when :integer then @result.create_integer(@brast.children_of(node).first)
          else raise Error, "#{location(node)}: unsupported expression #{@brast.node_type(node)}"
          end
        end

        def infer_call(node)
          _receiver, name, argument_nodes = @brast.children_of(node)
          owner, method = lookup(TOP_LEVEL_CLASS, name)
          raise Error, "#{location(node)}: undefined method '#{name}' for main" unless method

          check_arity(node, method, argument_nodes)
          arguments = argument_nodes.map { infer(it) }
          row = select_row(node, owner, name, method, arguments.map { @result.type_of(it) })
          @result.create_native_call("BareRuby::#{owner}", row, arguments)
        end

        def select_row(node, owner, name, method, types)
          row = method[:rows].rfind { it[:parameters].except(:self).values == types }
          raise Error, "#{location(node)}: no native_def of #{owner}##{name} accepts (#{types.join(", ")})" unless row

          row
        end

        def check_arity(node, method, arguments)
          return if arguments.size == method[:parameters].size

          raise Error, "#{location(node)}: wrong number of arguments " \
                       "(given #{arguments.size}, expected #{method[:parameters].size})"
        end

        def lookup(name, method_name)
          ancestors(name).each do |owner|
            method = @owners[owner][:methods][method_name]
            return [owner, method] if method
          end
          nil
        end

        def ancestors(name) = ([name] + @owners[name][:includes].reverse.flat_map { ancestors(it) }).uniq

        def location(node)
          span = @brast.span_of(node)
          "#{span[:filename]}:#{span[:start][:line]}"
        end
      end
    end
  end
end
