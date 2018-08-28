# coding: utf-8
class Handicap < ApplicationRecord
  has_many :teams
  scope :srs_keelboat, -> { where(type: 'SrsKeelboat')}
  scope :srs_multihull, -> { where(type: 'SrsMultihull')}
  scope :srs_dingy, -> { where(type: 'SrsDingy')}
  scope :srs_certificate, -> { where(type: 'SrsCertificate')}
  scope :srs_multihull_certificate, -> { where(type: 'SrsMultihullCertificate')}
  scope :sxk_certificate, -> { where(type: 'SxkCertificate')}
  scope :legacy_boat_type, -> { where(type: 'LegacyBoatType')}
  scope :active, -> { where("best_before > ?", DateTime.now)}

  default_scope { order 'name', 'sail_number' }

  def description
    "#{self.name}, SRS: #{self.srs}, SXK: #{self.sxk}, #{self.source}"
  end

  def self.types
    types = {}
    types['SrsKeelboat'] = 'Enskrovsbåt enligt SRS-tabellen'
    types['SrsMultihull'] = 'Flerskrovsbåt enligt SRS-tabellen'
    types['SrsDingy'] = 'Jolle enligt SRS-tabellen'
    types['SrsCertificate'] = 'SRS-mätbrev enskrov (för individuell båt)'
    types['SrsMultihullCertificate'] = 'SRS-mätbrev flerskrov (för individuell båt)'
    types['SoonSrsCertificate'] = 'Kommer att skaffa SRS-mätbrev'
    types['SxkCertificate'] = 'SXK-mätbrev (för individuell båt)'
    types['SoonSxkCertificate'] = 'Kommer att skaffa SXK-mätbrev'

    types
  end

  def self.short_types
    types = {}
    types['SrsKeelboat'] = 'SRS Enskrov'
    types['SrsMultihull'] = 'SRS Flerskrov'
    types['SrsDingy'] = 'SRS Jolle'
    types['SrsCertificate'] = 'SRS-mätbrev enskrov'
    types['SrsMultihullCertificate'] = 'SRS-mätbrev flerskrov'
    types['SoonSrsCertificate'] = 'Interimistiskt'
    types['SxkCertificate'] = 'SXK-mätbrev'
    types['SoonSxkCertificate'] = 'Interimistiskt'

    types
  end


end
