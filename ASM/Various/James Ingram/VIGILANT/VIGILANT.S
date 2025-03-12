* VIGILANTE
*  by James Ingram, 1993

* This is a DESK ACCESSORY!

* recognises & can kill (in memory and on disk)
*	Signum/BPL
*	Ghost
*	Goblin
*	KOBOLD
*	Anti-virus
*	My hdv_bpb
*	My reset-1
*	My reset-2
*	My Virus2

* Harmless bootsectors recognised:
*	AVK protection
*	FCOPY PRO
*	Medway boys II
*	Medway Boys III



no_recog	equ	10	; number of viruses recognised
recog_mine	equ	1

;labels	equ	1

;acc_test	equ	1

link	equ	1

no_of_trees	equ	9


	IFND	link
		IFD	am_acc
		OUTPUT	vigilant.acc
		ENDC
	ENDC


	IFD	link
	OPT	GST,CASE

	XREF	init_appl,ap_id,do_load_rsc,aes
	XREF	add_to_desk_menu,wait_for_message
	XREF	get_tree_data,hide_obj,put_text_dialog
	XREF	show_obj,disable_obj,new_default,enable_obj
	XREF	draw_exp_box_tree,hand_dialog,button_number
	XREF	button_off,draw_con_box_tree
	XREF	open_some,read_some,seek_some,close_some,save_some
	XREF	preselect_radio,find_radio_selected
	XREF	file_selector,restore_path
	XREF	get_drive,mouse_arrow
	XREF	clean_up_appl
	ENDC


	ifd	labels
	opt	x+
	endc

	opt	o+,ow-

flag	macro
	move.l	#"VIGI",(a0)
	move.l	#\1,4(a0)
	endm


	include	aes_defs.i
	include	vdi_defs.i
	include	xbiosdef.i



start:
	ifd	acc_test
	illegal
	endc


	bra.s	past_opts

in_len	equ	*-start


flag:
	dc.b	"VIGI"
	dc.b	"LANT"
	dc.b	"V1.0"
flag_len	equ	*-flag

options:

* NB! 0 is ON!

red		dc.b	0	; red flash for known virus
yellow		dc.b	0	; yellow flash for unknown
auto_kill	dc.b	0	; auto-kill viruses
long_chk	dc.b	1	; long check
auto_chk	dc.b	0	; check automatically on boot-up
hex_text	dc.b	0	; 0 = text view

options_len	equ	*-options

	even



past_opts:
	sf	in_hdv

	move.w	#"PR",run_type

	move.l	a7,d0
	bne.s	.not_acc

* I am an accessory!
	move.w	#"AC",run_type

.not_acc:
	cmp.w	#"PR",run_type
	bne.s	.dont_release

* release memory only if running as PRG
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

* If I am running as a prog, then I also change the mouse pointer to an arrow

	bsr	mouse_arrow


.dont_release:
	move.l	#stack,a7

	bsr	init_appl	; always innitialise application

	cmp.w	#"PR",run_type
	beq.s	.no_reg

* register myself on the Desk menu

	lea	menu_txt(pc),a0
	bsr	add_to_desk_menu

	move.w	d0,menu_id


.no_reg:
	bsr	get_rsc

* no error loading .RSC file.  If I am a program, then do menu stuff.
* but if I am a .ACC, then register on desk menu and wait...

	cmp.w	#"PR",run_type
	bne.s	i_am_acc

* Is the auto-check on?
	tst.b	auto_chk
	bne.s	.no_auto

	bsr	reserve_scrn
	bsr	do_mem
	bsr	free_scrn

.no_auto:
	bsr	do_vigilante	; call main routine

	bsr	clean_up_appl

	clr.w	-(a7)
	trap	#1		; and quit to desktop

i_am_acc:

	sf	startup_flag	; I am starting up now...
	sf	inf_flag	; clean infection flag

	tst.b	auto_chk
	bne.s	.no_auto

	cmp.w	#"ER",run_type
	beq.s	.no_auto	; don't do AUTO check if I haven't got RSC

	bsr	reserve_scrn
	bsr	do_mem
	bsr	free_scrn

.no_auto:
	st	startup_flag

	pea	chng_vec(pc)
	move.w	#38,-(a7)
	trap	#14		; install hdv_bpb monitor
	addq.l	#6,a7

acc_loop:
* now wait for something to happen
	bsr	wait_for_message

	cmp.w	#40,(a0)	; open message?
	bne.s	acc_loop	; no - keep looking


* I have been selected!
	cmp.w	#"ER",run_type
	bne.s	.no_error

* RSC file was not found!
	bsr	get_rsc		; try to get RSC file again

	cmp.w	#"ER",run_type
	beq.s	acc_loop	; and loop if error occurred again

.no_error:
	bsr	do_vigilante

	bra.s	acc_loop

	

get_rsc:
* load in the .RSC file
* and cope with not found error
* for PRG and ACC

* first get the drive I am on...
	bsr	get_drive

	lea	rsc_name(pc),a0
	add.b	#"A",d0
	move.b	d0,(a0)

* now RSC name has full path (.ACC only)

* for a PRG type, we must ignore the "X:\"
	cmp.w	#"PR",run_type
	bne.s	.not_prg

	lea	3(a0),a0

.not_prg:
	lea	centre_list(pc),a1
	moveq	#no_of_trees,d7

	bsr	do_load_rsc	; load up .RSC file


	move.w	run_type,d1	; get current run-type

	tst.w	d0
	bpl	.no_rsc_err

* error loading resource file!

	lea	rsc_name(pc),a0
	cmp.b	#"A",(a0)	; was I trying drive A?
	beq.s	.a

* no!
	move.b	#"A",(a0)
	bra.s	.not_prg	; try again for drive A

.a:
	move.w	run_type,d0
	move.w	#"ER",run_type

* now terminate if I am a PRG file
	cmp.w	#"PR",d0
	bne.s	.no_prg_err

	clr.w	-(a7)
	trap	#1

.no_prg_err:
* error with accessory!
	rts


.no_rsc_err:
	cmp.w	#"ER",d1		; was old type an error?
	bne.s	.not_second		; branch if not

	move.w	#"AC",run_type		; else I am a normal .ACC now

.not_second:
* now get largest rect possible

	moveq	#0,d0
	bsr	get_tree_data
	movem.w	d0-d3,smallx	; put in 1st tree's co-ords

	moveq	#1,d7		; start with 2nd tree

get_largest:
	move.w	d7,-(a7)
	move.w	d7,d0
	bsr	get_tree_data

	lea	smallx(pc),a0
	movem.w	(a0),a1-a4
	movem.w	a1-a4,8(a0)	; copy co-ords

	cmp.w	(a0),d0
	bge.s	.not_smaller	; branch if this x smaller

	move.w	d0,8(a0)	; else use it

.not_smaller:
	cmp.w	2(a0),d1
	bge.s	.not_smaller2

	move.w	d1,10(a0)

.not_smaller2:
* have compared X and Y!
* comparing width & height involves adding them on to their X and Ys!

	move.w	4(a0),d6
	add.w	(a0),d6		; get old end X co-ord

	add.w	d2,d0		; and new one

	cmp.w	d6,d0
	ble.s	.not_bigger

	move.w	d2,12(a0)

.not_bigger:
	move.w	6(a0),d6
	add.w	2(a0),d6

	add.w	d3,d1
	cmp.w	d6,d1
	ble.s	.not_bigger2

	move.w	d3,14(a0)

