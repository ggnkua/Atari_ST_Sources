* save out files from disk with wiped directory
* by analysing the FAT

* by James Ingram, 1994

	opt	x+
	opt	o+,ow-

link	equ	1

	IFD	link
	OPT	GST,CASE
	XREF	print_mes,res_mem,rel_mem
	XREF	file_selector,save_a_file
	XREF	to_lower
	ENDC


page_len	equ	512

	include	aes_defs.i
	include	lens.i

	move.l	4(a7),a5
	move.l	#stack,a7
	move.l	$c(a5),a0
	add.l	$14(a5),a0
	add.l	$1c(a5),a0
	lea	$100(a0),a0
	pea	(a0)
	pea	(a5)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

	bsr	disp_screen

menu_loop:
* display menu
	bsr	get_input
	bsr	process_input

	bra	menu_loop

disp_screen:
	lea	menu(pc),a0
	bsr	print_mes

	moveq	#0,d0
	move.w	no_of_files,d0
	bsr	bin_to_dec
	bsr	print_mes


	lea	file_pos,a0
	bsr	print_mes

* now show all files
	move.w	no_of_files,d7
	move.w	first_file,d6
	sub.w	d6,d7

	clr.w	disp_line

.while:
* while line < 20 and files_to_do > 0

	tst.w	d7
	beq.s	.end_while

	cmp.w	#20,disp_line
	beq.s	.end_while


	bsr	show_a_file

	addq.w	#1,disp_line
	addq.w	#1,d6
	subq.w	#1,d7
	bra.s	.while

.end_while:
	rts

show_a_file:
* show file number in d6

	move.w	disp_line,d0
	cmp.w	file_on,d0
	bne.s	.not_sel

	lea	inv(pc),a0
	bsr	print_mes

.not_sel:
show_name:
* first show file-name...
	move.l	file_names,a0

	move.l	d6,d0
	mulu	#13,d0
	add.l	d0,a0
	bsr	print_mes


* now show starting sector...
	lea	tab(pc),a0
	bsr	print_mes

	move.l	file_details,a5
	move.l	d6,d5
	lsl.l	#3,d5

	add.l	d5,a5

	moveq	#0,d0
	move.w	2(a5),d0
	bsr	bin_to_dec
	bsr	print_mes

* and finally, the length...
	lea	tab(pc),a0
	bsr	print_mes

	move.l	4(a5),d0
	bsr	bin_to_dec
	bsr	print_mes

	lea	not_inv(pc),a0
	bsr	print_mes

	lea	new_line(pc),a0
	bsr	print_mes

	rts


get_input:
	bsr	inp
	rts


process_input:
	bsr	to_lower

	cmp.b	#"r",d0
	beq	read_fat

	cmp.b	#"l",d0
	beq	load_file
	
	cmp.b	#"v",d0
	beq	view_file
	
	cmp.b	#"s",d0
	beq	save_file

	cmp.b	#"q",d0
	beq	quit

	cmp.l	#$00620000,d0
	beq	show_help

	cmp.l	#$00500000,d0
	beq	down_arrow

	cmp.l	#$00480000,d0
	beq	up_arrow

	rts

up_arrow:
* any files?
	tst.w	no_of_files
	bne.s	.yup
	rts

.yup

* am I on first file already?
	move.w	file_on,d0
	add.w	first_file,d0
	tst.w	d0
	bne.s	.no
	rts

.no:
	moveq	#0,d0
	move.w	file_on,d0
	subq.w	#1,d0
	bpl.s	.not_top

* at top of screen!
	move.w	first_file,d1
	sub.w	#20,d1
	move.w	d1,first_file

	move.w	#19,file_on
	bsr	disp_screen
	rts


.not_top:
	move.w	d0,file_on
* now I have to re-draw the old filename
* and also the new one which has been selected

	moveq	#0,d1
	move.w	d0,d1
	addq.w	#1,d1
	bsr	redraw_names

	rts


down_arrow:
* any files?
	tst.w	no_of_files
	bne.s	.yup
	rts

