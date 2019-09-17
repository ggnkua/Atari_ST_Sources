
***************************
*	DEANSIFY
* by: MÜrten Lindstrîm
***************************

prgstart	lea	prgend,SP	Set Stackpointer to end of program area

	pea	256+prgend-prgstart.W	Program length including basepage
	pea	prgstart-256(PC)	Address of basepage
	clr.w	-(SP)	Dummy parameter
	move.w	#74,-(SP)	MSHRINK
	trap	#1
	lea	12(SP),SP

	pea	-1.W	Inquire
	move.w	#72,-(SP)	MALLOC
	trap	#1
	addq.w	#6,SP
	move.l	D0,D6	D6: Amount of free memory
	ble	error

	move.l	D6,-(SP)	Request all of it
	move.w	#72,-(SP)
	trap	#1	MALLOC
	addq.w	#6,SP
	tst.l	D0
	ble	error
	move.l	D0,A6	A6-> Memory block


****** LOAD FILE NAMED ON COMMAND LINE AND CONVERT IT ******

	lea	prgstart-128(PC),A4	A4 -> Command tail
	moveq	#0,D4
	move.b	(A4)+,D4	D4: Length of it
	ble	error	Error
	cmpi.b	#127,D4	ARGV parameter passing was used?
	beq	error	Yes, and we don't support that (for now)
	lea	0(A4,D4.W),A0	A0-> End of tail
	clr.b	(A0)	Make sure string is null-terminated
	cmpi.b	#10,-(A0)
	bne.s	tail_ok
	subq.w	#1,D4
	clr.b	(A0)	Strip off any terminating LF
	cmpi.b	#13,-(A0)	and CR
	bne.s	tail_ok
	subq.w	#1,D4
	ble	error
	clr.b	(A0)

tail_ok	clr.w	-(SP)	Open for read only
	pea	(A4)	Address of pathname
	move.w	#61,-(SP)	FOPEN
	trap	#1
	addq.l	#8,SP
	move.w	D0,D7	Save file handle
	bmi	error

	pea	(A6)
	move.l	D6,-(SP)	Read whole file or as much as fits in memory
	move.w	D7,-(SP)
	move.w	#63,-(SP)	FREAD
	trap	#1
	lea	12(SP),SP
	move.l	D0,D5

	move.w	D7,-(SP)
	move.w	#62,-(SP)	FCLOSE
	trap	#1
	addq.l	#4,SP

	move.l	D5,D0
	ble	error
	cmp.l	D6,D5	For simplicity, we demand that
	beq	error	whole file fits in one go.

	cmpi.b	#$1F,(A6)	Simple check against 1st Word file.
	beq	error

*-------------------------- And now the conversion itself
	lea	(A6),A0
	lea	convtab(PC),A5
	moveq.l	#$8A,D2
	moveq	#0,D1
	bra.s	ansictrl

ansify1	swap	D0	Outer loop takes care of files > 65535 bytes
ansify	move.b	(A0),D1
	beq	error	If there is a null, this is no text file
* - - - - - - - - - - - - - Simple test for Protext file
	cmp.b	D2,D1	Look for Protext soft line-breaks.
	bne.s	nprotext
	cmpi.b	#13,-1(A0)
	beq	error	This is apparently a Protext file
nprotext
* - - - - - - - - - - - - -
	move.b	0(A5,D1.W),(A0)+
ansictrl	dbf	D0,ansify
	swap	D0
	dbf	D0,ansify1


****** RENAME THE OLD FILE TO xxx.ATR ******
*convtab has now served its purpose and can be overwritten with new pathname
	lea	(A4),A0
	lea	(A5),A1
copypath	move.b	(A0)+,(A1)+
	bne.s	copypath

	subq.l	#1,A1
	lea	(A1),A0

findext	cmp.b	#'.',-(A1)
	beq.s	extfound
	cmp.b	#'\',(A1)
	beq.s	noext
	cmp.l	A5,A1
	bhi.s	findext

noext	lea	(A0),A1

extfound	move.b	#'.',(A1)+
	move.b	#'A',(A1)+
	move.b	#'N',(A1)+
	move.b	#'S',(A1)+
	clr.b	(A1)+

	pea	(A5)
	move.w	#65,-(SP)	FDELETE
	trap	#1
	addq.l	#6,SP

	pea	(A5)	pointer new filename string
	pea	(A4)	pointer to old filename string
	clr.w	-(SP)	dummy parameter
	move.w	#86,-(SP)	FRENAME
	trap	#1
	lea	12(SP),SP


****** SAVE THE CONVERTED FILE UNDER THE OLD NAME ******

	clr.w	-(SP)	Normal file
	pea	(A4)	Address of pathname
	move.w	#60,-(SP)	FCREATE
	trap	#1
	addq.l	#8,SP
	move.w	D0,D7	Save file handle
	bmi.s	error

	pea	(A6)
	move.l	D5,-(SP)	File length
	move.w	D7,-(SP)
	move.w	#64,-(SP)	FWRITE
	trap	#1
	lea	12(SP),SP

	move.w	D7,-(SP)
	move.w	#62,-(SP)	FCLOSE
	trap	#1
	addq.l	#4,SP

	clr.w	-(SP)	return 0 for OK
pterm	move.w	#76,-(SP)	PTERM
	trap	#1
***************************
error	pea	1.W	return non-zero for error
	bra.s	pterm
***************************

convtab	dc.b	0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15
	dc.b	16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31
	dc.b	32,33,34,"#$%&'()*+,-./"
	dc.b	"0123456789:;<=>?"
	dc.b	"@ABCDEFGHIJKLMNO"
	dc.b	"PQRSTUVWXYZ[\]^_"
	dc.b	"`abcdefghijklmno"
	dc.b	"pqrstuvwxyz{|}~"

	dc.b	"",210,159,207,"",187,"^",222,"S",212,181,""
	dc.b	"",211,216,208,209,"˘",214,215,"~",191,"s",213,180,"Y"

	dc.b	" ≠õúù|›πΩ¶Æ™-æˇ¯Ò˝˛∫Êº˙,ßØ¨´®"
	dc.b	"∂",193,192,"∑éèíÄ",196,"ê",194,195,199,200,197,198
	dc.b	"•",202,203,201,"∏ô*≤",205,206,204,"öY",158
	dc.b	"Ö†É∞ÑÜëáäÇàâç°åã§ï¢ì±îˆ≥ó£ñÅyò"

	BSS
stackspc	ds.l	128
prgend
