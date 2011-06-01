require 'date'
require 'json'
require File.expand_path('../lib/reservation_finder', __FILE__)

# load the inventory
inventory = open('resources/vacation_rentals.json') do |f| 
  JSON.parse(f.gets).collect do |unit|
    AlohaProperties::Property.new(unit['name'], unit['seasons'], unit['cleaing fee'])      
  end
end

# load the vacation period
period = open('resources/input.txt') do |f|  
  dates = f.gets.split('-')
  Date.parse(dates.first)..Date.parse(dates.last)
end

# construct a reservation finder
finder = AlohaProperties::ReservationFinder.new(inventory)
puts finder.find(period)