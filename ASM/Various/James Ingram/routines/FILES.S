* File load / save routines
*  by James Ingram, April 1993

* assumes that AES_SHEL.S is present for AES messages etc
* also needs GEM_SHEL.S for file accessing etc
*
* may be INCLUDED in code
* or assembled to GST linkable
* use file "MK_LIB.S" to make libray code
*
* note when INCLUDING - this source expects:
*	AES_SHEL.S
*	GEM_SHEL.S
* to be present, as it references them!


path_len	equ	512


	ifd	link_library
	MODULE	select_load
	
	XDEF	select_load
	
	XREF	file_selector
	XREF	load_a_file
	endc


select_load:
* pass wildcard in a0
* returns:
* d0 = buffer addr or error code
* d1 = file length
* a0 = addr of filename

	bsr	file_selector
	tst.w	d0
	bpl.s	.noerr
	rts

.noerr:
	bsr	load_a_file
	rts



	ifd	link_library
	MODULE	FILE_SELECTOR

	XDEF	file_selector
	XDEF	path,just_path,file_name
	XDEF	restore_path

	XREF	aes
	XREF	get_drive,get_path,get_dir,get_zed,copy_a0_a1
	XREF	get_slash_back
	XREF	set_drive,change_dir
	endc

file_selector:
* display the file selector
* wildcard or 0 passed in a0
* MUST contain wildcard first time!
* from then on zero can be passed

* returns filename in a0 and path in a1


	move.l	#path,a5
	pea	(a0)		; store wildcard addr

* get pathname
	bsr	get_drive

	move.l	#orig_drv,a0
	move.b	d0,(a0)		; keep original drive

	add.b	#"A",d0
	move.b	d0,(a5)+
	move.b	#":",(a5)+

	move.l	a5,a0
	bsr	get_dir

* now keep copy of original path
	move.l	a5,a0
	move.l	#orig_path,a1

.copy:
	move.b	(a0)+,(a1)+
	bne.s	.copy


	move.l	a5,a0
	bsr	get_zed
	move.l	a0,a5


	move.l	(a7),a0
	move.b	#"\",(a5)+
	move.l	a5,a1
	bsr	copy_a0_a1

	move.l	(a7)+,a0
	cmp.l	#0,a0
	beq.s	.path_rej

	move.l	a0,a1

* same path, different wildcard
	move.l	#path,a0
	bsr	get_zed		; get end of pathname

	bsr	get_slash_back	; get last slash
	addq.l	#1,a0

	exg.l	a0,a1
	bsr	copy_a0_a1	; put in new wildcard

.path_rej:

	selector	path,file_name

	subq.w	#1,d0
	subq.w	#1,d1
	or.w	d0,d1
	bne.s	.selector_error

	move.l	#path,a0
	move.l	#just_path,a1
	bsr	get_path

	move.l	#file_name,a0
	move.l	#just_path,a1
	moveq	#0,d0
	rts

.selector_error:
	moveq	#-1,d0
	rts


restore_path:
* restore the original pathname
* which may have been altered by the file selector

	move.l	#orig_drv,a0
	moveq	#0,d0
	move.b	(a0),d0

	bsr	set_drive

	move.l	#orig_path,a0
	bsr	change_dir

	rts


	ifd	link_library
	section	bss
	endc

path:
	ds.b	path_len
just_path:
	ds.b	path_len
file_name:
	ds.b	14

orig_path:
	ds.b	path_len
orig_drv:
	ds.b	1

	even



	ifd	link_library
	MODULE	LOAD_A_FILE

	XDEF	load_a_file,read_all
	XDEF	open_some,read_some
	XDEF	seek_some

	XREF	close_some
	XREF	aes
	XREF	all_caps
	XREF	set_dta,search_file,res_mem_wipe,rel_mem
	XREF	open_file,read_file,close_file,put_name
	XREF	dta

	endc

seek_some:
* d7 = handle
* d0 = type of search
* d1 = length

	move.w	d0,-(a7)
	move.w	d7,-(a7)
	move.l	d1,-(a7)
	move.w	#$42,-(a7)
	trap	#1
	lea	10(a7),a7
	rts


