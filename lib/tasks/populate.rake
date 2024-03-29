# coding: utf-8
require 'csv'
require 'open-uri'
require 'nokogiri'
require 'erb'
include ERB::Util
require 'cgi'


namespace :scrape do
  namespace :srs do
    # rake scrape:srs:certificates
    # rake scrape:srs:certificates[dryrun]
    task :certificates => :environment do |task, args|
      dryrun = args.extras.include? 'dryrun'
      do_expire = args.extras.include? 'expire'
      srs_table_url = "https://matbrev.svensksegling.se/Home/ApprovedList"
      doc = Nokogiri::HTML(URI.open(srs_table_url))
      entries = doc.xpath('//fieldset//tr')
      first_row = true
      source = "SRS-mätbrev #{DateTime.now.year.to_s}"
      handicaps = Array.new
      for entry in entries
        unless first_row
          h = Hash.new
#          h[:registry_id] = CGI::parse((entry.css('td')[0].css('a').map { |link| link['href'] })[0])["rpt"][0].to_s
          h[:registry_id] = entry.css('td')[0].text.to_s.strip
          h[:owner_name] = entry.css('td')[1].text.to_s.strip
          h[:name] = entry.css('td')[2].text.to_s.strip
          h[:boat_name] = entry.css('td')[3].text.to_s.strip
          h[:sail_number] = entry.css('td')[5].text.to_i
          h[:srs] = entry.css('td')[8].text.gsub(',', '.').to_f
          if h[:srs] == 0 # no std srs, use srs w/o "flygande segel"
            h[:srs] = entry.css('td')[9].text.gsub(',', '.').to_f
          end
          handicaps << h
        else
          first_row = false
        end
      end
      ActiveRecord::Base.transaction do
        user = User.find_by!(email: 'nobody@24-timmars.nu')
        Handicap.import('SrsCertificate', source, srs_table_url,
                        handicaps, user, do_expire, dryrun)
      end
    end
  end

  namespace :srs do
    task :keelboats => :environment do |task, args|
      dryrun = args.extras.include? 'dryrun'
      srs_table_url = "https://matbrev.svensksegling.se/home/boatlist?SrsGrid-sort=B%C3%A5ttyp-asc&SrsGrid-group=&SrsGrid-filter="
      doc = Nokogiri::HTML(URI.open(srs_table_url))
      entries = doc.xpath('//tr')
      first_row = true
      source = "SRS enskrov #{DateTime.now.year.to_s}"
      handicaps = Array.new
      for entry in entries
        unless first_row
          h = Hash.new
          h[:name] = entry.css('td')[0].text.gsub('Ã¶','ö').gsub('Ã¥','ö').gsub('Ã¤','ä').to_s.strip
          h[:srs] = entry.css('td')[6].text.gsub(',', '.').to_f
          if h[:srs] == 0 # no std srs, use srs w/o "flygande segel"
            h[:srs] = entry.css('td')[7].text.gsub(',', '.').to_f
          end
          handicaps << h
        else
          first_row = false
        end
      end
      ActiveRecord::Base.transaction do
        user = User.find_by!(email: 'nobody@24-timmars.nu')
        do_expire = true
        Handicap.import('SrsKeelboat', source, srs_table_url,
                        handicaps, user, do_expire, dryrun)
      end
    end

    task :multihulls => :environment do |task, args|
      dryrun = args.extras.include? 'dryrun'
      srs_table_url = "https://matbrev.svensksegling.se/home/srsflerskrovlist"
      doc = Nokogiri::HTML(URI.open(srs_table_url))
      entries = doc.xpath('//tr')
      first_row = true
      source = "SRS flerskrov #{DateTime.now.year.to_s}"
      handicaps = Array.new
      for entry in entries
        unless first_row
          h = Hash.new
          h[:name] = entry.css('td')[0].text.gsub('Ã¶','ö').gsub('Ã¥','ö').gsub('Ã¤','ä').to_s.strip
          h[:srs] = entry.css('td')[1].text.gsub(',', '.').to_f
          handicaps << h
        else
          first_row = false
        end
      end
      ActiveRecord::Base.transaction do
        user = User.find_by!(email: 'nobody@24-timmars.nu')
        do_expire = true
        Handicap.import('SrsMultihull', source, srs_table_url,
                        handicaps, user, do_expire, dryrun)
      end
    end
  end
