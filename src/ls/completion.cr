module LSP
  enum CompletionItemKind
    Text          =  1
    Method        =  2
    Function      =  3
    Constructor   =  4
    Field         =  5
    Variable      =  6
    Class         =  7
    Interface     =  8
    Module        =  9
    Property      = 10
    Unit          = 11
    Value         = 12
    Enum          = 13
    Keyword       = 14
    Snippet       = 15
    Color         = 16
    File          = 17
    Reference     = 18
    Folder        = 19
    EnumMember    = 20
    Constant      = 21
    Struct        = 22
    Event         = 23
    Operator      = 24
    TypeParameter = 25
  end

  struct CompletionItem
    include JSON::Serializable

    # The label of this completion item. By default
    # also the text that is inserted when selecting
    # this completion.
    property label : String

    # The kind of this completion item. Based of the kind
    # an icon is chosen by the editor.
    property kind : CompletionItemKind

    # A human-readable string with additional information
    # about this item, like type or symbol information.
    property detail : String

    # A human-readable string that represents a doc-comment.
    property documentation : String

    # Indicates if this item is deprecated.
    property deprecated : Bool

    # Select this item when showing.
    #
    # *Note* that only one completion item can be selected and that the
    # tool / client decides which item that is. The rule is that the *first*
    # item of those that match best is selected.
    property preselect : Bool

    # A string that should be used when comparing this item
    # with other items. When `falsy` the label is used.
    @[JSON::Field(key: "sortText")]
    property sort_text : String

    # A string that should be used when filtering a set of
    # completion items. When `falsy` the label is used.
    @[JSON::Field(key: "filterText")]
    property filter_text : String

    # A string that should be inserted into a document when selecting
    # this completion. When `falsy` the label is used.
    #
    # The `insertText` is subject to interpretation by the client side.
    # Some tools might not take the string literally. For example
    # VS Code when code complete is requested in this example `con<cursor position>`
    # and a completion item with an `insertText` of `console` is provided it
    # will only insert `sole`. Therefore it is recommended to use `textEdit` instead
    # since it avoids additional client side interpretation.
    #
    # @deprecated Use textEdit instead.
    @[JSON::Field(key: "insertText")]
    property insert_text : String

    def initialize(@label,
                   @filter_text,
                   @sort_text,
                   @kind,
                   @detail,
                   @documentation,
                   @deprecated,
                   @preselect,
                   @insert_text)
    end
  end
end

module Mint
  module LS
    class Completion < LSP::RequestMessage
      property params : LSP::CompletionParams

      def execute(server)
        workspace =
          Mint::Workspace[params.path]

        items =
          workspace.ast.components.map do |component|
            index = 0

            attributes =
              component
                .properties
                .reject(&.name.value.==("children"))
                .map do |property|
                  default =
                    Mint::Formatter
                      .new(workspace.ast, workspace.json.formatter_config)
                      .format(property.default)
                      .gsub("}", "\\}")

                  type =
                    workspace.type_checker.cache[property]? || Mint::TypeChecker::Type.new("")

                  value =
                    case type.name
                    when "String"
                      if default == %("")
                        %("${#{index + 2}}")
                      else
                        %(${#{index + 2}:#{default}})
                      end
                    when "Array"
                      %([${#{index + 2}}])
                    else
                      %({${#{index + 2}:#{default}}\\})
                    end

                  result =
                    "${#{index + 1}:#{property.name.value}=#{value}}"

                  index += 2

                  result
                end
                .to_a

            snippet =
              if attributes.size > 3
                <<-MINT
                <#{component.name}
                  #{attributes.join("\n  ")}>
                  $0
                </#{component.name}>
                MINT
              else
                <<-MINT
                <#{component.name} #{attributes.join(" ")}>
                  $0
                </#{component.name}>
                MINT
              end

            LSP::CompletionItem.new(
              label: component.name,
              filter_text: component.name,
              sort_text: component.name,
              kind: LSP::CompletionItemKind::Snippet,
              detail: "Component",
              documentation: "",
              deprecated: false,
              preselect: false,
              insert_text: snippet,
            )
          end

        server.send({
          jsonrpc: "2.0",
          id:      id,
          result:  items,
        })
      end
    end
  end
end
