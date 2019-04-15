module Mint
  module LS
    class Completion < LSP::RequestMessage
      property params : LSP::CompletionParams

      def completion_item(node : Ast::Component)
        index = 0

        attributes =
          node
            .properties
            .reject(&.name.value.==("children"))
            .map do |property|
              default =
                Mint::Formatter
                  .new(workspace.ast, workspace.json.formatter_config)
                  .format(property.default)
                  .gsub("}", "\\}")

              type =
                workspace.type_checker.cache[property]? || Mint::TypeChecker::Type.new("")

              value =
                case type.name
                when "String"
                  if default == %("")
                    %("${#{index + 2}}")
                  else
                    %(${#{index + 2}:#{default}})
                  end
                when "Array"
                  %([${#{index + 2}}])
                else
                  %({${#{index + 2}:#{default}}\\})
                end

              result =
                "${#{index + 1}:#{property.name.value}=#{value}}"

              index += 2

              result
            end
            .to_a

        snippet =
          if attributes.size > 3
            <<-MINT
            <#{node.name}
              #{attributes.join("\n  ")}>
              $0
            </#{node.name}>
            MINT
          else
            <<-MINT
            <#{node.name} #{attributes.join(" ")}>
              $0
            </#{node.name}>
            MINT
          end

        LSP::CompletionItem.new(
          kind: LSP::CompletionItemKind::Snippet,
          filter_text: node.name,
          sort_text: node.name,
          label: node.name,
          detail: "Component",
          documentation: "",
          deprecated: false,
          preselect: false,
          insert_text: snippet,
        )
      end

      def completion_item(node : Ast::Argument)
        name =
          node.name.value

        LSP::CompletionItem.new(
          kind: LSP::CompletionItemKind::Variable,
          filter_text: name,
          sort_text: name,
          label: name,
          detail: "Argument",
          documentation: "",
          deprecated: false,
          preselect: false,
          insert_text: name,
        )
      end

      def completion_item(node : Ast::Function)
        name =
          node.name.value

        arguments =
          node
            .arguments
            .each_with_index
            .map do |(argument, index)|
              %(${#{index + 1}:#{argument.name.value}})
            end

        snippet =
          <<-MINT
          #{name}(#{arguments.join(", ")})
          MINT

        LSP::CompletionItem.new(
          kind: LSP::CompletionItemKind::Function,
          filter_text: name,
          sort_text: name,
          label: name,
          detail: "Function",
          documentation: "",
          deprecated: false,
          preselect: false,
          insert_text: snippet,
        )
      end

      def completion_item(node : Ast::Get)
        name =
          node.name.value

        LSP::CompletionItem.new(
          kind: LSP::CompletionItemKind::Variable,
          filter_text: name,
          sort_text: name,
          label: name,
          detail: "Computed Property",
          documentation: "",
          deprecated: false,
          preselect: false,
          insert_text: name,
        )
      end

      def completion_item(node : Ast::Node)
        nil
      end

      def completions(node : Ast::Component) : Array(Ast::Node)
        items = [] of Ast::Node

        node.functions.each { |function| items << function }
        node.gets.each { |get| items << get }

        items
      end

      def completions(node : Ast::Function) : Array(Ast::Node)
        items =
          [] of Ast::Node

        node.arguments.each do |argument|
          items << argument
        end

        workspace.type_checker.cache[node]?.try do |type|
          if type.parameters.last.try(&.name) == "Html"
            workspace.ast.components.each do |component|
              items << component
            end
          end
        end

        items
      end

      def completions(node : Ast::Node)
        [] of Ast::Node
      end

      def workspace
        Mint::Workspace[params.path]
      end

      def execute(server)
        items =
          server
            .nodes_at_cursor(params)
            .map { |node| completions(node) }
            .flatten
            .compact
            .uniq
            .map { |node| completion_item(node) }

        server.send({
          jsonrpc: "2.0",
          id:      id,
          result:  items,
        })
      end
    end
  end
end
