; Rob's driver Fixed playback speed Internal sound only
; Original Driver concept Rob... Speedup suggestions Tim Moss.
; Execution Rob........
; This driver now take appoximately 40% CPU time and NO registers
; Please Note though it now has Volume
;
; Dec 90

; If you don't like timer A then change it to another timer!!!!

; Alright -- This players a bit fanickity.... Doesn't use timer C
; but its very fast... You must NOT address the Soundchip outside
; of this driver!!! changing schip registers may have disasterous
; results.... So the GEM VBL is right out.. currently its set to
; 8K and 50Hz fairly obvious how to change it. Just change NUMPREP
; appropriately... It must be even...
; N.B. The area between sample_int and envelope_int must reside
; in a single 64K block of memory... There are currently NO checks
; for this in the code.... This is fairly trivial to implement, It just
; requires a buffer of size envelope_int-sample_int....

	opt p+		;MUST be position-independent code

;once assembled, go into MonST(2) with ALT-D, and save binary file
;(press S) with '<filename>.BIN', with (start address, end) = 'top,bottom'


;global parameters you can change (as you wish) :-

STACKMAX equ	200	;how many 16-bit words deep each channel stack is


;	SECTION	TEXT

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
	dc.w	0
	dc.w	0
timdata	dc.b	0		;$40.b	[was $2c]
active	dc.b	0		;$41.b	[0=>dormant, 1=> active]

lowlevelroutine dc.l 0
lowlevelpointer	dc.l 0

	;case of soundtype=
		;[0] => default internal sound
	;will install driver when soundenable is called (ie Start)


Install	;must be in supervisor mode!
	movem.l	d0-d1/a0-a1,-(sp)
	lea	loopcount(pc),a0
	lea	smod1(pc),a1
	move.l	a0,(a1)
	lea	smod2(pc),a1
	move.l	a0,(a1)

	bsr.w	initsample_int			;setup branches

	bsr.w	Stop				;kill interrupts


	move.w	SR,-(sp)
	move.w	#$2700,SR			;disable int's while
	lea	oldints(pc),a0			;changing vectors
	move.l	$134.w,(a0)
	move.l	$114.w,4(a0)
	move.l	8*4.w,8(a0)

	bsr	typesub
	bsr.w	initmodule

	move.w	(sp)+,SR
	bsr.w	initsoundchip

	movem.l	(sp)+,d0-d1/a0-a1
	rts

typesub
	clr.w	d1
	lea	typearray(pc),a0
	move.l	0(a0,d1.w),d1		;get routine & buffer offsets
	pea	0(a0,d1.w)		;push 256-byte buffer pointer addr
	swap	d1
	pea	0(a0,d1.w)		;push routine address
	lea	lowlevelroutine(pc),a0
	move.l	(sp)+,(a0)
	move.l	(a0),$134.w		;interrupt auto-vector
	lea	lowlevelpointer(pc),a0
	move.l	(sp)+,(a0)
	lea	PrivViolation(PC),a1
	move.l	a1,8*4.w
	rts

soundtype MACRO
	dc.w	\1-typearray
	ENDM

typearray
	soundtype sample_int
maxtype	equ	*-typearray



oldints	dc.l	0,0,0		;holds original (system, perhaps) vectors

DeInstall
	movem.l	d0/a0,-(sp)
	bsr.s	Stop				;stop interrupts

	lea	songptr(pc),a0
	clr.l	(a0)
	clr.l	vsetptr-songptr(a0)				;invalidate data area

	move.w	SR,d0
	move.w	#$2700,SR			;disable int's while
	lea	oldints(pc),a0			;changing vectors
	move.l	(a0),$134.w
	move.l	4(a0),$114.w
	move.l	8(a0),8*4.w
	lea	active(pc),a0
	clr.b	(a0)				;not active any more!
	move.w	d0,SR

	bsr.w	killsoundchip

	movem.l	(sp)+,d0/a0
	rts


Start	move.l	a0,-(sp)
	lea	songptr(pc),a0
	tst.l	(a0)
	beq.s	notvalid
