class AddKeyedNumToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :keyed_num, :integer
  end
end
