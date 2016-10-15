class Photo
  include Mongoid::Document

  attr_accessor :id, :location
  attr_writer :contents

  # Photos
  
  def self.mongo_client
    Mongoid::Clients.default
  end

  def initialize doc=nil
  	if doc
  		@id = doc[:_id].to_s
      @location = Point.new(doc[:metadata][:location]) if doc[:metadata][:location]
      @place = doc[:metadata][:place].to_s if doc[:metadata][:place]
  	end
  end

  def persisted?
  	!@id.nil?
  end

  def save
    if @contents
      @contents.rewind
      gps = EXIFR::JPEG.new(@contents).gps
    	@location = Point.new({ lng: gps.longitude, lat: gps.latitude })
    end
    description = {}
    description[:content_type] = "image/jpeg"
    description[:metadata] = {}
    description[:metadata][:location] = @location.to_hash if @location
    description[:metadata][:place] = BSON::ObjectId.from_string(@place) if @place
    if persisted?
      self.class.mongo_client.database.fs.find(_id: BSON::ObjectId.from_string(id)).update_one(metadata: description[:metadata])
    else
      @contents.rewind
      gf = Mongo::Grid::File.new(@contents.read, description)
      @id = self.class.mongo_client.database.fs.insert_one(gf).to_s
    end
    return @id
  end

  def self.all(offset=0, limit=nil)
  	if limit
  		results = mongo_client.database.fs.find.skip(offset).limit(limit)
  	else
  		results = mongo_client.database.fs.find.skip(offset)
  	end
  	results.to_a.map { |doc| Photo.new(doc) }
  end

  def self.find id
  	result = mongo_client.database.fs.find(_id: BSON::ObjectId.from_string(id)).first
  	return nil if result.nil?
  	@id = id
    @location = Point.new(result[:metadata][:location]) if result[:metadata][:location]
    @place = result[:metadata][:place].to_s if result[:metadata][:place]
  	return Photo.new(result)
  end

  def contents
  	result = self.class.mongo_client.database.fs.find_one(_id: BSON::ObjectId.from_string(@id))
  	return nil if result.nil?
  	buffer = ""
  	result.chunks.reduce([]) do |x, chunk|
  		buffer << chunk.data.data
  	end
  	return buffer
  end

  def destroy
    self.class.mongo_client.database.fs.find(_id: BSON::ObjectId.from_string(@id)).delete_one
  end

  # Relationships
  
  def find_nearest_place_id max_distance
    coll = Place.near(@location, max_distance).limit(1).projection(_id: true).first
    return coll ? coll[:_id] : nil
  end

  def place
    return @place ? Place.find(@place) : nil
  end

  def place=param
    if param.is_a?(Place)
      @place = param.id
    elsif param.is_a?(BSON::ObjectId)
      @place = param.to_s
    elsif param.is_a?(String)
      @place = param
    end
  end

  def self.find_photos_for_place id
    if id.is_a?(String)
      mongo_client.database.fs.find("metadata.place": BSON::ObjectId.from_string(id))
    else
      mongo_client.database.fs.find("metadata.place": id)
    end
  end
  
end
