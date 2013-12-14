class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.string :name
      t.string :youTubeId

      t.timestamps
    end
  end
end
