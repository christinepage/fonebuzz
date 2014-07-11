require 'twilio-ruby'
 
class TwilioController < ApplicationController
  include Webhookable
 
  after_filter :set_header
  
  skip_before_action :verify_authenticity_token
 
  def voice
    people = {
    '+14158675309' => 'Curious George',
    '+14158644854' => 'Christine'
    }
   
    name = people[params['From']] || "monkey"
    response = Twilio::TwiML::Response.new do |r|
      r.Say "#{name}, please enter a number", :voice => 'alice'
      #r.Play 'http://linode.rabasa.com/cantina.mp3'
    end
 
    render_twiml response
  end
end