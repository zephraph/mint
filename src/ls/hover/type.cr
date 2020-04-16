module Mint
  module LS
    class Hover < LSP::RequestMessage
      def hover(node : Ast::Type, workspace) : Array(String | Nil)
        type =
          workspace.formatter.format(node)

        [type] of String | Nil
      end
    end
  end
end
