require "starburst/engine"
require "helpers/starburst/configuration"

module Starburst
	extend Configuration

	define_setting :current_admin_user_method, "current_admin_user"
	define_setting :admin_user_instance_methods
end
