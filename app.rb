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
  redirect to('/memos')
end

get '/memos' do
  @data_list = read_data
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  new_data = {
    "id": SecureRandom.uuid,
    "title": params['input_title'],
    "content": params['input_content'],
    "registered_at": Time.now.strftime('%Y-%m-%d %H:%M:%S')
  }

  data_list = read_data
  data_list.push(new_data)
  save_data(data_list)
  redirect to('/memos')
end

get '/memos/:id' do
  @memo = read_data.find { |record| record['id'] == params['id'] }

  if @memo.nil?
    erb :notfound
  else
    erb :detail
  end
end

delete '/memos/:id' do
  data_list = read_data
  data_list.delete_at(data_list.find_index { |record| record['id'] == params['id'] })

  save_data(data_list)
  redirect to('/memos')
end

get '/memos/:id/edit' do
  @memo = read_data.find { |record| record['id'] == params['id'] }

  erb :edit
end

patch '/memos/:id' do
  data_list = read_data
  target_index = data_list.find_index { |record| record['id'] == params['id'] }
  change_data = data_list[target_index]
  change_data['title'] = params['edit_title']
  change_data['content'] = params['edit_content']
  change_data['registerd_at'] = Time.now.strftime('%Y-%m-%d %H:%M:%S')

  save_data(data_list)
  redirect to('/memos')
end
