class AddPictureToChannel < ActiveRecord::Migration
  def change
    add_column :channels, :picture, :string
  end
end
