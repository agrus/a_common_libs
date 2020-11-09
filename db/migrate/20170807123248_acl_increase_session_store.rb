class AclIncreaseSessionStore < ActiveRecord::Migration[5.0]
  def up
    change_column :sessions, :data, :text, limit: 16777214
  end
end