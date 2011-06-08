require 'rubygems'
require 'mynu'
require 'yaml'
$: << File.expand_path('./', File.dirname(__FILE__))
require 'maguro/project'

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
        if feed == 'SEP'
          @menu.separator
        else
          puts 'Configuring project %s' % feed
          @projects << Maguro::Project.new(self, url_string % feed, @config[:poll_interval])
        end
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

Maguro::Menu.new.run
