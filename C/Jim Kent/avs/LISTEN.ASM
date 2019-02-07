	;:ts=8		;tell Z tab = 8 spaces
	far data	;tell Aztec compiler to do absolute addresses

****************************************************
*                                                  *
*    (c)  A.Racine   2-Bit Systems Ltd  14/7/87    *
*    (c)  Jim Kent   Dancing Flame      5/20/88    *
*                                                  *
*    date                   mod                    *
*   14/7/87       Make basic sounds clearer        *
*   19/7/87   Prevent mouse from crashing basic    *
*   5/20/88   JK hacked in delta playback          *
****************************************************
*
* The goal of this module is to play digitized sound while displaying
* a Cyber Sequence animation.   The sound is done on an interrupt.
* The interrupt happens at the sound sampling rate which will range
* from 5Khz to 30Khz.  The faster the sampling rate the less time there
* will be for animation, but the clearer the sound will be.  20Khz
* samples seem to be a good compromise.
*
* In order to make the interrupt routine as fast as possible, it is
* necessary to devote a few registers just to the interrupt so that it
* won't have to save them to the stack and reload them from memory.
* Registers d0,d6,d7,a2,a3,and a6 are used by the interrupt.
*
* The animation routine expects the first frame of the animation to
* be on the screen already.  It's passed list of delta frames.  Each
* frame starts with a 16 bit count of the number of deltas in this frame.
* A count of 0 means it's the last frame.  Next comes the deltas.  Each
* delta is a 16 bit offset into the screen followed by a 32 bit value to
* xor in at that offset.
*
* The sound routines expect a series of 8 bit samples.  The sample count
* is passed separately.  The samples are signed value.  This is a slight
* modification of STreplay samples which are unsigned.  It plays back just
* a tad faster this way, but a small routine to subtract $80 from each
* sample must be called after loading the replay file from disk (not in
* this module).
*
* The parameters to this routine are passed in the code space rather
* than on the stack.  This is a wierd way to do it that happened because
* this is a hack on a file that was to interface with Basic rather than C.
* Sadly it is harder to use this routine with basic these days 'cause 
* it's not position independent.
*****************************************************
*
*	MFP equates	(bits in the timer chip)
*
mfp	equ	$fffa00
iera	equ	$07
ierb	equ	$09
ipra	equ	$0b
isra	equ	$0f
imra	equ	$13
imrb	equ	$15
vector	equ	$17
tacr	equ	$19
tadr	equ	$1f
isrvec	equ	$134
*
*
hbase	equ	$ff8000		* base for doing movep's with 16 bit offset
cmap    equ     $ff8240         * hardware color map
pscreen equ	$ff8203		* hardware screen
*
*	the sound chip
*
snd_chp	equ	$ff8800 chip address	
screg	equ	0	chip register select
scdata	equ	2	register data
*
*	the keyboard & midi acia's
*
kbdcont	equ	$fffc00
kbddata	equ	kbdcont+2
midcont	equ	$fffc04
middata	equ	midcont+2

