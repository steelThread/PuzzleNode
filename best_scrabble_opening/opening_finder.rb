require 'json'
require 'matrix'
require 'set'

#
# Linear algebra solution .
#
module OpeningFinder
  
  #
  # Find the best opening for a given board, dictionary and rack of tiles.
  #
  def self.find
    input      = JSON.parse(File.read('sample_input.json'))
    rack       = decode_rack(input['tiles'])
    board      = decode_board(input['board'])
    dictionary = input['dictionary'].to_set
    solutions = []
    dictionary.each do |word|
      next unless rack.includes?(word)
      solutions << solve(word, board, rack)
    end 
    solution = solutions.sort!.last
    puts "word => #{solution.word} score => #{solution.score} orientation => #{solution.orientation}"
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
    Rack.new(decode_tiles(tiles).sort!)
  end

  #
  # Decode the array of hashes into an array of Tile instances.
  #
  def self.decode_tiles(tiles)
    tiles.collect {|tile| Tile.new(tile[0], tile[1..-1].to_i)}
  end
  
  #
  # Find the best solution for a given word.
  #
  def self.solve(word, board, rack)
    points    = rack.tiles(word).collect {|tile| tile.points}
    solutions = []
    row_solutions(board, points) do |score, x, y|
      solutions << Solution.new(word, score, :x => x, :y => y, :orientation => :horizontal) 
    end
    col_solutions(board, points) do |score, x, y|
      solutions << Solution.new(word, score, :x => x, :y => y, :orientation => :vertical) 
    end
    solutions.sort!.last
  end
  
  #
  # Returns all the dot products for the provided vector.
  #
  def self.row_solutions(matrix, points)
    solutions = (0..matrix.column_size - points.size).collect do |offset|
      matrix * Matrix.column_vector(
        Array.new(offset, 0) + points + Array.new(matrix.column_size - offset - points.size, 0)
      )
    end 
    
    solutions.each_index do |x|
      solutions[x].each_with_index do |score, y|
        yield score, x, y
      end    
    end   
  end

  #
  # Returns all the dot products for the provided vector.
  #
  def self.col_solutions(matrix, points)
    solutions = (0..matrix.row_size - points.size).collect do |offset|
      Matrix.row_vector(
        Array.new(offset, 0) + points + Array.new(matrix.row_size - offset - points.size, 0)
      ) * matrix
    end 
    
    solutions.each_index do |x|
      solutions[x].each_with_index do |score, y|
        yield score, x, y
      end    
    end   
  end

  #
  # Internal representation of a scrabble board.
  #
  class Board < Matrix
    def write(solution, file)
    end
  end
  
  #
  # Internal representation of a Tile.
  #
  class Tile
    attr_accessor :letter, :points
        
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
      @tiles_hash = Hash[
        tiles.collect {|tile| [tile.letter, tile]}
      ]
    end

    def tiles(word) 
      word.split(//).collect {|c| @tiles_hash[c]}
    end      
    
    def includes?(word)
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
    attr_accessor :word, :score, :orientation
    
    def initialize(word, score, orientation)
      @word, @score, @orientation = word, score, orientation
    end
    
    def <=>(other)
      @score <=> other.score
    end
  end
end

OpeningFinder.find