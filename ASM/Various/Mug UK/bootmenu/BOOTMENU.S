
test	equ	1

	ifne	test
	include	'install.s'
	endc
	
 
; Regression Therapy Bootmenu #1
; ------------------------------
;
; Bootsector Coded by: MUG U.K(tm)
;

	opt p+,o+

	clr.w	-(sp)
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	adda.l	#12,sp

	clr.w	$ffff8240.w
	move.w	#$777,$ffff825e.w

	lea	text(pc),a1
	bsr.s	print

get_key	move.b	$fffffc02.w,d0

key1	cmp.b	#$3b,d0	; was 1 pressed ???
	bne.s	key2	; no it wasn't
	lea	file1(pc),a0	; if it was then a0 = filename
	bra.s	load		; and load it

key2	cmp.b	#$3c,d0
	bne.s	key3
	lea	file2(pc),a0
	bra.s	load

key3	cmp.b	#$3d,d0
	bne.s	key4
	lea	file3(pc),a0
	bra.s	load

key4	cmp.b	#$3e,d0
	bne.s	keysp
	lea	file4(pc),a0
	bra.s	load
;
;key5	cmp.b	#$3f,d0
;	bne.s	key6
;	lea	file5(pc),a0
;	bra.s	load
;
;key6	cmp.b	#$40,d0
;	bne.s	keysp
;	lea	file6(pc),a0
;	bra.s	load
;
keysp	cmp.b	#$39,d0
	beq.s	exit
	bne.s	get_key

load	lea	loading(pc),a1
	bsr.s	print

	pea	null(pc)		; load file
	pea	null(pc)
	move.l	a0,-(sp)
	clr.w	-(sp)
	move.w	#$4b,-(sp)
	trap	#1
	lea	16(sp),sp

	move.l	$4.w,a0		; Hard-reset
	jmp	(a0)

exit	rts

print	move.l	a1,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts

null	dc.l	0

file1	dc.b	"bt_load.mug",0
	even

file2	dc.b	"eagles.mug",0
	even

file3	dc.b	"armymove.mug",0
	even

file4	dc.b	"wizball.mug",0
	even

;file5	dc.b	"illusion.src",0
;	even
;
;file6	dc.b	"no_coopr.src",0
;	even

text	dc.b	"Regression Therapy #1",13,10
	dc.b	"---------------------",13,10,10,10
	dc.b	"F1 - Black Tiger+",13,10,10
	dc.b	"F2 - Into The Eagles Nest+",13,10,10
	dc.b	"F3 - Army Moves+",13,10,10
	dc.b	"F4 - Wizball+",13,10,10,10
	dc.b	"SPACE - Bootmenu repairer",13,10,10,10
	dc.b	"Disk compiled by: MUG U.K",191,13,10,10
	dc.b	"Apologies for the bootsector menu :)",13,10
	dc.b	0
	even

loading	dc.b	27,'E',7,'Loading ....',13,10,0
	even

	dc.b	'Regression Therapy - website.lineone.net/~mikemee'
	even

blanks	ds.b	8