end

namespace :import do
  namespace :srs do
    task :multihull_certificates => :environment do |task, args|
      dryrun = args.extras.include? 'dryrun'
      do_expire = args.extras.include? 'expire'
      srs_table_url = "https://matbrev.svensksegling.se/Flerskrov/GetApprovedFlerskrovMatbrevListAll"
      source = "SRS-mätbrev flerskrov #{DateTime.now.year.to_s}"
      file = URI.open(srs_table_url)
      json = JSON.parse file.first
      handicaps = Array.new
      for boat in json['Data']
        h = Hash.new
        h[:registry_id] = boat['Certno']
        h[:owner_name] = boat['CustomerFirstName'].strip + ' ' +
                         boat['CustomerLastName'].strip
        h[:name] = boat['Boattype'].strip
        h[:boat_name] = boat['Boatname'].strip unless boat['Boatname'].blank?
        h[:sail_number] = boat['SailNo']
        h[:srs] = boat['SRS1'].to_f
        if h[:srs] == 0 # no std srs, use srs w/o "flygande segel"
          h[:srs] = boat['SRS2'].to_f
        end
        handicaps << h
      end
      ActiveRecord::Base.transaction do
        user = User.find_by!(email: 'nobody@24-timmars.nu')
        Handicap.import('SrsMultihullCertificate', source, srs_table_url,
                        handicaps, user, do_expire, dryrun)
      end
    end

    # NOTE:
    #   this task needs a file 'srs-jolle.csv' with a header row
    #   and each row on the form:
    #     <boat-type-name>;<srs>
    task :dingies => :environment do |task, args|
      dryrun = args.extras.include? 'dryrun'
      srs_table_url = 'http://www.svensksegling.se/globalassets/svenska-seglarforbundet/for-batagare/srs/srs-tabellen-for-jollar.pdf'
      source = "SRS jolle #{DateTime.now.year.to_s}"
      handicaps = Array.new
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "srs-jolle.csv"), "r"), :headers => true) do |row|
        h = Hash.new
        h[:name] = row['Typ'].to_s.strip
        h[:srs] = row['SRS'].to_f
        handicaps << h
      end
      ActiveRecord::Base.transaction do
        user = User.find_by!(email: 'nobody@24-timmars.nu')
        do_expire = true
        Handicap.import('SrsDingy', source, srs_table_url,
                        handicaps, user, do_expire, dryrun)
      end
    end
  end

  namespace :sxk do
    task :certificates => :environment do |task, args|
      dryrun = args.extras.include? 'dryrun'
      #sxk_table_url = 'https://dev.24-timmars.nu/PoD/SXK-tal/apiSXKtal.php'
      sxk_table_url = 'https://24-timmars.se/SXK-tal/apiSXKtal.php'
      source = "SXK-mätbrev"
      doc = Nokogiri::XML(URI.open(sxk_table_url), nil, 'utf-8')
      certificates = doc.xpath("/SXKbrev/brev")
      handicaps = Array.new
      certificates.each do |cert|
        h = Hash.new
        registry_id = cert.xpath("Regnr").text.strip
        expired_at = cert.xpath("Utgatt").text.strip
        sxk = cert.xpath("SXKtal").text.strip.gsub(',', '.')
        # sanity check
        if registry_id.blank?
          puts "Skipping certificate with empty 'Regnr'"
          next
        end
        if sxk.blank? and expired_at.blank?
          puts "Skipping certificate #{registry_id} with empty 'SXKtal' and no 'Utgatt'"
          next
        end
        h[:registry_id] = registry_id
        unless expired_at.blank?
          h[:expired_at] = expired_at.to_date
        end
        unless sxk.blank?
          h[:sxk] = sxk.to_f
        end
        name = cert.xpath("Bat").text.strip
        unless name.blank?
          h[:name] = name
        end
        boat_name = cert.xpath("Batnamn").text.strip
        unless boat_name.blank?
          h[:boat_name] = boat_name
        end
        owner_name = cert.xpath("Agare").text.strip
        unless owner_name.blank?
          h[:owner_name] = owner_name
        end
        sail_number = cert.xpath("Segelnr").text.strip
        unless sail_number.blank?
          # 'Segelnr' may contain letters; extract the number.
          # do not match a single zero
          m = sail_number.match("([1-9][0-9]*)")
          unless m.nil?
            h[:sail_number] = m[1].to_i
          end
        end
        handicaps << h
      end
      ActiveRecord::Base.transaction do
        user = User.find_by!(email: 'nobody@24-timmars.nu')
        do_expire = true
        Handicap.import('SxkCertificate', source, sxk_table_url,
                        handicaps, user, do_expire, dryrun)
      end
    end

  end

  namespace :pod do
    task :terrain => :environment do
      print "Getting PoD from server..."
      #pod_url = 'https://dev.24-timmars.nu/PoD/xmlapi_app.php'
      pod_url = 'https://24-timmars.se/PoD/xmlapi_app.php'
      doc = Nokogiri::XML(URI.open(pod_url), nil, 'utf-8')
      puts " ok"

      # points number 9000 and above are not real points; they are used to mark
      # area borders.  it would be better to not store them in the PoD database,
      # or that they are removed from api call.
      MAXPOINT=8999

      points = doc.xpath("/PoD/points/point")
      puts "Found #{points.count} points."

      ActiveRecord::Base.transaction do
        terrain = Terrain.new
        terrain.version_name = "During import"
        terrain.published = false

        ndups = 0
        point_ids = {}
        points.each do |point|
          point_number = point.xpath("number").text.to_i
          next if point_number > MAXPOINT
          name = point.xpath("name").text
          descr = point.xpath("descr").text
          footnote = point.xpath("footnote").text
          if footnote.blank?
            footnote = nil
          end
          lat = point.xpath("lat").text.to_f
          long = point.xpath("long").text.to_f
          unless (point_number.blank? || name.blank? ||
                  descr.blank? || lat == 0 || long == 0)
            pt = Point.find_or_initialize_by(number: point_number,
                                             name: name,
                                             definition: descr,
                                             footnote: footnote,
                                             latitude: lat,
                                             longitude: long)
            if pt.new_record?
              duplicates = Point.where("number = ?", point_number)
              version = duplicates.maximum("version").to_i + 1
              pt.version = version
              pt.save!
            else
              ndups = ndups + 1
            end
            point_ids[point_number] = pt.id
            terrain.points << pt
          else
            puts "Skipping incomplete point. number: #{point_number} " +
                 "name: #{name} defintion: #{definition} " +
                 "lat: #{lat} long: #{long}."
          end
        end
        puts "#{ndups} were duplicates."

        ndups = 0
        legs = doc.xpath("/PoD/legs/leg")
        puts "Found #{legs.count} legs."
        legs.each do |leg|
          from_number = leg.xpath('from').text.to_i
          to_number = leg.xpath('to').text.to_i
          next if from_number > MAXPOINT || to_number > MAXPOINT
          point_id = point_ids[from_number]
          to_point_id = point_ids[to_number]
          dist = leg.xpath('dist').text.to_f
          offshore = leg.xpath('sea').text.to_i == 1
          addtime = leg.xpath('addtime').text.to_i == 1
          unless (point_id.nil? || to_point_id.nil?)
            lg = Leg.find_or_initialize_by(point_id:    point_id,
                                           to_point_id: to_point_id,
                                           distance:    dist,
                                           offshore:    offshore,
                                           addtime:     addtime)
            if lg.new_record?
              duplicates =
                Leg.where("point_id = :point_id AND to_point_id = :to_point_id",
                          {point_id: point_id, to_point_id: to_point_id})
              version = duplicates.maximum("version").to_i + 1
              lg.version = version
              lg.save!
            else
              ndups = ndups + 1
            end
            terrain.legs << lg
          else
            puts "Skipping incomplete leg. Missing point #{from_number} " +
                 "or #{to_number}"
          end
        end
        puts "#{ndups} were duplicates."

        puts "Checking for duplicate terrains..."
        # check for duplicates (what's the probability...?)
        to_be_destroyed = false
        for t in Terrain.all
          puts "Comparing with terrain #{t.version_name}."
          if terrain.points.sort_by {|x| x.id} == t.points.sort_by {|x| x.id}
            puts "  Same set of points."
            if terrain.legs.sort_by {|x| x.id} == t.legs.sort_by {|x| x.id}
              puts "  Same legs."
              to_be_destroyed = true
              break
            end
          end
        end
        if to_be_destroyed
          puts "The PoD is already present, did not import."
          terrain.destroy!
        else
          puts "Added new terrain #{terrain.version_name}."
          terrain.save!
        end
      end
    end

    task :old_default_starts => :environment do
      print "Getting PoD from server..."
      doc = Nokogiri::XML(URI.open("https://dev.24-timmars.nu/PoD/xmlapi_app.php"),
                           nil, 'ISO-8859-1')
      puts " ok"

      print "Setting default start points..."
      # set default starts
      ActiveRecord::Base.transaction do
        for organizer in Organizer.all
          extid = organizer.external_id
          unless extid.blank?
            organizer.default_starts.destroy_all
            doc.xpath("/PoD/kretsar/krets[name='#{extid}']/startpoints/number").
              each do |number|
              point_number = number.text.to_i
              unless Point.where("number = ?", point_number).blank?
                default_start = DefaultStart.find_or_create_by(
                  organizer_id: organizer.id, number: point_number)
                default_start.save!
              end
            end
          end
        end
        puts " ok"
      end
    end

    task :default_starts => :environment do
      print "Getting PoD from server..."
      doc = Nokogiri::XML(URI.open("https://24-timmars.se/PoD/xmlapi_app2.php"),
                           nil, 'ISO-8859-1')
      puts " ok"

      print "Setting default start points..."
      # set default starts
      ActiveRecord::Base.transaction do
        for organizer in Organizer.all
          extid = organizer.external_id
          unless extid.blank?
            organizer.default_starts.destroy_all
            doc.xpath("/PoD/startpoints/point[user='#{extid}']/number").
              each do |number|
              point_number = number.text.to_i
              unless Point.where("number = ?", point_number).blank?
                default_start = DefaultStart.find_or_create_by(
                  organizer_id: organizer.id, number: point_number)
                default_start.save!
              end
            end
          end
        end
        puts " ok"
      end
    end

  end

  namespace :starema do
    task :people => :environment do
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "Starema-St-Deltagare.csv"), "r"), :headers => true) do |row|
        p = Person.find_or_create_by(external_system: 'Starema-St', external_id: row['DeltNr'].to_s.strip.to_i)
                puts p.external_id
        p.first_name = row['DeltFörnamn'].to_s.strip
        if p.first_name.blank?
          p.first_name = '*'
        end
        p.last_name = row['DeltEfternamn'].to_s.strip
        p.birthday = ('19' + row['DeltFodd'].to_s.strip).to_date
        p.co = row['DeltAdressCO'].to_s.strip
        p.street = row['DeltGatuAdr'].to_s.strip
        p.zip = row['DeltPostNr'].to_s.strip
        p.city = row['DeltPostAdr'].to_s.strip
        #p.country = row[''].to_s.strip)
        p.phone = row['DeltMobilnr'].to_s.strip
        p.email = row['DeltEpost1'].to_s.strip
        p.external_system = 'Starema-St'
        p.external_id = row['DeltNr'].to_s.strip
        p.save!
      end
    end

    task :regattas => :environment do
      # File format: SeglingFNStart,SeglingStartDag,SeglingStartTid,SeglingPeriod,StartDagCtr,StartVeckodag,
      # StartDag,StartAr,StartVH,StartFNTid,UrvalStartTid,TmpRegatta,TmpOrganizer,TmpRace,TmpRegattaName
      # If imported start period covers midnight --> #fail
      organizer = Organizer.find_by(name: 'Svenska Kryssarklubbens Stockholmskrets')
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "starema-sthlm-regatta-race.csv"), "r"), :headers => true) do |row|
        regatta = Regatta.find_or_create_by(name: row['TmpRegattaName'].to_s.strip, external_system: 'Starema-St')
                regatta.organizer = organizer
        regatta.email_from = 'arne@24-timmars.nu'
        regatta.name_from = 'Arne Wallers'
        regatta.email_to = 'arne@24-timmars.nu, stefan@24-timmars.nu'
        regatta.save!

        period = row['SeglingPeriod'].to_s.strip.to_i
        start_day = row['SeglingStartDag'][0..7]
        start_time_from = row['SeglingStartTid'][0..4]
        start_time_to = row['SeglingStartTid'][6..10]
        start_from = DateTime.strptime(start_day + ' ' + start_time_from, "%m/%d/%y %H:%M") - 2.hours #.in_time_zone("Europe/Stockholm")
        start_to = DateTime.strptime(start_day + ' ' + start_time_to, "%m/%d/%y %H:%M") - 2.hours #.in_time_zone("Europe/Stockholm")
        external_id = row['StartDagCtr'].to_s.strip.to_i
        race = Race.find_or_create_by( external_system: 'Starema-St',
                                       external_id: external_id,
                                       regatta_id: regatta.id,
                                       period: period,
                                       start_from: start_from,
                                       start_to: start_to,
                                       common_finish: nil,
                                       )
        race.save!
      end
    end


    task :crew_members => :environment do
      # File format:
      # DeltariSeglingCtr, DeltariRegistrerandeKrets, DeltariFNDeltagare,
      # DeltariFNSegling, DeltariSkipperGastqq, DeltariFNSkipperGast

      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "Starema-St-DeltariSeling.csv"), "r"), :headers => true) do |row|
        team = Team.find_by(external_id: row['DeltariFNSegling'].to_s.strip.to_i, external_system: 'Starema-St')
        person = Person.find_by(external_id: row['DeltariFNDeltagare'].to_s.strip.to_i, external_system: 'Starema-St')
        unless person.nil? || team.nil?
          crew_member = CrewMember.find_or_create_by(team_id: team.id, person_id: person.id)
          #puts "person #{person.id unless person.nil?} team #{team.id unless team.nil?}"
          #puts "crew_member.person #{crew_member.person_id} crew_member.team #{crew_member.team_id}"
          #puts "--------"
          if(row['DeltariFNSkipperGast'].to_i == 2)
            crew_member.skipper = true
          else
            crew_member.skipper = false
          end
          crew_member.save!
        else
          puts "Missing one part. Person #{person.id unless person.nil?}: Team: #{team.id unless team.nil?}."
          puts "Starema team: #{row['DeltariFNSegling']} Starema person: #{row['DeltariFNDeltagare']}"
        end
      end
    end



    task :boats => :environment do
      boat_type_name = Hash.new
      boat_handicap = Hash.new
      # File format:
      # BoatNr,BoatTyp,BoatSxkTal
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "Starema-St-BoatType.csv"), "r"), :headers => true) do |row|
        i = row['BoatNr'].to_i
        boat_type_name[i] = row['BoatTyp']
        boat_handicap[i] = row['BoatSxkTal']
      end

      # File format:
      # BoatIndNr, BoatIndFNBoattyp, BoatIndNamn, BoatIndParmNr, BoatIndVHF, BoatIndMobil
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "Starema-St-BoatIndivid.csv"), "r"), :headers => true) do |row|
        boat = Boat.find_or_create_by(external_id: row['BoatIndNr'].to_s.strip.to_i, external_system: 'Starema-St')
        name = row['BoatIndNamn'].to_s
        if name.blank?
          name = '* Okänt'
        end
        boat.name = name
        i = row['BoatIndFNBoattyp'].to_i
        boat.boat_type_name = boat_type_name[i]
        sail_number = row['BoatIndParmNr'].to_i
        if sail_number == 0
          boat.sail_number = nil
        else
          boat.sail_number = sail_number
        end
        boat.vhf_call_sign = row['BoatIndVHF'].to_s
        boat.ais_mmsi = nil
        boat.boat_type_name = "* Okänd" if boat.boat_type_name.blank?
        boat.save!
      end
    end




  end
