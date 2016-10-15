class Event
  include Mongoid::Document

  field :o, as: :order, type: Integer
  field :n, as: :name, type: String
  field :d, as: :distance, type: Float
  field :u, as: :units, type: String

  embedded_in :parent, polymorphic: true, touch: true

  validates_presence_of :order
  validates_presence_of :name

  def meters
  	case self.units
  	when "meters"
  		return self.distance
  	when "kilometers"
  		return self.distance * 1000
  	when "yards"
  		return self.distance * 0.9144
  	when "miles"
  		return self.distance * 1609.344
  	end
  	return nil
  end

  def miles
  	case self.units
  	when "meters"
  		return self.distance * 0.000621371
  	when "kilometers"
  		return self.distance * 0.621371
  	when "yards"
  		return self.distance * 0.000568182
  	when "miles"
  		return self.distance
  	end
  	return nil
  end

end