.not_bigger2:
	movem.w	8(a0),a1-4	; get new co-ords
	movem.w	a1-4,(a0)	; and slap 'em in!



	move.w	(a7)+,d7
	addq.w	#1,d7
	cmp.w	#no_of_trees,d7
	bne.s	get_largest

	rts


reserve_scrn:
* reserve screen for my boxes
	moveq	#0,d0		; reserve code

	movem.w	smallx,d1-d4
	movem.w	d1-d4,-(a7)
	movem.w	(a7)+,d5-d7	; co-ords 2

	move.w	#begin_or_end_dialog,-(a7)
	bsr	aes

	rts

do_vigilante:

	bsr	reserve_scrn

* has an infection been detected and not dealt with?
	tst.b	inf_flag
	beq.s	menu_loop	; branch to main loop if not

	bsr	not_start	; else call the routines to deal with infections

	sf	inf_flag	; and infected flag is set to clean

menu_loop:
	moveq	#1,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	dialog		; do menu dialog

	cmp.w	#3,d0
	beq	scan_memory

	cmp.w	#4,d0
	beq	drive_a

	cmp.w	#5,d0
	beq	drive_b

	cmp.w	#6,d0
	beq	config

* must be QUIT!


free_scrn:
* free screen

	moveq	#3,d0		; free code

	movem.w	smallx,d1-d4
	movem.w	d1-d4,-(a7)
	movem.w	(a7)+,d5-d7	; co-ords 2

	move.w	#begin_or_end_dialog,-(a7)
	bsr	aes
	rts

scan_memory:
	bsr	do_mem
	bra	menu_loop


do_mem:
	moveq	#3,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	d_tree

	pea	check_memory(pc)
	move.w	#38,-(a7)
	trap	#14
	addq.l	#6,a7

* Am I just starting up?
	tst.b	startup_flag
	bne.s	not_start

* yes!
* so give one of the startup messages...

	moveq	#6,d0		; assume clean message

	lea	vir_list(pc),a5
	tst.l	(a5)
	bmi.s	.clean

	st	inf_flag	; dirty infected flag
	moveq	#7,d0

.clean:
	moveq	#0,d1
	moveq	#0,d2
	bsr	d_tree		; show alert message

* now pause for 2 secs
	moveq	#100-1,d7

	dc.w	$a000
	lea	-348(a0),a6		; get mouse buttons addr

	move.b	(a6),d6		; get mouse button status
.wait:
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7

	move.w	#$ff,-(a7)
	move.w	#6,-(a7)
	trap	#1
	addq.l	#4,a7

	tst.w	d0
	bne.s	.key


	move.b	(a6),d5		; get button status
	btst	#0,d5
	bne.s	.butt_down

* button is up!
	bclr	#0,d6
	bra.s	.no_butt

.butt_down:
	btst	#0,d6
	bne.s	.no_butt	; branch if button not yet been up

* button has gone down (again)!
	bra.s	.key

.no_butt:
	dbra	d7,.wait

.key:
	rts


not_start:
	lea	vir_list(pc),a5
* a5 returns with virus list!
	tst.l	(a5)
	bmi	sys_clean

kill_loop:
* get virus type
	move.l	(a5)+,d0

* get data from list
	lea	vir_codes(pc),a1

get_one_kill:
	move.l	(a1)+,d1	; get flag
	sub.l	d0,d1		; test it
	beq.s	got_one_kill	; branch out if got one!

	addq.l	#8,a1
	bra.s	get_one_kill

got_one_kill:
	move.l	(a1)+,a0	; get addr of kill routine
	move.l	(a1)+,a1	; and addr of text srting

	exg.l	a0,a1

	movem.l	a0/a1/a5,-(a7)	; store all addrs

	pea	(a0)

	tst.w	4(a5)		; is this viruses' reset-flag set?
	bne.s	.no_destroy	; if so, branch round

	moveq	#4,d0
	moveq	#11,d1
	bsr	hide_obj	; hide reset-vector text
.no_destroy:

	move.l	(a7)+,a0

	moveq	#4,d0		; tree number for alert
	moveq	#7,d1		; obj no of text
	bsr	put_text_dialog


* display virus dialog box
	moveq	#4,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	dialog

	move.w	d0,-(a7)
	moveq	#4,d0
	moveq	#11,d1
	bsr	show_obj	; show reset-vector text
	move.w	(a7)+,d0

	movem.l	(a7)+,a0/a1/a5	; get back all addrs

	cmp.w	#12,d0
	bne	no_kill		; branch if leaving it!


	move.l	(a5),vir_addr	; get addr of virus

	pea	(a1)
	move.w	#38,-(a7)
	trap	#14		; call kill-virus routine
	addq.l	#6,a7



no_kill:
* go past this virus
	addq.l	#6,a5


kill_rej:
	tst.l	(a5)
	bmi	end_mem

	bra	kill_loop




sys_clean:
* no viruses in memory!
	moveq	#5,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	dialog

end_mem:
	rts


config:
* install the current options into the dialog

	lea	options(pc),a6
	moveq	#2,d0		; tree 2

	lea	red_list(pc),a0
	moveq	#7,d1		; assume ON

	tst.b	(a6)+
	beq.s	.red

	moveq	#8,d1		; actually off!
.red:
	movem.l	a6/d0,-(a7)
	bsr	preselect_radio
	movem.l	(a7)+,a6/d0

	lea	yellow_list(pc),a0
	moveq	#11,d1		; assume ON

	tst.b	(a6)+
	beq.s	.yellow

	moveq	#12,d1		; actually off!
.yellow:
	movem.l	a6/d0,-(a7)
	bsr	preselect_radio
	movem.l	(a7)+,a6/d0

	lea	auto_list(pc),a0
	moveq	#15,d1		; assume ON

	tst.b	(a6)+
	beq.s	.auto

	moveq	#16,d1		; actually off!
.auto:
	movem.l	a6/d0,-(a7)
	bsr	preselect_radio
	movem.l	(a7)+,a6/d0

	lea	long_list(pc),a0
	moveq	#19,d1		; assume ON

	tst.b	(a6)+
	beq.s	.long

	moveq	#20,d1		; actually off!
.long:
	movem.l	a6/d0,-(a7)
	bsr	preselect_radio
	movem.l	(a7)+,a6/d0

	lea	bootup_list(pc),a0
	moveq	#23,d1		; assume ON

	tst.b	(a6)+
	beq.s	.bootup

	moveq	#24,d1		; actually off!
.bootup:
	movem.l	a6/d0,-(a7)
	bsr	preselect_radio
	movem.l	(a7)+,a6/d0


	moveq	#2,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	dialog

* was cancel selected?
	cmp.w	#27,d0
	beq	menu_loop

* SAVE or OK was selected, so we MUST save the options back
* to me (in RAM) whatever!

	move.w	d0,-(a7)

	lea	options(pc),a6
	moveq	#2,d0

get	macro
	lea	\1(pc),a0

	movem.l	d0/a6,-(a7)
	bsr	find_radio_selected
	movem.l	(a7)+,d0/a6

	move.b	d1,(a6)+
	endm

	get	red_list
	get	yellow_list
	get	auto_list
	get	long_list
	get	bootup_list




	move.w	(a7)+,d0
	cmp.w	#26,d0		; was OK selected?
	beq	menu_loop	; branch if it was

* save the options!
	lea	progname(pc),a0
	cmp.w	#"PR",run_type
	beq.s	.is_prog

	lea	accname(pc),a0
