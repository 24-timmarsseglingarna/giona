require 'csv'

namespace :import do
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
        puts "startday #{start_from}"
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
        else 
          team.race_id = race.id
          team.start_number = row['SeglingStartnr'].to_s.strip
          team.boat_name = row['SeglingBåtIndivid'].to_s.strip
          team.boat_class_name = row['SeglingBåtTyp'].to_s.strip 
          #team.boat_sail_number = 
          team.start_point = row['SeglingFNStartpunkt'].to_s.strip.to_i
          team.handicap = row['SeglingSxkTal'].to_s.strip.to_f
          team.plaque_distance = row['SeglingPlakatDist'].to_s.strip.to_f
          team.name = "#{team.boat_name} / #{team.boat_class_name}"

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

  end
end 

namespace :batch do

  task :team_names => :environment do
    for team in Team.all
      skipper = team.skipper
      if team.skipper.nil?
        puts "Team with id: " + team.id.to_s + " is missing a skipper."
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
end

namespace :destroy do

  task :regattas => :environment do
    Regatta.delete_all
  end  

  task :races => :environment do
    Race.delete_all
  end  

  task :people => :environment do
    Person.delete_all
  end  

  task :users => :environment do
    User.delete_all
  end  

  task :teams => :environment do
    Team.delete_all
  end  

  task :crew_members => :environment do
    CrewMember.delete_all
  end  

end
