
num	equ 108

* Initialise a .MOD file pointed to by a0

init_mod	bsr.s	init_song
		bsr	init_samples
		rts

* Initialise a .MOD song data

init_song	lea.l	ntvars(pc),a5		;variables
*Amiga only	lea.l	CHIPBASE,a6		;chips
		move.l	a0,asys_ntadd1(a5)	;save address 1
		move.w	#$1d8,d0		;offset sequence
		move.w	#$258,d1		;offset patterns
		cmp.l	#'M.K.',$438(a0)	;which version?
		bne.s	asys_ntinit2		;this version
		move.w	#$3b8,d0		;offset sequence
		move.w	#$43c,d1		;offset patterns
asys_ntinit2:	lea.l	(a0,d0.w),a1		;find sequence address
		lea.l	(a0,d1.w),a2		;find patterns address
		move.l	a1,asys_ntadd2(a5)	;save address 2
		move.l	a2,asys_ntadd3(a5)	;save address 3
		moveq.l	#0,d0			;reset
		move.b	(a1),d0			;get start
		lsl.l	#8,d0			;times 256
		lsl.l	#2,d0			;times 4 = 1024
		add.l	a2,d0			;add start
		move.l	d0,asys_ntpatadd(a5)	;pattern address
		clr.l	asys_ntpatoff(a5)	;pattern offset
		add.w	#20,a0			;past filename
		move.b	-2(a1),asys_ntlength(a5);length
		moveq.l	#$7f,d0			;128 sequence bytes
		moveq.l	#0,d1			;maximum pattern so far
asys_ntinit3:	cmp.b	(a1)+,d1		;largest pattern?
		bge.s	asys_ntinit4		;no, leave
		move.b	-1(a1),d1		;set largest
asys_ntinit4:	dbra	d0,asys_ntinit3		;find largest
		move.b	#6,asys_ntspeed(a5)	;setup speed
		move.b	#0,asys_ntcount(a5)	;clear count
		move.b	#0,asys_ntseqpos(a5)	;set position
*		or.b	#$2,$bfe001		;set filter
*Amiga only	clr.w	$a8(a6)			;zero volume
*		clr.w	$b8(a6)			;zero volume
*		clr.w	$c8(a6)			;zero volume
*		clr.w	$d8(a6)			;zero volume
*		move.w	#$00ff,$9e(a6)		;set no modulation
*		move.w	#$000f,$96(a6)		;no channels on
		clr.w	asys_ntdmacon(a5)	;no channels on
		lea.l	ntstab(a5),a5		;sample table
		lea.l	asys_nulls(pc),a6	;sample

		tst.w	d7
		bne.s	exitinitmod
		moveq.l	#30,d0			;31 to do
asys_ntsclear:	move.l	a6,(a5)+		;set
		move.w	#1,(a5)+		;length
		move.l	a6,(a5)+		;set
		move.w	#2,(a5)+		;length
		clr.l	(a5)+			;finetune & volume
		dbra	d0,asys_ntsclear	;clear all samples
exitinitmod:
		lea.l	asys_regs(pc),a5	;registers
		movem.l	d0-d7/a0-a4,(a5)	;save
		rts

* Initialise the current .MOD's samples

init_samples:	lea.l	asys_regs(pc),a5	;registers
		movem.l	(a5),d0-d7/a0-a4	;restore
		lea.l	ntvars(pc),a5		;variables
		addq.w	#1,d1			;increment largest
		lsl.l	#8,d1			;times 256
		lsl.l	#2,d1			;times 2 = 1024
		lea.l	(a2,d1.l),a2		;find start of samples
		lea.l	ntstab(a5),a3		;sample table
		move.l	asys_ntadd2(a5),d0	;end address
		sub.l	a0,d0			;minus start
		subq.l	#2,d0			;minus 2
		divu	#30,d0			;find sample
		subq.w	#1,d0			;decrement
asys_ntinit5:	moveq.l	#0,d1			;reset
		moveq.l	#0,d2			;reset
		moveq.l	#0,d3			;reset
		move.w	22(a0),d1		;get length
		move.w	28(a0),d3		;get repeat length
		move.w	26(a0),d2		;get repeat offset
		bne.s	asys_ntinit6		;do loop
		add.l	d1,d1			;to bytes
		add.l	d3,d3			;to bytes
		move.l	d1,d4			;copy
		bra.s	asys_ntinit8		;set
asys_ntinit6:	move.l	d2,d4			;copy
		add.l	d3,d4			;add
		cmp.l	d1,d4			;ok?
		bgt.s	asys_ntinit7		;no
		add.l	d2,d2			;offset to bytes
asys_ntinit7:	add.l	d1,d1			;length to bytes
		add.l	d3,d3			;length to bytes
		move.l	d2,d4			;copy
		add.l	d3,d4			;add
		cmp.l	d1,d4			;ok?
		ble.s	asys_ntinit8		;yes
		move.l	d1,d3			;copy length
		sub.l	d2,d3			;minus offset
		move.l	d1,d4			;copy length
asys_ntinit8:	clr.l	(a2)			;clear first 4 bytes
		move.l	a2,(a3)+		;set start of sample

		lsr.l	#1,d3			;back to words
		lsr.l	#1,d4			;back to words

		move.w	d4,(a3)+		;save length
		move.l	a2,(a3)			;repeat start
		add.l	d2,(a3)+		;repeat offset
		move.w	d3,(a3)+		;repeat length
		moveq.l	#0,d2			;reset
		move.b	24(a0),d2		;finetune
		move.w	d2,(a3)+		;set
		move.b	25(a0),d2		;volume
		move.w	d2,(a3)+		;set
		
		add.l	d1,a2			;next sample
		lea.l	30(a0),a0		;next sample
		
		dbra	d0,asys_ntinit5		;initialise all table
		rts

asys_regs:	ds.l	13
asys_nulls:	ds.l	4

ntplay:		movem.l	d0-d7/a0-a6,-(sp)	;save all
		lea.l	ntvars(pc),a5		;variables
*		lea.l	CHIPBASE,a6		;base address
		lea.l	asys_ntcount(a5),a0	;counter
		lea.l	asys_ntcflgt2(pc),a1	;commands table
		move.b	(a0)+,d0		;get count
		addq.b	#1,d0			;increment
		cmp.b	(a0),d0			;ok?
		blt.s	asys_ntplay3		;yes, no new command
		clr.b	-(a0)			;zero count
		bsr	asys_ntnewc		;get new data
		lea.l	asys_ntpatdel(a5),a0	;pattern delay
		tst.b	(a0)+			;set?
		beq.s	asys_ntplay1		;no
		move.b	-(a0),1(a0)		;copy
		clr.b	(a0)+			;zero
asys_ntplay1:	tst.b	(a0)			;delay?
		beq.s	asys_ntplay2		;no, don't reset
		subq.b	#1,(a0)			;decrement
		beq.s	asys_ntplay2		;finished, don't reset
		sub.l	#16,asys_ntpatoff(a5)	;adjust back one command
asys_ntplay2:	bra.s	asys_ntplay4		;ok
asys_ntplay3:	move.b	d0,-(a0)		;reset count
asys_ntplay4:	lea.l	asys_ntvoice1(a5),a0	;voice data
		bsr	asys_ntproc		;process command
		tst.w	asys_ntdmac(a0)		;channel on?
		beq.s	asys_ntnoset1		;no
