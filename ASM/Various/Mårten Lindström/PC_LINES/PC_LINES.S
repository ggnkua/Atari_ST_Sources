
* For Ictari members, here is the (Devpack) source of PC Lines.
* I have written it for it to be very easy to add new characters or
* character moves. Just have a look at the very end of this file
* (beginning with label 'chrmoves').

* You may make changes of your own to implement in the system font any
* characters of your own design that you may personally need. But before
* spreading any modified copies of PC Lines, I must urge you to contact me.

* The program has very much grown from trial and error, since I don't know
* of a documented way to accomplish a change of the system screen fonts.
* Should anyone know more, I would, needless to say, be very grateful for
* any information he would like to share.

* If you have any views on which characters should be included in the
* character set and where (or on my programming) please tell me!

* Turn to Ictari or directly to me:

*	M†rten Lindstr”m
*	S„ven„sv„gen 24
*	S-932 31 Skelleftehamn
*	SWEDEN

***************************

	COMMENT	HEAD=7	No harm in some extra speed

 OPT C- I'm allergic to case sensitivity in any programming language

prgstart	nop
	bra.s	la_end

*************************** The new LA exception
* The following is to become the new Line A exception. Any new exception
* should always be installed according to the XBRA protocol:
*	 L: 'XBRA'
*	 L: four-letter program ID
*	 L: address of old routine
*	?W: New routine

la_start	dc.l	'XBRA'

defltfnt	set	la_start-36	I use SET variables for addresses
defltdat	set	la_start-32	to the new Line A routine and to
danorflg	set	la_start-26	variables and data blocks used by it.
la_flag	set	la_start-25	For reasons to be explained later.
var_base	set	la_start-24
routvecs	set	la_start-20
pntr_tab	set	la_start-16

xbra_id	dc.l	'PCLn'
old_la	set	*
	ds.l	1
new_la	set	*
	movea.l	2(SP),A1
	cmpi.w	#$A000,(A1)
	beq.s	font_ok?
runoldla	movea.l	old_la(PC),A1
	jmp	(A1)
* = = = = = = = = = = = = =
font_ok?	lea	la_flag(PC),A1
	tst.b	(A1)+
	beq.s	runoldla
	move.l	(A1)+,A0	A0: var_base
	move.l	-906(A0),D0
	lea	prgstart-256(PC),A2	If 'current font' points
	cmp.l	D0,A2	below the PC_LINES area, 
	bhi.s	setpntrs
	swap	D0
	cmpi.w	#$E0,D0	or within ROM,
	bcs.s	la_init
	cmpi.w	#$100,D0
	bcs.s	setpntrs	then redirect font pointers
* - - - - - - - - - - - - -
la_init	movea.l	(A1)+,A2	A2:routvecs, A1->pntr_tab
	move.l	A0,D0
	addq.l	#2,2(SP)	Forward pointer past $A000
	rte
* - - - - - - - - - - - - -
setpntrs	move.l	defltfnt(PC),-906(A0)	Current := Default
	move.l	defltfnt(PC),-460(A0)	Default font
	move.l	defltdat(PC),-22(A0)	Default font data
*	move.l	defltdat(PC),84(A0)
	move.l	4(A1),-456(A0)	6x6 font
	move.l	8(A1),-452(A0)	8x8 font
	bra.s	la_init

***************************
la_end

head6x6	set	la_start-124	Some more SET addresses
head8x8	set	la_end	Explanation will come
head8x16	set	head8x8+88
data6x6	set	head8x16+88
data8x8	set	data6x6+1152
data8x16	set	data8x8+2048
kbdtabls	set	data8x16+4096

	lea	prgstart-128(PC),A0
	clr.b	(A0)	Empty command line tail
	lea	kbdtabls(PC),A6
	suba.l	4(SP),A6	A6: prg length to reserve
	move.l	A6,-(SP)

	clr.l	-(SP)	SSP:=USP
	move.w	#32,-(SP)	SUPER
	trap	#1
	addq.l	#6,SP
	move.l	D0,-(SP)	Save SSP

* - - - - - - - - - - - - -  Check Line-A vector
	movea.l	$28.W,A1	Line-A
	move.l	xbra_id(PC),D0

nxt_xbra	lea	-12(A1),A1
	cmpi.l	#'XBRA',(A1)+
	bne.s	notinst
	cmp.l	(A1)+,D0	A1 -> old_la in installed routine
	beq.s	inst	Is installed!
	movea.l	(A1),A1
	bra.s	nxt_xbra

