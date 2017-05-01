module HandicapsHelper

  def handicap_table(type)
    handicap_array  = {}
    handicap_array['Välj'] = nil 
    for handicap in Handicap.where(type: type).active
      handicap_array[handicap.description] = handicap.id 
    end
    handicap_array 
  end

  # Returns a dynamic path based on the provided parameters
  def sti_handicap_path(type = "handicap", handicap = nil, action = nil)
    send "#{format_sti(action, type, handicap)}_path", handicap
  end

  def format_sti(action, type, handicap)
    action || handicap ? "#{format_action(action)}#{type.underscore}" : "#{type.underscore.pluralize}"
  end

  def format_action(action)
    action ? "#{action}_" : ""
  end



end