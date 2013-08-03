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
* same as above  see k. Garroch's ST Update Sept 87  and PCW April 89
inimfp	move.l	d0,-(sp)		address of routine
	move.w	d1,-(sp)		say 8 for vector 8 (h/b)
	move.w	#13,-(sp)
	trap	#14
	addq.l	#8,sp
	rts
*------------
* works best if pictures has lots of $0's (blank background) or $ff's
* a prompt will ask for a reference byte (0  or  f)
* Camy Maertens October 9, 1989
compact
	show	lady_screen
	cls
	font	16
	home
	print	prompt
	bsr	getline  		input filename
	vsync				..lines must stay
	open	keybuff+2 		recall that name
	tst.w	d0			if error, we don't come
	bmi	comp9			back here (rts during open)
	read	#palette_x,34		Must be a #
	print	prompt_3
	getkey				0 or f
	swap	d0
	cmp.b	#$70,d0			keypad 0
	beq	.zer
	cmp.b	#$0b,d0			top 0
	beq	.zer
	cmp.b	#$21,d0			f
	beq	.f
.zer	move.b	#0,reference_byte
	bra	.ov
.f	move.b	#$ff,reference_byte

.ov	read 	$44e,32000		actual data
	close
	palette	palette_x+2

	move.l	#32000,d7		32000 bytes to check
	move.l	lady_screen,a0		origin
	move.l	utility_screen,a1	destination
	clr.l	d6
	move.b	reference_byte,d6		usually $00 or $ff
.next	sub.l	#1,d7			loop
	beq	.end
	move.b	(a0)+,d0		one byte at a time
	tst.w	b_flag			if set : repeat
	beq	.notset
	bra	.set
.notset	move.b d0,(a1)+			not set: we store it
	add.l	#1,storel		length counter
; now let's examine this byte to see if it is same as reference byte
.set	
	cmp.b	d6,d0			same as reference byte?
	beq	.zero			same
	tst.b	z_ct			zero last time around?
	beq   	.eq			no
	clr.b	z_ct			yes. ok no more		
	add.w	#1,a1			next destination
	move.b 	d0,(a1)+		store this latest non-zero value
	add.l	#2,storel
.eq	clr.w	b_flag			not zero: flag clear
	bra	.next			goto next byte
.zero	move.w	#1,b_flag		zero: set flag
	add.b	#1,z_ct			number of successive zeroes
	move.b	z_ct,(a1)
	cmp.b	#125,z_ct		byte cmp not accurate above 127
	bne	.next
	sub.b	#1,z_ct			adjust
	move.b	z_ct,(a1)
	move.b	#1,z_ct			restart at one
	move.b	d6,1(a1)		another zero
	move.b	#1,2(a1)		store that one
	add.w	#2,a1			new pointer
	add.l	#2,storel		length
	bra	.next			goto next byte
.end	
* ok now we save this compacted file to disk
* no palette is saved at this point
	print	prompt2			"enter file name..."
	bsr	getline  		input filename
	vsync				
	create	keybuff+2 		recall that name
	write	#palette_x,34
	write	#reference_byte,1
	move.l	storel,d0		recall length
	writee	utility_screen,d0	write to disk
	close
comp9	rts

z_ct		dc.b	0,0		successive zeroes
b_flag		dc.w 	0		zero on/off flag
reference_byte	dc.b	0,0
prompt_3	dc.b	"reference_byte",13,10,0
	even

* storel can now be printed to reveal the number of bytes
* beware not to print onto the compacted screen as it will
* be corrupted!!!      :  bindec storel,10     printat 7,23,0,a0	

*-------------------------
* decompact:  see compact first
* a compacted picture previously loaded in utility_screen
* will be re-built in spr_screen (or wherever)
* the format is : 2 bytes res, 32 bytes palette, 1 byte reference, data...
* number of bytes expected in d7, destination in a1
decompact
	clr.l	storel			used as a byte counter only
	clr.l	d5
	clr.l	d6
	move.l	utility_screen,a0	origin      (dest in a1)
	move.b	reference_byte,d6
.next	sub.l	#1,d7			decrement loop
	beq	.out			out
	move.b	(a0),d0			analyse one byte...
	move.b 	d0,(a1)			..and rebuild it
	cmp.b	d6,d0			same as reference?
	beq	.zero
	add.w	#1,a0
	add.l	#1,storel		for internal use only
	add.w	#1,a1
	bra	.next
.zero	clr.l	d5
	move.b	1(a0),d5		special loop...
	tst.b	d5			(avoid negative number
	beq	.out			at all cost)
.ok	sub.w	#1,d5			...for zeroes only
.zloop	move.b	d6,(a1)+
	dbra	d5,.zloop
	add.w	#2,a0
	add.l	#2,storel
	bra	.next
.out	rts
*------------------
* check for multiples of 8 using AND mask  ex:
; move.w soso,d0
; and #7,d0  ... says K Garroch
