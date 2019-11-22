# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def notice_callout
    text = notice
    return '' unless text

    render 'general/callout', type: 'primary' do
      text
    end
  end

  def alert_callout
    text = alert
    return '' unless text

    render 'general/callout', type: 'alert' do
      text
    end
  end
end
