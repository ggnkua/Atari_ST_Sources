include build.conf
#-------------------------------------------------------------------------------
ifneq ($(MAKECMDGOALS),clean)

-include $(CACHEDIR)/buildcache2.mk

TARGET = $(CACHEDIR)/buildcache2.mk

$(TARGET): $(BUILDFILES)	
	@echo No cached build information found or build files were changed.
	@echo Forcing full rebuild.	
	@rm -f $(CACHEDIR)/*
	@if [ -d $(CACHEDIR) ]; then rmdir $(CACHEDIR); fi
	@rm -f $(TARGET)
	@printf "Scanning for buildfiles..."
	@python ../buildhelper.py -build $(ROOTDIR) $(BUILDDIR) $(CACHEDIR) $(BUILDNAME)
	@printf "done.\n"
else
clean:
endif

#-------------------------------------------------------------------------------
