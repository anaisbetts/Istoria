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
require 'importers'
require 'pathname'
require 'nokogiri'
require 'open-uri'

class TwitterXmlImporter
  include Istoria::XmlImportImplementation

  XmlHeaderMap = {
    "text" => :text,
    "created_at" => :authored_on,
    "user/screen_name" => :from,
    "geo" => :location,
    "id" => :twitter_id,
  }

  XmlDataTransformerMap = {
    :text => :passthrough,
    :authored_on => :parse_rfc2822_time,
    :from => :passthrough,
    :location => :parse_latlng,
    :twitter_id => :parse_integer
  }

  def xml_header_map; XmlHeaderMap; end
  def xml_data_transformer_map; XmlDataTransformerMap; end
  def xml_event_class; Message; end

  def xml_item_nodename
    "//status"
  end

  def xml_add_fields(item)
    item[:format] = Message::PlainTextFormat
    item[:tags] = [Tag.new(:name => "Twitter", :type => Tag::SourceType)]
    item[:original_uri] = "http://twitter.com/#{item[:from]}/status/#{item[:twitter_id]}"
    item
  end

  class << self
    include Istoria::StandardParsers
  end
end
