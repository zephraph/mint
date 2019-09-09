module LSP
  struct Range
    include JSON::Serializable

    # The range's start position.
    property start : Position

    # The range's end position.
    property end : Position
  end

  class VersionedTextDocumentIdentifier < TextDocumentIdentifier
    # The version number of this document. If a versioned text document identifier
    # is sent from the server to the client and the file is not open in the editor
    # (the server has not received an open notification before) the server can send
    # `null` to indicate that the version is known and the content on disk is the
    # truth (as speced with document content ownership).
    #
    # The version number of a document will increase after each change, including
    # undo/redo. The number doesn't need to be consecutive.
    property version : Int32 | Nil
  end

  struct DidChangeTextDocumentParams
    include JSON::Serializable

    # The document that did change. The version number points
    # to the version after all provided content changes have
    # been applied.
    @[JSON::Field(key: "textDocument")]
    property text_document : VersionedTextDocumentIdentifier

    # The actual content changes. The content changes describe single state changes
    # to the document. So if there are two content changes c1 and c2 for a document
    # in state S then c1 move the document to S' and c2 to S''.
    @[JSON::Field(key: "contentChanges")]
    property content_changes : Array(TextDocumentContentChangeEvent)
  end

  struct TextDocumentContentChangeEvent
    include JSON::Serializable

    # The range of the document that changed.
    property range : Range | Nil

    # The length of the range that got replaced.
    @[JSON::Field(key: "rangeLength")]
    property range_length : Int32 | Nil

    # The new text of the range/document.
    property text : String
  end
end

module Mint
  module LS
    class DidChange < LSP::NotificationMessage
      property params : LSP::DidChangeTextDocumentParams

      def execute(server)
        uri = URI.parse(params.text_document.uri)

        workspace = Workspace[uri.path.to_s]
        workspace.update(params.content_changes.first.text, uri.path)
        server.log(Workspace.workspaces.keys)
        server.log(params.to_json)
        server.log(workspace.cache.keys)
        server.log(uri.path)
      end
    end
  end
end
