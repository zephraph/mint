require "../spec_helper"

describe "Language Server - DidChange" do
  it "there should be no error" do
    with_workspace do |workspace|
      workspace.file "test.mint", <<-MINT
      component Test {
        fun render : Html {
          <div></div>
        }
      }
      MINT

      notify_lsp(
        method: "textDocument/didChange",
        message: {
          textDocument:   {uri: workspace.file_path("test.mint"), version: 1},
          contentChanges: [{text: "component Test { fun render : Html { ", range: nil, rangeLength: nil}],
        }
      )

      workspace.workspace.error.should_not eq(nil)
    end
  end
end
