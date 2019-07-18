# frozen_string_literal: true

module ApplicationHelper
  def notice_p
    n = notice
    return '' unless n

    "<p class='notice'>#{n}</p>"
  end

  def alert_p
    a = alert
    return '' unless a

    "<p class='alert'>#{a}</p>"
  end
end
