bin_PROGRAMS = auxb.ttp

auxb_ttp_SOURCES = xbios.c calib_it.S
auxb_ttp_LDADD = $(top_builddir)/common/libparam.a \
	$(top_builddir)/common/libmxalloc.a

INCLUDES = -I$(top_srcdir)/common

EXTRA_DIST = gsxb.h stfa.h mcsn.h calib_it.h
