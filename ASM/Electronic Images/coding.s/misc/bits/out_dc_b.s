*** Out To dc.b
***	By RaY.

debug	equ	1
	opt	d+

	include	"stdlib.s"
	include	"include.s"

	Powerup

	lea	out_bfr(pc),a1
	move.l	a1,d6

	Fopen	#0,in_file(pc)
	move.l	d0,d7
	bmi.s	line_loop
	Fread	in_bufr,#(15*32768)+1,d7
	tst.l	d0
	bmi.s	line_loop
	Fclose	d7

	lea	in_bufr,a0
	move.l	#"	dc.",d0
	move.w	#"b	",d1
	move.l	#",$",d2
	move.l	#"$",d3

	lea	text(pc),a2
textin	cmp.b	#0,(a2)
	beq.s	line_loop
	move.b	(a2)+,(a1)+
	bra.s	textin

line_loop
	cmp.b	#"P",(a0)		Program Memory?
	beq.s	pass
	cmp.b	#"X",(a0)		X Memory?
	beq.s	pass
	cmp.b	#"Y",(a0)		Y Memory?
	beq.s	pass
	bra.s	exit			End Of File.
pass	move.l	d0,(a1)+			dc.
	move.w	d1,(a1)+		b	
	move.b	d3,(a1)+		$
	addq	#7,a0
	move.w	(a0)+,(a1)+		XX
	move.w	d2,(a1)+		,$
	move.w	(a0)+,(a1)+		XX
	move.w	d2,(a1)+		,$
	move.w	(a0)+,(a1)+		XX
	move.b	(a0)+,(a1)+		Carridge Return
	addq.l	#1,a0
	bra.s	line_loop

exit	sub.l	d6,a1
	Fcreate	#0,out_fle(pc)		Create Output file
	move.l	d0,d7
	bmi.s	fin
	Fwrite	out_bfr,a1,d7
	tst.l	d0
	bmi.s	fin
	Fclose	d7

fin	Powerdown

text	dc.b	"* File Created by 'Out To Dc.b' By Ray of Digital Chaos.",10,13,0
in_file	dc.b	"d:\a56.out",0
out_fle	dc.b	"d:\dsp.s",0
Section BSS
out_bfr	ds.b	(18*32768)		18 bytes/line * 32768(max) words (1 word/line)
in_bufr	ds.b	(15*32768)		15 bytes/line * 32768(max) words (1 word/line)