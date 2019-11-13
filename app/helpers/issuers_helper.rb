# frozen_string_literal: true

module IssuersHelper
  # @return [String] The default email suffix (part including and after the `@`)
  #   to use in forms etc.
  def default_email_suffix
    ENV['DEFAULT_EMAIL_SUFFIX'] || '@spotswoodcollege.school.nz'
  end
end
