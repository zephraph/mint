require "../spec_helper"

describe "Language Server Completion" do
  it "returns snippets for html components while in a Html function" do
    with_workspace do |workspace|
      workspace.file "test.mint", <<-MINT
      component Test {
        fun render : Html {
          <></>
        }
      }
      MINT

      expect_lsp(
        id: 0,
        method: "textDocument/completion",
        message: {
          textDocument: {uri: workspace.file_path("test.mint")},
          position:     {line: 2, character: 4},
        },
        expected: {
          jsonrpc: "2.0",
          id:      0,
          result:  [
            {
              label:         "Test",
              kind:          15,
              detail:        "Component",
              documentation: "",
              deprecated:    false,
              preselect:     false,
              sortText:      "Test",
              filterText:    "Test",
              insertText:    "<Test >\n  $0\n</Test>",
            },
            {
              label:         "Html.Portals.Body",
              kind:          15,
              detail:        "Component",
              documentation: "",
              deprecated:    false,
              preselect:     false,
              sortText:      "Html.Portals.Body",
              filterText:    "Html.Portals.Body",
              insertText:    "<Html.Portals.Body >\n  $0\n</Html.Portals.Body>",
            },
            {
              label:         "Unless",
              kind:          15,
              detail:        "Component",
              documentation: "",
              deprecated:    false,
              preselect:     false,
              sortText:      "Unless",
              filterText:    "Unless",
              insertText:    "<Unless ${1:condition={${2:true}\\}}>\n  $0\n</Unless>",
            },
            {
              label:         "If",
              kind:          15,
              detail:        "Component",
              documentation: "",
              deprecated:    false,
              preselect:     false,
              sortText:      "If",
              filterText:    "If",
              insertText:    "<If ${1:condition={${2:true}\\}}>\n  $0\n</If>",
            },
            {
              label:         "render",
              kind:          3,
              detail:        "Function",
              documentation: "",
              deprecated:    false,
              preselect:     false,
              sortText:      "render",
              filterText:    "render",
              insertText:    "render()",
            },
          ],
        }
      )
    end
  end

  it "returns completions while in a function" do
    with_workspace do |workspace|
      workspace.file "test.mint", <<-MINT
      component Test {
        fun otherFunction (name : String) : String {
          name
        }

        fun render : String {
          "Hello"
        }
      }
      MINT

      expect_lsp(
        id: 0,
        method: "textDocument/completion",
        message: {
          textDocument: {uri: workspace.file_path("test.mint")},
          position:     {line: 2, character: 4},
        },
        expected: {
          jsonrpc: "2.0",
          id:      0,
          result:  [
            {
              label:         "name",
              kind:          6,
              detail:        "Argument",
              documentation: "",
              deprecated:    false,
              preselect:     false,
              sortText:      "name",
              filterText:    "name",
              insertText:    "name",
            },
            {
              label:         "otherFunction",
              kind:          3,
              detail:        "Function",
              documentation: "",
              deprecated:    false,
              preselect:     false,
              sortText:      "otherFunction",
              filterText:    "otherFunction",
              insertText:    "otherFunction(${1:name})",
            },
            {
              label:         "render",
              kind:          3,
              detail:        "Function",
              documentation: "",
              deprecated:    false,
              preselect:     false,
              sortText:      "render",
              filterText:    "render",
              insertText:    "render()",
            },
          ],
        }
      )
    end
  end
end
