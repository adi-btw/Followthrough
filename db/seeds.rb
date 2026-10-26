# Fictional demo data for local development. Not real patients.
return unless Rails.env.development?

practitioner = User.find_or_initialize_by(email_address: "practitioner@example.com")
if practitioner.new_record?
  practitioner.password = "password"
  practitioner.save!
end

[ "Mira Ellison", "Jonah Hale", "Priya Sen" ].each do |name|
  practitioner.patients.find_by(name: name)&.destroy
end

today = Date.current
window = ((today - 6)..today).to_a

mira = practitioner.patients.create!(name: "Mira Ellison")
mira_plan = mira.care_plans.create!(
  start_date: today - 21,
  recommendations_attributes: [
    { name: "Vitamin D", dose: "2000 IU", times_per_day: 1 },
    { name: "Magnesium glycinate", dose: "200 mg", times_per_day: 1 }
  ]
)
mira_plan.recommendations.each do |recommendation|
  window.each do |date|
    recommendation.check_ins.create!(taken_on: date, taken: true)
  end
end

jonah = practitioner.patients.create!(name: "Jonah Hale")
jonah_plan = jonah.care_plans.create!(
  start_date: today - 21,
  recommendations_attributes: [
    { name: "Omega-3", dose: "1000 mg", times_per_day: 1 }
  ]
)
taken_days = [ today - 6, today - 5 ]
window.each do |date|
  jonah_plan.recommendations.first.check_ins.create!(taken_on: date, taken: taken_days.include?(date))
end

priya = practitioner.patients.create!(name: "Priya Sen")
priya_plan = priya.care_plans.create!(
  start_date: today - 2,
  recommendations_attributes: [
    { name: "Probiotic", dose: "1 capsule", times_per_day: 2 }
  ]
)
(today - 2..today).each do |date|
  priya_plan.recommendations.first.check_ins.create!(taken_on: date, taken: date != today)
end

FollowUpJob.perform_now