.yup:
* am I on last file already?
	move.w	file_on,d0
	add.w	first_file,d0
	sub.w	no_of_files,d0
	addq.w	#1,d0

	bne.s	.no
	rts

.no:
	moveq	#0,d0
	move.w	file_on,d0
	addq.w	#1,d0
	cmp.w	#20,d0
	bne.s	.not_bot

* at bottom of screen!
	moveq	#0,d1
	move.w	first_file,d1
	add.w	#20,d1

* will next screen be past end?
	move.w	d1,d2
	sub.w	no_of_files,d2
	bmi.s	.ok

* yup! do nothing!
	rts

.ok:
* another screen can be displayed...
	move.w	d1,first_file
	clr.w	file_on
	bsr	disp_screen
	rts


.not_bot:
	move.w	d0,file_on
* now I have to re-draw the old filename
* and also the new one which has been selected

	moveq	#0,d1
	move.w	d0,d1
	subq.w	#1,d1
	bsr	redraw_names

	rts


redraw_names:
* file to go to normal in d1
* file to invert in d0

	move.l	d0,-(a7)
	move.l	d1,d7

* move cursor to correct position
	move.l	d7,d0
	bsr	curs_line

* now do name...
	move.l	d7,d6
	add.w	first_file,d6
	bsr	show_name

* cursor to inverted name
	move.l	(a7)+,d7
	move.l	d7,d0
	bsr	curs_line

	lea	inv(pc),a0
	bsr	print_mes

	move.l	d7,d6
	add.w	first_file,d6
	bsr	show_name

	rts

curs_line:
* move cursor to correct line
	moveq	#32+4,d3
	add.w	d0,d3
	move.b	d3,line_pos
	lea	pos(pc),a0
	bsr	print_mes
	rts


pos:
	dc.b	27,"Y"
line_pos	dc.b	32,32,0
	even


show_help:
	lea	clr_scrn(pc),a0
	bsr	print_mes
	lea	help(pc),a0
	bsr	print_mes
	bsr	get_input
	bsr	disp_screen

	rts


quit:
	clr.w	-(a7)
	trap	#1

call_super:
	pea	(a0)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7
	rts


force_read:
	clr.w	-(a7)
	move.l	$472.w,a0
	jsr	(a0)
	addq.l	#2,a7
	rts


read_fat:
* force a read of the disk...
* to make the "RWABS" trap #13 call work OK...
	lea	force_read(pc),a0
	bsr	call_super

	clr.w	file_on
	clr.w	first_file

* read the FAT from a disk...
* do we have one present?
	move.l	fat_addr,d0
	beq.s	.no_fat

* yes! get rid of it!
	bsr	release


.no_fat:
* read the boot sector!

	moveq	#0,d0
	moveq	#1,d1
	lea	boot_sector,a0
	bsr	read_secs
	tst.l	d0
	bpl.s	.ok

* disk error!
	bsr	disk_error
	rts

.ok:
* get some data out...
	lea	boot_sector(pc),a0
	moveq	#0,d0
	move.b	$16(a0),d0
	move.w	d0,sectors_per_fat

	moveq	#0,d0
	move.b	$14(a0),d0
	lsl.w	#8,d0
	move.b	$13(a0),d0
	move.w	d0,sectors_on_disk

	lsr.w	#1,d0
	move.w	d0,clusters_on_disk

* calculate 1st logical sector
	moveq	#1,d0		; count the bootsector as 1...
	move.w	sectors_per_fat,d1
	moveq	#0,d2
	move.b	$10(a0),d2	; no of FATs
	mulu	d2,d1		; d1 = sectors in FAT (total)
	add.w	d1,d0

* how many secs in directory???
	moveq	#0,d1
	move.b	$12(a0),d1
	lsl.w	#8,d1
	move.b	$11(a0),d1

* got no of directory entries...
* so x 32 for total length of directory
	lsl.l	#5,d1

* and / 512 for sectors...
	lsr.l	#8,d1
	lsr.l	#1,d1

	add.w	d1,d0
	move.w	d0,first_sec


