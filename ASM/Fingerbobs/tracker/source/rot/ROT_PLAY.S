;-------------------------------------------------------------------------
;
; Fingerbobs STE Soundtracker Player - Demo of ROT File in use!
;
; Written by Oberje' 2/12/90 - 26/12/90 (c)1990 Fingerbobs
;
; Used again 11/6/91 : After finally recovering version 2 of my
; ROT file which was corrupted after 2 week of development!
; 
;-------------------------------------------------------------------------

	section	text

red	macro
	dc.b	27,"b",1
	endm
green	macro
	dc.b	27,"b",2
	endm
white	macro
	dc.b	27,"b",3
	endm


start	bsr	reloc		; Relocate player module

	dc.w	$a00a

	pea	run		; Execute program in supervisor mode
	move.w	#$26,-(a7)
	trap	#14
	addq.l	#6,a7
	
	clr	-(a7)		; Exit
	trap	#1

click	ds.w	1

;
; Main program
;
run	move.b	$484.w,click	; Save console bits
	bclr.b	#0,$484.w	; Switch keyclick OFF
	move.b	#$12,$fffffc02.w

	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_pal
	movem.l	new_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w

begin	bsr	load_module	; Load music
speed	move.l	#1,d0		; 12 KHz
	move.l	music_at,a0	;
	bsr	code+28+4	; Init
	bsr	code+28+8	; Start
	move.l	#vbl,$4d6.w	; VBL

program move.w	#37,-(a7)	;
	trap	#14		;
	addq.l	#2,a7		;
	move.w	#$ff,-(a7)	;
	move.w	#6,-(a7)	;
	trap	#1		;
	addq.l	#4,a7		;
	tst.w	d0		;
	beq	program		;
	cmp.b	#"1",d0		;F1
	beq	vol_up
	cmp.b	#"2",d0		;F2
	beq	vol_down
	cmp.b	#"3",d0		;F3
	beq	vol_left_up
	cmp.b	#"4",d0		;F4
	beq	vol_left_down
	cmp.b	#"5",d0		;F5
	beq	vol_right_up
	cmp.b	#"6",d0		;F6
	beq	vol_right_down
	cmp.b	#"7",d0		;F7
	beq	bass_up
	cmp.b	#"8",d0		;F8
	beq	bass_down
	cmp.b	#"9",d0		;F9
	beq	treble_up
	cmp.b	#"0",d0		;F10
	beq	treble_down
	cmp.b	#"t",d0
	beq	timing
	
	move.l	#0,$4d6.w	; VBL Off
	bsr	code+28+12		; Stop
	bra	begin

timing	cmp.w	#$0,vbl+2
	beq.s	.nnn
	move.w	#$0,vbl+2
	bra	program
.nnn	move.w	#$707,vbl+2
	bra	program

vbl	move.w	#$0,$ffff8240.w
	bsr	code+28+16		; VBL
	move.w	#$0,$ffff8240.w
	rts

	even

;
; These are the bits for setting the registers in the
; LMwotsit Volume & Tone chip. It uses a crud interface
; called microwire or something. By the way the info about this
; in the STE Developers info pack is very unhelpful.
;	
vol_up	add.w	#1,m_vol
	cmp.w	#40,m_vol
	ble.s	.over
	move.w	#40,m_vol
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10011000000,d0
	add.w	m_vol,d0
	bsr	mwwrite
	bra	program

vol_down
	sub.w	#1,m_vol
	bpl.s	.over
	clr.w	m_vol
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10011000000,d0
	add.w	m_vol,d0
	bsr	mwwrite
	bra	program
	
vol_left_up
	add.w	#1,l_vol
	cmp.w	#20,l_vol
	ble.s	.over
	move.w	#20,l_vol
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10101000000,d0
	add.w	l_vol,d0
	bsr	mwwrite
	bra	program

vol_left_down
	sub.w	#1,l_vol
	bpl.s	.over
	clr.w	l_vol
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10101000000,d0
	add.w	l_vol,d0
	bsr	mwwrite
	bra	program

vol_right_up
	add.w	#1,r_vol
	cmp.w	#20,r_vol
	ble.s	.over
	move.w	#20,r_vol
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10100000000,d0
	add.w	r_vol,d0
	bsr	mwwrite
	bra	program

vol_right_down
	sub.w	#1,r_vol
	bpl.s	.over
	clr.w	r_vol
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10100000000,d0
	add.w	r_vol,d0
	bsr	mwwrite
	bra	program

bass_up
	add.w	#1,bass
	cmp.w	#12,bass
	ble.s	.over
	move.w	#12,bass
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10001000000,d0
	add.w	bass,d0
	bsr	mwwrite
	bra	program

