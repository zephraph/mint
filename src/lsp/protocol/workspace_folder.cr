module LSP
  struct WorkspaceFolder
    include JSON::Serializable

    property uri : String
    property name : String
  end
end
