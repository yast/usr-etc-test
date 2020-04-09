#
# spec file for package yast2-usr-etc-test
#
# Copyright (c) 2020 SUSE LINUX Products GmbH, Nuernberg, Germany.
#
# All modifications and additions to the file contributed by third parties
# remain the property of their copyright owners, unless otherwise agreed
# upon. The license for this file, and modifications and additions to the
# file, is the same license as for the pristine package itself (unless the
# license for the pristine package is not an Open Source License, in which
# case the license is the MIT License). An "Open Source License" is a
# license that conforms to the Open Source Definition (Version 1.9)
# published by the Open Source Initiative.

# Please submit bugfixes or comments via http://bugs.opensuse.org/
#


######################################################################
#
# IMPORTANT: Please do not change spec file in build service directly
#            Use https://github.com/yast/usr-etc-check
#
######################################################################

Name:           yast2-usr-etc-check
Version:        0.0.1
Release:        0
BuildArch:      noarch

BuildRoot:      %{_tmppath}/%{name}-build
Source0:        %{name}-%{version}.tar.bz2

BuildRequires:  rubygem(%{rb_default_ruby_abi}:rspec)
BuildRequires:  rubygem(%{rb_default_ruby_abi}:yast-rake)

Requires:       rubygem(%{rb_default_ruby_abi}:rspec)
Requires:       rubygem(%{rb_default_ruby_abi}:yast-rake)
Requires:       wget

Summary:        YaST2 - Checking /usr/etc/ directory for new entries.
Group:          System/YaST
License:        GPL-2.0 or GPL-3.0
Url:            https://github.com/yast/usr-etc-test

%description
Checking /usr/etc/ directory for new entries.

%prep
%setup -n %{name}-%{version}

%check
rake test:unit

%install

%files
%defattr(-,root,root)
