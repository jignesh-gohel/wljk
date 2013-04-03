class CreateMails < ActiveRecord::Migration
  def change
    create_table :mails do |t|
      #http://stackoverflow.com/questions/8501933/specifying-string-fields-length-on-ruby-on-rails
      t.string :content, limit: 2000

      t.timestamps
    end
  end
end
