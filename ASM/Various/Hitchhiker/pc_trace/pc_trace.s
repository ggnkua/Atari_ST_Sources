**********************************************************
**							**
**			PC-TRACE			**
**							**
**	Written by The Hitchhiker and The Tempest	**
**							**
**		     7th July 1991			**
**							**
**------------------------------------------------------**
**							**
**	This is a VERY SMALL program that prints	**
**	the current PC (program counter) value in	**
**	the top right corner of the screen.		**
**							**
**********************************************************

	COMMENT HEAD=1		* set fastload bit for TOS 1.4+

	section text
	
	move.l	#msg,-(sp)	* Print installed message
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.l	-(sp)		* Let's go Super()
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,ssp
	
	move.l	$4ba,d0		* wait for 1 second
	addi.l	#200,d0
wait	cmp.l	$4ba,d0
	bne.s	wait
	
	move.l	$70.w,d0	* if VBI handler not in ROM then
	cmpi.l	#$fc0000,d0	* don't bother installing.
	bgt.s	install		* It's probably installed anyway.
	clr.w	-(sp)
	trap	#1
	
install
	move.l	$70.w,$8C.w	* Setup a TRAP #3 to call the old VBI code
	move.b	$44c.w,rez	* get current screen resolution
	move.l	$44e.w,logbase	* get screen address
	
	lea	lowoffsets(pc),a0	* calculate where the offset table
	moveq.l	#0,d0			* is for the text routines.
	move.b	rez,d0
	lsl.w	#3,d0
	add.l	d0,a0
	move.l	a0,tabaddr
	
	move.l	#main,$70.w	* install our new VBI routine

	move.l	ssp,-(sp)	* Back into User Mode.
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	
	clr.w	-(sp)		* Ptermres
	move.l	#1024,-(sp)	* reserving 1K - I told you it was small
	move.w	#$31,-(sp)
	trap	#1

main
	movem.l	d0-d7/a0-a7,regs	* save all registers

	move.l	2(sp),d0		* get PC into d0

	moveq.l	#0,d5			* clear offset
	moveq.l	#7,d1			* a character is 8 bytes high
	move.l	tabaddr,a1		* address of offset table
convloop
	move.l	d0,d2		* save value
	lsr.l	#4,d0		* ready for neXt nibble
	andi.l	#15,d2		* get low nibble
	lsl.w	#3,d2		* 8 bytes for each character
	lea	font(pc),a0	* get font address
	add.l	d2,a0
	move.b	0(a1,d1),d5	* address of character that we want
	
	move.l	logbase,a2	* screen address
	add.l	d5,a2		* along to the right place
	
	cmp.b	#2,rez		* are we in hi-rez
	beq.s	hifont		* yes - goto hi-rez routines
	
	move.b	(a0)+,(a2)	* put the character on the screen
	move.b	(a0)+,160(a2)
	move.b	(a0)+,320(a2)
	move.b	(a0)+,480(a2)
	move.b	(a0)+,640(a2)
	move.b	(a0)+,800(a2)
	move.b	(a0)+,960(a2)
	move.b	(a0)+,1120(a2)
	bra.s	donecolor
hifont
	move.b	(a0)+,(a2)	* put the mono character on the screen
	move.b	(a0)+,80(a2)
	move.b	(a0)+,160(a2)
	move.b	(a0)+,240(a2)
	move.b	(a0)+,320(a2)
	move.b	(a0)+,400(a2)
	move.b	(a0)+,480(a2)
	move.b	(a0)+,560(a2)
donecolor
	dbf	d1,convloop	* do the rest of the nibbles

	movem.l	regs,d0-d7/a0-a7	* restore all registers
	trap	#3		* call old VBI routine.
	rte			* go back to normality (?)


	section data

msg	dc.b	13,10,27,"p PC-TRACE Installed ",27,"q",13,10,0

font	incbin	font.dat	* our font

lowoffsets
	dc.b	134,135,142,143,150,151,158,159
medoffsets
	dc.b   	146,147,150,151,154,155,158,159
hioffsets
	dc.b	072,073,074,075,076,077,078,079


	section bss

ssp	ds.l	1
logbase	ds.l	1
tabaddr	ds.l	1
regs	ds.l	16
rez	ds.b	1