bass_down
	sub.w	#1,bass
	bpl.s	.over
	clr.w	bass
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10001000000,d0
	add.w	bass,d0
	bsr	mwwrite
	bra	program

treble_up
	add.w	#1,treble
	cmp.w	#12,treble
	ble.s	.over
	move.w	#12,treble
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10010000000,d0
	add.w	treble,d0
	bsr	mwwrite
	bra	program

treble_down
	sub.w	#1,treble
	bpl.s	.over
	clr.w	treble
.over	move.w	#$07ff,$ffff8924.w
	move.w	#%10010000000,d0
	add.w	treble,d0
	bsr	mwwrite
	bra	program

	
	
mwwrite	cmp.w	#$07ff,$ffff8924.w
	bne.s	mwwrite
	move.w	d0,$ffff8922.w
	rts
	
m_vol	dc.w	40
l_vol	dc.w	20
r_vol	dc.w	20
bass	dc.w	6
treble	dc.w	6

	even

;
; Relocate .ROT file
; Might as well, otherwise the bastard thing wont play!
;
reloc	lea	code(PC),a0
	move.l	2(a0),d0
	add.l	$6(a0),d0
	add.l	$E(a0),d0
	lea	$1C(a0),a0
	move.l	a0,a1
	move.l	a0,a2
	move.l	a0,d1
	add.l	d0,a1
	move.l	(a1)+,d0
	add.l	d0,a2
	add.l	d1,(a2)
	moveq	#0,d0
rel_lp	move.b	(a1)+,d0
	beq.s	reldone
	cmp.b	#1,d0
	beq.s	rel_1
	add.l	d0,a2
	add.l	d1,(a2)
	bra.s	rel_lp
rel_1	lea	$fe(a2),a2
	bra.s	rel_lp
reldone	rts


