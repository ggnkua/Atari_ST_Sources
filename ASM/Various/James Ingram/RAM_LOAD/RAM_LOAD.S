* RAM disk loader
* by James Ingram, 1994
*
* takes an input file and will create a RAM disk
* and load files into it.  Files are then accessed
* from the RAM disk first - no matter which disk they
* are selected on.


* last update
date	macro
	dc.b	"19 / 9 / 94",0
	endm

time	macro
	dc.b	"18:00",10,13,0
	endm

* last update - ramdisk searching moved to RAM list instead
* of opening files to see if they exist...


labels	equ	1
;demo	equ	1

link	equ	1

	IFD	demo
		IFD	link
		output	ram_demo.bin
		ENDC
	
		IFND	link
		output	ram_demo.prg
		ENDC
	ENDC


	ifd	labels
	opt	x+
	endc

	opt	o+,ow-

	ifd	link
	OPT	GST,CASE
	XREF	print_mes,load_a_file,file_selector
	XREF	mouse_arrow,to_lower
	XREF	change_dir,get_dir,get_drive,set_drive
	XREF	open_file,close_file,read_file,write_file,create_file
	XREF	dta,search_file,search_next,res_mem,num_to_asc
	XREF	super_on,rel_mem,set_dta,make_dir,what_is_path
	XREF	super_off
	XREF	search_folder_only,search_folder,search_next_folder
	endc

drv_bits	equ	$4c2

hdv_bpb	equ	$472
hdv_med	equ	$47e
hdv_rw	equ	$476

res_val	equ	$426
res_vec	equ	$42a

phystop	equ	$42e

wilds_per_block	equ	100
ram_per_block	equ	2+4+(wilds_per_block*14)

boot_dev	equ	$446

loop_len	equ	12
max_loops	equ	100

trap13	equ	$b4
help_vec	equ	$502

print	macro
	move.l	#\1,a0
	jsr	print_mes
	endm


	include	lens.i
	include	aes_defs.i
	include	keys.i

start:
	move.l	4(a7),a5
	move.l	#stack,a7
	move.l	$c(a5),a0
	add.l	$14(a5),a0
	add.l	$1c(a5),a0
	lea	$100(a0),a0
	move.l	a0,prog_len
	pea	(a0)
	pea	(a5)
	clr.w	-(a7)
	move.w	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7

* get command line addr
	lea	$80(a5),a5

	bsr	init
	bsr	tens_to_0
	bsr	main
	jsr	term


do_heading:
	print	heading
	print	last_update
	print	date_dc
	print	time_txt
	print	time_dc
	print	new_line
	rts

init:
* a5 points to command line!
	move.l	#help_page,page_addr

	move.l	#bss,a0
	move.l	#end_bss-bss,d0
	lsr.l	#2,d0
.clear:
	clr.l	(a0)+
	subq.l	#1,d0
	bne.s	.clear

	move.w	#wilds_per_block,exclude_all
	move.w	#wilds_per_block,exclude_temp

	move.l	#loops,a0
	move.l	#"END!",(a0)+
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	a0,loop_ptr

	move.l	#dta,a0
	jsr	set_dta

	move.l	#gosubs,a0
	moveq	#-1,d0
	move.l	d0,(a0)+
	move.l	d0,(a0)+

* print heading
	bsr	do_heading

* work out if we're entering from AUTO folder, or from desktop.

	move.b	#"n",auto_flag

	jsr	mouse_arrow
	tst.w	d0
	bne	not_auto

	move.b	#"y",auto_flag
	bsr	from_auto
	rts

from_auto:
* low res!
* change to medium
	move.w	#1,-(a7)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7

* wait for change
	jsr	vsync

* change palette
	jsr	super_on
	movem.l	$ffff8240.w,d0-7
	movem.l	d0-7,old_pal

	movem.l	my_pal,d0-7
	movem.l	d0-7,$ffff8240.w
	
	jsr	super_off

	bsr	do_heading

* is the CONTROL key pressed?
	jsr	test_shifts
	and.w	#4,d0
	beq.s	.ok
* yes! stop!
	print	ctrl_stop
	bra	do_command_mode

.ok:	
* try to load AUTO.RAM
	print	trying_auto_ram
	move.l	#auto_ram,a0
	moveq	#0,d0
	jsr	load_a_file
	tst.l	d0
	bpl	loaded_auto_ram

	print	no_auto_ram

get_command_file:
* couldn't find AUTO.RAM!
* so I have to ask for a name...
	print	prompt_name
	jsr	get_input
* was the input null?
	tst.w	d0
	bne.s	.ok

* yup - enter command mode!
	bra	do_command_mode

.ok:
* got some input
	move.l	a4,a0
	moveq	#0,d0
	jsr	load_a_file
	tst.l	d0
	bpl.s	.load_ok

* error loading!
	print	file_not_found
	bra	get_command_file

.load_ok:
loaded_auto_ram:
	move.l	d0,text_addr
	move.l	d1,text_len
	rts

tens_to_0:
* convert all the EOL markers in the text file
* to 0s
* all 10s - 0
* all 13s - 0
	move.l	text_addr,a0
	move.l	text_len,d0

	tst.l	d0
	beq.s	.end_while
.while:
	move.b	(a0)+,d1
	cmp.b	#10,d1
	beq	.got_10

	cmp.b	#13,d1
	bne	.not_any

* got a 13!
.got_10:
	clr.b	-1(a0)
.not_any:
	subq.l	#1,d0
	bne	.while

.end_while:
	rts


not_auto:
* I am NOT running from the AUTO folder...
* is there a command line?
	tst.b	(a5)+
	beq.s	.no_command

* try to load command line
	print	trying
	move.l	a5,a0
	jsr	print_mes
	print	new_line

	move.l	a5,a0
	jsr	load_a_file
	tst.l	d0
	bpl	got_file

.no_command:
* use file selector...
	move.l	#star,a0
	jsr	file_selector

	tst.l	d0
	bne	do_command_mode

* load the file which was seleted
	pea	(a0)
	bsr	do_heading

	move.l	(a7)+,a0
	moveq	#0,d0
	jsr	load_a_file
* keep addr
	tst.l	d0
	bpl	got_file

	print	no_file
	bra	do_command_mode

no_file:
	dc.b	"File not found.  Entering command mode.",10,13,10,0
	even


got_file:
	move.l	d0,text_addr
	move.l	d1,text_len
	rts

do_command_mode:
	bsr	do_heading

* enter command mode...
	move.l	#command_mode,text_addr
	move.l	#command_mode_len,text_len
	rts

command_mode:
	dc.b	"ask_mode",10,13
	dc.b	"quit",10,13
command_mode_len	equ	*-command_mode
	even


main:
* start the processing loop
	move.l	text_addr,process_addr
	move.l	text_len,process_len
	move.b	#"n",eof

.while:
	cmp.b	#"n",eof
	bne	.end_while

	move.l	process_addr,last_addr
	move.l	process_len,last_len

	bsr	get_next_line
	bsr	process_line

	bra.s	.while
.end_while:
	rts

get_next_line:
* get next command
* but am I in file or ask! mode?
	move.l	#input_mode,a0
	cmp.l	#"file",(a0)
	beq	from_file

* am I getting just 1?
	cmp.l	#"aone",(a0)
	bne.s	.many

* yup! just one!
	move.l	#"file",(a0)
.many:

* I am in ask! mode!
	print	ask_prompt

	pea	inp_com
	move.w	#10,-(a7)
	trap	#1
	addq.l	#6,a7

	move.w	d0,d7
	print	new_line

	move.l	#input_command,a0
	clr.b	(a0,d7.w)

	move.l	#command_line,a1

* now copy the INPUT to the command line
* erasing all spaces to 0s and putting in $ff after final 0

.copy:
	move.b	(a0)+,d0
	beq.s	.end

	cmp.b	#" ",d0
	bne.s	.not_spc

	moveq	#0,d0
.not_spc:
	move.b	d0,(a1)+
	bra.s	.copy

.end:
	clr.b	(a1)+
	move.b	#$ff,(a1)+
	rts


from_file:
* get the next line from the loaded command file
* don't worry about comment lines etc - just slap out the command line
* with 0s seperating the parameters

	move.l	process_addr,a6
	move.l	process_len,d6		; get addr & length left
	move.l	#command_line,a5
	move.b	#"n",eol
	move.b	#"n",text
	
.while:
* while (not eof) AND (not eol)
	tst.l	d6
	beq.s	.eof

	cmp.b	#"y",eol
	beq	.eol

	bsr	process_char
	subq.l	#1,d6
	bra.s	.while

.eof:
	move.b	#"y",eof
.eol:
	clr.b	(a5)+
	move.b	#$ff,(a5)
	move.l	a6,process_addr
	move.l	d6,process_len
	rts


process_char:
* get next char from command file

	move.b	(a6)+,d0
	bne.s	.not_eol

	move.b	#"y",eol
	rts

.not_eol:
* not to lower case if " are in action...
	tst.b	quote_flag
	bne.s	.not_lower

	jsr	to_lower

.not_lower:
* is it a space or tab?
	cmp.b	#9,d0
	beq.s	.white_space
	cmp.b	#" ",d0
	bne	.not_white

.white_space:
	clr.b	d0

.not_white:
* store the char in the line buffer
	move.b	d0,(a5)+
* was it a "?
	cmp.b	#'"',d0
	bne.s	.no

	eor.b	#1,quote_flag
.no:
	rts


process_line:
* the line is at address "command_line"
* it is terminated with a $ff byte
* spaces and tabs are replaced with 0

	move.l	#command_line,a0
	jsr	get_next_param
	move.l	a0,a5

* first find end of leading 0s
.zeds:
	tst.b	(a5)+
	beq.s	.zeds
	subq.l	#1,a5

	move.b	(a5),d0

* If it's a label then do nothing
	cmp.b	#":",d0
	beq	label

* IF it's a comment then do nothing!
	cmp.b	#"'",d0
	beq	comment

* IF it's blank, then do nothing!
	cmp.b	#$ff,d0
	beq	blank

* it must be a command!

command:
	move.l	#command_list,a0
	moveq	#0,d0

search_comm:
* search for matching command
	move.l	a5,a4

.matches:
	cmpm.b	(a4)+,(a0)+
	beq.s	.matches

* they have stopped matching.  If -1(a0) is $f0 and -1(a4) is $00 then we have a match!
	move.b	-1(a0),d1
	beq.s	.ok
	cmp.b	#$f0,d1
	bne	.not_match
.ok:
	subq.l	#1,a0
	move.b	-1(a4),d1
	beq.s	.match
	cmp.b	#$ff,d1
	bne	.not_match

.match:
* we have a matching command!
	lsl.w	#2,d0
	move.l	#commands,a0
	add.l	d0,a0
	move.l	(a0),a0
	jmp	(a0)

.not_match:
	addq.w	#1,d0

* get the next command in list
.next:
	move.b	(a0)+,d1
	beq	.end_of_list

	cmp.b	#$f0,d1
	bne	.next
	bra	search_comm

.end_of_list:
	print	command_not_known
	jsr	zeds_to_space
	print	command_line
	print	new_line
	rts

command_list:
	dc.b	"all",$f0
	dc.b	"boot_from",$f0
	dc.b	"cd",$f0
	dc.b	"clear_keys",$f0
	dc.b	"cls",$f0
	dc.b	"copy_to",$f0
	dc.b	"dir",$f0
	dc.b	"else",$f0
	dc.b	"end-if",$f0
	dc.b	"end-while",$f0
	dc.b	"flash",$f0
	dc.b	"gosub",$f0
	dc.b	"goto",$f0
	dc.b	"if",$f0
	dc.b	"inpchar",$f0
	dc.b	"inpclr",$f0
	dc.b	"newdisk",$f0
	dc.b	"print",$f0
	dc.b	"?",$f0
	dc.b	"repeat",$f0
	dc.b	"ram",$f0
	dc.b	"reset",$f0
	dc.b	"return",$f0
	dc.b	"search",$f0
	dc.b	"search_next",$f0
	dc.b	"switch",$f0
	dc.b	"until",$f0
	dc.b	"wend",$f0
	dc.b	"while",$f0

* commands in DEMO
	dc.b	"ask",$f0
	dc.b	"ask_mode",$f0
	dc.b	"exclude",$f0
	dc.b	"help",$f0
	dc.b	"input",$f0
	dc.b	"load",$f0
	dc.b	"mem",$f0
	dc.b	"pause",$f0
	dc.b	"quit",$f0
	dc.b	"ramdisk",$f0
	dc.b	"run",$f0
	dc.b	"stop",$f0
	dc.b	"x",$f0


	dc.b	0
	even

comment:
blank:
label:
	rts


commands:
	IFD	demo
	rept	29
	dc.l	demo_ver
	endr
	endc


	IFND	demo
	dc.l	all
	dc.l	boot_from
	dc.l	cd
	dc.l	clear_keys
	dc.l	cls
	dc.l	copy_to
	dc.l	dir
	dc.l	else
	dc.l	end_if
	dc.l	end_while
	dc.l	flash
	dc.l	gosub
	dc.l	goto
	dc.l	if
	dc.l	ninpchar
	dc.l	inpclr
	dc.l	newdisk
	dc.l	print
	dc.l	print
	dc.l	repeat
	dc.l	ram
	dc.l	reset
	dc.l	return
	dc.l	search_first
	dc.l	search_again
	dc.l	switch
	dc.l	until
	dc.l	end_while
	dc.l	while
	ENDC

* routines in DEMO AND FULL version
	dc.l	ask
	dc.l	ask_mode
	dc.l	exclude
	dc.l	help_mode
	dc.l	ninput
	dc.l	load
	dc.l	mmem
	dc.l	pause
	dc.l	quit
	dc.l	ramdisk
	dc.l	run
	dc.l	stop
	dc.l	exclude


	IFD	demo
demo_ver:
	print	not_demo
	rts
	ENDC

switch:
* SWITCH command - how can we switch the RAM searching on or off?
	move.l	a4,a0
	jsr	get_next_param
	tst.l	d0
	beq.s	.another

* nothing after the command!
	print	switch_how
	rts

.another:
	lea	switch_params(pc),a1
	jsr	get_param
	tst.w	d0
	bpl.s	.ok

* invalid param!
	print	switch_how
	rts

.ok:
* got a parameter!
	move.w	d0,d7
	print	switch_by	; print start of message

	moveq	#0,d0
	move.w	d7,d0		; get switch type
	lsl.w	#2,d0		; x 4 for LW offset
	lea	sw_txts(pc),a0
	add.l	d0,a0		; add to list of messages
	move.l	(a0),a0		; get message addr
	jsr	print_mes	; print switch message

* what sort of switch is it?
	dbra	d7,not_shift

	jsr	super_on

* shift switch!
* toggle the SWITCH flag
	move.l	#shift_switch_flag,a0
	move.w	#trap13,a1	; vector to alter
	move.l	#old_trap13+2,a2	; where to store it
	move.l	#my_trap13,a3	; wha to put in
	bsr	do_switch
	jsr	super_off
	rts


not_shift:
	dbra	d7,not_help

* help switch!
	jsr	super_on
	move.l	#help_switch_flag,a0
	move.l	#help_vec,a1
	move.l	#old_help,a2
	move.l	#my_help,a3
	bsr	do_switch
	jsr	super_off
	rts

not_help:
* running switch!

	move.l	#run_switch_flag,a0
	eor.b	#$ff,(a0)
	tst.b	(a0)
	beq.s	.off
	print	on
	print	new_line
	rts

.off:
	print	off
	rts


do_switch:
* enter in SUPER mode
* with:
* a0 = flag addr to toggle
* a1 = system vector to alter
* a2 = where to store vector
* a3 = new vector addr

	eor.b	#$ff,(a0)

* is it now ON?
	tst.b	(a0)
	beq	.off

* yup!  Set it up!
	move.l	(a1),(a2)	; store old vector
	move.l	a3,(a1)		; new vector in

	print	on
	print	new_line
	rts

.off:
	move.l	(a2),(a1)	; restore old vector
	print	off
	print	new_line
	rts


sw_txts:
	dc.l	sw_shift
	dc.l	sw_help
	dc.l	sw_run

switch_by:	dc.b	"SWITCHING using ",0
sw_shift:	dc.b	" Both SHIFT keys ",0
sw_help:	dc.b	" ALT-HELP ",0
sw_run:		dc.b	" Program RUNS ",0

switch_params:
	dc.b	"shift",0
	dc.b	"help",0
	dc.b	"run",0
	dc.b	$ff
	even


mmem:
* show largest free memory block size
	print	mem_free
	moveq	#-1,d0
	jsr	res_mem
* in K
	moveq	#10,d1
	lsr.l	d1,d0

	jsr	num_to_asc
	jsr	print_mes
	print	k
	print	new_line
	rts


help_mode:

help_loop:
	print	new_line

	move.l	page_addr,a6
* go past parent addr
	addq.l	#4,a6
* get no of child pages
	moveq	#0,d0
	move.w	(a6)+,d0
* go past their addrs
	lsl.w	#2,d0
	add.l	d0,a6

	move.w	#1,num_num

.help_loop:

.prt_loop:
* print out the help page, char by char...
	moveq	#0,d0
	move.b	(a6)+,d0
	beq.s	.end_prt

* is it "#"?
	cmp.b	#"#",d0
	beq.s	.show_num

	move.w	d0,-(a7)
	move.w	#2,-(a7)
	dc.w	$a00a
	trap	#1
	dc.w	$a009
	addq.l	#4,a7
	bra.s	.prt_loop

.show_num:
* show the next number!
	moveq	#0,d0
	move.w	num_num,d0
	jsr	num_to_asc

	move.l	a0,a4
	jsr	print_mes

* how many chars were there?
	moveq	#-1,d0
.add:
	addq.l	#1,d0
	tst.b	(a4)+
	bne.s	.add

* print 3 spaces minus the number of chars in the number
	move.l	#space3,a0
	add.l	d0,a0
	jsr	print_mes

	addq.w	#1,num_num
	bra	.prt_loop


.end_prt:
* shall I do a "more..."?
	tst.b	(a6)
	beq.s	.no_more

	print	more
	jsr	inp
	print	space17
	print	s_o_line
	bra.s	.help_loop


.no_more:
	print	new_line
.get_input:
	print	help_prompt

	pea	help_i(pc)
	move.w	#10,-(a7)
	trap	#1
	addq.l	#6,a7
	move.w	d0,d7

	print	new_line

	move.l	#help_inp,a0
	clr.b	(a0,d7.w)
	tst.w	d7
	beq	back_a_page

* not back a page!
* is it a number?
	jsr	asc_to_bin
	subq.w	#1,d0		; 1 less

	tst.w	d1
	bpl.s	.page_yup

* not a number! is it "Q"?
	move.l	#help_inp,a0
	move.b	(a0)+,d0
	jsr	to_lower
	cmp.b	#"q",d0
	bne	.get_input

	tst.b	(a0)
	bne	.get_input

* QUIT!
	rts

.page_yup:
* it's a page number!
	move.l	page_addr,a0	; get page data
	addq.l	#4,a0		; past parent data
	moveq	#0,d1
	move.w	(a0)+,d1	; get no of children

* is no specified > no_of_children?
	move.w	d1,d2		; no of children
	sub.w	d0,d2		; - no specified
	bmi.s	.err
	bne	.ok
.err:
	bra	.get_input

.ok:
* an OK child number
	lsl.w	#2,d0
	add.l	d0,a0	; get addr of child page
	move.l	(a0),page_addr
	bra	help_loop

back_a_page:
* go to parent page...
	move.l	page_addr,a0
	move.l	(a0),d0		; get parent address
	beq	help_loop	; do nothing if no parent
	move.l	d0,page_addr
	bra	help_loop


page_addr:	ds.l	1
help_i:
	dc.b	200,0
help_inp:
	ds.b	200

help_prompt:	dc.b	27,"pHELP>",27,"q ",0
	even

tit	macro
	dc.b	27,"p "
	dc.b	\1
	dc.b	" ",27,"q",10,13
	dc.b	10
	endm

help_page:
	dc.l	0		; no parent page
	ifnd	demo
	dc.w	4		; no of child pages
	dc.l	command_help
	dc.l	label_help
	dc.l	comment_help	; child pages
	dc.l	expressions_help

	dc.b	27,"p",10,13
	dc.b	" ************ ",10,13
	dc.b	" *** HELP *** ",10,13
	dc.b	" ************ ",10,13,27,"q"
	dc.b	10
	dc.b	"Using help... type in a number to see further help on that topic.",10,13
	dc.b	"Type Q to QUIT help",10,13
	dc.b	"Press ENTER to go back a page",10,13
	dc.b	10
	dc.b	"The command line can be one of several things:",10,13
	dc.b	"#a command",10,13
	dc.b	"#a label",10,13
	dc.b	"#a comment",10,13
	dc.b	10
	dc.b	"Shortcuts...",10,13
	dc.b	"#expressions",10,13
	dc.b	10
	dc.b	0,0
	even

