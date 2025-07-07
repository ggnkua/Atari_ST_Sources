/ This file contains fast text support routines for Spectral Sorcery.

/ This routine sets the colors for 'my_ftext'.
/ Define in C as:
/	VOID my_fcolor(color1, color2)
/	    int color1; (0-15)	pixel value for color1		4(sp)
/	    int color2;	(0-15)	pixel value for color2		6(sp)

	.globl my_fcolor_
	.shri

my_fcolor_:
	move.w	4(sp),fcolor1	/ set color1 register
	move.w  6(sp),fcolor2	/ set color2 register
	rts			/ done



/ This routine sets the ptr to the font to be used by the 'my_ftext' routine.
/ Define in C as:
/	VOID my_ffont(fontaddr)
/	    char *fontaddr;	4(sp)	ptr to font table to use

	.globl	my_ffont_
	.shri

my_ffont_:
	move.l	4(sp), fontptr		/ set pointer to font table
	rts				/ done


/ This routine sets the drawing mode flag (REPLACE or TRANSPARENT).
/ REPLACE is a block fill and TRANSPARENT is an OR operation.
/ Define in C as:
/	VOID my_fmode(mode)
/	    int mode;	which mode (0=replace, 1=transparent)
/			only the lsb is examined.

	.globl my_fmode_
	.shri

my_fmode_:
	move.b	4(sp),d0	/ check the mode bit
	btst	$0,d0		/ is it REPLACE mode?
	sne	drawmode	/ br if YES
	rts			/ go home

	.bssd
drawmode:	.blkb	1	/ mode flag for my_ftext drawing



/ This routine writes a null terminated string to the screen in a way that
/ is a cross between GEMDOS Cconws and VDI v_gtext.
/ Define in C as:
/	VOID my_ftext(x, y, text)
/	    int x; text coord column to print (0-39)		 8(a6)
/	    int y; screen line (top of character cell)		10(a6)
/	    char *text;  ptr to null-terminated ascii string	12(a6)


	.globl my_ftext_
	.shri

my_ftext_:
	link	a6,$0		/ reserve a stack frame
	movem.l	${d0-d6,a0-a2},-(sp)

	move.w	$3,-(sp)	/ get the Logbase
	trap	$14
	addq.l	$2,sp		/ clean stack
	movea.l	d0,a1		/ set Logbase as screen base 

goodbase:
	move.w	10(a6),d0	/ screen line (y)
	mulu	$160,d0		/ 160 byte offset per line
	adda.l	d0,a1		/ add to screen base address
	move.w	8(a6),d0	/ get char column
	bclr	$0,d0		/ check for odd column
	beq.s	iseven		/ not an odd byte
	addq.l	$1,a1		/ point to odd byte in vplanes
iseven:
	lsl.w	$2,d0		/ offset to correct vplane block
	adda.w	d0,a1
	move.l	a1,charaddr;	/ save string absolute dest address

	movea.l	12(a6),a0	/ set ptr to text string
nextchar:
	move.b	(a0)+,d0	/ get next char
	bne.s	prepch		/ quit if done

	movem.l	(sp)+,${d0-d6,a0-a2}	/ restore regs
	unlk	a6		/ kill stack frame
	rts			/ return

/ Here is where the real meat is... writing characters
prepch:
	ext.w	d0		/ make the character and integer
	cmpi.w	$'a,d0		/ if a lower case letter, then make it upper
	bmi.s	notlower	/ br if YES
	sub.w	$['a-'A],d0	/ make it an upper case letter
notlower:	
	cmpi.w	$'Z,d0		/ check for overflow
	bhi	scum		/ br if ch is too hi.
	sub.w	$' ,d0		/ reduce to my character set (BLANK is 0 mascii)
	bpl	goodchar	/ if still in range, then branch
scum:
	clr.w	d0		/ back char, force it to be a BLANK
goodchar:
	mulu	$20,d0		/ 20 bytes per character description
	movea.l	fontptr,a2	/ font table base
	adda.l	d0,a2		/ offset to correct font item
	
	movea.l	charaddr,a1	/ set ptr to screen write address
	moveq	$9,d0		/ line counter (10 per character)
mft0:
	move.l	fcolor1,d3	/ set color1 vplane pattern
	move.b	(a2)+,d4	/ get font mask data
	move.b	(a2)+,d5
	move.b	d4,d6		/ make font mask
	or.b	d5,d6		/ all color bits
	not.b	d6		/ invert for use as an AND mask
	and.b	drawmode,d6	/ clear if in replace mode
	moveq	$3,d1		/ set vplane counter (4 planes)
mft1:
	clr.w	d2		/ clear target reg
	btst	$16,d3		/ color1 bits present?
	beq.s	mftpl1		/ br if NO
	move.b	d4,d2		/ set color1 bits
mftpl1:
	btst	$0,d3		/ color2 bits present?
	beq.s	mftpl2
	or.b	d5,d2		/ combine results
mftpl2:
	and.b	d6,(a1)		/ mask out background
	or.b	d2,(a1)		/ place text image on screen
	addq.l	$2,a1		/ point to byte in next vplane
	ror.l	$1,d3		/ next set of color bits
	dbra	d1,mft1		/ next vplane

	adda.l	$[160-8],a1	/ point at the next screen line
	dbra	d0,mft0		/ next character line

/ Now that the work is done, point the scrbase at the next character
/ write address (absolute of course)

	move.l	charaddr,d0	/ get old character address
	btst	$0,d0		/ check for an odd address
	bne.s	go_even		/ make it even (7 byte offset)
	addq.l	$1,d0		/ do the second half of the vplanes words
	bra.s	scrset
go_even:
	addq.l	$7,d0		/ offset to the next vplane block
scrset:
	move.l	d0,charaddr	/ save the new write address
	bra	nextchar	/ get another character


	.bssd
	.even
charaddr:	.blkl	1	/ addr to write next character
fontptr:	.blkl	1	/ ptr to current font set
fcolor1:	.blkw	1	/ color 1 (vplane pattern in bits)
fcolor2:	.blkw	1	/ color 2 (vplane pattern in bits)