*		move.l	asys_ntfrqc(a0),$a6(a6)	;set period
		move.w	asys_ntvolc(a0),channel1+ch_samvol
		move.w	asys_ntfrqc(a0),d0	Get Amoeba period
		beq.s	asys_ntnoset1
		sub.w	#num,d0			Minus 108
		asl.w	#2,d0			Times 4
		lea	snd_table,a0		Point to sound table
		move.l	(a0,d0.w),channel1+ch_sampitch
asys_ntnoset1:	lea.l	asys_ntvoice2(a5),a0	;voice data
		bsr	asys_ntproc		;process command
		tst.w	asys_ntdmac(a0)		;channel on?
		beq.s	asys_ntnoset2		;no
*		move.l	asys_ntfrqc(a0),$b6(a6)	;set period
		move.w	asys_ntvolc(a0),channel2+ch_samvol
		move.w	asys_ntfrqc(a0),d0	Get Amoeba period
		beq.s	asys_ntnoset2
		sub.w	#num,d0			Minus 108
		asl.w	#2,d0			Times 4
		lea	snd_table,a0		Point to sound table
		move.l	(a0,d0.w),channel2+ch_sampitch
asys_ntnoset2:	lea.l	asys_ntvoice3(a5),a0	;voice data
		bsr	asys_ntproc		;process command
		tst.w	asys_ntdmac(a0)		;channel on?
		beq.s	asys_ntnoset3		;no
*		move.l	asys_ntfrqc(a0),$c6(a6)	;set period
		move.w	asys_ntvolc(a0),channel3+ch_samvol
		move.w	asys_ntfrqc(a0),d0	Get Amoeba period
		beq.s	asys_ntnoset3
		sub.w	#num,d0			Minus 108
		asl.w	#2,d0			Times 4
		lea	snd_table,a0		Point to sound table
		move.l	(a0,d0.w),channel3+ch_sampitch
asys_ntnoset3:	lea.l	asys_ntvoice4(a5),a0	;voice data
		bsr	asys_ntproc		;process command
		tst.w	asys_ntdmac(a0)		;channel on?
		beq.s	asys_ntnoset4		;no
*		move.l	asys_ntfrqc(a0),$d6(a6)	;set period
		move.w	asys_ntvolc(a0),channel4+ch_samvol
		move.w	asys_ntfrqc(a0),d0	Get Amoeba period
		beq.s	asys_ntnoset4
		sub.w	#num,d0			Minus 108
		asl.w	#2,d0			Times 4
		lea	snd_table,a0		Point to sound table
		move.l	(a0,d0.w),channel4+ch_sampitch
asys_ntnoset4:	
*		move.w	#$12c,d0		;wait time
*asys_ntplay5:	dbra	d0,asys_ntplay5		;wait
*		move.w	asys_ntdmacon(a5),d0	;channels
*		or.w	#$8200,d0		;set
*		move.w	d0,DMACON(a6)		;start DMA
*		bsr	read_cb			Convert Amoeba to ST
*		move.w	#$12c,d0		;wait time
*asys_ntplay6:	dbra	d0,asys_ntplay6		;wait
		lea.l	asys_ntvoice4(a5),a0	;voice 4
		tst.w	asys_ntdmac(a0)		;channel on?
		beq.s	asys_ntnoset5		;no
*		move.l	asys_ntradd(a0),$d0(a6)	;set
*		move.w	asys_ntrlen(a0),$d4(a6)	;set
		move.l	asys_ntradd(a0),channel4+ch_samrepst
		move.w	asys_ntrlen(a0),channel4+ch_samreplen
		asl.w	channel4+ch_samreplen
asys_ntnoset5:	lea.l	asys_ntvoice3(a5),a0	;voice 3
		tst.w	asys_ntdmac(a0)		;channel on?
		beq.s	asys_ntnoset6		;no
*		move.l	asys_ntradd(a0),$c0(a6)	;set
*		move.w	asys_ntrlen(a0),$c4(a6)	;set
		move.l	asys_ntradd(a0),channel3+ch_samrepst
		move.w	asys_ntrlen(a0),channel3+ch_samreplen
		asl.w	channel3+ch_samreplen
asys_ntnoset6:	lea.l	asys_ntvoice2(a5),a0	;voice 2
		tst.w	asys_ntdmac(a0)		;channel on?
		beq.s	asys_ntnoset7		;no
*		move.l	asys_ntradd(a0),$b0(a6)	;set
*		move.w	asys_ntrlen(a0),$b4(a6)	;set
		move.l	asys_ntradd(a0),channel2+ch_samrepst
		move.w	asys_ntrlen(a0),channel2+ch_samreplen
		asl.w	channel2+ch_samreplen
asys_ntnoset7:	lea.l	asys_ntvoice1(a5),a0	;voice 1
		tst.w	asys_ntdmac(a0)		;channel on?
		beq.s	asys_ntnoset8		;no
*		move.l	asys_ntradd(a0),$a0(a6)	;set
*		move.w	asys_ntrlen(a0),$a4(a6)	;set
		move.l	asys_ntradd(a0),channel1+ch_samrepst
		move.w	asys_ntrlen(a0),channel1+ch_samreplen
		asl.w	channel1+ch_samreplen
asys_ntnoset8:	tst.b	asys_ntpbreak(a5)	;break pattern?
		beq.s	asys_ntplay7		;no
		moveq.l	#0,d0			;reset
		move.b	asys_ntppos(a5),d0	;get position
		lsl.w	#4,d0			;times 16
		move.l	d0,asys_ntpatoff(a5)	;set pattern offset
		clr.w	asys_ntpbreak(a5)	;reset both flags
asys_ntplay7:	cmp.l	#$400,asys_ntpatoff(a5)	;end of pattern?
		blt.s	asys_ntplay10		;no
asys_ntplay8:	moveq.l	#0,d0			;reset
		move.b	asys_ntppos(a5),d0	;get position
		lsl.w	#4,d0			;times 16
		move.l	d0,asys_ntpatoff(a5)	;set pattern offset
		move.b	asys_ntseqpos(a5),d0	;get position
		addq.b	#1,d0			;next
		cmp.b	asys_ntlength(a5),d0	;end?
		blt.s	asys_ntplay9		;no, ok
		clr.b	d0			;reset
asys_ntplay9:	move.b	d0,asys_ntseqpos(a5)	;set position
		move.l	asys_ntadd2(a5),a0	;sequence address
		move.b	(a0,d0.w),d0		;get pattern
		lsl.l	#8,d0			;times 256
		lsl.l	#2,d0			;times 4 = 1024
		add.l	asys_ntadd3(a5),d0	;plus patterns start
		move.l	d0,asys_ntpatadd(a5)	;set address
		sf	asys_ntppos(a5)		;zero
		sf	asys_ntjump(a5)		;zero
asys_ntplay10:	tst.b	asys_ntjump(a5)		;break pattern?
		bne.s	asys_ntplay8		;yes
		movem.l	(sp)+,d0-d7/a0-a6	;restore all registers
*		bra	ntplay
		rts				******

