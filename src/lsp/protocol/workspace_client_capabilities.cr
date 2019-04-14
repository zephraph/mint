module LSP
  struct WorkspaceClientCapabilities
    include JSON::Serializable

    @[JSON::Field(key: "applyEdit")]
    property apply_edit : Bool

    @[JSON::Field(key: "workspaceEdit")]
    property workspace_edit : NamedTuple(document_changes: Bool) | Nil
  end
end
