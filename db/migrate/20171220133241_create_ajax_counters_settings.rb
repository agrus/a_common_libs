class CreateAjaxCountersSettings < ActiveRecord::Migration
  def change
    create_table :acl_ajax_counters do |t|
      t.string :token
      t.text :options
    end
  end
end