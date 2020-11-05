module Acl::Utils::Macros
  class IssueMacros < Acl::Utils::Macros::BaseMacros
    def target_class
      ::Issue
    end

    def fill_macros
      unless @static_loaded
        @static_loaded = true
        super

        macros_list.add('issue_name', :label_acl_macro_issue_name, :helpers, Proc.new { |issue, user, html|
          str = issue.to_s
          html ? "{{rs_html\n<b>#{str}</b>\n}}" : str
        })
        macros_list.add('issue_link', :label_acl_macro_issue_link, :helpers, Proc.new { |issue, user, html|
          str = url_for({ controller: :issues, action: :show, id: issue.id, only_path: false })
          html ? "{{rs_html\n<a href='#{str}'>#{issue.to_s}</a>\n}}" : "#{issue.to_s}: #{str}"
        })

        macros_list.add('issue.id', '#', :fields, :id)
        macros_list.add('issue.project.identifier', :label_acl_macro_issue_project_identifier, :fields, :'project.identifier')

        (::Issue.column_names - %w(id lft rgt root_id lock_version parent_id)).each do |f|
          lbl = f.gsub(/\_id$/, '')
          if f.size != lbl.size
            ref = self.find_reflection(::Issue, f)
            if ref && ref.name.present?
              macros_list.add("issue.#{lbl}", f, :fields, ref.name.to_sym)
            else
              macros_list.add("issue.#{lbl}", f, :fields, lbl.to_sym)
            end

            macros_list.add("issue.#{lbl}.id", Proc.new { "#{::Issue.human_attribute_name(@value.to_s)} (ID)" }, :fields, f.to_sym)
          else
            macros_list.add("issue.#{f}", lbl, :fields, f.to_sym)
          end
        end
      end
      macros_list.add("issue.parent", :field_parent_issue, :fields, :parent_issue)
      macros_list.add("issue.parent.id", Proc.new { "#{l(:field_parent_issue)} (ID)" }, :fields, :'parent_issue.id')
      macros_list.add("issue.notes", :label_comment, :fields, :notes)

      IssueCustomField.order(:name).each do |cf|
        macros_list.add("issue.cf_#{cf.id}", cf.name, :custom_fields, Proc.new { |issue| format_object(cf.cast_value(issue.custom_field_value(cf)), false) })
      end

      @loaded = false
    end
  end
end