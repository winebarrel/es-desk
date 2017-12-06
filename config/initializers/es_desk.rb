Rails.application.config.es_desk = {}

Rails.application.config.es_desk.tap do |es_desk|
  es_desk[:header_links] = {}

  if ENV['HEADER_LINSK']
    ENV['HEADER_LINSK'].split(',').each do |link|
      label, url = link.split(':', 2)
      es_desk[:header_links][label] = url
    end
  end
end
