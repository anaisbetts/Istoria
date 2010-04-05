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

require 'lib/boot'
require 'csv'
require 'cgi'
require 'open-uri'

require 'lib/types'

module Istoria

  def self.available_importers
    unless @initialized
      importers_path = File.join(File.dirname(__FILE__), 'importers')
      Dir.glob("#{importers_path}/**/*.rb").each {|x| require x}
      @initialized = true
    end

    ret = []
    ObjectSpace.each_object(Class) {|x| ret << x if x.name.include? "Importer"}
    ret
  end

  module StandardParsers
    def parse_mdy_date(value)
      month, day, year = value.split('/').map{|x| x.to_i}
      Time.utc(year, month, day, 0, 0, 0, 0)
    end

    def parse_float(value)
      value.to_f
    end

    def parse_integer(value)
      value.to_i
    end

    def passthrough(value); value; end

    def parse_latlng(value)
      return nil unless value and value != ""
      value.gsub(/^[^\d-]*(-?\d*\.\d*?) (-?\d*\.\d*?)\s+$/, '\1 \2').split(" ").map{|x| x.to_f}
    end

    def parse_rfc2822_time(value)
      Time.parse(value)
    end

    def unescape_html(value)
      CGI.unescapeHTML(value)
    end

    def download_uri(value)
      open(value)
    end
  end

  module CsvImportImplementation
    def can_import?(target)
      begin
        to_verify = {}
        CSV.open(target, 'r') do |row|
          row.each {|x| to_verify[x] = true}
          break
        end

        raise "Failed" unless self.csv_header_map.keys.all? {|x| to_verify[x]}
      rescue
        puts $!.message
        puts $!.backtrace
        return false
      end

      true
    end

    def import(target)
      ret = []
      headers = nil

      CSV.open(target, 'r') do |row|
        item = {}
        unless headers
          headers = row
          next
        end

        headers.zip(row) do |k, v|
          key = self.csv_header_map[k]
          next unless key

          item[key] = self.class.send(self.csv_data_transformer_map[key], v)
        end

        next if self.csv_reject_item? item

        ret << csv_event_class.create(csv_add_fields(item))
      end

      ret
    end
  end

  module XmlImportImplementation
    def can_import?(target)
      begin
        doc = XmlImportImplementation.open_file_or_url(target)
        items = doc.xpath(self.xml_item_nodename)

        return self.xml_header_map.keys.all? { |k| not items.xpath(k).empty? }
      rescue
        p $!.message
        return false
      end
    end

    def xml_custom_parser_map; {}; end

    def import(target)
      doc = XmlImportImplementation.open_file_or_url(target)

      items = doc.xpath(self.xml_item_nodename)
      ret = items.map do |node|
        current = {}
        self.xml_header_map.each do |path,prop_name| 
          data = node.xpath(path).text
          current[prop_name] = self.class.send(self.xml_data_transformer_map[prop_name], data)
        end

        self.xml_custom_parser_map.each do |path,parse_func|
          this_node = node.xpath(path)
          current.merge! self.class.send(parse_func, this_node)
        end

        self.xml_event_class.create(self.xml_add_fields(current))
      end
    end

    def self.open_file_or_url(target)
      return target if target.respond_to? :xpath

      doc = nil
      if (target.starts_with? "http")
        doc = Nokogiri::XML(open(target))
      else
        doc = Nokogiri::XML(File.open(target))
      end

      doc
    end
  end
end
