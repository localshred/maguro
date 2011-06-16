require 'open-uri'
require 'nokogiri'
require 'date'

require 'maguro/build'
require 'maguro/time_util'

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
    attr_reader :url, :page, :menu_item
  
    def initialize menu, url, interval
      @menu = menu
      @url = url
      @interval = interval
      refresh
      build_item
    end
  
    def refresh
      @menu_item.submenu.removeAllItems if @menu_item
      @title = @updated = @builds = nil
      
      Thread.new do
        @page = Nokogiri::XML(open(@url))
        puts 'Refreshed project %s, found %d builds with status of %s' % [title, builds.length, status]
      end.join
      
      # TODO implement polling refreshes
      # if @interval
        # puts 'sleeping for %d' % @interval
        # Thread.new do
        #   puts 'going to sleep %d' % self.object_id
        #   sleep @interval
        #   puts 'waking up %d' % self.object_id
        #   refresh
        # end
      # end
    end
    
    def build_item
      @menu_item = @menu.menu.menu title do |item|
        @menu.set_build_icon item, icon_name
        builds.each do |build|
          build_item = item.link build.title, build.url
          @menu.set_build_icon build_item, build.icon_name
        end
        item.separator
        item.link 'View in Browser', url.gsub(/\/feed\.atom$/, '')
      end
    end
  
    def title
      @title ||= begin
        t = @page.at_css('feed title').children.to_s.sub(/ CI$/, '')
        '%s - %s' % [t, TimeUtil.relative_time(updated)]
      end
    end
  
    def updated
      @updated ||= DateTime.parse(@page.at_css('feed updated').children.to_s).to_time
    end
  
    def builds
      @builds ||= @page.css('feed entry').map{|build| Maguro::Build.new(build) } || []
    end
    
    def url
      @url ||= @page.link('link[type="application/atom+xml"]').first.children.to_s
    end
    
    def failing?
      builds.first.failed?
    end
    
    def passing?
      !failing?
    end
    
    def status
      passing? ? 'passing' : 'failing'
    end
    
    def icon_name
      passing? ? 'green' : 'red'
    end
  
  end
end