.is_prog:
	bsr	file_selector

	cmp.w	#"AC",run_type
	bne.s	.dont_res

* If I am a desktop Accessory, then when the file selector has been done
* I must reserve and then free the screen again.
* This gets rid of a bug which is present with some replacement
* file selectors.
* The normal GEM file selector does not need this!

	movem.l	a0/d0,-(a7)
	bsr	reserve_scrn
	bsr	free_scrn
	movem.l	(a7)+,d0/a0

.dont_res:
	tst	d0
	bpl.s	no_cancel

* cancel was selected
end_save:
	bsr	restore_path	; go back to path I was on before

* now I have to decide what to do!
	cmp.w	#"PR",run_type
	beq	menu_loop	; If I am a program then loop to main menu

	rts	; else leave menu because of screen corruption left by file selector


no_cancel:
* Something was selected from file selector!

* file name is in a0
	bsr	open_some
	tst.l	d0
	bmi.s	end_save


* now clear the flag in bss
	lea	flag_buff(pc),a6
	moveq	#flag_len-1,d0
.clr:
	clr.b	(a6)+
	dbra	d0,.clr

* now seek the flag position in the file
	moveq	#0,d0		; from start
	moveq	#$1c+in_len,d1	; plus code up to flag
	bsr	seek_some

* now read flag length in
	moveq	#flag_len,d0
	lea	flag_buff(pc),a0
	bsr	read_some

	tst.l	d0
	bmi.s	.read_error

* read in the flag - but does it match?
	lea	flag_buff(pc),a0
	lea	flag(pc),a1
	moveq	#flag_len-1,d0

.cmp:
	cmpm.b	(a0)+,(a1)+
	bne.s	.not_flag
	dbra	d0,.cmp

* flags match perfectly!
* so now save the options out...

	lea	options(pc),a1
	moveq	#options_len,d0
	bsr	save_some
	bra.s	.read_error

.not_flag:
* wrong file!
	alert	#1,wrong_file

.read_error:
	bsr	close_some
	

	bra	end_save


red_list:
	dc.w	7,8,-1
yellow_list:
	dc.w	11,12,-1
auto_list:
	dc.w	15,16,-1
long_list:
	dc.w	19,20,-1
bootup_list:
	dc.w	23,24,-1

progname:
	dc.b	"*.PRG",0
accname:
	dc.b	"*.ACC",0

wrong_file:
	exclam
	dc.b	"[The file you selected was not |"
	dc.b	"VIGILANTE V1.0!]"
	dc.b	"[  Ah  ]",0

	even


drive_a:
	moveq	#0,d0
	bsr	check_disk
	bra.s	dun_disk

drive_b:
	moveq	#1,d0
	bsr	check_disk

dun_disk:
* regs here are:
* d0 = specific type or ????
* d1 = 0 (not exec)  LESS or VIRS
* a4 = text name

	movem.l	d0-1/a4,types

	move.l	d0,-(a7)	; keep specific type
	move.l	d1,-(a7)	; keep type

	move.l	a4,a0
	moveq	#0,d0		; tree 0
	moveq	#8,d1
	bsr	put_text_dialog	; put boot name into dialog

	move.l	4(a7),d0
	cmp.l	#"????",d0
	bne	not_unk

* unknown bootsector type!
* comment line is warning!
	lea	unk_warn(pc),a0
	moveq	#0,d0
	moveq	#9,d1
	bsr	put_text_dialog

* type line is executable
	lea	type_exec(pc),a0
	moveq	#0,d0
	moveq	#6,d1
	bsr	put_text_dialog

* disable the EXEC option
	moveq	#0,d0
	moveq	#14,d1
	bsr	disable_obj

* make "do nothing" the default button
	moveq	#0,d0
	moveq	#12,d1
	moveq	#11,d2
	bsr	new_default


	bra	dun_prepare


not_unk:
	move.l	(a7),d1		; get type back

	cmp.l	#"VIRS",d1
	bne.s	.not_virs

* comment line is should destroy!
	lea	destroy(pc),a0
	moveq	#0,d0
	moveq	#9,d1
	bsr	put_text_dialog

* type line is virus
	lea	infected(pc),a0
	moveq	#0,d0
	moveq	#6,d1
	bsr	put_text_dialog

* disable the EXEC option
	moveq	#0,d0
	moveq	#14,d1
	bsr	disable_obj

	bra.s	dun_prepare

.not_virs:
* bootsector is harmless.

* put "HARMLESS" in type text
	moveq	#0,d0
	moveq	#6,d1
	lea	ok_boot(pc),a0
	bsr	put_text_dialog

* make "do nothing" the default button
	moveq	#0,d0
	moveq	#12,d1
	moveq	#11,d2
	bsr	new_default


	moveq	#0,d0
	moveq	#9,d1
	bsr	hide_obj	; hide comment line

	move.l	4(a7),d0	; get specific type again

	cmp.l	#"UNEX",d0
	bne.s	.unexec_available

* If I am an UNEXEC, then disable the option

	moveq	#0,d0
	moveq	#13,d1
	bsr	disable_obj
	bra.s	dun_execs

.unexec_available:
* disable the EXEC option, as the boot is already exec!

	moveq	#0,d0
	moveq	#14,d1
	bsr	disable_obj

	move.l	4(a7),d0	; get type again
	tst.l	d0
	bne	dun_execs

* Harmless non-booting not-unexec
* so we don't need UNEXEC either!

	moveq	#0,d0
	moveq	#13,d1
	bsr	disable_obj


dun_execs:

dun_prepare:
	addq.l	#8,a7


	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	dialog

	move.w	d0,-(a7)

* restore everything!

	moveq	#0,d0
	moveq	#11,d1
	moveq	#12,d2
	bsr	new_default	; protect is default again


	moveq	#0,d0
	moveq	#9,d1
	bsr	show_obj	; show comment line again

	moveq	#0,d0
	moveq	#13,d1
	bsr	enable_obj	; enable unexec again

	moveq	#0,d0
	moveq	#14,d1
	bsr	enable_obj	; enable exec again

	move.w	(a7)+,d0	; get exit obj

	cmp.w	#11,d0
	beq	protect_disk	; protect

	cmp.w	#12,d0
	beq	menu_loop	; do nothing

	cmp.w	#13,d0
	beq	unexec_disk	; unexec

	cmp.w	#14,d0
	beq	exec_disk	; exec

* VIEW selected!
* no offset as yet...
	clr.w	boot_off


view_loop:
* put the data from the bootsector into the dialog box
* but is it in hex or text form?

	lea	boot_sec(pc),a6
	lea	line_objs(pc),a3
	lea	view_lines(pc),a5
	moveq	#16-1,d6	; 16 lines to put in


	tst.b	hex_text
	beq	show_text

* put HEX into the dialog box.
* convert 1 line at a time (8 words per line)

	moveq	#0,d0
	move.w	boot_off,d0
	add.l	d0,a6		; add offset for hex mode ONLY!

.all_lines:
	lea	hex_chars(pc),a4
	pea	(a5)


	moveq	#8-1,d7		; 8 words per line
.line:

	move.w	(a6)+,d3	; get a word
	moveq	#4-1,d1		; 4 nybbles

.word:
	rol.w	#4,d3		; get leftmost nybble
	moveq	#0,d0
	move.b	d3,d0
	and.b	#$f,d0

	move.b	(a4,d0.w),d0	; get hex char
	move.b	d0,(a5)+

	dbra	d1,.word

	move.b	#" ",(a5)+	; a space now
	dbra	d7,.line

