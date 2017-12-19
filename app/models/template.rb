class Template
  PREVIEW_LEN = 128

  class TemplateNotFound < StandardError
    attr_accessor :error, :status

    def initialize(template_name, error_response = nil)
      msg = "Couldn't find Template with 'template'=#{template_name}"

      if error_response
        self.error = error_response.fetch('error')
        self.status = error_response.fetch('status')
        msg << ": #{error_response.inspect}"
      end

      super(msg)
    end
  end

  include ActiveModel::Model

  attr_accessor :name
  attr_accessor :definition

  attr_accessor :persisted

  TEMPLATE_NAME_FORMAT = /\A[-\w]+\z/
  validates :name, presence: true, format: { with: TEMPLATE_NAME_FORMAT }
  validates :definition, presence: true
  validate :definition_should_be_valid_json
  validate :definition_should_be_valid

  class << self
    def all
      templates = Rails.application.config.elasticsearch.templates
      templates = templates.sort_by {|k, _| k }

      templates.map do |k, v|
        self.new(name: k, definition: JSON.pretty_generate(v), persisted: true)
      end
    end

    def find(template_name)
      tmpl = Rails.application.config.elasticsearch.template(template_name)

      if Elasticsearch::Client.has_error?(tmpl)
        raise TemplateNotFound.new(template_name, tmpl)
      end

      _, template_definition = tmpl.first

      unless template_definition
        raise TemplateNotFound.new(template_name)
      end

      template_definition = fix_definition(template_definition)
      self.new(name: template_name, definition: JSON.pretty_generate(template_definition), persisted: true)
    end

    def find_by_name(template_name)
      tmpl = Rails.application.config.elasticsearch.template(template_name)

      if Elasticsearch::Client.has_error?(tmpl)
        return nil
      end

      _, template_definition = tmpl.first

      unless template_definition
        return nil
      end

      self.new(name: template_name, definition: JSON.pretty_generate(template_definition), persisted: true)
    end

    # XXX:
    def fix_definition(definition)
      definition
    end
  end # of class methods

  def id
    self.name
  end

  def persisted?
    self.persisted
  end

  def destroy
    Rails.application.config.elasticsearch.delete_template(self.name)
  end

  def update(template_params)
    template_params.each do |key, value|
      self.send("#{key}=", value)
    end

    self.save
  end

  def save
    if self.valid?
      res = Rails.application.config.elasticsearch.create_template(self.definition, template: self.name)

      if Elasticsearch::Client.has_error?(res)
        errors.add(:definition, " could not be created: #{res.inspect.truncate(256)}")
        return false
      end

      true
    end
  end

  def preview
    self.definition.truncate(PREVIEW_LEN)
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
    if self.name =~ TEMPLATE_NAME_FORMAT
      elasticsearch = Rails.application.config.elasticsearch
      temporary_template = self.name + '-' + SecureRandom.hex

      begin
        res = elasticsearch.create_template(self.definition, template: temporary_template)

        if Elasticsearch::Client.has_error?(res)
          errors.add(:definition, " is invalid: #{res.inspect.truncate(1024)}")
        end
      ensure
        elasticsearch.delete_template(temporary_template)
      end
    end
  end
end
