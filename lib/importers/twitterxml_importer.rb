require 'types'
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
    "status"
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
