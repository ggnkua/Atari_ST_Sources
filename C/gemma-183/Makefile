ALL= libgemma libslb src
LIB= libgemma libslb

all: gemma libs

gemma:
	@echo "# Building the shared library..."
	@make -C src/

libs:
	@echo "# Building the static modules..."
	@for file in $(LIB) ; do \
		cd $$file; make; make clean; \
		make -f Makefile.000; make clean; \
		cd ..; \
	done

libtest:
	@echo "# Doing a test..."
	make -C libgemma/

install: gemma.slb
	cp gemma.slb $(SLBPATH)
	chmod 755 $(SLBPATH)/gemma.slb

libinstall:
	make -C include/ install
	make -C lib/ install

clean:
	@echo "# Doing global clean up..."
	@for file in $(ALL) ; do \
		cd $$file; make clean ; cd .. ;\
	done

veryclean:
	@echo "# Doing global super-clean up..."
	@for file in $(ALL) ; do \
		cd $$file; make veryclean ; cd .. ;\
	done
