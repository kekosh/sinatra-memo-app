# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'json'
require 'Rack'

configure do
  enable :method_override
end

not_found do
  erb :notfound
end

helpers do
  def read_data
    File.open('data.json', 'r') do |f|
      file_data = f.read

      [] if file_data.size.zero?
      begin
        JSON.parse(file_data)
      rescue JSON::ParserError
        []
      end
    end
  end

  def save_data(array_data)
    File.open('data.json', 'w') { |file| JSON.dump(array_data, file) }
  end

  def escape_html(str)
    Rack::Utils.escape_html(str)
  end
end

get '/' do
  redirect to('/memo/index')
end

get '/memo' do
  redirect to('/memo/index')
end

get '/memo/index' do
  @data_list = read_data
  erb :index
end

get '/memo/new' do
  erb :new
end

get '/memo/:id/detail' do
  read_data.each do |data|
    next if data['id'] != params['id']

    @id = data['id']
    @title = data['title']
    @content = data['content']
  end

  erb :detail
end

post '/memo/regist' do
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
  redirect to('/memo/index')
end

delete '/memo/:id/delete' do
  @data_list = read_data
  @data_list.each_with_index do |data, idx|
    next if data['id'] != params['id']

    @data_list.delete_at idx
  end

  save_data(@data_list)
  redirect to('/memo/index')
end

get '/memo/:id/edit' do
  @data_list = read_data
  @data = @data_list.find { |data| data['id'] == params['id'] }

  @id = params['id']
  @title = @data['title']
  @content = @data['content']

  erb :edit
end

patch '/memo/:id/edit' do
  @data_list = read_data
  @data_list.each do |data|
    next if data['id'] != params['id']

    data['title'] = params['edit_title']
    data['content'] = params['edit_content']
    data['registered_at'] = Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

  save_data(@data_list)
  redirect to('/memo/index')
end
