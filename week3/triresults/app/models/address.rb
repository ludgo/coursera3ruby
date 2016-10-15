class Address

	attr_accessor :city, :state, :location

	def mongoize
		address = Hash.new
		address[:city] = @city
		address[:state] = @state
		address[:loc] = Point.mongoize(@location)
		return address
	end

	def self.mongoize object
		case object
			when nil
				return nil
			when Hash
				return object
			when Address
				return object.mongoize
		end
	end

	def self.demongoize object
		case object
			when nil
				return nil
			when Hash
				address = Address.new
				address.city = object[:city]
				address.state = object[:state]
				address.location = Point.demongoize(object[:loc])
				return address
			when Address
				return object
		end
	end

	def self.evolve object
		self.class.mongoize object
	end

end
