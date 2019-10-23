# frozen_string_literal: true

module ApplicationHelper
  def notice_p
    text = notice
    return '' unless text

    "<p class='notice'>#{text}</p>"
  end

  def alert_p
    text = alert
    return '' unless text

    "<p class='alert'>#{text}</p>"
  end
end
