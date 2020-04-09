/usr/etc check
===============

This project checks and reports all changes around /usr/etc in order to
give the YAST team the possibility to adapt the YAST modules to the regarding
changes too.

## Workflow

- A rspec test is defined for each single repository/distribution which has
  to be checked.
- Run tests with `rake test:unit` or manually one by one.
- Each test
    -- downloads *-filelists.xml.gz from the given repository defined
       in repos_conf.yml.
    -- extracts a list of all /usr/etc files.
    -- compares this list with the white-list defined in
       <distribution>/white-list.yml.
    -- reports new /usr/etc entries which has be be checked by the YAST team.

## Packages Required for Running Test

- rubygem(rspec)
- rubygem(yast-rake)
- wget

