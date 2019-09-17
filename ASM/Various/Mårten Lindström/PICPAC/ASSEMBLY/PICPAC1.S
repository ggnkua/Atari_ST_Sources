
*		                  --
*		                PICPAC
*		             ------------
*		         By: M†rten Lindstr”m
*		      --------------------------

* A collection of sub-routines for picture un/packing, including palette
* handling routines, plus non-GEM routines to replace VDI image copy.

* 1 tab per field.
* Suggested tab length - constant: 10, variable: Double operand field

***************************
*	TT_VDO?		Compares VDO_ value MSW with 2
*~~~~~~~~~~~~~~~~~~~~~~~~~~	(Called by SETTRU)
* Affects NO REGISTERS. Only processor condition flags are set
* according to the comparison of the MSW of the VDO_ value with 2.
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* Short version: (requires that the value of the _VDO cookie has been
* copied to label '_vdo' earlier)
*TT_VDO?	cmpi.w	#2,_vdo
*	rts
*--------------------------
* Long version:

TT_VDO?	movem.l	D0-D2/A0-A2/A6,-(SP)
	bsr.s	tt_vdo?3  Push following address on stack and jump

	move.l	$5A0.W,D0
	beq.s	tt_vdo?2
	movea.l	D0,A0
	subq.l	#4,A0
tt_vdo?1	addq.l	#4,A0
	move.l	(A0)+,D0
	beq.s	tt_vdo?2
	cmpi.l	#'_VDO',D0
	bne.s	tt_vdo?1	Try next coookie
	move.w	(A0),D0	Cookie Most Significant Word
tt_vdo?2	rts

tt_vdo?3	move.w	#38,-(SP)	SUPEXEC
	trap	#14
	addq.l	#6,SP
	subq.w	#2,D0	Compare cookie value MSW with 2
	movem.l	(SP)+,D0-D2/A0-A2/A6
	rts


***************************
*    VDI_TRU   TRU_VDI	Routines to transform palettes
*    STE_TRU   STE_VDI	between three different formats:
*    TRU_STE   VDI_STE	ST(E) hardware, VDI and 24-bit
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A0->source, A1->dest,
*   D0.W: Number of colours
*~~~~~~~~~~~~~~~~~~~~~~~~~~

STE_TRU	movem.l	D0-D3/A0-A1,-(SP)
	bra.s	ste_tru3
ste_tru1	move.w	(A0)+,D2
	lsl.w	#5,D2	First bit of Red -> X-bit
	moveq	#2,D1
ste_tru2	rol.w	#3,D2	Let next 3 bits slip by.
	addx.w	D2,D2	First bit in from behind, and first
	move.b	D2,D3	of next RGB-component out to X-bit.
	rol.b	#4,D2
	or.b	D2,D3	To make full use of all 8 bits, copy
	move.b	D3,(A1)+	high nybble to low nybble.
	dbf	D1,ste_tru2	Next RGB component
ste_tru3	dbf	D0,ste_tru1	Next colour
	movem.l	(SP)+,D0-D3/A0-A1
	rts
*ðððððððððððððððððððððððððð
VDI_TRU	movem.l	D0-D1/A0-A1,-(SP)
	mulu	#3,D0	3 RGB components/colour
	bra.s	vdi_tru2

vdi_tru1	move.w	(A0)+,D1
	ext.l	D1
	lsl.l	#8,D1	Multiply by 256
	divu	#1001,D1
	move.b	D1,(A1)+
vdi_tru2	dbf	D0,vdi_tru1	Next RGB component

	movem.l	(SP)+,D0-D1/A0-A1
	rts
*ðððððððððððððððððððððððððð
STE_VDI	movem.l	D0-D1/A0-A1,-(SP)
	moveq	#3,D1
	mulu	D0,D1
	adda.w	D1,A1
	bsr.s	STE_TRU
	lea	(A1),A0
	suba.l	D1,A1
	bra.s	tru_vdi1
*==========================
TRU_VDI	movem.l	D0-D1/A0-A1,-(SP)
tru_vdi1	mulu	#3,D0
	bra.s	tru_vdi3

tru_vdi2	moveq	#0,D1
	move.b	(A0)+,D1
	mulu	#1000,D1
	divu	#255,D1
	move.w	D1,(A1)+
tru_vdi3	dbf	D0,tru_vdi2	Next RGB component

	movem.l	(SP)+,D0-D1/A0-A1
	rts
*ðððððððððððððððððððððððððð
VDI_STE	movem.l	D0-D1/A0-A2,-(SP)
	subq.l	#4,SP
	move.w	D0,D1	D1.W: Number of colours
	move.l	A1,A2	A2 -> Destination
	bra.s	vdi_ste2
vdi_ste1	lea	(SP),A1	Set destination to stack
	moveq	#1,D0	One colour
	bsr.s	VDI_TRU
	lea	6(A0),A1	Save address to next source colour
	lea	(SP),A0	Set source to stack
	bsr.s	tru_ste3	Convert one colour to STE
	move.w	D0,(A2)+
	lea	(A1),A0	Restore source address
vdi_ste2	dbf	D1,vdi_ste1
	addq.l	#4,SP
	movem.l	(SP)+,D0-D1/A0-A2
	rts
*ðððððððððððððððððððððððððð
TRU_STE	movem.l	D0-D1/A0-A1,-(SP)
	move.l	D0,D1
	bra.s	tru_ste2
tru_ste1	bsr.s	tru_ste3	Convert one colour to STE
	addq.l	#3,A0
	move.w	D0,(A1)+	STE colour
tru_ste2	dbf	D1,tru_ste1
	movem.l	(SP)+,D0-D1/A0-A1
	rts
*-------------------------- Convert 1 colour to STE. Also called by VDI_STE
* and SETTRU.   IN:  A0->source 24 bit colour, OUT: D0.W: STE colour
tru_ste3	addq.l	#3,A0	Do components backwards: B,G,R
	move.l	D1,-(SP)	Save D1
	moveq	#2,D1
tru_ste4	move.b	-(A0),D0
	lsr.b	#5,D0	Ignore 4 last bits. Next one to X
	ror.w	#3,D0
	roxr.w	#1,D0	X-bit first
	dbf	D1,tru_ste4	Next RGB component
	move.l	(SP)+,D1	Restore D1
	lsr.w	#4,D0
	rts


***************************
*	SETTRU		Sets palette given in 24-bit format
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A0 -> source,
*     D0 MSW: Hardware start colour,
*        LSW: Number of colours
*~~~~~~~~~~~~~~~~~~~~~~~~~~
SETTRU	movem.l	D0-D6/A0-A3,-(SP)
	lea	(A0),A3	A3 -> Source Palette
	move.l	D0,D4
	swap	D4
	move.w	D4,D6	D6.W: Start colour
	moveq	#$F,D3
	and.w	D4,D3	D3.W: Start colour in bank
	lsr.w	#4,D4	D4.W: Start colour bank (TT)
	move.w	D0,D5	D5.W: Number of colours
	bsr	TT_VDO?	Video hardware?
	bhi.s	settru7	Falcon
	beq.s	settru1	TT
	clr.w	D4	ST(E)
	subq.w	#1,D5
	and.w	#$F,D5
	addq.w	#1,D5
	move.w	#4,-(SP)	GETREZ
	trap	#14
	addq.l	#2,SP
	subq.w	#2,D0
	bne.s	settru4
	move.b	(A3)+,D0	Give ST in mono rez
	or.b	(A3)+,D0	special treatment
