module Mint
  module LS
    class Hover < LSP::RequestMessage
      def hover(node : Ast::StringLiteral, workspace) : Array(String | Nil)
        ["String"] of String | Nil
      end
    end
  end
end
