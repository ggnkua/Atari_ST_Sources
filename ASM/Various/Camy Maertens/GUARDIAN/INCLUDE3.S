*		INCLUDE 2        Oct 16, 1989
*------------------------------------------------------
* FADEIN		Damon. not tested yet
* SET_HORIZONTAL_BLANK	Kenn Garroch's h/blank
* RST_HORIZONTAL_BLANK
* INSTALL_VBI		Frank's quick vbi re-vector
* PICDUMP		Frank's screen dump to disk
* OR_BLOCK		block drawing with oring
* COMPACT		compact a Degas file
* DECOMPACT		decompact
* VIEW_ARRAY		view bytes in dec, hex or binary
* + various mfp trap calls
*----------------------------------------------------
* fadein Oct 89		not tested yet
fadein	subi.w	#1,flag2
	bne	fadeend
	addq.w	#2,flag2
	move.w	store2(pc),d3
	tst.w	inout
	beq	fadeend
	add.w	inout(pc),d3
	move.w	d3,store2
	beq	skip4
	cmpi.w	#$0010,d3
	bne	skip8
skip4	clr.w	inout
skip8	moveq.w	#$f,d4
	lea	palet,a0		; address of 16 words
	lea	$ff8240,a1		
fadeloop
	move.w	(a0)+,d0
	move.w	d0,d1
	asr.w	#4,d1
	move.w	d1,d2
	asr.w	#4,d2
	andi.w	#$0007,d0
	andi.w	#$0007,d1
	andi.w	#$0007,d2
	mulu	d3,d0
	mulu	d3,d1
	mulu	d3,d2
	asr.w	#4,d0
	asl.w	#4,d2
	andi.w	#$0007,d0
	andi.w	#$0070,d1
	andi.w	#$0700,d2
	or.w	d1,d0
	or.w	d2,d0
	move.w	d0,(a1)+
	dbf	d4,fadeloop
fadeend	rts	
inout		dc.w	0		(1 or $ffff)
flag2		dc.w	2
store2		dc.w 	0
*------------------------------------------
*	Horizontal blank	[Ken Garroch]  Sept 5 1987
* Expects address of my routine in A0
set_horizontal_blank
	move.l	d0,-(sp)
	MOVE	SR,D0	get status register
	OR	#$7,D0	set no interrupts
	MOVE	D0,SR
	MOVE.L	$68,hbl_vector   save old vector
	MOVE.L	A0,$68	point to our routine 
	MOVE	SR,D0
	AND	#$F8FF,D0	set interrupt level to zero
	MOVE	D0,SR	put back
	move.l	(sp)+,d0
	RTS
