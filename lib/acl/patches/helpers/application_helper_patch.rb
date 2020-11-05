module Acl::Patches::Helpers
  module ApplicationHelperPatch
    def self.included(base)
      base.send :prepend, InstanceMethods
      base.send :include, Acl::Helpers::ExtendHelper
    end

    module InstanceMethods
      def calendar_for(field_id, period = false)
        if Setting.plugin_a_common_libs['enable_periodpicker']
          include_calendar_headers_tags
          javascript_tag("$(function() {
              $('##{field_id}').periodpicker(#{period ? '$.extend(periodpickerOptionsRange, {end:\'#' + period + '\'})' : 'periodpickerOptions'});$('##{field_id}').show().css({'position': 'absolute', 'width': '1px', 'height': '1px', 'margin-left': '20px', 'margin-top': '10px'});
          });")
        else
          super(field_id)
        end
      end
    end
  end
end
