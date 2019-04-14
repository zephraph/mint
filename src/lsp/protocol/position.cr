module LSP
  struct Position
    include JSON::Serializable

    property line : Int32
    property character : Int32
  end
end