* there is an example in the shell.s used to count how long
* a particular routine takes (by peeking the h/b line, before
* and after the routine.   H/blank routines are very processor intensive.

*----------
* all h/b routines must be disabled prior to returning to desktop
rst_horizontal_blank
	move.l	d0,-(sp)
	MOVE	SR,D0	get status register
	OR	#$7,D0	set no interrupts
	MOVE	D0,SR
	MOVE.L	hbl_vector,$68   reset old vector
	MOVE	SR,D0
	AND	#$F8FF,D0	set interrupt level to zero
	MOVE	D0,SR
	move.l	(sp)+,d0
	RTS
hbl_vector DS.L 1
*----------------
* 	PICDUMP
* Press Alt-Help to dump screen to disk rather than printer
* To use, call install_vbi
* then read vbi_request1 (flag)
* from main program, and if set
* clear it.
* Exit to be finalized

install_vbi
eol	EQU	0	;setup constant
	bsr	superin
	move.l	$70,exitvbi+2	;get system vbi vector/save it
	move.l	#vbi_routine1,$70	;set my vbi as first
	bsr	superout
	RTS
;This is the easy way to install a vertical blank interupt 
;enabling it to be the first to execute, the reason for the need to be
;first is to reset the hard copy dump flag after our disk dump
;otherwise we would also get a print out.

vbi_routine1
	tst.w	$4ee	;alt/help key pressed
	bne	exitvbi	;no
	bset	#0,vbi_request1	YES
	move.w	#$ffff,$4ee	;reset alt/help flag
exitvbi	jmp	$ffff	;exit to old system vbi
vbi_request1	
	DC.W	0
*	note the use of JMP to unknown
* this vbi_request flag will now be tested by the main prog
*----------------------------------------------------------
* Now the PICDUMP routine 
* I've excluded the rez checks and assume LOW RES
* screen expected in 'save_screen' (L)
* see example in shell.s when you press D
picdump
	movem.l d0-d5/a0-a5,-(sp)
save_palette
        move.b $44c,paleta+1     ;move res header
        lea   $ff8240,a0        ;now copy palette
        lea   paleta+2,a1        ;to header \note precise pointer
        move.w #15,d0           ;copy 16 words
ccolor  MOVE.W (A0)+,(A1)+        to our buffer
        DBRA D0,ccolor
        move.l #fname,a0
        BSR f_create
        MOVE.L #fname,A0
        MOVE.L #paleta,A3
        move.l #34,D3
        BSR f_write
        MOVE.L #fname,A0
        MOVE.L save_screen,a3	screen address
        MOVE.L #32000,D3
        BSR f_write
        BSR f_close
	movem.l (sp)+,d0-d5/a0-a5
        RTS
paleta	dc.b 0,0	flag for res
	ds.w 16   palette
fname	dc.b 'APIC.PI1',0	EOL
	even
*-------------
* puts a block on screen, eored with background
* must start on a 16 boundary 
* expected: a0 origin (L), a1 destination (L), 
*           d6 number of chunks (W) (1 chunk=16 pixels)  d7 height (W)
* max chunks:20 
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
*	EXAMPLE 
*	move.l spr_screen,a0    move.l $44e,a1   move.w #8,d6
*	move.w #70,d7   jsr or_block
* there is a MACRO for it, called 'block'
* * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
or_block
	move.w	#160,d0
	move.w	d6,d5		save chunk number for now
	lsl	#3,d6		chunks times 8
	sub.w	d6,d0		say 160-32 (line offset)
	move.w	d0,d4		save it as a line offset
	move.w	d5,d6		retrieve chunk number
	sub.w	#1,d6		adjust for loop
	sub.w	#1,d7		loop, height
.lp	move.w	d6,d5		loop, chunks	
.loop	movem.l	(a0)+,d2/d3	get all 4 planes in one go
	move.l	d2,d0		combine...
	or.l	d3,d0		...the lot of them.
	move.w	d0,d1		convert result..
	swap	d0		into..
	or.w	d1,d0		..a mask
	not.w	d0		now invert it
	clr.l	d1	
	move.w	d0,d1		put mask in lower word of D1
	swap	d1		now it's in the high word
	move.w	d0,d1		now it's in both
	and.l	d1,(a1)		merge..
	or.l	d2,(a1)+	..all this lot...
	and.l	d1,(a1)		...with...
	or.l	d3,(a1)+	...the background on actual screen.
	dbra	d5,.loop
	add.w	d4,a0		line offset
	add.w	d4,a1
	dbra	d7,.lp
	rts
*-------------------------
* how to save 1/2 a degas_screen from utility_screen to disk
* no palette is saved at this point
half_degas
	print	prompt2			"enter file name..say bill.pic."
	bsr	getline  		input filename
	vsync				
	create	keybuff+2 		recall that name
	move.l	#16000,d0		length
	writee	utility_screen,d0	write to disk
	close
	rts

prompt2		dc.b "give it a name (***.pic)",10,13,0
	even
*-------------------------
* how to view a number of BYTES in an array, anywhere,
* a0 to point to array.
* currently, successive numbers do not scroll (fixed position)
* ex: lea my_array,a0   jsr view_array
* hit key to progress through array.  Hit UNDO to exit.
view_array
	flash	6,2
lllpp	clr.l	store
	move.b	(a0)+,store+3		get that byte
	move.l	a0,-(sp)		preserve a0
	bindec	store,10		10=dec  16=hex  2=bin
	printat	7,20,22,a0		show it (always same position)
	getkey
	move.l	(sp)+,a0
	swap	d0
	cmp.b	#$61,d0			undo to quit
	bne	lllpp
	rts

*--------------------------
* mfp end-of-interrupt timer bits: timer A bit 5 of $fffa0f
* B bit 0 od $fffa0f  C bit 5 of $fffa11   D bit 4 of $fffa11
* these must be bclr prior to rte
* delay modes: 0 stop timer   1 divide by 4   2 divide by 10
* 3 divide by 16   4 divide by 50   5 divide by 64  
* 6 divide by 100  7 divide by 200
* timers are normally used in delay modes, (rather than pulse mode)
* the mfp operates at 2457600 hz:  to get an interrupt every 3.9 milliseconds:
* put 4 in control and 256 in data.     Another example:
* 2457600/50=49152  then 49152/192=256  256 hz= 5.1 seconds  

* disable MFP	expects interrupt # in D0 (w)
di_mfp	move	d0,-(sp)	
	move.w	#26,-(sp)
	trap	#14
	addq.l	#4,sp
	rts
*------------
* enable MFP	expects interrupt # in D0 (W)
en_mfp	move.w	d0,-(sp)
	move.w	#27,-(sp)
	trap	#14
	addq.l	#4,sp
	rts
*------------
* set line interrupt timer B   expects D0 and D1 (W)
* also called xbtimer  See Anatony.
stimb	move.l	#-1,-(sp)		timer B (line counter)
	move.w	d0,-(sp)		data
	move.w	d1,-(sp)		control
	move.w	#1,-(sp)		timer 0=A  user
	move.w	#31,-(sp)		timer 1=B	 h/blank count
	trap	#14			timer 2=C	 system timer
	add.l	#12,sp
	rts
*------------
* initialize an MFP timer
* see Kenn Garroch's articles in folder
xbtimer	move.l	a0,-(sp)		address of our routine
	move.w	d0,-(sp)		data like 2 (2 lines per count
	move.w	d1,-(sp)		control like 8 for h/blank
	move.w	#0,-(sp)		timer 0=A  1=B  2=C  3=D
	move.w	#31,-(sp)
	trap	#14
	add.l	#12,sp
	rts
*------------
* same as above  see k