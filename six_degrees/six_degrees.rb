require 'set'

#
# Notes:  Cheated on the valid user names
#
module SixDegrees

  class << self
    def solve
      tweets = load
      graph  = graph tweets
      open('solution.txt', 'w') do |file|
        walk graph, file
      end
    end

    #
    # Load the tweets.
    #
    def load
      open('sample_input.txt') do |file|
        file.read.lines.collect {|line| Tweet.new(line)}
      end
    end

    #
    # Process the tweets building the graph nodes & edges.
    #
    def graph(tweets)
      nodes = nodes(tweets)
      edges(nodes, tweets)
      nodes.values.sort!
    end

    #
    # Build the nodes as User instances
    #
    def nodes(tweets)
      tweets.inject({}) do |nodes, tweet|
        node = nodes[tweet.user_name]
        nodes[tweet.user_name] = User.new(tweet.user_name) unless node
        nodes
      end
    end

    #
    # Build the graphs edges between the User nodes.
    #
    def edges(nodes, tweets)
      tweets.each do |tweet|
        node = nodes[tweet.user_name]
        node.mentions.merge(tweet.mentions.collect {|name| nodes[name]})
        tweet.mentions.each do |mention|
          nodes[mention].mentioned_by << node
        end
      end
    end

    #
    # Walk the mutual mentions recursively.
    #
    def walk(graph, output)
      graph.each do |node|
        puts "#{node.name}"
        puts "#{node.mutual_mentions.collect {|m| m.name}.join(', ')}\n\n"
      end
    end
  end

  #
  # Represents a tweet.
  #
  class Tweet
    attr_reader :user_name, :message

    def initialize(raw)
      parts = raw.split(/ /)
      @user_name, @message = parts.shift.chop, parts.join(' ')
    end

    def mentions
      @message.scan(/@\w+_*\w*/).collect {|word| word[1..-1]}
    end
  end

  #
  # Represents an node in the graph.
  #
  class User
    attr_accessor :name, :mentions, :mentioned_by

    def initialize(name)
      @name, @mentions, @mentioned_by = name, Set.new, Set.new
    end

    def mutual_mentions
      (@mentions & @mentioned_by).sort
    end

    def <=>(other)
      @name <=> other.name
    end
  end
end

SixDegrees.solve