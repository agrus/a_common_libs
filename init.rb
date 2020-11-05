require 'acl/hooks/view_hooks'
require 'query'

Redmine::Plugin.register :a_common_libs do
  name 'A common libraries'
  author 'Danil Kukhlevskiy'
  description 'This is a plugin for including common libraries'
  version '2.4.6'
  url 'http://rmplus.pro/'
  author_url 'http://rmplus.pro/'

  settings partial: 'settings/a_common_libs',
           default: { autoconfig_libs: true },
           auto: {}

  menu :custom_menu, :us_favourite_proj_name, nil, caption: Proc.new{ ('<div class="title">' + User.current.favourite_project.name + '</div>').html_safe }, if: Proc.new { User.current.logged? && User.current.favourite_project.is_a?(Project) }
  menu :custom_menu, :us_favourite_proj_link, nil, caption: Proc.new{ ('<a href="' + Redmine::Utils.relative_url_root + '/projects/'+User.current.favourite_project.identifier+'" class="no_line"><span>' + User.current.favourite_project.name + '</span></a>').html_safe }, if: Proc.new { User.current.logged? && User.current.favourite_project.is_a?(Project) }
  menu :custom_menu, :us_favourite_proj_issues, nil, caption: Proc.new{ ('<a href="' + Redmine::Utils.relative_url_root + '/projects/'+User.current.favourite_project.identifier+'/issues" class="no_line"><span>' + I18n.t(:label_issue_plural) + '</span></a>').html_safe }, if: Proc.new { User.current.logged? && User.current.favourite_project.is_a?(Project) }
  menu :custom_menu, :us_favourite_proj_new_issue, nil, caption: Proc.new{ ('<a href="' + Redmine::Utils.relative_url_root + '/projects/'+User.current.favourite_project.identifier+'/issues/new" class="no_line"><span>' + I18n.t(:label_issue_new) + '</span></a>').html_safe}, if: Proc.new { User.current.logged? && User.current.favourite_project.is_a?(Project) }
  menu :custom_menu, :us_favourite_proj_wiki, nil, caption: Proc.new{ ('<a href="' + Redmine::Utils.relative_url_root + '/projects/'+User.current.favourite_project.identifier+'/wiki" class="no_line"><span>' + I18n.t(:label_wiki) + '</span></a>').html_safe }, if: Proc.new { User.current.logged? && User.current.favourite_project.is_a?(Project) && User.current.favourite_project.module_enabled?(:wiki) }
  menu :custom_menu, :us_favourite_proj_dmsf, nil, caption: Proc.new{ ('<a href="' + Redmine::Utils.relative_url_root + '/projects/'+User.current.favourite_project.identifier+'/dmsf" class="no_line"><span>' + I18n.t(:label_dmsf) + '</span></a>').html_safe }, if: Proc.new { User.current.logged? && User.current.favourite_project.is_a?(Project) && User.current.favourite_project.module_enabled?(:dmsf) && Redmine::Plugin.installed?(:redmine_dmsf) }
  menu :custom_menu, :us_new_issue, nil, caption: Proc.new{ ('<a href="' + Redmine::Utils.relative_url_root + '/projects/'+User.current.favourite_project.identifier+'/issues/new" class="no_line"><span>' + I18n.t(:us_of_issue) + '</span></a>').html_safe }, if: Proc.new { User.current.logged? && User.current.favourite_project.is_a?(Project) }
  menu :custom_menu, :api_log_for_plugins, {controller: 'api_log_for_plugins', action: 'index'}, caption: Proc.new{ ApiLogForPlugin.build_link_unread_log }, if: Proc.new { User.current.logged? && User.current.try(:admin) }, html: {class: 'no_line'}
  menu :custom_menu, :acl_update_counters, '#', caption: Proc.new { ('<span>'+I18n.t(:label_acl_refresh_ajax_counters)+'</span>').html_safe }, if: Proc.new { User.current.logged? }, html: {class: 'in_link ac_refresh', id: 'refresh_ajax_counters'}


  requires_redmine '3.4.1'

  p = Redmine::AccessControl.permission(:view_issues)
  if p && p.project_module == :issue_tracking
    p.actions << 'issues/acl_edit_form'
  end
end

ActiveRecord::Base.send :prepend, Acl::ActsAsCustomizablePatch

Rails.application.config.to_prepare do
  require_dependency 'acl'
end

