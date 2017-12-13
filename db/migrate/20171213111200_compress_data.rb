class CompressData < ActiveRecord::Migration[5.1]
  def change
    Dataset.all.each do |ds|
      ds.data = ActiveSupport::Gzip.compress(ds.data)
      ds.save!
    end
  end
end
