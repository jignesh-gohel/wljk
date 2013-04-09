class AddUserIdToMails < ActiveRecord::Migration
  def change
    add_column :mails, :user_id, :integer
  end
end
