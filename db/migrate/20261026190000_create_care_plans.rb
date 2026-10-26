class CreateCarePlans < ActiveRecord::Migration[8.1]
  def change
    create_table :patients do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false

      t.timestamps
    end

    create_table :care_plans do |t|
      t.references :patient, null: false, foreign_key: true
      t.date :start_date, null: false
      t.boolean :needs_follow_up, null: false, default: false

      t.timestamps
    end

    create_table :recommendations do |t|
      t.references :care_plan, null: false, foreign_key: true
      t.string :name, null: false
      t.string :dose, null: false
      t.integer :times_per_day, null: false

      t.timestamps
    end

    create_table :check_ins do |t|
      t.references :recommendation, null: false, foreign_key: true
      t.date :taken_on, null: false
      t.boolean :taken, null: false, default: false

      t.timestamps
    end

    add_index :check_ins, [ :recommendation_id, :taken_on ], unique: true
  end
end
