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
eq	.a
	bclr	#6,$fffa11	acknowledge key press interrupt
	rts
* then cmpi.b #$01, d0 ... or whatever key is tested

*----------
* As soon as all unnecessary memory has been given back
* to Gem, we go supervisor.  Ex: jsr superin
superin 
	movem.l	d0-d5/a0-a5,-(sp)
	move.l	#$1,-(sp)  
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.l	-(sp)  		enter supervisor mode
	move.w	#32,-(sp) 
	trap	#1
	addq.l	#6,sp
	move.l	d0,savestk	save old stack pointer
	movem.l	(sp)+,d0-d5/a0-a5
	rts
savestk  	DS.L 1
*----------
* Next routine is activately automatically on exit from shell.
* jsr kwit   is the proper way to exit the shell
superout 
	movem.l	d0-d5/a0-a5,-(sp) 
	move.l	savestk,-(sp) 	exit supervisor
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	movem.l	(sp)+,d0-d5/a0-a5
	rts
*----------
** get screen rez into D0
getrez	move.w	#4,-(sp)
	trap	#14
	addq.l	#2,sp
	rts
*----------
* this routine is for Budgie games only
* the shell does a 'jsr kwit' which then comes here
quith	bsr	rst_horizontal_blank  if there was one
quit	bsr	resmouse
	bsr	clearbuf
quits	
	move.l	physbase,$45e	call this exit label if no..
	move.l	#atari_palette,A0	..interrupts were used
	BSR	setpal
	btst	#7,$fffa01	monochrome ?
	beq	qu2
	bsr	setmedrez
qu2	move.w	#$007,$ff8244	blue background 
	move.w	#$005,$ff8246	blue ink
	bset	#1,$484		key repeat  still supervisor
	bsr	superout
	move.w	#2,-(sp)		default values
	move.w	#15,-(sp)		key repeat  rate
	move.w	#35,-(sp)
	trap	#14
	addq.l	#6,sp

	move.w	#0,-(sp)
	move.w	#$4c,-(sp)
	trap	#1

* to quit and stay resident :
quit_stay
	clr.w -(sp)
	move.l proglength,-(sp)
	move.w $31,-(sp)
	trap #1
	even
atari_palette 
	DC.W	$777,$700,$007,$005,$007,$707,$77,$555,$333
	DC.W	$733,$373,$773,$337,$737,$377,$0
proglength	dc.l 0
prog_start	dc.l 0
*-----------

* BINDEC   binary to decimal ascii    
* enter with D0 as binary number
* and A0 as address of 6-byte buffer for string
* >>>>> examples in Speculator and Final Lap <<<<<<<<<
* also in shell.s under k_star (reveal all registers)
* there is now a macro called 'bindec' which will return 
* a given binary number (L) in A0
bindec 	movem.l	d0-d1/a0,-(sp) 
	MOVE.B	#' ',D1
	TST.W	D0
	BPL.S	notneg
	MOVE.B	#"-",D1
	NEG.W	D0
notneg	MOVE.B	D1,(A0)+
	ADDA.L	#4,A0		this figure previously 5 but some
	MOVE.W	#4,D1	failure on display caused a change to 4...
binloop EXT.L	D0
	DIVS	#10,D0
	SWAP	D0
	MOVE.B	D0,-(A0)
	ADD.B	#"0",(A0)
	SWAP	D0
	DBRA	D1,binloop
	movem.l	(sp)+,d0-d1/a0
	RTS
*----------
* PRINTN [ Janice Murray  March 1989 ]
* will print any L number in D0 (max 652000 approx)
* in base specified in D1 (2-10-16) Default 10 (decimal)
* the result is stored in a 20 byte-long string, starting from the end!
* leading nulls will force gemdos $09 to home position
* and only real digits towards the end of the string will be printed.
* I have therefore substituted nulls with spaces
* to recall: printat 11,12,0,num_buff+14 which will print on screen
* at location 12-0  in ink 11  a number 6 digit long (20-14=6)
* printat 11,12,0,num_buff+16 will only print the last 4 digits, and so on
* ex: >>> move.l physbase,d0  move.l #16,d1  bsr printn <<<<< 
* ex >>>>> in shell.s (under k_star) <<<<<
printn
	and.l	#$ff,d1
	cmp.l	#16,d1		hex?
	beq	.go
	cmp.l	#2,d1		binary?
	beq	.go
	move.l	#10,d1		ok decimal
