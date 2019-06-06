module TeamsHelper
  def team_in_regatta team
        out = team.name
        unless team.race.nil?
          out += ': ' + team.race.period.to_s + ' timmar'
          unless team.race.regatta.nil?
                out += ', ' + team.race.regatta.name
          end
         end
   end

   def i_may_see_links_to team
     if team.present?
       if !team.archived?
         if current_user
           if has_assistant_rights?
             true # is some kind of admin
           else
             if current_user.person.present?
               if team.people.present?
                 if team.people.include? current_user.person
                   true # is crew member
                 else
                   false
                 end
               else
                 false
               end
             else
               false
             end
           end
         else # current_user
           true # is not logged in (but shall see the link)
         end
       else # archived?
         false
       end
     else # team.present?
       false
     end
   end

   def panel_context status
     if status.blank?
       "panel-success"
     else
       "panel-danger"
     end
   end

   def find_leg(previous_point_number, point_number, terrain)
     previous_point = terrain.points.find_by number: previous_point_number
     point = terrain.points.find_by number: point_number
     terrain.legs.find_by point: previous_point, to_point: point
   end

   def get_leg_name(a, b)
     if a < b
       "#{a}-#{b}"
     else
       "#{b}-#{a}"
     end
   end

   def can_register_logbook(team)
     team.state == 'submitted' || team.state == 'approved'
   end

   def logbook_link(team)
     Rails.configuration.web_logbook_url +
       "?logbook=true" +
       "&url=#{URI.escape(request.protocol + request.host_with_port)}" +
       "&email=#{URI.escape(current_user.email)}" +
       "&token=#{URI.escape(current_user.authentication_token)}" +
       "&team=#{team.id}" +
       "&race=#{team.race_id}" +
       "&person=#{current_user.person.id}"
   end

   def get_logbook(team, logs)
     terrain = team.race.regatta.terrain
     prev = nil
     npoints = {}
     nlegs = {}
     entries = []
     cur_compensation_time = 0
     cur_compensation_dist_time = 0
     admin_time = 0
     admin_dist = 0
     compensation_time = 0
     compensation_dist_time = 0
     start_time = 0
     finish_time = 0
     signed = false
     state = nil
     sailed_dist = 0
     sailed_time = 0
     i = 0
     while i < logs.length do
       log = logs[i]
       unless log.deleted
         dist = nil
         leg_status = nil
         interrupt_status = nil
         prev_point = nil
         unless log.data.blank?
           log_data = JSON.parse(log.data)
         else
           log_data = Hash.new
         end
         if log.point
           # start or round
           unless npoints[log.point]
             npoints[log.point] = 0
           end
           if prev
             prev_point = prev.point
             unless log_data['finish'].blank?
               finish_time = log.time.to_i
             else
               # count this point (it is not start since it has prev_point)
               # NOTE: we count this point even if the leg is invalid.
               # unclear if this is correct or not.
               npoints[log.point] = npoints[log.point] + 1
             end
             leg = find_leg(prev.point, log.point, terrain)
             if leg && npoints[log.point] < 3
               # count this leg
               leg_name = get_leg_name(prev.point, log.point)
               if nlegs[leg_name]
                 nlegs[leg_name] = nlegs[leg_name] + 1
               else
                 nlegs[leg_name] = 1
               end
               if nlegs[leg_name] < 3
                 if leg.distance == 0 && leg.addtime
                   # zero-distance leg with time compensation;
                   # add the time to offset, and ignore compensation in
                   # ongoing interrupts
                   compensation_time += ((log.time.to_i - prev.time.to_i) / 60)
                 else
                   dist = leg.distance
                   sailed_dist += leg.distance
                   compensation_time += cur_compensation_time
                   compensation_dist_time += cur_compensation_dist_time
                 end
               else
                 leg_status = :too_many_legs
               end
             elsif leg.nil?
               leg_status = :no_leg
             else
               leg_status = :too_many_rounds
             end
             # reset compensation counters
             cur_compensation_time = 0
             cur_compensation_dist_time = 0
           else
             start_time = log.time.to_i
           end
           unless prev.nil?
             sailed_time += (log.time.to_i - prev.time.to_i) / 60
           end
           prev = log
         elsif log_data['interrupt'] && log_data['interrupt']['type'] != 'done'
           # Find the corresponding log entry for interrupt done
           j = i+1
           found = false
           while !found && j < logs.length do
             f = logs[j]
             unless f.deleted
               if f.log_type == 'interrupt'
                 unless f.data.blank?
                   f_log_data = JSON.parse(f.data)
                 else
                   f_log_data = Hash.new
                 end
                 if f_log_data['interrupt'] &&
                    f_log_data['interrupt']['type'] == 'done'
                   interrupt_time = (f.time.to_i - log.time.to_i) / 60
                   if log_data['interrupt']['type'] == 'rescue-time'
                     cur_compensation_time += interrupt_time
                   elsif log_data['interrupt']['type'] == 'rescue-dist'
                     cur_compensation_dist_time += interrupt_time
                   end
                   # no compensation for other interrupts
                   found = true
                 end
               elsif f.log_type == 'round'
                 # A rounding log entry before starting to sail again - error
                 interrupt_status = :no_done
                 found = true
               elsif f.log_type == 'interrupt'
                 # A new interrupt "replaced" this one
                 found = true
               end
             end
             j += 1
           end
         elsif log.log_type == 'sign'
           signed = true
         elsif log.log_type == 'retire'
           state = :retire
         elsif log.log_type == 'adminDSQ'
           state = :dsq
         elsif log.log_type == 'adminDist'
           admin_dist += log_data['admin_dist']
         elsif log.log_type == 'adminTime'
           admin_time += log_data['admin_time']
         end
         entries.append({:log => log,
                         :log_data => log_data,
                         :distance => dist,
                         :leg_status => leg_status,
                         :prev_point => prev_point,
                         :interrupt_status => interrupt_status})
       end
       i += 1
     end

     early_start_time = 0
     # all start_* vars are in seconds (since Unix epoch)
     if start_time > 0
       start_from = team.race.start_from.to_i
       start_to = team.race.start_to.to_i
       if start_time > start_to
         # late start, use "start-to" as starttime (RR 6.3)
         start_time = start_to
       elsif start_time < start_from
         # too early start; add penalty, use "start-from" as starttime
         early_start_time = (start_from - start_time) / 60
         start_time = start_from;
       end
     end

     late_finish_time = 0
     if finish_time > 0
       extra_time = compensation_time + admin_time
       race_length = (team.race.period * 60 + extra_time) * 60
       # FIXME: verify that it is correct to not add extra time here
       race_min_length = (team.race.minimal.to_i * 60) * 60
       real_finish_time = start_time + race_length
       min_finish_time = start_time + race_min_length
       if finish_time > real_finish_time
         # too late finish
         late_finish_time = (finish_time - real_finish_time) / 60
       elsif finish_time < min_finish_time
         # too short race, does not count
         state = :early_finish
       end
     end

     # we can't calculate early_start_dist properly until the race has finished
     early_start_dist = 0
     if finish_time > 0
       early_start_dist = (2 * sailed_dist * early_start_time) /
                          (team.race.period * 60)
     end

     late_finish_dist = 0
     if late_finish_time > 0
       late_finish_dist = (2 * sailed_dist * late_finish_time) /
                          (team.race.period * 60)
     end

     average_speed = 0
     # use sailed time - time for interrupts that gets compensated
     time = sailed_time - compensation_time
     if time > 0
       average_speed = sailed_dist * 60 / time
     end

     # we can't calculate compensation_dist properly until the race has finished
     compensation_dist = 0
     if finish_time > 0
       compensation_dist = (average_speed * compensation_dist_time) / 60;
     end

     approved_dist = 0
     plaque_dist = 0
     if signed and state.nil?
       approved_dist = sailed_dist + compensation_dist -
                       (early_start_dist + late_finish_dist)
       plaque_dist = (approved_dist / team.sxk) - admin_dist
     end

     { :state => state,
       :signed => signed,
       :entries => entries,
       :sailed_dist => sailed_dist,
       :early_start_dist => early_start_dist,
       :early_start_time => early_start_time,
       :late_finish_dist => late_finish_dist,
       :late_finish_time => late_finish_time,
       :compensation_dist => compensation_dist,
       :admin_dist => admin_dist,
       :approved_dist => approved_dist,
       :plaque_dist => plaque_dist
     }
   end

end
