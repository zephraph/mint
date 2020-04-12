require "log"

module LSP
  class Server
    Backend = ::Log::IOBackend.new(File.new("lsp.log", "w+"))

    Log = ::Log.for("lsp")
    ::Log.builder.bind "*", :debug, Backend

    @@methods = {} of String => RequestMessage.class | NotificationMessage.class

    macro method(name, message)
      @@methods[{{name}}] = {{message}}
    end

    def initialize(@in : IO, @out : IO)
    end

    def prepend_header(content)
      "Content-Length: #{content.bytesize}\r\n\r\n#{content}"
    end

    def send(message)
      @out << prepend_header(message.to_json)
      @out.flush
    end

    def log(message)
      # Log.info { message }

      send({
        jsonrpc: "2.0",
        method:  "window/logMessage",
        params:  {
          type:    4,
          message: message,
        },
      })
    end

    def read
      MessageParser.parse(@in) do |name, json|
        log(name)
        method = @@methods[name]?

        if method
          method
            .from_json(json)
            .execute(self)
        end
      end
    rescue error
      log(error.to_s)
      error.backtrace?.try(&.each { |item| log(item) })
    end
  end
end
