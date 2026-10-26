class Patient < ApplicationRecord
  belongs_to :user
  has_many :care_plans, dependent: :destroy

  validates :name, presence: true
end
