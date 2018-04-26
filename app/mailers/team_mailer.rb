class TeamMailer < ApplicationMailer
  default from: 'info@24-timmars.nu'

  def created_team_email(team)
    receiver_with_name = %("#{team.skipper.first_name} #{team.skipper.last_name}" <#{team.skipper.email}>)
    sender_with_name = %("#{team.race.regatta.name_from}" <#{team.race.regatta.email_from}>)
    @team = team
    mail(to: receiver_with_name, from: sender_with_name, subject: "Din anmälan till #{team.race.regatta.name}" )
  end

end
