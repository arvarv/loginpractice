class AddAgeNameFieldInUsers < ActiveRecord::Migration
  def up
  	add_column :users, :name, :string
  	add_column :users, :age, :integer
  end

  def down
  	remove_column :users, :name
  	remove_column :users, :age
  end
end
