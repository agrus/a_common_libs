module Acl
  class SessionStoreBypass < ActiveRecord::SessionStore::Session
    # to prevent saving session for API requests
    before_save do
      false if User.current.api_request?
    end
  end
end

if ActionDispatch::Session::ActiveRecordStore.session_class == ActiveRecord::SessionStore::Session
  ActionDispatch::Session::ActiveRecordStore.session_class = Acl::SessionStoreBypass
end

