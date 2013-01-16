# Be sure to restart your server when you modify this file.

# Add new mime types for use in respond_to blocks:
# Mime::Type.register "text/richtext", :rtf

# Initializers seem to be loaded multiple times in tests, so only define this 
# if it hasn't been defined yet.
Mime::Type.register_alias "text/html", :iphone unless defined?(Mime::IPHONE)
