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

class LastFmListen < Event
  key :song_name, String
  key :artist, String
  key :play_count, Integer

  key :image_key, Array

  def content_hash
    Digest::SHA1.hexdigest(self.artist + self.song_name + self.play_count)
  end
end

Sunspot.setup(LastFmListen) do
  text :name
  text :artist
end

Sunspot::Adapters::InstanceAdapter.register(MongoInstanceAdapter, LastFmListen)
Sunspot::Adapters::DataAccessor.register(MongoDataAccessor, LastFmListen)


class LastFmXmlImporter
  include Istoria::XmlImportImplementation

  XmlHeaderMap = {
    "url" => :original_uri,
    "artist" => :artist,
    "name" => :song_name,
    "playcount" => :play_count,
  }

  XmlDataTransformerMap = {
    :original_uri => :passthrough,
    :artist => :unescape_html,
    :song_name => :unescape_html,
    :play_count => :parse_as_integer,
  }

  def xml_header_map; XmlHeaderMap; end
  def xml_data_transformer_map; XmlDataTransformerMap; end
  def xml_event_class; LastFmListen; end

  def xml_item_nodename
    "//track"
  end

  def xml_add_fields(item)
    item[:format] = Message::PlainTextFormat
    item[:authored_on] = Time.now
    item[:tags] = [Tag.new(:name => "last.fm", :type => Tag::SourceType)]
    item[:original_uri] = "http://twitter.com/#{item[:from]}/status/#{item[:twitter_id]}"
    item
  end

  class << self
    include Istoria::StandardParsers
  end
end
