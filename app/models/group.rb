# frozen_string_literal: true

class Group < ApplicationRecord
  # @!attribute children
  #   @return [Array<Group>]
  has_many :children, class_name: 'Group',
                      foreign_key: 'parent_id',
                      inverse_of: :parent,
                      dependent: :destroy

  # @!attribute parent
  #   @return [Group]
  belongs_to :parent, class_name: 'Group', optional: true

  # @!attribute devices
  #   @return [Array<Device>]
  has_many :devices, dependent: :nullify

  # @return [true, false]
  def root?
    parent.blank?
  end

  # @return [String] the URL-safe {#code} of this Group.
  def to_param
    code
  end
end
