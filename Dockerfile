FROM registry.opensuse.org/yast/head/containers/yast-ruby:latest
RUN zypper --gpg-auto-import-keys --non-interactive in --no-recommends wget
COPY . /usr/src/app

