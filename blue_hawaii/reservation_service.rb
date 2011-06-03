require 'date'
require 'json'

#
# assumptions: 
#  - input range will be within the same year.
#  - last day of range is exclusive when calculating a price.
#
# trick:
#  - given the way i modeled the problem (ranges), when a 
#    reservation range crosses multiple seasons ensure to
#    account for the additional day that is lost using Date
#    subtraction
#
module ReservationService
  SALES_TAX = 0.0411416
  
  #
  # Lists the prices of the properties for a given period. 
  #
  def self.list
    listing   = File.open('reservation_listing.txt', 'w+')
    period    = load_period
    inventory = load_inventory
    inventory.each do |property|
      listing.puts "#{property.name}: #{property.price(period)}"    
    end
  end
  
  #
  # Loads the property inventory.
  #
  def self.load_inventory
    open('sample_vacation_rentals.json') do |file| 
      JSON.parse(file.gets).collect do |unit|
        name         = unit['name']
        rate         = unit['rate'][1..-1].to_f if unit['rate']
        seasons      = bind_seasons(unit['seasons'])
        cleaning_fee = unit['cleaning fee'][1..-1].to_f if unit['cleaning fee']
        Property.new(name, rate, seasons, cleaning_fee)      
      end
    end
  end
  
  #
  # Binds the season hash to a Season.
  #
  def self.bind_seasons(seasons)
    if seasons
      seasons.collect do |season|
        season = season.values[0]
        Season.new(
          Date.strptime(season['start'], '%m-%d'),
          Date.strptime(season['end'], '%m-%d'),
          season['rate'][1..-1].to_f
        )
      end
    end    
  end
  
  #
  # Loads the reservation period.
  #
  def self.load_period
    open('sample_input.txt') do |file|  
      dates = file.gets.split('-')
      Period.new(Date.parse(dates.first), Date.parse(dates.last))
    end
  end

  #
  # Internal representation of period.
  #
  class Period < Range
    def days
      (self.end - self.begin).to_i
    end
    
    def included_days(period)
      if member?(period.begin)
        if member?(period.end)
          period.days
        else
          (self.end - period.begin).to_i
        end
      elsif member?(period.end)
        (period.end - self.begin).to_i
      else
        0
      end      
    end
  end

  #
  # Internal representation of a rental season.
  #
  class Season
    def initialize(from, to, rate)
      @periods = 
        if from > to
          [Period.new(from, Date.parse('12/31')), Period.new(Date.parse('01/01'), to)]  
        else
          [Period.new(from, to)]
        end
      @rate = rate
    end 
    
    def price(period)
      @periods.inject(0) {|sum, p| sum + p.included_days(period) * @rate}
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
    
    def seasonal?
      !@seasons.nil?
    end
    
    def price(period)
      price = 
        if seasonal?
          @seasons.inject(0) {|sum, season| sum + season.price(period)}
        else
          period.days * @rate
        end

      price += @cleaning_fee unless @cleaning_fee.nil?
      price *= 1 + SALES_TAX
      sprintf("$%.02f", price)
    end
  end
end

ReservationService.list