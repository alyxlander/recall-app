require 'sinatra'
require 'data_mapper'
#------------------------------------------------------------------------------#
# Sets up a new SQLite3 database for recall
DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/recall.db")

# Datamapper creates a table Notes
# class note has 5 fields:
#1. 'id' - a int primary key that auto-increments
#2. 'content' - containts the text, which if true means that text has been entered
#3. 'complete' - if note is completed then true
#4. 'created_at' - time when note was created
#5. 'updated_at' - time when note was updated

class Note
	include DataMapper::Resource
	property :id, Serial
	property :content, Text, :required => true
	property :complete, Boolean, :required => true, :default => 0
	property :created_at, DateTime
	property :updated_at, DateTime
end

DataMapper.auto_upgrade!

#------------------------------------------------------------------------------#
# @notes retrieves notes from the database and assigns the notes to itself
# @ title sets the title
# erb :home summons home.erb which containts part of the html code
get '/' do
	@notes = Note.all :order => :id.desc
	@title = 'All Notes'
	erb :home
end
#------------------------------------------------------------------------------#
# n = note object, and is created when ever a post request is made
# content takes the submitted data
# created_at and updated_at are set to the currect time
# saves the note and then redirects to the homepage
post '/' do
	n = Note.new
	n.content = params[:content]
	n.created_at = Time.now
	n.updated_at = Time.now
	n.save
	redirect '/'
end
#------------------------------------------------------------------------------#
# Allows the user to edit notes
get '/:id' do
	@note = Note.get params[:id]
	@title = "Edit note ##{params[:id]}"
	erb :edit
end
#------------------------------------------------------------------------------#
# Creates a route by:
# gets the notes id int from the URI
# sets the content, complete, and updated_at to currect values
# saves then redirects back to the homepage
put '/:id' do
	n = Note.get params[:id]
	n.content = params[:content]
	n.complete = params[:complete] ? 1 : 0
	n.updated_at = Time.now
	n.save
	redirect '/'
end
#------------------------------------------------------------------------------#
# Allows users to delete posts
get '/:id/delete' do
	@note = Note.get params[:id]
	@title = "Confirm deletion of note ##{params[:id]}"
	erb :delete
end
#------------------------------------------------------------------------------#
#The 'delete route'
delete '/:id' do
	n = Note.get params[:id]
	n.destroy
	redirect '/'
end
#------------------------------------------------------------------------------#
# Sets a note as completed
# gets the notes id, sets complete to true
# gets update time, saves, then redirects to the homepage
get '/:id/complete' do
	n = Note.get params[:id]
	n.complete = n.complete ? 0 : 1 # flip it
	n.updated_at = Time.now
	n.save
	redirect '/'
end
