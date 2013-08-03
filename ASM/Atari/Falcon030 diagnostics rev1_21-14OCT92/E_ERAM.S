	.text

testeram:
.if HOST
	clr.w   passw
	lea     msgexpram,a5
	bsr	dspmsg
	move.l  a5,msgsave1
	bsr	sav_cur
.endif
	move.l  #$fc0000,blkstart
	move.l  #$fe0000,blkend

testeram40:
	move.l  #mess1,msgsave
	
testeram0:
	bsr	testblk
	bne     faileram
	move.l  #mess2,msgsave

testeram1:
	bsr	testaddr
	bne     failerama
	bsr	dsppass
	move.l  #mess3,msgsave
	
testeram2:
	bsr	testhilo
	bne     faileram
	bsr	dsppass
	move.l  #mess4,msgsave
	
testeram3:
	bsr	testcopy
	bne     faileram
	bsr	dsppass

exiteram:
;	tst.l   savekey		;
	btst    #eramf,flag
        rts

faileram:
.if HOST
	Dorelease
	Dohalt
.endif
	bset    #eramf,flag
	bsr	dspfail
	tst.w   loopt
	bne.s   .1
	bra	exiteram

.1:	bra     loopword
	
failerama:
.if HOST
	Dorelease
	Dohalt
.endif
	bset    #eramf,flag
	bsr	dspfaill
	bra	exiteram



