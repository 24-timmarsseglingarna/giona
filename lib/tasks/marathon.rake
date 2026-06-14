namespace :marathon do
  desc "Import marathon data from CSV file. Usage: rake 'marathon:import[path/to/file.csv,organizer_id,dryrun,col_sep]'"
  task :import, [:file, :organizer_id, :dryrun, :col_sep] => :environment do |_t, args|
    require 'csv'

    file = args[:file]
    organizer_id = args[:organizer_id].present? ? args[:organizer_id].to_i : nil
    col_sep = args[:col_sep].presence || ','
    unless file && File.exist?(file) && organizer_id
      puts "Usage: rake 'marathon:import[path/to/file.csv,organizer_id,dryrun,col_sep]'"
      puts "CSV columns: first_name, last_name, birthday, boat_type, boat_name, year, sailed_dist, plaque_dist"
      puts "col_sep defaults to ',' — pass ';' for Swedish semicolon-separated exports."
      exit 1
    end

    dryrun = args[:dryrun].present?
    puts "*** DRY RUN — no data will be written ***" if dryrun

    # Parse Swedish-formatted numbers: strip thousands separators (incl. NBSP)
    # and turn the decimal comma into a dot, e.g. "13 911,8" -> 13911.8.
    to_number = ->(s) { s.to_s.gsub(/[\s\u00A0]/, q()).tr(',', '.').to_f }

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

    CSV.foreach(file, headers: true, col_sep: col_sep, encoding: 'UTF-8') do |row|
      first_name  = row['first_name']&.strip
      last_name   = row['last_name']&.strip
      birthday    = row['birthday'].present? ? Date.parse(row['birthday']) : nil
      boat_type    = row['boat_type']
      boat_name    = row['boat_name']
      year         = row['year'].to_i
      year         = 1900 if year.zero?  # rows with no year (aggregate/unknown) -> 1900
      sailed_dist  = to_number.call(row['sailed_dist'])
      plaque_dist  = to_number.call(row['plaque_dist'])

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

      # Find matching Person (by birthday + initials, or by exact name when no birthday).
      person_candidates = if birthday
        Person.where(birthday: birthday).select { |p| p.initials == initials }
      else
        Person.where(first_name: first_name, last_name: last_name).to_a
      end

      # Year-based flagging based on Person existence: recent rows (>= 2018)
      # should have a matching Person, old rows (< 2018) should not.
      if year >= 2018 && person_candidates.empty?
        puts "FLAGGED (>=2018, no person): #{first_name} #{last_name} (#{birthday})"
        flagged += 1
      elsif year < 2018 && person_candidates.any?
        puts "FLAGGED (<2018, unexpected person): #{first_name} #{last_name} (#{birthday}) — #{person_candidates.map { |p| "#{p.sname} (id=#{p.id})" }.join(', ')}"
        flagged += 1
      end

      mp = if candidates.length >= 1
        puts "Marathon person exists, skipping: #{first_name} #{last_name} (#{birthday}) — matched: #{candidates.map{ |p| "#{p.full_name} (id=#{p.id})" }.join(', ')}" #"
        next
      else
        # Create new MarathonPerson
        puts "Would create MarathonPerson: #{first_name} #{last_name} (#{birthday})"
        unless dryrun
          new_mp = MarathonPerson.create!(first_name: first_name, last_name: last_name, birthday: birthday)
          puts "Created MarathonPerson: #{new_mp.full_name} (#{birthday})"
        end
        created_people += 1

        # Link every Person found in the flag step to this marathon person.
        if person_candidates.any?
          person_candidates.each do |p|
            if dryrun
              puts "Would link #{p.sname} (id=#{p.id}) → #{first_name} #{last_name}"
            else
              p.update_column(:marathon_person_id, new_mp.id)
              puts "Linked #{p.sname} (id=#{p.id}) → #{new_mp.full_name}"
            end
          end
          linked += person_candidates.length
          if person_candidates.length > 1
            puts "WARNING: linked #{person_candidates.length} persons to #{first_name} #{last_name}: #{person_candidates.map { |p| "#{p.sname} (id=#{p.id})" }.join(', ')}" #"
            multi += 1
          end
        else
          no_match += 1
          puts "ERROR: no person found for #{first_name} #{last_name} (#{birthday})" if year >= 2018
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

  desc "Import marathon data from a CSV without birthday, matching MarathonPerson by name " \
       "(exact, then fuzzy). Usage: rake 'marathon:import_by_name[path/to/file.csv,organizer_id,dryrun,col_sep]'"
  task :import_by_name, [:file, :organizer_id, :col_sep, :dryrun] => :environment do |_t, args|
    require 'csv'
    require 'did_you_mean'

    file = args[:file]
    organizer_id = args[:organizer_id].present? ? args[:organizer_id].to_i : nil
    col_sep = args[:col_sep].presence || ','
    unless file && File.exist?(file) && organizer_id
      puts "Usage: rake 'marathon:import_by_name[path/to/file.csv,organizer_id,dryrun,col_sep]'"
      puts "CSV columns: first_name, last_name, boat_type, boat_name, year, sailed_dist, plaque_dist (birthday is not used)"
      puts "col_sep defaults to ',' — pass ';' for Swedish semicolon-separated exports."
      exit 1
    end

    dryrun = args[:dryrun].present?
    puts "*** DRY RUN — no data will be written ***" if dryrun

    # Parse Swedish-formatted numbers: strip thousands separators (incl. NBSP)
    # and turn the decimal comma into a dot, e.g. "13 911,8" -> 13911.8.
    to_number = ->(s) { s.to_s.gsub(/[\s\u00A0]/, '').tr(',', '.').to_f }

    organizer = Organizer.find(organizer_id)
    puts "Importing for organizer=#{organizer.name}"

    # Max Levenshtein distance (on the normalised "first last" string) accepted as a fuzzy match.
    max_distance = 2

    normalize = ->(s) { s.to_s.strip.downcase }
    full_name = ->(first, last) { "#{normalize.call(first)} #{normalize.call(last)}" }

    # Return records from +collection+ whose name matches +first+/+last+: exact
    # (case-insensitive) matches if any, otherwise those within max_distance.
    name_matches = lambda do |collection, first, last, year|
      target = full_name.call(first, last)
      exact = collection.select { |r| full_name.call(r.first_name, r.last_name) == target }
      next exact if exact.any? or year < 2018
      collection.select { |r| DidYouMean::Levenshtein.distance(full_name.call(r.first_name, r.last_name), target) <= max_distance }
    end

    # Load all marathon people and all persons once so the fuzzy comparison
    # doesn't hit the DB per row.
    all_marathon_people = MarathonPerson.all.to_a
    all_people          = Person.all.to_a

    created_people = 0
    created_logs   = 0
    flagged        = 0
    errors         = 0
    matched        = 0
    no_match       = 0
    linked         = 0
    link_multi     = 0

    CSV.foreach(file, headers: true, col_sep: col_sep, encoding: 'UTF-8') do |row|
      first_name  = row['first_name']&.strip
      last_name   = row['last_name']&.strip
      boat_type   = row['boat_type']
      boat_name   = row['boat_name']
      year        = row['year'].to_i
      year        = 1900 if year.zero?  # rows with no year (aggregate/unknown) -> 1900
      sailed_dist = to_number.call(row['sailed_dist'])
      plaque_dist = to_number.call(row['plaque_dist'])

      unless first_name.present? && last_name.present? && year > 0
        puts "Skipping invalid row: #{row.inspect}"
        errors += 1
        next
      end

      target = full_name.call(first_name, last_name)

      # 1. Exact (case-insensitive) name match.
      match = all_marathon_people.find { |mp| full_name.call(mp.first_name, mp.last_name) == target }
      match_kind = match ? 'exact' : nil

      # 2. Fuzzy fallback: closest candidate within max_distance.
      unless match
        best = all_marathon_people
                 .map { |mp| [mp, DidYouMean::Levenshtein.distance(full_name.call(mp.first_name, mp.last_name), target)] }
                 .select { |_mp, dist| dist <= max_distance }
                 .min_by { |_mp, dist| dist }
        if best
          match, distance = best
          match_kind = "similar (distance #{distance})"
        end
      end

      # Find matching Person(s) by name (exact, then fuzzy).
      person_matches = name_matches.call(all_people, first_name, last_name, year)
      person_match_fuzzy = person_matches.any? &&
                           person_matches.none? { |p| full_name.call(p.first_name, p.last_name) == target }

      # Year-based flagging based on Person existence: recent rows (>= 2018)
      # should have a matching Person, old rows (< 2018) should not.
      if year >= 2018 && person_matches.empty?
        puts "FLAGGED (>=2018, no person): #{first_name} #{last_name} (#{year})"
        flagged += 1
      elsif year < 2018 && person_matches.any?
        puts "FLAGGED (<2018, unexpected person): #{first_name} #{last_name} (#{year}) → #{person_matches.map { |p| "#{p.sname} (id=#{p.id})" }.join(', ')}"
        flagged += 1
      end

      # Resolve the marathon person, creating one when there is no match.
      mp = match
      if mp
        matched += 1
        puts "Matched #{first_name} #{last_name} → #{mp.full_name} (id=#{mp.id}, #{match_kind})"
      else
        no_match += 1
        puts "Would create MarathonPerson: #{first_name} #{last_name}"
        unless dryrun
          mp = MarathonPerson.create!(first_name: first_name, last_name: last_name, birthday: nil)
          all_marathon_people << mp
          puts "Created MarathonPerson: #{mp.full_name} (id=#{mp.id})"
        end
        created_people += 1
      end

      # Link every Person found in the flag step to this marathon person.
      if person_matches.any?
        puts "WARNING: no exact name match for #{first_name} #{last_name} (#{year}), using fuzzy match: #{person_matches.map { |p| "#{p.sname} (id=#{p.id})" }.join(', ')}" if person_match_fuzzy
        person_matches.each do |person|
          if dryrun
            puts "Would link #{person.sname} (id=#{person.id}) → #{first_name} #{last_name}"
          else
            person.update_column(:marathon_person_id, mp.id)
            person.marathon_person_id = mp.id  # keep in-memory state consistent for later rows
            puts "Linked #{person.sname} (id=#{person.id}) → #{mp.full_name}"
          end
        end
        linked += person_matches.length
        if person_matches.length > 1
          puts "WARNING: linked #{person_matches.length} persons to #{first_name} #{last_name}: #{person_matches.map { |p| "#{p.sname} (id=#{p.id})" }.join(', ')}"
          link_multi += 1
        end
      elsif year >= 2018
        puts "ERROR: no person found for #{first_name} #{last_name}"
      end

      next if dryrun

      # Create or update the log entry (team_id = nil for historical imports).
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

    puts "\nDone. Matched #{matched}, created #{created_people} marathon people, " \
         "#{created_logs} log entries, #{flagged} flagged, #{errors} errors."
    puts "Linked #{linked} persons, #{link_multi} with multiple person matches (not linked)."
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

      if candidates.length >= 1
        person.update_column(:marathon_person_id, candidates.first.id) unless dryrun
        if candidates.length > 1
          puts "Linked #{person.sname} → #{candidates.first.full_name} (multiple matches: #{candidates.map(&:full_name).join(', ')})"
          multi += 1
        else
          puts "Linked #{person.sname} → #{candidates.first.full_name}"
        end
        linked += 1
      else
        no_match += 1
      end
    end

    puts "\nDone. Linked: #{linked}, multiple matches: #{multi}, no match: #{no_match}, skipped (no birthday): #{skipped}."
  end

  desc "List persons in a race organized by organizer_id 8 (default) with team plaque_dist > 0 that are not linked to a marathon_person"
  task unlinked_by_organizer: :environment do |task, args|
    organizer_id = (args.extras.first || 8).to_i

    teams = Team.joins(race: :regatta)
                .where(regattas: { organizer_id: organizer_id })
                .where("races.start_from < ? OR races.start_from IS NULL", Date.new(2026, 1, 1))

    listed = {}  # person_id => person, to dedupe across teams

    teams.find_each do |team|
      begin
        plaque_dist = team.get_logbook(team.logs.order(:time, :id))[:plaque_dist]
      rescue => e
        puts "Skipping team #{team.id}: #{e.message}"
        next
      end
      next unless plaque_dist && plaque_dist > 0

      team.people.where(marathon_person_id: nil).each do |person|
        next if listed.key?(person.id)
        listed[person.id] = person
        puts "#{person.sname} (id=#{person.id}, birthday=#{person.birthday}) — team #{team.id}, plaque_dist=#{plaque_dist.round(1)}"
      end
    end

    puts "\nDone. #{listed.size} unlinked persons with plaque_dist > 0 in races for organizer #{organizer_id}."
  end
end
