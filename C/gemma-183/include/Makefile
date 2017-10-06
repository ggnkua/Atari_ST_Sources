DIRS= gemma mint

install:
	@for file in $(DIRS); do \
		if [ -f $(GNUINC)/$$file ]; then \
			mkdir $(GNUINC)/$$file; \
		fi; \
		cp -v -R $$file $(GNUINC)/; \
	done
