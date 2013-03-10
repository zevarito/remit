require 'remit/common'

module Remit
  module Reserve
    class Request < Remit::Request
      action :Reserve

      parameter :caller_reference, :required => true
      parameter :sender_token_id, :required => true
      parameter :transaction_amount, :type => Remit::RequestTypes::Amount, :required => true

      parameter :caller_description
      parameter :descriptor_policy
      parameter :override_ipn_url
      parameter :sender_description
      parameter :transaction_timeout_in_mins
    end

    class Response < Remit::Response
      parameter :reserve_result, :type => Remit::TransactionResponse
      parameter :response_metadata, :type=>ResponseMetadata
    end

    def reserve(request = Request.new)
      call(request, Response)
    end
  end
end
 
