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

require 'mongo_mapper'
require 'grip'
require 'digest/sha1'

class Tag
  include MongoMapper::EmbeddedDocument

  OtherType = 1
  SourceType = 2

  key :location, Array
  key :name, String
  key :type, Integer

  def type_sym
    return :source if self.type == SourceType
    :other
  end
end

class Event
  include MongoMapper::Document

  key :_type, String
  key :saved_content_hash, String
  key :authored_on, Time
  key :location, Array
  key :original_uri, String
  many :tags

  timestamps!

  #ensure_index :saved_content_hash
  #ensure_index :authored_on

  validates_uniqueness_of :saved_content_hash
  validates_presence_of :authored_on
  before_validation :save_content_hash

  def content_hash
    raise "Implement me!"
  end

  def save_content_hash
    self.saved_content_hash = content_hash
  end
end

class Message < Event
  key :from, String
  key :to, String
  key :text, String
  key :format, Integer

  before_validation :save_content_hash

  validates_presence_of :text
  validates_presence_of :format

  #ensure_index :from, :to

  # Format constants
  PlainTextFormat = 1
  MarkdownFormat = 2
  HtmlFormat = 3
  MaximumFormatValue = 4

  def content_hash
    Digest::SHA1.hexdigest((self.from || "") + (self.to || "") + self.text)
  end

  def format_sym
    return :plain_text if self.format == PlainTextFormat
    return :markdown if self.format == MarkdownFormat
    return :html if self.format == HtmlFormat
    :unknown
  end
end

class Media < Event
  plugin Grip
  attachment :data 
 
  def content_hash
    data_hash
  end
end
