class Recommendation < ApplicationRecord
  belongs_to :care_plan
  has_many :check_ins, dependent: :destroy

  validates :name, :dose, presence: true
  validates :times_per_day, inclusion: { in: [ 1, 2 ], message: "must be 1 or 2" }

  def slots
    times_per_day.to_i == 2 ? [ "morning", "evening" ] : [ "morning" ]
  end

  def dose_taken_on?(date, slot)
    check_ins.any? do |check_in|
      check_in.taken && check_in.slot == slot && check_in.taken_on == date
    end
  end

  def record_dose!(slot:, taken:, on: Date.current)
    slot = slot.to_s
    return false unless slots.include?(slot)

    check_ins.find_or_initialize_by(taken_on: on, slot: slot).tap do |check_in|
      check_in.taken = taken
      check_in.save!
    end
  end
end
