class MarathonMailer < ApplicationMailer
  default from: 'segla@24-timmars.nu'

  ADMIN_EMAIL = ENV.fetch('ADMIN_EMAIL', 'admin@24-timmars.nu')

  def single_match_email(person, candidate)
    @person    = person
    @candidate = candidate
    mail(to: ADMIN_EMAIL, subject: "Maratonmatchning: #{person.sname}")
  end

  def multiple_matches_email(person, candidates)
    @person     = person
    @candidates = candidates
    mail(to: ADMIN_EMAIL, subject: "Maratondublett: #{person.sname}")
  end

  def no_match_email(person)
    @person = person
    mail(to: ADMIN_EMAIL, subject: "Ny seglare utan maratonpost: #{person.sname}")
  end
end
