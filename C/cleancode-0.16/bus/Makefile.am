bin_PROGRAMS = bupc.ttp busc.ttp

noinst_LIBRARIES = libpci.a libscsi.a

libpci_a_SOURCES = pci.c pcinames.c
libscsi_a_SOURCES = scsidrv.c scsi.c scsinames.c

bupc_ttp_SOURCES = bus_pci.c 
bupc_ttp_LDADD = $(top_builddir)/common/libparam.a \
	libpci.a

busc_ttp_SOURCES = bus_scsi.c
busc_ttp_LDADD = $(top_builddir)/common/libparam.a \
	libscsi.a

INCLUDES = -I$(top_srcdir)/common

EXTRA_DIST = pci.h pcinames.h pci.ids scsidrv.h scsi.h scsinames.h