load_a_file:
* load in an entire file
* a0 = filename
* d0 = 0 or amount of memory to use
* or -(amount to add on)
* returns d0 = buffer addr or error code
* d1 = file length
* a0 = addr of filename

	move.l	d0,d6

	bsr	open_some
	tst.l	d0
	bmi.s	.open_error

	bsr	read_all
	tst.l	d0
	bmi.s	.read_error

	bsr	close_some

	move.l	#dta+f_name,a0	; return file name
	move.l	d6,d1		; return file length
	move.l	d5,d0		; return buffer addr

.open_error:
	rts

.read_error:
* was the file too big?
	cmp.w	#-2,d0
	beq.s	.too_big	; branch if it was

	move.l	d5,d0
	bsr	rel_mem		; free memory I got

	move.l	#dta+f_name,a0
	move.l	#_file_readm,a1
	bsr	put_name


	alert	#1,_readd_mes

.too_big:
	bsr	close_some
	moveq	#-1,d0
	rts



open_some:
* a0 = file name
*
* returns
*	d0 = 0 is OK; -1 is error
*	d7 = handle

	bsr	all_caps		; filename becomes capital letters...

	move.l	a0,a5

	move.l	#dta,a0
	bsr	set_dta

	move.l	a5,a0
	bsr	search_file

	tst.w	d0
	bne.s	.not_found

* file is there!

	move.l	a5,a0
	bsr	open_file
	tst.w	d7
	bmi.s	.open_error
	beq.s	.open_error

	moveq	#0,d0
	rts

.open_error:
	moveq	#-1,d0
	rts

.not_found:
* file not found!
	move.l	a5,a0
	move.l	#_file_nf,a1
	bsr	put_name

	alert	#1,_found_mes

	moveq	#-1,d0
	rts



read_some:
* d0 = length to read
* a0 = addr to read to
* d7 = file handle

	move.l	d0,d6
	bsr	read_file

	sub.l	d6,d0
	beq.s	.no_error		; branch if not all file read in ok

	moveq	#-1,d0

.no_error:
	rts



read_all:
* d6 = 0 or amount of memory to use or -(amount to add on)

	move.l	dta+f_len,d0
	tst.l	d6
	beq.s	.dun_mem
	bpl.s	.use_it

* amount to add on!
	not.l	d6
	addq.l	#1,d6
	add.l	d6,d0
	bra.s	.dun_mem

.use_it:
* is it enough?
	move.l	d6,d5
	sub.l	d0,d5
	bpl.s	.enough

* no!
	alert	#1,not_enough_mem
	moveq	#-2,d0
	rts

.enough:
	move.l	d6,d0
.dun_mem:

	bsr	res_mem_wipe
	tst.l	d0
	bmi.s	_mem_err
	beq.s	_mem_err

	move.l	d0,d5		; keep buffer addr safe

	move.l	d5,a0			; get buffer addr
	move.l	dta+f_len,d0	; and length of file

	bsr	read_some
	rts



_mem_err:
	move.l	a5,a0
	move.l	#_mem,a1
	bsr	put_name

	alert	#1,_mem_mes
	
	moveq	#-1,d0
	rts





_open_error:
	move.l	#dta+f_name,a0
	move.l	#_file_open,a1
	bsr	put_name

	alert	#1,_open_mes

	moveq	#-1,d0
	rts






not_enough_mem:
	exclam
	dc.b	"[File too big for buffer ]"
	dc.b	"[Cancel]",0

_mem_mes:
	exclam
	dc.b	"[Not enough memory to load  |"
_mem:
	dc.b	"              ]"
	dc.b	"[Cancel]",0

_found_mes:
	exclam
	dc.b	"[Cannot find "
_file_nf:
	dc.b	"              ]"
	dc.b	"[Cancel]",0

_readd_mes:
	exclam
	dc.b	"[The file "
_file_readm:
	dc.b	"              |"
	dc.b	"was not read in correctly!  ]"
	dc.b	"[Cancel]",0

_open_mes:
	exclam
	dc.b	"[Cannot open the file |"
