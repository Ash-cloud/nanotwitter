require './models/user'
require './models/tweet'
require './models/followee'

File.open("./db/follows.csv").readlines.each do |line|
  CSV.parse do |line|
    user_id, follower = line
    Follow.create(user_id: user_id, follower: follower)
    
  end
end

