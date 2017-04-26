class Handicap < ApplicationRecord
  has_many :teams
  scope :srs_keelboat, -> { where(type: 'SrsKeelboat')}
  scope :srs_multihull, -> { where(type: 'SrsMultihull')}
  scope :srs_dingy, -> { where(type: 'SrsDingy')}
  scope :srs_certificate, -> { where(type: 'SrsCertificate')}
  scope :sxk_certificate, -> { where(type: 'SxkCertificate')}
  scope :legacy_boat_type, -> { where(type: 'LegacyBoatType')}
end
