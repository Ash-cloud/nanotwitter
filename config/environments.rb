#The environment variable DATABASE_URL should be in the following format:
# => postgres://{user}:{password}@{host}:{port}/path
configure :production do
	db = URI.parse(ENV['DATABASE_URL'] || 'postgres://localhost/development')
    ActiveRecord::Base.clear_active_connections!
	ActiveRecord::Base.establish_connection(
			:adapter => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
			:host     => db.host,
			:username => db.user,
			:password => db.password,
			:database => db.path[1..-1],
			:encoding => 'utf8',
			:pool => 15
	)
end