* - - - - - - - - - - - - - Already installed: Toggle Lines on/off and quit
inst	lea	la_flag-old_la(A1),A6
	dc.w	$A000
	movem.l	4(A1),D3-D4	D3->8x8, D4->8x16
	not.b	(A6)	TOGGLE!
	dc.w	$A000
	move.l	(A1)+,-456(A0)	6x6
	bsr.s	restrfnt
	move.l	A2,-452(A0)	8x8
	bsr.s	restrfnt

	tst.b	danorflg-la_flag(A6)
	beq.s	xit
	lea	kbdtabls-la_flag(A6),A2
	movem.l	(A2)+,A0/A3-A5	Restore Danish/Norwegian keyboard
	tst.b	(A6)
	beq.s	setkbd
	lea	(A2),A3
	lea	128(A2),A4
	lea	256(A2),A5
setkbd	movem.l	A3-A5,(A0)
xit	move.w	#32,-(SP)	SUPER (old SSP previously saved)
	trap	#1
	addq.l	#8,SP
	clr.w	(SP)
	trap	#1

restrfnt	move.l	(A1)+,A2	A2->Pointer to font
	cmp.l	-460(A0),D3	Old default font?
	bne.s	notdeflt
	move.l	A2,906(A0)	Set current
	move.l	A2,460(A0)	and default font to new font
	move.l	76(A2),-22(A0)	and system font data to its data
notdeflt	move.l	D4,D3	When 8x8 checked do 8x16 next time
	rts

*************************** INSTALL
notinst	moveq	#-1,D0  Correct danish/norwegian keyboards
	move.l	D0,-(SP)	Caps Locked
	move.l	D0,-(SP)	Shifted
	move.l	D0,-(SP)	Unshifted
	move.w	#16,-(SP)	KEYTBL
	trap	#14
	lea	14(SP),SP
	move.l	D0,A0

	moveq.l	#179,D2	o slash according to Atari
	movea.l	(A0),A1	Unshifted characters
	moveq	#127,D1	128 characters
fnddanor	cmp.b	(A1)+,D2	Look for o slash
	dbeq	D1,fnddanor
	lea	danorflg(PC),A2
	seq	(A2)+	If o slash found flag for it
	st	(A2)	Flag for new LA enabled
	bne.s	osl_done

	lea	kbdtabls(PC),A2
	move.l	A0,(A2)+	Address to pointer table
	lea	(A0),A1
	move.l	(A1)+,(A2)+	Save old pointers
	move.l	(A1)+,(A2)+
	move.l	(A1)+,(A2)+

	moveq.l	#155,D3	o slash according to Protext
	bsr.s	copyktbl
	moveq.l	#178,D2	O slash according to Atari
	moveq.l	#157,D3	O slash according to Protext
	bsr.s	copyktbl
	bsr.s	copyktbl
	lea	3*128+16(A6),A6	Prg length to reserve
	move.l	A6,4(SP)
	bra.s	osl_done
*==========================
copyktbl	move.l	A2,D0	Sub-routine to copy and convert
	movea.l	(A0),A1	a Danish/Norwegian keyboard table
	moveq	#127,D1	128 scan codes
nxtscan	move.b	(A1)+,(A2)
chkscan	cmp.b	(A2)+,D2
	dbeq	D1,nxtscan
	bne.s	ktbldone
	move.b	D3,-(A2)
	bra.s	chkscan
ktbldone	move.l	D0,(A0)+
	rts

*==========================  Copy rest of program up in memory
osl_done	lea	prgcont(PC),A0	Copy from
	lea	$3000(A0),A1	to
	movea.l	A1,A5	Save target address (to be jumped to)
	move.w	#(prgend-prgcont)/4,D0	;(/4 f”r l-format)
copyprg	move.l	(A0)+,(A1)+
	dbra	D0,copyprg
	jmp	(A5)

old_la	set	old_la-$3000	These addresses (the SET ones) will
new_la	set	new_la-$3000	from the remaining program's point
danorflg	set	danorflg-$3000	of view seem to have been moved down
la_flag	set	la_flag-$3000	-$3000 bytes - as long as only
defltfnt	set	defltfnt-$3000	PC-relative addressing is used.
defltdat	set	defltdat-$3000	(Though, of course it is actually
var_base	set	var_base-$3000	the remaining program that has been
routvecs	set	routvecs-$3000	moved UP +$3000 bytes.)
pntr_tab	set	pntr_tab-$3000
head6x6	set	head6x6-$3000
head8x8	set	head8x8-$3000
head8x16	set	head8x16-$3000
data6x6	set	data6x6-$3000
data8x8	set	data8x8-$3000
data8x16	set	data8x16-$3000
kbdtabls	set	kbdtabls-$3000

