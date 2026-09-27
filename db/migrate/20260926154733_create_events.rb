class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :billetto_id
      t.string :title
      t.text :description
      t.datetime :start_date
      t.datetime :end_date
      t.string :image_url
      t.string :location
      t.string :url

      t.timestamps
    end
  end
end
