# coding: utf-8


# install with: rake testdata:team

namespace :testdata do
  task :team => :environment do
    # first, clean up from previous runs
    regatta = Regatta.find_by(name: 'Testregatta')
    if regatta
      # deletes all races, teams, crewmembers automatically
      regatta.destroy!
      regatta.destroy!
    end

    # clean up test persons and users
    Person.where(["email LIKE ?", "%@test.se"]).each do |person|
      person.destroy!
      person.destroy!
    end
    User.where(["email LIKE ?", "%@test.se"]).each do |user|
      user.destroy!
      user.destroy!
    end

    # clean up *all* logs
    Log.all.each do |log|
      log.destroy!
      log.destroy!
    end

    regatta = Regatta.new
    regatta.organizer = Organizer.find_by name: 'Svenska Kryssarklubbens Stockholmskrets'
    regatta.name = 'Testregatta'
    regatta.email_from = 'stefan@24-timmars.nu'
    regatta.name_from = 'Stefan Pettersson'
    regatta.email_to = 'stefan@24-timmars.nu, arne@24-timmars.nu'
    regatta.confirmation = 'Hej och välkommen. Jättekul. Lång text om hur det funkar. Ska skickas via mejl.'
    regatta.terrain = Terrain.where(published: true).last
    regatta.active = true
    regatta.save!

    race = Race.new
    race.regatta = regatta
    race.start_from = DateTime.parse('2018-04-01 12:00+2')
    race.start_to = DateTime.parse('2018-04-01 12:00+2')
    race.period = 24
    race.common_finish = nil
    race.external_system = 'testdata'
    race.external_id = '1'
    race.save!

    # special boat, not in data imported from Starema
    boat = Boat.find_by(name: 'Alina')
    if not boat
      boat = Boat.new
      boat.name = 'Alina'
      boat.boat_type_name = 'Linjett 37'
      boat.sail_number = 63
      boat.save!
    end

    ##

    boat = Boat.find_by(name: 'Alina')
    skipper = Person.find_by(email: 'mbj4668@gmail.com')

    team = Team.new
    team.name = 'Alina/Martin'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 580
    team.finish_point = 580
    team.start_number = 11
    team.handicap = SrsKeelboat.find_by name: 'Linjett 37'
    team.handicap_type = 'SrsKeelboat'
    
    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ##

    person = Person.new
    person.email = 'stefan@test.se'
    person.first_name = 'Stefan'
    person.last_name = 'Petterson'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Vindil')
    skipper = person

    team = Team.new
    team.name = 'Vindil/Stefan'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 552
    team.finish_point = 552
    team.start_number = 12
    team.handicap = SrsKeelboat.find_by name: 'Scampi'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ##

    person = Person.new
    person.email = 'arvid@test.se'
    person.first_name = 'Arvid'
    person.last_name = 'Englund'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Abbe')
    skipper = person

    team = Team.new
    team.name = 'Abbe/Arvid'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 585
    team.finish_point = 585
    team.start_number = 13
    team.handicap = SrsKeelboat.find_by name: 'Albin Vigg'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ##

    person = Person.new
    person.email = 'thomas@test.se'
    person.first_name = 'Thomas'
    person.last_name = 'Bindzau'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Plasque')
    skipper = person

    team = Team.new
    team.name = 'Plasque/Thomas'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 580
    team.finish_point = 580
    team.start_number = 14
    team.handicap = SrsKeelboat.find_by name: 'Seacat'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ##

    person = Person.new
    person.email = 'christer@test.se'
    person.first_name = 'Christer'
    person.last_name = 'Forsgren'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Vindälva')
    skipper = person

    team = Team.new
    team.name = 'Vindälva/Christer'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 552
    team.finish_point = 552
    team.start_number = 15
    team.handicap = SrsKeelboat.find_by name: 'Sveakryssare'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ##

    person = Person.new
    person.email = 'arne@test.se'
    person.first_name = 'Arne'
    person.last_name = 'Wallers'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Bon-Bon')
    skipper = person

    team = Team.new
    team.name = 'Bon-Bon/Arne'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 552
    team.finish_point = 552
    team.start_number = 16
    team.handicap = SrsKeelboat.find_by name: 'Mixer Cr'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ##

    person = Person.new
    person.email = 'michael@test.se'
    person.first_name = 'Michael'
    person.last_name = 'Kramers'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Cirrus')
    skipper = person

    team = Team.new
    team.name = 'Cirrus/Michael'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 585
    team.finish_point = 585
    team.start_number = 17
    team.handicap = SrsKeelboat.find_by name: 'Arcona 355'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ##

    person = Person.new
    person.email = 'niklas@test.se'
    person.first_name = 'Niklas'
    person.last_name = 'Krantz'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Hafsorkestern')
    skipper = person

    team = Team.new
    team.name = 'Hafsorkestern/Niklas'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 555
    team.finish_point = 555
    team.start_number = 18
    team.handicap = SrsKeelboat.find_by name: 'Bavaria 30 Cr. 05-07'
    team.handicap_type = 'SrsKeelboat'

    team.approved!

    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ##

    person = Person.new
    person.email = 'roger@test.se'
    person.first_name = 'Roger'
    person.last_name = 'Henriksson'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Far Out')
    skipper = person

    team = Team.new
    team.name = 'Far Out/Roger'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 580
    team.finish_point = 580
    team.start_number = 20
    team.handicap = SrsKeelboat.find_by name: 'Conqubin 38 Cr'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!


    ###

    race = Race.new
    race.regatta = regatta
    race.start_from = DateTime.parse('2018-03-31 12:00+2')
    race.start_to = DateTime.parse('2018-04-01 20:00+2')
    race.period = 48
    race.common_finish = nil
    race.external_system = 'testdata'
    race.external_id = '1'
    race.save!

    ##

    person = Person.new
    person.email = 'cf@test.se'
    person.first_name = 'Carl-Fredric'
    person.last_name = 'Hunyadi'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Lea')
    skipper = person

    team = Team.new
    team.name = 'Lea/Carl-Fredric'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 540
    team.finish_point = 540
    team.start_number = 19
    team.handicap = SrsKeelboat.find_by name: 'NF'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ##

    person = Person.new
    person.email = 'matte@test.se'
    person.first_name = 'Mathias'
    person.last_name = 'Högberg'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    boat = Boat.find_by(name: 'Lady Gutte')
    skipper = person

    team = Team.new
    team.name = 'Lady Gutte/Mathias'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 579
    team.finish_point = 579
    team.start_number = 21
    team.handicap = SrsKeelboat.find_by name: 'Comfort 32'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    ###

    race = Race.new
    race.regatta = regatta
    race.start_from = DateTime.parse('2018-04-01 11:30+2')
    race.start_to = DateTime.parse('2018-04-01 12:00+2')
    race.period = 24
    race.common_finish = 552
    race.external_system = 'testdata'
    race.external_id = '1'
    race.description = 'Skutsegling start/mål 552 Grönö'
    race.save!

    person = Person.new
    person.email = 'jan@test.se'
    person.first_name = 'Jan'
    person.last_name = 'Wrangel'
    person.save!

    user = User.new
    user.email = person.email
    user.password = "secret"
    user.role = "user"
    user.person = person
    user.save!

    skipper = person

    boat = Boat.find_by(name: 'Gumman 100')

    team = Team.new
    team.name = 'Sofia Linnea/Jan'
    team.race = race
    team.boat = boat
    team.boat_name = 'Sofia Linnea'
    team.boat_type_name = 'Vedjakt'
    team.boat_sail_number = 0
    team.start_point = 552
    team.finish_point = 552
    team.start_number = 22
    team.handicap = SrsKeelboat.find_by name: 'Linjett 33'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!


    regatta = Regatta.find_by(name: 'Ensamseglingen test 2017')
    if regatta
      regatta.destroy!
      regatta.destroy!
    end
    regatta = Regatta.new
    regatta.organizer = Organizer.find_by name: 'Svenska Kryssarklubbens Stockholmskrets'
    regatta.name = 'Ensamseglingen test 2017'
    regatta.email_from = 'stefan@24-timmars.nu'
    regatta.name_from = 'Stefan Pettersson'
    regatta.email_to = 'stefan@24-timmars.nu, arne@24-timmars.nu'
    regatta.confirmation = 'Hej och välkommen. Jättekul. Lång text om hur det funkar. Ska skickas via mejl.'
    regatta.terrain = Terrain.where(published: true).first
    regatta.active = true
    regatta.save!

    race = Race.new
    race.regatta = regatta
    race.start_from = DateTime.parse('2017-06-17 07:00+2')
    race.start_to = DateTime.parse('2017-06-17 07:00+2')
    race.period = 12
    race.common_finish = 555
    race.external_system = 'testdata'
    race.external_id = '1'
    race.save!

    boat = Boat.find_by(name: 'Gumman 100')
    skipper = Person.find_by(email: 'mbj4668@gmail.com')

    team = Team.new
    team.name = 'Gumman 100/Martin'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 552
    team.finish_point = 553
    team.start_number = 1
    team.handicap = SrsKeelboat.find_by name: 'Linjett 33'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    person = Person.new
    person.email = 'stefan.petterson@lumano.se'
    person.first_name = 'Stefan'
    person.last_name = 'Petterson'
    person.save!

    boat = Boat.find_by(name: 'Vindil')
    skipper = person

    team = Team.new
    team.name = 'Vindil/Stefan'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_type_name
    team.boat_sail_number = boat.sail_number
    team.start_point = 540
    team.finish_point = 553
    team.start_number = 2
    team.handicap = SrsKeelboat.find_by name: 'Scampi'
    team.handicap_type = 'SrsKeelboat'

    team.approved!
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

  end

end
