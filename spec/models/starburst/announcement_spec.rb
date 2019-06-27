require_relative "../../spec_helper"

module Starburst

describe Announcement do

  context "a basic announcement" do

    it "can't be created without a body" do
      expect(Announcement.create(:body => nil).tap(&:valid?).errors[:body]).not_to be_empty
    end

    it "can be created with just a body" do
      expect(Announcement.create(:body => "This is an announcement.")).to be_valid
    end

    it "can be created with just a title" do
      expect(Announcement.create(:body => "This is an announcement.", :title => "Test title")).to be_valid
    end

  end

  context "a scheduled annoucement" do

    it "does not show up past its end date" do
      Announcement.create(:body => "test", :stop_delivering_at => 1.day.ago)
      expect(Announcement.current.blank?).to eq true
    end

    it "shows before its end date" do
      Announcement.create(:body => "test", :stop_delivering_at => Time.current + 1.day)
      expect(Announcement.current.present?).to eq true
    end

    it "does not show up before its start date" do
      Announcement.create(:body => "test", :start_delivering_at => Time.current + 1.day)
      expect(Announcement.current.blank?).to eq true
    end

    it "shows after its start date" do
      Announcement.create(:body => "test", :start_delivering_at => 1.day.ago)
      expect(Announcement.current.present?).to eq true
    end

    it "shows up between its start and end dates" do
      Announcement.create(:body => "test", :start_delivering_at => Time.current, :stop_delivering_at => Time.current + 1.day)
      expect(Announcement.current.present?).to eq true
    end

    it "does not show when its start and end dates are the same" do
      Announcement.create(:body => "test", :start_delivering_at => Time.current, :stop_delivering_at => Time.current)
      expect(Announcement.current.blank?).to eq true
    end

  end

  context "an announcement not yet read by the current admin_user" do

    it "shows up" do
      read_announcement = Announcement.create(:body => "test", :start_delivering_at => 1.day.ago)
      unread_announcement = Announcement.create(:body => "test", :start_delivering_at => Time.current)
      admin_user_who_read_announcement = FactoryGirl.create(:admin_user)
      AnnouncementView.create(:announcement => read_announcement, :admin_user => admin_user_who_read_announcement)
      expect(Announcement.unread_by(admin_user_who_read_announcement)).to eq [unread_announcement]
    end

    it "shows up for the current admin_user even when others have read it" do
      read_announcement = Announcement.create(:body => "test", :start_delivering_at => 1.day.ago)
      unread_announcement = Announcement.create(:body => "test", :start_delivering_at => Time.current)
      admin_user_who_read_announcement = FactoryGirl.create(:admin_user)
      admin_user_who_read_no_announcements = FactoryGirl.create(:admin_user)
      AnnouncementView.create(:announcement => read_announcement, :admin_user => admin_user_who_read_announcement)
      expect(Announcement.unread_by(admin_user_who_read_no_announcements)).to include(unread_announcement, read_announcement)
    end

  it "shows up for the current admin_user even when they have read other announcements" do
      read_announcement = Announcement.create(:body => "test", :start_delivering_at => 1.day.ago)
      unread_announcement = Announcement.create(:body => "test", :start_delivering_at => Time.current)
      admin_user_who_read_announcement = FactoryGirl.create(:admin_user)
      AnnouncementView.create(:announcement => read_announcement, :admin_user => admin_user_who_read_announcement)
      expect(Starburst::Announcement.current(admin_user_who_read_announcement)).to eq unread_announcement
    end


  end

  context "an announcement targeted to certain admin_users" do
    it "has a limited_to_admin_users field that is retrieveable from the database" do
      limited_announcement = Announcement.create(:body => "test", :limit_to_admin_users => [
        {
          :field => "subscription",
          :value => "",
          :operator => "="
        }
      ])
      expect(limited_announcement.limit_to_admin_users[0][:field]).to eq "subscription"
    end

    it "shows up for the proper admin_user only (one positive condition)" do
      limited_announcement = Announcement.create(:body => "test", :limit_to_admin_users => [
        {
          :field => "subscription",
          :value => ""
        }
      ])
      admin_user_who_should_see_announcement = FactoryGirl.create(:admin_user, :subscription => "")
      admin_user_who_should_not_see_announcement = FactoryGirl.create(:admin_user, :subscription => "monthly")
      expect(Announcement.find_announcement_for_current_admin_user(Announcement.where(nil), admin_user_who_should_see_announcement)).to eq limited_announcement
      expect(Announcement.find_announcement_for_current_admin_user(Announcement.where(nil), admin_user_who_should_not_see_announcement)).to eq nil
    end

    it "shows up for the proper admin_user only (method condition)" do
      Starburst.admin_user_instance_methods = ["free?"]
      limited_announcement = Announcement.create(:body => "test", :limit_to_admin_users => [
        {
          :field => "free?",
          :value => true
        }
      ])
      admin_user_who_should_see_announcement = FactoryGirl.create(:admin_user, :subscription => "")
      admin_user_who_should_not_see_announcement = FactoryGirl.create(:admin_user, :subscription => "monthly")
      expect(Announcement.find_announcement_for_current_admin_user(Announcement.where(nil), admin_user_who_should_see_announcement)).to eq limited_announcement
      expect(Announcement.find_announcement_for_current_admin_user(Announcement.where(nil), admin_user_who_should_not_see_announcement)).to eq nil
    end

    # it "performs" do
    #   pending
    #   require 'benchmark'

    #   (1 .. 500).each do
    #     Announcement.create(:limit_to_admin_users => [
    #       {
    #         :field => "subscription",
    #         :value => ""
    #       }
    #     ])
    #   end

    #   (1 .. 10000).each do
    #     create(:admin_user, :subscription => "")
    #   end

    #   Benchmark.realtime{
    #   Announcement.current(admin_user.last)
    #   }
    # end

  end



end

end
