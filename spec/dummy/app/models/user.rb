class AdminUser < ActiveRecord::Base
	def free?
		subscription.blank?
	end
end
