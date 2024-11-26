* Handy routines by James Ingram, April 1993 - July 1993
* for including or GST Linking with MK_LIB.S

	ifd	link_library
	MODULE	to_lower
	XDEF	to_lower
	endc

to_lower:
* enter with d0 = char
* returns d0 as lowercase char

	cmp.b	#"A",d0
	blt.s	.not_big

	cmp.b	#"Z",d0
	bgt.s	.not_big

	or.b	#$20,d0
.not_big:
	rts




	ifd	link_library
	MODULE	ALL_CAPS
	
	XDEF	all_caps
	endc


all_caps:
* make all chars in string at a0 capitals
* does not change anything!

	pea	(a0)
	move.w	d0,-(a7)
do_caps:
	move.b	(a0),d0
	beq.s	caps_end_string

	cmp.b	#"a",d0
	blo.s	not_letter

	cmp.b	#"z",d0
	bhi.s	not_letter

	bclr	#5,d0
not_letter:
	move.b	d0,(a0)+
	bra.s	do_caps

caps_end_string:
	move.w	(a7)+,d0
	move.l	(a7)+,a0
	rts





	ifd	link_library
	MODULE	PRINT_MES
	XDEF	print_mes
	endc


print_mes:
	pea	(a0)
	move.w	#9,-(a7)
	dc.w	$a00a
	trap	#1
	dc.w	$a009
	addq.l	#6,a7
	rts



	ifd	link_library
	MODULE	BITS_N_PIECES
	
	XDEF	get_path,no_wildcard,get_slash_back,copy_a0_a1,get_zed
	XDEF	put_name

	XREF	change_dir
	XREF	set_drive

	endc

put_name:
* put file name in a0 at a1
	move.l	a1,a2
	moveq	#14-1,d0
_sp:
	move.b	#" ",(a2)+
	dbra	d0,_sp

_sp2:
	move.b	(a0)+,(a1)+
	bne.s	_sp2

	move.b	#" ",-(a1)

dun_sp2:
	rts


get_path:
* get pathname without wildcard
* enter with pathname and wilcard addr in a0
* and where to put just pathname in a1

	bsr	no_wildcard

	moveq	#0,d0
	move.b	(a0),d0
	sub.b	#"A",d0

	pea	(a1)

	bsr	set_drive

	move.l	(a7)+,a0
	bsr	change_dir

	rts

no_wildcard:
	movem.l	a0-1,-(a7)

	addq.l	#2,a0		; past X:
	move.l	a0,d0
	bsr	get_zed
	bsr	get_slash_back
	addq.l	#1,a0		; include final slash

	move.l	a0,d1
	sub.l	d0,d1		; d1 = length moved

	add.l	d1,a1
	clr.b	(a1)		; ensure path ends with 0

	subq.w	#1,d1
	bmi.s	dun_path

copy_path:
	move.b	-(a0),d0
	cmp.b	#":",d0
	beq.s	dun_path
	move.b	d0,-(a1)
	bra.s	copy_path

dun_path:
	movem.l	(a7)+,a0-1
	rts


get_slash_back:
	cmp.b	#"\",-(a0)
	bne.s	get_slash_back
	rts


copy_a0_a1:
* copy string from a0 to a1
	move.b	(a0)+,(a1)+
	bne.s	copy_a0_a1
	rts

get_zed:
* get zero byte from a0 position
	tst.b	(a0)+
	bne.s	get_zed
	subq.l	#1,a0
	rts


	ifd	link_library
	MODULE	what_is_path
	XREF	get_drive,get_dir
	XDEF	what_is_path
	XDEF	current_pathname
	endc

what_is_path:
	pea	(a5)

	move.l	#current_pathname,a5
	bsr	get_drive
	add.b	#"A",d0
	move.b	d0,(a5)+
	move.b	#":",(a5)+

	move.l	a5,a0
	bsr	get_dir

.test:
	tst.b	(a5)+
	bne.s	.test

	move.b	#"\",-1(a5)
	clr.b	(a5)

	move.l	#current_pathname,a0
	move.l	(a7)+,a5
	rts

	ifd	link_library
	section	bss
	endc

current_pathname:	ds.b	512
	


