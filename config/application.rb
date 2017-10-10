require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Dotenv.load(File.expand_path('/.env', __FILE__)) if File.exist?(File.expand_path('/.env', __FILE__))

module CtaScraper
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    config.generators do |g|
      g.javascript_engine :js
    end

    config.autoload_paths << Rails.root.join('lib')

    config.sass.preferred_syntax = :scss
  end
end
