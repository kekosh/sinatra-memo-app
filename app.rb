# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'json'
require 'Rack'

configure do
  enable :method_override
end

helpers do
  def read_data
    File.open('data.json', 'r') do |f|
      JSON.parse(f.read)
    end
  end

  def save_data(array_data)
    File.open('data.json', 'w') { |file| JSON.dump(array_data, file) }
  end

  def escape_html(str)
    Rack::Utils.escape_html(str)
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
    next if data['id'] != params['id']

    @id = data['id']
    @title = data['title']
    @content = data['content']
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
  save_data(@data_list)
  redirect to('/index')
end

delete '/delete/:id' do
  @data_list = read_data
  @data_list.each_with_index do |data, idx|
    next if data['id'] != params['id']

    @data_list.delete_at idx
  end

  save_data(@data_list)
  redirect to('/index')
end
