class ResultsetsController < ApplicationController
  before_action :set_resultset, only: [:show, :destroy]

  # GET /resultsets
  def index
    @resultsets = Resultset.order(created_at: :desc).page(params[:page])
  end

  # GET /resultsets/:id
  def show
  end

  # POST /resultsets
  def create
    @resultset = Resultset.new(resultset_params)
    @resultset.load_data!
    @resultset.save!
    redirect_to @resultset, notice: 'Resultset was successfully created.'
  end


  # DELETE /resultsets/:id
  # DELETE /resultsets/:id.json
  def destroy
    @resultset.destroy
    respond_to do |format|
      format.html { redirect_to resultsets_url, notice: 'Resultset was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_resultset
    @resultset = Resultset.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def resultset_params
    params.require(:resultset).permit(:index_name, :dataset_id, :query, :result)
  end
end