* last word has no space!
	clr.b	-(a5)
	move.l	(a7),a0

	moveq	#8,d0		; tree no
	move.w	(a3)+,d1	; object no
	bsr	put_text_dialog	; put the line into the dialog box

	move.l	(a7)+,a5
	lea	40(a5),a5


	dbra	d6,.all_lines
	bra	dun_putting


show_text:
* show the bootsector as text

.all_lines:
	pea	(a5)

* put in 3 spaces at start of each line
	move.b	#" ",(a5)+
	move.b	#" ",(a5)+
	move.b	#" ",(a5)+



	moveq	#32-1,d7	; chars per line
.line:

	move.b	(a6)+,d0	; get a char
	bne.s	.not_zed

* zero!
	moveq	#".",d0		; show a 0 as a "."

.not_zed:
	move.b	d0,(a5)+
	dbra	d7,.line

	clr.b	(a5)

	move.l	(a7),a0
	moveq	#8,d0
	move.w	(a3)+,d1
	bsr	put_text_dialog

	move.l	(a7)+,a5
	lea	40(a5),a5


	dbra	d6,.all_lines


dun_putting:
	moveq	#8,d0
	moveq	#0,d1
	moveq	#0,d2
	bsr	dialog

* how have we come out?
	cmp.w	#18,d0
	beq	view_up

	cmp.w	#19,d0
	beq	view_down

	cmp.w	#22,d0
	beq	view_text

	cmp.w	#23,d0
	beq	view_hex

* OK clicked!

	movem.l	types,d0-1/a4
	bra	dun_disk

view_text:
	sf	hex_text
	bra	view_loop

view_hex:
	st	hex_text
	bra	view_loop

view_up:
	lea	boot_off(pc),a0
	move.w	(a0),d0
	sub.w	#256,d0
	bmi	view_loop

	move.w	d0,(a0)
	bra	view_loop

view_down:
	lea	boot_off(pc),a0
	move.w	(a0),d0
	add.w	#256,d0
	cmp.w	#512,d0
	beq	view_loop	; change nothing if at end

	move.w	d0,(a0)
	bra	view_loop


line_objs:
	dc.w	2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17


protect_disk:
	bsr	do_prot
	bra	menu_loop


do_prot:
* install AVK-type protection on disk

	lea	boot_sec2(pc),a0
	pea	(a0)

	move.w	#$6038,(a0)

	move.w	#"Nu",$3a(a0)

* now copy the bpb data from old bootsec to new

	lea	boot_sec(pc),a1
	addq.l	#2,a1
	addq.l	#2,a0

	move.w	#17-1,d0
.copy:
	move.w	(a1)+,(a0)+
	dbra	d0,.copy	; copy BPB of disk


	move.l	(a7),a0
	bsr	get_flag

	move.w	d0,(a0)

	move.l	(a7)+,a0
	bsr	write_sec
	rts



unexec_disk:
* make disk unexecutable

	lea	boot_sec(pc),a0
	cmp.w	#"JI",510(a0)
	beq.s	.do_JD

	move.w	#"JI",510(a0)
	bra.s	.dun_JD

.do_JD:
	move.w	#"JD",510(a0)
.dun_JD:
	lea	boot_sec(pc),a0
	bsr	write_sec
	bra	menu_loop


exec_disk:
* make disk exec again!
	lea	boot_sec(pc),a0
	pea	(a0)

	bsr	get_flag

	move.w	d0,(a0)

	move.l	(a7)+,a0
	bsr	write_sec
	bra	menu_loop



get_flag:
	moveq	#0,d1
	move.w	#$fe,d0

.add:
	add.w	(a0)+,d1
	dbra	d0,.add

	move.w	#$1234,d0
	sub.w	d1,d0
	rts


write_sec:
* write sector at addr a0

.write_loop:
	pea	(a0)		; keep it safe...

* now try to write it
	move.w	#1,-(a7)	; count
	clr.l	-(a7)		; side 0 track 0
	move.w	#1,-(a7)	; sector 1
	move.w	dev,-(a7)	; device
	clr.l	-(a7)
	pea	(a0)
	move.w	#9,-(a7)
	trap	#14
	lea	20(a7),a7

	tst.l	d0
	bpl.s	.write_ok	; branch if write ok

* WRITE ERROR!
	tst.b	in_hdv
	bne.s	.no_alert	; branch out if I am in th hdv_bpb vector now

	alert	#1,write_error

	move.l	(a7)+,a0

	cmp.w	#1,d0
	beq.s	.write_loop
	rts

.no_alert:
* cannot display error message!
* so flash instead...


	moveq	#25-1,d7

.flash:
	move.w	#37,-(a7)
	trap	#14
	addq.l	#2,a7

	eor.w	#$0ff,$ffff8240.w
	dbra	d7,.flash


.write_ok:
	move.l	(a7)+,a0
	rts





dialog:
* do everything from start to finish to handle a dialog box
* except reserve & free screen areas
* tree no passed in d0
* editable obj passed in d1
* box flag in d2 (0 = no box drawn)

* RETURNS:
*	d0 = exit box no
*	d1 = double click flag

	move.w	d2,-(a7)
	move.w	d1,-(a7)
	move.w	d0,-(a7)

	tst.w	d2
	beq.s	no_exp_box

	bsr	draw_exp_box_tree

no_exp_box:
	move.w	(a7),d0
	bsr	d_tree		; draw tree area on screen

	move.w	(a7),d0
	move.w	2(a7),d1	; get editable obj no in d1
	bsr	hand_dialog	; do the dialog handling...

* button returned in d0
	move.w	d0,button_number

	bclr.l	#15,d0		; get rid of double click bit

	move.w	(a7),d1
	bsr	button_off


	move.w	(a7),d0
	move.w	4(a7),d2	; get box flag back

	tst.w	d2
	beq.s	no_con_box

	bsr	draw_con_box_tree

no_con_box:
	addq.l	#6,a7

	move.w	button_number,d0	; return the button number dialog exited by
	moveq	#0,d1		; no double click
	btst	#15,d0
	beq.s	no_d_c

	moveq	#1,d1		; double click!
no_d_c:
	bclr	#15,d0
	rts

d_tree:
* tree no passed in d0
* first reserve the space!

	bsr	get_tree_data


	movem.w	d0-d3,-(a7)
	movem.w	(a7)+,d2-d5	; get co-ords back in correct regs for call

	moveq	#0,d0		; from 1st object
	move.w	#200,d1		; depth 200

	move.w	#draw_an_object_tree,-(a7)
	bsr	aes		; tree is now drawn!
	rts



chng_vec:
	move.l	$472.w,jump_to+2
	move.l	#my_472,$472.w

	move.l	$84.w,old_trap+2
	move.l	#my_trap,$84.w

	rts

my_trap:
* keep a watch out!
* if a call is made to free memory starting from the basepage
* of the accessory, then I am being shut down!
* so I must change the vectors back to how they were!

	move.l	a7,a0
	btst	#5,(a7)
	bne.s	.super

	move.l	usp,a0
	subq.l	#6,a0

.super:
	addq.l	#6,a0
	cmp.w	#$49,(a0)
	bne.s	old_trap

* $48 call made!
	cmp.l	#start-$100,2(a0)
	bne.s	old_trap

* I am being disabled!
* so put vectors back to how they were!
	move.l	jump_to+2,$472.w
	move.l	old_trap+2,$84.w

old_trap:
	jmp	$12345678


