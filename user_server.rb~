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

	def self.get_users_to_follow(user_id)
	    #get all the users who aren't you
		@other_users = User.where.not(id: user_id)
		puts("number of other users is #{@other_users.size}")
		#get all the people you follow
		@followees = Follow_Service.followers(user_id)
		
		@recommended = []
		
		@other_users.each do |other_user|
		    followed = false
			@followees.each do |followee|
			    #if other_user is a followee of you, followed is true
				if other_user.id == followee.user_id
					followed = true
				end
			end	
			#if you don't follow other_user yet, push to recommended
			if followed == false  
			    @recommended.push(other_user)
			end				
		end
		return @recommended
	end

end