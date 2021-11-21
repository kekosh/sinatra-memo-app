# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'json'

helpers do
  def read_data(file)
    File.open(file, 'r') do |f|
      JSON.parse(f.read)
    end
  end
end

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
  @registered_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  new_data = {
    "id": @id,
    "title": @title,
    "content": @content,
    "registered_at": @registered_at
  }

  begin
    @data_list = read_data('data.json')
  rescue JSON::ParserError
    @data_list = []
  end

  @data_list.push(new_data)
  File.open('data.json', 'w') { |file| JSON.dump(@data_list, file) }

  redirect to('/index')
end