* now read in the FAT..
* how much memory will I need?
* sectors_per_fat * 512!

	moveq	#0,d7
	moveq	#9,d1
	
	move.w	sectors_per_fat,d7
	lsl.l	d1,d7

	move.l	d7,d0

	bsr	res_mem
	tst.l	d0
	bmi	memory_error


* store FAT address
	move.l	d0,fat_addr
	move.l	d0,a6

* get memory needed to decode FAT!
* (say twice as long, to keep it simple...)
	lsl.l	#1,d7
	move.l	d7,d0
	bsr	res_mem
	tst.l	d0
	bmi	memory_error

	move.l	d0,decoded_fat

	move.l	a6,a0
	moveq	#1,d0
	moveq	#0,d1
	move.w	sectors_per_fat,d1
	bsr	read_secs

* now decode the FAT!
	move.l	decoded_fat,a1
	move.l	fat_addr,a0

* how many FAT entries are there?
* call it sectors_per_fat * 512 * 8 / 12
	moveq	#0,d0

	move.w	sectors_on_disk,d0
	lsr.w	#1,d0

	move.w	d0,no_of_entries

* now decode d0 number of FAT entries

	lsr.w	#1,d0
	tst.w	d0
	bne	.no_fat_error

	lea	fat_err(pc),a0
	bsr	print_mes
	bsr	inp

	bra	release


.no_fat_error:
* go past first 2 entries
	addq.l	#3,a0

decode:
* get 2 entries
	move.b	(a0)+,d1
	move.b	(a0)+,d2
	move.b	(a0)+,d3

* now seperate them out...
	moveq	#0,d7

	move.b	d2,d7
	lsl.w	#8,d7
	move.b	d1,d7
	and.w	#$0fff,d7

	move.w	d7,(a1)+
	moveq	#0,d6

	move.b	d3,d6
	lsl.w	#8,d6
	move.b	d2,d6
	lsr.w	#4,d6

	move.w	d6,(a1)+

	subq.w	#1,d0
	bne.s	decode

end_decode:
* calculate the number of files...
	move.l	decoded_fat,a0
	move.w	clusters_on_disk,d0
	moveq	#0,d1

count_files:
	move.w	(a0)+,d7
	cmp.w	#$fff,d7
	bne.s	.not_one

	addq.w	#1,d1

.not_one:
	subq.w	#1,d0
	bne.s	count_files

	move.w	d1,no_of_files

* get memory needed to hold file names...
	moveq	#0,d0
	move.w	d1,d0

	lsl.l	#4,d0	; x 16

	bsr	res_mem
	tst.l	d0
	bmi	memory_error

	move.l	d0,file_names

* now fill in the filenames...
	move.l	d0,a0
	moveq	#0,d0
	move.w	no_of_files,d0

	move.b	#"0",n1
	move.b	#"0",n2
	move.b	#"1",n3


.while:
	tst.w	d0
	beq.s	.end_while

	bsr	insert_name

	subq.w	#1,d0
	bra.s	.while

.end_while:


* get memory needed to hold starting sectors and lengths
	moveq	#0,d0
	move.w	no_of_files,d0
	lsl.l	#3,d0		; x 8
	bsr	res_mem
	tst.l	d0
	bmi	memory_error

	move.l	d0,file_details

* now get start sectors & lengths.....
	move.l	d0,a0
	moveq	#0,d0
	move.w	no_of_files,d0

.while2:
	tst.w	d0
	beq.s	.end_while2

	bsr	get_stuff

	subq.w	#1,d0
	bra.s	.while2
.end_while2:

	moveq	#0,d1
	move.w	no_of_files,d1
	move.l	file_details,a0
	
.while3:
	tst.w	d1
	beq.s	.end_while3

	bsr	clusts

	subq.w	#1,d1
	bra.s	.while3
.end_while3:

* reset all FATs to have top bit 0 again
	move.l	decoded_fat,a0
	move.w	clusters_on_disk,d0

.design:
	move.w	(a0),d1
	bclr	#15,d1
	move.w	d1,(a0)+

	subq.w	#1,d0
	bne.s	.design


	bsr	disp_screen

	rts



