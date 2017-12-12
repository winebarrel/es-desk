class AnalyzeController < ApplicationController
  def index
    @analyze = params[:analyze]
    session[:analyze] = @analyze if @analyze

    if @analyze
      @analyze = beautify_json(@analyze)
    end

    if @analyze.present?
      elasticsearch = Rails.application.config.elasticsearch
      @result = JSON.pretty_generate(elasticsearch.analyze(@analyze))
    end
  end

  private

  def beautify_json(json)
    hash = JSON.parse(json)
    JSON.pretty_generate(hash) + "\n"
  rescue JSON::ParserError
    json
  end
end
