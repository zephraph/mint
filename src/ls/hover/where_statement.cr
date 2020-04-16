module Mint
  module LS
    class Hover < LSP::RequestMessage
      def hover(node : Ast::WhereStatement, workspace) : Array(String | Nil)
        type =
          workspace
            .type_checker
            .cache[node]?
            .try(&.to_mint)

        head =
          workspace
            .formatter
            .format(node.target)

        [
          "**#{head} =**",
          type,
        ] of String | Nil
      end
    end
  end
end
