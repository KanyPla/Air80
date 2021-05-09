class CreateFlights < ActiveRecord::Migration[5.2]
  def change
    create_table :flights do |t|
    	t.string :user
	t.string :aircraft
	t.datetime :start
	t.datetime :finish
	t.string :legs
    end
  end
end
