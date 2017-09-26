bin_PROGRAMS = kbae.prg kbde.tos kbgd.tos kbbi.tos kbikin.tos kbikpo.tos

kbae_prg_SOURCES = aes.c

kbde_tos_SOURCES = console.c

kbgd_tos_SOURCES = gemdos.c

kbbi_tos_SOURCES = bios.c

kbikin_tos_SOURCES = ikbdintr.c
kbikin_tos_LDADD = $(top_builddir)/common/libikbd.a

kbikpo_tos_SOURCES = ikbdpoll.c

INCLUDES = -I$(top_srcdir)/common

