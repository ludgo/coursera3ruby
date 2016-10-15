class Point

  attr_accessor :longitude, :latitude

  def initialize hash
  	if hash[:lng] && hash[:lat]
  		@longitude = hash[:lng]
  		@latitude = hash[:lat]
  	elsif hash[:type] && hash[:type] == "Point" && hash[:coordinates]
  		@longitude = hash[:coordinates][0]
  		@latitude = hash[:coordinates][1]
  	end
  end

  def to_hash
  	hash = Hash.new
  	hash[:type] = "Point"
  	hash[:coordinates] = [@longitude, @latitude]
  	return hash
  end

end
