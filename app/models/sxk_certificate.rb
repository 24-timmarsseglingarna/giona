class SxkCertificate < Handicap

  def description
  	"#{self.name} #{self.sail_number unless self.sail_number.blank? }, #{self.boat_name unless self.boat_name.blank?}, #{self.owner_name}, regnr: #{self.registry_id}, SXK: #{self.sxk}"
  end

end
