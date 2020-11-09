class AclAjaxCounter < ActiveRecord::Migration[5.0]
  def up
    create_table :acl_ajax_counter, primary_key: ["id"] do |t|
      t.integer :id
      t.string :all_tokens
      t.text :options
    end
  end

  def down
    drop_table :acl_ajax_counter
  end
end