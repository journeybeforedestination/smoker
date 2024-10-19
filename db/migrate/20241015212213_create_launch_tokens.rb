class CreateLaunchTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :launch_tokens do |t|
      t.references :launch, null: false, foreign_key: true
      t.text :access_token, null: false
      t.datetime :experation, null: false
      t.string :scope, null: false
      t.text :id_token
      t.text :refresh_token

      t.timestamps
    end
  end
end
