require 'csv'
require 'open-uri'
require 'nokogiri'


namespace :scrape do

  
  namespace :srs do
    task :certificate => :environment do
      SrsCertificate.destroy_all #TODO
      srs_table_url = "http://matbrev.svensksegling.se/Home/ApprovedList"
      doc = Nokogiri::HTML(open(srs_table_url))
      entries = doc.xpath('//tr')
      first_row = true
      for entry in entries
        unless first_row
          boat_type = SrsCertificate.new
          boat_type.registry_id = entry.css('td')[0].text.strip
          boat_type.owner_name = entry.css('td')[1].text.strip
          boat_type.name = entry.css('td')[2].text.strip
          boat_type.boat_name = entry.css('td')[3].text.strip 
          boat_type.sail_number = entry.css('td')[5].text.to_i
          boat_type.srs = entry.css('td')[8].text.gsub(',', '.').to_f
          boat_type.handicap = (boat_type.srs * 1.215).round(2)
          boat_type.source = 'SRS-mätbrev 2017'
          boat_type.best_before = DateTime.now.in_time_zone.end_of_year
          boat_type.external_system = 'http://matbrev.svensksegling.se/Home/ApprovedList'
          boat_type.save!
        else
          first_row = false
        end
      end
    end
  end


  namespace :srs do
    task :keelboats => :environment do
      SrsKeelboat.destroy_all #TODO
      srs_table_url = "http://matbrev.svensksegling.se/home/boatlist?SrsGrid-sort=B%C3%A5ttyp-asc&SrsGrid-group=&SrsGrid-filter="
      doc = Nokogiri::HTML(open(srs_table_url))
      entries = doc.xpath('//tr')
      first_row = true
      for entry in entries
        unless first_row
          boat_type = SrsKeelboat.new
          boat_type.name = entry.css('td')[0].text.gsub('Ã¶','ö').gsub('Ã¥','ö').gsub('Ã¤','ä')
          boat_type.srs = entry.css('td')[6].text.gsub(',', '.').to_f
          boat_type.handicap = (boat_type.srs * 1.215).round(2)
          boat_type.source = 'SRS kölbåtar 2017'
          boat_type.best_before = DateTime.now.in_time_zone.end_of_year
          boat_type.external_system = 'http://matbrev.svensksegling.se/home/boatlist?SrsGrid-sort=B%C3%A5ttyp-asc&SrsGrid-group=&SrsGrid-filter='
          boat_type.save!
        else
          first_row = false
        end
      end
    end

    task :multihulls => :environment do
      SrsMultihull.destroy_all #TODO
      srs_table_url = "http://matbrev.svensksegling.se/home/srsflerskrovlist"
      doc = Nokogiri::HTML(open(srs_table_url))
      entries = doc.xpath('//tr')
      first_row = true
      for entry in entries
        unless first_row
          boat_type = SrsMultihull.new
          boat_type.name = entry.css('td')[0].text.gsub('Ã¶','ö').gsub('Ã¥','ö').gsub('Ã¤','ä')
          boat_type.srs = entry.css('td')[1].text.gsub(',', '.').to_f
          boat_type.handicap = (boat_type.srs * 1.215).round(2)
          boat_type.source = 'SRS flerskrov 2017'
          boat_type.best_before = DateTime.now.in_time_zone.end_of_year
          boat_type.external_system = 'http://matbrev.svensksegling.se/home/srsflerskrovlist'
          boat_type.save!
        else
          first_row = false
        end
      end
    end
  end
end

