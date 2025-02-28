class CreateSpecies < ActiveRecord::Migration[8.0]
  def change
    create_table :species do |t|
      t.string :species_name

      t.timestamps
    end
  end
end
