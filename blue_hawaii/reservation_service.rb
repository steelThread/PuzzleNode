require 'bigdecimal'
require 'date'
require 'json'

#
# Assumption: input range will be within the same year.
#
module ReservationService
  SALES_TAX = BigDecimal.new('.0411416')
  
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
    open('sample_vacation_rentals.json') do |f| 
      JSON.parse(f.gets).collect do |unit|
        if unit['seasons']
          seasons = unit['seasons'].collect do |season|
            season = season.values[0]
            first  = Date.strptime(season['start'], '%m-%d')
            last   = Date.strptime(season['end'], '%m-%d')
            rate   = BigDecimal.new(season['rate'][1..-1])
            Season.new(first, last, rate)    
          end
        end
        
        rate = BigDecimal.new(unit['rate'][1..-1]) if unit['rate']
        cleaning_fee = BigDecimal.new(unit['cleaning fee'][1..-1]) if unit['cleaning fee']
        Property.new(unit['name'], rate, seasons, cleaning_fee)      
      end
    end
  end
  
  #
  # Loads the reservation period.
  #
  def self.load_period
    open('sample_input.txt') do |f|  
      dates = f.gets.split('-')
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
      days = 
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
      puts "testing: #{period.to_s}   -   #{to_s}    - days: #{days}"
      days
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
      price += price * SALES_TAX 
      sprintf("$%.02f", price)
    end
  end
end

ReservationService.list