require './models/user'
require './models/tweet'
5.times do |i|
	User.create(user_name: "User ##{i}", email: "#{i}@mail.com")
	Tweet.create(text: "hello #{i}", user_id: '#{i}')
end

