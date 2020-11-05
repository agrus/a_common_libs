module ACommonLibs
  module SettingsControllerPatch

    def self.included(base)

      base.extend(ClassMethods)
      base.send(:prepend, InstanceMethods)

    end

    module ClassMethods
    end

    module InstanceMethods
      def plugin
        if request.post?
          if params[:settings].nil? || params[:settings] == ''
            params[:settings] = HashWithIndifferentAccess.new
          end
        end
        super
      end
    end

  end
end