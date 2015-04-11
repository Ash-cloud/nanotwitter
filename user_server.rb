require './models/user'
require_relative 'follow_server'

class User_Service

	def self.login(user_name,password)
		puts 'in login'
		@user=User.find_by(user_name: user_name)
		if @user #if that user exist, check the password
			if @user.password==password
				return 'logged_in'
			else
				return 'wrong password'
			end
		else
			return 'user not found'
		end
	end


	def self.timeline(user_id)
		@user=User.find_by(id: user_id)
		if @user
			return @user.tweets.order(created_at: "DESC")

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
	def self.get_users_to_follow(user_id)
	    #pull out ten random users to suggest be followed
	    candidates = User.limit(10).order("RANDOM()")
	end
	    
end
