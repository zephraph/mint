require "json"
require "./lsp/**"

require "./all"

module LSP
  struct Workspace
    include JSON::Serializable

    # The server supports workspace folder.
    @[JSON::Field(key: "workspaceFolders")]
    property workspace_folders : WorkspaceFolders

    def initialize(@workspace_folders)
    end
  end

  struct WorkspaceFolders
    include JSON::Serializable

    # The server has support for workspace folders
    property supported : Bool

    # Whether the server wants to receive workspace folder
    # change notifications.
    #
    # If a strings is provided the string is treated as a ID
    # under which the notification is registered on the client
    # side. The ID can be used to unregister for these events
    # using the `client/unregisterCapability` request.
    @[JSON::Field(key: "changeNotifications")]
    property change_notifications : String | Bool

    def initialize(@supported, @change_notifications)
    end
  end

  struct WorkspaceClientCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "applyEdit")]
    property apply_edit : Bool

    @[JSON::Field(key: "workspaceEdit")]
    property workspace_edit : NamedTuple(document_changes: Bool) | Nil
  end

  struct WorkspaceFolder
    include JSON::Serializable

    property uri : String
    property name : String
  end

  struct TextDocumentClientCapabilities
  end

  struct ClientCapabilities
    include JSON::Serializable

    property workspace : WorkspaceClientCapabilities
  end

  struct InitializeParams
    include JSON::Serializable

    @[JSON::Field(key: "processId")]
    property process_id : Int32 | Nil

    @[JSON::Field(key: "workspaceFolders")]
    property root_uri : String | Nil

    property capabilities : ClientCapabilities

    property trace : String | Nil

    @[JSON::Field(key: "workspaceFolders")]
    property workspace_folders : Array(WorkspaceFolder) | Nil
  end
end

class Initialize < LSP::RequestMessage
  property params : LSP::InitializeParams

  def execute(server)
    capabilities =
      LSP::ServerCapabilities.new(
        text_document_sync: 0,
        hover_provider: true,
        completion_provider: LSP::CompletionOptions.new(
          resolve_provider: true,
          trigger_characters: ["<", "."]),
        signature_help_provider: LSP::SignatureHelpOptions.new(
          trigger_characters: [":"] of String),
        definition_provider: false,
        type_definition_provider: false,
        implementation_provider: false,
        references_provider: false,
        document_highlight_provider: false,
        document_symbol_provider: false,
        workspace_symbol_provider: false,
        code_action_provider: false,
        code_lens_provider: LSP::CodeLensOptions.new(
          resolve_provider: false),
        document_formatting_provider: false,
        document_range_formatting_provider: false,
        document_on_type_formatting_provider: LSP::DocumentOnTypeFormattingOptions.new(
          first_trigger_character: "",
          more_trigger_character: [] of String),
        rename_provider: false,
        document_link_provider: LSP::DocumentLinkOptions.new(
          resolve_provider: false),
        color_provider: false,
        folding_range_provider: false,
        declaration_provider: false,
        execute_command_provider: LSP::ExecuteCommandOptions.new(
          commands: [] of String),
        workspace: LSP::Workspace.new(
          workspace_folders: LSP::WorkspaceFolders.new(
            supported: false,
            change_notifications: false)))

    server.log(id)
    server.send({
      jsonrpc: "2.0",
      id:      id,
      result:  LSP::InitializeResult.new(capabilities: capabilities),
    })
  end
end

class Shutdown < LSP::RequestMessage
  def execute(server)
    server.send({
      jsonrpc: "2.0",
      id:      id,
      result:  nil,
    })
  end
end

class Exit < LSP::NotificationMessage
  property params : Hash(String, String)

  def execute(server)
    exit(0)
  end
end

struct TextDocumentIdentifier
  include JSON::Serializable

  property uri : String
end

struct Position
  include JSON::Serializable

  property line : Int32
  property character : Int32
end

struct TextDocumentPositionParams
  include JSON::Serializable

  @[JSON::Field(key: "workspaceFolders")]
  property text_document : TextDocumentIdentifier
  property position : Position
end

class TextDocumentHover < LSP::RequestMessage
  property params : TextDocumentPositionParams

  def execute(server)
    uri = URI.parse(params.text_document.uri)

    workspace = Mint::Workspace[uri.path.to_s]

    contents = File.read(uri.path.to_s)

    char_count = 0
    line_count = 0
    line_char_count = 0

    while char = contents[char_count]?
      break if params.position.line == line_count &&
               params.position.character == line_char_count

      case char.to_s
      when "\n", "\r"
        line_count += 1
        line_char_count = 0
      end

      line_char_count += 1
      char_count += 1
    end

    node = workspace.ast.nodes.find do |item|
      next unless item.input.file == uri.path.to_s
      item.from <= char_count <= item.to
    end

    type_checker = Mint::TypeChecker.new(workspace.ast)
    type_checker.check

    contents =
      case node
      when Mint::Ast::Variable
        node.value
      when Mint::Ast::Node
        type = type_checker.cache[node]?

        if type
          type.to_pretty
        else
          "ASD"
        end
      else
        "WTF"
      end

    server.send({
      jsonrpc: "2.0",
      id:      id,
      result:  {
        contents: [node.class.to_s, contents],
      },
    })
  end
end

class TextDocumentCompletion < LSP::RequestMessage
  def execute(server)
    server.send({
      jsonrpc: "2.0",
      id:      id,
      result:  {
        isIncomplete: true,
        items:        [{
                  label:         "If",
                  kind:          1,
                  detail:        "WTF",
                  documentation: "",
                  deprecated:    false,
                  preselect:     false,
                  insertText:    "If",
                }],
      },
    })
  end
end

class Server < LSP::Server
  method "initialize", Initialize
  method "textDocument/hover", TextDocumentHover
  method "textDocument/completion", TextDocumentCompletion
  method "shutdown", Shutdown
  method "exit", Exit
end

module Test
  extend self

  def generate(message, method, id = Random.new.hex(5))
    body = {
      jsonrpc: "2.0",
      id:      id,
      params:  JSON.parse(message),
      method:  method,
    }.to_json

    "Content-Length: #{body.bytesize}\r\n\r\n#{body}"
  end
end

server = Server.new(STDIN, STDOUT)
loop do
  server.read
end
