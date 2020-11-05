module Acl
  module IssuesPdfHelperPatch
    def self.included(base)
      base.send :prepend, InstanceMethods
    end

    module InstanceMethods
      def fetch_row_values(issue, query, level)
        query.inline_columns.collect do |column|
          s = if column.is_a?(QueryCustomFieldColumn)
            cv = issue.visible_custom_field_values.detect {|v| v.custom_field_id == column.custom_field.id}
            show_value(cv, false)
          else
            value = issue.send(column.name)
            case column.name
              when :subject
                value = "  " * level + value
              when :attachments
                value = value.to_a.map {|a| a.filename}.join("\n")
            end
            if value.is_a?(Date)
              format_date(value)
            elsif value.is_a?(Time)
              format_time(value)
            else
              format_object(value, false)
            end
          end
          s.to_s
        end
      end
    end
  end
end

unless Redmine::Export::PDF::IssuesPdfHelper.included_modules.include?(Acl::IssuesPdfHelperPatch)
  Redmine::Export::PDF::IssuesPdfHelper.send :include, Acl::IssuesPdfHelperPatch
end