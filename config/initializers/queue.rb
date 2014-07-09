QUEUE = MemCache.new('localhost:11211') unless defined?(QUEUE)
NEW_BLIP_QUEUE = YAML.load_file(File.join(RAILS_ROOT, 'config', 'queue.yml'))[RAILS_ENV]['blips'] unless defined?(NEW_BLIP_QUEUE)
APN_QUEUE = YAML.load_file(File.join(RAILS_ROOT, 'config', 'queue.yml'))[RAILS_ENV]['apns'] unless defined?(APN_QUEUE)