my_472:
	st	in_hdv

	move.w	$ffff8240.w,colour

	link	a6,#0
	movem.l	d0-7/a0-5,-(a7)

	move.w	8(a6),d0	; get drive no
	and.w	#$fe,d0
	bne	not_ab		; branch if not A or B

* it IS A or B!!!
	bsr	check_disk

	cmp.l	#"LESS",d1
	beq.s	.harmless

	cmp.l	#"????",d0
	bne.s	.got_virus

* unknown bootsector!
	tst.b	yellow
	bne.s	not_ab		; branch if yellow is disabled

	eor.w	#$00f,$ffff8240.w
	bra.s	not_ab

.got_virus:
* VIRUS FOUND!!!
	tst.b	red
	bne.s	.not_red	; branch if red is diasabled

	eor.w	#$0ff,$ffff8240.w

.not_red:
	tst.b	auto_kill
	bne.s	not_ab		; branch if no auto-kill

* automatically kill the virus!
	bsr	do_prot
	bra.s	not_ab

.harmless:
not_ab:
	movem.l	(a7)+,d0-7/a0-5
	move.w	8(a6),-(a7)

jump_to:
	jsr	$12345678
	move.w	colour,$ffff8240.w
	unlk	a6

	sf	in_hdv
	rts

colour:
	ds.w	1


check_disk:
* enter with d0 = drive number
* returns d0 = 0 - not exec
* or "LESS" for harmLESS and d1 = type, a4 = text name
* or "VIRS" for VIRuS and d1 = type and a4 = text string of name

	move.w	d0,dev

	move.w	#1,-(a7)	; count
	clr.l	-(a7)		; side 0 track 0
	move.w	#1,-(a7)	; sector 1
	move.w	d0,-(a7)	; device
	clr.l	-(a7)
	pea	boot_sec(pc)
	move.w	#8,-(a7)
	trap	#14
	lea	20(a7),a7

	tst.l	d0
	bpl.s	no_read_err


* error
	move.l	#"LESS",d1
	moveq	#0,d0		; 0 in d0
	rts

no_read_err:
	lea	boot_sec(pc),a5

	move.l	a5,a0
	move.w	#$ff,d0
	moveq	#0,d1

.add:
	add.w	(a0)+,d1
	dbra	d0,.add

	sub.w	#$1234,d1
	beq.s	boot_exec

* bootsector not executable - harmless!
	move.w	510(a5),d1		; get exec flag

	move.l	#"UNEX",d0
	lea	un_exec(pc),a4

	cmp.w	#"JI",d1	; keep exec flag as type-flag
	beq.s	.mine

	cmp.w	#"JD",d1
	beq.s	.mine

	moveq	#0,d0		; not MY unexec, so 0 for not executable
	lea	non_exec(pc),a4	; and non-exec string

.mine:
	move.l	#"LESS",d1
	rts

boot_exec:
* bootsector is executable!!!!!

	lea	harmless(pc),a0		; get list of harmless bootsectors
	bsr	do_checks

	tst.w	d0
	bne.s	found_boot		; branch if was a match in the list


	lea	viruses(pc),a0
	bsr	do_checks		; check for viruses

	tst.w	d0
	bne.s	found_boot

	move.l	#"????",d0		; unknown executable bootsector!
	lea	type_unk(pc),a4

found_boot:
	rts


harmless:
	dc.b	"LESS"		; code for "HARMLESS"

****************************
	dc.l	"AVK!"	; AVK protection
	dc.l	avk_prot	; addr of related text string

	dc.b	"BR"	; check 1st word
	dc.w	$6038	; should be $6038

	dc.b	"WD"	; check a word
	dc.w	$3a	; at offset $3a
	dc.b	"Nu"	; should be "rts"

	dc.w	0

*********************************

	dc.l	"FCOP"	; FCOPY protection
	dc.l	fcopy

	dc.b	"BR"
	dc.w	$6038

	dc.b	"TX"
	dc.w	$6c
	dc.l	fcopy_txt

	dc.w	0

*******************************
	dc.l	"MED2"
	dc.l	medway2

	dc.b	"BR"
	dc.w	$601c

	dc.b	"TX"
	dc.w	$112
	dc.l	medway2_txt

	dc.w	0

*******************************
	dc.l	"MED3"
	dc.l	medway3

	dc.b	"BR"
	dc.w	$601c

	dc.b	"TX"
	dc.w	$f4
	dc.l	medway3_txt

	dc.w	0



	dc.l	-1

viruses:
	dc.b	"VIRS"		; code for viruses!

	ifd	recog_mine
***********
* HDV_BPB
	dc.b	"HDV_"
	dc.l	hdv

	dc.b	"BR"
	dc.w	$6020

	dc.b	"RT"
	dc.l	hdv_routine
	dc.w	0

*************
* RES_VIR
	dc.b	"RES1"
	dc.l	res1

	dc.b	"BR"
	dc.w	$6020

	dc.b	"RT"
	dc.l	res_vir1_rout

	dc.w	0

*************
* RES_VIR 2
	dc.b	"RES2"
	dc.l	res2

	dc.b	"BR"
	dc.w	$6020

	dc.b	"RT"
	dc.l	res_vir2_rout

	dc.w	0


**************
* VIRUS 2

	dc.b	"VIR2"
	dc.l	virus2

	dc.b	"LW"
	dc.w	0
	dc.l	$eb346020

	dc.b	"TX"
	dc.w	4
	dc.l	ibm

	dc.b	"WS"
	dc.w	$24		; offset 24
	dc.w	9		; 9 WORDs

	dc.l	$41faffd2
	dc.l	$0c501212
	dc.l	$66024250
	dc.l	$50882278
	dc.w	$042e

	dc.w	0



	endc


********************
* ANTI-VIRUS

	dc.b	"ANTI"
	dc.l	anti	; related text string

	dc.b	"BR"
	dc.w	$6038

	dc.b	"TX"	; check text
	dc.w	$1e	; offset in boot sector
	dc.l	anti1_txt	; txt addr in me!

	dc.b	"TX"
	dc.w	$186
	dc.l	anti2_txt

	dc.w	0
**********************************
* SIGNUM BPL

	dc.b	"SIGN"
	dc.l	signum

	dc.b	"BR"
	dc.w	$6038

	dc.b	"TX"
	dc.w	$122
	dc.l	bpl

	dc.b	"WD"
	dc.w	$7a
	dc.w	$4e56

	dc.w	0

************************
* KOBOLD

	dc.b	"KOBO"
	dc.l	kobo

	dc.b	"BR"
	dc.w	$601c

	dc.b	"TX"
	dc.w	$10a
	dc.l	kob_txt1

	dc.b	"TX"
	dc.w	$113
	dc.l	kob_txt2

	dc.w	0

*************************
* Green Goblins

	dc.b	"GOBL"
	dc.l	goblin

	dc.b	"BR"
	dc.w	$601c

	dc.b	"TX"
	dc.w	$1b6
	dc.l	goblin_txt

	dc.w	0

************************
* Ghost

	dc.b	"GHOS"
	dc.l	ghost

	dc.b	"BR"
	dc.w	$601c

	dc.b	"LW"
	dc.w	$24
	dc.l	$43f80140

	dc.b	"LW"
	dc.w	$34
	dc.l	$203c3141

	dc.b	"WD"
	dc.w	$38
	dc.w	$5926

	dc.w	0


	dc.l	-1

	ifd	recog_mine

