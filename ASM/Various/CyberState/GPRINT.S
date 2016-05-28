*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*
*	Cyberstate	921020
*
*	TARGET:	Print pixel oriented text. Ascii values from
*		32 to 127.
*
*	CAVEATS:	NO limit checking is done. You can print almost
*		anywhere in memory with any character.
*
*	FILES:	GPRINT.S	This one
*		GEMINC.S	GEM macro definitions	
*		CHAR.BIN	Character sprite data
*

*~~~~~~~~~~ Assembler informations ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*
*	Cyberstate	921005
*

	OPT	d-,p+,x+		*

	OUTPUT	GPRINT.PRG		*

*~~~~~~~~~~ Macro and EQU definitions ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

pbase	=	$44e		*

Crawcin	=	$07		*
Mshrink	=	$4a		*
Pterm	=	$4c		*

Supexec	=	38		*

	INCLUDE	"GEMINC.S"		*

*~~~~~~~~~~ Init Program ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*
*	Cyberstate	921005
*

	SECTION	TEXT		*

	move.l	a7,a5		*
	move.l	4(a5),a5		*
	move.l	$c(a5),d0		*
	add.l	$14(a5),d0		*
	add.l	$1c(a5),d0		*
	add.l	#$200,d0		*
	move.l	d0,d1		*
	add.l	a5,d1		*
	and.l	#-2,d1		*
	move.l	d1,a7		*
	move.l	d0,-(sp)		*
	move.l	a5,-(sp)		*
	clr.w	-(sp)		*
	gem	Mshrink,12		*
	tst.l	d0		*
	bmi.s	term		*

	pea	main(pc)		*
	xbios	Supexec,6		*

	clr.w	d0		*
term	move.w	d0,-(sp)		*
	gem	Pterm		*

*~~~~~~~~~~ Main Program ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*
*	Cyberstate	921005
*

main	bsr	GRAF.CLS		*

	lea	text(pc),a0		*
	lea	grect(pc),a1	*
	moveq	#2,d3		*

.bloop	move.w	#100,d2		*
.tloop1	bsr.s	GRAF.PRINT		*
	add.w	#3,(a1)		*
	add.w	#2,2(a1)		*
	dbra	d2,.tloop1		*

	move.w	#100,d2		*
.tloop2	bsr.s	GRAF.PRINT		*
	sub.w	#3,(a1)		*
	dbra	d2,.tloop2		*

	move.w	#100,d2		*
.tloop3	bsr.s	GRAF.PRINT		*
	add.w	#3,(a1)		*
	sub.w	#2,2(a1)		*
	dbra	d2,.tloop3		*

	move.w	#100,d2		*
.tloop4	bsr.s	GRAF.PRINT		*
	sub.w	#3,(a1)		*
	dbra	d2,.tloop4		*

	dbra	d3,.bloop		*

	rts			*

grect	DC.w	120,90		* List of 2 words.
				* X (col.) = 120
				* Y (row)  = 90

*~~~~~~~~~~	GRAF.PRINT Routine ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*
*	Cyberstate	921005
*	Prints graphical text on the screen
*
*	Input:	a0 = address to string
*		a1 = address to grect
*	Output:	-
*	Destroys:	-
*

gprint_reg	REG	d0-d4/a0/a2-a5	*

GRAF.PRINT	movem.l	gprint_reg,-(sp)	*

	bsr	GRAF.SCRADR		*
	movem.w	(a1),d0-d1		*
	exg.l	d0,d1		*
	and.w	#15,d1		*
	move.l	#$ffff,d3		*
	ror.l	d1,d3		*
	moveq	#-1,d4		*
	lea	chars(pc),a4	*

.ploop	move.b	(a0)+,d0		*
	beq.s	.end		*

	sub.b	#32,d0		*
	ext.w	d0		*
	lsl.w	#4,d0		*

	lea	0(a4,d0.w),a2	*

	move.b	(a0)+,d0		*
	bne.s	.c		*

	move.l	#$ffffff,d3		*
	ror.l	d1,d3		*
	clr.w	d4		*
	bra.s	.c1		*

.c	sub.b	#32,d0		*
	ext.w	d0		*
	lsl.w	#4,d0		*

.c1	lea	0(a4,d0.w),a3	*

	moveq	#15,d0		*

.mloop	clr.l	d2		*
	move.b	(a2)+,d2		*
	lsl.w	#8,d2		*
	move.b	(a3)+,d2		*
	swap.w	d2		*
	lsr.l	d1,d2		*
	and.l	d3,(a5)		*
	or.l	d2,(a5)		*
	lea	80(a5),a5		*
	dbra	d0,.mloop		*

	lea	-80*16+2(a5),a5	*

	tst.w	d4		*
	bne.s	.ploop		*

.end	movem.l	(sp)+,gprint_reg	*
	rts			*

*~~~~~~~~~~	GRAF.CLS Routine ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*
*	Cyberstate	921005
*	Clears the screen.
*
*	Input:	-
*	Output:	-
*	Destroys:	-
*

gcls_reg	REG	d0/d2-a3/a5		*

GRAF.CLS	movem.l	gcls_reg,-(sp)	*

	move.l	(pbase).w,a5	*
	moveq	#9,d0		*
.c1loop	clr.l	(a5)+		*
	dbra	d0,.c1loop		*

	lea	-40(a5),a5		*
	movem.l	(a5)+,d2-a3		*

	move.w	#798,d0		*
.c2loop	movem.l	d2-a3,(a5)		*
	lea	40(a5),a5		*
	dbra	d0,.c2loop		*

	movem.l	(sp)+,gcls_reg	*
	rts			*

*~~~~~~~~~~	GRAF.SCRADR Routine ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*
*	Cyberstate	921005
*	Calculates the screenaddress on wordbasis.
*
*	Input:	a1 = address to grect
*	Output:	a5 = screenaddress
*	Destroys:	-
*

gscradr_reg	REG	d0-d1		*

GRAF.SCRADR	movem.l	gscradr_reg,-(sp)	*

	move.l	(pbase).w,a5	*
	movem.w	(a1),d0-d1		*

	lsl.w	#4,d1		*
	add.l	d1,a5		*
	lsl.w	#2,d1		*
	add.l	d1,a5		*

	lsr.w	#4,d0		*
	add.l	d0,d0		*
	add.l	d0,a5		*

	movem.l	(sp)+,gscradr_reg	*
	rts			*

*~~~~~~~~~~	Variables ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*

	SECTION	DATA

text	DC.b	"Hello WORLD!",0	* don't forget the ZERO ending

chars	INCBIN	"CHAR.BIN"		*

*	CHAR.BIN	contents
*	Byte 00-15	ascii char. 32 from top to bottom
*	Byte 16-31	ascii char. 33
*	..........
*	Byte 1521-1535 ascii char. 127
*
