#Geospatial Queries

class GeoService

  def initialize(db)
    @db = db
  end

  def pcode_bounds(pcode)
    @db[:pcode_bounds]
    .where(pcode: pcode)
    .select(:swlat,:swlng,:nelat,:nelng)
    .map { |row|
    {"swlat" => row[:swlat], "swlng" => row[:swlng], "nelat" => row[:nelat], "nelng" => row[:nelng]}}
  end

end
