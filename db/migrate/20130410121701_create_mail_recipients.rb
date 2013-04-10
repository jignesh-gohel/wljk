class CreateMailRecipients < ActiveRecord::Migration
  def change
    create_table :mail_recipients do |t|
      t.integer :mail_template_id
      t.integer :recipient_id

      t.timestamps
    end
  end
end
