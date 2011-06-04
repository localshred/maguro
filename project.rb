require 'open-uri'
require 'nokogiri'
require './build'

=begin
  <feed xml:lang="en-US" xmlns="http://www.w3.org/2005/Atom">
    <id>tag:builder.bigtuna.appelier.com,2005:/projects/1-bigtuna/feed</id>
    <link type="text/html" href="http://builder.bigtuna.appelier.com" rel="alternate"/>
    <link type="application/atom+xml" href="http://builder.bigtuna.appelier.com/projects/1-bigtuna/feed.atom" rel="self"/>
    <title>BigTuna CI</title>
    <updated>2011-04-13T21:08:53Z</updated>
    <entry>
      ...
    </entry>
    ...
  </feed>
=end

module Maguro
  class Project
    attr_reader :url, :page
  
    def initialize url
      @url = url
      refresh
    end
  
    def refresh
      @title = @updated = @builds = nil
      @page = Nokogiri::XML(open(@url))
    end
  
    def title
      @title ||= @page.at_css('feed title').children.to_s
    end
  
    def updated
      @updated ||= Time.parse(@page.at_css('feed updated').children.to_s)
    end
  
    def builds
      @builds ||= @page.css('feed entry').map{|build| Maguro::Build.new(build) } || []
    end
    
    def failing?
      builds.first.failed?
    end
    
    def succeeding?
      !failing?
    end
  
  end
end