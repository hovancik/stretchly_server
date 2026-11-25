class AddStretchlyVersionToSettings < ActiveRecord::Migration[8.1]
  def change
    add_column :settings, :stretchly_version, :string
  end
end
