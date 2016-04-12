# encoding: utf-8
require 'sinatra'
require 'fias'
require 'sequel'

DB =  Sequel.connect(ENV['DATABASE_URL'])

configure :development do
 set :bind, '0.0.0.0'
 set :port, '3030'
end

get '/' do
 adrs = DB[:address_objects]
   .where(:parentguid => nil)
   .order(:name)
   .to_a.to_json
 #adrs.map{|adr| "<div><a href='/#{adr[:aoguid]}'>#{adr[:name]}</a></div>"}
end

get '/:parent_id' do
  adrs = DB[:address_objects]
    .where(:parentguid => params["parent_id"])
    .order(:name)
    .to_a
  if(adrs.blank?)
    adr = DB[:address_objects].where(:aoguid => params["parent_id"]).first
    return DB.from("fias_house#{adr[:region]}")
      .where(aoguid: adr[:aoguid])
      .order(:housenum)
      .to_a.to_json
  else
    return adrs.to_json
  end
  #adrs.map{|adr| adr[:level] <7 ? "<div><a href='/#{adr[:aoguid]}'>#{adr[:name]}<b>#{adr[:id]}</b></a>": "<div>#{adr[:name]}<a href='/#{adr[:aoguid]}/houses'>HOUSES</a><a href='/#{adr[:aoguid]}/full_address'>FULL ADDRESS</a></div>"}
end

# get '/:parent_id/houses' do
#   adr = DB[:address_objects].where(:aoguid => params["parent_id"]).first
#   houses = DB.from("fias_house#{adr[:region]}").where(aoguid: adr[:aoguid]).to_a
#   #  .map{|h| "<li>#{h[:housenum]}</li>"}        
# end

get '/:id/info' do
  item = DB[:address_objects].where(:aoguid => params["id"]).first
  full_name = []
  full_name.push "#{item[:abbr]} #{item[:name]}"
  ancestry = item[:ancestry].delete('{}').split(',')
  ancestry.each do |parent_id|
    result = DB[:address_objects].select(:abbr, :name).where(:id => parent_id).first    
    full_name.push "#{result[:abbr]} #{result[:name]}"
  end  
  item[:full_name] = full_name.reverse.join(", ")
  item.to_json
end