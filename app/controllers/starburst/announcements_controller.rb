require_dependency 'starburst/application_controller'

module Starburst
	class AnnouncementsController < ApplicationController
		def mark_as_read
			announcement = Announcement.find(params[:id].to_i)
			if respond_to?(Starburst.current_admin_user_method) && send(Starburst.current_admin_user_method) && announcement
				if AnnouncementView.where(admin_user_id: send(Starburst.current_admin_user_method).id, announcement_id: announcement.id).first_or_create(admin_user_id: send(Starburst.current_admin_user_method).id, announcement_id: announcement.id)
					render :json => :ok
				else
					render json: nil, :status => :unprocessable_entity
				end
			else
					render json: nil, :status => :unprocessable_entity
			end
		end
	end
end
