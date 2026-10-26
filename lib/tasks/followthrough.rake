namespace :followthrough do
  desc "Enqueue FollowUpJob on Solid Queue to flag plans under 50% adherence"
  task enqueue_follow_ups: :environment do
    FollowUpJob.perform_later
    puts "Enqueued FollowUpJob"
  end
end
