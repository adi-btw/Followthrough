class CheckIn < ApplicationRecord
  belongs_to :recommendation

  validates :taken_on, presence: true, uniqueness: { scope: :recommendation_id }
  validates :taken, inclusion: { in: [ true, false ] }
end
