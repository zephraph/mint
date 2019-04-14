module Mint
  module LS
    class Exit < LSP::NotificationMessage
      property params : Hash(String, String)

      def execute(server)
        exit(0)
      end
    end
  end
end
