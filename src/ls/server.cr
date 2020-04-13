module Mint
  module LS
    class Server < LSP::Server
      method "initialize", Initialize
      method "textDocument/hover", Hover
      method "textDocument/didChange", DidChange
      method "textDocument/completion", Completion
      method "shutdown", Shutdown
      method "exit", Exit

      def debug_stack(stack)
        stack.each_with_index do |item, index|
          class_name = item.class

          if index == 0
            log class_name.to_s
          else
            log "#{" " * (index - 1)} ↳ #{class_name}"
          end
        end
      end

      def nodes_at_cursor(params : LSP::TextDocumentPositionParams)
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
