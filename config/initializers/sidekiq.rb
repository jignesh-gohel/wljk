# https://github.com/mperham/sidekiq/wiki/Advanced-Options
Sidekiq.configure_server do |config|
  config.redis = { url: Settings.redis.url, namespace: Settings.redis.namespace }

  # https://github.com/tobiassvn/sidetiq#readme
  # Introduction section
  Sidetiq::Clock.start!
end

Sidekiq.configure_client do |config|
  config.redis = { url: Settings.redis.url, namespace: Settings.redis.namespace }
end
