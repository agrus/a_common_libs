module Acl::Patches::Helpers
  module CustomFieldsHelperPatch
    def self.included(base)
      base.send :prepend, InstanceMethods

    end

    module InstanceMethods
      def alias_method_chain(custom_value, html=true)
        return super(custom_value, html) unless html

        trimmed = false
        before_trim_size = 0
        original_values = nil
        if custom_value.is_a?(CustomFieldValue) &&
            custom_value.custom_field.present? &&
            custom_value.custom_field.format.present? &&
            custom_value.custom_field.format.multiple_supported &&
            custom_value.custom_field.multiple &&
            custom_value.custom_field.acl_trim_multiple &&
            (original_values = custom_value.value.clone).present? &&
            custom_value.value.is_a?(Array) &&
            (before_trim_size = custom_value.value.size) > 3

          trimmed = true
          custom_value.value = custom_value.value[0..2]
        end

        res = super(custom_value, html)

        if trimmed
          custom_value.value = original_values if original_values
          res << '&nbsp;&nbsp;'.html_safe
          res << link_to("<span>#{l(:label_acl_custom_field_all_trimmed, count: before_trim_size)}</span>".html_safe, { controller: :issues, action: :acl_cf_trimmed_all, id: custom_value.customized.id, cf_id: custom_value.custom_field.id }, class: 'in_link link_to_modal click_out', id: "lb-cf-other-trimmed-#{custom_value.custom_field.id}")
        end

        res
      end
    end
  end
end