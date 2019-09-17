
*		                  --
*		                PICPAC
*		             ------------
*		         By: M†rten Lindstr”m
*		      --------------------------

* This file contains the GIF and TIFF unpacking routines of the PICPAC library

***************************
*    GIFCALC   TIFCALC	Calculate space needed for unpacking
*~~~~~~~~~~~~~~~~~~~~~~~~~~  (TIFCALC also converts Intel TIFF to Motorola)
*     GIFUNP   TIFUNP	Unpack image file
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
GIFCALC	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	gifcal
	movem.l	(SP)+,D1-D7/A0-A6
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
* Sub-routine to load registers with parameters read or calculated from
* image file header.
* A4 untouched.  See ___unp for further info.  Also called by GIFUNP.
gifcal	move.l	(A3)+,D0
	clr.b	D0
	cmpi.l	#"GIF"<<8,D0
	bne.s	gifcal5	Not a GIF file
	addq.l	#6,A3	Skip version and Log. screen dim.
	move.b	(A3)+,D7
	addq.l	#1,A3	Skip background colour

	moveq	#0,D1
	move.b	(A3)+,D1
	beq.s	gifcal1
	add.w	#15,D1
	swap	D1
	move.w	#64,D1	D1: Pixel dimensions

gifcal1	moveq	#0,D2	Initialize to NO sorted palette
	moveq	#0,D6	Initialize # of colour bits to 0
	tst.b	D7
	bsr.s	gifcal6
	moveq	#0,D0
gifcal2	move.b	(A3)+,D0
	cmp.b	#',',D0
	beq.s	gifcal4	Image descriptor found
	cmp.b	#'!',D0	Extension block?
	bne.s	gifcal5	Not that either => error
	addq.l	#1,A3	Skip function code
gifcal3	move.b	(A3)+,D0	Sub-block data count
	beq.s	gifcal2	Extension block done - read next
	add.w	D0,A3
	bra.s	gifcal3	Next data sub-block

gifcal4	movep.w	5(A3),D5	Skip X- and Y-offsets
	move.b	4(A3),D5
	swap	D5	D5 MSW: Width in pixels
	movep.w	7(A3),D5
	move.b	6(A3),D5	D5 LSW: Number of lines
	addq.l	#8,A3
	move.b	(A3)+,D7	D7 bit6: Line interlace flag
	bsr.s	gifcal6
	or.b	D2,D7	   bit3: Sorted palette flag
	bra	___unp

gifcal5	moveq	#-1,D0	error
	rts

gifcal6	bpl.s	gifcal7
	moveq	#8,D2
	and.b	D7,D2	D2 bit3: Sorted palette flag
	moveq	#7,D6
	and.b	D7,D6
	addq.w	#1,D6	D6: # of colour planes
	lea	(A3),A0	A0: Source palette
	moveq	#3,D0
	lsl.w	D6,D0
	add.w	D0,A3	Skip palette for now
gifcal7	rts

*==========================
GIFUNP	movem.l	D1-D7/A0-A6,-(SP)
	bsr	gifcal  Read header
	bmi	gifunp23	error => exit
	move.l	D3,-(SP)	Save picture size in bytes
	movem.l	D1-D2/D4-D7/A1/A4/A6,-(SP)
	pea	(A5)

* - - - - - - - - - - - - - Prepare image data for unpacking
	lea	(6*4096+256+512+768)/8(A5),A5  Space for string table +
	move.l	A5,D7  ini. strings + freq tab + palette + 1 byte/pixel in image =
	lsl.l	#3,D7	D7: Space required for unpacking
	lea	(A0),A5	A5 -> palette
	moveq	#0,D3
	move.b	(A3)+,D3	Min. code length -1

	move.l	D7,-(SP)	Request temporary memory block
	move.w	#72,-(SP)	MALLOC
	trap	#1
	addq.l	#6,SP
	move.l	D0,-(SP)	Save Memory block address
	bne.s	gifunp1
	moveq	#-39,D0	D0: -39: Not enough memory
	lea	12*4(SP),SP	mem addr, 10 registers & image size
	bra	gifunp23
gifunp1	move.l	D0,A0
	move.w	#767,D1
gifunp2	move.b	(A5)+,(A0)+	Copy palette
	dbf	D1,gifunp2
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ LZW Depack
	move.l	(SP),A0
	lea	1024(A0),A0	A0 points to after initial strings
	lea	6*256(A0),A1
	move.w	#255,D0
	move.w	D0,D2
	moveq	#-1,D1
gifunp3	move.b	D0,-(A0)	Initialize string table
	move.l	A0,-(A1)
	move.w	D1,-(A1)
	dbf	D0,gifunp3	A1 -> stringtable
	lea	6*4096+512(A1),A6	A6 -> destination
	pea	(A6)		Save it!
	lea	-12(SP),SP	Reserve reg. save area on stack
	move.l	A3,-(SP)	Save address to first sub-block
	lea	(A6),A3	A3 to point to End of string table

	moveq	#1,D5	Initial count table entries = one
gifunp4	move.w	D5,-(A3)	(count of zero reserved for special
	dbf	D2,gifunp4	purpose)

	moveq	#0,D4	D4: Pixel offset in word
	moveq	#$F,D6	D6: 15

	lsl.w	D3,D5
	move.w	D5,D7
	subq.w	#2,D7	D7: # of codes to read -1
	move.w	D5,A4	A4: Clear code
	addq.w	#1,D5	D5: EOI code

	addq.w	#1,D3	D3: Code length
	move.w	D5,D1
	addq.w	#1,D1
	mulu	#6,D1	D1: Offset in the table
	moveq	#16,D0
	sub.w	D3,D0
	moveq	#-1,D2
	lsr.w	D0,D2	D2: Mask
	moveq	#-2,D0	Initial "sub-block offset"
	movem.w	D0-D3/D7,-(SP)
	subq.l	#4,SP	for first/last data longword
	lea	(SP),A5
	move.w	#$100,-(SP)  Initial stack correction value = 1(*2)

gifunp5	moveq	#0,D0	LZW Clear
	move.b	(SP),D0
	add.w	D0,D0
	movem.w	6(SP,D0.W),D1-D3/D7
	lea	(A1),A2
	add.w	D1,A2	A2 -> Next entry
	bra.s	gifunp8
* - - - - - - - - - - - - - LZW loop
* A0: Work register
* A1->String table (with 6-byte entries)
* A2->Next entry
* A3->End of string table, Beginning of count table
* A4: Clear code
* A5->LZW data
* A6->Destination for unpacked data
* D0: Work register
* D1: Work register
* D2: Mask
* D3: Code length
* D4: Pixel offset in word
* D5: EOI code
* D6: 15
* D7: # of codes to read -1

gifunp6	move.w	D0,(A2)+	Write next entry: count ...
	move.l	A6,(A2)+	... and string pointer
* - - - - - - - - - - - - - Count occurences of lead byte
	moveq	#0,D1	to give an idea of colour frequences
	move.b	(A0),D1	for later palette sorting
	add.w	D1,D1
	addq.w	#1,0(A3,D1.W)
* - - - - - - - - - - - - -
gifunp7	move.b	(A0)+,(A6)+	Write output string
	dbf	D0,gifunp7

gifunp8	move.w	D4,D1
	sub.b	D3,D4	Back pixel offset
	bcs.s	gifunp9	Back address

	neg.b	D1
	and.w	D6,D1
	move.w	(A5),D0
	lsr.w	D1,D0
	bra.s	gifunp11	Evaluate

gifunp9	and.w	D6,D4
	subq.w	#2,A5	Back address
	cmpa.l	SP,A5	If GIF data sub-block done
	bls.s	gifunp12	 then get next sub-block
gifunp10	move.l	(A5),D0
	lsl.l	D1,D0
	swap	D0

gifunp11	and.w	D2,D0	D0: Code
	cmp.w	A4,D0
	beq.s	gifunp5	Clear
	cmp.w	D5,D0
	beq	gifunp17	EndOfInformation

	lea	(A1),A0	Look it up in the table
	add.w	D0,D0
	add.w	D0,A0
	add.w	D0,D0
	add.w	D0,A0
	cmpa.l	A2,A0	To prevent crash when
	bcc.s	gifunp16	LZW data corrupted
	move.w	(A0)+,D0
	movea.l	(A0),A0	String pointer
	addq.w	#1,D0	and count
	dbf	D7,gifunp6	Write next table entry
* - - - - - - - - - - - - - IT'S TIME FOR CODE LENGTH CHANGE
	addq.w	#1,D7
	cmpa.l	A3,A2	If string table full then
	beq.s	gifunp7	 write output but no new table entry
	cmpi.w	#12,D3	If string table not full but code
	beq.s	gifunp6	 length = max (12), write next entry

	subq.w	#1,D7	Set X-bit
	addx.w	D2,D2
	moveq	#1,D7
	lsl.w	D3,D7
	subq.w	#1,D7
	addq.w	#1,D3
	bra.s	gifunp6	Write next entry
* - - - - - - - - - - - - - GET GIF DATA SUB-BLOCK
gifunp12	moveq	#0,D0
	move.b	(SP),D0
	add.w	D0,D0	Get stack correction value
	lea	(SP),A5
	add.w	D0,A5	A5 -> first longword of sub-block
	move.l	(SP),(A5)	Make last longword the first of new
	movem.l	D1/D3/A1,18(A5)	Save D1/D3/A1

	move.w	4(A5),D1
	lea	(A5),A1
	sub.w	D1,A1

	move.l	14(A5),A0	Address to next sub-block
	move.b	(A0)+,D3	D3: Length of sub-block
	beq.s	gifunp15	Corrupted data
	add.w	D3,D1
	moveq	#-2,D0
	or.w	D1,D0
	move.w	D0,4(A5)
	sub.w	D0,D1

	lea	(A5),SP
	sub.w	D1,SP
	lsr.w	#1,D1

	subq.w	#1,D3
gifunp13	move.b	(A0)+,-(A1)	Copy sub-block - reverse byte-order
	dbf	D3,gifunp13	- to stack
	move.l	A0,14(A5)

gifunp14	move.b	D1,(SP)	Save halved stack correction value
	movem.l	18(A5),D1/D3/A1	Restore D1/D3/A1
	bra	gifunp10
* - - - - - - - - - - - - -
gifunp15	lea	512*6(A1),A2	To catch corrupted data
	lea	-2(A5),SP
	moveq	#1,D1
	bra.s	gifunp14
* - - - - - - - - - - - - -
gifunp16	moveq	#-1,D1	Error
	bra.s	gifunp18
gifunp17	moveq	#0,D1	EndOfInformation: LZW data OK
gifunp18	moveq	#0,D0
	move.b	(SP),D0
	add.w	D0,D0
	lea	30(SP,D0.W),SP
	move.l	D1,14*4(SP)	Set/clear flag for 'minor error'
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
	move.l	4(SP),A0	A0 -> Palette
	moveq	#8,D7	Check flag for sorted palette
	and.w	34(SP),D7	D7: Flags	(34=8.5*4)
	bne.s	gifunp19	Sorted
	bsr	GTSORT	GIF & TIFF palette sorting

gifunp19	move.l	(SP)+,A3	A3 -> unpacked image in GIF format
	move.l	(SP)+,A2	Memory block address
	move.l	(SP)+,A5	Size of one plane
	movem.l	(SP)+,D1-D2/D4-D7/A1/A4/A6
	move.l	A2,-(SP)	Save memory block address

	move.l	D1,D0	Number of colours
	subq.w	#1,D0
gifunp20	move.b	(A0)+,(A1)+	Do palette
	move.b	(A0)+,(A1)+
	move.b	(A0)+,(A1)+
	dbf	D0,gifunp20

	suba.l	A5,A6
	adda.l	A6,A4	A4 -> last plane of the image

	add.w	D2,D2
	movem.l	D2/D5/A4,-(SP)

	add.b	D7,D7
	bpl.s	gifunp21
* - - - - - - - - - - - - - interleaved lines
	addq.w	#7,D5	#lines+7
	lsr.w	#3,D5	/8
	mulu	#7,D2	Skip 7 rows
	add.w	D2,A1	Start row: 0,  Skip: 7
	bsr.s	gifunp25

	addq.w	#3,D5	#lines+3
	lsr.w	#3,D5	/8
	lsl.w	#2,D2
	add.w	D2,A4	Start row: 4,  Skip: 7
	bsr.s	gifunp25

	addq.w	#1,D5	#lines+1
	lsr.w	#2,D5	/4
	add.w	D2,D2
	bsr.s	gifunp24	Start row: 2,  Skip: 3 (=7-4)

	lsr.w	#1,D5     #lines/2,  Start row: 1,  Skip: 1 (=3-2)
	bsr.s	gifunp24
	bra.s	gifunp22
* - - - - - - - - - - - - -
gifunp21	bsr.s	pln8sep	No interleave
gifunp22	lea	12(SP),SP
	move.w	#73,-(SP)	MFREE
	trap	#1
	addq.l	#6,SP
	move.l	(SP)+,D0
gifunp23	movem.l	(SP)+,D1-D7/A0-A6
	bra	plnfill0

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
gifunp24	add.w	D2,A4
	add.w	D2,D2
	sub.w	D2,A1
gifunp25	subq.w	#1,D5
	bsr.s	pln8sep
	movem.l	4(SP),D2/D5/A4
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~
*	PLN8SEP
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN:
*  A3 -> Source GIF or 8-bit TIFF unpacked image
*  A4 -> Destination last bitplane
*  A5  : Bytes per plane
*  A6  : Bytes in whole image less one plane
*  D4.W: 'Bytes' (8-pixel sets) per row
*  D5  LSW: Number of lines,  MSW: Pixels per row
*  D6.W: Number of planes
* All registers corrupted except A5 & A6.  A3 & A4 point to "next line".

pln8sep	moveq	#1,D0
	and.w	D4,D0
	move.w	D0,A1	A1: odd byte in dest lines
	subq.w	#1,D4	D4: # of bytes/row -1
	move.w	D5,D7
	subq.w	#1,D7	D7: # of lines -1
	swap	D5

pln8sep1	neg.w	D5
	and.w	#7,D5
	move.w	D5,A0	A0: odd bytes in source lines

	lea	pln8sep4(PC),A2
	lsl.w	#2,D6
	sub.w	D6,A2

	move.w	D4,-(SP)
pln8sep2	swap	D7	Next line
	move.w	(SP),D4
pln8sep3	swap	D4	Next 8 pixels
	move.b	(A3)+,D7
	move.b	(A3)+,D6
	move.b	(A3)+,D5
	move.b	(A3)+,D4
	move.b	(A3)+,D3
	move.b	(A3)+,D2
	move.b	(A3)+,D1
	move.b	(A3)+,D0

	rol.b	#1,D7
	add.b	D6,D6
	addx.b	D7,D7
	roxl.b	#2,D6
	addx.b	D5,D5
	ror.b	#1,D5
	addx.b	D7,D7
	roxl.b	#2,D5
	addx.b	D6,D6
	addx.b	D4,D4
	ror.b	#1,D4
	addx.b	D7,D7
	roxl.b	#2,D4
	addx.b	D6,D6
	addx.b	D3,D3
	ror.b	#1,D3
	addx.b	D7,D7
	roxl.b	#2,D3
	addx.b	D6,D6
	addx.b	D2,D2
	ror.b	#1,D2
	addx.b	D7,D7
	roxl.b	#2,D2
	addx.b	D6,D6
	addx.b	D1,D1
	ror.b	#1,D1
	addx.b	D7,D7
	roxl.b	#2,D1
	addx.b	D6,D6
	addx.b	D0,D0
	ror.b	#1,D0
	addx.b	D7,D7
	roxl.b	#2,D0
	addx.b	D6,D6
	rol.b	#1,D5
	ror.b	#2,D4
	roxl.b	#3,D4
	addx.b	D5,D5
	roxl.b	#2,D4
	addx.b	D3,D3
	ror.b	#1,D3
	addx.b	D5,D5
	roxl.b	#2,D3
	addx.b	D4,D4
	addx.b	D2,D2
	ror.b	#1,D2
	addx.b	D5,D5
	roxl.b	#2,D2
	addx.b	D4,D4
	addx.b	D1,D1
	ror.b	#1,D1
	addx.b	D5,D5
	roxl.b	#2,D1
	addx.b	D4,D4
	addx.b	D0,D0
	ror.b	#1,D0
	addx.b	D5,D5
	roxl.b	#2,D0
	addx.b	D4,D4
	rol.b	#1,D3
	ror.b	#4,D2
	roxr.b	#4,D2
	addx.b	D3,D3
	roxl.b	#2,D2
	addx.b	D1,D1
	ror.b	#1,D1
	addx.b	D3,D3
	roxl.b	#2,D1
	addx.b	D2,D2
	addx.b	D0,D0
	ror.b	#1,D0
	addx.b	D3,D3
	roxl.b	#2,D0
	addx.b	D2,D2
	rol.b	#1,D1
	rol.b	#2,D0 <=> ror.b #6
	roxr.b	#2,D0
	addx.b	D1,D1
	roxl.b	#2,D0

	jmp	(A2)
	move.b	D7,(A4)
	suba.l	A5,A4
	move.b	D6,(A4)
	suba.l	A5,A4
	move.b	D5,(A4)
	suba.l	A5,A4
	move.b	D4,(A4)
	suba.l	A5,A4
	move.b	D3,(A4)
	suba.l	A5,A4
	move.b	D2,(A4)
	suba.l	A5,A4
	move.b	D1,(A4)
	suba.l	A5,A4
	move.b	D0,(A4)+
	adda.l	A6,A4

pln8sep4	swap	D4
	dbf	D4,pln8sep3
	sub.w	A0,A3
	add.w	A1,A4
	swap	D7
	dbf	D7,pln8sep2
	addq.l	#2,SP
	rts

*ðððððððððððððððððððððððððð
TIFCALC	movem.l	D1-D7/A0-A6,-(SP)
	bsr.s	tifcal
	movem.l	(SP)+,D1-D7/A0-A6
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
* Sub-routine to load registers with parameters read or calculated from
* image file header. (In addition converts PC header to ST format.)
* A4 untouched.  See ___unp for further info.  Also called by TIFUNP.

tifcal	move.l	A3,D7	D7 -> file start
	move.w	#'MM',D1
	move.w	(A3),D0
	move.w	D1,(A3)+
	lea	(A3),A1
	cmp.w	D1,D0
	beq	tifcal10	Already in Motorola format
* = = = = = = = = = = = = = CONVERT FROM INTEL TO MOTOROLA FORMAT
	cmpi.w	#'II',D0
	bne.s	tifcal2
	move.w	(A1),D0	'version'
	ror.w	#8,D0
	move.w	D0,(A1)+

	move.l	(A1),D0
	ror.w	#8,D0
	swap	D0
	ror.w	#8,D0
	move.l	D0,(A1)
	move.l	D0,A1
	lsr.b	#1,D0
	bcs.s	tifcal2	IFD on odd address

	adda.l	D7,A1	A1 -> IFD
	move.w	(A1),D4
	beq.s	tifcal2
	ror.w	#8,D4
	move.w	D4,(A1)+	Number of fields
* - - - - - - - - - - - - - For each field
tifcal1	move.w	(A1),D0	Tag
	ror.w	#8,D0
	move.w	D0,(A1)+

	move.w	(A1),D0	Type of info units
	beq.s	tifcal2
	ror.w	#8,D0
	move.w	D0,(A1)+

	move.l	(A1),D1	Number of info units
	ror.w	#8,D1
	swap	D1
	ror.w	#8,D1
	move.l	D1,(A1)+
	lea	(A1),A0	A0 -> field value (if direct)

	ext.l	D0
	move.l	D0,D2
	subq.l	#5,D2
	bcs.s	tifcal3	Field type OK if in the range 1-4
	beq.s	tifcal4	or =5; Rationals always indirect
tifcal2	moveq	#-1,D0	error
	rts
tifcal3	add.l	D1,D2
	ble.s	tifcal5	Other data direct if type+lengthó5
	subq.l	#1,D2
	bgt.s	tifcal4	Otherwise indirect except when
	cmp.w	#2,D0	type=2 and length=4
	beq.s	tifcal5

tifcal4	move.l	(A1),D2	For indirect field read and
	ror.w	#8,D2	convert address
	swap	D2
	ror.w	#8,D2
	move.l	D2,(A1)
	move.l	D2,A0	A0 -> field value (indirect)
	adda.l	D7,A0

	lsr.b	#1,D2
	bcc.s	tifcal5
	cmp.b	#2,D0
	bhi.s	tifcal2	word/long on odd address

tifcal5	addq.l	#4,A1	Convert field data themselves
	subq.w	#3,D0
	bhi.s	tifcal7	Longs or rationals (type 4 or 5)
	bcs.s	tifcal9	Bytes (or ascii): leave unchanged

tifcal6	move.w	(A0),D2	Words
	ror.w	#8,D2
	move.w	D2,(A0)+
	subq.l	#1,D1
	bhi.s	tifcal6
	bra.s	tifcal9

tifcal7	subq.w	#1,D0
	beq.s	tifcal8	Long (type 4)
	add.l	D1,D1	Double amount for rational
tifcal8	move.l	(A0),D2
	ror.w	#8,D2
	swap	D2
	ror.w	#8,D2
	move.l	D2,(A0)+
	subq.l	#1,D1
	bhi.s	tifcal8

tifcal9	subq.w	#1,D4
	bhi.s	tifcal1	Next field
* = = = = = = = = = = = = = Now in Motorola format

tifcal10	cmpi.w	#42,(A3)+	TIFF "version" MUST be = 42
	bne.s	tifcal2
	move.l	(A3),D0
	move.l	D0,A3
	lsr.w	#1,D0
	bcs.s	tifcal2	IFD on odd address
	adda.l	D7,A3

	moveq	#2,D2
	moveq	#296-256,D0	ResolutionUnit
	bsr	GETTAG	Unit =
	move.w	#10000,D6	  1 centimetre - in micrometres
	subq.w	#2,D2
	bhi.s	tifcal11
	move.w	#25400,D6	  1 inch - in micrometres

tifcal11	moveq	#282-256,D0	XResolution (pixels per unit)
	bsr	GETTAG
	bmi.s	tifcal14
	bsr.s	tifcal15
	beq.s	tifcal12	No resolution given
	move.l	D0,D5
	swap	D5
	moveq	#283-256,D0	YResolution (pixels per unit)
	bsr	GETTAG
	bmi.s	tifcal14
	bsr.s	tifcal15
	beq.s	tifcal12	No resolution given
	move.w	D0,D5
tifcal12	move.l	D5,A2

	moveq	#284-256,D0	PlanarConfiguration
	bsr.s	GET1TAG
	subq.w	#1,D2	Can't handle anything but
	bne.s	tifcal14	PlanarConfiguration=1 yet

	moveq	#277-256,D0	SamplesPerPixel
	bsr.s	GET1TAG
*	bmi.s	tifcal14
	move.w	D2,D5

	moveq	#258-256,D0	BitsPerSample
	bsr.s	GET1TAG
*	bmi.s	tifcal14
	move.w	(A0)+,D6
	cmpi.b	#8,D6
	bhi.s	tifcal14
	subq.w	#1,D5
	beq.s	tifcal13
	move.w	(A0)+,D1
	move.w	(A0)+,D2
	cmp.w	D2,D6	We don't accept dissimilar number
	bne.s	tifcal14	of RED & BLUE bits per pixel
	add.w	D1,D6
	add.w	D2,D6	Just add RGB bits per pixel
	cmp.w	D1,D2
	beq.s	tifcal13	Same for GREEN bits too ...
	subq.w	#6,D1	... or else demand 6 GREEN ...
	bne.s	tifcal14
	subq.w	#5,D2	... and 5 each of RED and BLUE bits
	bne.s	tifcal14

tifcal13	moveq	#256-256,D0	ImageWidth
	bsr.s	GETTAG
	ble.s	tifcal14
	move.w	D2,D5
	swap	D2
	tst.w	D2
	bne.s	tifcal14	Cannot handle widths above 65535
	swap	D5
	moveq	#257-256,D0	ImageLength
	bsr.s	GETTAG
	ble.s	tifcal14
	move.w	D2,D5
	swap	D2
	tst.w	D2
	bne.s	tifcal14	Cannot handle heights above 65535

	move.l	A2,D1
	bra	___unp

tifcal14	moveq	#-1,D0	error
	rts
*-~-~-~-~-~-~-~-~-~-~-~-~-~ Calculate pixel width or height in microns
tifcal15	beq.s	tifcal18
	move.l	4(A0),D0	Denominator
	tst.w	(A0)	1st word of numerator
	beq.s	tifcal16
	divu	D6,D2	Divide very large numerator
	bra.s	tifcal17
tifcal16	mulu	D6,D0	Otherwise multiply denominator
tifcal17	divu	D2,D0	Invert rational
	beq.s	tifcal18
	bvs.s	tifcal18
	rts
tifcal18	moveq	#0,D5	No width/height given
	rts

*~~~~~~~~~~~~~~~~~~~~~~~~~~
*	GETTAG
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN : A3->IFD, D7->File start, D0.W: Tag to look for -256
*	(D2: default first value)
* OUT: A0 -> Info, or 0 if not found
*      D0.L: Type of info unit, 0=Not found, Negative=error (odd address)
*      D1.L: Number of them
*      D2.L: First value  (untouched if not found)
* GET1TAG is same as GETTAG except it sets default to 1.
*~~~~~~~~~~~~~~~~~~~~~~~~~~
GET1TAG	moveq	#1,D2
GETTAG	add.w	#256,D0
	movem.l	D4/A3,-(SP)
	move.w	(A3)+,D4	Number of fields
	bra.s	gettag2
gettag1	cmp.w	(A3)+,D0	Next tag
	beq.s	gettag3	Tag found
	lea	10(A3),A3
gettag2	dbf	D4,gettag1
	moveq	#0,D0
	move.l	D0,A0
	bra.s	gettag10

gettag3	lea	(A3),A0
	move.w	(A0)+,D0	Type of info unit
	beq.s	gettag5  error: type 0
	move.l	(A0)+,D1	Number of them
	ext.l	D0
	move.l	D0,D2
	subq.l	#5,D2
	beq.s	gettag4
	bhi.s	gettag5  error: type > 5
	add.l	D1,D2
	ble.s	gettag6
	subq.l	#1,D2
	bgt.s	gettag4
	cmp.w	#2,D0
	beq.s	gettag6
gettag4	movea.l	(A0),A0	Get address
	adda.l	D7,A0

	move.l	A0,D2
	lsr.w	#1,D2
	bcc.s	gettag6	Even address
	cmp.w	#2,D0
	bls.s	gettag6	Or else byte values
gettag5	moveq	#-1,D0	Error
	bra.s	gettag10

gettag6	moveq	#3,D2
	cmp.w	D2,D0
	bgt.s	gettag8
	bmi.s	gettag7
	move.w	(A0),D2
	bra.s	gettag9
gettag7	move.b	(A0),D2
	bra.s	gettag9
gettag8	move.l	(A0),D2
gettag9	ext.l	D0
gettag10	movem.l	(SP)+,D4/A3
	rts

*==========================
TIFUNP	movem.l	D2-D7/A0-A6,-(SP)
	clr.l	-(SP)	Minor error: Initiate to NO
	bsr	tifcal  Read header
	bmi	tifunp41	error => exit
	move.l	D3,-(SP)	Save picture size in bytes
	movem.l	D1-D2/D4-D7/A1/A4/A6,-(SP)
	pea	(A5)
	move.w	D1,D3	Save # of colours

* - - - - - - - - - - - - - Prepare image data for unpacking
	pea	(6*4096+256+512+768)(A6) Space for string table +
* ini. strings + freq tab + palette + 1 byte/pixel in image =
	move.w	#72,-(SP)	MALLOC
	trap	#1	Request temporary memory block
	addq.l	#6,SP
	move.l	D0,-(SP)	Save Memory block address
	bne.s	tifunp1
	moveq	#-39,D0	D0: -39: Not enough memory
	lea	12*4(SP),SP	mem addr, 10 registers & image size
	bra	tifunp41

* - - - - - - - - - - - - - Do palette
tifunp1	move.l	D0,A5  A5-> block start address where palette will go

	move.w	D3,D1	Number of colours
	beq.s	tifunp7	"No colours" (RGB)

	moveq	#320-256,D0	ColorMap
	bsr	GETTAG
	bgt.s	tifunp4
	bmi.s	tifunp8	error

	moveq	#262-256,D0	PhotometricInterpretation
	bsr	GET1TAG	Assume gray/black&white and 0=black
	moveq	#291-256,D0	GrayResponseCurve
	bsr	GETTAG
	moveq	#0,D1
	not.b	D1	#255
	moveq	#1,D0
	lsl.w	D6,D0
	subq.w	#1,D0	255/(# of colours -1)
	divu	D0,D1	D1: Step
	moveq	#0,D0	D0: Start value=0
	subq.w	#1,D2
	beq.s	tifunp2
	subq.w	#8,D2
	bls.s	tifunp8  error (P image without palette or R with ó8 planes)
	not.b	D0	D0: Start value=255
	neg.b	D1
tifunp2	subq.w	#1,D3
tifunp3	move.b	D0,(A5)+	create greyscale palette
	move.b	D0,(A5)+
	move.b	D0,(A5)+
	add.b	D1,D0
	dbf	D3,tifunp3
	bra.s	tifunp7

tifunp4	move.w	D3,D0
	add.w	D0,D0	offset to 2nd component table
	move.w	D0,D1
	add.w	D1,D1	offset to 3rd component table
	bra.s	tifunp6
tifunp5	move.b	(A0),(A5)+	Copy TIFF palette
	move.b	0(A0,D0.W),(A5)+
	move.b	0(A0,D1.W),(A5)+
	addq.l	#2,A0
tifunp6	dbf	D3,tifunp5

* - - - - - - - - - - - - - Do the image data
tifunp7	moveq	#278-256,D0	RowsPerStrip
	bsr	GETTAG
	move.l	D5,D4
	swap	D4	Number of pixels per row
	mulu	D6,D4	*planes
	addq.l	#7,D4
	lsr.l	#3,D4	D4: Bytes per row
	move.l	D4,D3
	move.l	D2,D6	D6: Rows per strip
	mulu	D6,D3	D3: Bytes per strip
	subq.w	#1,D4

	moveq	#273-256,D0	StripOffsets
	bsr	GETTAG
	bgt.s	tifunp9

tifunp8	move.w	#73,-(SP)	MFREE	at error
	trap	#1
	lea	2+12*4(SP),SP	mem addr, 10 registers & image size
	moveq	#-1,D0	error
	bra	tifunp41

tifunp9	ror.w	#1,D0	Offset format
	swap	D0
	move.w	D1,D0	Number of strips

	move.l	D7,-(SP)	Pointer to file start
	pea	(A0)	Address of offset table
	move.l	D0,-(SP)	Type & number of offsets

	moveq	#259-256,D0	Compression
	bsr	GET1TAG
	move.w	D2,D0
	subq.w	#1,D2
	beq.s	tifunp11	Uncompressed, 1

	subq.w	#5,D0
	beq.s	tifunp18	LZW, 5
	lea	tifunp44(PC),A4	A4 -> routine for packbits
	add.w	D0,D0
	beq.s	tifunp12	PackBits, 32773 (=$8005)

tifunp10	lea	12(SP),SP
	bra.s	tifunp8	error

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ UNCOMPRESSED AND PACKBITS COMPRESSED TIFF
* D0  : Work register
* D1  : Work register
* D5  : Count: Number of lines
* D6  : Number of lines per strip
* D2  : Number of lines in last strip
* D7.W: Number of strips;  D7.MSW: Type of strip offsets - neg=W, pos=L
* D3  : Bytes per strip
* D4  : Number of bytes/line
* A1 -> Strip offset table
* A2 -> TIFF file start
* A3 -> Destination strip start
* A4 -> Routine unpacking 1 strip /In Packbits routine: Destination end of line
* A5 -> Source
* A6 -> Destination
* A0 -> Palette (Not used in Packbits routine)

tifunp11	lea	tifunp42(PC),A4	A4 -> routine for uncompressed TIFF
tifunp12	movem.l	(SP)+,D7/A1-A2  Type&number of strips; Addr of offs-tab; File start
	move.l	(SP),A0
	lea	768(A0),A3	A3 -> Destination strip start address
	pea	(A3)	Save destination address

	move.w	D6,D2	rows per strip
	mulu	D7,D2	* number of strips
	sub.w	D5,D2	- rows total in image = rows in last strip

	bra.s	tifunp16
* - - - - - - - - - - - - - For each strip
tifunp13	add.l	D3,A3
	lea	(A3),A6
	lea	(A2),A5	File start +
	tst.l	D7
	bpl.s	tifunp14
	add.w	(A1)+,A5	+ offset = Address to strip
	bra.s	tifunp15
tifunp14	add.l	(A1)+,A5

tifunp15	jsr	(A4)	Unpack one strip

tifunp16	move.w	D6,D5	rows per strip
	tst.w	D7
	bne.s	tifunp17
	move.w	D2,D5	rows in last strip
tifunp17	subq.w	#1,D5	D5: Number of lines - 1
	dbcs	D7,tifunp13	Next strip
	bra	tifunp39

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ LZW Depack

tifunp18	moveq	#317-256,D0	Predictor
	bsr	GET1TAG
	subq.w	#1,D2
	bne.s	tifunp10  until I implement support for prediction

	move.l	12(SP),A0
	lea	1024(A0),A0	A0 points to after initial strings
	lea	6*256(A0),A1
	move.w	#255,D0
	move.w	D0,D2
	moveq	#-1,D1
tifunp19	move.b	D0,-(A0)	Initialize string table
	move.l	A0,-(A1)
	move.w	D1,-(A1)
	dbf	D0,tifunp19	A1 -> string table
	lea	6*4096+512(A1),A6	A6 -> destination

	lea	(A6),A3
	moveq	#1,D0	Initial count table entries = one
tifunp20	move.w	D0,-(A3)	(count of zero reserved for special
	dbf	D2,tifunp20	purpose)

	pea	(A6)	Save destination address
	pea	(A1)	Save string table address
	move.l	D3,-(SP)	Bytes per strip
	pea	(A6)	Save destination address

	bra	tifunp32

*~~~~~~~~~~~~~~~~~~~~~~~~~~ For each strip to be unpacked

tifunp21	movem.l	4(SP),D5/A1/A6
	add.l	D5,12(SP)
	tst.l	D2
	bpl.s	tifunp22
	add.w	(A0)+,A5
	bra.s	tifunp23
tifunp22	add.l	(A0)+,A5
tifunp23	movem.l	D2/A0,16(SP)

	move.w	A5,D2
	and.w	#1,D2
	suba.w	D2,A5
	lsl.w	#3,D2
	moveq	#16,D4
	sub.w	D2,D4	D4: Pixels to next word boundary

	moveq	#$F,D6	D6: 15
	lea	256.W,A4	A4: Clear code
	move.w	#257,D5	D5: EOI code

tifunp24	move.w	#$1FF,D2  LZW clear: D2: Mask
	moveq	#9,D3	D3: Code length
	move.w	#253,D7	D7: # of codes to read -1
*	move.w	#254,D7	D7: # of codes to read -1
	lea	6*258(A1),A2	A2 -> Next entry
	bra.s	tifunp27

tifunp25	move.w	D0,(A2)+	Write next entry
	move.l	A6,(A2)+
* - - - - - - - - - - - - - Count occurences of lead byte
	moveq	#0,D1	to give an idea of colour frequences
	move.b	(A0),D1	for later palette sorting
	add.w	D1,D1
	addq.w	#1,0(A3,D1.W)
* - - - - - - - - - - - - -
tifunp26	move.b	(A0)+,(A6)+	Write output string
	dbf	D0,tifunp26

tifunp27	sub.b	D3,D4	Count down to word boundary
	bcs.s	tifunp29	Passed
	beq.s	tifunp28	On it

	move.w	(A5),D0	Not there yet
	lsr.w	D4,D0
	bra.s	tifunp30

tifunp28	move.w	(A5)+,D0
	moveq	#16,D4
	bra.s	tifunp30

tifunp29	move.b	D4,D1
	neg.b	D1
	and.w	D6,D4
	move.l	(A5),D0
	lsl.l	D1,D0
	swap	D0
	addq.w	#2,A5	Forward address

tifunp30	and.w	D2,D0	D0: Code
	cmp.w	A4,D0
	beq.s	tifunp24	Clear
	cmp.w	D5,D0
	beq.s	tifunp32	EndOfInformation

	lea	(A1),A0	Look it up in the table
	add.w	D0,D0
	add.w	D0,A0
	add.w	D0,D0
	add.w	D0,A0
	cmpa.l	A2,A0	To prevent crash when
	bcc.s	tifunp31	LZW data corrupted
	move.w	(A0)+,D0
	movea.l	(A0),A0	String pointer
	addq.w	#1,D0	and count
	dbf	D7,tifunp25	Write next table entry
* - - - - - - - - - - - - - IT'S TIME FOR CODE LENGTH CHANGE
	addq.w	#1,D7
	cmpa.l	A3,A2	If string table full then
	beq.s	tifunp26	 write output but no new table entry
	cmpi.w	#12,D3	If string table not full but code
	beq.s	tifunp25	 length = max (12), write next entry

	subq.w	#1,D7	Set X-bit
	addx.w	D2,D2
	moveq	#1,D7
	lsl.w	D3,D7
	subq.w	#1,D7
	addq.w	#1,D3
	bra.s	tifunp25
* - - - - - - - - - - - - - LZW UNPACKING OF STRIP DONE
tifunp31	moveq	#-1,D2
	move.l	D2,28+12*4(SP)	error

tifunp32	movem.l	16(SP),D2/A0/A5	A5 -> file start, A0 -> offsets
	dbf	D2,tifunp21

*~~~~~~~~~~~~~~~~~~~~~~~~~~ ALL STRIPS UNPACKED

	move.l	(SP)+,A1	A1 -> Unpacked image data
	lea	24(SP),SP
	move.l	(SP),A0	A0 -> Palette
	move.l	A1,-(SP)
	cmp.w	#256,14(SP)	Sort only when 256 colours
	bne.s	tifunp38	(14=3*4+2)
	lea	(A0),A1
	lea	3*256(A1),A2	Already sorted?
	moveq	#4,D4	Check 5 times 16 colours
tifunp33	moveq	#3*16-1,D3
tifunp34	moveq.l	#$C0,D0
	moveq.l	#$C0,D1
	moveq.l	#$C0,D2
	and.b	(A1)+,D1
	and.b	(A2)+,D2
	bne.s	tifunp35
	cmp.b	D0,D1
	beq.s	tifunp37
tifunp35	tst.b	D1
	bne.s	tifunp36
	cmp.b	D0,D2
tifunp36	dbeq	D3,tifunp34
	beq.s	tifunp37
	lea	(A0),A1
	dbf	D4,tifunp33
	bra.s	tifunp38	Already sorted!
tifunp37	bsr	GTSORT	Sort

tifunp38	move.l	(SP)+,A3	A3 -> unpacked image in TIFF format
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷
tifunp39	move.l	(SP)+,A2	Memory block address
	move.l	(SP)+,A5	Size of one plane
	movem.l	(SP)+,D1-D2/D4-D7/A1/A4/A6
	move.l	A2,-(SP)	Save memory block address

	move.l	D1,D0	Number of colours
	subq.w	#1,D0
tifunp40	move.b	(A0)+,(A1)+	Do palette
	move.b	(A0)+,(A1)+
	move.b	(A0)+,(A1)+
	dbf	D0,tifunp40

	suba.l	A5,A6
	adda.l	A6,A4	A4 -> last plane of the image
	bsr.s	plnsep

	move.w	#73,-(SP)	MFREE
	trap	#1
	addq.l	#6,SP
	move.l	(SP)+,D0
tifunp41	movem.l	(SP)+,D1-D7/A0-A6
	bra	plnfill0

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ UNCOMPRESSED TIFF
tifunp42	move.w	D4,D1
tifunp43	move.b	(A5)+,(A6)+
	dbf	D1,tifunp43
	dbf	D5,tifunp42	Next line
	rts

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ PACKBITS COMPRESSED TIFF
tifunp44	pea	(A4)	Save A4
tifunp45	lea	(A6),A4	NEXT LINE
	adda.w	D4,A4	A4-> End of line in destination

tifunp46	moveq	#0,D1	Next command
tifunp47	move.b	(A5)+,D1	1st command byte
	bpl.s	tifunp49
	neg.b	D1
	bmi.s	tifunp47	$80 not used
	move.b	(A5)+,D0
tifunp48	move.b	D0,(A6)+
	dbf	D1,tifunp48
	bra.s	tifunp50

tifunp49	move.b	(A5)+,(A6)+
	dbf	D1,tifunp49

tifunp50	cmpa.l	A4,A6	Line end reached?
	bcs.s	tifunp46	No => next command
	dbhi	D5,tifunp45	Next line
	beq.s	tifunp51	All lines OK
	moveq	#-1,D5
	move.l	D5,15*4(SP)	Line end passed => ERROR
tifunp51	move.l	(SP)+,A4	Restore A4
	rts


*~~~~~~~~~~~~~~~~~~~~~~~~~~
*	PLNSEP
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* IN:
*  A3 -> Source GIF or 8-bit TIFF unpacked image
*  A4 -> Destination last bitplane
*  A5  : Bytes per plane
*  A6  : Bytes in whole image less one plane
*  D4.W: 'Bytes' (8-pixel sets) per row
*  D5  LSW: Number of lines,  MSW: Pixels per row
*  D6.W: Number of planes
* All registers trashed except A5 & A6.  A3 & A4 point to "next line".

plnsep	moveq	#1,D0
	and.w	D4,D0
	move.w	D0,A1	A1: odd byte in dest lines
	subq.w	#1,D4	D4: # of bytes/row -1
	move.w	D5,D7
	subq.w	#1,D7	D7: # of lines -1
 	swap	D5

	move.w	D6,D0
	subq.w	#8,D0
	beq	pln8sep1	8 planes
	bhi	plnsep4	more than 8 planes
	addq.w	#4,D0
	bne	plnsep5	Less than 8 but not 4 planes
* - - - - - - - - - - - - - 4 PLANES
	neg.w	D5
	and.w	#7,D5
	lsr.w	#1,D5
	move.w	D5,A0	A0: odd bytes in source lines

	move.w	D4,-(SP)
plnsep1	swap	D7	Next line
	move.w	(SP),D4
plnsep2	swap	D4	Next 8 pixels
	move.b	(A3)+,D7
	move.b	(A3)+,D6
	move.b	(A3)+,D5
	move.b	(A3)+,D4
	add.b	D7,D7
	addx.b	D3,D3
	add.b	D7,D7
	addx.b	D2,D2
	add.b	D7,D7
	addx.b	D1,D1
	add.b	D7,D7
	addx.b	D0,D0
	add.b	D7,D7
	addx.b	D3,D3
	add.b	D7,D7
	addx.b	D2,D2
	add.b	D7,D7
	addx.b	D1,D1
	add.b	D7,D7
	addx.b	D0,D0
	add.b	D6,D6
	addx.b	D3,D3
	add.b	D6,D6
	addx.b	D2,D2
	add.b	D6,D6
	addx.b	D1,D1
	add.b	D6,D6
	addx.b	D0,D0
	add.b	D6,D6
	addx.b	D3,D3
	add.b	D6,D6
	addx.b	D2,D2
	add.b	D6,D6
	addx.b	D1,D1
	add.b	D6,D6
	addx.b	D0,D0
	add.b	D5,D5
	addx.b	D3,D3
	add.b	D5,D5
	addx.b	D2,D2
	add.b	D5,D5
	addx.b	D1,D1
	add.b	D5,D5
	addx.b	D0,D0
	add.b	D5,D5
	addx.b	D3,D3
	add.b	D5,D5
	addx.b	D2,D2
	add.b	D5,D5
	addx.b	D1,D1
	add.b	D5,D5
	addx.b	D0,D0
	add.b	D4,D4
	addx.b	D3,D3
	add.b	D4,D4
	addx.b	D2,D2
	add.b	D4,D4
	addx.b	D1,D1
	add.b	D4,D4
	addx.b	D0,D0
	add.b	D4,D4
	addx.b	D3,D3
	add.b	D4,D4
	addx.b	D2,D2
	add.b	D4,D4
	addx.b	D1,D1
	add.b	D4,D4
	addx.b	D0,D0	32 æs
	move.b	D3,(A4)
	suba.l	A5,A4
	move.b	D2,(A4)
	suba.l	A5,A4
	move.b	D1,(A4)
	suba.l	A5,A4
	move.b	D0,(A4)+
	adda.l	A6,A4
plnsep3	swap	D4
	dbf	D4,plnsep2
	sub.w	A0,A3
	add.w	A1,A4
	swap	D7
	dbf	D7,plnsep1
	addq.l	#2,SP
	rts
* - - - - - - - - - - - - - MORE THAN 8 PLANES
plnsep4	sub.l	A6,A4
	move.l	A6,D1
	neg.l	D1
	move.l	D1,A6
	move.l	A5,D1
	neg.l	D1
	move.l	D1,A5
* - - - - - - - - - - - - - ANY NUMBER OF PLANES (used for 3,5,6,7 & 9+ planes)
plnsep5	addq.w	#2,D0
	ble.s	plnsep11	less than 3 planes

	addq.l	#1,A6
	subq.w	#1,D6
	move.w	D6,A0
	move.w	D5,A2

plnsep6	move.w	A2,D5	Next line
plnsep7	move.b	(A3)+,D1	New source byte
	moveq	#7,D2
plnsep8	move.b	(A4),D0	Next bit
	add.b	D1,D1
	addx.b	D0,D0
	move.b	D0,(A4)
	suba.l	A5,A4
	subq.w	#1,D6
plnsep9	dbcs	D2,plnsep8	Next pixel
	bcc.s	plnsep7
	adda.l	A6,A4
	move.w	A0,D6
	dbf	D5,plnsep9
	subq.l	#1,A4
plnsep10	move.b	(A4),D0	Next line end
	lsl.b	D2,D0
	move.b	D0,(A4)
	suba.l	A5,A4
	dbf	D6,plnsep10
	adda.l	A6,A4
	move.w	A0,D6
	adda.w	A1,A4
	dbf	D7,plnsep6
	rts
* - - - - - - - - - - - - - 1 PLANE
plnsep11	beq.s	plnsep14	2 planes
	move.w	D4,A2
plnsep12	move.w	A2,D4	Next line
plnsep13	move.b	(A3)+,(A4)+	Next 8 pixels
	dbf	D4,plnsep13
	add.w	A1,A4
	dbf	D7,plnsep12
	rts
* - - - - - - - - - - - - - 2 PLANES
plnsep14	neg.w	D5
	and.w	#7,D5
	lsr.w	#2,D5	D5: odd bytes in source lines

	move.w	D4,A2
plnsep15	move.w	A2,D4	Next line
plnsep16	move.b	(A3)+,D3	Next 8 pixels
	move.b	(A3)+,D2
	moveq	#3,D6
plnsep17	add.b	D3,D3
	addx.b	D1,D1
	add.b	D3,D3
	addx.b	D0,D0
	dbf	D6,plnsep17
	moveq	#3,D6
plnsep18	add.b	D2,D2
	addx.b	D1,D1
	add.b	D2,D2
	addx.b	D0,D0
	dbf	D6,plnsep18
	move.b	D1,(A4)
	suba.l	A5,A4
	move.b	D0,(A4)+
	adda.l	A6,A4
plnsep19	dbf	D4,plnsep16
	sub.w	D5,A3
	add.w	A1,A4
	dbf	D7,plnsep15
	rts


********** GTSORT ********* GIF and TIFF palette sorting
* Corrupts all registers
* IN:  4(SP) -> Image data, 8(SP) -> Palette, 12(SP): # of bytes in one plane
* 16(SP): # of colours
* A3 -> Frequency table - $200 bytes; below that $6100 bytes free for use
* (and below that palette). All in all $6300 bytes (+ $300 bytes palette)
* OUT: A0 -> new palette
mkpaldat	dc.b	32,12,10,8,8,7,7,6,5,6,7,9,0,7,7,7,9,15,28,66,0
*		0 1        2         3         4      5    6
*		1  2  3  4 5 6 7 8 9 A B C   B A 9 8 7  6  5

GTSORT	move.w	#$FF,D7
	move.l	8(SP),A6	A6 -> palette

	move.l	16(SP),D1	Number of colours
	moveq	#-$11,D0
	add.w	D1,D0
	add.w	D1,D1
	move.w	D1,-(SP)	# of colours * 2 ($200 for 8 planes)
	move.w	D0,-(SP)	# of colours - $11 (#$EF  - " - )

	addq.w	#8,D0
	bpl.s	gtsort4	More than 8 colours
	addq.w	#4,D0
	bpl.s	gtsort2	More than 4 colours
	addq.w	#2,D0
	bpl.s	gtsort1	More than 2 colours
	lea	(A6),A0	Two colours
	lea	6(A6),A1
	move.l	(A0)+,(A1)+
	move.w	(A0)+,(A1)+
gtsort1	lea	(A6),A0
	lea	12(A6),A1
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
gtsort2	lea	(A6),A0
	lea	24(A6),A1
	moveq	#5,D0	Copy 6 longwords = 24 bytes
gtsort3	move.l	(A0)+,(A1)+		= 8 colours
	dbf	D0,gtsort3
gtsort4
* - - - - - - - - - - - - -
	lea	-$800(A3),A2	Make a crude
	move.w	D7,D2	luminosity table ...
	lea	(A6),A0
	moveq	#0,D1
gtsort5	moveq	#0,D0
	move.b	(A0)+,D0
	move.b	(A0)+,D1
	add.w	D1,D0
	move.b	(A0)+,D1
	add.w	D1,D0
	move.w	D0,(A2)+
	dbf	D2,gtsort5
	lea	(A2),A5

	pea	$FFF.W  dummy for count word; "bad" for best result
	clr.w	-(SP)	Clear flag for finish sorting
*	move.w	#-1,-(SP)	Set flag for finish sorting
* - - - - - - - - - - - - - <<<<<<<<<<<<<<<<<
* A3 -> frequency table
* A5 -> Colour number table (to be)
* A6 -> palette
* D7.W: 255
	lea	-$1400(A3),A0
	lea	$200(A0),A1
	lea	$200(A1),A2
	lea	mkpaldat(PC),A4
	moveq	#0,D1
	moveq	#0,D2
	moveq	#0,D3
	moveq	#5,D4
	moveq	#6,D5
	moveq	#3,D6
	bra.s	gtsort8
gtsort6	add.w	D4,D1
	add.w	D5,D2
	add.w	D6,D3
	move.w	D1,(A0)+
	move.w	D2,(A1)+
	move.w	D3,(A2)+
gtsort7	dbf	D0,gtsort6
	addq.w	#5,D4
	addq.w	#6,D5
	addq.w	#3,D6
gtsort8	moveq	#0,D0
	move.b	(A4)+,D0
	bgt.s	gtsort7
	bra.s	gtsort11
gtsort9	add.w	D4,D1
	add.w	D5,D2
	add.w	D6,D3
	move.w	D1,(A0)+
	move.w	D2,(A1)+
	move.w	D3,(A2)+
gtsort10	dbf	D0,gtsort9
	subq.w	#5,D4
	subq.w	#6,D5
	subq.w	#3,D6
gtsort11	moveq	#0,D0
	move.b	(A4)+,D0
	bgt.s	gtsort10

gtsort12	move.w	D7,D0
	lea	-$400(A3),A2	Necessary when less than 256 colours
	lea	(A2),A0
gtsort13	move.w	(A3)+,(A0)+	Copy frequency table to after
	dbf	D0,gtsort13	colour number table

	lea	(A5),A1	Now arrange colour numbers according
	move.w	D7,D4	to frequency in a "colour number
gtsort14	move.w	D7,D1	table" replacing the "colour table".
	moveq	#0,D0
	lea	(A2),A0
gtsort15	cmp.w	(A0)+,D0
gtsort16	dbcs	D1,gtsort15
	bcc.s	gtsort17
	lea	-2(A0),A3
	move.w	(A3),D0
	move.w	D1,D2
	bra.s	gtsort16
gtsort17	move.w	D7,D3
	sub.w	D2,D3
	move.w	D3,(A1)+
	clr.w	(A3)	Clear entry in frequency table
	dbf	D4,gtsort14
*~~~~~~~~~~~~~~~~~~~~~~~~~~
* The situation thus far:
* $5700 bytes free
*  $200 bytes luminosity table
*  $200 bytes colour number table (A5), previously simplified colour table
*  $200 bytes free (previously work copy of combined frequency table)
*  $200 bytes free (previously work copy of frequency table)
*  $200 bytes unused
*  $200 bytes frequency table
*""""""""""""""""""""""""""
	lea	-$800(A5),A3	A3 -> space for pre-sorted palette
	lea	-$600(A3),A4

	lea	(A5),A1
	lea	$20(A5),A5
* A5 -> colour 16 in colour number table
	moveq	#0,D1
	lea	(A3),A2	Use the colour number table to
	move.w	D7,D2	create a corresponding palette,
gtsort18	move.w	(A1),D0	where each colour component has been
	add.w	D0,D0	truncated (to correspond to the
	add.w	(A1)+,D0	'simplified colours' used when
	lea	(A6),A0	colour equality was determined)
	add.w	D0,A0	The palette is written to the
	clr.w	D0	$300 bytes below luminosity table
	move.b	(A0)+,D0
	add	D0,D0
	move.w	0(A4,D0.W),(A2)+
	clr.w	D0
	move.b	(A0)+,D0
	add.w	D0,D0
	lea	$200(A4),A0
	add.w	D0,A0
	move.w	(A0),(A2)+
	clr.w	D0
	move.b	(A0)+,D0
	add.w	D0,D0
	lea	$400(A4),A0
	add.w	D0,A0
	move.w	(A0),(A2)+
	dbf	D2,gtsort18

* The situation thus far:
* $5400 bytes free
*  $300 bytes palette (components truncated) corresponding to below table
*  $200 bytes luminosity table
*   $20 bytes: 16 first entries of colour number table
*  $1E0 bytes: rest of colour number table (most frequent numbers first)
*   $20 bytes 'offset table' (into following 2nd colour number table)
*  $1E0 bytes free, were rest of 2nd colour number table will go
*  $200 bytes free
*  $200 bytes frequency table (similar colours combined)
*  $200 bytes frequency table

	lea	(A1),A4

*"""""""""""""""""""""""""" A4 -> Free workspace after colour number table
gtsort19	moveq	#$F,D0	Initiate 'offset table'
	moveq	#$20,D1
gtsort20	move.w	D1,(A1)+
	addq.w	#2,D1
	dbf	D0,gtsort20

	lea	$60(A3),A2	A2 -> colour 16 in new palette
*	move.w	#$EF,-(SP)
	move.w	6(SP),-(SP)	$EF
	bmi	gtsort54
gtsort21	move.w	(A2)+,D1	Truncated colour
	move.w	(A2)+,D2
	move.w	(A2)+,D3
	moveq	#$F,D6
	lea	(A4),A1	Offsets
	lea	(A3),A0	Base palette

*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ getclose
* IN:
*  A0 -> palette to compare with
*  A1 -> offsets
*  D6: number of colours to check
*  D1-D3: R,G,B
* OUT:
*  A6 -> offset for closest colour (D5: Distance)
* Affected: D0/D4-D7 A0-A1/A6

	moveq	#-1,D5

gtsort22	tst.w	(A1)+
	bpl.s	gtsort23
	addq.l	#6,A0
	bra.s	gtsort30
gtsort23	moveq	#0,D7
	move.w	D1,D4
	sub.w	(A0)+,D4
	bcc.s	gtsort24
	exg	D4,D7
	neg.w	D7
gtsort24	move.w	D2,D0
	sub.w	(A0)+,D0
	bcc.s	gtsort25
	neg.w	D0
	cmp.w	D0,D7
	bcc.s	gtsort26
	move.w	D0,D7
	bra.s	gtsort26
gtsort25	cmp.w	D0,D4
	bcc.s	gtsort26
	move.w	D0,D4
gtsort26	move.w	D3,D0
	sub.w	(A0)+,D0
	bcc.s	gtsort27
	neg.w	D0
	cmp.w	D0,D7
	bcc.s	gtsort28
	move.w	D0,D7
	bra.s	gtsort28
gtsort27	cmp.w	D0,D4
	bcc.s	gtsort28
	move.w	D0,D4
gtsort28	add.w	D7,D4
	cmp.w	D5,D4	D5: Min. distance
	dbls	D6,gtsort22
	bcs.s	gtsort29
	bhi.s	gtsort31
	move.w	-2(A1),D0	When distance equal, use the least
	cmp.w	(A6),D0	used colour.
	bhi.s	gtsort30
gtsort29	move.w	D4,D5
	lea	-2(A1),A6	Pointer to offset
gtsort30	dbf	D6,gtsort22

gtsort31	lea	(A4),A0
	add.w	(A6),A0
	moveq	#$20,D0
	add.w	(A6),D0
	move.w	(A5)+,(A0)	Colour number
	move.w	D0,(A6)
*	cmp.w	#$200,D0
	sub.w	10(SP),D0	$200
	bcs	gtsort53	Not filled
	tst.w	2(SP)	sortflag
	bmi	gtsort52	Filled and last pass

	sub.w	#$20,D0
	bcc.s	gtsort33	Filled and overflow

	move.w	(A5),D1	Filled but no overflow
	add.w	D1,D1	Make it last pass if only
	lea	$400(A4),A0	unused colours left
	add.w	D1,A0
	cmp.w	#1,(A0)
	bne	gtsort53
	st	2(SP)	sortflag
	bra	gtsort52
gtsort32
*÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷÷ Overflow
gtsort33	move.w	(SP),D1
	moveq	#$F,D2
	cmp.w	6(SP),D1	sortbest
	bmi.s	gtsort35

	subq.b	#1,5(SP)	nsorts
	bne.s	gtsort37
	move.l	20(SP),A6	Accept if no progress
	lea	-$200(A4),A5

	lea	$400(A4),A3	A3 -> frequence table
	move.w	#$FF,D7
	moveq	#-1,D1
	lea	$300(A4),A0
gtsort34	move.w	(A0)+,D0	Set frequencies of base colours
	add.w	D0,D0	to $FFFF
	move.w	D1,0(A3,D0.W)
	dbf	D2,gtsort34
	addq.l	#2,SP
	st	(SP)	sortflag
	bra	gtsort12

gtsort35	move.w	D1,6(SP)
	move.w	#$F,4(SP)	15 passes without progress
	moveq	#7,D0
	lea	-$200(A4),A0
	lea	$300(A4),A1
gtsort36	move.l	(A0)+,(A1)+
	dbf	D0,gtsort36
* - - - - - - - - - - - - -
* A6 -> offset for most used colour
* (A3 -> palette, A4 -> offset base)

gtsort37	lea	$400(A4),A1	A1 -> frequency table

	move.w	(A6),D3
*	and.w	#$7FFF,D3
	lea	$20(A6),A0
	sub.l	A4,A0
	sub.w	A0,D3
	asr.w	#5,D3	Number of secondary colours

	lea	-$400(A6),A5	Find, among colours using the most
	move.w	-$200(A6),D0	used base colour, the one with 
	add.w	D0,D0	luminance furthest from base colour
	move.w	0(A5,D0.W),D4	D4: Luminance of base colour
	moveq	#0,D1
	moveq	#1,D5
	move.w	$20(A6),D2
	bra.s	gtsort40

gtsort38	lea	$20(A6),A6
	move.w	(A6),D0
	add.w	D0,D0
	cmp.w	0(A1,D0.W),D5
	beq.s	gtsort40	Skip any unused colour
	move.w	0(A5,D0.W),D0
	sub.w	D4,D0
	bpl.s	gtsort39
	neg.w	D0
gtsort39	cmp.w	D0,D1
gtsort40	dbcs	D3,gtsort38
	bcc.s	gtsort41
	move.w	(A6),D2
	move.w	D0,D1
	bra.s	gtsort40

gtsort41	moveq	#-$10,D0
	lea	-$1E0(A4),A5
	lea	(A5),A6	Find position in frequency sorted table
gtsort42	cmp.w	(A6)+,D2
	dbeq	D0,gtsort42	A6 ->
	moveq	#0,D3
	sub.w	D0,D3	D3: Position of 2nd colour to swap

* D2: colour number, (A6-2) -> colour number in table, D3: position in table

	lea	(A4),A0
	moveq	#-3,D0
	moveq	#15,D1
gtsort43	addq.w	#2,D0
	cmp.w	(A0)+,D0	Find least used base colour
	dbcc	D1,gtsort43
	bcs.s	gtsort44
	lea	-2(A0),A1
	move.w	(A1),D0
	dbf	D1,gtsort43
gtsort44	move.l	A1,D1
	sub.l	A4,D1
	lea	(A3),A2
	add.w	D1,A2
	add.w	D1,A2
	add.w	D1,A2	A2 -> colour
	lsr.w	#1,D1	D1: Position of 1st colour to swap
	lea	-$200(A1),A1	A1 -> colour number

*==========================
* A1 -> 1st colour number in table, A2 -> 1st colour
* D2: 2nd colour number, (A6-2) -> 2nd colour number in table,
* D3: position of 2nd colour in table
*==========================

	move.w	(A1),D1	D1: Colour number
	move.w	D1,(SP)	Save it
	move.w	D2,(A1)
	move.w	(A2)+,D4
	move.w	(A2)+,D5
	move.w	(A2)+,D6
	subq.l	#6,A2
	lea	(A3),A0
	add.w	D3,D3
	add.w	D3,A0
	add.w	D3,D3
	add.w	D3,A0
	pea	(A0)	Save A0
	move.w	(A0)+,(A2)+
	move.w	(A0)+,(A2)+
	move.w	(A0)+,(A2)+

	add.w	D1,D1
	lea	$400(A4),A2
	lea	(A2),A0
	add.w	D1,A0
	move.w	(A0),D1	actual frequency

	move.w	#$EF,D2
	lea	(A5),A1	Now find equivalent position
gtsort45	move.w	(A1)+,D0
	add.w	D0,D0
	lea	(A2),A0
	add.w	D0,A0
	cmp.w	(A0),D1
	dbcc	D2,gtsort45
	bcc.s	gtsort46
	addq.l	#2,A1	A1 -> pos. after first lower or same
gtsort46

*  A1 -> new position +2,  A6 -> old position +2

	move.l	(SP)+,A0	A0 -> old colour position
	lea	6(A0),A2
	move.l	A6,D0
	sub.l	A1,D0
	lea	-2(A6),A1
	asr.w	#1,D0
	bpl.s	gtsort50
	neg.w	D0
	subq.w	#1,D0
	bra.s	gtsort48

gtsort47	move.w	(A6)+,(A1)+	if old<new
	move.w	(A2)+,(A0)+
	move.w	(A2)+,(A0)+
	move.w	(A2)+,(A0)+
gtsort48	dbf	D0,gtsort47
	move.w	(SP),(A1)+
	move.w	D4,(A0)+
	move.w	D5,(A0)+
	move.w	D6,(A0)+
	bra.s	gtsort51

gtsort49	move.w	-(A1),-(A6)	if oldònew (if A6 -> old+2)
	move.w	-(A0),-(A2)
	move.w	-(A0),-(A2)
	move.w	-(A0),-(A2)
gtsort50	dbf	D0,gtsort49
	move.w	(SP),-(A6)
	move.w	D6,-(A2)
	move.w	D5,-(A2)
	move.w	D4,-(A2)

gtsort51	lea	(A4),A1
	addq.l	#2,SP
	bra	gtsort19

gtsort52	tas	(A6)
gtsort53	subq.w	#1,(SP)
	bcc	gtsort21
gtsort54	addq.l	#8,SP
	move.w	(SP),D0
	bmi.s	gtsort56
	lea	$20(A4),A0
	lea	-$1E0(A4),A1
gtsort55	move.w	(A0)+,(A1)+
	dbf	D0,gtsort55
gtsort56	addq.l	#4,SP

*>>>>>>>>>>>>>>>>>>>>>>>>>>
* A3 -> palette of truncated colours
* A2 -> luminosity table
* A4 & A5 -> offset table and after this sorted colours 16+
* A0, A1 & A6 free (containing useless junk) (A1 -> sorted colours 16+)

	lea	-$400(A4),A2	Needed when less than 256 colours
	lea	(A4),A5

	moveq	#$F,D4	Write a small luminosity table, for
	lea	(A4),A0	16 most used colours only 
	lea	-$200(A4),A6	(replacing offset table)
gtsort57	move.w	(A6)+,D0
	add.w	D0,D0
	move.w	0(A2,D0.W),(A0)+
	dbf	D4,gtsort57

	lea	$200(A4),A4
	lea	(A4),A6

	moveq	#1,D4	Use this luminosity table to
gtsort58	moveq	#1,D3	sort the 16 first colours according
gtsort59	moveq	#3,D2	to darkness. (Colour 0 = darkest,
gtsort60	moveq	#$F,D1	then 4,8,12, 2,6,10,14, 1,5,9,13,
	moveq	#-1,D0	3,7,11 and 15 the brightest)
	lea	(A5),A0
gtsort61	cmp.w	(A0)+,D0
	dbhi	D1,gtsort61
	bls.s	gtsort62
	lea	-2(A0),A2
	move.w	(A2),D0
	dbf	D1,gtsort61
gtsort62	moveq	#15,D0
	lea	(A6),A1
	lea	-$200(A2),A0	Base colour number
gtsort63	move.w	(A0),(A1)
	lea	$20(A0),A0
	lea	$20(A1),A1
	dbf	D0,gtsort63
	addq.l	#8,A6
	st	(A2)
	dbf	D2,gtsort60
	lea	-$1C(A6),A6
	dbf	D3,gtsort59
	subq.l	#6,A6
	dbf	D4,gtsort58
* - - - - - - - - - - - - -	A4 -> sorted table of colour numbers
	movem.l	4(SP),A2/A6	A2 -> unpacked image, A6 -> palette
	lea	(A3),A0	Return new palette

	move.w	#$FF,D2	From the finally sorted table of
	moveq	#0,D1	colour numbers, create new palette
gtsort64	move.w	(A4),D0	plus a byte table for converting
	lea	(A5),A1	image data. (the latter overwriting
	add.w	D0,A1	now defunct offset table)
	move.b	D1,(A1)
	addq.b	#1,D1
	add.w	D0,D0
	add.w	(A4)+,D0
	lea	(A6),A1
	add.w	D0,A1
	move.b	(A1)+,(A3)+
	move.b	(A1)+,(A3)+
	move.b	(A1)+,(A3)+
	dbf	D2,gtsort64

	move.l	12(SP),D1
	lsl.l	#3,D1	Number of pixels (=bytes) in image
	moveq	#0,D0
	bra.s	gtsort67

gtsort65	swap	D1
gtsort66	move.b	(A2),D0
	lea	(A5),A1
	add.w	D0,A1
	move.b	(A1),(A2)+	Convert image data
gtsort67	dbf	D1,gtsort66
	swap	D1
	dbf	D1,gtsort65

	rts
