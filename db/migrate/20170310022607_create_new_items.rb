class CreateNewItems < ActiveRecord::Migration[5.0]
  def change
    create_table :new_items do |t|

      t.timestamps
    end
  end
end
