# Makefile fuer testmenu.prg

testmenu.prg: testmenu.o
	$(CC) -o testmenu.prg testmenu.o $(LIBPATH)\libmenu.a $(LIBPATH)\libterm.a $(LIBPATH)\libstr.a

.c.o: $(CC) $(CFLAGS)