.go	lea	num_buff(pc),a0 we'll put result her 
	move.w	#19,d7		clean up 20 byte- buffer
.cl	move.b	#" ",(a0)+	spaces (originally clr.b)
	dbra	d7,.cl
.lp1	divu	d1,d0		number is continuously divided by base right down to 1	
	swap	d0		d0 low is remainder
	addi.w	#"0",d0		make into digit
	cmpi.w	#"9",d0		digit or letter?
	ble	.ok
	addq.w	#7,d0		letter!
.ok	move.b	d0,-(a0)	store character (staring from end)
	clr.w	d0		
	swap	d0		d0 low: quotient
	bne	.lp1		another one?
	rts
num_buff
	ds.b	20		20 digit buffer
	dc.b 	0		end marker
	ds.l	6		safety	
	even
*-----------
* time delay	expects a figure in D5 **
* note: D5 is NOT saved. Save if necessary prior to calling
delay	
	move.l	d0,-(sp)
outer	move.w	#5000,D0	inner loops
inner	tst.w	D0
	dbeq	D0,inner                         
	tst.w	D5
	dbeq	D5,outer
	move.l	(sp)+,d0
	rts
*------------
* gemdos random
random
	movem.l	d1-d3/a0-a3,-(sp)
	move.w	#17,-(sp)		answer in D0 (L)
	trap	#14
	addq.l	#2,sp
	movem.l	(sp)+,d1-d3/a0-a3
	rts
*----------
* Joysticks *  [ ST World ]
* call initjoy once to initialize
* see full example in Budgie shell.s
* there is now a macro (getjoy) that waits for a button press
* and another one (joystick) that merely peeks the state of joystick
initjoy 
	MOVE.W	#$14,-(SP)	IKBDcommand to send joystick
	MOVE.W	#4,-(SP)	packages to IKBD
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP
	MOVE.W	#34,-(SP)	get address of IKBD vector table
	TRAP	#14
	ADDQ.L	#2,SP
	MOVEA.L	D0,A0
	ADDA.L	#24,A0	move to joy vector address in table
	LEA	oldpack(PC),A1
	MOVE.L	(A0),(A1)	save original packet handler address
	LEA	joypacket(PC),A1	address of new packet handler
	MOVE.L	A1,(A0)		modify joystick vector to point
	RTS			to our routine
*----------
* Joystick packet handler   (called by o/s) *
joypacket
	MOVEM.L	A0/A1,-(SP)	A0 points to addr of joy data
	LEA	joyport0(PC),A1	load addr of our new register
	MOVE.B	1(A0),(A1)	move joystick data to our loc
	MOVE.B	2(A0),1(A1)	and the same for port 1
	MOVEM.L	(SP)+,A0/A1
	RTS
* return to normal mouse control *
resmouse
	MOVE.W	#34,-(SP)	address of IKBD vector table
	TRAP	#14
	ADDQ.L	#2,SP
	MOVEA.L	D0,A0
	ADDA.L	#24,A0	move to joy vector address in table (24)
	MOVE.L	oldpack(PC),(A0)	restore original pack hndler
	MOVE.W	#128,-(SP)	reset keyboard processor to
	MOVE.W	#4,-(SP)	power up state
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP
	MOVE.W	#1,-(SP)
	MOVE.W	#4,-(SP)	and again
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP
	RTS
oldpack   DC.L	0	storage for old packet handler address
joyport0  DC.B	0
joyport1  DC.B	0
*------------
* call initmous once ONLY to initialize
* example in >>>>> MONEYSPINNER  <<<<<
initmous 	
	MOVE.W	#$08,-(SP)	IKBD command to send relative mouse
	MOVE.W	#4,-(SP)	packages from now on
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP
	MOVE.W	#34,-(SP)	get address of IKBD vector table
	TRAP	#14
	ADDQ.L	#2,SP
	MOVEA.L	D0,A0
	ADDA.L	#16,A0		mouse vector address in table
	LEA	oldpak(PC),A1
	MOVE.L	(A0),(A1)	save original packet handler address
	LEA	mouspacket(PC),A1	address of new packet handler
	MOVE.L	A1,(A0)		modify vector to point
	RTS			to our routine
