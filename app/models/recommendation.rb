class Recommendation < ApplicationRecord
  belongs_to :care_plan
  has_many :check_ins, dependent: :destroy

  validates :name, :dose, presence: true
  validates :times_per_day, inclusion: { in: [ 1, 2 ], message: "must be 1 or 2" }
end
