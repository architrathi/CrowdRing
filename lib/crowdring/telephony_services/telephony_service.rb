module Crowdring
  class TelephonyService
    def sms?
      false
    end

    def voice?
      false
    end

    def self.supports(*types)
      types.each {|type| define_method("#{type}?") { true }}
    end

    def self.request_handler(klass, &extra_params) 
      fun_block = extra_params ? proc {|request| klass.new(request, *extra_params.(self))} : proc {|request| klass.new(request)}
      define_method(:transform_request, fun_block) 
    end

    def send_request(uri)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
      request = Net::HTTP::Get.new(uri.request_uri)
      http.request(request)
    end

  end
end