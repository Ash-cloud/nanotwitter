ENV['SINATRA_ENV'] = 'test'
require_relative '../app.rb'

describe "server" do 
    #first 3 tests are for login method
    it "should login with correct name and password" do
        User.create(user_name:'alf',password:'123',email:'alf@brandeis')
        status = Service.login('alf','123')
        status.should == 'logged_in'
    end
    
    it "should not login with incorrect password" do
        status = Service.login('alf','wrongpass')
        status.should == 'wrong password'
    end
    
    it "should not login if user isn't found" do
        status = Service.login('henry', '123')
        status.should == 'user not found'
    end
    #need timeline test(s)
    #need followers test(s)
    
    #next test is for get_email_by_id
    it "should get user's email when given their id" do
        email = Service.get_email_by_id(User.find_by(user_name: 'alf').id)
        email.should == 'alf@brandeis'
    end
    #next 3 tests are for register method
    it "should register a new user with unique name and password" do
        response = Service.register('zordon','9876','zordon@email')
        response.should == 'ok'
    end
    it "should not register with a name that's already taken" do
        response = Service.register('alf','123','gordon@melmac.com')
        response.should == 'user_name taken'
    end
    it "should not register with an email that's already taken" do
        response = Service.register('alison','555','alf@brandeis')
        response.should == 'email taken'
    end  
     
    #need tests for getTweetsByID
    
    #need tests for getUserByID
    
    #need tests for getRecentTweets
    
    #test for post_tweet
    it "should let user post a tweet" do
        tweet_content = 'this is my first tweet!'
        user_id = User.find_by(user_name: 'alf').id
        tweet = Service.post_tweet(tweet_content, user_id)
        tweet_text = tweet.text
        tweet_text.should == 'this is my first tweet!'
    end
    
    #test for post_tweet_user
    it "should create an entry in Tweet_Users linking user_id and tweet_id" do
        user_id = User.find_by(user_name: 'zordon').id
        tweet = Service.post_tweet('hi, it is me, zordon', user_id)
        tweet_id = tweet.id
        tweet_user = Service.post_tweet_user(user_id, tweet_id)
        tweet_user.user_id.should == User.find_by(user_name: 'zordon').id
        tweet_user.tweet.id.should == tweet_id
    end
    #test follow --- this test is failing, I don't know why
    it "should create a follow relationship between 2 users" do
        followee_id = User.find_by(user_name: 'alf').id
        follower_id = User.find_by(user_name: 'zordon').id
        Service.follow(follower_id, followee_id)
        Follow.where(user_id: followee_id, follower: follower_id).should_not == nil
    end  
    
    #need test for unfollow
    
    #need test for get_followers
    
    #need tests for get_stream      
           
end
