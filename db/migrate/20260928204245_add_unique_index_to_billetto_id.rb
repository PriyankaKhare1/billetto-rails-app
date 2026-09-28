class AddUniqueIndexToBillettoId < ActiveRecord::Migration[7.1]
  def change
    add_index :events, :billetto_id, unique: true
  end
end
