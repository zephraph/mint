require "json"
require "http"

module LanguageServer
  enum ErrorCodes
    ParseError           = -32700
    InvalidRequest       = -32600
    MethodNotFound       = -32601
    InvalidParams        = -32602
    InternalError        = -32603
    ServerErrorStart     = -32099
    ServerErrorEnd       = -32000
    ServerNotInitialized = -32002
    UnknownErrorCode     = -32001
    RequestCancelled     = -32800
  end

  class ResponseError(D)
    JSON.mapping(
      code: Int32,
      message: String,
      data: D)
  end

  class Message(P)
    JSON.mapping(
      jsonrpc: String,
      id: Int32 | String,
      method: String,
      params: P)

    def run
      {} of String => String
    end
  end

  module Messages
    class Initialize
      JSON.mapping(rootPath: String)

      def run
        {hoverProvider: true}
      end
    end
  end

  MESSAGES = {"initialize": Message(Messages::Initialize)}

  class NotificationMessage(P)
    JSON.mapping(
      jsonrpc: String,
      method: String,
      params: P)
  end

  class ResponseMessage(R, E)
    JSON.mapping(
      jsonrpc: String,
      id: Int32 | String | Nil,
      result: R,
      error: ResponseError(E))
  end

  class Position
    JSON.mapping(
      line: Int32,
      character: Int32)
  end

  class Range
    JSON.mapping(
      start: Position,
      end: Position)
  end

  class Command(A)
    JSON.mapping(
      title: String,
      command: String,
      arguments: A)
  end

  module MessageParser
    extend self

    def self.read_headers(io)
      headers = [] of Tuple(String, String)

      loop do
        header = read_header(io)
        break if header.nil?
        headers << header
      end

      headers
    end

    def self.read_header(io)
      io.gets.try do |raw|
        parts = raw.split(':')
        {parts[0].strip, parts[1].strip} if parts.size == 2
      end
    end

    def self.parse(io)
      headers = read_headers(io)
      content_length = headers.find(&.first.==("Content-Length")).try(&.last)

      if content_length
        content = io.read_string(content_length.to_i)
        json = JSON.parse(content)
        method = json["method"].as_s

        message = MESSAGES[method].from_json(content)

        Logger.log(message.to_json)

        message
      end
    end
  end

  class Client
    def initialize(@in : IO, @out : IO)
    end

    def prepend_header(content)
      "Content-Length: #{content.bytesize}\r\n\r\n#{content}"
    end

    def read
      MessageParser.parse(@in).try do |message|
        result = message.run

        @out << prepend_header(result.to_json)
        @out.flush
      end

      Logger.log("WTF")
    end
  end

  module Logger
    extend self

    def log(value)
      STDOUT << prepend_header({type: "window/logMessage", message: value}.to_json)
      STDOUT.flush
    end

    def prepend_header(content)
      "Content-Length: #{content.bytesize}\r\n\r\n#{content}"
    end
  end

  def self.start
    client = Client.new(STDIN)

    loop do
      client.read
    end
  end
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

a = <<-JSON
{
  "processId": 22913,
  "rootPath": "/Users/octref/Code/css-test",
  "rootUri": "file:///Users/octref/Code/css-test",
  "capabilities": {
    "workspace": {
      "applyEdit": true,
      "workspaceEdit": {
        "documentChanges": true
      },
      "didChangeConfiguration": {
        "dynamicRegistration": true
      },
      "didChangeWatchedFiles": {
        "dynamicRegistration": true
      },
      "symbol": {
        "dynamicRegistration": true,
        "symbolKind": {
          "valueSet": [
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            22,
            23,
            24,
            25,
            26
          ]
        }
      },
      "executeCommand": {
        "dynamicRegistration": true
      },
      "configuration": true,
      "workspaceFolders": true
    },
    "textDocument": {
      "publishDiagnostics": {
        "relatedInformation": true
      },
      "synchronization": {
        "dynamicRegistration": true,
        "willSave": true,
        "willSaveWaitUntil": true,
        "didSave": true
      },
      "completion": {
        "dynamicRegistration": true,
        "contextSupport": true,
        "completionItem": {
          "snippetSupport": true,
          "commitCharactersSupport": true,
          "documentationFormat": [
            "markdown",
            "plaintext"
          ],
          "deprecatedSupport": true
        },
        "completionItemKind": {
          "valueSet": [
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            22,
            23,
            24,
            25
          ]
        }
      },
      "hover": {
        "dynamicRegistration": true,
        "contentFormat": [
          "markdown",
          "plaintext"
        ]
      },
      "signatureHelp": {
        "dynamicRegistration": true,
        "signatureInformation": {
          "documentationFormat": [
            "markdown",
            "plaintext"
          ]
        }
      },
      "definition": {
        "dynamicRegistration": true
      },
      "references": {
        "dynamicRegistration": true
      },
      "documentHighlight": {
        "dynamicRegistration": true
      },
      "documentSymbol": {
        "dynamicRegistration": true,
        "symbolKind": {
          "valueSet": [
            1,
            2,
            3,
            4,
            5,
            6,
            7,
            8,
            9,
            10,
            11,
            12,
            13,
            14,
            15,
            16,
            17,
            18,
            19,
            20,
            21,
            22,
            23,
            24,
            25,
            26
          ]
        }
      },
      "codeAction": {
        "dynamicRegistration": true
      },
      "codeLens": {
        "dynamicRegistration": true
      },
      "formatting": {
        "dynamicRegistration": true
      },
      "rangeFormatting": {
        "dynamicRegistration": true
      },
      "onTypeFormatting": {
        "dynamicRegistration": true
      },
      "rename": {
        "dynamicRegistration": true
      },
      "documentLink": {
        "dynamicRegistration": true
      },
      "typeDefinition": {
        "dynamicRegistration": true
      },
      "implementation": {
        "dynamicRegistration": true
      },
      "colorProvider": {
        "dynamicRegistration": true
      },
      "foldingRange": {
        "dynamicRegistration": false,
        "rangeLimit": 5000,
        "lineFoldingOnly": true
      }
    }
  },
  "initializationOptions": {},
  "trace": "verbose",
  "workspaceFolders": [
    {
      "uri": "file:///Users/octref/Code/css-test",
      "name": "css-test"
    }
  ]
}
JSON

io = IO::Memory.new(Test.generate(a, "initialize"))
out_io = IO::Memory.new
client = LanguageServer::Client.new(io, out_io)
client.read
puts out_io.rewind.gets_to_end
# client = LanguageServer.start
