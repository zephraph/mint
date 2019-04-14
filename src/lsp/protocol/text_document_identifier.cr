module LSP
  struct TextDocumentIdentifier
    include JSON::Serializable

    property uri : String
  end
end
