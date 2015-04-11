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