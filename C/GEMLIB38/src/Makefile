#
# Toplevel Makefile for GEM lib
#

all: gem gemx gem16 gemx16

gem:
	@echo "Making gem"
	@LIB="-f Makefile.gem gem.a"; OUT_DIR=32bit; XFLAGS=""; \
	 export LIB OUT_DIR XFLAGS; $(MAKE) dir

gemx:
	@echo "Making gemx"
	@LIB="-f Makefile.gemx gemx.a"; OUT_DIR=32bit; XFLAGS=""; \
	 export LIB OUT_DIR XFLAGS; $(MAKE) dir

gem16:
	@echo "Making gem 16"
	@LIB="-f Makefile.gem gem16.a"; OUT_DIR=16bit; XFLAGS="-mshort"; \
	 export LIB OUT_DIR XFLAGS; $(MAKE) dir

gemx16:
	@echo "Making gemx 16"
	@LIB="-f Makefile.gemx gemx16.a"; OUT_DIR=16bit; XFLAGS="-mshort"; \
	 export LIB OUT_DIR XFLAGS; $(MAKE) dir

dir:
	@ if test ! -d $(OUT_DIR);\
        then\
	  echo "Creating object target directory $(OUT_DIR)";\
          mkdir $(OUT_DIR);\
        fi
	@$(MAKE) $(LIB)

clean :
	rm -rf 16bit/* 32bit/*
