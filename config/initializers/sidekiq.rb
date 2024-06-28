sidekiq_config = { url: "redis://#{ENV['REDIS_HOST']}:#{ENV['REDIS_PORT']}" }

Sidekiq.configure_server do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379') }
end
Sidekiq.configure_client do |config|
    config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379') }
end