module Acl::Patches::Helpers
  module QueriesHelperPatch
    def self.included(base)
      base.send :prepend, InstanceMethods
    end

    module InstanceMethods
      def column_content(column, issue)
        res = super(column, issue)
        if column.is_a?(QueryCustomFieldColumn) && (value = column.value_object(issue)).is_a?(CustomFieldValue) && value.acl_trimmed_size.to_i > 3
          res << '&nbsp;&nbsp;'.html_safe
          res << link_to("<span>#{l(:label_acl_custom_field_all_trimmed, count: value.acl_trimmed_size.to_i)}</span>".html_safe, { controller: :issues, action: :acl_cf_trimmed_all, id: issue.id, cf_id: value.custom_field.id }, class: 'in_link link_to_modal click_out', id: "lb-cf-other-trimmed-#{value.custom_field.id}")
        end
        res
      end
    end
  end
end