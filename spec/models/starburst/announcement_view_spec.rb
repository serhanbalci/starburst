require_relative "../../spec_helper"

module Starburst

describe AnnouncementView do

  it "does not allow a admin_user to mark two views of an announcement" do
  	admin_user = FactoryGirl.create(:admin_user)
  	announcement = FactoryGirl.create(:announcement)
  	view1 = FactoryGirl.create(:announcement_view, :admin_user => admin_user, :announcement => announcement)
  	view2 = FactoryGirl.build(:announcement_view, :admin_user => admin_user, :announcement => announcement)
  	expect(view1).to be_valid
  	expect(view2.tap(&:valid?).errors[:admin_user_id]).not_to be_empty
  end

  it "allows a admin_user to log views of different announcements" do
  	admin_user = FactoryGirl.create(:admin_user)
  	announcement1 = FactoryGirl.create(:announcement)
  	announcement2 = FactoryGirl.create(:announcement)
  	view1 = FactoryGirl.create(:announcement_view, :admin_user => admin_user, :announcement => announcement1)
  	view2 = FactoryGirl.create(:announcement_view, :admin_user => admin_user, :announcement => announcement2)
  	expect(view1).to be_valid
  	expect(view2).to be_valid
  end

  it "allows multiple admin_users to view the same announcement" do
  	admin_user1 = FactoryGirl.create(:admin_user)
  	admin_user2 = FactoryGirl.create(:admin_user)
  	announcement = FactoryGirl.create(:announcement)
  	view1 = FactoryGirl.create(:announcement_view, :admin_user => admin_user1, :announcement => announcement)
  	view2 = FactoryGirl.create(:announcement_view, :admin_user => admin_user2, :announcement => announcement)
  	expect(view1).to be_valid
  	expect(view2).to be_valid
  end

end
end
