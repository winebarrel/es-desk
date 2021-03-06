class Dataset < ApplicationRecord
  VARIDATE_BUFSIZE = 32
  EMPTY_ACTION = '{"index":{}}'
  SHORT_PREVIEW_LEN = 64
  PREVIEW_LINES = 10

  validates :name, presence: true, uniqueness: true
  validates :index_name, presence: true, format: { with: Index::INDEX_NAME_FORMAT }
  validates :document_type, presence: true
  validates :data, presence: true
  validate :data_should_be_valid_ndjson

  before_save :read_file

  serialize :data, SerializeCoder::Gzip

  class << self
    def select_without_data
      self.select(*(self.column_names - ['data']))
    end
  end # of class methods

  def index
    Index.find_by_name(self.index_name)
  end

  def import
    res = Rails.application.config.elasticsearch.bulk(data_with_action, index: self.index_name, type: self.document_type)

    if !Elasticsearch::Client.has_error?(res) && self.index
      index_metadata = self.index.metadata
      index_metadata.dataset = self
      index_metadata.save!
    end

    res
  end

  def preview
    self.data.each_line.take(PREVIEW_LINES).join
  end

  def short_preview
    self.data.each_line.take(1).fetch(0).truncate(64).chomp
  end

  def data_with_metadata
    metadata = {'index' => {'_index' => self.index_name, '_type' => self.document_type}}.to_json

    self.data.each_line.map {|line|
      metadata + "\n" + line
    }.join
  end

  def data_count
    self.data.each_line.count
  end

  def copy_to(name)
    self.class.new do |ds|
      ds.name = name
      ds.index_name = self.index_name
      ds.document_type = self.document_type
      ds.data = self.data
    end
  end

  private

  def data_should_be_valid_ndjson
    if self.data.is_a?(ActionDispatch::Http::UploadedFile)
      head = self.data.read(VARIDATE_BUFSIZE) || ''

      unless head.strip =~ /\A{/
        errors.add(:data, " is invalid NDJSON: #{head.inspect.truncate(256)}")
      end

      file = self.data.open

      begin
        file.each_with_index do |line, i|
          begin
            JSON.parse(line)
          rescue JSON::ParserError => e
            errors.add(:data, " is invalid NDJSON: line: #{i + 1}: #{e.message}: #{line}")
            break
          end
        end
      ensure
        file.rewind
      end
    end
  end

  def read_file
    self.data = self.data.each_line.select {|line|
      line !~ /\A\s*\{\s*"index"\s*:\s*\{/
    }.join

    true
  end

  def data_with_action
    data.each_line.map {|l| EMPTY_ACTION + "\n" + l }.join
  end
end
