*
* Protector for ATOM 3.5
*
* Written by MAC SYS DATA of PERSISTENCE OF VISION
*
*
* NOT TO BE SPREAD TO ANY MEMBER OUTSIDE THE FOLLOWING;-
*
*   ANY MEMBER OF P.O.V
*   ANY MEMBER OF A.D.R.
*   MUG UK
*
*
start		move.l	sp,a5
		move.l	4(a5),a5	;get basepage
		move.l	$C(a5),d0	;text segment
		add.l	$14(a5),d0	;data segment
		add.l	$1C(a5),d0	;unitialized
		add.l	#$100,d0	;basepage size
		move.l	d0,-(sp)
		move.l	a5,-(sp)
		move.w	d0,-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp

		bsr	set_super
;;;		move.l	#go,$24.w
go		move.l	#mystack,sp
		bsr	sort_pals
restart		bsr	hide_mouse
		lea	intro(pc),a0
		jsr	p_string
		lea	menu(pc),a0
		jsr	p_string

.get_key	bsr	get_key
		cmp.b	#'1',d0
		beq	protect
		cmp.b	#'2',d0
		beq	deprotect
;		cmp.b	#'3',d0
;		beq	instructions
		cmp.b	#'0',d0
		beq	exit
		bra.s	.get_key


protect		lea	loadafile(pc),a0
		jsr	p_string

		bsr	fsel_input	;get filename + set path
		tst.w	int_out+2	;check for CANCEL button
		bne	.ok
		bsr	show_mouse
		bra	restart
.ok		lea	intro(pc),a0
		jsr	p_string
		lea	protecting(pc),a0
		jsr	p_string
		lea	fsel_filename(pc),a0
		jsr	p_string

		bsr	check_4_file
		tst.l	d0		;was there an error?
		bmi	not_found
		bsr	open_file
		tst.l	d0
		bmi	not_found	;couldn't open
		move.l	d0,d7
		bsr	read_file
		tst.l	d0
		bmi	error_in_reading
		lea	amount_loaded(pc),a1
		move.l	d0,(a1)

;quick check for ATOMIC 3.5......
		lea	space+28(pc),a4
		cmp.l	#$3f3c0002,(a4)
		bne	not_atom
		cmp.l	#$4e4e2040,4(a4)
		bne	not_atom
		cmp.l	#$303c017d,8(a4)
		bne	not_atom
;looks like an ATOMIC header so assume 3.5		

;check for previous protection
		cmp.l	#$487a023e,space+46
		beq	already_prot

		lea	space+46(pc),a1		;insert the protection
		lea	protection_part1(pc),a0
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0),(a1)

		lea	space+$26e(pc),a1
		lea	protection_part2(pc),a0
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0),(a1)

;now save the thing
;lets seek back to the start.. (just for good measure)
		bsr	seek_2_begin
		bsr	write_file
		tst.l	d0
		bmi	error_in_writing
		bsr	close_file
		bra	restart


deprotect	lea	loadaprotfile(pc),a0
		jsr	p_string

		bsr	fsel_input	;get filename + set path
		tst.w	int_out+2
		bne.s	.ok
		bsr	show_mouse
		bra	restart
.ok		lea	intro(pc),a0
		jsr	p_string
		lea	deprotecting(pc),a0
		jsr	p_string
		lea	fsel_filename(pc),a0
		jsr	p_string

		bsr	check_4_file
		tst.l	d0		;was there an error?
		bmi	not_found
		bsr	open_file
		tst.l	d0
		bmi	not_found
		move.l	d0,d7
		bsr	read_file
		tst.l	d0
		bmi	error_in_reading
		lea	amount_loaded(pc),a1
		move.l	d0,(a1)

;check for previous protection
		cmp.l	#$487a023e,space+46
		bne	not_prot

;now alter the prog back to normal
		lea	space+46(pc),a1
		lea	deprotection_part1(pc),a0
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0),(a1)

		lea	space+$26e(pc),a1
		lea	deprotection_part2(pc),a0
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.l	(a0)+,(a1)+
		move.w	(a0),(a1)

;now save the thing
;lets seek back to the start.. (just for good measure)
		bsr	seek_2_begin
		bsr	write_file
		tst.l	d0
		bmi.s	error_in_writing
		bsr	close_file
		bra	restart

exit
no_select
		lea	old_pal(pc),a3
		movem.l	(a3),d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.l	oldstack,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		clr.w	-(sp)
		trap	#1


*************************************************************************
not_found	lea	not_found_mess(pc),a0
		jsr	p_string
		bsr	get_key
		bra	restart

error_in_reading
		lea	error_in_reading_mess(pc),a0
		jsr	p_string
		bsr	get_key
		bra	restart

error_in_writing
		lea	error_in_writing_mess(pc),a0
		jsr	p_string
		bsr	get_key
		bsr	close_file
		bra	restart

