#!/usr/bin/env ruby
# Covert TSC voting process software.
# Copyright (C) 2016 The TSC Team
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

require "sinatra"

Dir.mkdir("ballots") unless Dir.exist?("ballots")

get "/" do
  erb :index
end

post "/votingballot" do
  halt 400 unless params["votingballot"]

  last = Dir["ballots/*.ballot"].sort.last
  if last
    last = last.split("/").last.sub(".ballot", "").to_i
  else
    last = 0
  end

  # Copy tempfile to the results dir. This service is intended to be only
  # run for a very short period of time, hence no size checks here.
  File.open(sprintf("ballots/%03d.ballot", last + 1), "w") do |f|
    f.write(params["votingballot"][:tempfile].read)
  end

  erb :donevoting
end

get "/results" do
  @ballots = Dir["ballots/*.ballot"].map{|path| File.read(path)}
  erb :results
end

get "/guide" do
  erb :guide
end
