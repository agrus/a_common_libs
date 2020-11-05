module Acl::UrlHelpersPatch
  def self.included(base)
    base.send :prepend, InstanceMethods
  end

  module InstanceMethods
    def uri_with_safe_scheme?(uri, schemes = ['http', 'https', 'ftp', 'mailto', nil])
      if uri.to_s.downcase.split(':').first == 'mailto'
        begin
          super(uri, schemes)
        rescue # just fix ruby bug
          true
        end
      else
        super(uri, schemes)
      end
    end
  end
end

unless Redmine::Helpers::URL.included_modules.include?(Acl::UrlHelpersPatch)
  Redmine::Helpers::URL.send :include, Acl::UrlHelpersPatch
end