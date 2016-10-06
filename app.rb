require 'sinatra'
require 'json'
require 'sinatra/sequel'

# INDEX
get '/' do
  content_type :json
  #erb(:index)

  @objects = Objects.all(:order => :created_at.desc)

  @objects.to_json
end

# SHOW
get 'objects/:id' do
  content_type :json
  @object = Object.get(params[:id].to_i)

  if @object
    @object.to_json
  else
    halt 404
  end
end

# CREATE
post 'objects/' do
  content_type :json
  #erb(:show)

  @object = Object.new(params)

  if @object.save
    @object.to_json
  else
    halt 500
  end
end

# DELETE
delete '/objects/:id/delete' do
  content_type :json
  @object = Object.get(params[:id].to_i)

  if @object.destroy
    {:success => "ok"}.to_json
  else
    halt 500
  end
end
