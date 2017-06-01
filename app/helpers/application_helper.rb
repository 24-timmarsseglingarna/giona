module ApplicationHelper

  def bootstrap_class_for flash_type
    { success: "alert-success", error: "alert-error", alert: "alert-warning", notice: "alert-info" }[flash_type.to_sym] || flash_type.to_s
  end

  def flash_messages(opts = {})
    flash.each do |msg_type, message|
      concat(content_tag(:div, message, class: "alert #{bootstrap_class_for(msg_type)} fade in", :role => 'alert') do 
              concat content_tag(:button, 'x', class: "close", data: { dismiss: 'alert' })
              concat message 
            end)
    end
    nil
  end


  def has_admin_rights?
    if current_user
      if current_user.role == 'admin'
        true
      else
        false
      end
    else
      false
    end
  end


  def has_organizer_rights?
    if current_user
      if current_user.role == 'organizer' || current_user.role == 'admin'
        true
      else
        false
      end
    else
      false
    end
  end

  def has_assistant_rights?
    if current_user
      if current_user.role == 'assistant' || current_user.role == 'organizer' || current_user.role == 'admin'
        true
      else
        false
      end
    else
      false
    end
  end


end
