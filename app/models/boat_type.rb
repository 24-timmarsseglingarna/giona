class BoatType < ApplicationRecord
  has_and_belongs_to_many :boats
  scope :srs_keelboat, -> { where(type: 'SrsKeelboat')}
  scope :srs_multihull, -> { where(type: 'SrsMultihull')}
  scope :srs_dingy, -> { where(type: 'SrsDingy')}
  scope :srs_certificate, -> { where(type: 'SrsCertificate')}
  scope :sxk_certificate, -> { where(type: 'SxkCertificate')}
  scope :legacy_boat_type, -> { where(type: 'LegacyBoatType')}
end
