class AddAppUrlToLaunches < ActiveRecord::Migration[8.1]
  def change
    add_column :launches, :app_url, :string
  end
end
