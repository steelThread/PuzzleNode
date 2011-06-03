require 'json'

#
# Recursive search.
#

module OpeningFinder
  
  #
  #
  #
  def self.find
    input      = JSON.parse(File.read('sample_input.json'))
    rack       = decode_rack(input['tiles'])
    #board      = decode_board(input['board'])
    dictionary = input['dictionary']
    opening    = File.open('opening.txt', 'w+')     
    
    dictionary.each do |word|
      puts "#{word} - #{rack.contains_word?(word)}"
      #uts "#{word} - #{rack.contains_word?(word)}"
    end  
  end

  #
  #
  #
  def self.decode_rack(tiles)
    tiles = decode_tiles(tiles)
    Rack.new(tiles.sort!)
  end

  #
  #
  #
  def self.decode_tiles(tiles)
    tiles.collect {|tile| Tile.new(tile[0], tile[1..-1])}
  end
  
  #
  #
  #
  class Board
    def initialize(squares)
      @squares = squares
    end
  end
  
  #
  #
  #
  class Tile
    attr_accessor :letter
    def initialize(letter, points)
      @letter, @points = letter, points
    end
    
    def ==(other)
      letter == other.letter
    end
    
    def <=>(other)
      letter <=> other.letter
    end
  end
  
  #
  #
  #
  class Rack
    def initialize(tiles)
      @tiles = tiles
    end
    
    def contains_word?(word)
      tiles = @tiles.collect {|tile| tile.letter}
      word.each_char do |c|
        index = tiles.index(c)
        return false unless index
        tiles.delete_at(index)
      end
      true
    end
  end
end

OpeningFinder.find