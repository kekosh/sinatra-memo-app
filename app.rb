# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'securerandom'
require 'json'
require 'Rack'
require 'pg'

configure do
  enable :method_override
end

not_found do
  erb :notfound
end

# Database Process
class Database
  def db_connect
    PG.connect(dbname: 'memodb')
  end

  def select_memo_titles
    data_list = []
    w_sql = 'SELECT id, title FROM memos ORDER BY registered_at'
    db_connect.exec(w_sql) do |result|
      result.each do |record|
        data_list.push(record)
      end
    end
    data_list
  end

  def insert_new_memo(id, title, content, registered_at)
    w_sql = 'INSERT INTO memos VALUES ($1, $2, $3, $4)'
    db_connect.exec(w_sql, [id, title, content, registered_at])
  end

  def select_memo(id)
    w_sql = 'SELECT id, title, contents FROM memos WHERE id = $1'
    db_connect.exec(w_sql, [id])
  end

  def delete_memo(id)
    w_sql = 'DELETE FROM memos WHERE id = $1'
    db_connect.exec(w_sql, [id])
  end
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
  database = Database.new
  @data_list = database.select_memo_titles
  erb :index
end

get '/memos/new' do
  erb :new
end

post '/memos' do
  database = Database.new
  id = SecureRandom.uuid
  title = params['input_title']
  content = params['input_content']
  registered_at = Time.now.strftime('%Y-%m-%d %H:%M:%S')
  database.insert_new_memo(id, title, content, registered_at)
  redirect to('/memos')
end

get '/memos/:id' do
  database = Database.new
  memo = database.select_memo(params['id'])

  if memo.none?
    erb :notfound
  else
    memo.each { |record| @memo = record }
    erb :detail
  end
end

delete '/memos/:id' do
  database = Database.new
  database.delete_memo(params['id'])
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
