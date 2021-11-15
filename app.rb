require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'json'

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

  data = JSON.dump({
    "id": @id,
    "title": @title,
    "content": @content,
    "registered_at": @registered_at
  })

  redirect to("/index")
end