module ResultsetsHelper
  def rs_link_to_dataset(resultset)
    dataset = resultset.dataset

    if dataset
      link_to dataset.name, dataset
    else
      '-'
    end
  end

  def rs_link_to_index(resultset)
    idx = resultset.index

    if idx
      link_to idx.name, index_path(idx.name)
    else
      resultset.index_name
    end
  end
end
