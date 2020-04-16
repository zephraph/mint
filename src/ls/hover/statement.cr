module Mint
  module LS
    class Hover < LSP::RequestMessage
      def hover(node : Ast::Statement, workspace) : Array(String | Nil)
        type =
          workspace
            .type_checker
            .cache[node]?
            .try(&.to_mint)

        head =
          node.target.try do |target|
            formatted =
              workspace
                .formatter
                .format(target)
            "**#{formatted} =**"
          end

        [
          head,
          type,
        ] of String | Nil
      end
    end
  end
end
