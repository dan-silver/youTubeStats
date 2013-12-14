class Video < ActiveRecord::Base
  belongs_to :channel
  has_many :videoStatistics
  has_many :stats, :foreign_key => 'video_id', :class_name => "VideoStatistic"
end
