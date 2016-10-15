class Placing

	attr_accessor :name, :place

	def mongoize
		placing = Hash.new
		placing[:name] = @name
		placing[:place] = @place
		return placing
	end

	def self.mongoize object
		case object
			when nil
				return nil
			when Hash
				return object
			when Placing
				return object.mongoize
		end
	end

	def self.demongoize object
		case object
			when nil
				return nil
			when Hash
				placing = Placing.new
				placing.name = object[:name]
				placing.place = object[:place]
				return placing
			when Placing
				return object
		end
	end

	def self.evolve object
		self.class.mongoize object
	end

end
