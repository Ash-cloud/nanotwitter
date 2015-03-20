require 'typhoeus'
require 'json'


class Client

	class << self; attr_accessor :base_uri end

	Client.base_uri = "http://localhost:4567"

	def self.login(user_name,password)
		response = Typhoeus::Request.get(
			"#{base_uri}/api/v1/user/login?user_name="+user_name.to_s+'&password='+password.to_s)

		if response.code == 200
			true
		elsif response.code == 403
			nil
		else
			raise response.body
		end
	end

	def self.post_tweet(tweet_content)

		response = Typhoeus::Request.post(
			"#{base_uri}/api/v1/tweet?tweet_content="+tweet_content.to_s)

		if response.code == 200
			JSON.parse(response.body)
		elsif response.code == 404
			nil
		else
			raise response.body
		end


	end




end
