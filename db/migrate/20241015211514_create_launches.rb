class CreateLaunches < ActiveRecord::Migration[8.0]
  def change
    create_table :launches do |t|
      t.string :iss, null: false
      t.string :launch, null: false
      t.string :authorization_endpoint, null: false
      t.string :token_endpoint, null: false
      t.string :state, null: false

      t.timestamps
    end
  end
end
