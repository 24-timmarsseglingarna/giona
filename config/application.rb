require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

Warning[:deprecated] = true

module Giona
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over
    # those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
    config.time_zone = 'Europe/Stockholm'
    config.active_record.time_zone_aware_types = [:datetime]
    config.i18n.default_locale = :sv
    config.web_logbook_url = 'https://app.24-timmars.nu/web'
    # ios sends origin: null
    config.action_controller.forgery_protection_origin_check = false
    config.middleware.insert_before 0, Rack::Cors, :debug => true,
                                    :logger => Rails.logger do #TODO tighten up
      allow do
        origins '*'
        resource '*',
        :headers => :any,
        :expose  => ['access-token', 'etag', 'expiry',
                     'token-type', 'uid', 'client'],
        :methods => [:get, :post, :options, :delete, :put, :patch]
      end
    end

  end
end
