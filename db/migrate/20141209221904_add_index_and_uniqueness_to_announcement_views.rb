class AddIndexAndUniquenessToAnnouncementViews < ActiveRecord::Migration[5.2]
  def change
  	add_index :starburst_announcement_views, [:admin_user_id, :announcement_id], unique: true, name: 'starburst_announcement_view_index'
  end
end