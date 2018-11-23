json.extract! @terrain, :id, :published, :version_name, :created_at, :updated_at
json.url terrain_url(@terrain, format: :json)
json.ignore_nil!

json.points do
  # GeoJSON object
  json.partial! 'terrains/feature_collection'
  json.features @terrain.points do |p|
    json.type "Feature"
    json.geometry do
      json.type "Point"
      json.coordinates [p.longitude, p.latitude]
    end
    json.properties do
      json.number p.number.to_s
      json.descr p.definition
      json.name p.name
      json.footnote p.footnote
    end
  end
end
json.legs do
  # GeoJSON object
  json.partial! 'terrains/feature_collection'
  json.features @terrain.legs do |leg|
    json.type "Feature"
    json.geometry do
      json.type "LineString"
      src = Point.find(leg.point_id)
      dst = Point.find(leg.to_point_id)
      json.coordinates [[src.longitude, src.latitude],
                        [dst.longitude, dst.latitude]]
    end
    json.properties do
      json.src leg.point_id.to_s
      json.dst leg.to_point_id.to_s
      json.dist leg.distance
      if leg.offshore
        json.offshore leg.offshore
      end
      if leg.addtime
        json.addtime leg.addtime
      end
      json.addtime
    end
  end
end
