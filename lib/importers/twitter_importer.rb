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
