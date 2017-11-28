class IndexMetadatum < ApplicationRecord
  belongs_to :dataset,  required: false

  def index
    Index.find(self.index_name)
  end
end
