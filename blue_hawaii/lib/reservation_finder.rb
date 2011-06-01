module AlohaProperties
  SALES_TAX = 4.11416

  #
  # Internal represenation of a rental sesion.
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
    def initialize(name, rate, seasons, cleaning_fee = 0)
      @name, @rate, @seasons, @cleaning_fee = name, rate, seasons, cleaning_fee      
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