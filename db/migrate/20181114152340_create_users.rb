class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :auth_token, null: false
      t.boolean :contributor, null: false, default: false

      t.timestamps
    end
    add_index :users, :provider
    add_index :users, :uid
    add_index :users, :auth_token
    add_index :users, [:provider, :uid], unique: true
  end
end
