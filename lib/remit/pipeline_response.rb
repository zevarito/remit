module Remit

  class PipelineResponse < InboundRequest

    def successful?
      [
        Remit::PipelineStatusCode::SUCCESS_UNCHANGED,
        Remit::PipelineStatusCode::SUCCESS_ABT,
        Remit::PipelineStatusCode::SUCCESS_ACH,
        Remit::PipelineStatusCode::SUCCESS_CC,
        Remit::PipelineStatusCode::SUCCESS_RECIPIENT_TOKEN_INSTALLED
      ].include?(@hash_params['status'])
    end

    def aborted?
      @hash_params['status'] == Remit::PipelineStatusCode::ABORTED
    end
  end
end
