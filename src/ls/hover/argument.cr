module Mint
  module LS
    class Hover < LSP::RequestMessage
      def hover(node : Ast::Argument, workspace) : Array(String | Nil)
        type =
          workspace.formatter.format(node.type)

        [
          "**#{node.name.value} : #{type}**",
        ] of String | Nil
      end
    end
  end
end