asys_ntnewc:	tst.b	asys_ntpatdel2(a5)	;delay?
		beq.s	asys_ntnewc2		;no
		add.l	#16,asys_ntpatoff(a5)	;next command
		rts
asys_ntnewc2:	move.l	asys_ntpatadd(a5),a0	;pattern address
		add.l	asys_ntpatoff(a5),a0	;plus offset
		add.l	#16,asys_ntpatoff(a5)	;next command
		lea.l	asys_ntvoice1(a5),a1	;voice 1 data
*		lea.l	$a0(a6),a2		;hardware
		lea	channel1,a2
		bsr.s	asys_ntgetc		;get data
		lea.l	asys_ntvoice2(a5),a1	;voice 2 data
*		lea.l	$b0(a6),a2		;hardware
		lea	channel2,a2
		bsr.s	asys_ntgetc		;get data
		lea.l	asys_ntvoice3(a5),a1	;voice 3 data
*		lea.l	$c0(a6),a2		;hardware
		lea	channel3,a2
		bsr.s	asys_ntgetc		;get data
		lea.l	asys_ntvoice4(a5),a1	;voice 4 data
*		lea.l	$d0(a6),a2		;hardware
		lea	channel4,a2
		bsr.s	asys_ntgetc		;get data
		lea.l	asys_ntcflgt1(pc),a1	;commands table
		rts

asys_ntgetc:	move.l	(a0)+,d0		;get data
		move.l	d0,asys_ntcomm(a1)	;set data
		move.w	d0,d1			;copy
		swap	d0			;other data half
		move.w	d0,d2			;copy
		and.w	#$f000,d1		;get sample nybble
		and.w	#$f000,d2		;get sample nybble
		lsr.w	#4,d1			;shift
		or.w	d2,d1			;merge
		beq.s	asys_ntgetc1		;no sample here
		subq.w	#1,d1			;subtract 1
		lsr.w	#4,d1			;divide by 16
		and.w	#$01f0,d1		;correct value
		lea.l	asys_ntsadd(a1),a3	;start address
		lea.l	ntstab(a5),a4		;sample table
		add.w	d1,a4			;plus offset
		move.l	(a4)+,(a3)+		;copy
		move.l	(a4)+,(a3)+		;copy
		move.l	(a4)+,(a3)+		;copy
		move.w	(a4)+,(a3)+		;copy
		move.w	(a4),2(a3)		;copy
		move.l	asys_ntradd(a1),a3	;get repeat
		move.l	a3,asys_ntwadd(a1)	;set wave
asys_ntgetc1:	and.w	#$0fff,d0		;get frequency
		beq	asys_ntgetc14		;nothing
		move.b	asys_ntcomm+2(a1),d1	;get command
		and.w	#$000f,d1		;get command
		cmp.b	#3,d1			;portamento?
		beq	asys_ntgetc10		;yes, set
		cmp.b	#5,d1			;portamento?
		beq	asys_ntgetc10		;yes, set
		cmp.b	#9,d1			;sample offset?
		bne.s	asys_ntgetc4		;yes, set
		moveq.l	#0,d1			;reset
		move.b	asys_ntcomm+3(a1),d1	;get data
		beq.s	asys_ntgetc2		;none to set
		move.b	d1,asys_ntsoff(a1)	;set sample offset
asys_ntgetc2:	move.b	asys_ntsoff(a1),d1	;get sample offset
		lsl.w	#7,d1			;times 128
		cmp.w	asys_ntslen(a1),d1	;ok?
		bge.s	asys_ntgetc3		;no
		sub.w	d1,asys_ntslen(a1)	;subtract
		add.w	d1,d1			;times 2
		add.l	d1,asys_ntsadd(a1)	;add to start
		bra.s	asys_ntgetc4		;done
asys_ntgetc3:	move.w	#1,asys_ntslen(a1)	;set length
asys_ntgetc4:	move.l	d0,d1			;copy
		swap	d1			;get freq
		and.w	#$0ff0,d1		;get command
		cmp.w	#$0e50,d1		;finetune?
		bne.s	asys_ntgetc5		;no, set period
		moveq.l	#0,d2			;reset
		move.b	asys_ntcomm+3(a1),d2	;get data
		and.w	#$000f,d2		;just 4 bits
		move.w	d2,asys_ntfine(a1)	;set finetune
asys_ntgetc5:	lea.l	asys_ntperiods(a5),a3	;period tables
		moveq.l	#36,d2			;loop
asys_ntgetc6:	cmp.w	(a3)+,d0		;this freq?
		bhs.s	asys_ntgetc7		;yes
		dbra	d2,asys_ntgetc6		;ok, find it
asys_ntgetc7:	move.w	asys_ntfine(a1),d2	;get finetune
		mulu	#36*2,d2		;find offset
		move.w	-2(a3,d2.w),d2		;get freq
		move.w	d2,asys_ntfreq(a1)	;set freq
		cmp.w	#$0ed0,d1		;note delay?
		beq	asys_ntgetc14		;yes
		move.w	asys_ntdmac(a1),d0	;get DMA channel
		beq.s	asys_ntnoset9		;nothing to set
*		move.w	d0,DMACON(a6)		;stop this channel
		or.w	d0,asys_ntdmacon(a5)	;set
asys_ntnoset9:	btst.b	#2,asys_ntwave(a1)	;vibrato?
		bne.s	asys_ntgetc8		;no
		clr.b	asys_ntvibp(a1)		;clear position
asys_ntgetc8:	btst.b	#6,asys_ntwave(a1)	;tremolo?
		bne.s	asys_ntgetc9		;no
		clr.b	asys_nttrep(a1)		;clear position
asys_ntgetc9:	tst.w	asys_ntdmac(a1)		;channel on?
		beq.s	asys_ntnoset10		;no
		move.l	asys_ntsadd(a1),0(a2)	;set start
		move.w	asys_ntslen(a1),4(a2)	;set length
		asl.w	4(a2)
asys_ntnoset10:	rts
asys_ntgetc10:	move.w	asys_ntfine(a1),d1	;get finetune
		mulu	#36*2,d1		;offset
		lea.l	asys_ntperiods(a5),a3	;period table
		add.l	d1,a3			;plus offset
		moveq.l	#0,d1			;reset
asys_ntgetc11:	cmp.w	(a3,d1.w),d0		;this?
		bhs.s	asys_ntgetc12		;yes
		addq.w	#2,d1			;next
		cmp.w	#36*2,d1		;end yet?
		blo.s	asys_ntgetc11		;no, find correct
		moveq.l	#35*2,d1		;not found, so reset
asys_ntgetc12:	move.w	asys_ntfine(a1),d0	;get finetune again
		and.b	#8,d0			;just bit 3
		beq.s	asys_ntgetc13		;ok
		tst.w	d1			;zero offset?
		beq.s	asys_ntgetc13		;yes
		subq.w	#2,d1			;adjust offset
asys_ntgetc13:	move.w	(a3,d1.w),d0		;get freq
		move.w	d0,asys_ntpend(a1)	;setup end freq
		clr.b	asys_ntpdir(a1)		;set up
		cmp.w	asys_ntfreq(a1),d0	;up or down?
		beq.s	asys_ntgetc15		;neither, already there
		bgt.s	asys_ntgetc14		;yes, up
		move.b	#1,asys_ntpdir(a1)	;set flag to down