*========================== Prepare PC Lines font data
prgcont	dc.w	$A000
	lea	var_base(PC),A6
	move.l	A0,(A6)+
	move.l	A2,(A6)+

	move.w	#1151,D1	length of font data -1
	lea	head6x6(PC),A3	A3-> space for this font header
	lea	data6x6(PC),A4	A4-> space for font data
	lea	head8x8(PC),A5	A5-> space for next font header
	move.l	A5,defltfnt-pntr_tab(A6)	Initialize to something
	bsr.s	movtoram	Copy 6x6 font to RAM
	pea	(A4)

	move.w	#2047,D1	length of font data -1
	lea	data8x8(PC),A4
	lea	head8x16(PC),A5
	move.l	A4,defltdat-pntr_tab-4(A6)	Initialize to something
	bsr.s	movtoram	Copy 8x8 font to RAM
	pea	(A4)

	move.w	#4095,D1	length of font data -1
	lea	data8x16(PC),A4
	suba.l	A5,A5
	bsr.s	movtoram	Copy 8x16 font to RAM
	clr.l	(A6)+

	lea	cpychr16(PC),A1
	lea	wrchr16(PC),A2
	lea	newchr16(PC),A3
	bsr	modify	Modify 8x16 font

	move.l	(SP)+,A4	Font data for 8x8 font
	lea	cpychr8(PC),A1
	lea	wrchr8(PC),A2
	lea	newchr8(PC),A3
	bsr.s	modify	Modify it

	pea	message(PC)
	move.w	#9,-(SP)	CCONWS
	trap	#1
	addq.l	#6,SP

	move.l	(SP)+,A4	Font data for 6x6 font
	lea	cpychr6(PC),A1
	lea	wrchr6(PC),A2
	lea	newchr6(PC),A3
	bsr.s	modify	Modify it

	lea	old_la(PC),A0
	movea.l	$28.W,A1
	move.l	A1,(A0)+	Save old Line-A vector
	move.l	A0,$28.W	Install new LA routine

	move.w	#32,-(SP)	SUPER  (old SSP saved earlier)
	trap	#1
	addq.l	#6,SP

	dc.w	$A000

	move.w	#49,-(SP)	PTERMRES (length to keep saved earlier)
	trap	#1

*-*-*-*-*-*-*-*-*-*-*-*-*-* Copy font from ROM to RAM
movtoram	move.l	A3,(A6)+	Save font pointer in table
	move.l	A3,D7
	move.l	(A1)+,A2	ROM font pointer
	moveq	#20,D0	21 longs = 84 bytes
copyhdr	move.l	(A2)+,(A3)+	Copy font header from ROM to RAM
	dbf	D0,copyhdr
	move.l	A5,(A3)+	Offset 84: Next header
	move.l	A4,76-88(A3)	Offset 76: Font data

	move.l	76-84(A2),A2	ROM font data
	move.l	A2,D2
	lea	(A5),A3	A3->Next font header
	lea	(A4),A5
copydata	move.b	(A2)+,(A5)+	Copy font data from ROM to RAM
	dbf	D1,copydata

	cmp.l	-22(A0),D2	Data of current font?
	bne.s	notdfltf  	No
	move.l	A4,-22(A0)	Yes: replace with new data pointer
	lea	defltfnt(PC),A5	and save as default this font's
	move.l	D7,(A5)+  	header
	move.l	A4,(A5)+  	and data
notdfltf	rts

*-*-*-*-*-*-*-*-*-*-*-*-*-* Modify RAM font
* IN: 
* A1 -> routine to read characters from font data, calling (A2) to write it
*   and preceded by offset to routine for generating IBM graphics, -  "  -
* A2 -> routine to write characters from buffer into font data
* A3 -> character definitions
* A4 -> font data
* Trashes D0,D1,D2,D3,D4,A0,A1,A5,A6

MODIFY	moveq	#0,D4

	lea	chrmoves(PC),A5	COPY CHARACTERS TO NEW POSITIONS
	move.b	(A5)+,D3
copyloop	move.b	(A5)+,D4
	lea	charbuf(PC),A6
	jsr	(A1)
	subq.b	#1,D3
	bne.s	copyloop

	lea	ibmdata(PC),A5	REPLACE CHARACTERS WITH LINES
	move.b	(A5)+,D3	Number of Line characters
	move.b	(A5)+,D4	Start number
	add.w	-(A1),A1
