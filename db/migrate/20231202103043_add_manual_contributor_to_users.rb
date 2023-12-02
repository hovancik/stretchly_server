class AddManualContributorToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :manual_contributor, :boolean, default: false, null: false
  end
end