Rails.application.config.after_initialize do
  Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['autoconfig_libs'] = true

  # Select2
  if Redmine::Plugin.installed?(:luxury_buttons) ||
     Redmine::Plugin.installed?(:kpi) ||
     Redmine::Plugin.installed?(:ldap_users_sync) ||
     Redmine::Plugin.installed?(:magic_my_page) ||
     Redmine::Plugin.installed?(:clear_plan) ||
     Redmine::Plugin.installed?(:goals) ||
     Redmine::Plugin.installed?(:extra_queries) ||
     Redmine::Plugin.installed?(:usability) ||
     Redmine::Plugin.installed?(:under_construction) ||
     Redmine::Plugin.installed?(:rmplus_devtools) ||
     Redmine::Plugin.installed?(:service_desk) ||
     Redmine::Plugin.installed?(:training) ||
     Redmine::Plugin.installed?(:shipping) ||
     Redmine::Plugin.installed?(:custom_menu) ||
     Redmine::Plugin.installed?(:rmplus_tags) ||
     Redmine::Plugin.installed?(:rm_custom_pdf)

    Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_select2_lib'] = true
  end

  # Highcharts
  if Redmine::Plugin.installed?(:kpi) ||
     Redmine::Plugin.installed?(:clear_plan) ||
     Redmine::Plugin.installed?(:service_desk)

    Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_jqplot_lib'] = true
  end

  # Twitter Bootstrap
  if Redmine::Plugin.installed?(:kpi) ||
     Redmine::Plugin.installed?(:ldap_users_sync) ||
     Redmine::Plugin.installed?(:magic_my_page) ||
     Redmine::Plugin.installed?(:clear_plan) ||
     Redmine::Plugin.installed?(:goals) ||
     Redmine::Plugin.installed?(:rm_user_mentions) ||
     Redmine::Plugin.installed?(:extra_queries) ||
     Redmine::Plugin.installed?(:usability) ||
     Redmine::Plugin.installed?(:under_construction) ||
     Redmine::Plugin.installed?(:rmplus_devtools) ||
     Redmine::Plugin.installed?(:service_desk)

    Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_bootstrap_lib'] = true
  end

  # Twitter Bootstrap for Luxury Buttons
  if Redmine::Plugin.installed?(:luxury_buttons)
    unless Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_bootstrap_lib']
      Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_bootstrap_lib_for_luxury_buttons'] = true
    end
  end

  # QuarterMonthPicker and moment.js
  if Redmine::Plugin.installed?(:goals)
    Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_qmpicker'] = true
  end

  # Javascript Patch
  if Redmine::Plugin.installed?(:luxury_buttons) ||
     Redmine::Plugin.installed?(:kpi) ||
     Redmine::Plugin.installed?(:ldap_users_sync) ||
     Redmine::Plugin.installed?(:magic_my_page) ||
     Redmine::Plugin.installed?(:clear_plan) ||
     Redmine::Plugin.installed?(:goals) ||
     Redmine::Plugin.installed?(:rm_user_mentions) ||
     Redmine::Plugin.installed?(:service_desk) ||
     Redmine::Plugin.installed?(:training) ||
     Redmine::Plugin.installed?(:rmplus_tags) ||
     Redmine::Plugin.installed?(:redmine_issue_tabs) ||
     Redmine::Plugin.installed?(:unread_issues)

    Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_javascript_patches'] = true
  end

  # Modal windows
  if Redmine::Plugin.installed?(:luxury_buttons) ||
     Redmine::Plugin.installed?(:kpi) ||
     Redmine::Plugin.installed?(:ldap_users_sync) ||
     Redmine::Plugin.installed?(:magic_my_page) ||
     Redmine::Plugin.installed?(:clear_plan) ||
     Redmine::Plugin.installed?(:goals) ||
     Redmine::Plugin.installed?(:extra_queries) ||
     Redmine::Plugin.installed?(:rm_user_mentions) ||
     Redmine::Plugin.installed?(:service_desk) ||
     Redmine::Plugin.installed?(:training) ||
     Redmine::Plugin.installed?(:shipping) ||
     Redmine::Plugin.installed?(:custom_menu) ||
     Redmine::Plugin.installed?(:rmplus_tags)

    Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_modal_windows'] = true
  end

  # FontAwasome
  if Redmine::Plugin.installed?(:ldap_users_sync) ||
     Redmine::Plugin.installed?(:goals) ||
     Redmine::Plugin.installed?(:magic_my_page) ||
     Redmine::Plugin.installed?(:luxury_buttons)
    Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_font_awesome'] = true
  end

  Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]['enable_ajax_counters'] = true

  if Setting.plugin_a_common_libs.blank? || Setting.plugin_a_common_libs[:autoconfig_libs].present? || Setting.plugin_a_common_libs['autoconfig_libs'].present?
    Setting.plugin_a_common_libs = Redmine::Plugin::registered_plugins[:a_common_libs].settings[:auto]
  end

  unless IssueQuery.included_modules.include?(Acl::IssueQueryPatch)
    IssueQuery.send(:include, Acl::IssueQueryPatch)
  end

  if Redmine::Plugin.installed?(:ajax_counters)
    raise Redmine::PluginRequirementError.new("'Ajax Counter' now moved to 'A Common Libs' plugin. You must delete ajax_counter from your server.")
  end
end