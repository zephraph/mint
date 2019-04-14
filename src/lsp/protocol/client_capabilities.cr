module LSP
  struct ClientCapabilities
    include JSON::Serializable

    property workspace : WorkspaceClientCapabilities
  end
end
