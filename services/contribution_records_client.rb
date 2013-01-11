#
# reads a file of lines with tab separated fields containing information
# the contributions made to idaho political candidates and
# uploads the information into the TFI Candidate Info database
#

require 'rubygems'
require 'optparse'
require 'active_resource'

class Contribution < ActiveResource::Base
  #self.site = "http://localhost:3000"
  self.site = "http://immense-forest-6797.herokuapp.com/"
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

  options[:elected] = ""
  opts.on( '-e', '--elected FILE', "Mandatory argument, list of elected legislators" ) do|f|
    options[:elected] = f
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

legislators = Hash.new
if options[:elected].nil? or options[:elected].empty?
  puts "Must provide a file containing the elected officials"
else
  line_number = 0
  puts "Reading #{options[:elected]} to find the candidates that were elected"
  File.open(options[:elected]).each do |record|
    line_number += 1
    if line_number > 1  # skip first line of column headers
      if record.chomp != "\t\t\t"
        fields = record.chomp.split("\t")
        entire_name =  fields[5].gsub(/^\"/, "").gsub(/\"$/, "").gsub(/\"\"/, '"')
        name = entire_name.split(" ")
        #print "#{entire_name}\t #{name.length}\n"

        first = name[0]
        middle = ""
        last = ""
        suffix = ""
        if name.length == 2
          first = name[0]
          last = name[1]
        elsif name.length == 3
          first = name[0]
          middle = name[1]
          last = name[2]
          if middle =~ /^Van/
            ## prepend middle to last name
            last = middle + " " + last
            middle = ""

          elsif first =~ /\.$/
            # append middle to first
            first = first + " " + middle
            middle = ""
          end

        else
          if name[name.length-1] =~ /\.$/
            #print "#{name[name.length-1]} is a suffix use "
            middle = name[1]
            last = name[name.length-2]
            suffix = name[name.length-1]
          elsif name[1] =~ /\.$/
            # middle name is abbreviation, ignore anything between middle and last
            last = name[name.length-1]
            middle = name[1]
          elsif name[1] =~ /^An$/
            # append to first, ex.:  "Jo An E. Wood"
            first << " " + name[1]
            middle = name[2]
            last = name[3]
          else
            last = name[name.length-1]
          end
        end

        #print "#{first}, #{middle}, #{last}, #{suffix}\n"
        legislators[last] = {:first => first, :middle => middle, :suffix => suffix}
      end
    end
  end


  if options[:verbose]
    puts "Elected Legislators"
    legislators.each_pair do | key, value|
      print "#{key}, #{value}\n"
    end
  end

end

ARGV.each do|f|
   puts "adding candidates, contribitors and contributions from #{f}..."

  # 2012 Election data file, 2012_cand_cont.txt, format by column
  # Field, Name,         Description
  #   0   CandLast     Candidate's Last or Family Name
  #   1   CandFirst    Candidate's First Name
  #   2   CandMid      Candidate's Middle Name or Initial
  #   3   CandSuf      Candidate's Suffix, ex Jr.
  #   4   CandParty    Name of the Political Party for the Candidate
  #   5   CandDistrict District number
  #   6   CandOffice   Political Office the candidate it running for
  #   7   ContrType    Contribution type: cash, inkind, loan
  #   8   ContrDate    when the contribition was given
  #   9   ContrAmount  how much was given
  #  10   ContrCP      If the Contributor is a Company or Person
  #  11   ContrName    Contributor's last name
  #  12   ContrFirst   Contributor's first name (if any)
  #  13   ContrMid     Contributor's middle name (if any)
  #  14   ContrSuf     Contributor's suffix
  #  15   ContrMail1   Contributor's mailing address, line 1
  #  16   ContrMail2   Contributor's mailing address, line 2
  #  17   ContrCity    Contributor's mailing address, the city
  #  18   ContrState   Contributor's mailing address, the state
  #  19   ContrZip     Contributor's mailing address, the zip code
  #  20   ContrCountry Contributor's mailing address, the country
  #

  line_number = 0
  File.open(f).each do |record|
    line_number += 1
    if line_number > 1  # skip first line of column headers
      if record.chomp != "\t\t\t"

        fields = record.chomp.split("\t")
        date_fields = fields[8].split("/")
        contrib_date = "#{date_fields[2]}-#{date_fields[0]}-#{date_fields[1]}"
        Contribution.create(:date              => Date.parse(contrib_date).to_formatted_s(:db),
                            :amount            => fields[9].tr('",', ''),
                            :contribution_type => fields[7],
                            :candidates_attributes => {
                              :year     => "2012-09-13",
                              :elected  => (legislators[fields[0]].nil? ? false : true),
                              :last     => fields[0],
                              :suffix   => fields[3],
                              :first    => fields[1],
                              :middle   => fields[2],
                              :party    => fields[4],
                              :district => fields[5],
                              :office   => fields[6]
                            },
                            :contributors_attributes => {
                              :kind    => fields[10],
                              :last    => fields[11],
                              :suffix  => fields[14],
                              :first   => fields[12],
                              :middle  => fields[13],
                              :mailing1 => fields[15],
                              :mailing2 => fields[16],
                              :city    => fields[17],
                              :state   => fields[18],
                              :zip     => fields[19],
                              :country => fields[20]
                            })
      end
    end
  end
end