clusts:
* convert the starting cluster numbers to logical sector numbers

	moveq	#0,d0
	move.w	(a0),d0

	bsr	clust_to_sec

	move.w	d0,2(a0)
	addq.l	#8,a0

	rts


clust_to_sec:
* cluster no in d0
* returns sector no in d0

	subq.w	#2,d0
	add.w	d0,d0
	add.w	first_sec,d0

	rts


get_stuff:
* get start sectors & file lengths

	move.l	decoded_fat,a1
	moveq	#2,d1		; start cluster count
	move.l	#1024,d3	; file length count

* get the first cluster which is not 0 and not scanned already...

.get_used:
	moveq	#0,d2
	move.w	(a1)+,d2
	bne.s	.used

.scanned:
	addq.w	#1,d1
	bra.s	.get_used

.used:
	btst	#15,d2
	bne.s	.scanned

* got an unused, unscanned cluster!
	subq.l	#2,a1

	bset	#15,d2
	move.w	d2,(a1)

	bclr	#15,d2
	move.w	d1,(a0)+	; save starting cluster

* is the cluster the last one?
.get_all:
	cmp.w	#$fff,d2
	beq.s	.got_all

* no!
	add.l	#1024,d3
	move.l	decoded_fat,a1
	subq.l	#2,d2
	lsl.w	#1,d2
	add.l	d2,a1		; get cluster pointed to...

	moveq	#0,d2
	move.w	(a1),d2
	bset	#15,d2
	move.w	d2,(a1)
	bclr	#15,d2
	bra.s	.get_all

.got_all:
	addq.l	#2,a0
	move.l	d3,(a0)+	; save file length...
	rts


insert_name:
	move.l	#name,a1

.next_byte:
	move.b	(a1)+,(a0)+
	bne.s	.next_byte

* add 1 to file name

	move.l	#n1,a1
	addq.b	#1,2(a1)
	cmp.b	#"9",2(a1)
	ble.s	.num_ok

	move.b	#"0",2(a1)
	addq.b	#1,1(a1)
	cmp.b	#"9",1(a1)
	ble.s	.num_ok

	move.b	#"0",1(a1)
	addq.b	#1,(a1)

.num_ok:
	rts


get_selected:
* returns selected file no in d0

	moveq	#0,d0
	move.w	first_file,d0
	add.w	file_on,d0
	rts


view_file:
* only if file exists...
	tst.l	file_addr
	bne.s	.ok
	rts

.ok:

* view the contents of a file...

* display the file, line by line...
* in either HEX or TEXT mode

	st	quit_view
.while:
	tst.b	quit_view
	beq.s	.end_while
	
	bsr	view_a_page
	bra.s	.while

.end_while:

	rts

view_a_page:
	dc.w	$a00a
	bsr	display_page
	dc.w	$a009
	bsr	get_input
	bsr	process_page_input
	rts

display_page:
	lea	clr_scrn(pc),a0
	bsr	print_mes

	lea	off_txt(pc),a0
	bsr	print_mes

	move.l	view_off,d0
	bsr	bin_to_dec
	bsr	print_mes

	lea	off_txt_2(pc),a0
	bsr	print_mes
	move.l	view_off,d0
	add.l	#page_len,d0
	subq.l	#1,d0
	bsr	bin_to_dec
	bsr	print_mes

	move.l	file_addr,d0
	add.l	view_off,d0
	move.l	d0,view_point

	move.w	#0,col_count

* now display lines of the file...
	move.w	#0,bytes_to_show
.while:
	move.w	#512,d0
	cmp.w	bytes_to_show,d0
	beq.s	.end_while

	bsr	show_a_byte
	addq.w	#1,bytes_to_show
	bra	.while

.end_while:
	rts


show_a_byte:
* new line if col counter = 0
	subq.w	#1,col_count
	bpl.s	.no_new

	lea	new_line(pc),a0
	bsr	print_mes
	move.w	#25,col_count

.no_new:
	move.l	view_point,a0
	moveq	#0,d0
	move.b	(a0)+,d0
	move.l	a0,view_point

	cmp.b	#"H",view_mode
	beq	view_hex

* show as text...
	move.w	d0,-(a7)
	move.w	#5,-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7
	rts

