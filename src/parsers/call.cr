module Mint
  class Parser
    syntax_error CallExpectedClosingParentheses

    def call(lhs : Ast::Expression) : Ast::Expression
      start do |start_position|
        char '(', SkipError

        whitespace
        arguments = list(
          terminator: ')',
          separator: ','
        ) { expression.as(Ast::Expression | Nil) }.compact
        whitespace

        char ')', CallExpectedClosingParentheses

        node = self << Ast::Call.new(
          partially_applied: false,
          from: start_position,
          arguments: arguments,
          expression: lhs,
          piped: false,
          to: position,
          input: data
        )

        array_access_or_call(node)
      end || lhs
    end
  end
end
