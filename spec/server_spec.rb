require_relative '../app.rb'

describe "server" do 
    before(:all) do
        #setting up the environment for testing
        env='test'
        databases = YAML.load_file("config/database.yml")
	puts env     
        ActiveRecord::Base.establish_connection(databases[env])
        #if environment is test then delete everything in the test database
        #so the tests will run anew
  
        if env == "test"
            puts "starting in test mode" 
            User.delete_all 
            Follow.delete_all
            Tweet.delete_all
            #TweetUser.delete_all 
        end
    end
    #first 3 tests are for login method
    it "should login with correct name and password" do
        User.create(user_name:'alf',password:'123',email:'alf@brandeis')
        status = User_Service.login('alf','123')
        status[0].should == 'logged_in'
    end
    
    it "should not login with incorrect password" do
        status = User_Service.login('alf','wrongpass')
        status.should == 'wrong password'
    end
    
    it "should not login if user isn't found" do
        status = User_Service.login('henry', '123')
        status.should == 'user not found'
    end
    #need timeline test(s)
    #need followers test(s)
    
    #next test is for get_email_by_id
    it "should get user's email when given their id" do
        email = User_Service.get_email_by_id(User.find_by(user_name: 'alf').id)
        email.should == 'alf@brandeis'
    end
    #next 3 tests are for register method
    it "should register a new user with unique name and password" do
        response = User_Service.register('zordon','9876','zordon@email')
        response.should == 'ok'
    end
    it "should not register with a name that's already taken" do
        response = User_Service.register('alf','123','gordon@melmac.com')
        puts response
        response.should == 'user_name taken'
    end
    it "should not register with an email that's already taken" do
        response = User_Service.register('alison','555','alf@brandeis')
        response.should == 'email taken'
    end  
     
    #tests for getTweetsByID
    it "should return tweet of some tweet_ID" do
        User.create(user_name:'songruoyun',password:'11111',email:'haha@brandeis')
        user_id = User.find_by(user_name: 'songruoyun').id
        Tweet.create(text: "the cake is very delicious",user_id: user_id)
        tweet_id = Tweet.find_by(user_id: user_id).id
        response = Tweet_Service.getTweetsByID(tweet_id)
        response.text.should == "the cake is very delicious"
    end
    
    
    #tests for getUserByID
    it "should return the user of certain user id" do
        user_id = User.find_by(user_name: 'songruoyun').id
        response = User_Service.getUserByID(user_id)
        response.user_name.should == "songruoyun"
        response.email.should == "haha@brandeis"
        response.password.should == "11111"
    end
    
    #tests for getRecentTweets-- changed the test slightly b/co getRecentTweets
    #was altered to return 100 most recent tweets instead of taking in a number
    it "should return most recent tweets for this test case " do
        response = Tweet_Service.getRecentTweets()
        Tweet_Service.Tweet_text(response[0]) == "the cake is very delicious"
        
    end
    
    #test for post_tweet
    it "should let user post a tweet" do
        tweet_content = 'this is my first tweet!'
        user_id = User.find_by(user_name: 'alf').id
        tweet = Tweet_Service.post_tweet(tweet_content, user_id)
        tweet_text = tweet.text
        tweet_text.should == 'this is my first tweet!'
    end
    
    #test for post_tweet_user
    #it "should create an entry in Tweet_Users linking user_id and tweet_id" do
       # user_id = User.find_by(user_name: 'zordon').id
        #tweet = Tweet_Service.post_tweet('hi, it is me, zordon', user_id)
        #tweet_id = tweet.id
        #tweet_user = TweetUser_Service.post_tweet_user(user_id, tweet_id, user_id)
        #tweet_user.user_id.should == User.find_by(user_name: 'zordon').id
        #tweet_user.tweet.id.should == tweet_id
    #end
    #test follow --- it's passing now
    it "should create a follow relationship between 2 users" do
        followee_id = User.find_by(user_name: 'alf').id
        follower_id = User.find_by(user_name: 'zordon').id
        Follow_Service.follow(follower_id, followee_id)
        Follow.where(user_id: followee_id, follower: follower_id).should_not == nil
    end  
    #need test for get_followers
    it "should return all the followers of a given user by user_id" do
        #I'll create another follower for alf, so he'll have 2 followers
        #zordon and songruoyun
        followee_id = User.find_by(user_name: 'alf').id
        follower_id = User.find_by(user_name: 'songruoyun').id
        Follow.create(user_id: followee_id, follower: follower_id)
        #now test if get_followers on 'alf' returns zordon and songruoyun
        followers = Follow_Service.get_followers(followee_id)
        zordon_id = User.find_by(user_name: 'zordon').id
        first_follow = Follow.find_by(user_id: followee_id, follower: zordon_id)
        second_follow = Follow.find_by(user_id: followee_id, follower: follower_id)
        followers.first.should == first_follow
        followers.second.should == second_follow   
    end
    #test for unfollow
    it "should have a user unfollow another user" do
        followee_id = User.find_by(user_name: 'alf').id
        follower_id = User.find_by(user_name: 'zordon').id
        Follow_Service.unfollow(follower_id, followee_id)
        Follow.where(user_id: followee_id, follower: follower_id).blank?().should == true #should no longer be a relation between these two users
    end
    
   
    
    #need tests for get_stream      
           
end
