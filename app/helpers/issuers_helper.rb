# frozen_string_literal: true

module IssuersHelper
  def default_email_suffix
    ENV['DEFAULT_EMAIL_SUFFIX'] || '@spotswoodcollege.school.nz'
  end
end