comment_help:
	dc.l	help_page	; parent
	dc.w	0		; no children
	tit	"COMMENTS"
	dc.b	"A comment line is prefixed with the ' character.",10,13
	dc.b	"This is for use in command files, and will be of no",10,13
	dc.b	"use in ask mode!",10,13,10
	dc.b	"Example:",10,13
	dc.b	"' this is a comment",10,13
	dc.b	0,0
	even


label_help:
	dc.l	help_page
	dc.w	0
	tit	"LABELS"
	dc.b	"A label always starts on the first character of a line",10,13
	dc.b	"and is prefixed by a :",10,13
	dc.b	":label",10,13
	dc.b	"It must not contain any spaces.",10,13
	dc.b	0,0
	even


command_help:
	dc.l	help_page
	dc.w	39

	dc.l	all_help
	dc.l	ask_help
	dc.l	ask_mode_help
	dc.l	boot_from_help
	dc.l	cd_help
	dc.l	clear_keys_help
	dc.l	cls_help
	dc.l	copy_to_help
	dc.l	dir_help
	dc.l	else_help
	dc.l	endif_help
	dc.l	endwhile_help
	dc.l	exclude_help
	dc.l	gosub_help
	dc.l	goto_help
	dc.l	help_help
	dc.l	if_help
	dc.l	inpchar_help
	dc.l	inpclr_help
	dc.l	input_help
	dc.l	load_help

	dc.l	mem_help
	dc.l	newdisk_help
	dc.l	print_help
	dc.l	pause_help
	dc.l	quit_help
	dc.l	ram_help
	dc.l	ramdisk_help
	dc.l	repeat_help
	dc.l	reset_help
	dc.l	return_help
	dc.l	run_help
	dc.l	search_help
	dc.l	search_next_help
	dc.l	stop_help
	dc.l	switch_help
	dc.l	until_help
	dc.l	while_help
	dc.l	x_help


	tit	"COMMANDS"
	dc.b	"The commands available are:",10,13,10
	dc.b	"#all",10,13
	dc.b	"#ask",10,13
	dc.b	"#ask_mode",10,13
	dc.b	"#boot_from",10,13
	dc.b	"#cd",10,13
	dc.b	"#clear_keys",10,13
	dc.b	"#cls",10,13
	dc.b	"#copy_to",10,13
	dc.b	"#dir",10,13
	dc.b	"#else",10,13
	dc.b	"#end-if",10,13
	dc.b	"#end-while",10,13
	dc.b	"#exclude",10,13
	dc.b	"#gosub",10,13
	dc.b	"#goto",10,13
	dc.b	"#help",10,13
	dc.b	0
	dc.b	"#if",10,13
	dc.b	"#inpchar",10,13
	dc.b	"#inpclr",10,13
	dc.b	"#input",10,13
	dc.b	"#load",10,13
	dc.b	"#mem",10,13
	dc.b	"#newdisk",10,13
	dc.b	"#print",10,13
	dc.b	"#pause",10,13
	dc.b	"#quit",10,13
	dc.b	"#ram",10,13
	dc.b	"#ramdisk",10,13
	dc.b	"#repeat",10,13
	dc.b	"#reset",10,13
	dc.b	"#return",10,13
	dc.b	"#run",10,13
	dc.b	"#search",10,13
	dc.b	"#search_next",10,13
	dc.b	"#stop",10,13
	dc.b	"#switch",10,13
	dc.b	"#until",10,13
	dc.b	"#while",10,13
	dc.b	"#x",10,13
	dc.b	0,0
	even



all_help:
	dc.l	command_help
	dc.w	2
	dc.l	exclude_help
	dc.l	newdisk_help
	tit	"ALL"
	dc.b	"all takes one of two parameters:",10,13
	dc.b	"all on",10,13
	dc.b	"all off",10,13
	dc.b	10
	dc.b	"It is used when an EXCLUDE has been specified with",10,13
	dc.b	"the /all option.  The excludes can be disabled by using all off",10,13
	dc.b	"and re-enabled using all on",10,13
	dc.b	10
	dc.b	0
	dc.b	10
	dc.b	"exclude *.DOG /all",10,13
	dc.b	"load *.*",10,13
	dc.b	"newdisk",10,13
	dc.b	'print "enter disk 2"',10,13
	dc.b	"pause",10,13
	dc.b	"load *.*",10,13
	dc.b	"'now I want to load all the *.DOG files!",10,13
	dc.b	"all off",10,13
	dc.b	"newdisk",10,13
	dc.b	'"print "enter disk 3"',10,13
	dc.b	"pause",10,13
	dc.b	"load *.*",10,13
	dc.b	10

	dc.b	"See also:",10,13
	dc.b	"#exclude",10,13
	dc.b	"#newdisk",10,13
	dc.b	0,0
	even

ask_help:
	dc.l	command_help
	dc.w	0
	tit	"ASK"
	dc.b	'When included in a command file, "ask" will allow',10,13
	dc.b	"the user to enter ONE command during run-time.",10,13
	dc.b	0,0
	even

ask_mode_help:
	dc.l	command_help
	dc.w	0
	tit	"ASK_MODE"
	dc.b	'When included in a command file, "ask_mode" will allow',10,13
	dc.b	"the user to enter the command mode until",10,13
	dc.b	'"stop" is entered as a command, when control will',10,13
	dc.b	"revert to the command file.",10,13
	dc.b	0,0
	even

boot_from_help:
	dc.l	command_help
	dc.w	0
	tit	"BOOT_FROM"
	dc.b	"This command changes the boot drive.",10,13
	dc.b	"Example:",10,13
	dc.b	"boot_from C		(boots from drive C next time)",10,13
	dc.b	10
	dc.b	"The machine will continue to boot from the specified drive",10,13
	dc.b	"until a cold reset or until another program alters the",10,13
	dc.b	"boot drive.",10,13
	dc.b	0,0
	even


cd_help:
	dc.l	command_help
	dc.w	0
	dc.b	27,"p cd ",27,"q",10,13,10
	dc.b	"cd is used to change directories, in the same manner",10,13
	dc.b	"that the MSDOS comamnd is used on PCs.",10,13
	dc.b	"Examples",10,13
	dc.b	"cd \             (go to root directory)",10,13
	dc.b	"cd dir_name      (go to directory dir_name)",10,13
	dc.b	"cd ..            (go back 1 directory)",10,13
	dc.b	"cd a:\           (go to drive A:, and root directory)",10,13
	dc.b	"cd b:\test       ( go to drive B: and directory \TEST)",10,13
	dc.b	0,0
	even

clear_keys_help:
	dc.l	command_help
	dc.w	0
	tit	"CLEAR_KEYS"
	dc.b	"Clears the keyboard buffer.",10,13
	dc.b	"Can be used before, for example, pausing between",10,13
	dc.b	"disk swaps.",10,13,10
	dc.b	'print "enter disk 2"',10,13
	dc.b	"clear_keys",10,13
	dc.b	"pause",10,13
	dc.b	0,0
	even

cls_help:
	dc.l	command_help
	dc.w	0
	tit	"CLS"
	dc.b	"Clears the screen.",10,13,10
	dc.b	0,0
	even


copy_to_help:
	dc.l	command_help
	dc.w	0
	tit	"COPY_TO"
	dc.b	"copy_to sets the destination drive for wildcard operations",10,13
	dc.b	"It is initialy set to A:.  When you install a RAMDISK",10,13
	dc.b	"the copy_to drive is automaticaly set to the RAMDISK drive.",10,13
	dc.b	"Example:",10,13
	dc.b	"copy_to c        (sets destination drive to C:)",10,13
	dc.b	0,0

dir_help:
	dc.l	command_help
	dc.w	0
	tit	"DIR"
	dc.b	"Allows you to see the directory of the current disk.",10,13
	dc.b	"You can specify wildcards.",10,13
	dc.b	10
	dc.b	"dir *.prg",10,13
	dc.b	"dir",10,13
	dc.b	10
	dc.b	0
	dc.b	"You can also specify other paths (you MUST incude a wildcard)",10,13
	dc.b	"but the title of the directory looks odd.",10,13
	dc.b	"I really could not be bothered to fix this bug",10,13
	dc.b	"as it is NOT a major bug!",10,13
	dc.b	10
	dc.b	"dir a:\auto\*.*",10,13
	dc.b	10
	dc.b	0,0
	even

else_help:
	dc.l	command_help
	dc.w	1
	dc.l	if_help
	tit	"ELSE"
	dc.b	"Allows an alternative action after an IF command.",10,13
	dc.b	"See also:",10,13
	dc.b	"#if",10,13
	dc.b	0,0
	even

endif_help:
	dc.l	command_help
	dc.w	1
	dc.l	if_help
	tit	"END-IF"
	dc.b	"The end of an IF command.",10,13
	dc.b	"See also:",10,13
	dc.b	"#if",10,13
	dc.b	0,0
	even

endwhile_help:
	dc.l	command_help
	dc.w	2
	dc.l	while_help
	dc.l	expressions_help
	tit	"END-WHILE"
	dc.b	"The end of a WHILE loop.",10,13
	dc.b	"Can also be written as WEND",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#while",10,13
	dc.b	"#expressions",10,13
	dc.b	0,0
	even


exclude_help:
	dc.l	command_help
	dc.w	2
	dc.l	all_help
	dc.l	newdisk_help
	tit	"EXCLUDE"
	dc.b	'"x" can be used as a shortcut for this command',10,13
	dc.b	"This command allows you to exclude files from being loaded.",10,13
	dc.b	"Say, for example, you wanted to load all the *.PI1 files",10,13
	dc.b	"_except_ those called CAT01.PI1, CAT02.PI1 etc...",10,13
	dc.b	"The commands would be:",10,13
	dc.b	"exclude CAT*.PI1",10,13
	dc.b	"load *.PI1",10,13
	dc.b	0
	dc.b	10
	dc.b	'The "excluded" wildcards will be left out after the exclude',10,13
	dc.b	"instruction has been executed.  To wipe the exclude list, use the",10,13
	dc.b	'newdisk command.  To ensure that a wildcard is "excluded" from ALL disks',10,13
	dc.b	'add "/all" after the wildcard:',10,13
	dc.b	10
	dc.b	"exclude CAT*.PI1 /all",10,13
	dc.b	"This will exclude CAT*.PI1 from ALL disks used to load in from.",10,13
	dc.b	"So you can have:",10,13
	dc.b	10
	dc.b	"'do not load CAT files...",10,13
	dc.b	"exclude CAT*.PI1 /all",10,13
	dc.b	"'or DOG files...",10,13
	dc.b	"exclude DOG*.PI1",10,13
	dc.b	"load *.PI1",10,13
	dc.b	'print "please enter DOG disk"',10,13
	dc.b	"pause",10,13
	dc.b	"newdisk",10,13
	dc.b	"'loading DOG files now, but still not CAT files...",10,13
	dc.b	"load *.PI1",10,13
	dc.b	"This will exclude CAT*.PI1 from BOTH disks, but DOG*.PI1 from the first only.",10,13
	dc.b	"Use the ALL command to switch the excludes with the /all switch off and on.",10,13
	dc.b	0
	dc.b	10,13,10
	dc.b	"See also:",10,13
	dc.b	"#all",10,13
	dc.b	"#newdisk",10,13
	dc.b	0,0
	even

gosub_help:
	dc.l	command_help
	dc.w	2
	dc.l	return_help
	dc.l	goto_help
	tit	"GOSUB"
	dc.b	"As in BASIC; it will call a subroutine.",10,13
	dc.b	'The subroutine ends with the command "return"',10,13
	dc.b	"and control will then return to the line after the GOSUB",10,13
	dc.b	10
	dc.b	"gosub :my_rout",10,13
	dc.b	'print "I have control back here!"',10,13
	dc.b	"pause",10,13
	dc.b	"quit",10,13
	dc.b	":my_rout",10,13
	dc.b	'print "Subroutine called now..."',10,13
	dc.b	"return",10,13
	dc.b	0,0
	even

goto_help:
	dc.l	command_help
	dc.w	1
	dc.l	gosub_help
	tit	"GOTO"
	dc.b	"As in BASIC; jumps to a label.",10,13
	dc.b	10
	dc.b	"goto :here",10,13
	dc.b	"'do not execute this line",10,13
	dc.b	":here",10,13
	dc.b	0,0
	even

help_help:
	dc.l	command_help
	dc.w	0
	tit	"HELP"
	dc.b	"What do you think you're in now?",10,13
	dc.b	0,0
	even

if_help:
	dc.l	command_help
	dc.w	3
	dc.l	repeat_help
	dc.l	while_help
	dc.l	expressions_help
	tit	"IF"
	dc.b	"Allows a selection.  This uses the same expressions",10,13
	dc.b	"as the REPEAT and WHILE loops.",10,13
	dc.b	10
	dc.b	"Example:",10,13
	dc.b	"if mem < 850",10,13
	dc.b	'   print "memory too small!"',10,13
	dc.b	"   quit",10,13
	dc.b	"else",10,13
	dc.b	'   print "memory ok for RAMDISK."',10,13
	dc.b	"   ramdisk 800 g",10,13
	dc.b	"   quit /resident",10,13
	dc.b	"end-if",10,13
	dc.b	0
	dc.b	10,13,10,10
	dc.b	'print "enter your name:"',10,13
	dc.b	"input",10,13
	dc.b	'if input = "james"',10,13
	dc.b	'   print "you are a top man!"',10,13
	dc.b	"else",10,13
	dc.b	'   print "You are not James!  Leave now!"',10,13
	dc.b	"end-if",10,13
	dc.b	'print "byeee!"',10,13
	dc.b	0
	dc.b	10,13
	dc.b	"See also:",10,13
	dc.b	"#repeat",10,13
	dc.b	"#while",10,13
	dc.b	"#expressions",10,13
	dc.b	0,0
	even


inpchar_help:
	dc.l	command_help
	dc.w	0
	tit	"INPCHAR"
	dc.b	"Waits for a single keypress.",10,13
	dc.b	"Can be used with a mask of characters, which",10,13
	dc.b	"will allow only those characters to be pressed.",10,13
	dc.b	"Upper and lower case are not distingusihed between.",10,13
	dc.b	"The result is stored in CHAR, and can be used in WHILE,",10,13
	dc.b	"REPEAT and IF statements",10,13
	dc.b	10
	dc.b	"inpchar",10,13
	dc.b	10
	dc.b	'print "use RAM LOADER (Y/N)?"',10,13
	dc.b	"'wait for a Y or a N",10,13
	dc.b	"inpchar yn",10,13
	dc.b	'IF char = "N"',10,13
	dc.b	"quit",10,13
	dc.b	"end-if",10,13
	dc.b	0,0
	even


inpclr_help:
	dc.l	command_help
	dc.w	1
	dc.l	inpchar_help
	tit	"INPCLR"
	dc.b	"As INPCHAR, but the keyboard buffer is cleared",10,13
	dc.b	"before any input is accepted.",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#inpchar",10,13
	dc.b	0,0
	even

input_help:
	dc.l	command_help
	dc.w	2
	dc.l	load_help
	dc.l	expressions_help
	tit	"INPUT"
	dc.b	"Allows the user to input a string.",10,13
	dc.b	"The string is stored in INPUT",10,13
	dc.b	"and can be referenced by WHILE, REPEAT and IF commands.",10,13
	dc.b	"No difference is made between upper and lower case.",10,13
	dc.b	"It can also be used in the LOAD command",10,13
	dc.b	10
	dc.b	'print "please enter file to load:"',10,13
	dc.b	"input",10,13
	dc.b	"load INPUT",10,13
	dc.b	10
	dc.b	'print "please enter your name"',10,13
	dc.b	"input",10,13
	dc.b	'WHILE input <> "James"',10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#load",10,13
	dc.b	"#expressions",10,13
	dc.b	0,0
	even


load_help:
	dc.l	command_help
	dc.w	2
	dc.l	input_help
	dc.l	search_help
	tit	"LOAD"
	dc.b	"The LOAD option allows files to be LOADED to the RAMDISK",10,13
	dc.b	'(or the drive specified by copy_to").',10,13
	dc.b	"You can use the parameter /full to load all matching files",10,13
	dc.b	"from sub-directories as well:",10,13
	dc.b	10
	dc.b	"cd a:\",10,13
	dc.b	"load *.* /full",10,13
	dc.b	10
	dc.b	"The above example will copy all the files on drive A:",10,13
	dc.b	0
	dc.b	10

	dc.b	"Load can also be used to load file(s) specified by the user using INPUT",10,13
	dc.b	10
	dc.b	'print "enter wildcard:"',10,13
	dc.b	"input",10,13
	dc.b	"load input",10,13
	dc.b	10
	dc.b	0
	dc.b	10
	dc.b	"LOAD can load files which have been FOUND:",10,13
	dc.b	10
	dc.b	"search *.pi1",10,13
	dc.b	"load found",10,13
	dc.b	10
	dc.b	"N.B. search_next will NOT work after a load!",10,13
	dc.b	10
	dc.b	0
	dc.b	"Just for completeness, you may be wandering how you load files",10,13
	dc.b	'called "found" or "input".',10,13
	dc.b	"To load files which happen to have these names, type:",10,13
	dc.b	"load @input",10,13
	dc.b	"load @found",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#input",10,13
	dc.b	"#search",10,13
	dc.b	0,0
	even

mem_help:
	dc.l	command_help
	dc.w	1
	dc.l	mem_exp
	tit	"MEM"
	dc.b	"Displays the size of the largest free block of memory",10,13
	dc.b	"mem",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#mem (expression)",10,13
	dc.b	0,0

newdisk_help:
	dc.l	command_help
	dc.w	2
	dc.l	all_help
	dc.l	exclude_help
	tit	"NEWDISK"
	dc.b	"Informs the system that a new logical disk has been entered.",10,13
	dc.b	"This will wipe all exclude files without the /all option.",10,13
	dc.b	"It does not cause the system to pause, so you must ask for",10,13
	dc.b	"a new disk and then pause manually, if it is required.",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#all",10,13
	dc.b	"#exclude",10,13
	dc.b	0,0
	even

print_help:
	dc.l	command_help
	dc.w	0
	tit	"PRINT"
	dc.b	"Allows you to print messages on the screen.",10,13
	dc.b	"Your message should be enclosed by quotes:",10,13
	dc.b	10
	dc.b	'print "hello mum!"',10,13
	dc.b	10
	dc.b	"You can use ? as a shortcut:",10,13
	dc.b	'? "the same as print!"',10,13
	dc.b	10
	dc.b	0,0
	even

pause_help:
	dc.l	command_help
	dc.w	2
	dc.l	inpchar_help
	dc.l	inpclr_help
	tit	"PAUSE"
	dc.b	"Simply waits for a keypress.  No record is made",10,13
	dc.b	"of which key is pressed.  To do this, you should use:",10,13
	dc.b	"#inpchar",10,13
	dc.b	"#inpclr",10,13
	dc.b	0,0
	even

quit_help:
	dc.l	command_help
	dc.w	1
	dc.l	boot_from_help
	tit	"QUIT"
	dc.b	"Quits RAM_LOAD.  If no parameters are specified,",10,13
	dc.b	"then any ramdisk is switched off, and all memory freed.",10,13
	dc.b	"There are two parameters you can specify:",10,13
	dc.b	"/resident",10,13
	dc.b	"/reset",10,13
	dc.b	10
	dc.b	0
	dc.b	"/resident allows RAM_LOAD to remain in memory.  Any RAMDISK",10,13
	dc.b	"will also remain, and can be accessed from the desktop",10,13
	dc.b	"or the file selector.",10,13
	dc.b	10
	dc.b	0
	dc.b	"/reset does the same job as /resident, but also makes the RAMDISK",10,13
	dc.b	"reset proof. You can boot from the ramdisk by using the boot_from",10,13
	dc.b	"command.",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#boot_from",10,13
	dc.b	0,0
	even


ram_help:
	dc.l	command_help
	dc.w	1
	dc.l	switch_help
	tit	"RAM"
	dc.b	"Turns RAM searching ON and OFF",10,13
	dc.b	"RAM searching is the reason d'etre for RAM_LOAD.",10,13
	dc.b	"Files are copied to RAMDISK, and are then automatically",10,13
	dc.b	"loaded from there when needed.  If you need to run a program",10,13
	dc.b	"Which is alergic to this function and crashes, you can turn the",10,13
	dc.b	"searching OFF using:",10,13
	dc.b	"ram off",10,13
	dc.b	"run strange.prg",10,13
	dc.b	"ram on",10,13
	dc.b	0
	dc.b	"See also:",10,13
	dc.b	"#switch",10,13,0,0
	even

ramdisk_help:
	dc.l	command_help
	dc.w	0
	tit	"RAMDISK"
	dc.b	"Allows a RAMDISK to be created.  You don't HAVE to have",10,13
	dc.b	"a RAMDISK to use RAM_LOAD, but if you have a hard",10,13
	dc.b	"disk then what are you doing using this?",10,13
	dc.b	"The command takes 2 parameters; the size and the letter",10,13
	dc.b	"of the new drive.",10,13
	dc.b	10
	dc.b	"ramdisk 200 g",10,13
	dc.b	"'set up a 200k ramdisk as drive g",10,13
	dc.b	10
	dc.b	0

	dc.b	"You can also make the ramdisk reset proof by adding /reset",10,13
	dc.b	"ramdisk 200 g /reset",10,13
	dc.b	0,0
	even

