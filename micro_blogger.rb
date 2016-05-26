require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
  attr_reader :client

  def initialize
    puts "Initializing MicroBlogger"
    @client = JumpstartAuth.twitter
  end

  def tweet(message)
    if message.length < 141
      @client.update(message)
    else
      puts "Tweet length more than 141 characters. Cannot post!"
    end
  end

  def run
    puts "Welcome to the JSL Twitter Client!"
    command = ""
    while command != "q"
      printf "enter command: "
      input = gets.chomp
      parts = input.split(" ")
      command = parts[0]
      case command
        when 'q' then puts "Goodbye!"
        when 't' then tweet(parts[1..-1].join(" "))
        when 'dm' then dm(parts[1], parts[2..-1].join(" "))
        when 'spam' then spam_my_followers(parts[1..-1].join(" "))
        when 'elt' then everyones_last_tweet
        when 's' then shorten(parts[1])
        when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
        else
          puts "Sorry, I don't know how to #{command}"
      end
    end
  end

  def dm(target, message)
    screen_names = @client.followers.collect {|follower| @client.user(follower).screen_name}
    if screen_names.include?(target)
      puts "Trying to send #{target} this direct message:"
      puts message
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts "You can only DM people who follow you. Sorry"
    end
  end

  def followers_list
    screen_names = []
    @client.followers.each {|follower| screen_names << @client.user(follower).screen_name}
    screen_names
  end

  def spam_my_followers(message)
    followers_list.each {|follower| dm(follower, message)}
  end

  def everyones_last_tweet
    friends = @client.friends
    friends = friends.sort_by {|friend| friend.screen_name.downcase}
    timestamp = friend.status.created_at
    friends.each do |friend|
      puts "#{friend.screen_name}: #{friend.status.text}"
      puts "Created at: #{timestamp.strftime("%A %b %d")}"
      puts ""
    end
  end

  def shorten(original_url)
  	Bitly.use_api_version_3
  	bitly = Bitly.new("hungryacademy", 'R_430e9f62250186d2612cca76eee2dbc6')
  	puts "Shortening this URL: #{original_url}"
  	bitly.shorten(original_url).short_url
  end
end

blogger = MicroBlogger.new
blogger.run
