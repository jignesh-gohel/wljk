class CreateMailSchedules < ActiveRecord::Migration
  def change
    create_table :mail_schedules do |t|
      t.datetime :datetime
      t.boolean :recurring
      t.integer :recurring_interval
      t.string :recurring_interval_type
      t.integer :mail_template_id

      t.timestamps
    end
  end
end
