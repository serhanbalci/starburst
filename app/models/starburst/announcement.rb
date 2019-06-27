module Starburst
	class Announcement < ActiveRecord::Base

		validates :body, presence: true

		serialize :limit_to_admin_users

		if Rails::VERSION::MAJOR < 4
			attr_accessible :title, :body, :start_delivering_at, :stop_delivering_at, :limit_to_admin_users
		end

		scope :ready_for_delivery, lambda {
			where("(start_delivering_at < ? OR start_delivering_at IS NULL)
				AND (stop_delivering_at > ? OR stop_delivering_at IS NULL)", Time.current, Time.current)
		}

		scope :unread_by, lambda {|current_admin_user|
			joins("LEFT JOIN starburst_announcement_views ON
				starburst_announcement_views.announcement_id = starburst_announcements.id AND
				starburst_announcement_views.admin_user_id = #{current_admin_user.id}")
			.where("starburst_announcement_views.announcement_id IS NULL AND starburst_announcement_views.admin_user_id IS NULL")
		}

		scope :in_delivery_order, lambda { order("start_delivering_at ASC")}

		def self.current(current_admin_user = nil)
			if current_admin_user
				find_announcement_for_current_admin_user(ready_for_delivery.unread_by(current_admin_user).in_delivery_order, current_admin_user)
			else
				ready_for_delivery.in_delivery_order.first
			end
		end

		def self.find_announcement_for_current_admin_user(announcements, admin_user)
			admin_user_as_array = admin_user.serializable_hash(methods: Starburst.admin_user_instance_methods)
			announcements.each do |announcement|
				if admin_user_matches_conditions(admin_user_as_array, announcement.limit_to_admin_users)
					return announcement
				end
			end
			return nil
		end

		def self.admin_user_matches_conditions(admin_user, conditions = nil)
			if conditions
				conditions.each do |condition|
					if admin_user[condition[:field]] != condition[:value]
						return false
					end
				end
			end
			return true
		end

	end
end