asys_ntgetc14:	rts
asys_ntgetc15:	clr.w	asys_ntpend(a1)		;clear
		rts

asys_ntproc:	move.l	a1,-(sp)		;save table address
		movem.l	a0/a1,-(sp)		;save
		bsr	asys_ntEF_2		;update funk
		movem.l	(sp)+,a0/a1		;restore registers
		lea.l	asys_ntfreq(a0),a2	;frequency
		move.l	(a2)+,(a2)		;copy
		moveq.l	#0,d0			;reset
		move.w	asys_ntcomm+2(a0),d0	;get command
		and.w	#$0fff,d0		;any command?
		beq.s	asys_ntproc3		;no
asys_ntproc2:	move.l	d0,d1			;copy data
		and.w	#$00ff,d1		;just byte
		lsr.w	#8,d0			;shift command
		tst.b	(a1,d0.w)		;on?
		beq.s	asys_ntproc3		;no
		add.w	d0,d0			;times 2
		lea.l	asys_ntct(pc),a1	;table
		add.w	(a1,d0.w),a1		;find address
		jsr	(a1)			;call to command
asys_ntproc3:	move.w	asys_ntmaxvol(a5),d0	;get maximum volume
		mulu	#25,d0			;times 1600/64
		mulu	asys_ntvolc(a0),d0	;times current volume
		divu	#1600,d0		;divide
		move.w	d0,asys_ntvolc(a0)	;reset volume
		move.l	(sp)+,a1		;restore
		rts
		
asys_ntct:	dc.w	asys_ntcomm0-asys_ntct	;arpeggio
		dc.w	asys_ntcomm1-asys_ntct	;port up
		dc.w	asys_ntcomm2-asys_ntct	;port down
		dc.w	asys_ntcomm3-asys_ntct	;portamento
		dc.w	asys_ntcomm4-asys_ntct	;vibrato
		dc.w	asys_ntcomm5-asys_ntct	;vol slide portamento
		dc.w	asys_ntcomm6-asys_ntct	;vol slide vibrato
		dc.w	asys_ntcomm7-asys_ntct	;tremolo
		dc.w	asys_ntcomm8-asys_ntct	;unused
		dc.w	asys_ntcomm9-asys_ntct	;sample offset
		dc.w	asys_ntcommA-asys_ntct	;volume slide
		dc.w	asys_ntcommB-asys_ntct	;pattern jump
		dc.w	asys_ntcommC-asys_ntct	;volume set
		dc.w	asys_ntcommD-asys_ntct	;pattern break
		dc.w	asys_ntcommE-asys_ntct	;effects
		dc.w	asys_ntcommF-asys_ntct	;set speed

asys_ntcflgt1:	dc.b	0			;arpeggio		OFF
		dc.b	0			;port up		OFF
		dc.b	0			;port down		OFF
		dc.b	0			;portamento		OFF
		dc.b	0			;vibrato		OFF
		dc.b	0			;vol slide portamento	OFF
		dc.b	0			;vol slide vibrato	OFF
		dc.b	0			;unused			OFF
		dc.b	0			;unused			OFF
		dc.b	1			;sample offset		ON
		dc.b	0			;volume slide		OFF
		dc.b	1			;pattern jump		ON
		dc.b	1			;volume set		ON
		dc.b	1			;pattern break		ON
		dc.b	1			;set filter		ON
		dc.b	1			;set speed		ON

asys_ntcflgt2:	dc.b	1			;arpeggio		ON
		dc.b	1			;port up		ON
		dc.b	1			;port down		ON
		dc.b	1			;portamento		ON
		dc.b	1			;vibrato		ON
		dc.b	1			;vol slide portamento	ON
		dc.b	1			;vol slide vibrato	ON
		dc.b	1			;tremolo		ON
		dc.b	0			;unused			OFF
		dc.b	0			;unused			OFF
		dc.b	1			;volume slide		ON
		dc.b	0			;pattern jump		OFF
		dc.b	0			;volume set		OFF
		dc.b	0			;pattern break		OFF
		dc.b	1			;effects		ON
		dc.b	0			;set speed		OFF
		
;-------------------------------------------------------------------------
;
; Command 0, Arpeggio
;

asys_ntcomm0:	moveq.l	#0,d0			;reset
		move.b	asys_ntcount(a5),d0	;get counter
		divs	#3,d0			;divided by three
		swap	d0			;get remainder
		cmp.w	#0,d0			;zero?
		beq.s	asys_ntcomm0_3		;yes
		cmp.w	#2,d0			;two?
		beq.s	asys_ntcomm0_2		;yes
		move.l	d1,d0			;copy data
		lsr.b	#4,d0			;divide by 16
		bra.s	asys_ntcomm0_4		;do it
asys_ntcomm0_2:	move.l	d1,d0			;copy data
		and.b	#$f,d0			;just 0-15
		bra.s	asys_ntcomm0_4		;do it
asys_ntcomm0_3:	move.w	asys_ntfreq(a0),d2	;get frequency
		bra.s	asys_ntcomm0_6		;do it
asys_ntcomm0_4:	add.w	d0,d0			;times 2
		move.w	asys_ntfine(a0),d1	;get finetune
		mulu	#36*2,d1		;offset
		lea.l	asys_ntperiods(a5),a1	;periods table
		add.l	d1,a1			;add
		move.w	asys_ntfreq(a0),d1	;get frequency
		moveq.l	#36,d7			;loop counter
asys_ntcomm0_5:	move.w	(a1,d0.w),d2		;get value
		cmp.w	(a1),d1			;this one?
		bhs.s	asys_ntcomm0_6		;yes
		addq.l	#2,a1			;next
		dbra	d7,asys_ntcomm0_5	;do all
		rts
asys_ntcomm0_6:	move.w	d2,asys_ntfrqc(a0)	;save
		rts

;-------------------------------------------------------------------------
;
; Command 1, Portamento Up

asys_ntcomm1:	sub.w	d1,asys_ntfreq(a0)	;set down
		cmp.w	#113,asys_ntfreq(a0)	;ok?
		bge.s	asys_ntcomm1_2		;yes
		move.w	#113,asys_ntfreq(a0)	;reset
asys_ntcomm1_2:	move.w	asys_ntfreq(a0),d0	;get
		move.w	d0,asys_ntfrqc(a0)	;set
		rts

;------------------------------------------------------------------------
;
; Command 2, Portamento Down
;

asys_ntcomm2:	add.w	d1,asys_ntfreq(a0)	;set up
		cmp.w	#856,asys_ntfreq(a0)	;ok?
		ble.s	asys_ntcomm2_2		;yes
		move.w	#856,asys_ntfreq(a0)	;reset
asys_ntcomm2_2:	move.w	asys_ntfreq(a0),d0	;get
		move.w	d0,asys_ntfrqc(a0)	;set
		rts

;-------------------------------------------------------------------------
;
; Command 3, Tone portamento
;

asys_ntcomm3:	tst.w	d1			;data set?
		beq.s	asys_ntcomm3_2		;yes, do
		move.b	d1,asys_ntpoff(a0)	;set data
		clr.b	asys_ntcomm+3(a0)	;clear data
