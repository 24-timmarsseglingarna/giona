class SrsCertificate < Handicap

  def description
  	"#{self.name} #{self.sail_number unless self.sail_number.blank? }, #{self.boat_name unless self.boat_name.blank?}, #{self.owner_name}, regnr: #{self.registry_id}, SRS: #{self.srs}, SXK: #{self.sxk}"
  end

end
