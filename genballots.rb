#!/usr/bin/env ruby
# coding: utf-8
#
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


PREAMBLE=<<EOS
TSC Covert Voting Ballot
°°°°°°°°°°°°°°°°°°°°°°°°

Insert your vote here:


Following is the cryptographic signature of the voting ballot. DO NOT
CHANGE THE BELOW!
EOS

SIGNEDPART=<<EOS
Ballot ID: %s

This is a cryptographically signed voting ballot for taking part
in TSC covert voting. Enter your vote above and then upload
this voting ballot to the page the vote taker has advertised to you.

The ballot ID above is a combination of characters unique for each
voting ballot. It prevents voting of unauthorised people and double
votes.
EOS

if ARGV.count != 1
  puts "USAGE: genballots.rb GPGKEY < email_addresses.txt"
  exit 1
end

puts "Reading mail addresses from standard input..."
mail_addresses = $stdin.read.split("\n").sort
puts "Done reading mail addresses."

gpgkey = ARGV[0]
puts "Will use GPG key #{gpgkey} for signing the ballots."

Dir.mkdir("/tmp/votingballots") unless Dir.exist?("/tmp/votingballots")

mail_addresses.each_with_index do |address, i|
  signedpart = sprintf(SIGNEDPART, Array.new(12){ ("a".."z").to_a.sample }.join(""))

  puts "Creating voting ballot #{i} for address #{address}..."

  # Signed part
  File.open("/tmp/signedpart.txt", "w"){|f| f.write(signedpart)}
  system("gpg --local-user=#{gpgkey} --batch --clearsign /tmp/signedpart.txt") || raise("Error while signing")

  File.open("/tmp/votingballots/#{i}.ballot", "w") do |file|
    file.puts(PREAMBLE)
    file.puts
    file.puts(File.read("/tmp/signedpart.txt.asc"))
  end

  File.unlink("/tmp/signedpart.txt")
  File.unlink("/tmp/signedpart.txt.asc")
end

puts "Done. The generated voting ballots are in /tmp/votingballots. Now send"
puts "each of those to one of the email addresses you handed into this program."
