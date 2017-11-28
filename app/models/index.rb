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
  attr_accessor :pri_store_size

  attr_accessor :persisted

  validates :name, presence: true
  validates :definition, presence: true
  validate :definition_should_be_valid_json

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

      if idx.has_key?('error')
        raise IndexNotFound.new(index_name, idx)
      end

      index_definition = idx.fetch(index_name)
      index_definition = fix_definition(index_definition)
      self.new(name: index_name, definition: JSON.pretty_generate(index_definition), persisted: true)
    end

    def find_by_name(index_name)
      idx = Rails.application.config.elasticsearch.index(index_name)

      if idx.has_key?('error')
        nil
      else
        self.new(name: index_name, definition: JSON.pretty_generate(idx.fetch(index_name)), persisted: true)
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

        if settings_index.dig('version', 'created')
          settings_index.fetch('version').delete('created')
        end
      end

      definition
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

    unless res.has_key?('error')
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
    res = Rails.application.config.elasticsearch.delete(self.name)

    if res.has_key?('error')
      return res
    end

    update_dataset!(nil)
    res
  end

  def update(index_params, dataset:)
    index_params.each do |key, value|
      self.send("#{key}=", value)
    end

    if self.save
      if dataset
        update_dataset!(dataset)
      else
        true
      end
    end
  end

  def save
    if self.valid?
      elasticsearch = Rails.application.config.elasticsearch

      if self.persisted?
        res = elasticsearch.delete(self.name)

        if res.has_key?('error')
          errors.add(:definition, " could not be deleted: #{res.inspect.truncate(256)}")
          return false
        end
      end

      res = elasticsearch.create(self.definition, index: self.name)

      if res.has_key?('error')
        Rails.logger.warn(res)
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

  private

  def definition_should_be_valid_json
    begin
      JSON.parse(self.definition)
    rescue JSON::ParserError => e
      errors.add(:definition, " is invalid JSON: #{e.message}")
    end
  end

  def update_dataset!(name)
    index_metadata = self.metadata

    if name
      index_metadata.dataset = Dataset.where(name: name).take
    else
      index_metadata.dataset = nil
    end

    index_metadata.save!
  end
end
