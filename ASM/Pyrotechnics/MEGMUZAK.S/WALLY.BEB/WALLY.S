* Musix by Wally Beben
* Crap program by Pyrotechnics
* ALL music ripped by XERUD

*cds.wal	length 8816	relocate to 192e6 run at 192e8 4 tunes
*lib.wal	length 5200		    192e8        192ea 2 
*quartz.wal	length 5298		    192fa	 192fc 1
*hawkeye.wal	length 6002		    192fa        192fc 5
*iball2.wal	length 6000		    192fc	 192fe 1
*circgame.wal	length 7591		    19302	 19304 5
*foundw.wal	length 7265		    1944e	 19450 2
*hyperdm.wal	length 4433		    192d0	 192d2 2
*phantasm.wal	length 4297		    19398	 1939a 2
*strftmus.wal	length 4125		    1944c	 1944e 5
*sumoly.wal	length 5251		    19296	 1929b 7
*wicked.wal	length 5985		    192fa	 192fc 5
*rtype.wal	length 11000		     d658	  d65a	lots

	CLR.L	-(a7)
	MOVE	#$20,-(a7)
	TRAP	#1
	ADDQ.L	#6,a7
	move.l	#MUS,a0
	move.l	#$d658,a1	;change to suit muzak
	move.l	#11000,d0	;ditto
l	move.b	(a0)+,(a1)+
	dbf	d0,l
	MOVE.B	#2,$484.w
	move.b	#1,$d658	;change tune here
	MOVE.L	#PLAY,$4d2.w
	MOVE	#8,-(a7)
	TRAP	#1
	ADDQ.L	#2,a7
	move.b	#0,$d658	;shut up tune (well its meant to!)
	CLR.L	$4D2.W
	CLR	-(a7)
	TRAP	#1
PLAY	MOVEM.L	D0-D7/A0-A6,-(a7)
	jsr	$d65a		;change to suit muzak
	MOVEM.L	(a7)+,D0-D7/A0-A6
	RTS
MUS	INCBIN A:\wally.beb\rtype.wal