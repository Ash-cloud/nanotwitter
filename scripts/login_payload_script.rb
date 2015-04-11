require 'csv'
require 'json'
file = File.new("../db/users.csv")
password = "1234"
@value=[]
file.each_line("\n") do |row|
    columns = row.split(",")
    user_name = columns[1].chomp
    @value.push([user_name,password])    
end
@to_be_json={keys:["user_name","password"],values:@value}
File.write("./payload",@to_be_json.to_json)
