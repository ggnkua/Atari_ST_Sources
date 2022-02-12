CFLAGS	= -O -D_MINIX -D_POSIX_SOURCE

CHMEM	= chmem

SCR	= run sh1 sh2
BIN	= test0 test1 test2 test3 test4 \
	  test5 test6 test7 test8 test9 \
	  test10 test11 test12 test13 test14 \
	  test15 test16 test17 test18 test19 \
	  test20 test21 t10a t11a t11b
CMD	= $(BIN) $(SCR)

all:	$(CMD) run

clean:
	rm -f *.o

clobber:
	rm -f $(CMD)

run:	run.sh
	cp $@.sh $@; chmod +wx $@
sh1:	sh1.sh
	cp $@.sh $@; chmod +wx $@
sh2:	sh2.sh
	cp $@.sh $@; chmod +wx $@

test0:	test0.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test1:	test1.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test2:	test2.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test3:	test3.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test4:	test4.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test5:	test5.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test6:	test6.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test7:	test7.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test8:	test8.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test9:	test9.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test10:	test10.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test11:	test11.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test12:	test12.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test13:	test13.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test14:	test14.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =20000 $@
test15:	test15.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test16:	test16.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test17:	test17.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test18:	test18.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test19:	test19.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
test20:	test20.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =65000 $@
test21:	test21.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
t10a:	t10a.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
t11a:	t11a.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
t11b:	t11b.c
	$(CC) $(CFLAGS) $@.c -o $@; $(CHMEM) =8192 $@
