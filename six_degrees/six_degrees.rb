require 'set'

#
# Notes:  Cheated on the valid user names
#
module SixDegrees

  class << self
    def solve
      tweets = load
      graph  = build_graph_from tweets
      graph.each do |member|
        puts "#{member.name}"
        puts "#{member.mentions.each.collect {|m| m.name}}"
        puts "#{member.mentioned_by.each.collect {|m| m.name}}\n\n"
      end
    end

    #
    # Load the tweets.
    #
    def load
      open('sample_input.txt') do |file|
        file.read.lines.collect {|line| to_tweet(line)}
      end
    end

    #
    # Parse to a Tweet instance.
    #
    def to_tweet(line)
      parts = line.split(/ /)
      Tweet.new(parts.shift.chop, parts.join(' '))
    end

    #
    # Process the tweets building the graph nodes & edges.
    #
    def build_graph_from(tweets)
      nodes = build_nodes(tweets)
      build_edges(nodes, tweets)
    end

    #
    # Build the nodes as User instances
    #
    def build_nodes(tweets)
      tweets.inject({}) do |nodes, tweet|
        node = nodes[tweet.user_name]
        nodes[tweet.user_name] = User.new(tweet.user_name) unless node
        nodes
      end
    end

    #
    # Build the graphs edges between the User nodes.
    #
    def build_edges(nodes, tweets)
      tweets.each do |tweet|
        node = nodes[tweet.user_name]
        node.mentions.merge(tweet.mentions.collect {|name| nodes[name]})
        tweet.mentions.each do |mention|
          nodes[mention].mentioned_by << node
        end
      end
      nodes.values.sort!
    end
  end

  #
  # Represents a tweet.
  #
  class Tweet
    attr_reader :user_name, :message

    def initialize(user_name, message)
      @user_name, @message = user_name, message
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
      @mentions & @mentioned_by
    end

    def <=>(other)
      @name <=> other.name
    end
  end
end

SixDegrees.solve