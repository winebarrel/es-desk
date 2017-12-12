Rails.application.config.elasticsearch = Elasticsearch::Client.new(
  ENV.fetch('ELASTICSEARCH_ENDPOINT', '127.0.0.1:9200')
)
