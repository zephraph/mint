module Mint
  module LS
    class Hover < LSP::RequestMessage
      property params : LSP::TextDocumentPositionParams

      def execute(server)
        uri = URI.parse(params.text_document.uri)

        workspace = Mint::Workspace[uri.path.to_s]

        node = workspace.ast.nodes.find do |item|
          next unless item.input.file == uri.path.to_s
          item.from <= params.offset <= item.to
        end

        contents =
          case node
          when Mint::Ast::Variable
            node.value
          when Mint::Ast::Node
            type = workspace.type_checker.cache[node]?

            if type
              type.to_pretty
            else
              "ASD"
            end
          else
            "WTF"
          end

        server.send({
          jsonrpc: "2.0",
          id:      id,
          result:  {
            contents: [node.class.to_s, contents],
          },
        })
      end
    end
  end
end
