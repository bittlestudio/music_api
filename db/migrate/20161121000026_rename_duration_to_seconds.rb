class RenameDurationToSeconds < ActiveRecord::Migration[5.0]
  def change
    rename_column :songs, :duration, :seconds
  end
end
