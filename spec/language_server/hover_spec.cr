require "../spec_helper"

describe "Language Server - Hover" do
  it "returns information about HTML elements" do
    with_workspace do |workspace|
      workspace.file "test.mint", <<-MINT
      component Test {
        fun render : Html {
          <div></div>
        }
      }
      MINT

      expect_lsp(
        id: 0,
        method: "textDocument/hover",
        message: {
          textDocument: {uri: workspace.file_path("test.mint")},
          position:     {line: 2, character: 5},
        },
        expected: {
          jsonrpc: "2.0",
          id:      0,
          result:  [
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
