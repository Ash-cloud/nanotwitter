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
	    #get all the users who aren't you
		@other_users = User.where.not(id: user_id)
		puts("number of other users is #{@other_users.size}")
		#get all the people you follow
		@followees = Follow_Service.followers(user_id)
		
		@recommended = []
		num_recommendations = 0;
		while num_recommendations < 11 #want to get 10 random recommendations
		    index = Random.rand(@other_users.size)
		    potential_recommendation = @other_users[index]
		    followed = false
			@followees.each do |followee|
			    #if other_user is a followee of you, followed is true
				if potential_recommendation.id == followee.user_id
					followed = true
				end
				#if potential_recommendation is already in recommendations, followed is true
				@recommended.each do |rec|
				    if potential_recommendation.id == rec.id
				        followed = true
				    end
			    end
			end	
			#if you don't follow other_user yet, push to recommended
			if followed == false  
			    @recommended.push(potential_recommendation)
			    num_recommendations += 1
			end				
		end
		return @recommended
	end

end