hdv_routine:
* enter with bootsec in a5

	lea	$174(a5),a1	; get addr of message for HDV_BPB
	bsr	crypt		; de-crypt message part

	pea	(a1)
	lea	hdv_txt1(pc),a2
	bsr	chk_txt2
	move.l	(a7)+,a1

	bsr	crypt		; re-encrypt
	move.l	d6,d1

	rts


res_vir1_rout:
	lea	$1c8(a5),a1

	bsr	crypt_res1

	pea	(a1)
	lea	res1_txt(pc),a2
	bsr	chk_txt2
	move.l	(a7)+,a1

	bsr	crypt_res1		; re-encrypt
	move.l	d6,d1

	rts

res_vir2_rout:
	lea	$1dc(a5),a1

	bsr	crypt_res2

	pea	(a1)
	lea	res2_txt(pc),a2
	bsr	chk_txt2
	move.l	(a7)+,a1

	bsr	crypt_res2		; re-encrypt
	move.l	d6,d1

	rts



crypt_res1:
	moveq	#$17-1,d1
	move.l	a1,a2

.loop:
	not.b	(a2)+
	dbra	d1,.loop
	rts

crypt_res2:
	moveq	#16-1,d1
	move.l	a1,a2

.loop:
	not.b	(a2)+
	dbra	d1,.loop
	rts






crypt:
	move.l	a1,a2
	moveq	#6,d5
.loop:
	eor.l	#$aaaaaaaa,(a2)+
	dbra	d5,.loop
	rts



skitz:
	dc.b	"SKITZ!",0
res1_txt:
	dc.b	"SKITZ strikes again!",0
res2_txt:
	dc.b	"SKITZ strikes",0

ibm:
	dc.b	"IBM",0

hdv_txt1:
	dc.b	"Beware - for I am alive..",0


hdv:
	dc.b	"The HDV_BPB virus",0
res1:
	dc.b	"Reset Virus no 1",0
res2:
	dc.b	"Reset Virus no 2",0
virus2:
	dc.b	"Virus no 2",0

	endc


kob_txt1:
	dc.b	"KOBOLD",0
kob_txt2:
	dc.b	"AKTIV!",0

goblin_txt:
	dc.b	"The Little Green Goblins Strike Again",0

anti1_txt:
	dc.b	"This Anti-Virus beeps and f",0
anti2_txt:
	dc.b	"lashes",13,10,"if the actual bootsector is executeable",0
fcopy_txt:
	dc.b	" Hello !!               ",13,10,"     I am your personal boot sector",0
medway2_txt:
	dc.b	"The Medway Boys Protector II",0
medway3_txt:
	dc.b	"The Medway Boys Protector III",0

unk_warn:
	dc.b	"Could be VIRUS or VITAL!",0
type_unk:
	dc.b	"Unknown",0


non_exec:
	dc.b	"Non-executable",0
type_exec:
	dc.b	"Executable",0
un_exec:
	dc.b	"Disabled bootsector",0

infected:
	dc.b	"*** VIRUS INFECTED ***",0
destroy:
	dc.b	"You should protect it at once!",0
ok_boot:
	dc.b	"HARMLESS",0


medway2:
	dc.b	"Medway Boys Protector II",0

medway3:
	dc.b	"Medway Boys Protector III",0

avk_prot:
	dc.b	"Immunised",0
fcopy:
	dc.b	"FCOPY protector",0

bpl:
	dc.b	"BPL",0

signum:
	dc.b	"Signum/BPL virus",0
anti:
	dc.b	"The Anti-Virus",0
ghost:
	dc.b	"The Ghost virus",0
goblin:
	dc.b	"The Goblin virus",0
kobo:
	dc.b	"The KOBOLD virus",0
kob1:
	dc.b	"The KOBOLD virus - 1st stage",0


	even



do_checks:
* enter with a0 pointing to list of boot checks
* and a5 pointing at bootsector addr
* returns 
*	d0 = 0 if not found
* 		else code from list
* 	a4 = text string of bootsector name
*	d1 = list code (LESS or VIRS)


	move.l	(a0)+,d7	; get list code

list_loop:
	move.l	(a0)+,d0	; get code for this boot
	move.l	(a0)+,a4	; get text string

	cmp.l	#-1,d0
	beq	not_in_list	; branch if end of list reached

do_comp:
	move.w	(a0)+,d1	; get command word
	beq	got_boot	; branch if all checks matched

* now interpret the command word
	cmp.w	#"TX",d1
	beq.s	do_txt		; compare text

	cmp.w	#"WS",d1
	beq.s	do_words

	cmp.w	#"RT",d1
	beq	do_rout

	cmp.w	#"BR",d1
	beq.s	do_bra		; compare 1st word

	cmp.w	#"WD",d1
	beq.s	do_word		; compare another word


* compare a LW
* get offset in bootsector
	move.w	(a0)+,d1

* get LW
	move.l	(a0)+,d3

	cmp.l	(a5,d1.w),d3	; do they match?
	bne.s	not_this_one	; branch if not
	bra.s	do_comp		; else check more


do_words:
* get offset
	moveq	#0,d1
	move.w	(a0)+,d1
	move.l	a5,a3
	add.l	d1,a3

* get no of words to do
	move.w	(a0)+,d2

.check_words:
	cmpm.w	(a0)+,(a3)+	; compare a word
	bne	not_this_one

	subq.w	#1,d2
	bne.s	.check_words

* all words match!
	bra	do_comp


do_rout:
	move.l	(a0)+,a1	; get routine addr
	jsr	(a1)		; call it

	tst.w	d1
	beq	do_comp		; keep going if d1 = 0
	bra	not_this_one	; else stop!


do_word:
* get offset in bootsector
	move.w	(a0)+,d1

	move.w	(a0)+,d3

	cmp.w	(a5,d1.w),d3
	bne.s	not_this_one
	bra.s	do_comp

do_bra:
* do 1st word on bootsector

* get word should be
	move.w	(a0)+,d3
	cmp.w	(a5),d3
	bne	not_this_one
	bra	do_comp


do_txt:
* compare text strings

* get offset of text in bootsector
	moveq	#0,d1
	move.w	(a0)+,d1
	move.l	a5,a1		; copy bootsector addr

	add.l	d1,a1		; a1 = addr of txt in bootsector


* get addr of string in program
	move.l	(a0)+,a2

	bsr	chk_txt2
	tst.w	d6
	bmi	not_this_one

	bra	do_comp


chk_txt2:
* enter with string in bootsec at a1
* and string to match in a2

* returns d6 = 0 if match or -1 if no match

.txt_loop:
	move.b	(a2)+,d3
	beq.s	match		; branch if end of string

	cmp.b	(a1)+,d3
	bne.s	no_match	; stop if string does not match
	bra.s	.txt_loop	; go on till end of string

match:
	moveq	#0,d6
	rts

no_match:
	moveq	#-1,d6
	rts



not_this_one:
* check has not matched!
* so scan list for next check or end of list...

.loop:
	move.w	(a0)+,d1
	beq	list_loop	; go to loop if end of this check
	bra.s	.loop


not_in_list:
	moveq	#0,d0
	rts

got_boot:
* matched!
* so return the bootsector code in d0
* and list code in d1

	move.l	d7,d1
	rts




check_memory:
* Check memory for all known viruses
* first the ones which are easy to find...

	lea	vir_list(pc),a5		; start the list of viruses


* SIGNUM BPL is located at ($4c6) + $600	
	move.l	$4c6.w,a0
	lea	$600(a0),a0

	pea	(a0)

	cmp.l	#"VIGI",(a0)
	beq	not_signum		; don't do any checking if whatever was there has been killed!

	cmp.w	#$6038,(a0)
	bne.s	not_signum

