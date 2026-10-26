class AddCheckInTokensAndDoseSlots < ActiveRecord::Migration[8.1]
  def up
    add_column :care_plans, :check_in_token, :string
    backfill_check_in_tokens
    change_column_null :care_plans, :check_in_token, false
    add_index :care_plans, :check_in_token, unique: true

    add_column :check_ins, :slot, :string, null: false, default: "morning"
    remove_index :check_ins, name: "index_check_ins_on_recommendation_id_and_taken_on"
    add_index :check_ins, [ :recommendation_id, :taken_on, :slot ],
      unique: true,
      name: "index_check_ins_on_recommendation_date_and_slot"
  end

  def down
    remove_index :check_ins, name: "index_check_ins_on_recommendation_date_and_slot"
    add_index :check_ins, [ :recommendation_id, :taken_on ],
      unique: true,
      name: "index_check_ins_on_recommendation_id_and_taken_on"
    remove_column :check_ins, :slot

    remove_index :care_plans, :check_in_token
    remove_column :care_plans, :check_in_token
  end

  private
    def backfill_check_in_tokens
      connection.select_values("SELECT id FROM care_plans").each do |id|
        token = SecureRandom.base58(24)
        execute "UPDATE care_plans SET check_in_token = #{connection.quote(token)} WHERE id = #{id.to_i}"
      end
    end
end
