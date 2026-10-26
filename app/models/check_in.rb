class CheckIn < ApplicationRecord
  SLOTS = [ "morning", "evening" ].freeze

  belongs_to :recommendation

  validates :slot, inclusion: { in: SLOTS }
  validates :taken_on, presence: true, uniqueness: { scope: [ :recommendation_id, :slot ] }
  validates :taken, inclusion: { in: [ true, false ] }
  validate :slot_is_scheduled

  private
    def slot_is_scheduled
      return if slot.blank? || recommendation.nil?
      return if recommendation.slots.include?(slot)

      errors.add(:slot, "is not scheduled for this supplement")
    end
end
