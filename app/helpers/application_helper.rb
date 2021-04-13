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

  def menu_link_to(name = nil, options = nil, html_options = nil, &block)
    options ||= {}
    html_options ||= {}

    if current_page? options
      classes = "#{html_options['class'] || ''} current-page"
      html_options['class'] = classes.strip
    end

    link_to name, options, html_options, &block
  end
end
