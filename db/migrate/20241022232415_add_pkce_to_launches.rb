class AddPkceToLaunches < ActiveRecord::Migration[8.1]
  def change
    add_column :launches, :pkce, :string
  end
end
