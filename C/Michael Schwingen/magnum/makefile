default:
	@echo Please specify target !

archive:
	-rm magnum.zoo
	UNIXMODE='/'; find . -type f -print | dumpfilt filter.inf | sort | zoo ahI magnum

clean:
	UNIXMODE='/'; rm *.o *.pdb *.lst *\*.pdb *.prg *.tos *.ttp *\*.bak *\*.dup *\foo*

.PHONY: archive clean default

