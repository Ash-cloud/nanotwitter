require './models/user'
require_relative 'follow_server'


class User_Service

	def self.login(user_name,password)
		puts 'in login'
		user=User.find_by(user_name: user_name)
		if user #if that user exist, check the password
			if user.password==password
				return 'logged_in',user.id
			else
				return 'wrong password'
			end
		else
			return 'user not found'
		end
	end


	def self.Tweet_text(tweet)
		return tweet[0]
	end

	def self.Tweet_create_time(tweet)
		return tweet[1]
	end


	def self.timeline_tweets_smash(tweets_without_name) #smash tweets into text and created_at attributes for timeline
		text_array=[]
		created_time_array=[]
		tweets_without_name.map{|tweet| 
						text_array.push User_Service.Tweet_text(tweet)
						created_time_array.push  Tweet_Service.create_time_interval(User_Service.Tweet_create_time(tweet))
		}
		return created_time_array,text_array
	end

	def self.timeline(user_id)
		user=User.find_by(id: user_id)
		if user
			tweets_without_name= user.tweets.order(created_at: "DESC").pluck(:text,:created_at)
			array_length=tweets_without_name.length
			user_name_array=Array.new(array_length,user.user_name)
			text_array,created_time_array=User_Service.timeline_tweets_smash(tweets_without_name)
			return user_name_array,text_array,created_time_array
		else
			return 'user not found'
		end
	end


	def self.get_email_by_id(user_id)
		@user = User.find_by(id: user_id)
		email = @user.email
	end

	def self.register(user_name,password,email)
		email_found = User.find_by(email: email)
		name_found = User.find_by(user_name: user_name)
		if email_found
			return 'email taken'
		elsif name_found
			return 'user_name taken'
		else
			User.create(user_name: user_name,password: password, email: email)
			return 'ok'
		end
	end

	def self.getUserByID(user_id)
		user = User.find_by(id: user_id)
		if user
			return user
		else
			return nil
		end
	end
    #now this method generates 10 recommendations at random (of users not yet followed)
	
	def self.get_users_to_follow() 
	    candidates = User.limit(10).order("RANDOM()")
	end
	    
end
