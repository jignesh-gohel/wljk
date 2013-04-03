class CreateMailRecipients < ActiveRecord::Migration
  def change
    create_table :mail_recipients do |t|
      t.integer :recipient_id
      t.integer :mail_id

      t.timestamps
    end
  end
end
