
Mongo::Logger.logger.level = ::Logger::INFO

class Place
  include Mongoid::Document#
  include ActiveModel::Model

  attr_accessor :id, :formatted_address, :location, :address_components

  PLACES_COLLECTION='places'

  # Places Collection
  
  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    coll=ENV['PLACES_COLLECTION'] ||= PLACES_COLLECTION
    return mongo_client[coll]
  end

  def self.load_all io
  	array_of_hash = JSON.parse(io.read)
    collection.insert_many(array_of_hash)
  end

  def initialize params
  	@id = params[:_id].to_s
  	@formatted_address = params[:formatted_address]
  	@location = Point.new(params[:geometry][:geolocation])
  	@address_components = []
  	if params[:address_components]
  	  params[:address_components].each do |address_component|
  	    @address_components.push(AddressComponent.new(address_component))
  	  end
  	end
  end

  # Standard Queries

  def self.find_by_short_name short_name
  	collection.find( "address_components.short_name": short_name )
  	#collection.find( address_components: { :$elemMatch => { short_name: short_name } } )
  end

  def self.to_places coll
  	places = []
  	coll.each do |place|
  		places.push(Place.new(place))
  	end
  	return places
  end

  def self.find id
  	result = collection.find(_id: BSON::ObjectId.from_string(id)).first
  	return result.nil? ? nil : Place.new(result)
  end

  def self.all(offset=0, limit=nil)
  	if limit
  		to_places( collection.find.skip(offset).limit(limit) )
  	else
  		to_places( collection.find.skip(offset) )
  	end
  end

  def destroy
  	self.class.collection.delete_one(_id: BSON::ObjectId.from_string(@id))
  end

  # Aggregation Framework Queries
  
  def self.get_address_components(sort=nil, offset=0, limit=nil)
  	aggr = []
  	aggr.push( { :$unwind => "$address_components" } )
  	aggr.push( { :$project => { _id: true, address_components: true, formatted_address: true, "geometry.geolocation": true } } )
  	if sort
  		aggr.push( { :$sort => sort } )
  	end
  	if offset > 0
  		aggr.push( { :$skip => offset } )
  	end
  	if limit && limit > 0
  		aggr.push( { :$limit => limit } )
  	end
  	collection.find.aggregate(aggr)
  end

  def self.get_country_names
  	collection.find.aggregate([
  		{ "$unwind": "$address_components" },
  		{ "$unwind": "$address_components.types" },
  		{ "$project": { "address_components.long_name": true, "address_components.types": true } },
  		{ "$match": { "address_components.types": "country" } },
  		{ "$group": { _id: "$address_components.long_name" } }
  	]).to_a.map { |item| item[:_id] }
  end

  def self.find_ids_by_country_code country_code
  	collection.find.aggregate([
  		{ "$match": { "address_components.short_name": country_code } },
  		{ "$project": { _id: true } }
  	]).to_a.map { |item| item[:_id].to_s }
  end

  # Geolocation Queries
  
  def self.create_indexes
  	collection.indexes.create_one( "geometry.geolocation": Mongo::Index::GEO2DSPHERE )
  end

  def self.remove_indexes
  	collection.indexes.drop_all
  end

  def self.near(point, max_meters=nil)
  	near = { "$geometry": point.to_hash }
  	if max_meters
  		near["$maxDistance"] = max_meters
  	end
  	collection.find( { "geometry.geolocation": { "$near": near } } )
  end

  def near(max_meters=nil)
  	self.class.to_places( self.class.near(@location, max_meters) )
  end

  # Relationships

  def photos(offset=0, limit=nil)
    photos = []
    if limit
      Photo.find_photos_for_place(@id).skip(offset).limit(limit).to_a.map { |photo| photos.push(Photo.new photo) }
    else
      Photo.find_photos_for_place(@id).skip(offset).to_a.map { |photo| photos.push(Photo.new photo) }
    end
    return photos
  end

  ###
  
  def persisted?
    !@id.nil?
  end

end
