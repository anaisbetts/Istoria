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

unless $istoria_already_booted
  begin
    # Try to require the preresolved locked set of gems.
    require File.expand_path('../.bundle/environment', __FILE__)
  rescue LoadError
    # Fall back on doing an unlocked resolve at runtime.
    require "rubygems"
    require "bundler"
    Bundler.setup
  end

  # Always include the Istoria root path
  $:.unshift File.join(File.dirname(__FILE__), "..")

  $istoria_already_booted = true
end
