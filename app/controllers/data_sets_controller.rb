class DataSetsController < ApplicationController
  def index
    @competition = Competition.current
    @data_sets = @competition.data_sets
    @id_regions = Region.id_regions(@data_sets.pluck(:region_id))
    respond_to do |format|
      format.html
      format.csv { send_data @data_sets.to_csv }
    end
  end

  def show
    @data_set = DataSet.find(params[:id])
  end
end
