module Acl::Patches::Models
  module QueryPatch
    def self.included(base)
      base.send :prepend, InstanceMethods

      base.class_eval do
        attr_accessor :acl_ajax_like

        self.operators_by_filter_type[:acl_date_time] = %w(= >< >= <= !* *)
      end
    end

    module InstanceMethods
      def sql_for_field(field, operator, value, db_table, db_field, is_custom_filter=false)
        if operator == '><' && type_for(field) == :acl_date_time
          sql = date_clause(db_table, db_field, parse_date(value[0]), parse_date(value[1]), is_custom_filter)
        elsif operator == '<=' && type_for(field) == :acl_date_time
          sql = date_clause(db_table, db_field, nil, parse_date(value.first), is_custom_filter)
        elsif operator == '>=' && type_for(field) == :acl_date_time
          sql = date_clause(db_table, db_field, parse_date(value.first), nil, is_custom_filter)
        else
          sql = super(field, operator, value, db_table, db_field, is_custom_filter)
        end
        sql
      end

      def parse_date(arg)
        if arg.to_s =~ /\A\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}/
          User.current.acl_user_to_server_time(arg.to_s, true)
        else
          super (arg)
        end
      end

      def acl_project_ids
        return @acl_project_ids if @acl_project_ids
        @acl_project_ids = []
        if self.project
          @acl_project_ids << self.project.id

          unless self.project.leaf?
            @acl_project_ids += self.project.descendants.visible.pluck(:id)
          end
        else
          if self.all_projects.any?
            @acl_project_ids = self.all_projects.map(&:id)
          end
        end

        @acl_project_ids
      end

      def acl_principals_scope
        Principal.joins(:members)
                 .where("#{User.table_name}.status in (?)", [Principal::STATUS_LOCKED, Principal::STATUS_ACTIVE])
                 .where("#{Member.table_name}.project_id in (?)", self.acl_project_ids + [0])
                 .order("#{User.table_name}.status")
                 .sorted
                 .distinct
      end

      def acl_principals
        @acl_principals ||= self.acl_principals_scope.to_a
      end
      def acl_users
        @acl_users ||= self.acl_principals_scope.where("#{User.table_name}.type = 'User'").to_a
      end
      def acl_locked_users
        @acl_locked_users ||= self.acl_principals_scope.where("#{User.table_name}.type = 'User' and #{User.table_name}.status = ?", Principal::STATUS_LOCKED).to_a
      end
    end

  end
end