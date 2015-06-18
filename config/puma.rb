threads 1, 8
workers 2

root = Dir.pwd

preload_app!

rackup "#{root}/config.ru"
bind "unix://#{root}/tmp/sockets/puma.sock"
state_path "#{root}/tmp/pids/puma.state"
pidfile "#{root}/tmp/pids/puma.sock"

on_worker_boot do
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.establish_connection

  defined?(Redis) &&
    Redis.current = Redis.new(url: ENV['REDIS_URL'])
end

on_restart do
  defined?(ActiveRecord::Base) &&
    ActiveRecord::Base.connection.disconnect!

  defined?(Redis) &&
    Redis.current.quit
end
