class FollowUpsController < ApplicationController
  def create
    # Run inline so the dashboard badges update on the next render.
    # `bin/rails followthrough:enqueue_follow_ups` enqueues the same job on Solid Queue.
    FollowUpJob.perform_now
    redirect_to root_path, notice: "Follow-up check finished. Plans under 50% adherence are flagged.", status: :see_other
  end
end
