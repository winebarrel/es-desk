module Elasticsearch
  class Client
    def initialize(endpoint)
      @endpoint = endpoint
    end

    def indices
      curl = build_curl('_cat/indices?format=json')
      curl.http_get
      JSON.parse(curl.body_str)
    end

    def index(name)
      curl = build_curl(name)
      curl.http_get
      JSON.parse(curl.body_str)
    end

    def bulk(data, index:, type:)
      curl = build_curl("#{index}/#{type}/_bulk", 'Content-Type' => 'application/x-ndjson')
      curl.post_body = data
      curl.http_post
      JSON.parse(curl.body_str)
    end

    def create(definition, index:)
      curl = build_curl(index)
      curl.http_put(definition)
      JSON.parse(curl.body_str)
    end

    def delete(name)
      curl = build_curl(name)
      curl.http_delete
      JSON.parse(curl.body_str)
    end

    def search(name, query:)
      curl = build_curl("#{name}/_search")
      curl.post_body = query
      curl.http_get
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
