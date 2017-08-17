CTAAggregatorClient.configure do |config|
  config.base_url = ENV['CTA_AGGREGATOR_HOST']
  config.api_version = ENV['CTA_AGGREGATOR_VERSION']
  config.api_key = ENV['CTA_AGGREGATOR_KEY']
  config.api_secret = ENV['CTA_AGGREGATOR_SECRET']
end
