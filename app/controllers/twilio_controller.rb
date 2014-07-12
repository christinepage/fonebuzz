require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
  
  skip_before_action :verify_authenticity_token
 
  # def voice
  #   response = Twilio::TwiML::Response.new do |r|
  #     r.Say "#{name}, please enter a number"
  #   end
  #   render_twiml response
  # end

  def voice
    response = Twilio::TwiML::Response.new do |r|      
      r.Say 'Hello there. '
      r.Gather :numDigits => '1', :action => 'handle_gather', :method => 'post' do |g|
        g.Say 'Please enter a number.'        
      end
    end
    render_twiml response
  end

  def handle_gather
    response = Twilio::TwiML::Response.new do |r|
      input_num = params['Digits']
      r.Say 'You entered' + input_num
      if (integer_str? input_num)
        r.Say "Your results are " + fizzbuzz(Integer(input_num)).join(", ")
      else
        r.Say "I have no results for that entry."
      end
    end
    render_twiml response
  end
end


def integer_str? num
  Integer(num)
  return true
rescue ArgumentError
  return false
end

def fizzbuzz num
    (1..num).map do |x|
      if ((x%15) == 0)
        "FizzBuzz"
      elsif ((x%5) == 0)
        "Buzz"
      elsif ((x%3) == 0)
        "Fizz"
      else
        String(x)
      end
    end
end

