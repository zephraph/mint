module Mint
  module LS
    class Server < LSP::Server
      method "initialize", Initialize
      method "textDocument/hover", Hover
      method "textDocument/completion", Completion
      method "shutdown", Shutdown
      method "exit", Exit

      def nodes_at_cursor(params : TextDocumentPositionParams)
        workspace =
          Mint::Workspace[params.path]

        workspace.ast.nodes.select do |item|
          next unless item.input.file == params.path
          item.from <= params.offset <= item.to
        end
      end
    end
  end
end
