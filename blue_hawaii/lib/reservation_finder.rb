module AlohaProperties
  SALES_TAX = 4.11416

  #
  # Internal representation of a rentable property.
  #
  class Property
    def initialize(name, seasons, cleaning_fee)
      @name, @seasons, @cleaning_fee = name, seasons, cleaning_fee ||= 0      
    end
    
    def available?(period)
      true
    end
  end
    
  #
  # Finds available properties in the inventory for a given period.
  #
  class ReservationFinder
    def initialize(inventory)
      @inventory = inventory
    end
    
    def find(period)
      @inventory.collect do |property|
        property if property.available?(period)
      end
    end
  end
end