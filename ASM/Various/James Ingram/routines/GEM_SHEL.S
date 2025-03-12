* GEMDOS shell routines
*  by James Ingram, April 1993
*
* may be included in a file
* or assembled to GST linkable format using the MK_LIB.S source code



	ifd	link_library
	MODULE	KEYBOARD_IO
	
	XDEF	conin,conout,rawconio,conin_no_echo
	XDEF	print_line,read_line,constat

	endc


conin:
	move.w	#1,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

conout:
	move.w	d0,-(a7)
	move.w	#2,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

rawconio:
	move.w	#$ff,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

conin_no_echo:
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

print_line:
	pea	(a0)
	dc.w	$a00a
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	dc.w	$a009
	rts

read_line:
	pea	(a0)
	move.w	#10,-(a7)
	trap	#1
	addq.l	#2,a7

	move.l	(a7)+,a0	; get addr of message
	addq.l	#2,a0		; start of text
	clr.b	(a0,d0.w)	; terminate with 0
	rts

constat:
	move.w	#$b,-(a7)
	trap	#1
	addq.l	#2,a7
	rts



	ifd	link_library
	MODULE	AUX_IO
	
	XDEF	aux_input,aux_output,printer_output,printer_stat,auxin_stat
	XDEF	auxout_stat
	endc


aux_input:
	move.w	#3,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

aux_output:
	move.w	d0,-(a7)
	move.w	#4,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

printer_output:
	move.w	d0,-(a7)
	move.w	#5,-(a7)
	trap	#1
	addq.l	#4,a7
	rts

printer_stat:
	move.w	#$11,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

auxin_stat:
	move.w	#$12,-(a7)
	trap	#1
	addq.l	#2,a7
	rts


auxout_stat:
	move.w	#$13,-(a7)
	trap	#1
	addq.l	#2,a7
	rts


	ifd	link_library
	MODULE	MEMORY
	
	XDEF	res_mem,rel_mem,res_mem_wipe

	endc

res_mem_wipe:
	movem.l	d2-6,-(a7)

	move.l	d0,-(a7)
	bsr	res_mem

	move.l	(a7)+,d1
	addq.l	#1,d1
	bclr	#0,d1		; ensure even length

	tst.l	d0
	bmi.s	.done

* wipe memory
	moveq	#0,d2
	move.l	d2,d3
	move.l	d2,d4
	move.l	d2,d5


	move.l	d0,a0
	add.l	d1,a0		; go to end of area

	move.l	d1,d6

	lsr.l	#4,d1		; divide by 16
	tst.l	d1
	beq.s	.do_small

.clr:
	movem.l	d2-5,-(a0)
	subq.l	#1,d1
	bne.s	.clr

.do_small:
* now do small bit we couldn't do before!
	and.w	#$f,d6
	beq.s	.done

.clr2:
	clr.b	-(a0)
	subq.w	#1,d6
	bne.s	.clr2

.done:
	movem.l	(a7)+,d2-6
	rts



res_mem:
	move.l	d0,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7

	tst.l	d0
	bne.s	.not_zed

	moveq	#-1,d0
.not_zed:

	rts


rel_mem:
	move.l	d0,-(a7)
	move.w	#$49,-(a7)
	trap	#1
	addq.l	#6,a7
	rts



	ifd	link_library
	MODULE	DRIVE_STUFF

	XDEF	set_drive,get_drive
	XDEF	get_disk_free,calc_disk_free
	endc

set_drive:
	move.w	d0,-(a7)
	move.w	#$e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts


get_drive:
	move.w	#$19,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

get_disk_free:
	clr.w	-(a7)
	pea	(a0)
	move.w	#$36,-(a7)
	trap	#1
	addq.l	#8,a7
	rts

calc_disk_free:
* return disk space in bytes in d0

	move.l	#disk_free_buffer,a0
	pea	(a0)

	bsr	get_disk_free	; get disk info

	move.l	(a7)+,a0
	move.l	(a0),d0		; get free units
	move.l	8(a0),d1	; get sector size
	move.l	12(a0),d2	; get secs per unit
	mulu	d2,d1
	mulu	d1,d0
	rts

	ifd	link_library
	section	bss
	endc

disk_free_buffer:
	ds.b	16


	ifd	link_library
	MODULE	SEARCH_STUFF


	XDEF	set_dta,get_dta
	XDEF	search_folder,search_file,search_hidden,search_next
	XDEF	dta,search_folder_only,search_next_folder

	endc


set_dta:
	pea	(a0)
	move.w	#$1a,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

get_dta:
	move.w	#$2f,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

search_folder:
	moveq	#$10,d0
	bra.s	do_search

search_file:
	moveq	#0,d0
	bra.s	do_search

search_hidden:
	moveq	#2,d0

do_search:
	move.w	d0,-(a7)	; file attributes
	pea	(a0)		; filename
	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	rts

search_next:
	move.w	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

search_folder_only:
	bsr	search_folder
	tst.w	d0
	beq.s	.some

.rts:
	rts

.some:
* got a file/folder
	move.b	dta+21,d0
	and.b	#$10,d0
	beq.s	.not_fold	; was it a folder?

