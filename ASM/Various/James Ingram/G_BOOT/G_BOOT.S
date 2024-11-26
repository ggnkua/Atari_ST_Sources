* AUTO booter
*  by James Ingram, 1992
*
*	V1.1 April 1993
*	EXCLUDES programed



test	equ	1		; only labels + control testing


	OUTPUT	.SKP

max_xcludes	equ	100

f_name	equ	30
f_len	equ	26

	ifd	test
	opt	x+
	endc

	opt	o+,ow-

comment	equ	"'"
comment2	equ	"~"

ctrl	macro
	ifnd	test
	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7

	btst	#2,d0
	bne	ctrl_pressed
	endc

	endm


* free memory
	pea	st_pal(pc)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7

	move.w	#4,-(a7)
	trap	#14
	addq.l	#2,a7
	move.w	d0,res

	tst.w	d0
	bne.s	no_chng

	moveq	#1,d0
	bsr	set_res

no_chng:
	move.l	4(a7),a5
	move.l	#stack,a7

	move.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	add.l	#$100,d0
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

	lea	heading(pc),a0
	bsr	print_mes

	pea	dta(pc)
	move.w	#$1a,-(a7)
	trap	#1
	addq.l	#6,a7

* now load in the data file from the root directory

	lea	boot(pc),a6
	moveq	#0,d0
	bsr	s_first

	tst.w	d0
	bpl.s	found_dat

* dat file missing
	lea	dat_err(pc),a0
	bsr	print_mes

	bsr	restore

	clr.w	-(a7)
	trap	#1

found_dat:
	tst.l	dta+f_len
	beq.s	data_zero	; data file zero length!

	addq.l	#1,dta+f_len
	move.l	dta+f_len,-(a7)

	lea	dta+f_name(pc),a6
	bsr	load_it

	move.l	d6,a0
	add.l	(a7)+,a0
	move.b	#$ff,-1(a0)

	cmp.b	#"N",load_err
	beq.s	load_dat_ok

* error loading data file
	cmp.b	#"O",load_err
	beq.s	open_dat_err

	bra.s	load_dat_ok

xcluded_file:
	lea	xmes(pc),a0
	bsr	print_mes
	bra	load_next


mes_term:
	bsr	print_mes
term:	
	bsr	restore

	clr.w	-(a7)
	trap	#1
data_zero:
	lea	zero(pc),a0
	bra.s	mes_term

open_dat_err:
	lea	dat_read_err(pc),a0
	bra.s	mes_term

mem_dat_err:
	lea	mem_err_mes(pc),a0
	bra.s	mes_term

load_dat_ok:
* data file has loaded perfectly!
* so now find the drive to use

	move.l	d6,boot_addr
	move.l	d6,boot_pos

	bsr	get_line

	dbra	d0,drv_end

* got addr of drive
	move.b	(a0)+,d7	; d7 = drive number!

	move.w	#10,-(a7)
	trap	#13		; get connected drives
	addq.l	#2,a7

	move.b	d7,drv_no
	move.b	d7,test_drv

	or.b	#$20,d7
	sub.b	#"a",d7

	btst	d7,d0
	bne.s	drv_there

* drive selected not present
	lea	drive(pc),a0
	bsr	print_mes

	lea	drv_miss(pc),a0
	bra.s	mes_term

drv_there:
* drive exists
	lea	test_drv(pc),a6
	moveq	#$10,d0
	bsr	s_first		; search anything in drive selected

	tst.w	d0
	bmi.s	drv_empty

* drive has something in it
	lea	drive(pc),a0
	bsr	print_mes

	lea	drv_not_empty(pc),a0
	bra.s	mes_term

drv_empty:
* drive is empty, so we're booting up!

	clr.w	no_xcludes

	lea	x_names(pc),a5

* first get all the files names to Xclude
do_xcludes:
	bsr	get_nxt_line	; get first line of .DAT file...
	tst.w	d0
	beq.s	x_not_end	; branch if not end of .DAT file

	addq.l	#4,a7		; else scrap kept addr
	bra	end_of_dat	; end finish

x_not_end:
	move.b	(a0),d0
	lsl.w	#8,d0
	move.b	1(a0),d0	; get a word into d0

	cmp.w	#"X ",d0
	beq.s	got_an_xclude
	
	cmp.w	#"x ",d0
	bne.s	dun_xcludes	; branch if this line is NOT an exclude line...

got_an_xclude:
* we now have a filename to exclude!

	addq.l	#2,a0

	move.l	a5,a4

