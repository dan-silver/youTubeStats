class AddPictureToVideo < ActiveRecord::Migration
  def change
    add_column :videos, :picture, :string
  end
end
