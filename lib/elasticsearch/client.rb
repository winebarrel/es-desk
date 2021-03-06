module Elasticsearch
  class Client
    class << self
      def logger=(v)
        @logger = v
      end

      def has_error?(res)
        has_e = res.has_key?('error') || !!res['errors']

        if has_e
          if res.has_key?('items')
            res.fetch('items').reject! {|i| i.dig('index', 'status') == 201 }
          end

          @logger.debug(res) if @logger
        end

        has_e
      end
    end # of class methods

    def initialize(endpoint)
      @endpoint = endpoint
    end

    def indices
      curl = build_curl('_cat/indices?format=json')
      curl.http_get
      JSON.parse(curl.body_str)
    end

    def index(name)
      curl = build_curl(URI.escape(name))
      curl.http_get
      JSON.parse(curl.body_str)
    end

    def stats(name)
      curl = build_curl("#{URI.escape(name)}/_stats")
      curl.http_get
      JSON.parse(curl.body_str)
    end

    def bulk(data, index:, type:)
      curl = build_curl("#{URI.escape(index)}/#{URI.escape(type)}/_bulk", 'Content-Type' => 'application/x-ndjson')
      curl.post_body = data
      curl.http_post
      JSON.parse(curl.body_str)
    end

    def create(definition, index:)
      curl = build_curl(URI.escape(index), 'Content-Type' => 'application/json')
      curl.http_put(definition)
      JSON.parse(curl.body_str)
    end

    def delete(name)
      curl = build_curl(URI.escape(name))
      curl.http_delete
      JSON.parse(curl.body_str)
    end

    def search(name, query:)
      curl = build_curl("#{URI.escape(name)}/_search", 'Content-Type' => 'application/json')
      curl.post_body = query
      # Is this okay?
      curl.http_post
      JSON.parse(curl.body_str)
    end

    def analyze(index: nil, query:)
      path = index ? "#{URI.escape(index)}/" : ''
      path << '_analyze'
      curl = build_curl(path, 'Content-Type' => 'application/json')
      curl.post_body = query
      # Is this okay?
      curl.http_post
      JSON.parse(curl.body_str)
    end

    def templates
      curl = build_curl('_template')
      curl.http_get
      JSON.parse(curl.body_str)
    end

    def template(name)
      curl = build_curl("_template/#{URI.escape(name)}")
      curl.http_get
      JSON.parse(curl.body_str)
    end

    def create_template(definition, template:)
      curl = build_curl("_template/#{URI.escape(template)}", 'Content-Type' => 'application/json')
      curl.post_body = definition
      # Is this okay?
      curl.http_post
      JSON.parse(curl.body_str)
    end

    def delete_template(name)
      curl = build_curl("_template/#{URI.escape(name)}")
      curl.http_delete
      JSON.parse(curl.body_str)
    end

    private

    def build_curl(path, headers = {})
      url = File.join(@endpoint, path)
      curl = Curl::Easy.new(url)

      headers.each do |name, value|
        curl.headers[name] = value
      end

      curl
    end
  end
end
