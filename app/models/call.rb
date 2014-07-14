class Call < ActiveRecord::Base
	before_validation :tel_num_sanitize, :delay_sanitize
	validates_presence_of :tel_num, :message=>"cannot be blank"
	validates_length_of :tel_num, :is=>10, :message=>"must be of length 10"

	def tel_num_sanitize
    self.tel_num = tel_num.gsub(/[^0-9]/, "")
  end

  def delay_sanitize
  	self.delay ||= 0
  end

end
