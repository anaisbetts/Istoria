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
require 'sunspot'
require 'open-uri'

class FileCache
  include MongoMapper::Document
  plugin Grip

  key :key, String
  attachment :data
  timestamps!

  validates_uniqueness_of :key

  def self.create_from_file(file_or_uri)
    fc = FileCache.create(:key => file_or_uri, :data => open(file_or_uri))
  end

  def self.[](key)
    ret = FileCache.find(:key => key)
    ret ? ret.first : nil
  end
end
