class FollowUpJob < ApplicationJob
  queue_as :default

  def perform(as_of = Date.current)
    as_of = as_of.to_date
    CarePlan.active(on: as_of).includes(recommendations: :check_ins).each do |care_plan|
      care_plan.update!(needs_follow_up: Adherence.for(care_plan, as_of: as_of).needs_follow_up?)
    end
  end
end
