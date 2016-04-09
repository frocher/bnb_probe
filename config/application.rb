require File.expand_path('../boot', __FILE__)

require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "rails/test_unit/railtie"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module BnbProbe
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Chrome is the default browser but firefox can be defined
    config.browser = Figaro.env.PROBE_BROWSER || 'chrome'

    # You can define a token to restrict access to the probe
    # If probe token is nil, no access restriction is applied
    # If token is defined, the token must be passed as a 'token' parameter
    config.probe_token = Figaro.env.PROBE_TOKEN
  end
end
