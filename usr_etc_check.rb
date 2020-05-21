#! /usr/bin/env ruby
# frozen_string_literal: true

# Copyright (c) [2020] SUSE LLC
#
# All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify it
# under the terms of version 2 of the GNU General Public License as published
# by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, contact SUSE LLC.
#
# To contact SUSE LLC about this file by physical or electronic mail, you may
# find current contact information at www.suse.com.
#
#
# Checking *-filelists.xml.gz for /usr/etc and /etc/*.d entries which are
# currently not handled by YaST.
#

require "open-uri"
require "rexml/document"
require "rexml/streamlistener"
require "uri"
require "yaml"
require "zlib"

abort_handler = proc {
  warn "\nAborted"
  exit 1
}

# allow aborting via Ctr+C
Signal.trap("INT", abort_handler)
Signal.trap("TERM", abort_handler)

# HACK: this is needed for the openSUSE mirroring, the default Ruby
# implementation forbids the HTTPS -> HTTP redirection for security reasons,
# unfortunately that's used by the openSUSE mirrors... :-o
module OpenURI
  def self.redirectable?(_uri1, _uri2)
    true
  end
end

# a generic HTTP downloader
class Downloader
  attr_reader :url

  # Create the downloader for the specified URL (only HTTP/HTTPS is supported)
  # @param url [String] the URL for downloading
  def initialize(url)
    @url = URI(url)
  end

  # download the file, returns the response body or if a block is given it
  # passes the response stream to it, handles HTTP redirection automatically
  def download(&block)
    puts "Downloading #{url}..."

    if block_given?
      URI.open(url) { |f| block.call(f) }
    else
      URI.open(url, &:read)
    end
  end
end

# RepoMD parser, downloads and parses the main repository index file
# (repomd.xml) and returns the full path to the filelist.xml.gz file
class RepoIndexParser
  attr_reader :repo

  def initialize(repo)
    @repo = repo
  end

  # get the full name of the filelist.xml.gz file
  def filelists
    downloader = Downloader.new(File.join(repo, "repodata/repomd.xml"))
    # the repomd.xml file is small, we can read it whole into memory
    doc = REXML::Document.new(downloader.download)
    # read the value from XML using XPath
    path = REXML::XPath.first(doc, "//data[@type='filelists']/location")
      .attribute("href").value
    # add the URL prefix to get a complete URL path
    File.join(repo, path)
  end
end

# Collect the file paths from the XML, use the XML SAX (streaming) parser
# because the uncompressed XML is huge (>650MB!), do not read the whole file
# into memory!
class FileListener
  include REXML::StreamListener

  attr_reader :files, :packages

  def initialize
    @files = {}
    # count the packages to show some progress
    @packages = 0
  end

  def tag_start(tag, attrs)
    case tag
    when "file"
      @in_file_tag = true
    when "package"
      @package = attrs["name"]
      @packages += 1
      # print a progress dot for each 1000 processed packages
      print "." if @packages % 1000 == 0
    end
  end

  def text(data)
    return unless @in_file_tag

    # bsc#1166473
    if data.match(/^\/etc\/\S*\.d\//) || data.start_with?("/usr/etc/")
      files[data] = @package
    end

    @in_file_tag = false
  end
end

# collects the etc files from a remote (HTTP) filelist.xml.gz file
class EtcFilesCollector
  attr_reader :xml_url

  def initialize(xml_url)
    @xml_url = xml_url
    @listener = FileListener.new
  end

  def files
    # directly parse the XML gzipped data while downloading
    downloader = Downloader.new(xml_url)
    downloader.download do |stream|
      reader = Zlib::GzipReader.new(stream)
      REXML::Document.parse_stream(reader, @listener)
    end

    @listener.files
  end

  def packages
    @listener.packages
  end
end

# compares the found etc files with the known files in the configuration file
class EtcVerifier
  attr_reader :files, :config

  def initialize(files, config_file)
    @files = files
    @config = YAML.load_file(config_file)
  end

  def new_entries
    files.reject do |f, p|
      config.any? do |c|
        c["files"].any? { |glob| File.fnmatch?(glob, f) }
      end
    end
  end
end

# the main application
class Application
  attr_reader :repo_url, :config_file

  def initialize
    @repo_url = ARGV[0]
    @config_file = ARGV[1]

    return if repo_url && config_file

    warn "Missing repository or config file parameter!"
    exit 1
  end

  def run
    # collect the config files
    repo_parser = RepoIndexParser.new(repo_url)
    collector = EtcFilesCollector.new(repo_parser.filelists)

    # compare them with the white list
    verifier = EtcVerifier.new(collector.files, config_file)
    unknown = verifier.new_entries

    puts "\nProcessed #{collector.packages} packages\n\n"

    if unknown.empty?
      puts "OK, nothing new found"
    else
      puts "Found #{unknown.size} new files/directories, please check them:\n\n"
      unknown.each do |f, p|
        puts "#{f} (package: #{p})"
      end
      exit 1
    end
  end
end

app = Application.new
app.run
