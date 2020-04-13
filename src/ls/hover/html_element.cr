module Mint
  module LS
    class Hover < LSP::RequestMessage
      HTML_ELEMENTS = {
        "div" => "The **HTML Content Division element (<div>)** is the generic container for flow content. It has no effect on the content or layout until styled using CSS.",
      }

      def hover(node : Ast::HtmlElement, workspace) : Array(String | Nil)
        [
          "**#{node.tag.value}**\n",
          HTML_ELEMENTS[node.tag.value]?.try { |value| HTML.escape(value) },
        ]
      end
    end
  end
end
