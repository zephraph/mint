module Mint
  module LS
    class Hover < LSP::RequestMessage
      def hover(node : Ast::ModuleAccess, workspace) : Array(String | Nil)
        item =
          workspace.type_checker.lookups[node.variable]?

        hover(item, workspace)
      end
    end
  end
end
