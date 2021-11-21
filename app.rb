# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'json'

helpers do
  def read_data
    File.open('data.json', 'r') do |f|
      JSON.parse(f.read)
    end
  end
end

get '/index' do
  @data_list = read_data
  erb :index
end

get '/new' do
  erb :new
end

get '/detail/:id' do

  read_data.each do |data|
    if data['id'] == params['id']
      @id = data['id']
      @title = data['title']
      @content = data['content']
    end
  end

  erb :detail

end

post '/regist' do
  @title = params['input_title']
  @content = params['input_content']
  @id = SecureRandom.uuid
  @registered_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  new_data = {
    "id": @id,
    "title": @title,
    "content": @content,
    "registered_at": @registered_at
  }

  begin
    @data_list = read_data
  rescue JSON::ParserError
    @data_list = []
  end

  @data_list.push(new_data)
  File.open('data.json', 'w') { |file| JSON.dump(@data_list, file) }

  redirect to('/index')
end
