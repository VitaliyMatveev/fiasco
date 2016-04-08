require 'sinatra'
require 'fias'
require 'sequel'

DB =  Sequel.connect('postgres://localhost/fiasco_db')

configure :development do
 set :bind, '0.0.0.0'
 set :port, '3000'
end

get '/' do
 adrs = DB[:address_objects]
   .where(:parentguid => nil)
   .to_a
 adrs.map{|adr| "<div><a href='/#{adr[:aoguid]}'>#{adr[:name]}</a></div>"}
end

get '/:parent_id' do
  adrs = DB[:address_objects]
   .where(:parentguid => params["parent_id"])
   .to_a
   if adrs.blank? 
    adr = DB[:address_objects].where(:aoguid => params["parent_id"]).first
    houses = DB.from("fias_house#{adr[:region]}").where(aoguid: adr[:aoguid]).to_a
      .map{|h| "<li>#{h[:housenum]}</li>"}      
   else    
    adrs.map{|adr| "<div><a href='/#{adr[:aoguid]}'>#{adr[:abbr]} #{adr[:name]}</a></div>"}
  end
end