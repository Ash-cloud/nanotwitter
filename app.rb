require 'sinatra'
require './app'
require 'sinatra/activerecord'
require './models/tweet'
require './models/user'
require './models/tweet_user'

get '/' do
	erb :welcome
end


get '/loggedin_root' do
	erb :loggedin_root
end

get '/tweet' do
end

get '/login' do
	erb :login
end

get '/register' do
	erb :register
end

get '/user/jf' do
	erb :loggedin_userpage
end
