class VisitorsController < ApplicationController
  def index
    @search = params[:search]
    @indices = Index.all
    @queries = Query.order(:name)

    if params[:index].present?
      @index = Index.find(params[:index])
    end

    if params[:query].present?
      @query = Query.find(params[:query])
    end

    if @search.present? && @index
      result = JSON.pretty_generate(@index.search(@search))
      dataset = @index.metadata.dataset

      @resultset = Resultset.new(
        index_name: @index.name,
        dataset: dataset,
        dataset_preview: dataset.try(:preview),
        query: @search,
        result: result,
      )
    end
  end

  def query
    render plain: Query.find(params[:query]).query
  end
end