*	tst.l	4(a0)
*	beq.s	notvalid

	movem.l	d0-d7/a1-a6,-(sp)
	bsr.w	sounddisable
	bsr.w	makechannels		;make stacks etc
	movem.l	(sp)+,d0-d7/a1-a6
	bsr.w	setfreq
validx
	bsr.w	soundenable		;start up interrupts!
notvalid
	move.l	(sp)+,a0
	rts

Stop	bra.w	sounddisable		;turn off interrupts!

Restart	move.l	a0,-(sp)
	btst	#7,active(pc)		;is quartet active?
	bne.s	notvalid		;can't restart if it is!
	lea	songptr(pc),a0
	tst.l	(a0)
	beq.s	notvalid
**	tst.l	4(a0)
*	beq.s	notvalid
	lea	freq0(pc),a0
	move.l	freqsave-freq0(a0),(a0)+
	move.l	freqsave-freq0(a0),(a0)+
	move.l	freqsave-freq0(a0),(a0)+
	move.l	freqsave-freq0(a0),(a0)+
	bra.s	validx


padlength=1600

initmodule
	move.l	songptr(pc),a0

	lea	pattoffs(pc),a1
	move.w	#472,(a1)		* pattern offset
	move.w	#600,2(a1)		* sample offset
	move.w	#472+128,4(a1)		* pattern base
	cmp.l	#$4d2e4b2e,1080(a0)
	bne.s	.oldversion
	move.w	#$3b8,(a1)
	move.w	#$43c,2(a1)
	move.w	#$3b8+$84,4(a1)
.oldversion
	add.w	(a1),a0			* a0 = pattern list
	moveq	#$7f,d0
	moveq	#0,d1
.init1
	move.l	d1,d2
	subq.w	#1,d0
.init2
	move.b	(a0)+,d1		* get pattern number
	cmp.b	d2,d1
	bgt.s	.init1			* update d2 to new bigger pattern
	dbf	d0,.init2		* check all patterns
	addq.b	#1,d2