* YES!
	moveq	#0,d0
	rts

.not_fold:
* not a folder!
	bsr	search_next_folder
	rts

search_next_folder:
	bsr	search_next
	tst.w	d0
	bne.s	.not_fnd

	move.b	dta+21,d0
	and.b	#$10,d0
	beq.s	search_next_folder

	moveq	#0,d0

.not_fnd:
	rts


	ifd	link_library
	section	bss
	endc

dta:
	ds.b	44


	ifd	link_library
	MODULE	DIR_STUFF

	XDEF	make_dir,remove_dir,change_dir
	XDEF	get_dir

	endc

make_dir:
	pea	(a0)
	move.w	#$39,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

remove_dir:
	pea	(a0)
	move.w	#$3a,-(a7)
	trap	#1
	addq.l	#6,a7
	rts


change_dir:
	pea	(a0)
	move.w	#$3b,-(a7)
	trap	#1
	addq.l	#6,a7
	rts

get_dir:
	clr.w	-(a7)
	pea	(a0)		; buffer for pathname
	move.w	#$47,-(a7)
	trap	#1
	addq.l	#8,a7
	rts




	ifd	link_library
	MODULE	FILE_STUFF

	XDEF	create_file,create_special
	XDEF	open_file,close_file,read_file,write_file
	XDEF	delete_file

	XDEF	seek_start,seek_end,seek_now
	XDEF	execute_prog

	XDEF	rename_file
	endc


rename_file:
	pea	(a0)	; new name
	pea	(a1)	; old name
	clr.w	-(a7)
	move.w	#$56,-(a7)
	trap	#1
	lea	12(a7),a7
	rts


execute_prog:
	pea	(a0)
	pea	(a1)
	pea	(a2)
	clr.w	-(a7)
	move.w	#$4b,-(a7)
	trap	#1
	lea	16(a7),a7
	rts



create_special:
	move.w	d0,-(a7)
	bra.s	create_rej

create_file:
	clr.w	-(a7)
create_rej:
	pea	(a0)
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7

	move.w	d0,d7

	rts


open_file:
	move.w	#2,-(a7)

open_rej:
	pea	(a0)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7

	move.w	d0,d7

	rts


close_file:
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts


read_file:
	pea	(a0)		; buffer
	move.l	d0,-(a7)	; len
	move.w	d7,-(a7)	; handle
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	rts


write_file:
	pea	(a0)
	move.l	d0,-(a7)
	move.w	d7,-(a7)
	move.w	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	rts

delete_file:
	pea	(a0)
	move.w	#$41,-(a7)
	trap	#1
	addq.l	#6,a7
	rts


seek_start:
	moveq	#0,d1
	bra.s	do_seek

seek_end:
	moveq	#2,d1
	bra.s	do_seek

seek_now:
	moveq	#1,d1
do_seek:
	move.w	d1,-(a7)
	move.w	d7,-(a7)
	move.l	d0,-(a7)
	move.w	#$42,-(a7)
	trap	#1
	lea	10(a7),a7
	rts



	ifd	link_library

	MODULE	ODD_DISK_STUFF
	XDEF	get_file_date_time,set_file_date_time

	endc

get_file_date_time:
	move.w	#1,-(a7)
do_date_time:
	pea	(a0)
	move.w	d7,-(a7)
	move.w	#$57,-(a7)
	trap	#1
	lea	10(a7),a7
	rts

set_file_date_time:
	clr.w	-(a7)
	bra.s	do_date_time




	ifd	link_library
	MODULE	FILE_ATTRIB

	XDEF	change_file_attrib,read_file_attrib
	endc


change_file_attrib:
	move.w	d0,-(a7)	; new attribute
	move.w	#1,-(a7)	; set flag
do_attrib:
	pea	(a0)		; filename
	move.w	#$43,-(a7)
	trap	#1
	lea	10(a7),a7
	rts


read_file_attrib:
	clr.l	-(a7)		; no attribute, and read flag
	bra.s	do_attrib




	ifd	link_library
	MODULE	GET_VERSION

	XDEF	get_version

	endc

get_version:
	move.w	#$30,-(a7)
	trap	#1
	addq.l	#2,a7
	rts



	ifd	link_library
	MODULE	DATE_TIME
	
	XDEF	get_date,set_date,get_time,set_time
	endc


get_date:
	move.w	#$2a,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

set_date:
	move.w	d0,-(a7)
	move.w	#$2b,-(a7)
	trap	#1
	addq.l	#4,a7
	rts


get_time:
	move.w	#$2c,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

set_time:
	move.w	d0,-(a7)
	move.w	#$2d,-(a7)
	trap	#1
	addq.l	#4,a7
	rts



	ifd	link_library
	MODULE	SUPER_MODE

	XDEF	super_on,super_off
	endc

super_on:
	clr.l	-(a7)
do_sup:
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7

	move.l	d0,_old_stack
	rts

super_off:
	move.l	_old_stack,-(a7)
	bra.s	do_sup


	ifd	link_library
	section	bss
	endc

_old_stack:
	ds.l	1


