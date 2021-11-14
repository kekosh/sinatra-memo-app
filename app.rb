require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'

get '/index' do
  erb :index
end

get '/new' do
  erb :new
end

post '/regist' do
  @title = params['input_title']
  @content = params['input_content']
  @id = SecureRandom.uuid
  @registered_at = Time.now.strftime("%Y%m%d%T")

  p @registered_at

  redirect to("/index")
end