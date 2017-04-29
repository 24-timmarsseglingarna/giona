class SrsKeelboat < Handicap


  def self.select_srs_keelboatz
    srs_keelboat_array  = {}
    srs_keelboat_array['Välj'] = nil 
    for srs_keelboat in SrsKeelboat.all
      srs_keelboat_array["#{srs_keelboat.name}, SRS-tal: #{srs_keelboat.srs}"] = srs_keelboat.id 
    end
    srs_keelboat_array 
  end


end
