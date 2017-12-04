class IndicesController < ApplicationController
  before_action :set_index, only: [:show, :edit, :update, :destroy]

  # GET /indices
  def index
    @indices =  Kaminari.paginate_array(Index.all).page(params[:page])
  end

  # GET /indices/:id
  def show
  end

  # GET /indices/new
  def new
    @index = Index.new

    if params[:copy].present?
      idx = Index.find(params[:copy])
      @index.definition = idx.definition
    end
  end

  # GET /indices/:id/edit
  def edit
    @datasets = Dataset.where(index_name: @index.name).order(:name)
  end

  # POST /indices
  def create
    @index = Index.new(index_params)

    if @index.save
      redirect_to @index, notice: 'Index was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /indices/:id
  def update
    if @index.update(index_params, dataset_id: params[:dataset].present? ? params[:dataset] : nil)
      res = reload_dataset(@index)

      if res.has_key?('error')
        message = {alert: "Index was successfully created but Dataset import failed: #{res.inspect.truncate(256)}"}
      else
        message = {notice: 'Index was successfully updated.'}
      end

      redirect_to @index, message
    else
      render :edit
    end
  end

  # DELETE /indices/:id
  def destroy
    @index.destroy
    redirect_to indices_url, notice: 'Index was successfully destroyed.'
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_index
    @index = Index.find(params.fetch(:id))
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def index_params
    params.require(:index).permit(:name, :definition)
  end

  def reload_dataset(idx)
    dataset = idx.metadata.dataset

    if dataset
      dataset.import
    else
      {}
    end
  end
end
