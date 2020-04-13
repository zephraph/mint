module Mint
  module LS
    class Hover < LSP::RequestMessage
      def hover(node : Ast::Property, workspace) : Array(String | Nil)
        [
          workspace.formatter.format(node),
          node.comment.try(&.value),
        ]
      end
    end
  end
end
