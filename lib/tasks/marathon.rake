namespace :marathon do
  desc "Import marathon data from CSV file. Usage: rake 'marathon:import[path/to/file.csv,organizer_id,dryrun]'"
  task :import, [:file, :organizer_id, :dryrun] => :environment do |_t, args|
    require 'csv'

    file = args[:file]
    organizer_id = args[:organizer_id].present? ? args[:organizer_id].to_i : nil
    unless file && File.exist?(file) && organizer_id
      puts "Usage: rake 'marathon:import[path/to/file.csv,organizer_id,dryrun]'"
      puts "CSV columns: first_name, last_name, birthday, boat_type, boat_name, year, sailed_dist, plaque_dist"
      exit 1
    end

    dryrun = args[:dryrun].present?
    puts "*** DRY RUN — no data will be written ***" if dryrun

    organizer = Organizer.find(organizer_id)
    unless organizer
      puts "Error: organizer with id #{organizer_id} not found."
      exit 1
    else
      puts "Importing for organizer=#{organizer.name}"
    end

    created_people = 0
    created_logs   = 0
    flagged        = 0
    errors         = 0
    linked   = 0
    no_match = 0
    multi    = 0

    CSV.foreach(file, headers: true, encoding: 'UTF-8') do |row|
      first_name  = row['first_name']&.strip
      last_name   = row['last_name']&.strip
      birthday    = row['birthday'].present? ? Date.parse(row['birthday']) : nil
      boat_type    = row['boat_type']
      boat_name    = row['boat_name']
      year         = row['year'].to_i
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

      mp = if candidates.length >= 1
        puts "FLAGGED (marathon person exists): #{first_name} #{last_name} (#{birthday}) — matched: #{candidates.map{ |p| "#{p.full_name} (id=#{p.id})" }.join(', ')}" #"
        flagged += 1
        next
      else
        # Create new MarathonPerson
        puts "Would create MarathonPerson: #{first_name} #{last_name} (#{birthday})"
        unless dryrun
          new_mp = MarathonPerson.create!(first_name: first_name, last_name: last_name, birthday: birthday)
          puts "Created MarathonPerson: #{new_mp.full_name} (#{birthday})"
        end
        created_people += 1

        # Maybe link to Person
        person_candidates = Person.where(birthday: birthday).select { |p| p.initials == initials }
        if person_candidates.length == 1
          p = person_candidates.first
          p.update_column(:marathon_person_id, mp.id) unless dryrun
          puts "Linked #{p.full_name} → #{first_name} #{last_name}"
          linked += 1
        elsif person_candidates.length > 1
          puts "ERROR: Multiple matches for #{first_name} #{last_name} (#{birthday}): #{person_candidates.map { |p| "#{p.sname} (id=#{p.id})" }.join(', ')}" #"
          multi += 1
        else
          no_match += 1
          if year > 2017
            puts "ERROR: Did not find expected #{p.full_name}"
          end
        end
        next if dryrun
        new_mp
      end

      next if dryrun

      # Create or update the log entry (team_id = nil for historical imports)
      ml = MarathonLog.find_or_initialize_by(marathon_person_id: mp.id, team_id: nil,
                                             date: Date.new(year, 12, 31), organizer_id: organizer_id)
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
    puts "\nLinked: #{linked}, multiple matches: #{multi}, no match: #{no_match}."
  end

  desc "Re-run linking of Person records to MarathonPerson by birthday + initials"
  task link_people: :environment do |task, args|
    dryrun = args.extras.include? 'dryrun'
    linked   = 0
    skipped  = 0
    no_match = 0
    multi    = 0

    Person.where(marathon_person_id: nil).each do |person|
      next if person.birthday.blank?

      candidates = MarathonPerson.where(birthday: person.birthday)
                                 .select { |mp| mp.initials == person.initials }

      if candidates.length == 1
        person.update_column(:marathon_person_id, candidates.first.id) unless dryrun
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
