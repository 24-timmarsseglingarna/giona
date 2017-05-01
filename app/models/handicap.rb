class Handicap < ApplicationRecord
  has_many :teams
  scope :srs_keelboat, -> { where(type: 'SrsKeelboat')}
  scope :srs_multihull, -> { where(type: 'SrsMultihull')}
  scope :srs_dingy, -> { where(type: 'SrsDingy')}
  scope :srs_certificate, -> { where(type: 'SrsCertificate')}
  scope :sxk_certificate, -> { where(type: 'SxkCertificate')}
  scope :legacy_boat_type, -> { where(type: 'LegacyBoatType')}
  scope :active, -> { where("best_before > ?", DateTime.now)}

  default_scope { order 'name', 'sail_number' }

  def description 
  	"#{self.name}, SRS: #{self.srs}, SXK: #{self.handicap}"
  end

  def self.types
    types = {}
    types['SrsKeelboat'] = 'Kölbåt enligt SRS-tabellen'
    types['SrsMultihull'] = 'Flerskrovsbåt enligt SRS-tabellen'
    types['SrsDingy'] = 'Jolle enligt SRS-tabellen'
    types['SrsCertificate'] = 'SRS-mätbrev (för individuell båt)'
    types['SoonSrsCertificate'] = 'Kommer att skaffa SRS-mätbrev'
    types['SxkCertificate'] = 'SXK-mätbrev (för individuell båt)'
    types['SoonSxkCertificate'] = 'Kommer att skaffa SXK-mätbrev'

    types
  end

end
