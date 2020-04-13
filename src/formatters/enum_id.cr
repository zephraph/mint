module Mint
  class Formatter
    def format(node : Ast::EnumId)
      expressions =
        format_parameters(node.expressions)

      "#{node.name}::#{node.option}#{expressions}"
    end
  end
end