repeat_help:
	dc.l	command_help
	dc.w	4
	dc.l	until_help
	dc.l	expressions_help
	dc.l	while_help
	dc.l	if_help

	tit	"REPEAT"
	dc.b	"You can set up loops using the REPEAT/UNTIL combination.",10,13
	dc.b	"A REPEAT loop will ALWAYS execute at least once.",10,13
	dc.b	"The expression is tested at the UNTIL command.",10,13
	dc.b	"A WHILE loop is tested BEFORE it is executed, so may not run at all.",10,13
	dc.b	10
	dc.b	"repeat",10,13
	dc.b	'print "please enter GAME disk"',10,13
	dc.b	"pause"
	dc.b	"search_for game.prg",10,13
	dc.b	"until exists",10,13
	dc.b	10
	dc.b	0
	dc.b	"You can use any of the expressions in the expressions section.",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#until",10,13
	dc.b	"#expressions",10,13
	dc.b	"#while",10,13
	dc.b	"#if",10,13
	dc.b	0,0
	even


reset_help:
	dc.l	command_help
	dc.w	0
	tit	"RESET"
	dc.b	"Simply forces a soft reset of the machine.",10,13
	dc.b	"Equivalent to pressing the reset button at the back.",10,13
	dc.b	"Reset proof RAMDISKs will survive!",10,13
	dc.b	0,0
	even

return_help:
	dc.l	command_help
	dc.w	1
	dc.l	gosub_help
	tit	"RETURN"
	dc.b	"Returns from a subroutine called by GOSUB",10,13
	dc.b	"See also:",10,13
	dc.b	"#gosub",10,13
	dc.b	0,0
	even

run_help:
	dc.l	command_help
	dc.w	1
	dc.l	ram_help
	tit	"RUN"
	dc.b	"Runs a program.  You can specify NOT to use the RAMDISK",10,13
	dc.b	"automatically using the RAM command.",10,13
	dc.b	"You can also pass a command line!",10,13
	dc.b	10
	dc.b	"run me.prg",10,13
	dc.b	"run devpac.prg mycode.s",10,13
	dc.b	10
	dc.b	"You can loop a program by adding the /loop parameter.",10,13
	dc.b	"run me.prg command_line_here /loop",10,13
	dc.b	10
	dc.b	"which will ask whether to run the program again or not",10,13
	dc.b	"each time the program finishes.",10,13
	dc.b	"See also:",10,13
	dc.b	"#ram",10,13
	dc.b	0,0
	even

search_help:
	dc.l	command_help
	dc.w	2
	dc.l	search_next_help
	dc.l	expressions_help
	tit	"SEARCH_FOR"
	dc.b	"Allows you to search for a file.",10,13
	dc.b	"The result is stored in several variables:",10,13
	dc.b	"   EXISTS",10,13
	dc.b	"   NOTEXISTS",10,13
	dc.b	"   FOUND",10,13
	dc.b	"They can all be used in WHILE, REPEAT and IF commands.",10,13
	dc.b	10
	dc.b	"'search for file to tell when correct disk is in",10,13
	dc.b	"REPEAT",10,13
	dc.b	"search_for disk1.inf",10,13
	dc.b	"UNTIL exists",10,13
	dc.b	10
	dc.b	0
	dc.b	"'search for and load a file",10,13
	dc.b	"search_for file1.dat",10,13
	dc.b	"if exists",10,13
	dc.b	"   load found",10,13
	dc.b	"end-if",10,13
	dc.b	10
	dc.b	"N.B. The SEARCH_NEXT command WILL NOT WORK after a load",10,13
	dc.b	"instruction, as LOAD performs searches of it's own!",10,13
	dc.b	10
	dc.b	0
	dc.b	"See also:",10,13
	dc.b	"#search_next",10,13
	dc.b	"#expressions",10,13

	dc.b	0,0
	even

search_next_help:
	dc.l	command_help
	dc.w	1
	dc.l	search_help
	tit	"SEARCH_NEXT"
	dc.b	"Searches for the next file which matches the wildcard",10,13
	dc.b	"passed to SEARCH_FOR.",10,13
	dc.b	10
	dc.b	"N.B. The SEARCH_NEXT command WILL NOT WORK after a load",10,13
	dc.b	"instruction, as LOAD performs searches of it's own!",10,13
	dc.b	10
	dc.b	"For a full breakdown, see:",10,13
	dc.b	"#search_for",10,13
	dc.b	0,0
	even



stop_help:
	dc.l	command_help
	dc.w	1
	dc.l	ask_mode_help
	tit	"STOP"
	dc.b	"Allows the user to leave the ask mode.",10,13
	dc.b	"Control is passed back to the command file.",10,13
	dc.b	"See also:",10,13
	dc.b	"#ask_mode",10,13
	dc.b	0,0
	even

switch_help:
	dc.l	command_help
	dc.w	1
	dc.l	ram_help
	tit	"SWITCH"
	dc.b	"You can specify how to switch the RAM searching on and off",10,13
	dc.b	"when you are not in the ASK mode.  For example, when running",10,13
	dc.b	"a program, or after quitting with a resident ramdisk.",10,13
	dc.b	"The valid parameters are:",10,13
	dc.b	"   shift",10,13
	dc.b	"   help",10,13
	dc.b	"   run",10,13,10
	dc.b	0
	dc.b	"SHIFT will toggle the RAM on/off when both shift keys are held.",10,13,10
	dc.b	"HELP will toggle when ALT-HELP is pressed.",10,13
	dc.b	"RUN will ALWAYS switch on searching when a program is RUN.",10,13
	dc.b	10
	dc.b	"E.G.",10,13
	dc.b	"ramdisk 100 g",10,13
	dc.b	"ram off",10,13
	dc.b	"switch help",10,13
	dc.b	"switch shift",10,13
	dc.b	"quit /reset",10,13
	dc.b	10
	dc.b	"This will switch the searching OFF.  When you press either",10,13
	dc.b	"both SHIFT keys or ALT-HELP, searching is toggled.",10,13
	dc.b	0
	dc.b	10
	dc.b	"Bug Note:",10,13
	dc.b	"When RAM_LOAD is run from the AUTO folder, and SWITCH is set to turn",10,13
	dc.b	"RAM searching on when a program is run, note that programs in",10,13
	dc.b	"the AUTO folder will turn it on!",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#ram",10,13
	dc.b	0,0
	even


until_help:
	dc.l	command_help
	dc.w	2
	dc.l	repeat_help
	dc.l	expressions_help
	tit	"UNTIL"
	dc.b	"The end of a REPEAT loop.",10,13
	dc.b	"See also:",10,13
	dc.b	"#REPEAT",10,13
	dc.b	"#expressions",10,13
	dc.b	0,0
	even

while_help:
	dc.l	command_help
	dc.w	4
	dc.l	endwhile_help
	dc.l	expressions_help
	dc.l	repeat_help
	dc.l	if_help
	tit	"WHILE"
	dc.b	"You can set up a loop using a WHILE loop.",10,13
	dc.b	"The expression is tested right away, so the loop may not",10,13
	dc.b	"run at all.  If you want to ensure the loop runs at least once, see",10,13
	dc.b	"the REPEAT command.",10,13
	dc.b	10
	dc.b	"search *.*",10,13
	dc.b	'print "load a file (Y/N)?"',10,13
	dc.b	"inpchar yn",10,13
	dc.b	'while inpchar = "y" and exists',10,13
	dc.b	"load found",10,13
	dc.b	'print "load another file (Y/N)?"',10,13
	dc.b	"inpchar yn",10,13
	dc.b	"end-while",10,13
	dc.b	10
	dc.b	0
	dc.b	"See also:",10,13
	dc.b	"#end-while",10,13
	dc.b	"#expressions",10,13
	dc.b	"#repeat",10,13
	dc.b	"#if",10,13
	dc.b	0,0
	even



x_help:
	dc.l	command_help
	dc.w	1
	dc.l	exclude_help
	tit	"X"
	dc.b	"See:",10,13
	dc.b	"#exclude",10,13
	dc.b	0,0
	even


expressions_help:
	dc.l	command_help
	dc.w	6
	dc.l	inpchar_exp
	dc.l	input_exp
	dc.l	exists_exp
	dc.l	found_exp
	dc.l	mem_exp
	dc.l	combine_exp
	tit	"EXPRESSIONS",10,13
	dc.b	"The REPEAT, WHILE and IF statements are fairly powerful.",10,13
	dc.b	"They all use the same expressions:",10,13
	dc.b	"#INPCHAR",10,13
	dc.b	"#INPUT",10,13
	dc.b	"#EXISTS",10,13
	dc.b	"#FOUND",10,13
	dc.b	"#MEM",10,13
	dc.b	"#COMBINING EXPRESSIONS",10,13
	dc.b	0,0
	even

inpchar_exp:
	dc.l	expressions_help
	dc.w	5
	dc.l	input_exp
	dc.l	exists_exp
	dc.l	found_exp
	dc.l	mem_exp
	dc.l	combine_exp
	tit	"INPCHAR",10,13
	dc.b	"The commands inpchar and inpclr leave 1 character",10,13
	dc.b	"in a buffer called INPCHAR.",10,13
	dc.b	"This can be evaluated like this:",10,13
	dc.b	10
	dc.b	'IF inpchar = "y"',10,13
	dc.b	10
	dc.b	'WHILE inpchar <> "n"',10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#INPUT",10,13
	dc.b	"#EXISTS",10,13
	dc.b	"#FOUND",10,13
	dc.b	"#MEM",10,13
	dc.b	"#COMBINING EXPRESSIONS",10,13

	dc.b	0,0
	even

input_exp:
	dc.l	expressions_help
	dc.w	5
	dc.l	inpchar_exp
	dc.l	exists_exp
	dc.l	found_exp
	dc.l	mem_exp
	dc.l	combine_exp
	tit	"INPUT"
	dc.b	"Allows you to examine what the user inputed",10,13
	dc.b	"When the input command was used:",10,13
	dc.b	10
	dc.b	'IF input = "James"',10,13
	dc.b	10
	dc.b	'WHILE input = ""',10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#INPCHAR",10,13
	dc.b	"#EXISTS",10,13
	dc.b	"#FOUND",10,13
	dc.b	"#MEM",10,13
	dc.b	"#COMBINING EXPRESSIONS",10,13

	dc.b	0,0
	even

exists_exp:
	dc.l	expressions_help
	dc.w	5
	dc.l	inpchar_exp
	dc.l	input_exp
	dc.l	found_exp
	dc.l	mem_exp
	dc.l	combine_exp
	tit	"EXISTS"
	dc.b	"When you do a search_for or a search_next command,",10,13
	dc.b	"the EXISTS flag is changed.",10,13
	dc.b	10
	dc.b	"search_for disk1.inf",10,13
	dc.b	"IF exists",10,13
	dc.b	"goto :special",10,13
	dc.b	"end-if",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#INPCHAR",10,13
	dc.b	"#INPUT",10,13
	dc.b	"#FOUND",10,13
	dc.b	"#MEM",10,13
	dc.b	"#COMBINING EXPRESSIONS",10,13

	dc.b	0,0
	even

found_exp:
	dc.l	expressions_help
	dc.w	5
	dc.l	inpchar_exp
	dc.l	input_exp
	dc.l	exists_exp
	dc.l	mem_exp
	dc.l	combine_exp
	tit	"FOUND"
	dc.b	"When you do a search_for or a search_next command,",10,13
	dc.b	"the FOUND text is changed to the name of the file found.",10,13
	dc.b	10
	dc.b	'search_for *.dat',10,13
	dc.b	'if found = "first.dat"',10,13
	dc.b	"   load found",10,13
	dc.b	"end-if",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#INPCHAR",10,13
	dc.b	"#INPUT",10,13
	dc.b	"#EXISTS",10,13
	dc.b	"#COMBINING EXPRESSIONS",10,13

	dc.b	0,0
	even

combine_exp:
	dc.l	expressions_help
	dc.w	5
	dc.l	inpchar_exp
	dc.l	input_exp
	dc.l	exists_exp
	dc.l	found_exp
	dc.l	mem_exp
	tit	"COMBINE"
	dc.b	"You can combine several expressions in one command:",10,13
	dc.b	10
	dc.b	'IF (((exists) and (found <> "last.dat")) or inpchar = "y")',10,13
	dc.b	10
	dc.b	"As you can see, you can also use brackets.",10,13
	dc.b	10
	dc.b	"See also:",10,13
	dc.b	"#INPCHAR",10,13
	dc.b	"#INPUT",10,13
	dc.b	"#EXISTS",10,13
	dc.b	"#FOUND",10,13
	dc.b	"#MEM",10,13
	dc.b	0,0
	even

mem_exp:
	dc.l	expressions_help
	dc.w	5
	dc.l	inpchar_exp
	dc.l	input_exp
	dc.l	exists_exp
	dc.l	found_exp
	dc.l	combine_exp
	tit	"MEM"
	dc.b	"You can base decisions on how much memory you have free.",10,13
	dc.b	"Note that a 1 meg machine will always have LESS than",10,13
	dc.b	"1000k free. So test for about 950 or so.",10,13
	dc.b	"But always take into account any resident programs",10,13
	dc.b	" - including RAM_LOAD!",10,13
	dc.b	10
	dc.b	"if mem < 950",10,13
	dc.b	'print "not enough memory!"',10,13
	dc.b	"quit",10,13
	dc.b	"end-if",10,13
	dc.b	10
	dc.b	0
	dc.b	"See also:",10,13
	dc.b	"#INPCHAR",10,13
	DC.B	"#INPUT",10,13
	DC.B	"#EXISTS",10,13
	DC.B	"#FOUND",10,13
	DC.B	"#COMBINING EXPRESSIONS",10,13
	DC.B	10
	DC.B	0,0
	EVEN

	endc

	ifd	demo
	dc.w	0
	dc.b	"no help available in Demo.",10,13
	dc.b	"Enter Q and press RETURN.",10,13
	dc.b	0,0
	even
	endc


ask_mode:
	cmp.l	#"file",input_mode
	beq.s	.ok

	print	in_ask_mode
	rts

.ok:
	move.l	#"ask!",input_mode
	move.b	#"n",eof
	print	ask_intro
	rts

stop:
	move.l	#"file",input_mode
	rts

ask:
	cmp.l	#"file",input_mode
	beq.s	.ok

	print	in_ask_mode
	rts

.ok:
	move.l	#"aone",input_mode
	move.b	#"n",eof
	rts




run:
* run <progname> {/LOOP}
	move.b	#"n",run_loop
	move.l	#null,prog_command

	move.l	a4,a0
	bsr	get_next_param
	move.l	a0,a4
	tst.w	d0
	bpl.s	.ok

	print	run_what?
	rts

.ok:
	bsr	past_param
	bsr	get_next_param
	tst.w	d0
	bmi	.no_loop_or_comm

* could have "/LOOP"
* or command line

	move.l	#run_params,a1
	bsr	get_param
	tst.w	d0
	bpl.s	.ok2

* it's a command line
	move.l	a0,prog_command
	bsr	past_param
	bsr	get_next_param
	tst.w	d0
	bmi	.no_loop_or_comm

* we've also got "/LOOP"
* maybe.
	move.l	#run_params,a1
	bsr	get_param
	tst.w	d0
	bpl.s	.ok2

	print	inv_run_param
	rts


.ok2:
* we have /LOOP!
	move.b	#"y",run_loop

.no_loop_or_comm:
* do I install search routines?

	tst.b	run_switch_flag
	beq.s	.no_flag

* always switch on when running!
	lea	search_ram(pc),a0
	move.b	#"y",(a0)

.no_flag:
	lea	installed_search(pc),a0
	move.b	#"n",(a0)

	lea	search_ram(pc),a1
	cmp.b	#"y",(a1)
	bne.s	.no

* install the search!
	move.b	#"y",(a0)
	bsr	install_search
.no:


.run_loop:
* a4 holds progname

* sort out program command
	move.l	prog_command,a0
	move.l	#prog_line,a1
	move.l	a1,a2
	addq.l	#1,a2

	moveq	#-1,d0
.copy:
	addq.w	#1,d0
	move.b	(a0)+,(a2)+
	bne.s	.copy

	move.b	d0,(a1)

	bsr	cls

	move.l	#env,-(a7)
	move.l	#prog_line,-(a7)
	pea	(a4)
	clr.w	-(a7)
	move.w	#$4b,-(a7)
	trap	#1
	lea	16(a7),a7

	move.w	d0,d7
	bsr	cls

	move.l	#dta,a0
	jsr	set_dta


* error?
	tst.w	d7
	bpl.s	.run_ok

	print	run_error
.run_ok:
* is there a loop?
	cmp.b	#"y",run_loop
	bne	.loop_end

* ask whether or not to run again
	print	run_again?
.wait_val:
	bsr	inp_echo
	jsr	to_lower
	cmp.b	#"y",d0
	beq	.run_loop
	cmp.b	#"n",d0
	bne.s	.wait_val
.loop_end:
* do I de-stall run loop?
	cmp.b	#"y",installed_search
	bne.s	.no2

	bsr	destall_search
.no2:
	rts



run_params:
	dc.b	"/loop",0
	dc.b	$ff
	even


load:
* load FOUND or INPUT or wildcard?
	move.l	a4,a0
	bsr	get_next_param
	move.l	a0,a4
	tst.w	d0
	bpl	.ok

	print	inv_load_param
	rts

.ok:
	move.l	#load_params,a1
	bsr	get_param
	tst.w	d0
	bpl.s	.ok2

* it's a wildcard!
	move.l	a4,a5
	bra	wildcard

.ok2:
* was it "FOUND"?
	tst.w	d0
	bne	.not_found

* yes!
	move.l	#dta+f_name,a5
	bra	.do_wild

.not_found:
	subq.w	#1,d0
	bne.s	.not_input

	move.l	#input_line+2,a5
.do_wild:
* copy wildcard to load to buffer line
* and put in end of line marker

	move.l	#load_buf,a0
.copy:
	move.b	(a5)+,(a0)+
	bne.s	.copy

	move.b	#$ff,(a0)
	move.l	#load_buf,a5
* replace spaces with 0s
	move.l	a5,a0

.zeds:
	move.b	(a0)+,d0
	beq.s	.dun

	cmp.b	#" ",d0
	bne.s	.zeds

	clr.b	-1(a0)
	bra.s	.zeds

.not_input:
	subq.w	#1,d0
	bne.s	.not_found2

* @found was the parameter!
	lea	found_txt(pc),a5
	bra	.do_wild

.not_found2:
* @input was the parameter!
	lea	input_txt(pc),a5
	bra	.do_wild


.dun:
* it must be a wildcard!
wildcard:
	move.b	#"n",full_path
	move.l	a5,wild_addr
.get_end:
	tst.b	(a5)+
	bne.s	.get_end

	move.l	a5,a0
	bsr	get_next_param
	move.l	a0,a4

	tst.w	d0
	bne	.no_flags

* found a flag
	move.l	#wild_params,a1
	bsr	get_param
	tst.w	d0
	bpl.s	.param_ok

	print	inv_param
	rts

.param_ok:
* got a parameter!
	move.b	#"y",full_path

.no_flags:
* now do the stuff...

* first, we have to go into the directory we want...
	move.l	wild_addr,a0
	move.l	#wild_path,a1
	bsr	sep_path

* do we have a drive?
	move.l	#wild_path,a5
	cmp.b	#":",1(a5)
	bne.s	.no_drive

	moveq	#0,d0
	move.b	(a5),d0
	jsr	to_lower
	sub.b	#"a",d0
	bsr	set_drive
	addq.l	#2,a5

.no_drive:
	bsr	keep_path2

	move.l	a5,a0
	bsr	change_dir	; into correct path on drive to copy from
	tst.w	d0
	beq.s	.ok

	print	no_such_dir
	rts

.ok:
	move.l	wild_addr,a0
	bsr	get_card

	cmp.b	#"y",full_path
	bne	just_this_dir

* now in correct directory for search to begin
	move.l	#folder_list,a6
	clr.b	(a6)		; haven't gone into any yet...

dir_search:
* search for DIRs only!
	move.l	#all_star,a0
	bsr	search_folder_only

	tst.w	d0
	bne	go_back_one

* found a directory!!!!
	move.l	#dta+f_name,a0
	cmp.b	#".",(a0)
	bne	.not_dot

* it's the DOT folder!!!
	bsr	search_next_folder
	bsr	search_next_folder
	tst.w	d0
	bne	go_back_one

.not_dot:
* got a folder.
* have I been here before?
	moveq	#0,d7
	move.b	(a6),d7

.get_folder:
	tst.w	d7
	beq	got_folder

* yup! go past any folder's I've had dealings with in the past...

	bsr	search_next_folder
	tst.w	d0
	bne	go_back_one

	subq.w	#1,d7
	bra.s	.get_folder

