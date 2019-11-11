scrolfix.acc: scrolfix.s
  mac.prg $(SFLAGS) -p -o scrolfix.acc scrolfix.s
  
archive:
    lharc a scrolfix *.acc *.s *.mak *.doc
