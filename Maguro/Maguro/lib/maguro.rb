require 'rubygems'
require 'mynu'
require 'yaml'
# $: << File.expand_path('./', File.dirname(__FILE__))
# require 'maguro/project' unless defined? Maguro::Project

module Maguro
  class Menu
    attr_accessor :menu, :projects
  
    BT_DOMAIN = 'http://builder.bigtuna.appelier.com'.freeze
    BT_URL_PATTERN = 'projects/%s/feed.atom'.freeze
    BT_PROJECTS = %w(
      1-bigtuna
      4-bigtuna-dev
    ).freeze
    DEFAULT_POLL = 300 # seconds
  
    def initialize
      @menu = Mynu.new nil, 'Maguro'
      load_config
      build_projects
      set_status
    end
  
    def load_config
      @config = {}
      data = YAML.load_file(File.expand_path('~/.maguro')) rescue Hash.new
      @config[:url] = data.fetch('url') { BT_DOMAIN }
      @config[:projects] = data.fetch('projects') { BT_PROJECTS }
      @config[:poll_interval] = data.fetch('poll_interval') { DEFAULT_POLL }
      puts @config.inspect
    end
  
    def build_projects
      @projects = []
      url_string = [@config[:url], BT_URL_PATTERN].join('/')
      puts 'url_string = %s' % url_string
      @config[:projects].each do |feed|
        puts 'Configuring project %s' % feed
        @projects << Maguro::Project.new(self, url_string % feed, @config[:poll_interval])
      end
    end
    
    def set_status
      if @projects.any?{|p| p.failing? }
        set_build_icon @menu.__status_item, 'red'
      else
        set_build_icon @menu.__status_item, 'green'
      end
    end
  
    def set_build_icon menu_item, color
      icon = File.expand_path("assets/#{color}.png", File.dirname(__FILE__))
      menu_item.setImage NSImage.new.initWithContentsOfFile(icon)
    end
  
    def run
      @menu.separator
      @menu.link 'View in Browser', @config[:url]
      @menu.separator
      @menu.run
    end
  end
end


# %w(
#   5-atlas-master
#   8-md-admin-master
#   1-amigo-master
#   2-amigo-stable
#   3-abacus-master
#   4-abacus-stable
#   6-ballista-master
#   7-ballista-stable
#   9-morannon-master
#   10-morannon-stable
#   11-newman-master
#   12-newman-stable
#   13-peon-master
#   14-peon-stable
#   15-persona-master
#   16-persona-stable
#   17-toolbox-master
#   18-toolbox-stable
#   19-trump-master
#   20-trump-stable
#   21-tyrant-master
#   22-tyrant-stable
#   23-zeus-master
# ).each do |feed|
# .each do |feed|
#   @projects << project = Maguro::Project.new('http://builder.bigtuna.appelier.com/projects/%s/feed.atom' % feed)
#   @menu.menu project.title do |project_item|
#     set_build_icon project_item, (project.failing? ? 'red' : 'green')
#     project.builds.each do |build|
#       project_item.link build.title, build.url do |build_item|
#         set_build_icon build_item, (build.failed? ? 'red' : 'green')
#       end
#     end
#   end
# end

# if @projects.any?{|p| p.failing? }
#   set_build_icon @menu.__status_item, 'red'
# else
#   set_build_icon @menu.__status_item, 'green'
# end
# 
# @menu.separator
# 
# @menu.link 'View in Browser', 'http://ci.moneydesktop.com:3000'
# 
# @menu.separator