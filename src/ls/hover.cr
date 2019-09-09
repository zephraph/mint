module Mint
  module LS
    class Hover < LSP::RequestMessage
      property params : LSP::TextDocumentPositionParams

      HTML_ELEMENTS = {
        "div" => "The **HTML Content Division element (\<div\>)** is the generic container for flow content. It has no effect on the content or layout until styled using CSS.",
      }

      def hover(node : Ast::HtmlElement)
        [
          node.tag.value,
          HTML_ELEMENTS[node.tag.value]? || "",
        ]
      end

      def hover(node : Ast::Function)
        [
          node.name.value,
          node.comment.try(&.value).to_s,
        ]
      end

      def hover(node : Ast::EnumId, workspace)
        item =
          workspace.ast.enums.find(&.name.==(node.name))

        [
          item.try(&.name).to_s,
          item.try(&.options.map(&.value).join("\n\n")).to_s,
        ]
      end

      def execute(server)
        uri = URI.parse(params.text_document.uri)

        workspace = Workspace[uri.path.to_s]

        result = server.nodes_at_cursor(params)

        node = result[0]?
        parent = result[1]?

        server.log(node.class.to_s)
        server.log(parent.class.to_s)

        contents =
          case parent
          when Ast::Function
            hover(parent)
          when Ast::HtmlElement
            hover(parent)
          when Ast::EnumId
            hover(parent, workspace)
          else
            case node
            when Ast::Function
              hover(node)
            when Ast::HtmlElement
              hover(node)
            when Ast::EnumId
              hover(node, workspace)
            when Ast::Node
              type = workspace.type_checker.cache[node]?

              if type
                type.to_pretty
              else
                "ASD"
              end
            else
              "WTF"
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
