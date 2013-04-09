class AddSubjectToMails < ActiveRecord::Migration
  def change
    add_column :mails, :subject, :string
  end
end