*	or.b	(A3)+,D0
	smi	D0
	clr.w	D5
	bra.s	settru3

settru1	bsr.s	settru6
	move.w	D0,D6	Save old TT colour bank
	bra.s	settru4
*÷ ST/TT ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
settru2	lea	(A3),A0	A0 is input for tru_ste3
	addq.l	#3,A3
	bsr.s	tru_ste3	Do one colour
settru3	move.w	D0,-(SP)	Colour
	move.w	D3,-(SP)	Colour number
	move.w	#7,-(SP)	SETCOLOR
	trap	#14
	addq.l	#6,SP
	addq.w	#1,D3
settru4	cmp.w	#15,D3
	dbhi	D5,settru2	Next colour
	bls.s	settru5
	clr.w	D3
	bsr.s	settru6
	bra.s	settru4

settru5	move.w	D6,D4	Restore old TT colour bank
	bsr.s	settru6
	bra.s    settru10	EXIT

settru6	move.w	D4,-(SP)
	move.w	#82,-(SP)	ESETBANK (TT)
	trap	#14
	addq.l	#4,SP
	addq.w	#1,D4
	rts

*÷ FALCON ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
settru7	move.l	SP,D3	Save SP
	pea	1024.W
	move.w	#72,-(SP)	MALLOC
	trap	#1
	move.l	D0,D4	D4 -> Memory block
	beq.s	settru9

	move.l	D0,A0
	move.w	D5,D1	Number of colours
	subq.w	#1,D1
	and.w	#$FF,D1
settru8	clr.b	(A0)+	dummy
	move.b	(A3)+,(A0)+	R
	move.b	(A3)+,(A0)+	G
	move.b	(A3)+,(A0)+	B
	dbf	D1,settru8

	move.l	D4,(SP)
	move.w	D5,-(SP)	Number of colours
	move.w	D6,-(SP)	Start colour
	move.w	#93,-(SP)	VSETRGB (Falcon)
	trap	#14
	move.w	#37,(SP)	VSYNC
	trap	#14
	move.l	D4,(SP)
	move.w	#73,-(SP)	MFREE
	trap	#1

settru9	move.l	D3,SP	Restore SP
settru10	movem.l	(SP)+,D0-D6/A0-A3
	rts

*settru7	bsr.s	.supexec
*	lea	$FF9C00,A0	A0 -> Falcon hardware palette
*	lea	$400(A0),A1	Take some precautions against
*	and.w	#$FF,D6	nasty crashes
*	add.w	D6,D6
*	add.w	D6,D6
*	add.w	D6,A0
*	bra.s	.setcctr
*.nxtcolr	move.b	(A3)+,(A0)+	R
*	move.b	(A3)+,(A0)+	G
*	clr.b	(A0)+	dummy
*	move.b	(A3)+,(A0)+	B
*.setcctr	cmpa.l	A1,A0	End of hardware palette?
*	dbcc	D5,.nxtcolr
*	rts
*.supexec	move.w	#38,-(SP)	SUPEXEC
*	trap	#14
*	addq.l	#6,SP
*
*settru10	movem.l	(SP)+,D0-D6/A0-A3
*	rts


***************************
* IMGCALC LBMCALC DEGCALC NEOCALC	Calculate space needed for unpacking
*~~~~~~~~~~~~~~~~~~~~~~~~~~  (IMGCALC also converts PC IMG header to ST)
* IMGUNP  LBMUNP  DEGUNP  NEOUNP	Unpack image file
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A3 -> Loaded image file
*     D3 MSW: Flag for VRT_CPYFM use
*        LSW: Number of planes on screen. Absent planes will be filled in.
*     A4 -> Extended MFDB
*     D4: Zero or address to pre-allocated palette space
* OUT (CALC):
*     D0.L: Required size of block to be reserved for 'UNP' or -1 for error
* OUT (UNP):
*     D0.L: Size of image data or -1 for major error
*     D1: -1 for minor error, 0 for OK

*~~~~~~~~~~~~~~~~~~~~~~~~~~
IMGCALC	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	imgcal
	movem.l	(SP)+,D1-D7/A0-A6
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
* Sub-routine to load registers with parameters read or calculated from
* image file header. (In addition converts PC header to ST format.)
* A4 untouched.  See ___unp for further info.  Also called by IMGUNP.
imgcal	tst.b	4(A3)	PC format?
	beq.s	imgcal3	NO Motorola
* - - - - - - - - - - - - -	YES: Transform header words from Intel
	lea	(A3),A0
	moveq	#7,D1
imgcal1	move.w	(A0),D0
	ror.w	#8,D0
	move.w	D0,(A0)+
	dbf	D1,imgcal1

	moveq	#-13,D1
	add.w	2(A3),D1
	bmi.s	imgcal3
	addq.l	#4,A0	Skip possible 'XIMG' byte string
imgcal2	move.w	(A0),D0
	ror.w	#8,D0
	move.w	D0,(A0)+
	dbf	D1,imgcal2
* - - - - - - - - - - - - -
imgcal3	lea	2(A3),A0
	adda.w	(A0),A3
	adda.w	(A0)+,A3	A3 -> Image data

	move.w	(A0)+,D6	D6: Number of planes
	ble.s	imgcal4
	move.w	(A0)+,D7	D7: Pattern length
	ble.s	imgcal4
	move.l	(A0)+,D1	D1: Pixel dimensions
	move.l	(A0)+,D5	D5 LSW: Number of lines
	bra	___unp	   MSW: Width in pixels
* After this A0 points to possible source palette

imgcal4	moveq	#-1,D0	error
	rts
*==========================
IMGUNP	movem.l	D2-D7/A0-A6,-(SP)
	bsr.s	imgcal  Read header
	pea	-1.W	Minor error: Initiate to yes
	bmi	imgunp27	error => exit
	move.l	D3,-(SP)	Save picture size in bytes
* - - - - - - - - - - - - - Do palette
	move.l	D1,D0	Number of colours
	beq.s	imgunp7	No palette
	cmpi.l	#'XIMG',(A0)+
	bne.s	imgunp3
	tst.w	(A0)+
	bne.s	imgunp4
	bsr	VDI_TRU
	bra.s	imgunp7

imgunp3	subq.l	#4,A0
	cmpi.w	#$80,(A0)+	HyperPaint?
	bne.s	imgunp4	NO
	add.w	D1,D1	YES, apparently
	add.l	A0,D1
	cmp.l	A3,D1	'Palette' ranges into data?
	bls.s	imgunp5	No, palette OK!