.init3
	move.l	songptr(pc),a0
	lea	sample0(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	move.w	pattoffs+2(pc),d0
	ext.l	d0
	add.l	d0,d2
	add.l	a0,d2

	moveq	#14,d7
	move.w	pattoffs(pc),d0
	cmp.w	#472,d0
	beq	.old1
	moveq	#30,d7
.old1	move.l	d2,a6
* Now fill in sample offsets
.init4
	move.l	d2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	cmp.w	#2,48(a0)	* does this sample repeat???
	ble	.nlop
	move.w	46(a0),d0	* N.B. repeat doesn't appear to be halved in tracker format
	add.w	48(a0),d0
	add.w	48(a0),d0	* max length ever played
	lsr.w	d0
	move.w	d0,42(a0)	* save it in sample info
	bra	.ok
.nlop	move.w	#-1,48(a0)	* so I can signify no repeat
.ok	asl.l	#1,d1
	add.l	d1,d2
	add.w	#30,a0
	dbf	d7,.init4	* 31 sample addresses to fill in
	move.l	d2,(a1)		* +enddescriptor
	move.l	d2,a1		* a1 = address of first free byte

	moveq	#0,d0
* convert to unsigned (Xs 128)
.loopc
	move.b	(a6),d0
*	asr.b	d0
	move.b	d0,(a6)
	add.b	#128,(a6)+
	cmp.l	a6,a1
	bne	.loopc

	lea	sample0+16*4(pc),a0
	move.w	pattoffs(pc),d0
	cmp.w	#472,d0
	beq	.old2
	lea	sample0+32*4(pc),a0
.old2
* Now pad out the set for outside loop detect
.init5
	cmp.l	-(a0),a1	* no sample to pad out
	bne	.init6
	bra	.init5
.init6
	move.l	a1,a3
.mlop6	move.b	(a3),padlength(a3)
	cmp.l	4(a0),a3
	beq	.einit6
	subq.w	#1,a3
	bra	.mlop6
.einit6	lea	sample0+31*4(pc),a2
.loop6	cmp.l	a0,a2
	beq	.end6
	add.l	#padlength,(a2)
	subq.l	#4,a2
	bra	.loop6
.end6	add.l	#padlength,a1

	subq.l	#4,a0
	lea	sample0-4(pc),a6
	cmp.l	a6,a0
	bne	.init6

* should now at least have the space to work with
	lea	sample0(pc),a0
	move.l	songptr(pc),a1
.init7
	move.l	(a0),a2		* sample address
	move.w	42(a1),d0
	add.w	d0,d0
	add.w	d0,a2		* end of sample -- should be start of pad area

	tst.w	48(a1)
	bmi	.nrepeat
	move.l	a2,a3
	move.w	48(a1),d0
	add.w	d0,d0
	sub.w	d0,a3		* start of repeated section
	move.w	#padlength-1,d0	* for dbf loop
.loop7a	move.b	(a3)+,(a2)+
	dbf	d0,.loop7a
	bra	.nsam7
.nrepeat
	move.w	#padlength-1,d0	* for dbf loop
.loop7	move.b	#$80,(a2)+
	dbf	d0,.loop7

.nsam7	addq.l	#4,a0
	add.w	#30,a1
	lea	sample0+15*4(pc),a6
	cmp.l	a0,a6
	bne	.init7

	rts
	
pattoffs:	ds.w	1
sampleoffs:	ds.w	1
pattbase:	ds.w	1
sample0:	ds.l	32






setfreq
	move.b	#$26,$fffffa1f.w		; set to 16K
	move.b	#1,$fffffa19.w			;divide by 4
	rts

	
ftable	dc.b	$b0,$b0,$b0,$b0
	dc.b	$98,$7a,$66,$58,$4c,$44,$3d,$38,$33,$2f,$2c,$29,$26,$24,$22,$20,$1e
	even




;----------------------------------------
;generate all relevant data for each channel in turn

getchan MACRO
	lea	ioffset\1(pc),a4
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
	bsr.s	makechannel

	move.l	songptr(pc),a0
	add.w	pattoffs(pc),a0
	lea	initialpattern(pc),a1
	clr.b	(a1)			* first pattern
	lea	currentpattern(pc),a1
	move.b	#-1,(a1)		* current pattern
	lea	pattpos(pc),a1
	move.w	#-16,(a1)		* offset into that pattern
	lea	maximumpattern(pc),a1
	move.b	-2(a0),(a1)		* maximum pattern number
	lea	patternaddress(pc),a1	* address of that pattern
	moveq	#0,d0
*	move.b	currentpattern(pc),d0
	clr.b	d0
	move.b	(a0,d0.w),d0		* first pattern number
	asl.w	#8,d0
	asl.l	#2,d0			* *1024 for pattern offset
	move.l	songptr(pc),a0
	add.w	pattbase(pc),a0
*	add.w	#$80,a0			* go to first pattern
	add.l	d0,a0
	move.l	a0,(a1)			* store current pattern address

	rts


makechannel
	;a0 is channel
	;first, set up variables for this channel

	clr.l	freq(a4)
	move.l	#-1,rppt(a4)
	move.l	#-1,irppt(a4)
	lea	silentend(pc),a2
	move.l	a2,inst(a4)
	move.l	a2,base(a4)
	move.l	#silentval,ioffset(a4)
	move.l	#silentval,offset(a4)
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
	or.w	#$2000,d1		;timer A on, timer C on
	lea	$fffffa00.w,a0
	move.w	#$2700,SR
	movep.w	d1,IMRA(a0)
	movep.w	d1,IERA(a0)
	lea	active(pc),a0
	move.b	#255,(a0)
	bsr.w	typesub			;install selected sound driver

	move.w	d0,SR
	movem.l	(sp)+,d0-d1/a0-a1
	rts



sounddisable
	movem.l	d0-d1/a0,-(sp)
	move.w	SR,d0

	move.w	#$2700,SR
	lea	$fffffa00.w,a0
	move.w	irqmask(pc),d1
	movep.w	d1,IMRA(a0)	;also writes to IMRB
	movep.w	d1,IERA(a0)	;also writes to IERB
	moveq.l	#0,d1
	movep.l	d1,IPRA(a0)	;also clears IPRB, ISRA, & ISRB
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
	move.b	#7,(a0)		turn on sound
	move.b	#$c0,d0
	and.b	(a0),d0
	or.b	#$38,d0
	move.b	d0,2(a0)

	move.w	#$0500,d0	;set registers 5/4/3/2/1/0 all = 0
initslp	movep.w	d0,(a0)
	sub.w	#$0100,d0
	bpl.s	initslp
	move.b	#8,(a0)		; select register 8
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
	dc.b	(($\1>>8)&15),(($\1>>4)&15)
	dc.b	(($\2>>8)&15),(($\2>>4)&15)
	dc.b	(($\3>>8)&15),(($\3>>4)&15)
	dc.b	(($\4>>8)&15),(($\4>>4)&15)
	dc.b	(($\5>>8)&15),(($\5>>4)&15)
	dc.b	(($\6>>8)&15),(($\6>>4)&15)
	dc.b	(($\7>>8)&15),(($\7>>4)&15)
	dc.b	(($\8>>8)&15),(($\8>>4)&15)
	ENDM


pad	MACRO
	dcb.b	(\1)-*,0
	ENDM

cliptab
	dcb.w	$180,0		* bottom clip area
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

* top clip area
	REPT	$48
	digi2	fd3,fd3,fd3,fd3,fd3,fd3,fd3,fd3
	ENDR


;----------------------------------------------------------------------
;now - decode quartet data stuff

initsample_int
	lea	sample_int(pc),a0
	move.w	#NUMPREP-2,d1
	move.l	a0,d0
.loop
	add.w	#22,d0
	move.w	d0,16(a0)
	add.w	#22,a0
	dbf	d1,.loop
	lea	sample_int(pc),a1
	move.l	a1,d0
	move.w	d0,16(a0)
	rts

NUMPREP	equ	322


sample_int
	rept	(NUMPREP-4)/2
	move.l	#$11000900,$ffff8802.w
	move.w	#$1100,$ffff8802.w
	move.w	#0000,$134+2.w
	rte

	move.l	#$11000800,$ffff8802.w
	move.w	#$1100,$ffff8802.w
	move.w	#0000,$134+2.w
	rte
	endr


	move.l	#$11000900,$ffff8802.w
	move.w	#$1100,$ffff8802.w
	move.w	#0000,$134+2.w
	rte

	move.l	#$11000800,$ffff8802.w
	move.w	#$1100,$ffff8802.w
	move.w	#0000,$134+2.w
	bra.b	envelope_int

	move.l	#$11000900,$ffff8802.w
	move.w	#$1100,$ffff8802.w
	move.w	#0000,$134+2.w
	rte

	move.l	#$11000800,$ffff8802.w
	move.w	#$1100,$ffff8802.w
	move.w	#0000,$134+2.w
	rte




loopmac	MACRO
	move.l	rppt\1(pc),d4
	bpl	.rep\1
	lea	freq\1(pc),a5
	clr.l	(a5)		; stop the bastard dead if silence is required
	lea	silentend(pc),a6
	lea	base\1(pc),a5
	move.l	a6,(a5)
	move.l	#-1,d\1
	bra	.nrep\1	
.rep\1	swap	d\1
	subq.l	#1,d\1		;compensate for carry cascade (very minor!)
	sub.l	d4,d\1
	swap	d\1
.nrep\1
	ENDM


	;now, preperation bit!!!!
envelope_int
	move.w	#$700,$ffff8240.w
	movem.l	d0-d7/a0-a6,-(sp)	; be careful... ruining latency???
	move.w	#$0500,SR		; allow timer A to interrupt (??)
					; now in user mode.. user A7 is fair game
*	;now perform sample stepping in the midground
	movem.l	freq0(pc),d0/d1/d6/d7
	swap	d0
	swap	d1
	swap	d6
	swap	d7
	move.l	d0,a6
	move.l	d1,a7
	movem.l	offset0(pc),d0-d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	movem.l	base0(pc),a0-a3

	clr.w	d5	;high byte of low word is always zero

	lea	sample_int+2(pc),a5	;table address for selfmodifying bits

smod1=*+4
	move.w	#NUMPREP/2,0
.midglp
*	REPT	NUMPREP/2

	clr.w	d4
	add.l	a6,d0
	addx.w	d4,d0
	add.l	a7,d1
	addx.w	d4,d1
	add.l	d6,d2
	addx.w	d4,d2
	add.l	d7,d3
	addx.w	d4,d3

	move.b	0(a0,d0.w),d4
v10=*+2
	lea	Voltabs+64*256(pc),a4		;holds volumetable
	move.b	0(a4,d4.w),d4

	move.b	0(a1,d1.w),d5
v11=*+2
	lea	Voltabs+64*256(pc),a4		;holds volumetable
	move.b	0(a4,d5.w),d5
	add.w	d5,d4

	move.b	0(a2,d2.w),d5
v12=*+2
	lea	Voltabs+64*256(pc),a4		;holds volumetable
	move.b	0(a4,d5.w),d5
	add.w	d5,d4

	move.b	0(a3,d3.w),d5
v13=*+2
	lea	Voltabs+64*256(pc),a4		;holds volumetable
	move.b	0(a4,d5.w),d5
	add.w	d5,d4

	add.w	d4,d4			; double for table

	lea	cliptab(pc),a4		;holds cliptab
	move.b	0(a4,d4.w),(a5)
	move.b	1(a4,d4.w),8(a5)
	lea	22(a5),a5


	clr.w	d4
	add.l	a6,d0
	addx.w	d4,d0
	add.l	a7,d1
	addx.w	d4,d1
	add.l	d6,d2
	addx.w	d4,d2
	add.l	d7,d3
	addx.w	d4,d3

	move.b	0(a0,d0.w),d4
v20=*+2
	lea	Voltabs+64*256(pc),a4		;holds volumetable
	move.b	0(a4,d4.w),d4

	move.b	0(a1,d1.w),d5
v21=*+2
	lea	Voltabs+64*256(pc),a4		;holds volumetable
	move.b	0(a4,d5.w),d5
	add.w	d5,d4

	move.b	0(a2,d2.w),d5
v22=*+2
	lea	Voltabs+64*256(pc),a4		;holds  volumetable
	move.b	0(a4,d5.w),d5
	add.w	d5,d4

	move.b	0(a3,d3.w),d5
v23=*+2
	lea	Voltabs+64*256(pc),a4		;holds volumetable
	move.b	0(a4,d5.w),d5
	add.w	d5,d4

	add.w	d4,d4			; double for table
	lea	cliptab(pc),a4		;holds cliptab
	move.b	0(a4,d4.w),8(a5)
	move.b	1(a4,d4.w),(a5)
	lea	22(a5),a5


smod2=*+2
	subq.w	#1,0
	bne	.midglp

*	ENDR
	
	lea	Tstack(PC),a7		; temporary stack while in user mode

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

.lpdone
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	lea	offset0(pc),a4
	movem.l	d0-d3,(a4)

.nonedone

	lea	scount(pc),a5
	subq.w	#1,(a5)			decrease speed number
	bgt.s	envx
	move.w	-2(a5),(a5)		reset the counter
	bsr.w	decodesub
	rte
envx
* deal with Portamentos etc.
arp	MACRO	* voice number 0--3
	lea	amigafx0+(4*\1)(pc),a2
	tst.w	(a2)
	beq.s	.nofx\@	
	tst.b	(a2)
	bne	.n0\@
	bsr	dealarpegio
.n0\@	cmp.b	#1,(a2)
	bne	.n1\@
	bsr	dealportup
.n1\@	cmp.b	#2,(a2)
	bne	.n2\@
	bsr	dealportdown
.n2\@
	lea	v1\1(pc),a3	* for volume portamento
	cmp.b	#$a,(a2)
	bne	.na\@
	bsr	dealvolport
.na\@

.nofx\@
	ENDM

	arp	0
	arp	1
	arp	2
	arp	3

	rte				* cause a privilige violation
	
PrivViolation
	addq.l	#6,sp			* skip extra return
	movem.l (sp)+,d0-d7/a0-a6	* reastore registers
	move.w	#$777,$ffff8240.w
	rte				* return to caller


	ds.l	10
Tstack:	dc.l	0
loopcount: dc.w	0

lastbtmod dc.b	0
nextpass dc.b	0
	even

decode:	MACRO	VoiceNumberh
	move.l	\1*4(a0,d0),d1		* read instruction
	beq.w	.decanother\@		* fuck it, its zero see if the other voices are too

	move.l	d1,d2
	swap	d2
	and.w	#$1000,d2
	lsr.w	#8,d2

	move.l	d1,d3
	rol.w	#4,d3
	and.w	#$f,d3			* sample number
	add.w	d2,d3			* upto 32 samples

	move.l	d1,d2
	swap	d2
	and.w	#$fff,d2		* frequency

	lea	ioffset\1(pc),a5

	subq.w	#1,d3
	bmi	.nonewsamp\@
.okdoke\@
******
* Set up new play command

	lea	amigasam0+(\1*4)(pc),a2
	move.w	d3,(a2)
	move.w	d3,d4
	lsl.w	#2,d4			* offset intop sample table
	lea	sample0(pc),a2
	move.l	(a2,d4.w),d4		* sample address
	mulu.w	#30,d3
	move.l	songptr(pc),a2
	add.w	d3,a2			* pointer into sample info

	moveq	#0,d6
	move.w	42(a2),d6
	add.w	d6,d6
	swap	d6			* into quartet format
	move.l	d6,ioffset(a5)
	neg.l	ioffset(a5)

	move.w	48(a2),d5
	ext.l	d5
	add.l	d5,d5
	swap	d5
	move.l	d5,irppt(a5)		* repeat length

	swap	d6
	add.l	d6,d4
	move.l	d4,inst(a5)		* pointer to end of sample

	move.w	44(a2),d5
	move.w	d5,volume(a5)
	lsl.w	#8,d5			* offset into volume table
	lea	voltabs(pc),a3
	lea	v1\1(pc),a4
	sub.l	a4,a3
	add.w	d5,a3
	move.w	a3,(a4)			* set up tracker volume properly
	sub.w	#v2\1-v1\1,a3
	lea	v2\1(pc),a4
	move.w	a3,(a4)

* I don't think I need the initial values
* so I was wrong!!!!
.nonewsamp\@
	tst.w	d2
	beq	.nonewnote\@

	move.l	inst(a5),base(a5)
	move.l	ioffset(a5),offset(a5)
	move.l	irppt(a5),rppt(a5)

	move.w	d2,amigaf(a5)		* save amiga chip frequency
	lea	freqtable(pc),a3
	asl.w	#2,d2
	move.l	(a3,d2.w),freq(a5)




.nonewnote\@
	and.w	#$fff,d1
	lea	amigaFX0+(\1*4)(pc),a2
	move.w	d1,(a2)
	beq	.decanother\@		* no special FX
	move.w	d1,d3
	and.w	#$ff,d1			* FX data
	lsr.w	#7,d3			* actual FX code*2
	and.w	#$1e,d3
	lea	FXrouts(pc),a2
	lea	FXtable(pc),a3
	add.w	(a3,d3.w),a2
	lea	ioffset\1(pc),a5	* -> to area to modify with FX
	lea	v1\1(pc),a3
	jsr	(a2)			* do effect


.decanother\@
	ENDM




* Now the Tracker decoder
decodesub:
	lea	pattpos(pc),a1
	move.w	(a1),d0
	add.w	#16,d0		* next item in pattern
	and.w	#1023,d0	* wraps at 1024
	move.w	d0,(a1)		* store new pattern offset
	bne	.nnpat		* not a new pattern
	moveq	#0,d1
	lea	currentpattern(pc),a0
	move.b	(a0),d1
	addq.b	#1,d1
	cmp.b	maximumpattern(pc),d1
	bne	.nrstart
	move.b	initialpattern(pc),d1
.nrstart
	move.b	d1,(a0)		* save new current pattern
	move.l	songptr(pc),a0
	add.w	pattoffs(pc),a0
	move.b	(a0,d1.w),d1
	asl.w	#8,d1
	asl.l	#2,d1
	move.l	songptr(pc),a0
	add.w	pattbase(pc),a0
*	add.w	#$84,a0
	add.l	d1,a0
	lea	patternaddress(pc),a2
	move.l	a0,(a2)
.nnpat
	move.l	patternaddress(pc),a0	* address of current pattern
*					* d0=pattern offset
	decode	0	
	decode	1
	decode	2
	decode	3
	rts


* I ripped this bit out of a soundtracker thing *
* I don't think it's how the original works!!!! *

dealarpegio
	tst.l	freq0-amigaFX0(a2)
	beq	.end			* sample pointing at silence
	move.w	scount(pc),d0
	cmp.w	#5,d0
	beq	arp2
	cmp.w	#4,d0
	beq	arp3
	cmp.w	#3,d0
	beq	arp4
	cmp.w	#2,d0
	beq	arp2
	cmp.w	#1,d0
	beq	arp3
.end	rts

arp2
	move.w	#0,d0
	move.b	1(a2),d0
	lsr.w	#4,d0
	bra	arpcont
arp3
	move.w	#0,d0
	move.b	1(a2),d0
	and.w	#$f,d0
	bra	arpcont
arp4
	move.w	amigaf0-amigaFX0(a2),d0
	bra	endarp
arpcont
	add.w	d0,d0
	move.w	amigaf0-amigaFX0(a2),d1
	lea	arpegiotab(pc),a3
.loop	cmp.w	(a3)+,d1
	bne	.loop
	subq.l	#2,a3
	move.w	(a3,d0.w),d1
endarp
	lea	freqtable(pc),a3
	add.w	d1,d1
	add.w	d1,d1
	move.l	(a3,d1.w),freq0-amigaFX0(a2)
	rts
	


dealportup
	moveq	#0,d0
	move.b	1(a2),d0	* portamentovalue
	move.w	amigaf0-amigaFX0(a2),d1
	sub.w	d0,d1		* change amiga frequency
	cmp.w	#$71,d1
	bpl	.okf
	move.w	#$71,d1		* minimum frequency
.okf	move.w	d1,amigaf0-amigaFX0(a2)
	lea	freqtable(pc),a3
	asl.w	#2,d1
	tst.l	freq0-amigaFX0(a2)
	beq	.silence
	move.l	(a3,d1.w),freq0-amigaFX0(a2)
.silence
	rts
dealportdown
	moveq	#0,d0
	move.b	1(a2),d0	* portamentovalue
	move.w	amigaf0-amigaFX0(a2),d1
	add.w	d0,d1		* change amiga frequency
	cmp.w	#$358,d1
	bmi	.okf
	move.w	#$358,d1	* minimum frequency
.okf	move.w	d1,amigaf0-amigaFX0(a2)
	lea	freqtable(pc),a3
	asl.w	#2,d1
	tst.l	freq0-amigaFX0(a2)
	beq	.silence
	move.l	(a3,d1.w),freq0-amigaFX0(a2)
.silence
	rts

dealvolport
	moveq	#0,d0
	move.b	1(a2),d0	* portamentovalue
	move.w	volume0-amigaFX0(a2),d1
	sub.w	d0,d1		* change amiga volume
	bpl	.okf
	moveq	#0,d1		* minimum volume
.okf	move.w	d1,volume0-amigaFX0(a2)
	lsl.w	#8,d1
	lea	voltabs(pc),a4
	add.w	d1,a4
	sub.l	a3,a4
	move.w	a4,(a3)			* set up tracker volume properly
	sub.w	#v20-v10,a4		* This will be good for a laugh
	add.w	#v20-v10,a3
	move.w	a4,(a3)
	rts


FXe	MACRO
	dc.w	\1-FXrouts,\2-FXrouts,\3-FXrouts,\4-FXrouts
	ENDM

FXtable
	FXe	ArpFX,PortupFX,PortdownFX,PorttoneFX
	FXe	VibratoFX,Nothing,Nothing,Nothing
	FXe	Nothing,Nothing,VolportFX,AbandFX
	FXe	SetVolFX,JumpFX,Nothing,SpeedFX	



FXrouts
Nothing
	move.w	#0,amigaFX(a5)
	rts

ArpFX
	rts

PortupFX
	rts

PortdownFX
	rts

PorttoneFX
	rts

VibratoFX
	rts

VolportFX
	rts

AbandFX
	rts

SetVolFX
	and.w	#$7f,d1
	cmp.w	#$40,d1
	ble	.ok
	move.w	#$40,d1
.ok	move.w	d1,volume(a5)
	asl.w	#8,d1

	lea	voltabs(pc),a4
	add.w	d1,a4
	sub.l	a3,a4
	move.w	a4,(a3)			* set up tracker volume properly
	sub.w	#v20-v10,a4		* This will be good for a laugh
	add.w	#v20-v10,a3
	move.w	a4,(a3)

	rts

JumpFX					* I think this just terminates the current track
	lea	pattpos(pc),a4
	move.w	#-16,(a4)
	rts

SpeedFX					* set synth speed in 50ths 1 fastest
	and.w	#$ff,d1
	lea	speed(pc),a4
	move.w	d1,2(a4)
	move.w	d1,(a4)
	rts





* And variables for the player

speed	dc.w	6			;number of frames per instr
scount	dc.w	6			;counter for above
initialpattern	dc.b	0
currentpattern	dc.b	0
maximumpattern	dc.b	0
	even
pattpos	dc.w	0
patternaddress	dc.l	0


	dc.l	$001000000,$001000000	;format of individual sample
silent	dcb.b	800,$80			;played at end of play and by rests


silentend	equ	silent+700
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
irppt0		dc.l	0,0,0,0		; initial repeat crap
rppt0		dc.l	0
rppt1		dc.l	0
rppt2		dc.l	0
rppt3		dc.l	0
base0		dc.l	0
base1		dc.l	0
base2		dc.l	0
base3		dc.l	0
amigasam0	dc.l	0,0,0,0		; current sample number
amigaf0		dc.l	0,0,0,0		; amiga chip frequency
amigaFX0	dc.l	0,0,0,0		; tracker fx data
volume0		dc.l	0,0,0,0		; volume for each channel
speed0		dc.l	0,0,0,0		; slide speed
freqsave	dc.l	0,0,0,0		; holds freq0..3 while stopped

	;now offset equates
ioffset	equ	0
freq	equ	freq0-ioffset0
inst	equ	inst0-ioffset0
irppt	equ	irppt0-ioffset0
rppt	equ	rppt0-ioffset0
offset	equ	offset0-ioffset0
base	equ	base0-ioffset0
amigaf	equ	amigaf0-ioffset0
amigaFX	equ	amigaFX0-ioffset0
volume	equ	volume0-ioffset0


* Amiga Volume to sample amplitude volume
* 256bytes *64
Voltabs
	incbin voltab.bin
	dcb.b	512,$80	

* now the amiga chip frequency to Quartet frequency conversion

freqtable
	incbin	freqta16.bin


Arpegiotab
	dc.w	$0358,$0328,$02fa,$02d0,$02a6,$0280,$025c
	dc.w	$023a,$021a,$01fc,$01e0,$01c5,$01ac,$0194,$017d
	dc.w	$0168,$0153,$0140,$012e,$011d,$010d,$00fe,$00f0
	dc.w	$00e2,$00d6,$00ca,$00be,$00b4,$00aa,$00a0,$0097
	dc.w	$008f,$0087,$007f,$0078,$0071,$0000,$0000,$0000


bottom	;end of binary saved data



