# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_malaria_session',
  :secret      => '0c3e4579cd878c6feae5a225c5aea3711ff9b2e45bf0a60cda4f0a9423b0b1ff828bd085fbd385732ac3b668b6dfc7558e783d6486ef29c80f4597c9d93ff023'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
