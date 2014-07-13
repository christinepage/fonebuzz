class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.string :tel_num
      t.datetime :call_dt
      t.integer :delay

      t.timestamps
    end
  end
end
