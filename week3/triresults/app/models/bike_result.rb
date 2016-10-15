class BikeResult < LegResult

  field :mph, type: Float

  def calc_ave
  	if event && secs
  		miles = event.miles
  		self.mph = miles.nil? ? nil : (3600 * miles / secs)
  	end
  end

end