asys_ntcomm3_2:	move.w	asys_ntpend(a0),d2	;get end frequency
		bne.s	asys_ntcomm3_3		;there is one
		rts
asys_ntcomm3_3:	moveq.l	#0,d0			;reset
		move.b	asys_ntpoff(a0),d0	;get variable
		tst.b	asys_ntpdir(a0)		;up or down?
		beq.s	asys_ntcomm3_4		;up
		sub.w	d0,asys_ntfreq(a0)	;freq down
		cmp.w	asys_ntfreq(a0),d2	;ok?
		blt.s	asys_ntcomm3_5		;yes
		move.w	d2,asys_ntfreq(a0)	;reset
		clr.w	asys_ntpend(a0)		;reset
		bra.s	asys_ntcomm3_5		;set
asys_ntcomm3_4:	add.w	d0,asys_ntfreq(a0)	;freq down
		cmp.w	asys_ntfreq(a0),d2	;ok?
		bgt.s	asys_ntcomm3_5		;yes
		move.w	d2,asys_ntfreq(a0)	;reset
		clr.w	asys_ntpend(a0)		;reset
asys_ntcomm3_5:	move.w	asys_ntfreq(a0),d0	;get
		move.b	asys_ntgfun(a0),d1	;get glissfunk
		and.b	#$f,d1			;do it?
		beq.s	asys_ntcomm3_8		;no, leave
		move.w	asys_ntfine(a0),d1	;get finetune
		mulu	#36*2,d1		;offset
		lea.l	asys_ntperiods(a5),a1	;period table
		add.l	d1,a1			;add offset
		moveq.l	#0,d1			;reset
asys_ntcomm3_6:	cmp.w	(a1,d1.w),d0		;this one?
		bhs.s	asys_ntcomm3_7		;yes
		addq.w	#2,d1			;increment
		cmp.w	#36*2,d1		;end?
		blo.s	asys_ntcomm3_6		;no, try next
		moveq.l	#35*2,d1		;reset
asys_ntcomm3_7:	move.w	(a1,d1.w),d0		;get freq
asys_ntcomm3_8:	move.w	d0,asys_ntfrqc(a0)	;set
		rts

;-------------------------------------------------------------------------
;
; Command 4, vibrato
;

asys_ntcomm4:	tst.w	d1			;data set?
		beq.s	asys_ntcomm4_4		;yes
		move.b	asys_ntvibc(a0),d2	;get vibrato command
		and.b	#$0f,d1			;just nybble
		beq.s	asys_ntcomm4_2		;ok
		and.b	#$f0,d2			;just nybble
		or.b	d1,d2			;merge
asys_ntcomm4_2:	move.b	asys_ntcomm+3(a0),d1	;get data again
		and.b	#$f0,d1			;just nybble
		beq.s	asys_ntcomm4_3		;ok
		and.b	#$0f,d2			;just nybble
		or.w	d1,d2			;merge
asys_ntcomm4_3:	move.b	d2,asys_ntvibc(a0)	;set command
asys_ntcomm4_4:	lea.l	asys_ntvibtab(a5),a1	;vibrato table
		move.b	asys_ntvibp(a0),d0	;get offset
		lsr.w	#2,d0			;divide by 2
		and.w	#$001f,d0		;max value
		moveq.l	#0,d1			;reset
		move.b	asys_ntwave(a0),d1	;get wave control
		and.b	#3,d1			;sine?
		beq.s	asys_ntcomm4_7		;yes
		lsl.b	#3,d0			;times 8
		cmp.b	#1,d1			;ramp-down?
		beq.s	asys_ntcomm4_5		;yes
		move.b	#$ff,d1			;reset
		bra.s	asys_ntcomm4_8		;set
asys_ntcomm4_5:	tst.b	asys_ntvibp(a0)		;position pos or neg?
		bpl.s	asys_ntcomm4_6		;pos
		move.b	#$ff,d1			;reset
		sub.b	d0,d1			;find difference
		bra.s	asys_ntcomm4_8		;ok, set
asys_ntcomm4_6:	move.b	d0,d1			;copy
		bra.s	asys_ntcomm4_8		;ok, set
asys_ntcomm4_7:	move.b	(a1,d0.w),d1		;get from table
asys_ntcomm4_8:	move.b	asys_ntvibc(a0),d0	;get command again
		and.w	#$f,d0			;just a nybble
		mulu	d0,d1			;times data
		lsr.w	#7,d1			;shift down
		move.w	asys_ntfreq(a0),d0	;get freq
		tst.b	asys_ntvibp(a0)		;position pos or neg?
		bmi.s	asys_ntcomm4_9		;neg
		add.w	d1,d0			;add offset
		bra.s	asys_ntcomm4_A		;set this freq
asys_ntcomm4_9:	sub.w	d1,d0			;subtract offset
asys_ntcomm4_A:	move.w	d0,asys_ntfrqc(a0)	;setup frequency
		move.b	asys_ntvibc(a0),d0	;get command
		lsr.w	#2,d0			;shift
		and.w	#$003c,d0		;max value
		add.b	d0,asys_ntvibp(a0)	;adjust position
		rts

;-------------------------------------------------------------------------
;
; Command 5, Tone Portamento plus Volume Slide
;

asys_ntcomm5:	bsr	asys_ntcomm3_2		;do portamento
		moveq.l	#0,d1			;reset
		move.b	asys_ntcomm+3(a0),d1	;get data
		bsr	asys_ntcommA		;do vol slide
		rts

;--------------------------------------------------------------------------
;
; Command 6, Vibrato plus Volume Slide
;

asys_ntcomm6:	bsr	asys_ntcomm4_4		;do portamento
		moveq.l	#0,d1			;reset
		move.b	asys_ntcomm+3(a0),d1	;get data
		bsr	asys_ntcommA		;do vol slide
		rts

;-------------------------------------------------------------------------
;
; Command 7, Tremolo
;

asys_ntcomm7:	tst.w	d1			;data set?
		beq.s	asys_ntcomm7_4		;yes
		move.b	asys_nttrec(a0),d2	;get vibrato command
		and.b	#$0f,d1			;just nybble
		beq.s	asys_ntcomm7_2		;ok
		and.b	#$f0,d2			;just nybble
		or.b	d1,d2			;merge
asys_ntcomm7_2:	move.b	asys_ntcomm+3(a0),d1	;get data again
		and.b	#$f0,d1			;just nybble
		beq.s	asys_ntcomm7_3		;ok
		and.b	#$0f,d2			;just nybble
		or.w	d1,d2			;merge
asys_ntcomm7_3:	move.b	d2,asys_nttrec(a0)	;set command
asys_ntcomm7_4:	lea.l	asys_nttretab(a5),a1	;vibrato table
		move.b	asys_nttrep(a0),d0	;get offset
		lsr.w	#2,d0			;divide by 2
		and.w	#$001f,d0		;max value
		moveq.l	#0,d1			;reset
		move.b	asys_ntwave(a0),d1	;get wave control
		lsr.b	#4,d1			;get tremolo command
		and.b	#3,d1			;sine?
		beq.s	asys_ntcomm7_7		;yes
		lsl.b	#3,d0			;times 8
		cmp.b	#1,d1			;ramp-down?
		beq.s	asys_ntcomm7_5		;yes
		move.b	#$ff,d1			;reset
		bra.s	asys_ntcomm7_8		;set
