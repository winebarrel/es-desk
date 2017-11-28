module IndicesHelper
  def index_link_to_dataset(index)
    dataset = index.metadata.dataset

    if dataset
      link_to dataset.name, dataset
    else
      '-'
    end
  end
end
