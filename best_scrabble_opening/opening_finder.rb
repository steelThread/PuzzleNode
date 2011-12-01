require 'json'
require 'matrix'
require 'set'

#
# Linear algebra solution .
#
module OpeningFinder

  class << self
    #
    # Find the best opening for a given board, dictionary and rack of tiles.
    #
    def find
      input      = load
      rack       = to_rack(input['tiles'])
      board      = to_board(input['board'])
      dictionary = input['dictionary'].to_set
      solutions  = dictionary.collect do |word|
        solve(word, board, rack) if rack.includes?(word)
      end

      solution = solutions.compact!.sort!.last
      open('solution.txt', 'w') do |file|
        board.write(solution, file)
      end
    end

    def load
      open('input.json') {|file| JSON.parse(file.read)}
    end

    #
    # Decode the tiles and return a Rack instance.
    #
    def to_rack(tiles)
      Rack.new(to_tiles(tiles).sort!)
    end

    #
    # Decode the board
    #
    def to_board(rows)
      Board.rows(
        rows.collect {|row| row.split(' ').map(&:to_i)}
      )
    end

    #
    # Decode the array of hashes into an array of Tile instances.
    #
    def to_tiles(tiles)
      tiles.collect {|tile| Tile.new(tile[0], tile[1..-1].to_i)}
    end

    #
    # Find the best solution for a given word.
    #
    def solve(word, board, rack)
      points    = rack.tiles(word).collect {|tile| tile.points}
      solutions = []
      row_solutions(board, points) do |score, x, y|
        solutions << Solution.new(word, score, :x => x, :y => y, :orientation => :rank)
      end
      col_solutions(board, points) do |score, x, y|
        solutions << Solution.new(word, score, :x => x, :y => y, :orientation => :file)
      end

      solutions.sort!.last
    end

    #
    # Returns all the dot products for the provided vector.
    #
    def row_solutions(matrix, points)
      solutions = (0..matrix.column_size - points.size).collect do |offset|
        matrix * Matrix.column_vector(
          Array.new(offset, 0) + points + Array.new(matrix.column_size - offset - points.size, 0)
        )
      end

      # each solution is a column vector
      solutions.each_index do |x|
        solutions[x].each_with_index do |score, y|
          yield score, x, y
        end
      end
    end

    #
    # Returns all the dot products for the provided vector.
    #
    def col_solutions(matrix, points)
      solutions = (0..matrix.row_size - points.size).collect do |offset|
        Matrix.row_vector(
          Array.new(offset, 0) + points + Array.new(matrix.row_size - offset - points.size, 0)
        ) * matrix
      end

      # each solution is a row vector
      solutions.each_index do |x|
        solutions[x].each_with_index do |score, y, z|
          yield score, z, x
        end
      end
    end
  end

  #
  # Internal representation of a scrabble board.
  #
  class Board < Matrix
    def write(solution, output)
      position = solution.position
      word = solution.word.split(//)
      printable =
        if position[:orientation] == :rank
          rows = row_vectors.collect {|row| row.to_a}
          row  = rows[position[:y]]
          sub  = word + row[position[:x] + word.size..-1]
          sub  = row[0..position[:x]-1] + sub unless position[:x] == 0
          rows[position[:y]] = sub
          rows
        else
          cols = column_vectors.collect {|col| col.to_a}
          col  = cols[position[:x]]
          sub  = word + col[position[:y] + word.size..-1]
          sub  = col[0..position[:y]-1] + sub unless position[:y] == 0
          cols[position[:x]] = sub
          cols.transpose
        end
        printable.each {|row| output.puts row.join(' ')}
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
    attr_accessor :word, :score, :position

    def initialize(word, score, position)
      @word, @score, @position = word, score, position
    end

    def <=>(other)
      @score <=> other.score
    end
  end
end

OpeningFinder.find