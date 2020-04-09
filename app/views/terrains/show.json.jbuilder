json.extract! @terrain, :id, :published, :version_name, :created_at, :updated_at
json.url terrain_url(@terrain, format: :json)
json.ignore_nil!

json.startPoints do
  # GeoJSON object
  json.partial! 'terrains/feature_collection'
  json.features @terrain.points do |p|
    next unless is_start p
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
json.turningPoints do
  # GeoJSON object
  json.partial! 'terrains/feature_collection'
  json.features @terrain.points do |p|
    next if is_start p
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
json.inshoreLegs do
  # GeoJSON object
  json.partial! 'terrains/feature_collection'
  json.features @terrain.legs do |leg|
    next if leg.offshore
    src = Point.find(leg.point_id)
    dst = Point.find(leg.to_point_id)
    json.type "Feature"
    json.geometry do
      json.type "LineString"
      json.coordinates [[src.longitude, src.latitude],
                        [dst.longitude, dst.latitude]]
    end
    json.properties do
      json.src src.number.to_s
      json.dst dst.number.to_s
      json.dist leg.distance
      if leg.addtime
        json.addtime leg.addtime
      end
    end
  end
end
json.offshoreLegs do
  # GeoJSON object
  json.partial! 'terrains/feature_collection'
  json.features @terrain.legs do |leg|
    next unless leg.offshore
    src = Point.find(leg.point_id)
    dst = Point.find(leg.to_point_id)
    json.type "Feature"
    json.geometry do
      json.type "LineString"
      json.coordinates [[src.longitude, src.latitude],
                        [dst.longitude, dst.latitude]]
    end
    json.properties do
      json.src src.number.to_s
      json.dst dst.number.to_s
      json.dist leg.distance
      if leg.addtime
        json.addtime leg.addtime
      end
    end
  end
end
