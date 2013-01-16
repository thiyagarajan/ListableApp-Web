class UserSession < Authlogic::Session::Base
  self.allow_http_basic_auth false
  self.single_access_allowed_request_types = ["application/json"]
  
  find_by_login_method :find_by_login_or_email
end