# https://github.com/tobiassvn/sidetiq#readme - Configuration section
Sidetiq.configure do |config|
  # Thread priority of the clock thread (default: Thread.main.priority as
  # defined when Sidetiq is loaded).
  config.priority = 2

  # Clock tick resolution in seconds (default: 1).
  config.resolution = 0.5

  # Clock locking key expiration in ms (default: 1000).
  config.lock_expire = 100

  # When `true` uses UTC instead of local times (default: false)
  config.utc = true
end
