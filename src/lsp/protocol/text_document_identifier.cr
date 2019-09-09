module LSP
  class TextDocumentIdentifier
    include JSON::Serializable

    property uri : String
  end
end
