require 'json'
require 'matrix'

#
# Recursive search.
#

module OpeningFinder
  
  #
  # Find the best opening for a given board, dictionary and rack of tiles.
  #
  def self.find
    input      = JSON.parse(File.read('sample_input.json'))
    rack       = decode_rack(input['tiles'])
    board      = decode_board(input['board'])
    dictionary = input['dictionary']
    opening    = File.open('opening.txt', 'w+')     
    dictionary.each do |word|
      next unless tiles = rack.tiles(word)
      #board.solve(word) if rack.contains_word?(word)
    end  
  end

  #
  # Decode the board
  #
  def self.decode_board(rows)
    Board.rows(
      rows.collect {|row| row.split(' ').map(&:to_i)}
    )
  end

  #
  # Decode the tiles and return a Rack instance.
  #
  def self.decode_rack(tiles)
    tiles = decode_tiles(tiles)
    Rack.new(tiles.sort!)
  end

  #
  # Decode the array of hashes into an array of Tile instances.
  #
  def self.decode_tiles(tiles)
    tiles.collect {|tile| Tile.new(tile[0], tile[1..-1])}
  end
  
  #
  # Internal representation of a scrabble board.
  #
  class Board < Matrix
    def write(file, solution)
    end
  end
  
  #
  # Internal representation of a Tile.
  #
  class Tile
    attr_accessor :letter
        
    def initialize(letter, points)
      @letter, @points = letter, points
    end
    
    def <=>(other)
      letter <=> other.letter
    end
  end
  
  #
  # Internal representation of a Rack (holds the tiles).
  #
  class Rack
    def initialize(tiles)
      @tiles = tiles
      @tiles_hash = Hash.new(
        tiles.inject([]) do |v, tile|
          v << [tile.letter, tile]
        end
      )
    end

    def tiles(word) 
      word.split(//).collect {|c| @tiles_hash[c]} if contains_word?(word)
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
  
  #
  # A solution encapsulates the work, score and posistions found.
  #
  class Solution
    attr_accessor :word, :score, :positions
    
    def initialize(word, score, positions, row = true)
      @word, @score, @positions, @row = word, score, positions, row
    end
    
    def row?; @row; end
    
    def <=>(other)
      @score <=> other.score
    end
  end
end

OpeningFinder.find