got_folder:
* got a NEW folder!
	addq.b	#1,(a6)+	; 1 more done this time
	clr.b	(a6)		; none done in THIS folder

	move.l	#dta+f_name,a0
	bsr	change_dir	; we've just gone into next folder!
	bra	dir_search	; search for more folders...


go_back_one:
* no more folders to go into.
* am I back at the beginning of the list?
	cmp.l	#folder_list-1,a6
	bne.s	.not_1st
* yup! stop!

	bsr	rest_path2
	rts

.not_1st:
* before we go back one, we have to copy everything from this DIR to the other drive...
	bsr	just_this

* now go back a directory...
	lea	two_dots(pc),a0
	bsr	change_dir

* go to previous folder count
	subq.l	#1,a6

* and search for more folders..
	bra	dir_search


two_dots:
	dc.b	"..",0
	even



just_this_dir:
* just copy files in current directory to current ramdisk directory...
	bsr	just_this
	bsr	rest_path2
	rts

just_this:
* first, ensure directory exists on RAMDISK
	bsr	create_c_dirs

	bsr	get_drive
	move.w	d0,-(a7)

	print	copying

	bsr	get_full_path
	print	temp_path
	print	card

	print	to

	move.w	copy_to_drive,d0
	bsr	set_drive
	bsr	get_full_path

	print	temp_path
	print	new_line

	move.w	(a7)+,d0
	bsr	set_drive


* read-ahead
	move.l	#card,a0
	bsr	search_file
	tst.w	d0
	beq.s	.while

* first file not found!
	print	none_found

* WHILE file has been found
.while:
	tst.w	d0
	bne.s	.end_while

	bsr	copy_a_file

	bsr	search_next
	bra	.while

.end_while:
	rts

get_full_path:
* get full path (including drive:) to temp_path
	pea	(a5)
	move.l	#temp_path,a5

	bsr	get_drive
	add.b	#"A",d0
	move.b	d0,(a5)+
	move.b	#":",(a5)+
	clr.b	(a5)

	move.l	a5,a0
	bsr	get_dir

	move.l	a5,a0
	bsr	slash_on_end

	move.l	#temp_path,a0
	move.l	(a7)+,a5
	rts


copy_a_file:
* copy filename found in dta
* to the ramdisk (paths already set)

	print	spaces
copy_no_space:
	print	dta+f_name
	print	space2

* now do checks to see if we should copy it or not...
	bsr	check_alls
	tst.w	d0
	bne.s	.nono

	bsr	check_this_disk
	tst.w	d0
	beq.s	.ok
.nono:
	print	excluded

	rts

.ok:
	move.l	#dta+f_name,a0
	bsr	open_file

	move.w	d7,d6		; keep handle in d6...
	bpl.s	.open_ok

* error opening file!
	print	file_open_error
	rts


.open_ok:
* create the file on the ramdisk
	bsr	get_drive
	move.w	d0,-(a7)	; remember source drive

	move.w	copy_to_drive,d0
	bsr	set_drive	; set to RAMDISK

	move.l	#dta+f_name,a0
	bsr	create_file	; create file

	move.w	(a7)+,d0
	bsr	set_drive	; back to source drive

	tst.w	d7
	bpl.s	.create_ok

* create went wrong!
	print	create_file_error

	move.w	d6,d7
	bsr	close_file
	rts


.create_ok:
* read as much of the file as possible into memory...
	moveq	#-1,d0
	jsr	res_mem

	move.l	d0,d5		; d5 holds amount of memory available
	jsr	res_mem
	move.l	d0,a5		; a5 holds addr of memory reserved...


	move.l	dta+f_len,d4	; d4 holds length of file

.read_loop:
	move.l	a5,a0		; into memory
	move.l	d5,d0		; all of memory
	exg	d6,d7
	bsr	read_file	; read in as much as possible
	move.l	d0,-(a7)	; keep length read

* now save out file to ramdisk
	move.l	a5,a0
* length already in d0
	exg	d6,d7
	bsr	write_file

	tst.l	d0
	bmi	.write_error

	move.l	(a7),d1
	sub.l	d1,d0
	bne	.write_error

	move.l	(a7)+,d0
* how much was read in?
	sub.l	d0,d4
* if d4 = 0 then all of file was read in
	bne	.read_loop

* all of file now done!
.finished_copy:
	bsr	close_file
	move.w	d6,d7
	bsr	close_file

	move.l	a5,d0
	bsr	rel_mem
	print	new_line
	rts

.write_error:
	addq.l	#4,a7
	print	write_error
	bra	.finished_copy


check_this_disk:
	move.l	#exclude_temp,a3
	move.l	#dta+f_name,a1
	bra	do_check

check_alls:
* check to see if this wildcard is excluded in the ALL section
	cmp.b	#"y",all_flag
	bne.s	not_found

* get the first block
	move.l	#exclude_all,a3
	move.l	#dta+f_name,a1

do_check:
.new_block:
	move.w	(a3)+,d0
	
	move.w	#wilds_per_block,d1
	sub.w	d0,d1		; d1 holds no of wildcards in this block!
	lea	4(a3),a2	; get 1st wildcard address

.block_loop:
	tst.w	d1
	beq	.end_of_block

	move.l	a2,a0
	bsr	compare_wilds	; check to see if wildcards match...
	tst.w	d0
	beq.s	.notfound

* match found! it's excluded!
	moveq	#-1,d0
	rts

.notfound:
* wildcards did not match!
* try next wildcard
	lea	14(a2),a2
	subq.w	#1,d1
	bra.s	.block_loop

.end_of_block:
* end of this block!  another?
	move.l	(a3),d0
	beq	not_found
	move.l	d0,a3
	bra	.new_block

not_found:
	moveq	#0,d0
	rts


compare_wilds:
* compare wildcard in a0 and filename in a1
* to see if they match.
* returns:
*	a0 and a1 as sent
*	d0 = -1 if match
*	   = 0 if no match

	movem.l	a0-1/d1,-(a7)

cardloop:
	move.b	(a0)+,d0
	beq	w_end1

	jsr	to_lower

	move.b	(a1)+,d1
	beq	w_end2

	move.w	d0,d2
	move.w	d1,d0
	jsr	to_lower
	move.w	d0,d1
	move.w	d2,d0


* neither has ended!
* is the wildcard a special char?
	cmp.b	#"?",d0
	beq.s	w_quest

	cmp.b	#"*",d0
	beq.s	w_star

	cmp.b	#".",d0
	beq.s	w_dot

* not a special wildcard.  So they must match!
	sub.b	d0,d1
	beq.s	cardloop

* no match!
nomatch:
	moveq	#0,d0
	movem.l	(a7)+,a0-1/d1
	rts

match:
	moveq	#-1,d0
	movem.l	(a7)+,a0-1/d1
	rts

w_end1:
* wildcard has ended!
* has filename?
	tst.b	(a1)
	beq	match		; match if it has
	bra	nomatch		; else no match

w_end2:
* filename has ended!
* still valid if:
*
* wildcard has "*.*" next
* wildcard has "*",0 next
* wildcard has ".*" next

	cmp.b	#"*",d0
	bne	.dot?

* it's a star!
* must be a 0 or a dot now!
	move.b	(a0)+,d0
	beq	match

	sub.b	#".",d0
	bne	nomatch

.zedstar:
* and now, must be 0 or *
	move.b	(a0)+,d0
	beq	match

	sub.b	#"*",d0
	beq	match
	bra	nomatch

.dot?:
* is it a dot?
	sub.b	#".",d0
	bne	nomatch

* must now be a 0 or a *
	bra	.zedstar

