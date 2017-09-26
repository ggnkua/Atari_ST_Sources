bin_PROGRAMS = jsikin.tos jsxb.tos jpha.tos

jsxb_tos_SOURCES = xbios_it.S xbios.c

jsikin_tos_SOURCES = ikbdintr.c
jsikin_tos_LDADD = $(top_builddir)/common/libikbd.a

jpha_tos_SOURCES = joypad.c

INCLUDES = -I$(top_srcdir)/common

EXTRA_DIST = xbios_it.h
