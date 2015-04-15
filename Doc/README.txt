Nano Twitter V0.1 Modification Log
Nano Twitter V0.2 Modification Log
Nano Twitter V0.3 Modification Log
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