asys_ntcomm7_5:	tst.b	asys_nttrep(a0)		;position pos or neg?
		bpl.s	asys_ntcomm7_6		;pos
		move.b	#$ff,d1			;reset
		sub.b	d0,d1			;find difference
		bra.s	asys_ntcomm7_8		;ok, set
asys_ntcomm7_6:	move.b	d0,d1			;copy
		bra.s	asys_ntcomm7_8		;ok, set
asys_ntcomm7_7:	move.b	(a1,d0.w),d1		;get from table
asys_ntcomm7_8:	move.b	asys_nttrec(a0),d0	;get command again
		and.w	#$f,d0			;just a nybble
		mulu	d0,d1			;times data
		lsr.w	#6,d1			;shift down
		move.w	asys_ntvolu(a0),d0	;get freq
		tst.b	asys_nttrep(a0)		;position pos or neg?
		bmi.s	asys_ntcomm7_9		;neg
		add.w	d1,d0			;add offset
		bra.s	asys_ntcomm7_A		;set this freq
asys_ntcomm7_9:	sub.w	d1,d0			;subtract offset
asys_ntcomm7_A:	bpl.s	asys_ntcomm7_B		;positive, ok
		moveq.l	#0,d0			;reset to min
asys_ntcomm7_B:	cmp.w	#$40,d0			;ok?
		ble.s	asys_ntcomm7_C		;yes, ok
		moveq.l	#$40,d0			;reset to max
asys_ntcomm7_C:	move.w	d0,asys_ntvolc(a0)	;set new volume		
		move.b	asys_nttrec(a0),d0	;get command
		lsr.w	#2,d0			;shift
		and.w	#$003c,d0		;max value
		add.b	d0,asys_nttrep(a0)	;adjust position
		rts

;------------------------------------------------------------------------
;
; Command 8, unused
;

asys_ntcomm8:	rts

;------------------------------------------------------------------------
;
; Command 9, sample offset
;

asys_ntcomm9:	tst.w	d1			;set?
		beq.s	asys_ntcomm9_2		;no
		move.b	d1,asys_ntsoff(a0)	;set sample offset
asys_ntcomm9_2:	move.b	asys_ntsoff(a0),d1	;get offset
		lsl.w	#7,d1			;times 128
		cmp.w	asys_ntslen(a0),d1	;ok?
		bge.s	asys_ntcomm9_3		;no
		sub.w	d0,asys_ntslen(a0)	;subtract from length
		add.w	d0,d0			;times 2
		add.l	d0,asys_ntsadd(a0)	;add to start
		rts
asys_ntcomm9_3:	move.w	#1,asys_ntslen(a0)	;no length
		rts
		
;--------------------------------------------------------------------------
;
; Command A, volume slide
;
			
asys_ntcommA:	move.w	asys_ntvolu(a0),d3	;get volume
		move.w	d1,d2			;copy
		lsr.w	#4,d1			;shift
		and.w	#$f,d1			;down?
		beq.s	asys_ntcommA_3		;yes
		add.w	d1,d3			;volume up
		cmp.w	#$40,d3			;ok?
		ble.s	asys_ntcommA_4		;yes
		moveq.l	#$40,d3			;reset
		bra.s	asys_ntcommA_4		;set
asys_ntcommA_3:	and.w	#$f,d2			;get slide value
		sub.w	d2,d3			;volume down
		bpl.s	asys_ntcommA_4		;ok
		moveq.l	#0,d3			;reset
asys_ntcommA_4:	move.w	d3,asys_ntvolu(a0)	;set
		move.w	d3,asys_ntvolc(a0)	;set
		rts

;----------------------------------------------------------------------
;
; Command B, position jump
;

asys_ntcommB:	subq.w	#1,d1			;decrement data
		move.b	d1,asys_ntseqpos(a5)	;set position
		clr.b	asys_ntppos(a5)		;position zero
		st	asys_ntjump(a5)		;set jump
		rts

;------------------------------------------------------------------------
;
; Command C, set volume
;

asys_ntcommC:	cmp.w	#$40,d1			;ok?
		ble.s	asys_ntcommC_2		;yes
		moveq.l	#$40,d1			;reset
asys_ntcommC_2:	move.w	d1,asys_ntvolu(a0)	;set volume
		move.w	d1,asys_ntvolc(a0)	;set volume
		rts

;---------------------------------------------------------------------------
;
; Command D, break pattern
;

asys_ntcommD:	clr.b	asys_ntppos(a5)		;zero
		st	asys_ntjump(a5)		;set jump flag
		move.l	d1,d2			;copy data
		lsr.b	#4,d1			;divide by 16
		mulu	#10,d1			;and times 10
		and.b	#$f,d2			;just nybble
		add.b	d2,d1			;add
		cmp.b	#63,d1			;in current pattern?
		bhi.s	asys_ntcommD_2		;no
		move.b	d1,asys_ntppos(a5)	;set
asys_ntcommD_2:	rts

;-----------------------------------------------------------------------
;
; Command E, effects & misc
;

asys_ntcommE:	move.w	d1,d2			;copy command
		and.w	#$000f,d1		;get data
		lsr.w	#4,d2			;get 'E' command
		add.w	d2,d2			;times 2
		lea.l	asys_ntEt(pc),a1	;table
		add.w	(a1,d2.w),a1		;add
		jsr	(a1)			;call
		rts

asys_ntEt:	dc.w	asys_ntE0-asys_ntEt	;set filter
		dc.w	asys_ntE1-asys_ntEt	;fine portamento up
		dc.w	asys_ntE2-asys_ntEt	;fine portamento down
		dc.w	asys_ntE3-asys_ntEt	;set gliss control
		dc.w	asys_ntE4-asys_ntEt	;set vibrato control
		dc.w	asys_ntE5-asys_ntEt	;set finetune
		dc.w	asys_ntE6-asys_ntEt	;jump into loop
		dc.w	asys_ntE7-asys_ntEt	;set tremolo control
		dc.w	asys_ntE8-asys_ntEt	;unused
		dc.w	asys_ntE9-asys_ntEt	;regtrigger note
		dc.w	asys_ntEA-asys_ntEt	;fine volume up
		dc.w	asys_ntEB-asys_ntEt	;fine volume down
		dc.w	asys_ntEC-asys_ntEt	;cut note off
		dc.w	asys_ntED-asys_ntEt	;delay start of note
		dc.w	asys_ntEE-asys_ntEt	;delay pattern
		dc.w	asys_ntEF-asys_ntEt	;set funk

asys_ntE0:	and.b	#1,d1			;get data
		lsl.b	#1,d1			;shift up
*		and.b	#$fd,$bfe001		;setup
*		or.b	d1,$bfe001		;set filter
		rts

asys_ntE1:	tst.b	asys_ntcount(a5)	;count zero?
		bne.s	asys_ntE1_2		;no
		bsr	asys_ntcomm1		;portamento up
asys_ntE1_2:	rts

asys_ntE2:	tst.b	asys_ntcount(a5)	;count zero?
		bne.s	asys_ntE2_2		;no
		bsr	asys_ntcomm2		;portamento up
asys_ntE2_2:	rts
		