namespace :import do
  namespace :srs do 
    task :dingies => :environment do
      SrsDingy.destroy_all
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "srs-jolle-2017.csv"), "r"), :headers => true) do |row|
        boat_type = SrsDingy.new
        boat_type.name = row['Typ'].to_s.strip
        boat_type.srs = row['SRS'].to_f
        boat_type.handicap = (boat_type.srs * 1.215).round(2)
        boat_type.source = 'SRS jolle 2017'
        boat_type.best_before = DateTime.now.in_time_zone.end_of_year
        boat_type.external_system = 'http://www.svensksegling.se/globalassets/svenska-seglarforbundet/for-batagare/srs/srs-tabellen-for-jollar.pdf'
        boat_type.save!
      end
    end
  end

  namespace :sxk do 
    task :certificate => :environment do
      SxkCertificate.destroy_all
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "sxk-tal-2016.csv"), "r"), :headers => true) do |row|
        boat_type = SxkCertificate.new
        boat_type.name = row['Boat'].to_s.strip
        boat_type.handicap = row['SXKtal'].to_f
        boat_type.boat_name = row['Name'].to_s.strip unless row['Name'].to_s.strip == 'NULL' 
        boat_type.owner_name = row['Owner'].to_s.strip unless row['Owner'].to_s.strip == 'NULL'
        boat_type.sail_number = row['Segelnr'].to_i
        boat_type.registry_id = row['Regnr'].to_s.strip
        boat_type.source = 'SXK-mätbrev'
        boat_type.best_before = nil #DateTime.now.in_time_zone.end_of_year
        boat_type.external_system = 'http://aws.24-timmars.nu/phpmyadmin'
        boat_type.save!
      end
    end
  end



  namespace :starema do 
    task :people => :environment do
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "Starema-St-Deltagare.csv"), "r"), :headers => true) do |row|
        puts row['DeltNamn']
        p = Person.find_or_create_by(external_system: 'Starema-St', external_id: row['DeltNr'].to_s.strip.to_i)
        p.first_name = row['DeltFörnamn'].to_s.strip
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
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "starema-sthlm-regatta-race.csv"), "r"), :headers => true) do |row|
        regatta = Regatta.find_or_create_by(name: row['TmpRegattaName'].to_s.strip)
        regatta.organizer = row['TmpOrganizer'].to_s.strip
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
                                       common_finish: false,
                                       mandatory_common_finish: false
                                       )
        race.save!
      end
    end


    task :teams => :environment do
      # File format: SeglingNr, SeglingRegistrerandeKrets, SeglingFNStart, SeglingStartDag, 
      # SeglingStartTid, SeglingPeriod, SeglingFNBoatIndivid, SeglingBåtIndivid, SeglingBåtTyp,
      # SeglingFNStartpunkt, SeglingStartnr, SeglingÖvertid, SeglingTotalDist, SeglingAvdrag, 
      # SeglingGodkDist, SeglingSxkTal, SeglingPlakatDist, SeglingEfteranmäld, SeglingEjStart,
      # SeglingBrutit, SeglingFiktiv, SeglingÅr, SeglingVH, SeglingLåst, SeglingDeltarFest, 
      # SeglingDeltarFestNotering, SeglingBetalt, SeglingBetaltBelopp, SeglingKorrDistans

      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "Starema-St-Seglingar.csv"), "r"), :headers => true) do |row|
        team = Team.find_or_create_by(external_id: row['SeglingNr'].to_s.strip.to_i, external_system: 'Starema-St')
        race = Race.find_by( external_id: row['SeglingFNStart'].to_s.strip.to_i, external_system: 'Starema-St')
        if race.nil?
          puts row
          team.destroy!
        else 
          team.race_id = race.id
          team.start_number = row['SeglingStartnr'].to_s.strip
          team.boat_name = row['SeglingBåtIndivid'].to_s.strip
          team.boat_class_name = row['SeglingBåtTyp'].to_s.strip 
          #team.boat_sail_number = 
          team.start_point = row['SeglingFNStartpunkt'].to_s.strip.to_i
          team.handicap = row['SeglingSxkTal'].to_s.strip.to_f
          team.plaque_distance = row['SeglingPlakatDist'].to_s.strip.to_f
          team.name = "#{team.boat_name} / #{team.boat_class_name}" if team.name.blank?
          boat = Boat.find_by( external_id: row['SeglingFNBoatIndivid'].to_s.strip.to_i, external_system: 'Starema-St')
          if boat.nil?
            puts row
          else
            team.boat_id = boat.id
            boat_type = LegacyBoatType.find_or_create_by( name: team.boat_class_name, 
                                                          handicap: team.handicap, 
                                                          external_system: 'Starema-St',
                                                          source: 'Arkiv',
                                                          best_before: DateTime.parse('2016-12-31'))
            boat.boat_types << boat_type

            if team.boat_sail_number == 0 || team.boat_sail_number.nil? 
              team.boat_sail_number = nil
            else
              team.boat_sail_number = boat.sail_number
            end
          end
          if row['SeglingEjStart'].to_i == 1
            team.did_not_start = true 
          else
            team.did_not_start = false
          end
           
          if ( row['SeglingBrutit'].to_i == 1 )
            team.did_not_finish = true
          else
            team.did_not_finish = false
          end

          if ( row['SeglingBetalt'].to_i == 1 )
            team.paid_fee = true 
          else
            team.paid_fee = false
          end

          team.save!
        end
      end
    end


    task :crew_members => :environment do
      # File format: 
      # DeltariSeglingCtr, DeltariRegistrerandeKrets, DeltariFNDeltagare, 
      # DeltariFNSegling, DeltariSkipperGastqq, DeltariFNSkipperGast

      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "Starema-St-DeltariSeling.csv"), "r"), :headers => true) do |row|
        team = Team.find_by(external_id: row['DeltariFNSegling'].to_s.strip.to_i, external_system: 'Starema-St')
        person = Person.find_by(external_id: row['DeltariFNDeltagare'].to_s.strip.to_i, external_system: 'Starema-St')
        crew_member = CrewMember.find_or_create_by(team: team, person: person)
        if(row['DeltariFNSkipperGast'].to_i == 2)
          crew_member.skipper = true 
        else
          crew_member.skipper = false
        end
        crew_member.save!
      end
    end


    task :boats => :environment do
      # File format: 
      # BoatIndNr, BoatIndFNBoattyp, BoatIndNamn, BoatIndParmNr, BoatIndVHF, BoatIndMobil
      CSV.foreach( File.open(File.join(Rails.root, "db", "import", "Starema-St-BoatIndivid.csv"), "r"), :headers => true) do |row|
        boat = Boat.find_or_create_by(external_id: row['BoatIndNr'].to_s.strip.to_i, external_system: 'Starema-St')
        name = row['BoatIndNamn'].to_s
        if name.blank?
          puts row
          name = '*** no name ***'
        end
        boat.name = name
        sail_number = row['BoatIndParmNr'].to_i
        if sail_number == 0
          boat.sail_number = nil
        else
          boat.sail_number = sail_number
        end
        boat.vhf_call_sign = row['BoatIndVHF'].to_s
        boat.ais_mmsi = nil
        #boat_class = BoatClass.find_by(external_id: row['BoatIndFNBoattyp'].to_i, external_system: 'Starema-St')
        #if boat_class.present?
        #  boat.boat_class_id = boat_class.id
        #  boat.save!
        #else
        ##  boat.destroy!
        #end
      end
    end




  end
end 

namespace :batch do

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
      if race.name.nil?
        race.name = race.regatta.name + ', period: ' + race.period.to_s + ', start från: ' + I18n.l(race.start_from, format: :short)
        race.save!
      end
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

  task :boat_classes => :environment do
    BoatClass.destroy_all
  end  

  task :boats => :environment do
    Boat.destroy_all
  end  


end
