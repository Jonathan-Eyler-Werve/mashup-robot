class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.string :message
      t.string :string

      t.timestamps null: false
    end
  end
end
