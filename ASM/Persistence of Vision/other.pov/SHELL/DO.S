*************************************************************************
*			Shell utility program DO			*
*			------------------------			*
*									*
* Written by:	Mac Sys Data of Persistence Of Vision			*
*									*
* Date:		3rd Jan 1993						*
*									*
* Use:	Program to take parameters from Boris' command line and set	*
*	working directory to one specified then run GENSTD.PRG		*
*									*
* In:	Directory name							*
*									*
* eg.	DO pov150							*
*	This will try to do a CD POV150 then run GENSTD.PRG		*
*									*
*	This PRG can be called anything you like as long as the name	*
*	is called from the shell command line				*
*************************************************************************
* NOTE:  No error checking in here so don't screw it up!!
*
	move.l	a7,a5
	move.l	4(a5),a5	;get basepage
	move.l	a5,a6
	move.l	$C(a5),d0	;text segment
	add.l	$14(a5),d0	;data segment
	add.l	$1c(a5),d0	;unitialized
	add.l	#$100,d0	;basepage size
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	move.w	d0,-(sp)
	move.w	#$4a,-(sp)
	trap	#1
	add.l	#12,sp

	lea	128(a6),a6	;get command line
	moveq	#0,d0
	move.l	d0,d7
	move.b	(a6)+,d0	;length of command line
	move.b	d0,commandlinelength
	move.b	d0,d7
	lea	workspace(pc),a5
copy	move.b	(a6)+,(a5)+
	sub.w	#1,d0
	bne.s	copy

	lea	directoryspace(pc),a6
	lea	workspace(pc),a5
findspc	tst.b	(a5)
	beq.s	stop
	cmp.b	#' ',(a5)
	beq.s	rest
	move.b	(a5)+,d0
	sub.l	#1,d7
	move.b	d0,(a6)+
	bra.s	findspc

rest	move.b	(a5)+,d1	;rid of spare space!!
	tst.l	d7		;is anymore command line?
	beq.s	no_more

	moveq	#0,d1
	lea	restofcl+1(pc),a6
findend	move.b	(a5)+,(a6)+
	addq	#1,d1
	sub.l	#1,d7
	bne.s	findend
	move.b	d1,restofcl

stop	move.b	#0,(a6)

no_more	pea	directoryspace	;set to new directory
	move.w	#$3b,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	bpl.s	.ok
; If there is an error, just run the assembler with the rest of the command
; line.
	moveq	#0,d0
	move.b	commandlinelength,d0
	lea	restofcl(pc),a5
	lea	workspace,a6
	move.b	d0,(a5)+
.copyrest
	move.b	(a6)+,(a5)+
	sub.w	#1,d0
	bne.s	.copyrest

.ok	pea	0
	pea	restofcl
	pea	asm
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp

	clr.w	-(sp)
	move.w	#$4c,-(sp)
	trap	#1
	tst.l	d0
	beq.s	out
	pea	error
	move.w	#$26,-(sp)
	trap	#14
error	eor.w	#$700,$ffff8240.w
	move.w	#22,d0
ellop	nop
	dbf	d0,ellop
	bra.s	error
out	clr.w	-(sp)
	trap	#1

	SECTION DATA
asm	dc.b	"g:\GENSTD.PRG",0
	even

	SECTION BSS
commandlinelength	ds.b	2
workspace	ds.b	256
directoryspace	ds.b	256
restofcl	ds.b	256
