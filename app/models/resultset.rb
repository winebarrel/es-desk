class Resultset < ApplicationRecord
  belongs_to :dataset, required: false

  validates :name, presence: true

  def index
    Index.find_by_name(self.index_name)
  end

  def query_preview
    JSON.parse(self.query).to_json.truncate(64)
  end

  def load_data!
    ds = self.dataset
    self.dataset_preview = ds.preview if ds

    idx = self.index
    self.index_definition = idx.definition if idx
  end
end
