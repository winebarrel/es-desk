class Query < ApplicationRecord
  PREVIEW_LEN = 64

  validates :name, presence: true, uniqueness: true
  validates :query, presence: true
  validate :query_should_be_valid_json

  before_save :beautify!

  def preview
    JSON.parse(self.query).to_json.truncate(64)
  end

  def beautify!
    self.query = JSON.pretty_generate(JSON.parse(self.query)) + "\n"
  end

  private

  def query_should_be_valid_json
    begin
      JSON.parse(self.query)
    rescue JSON::ParserError => e
      errors.add(:query, " is invalid JSON: #{e.message}")
    end
  end
end
