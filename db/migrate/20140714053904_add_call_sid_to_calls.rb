class AddCallSidToCalls < ActiveRecord::Migration
  def change
    add_column :calls, :call_sid, :string
  end
end