x_copy_loop:
* copy filename
	cmp.b	#$ff,(a0)
	beq.s	dun_x_copy

	cmp.b	#13,(a0)
	beq.s	dun_x_copy

	move.b	(a0)+,d0

	cmp.b	#"a",d0
	blo.s	not_sm

	cmp.b	#"z",d0
	bhi.s	not_sm

	and.b	#%11011111,d0

not_sm:
	move.b	d0,(a4)+

	bra.s	x_copy_loop

dun_x_copy:
	clr.b	(a4)		; ensure filename is terminated with 0
	lea	14(a5),a5	; goto next xcluded f/n addr
	addq.w	#1,no_xcludes	; 1 more xcluded file!

	cmp.w	#max_xcludes,no_xcludes
	bne.s	do_xcludes

* more than max xcludes defined!

	lea	max_x(pc),a0
	bsr	print_mes
	bra.s	dun_xcludes




main_loop:
* enter the load and save loop

	ctrl

	bsr	get_nxt_line	; get next line of .DAT file
	dbra	d0,end_of_dat

dun_xcludes:
* are we creating a directory???
	move.l	a0,a1
	move.b	(a1)+,d0
	lsl.w	#8,d0
	move.b	(a1)+,d0
	lsl.l	#8,d0
	move.b	(a1)+,d0
	lsl.l	#8,d0
	move.b	(a1)+,d0

	sub.l	#"DIR ",d0
	bne.s	loading

* we must create a directory with name at a1

* copy dir name to "file" and add null byte

	lea	file(pc),a0
	move.b	drv_no,(a0)+
	move.b	#":",(a0)+
	move.b	#"\",(a0)+

copy_dir:
	cmp.b	#$ff,(a1)
	beq.s	dun_dir_copy

	move.b	(a1)+,d0
	cmp.b	#13,d0
	beq.s	dun_dir_copy

	move.b	d0,(a0)+
	bra.s	copy_dir

dun_dir_copy:
	clr.b	(a0)
	lea	file(pc),a6

	lea	create_dir(pc),a0
	bsr	print_mes
	move.l	a6,a0
	bsr	print_mes

	lea	new_line(pc),a0
	bsr	print_mes

	pea	(a6)
	move.w	#$39,-(a7)
	trap	#1
	addq.l	#6,a7

	tst.w	d0
	beq	main_loop

* error creating directory
	lea	dir_err(pc),a0
	bsr	print_mes

	bra	main_loop

loading:
* load this wildcard and then save it to disk with optional path

* first copy wildcard to first space of EOL
	lea	file(pc),a1

	move.b	#"N",path
	move.b	#"n",f_path
copy_name:
	cmp.b	#$ff,(a0)
	beq.s	no_path

	move.b	(a0)+,d0
	cmp.b	#13,d0
	beq.s	no_path

	cmp.b	#"\",d0
	bne.s	no_f_path

	move.b	#"y",f_path

no_f_path:
	cmp.b	#" ",d0
	beq.s	yes_path

	move.b	d0,(a1)+
	bra.s	copy_name

yes_path:
	move.b	#"Y",path
	move.l	a0,path_addr	; keep start of pathname

no_path:
	clr.b	(a1)		;put in null byte to wildcard

	lea	file(pc),a6
	bsr	s_first		; search for a file

	tst.w	d0
	beq.s	got_one
* file not found!

	lea	file(pc),a0
	bsr	print_mes

	lea	n_f(pc),a0
	bsr	print_mes
	bra	main_loop


got_one:
* found first file
	cmp.b	#"y",f_path
	bne.s	no_f_path2

* there was a path with the filename!!!!!!!!!!!!
	lea	file(pc),a6
	lea	file2(pc),a5
get_n_end:
	move.b	(a6)+,(a5)+
	bne.s	get_n_end	; get end of filename

get_slash:
	cmp.b	#"\",-(a5)
	bne.s	get_slash	; get slash
	addq.l	#1,a5

	lea	dta+f_name(pc),a0
namename:
	move.b	(a0)+,(a5)+
	bne.s	namename

	lea	file2(pc),a6
	bra.s	pathd

no_f_path2:
	lea	dta+f_name(pc),a6

pathd:
	move.l	a6,a0
	bsr	print_mes

	bsr	load_it		; load in file

	cmp.b	#"N",load_err
	beq.s	load_ok

	cmp.b	#"X",load_err
	beq	xcluded_file

* error ocurred
	lea	load_err(pc),a0
	bsr	print_mes
	bra	rel_mem

load_ok:
* now save file to RAM disk

	lea	to(pc),a0
	bsr	print_mes

	lea	file_to(pc),a0

	cmp.b	#"Y",path
	bne.s	just_copy

* put in pathname first
	move.l	path_addr,a1	; get path address

	cmp.b	#":",1(a1)
	beq.s	got_drv_path

* drive has not been specified in pathname
	move.b	drv_no,(a0)+
	move.b	#":",(a0)+
	move.b	#"\",(a0)+

got_drv_path:

copy_path:
	cmp.b	#$ff,(a1)
	beq.s	end_path

	move.b	(a1)+,d0
	cmp.b	#13,d0
	beq.s	end_path
	move.b	d0,(a0)+
	bra.s	copy_path

end_path:
* path name has now been copied
	bra.s	copy_it

just_copy:
	move.b	drv_no,(a0)+
	move.b	#":",(a0)+
	move.b	#"\",(a0)+
copy_it:
* path completed - get file name in
	lea	dta+f_name(pc),a1

do_file:
	move.b	(a1)+,(a0)+
	bne.s	do_file

* show file name
	lea	file_to(pc),a0
	bsr	print_mes


* now file name is complete, do the save!

	clr.w	-(a7)
	pea	file_to(pc)
	move.w	#$3c,-(a7)
	trap	#1
	addq.l	#8,a7

	move.w	d0,d7
	bpl.s	no_cr_err

* error creating the file!
	lea	f_cr(pc),a0
	bsr	print_mes
	bra.s	rel_mem

no_cr_err:
	move.l	d6,-(a7)
	move.l	dta+f_len,-(a7)
	move.w	d7,-(a7)
	move.w	#$40,-(a7)
	trap	#1		; save it
	lea	12(a7),a7

	sub.l	dta+f_len,d0
	beq.s	saved_ok

* error saving
	lea	sav_err(pc),a0
	bsr	print_mes
	bra.s	close_it

saved_ok:
	lea	new_line(pc),a0
	bsr	print_mes
close_it:
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7

* now release memory for file
rel_mem:
	move.l	d6,-(a7)
	move.w	#$49,-(a7)
	trap	#1
	addq.l	#4,a7


load_next:
* test for CTRL
	ctrl


* do next file on this wildcard

	move.w	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
	tst.w	d0
	bpl	got_one

	bra	main_loop
	

end_of_dat:
* everything done
	lea	dun(pc),a0
	bra	mes_term


set_res:
	move.w	d0,-(a7)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	rts

restore:
	move.w	#50-1,d7
pause:
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7
	dbra	d7,pause

	move.w	res,d0
	bsr.s	set_res

	pea	m_pal(pc)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7
	rts

st_pal:
	movem.l	$ffff8240.w,d0-d7
	movem.l	d0-d7,old_pal
	movem.l	my_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

m_pal:
	movem.l	old_pal,d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts

my_pal:
	dc.w	$fff,$000,$000,$000
ctrl_pressed:
	lea	abort(pc),a0
	bsr	mes_term


drv_end:
* EOF before drive declared!
	lea	null(pc),a0
	bra	mes_term


get_nxt_line:
* gets the NEXT valid line
* first go to end of current line

	move.l	boot_pos,a0
fnd_ret:
	cmp.b	#$ff,(a0)
	beq.s	end_boot_file

	cmp.b	#10,(a0)+
	bne.s	fnd_ret

	move.l	a0,boot_pos


get_line:
* get the start of the first valid line in the bootup file
* updates boot_pos and returns same value in a0
* returns d0 with error code.  0 = not at EOF

	move.l	boot_pos,a0

line_loop:
	cmp.b	#$ff,(a0)
	beq.s	end_boot_file

	move.b	(a0)+,d0
	cmp.b	#comment,d0
	beq.s	go_end		; branch if this is a comment line

	cmp.b	#comment2,d0
	beq.s	go_end

* this is not a comment, therefore a valid line
	subq.l	#1,a0
	move.l	a0,boot_pos
	moveq	#0,d0
	rts

go_end:
	cmp.b	#$ff,(a0)
	beq.s	end_boot_file

	cmp.b	#10,(a0)+
	bne.s	go_end
	bra.s	line_loop

end_boot_file:
	moveq	#-1,d0
	rts


s_first:
* pass addr of name in a6 and attribute in d0

	move.w	d0,-(a7)
	pea	(a6)
	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	rts


load_it:
* file name in a6
* returns address of file in d6 and error code in "load_err"


* first check to ensure filename is not XCLUDED
	lea	dta+f_name(pc),a5
	lea	x_names(pc),a1

	move.w	no_xcludes,d0

