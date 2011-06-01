require 'date'
require 'json'

module ReservationService
  SALES_TAX = 4.11416
  
  #
  # Run the reservation request. 
  #
  def self.run
    lister = ReservationLister.new(load_inventory)
    listing = File.open('reservation_listing.txt', 'w+')
    listing.puts  lister.list(load_period)  
  end
  
  #
  # Loads the property inventory.
  #
  def self.load_inventory
    open('vacation_rentals.json') do |f| 
      JSON.parse(f.gets).collect do |unit|
        if unit['seasons']
          seasons = unit['seasons'].collect do |season|
            season = season.values[0]
            Season.new(season['start'], season['end'], season['rate'])    
          end
        end
        
        Property.new(unit['name'], unit['rate'], seasons, unit['cleaing fee'])      
      end
    end
  end
  
  #
  # Loads the reservation period.
  #
  def self.load_period
    open('input.txt') do |f|  
      dates = f.gets.split('-')
      Date.parse(dates.first)..Date.parse(dates.last)
    end
  end

  #
  # Internal represenation of a rental season (range like).
  #
  class Season
    def initialize(from, to, rate)
      @from, @to, @rate = from, to, rate
    end
    
    def contains(date)
        
    end
  end    

  #
  # Internal representation of a rentable property.
  #
  class Property
    attr_reader :name
    def initialize(name, rate, seasons, cleaning_fee)
      @name, @rate, @seasons, @cleaning_fee = name, rate, seasons, cleaning_fee      
    end
    
    def calculate(period)
      puts period.end - period.start
    end
  end
    
  #
  # Finds available properties in the inventory for a given period.
  #
  class ReservationLister
    def initialize(inventory)
      @inventory = inventory
    end
    
    def list(period)
      @inventory.collect do |property|
        %{#{property.name}}    
      end
    end
  end
end

ReservationService.run