end

namespace :batch do

  task :add_nobody => :environment do
    email = 'nobody@24-timmars.nu'
    p = Person.new
    p.first_name = 'No'
    p.last_name = 'Body'
    p.email = email
    p.save!
    u = User.new
    u.email = email
    u.person = p
    o = [('a'..'z'), ('A'..'Z')].map(&:to_a).flatten
    passwd = (0...50).map { o[rand(o.length)] }.join
    u.reset_password(passwd, passwd)
    u.save!
  end

  task :trim_handicap_names => :environment do
    for handicap in Handicap.all
      handicap.name.strip!
      handicap.save!
    end
  end

  task :agreement => :environment do
    a = Agreement.create name: 'Revision A - riksreglerna 2006',
                         description: 'Start-, resultat- och maratonlistor med personnamn och båtnamn kan komma att publiceras bland annat på Internet vilket alla deltagare förutsättes godkänna i och med att de anmäler sig till seglingen.'
    a.save!
  end

  task :admin => :environment do
    User.first.admin!
  end


  namespace :pod do
    task :organizers => :environment do
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Västkustkrets', external_system: 'PoD', external_id: 'Vk')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Vänerkrets', external_system: 'PoD', external_id: 'Va' )
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Blekingekrets', external_system: 'PoD', external_id: 'Bl')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Dackekrets', external_system: 'PoD', external_id: 'Da')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens S:t Annakrets', external_system: 'PoD', external_id: 'SA')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Sörmlandskrets', external_system: 'PoD', external_id: 'So')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Västermälarkrets', external_system: 'PoD', external_id: 'Vm')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Stockholmskrets', external_system: 'PoD', external_id: 'St')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Uppsalakrets', external_system: 'PoD', external_id: 'Up')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Eggegrundskrets', external_system: 'PoD', external_id: 'Eg')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Bottenhavskrets', external_system: 'PoD', external_id: 'Bo')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Bottenvikskrets', external_system: 'PoD', external_id: 'Sk')
      Organizer.find_or_create_by(name: 'Svenska Kryssarklubbens Öresundskrets', external_system: 'PoD', external_id: 'Or')
    end
  end

  namespace :starema do
    task :organizers => :environment do
      organizer = Organizer.find_by(name: 'Svenska Kryssarklubbens Stockholmskrets')
      for regatta in Regatta.where("organizer_id IS NULL")
        regatta.organizer = organizer
        regatta.save!
      end
    end
  end

  task :regatta_terrain => :environment do
    terrain = Terrain.where(published: true).last
    for regatta in Regatta.all
      if regatta.terrain.blank?
        regatta.terrain = terrain
        regatta.save!
      end
    end
  end

  task :team_names => :environment do
    for team in Team.all
      skipper = team.skipper
      if team.skipper.nil?
        puts "Team with id: " + team.id.to_s + " is missing a skipper. External_id: " + team.external_id.to_s
      else
        if team.skipper.last_name.nil?
          puts "Skipper with id: " + team.skipper.id.to_s + "is missing a last name."
        else
          team.name = "#{team.boat_name}/#{skipper.last_name}"
          team.save!
        end
      end
    end
  end


  task :race_names => :environment do
    for race in Race.all
      race.name = nil
      race.save!
    end
  end

  task :regatta_names => :environment do
    for regatta in Organizer.find_by( name: 'Svenska Kryssarklubbens Stockholmskrets' ).regattas
      regatta.name = regatta.name.gsub(/\ i\ Stockholm/, '')
      regatta.save!
    end
  end

  # this is a run-once task to clean up handicaps imported before we
  # changed how best_before was handled
  # NOTE: must run db migrate first!
  task :remove_expired_at_from_handicap => :environment do
    eoy = DateTime.now.in_time_zone.end_of_year
    # first, do sanity check
    res = Handicap.where(expired_at: nil)
    if res.length != 0
      puts "There are #{res.length} handicaps without expired_at in the db already"
    end
    res = Handicap.where("expired_at < ?", eoy)
    if res.length != 0
      puts "There are #{res.length} expired handicaps in the db already"
    end
    res = Handicap.where("expired_at > ?", eoy)
    if res.length != 0
      puts "There are #{res.length} handicaps with expired_at in the future!!"
    end

    res = Handicap.where(expired_at: eoy)
    puts "Removing expired_at from #{res.length} current handicaps"
    for h in res
      # ensure that there are not another handicap with the same "key" that
      # is not expired
      duplicates = Handicap.active.where("name = :n and type = :t and registry_id = :r",
                                         {n: h.name, t: h.type, r: h.registry_id})
      if duplicates.length > 0
        puts "NOTE: found duplicate active handicaps #{duplicates[0].id}"
      else
        h.expired_at = nil
        h.save!
      end
    end
  end

  # this task is supposed to be used until we have implemented the
  # full review process in Giona.  run this to close all teams in all
  # archived regattas as "incomplete".  their data can not be
  # trusted (e.g., they might not have a log book, or incomplete log
  # book.)
  task :close_teams, [:dryrun] => :environment do |task, args|
    dryrun = not(args[:dryrun].nil?)
    for team in Team.is_archived(false).joins(race: :regatta).where("regattas.active = ?", false)
      puts "Closing #{team.id} #{team.name} #{team.race.regatta.name}"
      team.closed! unless dryrun
    end
  end

  # this is a run-once task to clean up SXK certs that are active
  # but imported with partly bad data; specifically if some field had
  # non-ascii characters, the data was truncated.
  #
  # this task find them by comparing with data from the server, and
  # removes them (marks them as expired).
  #
  # after this task is run, task import:sxk:certificates must be run, to
  # add the new certs.
  task :del_old_sxk_certs, [:dryrun] => :environment do |task, args|
    dryrun = not(args[:dryrun].nil?)
    sxk_table_url = 'https://dev.24-timmars.nu/PoD/SXK-tal/apiSXKtal.php'
    source = "SXK-mätbrev"
    doc = Nokogiri::XML(URI.open(sxk_table_url), nil, 'utf-8')
    certificates = doc.xpath("/SXKbrev/brev")
    handicaps = Array.new
    certificates.each do |cert|
      h = Hash.new
      registry_id = cert.xpath("Regnr").text.strip
      expired_at = cert.xpath("Utgatt").text.strip
      sxk = cert.xpath("SXKtal").text.strip.gsub(',', '.')
      # sanity check
      if registry_id.blank?
        puts "Skipping certificate with empty 'Regnr'"
        next
      end
      if sxk.blank? and expired_at.blank?
        puts "Skipping certificate #{registry_id} with empty 'SXKtal' and no 'Utgatt'"
        next
      end
      h[:registry_id] = registry_id
      unless expired_at.blank?
        h[:expired_at] = expired_at.to_date
      end
      unless sxk.blank?
        h[:sxk] = sxk.to_f
      end
      name = cert.xpath("Bat").text.strip
      unless name.blank?
        h[:name] = name
      end
      boat_name = cert.xpath("Batnamn").text.strip
      unless boat_name.blank?
        h[:boat_name] = boat_name
      end
      owner_name = cert.xpath("Agare").text.strip
      unless owner_name.blank?
        h[:owner_name] = owner_name
      end
      sail_number = cert.xpath("Segelnr").text.strip
      unless sail_number.blank?
        # 'Segelnr' may contain letters; extract the number.
        # do not match a single zero
        m = sail_number.match("([1-9][0-9]*)")
        unless m.nil?
          h[:sail_number] = m[1].to_i
        end
      end
      handicaps << h
    end
    # the bad import comes from the following external_system:
    badsyst = "http://aws.24-timmars.nu/phpmyadmin"
    yesterday = DateTime.now.in_time_zone.end_of_day - 1.day
    ActiveRecord::Base.transaction do
      user = User.find_by!(email: 'nobody@24-timmars.nu')
      for new in handicaps
        cur = Handicap.find_by(external_system: badsyst,
                               registry_id: new[:registry_id],
                               expired_at: nil)
        if not cur.nil?
          # this means that we have a potentially bad handicap in the system
          if ((new[:name] != cur.name) or
              (new[:boat_name] != cur.boat_name) or
              (new[:owner_name] != cur.owner_name) or
              (new[:sail_number] != cur.sail_number) or
              (new[:sxk] != cur.sxk))
            puts "Handicap #{cur.id} is different"
            puts "Cur #{cur.name} #{cur.sxk} #{cur.boat_name} #{cur.owner_name} #{cur.sail_number}"
            puts "New #{new}"
            cur.expired_at = yesterday
            cur.save! unless dryrun
            Team.handicap_changed(cur.id, user, dryrun)
          end
        end
      end
    end
  end

  task :strip_whitespace_people => :environment do
    for p in Person.all
      modified = false
      if p.first_name.strip != p.first_name
        puts "Strip '#{p.first_name}' #{p.last_name}"
        p.first_name = p.first_name.strip
        modified = true
      end
      if p.last_name.strip != p.last_name
        puts "Strip #{p.first_name} '#{p.last_name}'"
        p.last_name = p.last_name.strip
        modified = true
      end
      if p.email.strip != p.email
        puts "Strip '#{p.email}'"
        p.email = p.email.strip
        modified = true
      end
      if modified
        p.save!
      end
    end
  end

  task :destroy_zombie_people => :environment do
    for person in Person.all
      if CrewMember.find_by(person_id: person.id).blank? && person.user.nil?
        puts "#{person.birthday},#{person.id},#{person.first_name},#{person.last_name},#{p}"
        person.destroy!
      end
    end
  end

