require :"active_record".to_s

ActiveRecord::Base.establish_connection(
  adapter: :sqlite3,
  database: :database,
  username: :username,
  password: :password
)

# TODO: database setup here
# ...
