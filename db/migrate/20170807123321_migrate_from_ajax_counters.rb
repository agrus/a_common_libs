class MigrateFromAjaxCounters < ActiveRecord::Migration
  def up
    if ActiveRecord::Base.connection.table_exists?('cm_items')
      ActiveRecord::Base.connection.execute("UPDATE cm_items SET code = 'custom_menu_acl_update_counters' WHERE code = 'custom_menu_ac_update_counters'")
    end
  end
end