end

namespace :query do
  task :all_people => :environment do
    for person in Person.all
      puts "#{person.birthday},#{person.id},#{person.first_name},#{person.last_name},#{person.created_at}"
    end
  end

  task :zombie_people => :environment do
    for person in Person.all
      if CrewMember.find_by(person_id: person.id).blank? && person.user.nil?
        puts "#{person.birthday},#{person.id},#{person.first_name},#{person.last_name},#{p}"
      end
    end
  end

  task :duplicate_people => :environment do
    for p in Person.all
      for dp in Person.where("birthday = ? AND first_name = ? AND id != ?", p.birthday, p.first_name, p.id)
        if p.user.nil? and not CrewMember.find_by(person_id: p.id).blank?
          puts "#{p.id},#{p.first_name},#{p.last_name} does not have a user but result"
        elsif not p.user.nil? and CrewMember.find_by(person_id: p.id).blank?
          puts "#{p.id},#{p.first_name},#{p.last_name} does not have result but user #{p.user.id}"
        else
          puts "#{p.id},#{p.first_name},#{p.last_name},#{p.email} is duplicate of #{dp.id} #{dp.first_name},#{dp.last_name},#{dp.email}"
        end
      end
    end
  end

  task :vk_people => :environment do
    for p in Person.all
      vk = false
      other = false
      for t in p.teams
        if t.race.regatta.organizer_id == 1 and (
            t.sailing_state == 'finished' or t.sailing_state == 'started')
          vk = true
        elsif t.sailing_state == 'finished' or t.sailing_state == 'started'
          other = true
        end
      end
      puts "#{p.birthday},#{p.id},#{p.first_name},#{p.last_name},#{vk},#{other}"
    end
  end

