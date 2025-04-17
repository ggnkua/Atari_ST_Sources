|
| This is a variant of the method use in 'ofake' to use pseudo drives in
| an installable filesystem. Basically mediach, rwabs and getbpb have to
| be faked by intercepting their vectors. It works but it's a kludge, this
| kind of thing shouldn't be necessary.
|

.globl _kludge_rwabs,_kludge_mediach,_kludge_getbpb

_kludge_rwabs:
	movml	d0-d1,sp@-
	movel 	_shadmap,d0
	movew	sp@(0xe),d1
	btst	d1,d0
	bne	ret0
	movml	sp@+,d0-d1
	movel	_old_rwabs,sp@-
	rts

_kludge_mediach:
	movml	d0-d1,sp@-
	movel	_shadmap,d0
	movew	sp@(4),d1
	btst	d1,d0
	bne	ret0
	movml	sp@+,d0-d1
	movel	_old_mediach,sp@-
	rts

_kludge_getbpb:
	movml	d0-d1,sp@-
	movel	_shadmap,d0
	movew	sp@(4),d1
	btst	d1,d0
	bne 	ret0
	movml	sp@+,d0-d1
	movel	_old_getbpb,sp@-
	rts
	
ret0:	movml	sp@+,d0-d1
	movq	#0,d0
	rts	
