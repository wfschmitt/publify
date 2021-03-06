#!/usr/bin/env ruby

# RSS 0.2/2.0/Atom converter to publify by Lennon Day-Reynolds <rcoder@gmail.com>
# Shamelessly copied from RSS-only converter by Chris Lee

require File.dirname(__FILE__) + '/../../config/environment'
require 'optparse'
begin
  require 'feed_tools'
rescue LoadError
  STDERR.puts <<-EOF.strip_heredoc
    This converter requires feedtools to be installed.
    Please run `gem install feedtools` and try again.
EOF
  exit 1
end

class FeedMigrate
  attr_accessor :options

  def initialize
    self.options = {}
    parse_options
    convert_entries
  end

  def convert_entries
    feed = FeedTools::Feed.open(options[:url])
    puts "Converting #{feed.items.length} entries..."
    feed.items.each do |item|
      puts "Converting '#{item.title}'"
      a = Article.new
      a.author = options[:author]
      a.title = item.title
      a.body = item.description
      a.created_at = item.published
      a.save
    end
  end

  def parse_options
    OptionParser.new do |opt|
      opt.banner = 'Usage: feed.rb [options]'

      opt.on('-a', '--author AUTHOR', 'Username of author in publify') do |a|
        options[:author] = a
      end

      opt.on('-u', '--url URL', 'URL of RSS feed to import.') do |u|
        options[:url] = u
      end

      opt.on_tail('-h', '--help', 'Show this message.') do
        puts opt
        exit
      end

      opt.parse!(ARGV)
    end

    unless options.include?(:author) && options.include?(:url)
      puts 'See feed.rb --help for help.'
      exit
    end
  end
end

FeedMigrate.new