end


namespace :mess do
  task :details => :environment do
    for person in Person.all
      person.birthday = person.birthday + (rand (3600) - 1800).day unless person.birthday.nil?
      person.co = nil
      person.zip = Faker::Address.zip
      person.phone = nil
      person.email = Faker::Internet.email unless (person.email == 'stefan.pettersson@lumano.se' || person.email == 'mbj4668@gmail.com' )
      #person.first_name = ''
      #person.last_name = ''
      person.street = Faker::Address.street_name + ' ' + (rand(150)+1).to_s
      person.external_system = 'obfuscated'
      person.save!
    end
  end
end

namespace :destroy do

  task :terrains => :environment do
    Terrain.destroy_all
  end

  task :points => :environment do
    Point.destroy_all
  end

  task :legs => :environment do
    Leg.destroy_all
  end

  task :default_starts => :environment do
    DefaultStart.destroy_all
  end

  task :regattas => :environment do
    Regatta.destroy_all
  end

  task :races => :environment do
    Race.destroy_all
  end

  task :people => :environment do
    Person.destroy_all
  end

  task :users => :environment do
    User.destroy_all
  end

  task :teams => :environment do
    Team.destroy_all
  end

  task :crew_members => :environment do
    CrewMember.destroy_all
  end

  task :boats => :environment do
    Boat.destroy_all
  end

  task :handicaps => :environment do
    Handicap.destroy_all
  end

  task :organizers => :environment do
    Organizer.destroy_all
  end

end