ibmloop	lea	charbuf(PC),A6
	jsr	(A1)
	addq.b	#1,D4
	subq.b	#1,D3
	bne.s	ibmloop

	lea	newchars(PC),A5	DEFINE NEW CHARACTERS
	movea.l	A3,A6
	move.b	(A5)+,D3	Number of characters
writloop	move.b	(A5)+,D4
	jsr	(A2)
	subq.b	#1,D3
	bne.s	writloop

	rts

***************************	
* READ AND WRITE ROUTINES
* IN: D4: character number
*     A4 -> base of font data
*     A6 -> buffer
*     A2 -> write routine
* Trash D0,D1,D2, A0

	dc.w	IBMCHR16-*
CPYCHR16	moveq	#15,D2
	bra.s	rd_cont
*==========================
	dc.w	IBMCHR8-*
CPYCHR8	moveq	#7,D2
rd_cont	movea.l	A4,A0
	adda.w	D4,A0

nxtrdrow	move.b	(A0),(A6)+
	lea	256(A0),A0
	dbra	D2,nxtrdrow
	move.b	(A5)+,D4
	lea	charbuf(PC),A6
	jmp	(A2)
*ðððððððððððððððððððððððððð
IBMCHR16	move.b	(A5),(A6)+	For high resolution repeat top and
	move.b	(A5),(A6)+	bottom row 5 times ...
	move.b	(A5),(A6)+
	move.b	(A5),(A6)+
	move.b	(A5)+,(A6)+
	move.b	(A5),(A6)+	... and each of the
	move.b	(A5)+,(A6)+	three middle rows 2 times
	move.b	(A5),(A6)+
	move.b	(A5)+,(A6)+
	move.b	(A5),(A6)+
	move.b	(A5)+,(A6)+
	move.b	(A5),(A6)+	(bottom row)
	move.b	(A5),(A6)+
	move.b	(A5),(A6)+
	move.b	(A5),(A6)+
	move.b	(A5)+,(A6)+
	lea	charbuf(PC),A6
*==========================
WRCHR16	moveq	#15,D2
	bra.s	wr_cont
*==========================
IBMCHR8	move.b	(A5),(A6)+
	move.b	(A5)+,(A6)+	For medium rez repeat top row 2 times
	move.b	(A5)+,(A6)+	don't repeat middle rows
	move.b	(A5)+,(A6)+
	move.b	(A5)+,(A6)+
	move.b	(A5),(A6)+
	move.b	(A5),(A6)+
	move.b	(A5)+,(A6)+	repeat last row 3 times
	lea	charbuf(PC),A6
*==========================
WRCHR8	moveq	#7,D2
wr_cont	movea.l	A4,A0
	adda.w	D4,A0

nxtwrrow	move.b	(A6)+,(A0)
	lea	256(A0),A0
	dbra	D2,nxtwrrow
	rts

*ðððððððððððððððððððððððððð
* multipy character number by 6 and divide by 8 => start byte number
	dc.w	IBMCHR6-*
CPYCHR6	move.w	D4,D1	Let D1 be work register for D4
	mulu	#6,D1
	moveq	#7,D0
	and.b	D1,D0	D0: Shift
	asr.w	#3,D1	D1: Start byte

	moveq	#5,D2	Six rows
	movea.l	A4,A0
	adda.w	D1,A0

nxt6rowr	movep.w	1(A0),D1
	move.b	(A0),D1
	rol.w	D0,D1
	andi.w	#$FC,D1
	move.b	D1,(A6)+
	lea	192(A0),A0
	dbra	D2,nxt6rowr
	move.b	(A5)+,D4
	bra.s	wrchr6_

*ðððððððððððððððððððððððððð
IBMCHR6	moveq	#4,D2	5 rows in ibm definition
	moveq	#0,D0

ibm6row	move.b	(A5)+,D0	    |lLLmmRRr|
	lsl.w	#2,D0	  lL|LmmRRr  |
	rol.b	#2,D0	  lL|mRRr  Lm|
	lsl.w	#2,D0	lLmR|Rr  Lm  |
	rol.b	#1,D0	lLmR|r  Lm  R|
	asr.b	#1,D0	lLmR|rr  Lm  |
	lsr.w	#4,D0	    | lLmRrr |
	move.b	D0,(A6)+
	dbra	D2,ibm6row
	move.b	D0,(A6)+	Repeat last row
