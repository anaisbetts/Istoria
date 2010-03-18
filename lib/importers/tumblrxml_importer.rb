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

include Istoria

class TumblrXmlImporter
  def can_import?(target)
      begin
        doc = XmlImportImplementation.open_file_or_url(target)
        items = doc.xpath("/tumblr")
        return (not items.empty?)
      rescue
        p $!.message
        return false
      end
  end

  def import(target)
    ret = []
    doc = XmlImportImplementation.open_file_or_url(target)

    ret += (TumblrQuoteOrTextParser.new).import(doc)
    ret += (TumblrLinkParser.new).import(doc)
    ret += (TumblrConversationParser.new).import(doc)
    ret
  end
end

module TumblrParsers
  include Istoria::StandardParsers

  def parse_tumblr_format(value)
    return TextSupport::MarkdownFormat if value == "markdown"
    return TextSupport::HtmlFormat if value == "html"
    TextSupport::PlainTextFormat 
  end
end

class TumblrConversationParser
  include Istoria::XmlImportImplementation

  XmlHeaderMap = {
    'conversation-title'  => :title,
    '@format' => :format,
    '@url-with-slug' => :original_uri,
    '@date-gmt' => :authored_on,
  }

  XmlDataTransformerMap = {
    :title => :passthrough,
    :format => :parse_tumblr_format,
    :original_uri => :passthrough,
    :authored_on => :parse_rfc2822_time,
  }
  
  NewLineForFormat = {
    TextSupport::MarkdownFormat => "  ",
    TextSupport::HtmlFormat => "<br/>",
    TextSupport::PlainTextFormat => "",
  }

  def xml_header_map; XmlHeaderMap; end
  def xml_data_transformer_map; XmlDataTransformerMap; end
  def xml_event_class; Message; end

  def xml_item_nodename
    "//post[@type='conversation']"
  end

  def xml_custom_node_parse(node, item)
    lines = node.xpath("//line").map do |l|
      "#{l.xpath("@label").text}: #{l.text}#{NewLineForFormat[item[:format]]}"
    end

    item[:text] = lines.join("\n")
    item
  end

  def xml_add_fields(item)
    item[:tags] = [Tag.new(:name => "Tumblr", :type => Tag::SourceType)]
    item[:original_uri] = "http://twitter.com/#{item[:from]}/status/#{item[:twitter_id]}"
    item
  end
  
  class << self
    include TumblrParsers
  end
end

class TumblrLinkParser
  include Istoria::XmlImportImplementation

  XmlHeaderMap = {
    'link-text'  => :title,
    '@format' => :format,
    'link-url' => :original_uri,
    '@date-gmt' => :authored_on,
    'link-description' => :text,
  }

  XmlDataTransformerMap = {
    :title => :passthrough,
    :format => :parse_tumblr_format,
    :original_uri => :passthrough,
    :authored_on => :parse_rfc2822_time,
    :text => :passthrough,
  }

  def xml_header_map; XmlHeaderMap; end
  def xml_data_transformer_map; XmlDataTransformerMap; end
  def xml_event_class; Message; end

  def xml_item_nodename
    "//post[@type='link']"
  end

  def xml_add_fields(item)
    if item[:text] == ""
      item[:format] = TextSupport::PlainTextFormat 
      item[:text] = item[:title]
      item.delete :title
    end

    item[:tags] = [Tag.new(:name => "Tumblr", :type => Tag::SourceType)]
    item[:original_uri] = "http://twitter.com/#{item[:from]}/status/#{item[:twitter_id]}"
    item
  end

  class << self
    include TumblrParsers
  end
end

class TumblrQuoteOrTextParser
  include Istoria::XmlImportImplementation

  XmlHeaderMap = {
    'quote-text | regular-body' => :text,
    '@format' => :format,
    '@url-with-slug' => :original_uri,
    '@date-gmt' => :authored_on,
    'quote-source | regular-title' => :title,
  }

  XmlDataTransformerMap = {
    :text => :passthrough,
    :format => :parse_tumblr_format,
    :original_uri => :passthrough,
    :authored_on => :parse_rfc2822_time,
    :title => :passthrough,
  }

  def xml_header_map; XmlHeaderMap; end
  def xml_data_transformer_map; XmlDataTransformerMap; end
  def xml_event_class; Message; end

  def xml_item_nodename
    "//post[@type='quote'] | //post[@type='regular']"
  end

  def xml_add_fields(item)
    item[:tags] = [Tag.new(:name => "Tumblr", :type => Tag::SourceType)]
    item[:original_uri] = "http://twitter.com/#{item[:from]}/status/#{item[:twitter_id]}"
    item
  end

  class << self
    include TumblrParsers
  end
end
