STUFF = caltone.omf memtest.omf pink.omf sloader.omf test-dac.omf \
	test-int.omf thru.omf reverb.omf flange.omf chorus.omf sixcomb.omf

M4 = m4
CPP = /lib/cpp

all:	$(STUFF)

clean:	; rm -f *.out *.omf *.lis tmp.a56 *.bak .jrc LOG ERR x.a56

sixcomb.omf:	sixcomb.a56
		$(M4) $*.a56 > x.a56
		make x.omf
		mv x.out sixcomb.out
		mv x.lis sixcomb.lis

.SUFFIXES:	.a56 .omf

.a56.omf:	$*.a56
		$(CPP) -Uicon $*.a56 > tmp.a56
		a56 -o $*.out tmp.a56 > $*.lis
		rm tmp.a56
		toomf < $*.out > $*.omf
