class VisitorsController < ApplicationController
  def index
    @search = params[:search]
    session[:search] = @search if @search

    if @search
      @search = beautify_json(@search)
    end

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
        name: "#{@index.name} #{Time.now}",
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

  private

  def beautify_json(json)
    hash = JSON.parse(json)
    JSON.pretty_generate(hash)
  rescue JSON::ParserError
    json
  end
end