not_atom	lea	not_atom_mess(pc),a0
		jsr	p_string
		bsr	get_key
		bra	restart

already_prot	lea	already_prot_mess(pc),a0
		jsr	p_string
		bsr	get_key
		bra	restart

not_prot	lea	not_prot_mess(pc),a0
		jsr	p_string
		bsr	get_key
		bra	restart

p_string	movem.l	d0-a6,-(sp)
		pea	(a0)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		movem.l	(sp)+,d0-a6
		rts

get_key		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp
		rts



fsel_input	movem.l	d1-d3/a0-a2,-(sp)
		bsr	show_mouse
		lea	search(pc),a3
		bsr	get_drive_path
		lea	path(pc),a2
		tst.b	(a2)+
		beq.s	.clear
.notclear	tst.b	(a2)+
		bne.s	.notclear
.clear		move.b	#'\',-1(a2)
.build		move.b	(a3)+,(a2)+
		bne.s	.build

		move.l	#path,addr_in
		move.l	#fsel_filename,addr_in+4
		move.w	#90,d0
		bsr	CALL_AES

		bsr	hide_mouse

		tst.w	d0		;check for okay load
		beq.s	.cancel_button
		bsr.s	set_fsel_path
		moveq	#0,d0
		bra.s	.ok
.cancel_button	moveq	#-1,d0
.ok		movem.l	(sp)+,d1-d3/a0-a2
		rts

set_fsel_path	lea	path(pc),a1	;a valid was returned so set path
		moveq	#0,d0
		move.b	(a1)+,d0
		move.l	a1,-(sp)	;pea	(a1)
		sub.w	#'A',d0
		move.w	d0,-(sp)	;set default drive
		move.w	#$e,-(sp) 
		trap	#1
		addq.l	#4,sp
		move.l	(sp)+,a1
.not		move.b	(a1)+,d0
		beq.s	.get_path
		cmp.b	#'*',d0
		bne.s	.not
		clr.b	-(a1)
.get_path	pea	path(pc)
		move.w	#$3b,-(sp)
		trap	#1
		addq.l	#6,sp
		rts


get_drive_path	movem.l	a0-a2,-(sp)
		lea	path(pc),a1
		move.l	a1,a2
		moveq	#64,d0
.clear_old	clr.b	(a1)+
		dbf	d0,.clear_old

		move.w	#$19,-(sp)	;get current drive
		trap	#1
		addq.l	#2,sp
		add.w	#'A',d0
		move.b	d0,(a2)+	;poke drive letter
		move.b	#':',(a2)+

		clr.w	-(sp)		;default drive
		pea	(a2)		;64 byte buffer for pathname
		move.w	#$47,-(sp)	;get current directory
		trap	#1
		addq.l	#8,sp
		movem.l	(sp)+,a0-a2
		rts


check_4_file	move.w	#-1,-(sp)	;FS_FIRST (does it exist?)
		pea	fsel_filename(pc)
		move.w	#$4e,-(sp)
		trap	#1
		addq.l	#8,sp
		rts

open_file	move.w	#2,-(sp)	;read/write
		pea	fsel_filename(pc)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp
		rts

read_file	pea	space(pc)
		move.l	#$c000000,-(sp)	;max file length to load
		move.w	d7,-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp
		rts

seek_2_begin	clr.w	-(sp)		;seek to x bytes from beginning
		move.w	d7,-(sp)
		move.l	#0,-(sp)	;0 bytes from beginning
		move.w	#$42,-(sp)
		trap	#1
		lea	10(sp),sp
		rts

write_file	pea	space(pc)
		lea	amount_loaded(pc),a3
		move.l	(a3),-(sp)
		move.w	d7,-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea	12(sp),sp
		rts

close_file	move.w	d7,-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#4,sp
		rts

hide_mouse	movem.l	d0-d2/a0-a2,-(sp)
		dc.w	$a00a
		movem.l	(sp)+,d0-d2/a0-a2
		rts

show_mouse	movem.l	d0-d2/a0-a2,-(sp)
		dc.w	$A009
		movem.l	(sp)+,d0-d2/a0-a2
		rts


sort_pals	movem.l	$ffff8240.w,d0-d7
		lea	old_pal(pc),a3
		movem.l	d0-d7,(a3)
		lea	new_pal(pc),a3
		movem.l	(a3),d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts

set_super	clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,oldstack
		rts



bgnd1	MACRO
	dc.b	27,'c',1
	ENDM
bgnd2	MACRO
	dc.b	27,'c',2
	ENDM
bgnd3	MACRO
	dc.b	27,'c',3
	ENDM
bgnd4	MACRO
	dc.b	27,'c',4
	ENDM

fgnd1	MACRO
	dc.b	27,'b',1
	ENDM
fgnd2	MACRO
	dc.b	27,'b',2
	ENDM
fgnd3	MACRO
	dc.b	27,'b',3
	ENDM
