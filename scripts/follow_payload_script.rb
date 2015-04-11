require 'json'
filename = '../db/follows.csv'
file = File.new(filename, 'r')
@value=[]
file.each_line("\n") do |row|
	columns = row.split(",")
	user_id=columns[0]
	follower=columns[1].chomp
	@value.push([user_id,follower])
end
@to_be_json={keys:["followee_id","follower_id"],values:@value}
File.write("./follow_payload",@to_be_json.to_json)
