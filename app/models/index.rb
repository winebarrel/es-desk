class Index
  class IndexNotFound < StandardError
    attr_accessor :error, :status

    def initialize(index_name, error_response)
      self.error = error_response.fetch('error')
      self.status = error_response.fetch('status')
      super("Couldn't find Index with 'index'=#{index_name}: #{error_response.inspect}")
    end
  end

  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :definition

  attr_accessor :health
  attr_accessor :status
  attr_accessor :uuid
  attr_accessor :pri
  attr_accessor :rep
  attr_accessor :docs_count
  attr_accessor :docs_deleted
  attr_accessor :store_size
  attr_accessor :store_size_in_byte
  attr_accessor :pri_store_size
  attr_accessor :pri_store_size_in_byte

  attr_accessor :persisted

  INDEX_NAME_FORMAT = /\A[-\w]+\z/
  validates :name, presence: true, format: { with: INDEX_NAME_FORMAT }
  validates :definition, presence: true
  validate :definition_should_be_valid_json
  validate :definition_should_be_valid

  class << self
    def all
      indices = Rails.application.config.elasticsearch.indices
      indices.sort_by! {|i| i['index'] }

      indices.map do |idx|
        idx = idx.map {|k, v| [k.tr('.', '_').to_sym, v] }.to_h
        idx[:name] = idx.delete(:index)
        idx[:persisted] = true
        self.new(idx)
      end
    end

    def find(index_name)
      idx = Rails.application.config.elasticsearch.index(index_name)

      if Elasticsearch::Client.has_error?(idx)
        raise IndexNotFound.new(index_name, idx)
      end

      conv_to_model(index_name, idx)
    end

    def find_by_name(index_name)
      idx = Rails.application.config.elasticsearch.index(index_name)

      if Elasticsearch::Client.has_error?(idx)
        nil
      else
        conv_to_model(index_name, idx)
      end
    end

    def fix_definition(definition)
      settings_index = definition.dig('settings', 'index')

      if settings_index
        if settings_index['creation_date']
          settings_index.delete('creation_date')
        end

        if settings_index['provided_name']
          settings_index.delete('provided_name')
        end

        if settings_index['uuid']
          settings_index.delete('uuid')
        end

        if settings_index['version']
          settings_index.delete('version')
        end
      end

      definition
    end

    def conv_to_model(index_name, idx)
      index_definition = idx.fetch(index_name)
      index_definition = fix_definition(index_definition)
      model = self.new(name: index_name, definition: JSON.pretty_generate(index_definition), persisted: true)

      stats = Rails.application.config.elasticsearch.stats(index_name)

      unless Elasticsearch::Client.has_error?(stats)
        stats = stats.fetch('_all')
        total = stats.fetch('total')
        primaries = stats.fetch('primaries')
        model.docs_count = total.fetch('docs').fetch('count')
        model.docs_deleted = total.fetch('docs').fetch('deleted')
        model.store_size_in_byte = total.fetch('store').fetch('size_in_bytes')
        model.pri_store_size_in_byte = primaries.fetch('store').fetch('size_in_bytes')
      end

      model
    end
  end # of class methods

  def id
    self.name
  end

  def persisted?
    self.persisted
  end

  def metadata
    IndexMetadatum.find_or_create_by!(index_name: self.name)
  end

  def destroy
    res = Rails.application.config.elasticsearch.delete(self.name)

    unless Elasticsearch::Client.has_error?(res)
      IndexMetadatum.where(index_name: self.name).delete_all
    end

    res
  end

  def reload!
    idx = self.class.find(self.name)
    self.definition = idx.definition
    self.persisted = true
    self
  end

  def truncate!
    self.reload! unless self.definition
    elasticsearch = Rails.application.config.elasticsearch
    res = elasticsearch.delete(self.name)

    if Elasticsearch::Client.has_error?(res)
      return res
    end

    parsed_definition = JSON.parse(self.definition)
    parsed_definition = self.class.fix_definition(parsed_definition)

    res = elasticsearch.create(JSON.dump(parsed_definition), index: self.name)

    if Elasticsearch::Client.has_error?(res)
      return res
    end

    update_dataset!(nil)
    res
  end

  def update(index_params, dataset_id:)
    index_params.each do |key, value|
      self.send("#{key}=", value)
    end

    if self.save
      update_dataset!(dataset_id)
      true
    end
  end

  def save
    if self.valid?
      elasticsearch = Rails.application.config.elasticsearch

      if self.persisted?
        res = elasticsearch.delete(self.name)

        if Elasticsearch::Client.has_error?(res)
          errors.add(:definition, " could not be deleted: #{res.inspect.truncate(256)}")
          return false
        end
      end

      res = elasticsearch.create(self.definition, index: self.name)

      if Elasticsearch::Client.has_error?(res)
        errors.add(:definition, " could not be created: #{res.inspect.truncate(256)}")
        return false
      end

      true
    end
  end

  def search(query)
    elasticsearch = Rails.application.config.elasticsearch
    elasticsearch.search(self.name, query: query)
  end

  def update_dataset!(dataset_id)
    index_metadata = self.metadata

    if name
      index_metadata.dataset = Dataset.where(id: dataset_id).take
    else
      index_metadata.dataset = nil
    end

    index_metadata.save!
  end

  private

  def definition_should_be_valid_json
    begin
      JSON.parse(self.definition)
    rescue JSON::ParserError => e
      errors.add(:definition, " is invalid JSON: #{e.message}")
    end
  end

  def definition_should_be_valid
    if self.name =~ INDEX_NAME_FORMAT
      elasticsearch = Rails.application.config.elasticsearch
      temporary_index = self.name + '-' + SecureRandom.hex

      begin
        res = elasticsearch.create(self.definition, index: temporary_index)

        if Elasticsearch::Client.has_error?(res)
          errors.add(:definition, " is invalid: #{res.inspect.truncate(1024)}")
        end
      ensure
        elasticsearch.delete(temporary_index)
      end
    end
  end
end
