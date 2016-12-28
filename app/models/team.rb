class Team < ApplicationRecord
  belongs_to :race, dependent: :destroy

  after_initialize :set_defaults, unless: :persisted?
  # The set_defaults will only work if the object is new

  def set_defaults
    self.did_not_start  ||= false
    self.did_not_finish  ||= false
    self.paid_fee  ||= false
    self.name ||= "#{self.boat_name} / #{boat_class_name}"
  end
end