* Is it REALLY Signum?

	cmp.w	#"BP",$122(a0)
	bne.s	not_signum

* YES! IT IS SIGNUM BPL!
	move.l	#"SIGN",(a5)+
	move.l	a0,(a5)+
	clr.w	(a5)+		; no reset-vector

not_signum:
	cmp.l	#"VIGI",(a0)
	beq	not_antiv

	move.l	a0,a3

	lea	anti1_txt(pc),a1
	lea	$1e(a0),a0
	bsr	chk_txt

	tst.w	d0
	bne.s	not_antiv

	lea	anti2_txt(pc),a1
	lea	$186(a3),a0
	bsr	chk_txt

	tst.w	d0
	bne.s	not_antiv


* Anti-virus found!
	move.l	#"ANTI",(a5)+
	move.l	(a7),(a5)+
	clr.w	(a5)+

not_antiv:
	ifd	recog_mine

* are any of MINE in memory?
	move.l	(a7),a0

	cmp.w	#$6020,(a0)
	bne.s	not_hdv

	lea	skitz(pc),a1
	lea	$1f8(a0),a0
	bsr	chk_txt

	tst.w	d0
	bne	not_hdv

* MY HDV_BPB is resident!
	move.l	#"HDV_",(a5)+
	move.l	(a7),(a5)+
	clr.w	(a5)+

not_hdv:
	move.l	(a7),a0

	cmp.l	#"VIGI",(a0)
	beq	not_res1

	lea	$1c8(a0),a0
	moveq	#22-1,d0
	bsr	do_copy

	lea	res1_txt(pc),a0
	exg.l	a0,a1
	bsr	chk_txt

	tst.w	d0
	bne	not_res1

	move.l	#"RES1",(a5)+
	move.l	(a7),(a5)+
	move.w	#1,(a5)+	; reset vec destroyed!

not_res1:
* Is is reset-proof virus 2?
	move.l	(a7),a0

	cmp.l	#"VIGI",(a0)
	beq	not_res2


	lea	$1dc(a0),a0
	moveq	#12,d0
	bsr	do_copy

	move.l	a1,a0
	lea	res2_txt(pc),a1
	bsr	chk_txt

	tst.w	d0
	bne.s	not_res2

* Is my reset-proof V2
	move.l	#"RES2",(a5)+
	move.l	(a7),(a5)+
	clr.w	(a5)+

not_res2:
* my second virus is at ($42e) - $300

	move.l	$42e.w,a0
	lea	-$300(a0),a0

	move.l	a0,4(a5)

	cmp.l	#"VIGI",(a0)
	beq	not_virus2

	cmp.l	#$eb346020,(a0)+
	bne	not_virus2

	lea	ibm(pc),a1
	bsr	chk_txt

	tst.w	d0
	bne	not_virus2

	cmp.l	#"1AY&",$59(a0)
	bne.s	not_virus2


	move.l	#"VIR2",(a5)+
	addq.l	#4,a5
	clr.w	(a5)+

not_virus2:
	endc


* GHOST VIRUS ALWAYS AT $140
	addq.l	#4,a7

	move.w	#$140,a0

	cmp.l	#"VIGI",(a0)
	beq	not_ghost

	move.l	a0,4(a5)

	cmp.l	#$263c0000,(a0)
	bne.s	not_ghost

	cmp.w	#$00d6,4(a0)
	bne.s	not_ghost

	cmp.l	#"1AY&",$18(a0)
	bne.s	not_ghost

* GHOST is present!
	move.l	#"GHOS",(a5)+
	addq.l	#4,a5
	clr.w	(a5)+

not_ghost:

* GOBLINS virus!
	move.l	$42e.w,a0

	cmp.l	#"VIGI",(a0)
	beq	not_goblin

	move.l	a0,4(a5)

	lea	$198(a0),a0
	lea	goblin_txt(pc),a1
	bsr	chk_txt

	tst.w	d0
	bne.s	not_goblin

	move.l	#"GOBL",(a5)+
	addq.l	#4,a5
	move.w	#1,(a5)+


not_goblin:

* KOBOLD VIRUS ! YIKES!

	tst.b	long_chk
	bne	not_kobold

	move.l	$432.w,a0
	move.l	$436.w,a1	; get top + bottom of memory

	move.l	a1,d0
	sub.l	a0,d0		; get length of memory

	lsr.l	#1,d0		; as no of words
	lsr.l	#3,d0		; divided by 8 (4 LWs)


	move.l	#"KOKO",d1


search_kobold:
	movem.l	(a0)+,d3-d6

test	macro
	sub.w	d1,\1
	beq.s	\22

	swap	\1
	sub.w	d1,\1
	beq.s	\21
	endm

	sub.w	d1,d3
	beq.s	got_12
	swap	d3
	sub.w	d1,d3
	beq.s	got_11


	test	d4,got_2
	test	d5,got_3
	test	d6,got_4


got_rej:
	subq.l	#1,d0
	bne.s	search_kobold


	bra	not_kobold

got_11:
	lea	-16(a0),a2
	bra.s	got_one

got_12:
	lea	-14(a0),a2
	bra.s	got_one

got_21:
	lea	-12(a0),a2
	bra.s	got_one

got_22:
	lea	-10(a0),a2
	bra.s	got_one

got_31:
	lea	-8(a0),a2
	bra.s	got_one

got_32:
	lea	-6(a0),a2
	bra.s	got_one

got_41:
	lea	-4(a0),a2
	bra.s	got_one

got_42:
	lea	-2(a0),a2

got_one:
* will come here AT LEAST once (finds myself!)

	cmp.w	#"BO",2(a2)
	bne	got_rej

	cmp.w	#"LD",4(a2)
	bne	got_rej

	cmp.w	#0,6(a2)
	bne	got_rej

	cmp.w	#" A",8(a2)
	bne	got_rej

	cmp.w	#"KT",10(a2)
	bne	got_rej

	cmp.w	#"IV",12(a2)
	bne	got_rej

	lea	-$10a(a2),a2
	cmp.l	#"1AY&",$ce(a2)
	bne	got_rej

* WE HAVE KOBOLD!
	cmp.l	#"VIGI",(a2)
	beq	not_kobold		; but not if it's killed!

	cmp.l	#$10000,a2
	beq	kobold_1st		; and not if it's 1st stage!

	move.l	#"KOBO",(a5)+
	move.l	a2,(a5)+
	move.w	#1,(a5)+

	bra.s	not_kobold

kobold_1st:
* KOBOLD at the 1st stage (at $10000)
	move.l	#"KOB1",(a5)+
	move.l	a2,(a5)+


not_kobold:
	move.l	#-1,(a5)+		; terminate the list of viruses
	move.l	#-1,(a5)

	rts




vir_codes:
	dc.b	"SIGN"
	dc.l	kill_signum,signum

	dc.b	"ANTI"
	dc.l	kill_anti,anti


	IFD	recog_mine
	dc.b	"HDV_"
	dc.l	kill_hdv,hdv

	dc.b	"RES1"
	dc.l	kill_res1,res1

	dc.b	"RES2"
	dc.l	kill_res2,res2

	dc.b	"VIR2"
	dc.l	kill_vir2,virus2
	ENDC


	dc.b	"GHOS"
	dc.l	kill_ghost,ghost

	dc.b	"GOBL"
	dc.l	kill_goblin,goblin

	dc.b	"KOBO"
	dc.l	kill_kobo,kobo

	dc.b	"KOB1"
	dc.l	kill_kob1,kob1



