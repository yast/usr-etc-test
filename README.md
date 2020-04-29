/usr/etc and /etc/\*/\*.d check
==============================

File check result: &nbsp; [![Build Status](https://travis-ci.com/yast/yast2-usr-etc-test.svg?branch=master)](https://travis-ci.com/yast/yast2-usr-etc-test)

This project checks and reports all changes in `/usr/etc` and `/etc/*/*.d`
in order to give the YaST team the possibility to adapt the YAST modules to that
changes too.

## Workflow

- Run test with `./usr_etc_check.rb <repository_url> <whitelist.yml>`
- Example: `./usr_etc_check.rb https://download.opensuse.org/tumbleweed/repo/oss tumbleweed_white_list.yml`
- The test
  - Downloads the `*-filelists.xml.gz` from the given repository
  - Extracts a list of all configuration files in `/etc/*/*.d` and `/usr/etc`
  - Compares this list with the white list YAML file
  - Reports the new entries which where not found

## Packages Required for Running Test

- A Ruby interpreter
