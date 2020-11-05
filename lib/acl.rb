module Acl
end

require 'acl/rails/action_view'
require 'rmp_sql_ext'

require_dependency 'acl/session_store_bypass'
require_dependency 'redmine/field_format'
require_dependency 'acl/redmine/field_format'
require_dependency 'acl/helpers/extend_helper'
require_dependency 'acl/patches'
require_dependency 'acl/url_helpers_patch'
require_dependency 'acl/issues_pdf_helper_patch'
require_dependency 'acl/utils/macros/base_macros'
require_dependency 'acl/utils/macros/issue_macros'

begin
  Acl::Utils::CssBtnIconsUtil.generate_css_file
rescue Exception => ex
  Rails.logger.info "WARNING: Cannot generate custom css for button icons #{ex.message}" if Rails.logger
end