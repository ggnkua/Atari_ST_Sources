bin_PROGRAMS = dixh.ttp

noinst_LIBRARIES = libxhdi.a

libxhdi_a_SOURCES = xhdi.c

dixh_ttp_SOURCES = xhdidemo.c
dixh_ttp_LDADD = $(top_builddir)/common/libparam.a \
	libxhdi.a

INCLUDES = -I$(top_srcdir)/common

EXTRA_DIST = xhdi.h
