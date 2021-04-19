# frozen_string_literal: true

module BorrowersHelper
  # @return [String] The default email suffix (part including and after the `@`)
  #   to use in forms etc.
  def default_email_suffix
    ENV.fetch 'DEFAULT_EMAIL_SUFFIX', '@spotswoodcollege.school.nz'
  end
end
