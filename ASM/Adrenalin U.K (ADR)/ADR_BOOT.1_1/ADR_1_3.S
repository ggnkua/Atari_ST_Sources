; Adrenalin Bootsector v1.1 by Mookie/ADR
;
; Ripped/Updated by MUG U.K(tm) - credited as Mookie !!
;
; Now v1.3 as Mookie has already done v1.2
;
; Hey! Mark, if you change any of this code from v1.1 in
; v1.2, can you alter it here as well.  All I have done is shorten
; the code by using a print subroutine instead of three GEMDOS
; calls !  The spare 'blanks' at the end could be used for something
; else.  Eg. XBIOS(32) noise ??  Hard reset when virus found ? 


	opt	o+

yes	equ	1	; include Installer program ?
no	equ	0	; assemble bootsector only (480 bytes or less!)

program	equ	yes	; when set to no = total bytes MUST equal 480

	section	text

	ifne	program
	include	'install.s'
	endc

	opt	p+

begin	bra.s	start
	dc.b	'<<< ADRENALIN U.K. VIRUS FREE BOOTBLOCK '
	dc.b	'Version 1.3 written by MOOKIE (C) 1/7/93 >>>'
	even

start	move.w	#7,$ffff8240.w		; blue
	move.w	#$ffff,$ffff825e.w	; white

	lea	intro(pc),a2		; intro text
	bsr.s	print

	move.l	$426.w,d0
	cmp.l	#$31415926,d0		; res-vector set ?
	beq.s	alert

	movea.l	$42a.w,a0
	movea.l	a0,a4
	lea	16(a0),a0
	move.l	(a0)+,d0
	cmp.l	#$12123456,d0
	beq.s	alert
	adda.l	#$14,a4
	move.l	(a4),d0
	cmp.l	#$12123456,d0
	beq.s	alert
	move.l	$472.w,d0
	move.l	$4f2.w,d1
	movea.l	d0,a0
	cmpi.l	#$6072606a,(a0)
	beq.s	safe
	cmp.l	d1,d0
	bls.s	alert

safe	lea	novirus(pc),a2
	bsr.s	print

;
; A wee pause before exiting
;
	move.l	#$54120,d1
delay	subq.l	#1,d1
	bne.s	delay
	rts

alert	move.w	#$700,$ffff8240.l
	lea	virus(pc),a2
	bsr.s	print
	bra.s	alert

print	pea	(a2)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

intro	dc.b	27,'c0',27,'b/',27,'F'
	dc.b	27,'Y',32+1,32+13,'ADRENALIN U.K.',0
	even
novirus	dc.b	27,'c0',27,'b/',27,'F'
	dc.b	27,'Y',32+14,32+8,'YOU ARE FREE OF VIRUSES',0
	even
virus	dc.b	27,'c0',27,'b/',27,'F'
	dc.b	27,'Y',32+14,32+10,'<<< VIRUS FOUND >>>'
	dc.b	27,'Y',32+16,32+4,'** SWITCH OFF ST AND RE-LOAD **',0
	even
;
; This fills up some of the gaps left at the end !!
;
blanks	rept	32
	dc.b	'ADR!'
	endr

	opt	p-