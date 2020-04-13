# frozen_string_literal: true

module UploadHelper
  # rubocop:disable Rails/HelperInstanceVariable

  class UploadException < ActiveRecord::ActiveRecordError
    attr_reader :row

    def initialize(row = nil, message = nil)
      @row = row
      super(message)
    end

    # @return [String] a formatted string representing the error and its
    # position in the offending file
    def render
      "Error on row #{row}: #{message}"
    end
  end

  # rubocop:enable Rails/HelperInstanceVariable
end
