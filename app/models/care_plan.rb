class CarePlan < ApplicationRecord
  belongs_to :patient
  has_many :recommendations, dependent: :destroy

  accepts_nested_attributes_for :recommendations, allow_destroy: true, reject_if: :blank_recommendation?

  validates :start_date, presence: true
  validate :at_least_one_recommendation

  scope :active, ->(on: Date.current) { where(start_date: ..on) }

  def adherence(as_of: Date.current)
    Adherence.for(self, as_of: as_of)
  end

  private
    def blank_recommendation?(attributes)
      attributes = attributes.to_h.with_indifferent_access
      attributes[:id].blank? && attributes[:name].blank? && attributes[:dose].blank?
    end

    def at_least_one_recommendation
      kept = recommendations.reject(&:marked_for_destruction?)
      errors.add(:base, "Add at least one supplement") if kept.empty?
    end
end
