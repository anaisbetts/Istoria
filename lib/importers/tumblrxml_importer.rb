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

require 'pathname'
require 'nokogiri'
require 'open-uri'

require 'lib/types'
require 'lib/importers'

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
    ret += (TumblrPhotoParser.new).import(doc)
    ret += (TumblrAudioParser.new).import(doc)
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

class TumblrAudioParser
  include Istoria::XmlImportImplementation

  XmlHeaderMap = {
    'audio-caption'  => :text,
    '@format' => :format,
    '@url-with-slug' => :original_uri,
    'audio-player' => :data,
    '@date-gmt' => :authored_on,
  }

  XmlDataTransformerMap = {
    :text => :unescape_html,
    :format => :parse_tumblr_format,
    :original_uri => :passthrough,
    :data => :tumblr_download_audio,
    :authored_on => :parse_rfc2822_time,
  }

  def xml_header_map; XmlHeaderMap; end
  def xml_data_transformer_map; XmlDataTransformerMap; end
  def xml_event_class; Media; end

  def xml_item_nodename
    "//post[@type='audio']"
  end

  def xml_add_fields(item)
    item[:tags] = [Tag.new(:name => "Tumblr", :type => Tag::SourceType)]
    item
  end
  
  class << self
    include TumblrParsers

    def tumblr_download_audio(value)
      embed_tag = CGI.unescapeHTML(value)
      download_uri = embed_tag.gsub(/^.*audio_file=(http.*?)&.*$/, '\1')
      open(download_uri)
    end
  end
end



class TumblrPhotoParser
  include Istoria::XmlImportImplementation

  XmlHeaderMap = {
    'photo-caption'  => :text,
    '@format' => :format,
    '@url-with-slug' => :original_uri,
    'photo-link-url' => :tumblr_link,
    '@date-gmt' => :authored_on,
    '@type' => :tumblr_type,
    "photo-url[@max-width='1280']" => :data,
  }

  XmlDataTransformerMap = {
    :text => :passthrough,
    :format => :parse_tumblr_format,
    :original_uri => :passthrough,
    :tumblr_link => :passthrough,
    :authored_on => :parse_rfc2822_time,
    :tumblr_type => :passthrough,
    :data => :download_uri,
  }

  def xml_header_map; XmlHeaderMap; end
  def xml_data_transformer_map; XmlDataTransformerMap; end
  def xml_event_class; Media; end

  def xml_item_nodename
    "//post[@type='photo']"
  end

  def xml_add_fields(item)
    item[:tags] = [Tag.new(:name => "Tumblr", :type => Tag::SourceType)]
    item
  end
  
  class << self
    include TumblrParsers
  end
end

class TumblrConversationParser
  include Istoria::XmlImportImplementation

  XmlHeaderMap = {
    'conversation-title'  => :title,
    '@format' => :format,
    '@url-with-slug' => :original_uri,
    '@date-gmt' => :authored_on,
    '@type' => :tumblr_type,
    'conversation-text' => :text
  }

  XmlDataTransformerMap = {
    :title => :passthrough,
    :format => :parse_tumblr_format,
    :original_uri => :passthrough,
    :authored_on => :parse_rfc2822_time,
    :tumblr_type => :passthrough,
    :text => :unescape_html,
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

  def xml_add_fields(item)
    item[:tags] = [Tag.new(:name => "Tumblr", :type => Tag::SourceType)]
    item[:text].gsub!(/\n/m, "#{NewLineForFormat[item[:format]]}\n") + "#{NewLineForFormat[item[:format]]}\n"
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
    '@type' => :tumblr_type,
  }

  XmlDataTransformerMap = {
    :title => :passthrough,
    :format => :parse_tumblr_format,
    :original_uri => :passthrough,
    :authored_on => :parse_rfc2822_time,
    :text => :passthrough,
    :tumblr_type => :passthrough,
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
    '@type' => :tumblr_type,
  }

  XmlDataTransformerMap = {
    :text => :passthrough,
    :format => :parse_tumblr_format,
    :original_uri => :passthrough,
    :authored_on => :parse_rfc2822_time,
    :title => :passthrough,
    :tumblr_type => :passthrough,
  }

  def xml_header_map; XmlHeaderMap; end
  def xml_data_transformer_map; XmlDataTransformerMap; end
  def xml_event_class; Message; end

  def xml_item_nodename
    "//post[@type='quote'] | //post[@type='regular']"
  end

  def xml_add_fields(item)
    item[:tags] = [Tag.new(:name => "Tumblr", :type => Tag::SourceType)]
    item
  end

  class << self
    include TumblrParsers
  end
end
