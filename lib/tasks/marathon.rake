namespace :marathon do
  desc "Import marathon data from CSV file. Usage: rake 'marathon:import[path/to/file.csv]'"
  task :import, [:file] => :environment do |_t, args|
    require 'csv'

    file = args[:file]
    unless file && File.exist?(file)
      puts "Usage: rake 'marathon:import[path/to/file.csv]'"
      puts "CSV columns: first_name, last_name, birthday, boat_type, boat_name, year, organizer_id, sailed_dist, plaque_dist"
      exit 1
    end

    created_people = 0
    created_logs   = 0
    flagged        = 0
    errors         = 0

    CSV.foreach(file, headers: true, encoding: 'UTF-8') do |row|
      first_name  = row['first_name']&.strip
      last_name   = row['last_name']&.strip
      birthday    = row['birthday'].present? ? Date.parse(row['birthday']) : nil
      boat_type   = row['boat_type']
      boat_name   = row['boat_name']
      year        = row['year'].to_i
      organizer_id = row['organizer_id'].present? ? row['organizer_id'].to_i : nil
      sailed_dist  = row['sailed_dist'].to_f
      plaque_dist  = row['plaque_dist'].to_f

      unless first_name.present? && last_name.present? && year > 0
        puts "Skipping invalid row: #{row.inspect}"
        errors += 1
        next
      end

      initials = "#{first_name.first.upcase}#{last_name.first.upcase}"

      # Find candidates by birthday + initials
      candidates = if birthday
        MarathonPerson.where(birthday: birthday).select { |mp| mp.initials == initials }
      else
        MarathonPerson.where(first_name: first_name, last_name: last_name, birthday: nil)
      end

      mp = if candidates.length == 1
        candidates.first
      elsif candidates.length > 1
        puts "FLAGGED (multiple matches): #{first_name} #{last_name} (#{birthday}) — matched: #{candidates.map(&:full_name).join(', ')}"
        flagged += 1
        next
      else
        # Create new MarathonPerson
        new_mp = MarathonPerson.create!(first_name: first_name, last_name: last_name, birthday: birthday)
        created_people += 1
        puts "Created MarathonPerson: #{new_mp.full_name} (#{birthday})"
        new_mp
      end

      # Create or update the log entry (team_id = nil for historical imports)
      ml = MarathonLog.find_or_initialize_by(marathon_person_id: mp.id, team_id: nil,
                                             year: year, organizer_id: organizer_id)
      ml.sailed_dist = sailed_dist
      ml.plaque_dist = plaque_dist
      ml.boat_type   = boat_type
      ml.boat_name   = boat_name
      ml.save!
      created_logs += 1

    rescue => e
      puts "Error on row #{row.inspect}: #{e.message}"
      errors += 1
    end

    puts "\nDone. Created #{created_people} marathon people, #{created_logs} log entries, #{flagged} flagged for review, #{errors} errors."
  end

  desc "Re-run linking of Person records to MarathonPerson by birthday + initials"
  task link_people: :environment do
    linked   = 0
    skipped  = 0
    no_match = 0
    multi    = 0

    Person.where(marathon_person_id: nil).each do |person|
      next if person.birthday.blank?

      candidates = MarathonPerson.where(birthday: person.birthday)
                                 .select { |mp| mp.initials == person.initials }

      if candidates.length == 1
        person.update_column(:marathon_person_id, candidates.first.id)
        puts "Linked #{person.sname} → #{candidates.first.full_name}"
        linked += 1
      elsif candidates.length > 1
        puts "Multiple matches for #{person.sname} (#{person.birthday}): #{candidates.map(&:full_name).join(', ')}"
        multi += 1
      else
        no_match += 1
      end
    end

    puts "\nDone. Linked: #{linked}, multiple matches: #{multi}, no match: #{no_match}, skipped (no birthday): #{skipped}."
  end
end
