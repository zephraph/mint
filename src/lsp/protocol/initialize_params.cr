module LSP
  struct InitializeParams
    include JSON::Serializable

    @[JSON::Field(key: "processId")]
    property process_id : Int32 | Nil

    @[JSON::Field(key: "rootUri")]
    property root_uri : String | Nil

    property capabilities : ClientCapabilities

    property trace : String | Nil

    @[JSON::Field(key: "workspaceFolders")]
    property workspace_folders : Array(WorkspaceFolder) | Nil
  end
end
