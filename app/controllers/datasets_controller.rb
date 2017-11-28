class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy, :import]

  # GET /datasets
  # GET /datasets.json
  def index
    @datasets = Dataset.order(:name).page(params[:page])
  end

  # GET /datasets/1
  # GET /datasets/1.json
  def show
  end

  # GET /datasets/new
  def new
    @dataset = Dataset.new
  end

  # GET /datasets/:id/edit
  def edit
  end

  # POST /datasets
  def create
    @dataset = Dataset.new(dataset_params)

    if disable_sql_logging { @dataset.save }
      redirect_to @dataset, notice: 'Dataset was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /datasets/:id
  def update
    if disable_sql_logging { @dataset.update(dataset_params) }
      redirect_to @dataset, notice: 'Dataset was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /datasets/:id
  def destroy
    @dataset.destroy
    redirect_to datasets_url, notice: 'Dataset was successfully destroyed.'
  end

  # POST /import/:id
  def import
    res = @dataset.import

    if res.has_key?('error')
      Rails.logger.warn(res)
      redirect_to @dataset, alert: res.inspect.truncate(256)
    else
      redirect_to @dataset, notice: 'Dataset was successfully imported.'
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dataset
    @dataset = Dataset.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dataset_params
    params.require(:dataset).permit(:name, :index_name, :document_type, :data)
  end
end
