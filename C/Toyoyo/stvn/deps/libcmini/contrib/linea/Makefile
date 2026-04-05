CP=cp
RM=rm -f
MKDIR=mkdir -p

LIBCMINIDIR=../..
DIRS=include/mint
SRCFILES=sources/linea.c
INCFILES=include/mint/linea.h


install:	dirs
	@for f in $(SRCFILES) $(INCFILES);\
	do\
	  $(CP) $$f $(LIBCMINIDIR)/$$f;\
	done

uninstall:
	@for f in $(SRCFILES) $(INCFILES);\
	do\
	  $(RM) $(LIBCMINIDIR)/$$f;\
	done

dirs:
	@for dir in $(DIRS);\
	do\
	  $(MKDIR) $(LIBCMINIDIR)/$$dir;\
	done