view_hex:

	move.w	d0,d7
	move.w	d7,d6
	and.w	#$000f,d7
	and.w	#$00f0,d6
	lsr.w	#8,d6
	lea	hex_dig(pc),a1
	move.b	(a1,d6.w),d6
	move.b	(a1,d7.w),d7

	move.w	d6,-(a7)
	move.w	#5,-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7

	move.w	d7,-(a7)
	move.w	#5,-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7

	move.w	#"  ",-(a7)
	move.w	#5,-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7
	rts

hex_dig:
	dc.b	"0123456789ABCDEF"
	even
col_count	dc.w	0

view_help:
	lea	clr_scrn(pc),a0
	bsr	print_mes
	lea	view_help_txt(pc),a0
	bsr	print_mes
	bsr	inp
	rts


process_page_input:
	cmp.l	#$00620000,d0
	beq	view_help

	cmp.b	#" ",d0
	beq	toggle_hex

	cmp.l	#$00500000,d0
	beq	pg_up

	cmp.l	#$00480000,d0
	beq	pg_down

	cmp.l	#$0001001b,d0
	beq	stop_view

	rts

toggle_hex:
	move.b	#"H",d0
	cmp.b	#"H",view_mode
	bne.s	.no
	move.b	#"T",d0
.no:
	move.b	d0,view_mode
	rts


stop_view:
	bsr	disp_screen
	sf	quit_view
	rts

pg_up:
	move.l	view_off,d0
	add.l	#page_len,d0
	move.l	file_len,d1
	sub.l	d0,d1
	bmi.s	.end
	beq.s	.end

	move.l	d0,view_off
.end:
	rts

pg_down:
	move.l	view_off,d0
	sub.l	#page_len,d0
	bmi.s	.end

	move.l	d0,view_off
.end:
	rts



load_file:
	clr.l	view_off

	move.l	file_addr,d0
	beq.s	.no_rel
	bsr	rel_mem
.no_rel:
	tst.w	no_of_files
	bne.s	.yup
	rts
.yup:
* load the file into memory...
	bsr	get_selected

	move.l	file_details,a6
	lsl.l	#3,d0
	add.l	d0,a6

* got addr of 1st sector & file length	
	move.l	4(a6),d0	; get file length
	move.l	d0,file_len
	bsr	res_mem
	tst.l	d0
	bpl.s	.mem_ok

* not enough memory!
	lea	not_enough(pc),a0
	bsr	print_mes
	bsr	inp
	bsr	disp_screen
	rts

.mem_ok:
	move.l	d0,a5		; keep addr of file...

	move.l	d0,file_addr

	move.w	(a6),d7		; get 1st cluster...


.load_loop:
	move.w	d7,d0
	bsr	clust_to_sec

* get next cluster (if any)
	move.l	decoded_fat,a4
	subq.w	#2,d7
	lsl.w	#1,d7

	add.l	d7,a4
	move.w	(a4),d7


	moveq	#2,d1
	move.l	a5,a0
	bsr	read_secs

	lea	1024(a5),a5

	cmp.w	#$fff,d7
	bne.s	.load_loop
	rts

save_file:
* now do save...
	lea	star(pc),a0
	bsr	file_selector

	tst.l	d0
	bmi	cancel

* save the file!!!!!!!
	move.l	file_addr,a1
	move.l	file_len,d0
	bsr	save_a_file

cancel:
	bsr	disp_screen

	rts

disk_error:
	lea	disk_err(pc),a0
	bsr	print_mes
	bsr	inp
	rts

memory_error:
	lea	mem_err(pc),a0
	bsr	print_mes
	bsr	inp

release:
	move.l	fat_addr,d0
	bsr	rel_mem

	move.l	decoded_fat,d0
	bsr	rel_mem
	clr.l	fat_addr

	move.l	file_names,d0
	bsr	rel_mem

	move.l	file_details,d0
	bsr	rel_mem


	rts


inp:
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

bin_to_dec:
* enter with d0 as binary WORD
* leave with a0 pointing to string of decimal characters...

	clr.b	-(a7)

	tst.w	d0
	bne.s	.not_zed

	move.b	#"0",-(a7)
	bra.s	.to_string