_file_open:
	dc.b	"              ]"
	dc.b	"[Cancel]",0
	even




	ifd	link_library
	MODULE	SAVE_A_FILE

	XDEF	save_a_file
	XDEF	create_some,save_some,close_some

	XREF	aes
	XREF	all_caps
	XREF	search_file
	XREF	create_file,write_file,close_file
	XREF	put_name
	XREF	calc_disk_free
	endc



save_a_file:
* save an entire file
* a0 = filename
* d0 = length to save
* a1 = buffer addr to save from

* returns d0 = -1 if error occurred


	movem.l	d0/a0-1,-(a7)
	bsr	create_some
	tst.l	d0
	bmi.s	_err

	movem.l	(a7)+,d0/a0-1

	bsr	save_some
	tst.l	d0
	bmi.s	_err

	bsr	close_some
	rts

_err:
	lea	12(a7),a7
	rts



create_some:
* save bits of a file at a time
* a0 = file name
file_vals	reg	d6-d7/a4-a5	; regs with file stuff in them

	movem.l	a1-a6/d1-d6,-(a7)

	bsr	all_caps		; filename to capital letters

	move.l	a0,a5		; keep filneame safe

	bsr	search_file	; is the file there?
	tst.w	d0
	bne.s	save_file_not_there

* the save file is present

	move.l	a5,a0
	move.l	#save_name,a1
	bsr	put_name


	movem.l	file_vals,-(a7)		; store all file stuff

	alert	#1,save_file_present

	movem.l	(a7)+,file_vals		; get file stuff back after aes call

	cmp.w	#1,d0
	beq.s	save_file_not_there

* user selected not to save it
	moveq	#-1,d0

	movem.l	(a7)+,a1-a6/d1-d6
	rts

save_file_not_there:
* assume that the save file does not exist

* check disk space
	bsr	calc_disk_free
	sub.l	d6,d0
	bpl.s	disk_space_ok

* not enough disk space!
	move.l	a5,a0
	move.l	#space_name,a1
	bsr	put_name

	alert	#1,no_disk_space
	moveq	#-1,d0
	movem.l	(a7)+,a1-a6/d1-d6
	rts


disk_space_ok:
	move.l	a5,a0		; get filename
	bsr	create_file	; try to create the file

	tst.w	d0
	bpl.s	no_save_cr_err

* error creating file
	move.l	a5,a0
	move.l	#cr_name,a1
	bsr	put_name

	alert	#1,cr_err_mes
	moveq	#-1,d0
	movem.l	(a7)+,a1-a6/d1-d6
	rts

no_save_cr_err:
	moveq	#0,d0
	movem.l	(a7)+,a1-a6/d1-d6
	rts


save_some:
* now write the file to disk
* a1 holds addr of buffer
* d0 = len to save
* returns d0 = -1 if error

	movem.l	a0-a6/d1-d6,-(a7)

	move.l	a1,a0
	move.l	d0,d6
	bsr	write_file	; attempt the writing of the file

	sub.l	d6,d0
	beq.s	write_ok

* the file was not written correctly!
	bsr	close_file

	move.l	#write_name,a1
	move.l	a5,a0
	bsr	put_name

	alert	#1,write_err_mes
	moveq	#-1,d0


	movem.l	(a7)+,a0-a6/d1-d6
	rts

write_ok:
	moveq	#0,d0
	movem.l	(a7)+,a0-a6/d1-d6
	rts


close_some:
	bsr	close_file
	moveq	#0,d0
	rts




write_err_mes:
	exclam
	dc.b	"[Error writing the file  |"
write_name:
	ds.b	14
	dc.b	" to disk.]"
	dc.b	"[Cancel]",0
	even


no_disk_space:
	exclam
	dc.b	"[Not enough space on disk  |"
	dc.b	"for the file "
space_name:
	ds.b	14
	dc.b	"]"
	dc.b	"[Cancel]",0


cr_err_mes:
	exclam
	dc.b	"[Error creating file  |"
cr_name:
	dc.b	"              ]"
	dc.b	"[Cancel]",0

save_file_present:
	stopp
	dc.b	"[The file "
save_name:
	dc.b	"              |"
	dc.b	"already exists!]"
	dc.b	"[Overwrite|Cancel]",0

	even