w_quest:
* doesn't matter what's in d1 (unless it's a dot)
	cmp.b	#".",d1
	bne	cardloop
	bra	nomatch


w_dot:
* wildcard has a dot! filename MUST also have a dot!
	cmp.b	#".",d1
	beq	extensions
	bra	nomatch

w_star:
* it's a star in the wildcard! ignore rest of filename up to dot
* or end of filename

.getdot:
	cmp.b	#".",d1
	beq.s	.gotdot

	move.b	(a1)+,d1
	beq.s	.starend
	bra.s	.getdot

.starend:
* filename has ended.
* next wildcard char MUST be 0
	tst.b	(a0)
	bne	nomatch
	bra	match

.gotdot:
* got the dot in the filename!
* now get it in the wildcard
.getdot2:
	move.b	(a0)+,d0
	beq	nomatch		; doesn't match if filename has a dot & card doesn't

	cmp.b	#".",d0
	bne.s	.getdot2

* got both the dots!
extensions:
	bra	cardloop



get_card:
* path & card in a0
* get just the wildcard out from a possible pathname
	move.l	#card,a1

	move.l	a0,a2
* get end of path & card
.end:
	tst.b	(a0)+
	bne.s	.end

* now scan back for a "\" or start
.get:
	move.b	-(a0),d0
	cmp.b	#"\",d0
	beq.s	.slash

	cmp.l	a0,a2
	bne.s	.get

.start:
	move.b	(a0)+,(a1)+
	bne.s	.start
	rts

.slash:
	addq.l	#1,a0
	bra.s	.start




create_c_dirs:
* we have a pathname on source drive
* which we are to use on ramdisk
* but... do those folders exist yet?
* if not, create them!

	move.l	#temp_path,a0
	bsr	get_dir		; get directory on source drive

* store current drive & path
	bsr	keep_path

	pea	(a5)
	move.l	#temp_path,a0
	bsr	slash_on_end

* now take each folder name in turn and make sure it exists on RAMDISK
	move.w	copy_to_drive,d0
	bsr	set_drive

* go to ROOT directory
	move.l	#root,a0
	bsr	change_dir

* now go through list
* WHILE not at end of list
	move.l	#temp_path,a5
	addq.l	#1,a5		; go past initial "\"
.while:
	tst.b	(a5)
	beq.s	.end_while

	bsr	check_dir
	bra.s	.while

.end_while:
	move.l	(a7)+,a5
* restore drive & path
	bsr	rest_path
	rts


slash_on_end:
* get end of path
.get_zed:
	tst.b	(a0)+
	bne.s	.get_zed
	move.b	#"\",-1(a0)
	clr.b	(a0)
	rts


check_dir:
* check dir starting at a5 exists.  If not, make it!
* but first, I need to isolate the dirname

	move.l	a5,a0
.get_end:
	cmp.b	#"\",(a0)+
	bne.s	.get_end

	clr.b	-1(a0)

	move.l	a5,a0
	bsr	change_dir
	tst.w	d0
	beq	.change_ok

* didn't change into the dir!
	move.l	a5,a0
	bsr	make_dir

	move.l	a5,a0
	bsr	change_dir

.change_ok:
* now go past dir we've just done
.past:
	tst.b	(a5)+
	bne.s	.past
	rts



ram_drive:
	move.w	copy_to_drive,d0
	bsr	set_drive
	rts



sep_path:
* a0 = wildcard
* a1 = just pathname

	move.l	a1,a2
* copy whole of wildcard
.copy:
	move.b	(a0)+,(a1)+
	bne.s	.copy

* now search back to find either slash or start of wildcard
.slash:
	move.b	-(a1),d0
	cmp.b	#"\",d0
	beq.s	.got_slash

	cmp.l	a1,a2
	bne.s	.slash

* no slash!
	clr.b	(a1)+
	clr.b	(a1)+
	rts

.got_slash:
	clr.b	1(a1)
	rts


wild_params:
	dc.b	"/f",0
	dc.b	"/full",0
	dc.b	$ff
	even



load_params:
found_txt:	dc.b	"found",0
input_txt:	dc.b	"input",0
	dc.b	"@found",0
	dc.b	"@input",0
	dc.b	$ff

	even


exclude:
* exclude wildcard files
* possible flag /ALL
	move.l	a4,a0
	bsr	get_next_param		; get wildcard
	move.l	a0,a4
	tst.w	d0
	beq.s	.ok

	print	exclude_what?
	rts

.ok:
	move.b	#"n",temp_all		; assume no "/all" flag

	bsr	past_param
	bsr	get_next_param		; anything else?
	tst.w	d0
	bmi.s	.ok2			; no

* something else!  could it be "/all"?
	move.l	#exclude_flags,a1
	bsr	get_param
	tst.w	d0
	bpl.s	.valid

 	print	inval_x_param
	rts

.valid:
* valid exclude parameter!
	move.b	#"y",temp_all
.ok2:
* store wildcard in ALL section
	bsr	get_new_x_all	; get addr for new wildcard
	bra	store_rej


not_flagged:
* store wildcard in TEMP section
	bsr	get_new_x_temp

store_rej:
	pea	(a4)
	subq.w	#1,(a1)
.copy:
	move.b	(a4)+,(a0)+
	bne.s	.copy

	print	excluding
	move.l	(a7)+,a0
	jsr	print_mes

* all of them?
	cmp.b	#"y",temp_all
	bne.s	.nono

	print	from_all
.nono:
	print	new_line
	rts

excluding:
	dc.b	27,"p EXCLUDING ",27,"q ",0
from_all:
	dc.b	" from ALL disks",0

exclude_flags:	
	dc.b	"/all",0
	dc.b	$ff
	even


get_new_x_temp:
	pea	(a6)
	move.l	#exclude_temp,a6
	bra.s	exclude_rej

get_new_x_all:
* get the next storage address for ALL excludes...
* returns space addr in a1 and start of block (must be decreased) in a1
	pea	(a6)

	move.l	#exclude_all,a6
exclude_rej:
.test_block:
	move.l	a6,a1
	tst.w	(a6)+
	bne	.more_spaces	; branch if spaces in this block

* no more spaces in this block!
* is there a pointer?
	move.l	(a6),d0
	beq	.no_pointer

	move.l	d0,a6
	bra.s	.test_block

.no_pointer:
* no pointer!
* create a new block!
	move.l	#ram_per_block,d0
	jsr	res_mem
	tst.l	d0
	bpl.s	.ok
	rts

.ok:
	move.l	d0,(a6)
	move.l	d0,a6
	move.l	d0,a1
	move.w	#wilds_per_block,(a6)+
	clr.l	(a6)

.more_spaces:
* there are spaces in this block! let's find the next available one...
	moveq	#0,d0
	move.w	-2(a6),d0	; get number remaining
	moveq	#wilds_per_block,d1
	sub.w	d0,d1		; d1 holds free space number
	addq.l	#4,a6

	mulu	#14,d1
	add.l	d1,a6
	move.l	a6,a0
	move.l	(a7)+,a6
	rts



comp_string:
* compare strings in a0 and a1 (both NULL terminated)
* returns:
*	d0 = 0 if same
*	d0 = -1 if different

	moveq	#0,d0
.test:
	tst.b	(a0)
	beq.s	.end1
	tst.b	(a1)
	beq.s	.different

	cmpm.b	(a0)+,(a1)+
	beq.s	.test
.different:
	moveq	#-1,d0
	rts

.end1:
	tst.b	(a1)
	bne.s	.different
	rts


ramdisk:
* Set up the RAMDISK!!!
* params:
*	size in k
*	drive letter
* possible options:
*	/reset

* do I exist already?
	cmp.b	#"y",ramdisk_exists
	bne.s	.no

	print	ram_already
	rts

.no:
	move.l	a4,a0
	bsr	get_next_param
	tst.l	d0
	beq.s	.ok
	print	need_size_lett
	rts

.ok:
* here's the size!
* interpret the number...
	bsr	asc_to_bin
	move.l	a0,a4

	tst.l	d1
	beq.s	.ok2
	print	invalid_num
	rts

.ok2:
	move.l	d0,ram_size

	move.l	a4,a0
	bsr	get_next_param
	move.l	a0,a4
	tst.l	d0
	beq.s	.ok3

	print	no_letter
	rts

.ok3:
	move.b	(a4)+,d0
	jsr	to_lower
	cmp.b	#"a",d0
	blt.s	.inv

	cmp.b	#"p",d0
	ble.s	.val

.inv:
	print	no_letter
	rts

.val:
* drive letter valid!
	move.b	d0,drive_letter
	sub.b	#"a",d0
	move.w	d0,drive_no
	move.w	d0,copy_to_drive

* is there a flag?
	move.l	a4,a0
	bsr	get_next_param
	tst.l	d0
	bne.s	.no_flag

* there is A flag... what is it?
	move.l	#ramdisk_flags,a1
	bsr	get_param

	tst.w	d0
	bpl.s	.valid_param

	print	inv_ramdisk_param
	rts

.valid_param:
* must be "/reset"!
	move.b	#"y",reset_proof

* install the disk drive!
* how much memory?
.no_flag:
	move.l	ram_size,d0
	move.w	d0,bpb_size
	addq.w	#2,bpb_size
	add.l	#11,d0
* times 1024
	moveq	#10,d1
	lsl.l	d1,d0

	move.l	d0,total_size

	jsr	res_mem
	tst.l	d0
	bpl.s	.ok4

* not enough memory
	print	mem_err
	rts

.ok4:
* clear the ramdisk memory
	move.l	d0,ramdisk_addr
	move.l	d0,a0
	move.l	#(10*1024)/4,d0	; clear bootsec, FATS & dir
.clear:
	clr.l	(a0)+
	subq.l	#1,d0
	bne.s	.clear


* set up the RAMDISK routines
	pea	ram_disk_on(pc)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7

	move.b	#"y",ramdisk_exists


	print	ramdisk_ok
	move.l	ram_size,d0
	bsr	num_to_asc
	jsr	print_mes
	print	ram_size_ok

	move.b	drive_letter,d0
	sub.b	#"a",d0
	add.b	#"A",d0
	move.b	d0,temp_char
	print	temp_char
	print	new_line
	rts

ramdisk_off:
	cmp.b	#"y",ramdisk_exists
	bne.s	.no
	pea	ram_disk_off(pc)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7
.no:
	rts

*bootsec:
	dc.b	0,2
	dc.b	2
	dc.b	1,0
	dc.b	2
	dc.b	112,0
secs:	dc.b	2,0
	dc.b	0
	dc.b	5,0
	dc.b	9,0
	dc.b	1,0
	dc.b	0
*bootsec_len	equ *-bootsec


ram_disk_off:
	moveq	#0,d0
	lea	drive_no(pc),a0
	move.w	(a0),d0

	move.l	drv_bits.w,d1
	bclr	d0,d1
	move.l	d1,drv_bits.w

	lea	hdv(pc),a0
	move.l	(a0)+,hdv_bpb.w
	move.l	(a0)+,hdv_med.w
	move.l	(a0)+,hdv_rw.w
	move.l	(a0)+,res_val.w
	move.l	(a0)+,res_vec.w

* restore HELP and TRAP13 vectors...
	move.l	old_trap13+2,d0
	cmp.l	#$12345678,d0
	beq.s	.no

	move.l	d0,trap13.w
.no:
	move.l	old_help,d0
	cmp.l	#$12345678,d0
	beq.s	.no2

	move.l	d0,help_vec.w
.no2:

	rts


cls:
	print	clr_scrn
	rts

inp_echo:
	move.w	#1,-(a7)
	trap	#1
	addq.l	#2,a7

	move.w	d0,-(a7)
	print	new_line
	move.w	(a7)+,d0
	rts


*******************************************************************
**** FULL VERSION ONLY ROUTINES ***********************************
*******************************************************************

	IFND	demo
all:
* turn ALL on or off!
	move.l	a4,a0
	bsr	get_next_param
	move.l	a0,a4
	tst.w	d0
	beq.s	.ok

	print	all_what?
	rts

.ok:
	move.l	#on,a1
	bsr	comp_string
	tst.w	d0
	beq	.turn_on

	move.l	#off,a1
	move.l	a4,a0
	bsr	comp_string
	tst.w	d0
	beq	.turn_off

	print	all_what?
	rts

.turn_on:
	move.b	#"y",all_flag
	rts

.turn_off:
	move.b	#"n",all_flag
	rts

boot_from:
	move.l	a4,a0
	bsr	get_next_param
	tst.w	d0
	bpl.s	.ok

	print	boot_where?
	rts

.ok:
	moveq	#0,d0
	move.b	(a0),d0
	jsr	to_lower

	cmp.b	#"a",d0
	blt.s	.invalid

	cmp.b	#"p",d0
	ble.s	.valid

.invalid:
	print	invalid_drive
	rts

.valid:
* set the drive to boot from...
	sub.b	#"a",d0
	move.w	d0,d7
	jsr	super_on

	move.w	d7,boot_dev.w
	jsr	super_off

	print	booting_from
	add.b	#"A",d7
	move.b	d7,temp_char
	print	temp_char
	print	new_line
	rts

cd:
* change directory / disk drive
	move.l	a4,a0
	bsr	get_next_param
	tst.w	d0
	beq.s	.ok

	print	no_cd
	rts

.ok:
* got the path at a0!
	move.l	a0,a4

* is there a disk drive specified?
	move.b	1(a0),d0
	cmp.b	#":",d0
	bne	.no_drive
* change disk drive
	moveq	#0,d0
	move.b	(a0),d0
	jsr	to_lower

	sub.b	#"a",d0
	bsr	set_drive
	tst.w	d0
	bpl.s	.ok2

	print	drive_error
	rts

.ok2:
	addq.l	#2,a4
.no_drive:
* set the pathname now!
	move.l	a4,a0
	bsr	change_dir
	tst.l	d0
	bpl.s	.ok3

	print	path_error
	rts
.ok3:
	print	path_changed
	bsr	what_is_path
	jsr	print_mes
	print	new_line
	rts

clear_keys:
* clear the keyboard buffer

.test:
	move.w	#$ff,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq.l	#4,a7

	tst.w	d0
	bne.s	.test
	rts

copy_to:
	move.l	a4,a0
	bsr	get_next_param
	tst.w	d0
	bpl.s	.ok

	print	copy_where?
	rts

.ok:
	moveq	#0,d0
	move.b	(a0),d0
	jsr	to_lower

	cmp.b	#"a",d0
	blt.s	.invalid

	cmp.b	#"p",d0
	ble.s	.valid

.invalid:
	print	invalid_drive_copy
	rts

.valid:
* set the drive to copy to...
	sub.b	#"a",d0
	move.w	d0,copy_to_drive
	add.b	#"A",d0
	move.b	d0,temp_char

	print	copying_to
	print	temp_char
	print	new_line
	rts

dir:
* show directory of disk...

* assume "*.*"...
	move.l	#dir_card,a0
	move.b	#"*",(a0)+
	move.b	#".",(a0)+
	move.b	#"*",(a0)+
	clr.b	(a0)

* wildcard specified?
	move.l	a4,a0
	bsr	get_next_param
	tst.w	d0
	bne.s	.none

* wildcard given...
	move.l	#dir_card,a1
.copy:
	move.b	(a0)+,(a1)+
	bne.s	.copy
.none:

	print	dir_of
	bsr	get_full_path
	jsr	print_mes
	print	dir_card
	print	new_line

* count no of files in directory...
	moveq	#0,d7

	move.l	#dir_card,a0
	bsr	search_folder
	tst.w	d0
	beq.s	.files

	print	no_files_found
	rts

.files:
* found A file!
* count the rest!
	bsr	search_next
	addq.w	#1,d7
	tst.w	d0
	beq.s	.files

* d7 = no of files found.
* get memory to read files into

d_len	equ	20

	move.l	d7,d0
	mulu	#d_len,d0
	jsr	res_mem

	tst.l	d0
	bpl.s	.ok

	print	out_of_mem
	rts

.ok:
	move.l	d0,a6		; keep addr of memory
	move.l	d0,a5

	move.l	#dir_card,a0
	bsr	search_folder

.dir_loop2:
	move.l	a5,a4
	move.l	dta+f_len,(a4)+
	move.b	dta+f_attrib,(a4)+
	move.l	#dta+f_name,a0

.copy2:
	move.b	(a0)+,(a4)+
	bne.s	.copy2

	lea	d_len(a5),a5
	bsr	search_next
	tst.w	d0
	beq	.dir_loop2

* got all filenames!
* sort into order by:
* 1 - folder / filename
* 2 - alphabetical

* uses bubble sort.

	cmp.w	#1,d7
	beq	sorted		; sorted if 1 file only!

bubble:
	move.w	d7,d6
	subq.w	#1,d6

	moveq	#0,d5		; change flag
	move.l	a6,a5		; 1st filename addr

bubble_loop:
* is the 1st file a folder?
	move.b	4(a5),d0
	and.b	#$10,d0
	bne.s	.fold_1st	; if so, jump to folder testing

* no! is the second?
	move.b	d_len+4(a5),d0
	and.b	#$10,d0
	bne.s	swap_em		; yes! so put folder on top

* got 2 files!
	bra.s	.fold_test	; go on to test filenames


.fold_1st:
* is the 2nd a folder?
	move.b	d_len+4(a5),d0
	and.b	#$10,d0
	beq	no_swap		; don't swap if folder is at top

.fold_test:
* not swapping by attribute...
* how about filename?
	lea	5(a5),a3
	lea	d_len(a3),a4

.test:
	move.b	(a3)+,d0
	beq.s	no_swap		; don't swap if 1st is smaller

	move.b	(a4)+,d1
	beq	swap_em		; swap if 2nd name smaller

	sub.b	d0,d1
	beq.s	.test		; keep going until d0 > d1
	bpl.s	no_swap
	
swap_em:
	addq.w	#1,d5

	movem.l	(a5),d0-4
	movem.l	d_len(a5),a0-4

	movem.l	a0-4,(a5)
	movem.l	d0-4,d_len(a5)

no_swap:
* go to next name
	lea	d_len(a5),a5

* any more to do?
	sub.w	#1,d6
	bne	bubble_loop

* any changes?
	tst.w	d5
	bne	bubble

* no!
sorted:

	move.l	a6,a5
	move.l	d7,d6
	moveq	#20,d5		; MORE counter

print_dir:
* print 'em!
* is this a folder?
	move.l	#space2,a0

	move.b	4(a5),d0
	and.b	#$10,d0
	beq.s	.nof

* yup! a folder!
	move.w	#7,-(a7)
	move.w	#5,-(a7)
	move.w	#3,-(a7)
	trap	#13
	addq.l	#6,a7

	move.l	#space1,a0
.nof
	jsr	print_mes

* print filename
	lea	5(a5),a0
	jsr	print_mes

* how many chars were there in the filename?
	moveq	#0,d0
	lea	5(a5),a0
.count:
	addq.w	#1,d0
	tst.b	(a0)+
	bne.s	.count

* add that many to the start of the spaces...
	move.l	#space17,a0
	add.l	d0,a0
	jsr	print_mes

* now print the program length...
	move.l	(a5),d0
	bsr	num_to_asc
	jsr	print_mes

	print	new_line

	lea	d_len(a5),a5

	subq.w	#1,d5
	bne.s	.nomore

* pause to scroll!
	print	more
	bsr	inp
	print	new_line
	moveq	#20,d5

.nomore:

	subq.w	#1,d6
	bne	print_dir

* release memory
	move.l	a6,d0
	bsr	rel_mem

* show number of files
	move.l	d7,d0
	bsr	num_to_asc
	jsr	print_mes
	print	files_found

	rts

files_found:	dc.b	" files found.",10,13,10,0
	even



if:
* IF test.
* if false, then goto either "else" or "end-if"
* if true, then execute until "else" or "end-if" found

	cmp.l	#"file",input_mode
	beq.s	.ok

	print	if_file_only
	rts

.ok:
	move.l	a4,a0
	bsr	get_next_param
	bsr	evaluate

	tst.w	d0
	beq	false_if

true_if:
* true! start executing next instructions...
	move.l	loop_ptr,a0


* I'm an IF
	move.l	#"IF  ",(a0)+

* dummy LWs
	clr.l	(a0)+
	clr.l	(a0)+
	move.l	a0,loop_ptr
	rts

false_if:
* false! find "end-if" or "else"!
* but skip any IFs we find along the way!

	clr.w	while_count

.get_end_if:
	cmp.b	#"n",eof
	bne	.end_file

	bsr	get_next_line
* is it an "if", "else" or "end-if" command?
	move.l	#if_txt,a1
	move.l	#if_routs,a2
	bsr	do_command

	tst.w	while_count
	bpl.s	.get_end_if
	rts

.end_file:
* end of file!
	print	no_end_if
	rts

if_txt:
	dc.b	"if",0
	dc.b	"else",0
	dc.b	"end-if",0
	dc.b	0
	even

if_routs:
	dc.l	do_if
	dc.l	do_else
	dc.l	do_end_if

do_if:
	addq.w	#1,while_count
	rts

do_end_if:
	subq.w	#1,while_count
	rts

do_else:
* If this is the IF I was working on, then normal service is resumed.
* if it is a different IF, then ignore it!
	tst.w	while_count
	bne	.not_mine

* MY else!
	subq.w	#1,while_count
	bra	true_if

.not_mine:
* ignore the else!
	rts


else:
* I have found an "else" command!
* am I doing an IF?

	move.l	#loop_ptr,a0
	move.l	(a0),a1

	lea	-12(a1),a1
	move.l	(a1),d0
	cmp.l	#"IF  ",d0
	beq.s	.yes_if

* not doing an IF!
	print	else_no_if
	rts

.yes_if:
* yup! I am doing an IF!
* but this is the ELSE!
* so skip to the end!
	clr.w	while_count

.get_end_if:
	cmp.b	#"n",eof
	bne	.end_file

	bsr	get_next_line
* is it an "if" or "end-if" command?
	move.l	#else_txt,a1
	move.l	#else_routs,a2
	bsr	do_command

	tst.w	while_count
	bpl.s	.get_end_if
	rts

.end_file:
* end of file!
	print	no_end_if
	rts

else_txt:
	dc.b	"if",0
	dc.b	"end-if",0
	dc.b	0
	even

else_routs:
	dc.l	do_if2
	dc.l	do_end_if2

do_if2:
* found another IF
	addq.w	#1,while_count
	rts

do_end_if2:
* found an END-IF
	subq.w	#1,while_count
	rts

end_if:
* I have reached the end of an IF command.
* was I doing one?
	move.l	#loop_ptr,a0
	move.l	(a0),a1
	lea	-12(a1),a1
	move.l	(a1),d0
	cmp.l	#"IF  ",d0
	beq.s	.yesif

	print	end_no_if
	rts

.yesif:
* was doing an IF, but now finished!
	move.l	a1,(a0)
	rts


while:
* WHILE loop
* test before loop
* if false, find relevant end-while
* if true, store current pos in file & continue...

	cmp.l	#"file",input_mode
	beq.s	.ok

	print	loop_file_only
	rts

.ok:
	move.l	a4,a0
	bsr	get_next_param
	bsr	evaluate

	tst.w	d0
	beq	.false

* true! do the WHILE loop
* but first, store the loop details...
	move.l	loop_ptr,a0


* I'm a WHILE loop
	move.l	#"WHIL",(a0)+

* store text file position
* as it was at the START of the WHILE loop!
	move.l	last_addr,(a0)+
	move.l	last_len,(a0)+
	move.l	a0,loop_ptr

	rts

.false:
* false! find end-while!
* but skip any WHILE loops we find along the way!

	clr.w	while_count

.get_end_while:
	cmp.b	#"n",eof
	bne	.end_file

	bsr	get_next_line
* is it a while or end-while command?
	move.l	#while_txt,a1
	move.l	#while_routs,a2
	bsr	do_command

	tst.w	while_count
	bpl.s	.get_end_while
	rts

.end_file:
* end of file!
	print	no_end_while
	rts

while_txt:
	dc.b	"while",0
	dc.b	"end-while",0
	dc.b	"wend",0
	dc.b	0
	even

while_routs:
	dc.l	do_while
	dc.l	do_end_while
	dc.l	do_end_while

do_while:
* another WHILE loop has been perpetrated!
	addq.w	#1,while_count
	rts

do_end_while:
	subq.w	#1,while_count
	rts

end_while:
* WHILE loop has ended!
* let's transfer command back to the start of the WHILE loop
* no need for any tests of conditions!
* UNTIL part of REPEAT loop!
	cmp.l	#"file",input_mode
	beq.s	.ok

	print	loop_file_only
	rts

.ok:
	move.l	loop_ptr,a0
	move.l	-12(a0),d0
	sub.l	#"WHIL",d0
	beq.s	.ok2

	print	not_a_while
	rts
.ok2:
* put pointer back to start of WHILE loop!
	lea	-12(a0),a0
	movem.l	(a0),d0-2
	move.l	a0,loop_ptr

	move.l	d1,process_addr
	move.l	d2,process_len
	move.b	#"n",eof
	rts


do_command:
* a1 = list of valid commands
* a2 = list of routines

	moveq	#0,d2

.command_loop:
	move.l	#command_line,a0
	bsr	get_next_param

.test:
	move.b	(a0)+,d0
	beq.s	.fin1		; input has ended - has command?

	move.b	(a1)+,d1
	beq.s	.not_this	; if command ends before input, invalid

	cmp.b	d0,d1
	beq.s	.test

* get next valid command
.nnn:
	tst.b	(a1)+
	bne.s	.nnn

.not_this:
	addq.w	#1,d2		; go to next one
	tst.b	(a1)
	bne.s	.command_loop

* no valid commands!
	rts

.fin1:
* if command has also finished, then it's found!
	tst.b	(a1)
	bne	.nnn

* valid!
	lsl.w	#2,d2
	add.l	d2,a2
	move.l	(a2),a2
	jmp	(a2)

	
repeat:
* REPEAT loop initialises...
	cmp.l	#"file",input_mode
	beq.s	.ok

	print	loop_file_only
	rts

.ok:
* simply store the data of where we are now
* for when we come to the UNTIL clause
	move.l	loop_ptr,a0


* I'm a REPEAT loop
	move.l	#"REPE",(a0)+

* store text file position
	move.l	process_addr,(a0)+
	move.l	process_len,(a0)+
	move.l	a0,loop_ptr

	rts

until:
* UNTIL part of REPEAT loop!
	cmp.l	#"file",input_mode
	beq.s	.ok

	print	loop_file_only
	rts

.ok:

* evaluate expression
* if it's TRUE, then we go all the way back to where we were
* if it's FALSE, we just continue.
	move.l	loop_ptr,a0
	move.l	-12(a0),d0
	sub.l	#"REPE",d0
	beq.s	.ok2

	print	not_a_repeat
	rts


.ok2:
	move.l	a4,a0
	bsr	get_next_param
	bsr	evaluate

	tst.w	d0
	beq	.false

* true! end of repeat loop!
	sub.l	#12,loop_ptr
	rts

.false:
* go back to where we were!
	move.l	loop_ptr,a0

	lea	-12(a0),a0
	movem.l	(a0),d0-2

	move.l	d1,process_addr
	move.l	d2,process_len
	move.b	#"n",eof
	rts


evaluate:
* enters with a0 pointing to expression.
	move.l	a0,a6
	move.l	#exp_buffer,a5

	bsr	translate
	tst.w	d0
	bpl.s	.ok
* error occurred!
	print	eval_error
	rts

.ok:
* it's been translated...
* so now we need to go through it, and break it down
* until we are left with just 1 byte!
* if no changes are made and we still have >1 byte
* then there is an error!

	moveq	#-1,d7

.loop:
	bsr	break_down

	cmp.w	#1,d0
	beq.s	.dun

	move.w	d7,d6
	move.w	d0,d7

	cmp.w	d6,d7
	bne.s	.loop

* error!
	moveq	#-1,d0
	rts

.dun:
	moveq	#0,d0
	move.b	exp_buffer,d0
	rts


break_down:
* break down the expression...

	move.l	#exp_buffer,a0
	move.l	a0,a1
	moveq	#0,d0

break_loop:
	move.b	(a0)+,d1	; get byte from expression...
* where do I go to deal with it?
	move.l	#exp_list,a2
	moveq	#0,d3

.getit:
	move.b	(a2)+,d2
	sub.b	d1,d2
	beq.s	.gotit

	addq.w	#1,d3
	bra.s	.getit

.gotit:
	lsl.w	#2,d3
	move.l	#exp_rout,a2
	add.l	d3,a2
	move.l	(a2),a2
	jmp	(a2)

exp_list:
	dc.b	"()&+!",0,1,$ff

exp_rout:
	dc.l	o_brack
	dc.l	c_brack
	dc.l	aand
	dc.l	oor
	dc.l	nnot
	dc.l	false
	dc.l	true
	dc.l	end_exp

end_exp:
	move.b	#$ff,(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	clr.b	(a1)+
	rts


false:
true:
	move.b	-1(a0),(a1)+
	addq.w	#1,d0
	bra	break_loop


o_brack:
* if we have (?) then replace with just ?
	move.b	1(a0),d3
	cmp.b	#")",d3
	bne.s	.no

	move.b	(a0),(a1)+
	addq.l	#2,a0
	addq.w	#1,d0
.no:
	bra	break_loop

c_brack:
	move.b	#")",(a1)+
	addq.w	#1,d0
	bra	break_loop

aand:
* if we have a T/F on either side, then DO THEM!
	move.b	-2(a0),d3
	move.b	(a0),d4

	bsr	both?

	tst.w	d3
	bpl.s	.yup

* not both were T/F, so just keep plodding on...
	move.b	#"&",(a1)+	; replace T/F with combined
	addq.w	#1,d0
	bra	break_loop

.yup:
	and.b	d3,d4
	subq.l	#1,a1
	move.b	d4,(a1)+
	addq.l	#1,a0
	bra	break_loop

oor:
* if we have a T/F on either side, then DO THEM!
	move.b	-2(a0),d3
	move.b	(a0),d4

	bsr	both?

	tst.w	d3
	bpl.s	.yup

* not both were T/F, so just keep plodding on...
	move.b	#"+",(a1)+
	addq.w	#1,d0
	bra	break_loop

.yup:
	or.b	d3,d4
	subq.l	#1,a1
	move.b	d4,(a1)+
	addq.l	#1,a0
	bra	break_loop

nnot:
* if T/F comes next, do it!
	move.b	(a0),d3
	tst.b	d3
	beq.s	.yup

	cmp.b	#1,d3
	beq.s	.yup

	move.b	#"!",(a1)+
	addq.w	#1,d0
	bra	break_loop

.yup:
	eor.b	#1,d3

	move.b	d3,(a1)+
	addq.w	#1,d0
	addq.l	#1,a0
	bra	break_loop


both?:
	tst.b	d3
	beq.s	.yup1

	cmp.b	#1,d3
	beq.s	.yup1

* 1st one isn't!
	moveq	#-1,d3
	rts

.yup1:
	tst.b	d4
	beq.s	.yup2

	cmp.b	#1,d4
	beq.s	.yup2

* 2nd one isn't!
	moveq	#-1,d3

.yup2:
	rts




translate:
* translate the phrases at a6 into the buffer at a5

.loop:
	bsr	get_next_phrase
	tst.w	d0
	beq.s	.end		; jump to end if no more phrases
	bpl.s	.ok
	rts			; stop if minus (error)

.ok:
	moveq	#0,d0
	jsr	(a0)		; call the correct routine
	tst.w	d0
	bpl.s	.loop
	rts			; return with error


.end:
	move.b	#$ff,(a5)
	rts

get_next_phrase:
* get the next phrase in the expression
* and return the routine's address in a0
* d0 = -1 for error (phrase not found)
*      0 for no more phrases
*      positive no for phrase found

* a6 = expression
.past_zeds:
	tst.b	(a6)+
	beq.s	.past_zeds

	subq.l	#1,a6

	cmp.b	#$ff,(a6)
	bne.s	.notend

* end! no more phrases!
	moveq	#0,d0
	rts

.notend:
	move.l	#phrase_list,a1
	moveq	#0,d0

scan_phrases:
	move.l	a6,a2

.check_phrase:
	move.b	(a2)+,d1		; get char from user's phrase
	beq.s	.end_phrase		; branch if end of phrase

	move.b	(a1)+,d2		; get char from list
	beq.s	.end_phrase_list	; branch if end of list's phrase

	sub.b	d1,d2
	beq.s	.check_phrase

.not_this_phrase:
* didn't match!
* get end of this phrase in list
.nextp:
	tst.b	(a1)+
	bne.s	.nextp

* 1 more phrase
	addq.w	#1,d0

	cmp.b	#$ff,(a1)	; am I at the end of the phrase list?
	bne	scan_phrases	; if not, check next phrase

* phrase not found
	moveq	#-1,d0
	rts

.end_phrase:
* end of user's phrase - has list phrase ended too?
	tst.b	(a1)
	bne	.not_this_phrase	; if not, jump

* list phrase ended... match!

	addq.l	#1,a2	; account for subtraction next... user's phrase is in correct position

.end_phrase_list:
* phrase in list has ended - automatic match!

	move.l	a2,a6	; user's phrase went 1 too far
	subq.l	#1,a6

	move.l	#phrase_routs,a0
	lsl.w	#2,d0
	add.l	d0,a0
	move.l	(a0),a0
	moveq	#1,d0
	rts

phrase_list:
	dc.b	"(",0
	dc.b	")",0
	dc.b	"and",0
	dc.b	"or",0
	dc.b	"not",0
	dc.b	"exists",0
	dc.b	"mem",0
	dc.b	"found",0
	dc.b	"input",0
	dc.b	"inpchar",0
	dc.b	$ff
	even

phrase_routs:
	dc.l	open_bracket
	dc.l	close_bracket
	dc.l	and
	dc.l	or
	dc.l	not
	dc.l	exist
	dc.l	mem
	dc.l	found
	dc.l	input
	dc.l	inpchar

open_bracket:
	move.b	#"(",(a5)+
	rts

close_bracket:
	move.b	#")",(a5)+
	rts
and:
	move.b	#"&",(a5)+
	rts
or:
	move.b	#"+",(a5)+
	rts
not:
	move.b	#"!",(a5)+
	rts

exist:
	moveq	#1,d2	; assume yes
	move.b	exists,d1
	cmp.b	#"y",d1
	beq.s	.true

	moveq	#0,d2
.true:
	move.b	d2,(a5)+
	rts

mem:
* get amount of free memory
	moveq	#-1,d0
	jsr	res_mem
* in K
	moveq	#10,d1
	lsr.l	d1,d0

* following this there is a numeric expression.
* it can be evaluated by = < >
	bsr	eval_numeric
	tst.l	d0
	bpl.s	.ok

* error in numeric!
	print	numeric_error
	moveq	#-1,d0
	rts

.ok:
* d0 holds T/F
	move.b	d0,(a5)+
	rts

found:
	move.l	#found_name,a0
	bsr	eval_string
	tst.l	d0
	bpl.s	.ok

	print	str_error
	moveq	#-1,d0
	rts

.ok:
	move.b	d0,(a5)+
	rts

input:
	move.l	#input_line+2,a0
	bsr	eval_string
	tst.l	d0
	bpl.s	.ok

	print	str_error
	moveq	#-1,d0
	rts

.ok:
	move.b	d0,(a5)+
	rts
	
inpchar:
	move.l	#input_char,a0
	bsr	eval_string
	tst.l	d0
	bpl.s	.ok

	print	str_error
	moveq	#-1,d0
	rts

.ok:
	move.b	d0,(a5)+
	rts

eval_string:
* enters with:
* a6 = expression (in quotes)
* a0 = expression to compare with
* returns:
* d0 = T/F or -1 for error

* keep MY expression for later use..
	move.l	a0,a4

* get < > = <>
	bsr	get_exp
	tst.w	d7
	bpl.s	.ok
	moveq	#-1,d0
	rts

.ok:
* got valid < > = <>
* expression at a6
	move.l	a6,a0
	bsr	get_next_param
	move.l	a0,a6
	tst.w	d0
	bpl.s	.ok2

	moveq	#-1,d0
	rts

.ok2:
* got start of expression.  Must now have "
	move.b	(a6)+,d0
	cmp.b	#'"',d0
	beq.s	.start_quote

	moveq	#-1,d0
	rts

.start_quote:
* got a start quote...
* begin to analyse the expression

* get next char from file's expression
.check_loop:
	move.b	(a6)+,d0
	bne.s	.no_err

	moveq	#-1,d0
	rts

.no_err:
	jsr	to_lower
	cmp.b	#'"',d0
	beq.s	.end_quote

* not an end quote - compare the two chars!
	move.b	(a4)+,d1
	beq	.getend		; no match if it's reached the end

	cmp.b	d0,d1
	beq	.check_loop

* didn't match!
* so we go to the end of the string... either a " or a 0 (error)
.getend:
	move.b	(a6)+,d0
	beq.s	.error
	cmp.b	#'"',d0
	beq.s	.nomatch
	bra.s	.getend

.error:
	moveq	#-1,d0
	rts

.nomatch:
* did we want a match?
	cmp.b	#"!",d7
	beq	.true		; no!

.false:
	moveq	#0,d0
	rts


.end_quote:
* got end quote - has other string finished?
	tst.b	(a4)
	bne	.nomatch

* match! do we want one?
	cmp.b	#"!",d7
	beq	.false

.true:
	moveq	#1,d0
	rts



get_exp:
	move.l	a6,a0
	bsr	get_next_param
	tst.w	d0
	bpl.s	.ok
	moveq	#-1,d7
	rts
.ok:
	move.l	a0,a6

	moveq	#0,d7
	move.b	(a6)+,d7
	cmp.b	#"=",d7
	beq.s	.gotit

	cmp.b	#">",d7
	beq.s	.gotit

	cmp.b	#"<",d7
	beq.s	.notinvyet

* invalid operator!
	moveq	#-1,d0
	rts

.notinvyet:
* could be <>!
	cmp.b	#">",(a6)
	bne.s	.gotit

	move.b	#"!",d7
	addq.l	#1,a6

.gotit:
* got a valid operator.
	rts


eval_numeric:
* enters with a6 pointing to expression, d0 holding number to compare with

* evaluate a numeric expression.
* this can be: = < > <> <number>
* and may not be null-terminated

	move.l	d0,d6

* get the = < > <>
	bsr	get_exp
	tst.w	d7
	bpl.s	.ok
	moveq	#-1,d0
	rts

.ok:

* now we interpret the number itself.
	move.l	a6,a0
	bsr	get_next_param
	move.l	a0,a6
	tst.w	d0
	bpl.s	.ok2
	moveq	#-1,d0
	rts

.ok2:
* at the start of the number!
	moveq	#0,d0		; number = 0 to start with...
	moveq	#0,d3		; flag = none done yet!
.num_loop:
	moveq	#0,d1
	move.b	(a6)+,d1
	sub.b	#"0",d1
	bmi.s	.end_num

	cmp.b	#9,d1
	bgt	.end_num

* valid digit!
	move.l	d0,d2
	lsl.l	#3,d0
	add.l	d2,d0
	add.l	d2,d0
	add.l	d1,d0

	moveq	#1,d3

	bra.s	.num_loop

.end_num:
* did we do any?
	tst.w	d3
	bne.s	.yup

* no! none done!
	moveq	#-1,d0
	rts

.yup:
* done it!
* now compare d6 and d0!
	cmp.b	#"=",d7
	beq.s	.eqs

	cmp.b	#">",d7
	beq.s	.gt

	cmp.b	#"<",d7
	beq.s	.lt

* not equal!
	cmp.l	d6,d0
	beq	.false

.true:
	moveq	#1,d0
	rts

.false:
	moveq	#0,d0
	rts


.eqs:
* must be equal!
	cmp.l	d6,d0
	bne	.false

* it's true!
	bra	.true

.gt:
* is d6 > d0?
	cmp.l	d6,d0
	bgt	.false
	bra	.true

.lt:
* is d6 < d0?
	cmp.l	d6,d0
	blt	.false

	bra	.true

flash:
	move.l	a4,a0
	bsr	get_next_param
	tst.w	d0
	bpl.s	.ok

	print	flash_what?
	rts

.ok:
	move.l	#flash_params,a1
	bsr	get_param
	tst.w	d0
	bpl.s	.ok2

	print	flash_what?
	rts

.ok2:
* on or off?
	tst.w	d0
	bne	.off

	move.b	#"y",flash_flag
	print	flash_on
	rts

.off:
	move.b	#"n",flash_flag
	print	flash_off
	rts


flash_params:
	dc.b	"on",0
	dc.b	"off",0
	dc.b	$ff
	even

gosub:
* can I do another GOSUB?
	move.w	no_of_gosubs,d0
	cmp.w	#99,d0
	bne.s	.okok

	print	too_many_gosubs
	rts

.okok:
* gosub which label?
	move.l	a4,a0
	bsr	get_next_param
	tst.l	d0
	beq.s	.got_a_label

	print	gosub_where
	rts

.got_a_label:
	move.l	#label_addr,a1
.copy:
	move.b	(a0)+,d0
	beq.s	.end
	cmp.b	#$ff,d0
	beq.s	.end
	move.b	d0,(a1)+
	bra.s	.copy

.end:
	clr.b	(a1)+

	move.l	process_addr,a0
	move.l	process_len,d0
	move.l	gosub_list,a1
	movem.l	a0/d0,-(a1)
	move.l	a1,gosub_list

	bsr	find_a_label

	cmp.b	#"y",label_found
	beq.s	.found

	move.l	gosub_list,a1
	movem.l	(a1)+,d0/a0
	move.l	a1,gosub_list

	move.l	a0,process_addr
	move.l	d0,process_len
	print	no_label
	rts

.found:
	addq.w	#1,no_of_gosubs
	rts

return:
	move.l	gosub_list,a1
	movem.l	(a1)+,d0/a0
	tst.l	d0
	bpl.s	.ok

	print	no_gosub
	rts

.ok:
	move.l	d0,process_len
	move.l	a0,process_addr
	move.l	a1,gosub_list
	subq.w	#1,no_of_gosubs
	rts

goto:
* goto which label?
	move.l	a4,a0
	bsr	get_next_param
	tst.l	d0
	beq.s	.got_a_label

	print	goto_where
	rts

.got_a_label:
	move.l	#label_addr,a1
.copy:
	move.b	(a0)+,d0
	beq.s	.end
	cmp.b	#$ff,d0
	beq.s	.end
	move.b	d0,(a1)+
	bra.s	.copy

.end:
	clr.b	(a1)+

	move.l	process_addr,a0
	move.l	process_len,d0
	movem.l	a0/d0,-(a7)	; keep current process data safe (in case of error)
	bsr	find_a_label

	cmp.b	#"y",label_found
	beq.s	.found

	movem.l	(a7)+,a0/d0
	move.l	a0,process_addr
	move.l	d0,process_len
	print	no_label
	rts

.found:
	movem.l	(a7)+,a0/d0
	rts

find_a_label:
	move.l	text_addr,process_addr
	move.l	text_len,process_len
	move.b	#"n",label_found
	move.b	#"n",eof

.while:
	cmp.b	#"n",eof
	bne	.end_while

	cmp.b	#"n",label_found
	bne	.end_while

	bsr	get_next_line
	bsr	find_label

	bra.s	.while
.end_while:
	move.b	#"n",eof
	rts



find_label:
* is this command line a label?
	move.l	#command_line,a0
	cmp.b	#":",(a0)
	beq.s	.label
	rts

.label:
* does the label match the one we're looking for?
	move.l	#label_addr,a1

.compare:
	cmpm.b	(a0)+,(a1)+
	beq.s	.compare

* after compare, -1(a0) must be 0 or $ff and -1(a1) must be 0 or $ff
	move.b	-1(a0),d0
	beq.s	.ok1
	cmp.b	#$ff,d0
	bne.s	.not_lab

.ok1:
	move.b	-1(a1),d0
	beq.s	.lab
	cmp.b	#$ff,d0
	bne.s	.not_lab

.lab:
	move.b	#"y",label_found
.not_lab:
	rts

inpclr:
	bsr	clear_keys
ninpchar:
* is there a mask of characters?
	move.l	a4,a0
	bsr	get_next_param
	tst.l	d0
	beq	.mask

* no mask!
	bsr	inp_echo
	jsr	to_lower
	move.b	d0,input_char
	rts

.mask:
	move.l	a0,a4	; keep list of mask!

.get_char:
	move.w	#1,-(a7)
	trap	#1
	addq.l	#2,a7

	move.w	d0,-(a7)
	print	back_space
	move.w	(a7)+,d0

	jsr	to_lower

* does the char I got match any in the list?
	move.l	a4,a0
.check:
	move.b	(a0)+,d1
	beq	.get_char
	cmp.b	#$ff,d1
	beq	.get_char

	sub.b	d0,d1
	bne	.check
* got a match!
	move.b	d0,input_char
	print	new_line
	rts


print:
* I must have another parameter here... what to print!
	move.l	a4,a0
	bsr	get_next_param
	tst.l	d0
	beq.s	.another

* nothing after the command; just a new line!
	print	new_line
	rts

.another:
* the stuff to print is enclosed in quotes...
* and has 0s instead of spaces...
	move.l	a0,a1
	cmp.b	#'"',(a1)+
	beq.s	.ok

	print	no_quotes
	rts

.ok:
* find end of line...
.eol:
	cmp.b	#$ff,(a1)+
	bne.s	.eol

* now go back to find quote mark...
.quote:
	cmp.b	#'"',-(a1)
	bne.s	.quote

* is it the same as a0?
	cmp.l	a1,a0
	bne.s	.ok2

	print	no_quotes
	rts

.ok2:
* replace all 0s with spaces until we reach a1
	move.l	a0,a2

.spaces:
	move.b	(a2)+,d0
	bne.s	.notzed

	move.b	#" ",-1(a2)
	bra.s	.spaces

.notzed:
	cmp.l	a2,a1
	bne.s	.spaces

	clr.b	(a1)	; get rid of last quote

	addq.l	#1,a0	; go past 1st quote

	jsr	print_mes
	print	new_line
	rts


newdisk:
* simply clear the exclusions for this disk!
	move.l	#exclude_temp,a6

.clear:
	move.w	#wilds_per_block,(a6)+
	move.l	(a6),d0
	clr.l	(a6)
	tst.l	d0
	beq	.dun
	move.l	d0,a6
	bsr	rel_mem
	bra.s	.clear

.dun:
	rts


ram:
* turn RAM searching ON or OFF
	move.l	a4,a0
	bsr	get_next_param
	tst.w	d0
	bpl.s	.ok

	print	inv_ram_param
	rts

.ok:
	move.l	#ram_params,a1
	bsr	get_param

	tst.w	d0
	bpl.s	.ok2

	print	inv_ram_param
	rts

.ok2:
	tst.w	d0
	beq.s	.yes

	move.b	#"n",search_ram
	print	ram_is
	print	off
	print	new_line
	rts

.yes:
	move.b	#"y",search_ram
	print	ram_is
	print	on
	print	new_line
	rts

ram_params:
	dc.b	"on",0
	dc.b	"off",0
	dc.b	$ff
	even

reset:
* perform a soft reset
	jsr	super_on
	move.l	$4.w,a0
	jmp	(a0)

search_first:
	move.l	a4,a0
	bsr	get_next_param
	move.l	a0,a4

	tst.w	d0
	beq.s	.ok

	print	no_search_file
	rts

.ok:
* search for the file...
	move.b	#"y",exists

	bsr	search_file
	tst.w	d0
	beq.s	found_one

	clr.b	found_name
	move.b	#"n",exists
	rts
found_one:
	move.l	#dta+f_name,a0
	move.l	#found_name,a1
.copy:
	move.b	(a0)+,d0
	jsr	to_lower
	move.b	d0,(a1)+

	tst.b	d0
	bne.s	.copy

	rts

search_again:
	move.b	#"y",exists

	bsr	search_next

	tst.w	d0
	beq.s	found_one

	move.b	#"n",exists
	rts

	ENDC


*******************************************************************
**** END OF FULL VERSION ONLY ROUTINES ****************************
*******************************************************************



************************************************************
***************         RAMDISK STUFF        ***************
************************************************************

handling_routines:
	dc.w	0

ram_disk_on:
	moveq	#0,d0
	lea	drive_letter(pc),a0
	move.b	(a0),d0
	sub.b	#"a",d0

	lea	drive_no(pc),a0
	move.w	d0,(a0)
	lea	changed(pc),a0
	move.w	d0,(a0)

	lea	hdv(pc),a0
	move.l	hdv_bpb.w,(a0)+
	move.l	hdv_med.w,(a0)+
	move.l	hdv_rw.w,(a0)+
	move.l	res_val.w,(a0)+
	move.l	res_vec.w,(a0)+

	move.l	drv_bits.w,d0
	lea	drive_no(pc),a1
	move.w	(a1),d1
	bset	d1,d0
	move.l	d0,drv_bits.w

* my routines in!
	lea	my_rw(pc),a1
	move.l	a1,hdv_rw.w

	lea	my_med(pc),a1
	move.l	a1,hdv_med.w

	lea	my_bpb(pc),a1
	move.l	a1,hdv_bpb.w


* am I reset-proof?
	lea	reset_proof(pc),a0
	cmp.b	#"y",(a0)
	bne.s	no_res

* yes!
reset_routines:
	lea	my_reset(pc),a1
	move.l	a1,res_vec.w
	move.l	#$31415926,res_val.w
no_res:
	rts

first_reset:	dc.b	"y "

my_reset:
* I have been reset.
* is this the first ever reset?
	move.w	#$f00,$ffff8240.w

	lea	j_to(pc),a0
	movem.l	d0-7/a1-6,(a0)	; keep ALL variables!

	lea	first_reset(pc),a0
	cmp.b	#"y",(a0)
	bne	not_first_reset

	move.b	#"n",(a0)

* I must copy myself above normal memory.
* to protect myself in future...
	move.l	phystop.w,a0	; get top end of memory at the moment...
	lea	total_size(pc),a1
	move.l	(a1),d0		; get total size of ramdisk
	sub.l	d0,a0		; a0 holds ramdisk data address from now on...

	lea	ramdisk_addr(pc),a1
	move.l	(a1),a2		; get current addr of ramdisk

* now remember the new RAMDISK address for later access...
	move.l	a0,(a1)

	move.l	d0,d1
	moveq	#9,d2
	lsr.l	d2,d1		; d1 = total size / 512

* keep top of memory address
	move.l	a0,a4

* copy whole of RAMDISK above normal memory...
.copy:
c	set	0
	rept	16
	movem.l	(a2)+,d2-7/a5-6
	movem.l	d2-7/a5-6,c(a0)
c	set	c+32
	endr

	not.w	$ffff8240.w

	lea	512(a0),a0

	subq.l	#1,d1
	bne	.copy


* take the length of the handling routines away from the phystop
	sub.l	#hand_len,a4

* and store new phystop
* but on an even address!
	move.l	a4,d0
	and.w	#$fe00,d0
	move.l	d0,phystop.w
	move.l	a4,a1		; keep top end for later

* now put the handling routines into top memory!
	lea	handling_routines(pc),a0
	move.w	#hand_len/2-1,d1

.copy2:
	move.w	(a0)+,(a4)+
	dbra	d1,.copy2

* now! everything is in place!
* but I have to calculate the address of the post-reset routine!
* get relative length
	move.l	a1,a4

	lea	res_offset(a1),a1
	lea	res_jump_addr+2(pc),a0
	move.l	a1,(a0)		; slap it in!

* and put it into the code we'll copy from NOW ON!
	lea	res_jump_addr+2(pc),a2
	lea	handling_routines(pc),a3
	sub.l	a3,a2		; a2 is the offset address
	add.l	a2,a4		; a4 is where to put it...
	move.l	a1,(a4)

not_first_reset:
* I must now set up the post-reset program.
	lea	post_res(pc),a0

* get top of memory...
	move.l	phystop.w,d0

	sub.l	#$10000,d0	; "safe"ish area...
	move.l	d0,a1

	move.l	#$12123456,(a1)+
	move.l	d0,(a1)+

* copy my proggy...
	move.w	#post_res_len/2-1,d1
.copy:
	move.w	(a0)+,(a1)+
	dbra	d1,.copy

* set up the checksum
	move.l	d0,a0

	moveq	#0,d1
	move.w	#$fe,d2
.add:
	add.w	(a0)+,d1
	dbra	d2,.add

	move.w	#$5678,d0
	sub.w	d1,d0
	move.w	d0,(a0)

* restore old reset vectors...
	lea	old_res_val(pc),a0
	movem.l	(a0),d0-1
	movem.l	d0-1,res_val.w

	lea	j_to(pc),a0
	movem.l	(a0),d0-7/a1-6

	move.w	#$fff,$ffff8240.w

	jmp	(a6)

j_to:	ds.b	64

post_res:
* I have been reset!
* set up the vectors again...

	lea	post_res-8(pc),a0
	clr.l	(a0)+
	clr.l	(a0)+		; not reset-proof prog anymore!
res_jump_addr:
	jmp	$12345678
post_res_len	equ	*-post_res


post_res_here:
res_offset	equ	*-handling_routines

	lea	i_am_on(pc),a0
	bsr	prt_it

	bsr	ram_disk_on
* re-install the Alt-help and TRAP 13 routines
* if necessary
	lea	help_switch_flag(pc),a0
	tst.b	(a0)
	beq.s	.no_help

* turn on ALT-HELP switching!
	move.w	#help_vec,a1
	lea	old_help(pc),a2
	lea	my_help(pc),a3

	move.l	(a1),(a2)
	move.l	a3,(a1)

.no_help:

* switch on shift routine?
	lea	shift_switch_flag(pc),a0
	tst.b	(a0)
	beq.s	.no_shft

* install SHIFT routine...
	move.w	#trap13,a1	; vector to alter
	lea	old_trap13+2(pc),a2	; where to store it
	lea	my_trap13(pc),a3	; what to put in

	move.l	(a1),(a2)
	move.l	a3,(a1)

.no_shft:


	bsr	search_in

.no_ram:
	rts

prt_it:
	pea	(a0)
	move.w	#9,-(a7)
	trap	#1
	addq.l	#6,a7
	rts


i_am_on:
	dc.b	"RAM_LOAD ramdisk is resident.",10,13
	dc.b	"½ James Ingram, 1994",10,13
	dc.b	0
searching:
	dc.b	"Files taken from RAMDISK automatically",10,13
	dc.b	0
	even

my_rw:
	lea	drive_no(pc),a0
	move.w	(a0),d0
	cmp.w	14(a7),d0
	beq	.my_rw

	lea	old_hdv_rw(pc),a0
	move.l	(a0),a0
	jmp	(a0)

.my_rw:
	lea	store(pc),a0
	movem.l	d1-d7/a1-a6,(a0)

	moveq	#0,d0
	move.w	12(a7),d0	; rec no
	lsl.l	#8,d0
	add.l	d0,d0		; x 512

	lea	ramdisk_addr(pc),a3
	move.l	(a3),a3
	add.l	d0,a3

	move.l	6(a7),a1	; buffer

	move.w	a1,d0
	btst	#0,d0
	bne	odd_rw		; branch if odd addr in memory!!!

	move.w	10(a7),d0	; no of secs
	subq.w	#1,d0		; - 1

	move.w	$ffff8240.w,d1
	move.w	d1,d7
	swap	d1

* are we flashing?
	lea	flash_flag(pc),a4
	cmp.b	#"y",(a4)
	bne.s	.noflash

	move.w	#$0f0,d1	; green for reading
	bra.s	.pf

.noflash:
	move.w	$ffff8240.w,d1
.pf:
	move.w	4(a7),d2

	btst	#0,d2
	beq.s	reading

	exg.l	a3,a1

* are we flashing?
	lea	flash_flag(pc),a4
	cmp.b	#"y",(a4)
	bne.s	.noflash2
	move.w	#$f00,d1	; red for WRITING

	bra.s	.pf2

.noflash2:
	move.w	$ffff8240.w,d1
.pf2:

reading:
	move.w	d7,-(a7)
.loop:
	move.w	d1,$ffff8240.w
	swap	d1

mov	macro
	movem.l	(a3)+,d2-d7/a2/a4
	movem.l	d2-d7/a2/a4,\1(a1)
	endm

	mov	0
	mov	32
	mov	64
	mov	96
	mov	128
	mov	160
	mov	192
	mov	224
	mov	256
	mov	288
	mov	320
	mov	352
	mov	384
	mov	416
	mov	448
	mov	480

	lea	512(a1),a1
	dbra	d0,.loop

	move.w	(a7)+,$ffff8240.w

	moveq	#0,d0
	movem.l	(a0),a1-a6/d1-d7

	rts

odd_rw:
	move.w	10(a7),d0	; no of secs
	subq.w	#1,d0		; - 1

	move.w	4(a7),d2

	move.w	$ffff8240.w,d1
	move.w	d1,-(a7)
	swap	d1

* are we flashing?
	lea	flash_flag(pc),a4
	cmp.b	#"y",(a4)
	bne.s	.noflash

	move.w	#$0f0,d1	; green for reading
	bra.s	.pf

.noflash:
	move.w	$ffff8240.w,d1
.pf:

	btst	#0,d2
	beq.s	reading2

	exg.l	a3,a1

* are we flashing?
	lea	flash_flag(pc),a4
	cmp.b	#"y",(a4)
	bne.s	.noflash2
	move.w	#$f00,d1	; red for WRITING

	bra.s	.pf2

.noflash2:
	move.w	$ffff8240.w,d1
.pf2:


reading2:
	move.w	#512-1,d2
do_odd:
	move.b	(a3)+,(a1)+
	dbra	d2,do_odd

	move.w	d1,$ffff8240.w
	swap	d1

	dbra	d0,reading2

	move.w	(a7)+,$ffff8240.w

	moveq	#0,d0
	movem.l	(a0),a1-a3/d1-d7

	rts

my_bpb:
	lea	drive_no(pc),a0
	move.w	(a0),d0
	cmp.w	4(a7),d0
	beq	.my_bpb

	lea	old_hdv_bpb(pc),a0
	move.l	(a0),a0
	jmp	(a0)
.my_bpb:
	lea	bpb(pc),a0
	move.l	a0,d0
	rts



my_med:
	lea	drive_no(pc),a0
	move.w	(a0),d0
	cmp.w	4(a7),d0
	beq	.my_med

	lea	old_hdv_med(pc),a0
	move.l	(a0),a0
	jmp	(a0)
.my_med:
	lea	changed(pc),a0
	move.w	(a0),d0
	clr.w	(a0)
	rts

bpb:
	dc.w	$200,2,$400,7,5,6,18
bpb_size:
	ds.w	1
	ds.l	4

changed		ds.w	1
drive_no	ds.w	1
ram_size	ds.l	1
total_size	ds.l	1
ramdisk_addr	ds.l	1

hdv:
old_hdv_bpb	ds.l	1
old_hdv_med	ds.l	1
old_hdv_rw	ds.l	1
old_res_val	ds.l	1
old_res_vec	ds.l	1

store		ds.b	64

install_search:
	pea	search_in(pc)
search_rej:
	move.w	#38,-(a7)

	lea	ramdisk_exists(pc),a0
	cmp.b	#"y",(a0)
	bne.s	.no_disk

	trap	#14
.no_disk:
	addq.l	#6,a7
	rts

destall_search:
	pea	search_de(pc)
	bra.s	search_rej


search_in:
* install the trap #1 searching routines
	lea	old_trap1(pc),a0
	move.l	$84.w,(a0)

	lea	my_trap1(pc),a0
	move.l	a0,$84.w

	lea	skipping(pc),a0
	clr.w	(a0)

	rts

search_de:
	lea	old_trap1(pc),a0
	move.l	(a0),$84.w
	rts


my_trap1:
* my trap 1!
* will act if instruction is:
*	search first
*	search next
*	open
*	run
*	change path
* AND search_ram flag is set!

	lea	skipping(pc),a0
	tst.w	(a0)
	bne	skip

	st	(a0)
	lea	variables(pc),a0
	movem.l	d1-7/a0-6,(a0)

	lea	6(a7),a0
	btst	#5,(a7)
	bne.s	.super
	move.l	usp,a0
.super:
* keep addr of stack stuff
	lea	stack_addr(pc),a1
	move.l	a0,(a1)

* is this a call I need to intercept???
b	macro
	cmp.w	#$\1,(a0)
	beq	\2
	endm

	lea	search_ram(pc),a1
	cmp.b	#"y",(a1)
	beq.s	.do_it

* searching is off! Do I want to switch it on?
	cmp.w	#$4b,(a0)
	bne	.nono

* running command...
* am I to switch on?
	lea	run_switch_flag(pc),a1
	tst.b	(a1)
	beq	.nono

* yes!
	lea	search_ram(pc),a1
	move.b	#"y",(a1)


.do_it:
	b	4b,runner
	b	3b,c_path
	b	3d,open
	b	4e,sfirst
	b	4f,snext

.nono:
* not a call I need to do anything about...
do_nothing:
	lea	skipping(pc),a0
	clr.w	(a0)

	lea	variables(pc),a0
	movem.l	(a0),d1-7/a0-6
skip:
	lea	old_trap1(pc),a0
	move.l	(a0),a0
	jmp	(a0)

runner:
* program being run!
* is the run switch on?
	lea	run_switch_flag(pc),a0
	tst.b	(a0)
	beq.s	.no

* yes! switch on RAM searching!
	lea	search_ram(pc),a0
	move.b	#"y",(a0)
.no:

	lea	search_ram(pc),a0
	cmp.b	#"n",(a0)
	beq	do_nothing		; do nothing if RAM searching not on!	

	lea	stack_addr(pc),a4
	move.l	(a4),a4
	move.l	4(a4),a5
	bsr	get_file_path

* insert filename
.name:
	move.b	(a0)+,(a6)+
	bne.s	.name

* COMPLETE file path is now in trap_path
* (include "X:\")
* now...
* does the file being opened match any on the ramdisk?

* attempt to open file on RAMDISK to see!
* change drive letter
	lea	drive_no(pc),a0
	moveq	#0,d0
	move.w	(a0),d0
	add.b	#"A",d0

	lea	trap_path(pc),a1
	move.b	(a1),d1
	move.b	d0,(a1)

* but keep old one!
	lea	old_d(pc),a1
	move.b	d1,(a1)

* now attempt open

	clr.w	-(a7)
	pea	trap_path(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.w	d0
	bmi	do_nothing	; do normal run if not found

* found file!
	move.w	d0,-(a7)
	move.w	#$3e,-(a7)
	trap	#1		; close file
	addq.l	#4,a7

* run file on RAMDISK!

	lea	trap_path(pc),a0
	move.l	a0,4(a4)	; MY path & file name!
	bra	do_nothing	; normal run, but with MY filename!


c_path:
* it's trying to change the path!!!
* no problem if path exists on current drive.  But if it DOESN'T
* then I need to check the RAMDISK.
* If it exists on the RAMDISK, then I return an OK code.

	lea	stack_addr(pc),a4
	move.l	(a4),a4
	move.l	2(a4),a5	; get path addr

	move.l	a5,a0
	bsr	c_p
	tst.w	d0
	beq	finished	; return if path exists

* does it exist on RAMDISK?
	bsr	keep_path
	bsr	to_me		; change to my disk

	cmp.b	#"\",(a5)
	beq	.from_start	; no need to change to any dir if slash at start

* no slash at start of pathname!
* so I need to go to the path which the other drive is on...
	lea	old_path(pc),a0
	tst.w	d0
	bmi	.p_error	; finished if can't even get there...

.from_start:
	move.l	a5,a0
	bsr	c_p

* keep d0 code
.p_error:
	bra	finished



c_p:
	pea	(a0)
	move.w	#$3b,-(a7)
	trap	#1
	addq.l	#6,a7
	rts
	


open:
* it's trying to OPEN a file!!!!!!!!!
* I must get the correct FULL pathname
	lea	stack_addr(pc),a4
	move.l	(a4),a4
	move.l	2(a4),a5	; a5 holds search details
	bsr	get_file_path

* insert filename
.name:
	move.b	(a0)+,(a6)+
	bne.s	.name

* COMPLETE file path is now in trap_path
* (include "X:\")
* now...
* does the file being opened match any on the ramdisk?

* attempt to open file on RAMDISK to see!
* change drive letter
	lea	drive_no(pc),a0
	moveq	#0,d0
	move.w	(a0),d0
	add.b	#"A",d0

	lea	trap_path(pc),a1
	move.b	(a1),d1
	move.b	d0,(a1)

* but keep old one!
	lea	old_d(pc),a1
	move.b	d1,(a1)

* now attempt open

	lea	stack_addr(pc),a0
	move.l	(a0),a0
	move.w	6(a0),-(a7)	; attribute
	pea	trap_path(pc)
	move.w	#$3d,-(a7)
	trap	#1
	addq.l	#8,a7

	tst.w	d0
	bpl.s	.opened

* doesn't exist on RAMDISK!
* so try to open it as it was...
	lea	stack_addr(pc),a0
	move.l	(a0),a0
	move.w	6(a0),-(a7)
	move.l	2(a0),-(a7)
	move.w	(a0),-(a7)
	trap	#1
	addq.l	#8,a7
	bra	do_nothing

.opened:
* I opened it OK!

finished:
	lea	skipping(pc),a0
	clr.w	(a0)

	lea	variables(pc),a0
	movem.l	(a0),d1-7/a0-6
	rte






snext:
* am I searching on the RAMDISK?
	lea	search_ramdisk_now(pc),a0
	cmp.b	#"n",(a0)
	beq	search_norm
* yup!
	move.w	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7

* was any file found?
	tst.w	d0
	bmi	.none_found	; do nothing if another file found OK

	bsr	into_list	; put file details into list
	bra	finished

.none_found:
* no!
	lea	search_ramdisk_now(pc),a0
	move.b	#"n",(a0)

* begin searching on the normal drive!!
	lea	old_d(pc),a0
	lea	search_path(pc),a1
	move.b	(a0),(a1)

* do a sfirst...
	lea	attrib(pc),a0
	move.w	(a0),-(a7)
	pea	(a1)
	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7
	tst.w	d0
	bne	finished

* if file exists, check it isn't on RAMDISK
	lea	call_type(pc),a0
	move.b	#"s",(a0)
	bsr	check_ram
	tst.w	d0
	beq	finished

* It is on RAMDISK! search again!
search_norm:
* I am searching the original drive now
* do the search!
.search_loop:
	move.w	#$4f,-(a7)
	trap	#1
	addq.l	#2,a7
	tst.w	d0
	bne	finished


* check to make sure it's not on RAMDISK
	lea	call_type(pc),a0
	move.b	#"s",(a0)
	bsr	check_ram

* search again if it is on the RAMDISK
	tst.w	d0
	bne.s	.search_loop

	bra	finished


check_ram:
* I have found a file on the ORIGINAL disk.
* I must check to see if it exists on the RAMDISK
* if it does, then I ignore it, because it will have been done already
* if it does not, then I leave it alone.

* first, find the dta
	move.w	#$2f,-(a7)
	trap	#1
	addq.l	#2,a7

	move.l	d0,a6

* get the filename we found
	lea	f_name(a6),a5


	lea	list_folders(pc),a0
* is it a file or a folder which was found?
	move.b	21(a6),d0
	and.b	#$10,d0
	bne.s	.folder

	lea	list_files(pc),a0
.folder:
* now scan list at a0 to find filename held at a5
	move.w	-2(a0),d0	; get number of entries


.search:
	move.l	a5,a4
	move.l	a0,a1

	tst.w	d0
	beq	.end_list

* another one in the list...
.compare:
	move.b	(a4)+,d1
	move.b	(a1)+,d2

	move.b	d1,d3
	or.b	d2,d3
	beq.s	.this_one

	sub.b	d1,d2
	bne	.not_this_one	; branch if different

* keep comparing
	bra.s	.compare

.not_this_one:
* one less to do
	subq.w	#1,d0

* get next name to search
	lea	20(a0),a0
	bra.s	.search

.end_list:
* file does not exist already
	moveq	#0,d0
	rts


.this_one:
* get file length
	move.l	14(a0),d0
	move.l	d0,f_len(a6)	; put into dta

	move.b	19(a0),d0
	move.b	d0,21(a6)	; put in old attribute...

* and return negative number to flag "exists"
	moveq	#-1,d0
	rts

no_of_files	equ	300
no_of_folders	equ	100

	ds.w	1
list_files:
	ds.b	no_of_files*20

	ds.w	1
list_folders:
	ds.b	no_of_folders*20



to_me:
* change to MY RAMDISK!
	lea	drive_no(pc),a0
	move.w	(a0),-(a7)
	move.w	#$e,-(a7)
	trap	#1
	addq.l	#4,a7
	rts


sfirst:
* no files or folders found so far...

	lea	list_folders(pc),a0
	clr.w	-2(a0)
	lea	list_files(pc),a0
	clr.w	-2(a0)

	bsr	keep_path

* I must get the correct FULL pathname
	lea	stack_addr(pc),a4
	move.l	(a4),a4
	move.l	2(a4),a5	; a5 holds search details
	bsr	get_file_path

* COMPLETE file path is now in trap_path
* (including "X:\")
* so put in wildcard (in a0)
.wild:
	move.b	(a0)+,(a6)+
	bne.s	.wild

* now copy the trap_path to the search_path
* This is necessary because of a bug caused by INTERCEPTOR,
* whereby in the middle of SEARCHING, a file is OPENED!
* The OPEN command caused RAM_FILE to overwrite the trap_path
* areas!  So I have to keep the original search pattern
* totally seperate!

	lea	search_path(pc),a0
	lea	trap_path(pc),a1

.copyit:
	move.b	(a1)+,(a0)+
	bne.s	.copyit

	lea	search_path_only(pc),a0
	lea	trap_path_only(pc),a1
.copyit2:
	move.b	(a1)+,(a0)+
	bne.s	.copyit2



* now...
* does the file being searched for match any on the ramdisk?

* change drive letter
	lea	drive_no(pc),a0
	moveq	#0,d0
	move.w	(a0),d0
	add.b	#"A",d0

	lea	search_path(pc),a1
	move.b	(a1),d1
	move.b	d0,(a1)

* but keep old one!
	lea	old_d(pc),a2
	move.b	d1,(a2)

	move.w	6(a4),-(a7)
	pea	(a1)
	move.w	#$4e,-(a7)
	trap	#1
	addq.l	#8,a7

* keep search attribute
	lea	attrib(pc),a0
	move.w	6(a4),(a0)

* I have just searched MY RAMDISK for the file
	tst.w	d0
	bne	.not_found

* and I found the stuff!
	bsr	into_list	; put file details into list...
	bsr	rest_path

	lea	search_ramdisk_now(pc),a0
	move.b	#"y",(a0)
	moveq	#0,d0
	bra	finished

.not_found:
* I didn't find it on the RAMDISK.
* so allow search on normal drive
	lea	search_ramdisk_now(pc),a0
	move.b	#"n",(a0)

	bsr	rest_path

	move.w	6(a4),-(a7)
	move.l	2(a4),-(a7)
	move.w	(a4),-(a7)
	trap	#1
	addq.l	#8,a7
	bra	finished

into_list:
* put a file or a folder into the list
* what type is it?

* get the dta first...
	move.w	#$2f,-(a7)
	trap	#1
	addq.l	#2,a7

	move.l	d0,a0
	move.b	21(a0),d0

	lea	list_files(pc),a1

	move.b	d0,d1
	and.b	#$10,d0
	beq.s	.file

	lea	list_folders(pc),a1

.file:
* a1  = list start address
* get no in list NOW
	moveq	#0,d0
	move.w	-2(a1),d0

* add 1 to number in list...
	addq.w	#1,-2(a1)

* get next free space in list
	mulu	#20,d0
	add.l	d0,a1

* put in attribute
	move.b	d1,19(a1)

* and file length
	move.l	f_len(a0),14(a1)

* now copy file name
	lea	f_name(a0),a0
.copy:
	move.b	(a0)+,(a1)+
	bne.s	.copy

* return d0 = 0 as before
	moveq	#0,d0
	rts



get_file_path:
* get complete pathname for file...
* possible conditions here:
*	- just a file name
*	- some directories then filename
*	- first directory goes from root (ie first char is "\")
*	- complete pathname

* path is in a5
* returns full path at "trap_path" and "trap_path_only"
* and filename address in a0

	bsr	do_path
	lea	trap_path(pc),a1
	lea	trap_path_only(pc),a2
.copy:
	move.b	(a1)+,(a2)+
	bne.s	.copy
	rts


do_path:
	lea	trap_path(pc),a6
	cmp.b	#":",1(a5)
	beq	full_given		; branch to full path given

* is there any folder info?
	move.l	a5,a3
.test:
	move.b	(a3)+,d0
	beq.s	no_folders		; branch to just filename
	cmp.b	#"\",d0
	beq	folders			; branch to some folders
	bra.s	.test

no_folders:
* just a filename passed!
* so it's the CURRENT path!
* put in drive letter

	move.w	#$19,-(a7)
	trap	#1
	addq.l	#2,a7
	add.b	#"A",d0
	move.b	d0,(a6)+
	move.b	#":",(a6)+

	move.l	a6,a0
	bsr	get_dir_2
.not_end:
	tst.b	(a6)+
	bne.s	.not_end

	move.b	#"\",-1(a6)
	clr.b	(a6)
	move.l	a5,a0

	rts

get_dir_2:
	clr.w	-(a7)
	pea	(a0)		; buffer for pathname
	move.w	#$47,-(a7)
	trap	#1
	addq.l	#8,a7
	rts


full_given:
* full pathname given!
	move.b	(a5)+,(a6)+
	bne.s	full_given

* now take off filename itself!
.slash:
	cmp.b	#"\",-(a6)
	bne.s	.slash
	addq.l	#1,a6
	clr.b	(a6)

* and get filename addr
.slash2:
	cmp.b	#"\",-(a5)
	bne.s	.slash2
	lea	1(a5),a0
	rts

folders:
* some folders are given.
* do we go from where we are, or from the root?
	cmp.b	#"\",(a5)
	beq	from_root

* from where we are!
	bsr	insert_drive

	clr.w	-(a7)
	pea	(a6)
	move.w	#$47,-(a7)
	trap	#1
	addq.l	#8,a7


* find end of the current directory string
.get_end:
	tst.b	(a6)+
	bne.s	.get_end

	move.b	#"\",-1(a6)
	bsr	add_current
	bsr	get_name_only
	rts


get_name_only:
* get filename addr
.end:
	tst.b	(a5)+
	bne.s	.end

.slash:
	cmp.b	#"\",-(a5)
	bne.s	.slash

	addq.l	#1,a5
	move.l	a5,a0

	rts

from_root:
	bsr	insert_drive
	bsr	add_current
	bsr	get_name_only
	rts

add_current:
* add the search string (but not the wildcard)
* string in a5
* buffer in a6

.copy:
	move.b	(a5)+,(a6)+
	bne.s	.copy

* now go back & find the last "\"
.slash:
	cmp.b	#"\",-(a6)
	bne.s	.slash

	addq.l	#1,a6
	clr.b	(a6)
	rts


insert_drive:
	move.w	#$19,-(a7)
	trap	#1
	addq.l	#2,a7

	add.b	#"A",d0
	move.b	d0,(a6)+
	move.b	#":",(a6)+
	rts

keep_path2:
	pea	old_path2(pc)
	bra.s	keep_rej
keep_path:
	pea	old_path(pc)

keep_rej:
	move.w	#$19,-(a7)
	trap	#1
	addq.l	#2,a7

	lea	old_drive(pc),a0
	move.w	d0,(a0)

	move.l	(a7),a0

	clr.w	-(a7)
	pea	(a0)
	move.w	#$47,-(a7)
	trap	#1
	addq.l	#8,a7

	move.l	(a7)+,a0
.get_zed:
	tst.b	(a0)+
	bne.s	.get_zed

	move.b	#"\",-1(a0)
	clr.b	(a0)
	rts

rest_path2:
	pea	old_path2(pc)
	bra	rest_rej

rest_path:
	pea	old_path(pc)
rest_rej:
	lea	old_drive(pc),a0
	move.w	(a0),-(a7)
	move.w	#$e,-(a7)
	trap	#1
	addq.l	#4,a7

	move.w	#$3b,-(a7)
	trap	#1
	addq.l	#6,a7

	rts

my_help:
* just switch it!
	movem.l	d0-2/a0-2,-(a7)
	bsr	toggle_ram
	movem.l	(a7)+,a0-2/d0-2
	rts


my_trap13:
* if I am testing for both SHIFT keys to toggle, then jump here!

	pea	(a5)
	lea	flag13(pc),a5

	tst.b	(a5)
	bne.s	.out_now	; skip if I'm already in my routine

	addq.b	#1,(a5)

	movem.l	d0-2/a0-2,-(a7)	; store regs

	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13			; test shift keys
	addq.l	#4,a7			; N.B. THIS CALLS TRAP #13 (ie itself!!  That is what the FLAG_13 is for!)

	and.w	#3,d0
	cmp.w	#3,d0
	bne	.not_called

* called!
* toggle!
	bsr	toggle_ram

* wait for shift keys to go up!
.wait:
	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13			; test shift keys
	addq.l	#4,a7			; N.B. THIS CALLS TRAP #13 (ie itself!!  That is what the FLAG_13 is for!)

	and.w	#3,d0
	cmp.w	#3,d0
	beq	.wait


.not_called:
	movem.l	(a7)+,d0-2/a0-2
	clr.b	(a5)

.out_now:
	move.l	(a7)+,a5
old_trap13:
	jmp	$12345678

toggle_ram:
* called by either both SHIFT keys or ALT+HELP
* toggles ram searching on / off and show appropriate colour
* also pauses for a bit

	lea	search_ram(pc),a0
	move.b	(a0),d0
	cmp.b	#"y",d0
	beq.s	.off

* turning ON!
	move.b	#"y",(a0)
	move.w	#$f00,d0

.colours:
	move.w	#$8240,a0
	move.w	(a0),d1
	move.w	d0,(a0)

* pause!
	moveq	#5,d0
	moveq	#-1,d2

.pause:
	dbra	d2,.pause
	dbra	d0,.pause

* restore colour
	move.w	d1,(a0)
	rts

.off:
	move.b	#"n",(a0)
	move.w	#$ff0,d0
	bra.s	.colours



ramdisk_exists	ds.b	1
flash_flag	dc.b	"y"
search_ram	dc.b	"y"
installed_search:	dc.b	0
search_ramdisk_now:	ds.b	1
reset_proof:	ds.b	1
drive_letter:	ds.b	1
call_type:	ds.b	1
old_d:		ds.b	1
shift_switch_flag:	dc.b	0
help_switch_flag:	dc.b	0
run_switch_flag:	dc.b	0
flag13:	dc.b	0
	even

trap_path:	ds.b	256
trap_path_only:	ds.b	256
trap_name:	ds.b	256
search_path:	ds.b	256
search_path_only:	ds.b	256
skipping:	ds.w	1
variables:	ds.b	64
stack_addr:	ds.l	1
old_trap1:	ds.l	1
old_help	dc.l	$12345678
attrib:		ds.w	1

old_drive:	ds.w	1
old_path:	ds.b	512
old_path2:	ds.b	512
*****************************************
************** END OF RAMDISK ***********
*****************************************
hand_len	equ	*-handling_routines


ramdisk_flags:
	dc.b	"/reset",0
	dc.b	$ff
	even
	
get_param:
* a0 = command line parameter
* a1 = parameter list
* returns d0 = -1 if error
* or parameter no in list

	moveq	#0,d0

.check_params:
	move.l	a0,a2

.chk:
	move.b	(a2)+,d1
	beq	.end
	move.b	(a1)+,d2
	beq.s	.not_this

	sub.b	d2,d1
	beq.s	.chk
	bra	.not_this

.end:
* reached end!  both must now be 0!
	move.b	(a1),d2
	bne	.not_this
	rts

.not_this:
* get next param in list...
* did we just reach 0?
	tst.b	-1(a1)
	beq.s	.zed_now

	tst.b	(a1)+
	bne.s	.not_this

.zed_now:
	addq.w	#1,d0
	cmp.b	#$ff,(a1)
	bne.s	.check_params
	moveq	#-1,d0
	rts



ninput:
	bsr	get_input
	print	new_line
	rts



pause:
	move.l	a4,a0
	bsr	get_next_param
	tst.w	d0
	bpl.s	.got_num
	bsr	inp
	rts

.got_num:
* got a number (pause length)
	bsr	asc_to_bin
	tst.l	d1
	bpl.s	.num_ok

	print	inval_pause
	rts

.num_ok:
* got a valid pause length
	move.l	d0,d7

.loop:
	bsr	vsync

	move.w	#$ff,-(a7)
	move.w	#6,-(a7)
	trap	#1		; test keyboard
	addq.l	#4,a7
	tst.w	d0
	bne.s	.end

	subq.l	#1,d7
	bne.s	.loop
.end:
	rts

inp:
	move.w	#7,-(a7)
	trap	#1
	addq.l	#2,a7
	rts

vsync:
	move.w	#37,-(a7)
	trap	#14		; wait 1/50th second
	addq.l	#2,a7
	rts


quit:
* quit command given - stay resident?
	move.l	a5,a0
	bsr	past_param
	bsr	get_next_param
	move.l	a0,a5
	tst.w	d0
	beq	.ok

* is it reset-proof?
	cmp.b	#"y",reset_proof
	beq	.reset

* no! just quit!
	bsr	ramdisk_off
	bsr	back_to_low
	clr.w	-(a7)
	trap	#1

.ok:
* parameter found.
* which one is it?
	move.l	#quit_params,a1
	bsr	get_param
	tst.w	d0
	bpl.s	.ok2

	print	inv_quit_param
* invalid param - don't quit, just in case!
	rts


.ok2:
* was the parameter "/reset"?
	tst.w	d0
	beq	.resident

.reset:
* yup!
* reset-proof!
	move.b	#"y",reset_proof
* set up reset-proof prog...
	pea	reset_routines
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7


.resident:
* quit my prog, but with ramdisk still resident...

	bsr	install_search
	bsr	back_to_low
	clr.w	-(a7)
	move.l	prog_len,-(a7)
	move.w	#$31,-(a7)
	trap	#1


quit_params:
	dc.b	"/resident",0
	dc.b	"/reset",0
	dc.b	$ff
	even


term:
	bsr	ramdisk_off
	bsr	back_to_low
	clr.w	-(a7)
	trap	#1

back_to_low:
* was I called from AUTO folder?
	cmp.b	#"n",auto_flag
	beq.s	.no

	clr.w	-(a7)
	pea	-1.w
	pea	-1.w
	move.w	#5,-(a7)
	trap	#14
	lea	12(a7),a7

	bsr	vsync

	jsr	super_on
	movem.l	old_pal,d0-7
	movem.l	d0-7,$ffff8240.w
	jsr	super_off
.no:
	rts


past_param:
* go past current parameter
* in a0
.past:
	tst.b	(a0)+
	bne.s	.past
	rts



get_next_param:
* command line in a0
* get next parameter
* d0 = 0 if ok or -1 if no more

	moveq	#0,d0
	cmp.b	#$ff,-1(a0)
	beq.s	.no
.find:
	move.b	(a0)+,d1
	beq.s	.find

	cmp.b	#$ff,d1
	bne.s	.got_next
.no:
	moveq	#-1,d0
.got_next:
	subq.l	#1,a0
	rts


zeds_to_space:
	move.l	#command_line,a0

.conv:
	move.b	(a0)+,d0
	bne.s	.not_space

	move.b	#" ",-1(a0)
.not_space:
	cmp.b	#$ff,d0
	bne.s	.conv

	clr.b	-1(a0)
	rts


test_shifts:
	move.w	#-1,-(a7)
	move.w	#11,-(a7)
	trap	#13
	addq.l	#4,a7
	rts

get_input:
	move.l	#input_line,a4
	move.b	#198,(a4)
	clr.b	1(a4)

	pea	(a4)
	move.w	#10,-(a7)
	trap	#1
	addq.l	#6,a7

	addq.l	#2,a4
	clr.b	(a4,d0.w)
	move.b	#$ff,1(a4,d0.w)
	move.w	d0,-(a7)

	print	new_line

	move.l	#input_line+2,a0
.lowerit:
	move.b	(a0),d0
	jsr	to_lower
	move.b	d0,(a0)+
	tst.b	d0
	bne.s	.lowerit

	move.w	(a7)+,d0
	rts

asc_to_bin:
* a0 = ASCII
* returns d0.l as binary number
* d1 = 0 if number ok
* or -1 if invalid number

	moveq	#0,d0
.conv:
	moveq	#0,d1
	move.b	(a0)+,d1
	beq.s	.dun_conv
	cmp.b	#$ff,d1
	beq.s	.dun_conv

	sub.b	#"0",d1
	bmi	.invalid_no

	cmp.b	#9,d1
	bgt	.invalid_no

	move.l	d0,d2
	lsl.w	#3,d0
	add.w	d2,d2
	add.w	d2,d0
	add.l	d1,d0
	bra.s	.conv
.dun_conv:
	moveq	#0,d1
	rts

.invalid_no:
	moveq	#-1,d1
	rts



	ifnd	link
	include	aes_shel.s
	include	aes_call.s
	include	bits.s
	include	gem_shel.s
	include	dialogs.s
	include	files.s
	include	maths.s
	endc

heading:
	dc.b	27,"E"
	dc.b	27,"p"
	dc.b	"*******************",10,13
	dc.b	"*    RAM LOAD     *",10,13
	dc.b	"* by James Ingram *",10,13
	dc.b	"*       1994      *",10,13
	dc.b	"*******************",10,13
	dc.b	27,"q"

	IFD	demo
	dc.b	10
	dc.b	27,"p"
	dc.b	"*** DEMO VERSION ***",27,"q",10,13
	dc.b	"Register œ5 to get the full version.",10,13
	dc.b	"Cheques ONLY, payable to:",10,13
	dc.b	"     James Ingram",10,13
	dc.b	"     c/o Chris",10,13
	dc.b	"     84 North Street",10,13
	dc.b	"     Rushden",10,13
	dc.b	"     Northamptonshire",10,13
	dc.b	"     NN10 9BU",10,13
	dc.b	10
	dc.b	27,"pALSO AVAILABLE - 68000 demo tutorial!",10,13
	dc.b	"œ5 to the same address!",27,"q",10,13,0
	ENDC


	dc.b	10,0

root:	dc.b	"\",0


clr_scrn:	dc.b	27,"E",0
back_space	dc.b	8,0

on:		dc.b	"on",0
off:		dc.b	"off",0
all_flag	dc.b	"y"

all_star:	dc.b	"*.*",0
star:		dc.b	"*.RAM",0
auto_ram:	dc.b	"auto.ram",0

ctrl_stop:	dc.b	27,"p CONTROL PRESSED... Aborting... ",27,"q",10,13,10,0
trying:		dc.b	"Attempting to load command file ",0
prompt_name:	dc.b	"Please enter name of command file:",10,13,0
file_not_found:	dc.b	27,"p File not found ",27,"q",10,13,10,0
new_line:	dc.b	10,13,0
command_not_known:	dc.b	27,"p*** COMMAND NOT KNOWN ***",27,"q",10,13,0
no_quotes:		dc.b	27,"p PRINT messages must be enclosed with quotes! ***",27,"q",10,13,0
goto_where:		dc.b	27,"p*** GOTO without label ***",27,"q",10,13,0
no_label:		dc.b	27,"p*** LABEL not found ***",27,"q",10,13,0
need_size_lett:		dc.b	27,"p*** No RAMDISK size or letter! ***",27,"q",10,13,0
invalid_num:		dc.b	27,"p*** Invalid RAMDISK SIZE ***",27,"q",10,13,0
no_letter:		dc.b	27,"p*** Invalid RAMDISK DRIVE LETTER ***",27,"q",10,13,0
mem_err:		dc.b	27,"p*** Out of memory! ***",27,"q",10,13,0
ram_already:		dc.b	27,"p*** RAMDISK already installed ***",27,"q",10,13,0
inv_ramdisk_param:	dc.b	27,"p*** Invalid RAMDISK parameter ***",27,"q",10,13,0
ramdisk_ok:		dc.b	27,"p Ramdisk Installed ",27,"q size ",0
ram_size_ok:		dc.b	"k as drive ",0
temp_char		dc.b	0,0
gosub_where:		dc.b	27,"p*** No GOSUB label! ***",27,"q",10,13,0
no_gosub:		dc.b	27,"p*** RETURN without a GOSUB ***",27,"q",10,13,0
too_many_gosubs:	dc.b	27,"p*** Too many GOSUBs! ***",27,"q",10,13,0
no_search_file:		dc.b	27,"p*** No wildcard in SEARCH command! ***",27,"q",10,13,0
no_cd:			dc.b	27,"p*** CD to what path ? ***",27,"q",10,13,0
drive_error:		dc.b	27,"p*** Error selecting drive ***",27,"q",10,13,0
path_error:		dc.b	27,"p*** Path does not exist ***",27,"q",10,13,0
path_changed:		dc.b	"Path changed to ",0
exclude_what?:		dc.b	27,"p*** EXCLUDE what? ***",27,"q",10,13,0
inval_x_param:		dc.b	27,"p*** Invalid EXCLUDE parameter ***",27,"q",10,13,0
all_what?:		dc.b	27,"p*** Turn ALL on or off? ***",27,"q",10,13,0
inv_param:		dc.b	27,"p*** Invalid parameter with WILDCARD ***",27,"q",10,13,0
no_ramdisk:		dc.b	27,"p*** No RAMDISK defined ***",27,"q",10,13,0
inv_quit_param:		dc.b	27,"p*** Invalid QUIT parameter ***",27,"q",10,13,0
file_open_error:	dc.b	27,"p*** FILE OPEN ERROR ***",27,"q ",10,13,0
create_file_error:	dc.b	27,"p*** FILE CREATE ERROR ***",27,"q ",10,13,0
write_error:		dc.b	27,"p*** FILE WRITE ERROR ***",27,"q",10,13,0
copying:		dc.b	"Copying... ",0
to:			dc.b	" to ",0
none_found:		dc.b	27,"pNo files found",27,"q",10,13,0
inv_ram_param:		dc.b	27,"p*** Turn RAM ON or OFF? ***",27,"q",10,13,0
ram_is:			dc.b	"RAMDISK searching is ",0
inv_load_param:		dc.b	27,"p*** Invalid LOAD parameter ***",27,"q",10,13,0
null:			dc.b	0
inv_run_param:		dc.b	27,"p*** Invalid RUN parameter ***",27,"q",10,13,0
run_what?:		dc.b	27,"p*** RUN what? ***",27,"q",10,13,0
run_error:		dc.b	27,"p*** ERROR RUNNING PROGRAM ***",27,"q",10,13,0
run_again?:		dc.b	27,"p RUN AGAIN? ",27,"q (Y/N) ",10,13,0
boot_where?:		dc.b	27,"p*** BOOT_FROM which drive ? ***",27,"q",10,13,0
invalid_drive:		dc.b	27,"p*** Invalid drive letter in BOOT_FROM ***",27,"q",10,13,0
booting_from:		dc.b	"Boot drive set to ",0
copy_where?:		dc.b	27,"p*** COPY to which drive ? ***",27,"q",10,13,0
invalid_drive_copy:	dc.b	27,"p*** Invalid drive letter in COPY_TO ***",27,"q",10,13,0
copying_to:		dc.b	"Copying drive set to ",0
ask_intro:		dc.b	27,"p ASK MODE ",27,"q",10,13
			dc.b	'Type "STOP" to leave ASK MODE or "HELP" for help',10,13,10,0
ask_prompt:		dc.b	27,"pASK>",27,"q ",0
inval_pause:		dc.b	27,"p*** Invalid PAUSE length ***",27,"q",10,13,0
no_such_dir:		dc.b	27,"p Invalid Directory ",27,"q",10,13,0
trying_auto_ram:	dc.b	27,"p Trying to load AUTO.RAM ",27,"q",10,13,0
no_auto_ram:		dc.b	"AUTO.RAM does not exist.",10,13,0
more:			dc.b	27,"pMore..........",27,"q",13,0
load_what?:		dc.b	27,"p*** LOAD what? ***",27,"q",10,13,0
no_files_found:		dc.b	"*** no files found ***",10,13,10,0
loop_file_only:		dc.b	27,"p*** Loops can only be used from a file! ***",27,"q",10,13,0
if_file_only:		dc.b	27,"p*** IFs can only be used from a file! ***",27,"q",10,13,0
not_a_repeat:		dc.b	27,"p*** UNTIL without REPEAT ***",27,"q",10,13,0
eval_error:		dc.b	27,"p*** Error in phrase ***",27,"q",10,13,0
k:			dc.b	"k",0
dir_of:
	dc.b	10,13
	dc.b	27,"p DIRECTORY ",27,"q",10,13
	dc.b	0
out_of_mem:	dc.b	27,"p*** Out of Memory! ***",27,"q",10,13,0
excluded:	dc.b	27,"p EXCLUDED ",27,"q",10,13,0
mem_free:	dc.b	"Largest free memory block is: ",0
numeric_error:	dc.b	27,"p*** Error in NUMERIC expression ***",27,"q",10,13,0
str_error:	dc.b	27,"p*** Error in STRING expression ***",27,"q",10,13,0
no_end_while:	dc.b	27,"p*** No END-WHILE command! ***",27,"q",10,13,0
not_a_while:	dc.b	27,"p*** END-WHILE without WHILE ***",27,"q",10,13,0
no_end_if:	dc.b	27,"p*** No END-IF command! ***",27,"q",10,13,0
else_no_if:	dc.b	27,"p*** ELSE without IF ***",27,"q",10,13,0
end_no_if:	dc.b	27,"p*** END-IF without IF ***",27,"q",10,13,0
flash_what?:	dc.b	27,"p*** FLASH on or off? ***",27,"q",10,13,0
flash_on:	dc.b	"FLASHING ",27,"p ON ",27,"q",10,13,0
flash_off:	dc.b	"FLASHING ",27,"p OFF ",27,"q",10,13,0
in_ask_mode:	dc.b	27,"p*** In ASK mode already! ***",27,"q",10,13,0
switch_how:	dc.b	27,"p*** How shall I SWITCH? ***",27,"q",10,13,0

	IFD	demo
not_demo:	dc.b	27,"pCommand not available in DEMO version.",27,"q",10,13
		dc.b	"Upgrade!",10,13,0
	ENDC


last_update:
	dc.b	"Last update",10,13
	dc.b	"Date: ",0

date_dc:
	date

time_txt:
	dc.b	10,13,"Time: ",0
time_dc:
	time

inp_com:	dc.b	200,0
input_command:	ds.b	200

space17	dc.b	" "
space16	dc.b	" "
space15	dc.b	" "
space14	dc.b	" "
space13	dc.b	" "
space12	dc.b	" "
space11	dc.b	" "
space10	dc.b	" "
space9	dc.b	" "
space8	dc.b	" "
space7	dc.b	" "
space6	dc.b	" "
spaces:	dc.b	" "
space4	dc.b	" "
space3	dc.b	" "
space2	dc.b	" "
space1	dc.b	" "
	dc.b	0
s_o_line	dc.b	13,0


	even

my_pal:
	dc.w	$fff
	ds.w	15

input_mode	dc.b	"file"

gosub_list	dc.l	gosubs
no_of_gosubs	dc.w	0


	section	bss
bss:

quote_flag	ds.b	1
auto_flag	ds.b	1
eof		ds.b	1
eol		ds.b	1
text		ds.b	1
label_found	ds.b	1
error		ds.b	1
temp_all	ds.b	1
full_path	ds.b	1
resident	ds.b	1
run_loop	ds.b	1
exists		ds.b	1
found_name	ds.b	15
	even

copy_to_drive	ds.w	1

text_addr	ds.l	1
text_len	ds.l	1
process_addr	ds.l	1
process_len	ds.l	1
last_addr	ds.l	1
last_len	ds.l	1


label_addr	ds.b	50

input_line	ds.b	200
input_char	ds.w	1
command_line	ds.b	512

prog_command	ds.l	1
env	ds.b	2
prog_line	ds.b	260


load_buf:	ds.b	100

exclude_all:
	ds.w	1	; spaces remaining in this block
	ds.l	1	; pointer to next block
	ds.b	14*wilds_per_block	; wildcards

wild_addr	ds.l	1
wild_path	ds.b	512
card		ds.b	14


exclude_temp:
	ds.w	1	; spaces remaining in this block
	ds.l	1	; pointer to next block
	ds.b	14*wilds_per_block	; wildcards


	ds.l	100*2
gosubs:
	ds.l	2

folder_list	ds.b	200
temp_path	ds.b	512
end_bss:
*********************************************
dir_card:	ds.b	150
exp_buffer:	ds.b	150
num_num:	ds.w	1	; the current option number (help mode printing page)
while_count:	ds.w	1	; the no of while loops found within one which is terminating

loop_ptr:	ds.l	1
loops:		ds.b	loop_len*max_loops

prog_len	ds.l	1
old_pal:	ds.b	32

	ds.b	1000
stack:

