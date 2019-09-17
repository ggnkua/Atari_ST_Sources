
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
	subq.w	#2,SP	Reserve space for word value
	lea	(SP),A6
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
tt_vdo?2	move.w	D0,(A6)
	rts

tt_vdo?3	move.w	#38,-(SP)	SUPEXEC
	trap	#14
	subq.w	#2,(A6)	Compare cookie value MSW with 2
	lea	2(A6),SP
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
SETTRU	movem.l	D0-D4/A0-A3,-(SP)
	lea	(A0),A3	A3 -> Source Palette
	move.l	D0,D3
	swap	D3	D3.W: Start colour
	move.w	D0,D4	D4.W: Number of colours
	bsr	TT_VDO?	Falcon Video?
	bls.s	settru2	NO: ST/TT
	bhi.s	settru5	YES
*÷ ST/TT ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
settru1	lea	(A3),A0	A0 is input for tru_ste3
	addq.l	#3,A3
	bsr.s	tru_ste3	Do one colour
	move.w	D0,-(SP)	Colour
	move.w	D3,-(SP)	Colour number
	addq.w	#1,D3
	move.w	#7,-(SP)	SETCOLOR
	trap	#14
	addq.l	#6,SP
settru2	dbf	D4,settru1	Next colour
	bra.s	settru6	EXIT
*÷ FALCON ÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Set palette in rounds of 16 colours each
* Depending on how much/little space you think you have on stack, the
* number 16 can be changed (throughout routine) to any other number.
settru3	lea	-16*4(SP),SP	Reserve space for palette
	lea	(SP),A1	
	pea	(A1)	Address
	move.w	D0,-(SP)	Number of colours
	move.w	D3,-(SP)	Start colour
	add.w	D0,D3
	move.w	#93,-(SP)	VSETRGB (Falcon)
	subq.w	#1,D0
settru4	clr.b	(A1)+	Dummy byte
	move.b	(A3)+,(A1)+	R
	move.b	(A3)+,(A1)+	G
	move.b	(A3)+,(A1)+	B
	dbf	D0,settru4
	trap	#14
	lea	16*4+10(SP),SP
settru5	moveq	#16,D0
	sub.w	D0,D4
	bpl.s	settru3
	add.w	D4,D0
	bgt.s	settru3

settru6	movem.l	(SP)+,D0-D4/A0-A3
	rts


