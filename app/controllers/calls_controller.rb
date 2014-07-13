class CallsController < ApplicationController

  before_action :set_call, :only => [:make_call]

 # GET /calls
  def index
  	@call = Call.new
    @calls = Call.all
  end

  # GET /calls/new
  def new
    @call = Call.new
  end

  # POST /calls
  def create
    @call = Call.new(call_params)

    if @call.save    	
    	flash[:notice] = 'Telephone number was logged.'
    	make_call
    else
    	render action: 'new'
    end
  end

  def make_call
  	(flash[:notice] ||= "") << " Dialing " + @call.tel_num + "..."
  	redirect_to :action => 'index'
  end

  private
    def set_call
      @call = Call.find(params[:id])
    end

    def call_params
      params.require(:call).permit(:tel_num, :call_dt, :delay)
    end

end
