class AddAjaxableToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :ajaxable, :boolean, default: false
  end
end