*----------
* Mouse packet handler   (called by o/s) *
* see MONEYSPINNER for details
mouspacket
	movem.l	a0/a1,-(sp)	A0 points to addr of packet received
	lea	mse_packet(pc),a1	 A1 is where we store it
	clr	d0
	move.b	(a0),(a1)	header (buttons)
	move.b	1(a0),d0	x movement
	ext	d0   		make it a word (added nov 88)
	add.w	d0,2(a1) 	new x position (lateral 0-320)
	tst.w	2(a1)		below 0 ?
	bpl	.m1		ok
	clr.w	2(a1)		keep it at 0
.m1	cmp.w	#302,2(a1)	too large? off screen
	bmi	.m2		no  ok
	move.w	#302,2(a1)	hold it there
.m2	clr	d0
	move.b	2(a0),d0	y movement
	ext	d0	
	add.w 	d0,4(a1) 	new y position (vertical 0-200)
	tst.w	4(a1)		below 0 ?
	bpl	.m3		ok
	clr.w	4(a1)		keep it at 0
.m3	cmp.w	#186,4(a1)	too large? off bottom?
	bmi	.m4		no  ok
	move.w	#186,4(a1)	hold it there
.m4	movem.l	(sp)+,a0/a1
	rts

* return to normal mouse control *
resmous	
	MOVE.W	#34,-(SP)	address of IKBD vector table
	TRAP	#14
	ADDQ.L	#2,SP
	MOVEA.L	D0,A0
	ADDA.L	#16,a0		mouse vector
	MOVE.L	oldpak(PC),(A0)	restore original pack hndler
	MOVE.W	#128,-(SP)	reset keyboard processor to
	MOVE.W	#4,-(SP)	power up state
	MOVE.W	#3,-(SP)
	TRAP	#13
	ADDQ.L	#6,SP		and again
	MOVE.W	#1,-(SP)	data to write 128 and 1 = reset
	MOVE.W	#4,-(SP)	4 is ikbd
	MOVE.W	#3,-(SP)	3 is chr out
	TRAP	#13
	ADDQ.L	#6,SP
	RTS
oldpak 	DC.L	0	storage for old packet handler address
mse_packet
	DC.B	0	button
	dc.b  	0 	empty byte (not used)
	dc.w 	160     x 	0 to 320 max
	dc.w 	20 	y	0 to 200 max	
	dc.b	0,0,0,0,0,0
	even
*-----------
* VERTICAL SCROLL [ Simon Rush ]  May 20, 1987 
* there is a macro to call it (called 'scroll')
* see full example in shell.s  under 'opening sequence'
* this routine merely scrolls a block on itself.
* for scenery scrolling, see the example inside shell.s
* by pressing V 

* expects times in D2, width in D3,
* left corner + margin in D4 and height in D5
* macro example in all budgie shells under 'opening sequence'
* modified aug 89  (B is now L) ~~ much faster

scrol	move.w	d3,d6		width
	lsr	#2,d3		divide by 4
.scrol
	MOVE.L	$44e,A1		origin
	ADD.W	D4,A1		bottom left corner
	MOVE.L	$44e,A2		destination
	add.l	#160,A2
	ADD.W	D4,A2		bottom left 
	MOVE.W	D5,D1		height
.a 	MOVE.W	D3,D0
.lp 	MOVE.l (A1)+,(A2)+  
	DBRA	D0,.lp	loop
	SUB.L	#164,A1	
	SUB.W	D6,A1  
	SUB.L	#164,A2	
	SUB.W	D6,A2
	DBRA	D1,.a
	MOVE.L	$44e,A2
	adda.w	#160,A2
	ADD.W	D4,A2 
	MOVE.W	D3,D0
	ADD.L	#160,A1
.s 	MOVE.l	(A2)+,(A1)+
	DBRA	D0,.s          
	DBRA	D2,.scrol
	RTS
*------------
* increment palette color register 0 (border)  [ Rik Haynes ] Jul 87
* 	expects a number in D3 (10000 = 2 seconds approx)
* Again, we now have a macro, called 'flash'
flashes
	movem.l	d0-d3/a0,-(sp)
	lea	$ff8240,a0	register address
	move.w	#0,(a0)		start with black
