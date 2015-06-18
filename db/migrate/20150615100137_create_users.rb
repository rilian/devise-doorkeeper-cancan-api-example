class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.boolean :is_admin, default: false
      t.timestamps null: false
    end
  end
end
