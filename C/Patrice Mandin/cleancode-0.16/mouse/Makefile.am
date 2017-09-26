bin_PROGRAMS = moaeev.prg moaegr.prg movd.tos mode.tos moxb.tos moikin.tos

moaeev_prg_SOURCES = aes_evnt.c

moaegr_prg_SOURCES = aes_graf.c

movd_tos_SOURCES = vdi.c vdi_it.S

mode_tos_SOURCES = mouse.c

moxb_tos_SOURCES = xbios_it.S xbios.c

moikin_tos_SOURCES = ikbdintr.c
moikin_tos_LDADD = $(top_builddir)/common/libikbd.a

INCLUDES = -I$(top_srcdir)/common

EXTRA_DIST = xbios_it.h vdi_it.h
