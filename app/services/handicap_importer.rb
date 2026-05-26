# coding: utf-8
require 'open-uri'
require 'nokogiri'
require 'json'
require 'cgi'

module HandicapImporter
  SRS_KEELBOATS_URL = "https://matbrev.svensksegling.se/home/boatlist?SrsGrid-sort=B%C3%A5ttyp-asc&SrsGrid-group=&SrsGrid-filter=".freeze
  SRS_CERTIFICATES_URL = "https://matbrev.svensksegling.se/Home/ApprovedList".freeze
  SRS_MULTIHULLS_URL = "https://matbrev.svensksegling.se/home/srsflerskrovlist".freeze
  SRS_MULTIHULL_CERTIFICATES_URL = "https://matbrev.svensksegling.se/Flerskrov/GetApprovedFlerskrovMatbrevListAll".freeze
  SXK_CERTIFICATES_URL = "https://24-timmars.se/SXK-tal/apiSXKtal.php".freeze

  def self.srs_keelboats(user, do_expire: true, dryrun: false)
    source = "SRS enskrov #{DateTime.now.year}"
    doc = Nokogiri::HTML(URI.open(SRS_KEELBOATS_URL))
    entries = doc.xpath('//tr')
    first_row = true
    handicaps = []
    srs_index = 6
    for entry in entries
      if first_row
        th = entry.css('th')
        for i in 0..th.length
          if th[i].text == 'SRS'
            srs_index = i
            break
          end
        end
      end
      unless first_row
        h = {}
        h[:name] = entry.css('td')[0].text.gsub('Ã¶','ö').gsub('Ã¥','ö').gsub('Ã¤','ä').to_s.strip
        h[:srs] = entry.css('td')[srs_index].text.gsub(',', '.').to_f
        if h[:srs] == 0
          h[:srs] = entry.css('td')[srs_index+1].text.gsub(',', '.').to_f
        end
        handicaps << h
      else
        first_row = false
      end
    end
    ActiveRecord::Base.transaction do
      Handicap.import('SrsKeelboat', source, SRS_KEELBOATS_URL,
                      handicaps, user, do_expire, dryrun)
    end
  end

  def self.srs_certificates(user, do_expire: false, dryrun: false)
    source = "SRS-mätbrev #{DateTime.now.year}"
    doc = Nokogiri::HTML(URI.open(SRS_CERTIFICATES_URL))
    entries = doc.xpath('//fieldset//tr')
    first_row = true
    handicaps = []
    for entry in entries
      unless first_row
        h = {}
        h[:registry_id] = entry.css('td')[0].text.to_s.strip
        h[:owner_name] = entry.css('td')[1].text.to_s.strip
        h[:name] = entry.css('td')[2].text.to_s.strip
        h[:boat_name] = entry.css('td')[3].text.to_s.strip
        h[:sail_number] = entry.css('td')[5].text.to_i
        h[:srs] = entry.css('td')[8].text.gsub(',', '.').to_f
        if h[:srs] == 0
          h[:srs] = entry.css('td')[9].text.gsub(',', '.').to_f
        end
        handicaps << h
      else
        first_row = false
      end
    end
    ActiveRecord::Base.transaction do
      Handicap.import('SrsCertificate', source, SRS_CERTIFICATES_URL,
                      handicaps, user, do_expire, dryrun)
    end
  end

  def self.srs_multihulls(user, do_expire: true, dryrun: false)
    source = "SRS flerskrov #{DateTime.now.year}"
    doc = Nokogiri::HTML(URI.open(SRS_MULTIHULLS_URL))
    entries = doc.xpath('//tr')
    first_row = true
    handicaps = []
    for entry in entries
      unless first_row
        h = {}
        h[:name] = entry.css('td')[0].text.gsub('Ã¶','ö').gsub('Ã¥','ö').gsub('Ã¤','ä').to_s.strip
        h[:srs] = entry.css('td')[1].text.gsub(',', '.').to_f
        handicaps << h
      else
        first_row = false
      end
    end
    ActiveRecord::Base.transaction do
      Handicap.import('SrsMultihull', source, SRS_MULTIHULLS_URL,
                      handicaps, user, do_expire, dryrun)
    end
  end

  def self.srs_multihull_certificates(user, do_expire: false, dryrun: false)
    source = "SRS-mätbrev flerskrov #{DateTime.now.year}"
    file = URI.open(SRS_MULTIHULL_CERTIFICATES_URL)
    json = JSON.parse file.first
    handicaps = []
    for boat in json['Data']
      h = {}
      h[:registry_id] = boat['Certno']
      h[:owner_name] = boat['CustomerFirstName'].strip + ' ' +
                       boat['CustomerLastName'].strip
      h[:name] = boat['Boattype'].strip
      h[:boat_name] = boat['Boatname'].strip unless boat['Boatname'].blank?
      h[:sail_number] = boat['SailNo']
      h[:srs] = boat['SRS1'].to_f
      if h[:srs] == 0
        h[:srs] = boat['SRS2'].to_f
      end
      handicaps << h
    end
    ActiveRecord::Base.transaction do
      Handicap.import('SrsMultihullCertificate', source, SRS_MULTIHULL_CERTIFICATES_URL,
                      handicaps, user, do_expire, dryrun)
    end
  end

  def self.sxk_certificates(user, do_expire: true, dryrun: false)
    source = "SXK-mätbrev"
    doc = Nokogiri::XML(URI.open(SXK_CERTIFICATES_URL), nil, 'utf-8')
    certificates = doc.xpath("/SXKbrev/brev")
    handicaps = []
    certificates.each do |cert|
      h = {}
      registry_id = cert.xpath("Regnr").text.strip
      expired_at = cert.xpath("Utgatt").text.strip
      sxk = cert.xpath("SXKtal").text.strip.gsub(',', '.')
      if registry_id.blank?
        Rails.logger.info "Skipping certificate with empty 'Regnr'"
        next
      end
      if sxk.blank? and expired_at.blank?
        Rails.logger.info "Skipping certificate #{registry_id} with empty 'SXKtal' and no 'Utgatt'"
        next
      end
      h[:registry_id] = registry_id
      h[:expired_at] = expired_at.to_date unless expired_at.blank?
      h[:sxk] = sxk.to_f unless sxk.blank?
      name = cert.xpath("Bat").text.strip
      h[:name] = name unless name.blank?
      boat_name = cert.xpath("Batnamn").text.strip
      h[:boat_name] = boat_name unless boat_name.blank?
      owner_name = cert.xpath("Agare").text.strip
      h[:owner_name] = owner_name unless owner_name.blank?
      sail_number = cert.xpath("Segelnr").text.strip
      unless sail_number.blank?
        m = sail_number.match("([1-9][0-9]*)")
        h[:sail_number] = m[1].to_i unless m.nil?
      end
      handicaps << h
    end
    ActiveRecord::Base.transaction do
      Handicap.import('SxkCertificate', source, SXK_CERTIFICATES_URL,
                      handicaps, user, do_expire, dryrun)
    end
  end
end
