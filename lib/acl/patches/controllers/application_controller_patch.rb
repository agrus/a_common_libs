module Acl::Patches::Controllers
  module ApplicationControllerPatch
    def self.included(base)
      base.send(:prepend, InstanceMethods)

      base.class_eval do
        before_action :acl_store_mobile

        helper_method :acl_mobile_device?
      end
    end

    module InstanceMethods

      def acl_store_mobile
        session[:mobile_override] = params[:mobile] if params[:mobile]
      end

      def acl_check_for_mobile(path_to_plugin)
        acl_prepare_for_mobile(path_to_plugin) if acl_mobile_device?
      end

      def acl_prepare_for_mobile(path_to_plugin)
        prepend_view_path(File.join(path_to_plugin, 'app', 'views_mobile'))
      end

      def acl_mobile_device?
        if session[:mobile_override]
          session[:mobile_override] == "1"
        else
          # Season this regexp to taste. I prefer to treat iPad as non-mobile.
          request.user_agent =~ /Mobile|iP(hone|od)|Android|webOS/
        end
      end

      def find_current_user
        usr = super

        usr.api_request = api_request? if usr
        usr
      end
    end

  end
end
