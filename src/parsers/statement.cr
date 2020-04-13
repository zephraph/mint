module Mint
  class Parser
    def statement(parent) : Ast::Statement | Nil
      start do |start_position|
        target = start do
          value = variable(track: false) || tuple_destructuring
          whitespace
          skip unless keyword "="
          whitespace
          value
        end

        body = expression

        skip unless body

        self << Ast::Statement.new(
          expression: body.as(Ast::Expression),
          from: start_position,
          target: target,
          parent: parent,
          to: position,
          input: data)
      end
    end
  end
end
