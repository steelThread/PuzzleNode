module AlohaProperties
  SALES_TAX = 4.11416

  class Property
    def initialize(name, seasons, cleaning_fee)
      @name, @seasons, @cleaning_fee = name, seasons, cleaning_fee      
    end
  end
    
  class ReservationFinder
    def initialize(inventory)
      @inventory = inventory
    end
    
    def find(period)
      'found it'
    end
  end
end