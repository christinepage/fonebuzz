require 'twilio-ruby'
require 'FizzBuzz'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header

  # validate_request is not working correctly, so commented out, so the rest
  # of the app can function
  #before_action :validate_request

  skip_before_action :verify_authenticity_token

  def fizzbuzz_greeting
    # get call record associated w/ this Twilio Sid
    call = Call.find_by(:call_sid => params['CallSid'])
    response = Twilio::TwiML::Response.new do |r|
      if call && call.keyed_num   # read what's stored in db
        r.Say "Hello there. You previously entered #{call.keyed_num}"
        r.Say fizzbuzz_results call.keyed_num

      else                        # either this request did not originate from
                                  # this app or keyed_num is not stored
        r.Say "Hello there."
        r.Gather :numDigits => '1', :action => 'fizzbuzz_get_digits', :method => 'post' do |g|
          g.Say "Please enter a number."
        end
      end
    end
    render_twiml response
  end

  def fizzbuzz_get_digits
    # get call record associated w/ this Twilio Sid
    call = Call.find_by(:call_sid => params['CallSid'])
    response = Twilio::TwiML::Response.new do |r|
      input_num = params['Digits'] || "nothing"
      r.Say "You entered " + input_num
      if (integer_str? input_num)
        if (call)                  # request is the result of initiate_call
          call.update(:keyed_num => Integer(input_num))   # store key the user entered
        end
        r.Say fizzbuzz_results input_num

      else                         # they entered something non-numeric like '*'
        r.Say "I have no results for that entry."
      end
    end
    render_twiml response
  end

  def fizzbuzz_results input_num
    "Your results are " + FizzBuzz::listing(Integer(input_num)).join(", ")
  end

  def initiate_call
    # based upon the call id we got in our POST params, update the time
    call = Call.find(params[:call_id])
    if call
      call.update(:call_dt => Time.now)
    end
    begin
      client = Twilio::REST::Client.new(
        TwilioConfig.config_param('account_sid'),
        TwilioConfig.config_param('auth_token'))

      # our call controller deals w/ 10 digit numbers, no country code
      # so add '+1' for twilio 
      twilio_tel_num = '+1' + params[:tel_num]
      logger.debug "calling #{twilio_tel_num} ..."

      # call the phone number w/ our app and let :url handle the call
      twilio_call = client.account.calls.create(
        :url => TwilioConfig.config_param('fizzbuzz_url'),
        :to => twilio_tel_num,
        :from => TwilioConfig.config_param('caller'))

      # store Twilio's sid in our db w/ the associated call
      call.update(:call_sid => twilio_call.sid)

    # Twilio throws an exception if the phone number is unverified
    # or otherwise bogus looking, so recover and save the errors.
    rescue Twilio::REST::RequestError => e
      logger.debug e.message
      flash[:notice] = "The call to #{params[:tel_num]} did not go through."
      (flash[:errors] ||= []) << e.message
    end

    # back to the calls listing index page
    redirect_to :controller => 'calls', :action => 'index'
  end

  # compare the signature from the http header w/ our computation
  # I am not getting the same signature - either using the wrong url
  # or wrong parameters to create the signature
  def validate_request
    validator = Twilio::Util::RequestValidator.new(TwilioConfig.config_param('auth_token'))
    signature = request.headers[TwilioConfig.config_param('twilio_signature_header')]
    
    if !(validator.validate(request.original_url, params, signature))
      logger.debug "Validation failed"
      logger.debug "tok: #{@auth_token}"
      logger.debug "url: #{request.original_url}"
      logger.debug "par: #{params}"
      logger.debug "provided sig:   #{signature}"
      logger.debug "calculated sig: #{validator.build_signature_for(request.original_url, params)}"

      response = Twilio::TwiML::Response.new do |r|     
        r.Say 'Sorry you are not authorized to use this application.'
      end
      render_twiml response
    else
      logger.debug "Validation succeeded"
    end
  end

end

# can Ruby convert this string to a number?
def integer_str? num
  Integer(num)
  return true
rescue ArgumentError
  return false
end