***************************
* IMGCALC LBMCALC DEGCALC NEOCALC   Calculate space needed for unpacking
*~~~~~~~~~~~~~~~~~~~~~~~~~~  (IMGCALC also converts PC IMG header to ST)
* IMGUNP  LBMUNP  DEGUNP  NEOUNP	Unpacks image file
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A3 -> Loaded image file
*  D3 MSW: Type of palette wanted: -1 = 24-bit, 0=VDI
*     LSW: >0 = 'Min number of planes' (= # planes on screen). Absent
*	planes to be filled in.  ó0 = No fill planes to be used.
*     A4 -> Space for unpacked image (Only needed for the UNP routines)
* OUT (CALC):
*  D0.L: Required size of block to be reserved for 'UNP' or -1 for error
*  D1.L = D0.L except for one plane pic. and D3.W>0 when D1.L is size
*	required without fill. Intended for VRT_CPYFM.
* OUT (UNP):
*  D0.L: Size of image data or -1 for major error
*  D1 MSW <0 for minor error, LSW: =D3.W or =1 for one plane image
*  At (A4) a VDI MFDB for the unpacked image + extra info and palette

*~~~~~~~~~~~~~~~~~~~~~~~~~~
IMGCALC	movem.l	D2-D7/A0-A3/A5-A6,-(SP)
	bsr.s	imgcalc3
	move.l	D0,D1	Size of MFDB +xtra pars +palette
	bmi.s	imgcalc2	error
	subq.w	#1,D6	Number of planes?
	beq.s	imgcalc1
	movea.l	A1,A5
imgcalc1	add.l	A5,D1
	add.l	A1,D0
imgcalc2	movem.l	(SP)+,D2-D7/A0-A3/A5-A6
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
* Sub-routine to load registers with parameters read or calculated from
* image file header. (In addition converts PC header to ST format.)
* A4 untouched.  See ___unp0 for further info.  Also called by IMGUNP.
imgcalc3	tst.b	4(A3)	PC format?
	beq.s	imgcalc6	NO Motorola
* - - - - - - - - - - - - -	YES: Transform header words from Intel
	lea	(A3),A0
	moveq	#7,D1
imgcalc4	move.w	(A0),D0
	ror.w	#8,D0
	move.w	D0,(A0)+
	dbf	D1,imgcalc4

	moveq	#-13,D1
	add.w	2(A3),D1
	bmi.s	imgcalc6
	addq.l	#4,A0	Skip possible 'XIMG' byte string
imgcalc5	move.w	(A0),D0
	ror.w	#8,D0
	move.w	D0,(A0)+
	dbf	D1,imgcalc5
* - - - - - - - - - - - - -
imgcalc6	lea	2(A3),A0
	adda.w	(A0),A3
	adda.w	(A0)+,A3	A3 -> Image data

	move.w	(A0)+,D6	D6: Number of planes
	ble.s	imgcalc7
	move.w	(A0)+,D7	D7: Pattern length
	ble.s	imgcalc7
	move.l	(A0)+,A2	A2: Pixel dimensions
	move.l	(A0)+,D5	D5 LSW: Number of lines
	bra	___unp0	   MSW: Width in pixels
* After this A0 points to possible source palette

imgcalc7	moveq	#-1,D0	error
	rts
*==========================
IMGUNP	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	imgcalc3  Read header
	bmi	imgunp27	error => exit
	move.l	D3,(SP)
	st	(SP)	Minor error: Initiate to yes
	pea	(A1)	Save picture size in bytes
	bsr	___unp7  Fill in MFDB and extra parameters
* - - - - - - - - - - - - - Do palette
	move.l	D1,D0	Number of colours
	beq.s	imgunp7	No palette
	cmpi.l	#'XIMG',(A0)+
	bne.s	imgunp3
	tst.w	(A0)+
	bne.s	imgunp4

	tst.l	D3	Palette format wanted?
	bpl.s	imgunp1
	bsr	VDI_TRU	24 bit palette
	bra.s	imgunp7
imgunp1	subq.w	#1,D0	VDI palette
imgunp2	move.w	(A0)+,(A1)+
	move.w	(A0)+,(A1)+
	move.w	(A0)+,(A1)+
	dbf	D0,imgunp2
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

imgunp5	tst.l	D3	Source palette in STE format.
	bpl.s	imgunp6	Convert to:
	bsr	STE_TRU	24 bit
	bra.s	imgunp7
imgunp6	bsr	STE_VDI	VDI

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
	sf	8(A1)	Done without error
imgunp26	lea	4(A1),SP
	move.l	(SP)+,D0	Return image length
imgunp27	movem.l	(SP)+,D1-D7/A0-A6
	rts

*--------------------------
imgunp28	dc.w	$FFF,$F00,$0F0,$FF0,$00F,$F0F,$0FF,$555  default palette
	dc.w	$333,$F33,$3F3,$FF3,$33F,$F3F,$3FF,$000


*~~~~~~~~~~~~~~~~~~~~~~~~~~
* ___unp0: branched to from IMGCALC, DEGCALC, LBMCALC etc.
*	calculates parameters
* ___unp7: called from IMGUNP, DEGUNP, LBMUNP etc.
*	writes parameters in MFDB
* -------------------------
* IN (___unp0):
*  D3 MSW: -1 = 24-bit palette, 0=VDI; LSW: Requested number of planes
*  D5 MSW: Width in pixels, LSW: Number of lines
*  D6.W: Number of planes
* OUT (___unp0):
*  D0.L: Size of MFDB + extra block + palette,  or -1 for error
*  D1.L: Number of colours,  or 0 if more than 8 planes
*  D2.W: Width in words
*  D3: As input except LSW=1 if D6=1
*  D4.W: Width in bytes
*  A1: Total picture size, incl. fill planes
*  A5: Size in bytes of one plane
*  A6: Total picture size, not incl. fill planes
* Remaining register (ie D5,D6,D7, A0,A2,A3,A4) untouched
*
* IN (___unp7): Same as input AND OUTPUT from ___unp0 +
*  A4 -> Area for unpacked image
*  A2 MSW: Pixel width, LSW: Pixel height
* OUT: A1-> area for palette, A4-> area for image data, D3.W cleared

___unp0	move.l	D5,D4
	swap	D4
	addq.w	#7,D4
	lsr.w	#3,D4	D4: Width in bytes

	move.w	D4,D0
	addq.w	#1,D0
	lsr.w	#1,D0
	move.w	D0,D2	D2: Width in words
	add.w	D0,D0
	mulu	D5,D0
	beq.s	___unp6	error
	movea.l	D0,A5	A5: Size in bytes of one plane

	move.w	D3,D1	# requested planes
	move.w	D6,D0	# actual planes
	ble.s	___unp6	error
	subq.w	#1,D0
	bne.s	___unp1
	move.w	D6,D3	If # actual planes=1 then #req.pl=1
___unp1	suba.l	A6,A6
___unp2	adda.l	A5,A6	Total planes
	dbf	D0,___unp2	

	movea.l	A6,A1	A6: Total size of actual planes
	sub.w	D6,D1
	bls.s	___unp4
	subq.w	#1,D1
___unp3	adda.l	A5,A1	Add size of fill planes
	dbf	D1,___unp3	A1: Total size incl. fill planes

___unp4	moveq	#0,D0
	moveq	#0,D1
	cmpi.w	#8,D6
	bhi.s	___unp5	direct colour RGB (no palette)
	moveq	#1,D1
	lsl.w	D6,D1	D1: Number of colours
	move.w	D1,D0
	mulu	#3,D0
	tst.l	D3
	bmi.s	___unp5
	add.w	D0,D0	D0: Size of palette
___unp5	add.w	#20+12,D0	 + size of MFDB + extra info
	rts

___unp6	moveq	#-1,D0
	moveq	#-1,D3
	rts
*~~~~~~~~~~~~~~~~~~~~~~~~~~
___unp7	lea	(A4),A1
	adda.l	D0,A4	A4 -> destination data
* - - - - - - - - - - - - - Fill in MFDB
	move.l	A4,(A1)+	Address
	move.l	D5,(A1)+	Width in pixels, Height
	move.w	D2,(A1)+	Width in words
	move.w	#1,(A1)+	Flag for device independent format
	move.w	D6,(A1)+	Initiate to actual number of planes
	clr.w	(A1)+
	clr.l	(A1)+
* - - - - - - - - - - - - - and extra parameters
	move.w	D6,(A1)+	Actual number of planes in file
	move.l	A2,(A1)+	Pixel dimensions
	clr.w	D3
	move.l	D3,(A1)+	Palette format; Start colour
	move.w	D1,(A1)+	Number of colours
	rts

*ðððððððððððððððððððððððððð
NEOCALC	movem.l	D2-D7/A0-A3/A5-A6,-(SP)
	bsr.s	neocalc1
	bra.s	degcalc1

neocalc1	move.l	(A3)+,D7
	bra.s	degcalc5

*==========================
DEGCALC	movem.l	D2-D7/A0-A3/A5-A6,-(SP)
	bsr.s	degcalc4
degcalc1	move.l	D0,D1	Size of MFDB +xtra pars +palette
	bmi.s	degcalc3	error
	subq.w	#1,D6	Number of planes?
	beq.s	degcalc2
	movea.l	A1,A5
degcalc2	add.l	A5,D1
	add.l	A1,D0
degcalc3	movem.l	(SP)+,D2-D7/A0-A3/A5-A6
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
* Load registers with parameters read/calculated from file header. A4 un-
* touched. ___unp0 for further info. Also called by DEGUNP/NEOCALC/NEOUNP.
degcalc4	move.w	(A3)+,D7	M.S.Bit of D7.W: Compression flag
degcalc5	moveq	#7,D0
	and.w	D7,D0	D0.W: Resolution
	move.b	degcalc7(PC,D0.W),D0
	bmi.s	degcalc6	error (unknown resolution)
	lea	degcalc8(PC),A0
	adda.w	D0,A0
	move.w	(A0)+,D6	D6.W: # planes
	move.l	(A0)+,D5	D5.L: image dimensions
	move.l	(A0)+,A2	A2:   pixel dimensions
	lea	(A3),A0	A0 -> palette
	bra	___unp0

degcalc6	moveq	#-1,D0	error
	rts
* ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~ ~  Data for standard ST/TT resolutions
degcalc7	dc.b	0,10,20,-1,30,-1,40,-1 (or replace last -1 with 50)

degcalc8	dc.w	4,320,200,338,372	#planes,imagew,imageh,pixw,pixh
	dc.w	2,640,200,169,372
	dc.w	1,640,400,372,372
	dc.w	4,640,480,372,372
	dc.w	1,1280,960,372,372
*	dc.w	8,320,480,744,372	TT low
* To use last line for TT low you would have to change routine below for
* uncompressed image. (And TT low rez screen may be BYTE interleaved ?)

* Pixel dimensions (for the ST) as given by the VDI (supposedly in microns)

*==========================
NEOUNP	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	neocalc1  Read header
	lea	124(A3),A3	A3->image data
	bra.s	degunp1
*==========================
DEGUNP	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	degcalc4  Read header
	lea	32(A3),A3	A3->image data
degunp1	bmi	degunp12	error => exit
	move.l	D3,(SP)
	st	(SP)	initiate to error
	pea	(A1)	Save picture size
	bsr	___unp7  Fill in MFDB and extra parameters
* - - - - - - - - - - - - - Do palette
	move.w	D1,D0	Number of colours
	tst.l	D3
	bpl.s	degunp2
	bsr	STE_TRU	24-bit palette
	bra.s	degunp3
degunp2	bsr	STE_VDI	VDI palette
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
degunp10	sf	4(SP)	No error
degunp11	move.l	(SP)+,D0	Return image length
degunp12	movem.l	(SP)+,D1-D7/A0-A6
	rts
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
LBMCALC	movem.l	D2-D7/A0-A3/A5-A6,-(SP)
	bsr.s	lbmcalc3
	move.l	D0,D1	Size of MFDB +xtra pars +palette
	bmi.s	lbmcalc2	error
	subq.w	#1,D6	Number of planes?
	beq.s	lbmcalc1
	movea.l	A1,A5
lbmcalc1	add.l	A5,D1
	add.l	A1,D0
lbmcalc2	movem.l	(SP)+,D2-D7/A0-A3/A5-A6
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
* Load registers with parameters read/calculated from image file header.
* A4 untouched. See ___unp0 for further info. Also called by LBMUNP.
lbmcalc3	cmpi.l	#'FORM',(A3)
	bne.s	lbmcalc4
	cmpi.l	#'ILBM',8(A3)
	bne.s	lbmcalc4
	move.l	#'BMHD',D0
	bsr.s	GETCHNK
	ble.s	lbmcalc4

	move.l	(A0)+,D5
	moveq	#0,D6
	addq.l	#4,A0
	move.b	(A0),D6
	move.l	(A0)+,D7
	moveq	#0,D0
	addq.l	#2,A0
	move.b	(A0)+,D0
	swap	D0
	move.b	(A0)+,D0
	movea.l	D0,A2
	bra	___unp0

lbmcalc4	moveq	#-1,D0	error
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
LBMUNP	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	lbmcalc3   Read header
	bmi	lbmunp21	error => exit
	move.l	D3,(SP)
	sf	(SP)	Initiate to NO error
	pea	(A1)	Save picture size
	bsr	___unp7	Fill in MFDB and extra parameters
* - - - - - - - - - - - - - Do palette
	move.l	#'CMAP',D0
	bsr.s	GETCHNK
	ble	lbmunp23	error

	move.w	D1,D0	Number of colours
	tst.l	D3	Palette format wanted?
	bpl.s	lbmunp3
lbmunp1	subq.w	#1,D0
lbmunp2	move.b	(A0)+,(A1)+	24 bit palette
	move.b	(A0)+,(A1)+
	move.b	(A0)+,(A1)+
	dbf	D0,lbmunp2
	bra.s	lbmunp4
lbmunp3	bsr	TRU_VDI	VDI palette

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
	rts

lbmunp22	st	4(SP)	'Minor error'
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
	add.w	D4,D4	D4: # Bytes/line evened up

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


***************************	Updates number of planes in MFDB
*	PICFILL		(at 12(A4)) and fills any absent
*~~~~~~~~~~~~~~~~~~~~~~~~~~	(compared to D3 ie screen) planes
* IN: A4-> unpacked image, D3: requested number of planes
* Planes will be filled according to start colour at 28(A4)

PICFILL	movem.l	D0-D4/A0,-(SP)
	move.w	20(A4),D0	D0: Actual number of planes
	move.w	D3,12(A4)	    Requested number of planes
	sub.w	D0,D3	D3: Number of fill planes
	ble.s	picfill7

	move.w	28(A4),D4	Start colour
	movem.w	6(A4),D1-D2
	mulu	D1,D2	D2: size of 1 plane in words
	move.l	D2,D1
	add.l	D1,D1	D1: ditto in bytes
	movea.l	(A4),A0
	bra.s	picfill2
picfill1	adda.l	D1,A0	Skip actual planes
	lsr.w	#1,D4
picfill2	dbf	D0,picfill1
	bra.s	picfill6

picfill3	swap	D1
picfill4	move.w	D0,(A0)+
picfill5	dbf	D1,picfill4	next word
	swap	D1
	dbf	D1,picfill3	next 64 K words
picfill6	lsr.w	#1,D4	Shift last bit of colour number out
	scs	D0	and extend it to word
	ext.w	D0
	move.l	D2,D1	D1: size of 1 plane in words
	dbf	D3,picfill5	next plane

picfill7	movem.l	(SP)+,D0-D4/A0
	rts


***************************
*	PUTFM		Non-VDI copy to screen
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN: A4 -> MFDB
*     A3 -> 8 Words: source X1,Y1,X2,Y2, dest X1,Y1,X2,Y2 (as VDI)
*     D0: Start colour (when # image planes < # screen planes
*	Only M.S.Bits, in excess of # image planes, noted)
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
	movem.l	A4,-(SP)	MSW: # extra screen planes, LSW: Colour
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

	move.w	(SP),D6	# extra planes
	ble	putfm28
	suba.l	A0,A5
	suba.l	A0,A0
	move.w	A0,(SP)	Clear extra planes
	move.w	2(SP),D0	M.S.Bits of start colour
	bmi.s	putfm9	Extra planes = last plane repeated
	bra.s	putfm19	Extra planes filled with D0 bits

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ SHIFTED COPY
putfm10	move.l	D0,-(SP)	M.S.Bit: Odd word flag
	movem.l	A4,-(SP)	MSW: # extra screen planes, LSW: Colour
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

	move.w	(SP),D6	# extra planes
	ble.s	putfm28
	suba.l	A0,A5
	suba.l	A0,A0
	move.w	A0,(SP)	Clear extra planes
	move.w	2(SP),D0	M.S.Bits of start colour
	bmi.s	putfm18	Repeat last plane for extra planes

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Fill extra planes according to D0 bits
putfm19	move.w	D6,(SP)	# planes
	move.w	6(SP),A4	# words to do per line
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
	bsr	putfm38 (Push next address on stack and jump)
	move.l	A6,-(SP)	and save it
	bsr	putfm46
	beq	putfm37

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
	bmi	putfm37
	suba.l	A0,A5
	tst.w	D4
	bpl.s	putfm35
putfm34	bsr.s	putfm39
	addq.l	#2,A6
	dbf	D6,putfm34
	bra.s	putfm37
putfm35	lsr.w	D4
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
* (A0): #planes, -2(A0) Bytes per line, -4(A0) # screen lines
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

	move.w	(A4),D2	D2: # raster planes
	move.w	D3,D0
	sub.w	D2,D0	D0: # screen planes - # raster ones
	bpl.s	putfm50
	add.w	D0,D2	Less screen planes than raster ones
	moveq	#0,D0
	tst.l	D7
	bpl.s	putfm50
	move.w	D2,(A4)	For GETFM set new #planes in MFDB

putfm50	swap	D0	D0 MSW: Extra screen planes
	move.w	6(SP),D0	   LSW: Start colour
	asr.w	D2,D0	   shifted with # raster planes
	move.l	D0,A4

	add.w	D3,D3
	move.w	D3,A3	A3: number of screen planes *2
	mulu	D6,D3	# Screen planes * (# Bytes to do)
	sub.w	A3,D3	- # Screen planes * 2

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


***************************
*    IMGPAC    LBMPAC	Pack images to files of types
*~~~~~~~~~~~~~~~~~~~~~~~~~~	IMG and IFF ILBM
* IN:
*  A4 -> MFDB + extra parameters
*  A3 -> Space for file
*  D0  for LBM: Compression type (0-2),  for IMG: Pattern length (1 or 2)
* OUT:  D0: File length or -1 for error
*~~~~~~~~~~~~~~~~~~~~~~~~~~

___pac	lea	20(A4),A0	READ PARAMETERS
	move.w	(A0)+,D6	D6: # planes

	movea.l	(A4)+,A2	A2: Image data
	move.w	(A4),D4
	addq.w	#7,D4
	lsr.w	#3,D4	D4: Image width in bytes
	move.l	(A4)+,D5	D5: Image height (and width in MSW)
	move.w	(A4)+,D2	D2: Width in words

	move.w	D2,D1
	add.w	D1,D1	  Width in bytes evened up
	move.w	D1,D3
	mulu	D5,D1
	movea.l	D1,A5	A5: Bytes per plane
	mulu	D6,D3
	mulu	D5,D3
	movea.l	D3,A6	A6: Bytes of whole picture

	movem.l	(A0)+,D1/D3	D1: pixel dimensions
	rts		D3: Palette format (and start colour)
*			A0 -> #colours and palette
*==========================
IMGPAC	movem.l	D0-D7/A0-A6,-(SP)
	bsr.s	___pac	Read parameters
	bgt.s	imgpac2
	addq.l	#4,SP
imgpac1	moveq	#-1,D0	Error: quick exit
	movem.l	(SP)+,D1-D7/A0-A6
* - - - - - - - - - - - - -
imgpac2	move.l	#$10008,(A3)+  (File v1); Palette-less header: 8 words
	move.w	D6,(A3)+	# planes
	move.w	D0,(A3)+	pattern length
	move.l	D1,(A3)+	Pixel dimensions
	move.l	D5,(A3)+	Image width and height

	move.w	(A0)+,D0	Number of colours
	beq.s	imgpac7
* - - - - - - - - - - - - - SKIP PALETTE FOR WHITE-BLACK IMG
	cmp.b	#2,D0	If # colours is 2, a palette is
	bne.s	imgpac4	probably best left out of an
	lea	(A0),A1	IMG file
	tst.l	D3
	bpl.s	imgpac3
	addq.l	#3,A1
	move.b	(A1)+,D1
	or.b	(A1)+,D1	
	or.b	(A1)+,D1
	beq.s	imgpac7	at least if 2nd colour is black
	bra.s	imgpac4
imgpac3	addq.l	#6,A1
	move.w	(A1)+,D1
	or.w	(A1)+,D1
	or.w	(A1)+,D1
	beq.s	imgpac7
* - - - - - - - - - - - - - DO PALETTE
imgpac4	move.w	D0,D1
	add.w	D0,D1
	add.w	D0,D1	# words in palette
	addq.w	#3,D1	+ XIMG palette header
	add.w	D1,-14(A3)	Add to file header length
	move.l	#'XIMG',(A3)+
	clr.w	(A3)+
	tst.l	D3
	bpl.s	imgpac5
	lea	(A3),A1
	bsr	TRU_VDI
	subq.w	#3,D1
	add.w	D1,D1	# bytes in palette
	add.w	D1,A3
	bra.s	imgpac7
imgpac5	subq.w	#1,D0
imgpac6	move.w	(A0)+,(A3)+
	move.w	(A0)+,(A3)+
	move.w	(A0)+,(A3)+
	dbf	D0,imgpac6
* - - - - - - - - - - - - -
imgpac7	move.l	(SP)+,D0
	sub.w	D4,A5	Plane size minus one line
	add.w	D2,D2
	sub.w	D2,A6	Image size minus one evened up line
	move.w	D2,-(SP)	Save line offset within plane
	subq.w	#1,D6	# planes -1
	subq.w	#1,D5	# lines -1
	subq.w	#1,D4	# bytes/line -1
	move.w	D4,A4
	subq.b	#2,D0
	bhi	imgpac1	Can't handle pattern length > 2
* - - - - - - - - - - - - - Check IMG line repeat
imgpac8	lea	(A2),A0
	lea	(A2),A1
	add.w	(SP),A1
	move.w	D5,D7
	moveq	#1,D1
	bra.s	imgpac11

imgpac9	move.w	A4,D4
imgpac10	cmpm.b	(A0)+,(A1)+
	dbne	D4,imgpac10
	bne.s	imgpac12
	adda.l	A5,A0	Same line, next plane
	adda.l	A5,A1
	dbf	D2,imgpac9
	suba.l	A6,A0
	suba.l	A6,A1
	lea	(A0),A2
imgpac11	move.w	D6,D2
	addq.b	#1,D1
	dbcs	D7,imgpac9
imgpac12	subq.b	#2,D1
	beq.s	imgpac13	No repeat
	sub.w	D1,D5
	addq.b	#1,D1
	sf	(A3)+
	sf	(A3)+
	st	(A3)+
	move.b	D1,(A3)+
* - - - - - - - - - - - - -
imgpac13	move.w	D6,D2
imgpac14	move.w	A4,D4

imgpac15	lea	(A3),A1	A1 -> Start of literal sequence
	addq.l	#2,A3
	moveq	#0,D3	D3: Bytes in current sequence

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
imgpac16	move.b	D1,D7	LITERAL COPY RUN:
	move.b	(A2)+,D1

	beq.s	imgpac17	If D1 = %00000000
	cmp.b	#-1,D1	 or %11111111
	bne.s	imgpac18
imgpac17	tst.b	D3	and if current literal sequence
	beq.s	imgpac31	was just started
	cmp.b	D1,D7
	bne.s	imgpac18
	cmpi.b	#2,D3
	bcs.s	imgpac30
	tst.b	D4	or about to be finished
	beq.s	imgpac30
	cmp.b	(A2),D1	or if 3+ of 'solid' bytes
	beq.s	imgpac30	then use 'solid run'!

imgpac18	cmp.b	-4(A2),D7	Try possible pattern match: 1st
	bne.s	imgpac21
	cmp.b	-3(A2),D1	and 2nd byte.
	bne.s	imgpac21
	cmpi.b	#2,D3	At least 3 bytes must have preceded
	bls.s	imgpac21	for this to be valid
	cmp.b	(A2),D7	Try a further pattern repeat
	bne.s	imgpac21	(A pattern usually needs to be
	tst.b	D0
	bne.s	imgpac36  (1 byte pattern repeated 5 times)
	cmp.b	1(A2),D1	repeated 3 times to be economical)
	bne.s	imgpac21
	bsr.s	imgpac27	End literal copy sequence
	moveq	#1,D3	Include previous 2-byte pattern
	subq.l	#3,A3
	addq.w	#1,D4
	bra	imgpac48	To pattern run!

imgpac19	bsr.s	imgpac35
imgpac20	lea	(A3),A1	A1 -> Start of literal sequence
	addq.l	#2,A3
	moveq	#0,D3

imgpac21	move.b	D1,(A3)+
	addq.b	#1,D3
imgpac22	dbcs	D4,imgpac16	Next byte (LITERAL)
	bcs.s	imgpac23
	bsr.s	imgpac26
	bra	imgpac49

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Break off sequence at $7F/$FF bytes
imgpac23	subq.w	#1,D3	Back 1 byte to $FF
	bsr.s	imgpac26	End literal copy run
	subq.l	#1,A3
imgpac24	subq.l	#1,A2	Back 1 byte
imgpac25	bra.s	imgpac15	Skip dbf

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End literal copy sequence
imgpac26	addq.b	#3,D3	Include last bytes in sequence
imgpac27	subq.b	#2,D3	 or deduct three
imgpac28	subq.b	#1,D3	 or one
	bls.s	imgpac29	Cancel sequence if empty
	move.b	#$80,(A1)+
	move.b	D3,(A1)
	rts
imgpac29	subq.l	#2,A3
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Solid run
imgpac30	subq.l	#1,A3
imgpac31	bsr.s	imgpac28	End literal sequence
	move.b	D1,D7
	addq.b	#1,D3
	beq.s	imgpac33
	moveq	#1,D3
	bra.s	imgpac33

imgpac32	move.b	(A2)+,D1	SOLID RUN
	cmp.b	D1,D7
	bne.s	imgpac19
imgpac33	addq.b	#1,D3
	dbmi	D4,imgpac32	Next byte
	bmi.s	imgpac34	$80 bytes are more than allowed
	bsr.s	imgpac35
	bra.s	imgpac49

imgpac34	subq.w	#1,D3	Back 1 byte to $7F
	bsr.s	imgpac35
	bra.s	imgpac24

imgpac35	andi.b	#$80,D7	End solid run
	or.b	D7,D3
	move.b	D3,(A3)+
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Pattern run - 1-byte pattern
imgpac36	cmp.b	D1,D7
	bne.s	imgpac21
	bsr.s	imgpac27	End literal copy sequence
	moveq	#3,D3	Include previous 3 bytes
	subq.l	#3,A3
	bra.s	imgpac41

imgpac37	bsr.s	imgpac38
	bra.s	imgpac20

imgpac38	clr.b	(A3)+	End pattern run
	move.b	D3,(A3)+
	move.b	D7,(A3)+
	rts

imgpac39	subq.w	#1,D3	Back 1 pattern to $FF
	bsr.s	imgpac38	End pattern run
	bra.s	imgpac24

imgpac40	move.b	(A2)+,D1	1-BYTE PATTERN RUN
	cmp.b	D1,D7
	bne.s	imgpac37
imgpac41	addq.b	#1,D3
	dbcs	D4,imgpac40	Next byte
	bcs.s	imgpac39	$100 bytes are more than allowed
	bsr.s	imgpac38
	bra.s	imgpac49

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Pattern run - 2-byte pattern
imgpac42	subq.w	#1,D3	Back 1 pattern to $FF
	subq.l	#2,A2	= 2 bytes
	addq.w	#1,D4   Total 2 regained by adding 1 + skipping dbf
imgpac43	bsr.s	imgpac44
	bra.s	imgpac25

imgpac44	clr.b	(A3)+	End pattern run
	move.b	D3,(A3)+
	move.b	D7,(A3)+
	move.b	D1,(A3)+
	rts

imgpac45	subq.l	#1,A2
imgpac46	bsr.s	imgpac44
	move.b	-1(A2),D1
	bra	imgpac20

imgpac47	cmp.b	(A2)+,D7	PATTERN RUN: Compare 1st
	bne.s	imgpac46
	cmp.b	(A2)+,D1	and 2nd byte of pattern
	bne.s	imgpac45
imgpac48	addq.b	#1,D3
	bcs.s	imgpac42
	subq.w	#2,D4
	bhi.s	imgpac47	Next pattern
	beq.s	imgpac43
	bsr.s	imgpac44
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
imgpac49	adda.l	A5,A2	Same line, next plane
	dbf	D2,imgpac14
	suba.l	A6,A2
	dbf	D5,imgpac8
	addq.l	#2,SP
	move.l	A3,D0
	movem.l	(SP)+,D1-D7/A0-A6
	sub.l	A3,D0
	rts


*==========================
LBMPAC	movem.l	D0-D7/A0-A6,-(SP)
	move.l	#'FORM',(A3)+
	addq.l	#4,A3
	move.l	#'ILBM',(A3)+
	move.l	#'BMHD',(A3)+
	moveq	#20,D1
	move.l	D1,(A3)+
	bsr	___pac	Read parameters
	bgt.s	lbmpac2
	addq.l	#4,SP
lbmpac1	moveq	#-1,D0	Error: quick exit
	movem.l	(SP)+,D1-D7/A0-A6
* - - - - - - - - - - - - -
lbmpac2	move.l	D5,(A3)+	Image width and height
	clr.l	(A3)+	Image X & Y offset
	move.b	D6,(A3)+	# planes
	clr.b	(A3)+	No mask
	move.b	D0,(A3)+	Compression type
	clr.b	(A3)+	Reserved dummy byte
	clr.w	(A3)+	transparent colour
	bsr	WBRATIO	Make 2-word ratio fit in 2 bytes
	move.b	D0,(A3)+	Pixel width
	move.b	D1,(A3)+	Pixel height
	move.l	D5,(A3)+	Set page dimensions = image dim.
	move.w	(A0)+,D0	Number of colours
	beq.s	lbmpac5
	move.l	#'CMAP',(A3)+
	move.w	D0,D1
	mulu	#3,D1
	move.l	D1,(A3)+
	tst.l	D3
	bmi.s	lbmpac3
	lea	(A3),A1
	bsr	VDI_TRU
	add.l	D1,A3
	bra.s	lbmpac5
lbmpac3	subq.w	#1,D0
lbmpac4	move.b	(A0)+,(A3)+
	move.b	(A0)+,(A3)+
	move.b	(A0)+,(A3)+
	dbf	D0,lbmpac4
lbmpac5	move.l	#'BODY',(A3)+
	move.l	(SP)+,D0
	addq.l	#4,A3
	move.l	A3,-(SP)	Save address to BODY start

	subq.w	#1,D5	# lines -1
	subq.w	#1,D6	# planes -1

	subq.w	#2,D0
	bhi.s	lbmpac1
	beq	lbmpac27	2 = Vertical word compression

	add.w	D2,D2
	sub.w	D2,A6	Image size minus one evened up line

	addq.w	#1,D0
	bne	lbmpac23	0 = No compression
	sub.w	D4,A5	Plane size minus one line
	subq.w	#1,D4	# bytes/line -1
	move.w	D4,A4
*-------------------------- 1 = PACKBITS COMPRESSION
lbmpac6	move.w	D6,D2
lbmpac7	move.w	A4,D4
	move.b	(A2)+,D1
	bra.s	lbmpac18
*ßßßßßßßßßßßßßßßßßßßßßßßßßß
lbmpac8	move.b	D1,D7
	move.b	(A2)+,D1
	cmp.b	D1,D7
	bne.s	lbmpac19
	cmp.b	(A2),D7	You usually need three bytes in a
	bne.s	lbmpac19	repeat seq. to make it economical
	tst.b	D3
	beq.s	lbmpac19
*ßßßßßßßßßßßßßßßßßßßßßßßßßß When a byte = previous (and subsequent) byte:
	bsr.s	lbmpac12
	moveq	#1,D3
lbmpac9	addq.b	#1,D3
	dbmi	D4,lbmpac17
	bmi.s	lbmpac14
	bsr.s	lbmpac10
	bra.s	lbmpac21

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End repeat sequence
lbmpac10	subq.b	#1,D3
	neg.b	D3
	move.b	D3,-1(A3)
	move.b	D7,(A3)+
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End literal sequence
lbmpac11	addq.b	#1,D3	Include last byte in sequence
lbmpac12	subq.b	#2,D3	 or don't (and subtract 1 for dbf)
	bmi.s	lbmpac13	Cancel sequence if empty
	move.b	D3,(A1)
	rts
lbmpac13	subq.l	#1,A3
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Cut sequence at $80 bytes
lbmpac14	bsr.s	lbmpac10
	bra.s	lbmpac16
lbmpac15	bsr.s	lbmpac11
lbmpac16	lea	(A3),A1	A1 -> Start of literal sequence
	addq.l	#1,A3
	moveq	#0,D3
	bra.s	lbmpac20
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷

lbmpac17	move.b	(A2)+,D1
	cmp.b	D1,D7
	beq.s	lbmpac9
*ßßßßßßßßßßßßßßßßßßßßßßßßßß When a byte <> previous byte:
	bsr.s	lbmpac10
lbmpac18	lea	(A3),A1	A1 -> Start of literal sequence
	addq.l	#1,A3
	moveq	#0,D3	D3: Bytes in current sequence
lbmpac19	move.b	D1,(A3)+
	addq.b	#1,D3
lbmpac20	dbmi	D4,lbmpac8
	bmi.s	lbmpac15
	bsr.s	lbmpac11
*ßßßßßßßßßßßßßßßßßßßßßßßßßß
lbmpac21	adda.l	A5,A2	Same line, next plane
	dbf	D2,lbmpac7
	suba.l	A6,A2
	dbf	D5,lbmpac6

*--------------------------
lbmpac22	move.l	(SP)+,A0	Start of BODY
	move.l	A3,D0
	suba.l	A0,A3
	move.l	A3,-(A0)	Length of BODY chunk
	movem.l	(SP)+,D1-D7/A0-A6
	sub.l	A3,D0
	subq.l	#8,D0
	move.l	D0,4(A3)	Length of whole ILBM FORM
	addq.l	#8,D0	Length of file
	rts
*-------------------------- 0 = UNCOMPRESSED IFF ILBM
lbmpac23	sub.w	D2,A5	Plane size minus one evened up line
	subq.w	#1,D4
	lsr.w	#1,D4	D4: # words/line -1
lbmpac24	move.w	D6,D2	plane counter
lbmpac25	move.w	D4,D1	word counter
lbmpac26	move.w	(A2)+,(A3)+
	dbf	D1,lbmpac26
	adda.l	A5,A2	Same line, next plane
	dbf	D2,lbmpac25
	suba.l	A6,A2
	dbf	D5,lbmpac24	Next line
	bra.s	lbmpac22
*-------------------------- 2 = VERTICAL WORD COMPRESSION
lbmpac27	move.w	D5,A6
	move.w	D2,D4
	add.w	D4,D4	Image width in bytes evened up
	subq.w	#1,D2

	move.l	A5,D7
	addq.l	#5,D7	Calculate worst case space needed
	divs	#3,D7	for control bytes
	bvc.s	lbmpac28
	moveq	#-1,D7	Max. =
lbmpac28	andi.w	#$7FFE,D7	   32K - 2

	subq.w	#2,A5	# Bytes/plane - 2

	movem.w	D2/D7,-(SP)

*>>>>>>>>>>>>>>>>>>>>>>>>>> VDAT
lbmpac29	movem.w	(SP),D2/A4	#words/line, space for ctrl bytes
	move.l	#"VDAT",(A3)+
	move.l	A3,-(SP)
	addq.l	#6,A3	A3 -> control bytes
	adda.l	A3,A4	A4 -> word data
	move.l	A4,-(SP)

	move.w	(A2),D1	Read first word
	bra.s	lbmpac45

*ßßßßßßßßßßßßßßßßßßßßßßßßßß Literal copy loop
lbmpac30	suba.l	A5,A2	Move A2 to next column start
lbmpac31	move.w	D1,D7	D7: previous word
	adda.w	D4,A2
	move.w	(A2),D1	Read word
	cmp.w	D1,D7
	bne.s	lbmpac46	Write it if previous word <> it
	tst.w	D3
	beq.s	lbmpac46	... or not valid
*ßßßßßßßßßßßßßßßßßßßßßßßßßß When a word = previous word:
	bsr.s	lbmpac35	End literal sequence and start
	moveq	#1,D3	repeat seq. counted from prev. word
lbmpac32	addq.w	#1,D3
	dbcs	D5,lbmpac44	Next word (REPEAT)
	bcs.s	lbmpac40	At $10000 words, cut sequence
	move.w	A6,D5
	dbf	D2,lbmpac43	Next column (REPEAT)
	bsr.s	lbmpac33
	bra.s	lbmpac48

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End repeat sequence
lbmpac33	cmp.w	#128,D3
	bhs.s	lbmpac34	If count > 127: word format
	move.b	D3,(A3)+
	rts

lbmpac34	move.b	#1,(A3)+	Repeated word, count in word format
	move.w	D3,-2(A4)	Count
	move.w	D7,(A4)+	and data word
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ End literal sequence
lbmpac35	subq.w	#1,D3	Prev. word to new repeat sequence
lbmpac36	beq.s	lbmpac37	Exit if no words in old sequence
	cmp.w	#128,D3	
	bhi.s	lbmpac38	If count > 128: word format
	neg.b	D3
	move.b	D3,(A3)+
lbmpac37	rts

lbmpac38	clr.b	(A3)+	Literal run, count in word format
	addq.l	#2,A4
	lea	(A4),A0
	move.w	D3,D0
lbmpac39	move.w	-4(A0),-(A0)	Move whole sequence one word ...
	dbf	D0,lbmpac39
	move.w	D3,(A1)	... so that count can be inserted
	rts
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Cut sequence at $10000 words
lbmpac40	bsr.s	lbmpac34
	bra.s	lbmpac42
lbmpac41	bsr.s	lbmpac38
lbmpac42	lea	(A4),A1	A1 -> Start of literal sequence
	bra.s	lbmpac47
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷

lbmpac43	suba.l	A5,A2  Repeat loop	New column (REPEAT)
lbmpac44	adda.w	D4,A2	New word (REPEAT)
	cmp.w	(A2),D7
	beq.s	lbmpac32
*ßßßßßßßßßßßßßßßßßßßßßßßßßß When a word <> previous word:
	move.w	(A2),D1
	bsr.s	lbmpac33	End repeat sequence and start
lbmpac45	moveq	#0,D3	literal seq. counted from this word
	lea	(A4),A1	A1 -> Start of literal sequence
lbmpac46	move.w	D1,(A4)+	Write word
	addq.w	#1,D3
lbmpac47	dbcs	D5,lbmpac31	Next word (LITERAL)
	bcs.s	lbmpac41	At $10000 words, cut sequence
	move.w	A6,D5
	dbf	D2,lbmpac30	Next column (LITERAL)

	tst.w	D3
	bsr.s	lbmpac36
*ßßßßßßßßßßßßßßßßßßßßßßßßßß End of literal copy
lbmpac48	move.l	A3,D1	D1 -> End of control bytes
	addq.l	#1,D1	rounded up
	andi.b	#-2,D1
	movea.l	D1,A3

	move.l	(SP)+,A0	Move all data words back to
lbmpac49	move.w	(A0)+,(A3)+	where control bytes end
	cmpa.l	A0,A4
	bne.s	lbmpac49

	move.l	(SP)+,A0
	addq.l	#4,A0	A0 -> VDAT start (excl header)
	move.l	A3,D0	D0 -> VDAT end
	sub.l	A0,D0	Length of VDAT chunk
	sub.l	A0,D1	Offset to data words
	move.w	D1,(A0)
	move.l	D0,-(A0)

	addq.l	#2,A2	A2 -> Next source plane
	dbf	D6,lbmpac29
*>>>>>>>>>>>>>>>>>>>>>>>>>>
	addq.l	#4,SP
	bra	lbmpac22


***************************
*	WBRATIO		Called by LBMPAC
* translates two-WORD ratio into an approximately equivalent two-BYTE ratio
* (May seem a big routine for a small task, but I thought it necessary)
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN:  D1 MSW: Width, LSW: Height.  OUT:  D0.B: Width, D1.B: Height
*~~~~~~~~~~~~~~~~~~~~~~~~~~
WBRATIO	movem.l	D2-D7,-(SP)	Make 2-word ratio fit in 2 bytes
	move.w	D1,D3	D3: Height
	beq.s	wbratio4
	swap	D1
	moveq	#0,D2
	move.w	D1,D2	D2: Width
	beq.s	wbratio4
	move.w	D2,D7
	sub.w	D3,D7
	bpl.s	wbratio1
	exg	D2,D3	D2:max D3:min
wbratio1	moveq	#1,D0	First try 1 for out-component 1
wbratio2	move.w	D0,D4
	mulu	D3,D4	In2*Out1
	move.l	D2,D5
	lsr.w	#1,D5
	move.l	D5,D6
	add.l	D4,D5
	divu	D2,D5	/In1
	move.w	D5,D1	=Out2
	swap	D5
	sub.w	D5,D6
	bpl.s	wbratio3
	neg.w	D6
wbratio3	lsl.l	#8,D6
	cmp.l	D4,D6
	bcs.s	wbratio5	Acceptable match
	addq.b	#1,D0	Try other out-component 1
	bcc.s	wbratio2
wbratio4	moveq	#1,D0	Default: 1 for both width
	moveq	#1,D1	and height
wbratio5	tst.w	D7
	bpl.s	wbratio6
	exg	D0,D1
wbratio6	movem.l	(SP)+,D2-D7
	rts

