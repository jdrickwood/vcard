#!/usr/bin/env ruby

require 'digest/md5'
require 'fileutils'
require 'optparse'
require 'base64'

MAX_COUNT = 1000
avatars = []

first_names = ["Daenerys", "Jon", "Tyrion", "Arya", "Joffrey", "Catelyn", "Brienne", "Margaery", "Petyr", "Gregor", "Sansa", "Eddard"]
last_names = ["Targaryen", "Snow", "Lannister", "Stark", "Baratheon", "Tyrell", "Baelish", "Clegane"]
starting_number_uk = "447700900100"
starting_number_us = "15555550000"

options = {}
options[:avatar] = false

OptionParser.new do |opts|
    opts.banner = "Usage: duplicates.rb [options]"
    opts.on('-c', '--contacts-count int', Integer) { |c| options[:number] = c }
    opts.on('-a', '--[no-]avatar', "Add an avatar") { |a| options[:avater] = a }
end.parse!

unless options[:number] && options[:number] > 0 && options[:number] <= MAX_COUNT
    puts "you must enter a valid number between 1 and #{MAX_COUNT}"
    exit
end

if options[:avater]
    Dir.glob('images/*.jpg') do |avatar_file|
       avatars << avatar_file
    end
end

now = Time.now.strftime("%Y%m%d-%H%M")
filename = "contacts-#{now}.vcf"

# lets create the vcf file
File.open(filename, 'w') do |vcard|

    (0..options[:number]-1).each do |count|
        first_name = first_names.sample
        last_name = last_names.sample
        number_uk = starting_number_uk
        number_uk[-count.to_s.length]= count.to_s
        number_us = starting_number_us
        number_us[-count.to_s.length]= count.to_s
        
        vcard.write "BEGIN:VCARD\n"
        vcard.write "VERSION:3.0\n"
        vcard.write "N:#{last_name};#{first_name};;;\n"
        vcard.write "FN:#{first_name};#{last_name}\n"
        vcard.write "TEL;type=CELL;type=VOICE;type=pref:+#{number_uk}\n"
        vcard.write "TEL;type=CELL;type=VOICE;type=pref:+#{number_us}\n"
        
        if options[:avater]
            avatar = avatars.sample
            File.open(avatar, 'r') do|image_file|
                image = Base64.strict_encode64(image_file.read).scan(/.{1,60}/).join("\n ")
                vcard.write "PHOTO;ENCODING=b;TYPE=JPEG:\n #{image}\n"
            end
        end
        
        vcard.write "END:VCARD\n"
    end
    
    vcard.close

end