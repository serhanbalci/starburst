require 'spec_helper'

feature 'Announcements' do
	scenario 'show announcement to admin_user' do
		@current_admin_user = FactoryGirl.create(:admin_user)
		ActionController::Base.any_instance.stub(:current_admin_user).and_return(@current_admin_user)
		ActionView::Base.any_instance.stub(:current_admin_user).and_return(@current_admin_user)
		FactoryGirl.create(:announcement, :body => "My announcement")
		visit root_path
		page.should have_content "My announcement"
	end
	scenario 'show no announcements if admin_user not logged in' do
		ActionController::Base.any_instance.stub(:current_admin_user).and_return(nil)
		ActionView::Base.any_instance.stub(:current_admin_user).and_return(nil)
		FactoryGirl.create(:announcement, :body => "My announcement")
		visit root_path
		page.should_not have_content "My announcement"
		page.should have_content "Sample homepage"
	end
	scenario 'stop showing announcement once the admin_user has read it' do
		@current_admin_user = FactoryGirl.create(:admin_user)
		ActionController::Base.any_instance.stub(:current_admin_user).and_return(@current_admin_user)
		ActionView::Base.any_instance.stub(:current_admin_user).and_return(@current_admin_user)
		announcement = FactoryGirl.create(:announcement, :body => "My announcement")
		visit root_path
		page.should have_content "My announcement"
		FactoryGirl.create(:announcement_view, :admin_user => @current_admin_user, :announcement => announcement)
		visit root_path
		page.should_not have_content "My announcement"
	end
	scenario 'allow the admin_user to click to hide the announcement' do
		skip "Figure out how to best stub the current_admin_user method for a JavaScript-enabled test"
	end
end