wrchr6_	lea	charbuf(PC),A6
*==========================
WRCHR6	move.w	D4,D1	Let D1 be work register for D4
	mulu	#6,D1
	moveq	#7,D0
	and.b	D1,D0	D0: Shift
	asr.w	#3,D1	D1: Start byte

	moveq	#5,D2
	movea.l	A4,A0
	adda.w	D1,A0

nxt6roww	movep.w	1(A0),D1
	move.b	(A0),D1
	rol.w	D0,D1
	and.w	#$FF03,D1
	or.b	(A6)+,D1
	ror.w	D0,D1
	move.b	D1,(A0)+
	lsr.w	#8,D1
	move.b	D1,(A0)+

	lea	190(A0),A0
	dbra	D2,nxt6roww
	rts


***************************
message	dc.b	' ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ» ',13,10
	dc.b	' º       PC Lines v1.0       º ',13,10
	dc.b	' º (c) M†rten Lindstr”m 1995 º ',13,10
	dc.b	' ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼ ',13,10,0

ibmdata	dc.b	40	Number of IBM characters
	dc.b	179	First IBM character

	dc.b	%00011000	179
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000
	dc.b	%00011000

	dc.b	%00011000	180
	dc.b	%00011000
	dc.b	%11111000
	dc.b	%00011000
	dc.b	%00011000

	dc.b	%00011000	181
	dc.b	%11111000
	dc.b	%00011000
	dc.b	%11111000
	dc.b	%00011000

	dc.b	%01100110	182‚
	dc.b	%01100110
	dc.b	%11100110
	dc.b	%01100110
	dc.b	%01100110

	dc.b	%00000000	183
	dc.b	%00000000
	dc.b	%11111110
	dc.b	%01100110
	dc.b	%01100110

	dc.b	%00000000	184
	dc.b	%11111000
	dc.b	%00011000
	dc.b	%11111000
	dc.b	%00011000

	dc.b	%01100110	185
	dc.b	%11100110
	dc.b	%00000110
	dc.b	%11100110
	dc.b	%01100110

	dc.b	%01100110	186
	dc.b	%01100110
	dc.b	%01100110
	dc.b	%01100110
	dc.b	%01100110

	dc.b	%00000000	187
	dc.b	%11111110
	dc.b	%00000110
	dc.b	%11100110
	dc.b	%01100110

	dc.b	%01100110	188
	dc.b	%11100110
	dc.b	%00000110
	dc.b	%11111110
	dc.b	%00000000

	dc.b	%01100110	189
	dc.b	%01100110
	dc.b	%11111110
	dc.b	%00000000
	dc.b	%00000000

	dc.b	%00011000	190
	dc.b	%11111000
	dc.b	%00011000
	dc.b	%11111000
	dc.b	%00000000

	dc.b	%00000000	191
	dc.b	%00000000
	dc.b	%11111000
	dc.b	%00011000
	dc.b	%00011000

	dc.b	%00011000	192
	dc.b	%00011000
	dc.b	%00011111
	dc.b	%00000000
	dc.b	%00000000

	dc.b	%00011000	193
	dc.b	%00011000
	dc.b	%11111111
	dc.b	%00000000
	dc.b	%00000000

	dc.b	%00000000	194
	dc.b	%00000000
	dc.b	%11111111
	dc.b	%00011000
	dc.b	%00011000

	dc.b	%00011000	195
	dc.b	%00011000
	dc.b	%00011111
	dc.b	%00011000
	dc.b	%00011000

	dc.b	%00000000	196
	dc.b	%00000000
	dc.b	%11111111
	dc.b	%00000000
	dc.b	%00000000

	dc.b	%00011000	197
	dc.b	%00011000
	dc.b	%11111111
	dc.b	%00011000
	dc.b	%00011000

	dc.b	%00011000	198
	dc.b	%00011111
	dc.b	%00011000
	dc.b	%00011111
	dc.b	%00011000

	dc.b	%01100110	199
	dc.b	%01100110
	dc.b	%01100111
	dc.b	%01100110
	dc.b	%01100110

	dc.b	%01100110	200
	dc.b	%01100111
	dc.b	%01100000
	dc.b	%01111111
	dc.b	%00000000

	dc.b	%00000000	201
	dc.b	%01111111
	dc.b	%01100000
	dc.b	%01100111
	dc.b	%01100110

	dc.b	%01100110	202
	dc.b	%11100111
	dc.b	%00000000
	dc.b	%11111111
	dc.b	%00000000

	dc.b	%00000000	203
	dc.b	%11111111
	dc.b	%00000000
	dc.b	%11100111
	dc.b	%01100110

	dc.b	%01100110	204
	dc.b	%01100111
	dc.b	%01100000
	dc.b	%01100111
	dc.b	%01100110

	dc.b	%00000000	205
	dc.b	%11111111
	dc.b	%00000000
	dc.b	%11111111
	dc.b	%00000000

	dc.b	%01100110	206
	dc.b	%11100111
	dc.b	%00000000
	dc.b	%11100111
	dc.b	%01100110

	dc.b	%00011000	207
	dc.b	%11111111
	dc.b	%00000000
	dc.b	%11111111
	dc.b	%00000000

	dc.b	%01100110	208
	dc.b	%01100110
	dc.b	%11111111
	dc.b	%00000000
	dc.b	%00000000

	dc.b	%00000000	209
	dc.b	%11111111
	dc.b	%00000000
	dc.b	%11111111
	dc.b	%00011000

	dc.b	%00000000	210
	dc.b	%00000000
	dc.b	%11111111
	dc.b	%01100110
	dc.b	%01100110

	dc.b	%01100110	211
	dc.b	%01100110
	dc.b	%01111111
	dc.b	%00000000
	dc.b	%00000000

	dc.b	%00011000	212
	dc.b	%00011111
	dc.b	%00011000
	dc.b	%00011111
	dc.b	%00000000

	dc.b	%00000000	213
	dc.b	%00011111
	dc.b	%00011000
	dc.b	%00011111
	dc.b	%00011000

	dc.b	%00000000	214
	dc.b	%00000000
	dc.b	%01111111
	dc.b	%01100110
	dc.b	%01100110

	dc.b	%01100110	215
	dc.b	%01100110
	dc.b	%11111111
	dc.b	%01100110
	dc.b	%01100110

	dc.b	%00011000	216
	dc.b	%11111111
	dc.b	%00011000
	dc.b	%11111111
	dc.b	%00011000

	dc.b	%00011000	217
	dc.b	%00011000
	dc.b	%11111000
	dc.b	%00000000
	dc.b	%00000000

	dc.b	%00000000	218
	dc.b	%00000000
	dc.b	%00011111
	dc.b	%00011000
	dc.b	%00011000

