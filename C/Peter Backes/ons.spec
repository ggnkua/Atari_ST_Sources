#
# RPM spec file for package OUR NEXT STEP
# 
# Please send bugfixes or comments to <m.hoffmann@uni-bonn.de>.
#

Summary: The GFABASIC4 development package
Vendor: PLASMA
Name: ons
Version: 0.01.a
Release: 1
License: GPL
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
to C.  Currently it contains only a handy utility named gfalist which 
reads binary *.GFA files from GFA-BASIC V3.5/3.6 and outputs the 
decoded data in the host system's character set.

%prep
%setup -q

%build
make libsky.a gfalist

%install
mkdir $RPM_BUILD_ROOT

cd $RPM_BUILD_ROOT
mkdir -p .%{_mandir}/man1 .%{_bindir} .%{_includedir}/ons/sky .%{_libdir}
cd -

install -p -s -m 755 gfalist $RPM_BUILD_ROOT%{_bindir}/gfalist
cp -p tables.h sky.h $RPM_BUILD_ROOT%{_includedir}/ons/sky
cp -p version.h $RPM_BUILD_ROOT%{_includedir}/ons
cp -p libsky.a $RPM_BUILD_ROOT%{_libdir}

%clean
test "$RPM_BUILD_ROOT" != / && rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%doc README COPYING HISTORY
%dir %{_includedir}/ons
%dir %{_includedir}/ons/sky

%{_bindir}/gfalist

%{_includedir}/ons/sky/*.h
%{_includedir}/ons/*.h
%{_libdir}/libsky.a

%changelog
* Mon Sep  9 2002 Peter Backes <rtc@gmx.de> 0.00.a.pl11-1
- Removed version.h from package as it's not required.
- Replaced obsolete Copyright tag by License tag.
- Removed gfalist subpackage as it's all contained in the main one.
- Timestamp preservation and general cleanup.
- Adjusted paths to new flat scheme.
- Re-added version.h as ons, not sky component.

* Mon Sep 10 2001 Peter Backes <rtc@gmx.de>
- Include library and headers.
- Subpackage with only gfalist

* Tue Sep  7 2001 Markus Hoffmann <m.hoffmann@uni-bonn.de> 
- 1st release

