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
  5-atlas-master
  8-md-admin-master
  1-amigo-master
  2-amigo-stable
  3-abacus-master
  4-abacus-stable
  6-ballista-master
  7-ballista-stable
  9-morannon-master
  10-morannon-stable
  11-newman-master
  12-newman-stable
  13-peon-master
  14-peon-stable
  15-persona-master
  16-persona-stable
  17-toolbox-master
  18-toolbox-stable
  19-trump-master
  20-trump-stable
  21-tyrant-master
  22-tyrant-stable
  23-zeus-master
).each do |feed|
  @projects << project = Maguro::Project.new('http://ci.moneydesktop.com:3000/projects/%s/feed.atom' % feed)
  @menu.menu project.title do |project_item|
    set_build_icon project_item, (project.failing? ? 'red' : 'green')
    project.builds.each do |build|
      project_item.link build.title, build.url do |build_item|
        set_build_icon build_item, (build.failed? ? 'red' : 'green')
      end
    end
  end
end

if @projects.any?{|p| p.failing? }
  set_build_icon @menu.__status_item, 'red'
else
  set_build_icon @menu.__status_item, 'green'
end

@menu.separator

@menu.link 'View in Browser', 'http://ci.moneydesktop.com:3000'

@menu.separator

@menu.run
