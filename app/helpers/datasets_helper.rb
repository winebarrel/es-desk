module DatasetsHelper
  def dataset_link_to_index(dataset)
    idx = Index.find_by_name(dataset.index_name)

    if idx
      link_to dataset.index_name, index_path(dataset.index_name)
    else
      dataset.index_name
    end
  end
end
