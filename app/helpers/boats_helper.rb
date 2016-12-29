module BoatsHelper
  def boat_brief boat
  	boat.boat_class.name + ' ' + boat.sail_number.to_s + ' ' + boat.name 	
  end
end
