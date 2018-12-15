class TeamMailer < ApplicationMailer
  default from: 'segla@24-timmars.nu'

  def created_team_email(team)
    receiver_with_name = %("#{team.skipper.first_name} #{team.skipper.last_name}" <#{team.skipper.email}>)
    sender_with_name = %("#{team.race.regatta.name_from}" <#{team.race.regatta.email_from}>)
    @team = team
    mail(to: receiver_with_name, from: sender_with_name, subject: "Din anmälan till #{team.race.regatta.name}" )
  end

  def submitted_team_email(team)
    skipper_with_name = %("#{team.skipper.first_name} #{team.skipper.last_name}" <#{team.skipper.email}>)
    sender_with_name = %("#{team.race.regatta.name_from}" <#{team.race.regatta.email_from}>)
    @team = team
    mail(to: skipper_with_name, from: sender_with_name, subject: "Din anmälan till #{team.race.regatta.name}" )
  end

  def inform_officer_email(team)
    skipper_with_name = %("#{team.skipper.first_name} #{team.skipper.last_name}" <#{team.skipper.email}>)
    sender_with_name = %("#{team.race.regatta.name_from}" <#{team.race.regatta.email_from}>)
    officers = team.race.regatta.email_to.split(',')
    @team = team
    mail(to: officers, from: skipper_with_name, subject: "Deltagaranmälan till #{team.race.regatta.name}" )
  end

  def added_crew_member_email(team, person)
    receiver_with_name = %("#{person.first_name} #{person.last_name}" <#{person.email}>)
    sender_with_name = %("#{team.race.regatta.name_from}" <#{team.race.regatta.email_from}>)
    @team = team
    mail(to: receiver_with_name, from: sender_with_name, subject: "Du är anmäld till #{team.race.regatta.name} som gast" )
  end

  def set_skipper_email(team)
    receiver_with_name = %("#{team.skipper.first_name} #{team.skipper.last_name}" <#{team.skipper.email}>)
    sender_with_name = %("#{team.race.regatta.name_from}" <#{team.race.regatta.email_from}>)
    @team = team
    mail(to: receiver_with_name, from: sender_with_name, subject: "Du är nu skeppare i #{team.race.regatta.name}" )
  end

  def approved_team_email(team)
    receiver_with_name = %("#{team.skipper.first_name} #{team.skipper.last_name}" <#{team.skipper.email}>)
    sender_with_name = %("#{team.race.regatta.name_from}" <#{team.race.regatta.email_from}>)
    @team = team
    mail(to: receiver_with_name, from: sender_with_name, subject: "Din anmälan till #{team.race.regatta.name} är godkänd" )
  end

  def handicap_reset_email(team)
    receiver_with_name = %("#{team.skipper.first_name} #{team.skipper.last_name}" <#{team.skipper.email}>)
    sender_with_name = %("#{team.race.regatta.name_from}" <#{team.race.regatta.email_from}>)
    @team = team
    mail(to: receiver_with_name, from: sender_with_name, subject: "Ditt valda handikapp i #{team.race.regatta.name} har gått ut." )
  end

  def handicap_reset_officer_email(team)
    officers = team.race.regatta.email_to.split(',')
    @team = team
    # mail from the default address; segla@24-timmars.nu
    mail(to: officers, subject: "Det valda handikappet i #{team.race.regatta.name} har gått ut." )
  end

end
