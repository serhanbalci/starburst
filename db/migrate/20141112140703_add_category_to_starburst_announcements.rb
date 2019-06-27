class AddCategoryToStarburstAnnouncements < ActiveRecord::Migration[5.2]
  def change
    add_column :starburst_announcements, :category, :text
  end
end