imgunp4	lea	imgunp28(PC),A0	No recognizable palette: Use the
	subq.w	#1,D0	default one instead
	andi.w	#$F,D0
	addq.w	#1,D0	Max 16 colours
	move.w	D0,D1
	add.w	D1,D1
	clr.w	-2(A0,D1.W)	Last colour = black

imgunp5	bsr	STE_TRU	Convert STE palette to 24 bit

* - - - - - - - - - - - - - Do the image data

imgunp7	subq.l	#4,SP	Reserve room for A3 save
	lea	(SP),A1	Save stack pointer
	moveq	#1,D0
	and.w	D7,D0
	add.w	D7,D0	Pattern length evened up
	suba.w	D0,SP	Reserve!  SP-> Pattern buffer

	subq.w	#1,D7	D7: Bytes/pattern - 1
	subq.w	#1,D6	D6: Number of planes - 1
	add.w	D2,D2
	sub.w	D2,A6	A6: Pic Size - (#b/line evened up)

	lea	(A4),A2
	adda.w	D4,A2	A2: End of line in destination
	move.w	D6,D2	D2: Plane counter

imgunp8	moveq	#0,D3	Read first command of line
	moveq	#0,D1
imgunp9	move.b	(A3)+,D1	1st command byte
	bne.s	imgunp12	0
	move.b	(A3)+,D1	2nd command byte
	bne.s	imgunp16	0 0
	move.b	(A3)+,D1	3rd ditto
	not.b	D1	should be $FF
	bne.s	imgunp9
	move.b	(A3)+,D3	D3: Number of line repeats
	subq.b	#1,D3
	bcs.s	imgunp9	If D3 was 0, skip command
	move.l	A3,(A1)	Save source pointer A3

imgunp10	movea.l	(A1),A3	Next line repeat: Restore A3
imgunp11	moveq	#0,D1	Read command within line
	move.b	(A3)+,D1	1st command byte
	beq.s	imgunp15	Pattern
imgunp12	bgt.s	imgunp22	Solid run with 0
	andi.w	#$7F,D1
	bne.s	imgunp21	Solid run with $FF

	move.b	(A3)+,D1	Copy bytes:  D1 = Number of bytes
	bra.s	imgunp14
imgunp13	move.b	(A3)+,(A4)+
imgunp14	dbf	D1,imgunp13
	bra.s	imgunp25

imgunp15	move.b	(A3)+,D1	Repeat pattern:  D1 = times
imgunp16	lea	(SP),A0
	move.w	D7,D0	Pattern length - 1
imgunp17	move.b	(A3)+,(A0)+	Read pattern
	dbf	D0,imgunp17
	bra.s	imgunp20
imgunp18	lea	(SP),A0
	move.w	D7,D0	Pattern length - 1
imgunp19	move.b	(A0)+,(A4)+	Write pattern
	dbf	D0,imgunp19
imgunp20	dbf	D1,imgunp18
	bra.s	imgunp25

imgunp21	moveq	#-1,D0	Solid run with $FF
	bra.s	imgunp23
imgunp22	moveq	#0,D0	Solid run with 0
imgunp23	subq.w	#1,D1
imgunp24	move.b	D0,(A4)+
	dbf	D1,imgunp24

imgunp25	cmpa.l	A2,A4	Line end reached?
	bcs.s	imgunp11	No => continue with next command
	bhi.s	imgunp26	ERROR (Command broke line/plane limit)
	adda.l	A5,A2	A2-> end of same line in next plane
	lea	(A2),A4
	suba.w	D4,A4	A4 -> its beginning
	dbf	D2,imgunp11	Do same line in next plane
	suba.l	A6,A4	Back to plane 0 for new line
	lea	(A4),A2
	adda.w	D4,A2
	move.w	D6,D2
	subq.w	#1,D5	Decrease line counter
	dbeq	D3,imgunp10	Next line repeat
	bne	imgunp8	Next line
	clr.l	8(A1)	Done without error
imgunp26	lea	4(A1),SP
	move.l	(SP)+,D0	Return image length
imgunp27	movem.l	(SP)+,D1-D7/A0-A6
	bra	plnfill0

*--------------------------
imgunp28	dc.w	$FFF,$F00,$0F0,$FF0,$00F,$F0F,$0FF,$555  default palette
	dc.w	$333,$F33,$3F3,$FF3,$33F,$F3F,$3FF,$000


*~~~~~~~~~~~~~~~~~~~~~~~~~~
* ___unp: branched to from IMGCALC, DEGCALC, LBMCALC etc.
*	calculates parameters and writes them in MFDB
* -------------------------
* IN:
*  D3 MSW: Flag for VRT_CPYFM use; LSW: Number of planes on screen
*  D4: Zero or address to pre-allocated space for palette
*  D5 MSW: Width in pixels, LSW: Number of lines
*  D6.W: Number of planes
*  A4 -> Area for unpacked image
*  A1 MSW: Pixel width, LSW: Pixel height
* OUT:Size of MFDB + extra block + palette
*  D0.L: Total picture size, incl. fill planes (& palette?), or -1 for error
*  D1.L: Number of colours,  or 0 if more than 8 planes
*  D2.W: Width in words
*  D3.L: = D0 except any palette
*  D4.W: Width in bytes
*  A1-> Area for palette
*  A2-> Palette pointer in MFDB
*  A4-> Area for image data
*  A5: Size in bytes of one plane
*  A6: Total picture size, not incl. fill planes
* Remaining register (ie D5,D6,D7, A0,A3) untouched

___unp	move.l	D4,32(A4)
	lea	(A4),A2
	move.l	(A2)+,A4	A4 -> destination data

	move.l	D5,(A2)+	Width in pixels, Height

	move.l	D5,D4
	swap	D4
	addq.w	#7,D4
	lsr.w	#3,D4	D4: Width in bytes

	move.w	D4,D0
	addq.w	#1,D0
	lsr.w	#1,D0
	move.w	D0,D2	D2: Width in words
	move.w	D2,(A2)+	Width in words
	move.w	#1,(A2)+	Flag for device independent format
	add.w	D0,D0
	mulu	D5,D0
	beq.s	___unp8	error
	movea.l	D0,A5	A5: Size in bytes of one plane

	move.w	D6,D0	# of actual planes
	ble.s	___unp8	error
	subq.w	#1,D0
	bne.s	___unp2
	tst.l	D3	If # of actual planes=1
	bpl.s	___unp2	and VRT_CPYFM is to be used
___unp1	move.w	D6,D3	then # of used planes = 1
___unp2	tst.w	D3	(If # of planes to use ó 0 then
	ble.s	___unp1	set it = planes in image)
	move.w	D3,(A2)+	# of used planes
	clr.w	(A2)+
	clr.l	(A2)+
	move.w	D6,(A2)+	Actual number of planes in file
	move.l	D1,(A2)+	Pixel dimensions
	clr.l	(A2)+	(Reserved word); Start colour
	suba.l	A6,A6
___unp3	adda.l	A5,A6	Total planes
	dbf	D0,___unp3	

	move.l	A6,D0	A6: Total size of actual planes
	sub.w	D6,D3
	bls.s	___unp5
	subq.w	#1,D3
___unp4	add.l	A5,D0	Add size of fill planes
	dbf	D3,___unp4	D0: Total size incl. fill planes

___unp5	moveq	#0,D1
	cmpi.w	#8,D6
	bhi.s	___unp6	direct colour RGB (no palette)
	moveq	#1,D1
	lsl.w	D6,D1	D1: Number of colours
___unp6	move.w	D1,(A2)+	Number of colours

	move.l	D0,D3
	move.l	(A2),A1
	tst.l	(A2)
	bgt.s	___unp7
	lea	(A4),A1
	add.l	D0,A1	A1 -> Destination palette
	move.l	A1,(A2)
	moveq	#3,D0
	mulu	D1,D0	Add length of palette
	add.l	D3,D0	to length of image data
___unp7	rts

___unp8	moveq	#-1,D0
	rts
*ðððððððððððððððððððððððððð
NEOCALC	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	neocal
	bra.s	degcalc1
*==========================
DEGCALC	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	degcal
degcalc1	movem.l	(SP)+,D1-D7/A0-A6
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
* Load registers with parameters read/calculated from file header. A4 un-
* touched. ___unp for further info. Also called by DEGUNP/NEOCALC/NEOUNP.
neocal	move.l	(A3)+,D7
	bra.s	degcal1
degcal	move.w	(A3)+,D7	M.S.Bit of D7.W: Compression flag
degcal1	moveq	#7,D0
	and.w	D7,D0	D0.W: Resolution
	move.b	degcal3(PC,D0.W),D0
	bmi.s	degcal2	error (unknown resolution)
	lea	degcal4(PC),A0
	adda.w	D0,A0
	move.w	(A0)+,D6	D6.W: # of planes
	move.l	(A0)+,D5	D5.L: image dimensions
	move.l	(A0)+,D1	D1.L: pixel dimensions
	lea	(A3),A0	A0 -> palette
	bra	___unp

degcal2	moveq	#-1,D0	error
	rts
* ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  Data for standard ST/TT resolutions
degcal3	dc.b	0,10,20,-1,30,-1,40,-1 (or replace last -1 with 50)

degcal4	dc.w	4,320,200,338,372	planes,imagew,imageh,pixw,pixh
	dc.w	2,640,200,169,372
	dc.w	1,640,400,372,372
	dc.w	4,640,480,372,372
	dc.w	1,1280,960,372,372
*	dc.w	8,320,480,744,372	TT low
* To use last line for TT low you would have to change routine below for
* uncompressed image. (And TT low rez screen may be BYTE interleaved ?)

* Pixel dimensions (for the ST) as given by the VDI (supposedly in microns)

*==========================
NEOUNP	movem.l	D2-D7/A0-A6,-(SP)
	bsr.s	neocal  Read header
	lea	124(A3),A3	A3->image data
	bra.s	degunp1
*==========================
DEGUNP	movem.l	D2-D7/A0-A6,-(SP)
	bsr.s	degcal  Read header
	lea	32(A3),A3	A3->image data
degunp1	pea	-1.W	initiate to minor error
	bmi.s	degunp12	error => exit
	move.l	D3,-(SP)	Save picture size
* - - - - - - - - - - - - - Do palette
	move.w	D1,D0	Number of colours
	bsr	STE_TRU
* - - - - - - - - - - - - - Do the image data
degunp3	subq.w	#1,D6	D6: Number of planes - 1
	tst.w	D7	Compressed?
	bpl.s	degunp13
*-------------------------- COMPRESSED DEGAS
	subq.w	#1,D5	D5: Number of lines - 1
	add.w	D2,D2
	sub.w	D2,A6	A6: Pic Size - (#B/line evened up)

degunp4	lea	(A4),A2
	adda.w	D4,A2	A2-> End of line in destination
	move.w	D6,D2	D2: Plane counter

degunp5	moveq	#0,D1
degunp6	move.b	(A3)+,D1	1st command byte
	bpl.s	degunp8
	neg.b	D1
	bmi.s	degunp6	$80 not used
	move.b	(A3)+,D0
degunp7	move.b	D0,(A4)+
	dbf	D1,degunp7
	bra.s	degunp9

degunp8	move.b	(A3)+,(A4)+
	dbf	D1,degunp8

degunp9	cmpa.l	A2,A4	Line end reached?
	bcs.s	degunp5	No => next command
	bhi.s	degunp11	Passed => EXIT
	adda.l	A5,A2	A2-> end of same line in next plane
	lea	(A2),A4
	suba.w	D4,A4	A4 -> its beginning
	dbf	D2,degunp5	Do same line in next plane
	suba.l	A6,A4	Back to plane 0 for new line
	dbf	D5,degunp4	Next line
degunp10	clr.l	4(SP)	No error
degunp11	move.l	(SP)+,D0	Return image length
degunp12	movem.l	(SP)+,D1-D7/A0-A6
	bra	plnfill0
*-------------------------- UNCOMPRESSED DEGAS/NEO
* As written can only handle up to 4 planes (i.e. not TT low)
degunp13	mulu	D5,D2	words per plane
	lea	degunp16(PC),A6
	sub.w	D6,A6
	sub.w	D6,A6
	bra.s	degunp15
degunp14	adda.l	A5,A4
degunp15	dbf	D6,degunp14
	lea	(A4),A2
	suba.l	A5,A2
	lea	(A2),A1
	suba.l	A5,A1
	lea	(A1),A0
	suba.l	A5,A0
	jmp	(A6)

	move.w	(A3)+,(A0)+
	move.w	(A3)+,(A1)+
	move.w	(A3)+,(A2)+
degunp16	move.w	(A3)+,(A4)+
	subq.l	#1,D2
	beq.s	degunp10
	jmp	(A6)

*ðððððððððððððððððððððððððð
LBMCALC	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	lbmcal
	movem.l	(SP)+,D1-D7/A0-A6
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
* Load registers with parameters read/calculated from image file header.
* A4 untouched. See ___unp for further info. Also called by LBMUNP.
lbmcal	cmpi.l	#'FORM',(A3)
	bne.s	lbmcal1
	cmpi.l	#'ILBM',8(A3)
	bne.s	lbmcal1
	move.l	#'BMHD',D0
	bsr.s	GETCHNK
	ble.s	lbmcal1

	move.l	(A0)+,D5
	moveq	#0,D6
	addq.l	#4,A0
	move.b	(A0),D6
	move.l	(A0)+,D7
	moveq	#0,D1
	addq.l	#2,A0
	move.b	(A0)+,D1
	swap	D1
	move.b	(A0)+,D1
	bra	___unp

lbmcal1	moveq	#-1,D0	error
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~
*	GETCHNK		Searches IFF FORM for chunk
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN:  A3 -> FORM chunk to search,  D0: ID to look for
* OUT: A0 -> Found chunk data,  D0: Length  or -1 at error
*~~~~~~~~~~~~~~~~~~~~~~~~~~
GETCHNK	movem.l	D1/A1,-(SP)
	lea	12(A3),A0	A0 -> start of FORM chunk data
	lea	4(A3),A1
	adda.l	(A1)+,A1	A1 -> end of it
getchnk1	cmp.l	(A0)+,D0
	movem.l	(A0)+,D1
	beq.s	getchnk2	found
	addq.l	#1,D1
	andi.b	#$FE,D1
	adda.l	D1,A0
	cmpa.l	A1,A0
	bcs.s	getchnk1	next chunk
	moveq	#-1,D1
getchnk2	move.l	D1,D0
	movem.l	(SP)+,D1/A1
	rts

*==========================
LBMUNP	movem.l	D2-D7/A0-A6,-(SP)
	clr.l	-(SP)	Initiate to NO minor error
	bsr.s	lbmcal   Read header
	bmi	lbmunp21	error => exit
	move.l	D3,-(SP)	Save picture size
* - - - - - - - - - - - - - Do palette
	move.l	#'CMAP',D0
	bsr.s	GETCHNK
	ble	lbmunp23	error
	move.w	D1,D0	Number of colours
	subq.w	#1,D0
lbmunp2	move.b	(A0)+,(A1)+	24 bit palette
	move.b	(A0)+,(A1)+
	move.b	(A0)+,(A1)+
	dbf	D0,lbmunp2
* - - - - - - - - - - - - - Do the image data
lbmunp4	move.l	#'BODY',D0
	bsr.s	GETCHNK	A0 -> source image data
	ble	lbmunp23	error

	subq.w	#1,D6	D6: Number of planes - 1
	subq.w	#1,D5	D5: Number of lines - 1
	sub.w	D2,A6
	sub.w	D2,A6	A6: Pic Size - (#B/line evened up)

	lsr.w	#8,D7
	move.w	D7,D0
	swap	D7
	subq.b	#1,D7	D7.B: 0 if there is mask
	subq.b	#1,D0	Compression type?
	beq.s	lbmunp10	1 : Line Byterun
	bhi	lbmunp24	2+: Vertical?
*--------------------------	0 : UNCOMPRESSED IFF ILBM
lbmunp5	sub.w	D2,A5	
	sub.w	D2,A5	Bytes per plane - 1 row
	subq.w	#1,D2	words per row -1
lbmunp6	move.w	D6,D1
lbmunp7	move.w	D2,D0
lbmunp8	move.w	(A0)+,(A4)+
	dbf	D0,lbmunp8	next word
	adda.l	A5,A4	Same line, new plane
	dbf	D1,lbmunp7	next plane
	tst.b	D7
	bne.s	lbmunp9	No mask
	adda.w	D4,A0
lbmunp9	suba.l	A6,A4	Back to plane 0 for new line
	dbf	D5,lbmunp6	next line
	bra.s	lbmunp20
*-------------------------- PACKBITS COMPRESSED
lbmunp10	lea	(A4),A2
	adda.w	D4,A2
	move.w	D6,D2

lbmunp11	moveq	#0,D1
lbmunp12	move.b	(A0)+,D1	Command byte
	bpl.s	lbmunp14
	neg.b	D1
	bmi.s	lbmunp12	$80 not used
	move.b	(A0)+,D0
lbmunp13	move.b	D0,(A4)+
	dbf	D1,lbmunp13
	bra.s	lbmunp15

lbmunp14	move.b	(A0)+,(A4)+
	dbf	D1,lbmunp14

lbmunp15	cmpa.l	A2,A4	Line end reached?
	bcs.s	lbmunp11	No => continue with next command
	bhi.s	lbmunp22	Passed => EXIT
	adda.l	A5,A2	A2-> end of same line in next plane
	lea	(A2),A4
	suba.w	D4,A4	A4 -> its beginning
	dbf	D2,lbmunp11	Do same line in next plane
* - - - - - - - - - - - - - Skip mask
	tst.b	D7
	bne.s	lbmunp19	No mask
	move.w	D4,D2	Bytes of one line
	moveq	#0,D1
lbmunp16	move.b	(A0)+,D1	Command byte
	bpl.s	lbmunp17
	neg.b	D1
	bmi.s	lbmunp16	$80 not used
	bra.s	lbmunp18
lbmunp17	add.w	D1,A0	Instead of copy: Add D1+1 to A0
lbmunp18	addq.l	#1,A0	Instead of repeat: Add 1 to A0
	addq.w	#1,D1
	sub.w	D1,D2	Subtract |D1+1| from bytes on line
	bhi.s	lbmunp16
	bcs.s	lbmunp22	Line end passed => EXIT
* - - - - - - - - - - - - -
lbmunp19	suba.l	A6,A4	Back to plane 0 for new line
	dbf	D5,lbmunp10	Next line

lbmunp20	move.l	(SP)+,D0	Return image length
lbmunp21	movem.l	(SP)+,D1-D7/A0-A6
	bra	plnfill0

lbmunp22	moveq	#-1,D0
	move.l	D0,4(SP)	'Minor error'
	bra.s	lbmunp20

lbmunp23	addq.l	#4,SP	Skip saved image size
	moveq	#-1,D0	Major error
	bra.s	lbmunp21

*-------------------------- VERTICAL WORD COMPRESSED
lbmunp24	subq.b	#1,D0	Compression type 2?
	bne.s	lbmunp23	No, "error" (higher than 2)
	lea	-2(A5),A6	A6: Plane size less one word
	move.w	D5,A3	A3: Line counter save
	move.w	D2,D4
	add.w	D4,D4	D4: # of bytes/line evened up

lbmunp25	cmpi.l	#'VDAT',(A0)+	New plane
	bne.s	lbmunp22	error
	move.l	(A0)+,D7
	add.l	A0,D7	D7 -> End of VDAT
	lea	(A0),A1
	adda.w	(A1)+,A0	A1 -> control bytes
	movea.l	A4,A2	A0 -> word data
	adda.l	A5,A2	A2 -> Next destination plane
	move.w	D2,D3	D3: Word column counter

lbmunp26	moveq	#0,D1	Get command byte
	move.b	(A1)+,D1
	bmi.s	lbmunp30
	beq.s	lbmunp29

	subq.w	#1,D1
	bne.s	lbmunp27
	move.w	(A0)+,D1
	subq.w	#1,D1
lbmunp27	move.w	(A0)+,D0
lbmunp28	move.w	D0,(A4)	Repeat word
	adda.w	D4,A4
	subq.w	#1,D5
	dbcs	D1,lbmunp28
	bcc.s	lbmunp34
	suba.l	A6,A4	Next word column
	move.w	A3,D5
	subq.w	#1,D3
	dbeq	D1,lbmunp28
	bra.s	lbmunp33

lbmunp29	move.w	(A0)+,D1
	bra.s	lbmunp31
lbmunp30	neg.b	D1
lbmunp31	subq.w	#1,D1
lbmunp32	move.w	(A0)+,(A4)	Copy word
	adda.w	D4,A4
	subq.w	#1,D5
	dbcs	D1,lbmunp32
	bcc.s	lbmunp34
	suba.l	A6,A4	Next word column
	move.w	A3,D5
	subq.w	#1,D3
	dbeq	D1,lbmunp32
lbmunp33	beq.s	lbmunp35

lbmunp34	cmpa.l	D7,A0
	bcs.s	lbmunp26
	bra.s	lbmunp36
lbmunp35	tst.w	D1
	beq.s	lbmunp37
lbmunp36	st	4(SP)
lbmunp37	movea.l	D7,A0
	and.w	#1,D7
	adda.w	D7,A0	A0 -> Next VDAT
	lea	(A2),A4
	dbf	D6,lbmunp25	Next plane
	bra	lbmunp20


***************************
*	PLNFILL		Fills any absent planes in image
*~~~~~~~~~~~~~~~~~~~~~~~~~~	(compared to screen)
* IN: A4-> Extended MFDB for unpacked image, D1: Start colour
* If Negative flag set - skip. Otherwise do, and set to Positive.

PLNFILL	move.w	D1,28(A4)
plnfill0	bmi.s	plnfill8
	movem.l	D0-D4/A0,-(SP)
	move.w	28(A4),D4	Start colour

	movem.w	6(A4),D1-D2
	mulu	D1,D2	D2: size of 1 plane in words

	move.w	20(A4),D0	D0: Actual number of planes
	move.w	12(A4),D3	 Used number of planes
	sub.w	D0,D3	D3: Number of fill planes
	ble.s	plnfill7

	move.l	D2,D1
	add.l	D1,D1	D1: ditto in bytes
	movea.l	(A4),A0
	bra.s	plnfill2
plnfill1	adda.l	D1,A0	Skip actual planes
	lsr.w	#1,D4
plnfill2	dbf	D0,plnfill1
	bra.s	plnfill6

plnfill3	swap	D1
plnfill4	move.w	D0,(A0)+
plnfill5	dbf	D1,plnfill4	next word
	swap	D1
	dbf	D1,plnfill3	next 64 K words
plnfill6	lsr.w	#1,D4	Shift last bit of colour number out
	scs	D0	and extend it to word
	ext.w	D0
	move.l	D2,D1	D1: size of 1 plane in words
	dbf	D3,plnfill5	next plane

plnfill7	tst.l	D2	Set condition flags
	movem.l	(SP)+,D0-D4/A0
plnfill8	rts


***************************
*	PUTFM		Non-VDI copy to screen
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A4 -> MFDB
*     A3 -> 8 Words: source X1,Y1,X2,Y2, dest X1,Y1,X2,Y2 (as VDI)
*     D0: Start colour (when # of image planes < # of screen planes
*	Only M.S.Bits, in excess of # of image planes, noted)
*~~~~~~~~~~~~~~~~~~~~~~~~~~

PUTFM	movem.l	D0-D7/A0-A6,-(SP)
	movem.l	(A3),D3-D6
	moveq	#0,D7	Flag for PUT form

	move.l	#$40FFFF,-(SP)	BLITMODE, don't change
	trap	#14
	addq.l	#4,SP
	and.b	#1,D0
	bne	putfm30	Use blitter

	bsr	putfm46	Calculate parameters
	beq	putfm29	error: exit
	addq.l	#2,A5
	tst.w	D1
	bne.s	putfm10
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ FAST COPY WITH NO SHIFT
putfm1	move.l	D0,-(SP)	M.S.Bit: Odd word flag
	movem.l	A4,-(SP)	MSW: # of extra screen planes, LSW: Colour
	lea	putfm7(PC),A4
	bpl.s	putfm2
	lea	putfm6-putfm7(A4),A4

putfm2	movem.l	D6-D7/A5-A6,-(SP)	Next plane

putfm3	move.w	(A5)+,D0	Next line
	and.w	D2,D0
	and.w	D4,(A6)
	or.w	D0,(A6)
	adda.w	A3,A6
	move.w	(SP),D6
	bra.s	putfm5

putfm4	move.w	(A5)+,(A6)
	adda.w	A3,A6
	move.w	(A5)+,(A6)
	adda.w	A3,A6
putfm5	dbf	D6,putfm4
	jmp	(A4)

putfm6	move.l	(A5)+,(A6)
	adda.w	A3,A6

putfm7	move.w	(A5)+,D0
	and.w	D3,D0
	and.w	D5,(A6)
	or.w	D0,(A6)

putfm8	adda.l	A1,A5
	adda.l	A2,A6
	dbf	D7,putfm3

	movem.l	(SP)+,D6-D7/A5-A6
	adda.l	A0,A5
	addq.l	#2,A6
putfm9	dbf	D6,putfm2

	move.w	(SP),D6	# of extra planes
	ble	putfm28
	suba.l	A0,A5
	suba.l	A0,A0
	move.w	A0,(SP)	Clear extra planes
	move.w	2(SP),D0	M.S.Bits of start colour
	bmi.s	putfm9	Extra planes = last plane repeated
	bra.s	putfm19	Extra planes filled with D0 bits

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ SHIFTED COPY
putfm10	move.l	D0,-(SP)	M.S.Bit: Odd word flag
	movem.l	A4,-(SP)	MSW: # of extra screen planes, LSW: Colour
	lea	putfm16(PC),A4
	bpl.s	putfm11
	lea	putfm15-putfm16(A4),A4

putfm11	movem.l	D6-D7/A0/A5-A6,-(SP)	Next plane

putfm12	lea	-2(A5),A0	Next line
	move.l	(A0)+,D0
	lsr.l	D1,D0
	and.w	D2,D0
	and.w	D4,(A6)
	or.w	D0,(A6)
	adda.w	A3,A6
	move.w	(SP),D6
	bra.s	putfm14

putfm13	move.l	(A5)+,D0
	lsr.l	D1,D0
	move.w	D0,(A6)
	adda.w	A3,A6
	move.l	(A0)+,D0
	lsr.l	D1,D0
	move.w	D0,(A6)
	adda.w	A3,A6
putfm14	dbf	D6,putfm13
	jmp	(A4)

putfm15	move.l	(A5),D0
	lea	(A0),A5
	lsr.l	D1,D0
	move.w	D0,(A6)
	adda.w	A3,A6

putfm16	move.l	(A5)+,D0
	lsr.l	D1,D0
	and.w	D3,D0
	and.w	D5,(A6)
	or.w	D0,(A6)

putfm17	adda.l	A1,A5
	adda.l	A2,A6
	dbf	D7,putfm12

	movem.l	(SP)+,D6-D7/A0/A5-A6
	adda.l	A0,A5
	addq.l	#2,A6
putfm18	dbf	D6,putfm11

	move.w	(SP),D6	# of extra planes
	ble.s	putfm28
	suba.l	A0,A5
	suba.l	A0,A0
	move.w	A0,(SP)	Clear extra planes
	move.w	2(SP),D0	M.S.Bits of start colour
	bmi.s	putfm18	Repeat last plane for extra planes

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Fill extra planes according to D0 bits
putfm19	move.w	D6,(SP)	# of planes
	move.w	6(SP),A4	# of words to do per line
	subq.w	#2,A4
	movea.w	D7,A5

putfm20	move.w	A5,D7
	lsr.w	#1,D0
	scs	D1
	ext.w	D1
	beq.s	putfm24

putfm21	or.w	D2,(A6)
	adda.w	A3,A6
	move.w	A4,D6
	bra.s	putfm23
putfm22	move.w	D1,(A6)
	adda.w	A3,A6
putfm23	dbf	D6,putfm22
	or.w	D3,(A6)
	adda.l	A2,A6
	dbf	D7,putfm21
	bra.s	putfm27

putfm24	and.w	D4,(A6)
	adda.w	A3,A6
	move.w	A4,D6
	bra.s	putfm26
putfm25	move.w	D1,(A6)
	adda.w	A3,A6
putfm26	dbf	D6,putfm25
	and.w	D5,(A6)
	adda.l	A2,A6
	dbf	D7,putfm24

putfm27	addq.l	#2,A6
	subq.w	#1,(SP)
	bgt.s	putfm20
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
putfm28	addq	#8,SP
putfm29	movem.l	(SP)+,D0-D7/A0-A6
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Blitter version of PUTFM
putfm30	move.l	(SP),A6	Get start colour
	bsr.s	putfm38 (Push next address on stack and jump)
	move.l	A6,-(SP)	and save it
	bsr	putfm46
	beq.s	putfm37

	addq.w	#1,D7	Y count
	move.w	#$C080,D5

	tst.w	D1
	bne.s	putfm31
	clr.b	D5
	addq.l	#2,A5
	addq.w	#2,A1
putfm31	or.b	D1,D5
	cmp.w	#1,D0
	bne.s	putfm32
	addq.w	#2,A1
	adda.w	A3,A2
putfm32	swap	D3
	move.w	A3,D3
	swap	D0
	move.w	D7,D0
	move.l	A4,D4	MSW: Xtra planes LSW: Start colour
	lea	$FFFF8A20.W,A3
	move.w	#$203,D1

putfm33	bsr.s	putfm39
	adda.l	A0,A5
	addq.l	#2,A6
	dbf	D6,putfm33

	move.l	D4,D6
	swap	D6	Extra screen planes
	subq.w	#1,D6
	bmi.s	putfm37
	suba.l	A0,A5
	tst.w	D4
	bpl.s	putfm35
putfm34	bsr.s	putfm39
	addq.l	#2,A6
	dbf	D6,putfm34
	bra.s	putfm37
putfm35	lsr.w	#1,D4
	scs	D1
	ext.w	D1
	ext.l	D1
	lea	-32(A3),A4
	moveq	#7,D7
putfm36	move.l	D1,(A4)+
	dbf	D7,putfm36
	move.w	#$103,D1
	bsr.s	putfm39
	addq.l	#2,A6
	dbf	D6,putfm35

putfm37	addq.l	#4,SP
	rts
putfm38	move.w	#38,-(SP)	SUPEXEC
	trap	#14
	addq.l	#6,SP
	bra	putfm29

* ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷
putfm39	lea	(A3),A4	LOAD BLITTER:
	move.w	#2,(A4)+	Source X increment
	move.w	A1,(A4)+	Source Y increment
	move.l	A5,(A4)+	Source address
	move.w	D2,(A4)+	Endmask 1
	move.w	#-1,(A4)+	Endmask 2
	move.l	D3,(A4)+	Endmask 3, Dest X incr
	move.w	A2,(A4)+	Destination Y increment
	move.l	A6,(A4)+	Destination address
	move.l	D0,(A4)+	X count, Y count
	move.w	D1,(A4)+	HOP op, logical op
	move.w	D5,(A4)+	Busy+HOG, FXSR+Rshift
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Check rectangle dimension
putfm40	addq.w	#1,D6	X2/Y2 on screen
	cmp.w	A3,D6	Compare with W/H of screen
	bls.s	putfm41
	move.w	A3,D6
putfm41	tst.w	D5	X1/Y1 on screen
	bpl.s	putfm42
	clr.w	D5
putfm42	sub.w	D5,D6	X2/Y2 - X1/Y1 on screen = W/H

	addq.w	#1,D4	X2/Y2 in raster
	cmp.w	A1,D4	Compare with W/H of raster
	bls.s	putfm43
	move.w	A1,D4
putfm43	tst.w	D3	X1/Y1 in raster
	bpl.s	putfm44
	clr.w	D3
putfm44	sub.w	D3,D4	X2/Y2 - X1/Y1 in raster = W/H

	cmp.w	D4,D6
	bls.s	putfm45
	move.w	D4,D6	D6: Min. W/H
putfm45	rts

* ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷ ÷
putfm46	move.w	#3,-(SP)	LOGBASE
	trap	#14
	addq.l	#2,SP
	move.l	D0,A6	A6 -> Logical screen
	dc.w	$A000	Line-A Init
* (A0): #planes, -2(A0) Bytes per line, -4(A0) # of screen lines
* -12(A0): width in pixels

	movea.l	(A4)+,A5	Raster pointer

* - - - - - - - - - - - - -
	move.w	(A4)+,D0	W of raster
	move.w	(A4)+,A1	H of raster
	move.w	-4(A0),A3	H of screen
	bsr.s	putfm40
	move.w	D6,D7	Height
	beq	putfm53
	subq.w	#1,D7

	move.w	-2(A0),A2	Bytes per screen line
	move.w	A2,D2
	mulu	D5,D2	 times Y on screen
	add.l	D2,A6	 added to screen address

	move.w	(A4)+,D2	words per raster line
	tst.w	(A4)+
	beq	putfm53	Abort if MFDB 'device specific'
	add.w	D2,D2	D2: bytes per raster line
	move.w	D3,D1	D1: Y i raster
	mulu	D2,D1	Y-offs	(B/linje * Y in raster)
	add.l	D1,A5
* - - - - - - - - - - - - -
	swap	D3
	swap	D4
	swap	D5
	swap	D6
	exg	D0,A1	W of raster in A1
	move.w	-12(A0),A3	W of screen
	bsr.s	putfm40

	move.w	D5,D1	X on screen - X in raster
	sub.w	D3,D1	D1: X of raster rel. to screen

	asr.w	#4,D3	X in raster in words, truncated
	add.w	D3,D3	X in bytes, rounded down to word
	adda.w	D3,A5

	move.w	D5,D4
	lsr.w	#4,D4	X on screen in words, truncated
	add.w	D4,D4	X in bytes, rounded down to word

	tst.l	D7
	bpl.s	putfm47
	neg.w	D1	For GETFM (from screen to raster)
	move.w	D3,D5	 make D1 and D5 raster relative.

putfm47	move.w	(A0),D3	D3: nplanes
	mulu	D3,D4
	adda.w	D4,A6	A6 -> start address on screen

	moveq	#15,D4
	add.w	D4,D6	Width+15
	and.w	D5,D4	D4: Xfrac
	add.w	D4,D6	Width + Xfrac + 15
	moveq	#15,D5
	and.w	D5,D1	D1: Right shift
	cmp.w	D4,D1
	bhi.s	putfm49
	tst.l	D7
	bpl.s	putfm48
	sub.w	D3,A6
	sub.w	D3,A6
	bra.s	putfm49
putfm48	subq.l	#2,A5
putfm49	and.w	D6,D5	D5: X2frac
	lsr.w	#4,D6	D6: Number of words to do per row
	beq.s	putfm53

* - - - - - - - - - - - - -
	move.w	D2,A1	A1: Bytes per raster line
	mulu	D0,D2	times raster height (in D0)
	movea.l	D2,A0	A0: Bytes per raster plane

	move.w	(A4),D2	D2: # of raster planes
	move.w	D3,D0
	sub.w	D2,D0	D0: # of screen planes - # of raster ones
	bpl.s	putfm50
	add.w	D0,D2	Less screen planes than raster ones
	moveq	#0,D0
	tst.l	D7
	bpl.s	putfm50
	move.w	D2,(A4)	For GETFM set new #planes in MFDB

putfm50	swap	D0	D0 MSW: Extra screen planes
	move.w	6(SP),D0	   LSW: Start colour
	asr.w	D2,D0	   shifted with # of raster planes
	move.l	D0,A4

	add.w	D3,D3
	move.w	D3,A3	A3: number of screen planes *2
	mulu	D6,D3	# of screen planes * (# of bytes to do)
	sub.w	A3,D3	- # of screen planes * 2

	suba.w	D3,A2	A2: Screen line offset

	suba.w	D6,A1
	suba.w	D6,A1	A1: Raster line offset

	add.w	D4,D4
	move.w	putfm54(PC,D4.W),D4	Left mask
	add.w	D5,D5
	move.w	putfm55(PC,D5.W),D5	Right mask

	moveq	#0,D0
	move.w	D6,D0
	lsr.w	#1,D6	Number of longwords to do per row
	bne.s	putfm52

putfm51	subq.w	#2,A1	1 word
	sub.w	A3,A2
	or.w	D5,D4
	moveq	#-1,D5
	addq.w	#1,D6	(This should clear X-bit)

putfm52	roxr.l	#1,D0	D0 M.S.Bit: Flag for odd word
	addx.w	D0,D0
	subq.w	#1,D6
	swap	D6
	move.w	D2,D6	Number of planes
	subq.w	#1,D6
	move.w	D5,D3
	not.w	D3
	move.w	D4,D2
	not.w	D2	Non-zero if OK
putfm53	rts		Zero-flag set if error
*--------------------------
putfm54	dc.w	$0000,$8000,$C000,$E000,$F000,$F800,$FC00,$FE00
	dc.w	$FF00,$FF80,$FFC0,$FFE0,$FFF0,$FFF8,$FFFC,$FFFE

putfm55	dc.w	$7FFF,$3FFF,$1FFF,$0FFF,$07FF,$03FF,$01FF,$00FF
	dc.w	$007F,$003F,$001F,$000F,$0007,$0003,$0001,$0000


*~~~~~~~~~~~~~~~~~~~~~~~~~~
*	GETFM		Non-VDI copy from screen
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A4 -> MFDB
*     A3 -> 8 Words: source X1,Y1,X2,Y2, dest X1,Y1,X2,Y2 (as VDI)
*~~~~~~~~~~~~~~~~~~~~~~~~~~
GETFM	movem.l	D0-D7/A0-A6,-(SP)
	move.l	(A3)+,D5
	move.l	(A3)+,D6
	move.l	(A3)+,D3
	move.l	(A3)+,D4
	moveq	#-1,D7	Flag for GET form

	move.l	#$40FFFF,-(SP)	BLITMODE, don't change
	trap	#14
	addq.l	#4,SP
	and.b	#1,D0
	bne.s	getfm6	Use blitter

	bsr	putfm46
	beq.s	getfm5	Exit
	suba.l	A3,A2
	subq.w	#2,D0	words to do per line -2
	move.w	D0,A4

getfm1	movem.l	D6-D7/A0/A5-A6,-(SP)	Next plane
getfm2	move.l	(A6),D0	Next line
	adda.w	A3,A6
	move.w	(A6),D0
	lsr.l	D1,D0
	and.w	D2,D0
	and.w	D4,(A5)
	or.w	D0,(A5)+
	move.w	A4,D6
	bra.s	getfm4

getfm3	move.l	(A6),D0	Next 'middle' (unmasked) word
	adda.w	A3,A6
	move.w	(A6),D0
	lsr.l	D1,D0
	move.w	D0,(A5)+
getfm4	dbf	D6,getfm3

	move.l	(A6),D0
	adda.w	A3,A6
	move.w	(A6),D0
	lsr.l	D1,D0
	and.w	D3,D0
	and.w	D5,(A5)
	or.w	D0,(A5)+

	adda.l	A1,A5
	adda.l	A2,A6
	dbf	D7,getfm2

	movem.l	(SP)+,D6-D7/A0/A5-A6
	adda.l	A0,A5
	addq.l	#2,A6
	dbf	D6,getfm1
getfm5	movem.l	(SP)+,D0-D7/A0-A6
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Blitter version of GETFM
getfm6	bsr.s	getfm11
	bsr	putfm46
	beq.s	getfm10

	addq.w	#1,D7	Y count
	move.l	#$203C080,D5

	tst.w	D1
	bne.s	getfm7
	clr.b	D5
	add.w	A3,A6
	add.w	A3,A2
getfm7	or.b	D1,D5
	cmp.w	#1,D0
	bhi.s	getfm8
	addq.w	#2,A1
	adda.w	A3,A2
getfm8	swap	D0
	move.w	D7,D0

getfm9	lea	$FFFF8A20.W,A4	LOAD BLITTER:
	move.w	A3,(A4)+	Source X increment
	move.w	A2,(A4)+	Source Y increment
	move.l	A6,(A4)+	Source address
	move.w	D2,(A4)+	Endmask 1
	move.w	#-1,(A4)+	Endmask 2
	move.w	D3,(A4)+	Endmask 3
	move.w	#2,(A4)+	Dest X incr
	move.w	A1,(A4)+	Destination Y increment
	move.l	A5,(A4)+	Destination address
	move.l	D0,(A4)+	X count, Y count
	move.l	D5,(A4)+	HOP,log,Busy+HOG,FXSR+Rshft	
	adda.l	A0,A5
	addq.l	#2,A6
	dbf	D6,getfm9

getfm10	rts
getfm11	move.w	#38,-(SP)	SUPEXEC
	trap	#14
	addq.l	#6,SP
	bra.s	getfm5

