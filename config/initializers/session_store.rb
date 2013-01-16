# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_ListableAppWeb_session',
  :secret      => '401b713c594c68795a070935fe6bd5730241d270b8b59dd3a21651d5407f9ed99381f98d4e6e6ca5352f1d410fdac0f39fd6d8a39c41805208d3d39dccd92e73'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
