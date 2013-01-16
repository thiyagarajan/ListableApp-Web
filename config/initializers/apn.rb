# Load the Apple Push Notification configuration for this env.

unless defined?(APN_CONFIG)
  APN_CONFIG = YAML.load_file(File.join(RAILS_ROOT, 'config', 'apn.yml'))[RAILS_ENV]
end
