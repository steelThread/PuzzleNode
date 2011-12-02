#
# Notes:  Cheated on the valid user names
#
module SixDegrees
  MEMBERS = []

  class << self
    def solve
      tweets = load
      tweets.each {|tweet| puts "user: '#{tweet.user_name}' mentions: '#{tweet.mentions}'"}
      build_graph tweets
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
      Tweet.new(parts[0].chop, parts[1..-1].join(' '))
    end

    #
    # Process the tweets building the relationships.
    #
    def build_graph(tweets)
      tweets.each do |tweet|

      end
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
      @message.scan(/@\w+_*\w*/).collect{|word| word[1..-1]}
    end
  end

  #
  # Represents an account.
  #
  class User
    attr_reader :name, :mentions, :mentioned_by

    def initialize
      @mentions, @mentioned_by = Set.new, Set.new
    end

    def mentioned(user)
      @mentions << user
    end

    def mentioned_by(user)
      @mentioned_by << user
    end

    def <=>(other)
      @name <=> other.name
    end
  end
end

SixDegrees.solve