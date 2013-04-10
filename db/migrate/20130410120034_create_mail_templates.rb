class CreateMailTemplates < ActiveRecord::Migration
  def change
    create_table :mail_templates do |t|
      #http://stackoverflow.com/questions/8501933/specifying-string-fields-length-on-ruby-on-rails
      t.string :content, limit: 2000
      t.string :subject
      t.integer :user_id

      t.timestamps
    end
  end
end
