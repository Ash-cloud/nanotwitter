require './models/followee'

class Follow_Service

	def self.followers(user_id)
		users_followed = Follow.where(follower: user_id)
		if users_followed
			return users_followed
		else
			return nil
		end
	end


	def self.follow(follower_id, followee_id)
		Follow.create(user_id: followee_id, follower: follower_id)
	end

	def self.unfollow(follower_id, followee_id)
		follow = Follow.find_by(user_id: followee_id, follower: follower_id)
		Follow.delete(follow)
	end

	def self.get_followers(user_id)

		@followers = Follow.where(user_id: user_id)

		return @followers
	end

	def self.followed?(followee_id,follower_id)
		puts 'followee',followee_id,'follower',follower_id
		#followed_record=Follow.where(user_id:followee_id).find_by(follower: follower_id)
		followed_record = Follow.find_by(user_id:followee_id, follower: follower_id)
		if followed_record
			return true
		else
			return false
		end
	end
	
end
