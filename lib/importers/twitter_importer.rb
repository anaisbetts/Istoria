###########################################################################
#   Copyright (C) 2010 by Paul Betts                                      #
#   paul.betts@gmail.com                                                  #
#                                                                         #
#   This program is free software; you can redistribute it and/or modify  #
#   it under the terms of the GNU General Public License as published by  #
#   the Free Software Foundation; either version 2 of the License, or     #
#   (at your option) any later version.                                   #
#                                                                         #
#   This program is distributed in the hope that it will be useful,       #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of        #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         #
#   GNU General Public License for more details.                          #
#                                                                         #
#   You should have received a copy of the GNU General Public License     #
#   along with this program; if not, write to the                         #
#   Free Software Foundation, Inc.,                                       #
#   59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.             #
###########################################################################

require 'types'
require 'pathname'
require 'nokogiri'
require 'open-uri'

class TwitterImporter
  def initialize(options = {})
    @opts = options
  end

  def can_import?(name)
    ti = TwitterXmlImporter.new
    ti.can_import?(name_to_url(name, 0))
  end

  def import(name)
    since_id = @opts[:since_id] || 0
    page = 1
    ti = TwitterXmlImporter.new

    while(ti.can_import?(name_to_url(name, page, since_id))) do
      ti.import(name_to_url(name, page, since_id))
      page += 1
      break if @opts[:limit] and @opts[:limit] < page
    end
  end

  def xml_add_fields(item)
    item[:tags] = [Tag.new(:name => "Twitter", :type => Tag::SourceType)]
    item
  end

private

  def name_to_url(name, page = 0, since_id = 0)
    if (since_id > 0)
      "http://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{name}&page=#{page}&since_id=#{since_id}"
    else
      "http://api.twitter.com/1/statuses/user_timeline.xml?screen_name=#{name}&page=#{page}"
    end
  end
  
end