fla1 	ADD	#61,(A0)	increment contents 
	CMP.W 	#$770,(A0)                
	BMI	fla2
	MOVE.W	#0,(A0)		reset color
fla2	MOVE.L	#256,D1
fla3	DBRA	D1,fla3
	DBRA	D3,fla1
	movem.l	(sp)+,d0-d3/a0
	rts
*------------
flashes_b
	movem.l	d0-d3/a0,-(sp)
	lea	$ff8240,a0	register address
	move.l	(a0),-(sp)	save original color
fla00	move.w	#0,(a0)		start with black
	move.l	#200,d1
fla11	dbra	d1,fla11	delay
	move.w	#$777,(a0)
	move.l	#200,d1
fla22	dbra	d1,fla22	delay
	dbra	d3,fla00	number of iterations required
	move.l	(sp)+,(a0)	restore original color
	movem.l	(sp)+,d0-d3/a0
	rts
*------------
* new palette expects address in A0
* see macro called 'palette'  
setpal  
	movem.l	d0-d2/a0-a2,-(sp)
	move.l	a0,-(sp)
	move.w	#6,-(sp)
	trap	#14
	addq.l	#6,sp
	movem.l	(sp)+,d0-d2/a0-a2
	rts
*----------
* here is how to save a palette
	movem.l	$ff8240,d0-d7
	movem.l	d0-d7,palet
*---------------------------
* here is how to quickly turn screen black
	movem.l	blanks(pc),d0-d7	; all nulls
	movem.l	d0-d7,$ff8240		; all colors are now black
blanks	ds.w	16
*----------------
*	REVEAL	[ Camy Maertens ]  July 1 1987
* will reveal the contents of D0
* >>> see 'r`  
  (       Œ          /<  
?< 	NA\*O.|  *m  - Ð­ Ð­ €   / /Bg?< JNAOï /<   è/<   èHy   î?<  ?< KNAßü   ?<  ?< LNA                                                                                                                                      a:\music\lisa_14.prg                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  GET_BUTT¢   PINITIALI¢    0MESSAGEB¡    RLOADED_¢    jSET_BUTT¢   GET_TEDI¢   LEAD_ZER¢   dSET_TEDI¢   âBADRSC_A¤    2DEINITIA¢   rRSC_FILE¤     GEM_CTRL¤    vVOLUME_B¢   ,________¢   â________¢   j   2$

À


,

0 (


 &&


P$


Ê







$&20220
šŠ










&








Žd                   ?ð ?ÿÿþà    à  ÿÀÿÿþ        àþàþÿÿþ                                     ?ð ÿÿþà    ð  ÿÀÿÿþ        àþÿÿþÿÿþ                                     ?ð ÿÿþÿà   ø ÿÿÀÿÿþ        ÿÿþÿÿþàþ                                     ?ð ÿÿþÿà   ü ÿÿÀÿÿþ        ÿÿþÿÿþàþ                                     ?ð ÿÿþÿà   þ ÿÿÀÿÿü        ÿÿþ?ÿÿüàþ                                     ?ð ÿÿþÿà    ÿ ÿÿÀÿÿü        ?ÿÿü?ÿÿüàþ                                     ?ð ÿÿþÿà      ÿÿÀÿÿø        ÿÿøÿÿøàþ                                     ?ð ÿÿþÿà      ÿÿÀÿÿà        ÿÿàÿÿààþ                                                        à                    þ                                                                                                                                                                                                                                                                                                                                                                     8ü    88pl0   xøø8øxüxx88 px xø|øüü|Ìxl`ÌÌxøxø|üÌÌÌÌÌü|à|                   8ü    8p880   8Ü8xÀÀÌÌ888|8Ü ÌÌÀÌÀÀÀÌ0x`üìÌÌÌÌÀ0ÌÌÌxÌpp                   8Ø    pp8|ü | püxxØøøx|  p 8 üøÀÌøøÜü0p`üüÌøÌøx0ÌÌü0x0p8                   8      p8808 8àìÀüÌ0Ì888|88 ÌÌÀÌÀÀÌÌ0Ìx`ÌÜÌÀÌð0Ìxüx0`p                          8pl08 8Àxüøøx0xx8 p  Ìø|øüÀ|Ìxxl|ÌÌxÀxÜø0|0ÌÌ0ü||ÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿÿ                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              