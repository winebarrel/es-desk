class DatasetsController < ApplicationController
  before_action :set_dataset, only: [:show, :edit, :update, :destroy, :import, :download, :copy]

  # GET /datasets
  # GET /datasets.json
  def index
    @datasets = Dataset.select_without_data.order(:name).page(params[:page])
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

  # GET /datasets/:dataset_id/import
  def import
    idx = @dataset.index
    truncate_res = idx.truncate! if idx
    import_res = @dataset.import

    if truncate_res && Elasticsearch::Client.has_error?(truncate_res)
      error_res = truncate_res
    elsif Elasticsearch::Client.has_error?(import_res)
      error_res = import_res
    end

    if error_res
      redirect_to @dataset, alert: error_res.inspect.truncate(1024)
    else
      redirect_to @dataset, notice: 'Dataset was successfully imported.'
    end
  end

  # GET /datasets/:dataset_id/download
  def download
    send_data @dataset.data_with_metadata, filename: "#{@dataset.name}.json", type: :json
  end

  # GET /datasets/:dataset_id/copy
  def copy
    @dataset = @dataset.copy_to(@dataset.name + '-copy-' + SecureRandom.hex(4))

    if disable_sql_logging { @dataset.save }
      redirect_to @dataset, notice: 'Dataset was successfully created.'
    else
      render :edit
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_dataset
    @dataset = Dataset.find(params[:id] || params[:dataset_id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def dataset_params
    params.require(:dataset).permit(:name, :index_name, :document_type, :data)
  end
end
