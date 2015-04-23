Nano Twitter V0.1 Modification Log

-Basic DB design

-Environment setup

Nano Twitter V0.2 Modification Log

- Sinatra basic version

Nano Twitter V0.3 Modification Log

- Function completed

Nano Twitter V0.4 Modification Log

- Modified the database 
	1.Add creator_id column on Tweet_User table to improve unfollow and follow performance.
	2.Set the password field to be "not null".

- Completed follow and unfollow function:
	1.Insert at most 100 tweets to new followers’ timeline.
	2.Delete all tweet from user’s timeline when User unfollow a followee.

- Add index on several columns to improve performance

- Add some script to generate payload file for load.io to send different request when doing test

- Improved the API performance by removing .all.
	- Rewrite order_by(“created_at desc”), adding table names as parameters like ordered_by(“tweets.created_at desc”) to avoid ambiguity exception when join the generated relation with other table.
	- Solved N+1 problems in erb for generating my page, logged_in_root page,unlogged_in_root page


- Describe time in words.
	0 <-> 29 secs                                                             # => 		less than a minute
	30 secs <-> 1 min, 29 secs                                                # => 1 minute
	1 min, 30 secs <-> 44 mins, 29 secs                                       # => [2..44] minutes
	44 mins, 30 secs <-> 89 mins, 29 secs                                     # => about 1 hour
	89 mins, 30 secs <-> 23 hrs, 59 mins, 29 secs                             # => about [2..24] hours
	23 hrs, 59 mins, 30 secs <-> 41 hrs, 59 mins, 29 secs                     # => 1 day
	41 hrs, 59 mins, 30 secs  <-> 29 days, 23 hrs, 59 mins, 29 secs           # => [2..29] days
	29 days, 23 hrs, 59 mins, 30 secs <-> 44 days, 23 hrs, 59 mins, 29 secs   # => about 1 month
	44 days, 23 hrs, 59 mins, 30 secs <-> 59 days, 23 hrs, 59 mins, 29 secs   # => about 2 months
	59 days, 23 hrs, 59 mins, 30 secs <-> 1 yr minus 1 sec                    # => [2..12] months
	1 yr <-> 1 yr, 3 months                                                   # => about 1 year
	1 yr, 3 months <-> 1 yr, 9 months                                         # => over 1 year
	1 yr, 9 months <-> 2 yr minus 1 sec                                       # => almost 2 years
	2 yrs <-> max time or date                                                # => (same rules as 1 yr)

- Revise bugs
	Bug description: 
		- Click on tweet box, there will have default indention and the light gray string “post tweet here” could not be shown appropriately. 
- Modified test to support new API interface
 	- The output of API Tweet_Service.getRecentTweets is changed from a activeRelation to ruby array with 4 attribute standing for user_name,user_id,text,time in word.
	- The output of API Tweet_Service.get_stream is array now
	- Add function to split the tweet array into 4 arrays of attributes.
	- Modify User_Service.Timeline method to generate new formate tweets.

- Using template in erb

-Add layout file, showing header and footer

-Moved profile button to navigator in my page

-Abandon the TweetUser table



Nano Twitter V0.5 Modification Log

-Array of 100 most recent tweets stored in Redis in JSON

-When a new tweet is made, the array is taken out of Redis, updated, and put back in Redis as JSON
-Implemented Redis for Logged in Root timelines 
	- add to Redis after first get. When user goes to Logged in root, the redis is checked to see if their timeline is being stored there.  
	- If so, get the timeline out of redis and avoid database calls
	- If the timeline is not in redis, get it from the database and put it into redis When a tweet is posted, go through the tweeter’s followers and get their timelines out of redis, update them with the new tweet, and put them back in redis.  
	- If a follower’s timeline is not in redis, get their timeline using database calls and put it into redis.

- Implemented Bootstrap for all pages

- Improved visuals for nanotwitter

- Profile pictures generated each time a profile page is called
- Tweets appear in boxes with name and time







Future Implementations

Enable Search function in navigation bar.
Enable Who you Follow, Who follows you features on loggedin root page
More experiments with Redis with larger Redis Cloud
Allow for Password Updates
Increase Password strength
Allow Users to load profile image
Implement Mentions and Hashtag features
Filter Follow Recommendations to users not followed

