class CreateScheduleOccurrences < ActiveRecord::Migration
  def change
    create_table :schedule_occurrences do |t|
      t.datetime :next_occurrence
      t.integer :scheduled_entity_id
      t.string :occurrence_status

      t.timestamps
    end
  end
end
