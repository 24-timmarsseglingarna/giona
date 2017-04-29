
namespace :testdata do 
  task :team => :environment do
    regatta = Regatta.find_by(name: 'Testregatta 2017')
    if regatta
      regatta.destroy!
    end
    regatta = Regatta.new
    regatta.organizer = 'Svenska Kryssarklubbens Stockholmskrets'
    regatta.name = 'Testregatta 2017'
    regatta.email_from = 'stefan@24-timmars.nu'
    regatta.name_from = 'Stefan Pettersson'
    regatta.email_to = 'stefan@24-timmars.nu, arne@24-timmars.nu'
    regatta.confirmation = 'Hej och välkommen. Jättekul. Lång text om hur det funkar. Ska skickas via mejl.'
    regatta.active = true
    regatta.save!

    race = Race.new
    race.regatta = regatta
    race.name = '24-timmars 2017T Stockholm'
    race.start_from = DateTime.parse('2017-06-03 12:00+2')
    race.start_to = DateTime.parse('2017-06-03 12:00+2')
    race.period = 24
    race.common_finish = false
    race.mandatory_common_finish = false
    race.external_system = 'testdata'
    race.external_id = '1'
    race.save!

    boat = Boat.find_by(name: 'Gumman 100')
    skipper = Person.find_by(email: 'mbj4668@gmail.com')
    user = User.find_by(email: 'mbj4668@gmail.com')
    user.person=skipper
    user.save!

    team = Team.new
    team.name = 'Gumman 100/Martin'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_class.name
    team.boat_sail_number = boat.sail_number
    team.start_point = 552
    team.finish_point = 552
    team.start_number = 11
    team.handicap = 1.185
    team.paid_fee = true
    team.active = true
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    boat = Boat.find_by(name: 'Vindil')
    skipper = Person.find_by(email: 'stefan.pettersson@lumano.se')

    team = Team.new
    team.name = 'Vindil/Stefan'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_class.name
    team.boat_sail_number = boat.sail_number
    team.start_point = 552
    team.finish_point = 552
    team.start_number = 12
    team.handicap = 1.097
    team.paid_fee = true
    team.active = true
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!


    regatta = Regatta.find_by(name: 'Ensamseglingen test 2017')
    if regatta
      regatta.destroy!
    end
    regatta = Regatta.new
    regatta.organizer = 'Svenska Kryssarklubbens Stockholmskrets'
    regatta.name = 'Ensamseglingen test 2017'
    regatta.email_from = 'stefan@24-timmars.nu'
    regatta.name_from = 'Stefan Pettersson'
    regatta.email_to = 'stefan@24-timmars.nu, arne@24-timmars.nu'
    regatta.confirmation = 'Hej och välkommen. Jättekul. Lång text om hur det funkar. Ska skickas via mejl.'
    regatta.active = true
    regatta.save!

    race = Race.new
    race.regatta = regatta
    race.name = '12-timmars ensam 2017E Stockholm'
    race.start_from = DateTime.parse('2017-06-17 07:00+2')
    race.start_to = DateTime.parse('2017-06-17 07:00+2')
    race.period = 12
    race.common_finish = true
    race.mandatory_common_finish = true
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
    team.boat_type_name = boat.boat_class.name
    team.boat_sail_number = boat.sail_number
    team.start_point = 552
    team.finish_point = 553
    team.start_number = 1
    team.handicap = 1.185
    team.paid_fee = true
    team.active = true
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

    boat = Boat.find_by(name: 'Vindil')
    skipper = Person.find_by(email: 'stefan.pettersson@lumano.se')

    team = Team.new
    team.name = 'Vindil/Stefan'
    team.race = race
    team.boat = boat
    team.boat_name = boat.name
    team.boat_type_name = boat.boat_class.name
    team.boat_sail_number = boat.sail_number
    team.start_point = 540
    team.finish_point = 553
    team.start_number = 2
    team.handicap = 1.097
    team.paid_fee = true
    team.active = true
    team.save!

    crew_member = CrewMember.new
    crew_member.person = skipper
    crew_member.team = team
    crew_member.skipper = true
    crew_member.save!

  end

end
