#!/usr/bin/env ruby

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

require File.join(File.dirname(__FILE__), "..", "lib", "boot")

# Standard library
require 'logger'
require 'optparse'
require 'optparse/time'

# Istoria
require 'lib/types'
require 'lib/importers'

# Gettext hack
def _(v); v; end

$logging_level = ($DEBUG ? Logger::DEBUG : Logger::ERROR)

class IstoriaImportData < Logger::Application
	include Singleton

	def initialize
		super(self.class.to_s) 
		self.level = $logging_level
	end

	def parse(args)
		# Set the defaults here
    results = {
      :db_name => "istoria-staging",
    }

		opts = OptionParser.new do |opts|
			opts.banner = _("Usage: istoria-importdata [options] name key1 value1 key2 value2 ...")

			opts.separator ""
			opts.separator _("Specific options:")

			opts.on('-n', "--db-name", _("Database name to import to")) do |x|
        results[:db_name] = x
			end
			
      opts.separator ""
			opts.separator _("Common options:")

			opts.on_tail("-h", "--help", _("Show this message") ) do
				puts opts
				exit
			end

			opts.on('-d', "--debug", _("Run in debug mode (Extra messages)")) do |x|
				$logging_level = DEBUG
			end

			opts.on('-v', "--verbose", _("Run verbosely")) do |x|
				$logging_level = INFO 
			end

			opts.on_tail("--version", _("Show version") ) do
				puts OptionParser::Version.join('.')
				exit
			end
		end

		opts.parse!(args)

    unless (ARGV.count % 2 == 1)  ## Is odd (i.e. name + key-value pairs)
      puts _("name missing; see --help for more info")
      exit
    end

    results
	end

	def run
		self.level = Logger::DEBUG

		# Parse arguments
    results = {}
		begin
			results = parse(ARGV)
		rescue OptionParser::MissingArgument
			puts _('Missing parameter; see --help for more info')
			exit
		rescue OptionParser::InvalidOption
			puts _('Invalid option; see --help for more info')
			exit
		end

		# Reset our logging level because option parsing changed it
		self.level = $logging_level

    ##
    ## DO STUFF HERE
    ##

    to_import = ARGV[0]
    MongoMapper.database = results[:db_name]

    options = {}
    key = nil
    ARGV.unshift.each do |x|
      unless key
        key = x
        next
      end

      options[key.downcase.to_sym] = x
      key = nil
    end
    
    importer = Istoria.available_importers.collect {|x| x.new(options)}.find{|x| x.can_import? to_import}
    unless importer
      importers_tried = Istoria.available_importers.collect{|x| "'#{x.name}'"}.join(',')
      log ERROR, "Couldn't find any appropriate importer for '#{to_import}'"
      log ERROR, "We tried: #{importers_tried}"
      exit
    end

    log INFO, "Importing via #{importer.class.name}..."
    items = importer.import(to_import)

    stats = {}
    items.each {|x| stats[x.class.name] = (stats[x.class.name] || 0) + 1} 
    log INFO, "Collected: " + stats.collect {|k,v| "#{k}:#{v}"}.join(",")

		log DEBUG, 'Exiting application'
	end
end

exit 0 unless __FILE__ == $0

$the_app = IstoriaImportData.instance
$the_app.run
