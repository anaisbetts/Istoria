require 'types'
require 'pathname'
require 'nokogiri'
require 'open-uri'

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

    ret += (new TumblrQuoteParser).import(doc)
  end
end

class TumblrQuoteParser
  include Istoria::XmlImportImplementation

  XmlHeaderMap = {
    "quote-text" => :text,
    "@format" => :format
    "@url-with-slug" => :original_uri,
    "@date-gmt" => :authored_on,
    "quote-source" => :title,
  }

  XmlDataTransformerMap = {
    :text => :passthrough,
    :format => :parse_tumblr_format,
    :original_uri => :passthrough,
    :authored_on => :parse_rfc2822_time,
    :title => :passthrough,
  }

  def xml_header_map
    XmlHeaderMap
  end

  def xml_data_transformer_map
    XmlDataTransformerMap 
  end

  def xml_event_class
    Message
  end

  def xml_item_nodename
    "post[@type='quote']"
  end

  def xml_add_fields(item)
    item[:tags] = [Tag.new(:name => "Tumblr", :type => Tag::SourceType)]
    item[:original_uri] = "http://twitter.com/#{item[:from]}/status/#{item[:twitter_id]}"
    item
  end

  class << self
    include Istoria::StandardParsers

    def parse_tumblr_format(value)
      return TextSupport::MarkdownFormat if value == "markdown"
      return TextSupport::HtmlFormat if value == "html"
      TextSupport::PlainTextFormat 
    end
  end
end
