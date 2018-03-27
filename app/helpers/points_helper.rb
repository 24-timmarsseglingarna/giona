module PointsHelper

  def lat_long point
      out = ''
      if point.latitude.present?
        if point.latitude < 0
          hemisphere = 'S'
        else
          hemisphere = 'N'
        end
         out << "#{hemisphere} #{point.latitude.floor}°#{number_with_precision(((point.latitude-point.latitude.floor)*60), precision: 2) }'"
         out << ' '
      end

      if point.longitude.present?
        if point.longitude < 0
          hemisphere = 'W'
        else
          hemisphere = 'E'
        end
        out << "#{hemisphere} #{point.longitude.floor}°#{number_with_precision(((point.longitude-point.longitude.floor)*60), precision: 2) }'"
      end
  end

  def name_by_number terrain, number
    points = terrain.points.where(number: number)
    unless points.blank?
      points.last.name
    else
      'Punkt med detta nummer saknas i den version av PoD som används.'
    end
  end

  def name_number point
    "#{point.number} #{point.name}"
  end

end
