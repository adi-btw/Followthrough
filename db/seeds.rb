# Fictional demo data. Not real patients.
# Log in as practitioner@example.com / password
return unless Rails.env.development?

practitioner = User.find_or_initialize_by(email_address: "practitioner@example.com")
practitioner.password = "password"
practitioner.save!
practitioner.patients.destroy_all

today = Date.current
window = (today - 6)..today

mira = practitioner.patients.create!(name: "Mira Ellison (fictional)")
mira_plan = mira.care_plans.create!(
  start_date: today - 21,
  recommendations_attributes: [
    { name: "Vitamin D", dose: "2000 IU", times_per_day: 1 },
    { name: "Magnesium glycinate", dose: "200 mg", times_per_day: 1 }
  ]
)
mira_plan.recommendations.each do |recommendation|
  window.each do |date|
    recommendation.check_ins.create!(taken_on: date, slot: "morning", taken: true)
  end
end

jonah = practitioner.patients.create!(name: "Jonah Hale (fictional)")
jonah_plan = jonah.care_plans.create!(
  start_date: today - 21,
  recommendations_attributes: [
    { name: "Omega-3", dose: "1000 mg", times_per_day: 1 }
  ]
)
window.each_with_index do |date, index|
  jonah_plan.recommendations.first.check_ins.create!(taken_on: date, slot: "morning", taken: index < 2)
end

priya = practitioner.patients.create!(name: "Priya Sen (fictional)")
priya_plan = priya.care_plans.create!(
  start_date: today - 2,
  recommendations_attributes: [
    { name: "Probiotic", dose: "1 capsule", times_per_day: 2 }
  ]
)
probiotic = priya_plan.recommendations.first
((today - 2)...today).each do |date|
  probiotic.check_ins.create!(taken_on: date, slot: "morning", taken: true)
  probiotic.check_ins.create!(taken_on: date, slot: "evening", taken: false)
end

FollowUpJob.perform_now

puts "Demo practitioner: practitioner@example.com / password"
puts "Mira check-in: /check-in/#{mira_plan.check_in_token}"
puts "Jonah check-in: /check-in/#{jonah_plan.check_in_token}"
puts "Priya check-in: /check-in/#{priya_plan.check_in_token}"