kill_signum:
	move.l	vir_addr,a0

	move.l	$12c(a0),a1	; get old vector

* tell myself about myself...
	flag	"SIGN"


	lea	$7a(a0),a0	; get addr to put patch in
	bsr	do_patch_hdv
	rts



kill_anti:
	move.l	vir_addr,a0
	move.l	$1f8(a0),a1	; get old vector
	flag	"ANTI"

	lea	$96(a0),a0
	bsr	do_patch_hdv
	rts


kill_ghost:
	move.l	vir_addr,a0
	move.l	$2e2.w,a1	; from abs addr!

	flag	"GHOS"


	move.w	#$20e,a0
	bsr	do_patch_hdv

	move.w	#$194,a0

	move.l	$190.w,a1
	cmp.l	#$00000000,a1
	beq.s	no_resetv	; branch if no reset addr stored

	bsr	do_patch_res_ok
	rts

no_resetv:
	bsr	do_patch_res_bad
	rts



kill_goblin:
	move.l	vir_addr,a0
	flag	"GOBL"

	pea	(a0)

	move.l	$17c(a0),a1
	lea	$b8(a0),a0
	bsr	do_patch_hdv

	move.l	(a7)+,a0
	lea	$64(a0),a0

	bsr	do_patch_res_bad
	rts




kill_kob1:
	move.l	vir_addr,a0
	move.w	#512/4-1,d0

.clr:
	clr.l	(a0)+
	dbra	d0,.clr
	rts


kill_kobo:
	move.l	vir_addr,a0
	flag	"KOBO"

	lea	512(a0),a0
	pea	(a0)

	lea	-$1b6(a0),a0
	bsr	do_patch_res_bad

	move.l	(a7)+,a0
	move.l	-$20c(a0),a1
	lea	-$1d4(a0),a0
	bsr	do_patch_hdv

	rts




	ifd	recog_mine

kill_hdv:
* kill the hdv_bpb virus
* simply restore $472

	move.l	vir_addr,a0

	flag	"HDV_"

	move.l	$1f2(a0),a1
	lea	$66(a0),a0
	bsr	do_patch_hdv
	rts


kill_res1:
	move.l	vir_addr,a0
	flag	"RES1"

	pea	(a0)

	move.l	$d0(a0),a1
	lea	$c6(a0),a0
	bsr	do_patch_hdv

	move.l	(a7)+,a0

	lea	$7e(a0),a0
	bsr	do_patch_res_bad

	rts



kill_res2:
	move.l	vir_addr,a0
	pea	(a0)

	move.l	$f2(a0),a1
	lea	$e8(a0),a0
	bsr	do_patch_hdv

	move.l	(a7),a0

	move.l	2(a0),d0
	cmp.l	#"1AY&",d0
	bne.s	no_res2_res


	move.l	6(a0),a1
	lea	$8c(a0),a0
	bsr	do_patch_res_ok

	move.l	(a7)+,a0
	flag	"RES2"		; put in flag LAST as it overwrites old reset vector!

	rts


no_res2_res:
* no reset vector to jump to!
	lea	$8c(a0),a0
	bsr	do_patch_res_bad

	move.l	(a7)+,a0
	flag	"RES2"
	rts




kill_vir2:
	move.l	vir_addr,a0
	flag	"VIR2"

	pea	(a0)
	move.l	$1a6(a0),a1	; get old reset vector

	lea	$164(a0),a0

	cmp.l	#$ffffffff,a1
	beq.s	no_vec		; branch if no vector stored

	bsr	do_patch_res_ok

vec_rej:
	move.l	(a7)+,a0
	move.l	$92(a0),a1	; get old hdv_bpb

	lea	$88(a0),a0	; new hdv_bpb
	bsr	do_patch_hdv

	rts

no_vec:
	bsr	do_patch_res_bad
	bra.s	vec_rej

	endc



* Routines to "patch" viruses

do_patch_hdv:
* put hdv path in addr at a0

	lea	patch_hdv(pc),a2
	move.l	a1,2(a2)	; put old vector into the patch

	move.l	(a2)+,(a0)+
	move.w	(a2),(a0)
	rts


do_patch_res_ok:
	lea	patch_res_ok(pc),a2
	move.l	a1,2(a2)

	move.l	(a2)+,(a0)+
	move.l	(a2)+,(a0)+
	move.w	(a2)+,(a0)+
	rts

do_patch_res_bad:
	lea	patch_res_bad(pc),a1

	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	move.l	(a1)+,(a0)+
	rts



patch_hdv:
	jmp	$12345678


patch_res_ok:
	move.l	#$12345678,$42a.w
	jmp	(a6)

patch_res_bad:
	clr.l	$42a.w
	clr.l	$426.w
	jmp	(a6)





do_copy:
	lea	buff(pc),a1
	pea	(a1)

	move.w	d0,-(a7)
cop:
	move.b	(a0)+,(a1)+
	dbra	d0,cop


	move.w	(a7)+,d0

	move.l	(a7)+,a1

	move.l	a1,a0
do_not:
	not.b	(a0)+
	dbra	d0,do_not

	rts

chk_txt:
* check the text passed in a1

* how long is it?
	moveq	#-1,d0
	move.l	a1,a2

tst:
	addq.w	#1,d0
	tst.b	(a2)+
	bne.s	tst

do_tst:
	cmpm.b	(a0)+,(a1)+
	bne.s	not_found

	subq.w	#1,d0
	bne.s	do_tst

* found the string!
	moveq	#0,d0
	rts


not_found:
	moveq	#-1,d0
	rts

rsc_name:
	dc.b	"c:\vigilant.rsc",0
menu_txt:
	dc.b	"  Vigilante",0

write_error:
	stopp
	dc.b	"[VIGILANTE V1.0|"
	dc.b	"   |"
	dc.b	"An error occurred while I  |"
	dc.b	"was trying to protect|"
	dc.b	"this disk.  |"
	dc.b	"   ]"
	dc.b	"[Retry|Cancel]",0

hex_chars:
	dc.b	"0123456789ABCDEF"

	even

centre_list:

num	set	0

	rept	no_of_trees
	dc.w	num
num	set	num+1
	endr

	dc.w	-1







	ifnd	link
	include	aes_shel.s
	include	aes_call.s
	include	dialogs.s
	include	vdi_call.s
	include	gem_shel.s
	include	vdi_shel.s
	include	bits.s
	include	xbioshel.s
	include	files.s
	endc







	section	bss

boot_sec:
	ds.b	512
boot_sec2:
	ds.b	512


vir_list:
	ds.l	no_recog	; room for flags
	ds.l	no_recog	; room for addrs
	ds.w	no_recog	; room for reset-vector flags


buff:
	ds.b	100

res_flag:
	ds.w	1

dev		ds.w	1
run_type	ds.w	1	; "AC" or "PR" for ACC or PROGRAM
menu_id		ds.w	1

startup_flag	ds.b	1
inf_flag	ds.b	1
in_hdv		ds.b	1
	even

types	ds.l	3		; keep d0 & d1 & a4 after checking bootsector

smallx:
	ds.w	4
smallx2:
	ds.w	4
boot_off:
	ds.w	1		; offset in VIEWing bootsector

view_lines:
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line
	ds.b	40	; 1 VIEW line


vir_addr	ds.l	1

flag_buff	ds.b	flag_len

	ds.b	5000
stack:
