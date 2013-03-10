require 'remit/common'

module Remit

  class InboundRequest
    include ConvertKey
    extend SignatureUtilsForOutbound

    protected :convert_key

    attr_reader :allow_sigv1

    # BJM: need to access sometimes from the app
    attr_reader :hash_params
    # signature key name
    SIGNATURE_KEY = 'signature'

    ##
    # +request_url+ is the full request path up to the query string, as from request.url in the controller
    # +params+ is the full params hash from the controller
    # +client+ is a fully instantiated Remit::API with access keys and sandbox settings
    #
    # Only clean params hash is params is sent as a hash.
    # Assume caller has cleaned string if string is sent as params
    def initialize(request_url, params, client, options = {})

      if params.is_a?(String)
        @string_params = params
        @hash_params = Hash.from_url_params(params)
      else
        options[:skip_param_keys] ||= []
        #this is a bit of helpful sugar for rails framework users
        options[:skip_param_keys] |= ['action','controller']

        if params.respond_to?(:reject)
          params.reject! {|key, val| options[:skip_param_keys].include?(key) }
        else
          params = {}
        end
        @hash_params      = params
        @string_params    = InboundRequest.get_http_params(@hash_params)
      end

      @request_url        = request_url
      @client             = client
    end

    def valid?

      if @hash_params['signatureVersion'].to_i == 2

        return false unless InboundRequest.check_parameters(@hash_params)
        verify_request = Remit::VerifySignature::Request.new(
          :url_end_point => @request_url,
          :http_parameters => @string_params
        )

        result = @client.verify_signature(verify_request)
        result.verify_signature_result.verification_status == 'Success'

      else
        false
      end
    end

    def method_missing(method, *args, &block) #:nodoc:
      return @hash_params[method.to_s] if @hash_params.has_key?(method.to_s)
      return @hash_params[method.to_sym] if @hash_params.has_key?(method.to_sym)
      key = self.convert_key(method)
      return @hash_params[key] if @hash_params.has_key?(key)
      return @hash_params[key.to_s] if @hash_params.has_key?(key.to_s)
      super
    end
  end

end
