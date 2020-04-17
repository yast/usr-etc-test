/usr/etc and /etc/*/*.d check
==============================

This project checks and reports all changes around /usr/etc and /etc/*/*.d in order
to give the YAST team the possibility to adapt the YAST modules to the regarding
changes too.

## Workflow

- Run tests with "usr_etc_check.rb <distribution e.g. Factory>"
- Each test
    -- Downloads *-filelists.xml.gz from the given repository defined
       in repos_conf.yml.
    -- Extracts a list of all configuration files in /etc/*/*.d and /usr/etc.
    -- Compares this list with the white-list defined in
       <distribution>/white-list.yml.
    -- reports new entries which have to be checked by the YAST team.

## Packages Required for Running Test

- wget

