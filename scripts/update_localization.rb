#!/usr/bin/env ruby
# frozen_string_literal: true

# List of locales, edit this to add new ones:
LOCALES = %w[en fr].freeze

require 'optparse'
require_relative '../RubySetupSystem/RubyCommon'

@options = {
  pot_suffix: '.pot',
  po_suffix: '.po'
}

OptionParser.new do |opts|
  opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

  opts.on('--pot-suffix suffix',
          'Set custom .pot suffix') do |suffix|
    @options[:pot_suffix] = suffix
  end
  opts.on('--po-suffix suffix',
          'Set custom .po suffix') do |suffix|
    @options[:po_suffix] = suffix
  end
end.parse!

onError "Unhandled parameters: #{ARGV}" unless ARGV.empty?

ROOT_FOLDER = File.expand_path(File.join(File.dirname(__FILE__), '../'))
LOCALE_FOLDER = File.join ROOT_FOLDER, 'locale'

puts "Detected Thrive root folder: #{ROOT_FOLDER}"

Dir.chdir(LOCALE_FOLDER) do
  puts 'Extracting .pot file'

  runOpen3Checked 'pybabel', 'extract', '-F', File.join(LOCALE_FOLDER, 'babelrc'), '-k',
                  'LineEdit', '-k', 'text', '-k', 'DisplayName', '-k', 'window_title', '-k',
                  'dialog_text', '-k', 'Translate', '-o',
                  File.join(LOCALE_FOLDER, 'messages' + @options[:pot_suffix]),
                  '../simulation_parameters', '../assets', '../src'

  success 'Done extracting .pot file'

  info 'Extracting .po files'

  LOCALES.each do |locale|
    puts "Extracting #{locale}.po"
    runOpen3Checked 'msgmerge', '--update', '--backup=none',
                    locale + @options[:po_suffix],
                    'messages' + @options[:pot_suffix]
  end
end

success 'Done extracting .po files'
