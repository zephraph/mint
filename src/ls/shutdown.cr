module Mint
  module LS
    class Shutdown < LSP::RequestMessage
      def execute(server)
        server.send({
          jsonrpc: "2.0",
          id:      id,
          result:  nil,
        })
      end
    end
  end
end
