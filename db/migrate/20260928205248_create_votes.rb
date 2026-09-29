class CreateVotes < ActiveRecord::Migration[7.1]
  def change
    create_table :votes do |t|
      t.string :user_id,  null: false
      t.integer :event_id,  null: false
      t.string :vote_type,  null: false

      t.timestamps
    end

    add_index :votes, [:user_id, :event_id], unique: true
  end
end

