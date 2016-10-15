class SwimResult < LegResult

  field :pace_100, type: Float

  def calc_ave
  	if event && secs
  		meters = event.meters
  		self.pace_100 = meters.nil? ? nil : (100 * secs / meters)
  	end
  end

end
