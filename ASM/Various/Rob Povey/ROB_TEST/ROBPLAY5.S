; Rob's Quartet driver about 21-22K maximum variable speed
; Oct 90
; low level driver for playing Quartet songs


; OK guys heres the Quartet driver that goes out with Quartet 2
; It uses Timer A+C as in the Quartet1 driver.....
; It uses no Registers. The only limit is you must start the player
; in supervisor mode..
;
; It's pretty obvious how this one works.
; See Robtest5.s for an example.....
; I always use the binary but This is the source if you need it.
; 
; This is by no means the fastest Quartet driver I have but It is
; the only one I've got which supports all of the output drivers.
; It should be plenty fast enough for your purposes...
;
; rewrite this if you like .. For interests sake my fastest internal
; soundhip driver (Not STE) takes about 28% at 8KHz and uses NO 
; registers at all ( Unlike TCB's ).
; 
; If you have any problems phone me during the week after 8 p.m.
; on the following number.
;				0904 - 784838 ask for Rob.
;
;
; This driver will stop you doing very little even with gem..
; Unfortunately the driver corrupts disk accesses!!
; If you must use gem at all.
; Make sure you increment the 200Hz timer (I always do it on the VBL)
; it just makes timeouts a bit slower.
;
; I look forward to seeing what you produce

;						Rob.


	opt p+		;MUST be position-independent code

;once assembled, go into MonST(2) with ALT-D, and save binary file
;(press S) with '<filename>.BIN', with (start address, end) = 'top,bottom'


;global parameters you can change (as you wish) :-

STACKMAX equ	200	;how many 16-bit words deep each channel stack is


	SECTION	TEXT

top	;ie beginning of binary data


instin	bra.w	Install		;$00
deinstin bra.w	DeInstall	;$04
startin	bra.w	Start		;$08
stopin	bra.w	Stop		;$0C
restartin bra.w	Restart		;$10
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
	dc.l	0
songptr	dc.l	0		;$2c.l	[points to start of song data]
vsetptr	dc.l	0		;$30.l	[point to start of voice memory]
	dc.l	0
irqmask	dc.w	0		;$38.w	[goes to mfp]
soundtype dc.w	0		;$3a.w
fadeincr dc.w	0		;$3c.w
fadeval	dc.w	0		;$3e.w
timdata	dc.b	0		;$40.b	[was $2c]
active	dc.b	0		;$41.b	[0=>dormant, 1=> active]

lowlevelroutine dc.l 0
lowlevelpointer	dc.l 0
envelopepointer	dc.l 0
	;case of soundtype=
		;[0] => default internal sound
		;[1] => Replay 8-bit
		;[2] => Replay 12-bit
		;[3] => Replay stereo 8-bit 
		;[4] => STE sample hardware
	;will install driver when soundenable is called (ie Start)

	even


Install	;must be in supervisor mode!
	movem.l	d0-d7/a0-a6,-(sp)
	bsr	SetUpSTE
	bsr	Stop				;kill interrupts

	lea	btmod(pc),a0
	lea	btmodmod(pc),a1
	move.l	a0,(a1)
	lea	btmod4(pc),a0
	lea	btmodmod4(pc),a1
	move.l	a0,(a1)
	lea	btmod5(pc),a0
	lea	btmodmod5(pc),a1
	move.l	a0,(a1)
	lea	btmod6(pc),a0
	lea	btmodmod6(pc),a1
	move.l	a0,(a1)
	lea	btmod7(pc),a0
	lea	btmodmod7(pc),a1
	move.l	a0,(a1)
	lea	btmod8(pc),a0
	lea	btmodmod8(pc),a1
	move.l	a0,(a1)
	lea	btmod9(pc),a0
	lea	btmodmod9(pc),a1
	move.l	a0,(a1)
	lea	SteLoc(pc),a0
	lea	STEmod1(pc),a1
	move.l	a0,(a1)
	lea	SteLoc+1(pc),a0
	lea	STEmod2(pc),a1
	move.l	a0,(a1)


	move.w	SR,-(sp)
	move.w	#$2700,SR			;disable int's while
	lea	oldints(pc),a0			;changing vectors
	move.l	$134.w,(a0)
	move.l	$114.w,4(a0)

	bsr	typesub
	move.w	(sp)+,SR

	bsr	wipebuffer
	bsr	initsoundchip

	movem.l	(sp)+,d0-d7/a0-a6
	rts

typesub
	move.w	soundtype(pc),d1
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	typearray(pc),a0
	lea	shiftclip(pc),a1
	move.w	6(a0,d1.w),(a1)		; adjust if necessary for STE
	move.w	4(a0,d1.w),d2
	pea	0(a0,d2.w)
	move.l	0(a0,d1.w),d1		;get routine & buffer offsets
	pea	0(a0,d1.w)		;push 256-byte buffer pointer addr
	swap	d1
	pea	0(a0,d1.w)		;push routine address
	lea	lowlevelroutine(pc),a0
	move.l	(sp)+,(a0)
	move.l	(a0),$134.w		;interrupt auto-vector
	lea	lowlevelpointer(pc),a0
	move.l	(sp)+,(a0)
	lea	envelopepointer(pc),a0
	move.l	(sp)+,(a0)
	move.l	(a0),$114.w		;timer C for slower int
	rts

soundtype MACRO
	dc.w	\1-typearray,\2-typearray,\3-typearray,\4
	ENDM

typearray
	soundtype sample_int,btmod,envelope_int,0
	soundtype replay8int,btmod2,envelope_int,0
	soundtype replay12int,btmod3,envelope_int,0
	soundtype playbackint,btmod4,envelope_int2,0
	soundtype STEint,btmod8,envelope_int2,516
maxtype	equ	*-typearray



oldints	dc.l	0,0,0		;holds original (system, perhaps) vectors

DeInstall
	movem.l	d0/a0,-(sp)
	bsr.w	Stop				;stop interrupts

	lea	songptr(pc),a0
	clr.l	(a0)
	clr.l	vsetptr-songptr(a0)		;invalidate data area

	move.w	SR,d0
	move.w	#$2700,SR			;disable int's while
	lea	oldints(pc),a0			;changing vectors
	move.l	(a0),$134.w			;o'riginal contents
	move.l	4(a0),$114.w
	lea	active(pc),a0
	clr.b	(a0)				;not active any more!
	move.w	d0,SR

	bsr	killsoundchip

	movem.l	(sp)+,d0/a0
	rts

* setup the STE soundchip *
SetUpSTE
	lea	$ffff8205.w,a5
	move.b	(a5),d0
	move.b	$ff,(a5)
	cmp.b	(a5),d0
	beq	.notSTE
	move.b	d0,(a5)

	lea	$ffff8900.w,a5		* set up STE
	lea	SteLoc(pc),a4
	move.l	a4,d6
	move.l	d6,d7
	addq.l	#2,d7
	movep.w	d7,$11(a5)		* set end
	swap	d7
	move.b	d7,$f(a5)
	movep.w	d6,5(a5)		* and start
	swap	d6
	move.b	d6,3(a5)
	move.b	#$3,$21(a5)
	move.b	#$3,1(a5)
.notSTE
	rts



Start	move.l	a0,-(sp)
	lea	songptr(pc),a0
	tst.l	(a0)
	beq.s	notvalid
	tst.l	4(a0)
	beq.s	notvalid

	movem.l	d0-d7/a1-a6,-(sp)
	bsr	set_up_voiceset		;set up voices & timer control
	bsr	sounddisable
	bsr	makechannels		;make stacks etc
;	bsr	wipebuffer
	movem.l	(sp)+,d0-d7/a1-a6

validx
	bsr	wipebuffer
	bsr	soundenable		;start up interrupts!
notvalid
	move.l	(sp)+,a0
	rts

Stop	bra	sounddisable		;turn off interrupts!

Restart	move.l	a0,-(sp)
	btst	#7,active(pc)		;is quartet active?
	bne.s	notvalid		;can't restart if it is!
	lea	songptr(pc),a0
	tst.l	(a0)
	beq.s	notvalid
	tst.l	4(a0)
	beq.s	notvalid
	lea	freq0(pc),a0
	move.l	freqsave-freq0(a0),(a0)+
	move.l	freqsave-freq0(a0),(a0)+
	move.l	freqsave-freq0(a0),(a0)+
	move.l	freqsave-freq0(a0),(a0)+
	bra.s	validx

wipebuffer
	move.l	lowlevelpointer(pc),a0
	move.b	(a0),d0
	lea	sample_buffer(pc),a0
	move.b	d0,lastbtmod-sample_buffer(a0)
	move.w	#256/4-1,d0		;buffer is 256 bytes long
	move.l	#$80808080,d1		;set each byte to $80 (silent)
clrbuflp
	move.l	d1,(a0)+
	dbra	d0,clrbuflp
	rts



	;get voice data from '.SET' file structure
	;also, get interrupt timer period from '.4v' file structure
set_up_voiceset
	move.l	vsetptr(pc),a5		;first - set up voice set
	lea	142(a5),a6		;skip past 142 byte header
	lea	satab(pc),a4		;table that dcvchg uses
	moveq	#20-1,d0		;contains 20 different voices

.loop	move.l	(a6)+,d1
	tst.l	d1
	bne.s	.seton			;if voice offset=0, use voice #1
	move.l	satab(pc),d1
	bra.s	.seton2
.seton	add.l	a5,d1			;ie relative to (vsetptr)
	addq.l	#8,d1			;skip 8-byte header
.seton2	move.l	d1,(a4)+		;stick it out to satab++
	dbra	d0,.loop

	move.l	songptr(pc),a0		;get playback frequency from songdata
	move.w	(a0),d0			;set the playback frequency
;	bra	setplayfreq		;falls through

setplayfreq
	lea	timdata(pc),a0
	move.b	ftable(pc,d0.w),(a0)		;set up new speed
	move.b	(a0),$fffffa1f.w 		;data (normally 50) (usec?)
	move.b	#1,$fffffa19.w			;divide by 4
	rts

	
ftable	dc.b	$b0,$b0,$b0,$b0
	dc.b	$98,$7a,$66,$58,$4c,$44,$3d,$38,$33,$2f,$2c,$29,$26,$24,$22,$20,$1e
	even

;----------------------------------------
;generate all relevant data for each channel in turn

getchan MACRO
	lea	ioffset\1(pc),a4
	lea	STACK\1(pc),a1
	ENDM


makechannels
	move.l	songptr(pc),a0		;second - set up song pointers
	lea	16(a0),a0		;skip past 16-byte header
	;a0 now points to start of this channel
	getchan	0
	bsr.s	makechannel
	getchan	1
	bsr.s	makechannel
	getchan	2
	bsr.s	makechannel
	getchan	3


makechannel
	;a0 is channel, a1 is stack
	;first, set up variables for this channel

	clr.l	freq(a4)
	move.l	#silentlen,irppt(a4)
	move.l	irppt(a4),rppt(a4)
	lea	silentend(pc),a2
	move.l	a2,inst(a4)
	move.l	#silentval,(a4)
	lea	silentend2(pc),a2
	move.l	a2,base(a4)
	move.l	#silentval2,offset(a4)

	move.w	#-1,-(a1)		;indicates top of stack!
	move.l	a1,stackptr(a4)
	move.l	a1,defstack(a4)		;held for when song reaches end

	move.l	a0,a2			;holds start of this voice
	move.w	#'R',cnote(a4)		;check for an empty voice
	move.w	#1,length(a4)		;will start at first decode
	bra.s	.lpin

.loop	cmp.w	#'P',(a0)		play command?
	lea	12(a0),a0
	beq.s	.isok
.lpin	cmp.w	#'F',(a0)
	bne.s	.loop	 		;loop until finish
					;no play commands to be found!
	lea	rdata(pc),a2		;so use null data - rest(10000),Fin
.isok	cmp.w	#'F',(a0)		;valid... therefore play as normal
	lea	12(a0),a0
	bne.s	.isok			;skip commands until ='F'
	
	move.l	a2,vstart(a4)
	move.l	a2,cinstptr(a4)
	rts

;---------------------------------
;now - mfp start/finish code

	IFND	IERA
IERA	equ	$07
IERB	equ	$09
IPRA	equ	$0B
IPRB	equ	$0D
ISRA	equ	$0F
ISRB	equ	$11
IMRA	equ	$13
IMRB	equ	$15
VECTR	equ	$17
TACR	equ	$19
TADR	equ	$1F
	ENDC


soundenable
	movem.l	d0-d1/a0-a1,-(sp)
	move.w	SR,d0			;holds status register

	move.w	irqmask(pc),d1		;default irqmask
	or.w	#$2020,d1		;timer A on, timer C on
	lea	$fffffa00.w,a0
	move.w	#$2700,SR
	bclr	#3,$fffffa17.w		set AEI mode
	movep.w	d1,IMRA(a0)
	movep.w	d1,IERA(a0)
	lea	active(pc),a0
	move.b	#255,(a0)
	bsr	typesub			;install selected sound driver

	move.w	d0,SR
	movem.l	(sp)+,d0-d1/a0-a1
	rts



sounddisable
	movem.l	d0-d1/a0,-(sp)
	move.w	SR,d0

	move.w	#$2700,SR
	bset	#3,$fffffa17.w		set SEI mode
	lea	$fffffa00.w,a0
	move.w	irqmask(pc),d1
	movep.w	d1,IMRA(a0)		also writes to IMRB
	movep.w	d1,IERA(a0)		also writes to IERB
	moveq.l	#0,d1
	movep.l	d1,IPRA(a0)		also clears IPRB, ISRA, & ISRB
	lea	active(pc),a0
	clr.b	(a0)
	lea	freq0(pc),a0
	move.l	(a0),freqsave-freq0(a0)
	clr.l	(a0)+
	move.l	(a0),freqsave-freq0(a0)
	clr.l	(a0)+
	move.l	(a0),freqsave-freq0(a0)
	clr.l	(a0)+
	move.l	(a0),freqsave-freq0(a0)
	clr.l	(a0)+

	move.w	d0,SR
	movem.l	(sp)+,d0-d1/a0
	rts

;------------------------------------
;now - sound chip start/finish code

initsoundchip
	movem.l	d0/a0,-(sp)
	lea	$ffff8800.w,a0
	move.b	#7,(a0)			turn on sound
	move.b	#$c0,d0
	and.b	(a0),d0
	or.b	#$38,d0
	move.b	d0,2(a0)

	move.w	#$0500,d0		set registers 5/4/3/2/1/0 all = 0
initslp	movep.w	d0,(a0)
	sub.w	#$0100,d0
	bpl.s	initslp
	movem.l	(sp)+,d0/a0
	rts

killsoundchip
	;reset sound chip
	move.w	d0,-(sp)
	move.b	#7,$ffff8800.w		turn off sound
	move.b	#7,d0
	or.b	$ffff8800.w,d0
	move.b	d0,$ffff8802.w
	move.w	(sp)+,d0
	rts

;-------------------------------
;now - very low level code

	;least significant sound digit
digi3	MACRO
	dc.w	$a00+($\1&15),$a00+($\2&15),$a00+($\3&15),$a00+($\4&15)
	dc.w	$a00+($\5&15),$a00+($\6&15),$a00+($\7&15),$a00+($\8&15)
	ENDM

	;most significant sound digits

digi2	MACRO
	dc.w	$0900,(($\1>>4)&15)*$100+(($\1>>8)&15)
	dc.w	$0900,(($\2>>4)&15)*$100+(($\2>>8)&15)
	dc.w	$0900,(($\3>>4)&15)*$100+(($\3>>8)&15)
	dc.w	$0900,(($\4>>4)&15)*$100+(($\4>>8)&15)
	dc.w	$0900,(($\5>>4)&15)*$100+(($\5>>8)&15)
	dc.w	$0900,(($\6>>4)&15)*$100+(($\6>>8)&15)
	dc.w	$0900,(($\7>>4)&15)*$100+(($\7>>8)&15)
	dc.w	$0900,(($\8>>4)&15)*$100+(($\8>>8)&15)
	ENDM


pad	MACRO
	dcb.b	(\1)-*,0
	ENDM

SteLoc	dc.l	0

* This is only confusing cause it has to be relocated
* by Init before the player can start.

*Routine for output through STE hardware

STEint
	addq.b	#1,$00000000.l
btmodmod8 equ	*-4		;where to relocate btmod
	addq.b	#1,$00000000.l
btmodmod9 equ	*-4		;where to relocate btmod
btmod8	equ	*+3		;effectively pointer to data
bas_997	move.b	sample_buffer1+00(pc),$00000000.l
STEmod1 equ	*-4
btmod9	equ	*+3		;effectively pointer to data
	move.b	sample_buffer2+00(pc),$00000000.l
STEmod2 equ	*-4
	rte

	ds.b	256-30		*	ds.b	256-(playbackint-STEint)

*Routine for output through 8 bit stereo cartridge

playbackint
	addq.b	#1,$00000000.l
btmodmod4 equ	*-4		;where to relocate btmod
	addq.b	#1,$00000000.l
btmodmod6 equ	*-4		;where to relocate btmod
btmod4	equ	*+3		;effectively pointer to data
bas_998	move.b	sample_buffer1+00(pc),$00000000.l
btmodmod5 equ	*-4
btmod6	equ	*+3		;effectively pointer to data
bas_999	move.b	sample_buffer2+00(pc),$00000000.l
btmodmod7 equ	*-4
	tst.b	$fa0000.l
btmod5	equ	*-1
	tst.b	$fa0200.l
btmod7	equ	*-1
	rte

	pad	bas_998+$100+2	; make sure sample buffer is on a round number offset
*				; from the reference to it
sample_buffer1
	dcb.b	256,$80		;basically, initialise to silence
	pad	bas_999+$200+2	; make sure sample buffer is on a round number offset
sample_buffer2
	dcb.b	256,$80

*Standard Replay cartridge output routine

replay8int
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	clr.w	d0
	lea	sample_buffer(pc),a0
	move.b	$0000(a0),d0
btmod2	equ	*-1
	addq.b	#1,btmod2-sample_buffer(a0)
	add.w	d0,d0
	lea	$fa0000.l,a0	;is this the correct address??
	tst.b	(a0,d0.w)	;write to ROM! (by reading!)
	move.l	(sp)+,a0
	move.w	(sp)+,d0
	rte

*Replay Professional output routine (12 Bit) 

replay12int
	move.w	d0,-(sp)
	move.l	a0,-(sp)
	clr.w	d0
	lea	sample_buffer(pc),a0
	move.b	$0000(a0),d0
btmod3	equ	*-1
	addq.b	#1,btmod3-sample_buffer(a0)
	add.w	d0,d0
	add.w	d0,d0
	lea	$fa0000.l,a0
	tst.b	(a0,d0.w)	;write to ROM! (by reading!)
	move.l	(sp)+,a0
	move.w	(sp)+,d0
	rte


*Standard output routine through monitor

sample_int
	move.l	d0,-(sp)
	moveq	#8,d0
	move.b	d0,$ffff8800.w
	addq.b	#1,$00000000.l
btmodmod equ	*-4		;where to relocate btmod
btmod	equ	*+3		;effectively pointer to data
bas_1	move.b	sample_buffer(pc),d0
	add.w	d0,d0		;d0=512+byte*2
	add.w	d0,d0		;d0=1024+byte*4
bas_3	move.l	conv2(pc,d0.w),d0
	move.b	d0,$ffff8802.w
	move.l	d0,$ffff8800.w
	move.l	(sp)+,d0
	rte

conv2	
	digi2	000,000,200,300,400,500,510,600
	digi2	600,620,700,720,730,800,800,820
	digi2	830,900,910,920,930,940,950,951
	digi2	A00,A20,A30,A40,A50,A50,A52,A60
	digi2	A62,A70,A71,B00,B10,B30,B40,B40
	digi2	B50,B52,B60,B61,B70,B71,B72,B73
	digi2	B80,B81,B83,B84,B90,C00,C20,C30
	digi2	C40,C50,C51,C52,C60,C62,C70,C72
	digi2	C73,C80,C80,C82,C83,C90,C90,C92
	digi2	c93,c94,c95,c95,ca0,d00,d20,d30
	digi2	d40,d50,d50,d52,d60,d62,d70,d71
	digi2	d73,d74,d80,d82,d83,d90,d90,d92
	digi2	d93,d94,d95,d95,da0,da1,da3,da4
	digi2	da4,da5,da5,da6,da6,da7,da7,db0
	digi2	db1,db2,db3,db4,db5,db5,db6,e00
	digi2	e10,e30,e40,e41,e50,e52,e60,e61
	digi2	e70,e71,e73,e74,e80,e81,e83,e84
	digi2	e90,e92,e93,e94,e95,e95,ea0,ea1
	digi2	ea3,ea4,ea4,ea5,ea5,ea6,ea6,ea7
	digi2	ea7,ea7,eb0,eb2,eb3,eb4,eb5,eb5
	digi2	eb5,eb6,eb6,eb7,eb7,eb7,eb8,eb8
	digi2	eb8,eb8,eb9,ec0,ec1,ec3,ec4,ec4
	digi2	ec5,f00,f10,f30,f40,f41,f50,f52
	digi2	f60,f61,f70,f71,f73,f74,f80,f82
	digi2	f83,f84,f90,f92,f93,f94,f95,f95
	digi2	fa0,fa1,fa3,fa4,fa4,fa5,fa5,fa6
	digi2	fa6,fa7,fa7,fb0,fb0,fb2,fb3,fb4
	digi2	fb5,fb5,fb6,fb6,fb6,fb7,fb7,fb7
	digi2	fb8,fb8,fb8,fb8,fb9,fc0,fc1,fc3
	digi2	fc4,fc4,fc5,fc5,fc6,fc6,fc7,fc7
	digi2	fc7,fc7,fc8,fc8,fc8,fc8,fc9,fc9
	digi2	fc9,fc9,fc9,fc9,fca,fd0,fd1,fd3


	pad	bas_1+$500+2	; make sure sample buffer is on a round number offset
*				; from the reference to it
sample_buffer
	dcb.b	256,$80		;basically, initialise to silence
	dcb.b	256,$80

;----------------------------------------------------------------------
;now - decode quartet data stuff

cliptabmem:
	REPT	384
	dc.b	0
	ENDR

rcnt	set	1
	REPT	254
	dc.b	rcnt
rcnt	set	rcnt+1
	ENDR

	REPT	384
	dc.b	255
	ENDR


cliptabmem2
	REPT	128
	dc.b	0
	ENDR

rcnt	set	2
	REPT	124
	dc.b	rcnt
	dc.b	rcnt
rcnt	set	rcnt+2
	ENDR

	REPT	140
	dc.b	254
	ENDR

cliptabmem3:
	REPT	128
	dc.b	-128
	ENDR

rcnt	set	-127
	REPT	254
	dc.b	rcnt
rcnt	set	rcnt+1
	ENDR

	REPT	140
	dc.b	127
	ENDR

shiftclip:	dc.w	0

synslide MACRO
	lea	ioffset\1(pc),a5
	cmp.w	#'S',cnote(a5)
	bne.s	.no\@

	move.l	speed(a5),d6
	add.l	freq(a5),d6		increase the freq by the speed
	move.l	d6,freq(a5)

	tst.l	speed(a5)
	bmi.s	.ismi\@

	cmp.l	dfreq(a5),d6
	blt.s	.no\@			hasn't reached dest
	bra.s	.on\@			;is done!

.ismi\@	cmp.l	dfreq(a5),d6
	bgt.s	.no\@			hasn't reached the destination yet
.on\@	move.w	#'P',cnote(a5)		it becomes a play command if it has
	move.l	dfreq(a5),freq(a5)
.no\@
	ENDM


decode	MACRO
	lea	ioffset\1(pc),a5
	subq.w	#1,length(a5)		decrease note length counter
	bne.s	.on\@ 			decode voice1 if not at end of note
	bsr.s	decodesub
.on\@
	ENDM

loopmac	MACRO
	move.l	rppt\1(pc),d4
	tst.w	d4
	beq.s	.rep\1			;rept iff non-zero
	move.l	#silentlen,d4
	lea	silentend(pc),a\1	;new start address
	move.l	a\1,base\1-ioffset0(a6)	;add silence to the end
	move.l	d4,rppt\1-ioffset0(a6)	;and repeat it
	clr.l	freq\1-ioffset0(a6)	;and stop it?
.rep\1	swap	d\1
	subq.l	#1,d\1			;compensate for carry cascade (very minor!)
	sub.l	d4,d\1
	swap	d\1
	ENDM


	;now, slower (200Hz) interrupt
envelope_int
	move.w	#$2500,SR		;allow timer A to interrupt (??)
	movem.l	d0-d7/a0-a6,-(sp)	;be careful... ruining latency???

*	lea	fadeincr(pc),a0
*	tst.w	(a0)
*	bne.s	isfading		;branch if fade level changing!

	clr.b	d5			;holds bytes for second pass
	clr.w	d6
	moveq.l	#0,d7
	move.l	lowlevelpointer(pc),a0
	move.b	(a0),d6			;d6 holds current value
	lea	lastbtmod(pc),a0
	move.b	(a0),d7			;d7 holds last value
	move.b	d6,(a0)+		;a0 now = nextpass
	lea	sample_buffer(pc),a5
	add.l	d7,a5			;point a5 to within buffer

	sub.b	d7,d6
	beq.w	envx			;cut out if none to go!
	bcc.s	.noover			;if d6.b > d7.b then is ok!
	add.b	d7,d6			;re-compensate
	move.b	d6,d5			;for next time
	move.b	d7,d6			;for this time
	neg.b	d6			;do top end
.noover
;	lea	nextpass(pc),a0		;because nextpass==lastbtmod+1
	move.b	d5,(a0)			;second pass's length

	;now perform sample stepping in the midground
	movem.l	freq0(pc),d0-d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	lea	.fmod0+2(pc),a0
	move.l	d0,(a0)
	move.l	d1,.fmod1-.fmod0(a0)
	move.l	d2,.fmod2-.fmod0(a0)
	move.l	d3,.fmod3-.fmod0(a0)
	movem.l	offset0(pc),d0-d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	movem.l	base0(pc),a0-a3
	clr.w	d5			;high byte of low word is always zero
	clr.w	d7			;used as dummy (0) in addx.w's
	lea	cliptabmem(pc),a4	;holds current cliptab
	lea	ioffset0(pc),a6
	subq.w	#1,d6			;because is a dbra (n-1) loop

.midglp	clr.w	d4
	move.b	0(a0,d0.w),d4
	move.b	0(a1,d1.w),d5
	add.w	d5,d4
	move.b	0(a2,d2.w),d5
	add.w	d5,d4
	move.b	0(a3,d3.w),d5
	add.w	d5,d4
	move.b	0(a4,d4.w),(a5)+

.fmod0	add.l	#0,d0
	addx.w	d7,d0
.fmod1	add.l	#0,d1
	addx.w	d7,d1
.fmod2	add.l	#0,d2
	addx.w	d7,d2
.fmod3	add.l	#0,d3
	addx.w	d7,d3
	move.w	d0,d4
	and.w	d1,d4
	and.w	d2,d4
	and.w	d3,d4
.midgon	dbpl	d6,.midglp
	bmi.w	.lpdone
.overflow
	tst.w	d0
	bmi.s	.try1
	loopmac	0
.try1	tst.w	d1
	bmi.s	.try2
	loopmac	1
.try2	tst.w	d2
	bmi.s	.try3
	loopmac	2
.try3	tst.w	d3
	bmi.s	.try4
	loopmac	3
.try4
	dbra	d6,.midglp
	;falls through to .lpdone ...

.lpdone
	lea	nextpass(pc),a5
	clr.w	d6
	move.b	(a5),d6
	clr.b	(a5)
	lea	sample_buffer(pc),a5
	dbra	d6,.midglp

	swap	d0
	swap	d1
	swap	d2
	swap	d3
	lea	offset0(pc),a4
	movem.l	d0-d3,(a4)

.nonedone
	bra	nonedone


lastbtmod dc.b	0
nextpass dc.b	0
	even




	;now, slower (200Hz) interrupt
envelope_int2
	move.w	#$2500,SR		;allow timer A to interrupt (??)
	movem.l	d0-d7/a0-a6,-(sp)	;be careful... ruining latency???

*	lea	fadeincr(pc),a0
*	tst.w	(a0)
*	bne.s	isfading		;branch if fade level changing!

	clr.b	d5			;holds bytes for second pass
	clr.w	d6
	moveq	#0,d7
	move.l	lowlevelpointer(pc),a0
	move.b	(a0),d6			;d6 holds current value
	lea	lastbtmod(pc),a0
	move.b	(a0),d7			;d7 holds last value
	move.b	d6,(a0)+		;a0 now = nextpass
	lea	sample_buffer1(pc),a5
	add.l	d7,a5			;point a5 to within buffer

	sub.b	d7,d6
	beq.w	envx			;cut out if none to go!
	bcc.s	.noover			;if d6.b > d7.b then is ok!
	add.b	d7,d6			;re-compensate
	move.b	d6,d5			;for next time
	move.b	d7,d6			;for this time
	neg.b	d6			;do top end
.noover
;	lea	nextpass(pc),a0		;because nextpass==lastbtmod+1
	move.b	d5,(a0)			;second pass's length

	;now perform sample stepping in the midground
	movem.l	freq0(pc),d0-d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	lea	.fmod0+2(pc),a0
	move.l	d0,(a0)
	move.l	d1,.fmod1-.fmod0(a0)
	move.l	d2,.fmod2-.fmod0(a0)
	move.l	d3,.fmod3-.fmod0(a0)
	movem.l	offset0(pc),d0-d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	movem.l	base0(pc),a0-a3
	clr.w	d5			;high byte of low word is always zero
	clr.w	d7			;used as dummy (0) in addx.w's
	lea	cliptabmem2(pc),a4	;holds current cliptab
	add.w	shiftclip(pc),a4	; for STE int
	lea	ioffset0(pc),a6
	subq.w	#1,d6			;because is a dbra (n-1) loop

.midglp	clr.w	d4
	move.b	0(a0,d0.w),d4
	move.b	0(a1,d1.w),d5
	add.w	d5,d4
	move.b	0(a4,d4.w),sample_buffer2-sample_buffer1(a5)	; right channel

	clr.w	d4
	move.b	0(a2,d2.w),d4
	move.b	0(a3,d3.w),d5
	add.w	d5,d4
	move.b	0(a4,d4.w),(a5)+

.fmod0	add.l	#0,d0
	addx.w	d7,d0
.fmod1	add.l	#0,d1
	addx.w	d7,d1
.fmod2	add.l	#0,d2
	addx.w	d7,d2
.fmod3	add.l	#0,d3
	addx.w	d7,d3
	move.w	d0,d4
	and.w	d1,d4
	and.w	d2,d4
	and.w	d3,d4
.midgon	dbpl	d6,.midglp
	bmi.w	.lpdone
.overflow
	tst.w	d0
	bmi.s	.try1
	loopmac	0
.try1	tst.w	d1
	bmi.s	.try2
	loopmac	1
.try2	tst.w	d2
	bmi.s	.try3
	loopmac	2
.try3	tst.w	d3
	bmi.s	.try4
	loopmac	3
.try4
	dbra	d6,.midglp
	;falls through to .lpdone ...

.lpdone
	lea	nextpass(pc),a5
	clr.w	d6
	move.b	(a5),d6
	clr.b	(a5)
	lea	sample_buffer1(pc),a5
	dbra	d6,.midglp

	swap	d0
	swap	d1
	swap	d2
	swap	d3
	lea	offset0(pc),a4
	movem.l	d0-d3,(a4)

nonedone
	synslide 0
	synslide 1
	synslide 2
	synslide 3
	decode	0
	decode	1
	decode	2
	decode	3
envx	movem.l (sp)+,d0-d7/a0-a6
	rte

;now - slide each channel, and then decode next instruction(s)

decodesub
declp	move.l	cinstptr(a5),a6		get pointer to next instruction
	add.l	#12,cinstptr(a5)	then increment for next time
	move.w	(a6),d6
	move.w	d6,cnote(a5)
	move.b	decodetab-'A'(pc,d6.w),d6	;ignore unknown chars
	jmp	brtab(pc,d6.w)

brtab	
Berr	bra.s	declp
Bplay	bra.w	dcplay
Brest	bra.s	dcrest
Bfin	bra.s	dcfin
Bvchg	bra.w	dcvchg
Blpst	bra.w	dclpst
Blpend	bra.w	dclend
Bslid	bra.s	dcslid

dtab	MACRO
	dc.b	\1-brtab,\2-brtab,\3-brtab,\4-brtab
	ENDM

decodetab
	dtab	Berr,Berr,Berr,Berr	;ABCD
	dtab	Berr,Bfin,Berr,Berr	;EFGH
	dtab	Berr,Berr,Berr,Blpend	;IJKL
	dtab	Berr,Berr,Berr,Bplay	;MNOP
	dtab	Berr,Brest,Bslid,Berr	;QRST
	dtab	Berr,Bvchg,Berr,Berr	;UVWX
	dtab	Berr,Berr,Berr,Berr	;YZ--
	dcb.b	'l'-('Z'+1+2),Berr-brtab
	dtab	Blpst,Berr,Berr,Berr	;lmno

dcfin	move.l	vstart(a5),cinstptr(a5)
	move.l	defstack(a5),stackptr(a5)
	bra.s	declp			decode it again

dcslid
	move.w	2(a6),length(a5)
	move.l	4(a6),dfreq(a5)		slide
	move.l	8(a6),speed(a5)		just copy it over previous Play
dcx	rts

dcrest
	move.w	2(a6),length(a5)	copy in the length
	clr.l	freq(a5)
	move.l	#silentval,d6
	lea	silentend(pc),a6
	move.l	a6,d7
	bra.s	set_play_params

dcplay	move.w	2(a6),length(a5)	copy in length
	move.l	ioffset(a5),d6		set offset to initial value
	move.l	inst(a5),d7
	move.l	4(a6),freq(a5)		and the frequency
	move.l	irppt(a5),rppt(a5)	reset repeat point
;	bra.s	set_play_params		;falls through

	;set d6 & d7 to be length(chan) & end(chan) respectively
set_play_params
	move.l	d6,offset(a5)
	move.l	d7,base(a5)
	rts

dcvchg	move.l	8(a6),d7		sound number *4
	move.l	satab(pc,d7.l),a6	address of wave
	move.l	-4(a6),ioffset(a5)
	neg.l	ioffset(a5)
	move.l	-8(a6),irppt(a5)	set initial repeat point
	moveq.l	#0,d7
	move.w	-4(a6),d7		get end of sample
	add.l	d7,a6
	move.l	a6,inst(a5)		and save in current voice
	bra	declp			This instruction takes 0 cycles


dclpst	move.l	stackptr(a5),a6
	move.l	cinstptr(a5),-(a6)	pushes the next instr address and 0
	clr.w	-(a6)
	move.l	a6,stackptr(a5)
	bra	declp			Takes 0 cycles	

	
dclend	move.w	8(a6),d7		copy the initial count into d7
	move.l	stackptr(a5),a6
	move.w	(a6),d6			read in the count
	tst.w	d6
	bmi.s	isstacktop		rather than analyse at start!
	bne.s	notflp			this isn't the first encounter
rezoom	move.w	d7,d6
	addq.w	#1,d6			and add 1 ( at least 1 rept )
notflp	subq.w	#1,d6			decrease count
	beq.s	endls			have finished loop
	move.l	2(a6),cinstptr(a5)	pop loop address
	move.w	d6,(a6)			stick count back on stack
	bra	declp			takes 0 cycles

isstacktop
	move.l	vstart(a5),-(a6)	;push start address
	clr.w	-(a6)
	move.l	a6,stackptr(a5)
	bra.s	rezoom

endls	addq.l	#2+4,a6			step over address on stack
	move.l	a6,stackptr(a5)
	bra	declp			and get next instruction

satab	ds.l	20			;holds each sound's start-address 
	;this is here so that 'dcvchg' can use 'satab(pc,dn.l)' mode 



	dc.l	$01000000,$01000000	;format of individual sample
silent	dcb.b	256,$80			;played at end of play and by rests

rdata	dc.w	'R'			;null data for non-playing channels
	dc.w	10000
	dc.l	0,0			;pad up to field size (12)
	dc.w	'F'
	ds.w	10			;pad up to field size (12)


silentend	equ	silent+256
silentlen	equ	$01000000
silentval	equ	$ff000000
silentend2	equ	silentend
silentval2	equ	silentval

wavedata
ioffset0	dc.l	0		;initial offset for current sample
ioffset1	dc.l	0
ioffset2	dc.l	0
ioffset3	dc.l	0

freq0		dc.l	0		;playback step 'frequency'
freq1		dc.l	0
freq2		dc.l	0
freq3		dc.l	0
offsets		;must follow immediately after freq0..freq3
offset0		dc.l	0
offset1		dc.l	0
offset2		dc.l	0
offset3		dc.l	0
inst0		dc.l	0,0,0,0		;silentend
rppt0		dc.l	0
rppt1		dc.l	0
rppt2		dc.l	0
rppt3		dc.l	0
base0		dc.l	0
base1		dc.l	0
base2		dc.l	0
base3		dc.l	0
cnote0		dc.l	'R','R','R','R'	;current note
speed0		dc.l	0,0,0,0		;slide speed
dfreq0		dc.l	0,0,0,0		;slide destination freq
length0		dc.l	1,1,1,1		;note duration
cinstptr0	dc.l	0,0,0,0		;current instruction pointer
irppt0		dc.l	0,0,0,0		;rept point for current sample
vstart0		dc.l	0,0,0,0		;start of voice
stackptr0	dc.l	0,0,0,0		;STACKn -- voice stack pointers
defstack0	dc.l	0,0,0,0
freqsave	dc.l	0,0,0,0		;holds freq0..3 while stopped

	;now offset equates
ioffset	equ	0
freq	equ	freq0-ioffset0
inst	equ	inst0-ioffset0
rppt	equ	rppt0-ioffset0
cnote	equ	cnote0-ioffset0
speed	equ	speed0-ioffset0
dfreq	equ	dfreq0-ioffset0
length	equ	length0-ioffset0
cinstptr equ	cinstptr0-ioffset0
irppt	equ	irppt0-ioffset0
vstart	equ	vstart0-ioffset0
stackptr equ	stackptr0-ioffset0
defstack equ	defstack0-ioffset0
offset	equ	offset0-ioffset0
base	equ	base0-ioffset0


	ds.w	STACKMAX
STACK0	ds.w	STACKMAX
STACK1	ds.w	STACKMAX
STACK2	ds.w	STACKMAX
STACK3	ds.l	1


bottom	;end of binary saved data

