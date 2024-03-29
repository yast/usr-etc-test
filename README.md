
/usr/etc and /etc/\*/\*.d check
==============================

[![CI](https://github.com/yast/usr-etc-test/workflows/CI/badge.svg?branch=master)](
https://github.com/yast/usr-etc-test/actions?query=workflow%3ACI+branch%3Amaster)


This project checks and reports all changes in `/usr/etc` and `/etc/*/*.d`
in order to give the YaST team the possibility to adapt the YAST modules to that
changes too.

## Workflow

- Run test with `./usr_etc_check.rb <repository_url> <known_changes.yml>`
- Example: `./usr_etc_check.rb https://download.opensuse.org/tumbleweed/repo/oss tumbleweed_known_changes.yml`
- The test
  - Downloads the `*-filelists.xml.gz` from the given repository
  - Extracts a list of all configuration files in `/etc/*/*.d` and `/usr/etc`
  - Compares this list with the known changes list YAML file
  - Reports the new entries which where not found

## Packages Required for Running Test

- A Ruby interpreter

## Running the Check

*The check has been disabled as it is not useful anymore and only reports
lots of false positives.*