x_check_loop:
	beq.s	dun_x_check

	move.l	a5,a2

	move.l	a1,a0

_loop:
	move.b	(a2)+,d1
	move.b	(a0)+,d2
	cmp.b	d1,d2
	bne.s	not_x_ed
* might be xcluded
	tst.b	d1
	bne.s	_loop

* is excluded!
	move.b	#"X",load_err
	rts

not_x_ed:
	lea	14(a1),a1
	subq.w	#1,d0
	bra.s	x_check_loop

dun_x_check:
	move.b	#"N",load_err

* now reserve memory
	move.l	dta+f_len,-(a7)
	move.w	#$48,-(a7)
	trap	#1
	addq.l	#6,a7

	move.l	d0,d6
	beq.s	mem_err
	bmi.s	mem_err

	clr.w	-(a7)
	pea	(a6)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7

	move.w	d0,d7
	bmi.s	open_err


* now read file
	move.l	d6,-(a7)
	move.l	dta+f_len,-(a7)
	move.w	d7,-(a7)
	move.w	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7

	sub.l	dta+f_len,d0
	beq.s	no_read_err

	move.b	#"Y",load_err

no_read_err:
* now close file
	move.w	d7,-(a7)
	move.w	#$3e,-(a7)
	trap	#1
	addq.l	#4,a7

	rts

open_err:
	move.b	#"O",load_err
	rts

mem_err:
	move.b	#"M",load_err
	rts


print_mes:
	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts


	section	data

test_drv:
	dc.b	"X:\*.*",0


heading:
	dc.b	27,"p"
	dc.b	"*************************",10,13
	dc.b	"*          THE          *",10,13
	dc.b	"*      GINGER BREAD     *",10,13
	dc.b	"* BOOTER FOR RAM DISKS  *",10,13
	dc.b	"*      VERSION 1.1      *",10,13
	dc.b	"* by James Ingram, 1992 *",10,13
	dc.b	"*************************",10,13
	dc.b	27,"q"
	dc.b	10,13,"Hold down CONTROL to abort",10,13,10
	dc.b	0


mem_err_mes:
	dc.b	"Memory error !?!",10,13,10,0

boot:
	dc.b	"BOOTUP.DAT",0
dat_err:
	dc.b	"The data file BOOTUP.DAT is missing!",10,13
	dc.b	"Program aborting...",10,13,10,0
load_err:
	dc.b	"N"

dat_read_err:
	dc.b	"Error reading data file!",10,13
	dc.b	"Please check it is OK!",10,13,10,0
zero:
	dc.b	"The file BOOTUP.DAT appears to be",10,13
	dc.b	"zero bytes in length!?!",10,13,10,0
null:
	dc.b	"No data in BOOTUP.DAT!?!",10,13,10,0
drive:
	dc.b	"Drive "
drv_no:
	dc.b	"X",0
drv_miss:
	dc.b	" is not present!",10,13,10,0

drv_not_empty:
	dc.b	" has files or folders in it.",10,13
	dc.b	"Aborting...",10,10,13,0
dun:
	dc.b	10,13,27,"pGINGER BREAD boot completed.",27,"q",10,13,10,0
create_dir:
	dc.b	"Creating directory ",0
dir_err:
	dc.b	"  ",27,"pERROR!!!",27,"q",10,13,0
to:
	dc.b	" to ",0

xmes:
	dc.b	"   ",27,"p*** EXCLUDED ***",27,"q",10,13,0
max_x:
	dc.b	"More than maximum number of XCLUDED files defined!",10,13,10,0

n_f:
	dc.b	10,13,27,"pnot found",27,"q",10,13,0
f_cr:
	dc.b	10,13,27,"perror creating file",27,"q",10,13,0
sav_err:
	dc.b	10,13,27,"perror saving file",27,"q",10,13,0
new_line:
	dc.b	10,13,0
abort:
	dc.b	10,13,27,"pCONTROL PRESSED.  ABORTING.",27,"q",10,13,10,0

	even

	section	bss
dta:
	ds.b	44
boot_addr:
	ds.l	1
boot_pos:
	ds.l	1
path:
	ds.b	1
f_path:
	ds.b	1
file:
	ds.b	100
file2:
	ds.b	100
file_to:
	ds.b	100
path_addr:
	ds.l	1
res:
	ds.w	1
old_pal:
	ds.b	32

x_names:
	ds.b	max_xcludes*14

no_xcludes:
	ds.w	1



	ds.b	500
stack:

