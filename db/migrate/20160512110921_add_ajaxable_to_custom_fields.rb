class AddAjaxableToCustomFields < ActiveRecord::Migration[5.0]
  def change
    add_column :custom_fields, :ajaxable, :boolean, default: false
  end
end