*	bdos equates (trap #1)

f_super  equ	$20
Cconis	equ	$B

*	xbois equates (trap #14)

ikbdws	equ	25

	public	_just_sound
_just_sound
	move.w	#$2700,sr	;no interrupts until set up finished
	move.w	#1,slpct ;store # of loops
	move.l	slist,d6	;get start of sample
	move.l	d6,a6		;load next sample register
	add.l	vlist,d6	;add length of sample
	move.l	#ireplay,isrvec
	move.b	#1,inuse	;Let rest of world know sound is happening.
	move.l	screen,d1	;get frequency
	bsr	setfreq		;tell mfp to start generating interrupts
	move.w	#$2400,sr
busywait	
	tst.b	inuse	Sample finished ?
	bne.s	busywait	Busy-wait until it is!
	rts

	;do a relatively fast full screen copy 
cpscreen
	move.w	#999,d1
	move.l	screen,a5
cpslp	move.l	(a0)+,(a5)+
	move.l	(a0)+,(a5)+
	move.l	(a0)+,(a5)+
	move.l	(a0)+,(a5)+
	move.l	(a0)+,(a5)+
	move.l	(a0)+,(a5)+
	move.l	(a0)+,(a5)+
	move.l	(a0)+,(a5)+
	dbra	d1,cpslp
	rts

	;move vbcmap to hardware clut registers
set_cmap
	move.b	#1,cms	;set flag to say have set cmap
	move.l	vbcmap,a0	;get pointer to data
	lea	cmap-hbase(a2),a5	;and pointer to clut
	move.w	#7,d1		;move 8 longwords
scm	move.l	(a0)+,(a5)+
	dbra	d1,scm
	rts

snstart	equ	0
snsample equ	4
snscount equ	8
snfreq	equ	12
snloops	equ	14
snstruct_size	equ	16

vstart	equ	0
vsample	equ	4
vscount	equ	8
vspeed	equ	12
vloops	equ	14
vframe1	equ	16
vstruct_size	equ	20


*ani_vblank
*	a psuedo vblank handler
*	actually is called frequently as the main loops polls to see
*	if it's in a vblank

ani_vblank
	;free regs - a0, a5, d1, d4
	tst.b	cms		;if haven't set color map set it.
	bne	inctime
	bsr	set_cmap
inctime	move.l	_time,d4	;increment time
	add.l	#1,d4
	move.l	d4,_time

nextsn	move.l	slist,d1	;check slist
	beq	nextvl
	move.l	d1,a5
	cmp.l	snstart(a5),d4
	bmi	nextvl

	;here we've got a new sound sample to set up
	move.l	snsample(a5),d1	
	beq	endslist	;NULL sample = STOP
	move.w	#$2700,sr	;no interrupts until set up finished
	move.l	d1,sample	;save sample for loops
	move.w	snloops(a5),slpct ;store # of loops
	move.l	d1,a6		;load next sample register
	move.l	snscount(a5),d6	;get count and add it to start sample
	add.l	d1,d6		;d6 = end of sample table
	move.l	#ireplay,isrvec
	move.b	#1,inuse	;Let rest of world know sound is happening.
	move.w	snfreq(a5),d1	;set initial frequency and
	bsr	setfreq		;tell mfp to start generating interrupts
	add.l	#snstruct_size,slist
endnsn	move.w	#$2400,sr


nextvl	move.l	vlist,d1	;check vlist
	beq	novlist
	move.l	d1,a5
	cmp.l	vstart(a5),d4	;see if reached start time for this one...
	bmi	novlist
	move.l	vsample(a5),d1
	beq	endvlist	;NULL sample = STOP
	move.l	d1,dlist
	move.l	d1,dpt
	move.l	d1,a0
	move.w	vloops(a5),vlpct
	move.w	vspeed(a5),d1
	ext.l	d1
	move.l	d1,speed
	move.l	vscount(a5),d1
	move.l	d1,dcount
	move.l	d1,dlcount
	move.l	(a0),vbcmap	;put up initial color map
	move.l	a5,-(sp)
	bsr	set_cmap
	move.l	(sp)+,a5
	move.l	vframe1(a5),a0	;put up initial screen
	bsr	cpscreen
	add.l	#1,_time	;copy takes roughly 1/60th sec.
	add.l	#vstruct_size,vlist
	move.l	#twait,(sp)	;jump direct to twait on return...
novlist	rts

endvlist
	move.l	#0,vlist
	move.b	#1,vdone
	rts

endslist
	move.l	#0,slist
	move.l	#inull,isrvec	;interrupt vector to nowhere...
	move.l	#0,d1		;low frequency interrupts (for keyboard???)
	bsr	setfreq		
	bra	endnsn	;go back to rest of 'vblank' code

tend	clr.l	dpt
	bra	twait

	public _aniwait
_aniwait
	clr.b	vdone
	clr.l	dpt
	clr.l	_time
frame:
	move.l	_time,d1	;go get the time and add a little to it.
	add.l	speed,d1
	move.l	d1,dtime	;dtime has time to go onto next frame

getloop
	move.l	dpt,d4		;get pointer to the deltas
	beq	twait		;if no animations just do vblank processing
	sub.l	#1,dcount
	bpl	noloop	;go to gscreen if not at end of deltas
	move.w	vlpct,d1 ;grab loop counter
	sub.w	#1,d1	 
	beq	tend	 ;if no loops left we're outta here...
	move.w	d1,vlpct
	move.l	dlist,dpt
	move.l	dlcount,dcount
	bra	getloop
noloop

	move.l	d4,a4
	add.l	#4,d4
	move.l	d4,dpt
	move.l	(a4),a4
	move.l	a4,vbcmap
	add.l	#32,a4

	move.l	screen,a1	;get pointer to the screen
	move.b	#0,cms		;set flag that haven't set color map this frame
	move.w	(a4)+,d2	;Load delta count for this frame.  If 0 done.
	move.w	d2,d3		;Going to do first bunch 32 deltas at a time...
	asr.w	#5,d3		;so do a cheap divide by 32.
	bra	zbddlp			;and branch to end of 32-at-a-time loop
bddlp	
; Will look at hardware video beam register to see if we're in vblank.
; Need to do this rather frequently ... every 32 deltas in fact.
; If it's the start of vblank we'll increment our time variable and
; go set the color map.
	dc.w	$034a	;movep.l	pscreen-hbase(a2),d1
	dc.w	pscreen-hbase  ;(silly Aztec assembler doesn't know about movep)
	and.l	#$00ffffff,d1  ;mask crufty bits...
	cmp.l	d5,d1	       ;see if we've been here before...
	beq	utime0	       ;not 1st time in vblank if we have
	move.l	d1,d5		
	cmp.l	screen,d1	;Test if in vblank.
	beq	invblank0	
	bra	utime0
invblank0	
	bsr	ani_vblank
utime0	


;Now do 32 deltas
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
;there's 8
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
;16
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
;24
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
;32
;Here's a little loop to do the remainder of the deltas after dividing
;by 32.
zbddlp	dbra	d3,bddlp
	and.w	#31,d2
	bra	zddlp
ddlp	adda.w	(a4)+,a1
	move.l	(a4)+,(a1)
zddlp	dbra	d2,ddlp


;Now we've done the deltas for this frame.  Will have to wait for time
;to put up next frame.  This is slightly less time critical than the
;interrupt routine or the delta routine.  We'll poll in a loop checking
;for vertical blank, and also check to see if the sound's finished.
;If the sound is done then we'll restart it.

;Check for vblank time
twait	
	dc.w	$034a	;movep.l	pscreen-hbase(a2),d1
	dc.w	pscreen-hbase
	and.l	#$00ffffff,d1	;mask crufty bits...
	cmp.l	d5,d1
	beq		utime1
	move.l	d1,d5
	cmp.l	screen,d1
	beq		invblank1
	bra		utime1
invblank1	
	bsr	ani_vblank
utime1	



;check if time's come for next frame 
next_frame	
	tst.b	vdone
	bne	doneframes
	move.l	dtime,d2
	cmp.l	_time,d2
	bgt	twait
	bra frame


;If the PC's made it here then done with animation.  First wait around
;to make sure done with sound too.
doneframes:
	rts



*****************************************
*           the programme               *
*****************************************
*   set up stack, memory & supervisor   *
*****************************************

	public _listen
_listen:
firstp	set	4+4*15
sabort	set	firstp+0
sanivec	set	firstp+2
sslist	set	firstp+6
svlist	set	firstp+10
sscreen	set	firstp+14

super	movem.l	a0-a6/d0-d7,-(sp) save 'basic' system


	move.l	sanivec(sp),anivec
	move.l	sslist(sp),slist
	move.l	svlist(sp),vlist
	move.l	sscreen(sp),screen

	bsr	keysoff		disable keyboard

	clr.l	-(sp)		
	move.w	#f_super,-(sp)	goto supervisor so can poke hardware bits!
	trap	#1
	addq.l	#6,sp

	move.l	d0,stack

	bsr	savemfp		save natural mfp conditions
	lea.l	snd_out(pc),a3	look up tables
	bsr	setsnd		set up sound registers

	move.l	#hbase,a2	;base pointer for hardware
	move.l	anivec,a1	;jump indirect through anivec for the rest
	move.w	#$2700,sr
	move.l	#inull,isrvec	;mfp int. vector to simple rte
;	move.l	#0,d1		;low frequency interrupts (for keyboard???)
;	bsr	setfreq		;tell mfp to start generating interrupts
	move.w	#$2400,sr
	jsr	(a1)
*
*  This tidies the system up before leaving back to basic.
*
exit	move.w	#$2700,sr	disable ints.
	bsr	oldmfp		restore original mfp data
	bsr	keyson		restore keyboard operation
*
*  We must now flush any characters out of the key buffer before
*  re-enabling the interrupts since the flood of data will crash
*  the computer. (users with a midi device connected may need to 
*  flush the midi acia in a similar way).
*
flush	btst.b	#0,kbdcont	is a character waiting ?
	beq.s	intson		br. if not
	move.b	kbddata,d1	read character (& ignore it)
	bra.s	flush		check for another

intson	move.w	#$2000,sr	restore ints for o.s.
	move.l	stack,-(sp)
	move.w	#f_super,-(sp)	return to user mode
	trap	#1
	addq.l	#6,sp

	movem.l	(sp)+,a0-a6/d0-d7 restore 'basic' data
	rts			back to basic


****************************************
*   the interrupt service routines     *
****************************************
*
*	a6 = pointer to base of replay ram
*	a3 = look up table address
*	a2 = hardware offset reg
*	d7 = scratched
*	d6 = pointer to end of replay ram
*	d0 = scratched
*
****************************************
*     the null interrupt routine       *
****************************************

inull	
	rte

****************************************
*       replay from memory             *
****************************************

looprep
	sub.w	#1,slpct
	beq	haltrep
	move.l	sample,a6

ireplay	
	clr.w	d7		set up d7 to be a table lookup
	move.b	(a6)+,d7	read from ram
	cmp.l	d6,a6		exceded end stop
	bgt.s	looprep		branch if so
	lsl.w	#3,d7		double long word offset
	move.l	0(a3,d7.w),d0	get two voices from table
	dc.w	$01ca		movep.l	d0,snd_chp-hbase(a2)
	dc.w	snd_chp-hbase	stuff voice select and volume registers
	move.w	4(a3,d7.w),d0	get third voice from table
	dc.w	$018a		movep.w	d0,snd_chp-hbase(a2)
	dc.w	snd_chp-hbase	stuff voice select and volume registers
	rte

haltrep	
	move.w	#$2700,sr
	movem.l	a0/d1,-(sp)
	move.l	#inull,isrvec	go to short interrupt handler
	move.l	#0,d1		;low frequency interrupts (for keyboard???)
	bsr	setfreq		
	movem.l	(sp)+,a0/d1
	clr.b	inuse
	move.w	#$2400,sr
	rte


***********************************
*     the system sub-routines     *
***********************************
*   preserve the mfp registers    *
***********************************

savemfp	move.l	#mfp,a0
	move.b	iera(a0),mfpmem
	move.b	ierb(a0),mfpmem+1
	move.b	imra(a0),mfpmem+2
	move.b	imrb(a0),mfpmem+3
	move.b	tadr(a0),mfpmem+4
	move.b	tacr(a0),mfpmem+5
	move.b	vector(a0),mfpmem+6
	rts

***********************************
*   restore natural running mfp   *
***********************************

oldmfp	move.l	#mfp,a0
	move.b	mfpmem+6,vector(a0)
	move.b	mfpmem+5,tacr(a0)
	move.b	mfpmem+4,tadr(a0)
	move.b	mfpmem+3,imrb(a0)
	move.b	mfpmem+2,imra(a0)
	move.b	mfpmem+1,ierb(a0)
	move.b	mfpmem,iera(a0)
	rts

******************************
*    ikbd enable/disable     *
******************************

keysoff	pea	skbddis(pc)
	bra.s	do_ikbd
keyson	pea	skbden(pc)
do_ikbd	move.w	#0,-(sp)	1 parameter
	move.w	#ikbdws,-(sp)
	trap	#14
	addq.l	#8,sp
	rts

*****************************************
*       set up mfp frequency            *
*****************************************
*
*   set up mfp timer a to generate interrupts
*   enter with d0.w set with a frequency number 0 to 7
*   e.g. d0.w = $0002 gets 3rd mfp data from table
*
setfreq	
	movem.l	a0/a1,-(sp)
	move.l	#mfp,a1
	move.b	#0,tacr(a1)	disable timer
	and.w	#7,d1		ensure 0-7
	lea	freqtab(pc),a0	get the frequency xref addr
	lsl.w	#1,d1		convert to word table offset
	move.w	0(a0,d1.w),d1	& get the mfp data
	move.b	d1,tacr(a1)	lsb = control reg byte
	lsr.w	#8,d1		shift down next byte
 	move.b	d1,tadr(a1)	next = data reg byte

***********************************
*       enable the mfp            *
***********************************

	move.l	#mfp,a0
	move.b	#$20,imra(a0)
	move.b	#0,imrb(a0)
	move.b	#$20,iera(a0)
	move.b	#0,ierb(a0)
	bclr.b	#3,vector(a0)
	movem.l	(sp)+,a0/a1
	rts

*****************************************
*    set up the sound chip channels     *
*****************************************

setsnd	move.l	#snd_chp,a0
	move.b	#0,screg(a0)	channel a
	move.b	#0,scdata(a0)
	move.b	#1,screg(a0)
	move.b	#0,scdata(a0)

	move.b	#2,screg(a0)	channel b
	move.b	#0,scdata(a0)
	move.b	#3,screg(a0)
	move.b	#0,scdata(a0)

	move.b	#4,screg(a0)	channel c
	move.b	#0,scdata(a0)
	move.b	#5,screg(a0)
	move.b	#0,scdata(a0)

	move.b	#7,screg(a0)	set up channel mixing & port 'a' i/o
	move.b	#$ff,scdata(a0)

	move.b	#8,screg(a0)	set all volumes to zero
	move.b	#0,scdata(a0)
	move.b	#9,screg(a0)
	move.b	#0,scdata(a0)
	move.b	#10,screg(a0)
	move.b	#0,scdata(a0)
	rts
	

***********************************
*	block storage area        *
***************************************
*    internal sound lookup table.     *
***************************************

snd_out	dc.w	$80c,$90b,$a09,0,$80c,$90b,$a09,0
	dc.w	$80d,$908,$a08,0,$80b,$90b,$a0b,0
	dc.w	$80d,$909,$a05,0,$80c,$90b,$a08,0
	dc.w	$80d,$909,$a02,0,$80d,$908,$a06,0
	dc.w	$80c,$90b,$a07,0,$80d,$907,$a07,0
	dc.w	$80c,$90b,$a06,0,$80c,$90a,$a09,0
	dc.w	$80b,$90b,$a0a,0,$80c,$90b,$a02,0
	dc.w	$80c,$90b,$a00,0,$80c,$90a,$a08,0

	dc.w	$80d,$906,$a04,0,$80d,$905,$a05,0
	dc.w	$80d,$905,$a04,0,$80c,$909,$a09,0
	dc.w	$80d,$904,$a03,0,$80b,$90b,$a09,0
	dc.w	$80c,$90a,$a05,0,$80b,$90a,$a0a,0
	dc.w	$80c,$909,$a08,0,$80b,$90b,$a08,0
	dc.w	$80c,$90a,$a00,0,$80c,$90a,$a00,0
	dc.w	$80c,$909,$a07,0,$80b,$90b,$a07,0
	dc.w	$80c,$909,$a06,0,$80b,$90b,$a06,0

	dc.w	$80b,$90a,$a09,0,$80b,$90b,$a05,0
	dc.w	$80a,$90a,$a0a,0,$80b,$90b,$a02,0
	dc.w	$80b,$90a,$a08,0,$80c,$907,$a07,0
	dc.w	$80c,$908,$a04,0,$80c,$907,$a06,0
	dc.w	$80b,$909,$a09,0,$80c,$906,$a06,0
	dc.w	$80a,$90a,$a09,0,$80c,$907,$a03,0
	dc.w	$80b,$90a,$a05,0,$80b,$909,$a08,0
	dc.w	$80b,$90a,$a03,0,$80a,$90a,$a08,0

	dc.w	$80b,$90a,$a00,0,$80b,$909,$a07,0
	dc.w	$80b,$908,$a08,0,$80a,$90a,$a07,0
	dc.w	$80a,$909,$a09,0,$80c,$901,$a01,0
	dc.w	$80a,$90a,$a06,0,$80b,$908,$a07,0
	dc.w	$80a,$90a,$a05,0,$80a,$909,$a08,0
	dc.w	$80a,$90a,$a02,0,$80a,$90a,$a01,0
	dc.w	$80a,$90a,$a00,0,$809,$909,$a09,0
	dc.w	$80a,$908,$a08,0,$80b,$908,$a01,0

	dc.w	$80a,$909,$a06,0,$80b,$907,$a04,0
	dc.w	$80a,$909,$a05,0,$809,$909,$a08,0
	dc.w	$80a,$909,$a03,0,$80a,$908,$a06,0
	dc.w	$80a,$909,$a00,0,$809,$909,$a07,0
	dc.w	$809,$908,$a08,0,$80a,$908,$a04,0
	dc.w	$809,$909,$a06,0,$80a,$908,$a01,0
	dc.w	$809,$909,$a05,0,$809,$908,$a07,0
	dc.w	$808,$908,$a08,0,$809,$909,$a02,0

	dc.w	$809,$908,$a06,0,$809,$909,$a00,0
	dc.w	$809,$907,$a07,0,$808,$908,$a07,0
	dc.w	$809,$907,$a06,0,$809,$908,$a02,0
	dc.w	$808,$908,$a06,0,$809,$906,$a06,0
	dc.w	$808,$907,$a07,0,$808,$908,$a04,0
	dc.w	$808,$907,$a06,0,$808,$908,$a02,0
	dc.w	$807,$907,$a07,0,$808,$906,$a06,0
	dc.w	$808,$907,$a04,0,$807,$907,$a06,0

	dc.w	$808,$906,$a05,0,$808,$906,$a04,0
	dc.w	$807,$906,$a06,0,$807,$907,$a04,0
	dc.w	$808,$905,$a04,0,$806,$906,$a06,0
	dc.w	$807,$906,$a04,0,$807,$905,$a05,0
	dc.w	$806,$906,$a05,0,$806,$906,$a04,0
	dc.w	$806,$905,$a05,0,$806,$906,$a02,0
	dc.w	$806,$905,$a04,0,$805,$905,$a05,0
	dc.w	$806,$905,$a02,0,$805,$905,$a04,0

	dc.w	$805,$904,$a04,0,$805,$905,$a02,0
	dc.w	$804,$904,$a04,0,$804,$904,$a03,0
	dc.w	$804,$904,$a02,0,$804,$903,$a03,0
	dc.w	$803,$903,$a03,0,$803,$903,$a02,0
	dc.w	$803,$902,$a02,0,$802,$902,$a02,0
	dc.w	$802,$902,$a01,0,$801,$901,$a01,0
	dc.w	$802,$901,$a00,0,$801,$901,$a00,0
	dc.w	$801,$900,$a00,0,$800,$900,$a00,0

	dc.w	$80e,$90d,$a0c,0,$80f,$903,$a00,0
	dc.w	$80f,$903,$a00,0,$80f,$903,$a00,0
	dc.w	$80f,$903,$a00,0,$80f,$903,$a00,0
	dc.w	$80f,$903,$a00,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0b,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0b,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0b,0,$80e,$90d,$a0b,0
	dc.w	$80e,$90d,$a0a,0,$80e,$90d,$a0a,0

	dc.w	$80e,$90d,$a0a,0,$80e,$90d,$a0a,0
	dc.w	$80e,$90c,$a0c,0,$80e,$90d,$a00,0
	dc.w	$80d,$90d,$a0d,0,$80d,$90d,$a0d,0
	dc.w	$80d,$90d,$a0d,0,$80d,$90d,$a0d,0
	dc.w	$80d,$90d,$a0d,0,$80d,$90d,$a0d,0
	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0
	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0
	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0

	dc.w	$80e,$90c,$a0b,0,$80e,$90c,$a0b,0
	dc.w	$80e,$90c,$a0a,0,$80e,$90c,$a0a,0
	dc.w	$80e,$90c,$a0a,0,$80e,$90c,$a0a,0
	dc.w	$80d,$90d,$a0c,0,$80d,$90d,$a0c,0
	dc.w	$80e,$90c,$a09,0,$80e,$90c,$a09,0
	dc.w	$80e,$90c,$a05,0,$80e,$90c,$a00,0
	dc.w	$80e,$90c,$a00,0,$80e,$90b,$a0b,0
	dc.w	$80e,$90b,$a0b,0,$80e,$90b,$a0b,0

	dc.w	$80e,$90b,$a0b,0,$80e,$90b,$a0a,0
	dc.w	$80e,$90b,$a0a,0,$80e,$90b,$a0a,0
	dc.w	$80d,$90d,$a0b,0,$80d,$90d,$a0b,0
	dc.w	$80d,$90d,$a0b,0,$80e,$90b,$a09,0
	dc.w	$80e,$90b,$a09,0,$80e,$90b,$a09,0
	dc.w	$80d,$90c,$a0c,0,$80d,$90d,$a0a,0
	dc.w	$80e,$90b,$a07,0,$80e,$90b,$a00,0
	dc.w	$80e,$90b,$a00,0,$80d,$90d,$a09,0

	dc.w	$80d,$90d,$a09,0,$80e,$90a,$a09,0
	dc.w	$80d,$90d,$a08,0,$80d,$90d,$a07,0
	dc.w	$80d,$90d,$a04,0,$80d,$90d,$a00,0
	dc.w	$80e,$90a,$a04,0,$80e,$909,$a09,0
	dc.w	$80e,$909,$a09,0,$80d,$90c,$a0b,0
	dc.w	$80e,$909,$a08,0,$80e,$909,$a08,0
	dc.w	$80e,$909,$a07,0,$80e,$908,$a08,0
	dc.w	$80e,$909,$a01,0,$80c,$90c,$a0c,0

	dc.w	$80d,$90c,$a0a,0,$80e,$908,$a06,0
	dc.w	$80e,$907,$a07,0,$80e,$908,$a00,0
	dc.w	$80e,$907,$a05,0,$80e,$906,$a06,0
	dc.w	$80d,$90c,$a09,0,$80e,$905,$a05,0
	dc.w	$80e,$904,$a04,0,$80d,$90c,$a08,0
	dc.w	$80d,$90b,$a0b,0,$80e,$900,$a00,0
	dc.w	$80d,$90c,$a06,0,$80d,$90c,$a05,0
	dc.w	$80d,$90c,$a02,0,$80c,$90c,$a0b,0

	dc.w	$80c,$90c,$a0b,0,$80d,$90b,$a0a,0
	dc.w	$80d,$90b,$a0a,0,$80d,$90b,$a0a,0
	dc.w	$80d,$90b,$a0a,0,$80c,$90c,$a0a,0
	dc.w	$80c,$90c,$a0a,0,$80c,$90c,$a0a,0
	dc.w	$80d,$90b,$a09,0,$80d,$90b,$a09,0
	dc.w	$80d,$90a,$a0a,0,$80d,$90a,$a0a,0
	dc.w	$80d,$90a,$a0a,0,$80c,$90c,$a09,0
	dc.w	$80c,$90c,$a09,0,$80c,$90c,$a09,0

	dc.w	$80d,$90b,$a06,0,$80c,$90b,$a0b,0
	dc.w	$80c,$90c,$a08,0,$80d,$90b,$a00,0
	dc.w	$80d,$90b,$a00,0,$80c,$90c,$a07,0
	dc.w	$80c,$90c,$a06,0,$80c,$90c,$a05,0
	dc.w	$80c,$90c,$a03,0,$80c,$90c,$a01,0
	dc.w	$80c,$90b,$a0a,0,$80d,$90a,$a05,0
	dc.w	$80d,$90a,$a04,0,$80d,$90a,$a02,0
	dc.w	$80d,$909,$a08,0,$80d,$909,$a08,0

**************************************
*       mfp/frequency table          *
**************************************
freqtab	dc.w	$0506	4.9 khz
	dc.w	$0505	7.68 khz
	dc.w	$0405	9.6 khz
	dc.w	$2901	14.99 khz
	dc.w	$1f01	19.8 khz
	dc.w	$0802	30.7 khz
 	dc.w	$0106	
	dc.w	$0106

************************************
*     keyboard message strings     *
************************************
skbddis	dc.b	$13,0		stop data
skbden	dc.b	$11,0		restart reporting

**************************************
*	define program storage       *
**************************************

	dseg
vars
xternal dc.b	0
inuse	dc.b	0
option 	dc.w	0
freqnum	dc.w	0
status	dc.w	0
mfpmem  dc.b	0,0,0,0,0,0,0,0
sample	dc.l	0
length	dc.l	0
freqncy	dc.l	0
stack	dc.l	0
dlt		dc.l 	0
screen	dc.l 	0
dtime	dc.l	0
time	dc.l	0
lastb	dc.l	0
_time	dc.l	0
anivec	dc.l	0
dlist	dc.l	0
dpt	dc.l	0
dcount	dc.l	0
dlcount	dc.l	0
speed	dc.l	0
vbcmap	dc.l	0
vlist	dc.l	0
vlpct	dc.w	0
slist	dc.l	0
slpct	dc.w	0
vdone	dc.b	0
cms	dc.b	0
;


;vars	dc.l	0,0,0,0,0,0,0,0,0,0,0,0,0,0
;	dc.l	0,0,0,0,0,0,0
;xternal	equ	0
;inuse	equ 1
;option	equ 2
;freqnum equ 4
;status  equ 6
;mfpmem  equ 8
;sample	equ 16
;length	equ	20
;freqncy	equ	24
;stack	equ	28
;dlt		equ 32
;screen	equ 36
;dtime	equ	40
;time	equ	44
;lastb	equ	48
;
	end