.not_zed:
	divu	#10,d0
	swap	d0
	add.b	#"0",d0
	move.b	d0,-(a7)
	clr.w	d0
	swap	d0
	tst.w	d0
	bne.s	.not_zed

.to_string:
	lea	number(pc),a0
	move.l	a0,a1

.copy:
	move.b	(a7)+,(a1)+
	bne.s	.copy
	rts


read_secs:
* enter with:
*	d0 = start sector no
*	d1 = number to read
*	a0 = buffer to read to

	move.w	#0,-(a7)	; drive 0
	move.w	d0,-(a7)
	move.w	d1,-(a7)
	pea	(a0)
	move.w	#2,-(a7)
	move.w	#4,-(a7)
	trap	#13
	lea	14(a7),a7
	rts

cls:
	dc.b	27,"E",0


	ifnd	link
	include	files.s
	include	aes_shel.s
	include	gem_shel.s
	include	bits.s
	endc

menu:
	dc.b	27,"E"
	dc.b	27,"p"
	dc.b	"                                        "
	dc.b	"                                        "

	dc.b	27,"Y",32,32+37

	dc.b	"FAT FILE"
	dc.b	27,"q"
	dc.b	27,"Y",32+1,32
	dc.b	"Files on disk:                "
	dc.b	"Press HELP to show keys to use",10,13
	dc.b	10
	dc.b	"Filename     Start Sec  Length"
	dc.b	27,"Y",32+1,32+15,0


file_pos:
	dc.b	27,"Y",32+4,32+0,0

view_mode:	dc.b	"T"

star:	dc.b	"*.*",0


disk_err:
	dc.b	10,13,"DISK ERROR!",10,13,0

mem_err	dc.b	10,13
	dc.b	"Out of memory!",0

fat_err:
	dc.b	10,13,"INVALID FAT!",0
tab:
	dc.b	9,0

space:
	dc.b	" ",0
new_line:
	dc.b	10,13,0

clr_scrn:
	dc.b	27,"Y",32+1,32
	dc.b	27,"J"
	dc.b	0
	
help:
	dc.b	"HELP",10,13,10
	dc.b	"Keys are as follows:",10,13
	dc.b	"Q = QUIT",10,13
	dc.b	"R = READ FAT",10,13
	dc.b	"Cursor keys to select file",10,13
	dc.b	"L = load file to memory",10,13
	dc.b	"V = View file",10,13
	dc.b	"S = Save file",10,13
	dc.b	0

inv:
	dc.b	27,"p",0
not_inv:
	dc.b	27,"q",0

not_enough:
	dc.b	27,"ENot enough memory to load file!  Soz.",0

off_txt:
	dc.b	10,13
	dc.b	"File from ",0
off_txt_2:
	dc.b	" to ",0

view_help_txt:
	dc.b	10,13,10
	dc.b	"PRESS:",10,13,10
	dc.b	"UP-arrow for previous page",10,13
	dc.b	"DOWN-arrow for next page",10,13
	dc.b	"Esc to stop",10,13
	dc.b	"SPACE to toggle HEX/TEXT viewing",10,13
	dc.b	0

name:
	dc.b	"FILENAME."
n1	dc.b	"0"
n2	dc.b	"0"
n3	dc.b	"1"
	dc.b	0
quit_view:	dc.b	0
	
	even


fat_addr	dc.l	0
sectors_per_fat	dc.w	0
sectors_on_disk	dc.w	0
clusters_on_disk	dc.w	0
no_of_files	ds.w	1


	section	bss

boot_sector	ds.b	512
decoded_fat	ds.l	1
no_of_entries	ds.w	1
file_names	ds.l	1
file_details	ds.l	1
first_sec	ds.w	1
file_no	ds.w	1

first_file	ds.w	1
file_on		ds.w	1
disp_line	ds.w	1

file_addr	ds.l	1
file_len	ds.l	1

view_off	ds.l	1
bytes_to_show	ds.w	1
view_point	ds.l	1


	ds.b	5000
stack:

number:	ds.b	50
