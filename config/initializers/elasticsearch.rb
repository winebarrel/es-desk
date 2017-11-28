Rails.application.config.elasticsearch = Elasticsearch::Client.new(
  ENV.fetch('ELASTICSEARCH_ENDPOINT', 'localhost:9200')
)
