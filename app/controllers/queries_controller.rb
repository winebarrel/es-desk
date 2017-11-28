class QueriesController < ApplicationController
  before_action :set_query, only: [:show, :edit, :update, :destroy]

  # GET /queries
  def index
    @queries = Query.order(:name).page(params[:page])
  end

  # GET /queries/:id
  def show
  end

  # GET /queries/new
  def new
    @query = Query.new

    if params[:copy].present?
      q = Query.find(params[:copy])
      @query.query = q.query
    end
  end

  # GET /queries/:id/edit
  def edit
  end

  # POST /queries
  def create
    @query = Query.new(query_params)

    if @query.save
      redirect_to @query, notice: 'Query was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /queries/:id
  def update
    if @query.update(query_params)
      redirect_to @query, notice: 'Query was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /queries/:id
  def destroy
    @query.destroy
    redirect_to queries_url, notice: 'Query was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_query
    @query = Query.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def query_params
    params.require(:query).permit(:name, :query)
  end
end