asys_ntE3:	and.b	#$f0,asys_ntgfun(a0)	;remove funk command
		or.b	d1,asys_ntgfun(a0)	;set funk
		rts

asys_ntE4:	and.b	#$f0,asys_ntwave(a0)	;remove vibrato
		or.b	d1,asys_ntwave(a0)	;setup vibrato
		rts
		
asys_ntE5:	move.b	d1,asys_ntfine(a0)	;set finetune
		rts

asys_ntE6:	tst.b	asys_ntcount(a5)	;count zero?
		bne.s	asys_ntE6_5		;no
		tst.w	d1			;data?
		beq.s	asys_ntE6_4		;no, set
		tst.b	asys_ntlcnt(a0)		;count zero?
		beq.s	asys_ntE6_3		;no, set
		subq.b	#1,asys_ntlcnt(a0)	;decrement
		beq.s	asys_ntE6_5		;finished
asys_ntE6_2:	move.b	asys_ntlpos(a0),d0	;get loop position
		move.b	d0,asys_ntppos(a5)	;set break
		st	asys_ntpbreak(a5)	;set flag
		rts
asys_ntE6_3:	move.b	d1,asys_ntlcnt(a0)	;set loop
		bra.s	asys_ntE6_2		;break
asys_ntE6_4:	move.l	asys_ntpatoff(a5),d1	;get pattern
		lsr.w	#4,d1			;divide by 16
		move.b	d1,asys_ntlpos(a0)	;set position
asys_ntE6_5:	rts

asys_ntE7:	lsl.b	#4,d1			;shift data
		and.b	#$0f,asys_ntwave(a0)	;remove tremolo
		or.b	d1,asys_ntwave(a0)	;setup wave
		rts

asys_ntE8:	rts

asys_ntE9:	tst.w	d1			;do?
		beq.s	asys_ntE9_6		;no, leave
		moveq.l	#0,d2			;reset
		move.b	asys_ntcount(a5),d2	;get counter
		bne.s	asys_ntE9_2		;ok, test
		move.w	asys_ntcomm(a0),d2	;get command
		and.w	#$0fff,d2		;just freq
		bne.s	asys_ntE9_6		;there is one, leave
		moveq.l	#0,d2			;reset
		move.b	asys_ntcount(a5),d2	;get counter
asys_ntE9_2:	divu	d1,d2			;divide
		swap	d2			;get remainder
		tst.w	d2			;any remainder?
		bne.s	asys_ntE9_6		;yes, exit
asys_ntE9_3:	moveq.l	#0,d1			;reset
		move.w	asys_ntdmac(a0),d1	;channel
		beq.s	asys_ntE9_6		;not on, leave
*		move.w	d1,DMACON(a6)		;stop
		or.w	d1,asys_ntdmacon(a5)	;set
		move.w	asys_ntchip(a0),d1	;get chipbase
		lea	channel1,a6
		move.l	asys_ntsadd(a0),ch_samstart(a6,d1.w)	;set address
		move.w	asys_ntslen(a0),ch_samlen(a6,d1.w)	;set length
		asl.w	ch_samlen(a6,d1.w)
asys_ntE9_6:	rts

asys_ntEA:	tst.b	asys_ntcount(a5)	;count zero?
		bne.s	asys_ntEA_2		;no
		lsl.b	#4,d1			;shift data
		bsr	asys_ntcommA		;volume up
asys_ntEA_2:	rts

asys_ntEB:	tst.b	asys_ntcount(a5)	;count zero?
		bne.s	asys_ntEB_2		;no
		bsr	asys_ntcommA		;volume down
asys_ntEB_2:	rts

asys_ntEC:	cmp.b	asys_ntcount(a5),d1	;count now?
		bne.s	asys_ntEC_2		;no
		clr.w	asys_ntvolu(a0)		;no volume
		clr.w	asys_ntvolc(a0)		;no volume
asys_ntEC_2:	rts

asys_ntED:	cmp.b	asys_ntcount(a5),d1	;count now?
		bne.s	asys_ntED_2		;no
		tst.w	asys_ntcomm(a0)		;freq?
		beq.s	asys_ntED_2		;no, leave
		bsr	asys_ntE9_3		;start note
asys_ntED_2:	rts

asys_ntEE:	tst.b	asys_ntcount(a5)	;count zero?
		bne.s	asys_ntEE_2		;no, leave
		tst.b	asys_ntpatdel2(a5)	;delay already?
		bne.s	asys_ntEE_2		;yes, leave
		addq.b	#1,d1			;increment
		move.b	d1,asys_ntpatdel(a5)	;set delay
asys_ntEE_2:	rts

asys_ntEF:	tst.b	asys_ntcount(a5)	;zero count?
		bne.s	asys_ntEF_4		;no
		lsl.b	#4,d1			;shift data
		and.b	#$0f,asys_ntgfun(a0)	;remove data
		or.b	d1,asys_ntgfun(a0)	;set data
		tst.b	d1			;data?
		beq.s	asys_ntEF_4		;no, leave
asys_ntEF_2:	moveq.l	#0,d1			;reset
		move.b	asys_ntgfun(a0),d1	;get funk
		lsr.b	#4,d1			;top nybble
		beq.s	asys_ntEF_4		;end
		lea.l	asys_ntfunktab(a5),a1	;table
		move.b	(a1,d1.w),d1		;get data
		add.b	d1,asys_ntfoff(a0)	;add to offset
		btst.b	#7,asys_ntfoff(a0)	;msb set?
		beq.s	asys_ntEF_4		;no, leave
		clr.b	asys_ntfoff(a0)		;zero offset
		move.l	asys_ntradd(a0),d0	;get loop address
		moveq.l	#0,d1			;reset
		move.w	asys_ntrlen(a0),d1	;repeat length
		add.l	d1,d0			;add
		add.l	d1,d0			;add
		move.l	asys_ntwadd(a0),a1	;wave address
		addq.l	#1,a1			;increment
		cmp.l	d0,a1			;end?
		blo.s	asys_ntEF_3		;no, ok
		move.l	asys_ntradd(a0),a1	;reset
asys_ntEF_3:	move.l	a1,asys_ntwadd(a0)	;set wave address
		moveq.l	#-1,d0			;minus 1
		sub.b	(a0),d0			;subtract sample
		move.b	d0,(a0)			;set back
asys_ntEF_4:	rts

;-------------------------------------------------------------------------
;
; Command F, set speed
;

asys_ntcommF:	and.w	#$1f,d1			;make correct
		beq.s	asys_ntcommF_2		;zero, not allowed
		move.b	d1,asys_ntspeed(a5)	;set speed
		clr.b	asys_ntcount(a5)	;set counter
asys_ntcommF_2:	rts

ch_samstart	equ	0	Start of current sample
ch_samlen	equ	4	Length (in bytes) left to play
ch_sampitch	equ	8	Note pitch
ch_samvol	equ	12	Note volume
ch_samrepst	equ	14	Repeat start
ch_samreplen	equ	18	Repeat length

	even

channel1	ds.b	22
channel2	ds.b	22
channel3	ds.b	22
channel4	ds.b	22

ntvars:					;the variables
	
