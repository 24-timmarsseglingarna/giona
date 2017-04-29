module HandicapsHelper

  def handicap_table(type)
    handicap_array  = {}
    handicap_array['Välj'] = nil 
    for handicap in Handicap.where(type: type)
      handicap_array[handicap.description] = handicap.id 
    end
    handicap_array 
  end

  

end
