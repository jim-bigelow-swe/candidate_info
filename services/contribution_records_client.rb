require 'rubygems'
require 'optparse'
require 'active_resource'

#ActiveResource::Base.logger = Logger.new("#{File.dirname(__FILE__)}/events.log")

class Contribution < ActiveResource::Base
  self.site = "http://localhost:3000"
  #self.site = "http://tranquil-fortress-2636.herokuapp.com"
end


 # This hash will hold all of the options
 # parsed from the command-line by
 # OptionParser.
 options = {}

 optparse = OptionParser.new do|opts|
   # Set a banner, displayed at the top
   # of the help screen.
   opts.banner = "Usage: contribution_records_client.rb [options] file1 file2 ..."

   # Define the options, and what they do
   options[:verbose] = false
   opts.on( '-v', '--verbose', 'Output more information' ) do
     options[:verbose] = true
   end

   options[:delete] = false
   opts.on( '-d', '--delete', 'Delete every contribution record' ) do
     options[:delete] = true
   end

   # This displays the help screen, all programs are
   # assumed to have this option.
   opts.on( '-h', '--help', 'Display this screen' ) do
     puts opts
     exit
   end
 end


# Parse the command-line. Remember there are two forms
# of the parse method. The 'parse' method simply parses
# ARGV, while the 'parse!' method parses ARGV and removes
# any options found there, as well as any parameters for
# the options. What's left is the list of files to resize.
optparse.parse!

puts "Being verbose" if options[:verbose]

if options[:delete]
  puts "Deleting all contribution records ... just use rake db:reset w/ an empty seed.rb"
  exit
end

ARGV.each do|f|
   puts "adding candidates from #{f}..."


  line_number = 0
  File.open(f).each do |record|
    line_number += 1
    if line_number > 1  # skip first line of column headers
      if record.chomp != "\t\t\t"

        fields = record.chomp.split("\t")
        date_fields = fields[7].split("/")
        contrib_date = "#{date_fields[2]}-#{date_fields[0]}-#{date_fields[1]}"
        Contribution.create(:date              => Date.parse(contrib_date).to_formatted_s(:db),
                            :amount            => fields[8].tr('",', ''),
                            :contribution_type => fields[9],
                            :candidates_attributes => {
                              :year     => "2012-09-13",
                              :last     => fields[0],
                              :suffix   => fields[1],
                              :first    => fields[2],
                              :middle   => fields[3],
                              :party    => fields[4],
                              :district => fields[5],
                              :office   => fields[6]
                            },
                            :contributors_attributes => {
                              :last    => fields[10],
                              :suffix  => fields[11],
                              :first   => fields[12],
                              :middle  => fields[13],
                              :mailing => fields[14],
                              :city    => fields[15],
                              :state   => fields[16],
                              :zip     => fields[17]
                            })



      end
    end
  end
end


