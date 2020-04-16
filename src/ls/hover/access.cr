module Mint
  module LS
    class Hover < LSP::RequestMessage
      def hover(node : Ast::Access, workspace) : Array(String | Nil)
        type =
          workspace
            .type_checker
            .cache[node]?
            .try(&.to_mint)

        [type] of String | Nil
      end
    end
  end
end