fgnd4	MACRO
	dc.b	27,'b',4
	ENDM

	include	AESLIB.S


	SECTION DATA
protection_part1
		dc.l	$487a023e
		dc.l	$3f3c0026
		dc.l	$4e4edffc
		dc.l	$00000008
		dc.l	$4e714e71
		dc.l	$4e714e71
		dc.l	$4e714e71
		dc.w	$4e71

protection_part2
		dc.l	$204f43fa
		dc.l	$001223c9
		dc.l	$00000010
		dc.l	$203c0000
		dc.l	$08084e7b
		dc.l	$00022e48
		dc.w	$4e75



deprotection_part1
		dc.l	$3ebc0004
		dc.l	$4e4e4a00
		dc.l	$41FA0236
		dc.l	$6706117C
		dc.l	$00390003
		dc.l	$48503F3C
		dc.l	$00094E71
		dc.w	$504F

deprotection_part2
		dc.l	$1B592025
		dc.l	$41544F4D
		dc.l	$494B2076
		dc.l	$332E3520
		dc.l	$62792041
		dc.l	$4C544149
		dc.w	$5220







search		dc.b	"*.PRG",0
		even

fsel_button	dc.l	0		;button result from FSEL_INPUT

path		dcb.b	78,0		;pathname found from FSEL_INPUT
		even

fsel_filename	dcb.b	66,0
		even

intro	bgnd4
	dc.b	27,'E'
	fgnd1
	dc.b	27,'Y',32+0,32+28,"ATOMIC 3.5 PROTECTOR v1.0"
	dc.b	27,'Y',32+1,32+28,"-------------------------"
	fgnd2
	dc.b	27,'Y',32+3,32+16,"Written by MAC SYS DATA of Persistence Of Vision"
	dc.b	0
	even
menu	fgnd3
	dc.b	27,'Y',32+6,32+32,"1: Protect a PRG"
	dc.b	27,'Y',32+8,32+32,"2: Deprotect a PRG"
	dc.b	27,'Y',32+10,32+32,"3: ************"
	dc.b	27,'Y',32+12,32+32,"0: Exit            "
	dc.b	27,'Y',32+16,32+30,"                    "
	fgnd1
	dc.b	0

protecting	fgnd3
		dc.b	27,'Y',32+6,32+30,"Protecting: "
		dc.b	0

deprotecting	fgnd3
		dc.b	27,'Y',32+6,32+30,"Deprotecting: "
		dc.b	0

loadafile	fgnd2
		dc.b	27,'Y',32+23,32+23,"Load a PRG packed with ATOMIC 3.5"
		fgnd1
		dc.b	0

loadaprotfile	fgnd2
		dc.b	27,'Y',32+23,32+30,"Load a protected PRG"
		fgnd1
		dc.b	0

not_found_mess	fgnd3
		dc.b	27,'Y',32+6,32+30,"                             "
		dc.b	27,'Y',32+12,32+24,"       File not found"
		dc.b	27,'Y',32+16,32+34,"Press a key."
		fgnd1
		dc.b	0

error_in_reading_mess
		fgnd3
		dc.b	27,'Y',32+6,32+30,"                             "
		dc.b	27,'Y',32+12,32+24,"        Couldn't read       "
		dc.b	27,'Y',32+16,32+34,"Press a key."
		fgnd1
		dc.b	0

error_in_writing_mess
		fgnd3
		dc.b	27,'Y',32+6,32+30,"                             "
		dc.b	27,'Y',32+12,32+24,"        Couldn't write      "
		dc.b	27,'Y',32+16,32+34,"Press a key."
		fgnd1
		dc.b	0


not_atom_mess	fgnd3
		dc.b	27,'Y',32+6,32+30,"                             "
		dc.b	27,'Y',32+12,32+24,"File NOT packed with Atomic 3.5"
		dc.b	27,'Y',32+16,32+34,"Press a key."
		fgnd1
		dc.b	0

already_prot_mess	fgnd3
		dc.b	27,'Y',32+6,32+30,"                             "
		dc.b	27,'Y',32+12,32+28,"File already protected!"
		dc.b	27,'Y',32+16,32+34,"Press a key."
		fgnd1
		dc.b	0

not_prot_mess	fgnd3
		dc.b	27,'Y',32+6,32+30,"                             "
		dc.b	27,'Y',32+12,32+28,"File is NOT protected!"
		dc.b	27,'Y',32+16,32+34,"Press a key."
		fgnd1
		dc.b	0

		even


new_pal		dc.w	$002,$770,$070,$777,$000,$000,$000,$000
		dc.w	$000,$000,$000,$000,$000,$000,$000,$000

	SECTION BSS

old_pal		ds.w	16
oldstack	ds.l	1

		ds.l	400
mystack		ds.l	1
amount_loaded	ds.l	1
space		ds.l	1
