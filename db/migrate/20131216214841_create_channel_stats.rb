class CreateChannelStats < ActiveRecord::Migration
  def change
    create_table :channel_stats do |t|
      t.integer :subscribers
      t.references :channel, index: true

      t.timestamps
    end
  end
end
