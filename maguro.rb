require 'rubygems'
require 'mynu'
require './project'

@menu = Mynu.new nil, 'Maguro'

def set_build_icon menu_item, color
  icon = File.expand_path("#{color}.png", File.dirname(__FILE__))
  menu_item.setImage NSImage.new.initWithContentsOfFile(icon)
end

@projects = []

%w(
  http://builder.bigtuna.appelier.com/projects/1-bigtuna/feed.atom
  http://builder.bigtuna.appelier.com/projects/4-bigtuna-dev/feed.atom
).each do |feed|
  @projects << project = Maguro::Project.new(feed)
  @menu.item project.title do |project_item|
    set_build_icon project_item, (project.failing? ? 'red' : 'green')
    project.builds.each do |build|
      project_item.item build.title do |build_item|
        set_build_icon build_item, (build.failed? ? 'red' : 'green')
        build_item.execute do
          `open #{build.url}`
        end
      end
    end
  end
end

if @projects.any?{|p| p.failing? }
  set_build_icon @menu.status_item, 'red'
else
  set_build_icon @menu.status_item, 'green'
end

@menu.run