* - - - - - - - - - - - - -
chrmoves	dc.b	3	Number of moves
	dc.b	223,236	Infinity
	dc.b	178,157	O slash
	dc.b	179,155	o slash

newchars	dc.b	5	Number of new characters
	dc.b	254	IBM square
	dc.b	158	Double s
	dc.b	42	New asterisk
	dc.b	249	'Big dot' shifted down
	dc.b	250	'Small dot' up

newchr6	dc.b	$00,$78,$78,$78,$00,$00	IBM square (6x6)
	dc.b	$70,$88,$B0,$88,$B0,$00	Double s
	dc.b	$48,$30,$78,$30,$48,$00	New asterisk
	dc.b	$00,$30,$78,$30,$00,$00	'Big dot' (249) down one row
	dc.b	$00,$00,$30,$30,$00,$00	'Small dot' (250) unchanged

newchr8	dc.b	$00,$00,$7E,$7E,$7E,$7E,$00,$00	IBM square (8x8)
	dc.b	$3C,$66,$66,$6C,$66,$66,$6C,$00	Double s
	dc.b	$6C,$38,$FE,$38,$6C,$00,$00,$00	New asterisk
	dc.b	$00,$00,$38,$7C,$38,$00,$00,$00	(249) down 2 rows
	dc.b	$00,$00,$00,$18,$18,$00,$00,$00	(250) up 1 row

newchr16
 dc.b $00,$00,$00,$00,$00,$7E,$7E,$7E,$7E,$7E,$7E,$00,$00,$00,$00,$00 Square
 dc.b $00,$00,$3C,$7E,$66,$66,$66,$6C,$6E,$66,$66,$66,$6E,$6C,$00,$00 Double s
 dc.b $00,$00,$6C,$6C,$38,$FE,$FE,$38,$6C,$6C,$00,$00,$00,$00,$00,$00 Asterisk
 dc.b $00,$00,$00,$00,$00,$38,$7C,$7C,$7C,$38,$00,$00,$00,$00,$00,$00 249 dwn 4
 dc.b $00,$00,$00,$00,$00,$00,$18,$3C,$3C,$18,$00,$00,$00,$00,$00,$00 250 up 3

***************************
prgend
charbuf	equ	prgend
