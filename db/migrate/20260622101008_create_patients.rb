class CreatePatients < ActiveRecord::Migration[8.1]
  enable_extension "pgcrypto" unless extension_enabled?("pgcrypto")
  
  def change
    create_table :patients, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :email, limit: 510
      t.string :name, limit: 510
      t.string :phone_no, limit: 510
      t.string :dob, limit: 510
      t.string :gender, limit: 510
      t.string :address, limit: 1020

      t.timestamps
    end
  end
end