asys_ntcomm:	equ	00	;long
asys_ntdmac:	equ	04	;word
asys_ntsadd:	equ	06	;long
asys_ntslen:	equ	10	;word
asys_ntradd:	equ	12	;long
asys_ntrlen:	equ	16	;word
asys_ntfine:	equ	18	;word
asys_ntfreq:	equ	20	;word
asys_ntvolu:	equ	22	;word
asys_ntfrqc:	equ	24	;word
asys_ntvolc:	equ	26	;word
asys_ntpend:	equ	28	;word
asys_ntpdir:	equ	30	;byte
asys_ntpoff:	equ	31	;byte
asys_ntchip:	equ	32	;word
asys_ntwave:	equ	34	;byte
asys_ntsoff:	equ	35	;byte
asys_ntvibc:	equ	36	;byte
asys_ntvibp:	equ	37	;byte
asys_nttrec:	equ	36	;byte
asys_nttrep:	equ	37	;byte
asys_ntlcnt:	equ	38	;byte
asys_ntlpos:	equ	39	;byte
asys_ntgfun:	equ	40	;byte
asys_ntfoff:	equ	41	;byte
asys_ntwadd:	equ	42	;long

asys_ntlength:	equ	0000	Sequence length
asys_ntcount:	equ	0001	VBL counter
asys_ntspeed:	equ	0002	Current speed (6 by default)
asys_ntseqpos:	equ	0003	Position in sequence list
asys_ntbreak:	equ	0004
asys_ntpbreak:	equ	0005
asys_ntppos:	equ	0006
asys_ntjump:	equ	0007
asys_ntpatadd:	equ	0008
asys_ntpatoff:	equ	0012
asys_ntadd1:	equ	0016	Address of mod file
asys_ntadd2:	equ	0020	Sequence address
asys_ntadd3:	equ	0024	Pattern address
ntstab:		equ	0028	Sample table
asys_ntdmacon:	equ	0524
asys_ntmaxvol:	equ	0526
asys_ntvoice1:	equ	0528
asys_ntvoice2:	equ	0578
asys_ntvoice3:	equ	0628
asys_ntvoice4:	equ	0678
asys_ntfunktab:	equ	0728
asys_ntvibtab:	equ	0744
asys_nttretab:	equ	0744
asys_ntperiods:	equ	0776
asys_ntpatdel:	equ	1928
asys_ntpatdel2:	equ	1929

asys_ntend:	equ	1930

		ds.b	1	Sequence length
		ds.b	1	VBL counter
		ds.b	1	Current Speed (6 by default)
		ds.b	1	Current position in sequence
		ds.b	1
		ds.b	1
		ds.b	1
		ds.b	1
		ds.l	1
		ds.l	1
		ds.l	1		Address of mod file
		ds.l	1		Sequence address
		ds.l	1		Pattern address
		ds.b	31*16		Sample table
		dc.w	0
		dc.w	64
		ds.b	4
		dc.w	$0001
		ds.b	26
*		dc.w	$a0		Chip address
		dc.w	0		Chip address
		ds.b	16
		ds.b	4
		dc.w	$0002
		ds.b	26
*		dc.w	$b0		Chip address
		dc.w	22		Chip address
		ds.b	16
		ds.b	4
		dc.w	$0004
		ds.b	26
*		dc.w	$c0		Chip address
		dc.w	44		Chip address
		ds.b	16
		ds.b	4
		dc.w	$0008
		ds.b	26
*		dc.w	$d0		Chip address
		dc.w	66		Chip address
		ds.b	16
		dc.b	0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128
		dc.b	000,024,049,074,097,120,141,161
		dc.b	180,197,212,224,235,244,250,253
		dc.b	255,253,250,244,235,224,212,197
		dc.b	180,161,141,120,097,074,049,024

pit_tab		dc.w	856,808,762,720,678,640,604,570,538,508,480,453
		dc.w	428,404,381,360,339,320,302,285,269,254,240,226
		dc.w	214,202,190,180,170,160,151,143,135,127,120,113

		dc.w	850,802,757,715,674,637,601,567,535,505,477,450
		dc.w	425,401,379,357,337,318,300,284,268,253,239,225
		dc.w	213,201,189,179,169,159,150,142,134,126,119,113

		dc.w	844,796,752,709,670,632,597,563,532,502,474,447
		dc.w	422,398,376,355,335,316,298,282,266,251,237,224
		dc.w	211,199,188,177,167,158,149,141,133,125,118,112

		dc.w	838,791,746,704,665,628,592,559,528,498,470,444
		dc.w	419,395,373,352,332,314,296,280,264,249,235,222
		dc.w	209,198,187,176,166,157,148,140,132,125,118,111

		dc.w	832,785,741,699,660,623,588,555,524,495,467,441
		dc.w	416,392,370,350,330,312,294,278,262,247,233,220
		dc.w	208,196,185,175,165,156,147,139,131,124,117,110

		dc.w	826,779,736,694,655,619,584,551,520,491,463,437
		dc.w	413,390,368,347,328,309,292,276,260,245,232,219
		dc.w	206,195,184,174,164,155,146,138,130,123,116,109

		dc.w	820,774,730,689,651,614,580,547,516,487,460,434
		dc.w	410,387,365,345,325,307,290,274,258,244,230,217
		dc.w	205,193,183,172,163,154,145,137,129,122,115,109

		dc.w	814,768,725,684,646,610,575,543,513,484,457,431
		dc.w	407,384,363,342,323,305,288,272,256,242,228,216
		dc.w	204,192,181,171,161,152,144,136,128,121,114,108

		dc.w	907,856,808,762,720,678,640,604,570,538,508,480
		dc.w	453,428,404,381,360,339,320,302,285,269,254,240
		dc.w	226,214,202,190,180,170,160,151,143,135,127,120

		dc.w	900,850,802,757,715,675,636,601,567,535,505,477
		dc.w	450,425,401,379,357,337,318,300,284,268,253,238
		dc.w	225,212,200,189,179,169,159,150,142,134,126,119

		dc.w	894,844,796,752,709,670,632,597,563,532,502,474
		dc.w	447,422,398,376,355,335,316,298,282,266,251,237
		dc.w	223,211,199,188,177,167,158,149,141,133,125,118

		dc.w	887,838,791,746,704,665,628,592,559,528,498,470
		dc.w	444,419,395,373,352,332,314,296,280,264,249,235
		dc.w	222,209,198,187,176,166,157,148,140,132,125,118

		dc.w	881,832,785,741,699,660,623,588,555,524,494,467
		dc.w	441,416,392,370,350,330,312,294,278,262,247,233
		dc.w	220,208,196,185,175,165,156,147,139,131,123,117

		dc.w	875,826,779,736,694,655,619,584,551,520,491,463
		dc.w	437,413,390,368,347,328,309,292,276,260,245,232
		dc.w	219,206,195,184,174,164,155,146,138,130,123,116

		dc.w	868,820,774,730,689,651,614,580,547,516,487,460
		dc.w	434,410,387,365,345,325,307,290,274,258,244,230
		dc.w	217,205,193,183,172,163,154,145,137,129,122,115

		dc.w	862,814,768,725,684,646,610,575,543,513,484,457
		dc.w	431,407,384,363,342,323,305,288,272,256,242,228
		dc.w	216,203,192,181,171,161,152,144,136,128,121,114

		ds.b	1
		ds.b	1
