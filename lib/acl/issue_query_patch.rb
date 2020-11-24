# must be last in patches stack
module Acl
  module IssueQueryPatch
    def self.included(base)
      base.send :prepend, InstanceMethods

      base.class_eval do
        cattr_accessor :acl_stored_filter_types
      end
    end


    module InstanceMethods

      def add_available_filter(field, options)
        if field.present? && options[:type].present?
          if self.class.acl_stored_filter_types.blank?
            self.class.acl_stored_filter_types = {}
          end
          self.class.acl_stored_filter_types[field.to_s] = options[:type]
        end
        super(field, options)
      end

      def type_for(field)
        if self.class.acl_stored_filter_types && self.class.acl_stored_filter_types[field.to_s].present?
          self.class.acl_stored_filter_types[field.to_s]
        else
          super(field)
        end
      end

      def sql_for_custom_field(field, operator, value, custom_field_id)
        if @available_filters.blank?
          @available_filters ||= ActiveSupport::OrderedHash.new
          @available_filters[field] = { field: CustomField.find_by_id(custom_field_id) }
          return nil if @available_filters[field][:field].blank?

          res = super(field, operator, value, custom_field_id)
          @available_filters = nil
        else
          res = super(field, operator, value, custom_field_id)
        end
        res
      end

      def group_by_column
        if group_by.present?
          super
        else
          nil
        end
      end

      def sort_clause
        if self.sort_criteria.blank?
          nil
        elsif self.sort_criteria.size == 1 && self.sort_criteria.first_key == 'id'
          ["#{Issue.table_name}.id #{self.sort_criteria.first_asc? ? 'ASC' : 'DESC'}"]
        else
          super
        end
      end
    end
  end
end