class CallsController < ApplicationController

  before_action :set_call, :only => [:make_call]

 # GET /calls
 # display all previous calls + a form for entering a new call
  def index
  	@call = Call.new
    @calls = Call.all
  end

  # GET /calls/new
  def new
    @call = Call.new
  end

  # POST /calls
  # creating a call in this app is synonymous with calling the #
  def create
    @call = Call.new(call_params)

    if @call.save    	
    	flash[:notice] = 'Telephone number was logged.'
    	make_call
    else
    	flash[:notice] = 'There was an error with that telephone number.'
    	flash[:errors] = @call.errors.full_messages
    	redirect_to :action => 'index'
    end
  end

  # POST /calls/:id/make_call
  def make_call
  	# either set flash or append to it, this informational message
  	(flash[:notice] ||= "") << " Dialing " + @call.tel_num + "..."

  	# let the twilio controller handle calling the #
  	redirect_to :controller => "twilio", :action => "initiate_call",
  		:tel_num => @call.tel_num, :call_id => @call.id
  end

  private
    def set_call
      @call = Call.find(params[:id])
    end

    def call_params
      params.require(:call).permit(:tel_num, :call_dt, :delay)
    end

end