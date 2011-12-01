require 'date'
require 'json'

#
# assumptions:
#  - input range will be within the same year.
#  - last day of range is exclusive when calculating a price.
#  - a single input range will cross at most 2 seasons.
#
# trick:
#  - given the way i modeled the problem (ranges), when a
#    reservation range crosses 2 seasons ensure to
#    account for the additional day in the first season
#    that is lost using Date subtraction
#
module ReservationService
  SALES_TAX = 0.0411416

  class << self
    #
    # Lists the prices of the properties for a given period.
    #
    def listings
      period    = load_period
      inventory = load_inventory
      open('solution.txt', 'w') do |file|
        inventory.each do |property|
          file.puts "#{property.name}: #{property.price(period)}"
        end
      end
    end

    #
    # Loads the reservation period.
    #
    def load_period
      open('input.txt') do |file|
        dates = file.gets.split(/-/)
        Period.new(Date.parse(dates.first), Date.parse(dates.last))
      end
    end

    #
    # Loads the property inventory.
    #
    def load_inventory
      open('vacation_rentals.json') do |file|
        JSON.parse(file.gets).collect do |hash|
          to_property(hash)
        end
      end
    end

    #
    # Build a Property instance from a Hash.
    #
    def to_property(property)
      name         = property['name']
      rate         = property['rate'][1..-1].to_f if property['rate']
      seasons      = to_seasons(property['seasons'])
      cleaning_fee = property['cleaning fee'][1..-1].to_f if property['cleaning fee']
      Property.new(name, rate, seasons, cleaning_fee)
    end

    #
    # Build a Season instance array for the
    #
    def to_seasons(seasons)
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

    def include?(date)
      @periods.any? {|p| p.include?(date)}
    end

    def price(period, inclusive = false)
      price =  @periods.inject(0) {|sum, p| sum + p.included_days(period) * @rate}
      price += inclusive ? @rate : 0
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
      not @seasons.nil?
    end

    def find_season_for(date)
      @seasons.find {|season| season.include?(date)}
    end

    def price(period)
      price =
        if seasonal?
          first_season  = find_season_for(period.begin)
          second_season = find_season_for(period.end)
          multi_season  = first_season != second_season
          sum  = first_season.price(period, multi_season)
          sum += multi_season ? second_season.price(period) : 0
        else
          period.days * @rate
        end

      price += @cleaning_fee if @cleaning_fee
      price *= 1 + SALES_TAX
      sprintf("$%.02f", price)
    end
  end
end

ReservationService.listings