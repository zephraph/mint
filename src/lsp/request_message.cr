module LSP
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

  class ResponseError
    include JSON::Serializable

    property code : Int32
    property message : String
  end

  class ResponseMessage
    include JSON::Serializable

    property id : Int32 | String | Nil
  end

  class NotificationMessage
    include JSON::Serializable

    property method : String

    def execute(server : Server)
    end
  end

  abstract class RequestMessage
    include JSON::Serializable

    property id : Int32 | String
    property method : String

    abstract def execute(server : Server)
  end
end
