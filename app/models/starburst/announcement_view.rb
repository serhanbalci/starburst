module Starburst
	class AnnouncementView < ActiveRecord::Base
		if Rails::VERSION::MAJOR < 4
			attr_accessible :announcement_id, :admin_user_id
		end
		
		belongs_to :announcement
		belongs_to :admin_user

		validates :announcement_id, presence: true
		validates :admin_user_id, presence: true
		validates_uniqueness_of :admin_user_id, scope: :announcement_id
	end
end