;----------------------------------------------------------------------------
;
; Load in a module from disk
;
;----------------------------------------------------------------------------
load_module
	move.l	#music,music_at
	pea	message(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	pea	free_mem(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	$436.w,d0	; Mem Top
	sub.l	#space,d0	; - End of program 
	bsr	number		; = Free mem
	pea	newline
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	pea	prompt(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	
	
input	lea	fname(pc),a0
	moveq	#(128/4)-1,d0
.loop
	move.l	#0,(a0)+
	dbf	d0,.loop
	
	move.b	#126,fname
	pea	fname
	move.w	#$a,-(a7)
	trap	#1
	addq.l	#6,a7
	
	cmp.l	#"EXIT",fname+2
	beq	lets_go
	cmp.l	#"LIST",fname+2
	beq	directory
	cmp.l	#"CD A",fname+2
	beq	driveA
	cmp.l	#"CD B",fname+2
	beq	driveB
	cmp.l	#"FAST",fname+2
	beq	fast
	cmp.l	#"SLOW",fname+2
	beq	slow
	cmp.l	#"HELP",fname+2
	beq	help
	
	pea	loading(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	pea	fname+2(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	pea	newline
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	
	move.w	#0,-(a7)
	pea	fname+2(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.l	d0
	bmi	Error
	move.w	d0,d7
	pea	music
	pea	$fffff	
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	tst.l	d0
	bmi	Error
	
	move.l	d0,d5
	pea	mod_long	; Module length
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d5,d0
	bsr	number
	pea	newline
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	tst.l	d0
	bmi	Error

	lea	music,a0
	cmp.l	#"LSD!",(a0)
	beq	unpack

	move.l	$436.w,d6	; Mem top
	add.l	#space,d5	; base+len
	sub.l	d5,d6		; Free mem
	pea	free_mem(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d6,d0
	bsr	number		; = Free mem
	pea	newline
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

cont
	pea	playing(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	music_at,-(a7)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts
lets_go
	move.l	#0,$4d6.w	; VBL Off
	bsr	code+36		; DMA Off
	move.b	click,$484.w	; Restore console bits
	move.b	#$8,$fffffc02.w
	dc.w	$a009
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	clr	-(a7)
	trap	#1

Error	pea	error2(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	bra	load_module

directory
	move.w	#$19,-(a7)	; Set Drive letter
	trap	#1
	addq.l	#2,a7
	add.w	#"A",d0
	move.b	d0,dlet
	pea	listing(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	pea	dta		; Set DTA
	move.w	#$1a,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#0,-(a7)	; Attrib
	pea	template(pc)	; Search
	move.w	#$4e,-(a7)
	trap	#1		; Sfirst
	addq.l	#8,a7
	lea	dta(pc),a6
.loop
	pea	dta+30
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	dta+26,a0
	move.l	(a0),d0
	bsr	number		; File Length

	pea	newline
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	
	move.w	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
	tst.l	d0
	bpl.s	.loop
	
.end	pea	listend(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	
	bra	load_module

fast	move.l	#1,speed+2	; 12 KHz
	pea	fastmess
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	bra	input

slow	move.l	#0,speed+2	; 6 KHz
	pea	slowmess
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	bra	input

driveA
	move.w	#0,-(a7)
	move.w	#$e,-(a7)
	trap	#1
	addq.l	#4,a7
	pea	ok
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	bra	input
driveB
	move.w	#1,-(a7)
	move.w	#$e,-(a7)
	trap	#1
	addq.l	#4,a7
	pea	ok
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	bra	input

help	pea	help_message
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	pea	help_message2
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	#8,-(a7)
	trap	#1
	addq.l	#2,a7
	bra	load_module

;
; Enter D0=number
; Ouptuts number a 6 digit hex value
;
number	lea	outnum+7,a0
	lea	char,a1
	move.w	#6-1,d7
.loop
	moveq	#0,d1
	move.b	d0,d1
	andi.b	#$f,d1
	move.b	(a1,d1.w),d1
	move.b	d1,-(a0)
	lsr.l	#4,d0
	dbf	d7,.loop
	
	pea	show
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	rts

show	dc.b	9
outnum	dc.b	"$000000",0
char	dc.b	"0123456789ABCDEF"
	
unpack	move.l	#space,music_at

	move.l	music+4,d5
	pea	un_long		; Unpacked length
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d5,d0
	bsr	number
	pea	newline
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	$436.w,d6	; Mem top
	add.l	#space,d5	; base+len
	sub.l	d5,d6		; Free mem
	pea	free_mem(pc)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d6,d0
	bsr	number		; = Free mem
	pea	newline
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7

	lea	music,a0
	lea	space,a1
	bsr	DEPACK
	bra	cont

;
; Automation 2.3 Depack code
;
; Enter A0 = Packed Data
;       A1 = Output to..
;
; Areas can overlap but A1 should be around
; 5k after A0
;

DEPACK	addq.l	#4,a0
	MOVEA.L	A0,A4
	MOVE.L	(A0)+,D5
	ADDA.L	D5,A1
	ADDA.L	(A0),A0
	SUBA.L	#4,A0

	TST.W	-(A0)			Test if it's a dummy.
	BPL.S	L652BC			NO. Valid data.
	SUBQ.L	#1,A0			Adjust it.

L652BC	MOVE.B	-(A0),D0
L652BE	LSL.B	#1,D0
	BNE.S	L652C6
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652C6	BCC.S	L65322			Go do the REPEATS.

	CLR.W	D1			Clear size count.
	LSL.B	#1,D0
	BNE.S	L652D2
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652D2	BCC.S	L65316			If ZERO then its a 1 byte repeat

	LEA	L6530E(PC),A3		Lower table? BIT sizes.
	MOVEQ	#3,D3			Initial index.
L652DA	CLR.W	D1			Clear size count.
	MOVE.B	0(A3,D3.W),D2		Get the BITsize.
	EXT.W	D2			Clear the crap.
	MOVEQ	#-1,D4			Set all the bits.
	LSL.W	D2,D4			Fill with X zero bits.
	NOT.W	D4			Invert the BITS.
	SUBQ.W	#1,D2			Adjust bit size.

L652EA	LSL.B	#1,D0
	BNE.S	L652F2
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L652F2	ROXL.W	#1,D1			Collect the size.
	DBF	D2,L652EA

	TST.W	D3			??? No zeroes in the table.
	BEQ.S	L65302
	CMP.W	D1,D4
	DBNE	D3,L652DA
L65302	MOVE.B	4(A3,D3.W),D2		Upper table. ADJUSTMENTS.
	EXT.W	D2			Clear crap.
	ADD.W	D2,D1			Adjust JUNK's count size.
	BRA.s	L65316

L6530E	DC.B	$A,3,2,2,$E,7,4,1

L65316	MOVE.B	-(A0),-(A1)		Transfer BYTES of junk.
	DBF	D1,L65316

L65322	MOVEA.L	A4,A3
	ADDQ.L	#8,A3
	CMPA.L	A3,A0
	BLE	gohome
	LEA	L65368(PC),A3		Little table.
	MOVEQ	#3,D2
L65332	LSL.B	#1,D0
	BNE.S	L6533A
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L6533A	BCC.S	L65340
	DBF	D2,L65332

L65340	CLR.W	D1
	ADDQ.W	#1,D2
	MOVE.B	0(A3,D2.W),D3		Get the BIT size.
	BEQ.S	L6535C			If ZERO no more bit to collect.
	EXT.W	D3			Clear the crap.
	SUBQ.W	#1,D3			Adjust for looping

L6534E	LSL.B	#1,D0
	BNE.S	L65356
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L65356	ROXL.W	#1,D1
	DBF	D3,L6534E

L6535C	MOVE.B	5(A3,D2.W),D3		Get any ADJUSTMENTS.
	EXT.W	D3
	ADD.W	D3,D1
	BRA.s	L65372			Go to normal REPEAT routine.

L65368	DC.B	$A,2,1,0,0,$A,6,4	Little table.
	DC.B	3,2

L65372	CMPI.W	#2,D1			2byte repeat.
	BEQ.S	rep			Yeh. Use A3's small table.
	LEA	L653AC(PC),A3		ELSE use the big table.
	MOVEQ	#1,D3			Only two bits to collect.
L6537E	LSL.B	#1,D0
	BNE.S	L65386
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0

L65386	BCC.S	L6538C			If first bit zero then leave
	DBF	D3,L6537E
L6538C	ADDQ.W	#1,D3			Adjust index into the table.
	CLR.W	D2			UGH!!
	MOVE.B	0(A3,D3.W),D4		Fetch offset's bitsize.
	EXT.W	D4			Clear the crap.

L65396	LSL.B	#1,D0
	BNE.S	L6539E
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L6539E	ROXL.W	#1,D2			Collect offset.
	DBF	D4,L65396
	LSL.W	#1,D3			Align with upper table.
	ADD.W	4(A3,D3.W),D2		Add the adjustment to the offset.
	BRA.S	L653DC			Go to MAIN repeat routine.

L653AC	DC.B	$B,4,7,0,1,$20		Offset bit sizes.
	DC.B	0,0,0,$20,0,0		Adjustments to the offsets.

rep	CLR.W	D2			Clear offset register.
	MOVEQ	#5,D3			SMALL 6bit offset
	CLR.W	D4			Set the ADJUSTER.
	LSL.B	#1,D0
	BNE.S	L653C6
	MOVE.B	-(A0),D0
	ROXL.B	#1,D0
L653C6	BCC.S	L653CC			If CLEAR then small offset.
	MOVEQ	#8,D3			LARGE 9bit offset.
	MOVEQ	#$40,D4			Set the ADJUSTER.

L653CC	LSL.B	#1,D0
	BNE.S	L653D4
	MOVE.B	-(A0),D0		Reload the data register.
	ROXL.B	#1,D0			and shift first bit.
L653D4	ROXL.W	#1,D2			Collect the offset.
	DBF	D3,L653CC

	ADD.W	D4,D2			Add any ADJUSTER to offset.
L653DC	LEA	0(A1,D2.W),A2		Calc address of repeated string.
	EXT.L	D1			Clear the shit in the LENGTH.
	ADDA.L	D1,A2			LENGTH + address = string end.
	SUBQ.W	#1,D1			Adust LENGTH for looping.
L653E6	MOVE.B	-(A2),-(A1)		Transfer the bytes.
	DBF	D1,L653E6
	BRA	L652BE
gohome	RTS



	even
	
ok	white
	dc.b	13,10,"OK.",13,10,">"
	;red
	dc.b	0
	
error2	;red
	dc.b	13,10,"A Load Error Has Occurred! - Press a key ",13,10,0

	even
	
message	dc.b	27,"E"
	white
	dc.b	27,"p FINGERBOBS STE TRACKER ",27,"q",13,10
	dc.b	13,10
	;green
	dc.b	"Version : 2.01 : Demonstration",13,10
	dc.b	13,10
	white
	dc.b	"Fingerbobs STE Soundtracker module player coded by Oberje'. This is ",13,10
	dc.b 	"the second version. Now making an appearance after I thought it lost",13,10
	dc.b	"in a disk corruption spree my STE had for a couple of weeks.",13,10
	dc.b	13,10
	dc.b	"The player featured here is a full translation of the Noistracker",13,10
	dc.b	"v1.0 replay code by Mahoney and Cactus on the Amiga. The ROT file",13,10
	dc.b	"just pretend to be a Paula chip. A couple of modifications to the",13,10
	dc.b	"amiga code & it works!",13,10
	dc.b	"Code also added so it will work with older soundtracker modules",13,10
	dc.b	"e.g. DOC",13,10
	dc.b	13,10
	dc.b	"Type name of module required, or HELP for keys/more info.",13,10
	dc.b	"Modules packed with Automation packer will automatically be depacked.",13,10,13,10
	dc.b	0

prompt	white
	dc.b	13,10,">"
	;red
	dc.b	0

free_mem	;green
		dc.b	"Free memory   : "
		white
		dc.b	0

mod_long	;green
		dc.b	"Module length : "
		white
		dc.b	0

un_long		;green
		dc.b	"Unpacked len  : "
		white
		dc.b	0

help_message	;red
	dc.b	27,"E"
	dc.b	"HELP!",13,10
	;green
	dc.b	"Type the name of the module required, or one of these commands..",13,10,13,10
	white
	dc.b	"   LIST    Directory of *.MOD files on current drive",13,10
	dc.b	"   CD A    Change drive to A",13,10
	dc.b	"   CD B    Chnage drive to B",13,10
	dc.b	"   HELP    For this page!",13,10
	dc.b	"   EXIT    Quit program",13,10,13,10
	;green
	dc.b	"During Playback the Volume/Tone chip can be adjusted with the"
	dc.b	" following keys",13,10,13,10
	white
	dc.b	"   + - ",13,10
	dc.b	"   1 2 : Master volume",13,10
	dc.b	"   3 4 : Left volume",13,10
	dc.b	"   5 6 : Right volume",13,10
	dc.b	"   7 8 : Bass",13,10
	dc.b	"   9 0 : Treble",13,10,13,10
	;green
	dc.b	"Pressing 't' will toggle the purple timimg bar. The timing bar",13,10
	dc.b	"gives an idea of how much CPU time is being used.",13,10
	dc.b	"( Approx 55% for 12KHz. 42% in version without Volume Variation. )",13,10
	dc.b	13,10
	;red
	dc.b	"Press a key....",0

	even

help_message2	;red
	dc.b	27,"EHELP! ( Continued )",13,10,13,10
	;green
	dc.b	"Soundtracker/Noisetracker commands",13,10,13,10
	white
	dc.b	"   0 - Normal/Arpeggio   : Implemented",13,10
	dc.b	"   1 - Portamento Up     : Implemented",13,10
	dc.b	"   2 - Portamento Down   : Implemented",13,10
	dc.b	"   3 - Tone Portamento   : Implemented",13,10
	dc.b	"   4 - Vibrato           : Implemented",13,10
	dc.b	"   A - Volume slide      : Implemented",13,10
	dc.b	"   B - Position Jump     : Implemented",13,10
	dc.b	"   C - Set Volume        : Implemented",13,10
	dc.b	"   D - Pattern Break     : Implemented",13,10
	dc.b	"   E - Set Filter        : Implemented",13,10
	dc.b	"   F - Set Speed         : Implemented",13,10
	dc.b	13,10
	;green
	dc.b	"Thanx to the following for inspiration.....",13,10
	dc.b	"ST Connexion, Empire, Griff, SYNC, FM!!!!!!!",13,10
	dc.b	13,10
	white
	dc.b	"Fingerbobs : 6 Carron Terrace, Stonehaven, AB3 2HX, Scotland",13,10
	dc.b	13,10
	;green
	dc.b	"If you wish to use this player commercially or PD, please write.",13,10
	dc.b	"Maybe we can come to some arrangement!",13,10
	;red
	dc.b	13,10
	dc.b	"Press a key....",0

	even
	
template	dc.b	"*.mod",0
	
	even

dta	ds.b	44
	dc.w	0

	even
		
newline	dc.b	13,10,0

	even
	
listing	dc.b	13,10,13,10
	;green
	dc.b	"Drive "
dlet	dc.b	"A         Length",13,10
	dc.b	"-----------------------",13,10
	white
	dc.b	0
	
	even
	
listend	;red
	dc.b	13,10,"Press a key...."
	white
	dc.b	0
		
	even
	
loading	;red
	dc.b	13,10,13,10,"Loading : ",0

	even

fname	ds.b	128

	even
	
playing	;red
	dc.b	13,10
	dc.b	"Playing : ",0
	
	even
	
fastmess dc.b	13,10
	;green
	dc.b	"12 KHz Mode Selected",13,10
	white
	dc.b	">"
	;red
	dc.b	0

	even

slowmess dc.b	13,10
	;green
	dc.b	"6 KHz Mode Selected",13,10
	white
	dc.b	">"
	;red
	dc.b	0
	
	even

old_pal	ds.w	16
new_pal	dc.w	$000,$700,$070,$777
	dc.w	$777,$777,$777,$777
	dc.w	$777,$777,$777,$777
	dc.w	$777,$777,$777,$777

music_at	ds.l	1

code	incbin	ste.rot	; Tracker .ROT code

	even

music	ds.b	5*1024

space	equ	*

