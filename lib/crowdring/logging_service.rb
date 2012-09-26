module Crowdring
  class LoggingRequest
    attr_reader :from, :to

    def initialize(request)
      @to = request.GET['to']
      @from = request.GET['from']
    end

    def callback?
      false
    end
  end

  class LoggingService 
    attr_reader :last_sms, :last_broadcast

    def initialize(numbers, opts={})
      @numbers = numbers
      @do_output = opts[:output]
    end

    def supports_outgoing?
      true
    end

    def transform_request(request)
      LoggingRequest.new(request)
    end

    def build_response(from, commands)
      @last_response = "Reponse: From: #{from}, Commands: #{commands}"
      p @last_response if @do_output
      @last_response
    end

    def numbers
      @numbers
    end

    def send_sms(params)
      @last_sms = params
      p "Send SMS: #{params}" if @do_output
    end

    def broadcast(from, msg, to_numbers)
      @last_broadcast = {from: from, msg: msg, to_numbers: to_numbers }
      p "Broadcast: from: #{from}, msg: '#{msg}', to: #{to_numbers}" if @do_output
    end

  end
end