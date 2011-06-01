require 'date'
require 'json'

module ReservationFinder
  SALES_TAX = 4.11416
  
  def self.run
    inventory = open('resources/vacation_rentals.json') do |f| 
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
    
    # load the vacation period
    period = open('resources/input.txt') do |f|  
      dates = f.gets.split('-')
      Date.parse(dates.first)..Date.parse(dates.last)
    end

    calculator = VacationCalculator.new(inventory)
    puts calculator.list(period)    
  end

  #
  # Internal represenation of a rental seasion.
  #
  class Season
    def initialize(from, to, rate)
      @from, @to, @rate = from, to, rate
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
  end
    
  #
  # Finds available properties in the inventory for a given period.
  #
  class VacationCalculator
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

ReservationFinder.run