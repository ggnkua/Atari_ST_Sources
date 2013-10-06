bin_PROGRAMS = viae.gtp vivd.ttp vixb.ttp

viae_gtp_SOURCES = aes.c vdi_com.c eddi.S rgb.c
viae_gtp_LDADD = $(top_builddir)/common/libparam.a \
	$(top_builddir)/common/libmxalloc.a

vivd_ttp_SOURCES = vdi.c vdi_com.c eddi.S rgb.c
vivd_ttp_LDADD = $(top_builddir)/common/libparam.a \
	$(top_builddir)/common/libmxalloc.a

vixb_ttp_SOURCES = xbios.c mvdi.c rgb.c vinside.c nova.c
vixb_ttp_LDADD = $(top_builddir)/common/libparam.a \
	$(top_builddir)/common/libmxalloc.a

INCLUDES = -I$(top_srcdir)/common

EXTRA_DIST = eddi_s.h mvdi.h rgb.h cscreen.h vdi_com.h \
	overscan.h vinside.h blowup.h nova.h
