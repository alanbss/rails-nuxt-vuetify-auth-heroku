class CreatePrivateContents < ActiveRecord::Migration[7.0]
  def change
    create_table :private_contents do |t|
      t.string :name

      t.timestamps
    end
  end
end
