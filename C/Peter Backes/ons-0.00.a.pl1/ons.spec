#
# RPM spec file for package OUR NEXT STEP
# 
# Please send bugfixes or comments to <m.hoffmann@uni-bonn.de>.
#

Summary: The GFABASIC4 development package
Vendor: PLASMA
Name: ons
Version: 0.00.a.pl1
Release: 1
Copyright: GPL
Group: Development/Languages
Source: http://www-cip.uni-bonn.de/~hoffmann/X11-Basic/%{name}-%{version}.tar.gz
URL: http://www-cip.uni-bonn.de/~hoffmann/X11-Basic
Packager: Markus Hoffmann <m.hoffmann@uni-bonn.de>
BuildRoot: %{_tmppath}/%{name}-%{version}-root

%description
OUR NEXT STEP aims at growing into a full featured, cross platform 
development system retaining compatibility to the famous GFA-BASIC from
ATARI.  It is far from being complete because most of the source which
was written in 1992-1996 still needs to be converted from GFA-BASIC 3.6 
to C.

%package gfalist
Summary: Token processor that makes GFA files readable
Group: Development/Tools

%description gfalist
A handy utility named gfalist which reads binary *.GFA files from 
GFA-BASIC V3.5/3.6 and outputs the decoded data in the host system's 
character set.

%prep
%setup -q

%build
make sky/libsky.a
make sky/gfalist
make CHANGELOG

%install
mkdir $RPM_BUILD_ROOT

cd $RPM_BUILD_ROOT
mkdir -p .%{_mandir}/man1 .%{_bindir} .%{_includedir}/ons/sky .%{_libdir}
cd -

install -s -m 755 sky/gfalist $RPM_BUILD_ROOT%{_bindir}/gfalist
cp sky/tables.h sky/sky.h sky/version.h $RPM_BUILD_ROOT%{_includedir}/ons/sky
cp sky/libsky.a $RPM_BUILD_ROOT%{_libdir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc README COPYING CHANGELOG
%dir %{_includedir}/ons
%dir %{_includedir}/ons/sky

%{_bindir}/gfalist
%{_includedir}/ons/sky/version.h
%{_includedir}/ons/sky/sky.h
%{_includedir}/ons/sky/tables.h

%files gfalist
%defattr(-,root,root)
%doc README COPYING sky/HISTORY
%{_bindir}/gfalist

%changelog
* Mon Sep 10 2001 Peter Backes <rtc@gmx.de>
- Include library and headers.
- Subpackage with only gfalist

* Tue Sep  7 2001 Markus Hoffmann <m.hoffmann@uni-bonn.de> 
- 1st release

