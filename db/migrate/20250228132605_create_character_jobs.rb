class CreateCharacterJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :character_jobs do |t|
      t.date :start_date
      t.date :end_date
      t.references :character, null: false, foreign_key: true
      t.references :job, null: false, foreign_key: true

      t.timestamps
    end
  end
end
