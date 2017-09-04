#Geospatial Queries

class GeoService

  def initialize(db)
    @db = db
  end

#Get SA1s from postcode entry
  def pcode_sa1s(pcode)
    #Just query postcode -> lat,lng and then use point_sa1s duh
    @db[:sa1s]
    .where(postcode: pcode)
    .select(:sa1,:sa2_name_2011,:sa3_name_2011,:sa4_name_2011,:state_name_2011)
    .map { |row|
      [ row[:sa1], row[:sa2_name_2011], row[:sa3_name_2011],
      row[:sa4_name_2011], row[:state_name_2011] ]
    }.to_h
  end

#Get SA1s from point on map
  def point_sa1s(lat,lng,num_of)
    @db["EXECUTE nearest_sa1s(#{lng},#{lat},#{num_of});"]
    .map { |row|
      [ row[:sa1], row[:sa2_name_2011], row[:sa3_name_2011],
      row[:sa4_name_2011], row[:state_name_2011] ]
    }.to_h
  end

end
