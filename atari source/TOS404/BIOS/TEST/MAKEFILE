keymodes.prg: testkey.o vtg.o
	lcc -w -b0 -bn -o $@ $<

vtg.o: ..\vtgb.c
	lcc -c -DTEST -DSPARROW=1 -w -b0 -bn -r0 -m3 -d2 -O -hd3 -ha3 -o $@ $<
