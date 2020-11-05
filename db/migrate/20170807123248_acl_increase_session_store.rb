class AclIncreaseSessionStore < ActiveRecord::Migration
  def up
    change_column :sessions, :data, :text, limit: 16777214
  end
end