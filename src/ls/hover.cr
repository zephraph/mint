module Mint
  module LS
    class Hover < LSP::RequestMessage
      property params : LSP::TextDocumentPositionParams

      HTML_ELEMENTS = {
        "div" => "The **HTML Content Division element (<div>)** is the generic container for flow content. It has no effect on the content or layout until styled using CSS.",
      }

      def hover(node : Ast::HtmlElement, workspace)
        <<-MARKDOWN
        **#{node.tag.value}**

        ------

        #{HTML_ELEMENTS[node.tag.value]? || ""}
        MARKDOWN
      end

      def hover(node : Ast::Function, workspace)
        formatted =
          Mint::Formatter
            .new(workspace.ast, workspace.json.formatter_config)
            .format(node)
            .to_s

        <<-MARKDOWN
        Function: **#{node.name.value}**

        ------

        ```mint
        #{formatted}
        ```
        MARKDOWN
      end

      def hover(node : Ast::ModuleAccess, workspace)
        if item = workspace.type_checker.lookups[node.variable]?
          hover(item, workspace)
        end
      end

      def hover(node : Ast::EnumId, workspace)
        item =
          workspace.ast.enums.find(&.name.==(node.name))

        case item
        when Ast::Enum
          formatted =
            Mint::Formatter
              .new(workspace.ast, workspace.json.formatter_config)
              .format(item)
              .to_s

          <<-MARKDOWN
          Enum: **#{item.name}**

          ------

          ```mint
          #{formatted}
          ```
          MARKDOWN
        else
          nil
        end
      end

      def hover(node : Ast::Property, workspace)
        formatted =
          Mint::Formatter
            .new(workspace.ast, workspace.json.formatter_config)
            .format(node)
            .to_s

        [
          formatted,
          node.comment.to_s,
        ]
      end

      def hover(node : Ast::Node, workspace)
        node.class.to_s
      end

      def execute(server)
        uri = URI.parse(params.text_document.uri)

        workspace = Workspace[uri.path.to_s]

        contents =
          if error = workspace.error
            "Cannot provide hover data because, there is an error with your project #{error}"
          else
            result = server.nodes_at_cursor(params)

            result.each_with_index do |i, index|
              x = i.class

              if index == 0
                server.log x.to_s
              else
                server.log "#{" " * (index - 1)} ↳ #{x}"
              end
            end

            node = result[0]?
            parent = result[1]?

            case node
            when Ast::Variable
              workspace.type_checker.scope(result[1..]) do
                item =
                  workspace.type_checker.lookup(node)

                case item
                when Ast::Node
                  hover(item, workspace)
                else
                  nil
                end
              end
            when Ast::ModuleAccess
              hover(node, workspace)
            when Ast::Property
              hover(node, workspace)
            when Ast::Function
              hover(node, workspace)
            when Ast::HtmlElement
              hover(node, workspace)
            when Ast::EnumId
              hover(node, workspace)
            else
              case node
              when Ast::Node
                type = workspace.type_checker.cache[node]?

                if type
                  "Type: \n#{type.to_mint}"
                else
                  "ASD"
                end
              else
                "WTF"
              end
            end
          end

        server.send({
          jsonrpc: "2.0",
          id:      id,
          result:  {
            contents: contents,
          },
        })
      end
    end
  end
end
