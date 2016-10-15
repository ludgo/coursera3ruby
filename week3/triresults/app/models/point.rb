class Point

	attr_accessor :longitude, :latitude

	def mongoize
		point = Hash.new
		point[:type] = "Point"
		point[:coordinates] = [@longitude, @latitude]
		return point
	end

	def self.mongoize object
		case object
			when nil
				return nil
			when Hash
				return object
			when Point
				return object.mongoize
		end
	end

	def self.demongoize object
		case object
			when nil
				return nil
			when Hash
				point = Point.new
				point.longitude = object[:coordinates][0]
				point.latitude = object[:coordinates][1]
				return point
			when Point
				return object
		end
	end

	def self.evolve object
		self.class.mongoize object
	end

end
