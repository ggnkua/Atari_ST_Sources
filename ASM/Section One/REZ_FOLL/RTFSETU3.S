*
* Standard routine for GEM programs, by WtP (some help from Abacus GEM PR)
*
* Supports shared memory
*

editfile		EQU	    0

write_it	EQU	    1
info_file	EQU	    2
edit_mem	EQU	    3
want_rgb_file	EQU	    4
want_tv_file	EQU	    5
got_vga_file	EQU	    6
got_rgb_file	EQU	    8
got_tv_file	EQU	    9

editmem			EQU	    1

reset		EQU	    1
edit_file	EQU	    2
fool_rgb_mem	EQU	    3
fool_tv_mem	EQU	    4
got_vga_mem	EQU	    5
got_rgb_mem	EQU	    7
got_tv_mem	EQU	    8
info_edit	EQU	   11

info_form		EQU	    2

exit_info	EQU	    1
show_me		EQU	   12

menu			EQU	    3

desk_menu	EQU	    3
edit_menu	EQU	    4
misc_menu	EQU	    5
about		EQU	    8
edit_mem_menu	EQU	   17
edit_file_menu	EQU	   18
quit_menu	EQU	   20
write_menu	EQU	   21
reset_menu	EQU	   22

unknown_path		EQU	    4

ok_unknow_p	EQU	    1

write_e			EQU	    5

ok_write_e	EQU	    1

faked			EQU	    6

ok_faked	EQU	    1

good_write		EQU	    7

write_good	EQU	    1

shower			EQU	    8

will		EQU	    1

*		opt X+				*long symbols for debugging

text:		bra	starter

		dc.b	"This program written by Pontus Sk”ld aka WtP of Section One ... "
		dc.b	"Ryllshyttan 1, 776 98 Garpenberg, Sweden ... Send me a postcard ..."

		even

starter:	move.l	sp,d0
		bne.s	got_stack

		move.l	a0,a6
		bra.s	dont_read_bp_adr
got_stack:
		move.l	4(sp),a6

dont_read_bp_adr:
		movea.l	16(a6),a4		*address to data segment
		movea.l	24(a6),a5		*and to bss segment

		move.l	12(a6),d0
		add.l	20(a6),d0
		add.l	28(a6),d0

		add.l	#$1400,d0

		lea	stack-bss(a5),sp

		move.l	d0,-(sp)
		move.l	a6,-(sp)
		clr.w	-(sp)
		move.w	#$4a,-(sp)
		trap	#1
		lea	12(sp),sp

		bsr	init_once	*setup variables one time only

		tst.w	acc_load-bss(a5)
		bne	acc_mode

		moveq	#0,d0
		bsr	graf_mouse

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		moveq	#1,d0

		bsr	menu_bar



start_acc_run:	bsr	popup_window

		cmp.l	#4*editmem,rcs_screen-bss(a5)
		beq	update_mem_screen

		cmp.l	#4*editfile,rcs_screen-bss(a5)
		beq	update_file_screen

		bsr	send_redraw
window_handling_loop:
		bsr	check_rezf

		bsr	init_em_parameters

		lea	em_buffer-bss(a5),a0

		bsr	setup_em_mesag
		bsr	setup_em_keyboard

		moveq	#2,d0
		moveq	#1,d1
		moveq	#1,d2

		bsr	setup_em_button
		bsr	do_evnt_multi

return_from_evnt:
		cmp.w	#1,d0
		bne	not_keyboard_event

		cmp.b	#13,intout+11-bss(a5)		*return or enter
		bne	not_keyboard_event

		move.l	rcs_screen-bss(a5),d0
		lsr.l	#1,d0

		lea	default_list-bss(a5),a0

		move.w	0(a0,d0.w),d0
		bpl	object_selected
		bra	window_handling_loop

not_keyboard_event:
		cmp.w	#2,d0
		bne	not_mouse_button

*		bsr	init_em_parameters	*Touch exit on everything

*		moveq	#1,d0
*		moveq	#1,d1
*		moveq	#0,d2

*		bsr	setup_em_button
*		bsr	do_evnt_multi

		move.w	intout+2-bss(a5),d6
		sub.w	work_x-bss(a5),d6

		move.w	intout+4-bss(a5),d7
		sub.w	work_y-bss(a5),d7

		tst.w	d6
		bmi	not_mouse_button

		tst.w	d7
		bmi	not_mouse_button

		cmp.w	work_w-bss(a5),d6
		bpl	not_mouse_button

		cmp.w	work_h-bss(a5),d7
		bpl	not_mouse_button

		move.w	intout+12-bss(a5),d0

		cmp.w	#2,d0
		bne	not_toggle_screens

		tst.l	text_adr-bss(a5)
		bne	toggle_screens

		cmp.l	#editfile*4,rcs_screen-bss(a5)
		bne	toggle_screens

		bra	window_handling_loop

not_toggle_screens:
		moveq	#0,d0			*start with object null
		moveq	#7,d1			*7 levels

		move.w	intout+2-bss(a5),d2	*mouse x
		move.w	intout+4-bss(a5),d3	*mouse y

		move.l	tree_pointer-bss(a5),a0
		add.l	rcs_screen-bss(a5),a0
		move.l	(a0),a0

		bsr	objc_find

		tst.w	d0
		bmi	window_handling_loop

		move.l	tree_pointer-bss(a5),a0
		add.l	rcs_screen-bss(a5),a0
		move.l	(a0),a0
		
		move.l	d0,d2
		mulu	#24,d2

		move.w	8(a0,d2.l),d1

		and.w	#%1000101,d1

		btst	#0,d1			*not selectable, nothing to
		beq	window_handling_loop	*care about

		btst	#2,d1
		beq	window_handling_loop

		btst	#6,d1			*if touchexit, goto object selected
		bne	object_selected

		move.l	tree_pointer-bss(a5),a0
		add.l	rcs_screen-bss(a5),a0
		move.l	(a0),a0

		move.w	10(a0,d2.l),d5		*get old status
		or.w	#1,d5			*highlighted
		
		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		moveq	#0,d7
		move.w	d0,d7

		moveq	#1,d6
		bsr	objc_change

		move.l	d7,d0

		move.l	tree_pointer-bss(a5),a0
		add.l	rcs_screen-bss(a5),a0
		move.l	(a0),a0
		
		bsr	objc_offset

		move.w	intout+2-bss(a5),d1	*get x &?â£æ?s
		move.w	intout+4-bss(a5),d2	*for object...

		bsr	init_em_parameters

		move.l	d7,d0
		mulu	#24,d0

		move.l	tree_pointer-bss(a5),a0
		add.l	rcs_screen-bss(a5),a0
		move.l	(a0),a0

		move.w	20(a0,d0.l),d3
		move.w	22(a0,d0.l),d4

		moveq	#1,d0
		bsr	setup_em_mouse1

		moveq	#1,d0				*max 1 click
		moveq	#1,d1				*only left counts
		moveq	#0,d2				*until release...

		bsr	setup_em_button

		bsr	do_evnt_multi

		move.w	d0,-(sp)		*save intout 0...

		move.l	d7,d0			*object #
		mulu	#24,d0

		move.l	tree_pointer-bss(a5),a0
		add.l	rcs_screen-bss(a5),a0
		move.l	(a0),a0
		
		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	10(a0,d0.l),d5		*get old status
		and.w	#$fffe,d5		*not highlighted

		move.l	d7,d0

		moveq	#1,d6
		bsr	objc_change

		move.w	(sp)+,d1
		move.l	d7,d0

		btst	#1,d1			*if it was mouse released
		bne	object_selected		*go to object_selected

		bra	window_handling_loop

not_mouse_button:
		cmp.w	#$10,d0
		bne	window_handling_loop

		move.w	em_buffer+4-bss(a5),d1
		beq.s	not_read_more

		move.w	appl_id-bss(a5),d0

		lea	em_buffer+16-bss(a5),a0

		bsr	appl_read

not_read_more:
*		move.w	appl_id-bss(a5),d0		*???
*		cmp.w	em_buffer+2-bss(a5),d0
*		bne	window_handling_loop

		move.w	em_buffer-bss(a5),d0

		cmp.w	#10,d0
		beq	menu_options

		cmp.w	#41,d0
		bne.s	not_ac_close

		move.w	em_buffer+6-bss(a5),d1
		cmp.w	desk_id-bss(a5),d1
		beq	delete_window_and_exit

not_ac_close:	cmp.w	#"RF",d0
		beq	message_to_me

		move.w	window_handle-bss(a5),d1
		cmp.w	em_buffer+6-bss(a5),d1
		bne	window_handling_loop
	
		cmp.w	#22,d0			*wm_close
		beq	close_window_and_exit

		cmp.w	#20,d0			*wm_update
		beq	update_screen

		cmp.w	#21,d0			*wm_top
		beq	top_my_window

		cmp.w	#10,d0
		beq	menu_options

		cmp.w	#28,d0			*wm_moved
		bne	window_handling_loop

		move.w	em_buffer+8-bss(a5),window_x-bss(a5)	*read new
		move.w	em_buffer+10-bss(a5),window_y-bss(a5)	*pos
		move.w	em_buffer+12-bss(a5),window_w-bss(a5)
		move.w	em_buffer+14-bss(a5),window_h-bss(a5)


		move.w	window_handle-bss(a5),d0
		moveq	#5,d1

		move.w	window_x-bss(a5),d2
		move.w	window_y-bss(a5),d3
		move.w	window_w-bss(a5),d4
		move.w	window_h-bss(a5),d5

		bsr	wind_set

		move.w	window_handle-bss(a5),d0	*get workarea
		moveq	#4,d1				*coords

		bsr	wind_get

		move.w	intout+2-bss(a5),work_x-bss(a5)	*save, so we now it's
		move.w	intout+4-bss(a5),work_y-bss(a5)	*current position
		move.w	intout+6-bss(a5),work_w-bss(a5)
		move.w	intout+8-bss(a5),work_h-bss(a5)

		move.l	tree_pointer-bss(a5),a0		*
		add.l	rcs_screen-bss(a5),a0
		move.l	(a0),a0

		move.w	work_x-bss(a5),16(a0)	*update tree coordinates
		move.w	work_y-bss(a5),18(a0)

		bra	window_handling_loop

close_window_and_exit:
		bsr	close_window
delete_window_and_exit:
		bsr	delete_window
		move.w	desk_id-bss(a5),d0
		cmp.w	#"er",d0
		bne	acc_loop
*
* Go look for accs...
*

* This only for program ...

		moveq	#0,d0			*erase bar

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		bsr	menu_bar

something_wrong:
		bsr	close_virtual
		bsr	appl_exit

		moveq	#0,d0
		bra.s	quit_right_now


acc_mode:	move.w	appl_id-bss(a5),d0
		lea	acc_name-data(a4),a0

		bsr	menu_register

		tst.w	d0			*if no handle, go something
		bmi	something_wrong		*wrong (exit)

		move.w	d0,desk_id-bss(a5)

acc_loop:	bsr	init_em_parameters

		lea	em_buffer-bss(a5),a0
		bsr	setup_em_mesag
		bsr	do_evnt_multi

		cmp.w	#$10,d0
		bne.s	acc_loop

		move.w	em_buffer+4-bss(a5),d1
		beq.s	not_read_more2

		move.w	appl_id-bss(a5),d0
		lea	em_buffer+16-bss(a5),a0

		bsr	appl_read

not_read_more2:	cmp.w	#40,em_buffer-bss(a5)
		beq	start_acc_run

		move.w	em_buffer+8-bss(a5),d0 		*???
		cmp.w	desk_id-bss(a5),d0
		beq	start_acc_run

		bra.s	acc_loop

auto_load:	move.l	text_adr-bss(a5),d0
		bne	search_command

auto_loaded:	pea	no_auto_run-data(a4)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp

		moveq	#-76,d0
quit_right_now:
		move.w	d0,-(sp)
		move.w	#$4c,-(sp)
		trap	#1

object_selected:
		cmp.l	#editfile*4,rcs_screen-bss(a5)	*are we in tree 0 ?
		bne	not_on_filescreen

		cmp.w	#info_file,d0
		beq	show_info

		cmp.w	#want_tv_file,d0
		bne	not_want_tv_file

		clr.w	want_file-bss(a5)
		bra	update_file_screen

not_want_tv_file:
		cmp.w	#want_rgb_file,d0
		bne	not_want_rgb_file

		move.w	#1,want_file-bss(a5)
		bra	update_file_screen

not_want_rgb_file:
		cmp.w	#got_tv_file,d0
		bne	not_got_tv_file

		clr.w	got_file-bss(a5)
		bra	update_file_screen

not_got_tv_file:
		cmp.w	#got_rgb_file,d0
		bne	not_got_rgb_file

		move.w	#1,got_file-bss(a5)
		bra	update_file_screen

not_got_rgb_file:
		cmp.w	#got_vga_file,d0
		bne	not_got_vga_file

		move.w	#2,got_file-bss(a5)
		bra	update_file_screen
not_got_vga_file:
		tst.l	text_adr-bss(a5)
		beq.s	skip_edit_mem_ctrl

		cmp.w	#edit_mem,d0
		beq	toggle_screens
skip_edit_mem_ctrl:
		cmp.w	#write_it,d0
		beq	write_to_file

		bra	unknown_event

not_on_filescreen:
		cmp.l	#editmem*4,rcs_screen-bss(a5)	*are we in tree 1 ?
		bne	not_on_memscreen

		cmp.w	#reset,d0
		bne	not_reset_settings

reset_sets:	move.l	text_adr-bss(a5),a0
		move.l	save_mem-bss(a5),2(a0)
		bra	update_mem_screen

not_reset_settings:
		cmp.w	#info_edit,d0
		beq	show_info

		cmp.w	#edit_file,d0
		beq	toggle_screens

		move.l	text_adr-bss(a5),a0

		cmp.w	#fool_rgb_mem,d0
		bne.s	not_fool_rgb_mem

		move.w	#1,4(a0)
		bra	update_mem_screen

not_fool_rgb_mem:
		cmp.w	#fool_tv_mem,d0
		bne.s	not_fool_tv_mem

		move.w	#3,4(a0)
		bra	update_mem_screen
not_fool_tv_mem:
		cmp.w	#got_rgb_mem,d0
		bne.s	not_got_rgb_mem

		move.w	#1,2(a0)
		bra	update_mem_screen

not_got_rgb_mem:
		cmp.w	#got_tv_mem,d0
		bne.s	not_got_tv_mem

		move.w	#3,2(a0)
		bra	update_mem_screen
not_got_tv_mem:
		cmp.w	#got_vga_mem,d0
		bne.s	not_got_vga_mem

		move.w	#2,2(a0)
		bra	update_mem_screen
not_got_vga_mem:
		bra	unknown_event

not_on_memscreen:
		cmp.l	#info_form*4,rcs_screen-bss(a5)
		bne	not_on_infoscreen

		cmp.w	#exit_info,d0		*we are in tree 2
		beq	toggle_screens		

		cmp.w	#show_me,d0		*we are in tree 2
		bne	unknown_event		

		move.l	#shower*4,d0
		bra	show_other_box

not_on_infoscreen:
		cmp.l	#unknown_path*4,rcs_screen-bss(a5)
		bne	not_on_up_screen

		cmp.w	#ok_unknow_p,d0
		beq	toggle_screens
		bra	unknown_event
	
not_on_up_screen:
		cmp.l	#write_e*4,rcs_screen-bss(a5)
		bne	not_on_we_screen

		cmp.w	#ok_write_e,d0
		beq	toggle_screens
		bra	unknown_event
	
not_on_we_screen:
		cmp.l	#faked*4,rcs_screen-bss(a5)
		bne	not_on_fv_screen

		cmp.w	#ok_faked,d0
		beq	toggle_screens
		bra	unknown_event
	
not_on_fv_screen:
		cmp.l	#good_write*4,rcs_screen-bss(a5)
		bne	not_on_gw_screen

		cmp.w	#write_good,d0
		beq	toggle_screens
		bra	unknown_event
	
not_on_gw_screen:
		cmp.l	#shower*4,rcs_screen-bss(a5)
		bne	not_on_secret_screen

		cmp.w	#will,d0
		beq	toggle_screens
		bra	unknown_event
	
not_on_secret_screen:


unknown_event:	bra	window_handling_loop

toggle_screens:	move.l	info_temp-bss(a5),d0
		bmi	not_on_info_screen

		move.l	info_temp-bss(a5),rcs_screen-bss(a5)
		move.l	#-1,info_temp-bss(a5)
		bra.s	exit_toggle

not_on_info_screen:
		tst.l	text_adr-bss(a5)	*if rez fooler not in memory
		beq.s	exit_toggle		*don't allow edit

		cmp.l	#editfile*4,rcs_screen-bss(a5)
		beq.s	do_edit_mem

		move.l	#editfile*4,rcs_screen-bss(a5)
		bra.s	exit_toggle

do_edit_mem:	move.l	#editmem*4,rcs_screen-bss(a5)
		bra.s	exit_toggle

show_info:	tst.l	info_temp-bss(a5)
		bpl	window_handling_loop

		move.l	rcs_screen-bss(a5),info_temp-bss(a5)
		move.l	#info_form*4,rcs_screen-bss(a5)

exit_toggle:	bsr	send_redraw

		cmp.l	#editfile*4,rcs_screen-bss(a5)
		beq	update_file_screen

		cmp.l	#editmem*4,rcs_screen-bss(a5)
		beq	update_mem_screen

		bsr	fix_checkmarks
		bra	window_handling_loop

fix_checkmarks:
		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#about,d0
		moveq	#0,d1

		bsr	menu_icheck

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#edit_mem_menu,d0
		moveq	#0,d1

		bsr	menu_icheck

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#edit_file_menu,d0
		moveq	#0,d1

		bsr	menu_icheck

		cmp.l	#editfile*4,rcs_screen-bss(a5)
		beq	mark_file

		cmp.l	#editmem*4,rcs_screen-bss(a5)
		beq	mark_mem

		cmp.l	#info_form*4,rcs_screen-bss(a5)
		bne	no_checkmark

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#about,d0
		moveq	#1,d1

		bsr	menu_icheck
no_checkmark:
		rts

mark_mem:	move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#edit_mem_menu,d0
		moveq	#1,d1

		bsr	menu_icheck
		rts

mark_file:	move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#edit_file_menu,d0
		moveq	#1,d1

		bsr	menu_icheck
		rts

send_redraw:	move.w	#20,em_buffer-bss(a5)
		move.w	window_handle-bss(a5),em_buffer+6-bss(a5)
		move.w	appl_id-bss(a5),em_buffer+2-bss(a5)
		clr.w	em_buffer+4-bss(a5)

		move.w	work_x-bss(a5),em_buffer+8-bss(a5)
		move.w	work_y-bss(a5),em_buffer+10-bss(a5)
		move.w	work_w-bss(a5),em_buffer+12-bss(a5)
		move.w	work_h-bss(a5),em_buffer+14-bss(a5)

		move.w	appl_id-bss(a5),d0
		moveq	#16,d1

		lea	em_buffer-bss(a5),a0
		bsr	appl_write
		rts

message_to_me:	move.w	em_buffer+6-bss(a5),em_buffer+2	*answerback handle

		move.w	#"RT",em_buffer-bss(a5)

		move.l	text_adr-bss(a5),d6
		bne.s	not_no_rf_loaded

		move.w	#-1,em_buffer+6-bss(a5)
		bra	send_answerback
not_no_rf_loaded:
		move.l	d6,a0

		move.w	em_buffer+8-bss(a5),d7
		bmi.s	do_not_change_got

		move.w	d7,2(a0)
do_not_change_got:
		move.w	2(a0),em_buffer+8-bss(a5)

		move.w	em_buffer+10-bss(a5),d7		*check wanted
		bmi.s	do_not_change_want

		move.w	d7,4(a0)			*make it true
do_not_change_want:
		move.w	4(a0),em_buffer+10-bss(a5)	*

		move.w	6(a0),em_buffer+6-bss(a5)	*version
send_answerback:
		move.w	em_buffer+2-bss(a5),d0

		moveq	#16,d1

		lea	em_buffer-bss(a5),a0
		bsr	appl_write
		rts

update_mem_screen:
		bsr	fix_checkmarks

		moveq	#10,d1
		bsr	wind_get

		move.w	intout+2-bss(a5),d0
		cmp.w	window_h-bss(a5),d0
		beq.s	draw_boxes_m

		cmp.l	#editmem*4,rcs_screen-bss(a5)	*show ???
		bne.s	no_show_mem_set

		bsr	send_redraw
		moveq	#0,d6
		bra.s	no_show_mem_set

draw_boxes_m:	moveq	#1,d6
no_show_mem_set:
		moveq	#0,d7

		move.w	#got_rgb_mem,d0

		move.l	text_adr-bss(a5),a3

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.l	tree_pointer-bss(a5),a0
		move.l	4*editmem(a0),a0

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.l),d5
		and.w	#$fffe,d5

		cmp.w	#1,2(a3)
		bne.s	not_mark_rgb3
		or.w	#1,d5
not_mark_rgb3:
		bsr	objc_change

		move.w	#got_tv_mem,d0

		move.l	tree_pointer-bss(a5),a0
		move.l	editmem*4(a0),a0

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.l),d5
		and.w	#$fffe,d5

		cmp.w	#3,2(a3)
		bne.s	not_mark_tv3
		or.w	#1,d5

not_mark_tv3:	bsr	objc_change

		move.w	#got_vga_mem,d0

		move.l	tree_pointer-bss(a5),a0
		move.l	editmem*4(a0),a0

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.l),d5
		and.w	#$fffe,d5

		cmp.w	#2,2(a3)
		bne.s	not_mark_vga3
		or.w	#1,d5
not_mark_vga3:
		bsr	objc_change

		move.w	#fool_rgb_mem,d0

		move.l	tree_pointer-bss(a5),a0
		move.l	editmem*4(a0),a0

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.l),d5
		and.w	#$fffe,d5

		cmp.w	#1,4(a3)
		bne.s	not_mark_rgb_w3
		or.w	#1,d5
not_mark_rgb_w3:
		bsr	objc_change

		move.w	#fool_tv_mem,d0

		move.l	tree_pointer-bss(a5),a0
		move.l	editmem*4(a0),a0

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.l),d5
		and.w	#$fffe,d5

		cmp.w	#3,4(a3)
		bne.s	not_mark_tv_w3
		or.w	#1,d5
not_mark_tv_w3:
		bsr	objc_change

		bra	window_handling_loop


update_file_screen:
		bsr	fix_checkmarks

		moveq	#10,d1
		bsr	wind_get

		move.w	intout+2-bss(a5),d0
		cmp.w	window_h-bss(a5),d0
		beq.s	draw_boxes_f

		cmp.l	#editfile*4,rcs_screen-bss(a5)	*show ???
		bne.s	no_show_file_set

		bsr	send_redraw
		moveq	#0,d6
		bra.s	no_show_file_set

draw_boxes_f:	moveq	#1,d6
no_show_file_set:

		moveq	#0,d7

		move.w	#got_rgb_file,d0

		move.l	tree_pointer-bss(a5),a3
		move.l	editfile*4(a3),a0

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.l),d5
		and.w	#$fffe,d5

		cmp.w	#1,got_file-bss(a5)
		bne.s	not_mark_rgb
		or.w	#1,d5
not_mark_rgb:
		bsr	objc_change

		move.w	#got_tv_file,d0

		move.l	editfile*4(a3),a0

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.l),d5
		and.w	#$fffe,d5

		tst.w	got_file-bss(a5)
		bne.s	not_mark_tv
		or.w	#1,d5
not_mark_tv:
		bsr	objc_change

		move.w	#got_vga_file,d0

		move.l	editfile*4(a3),a0

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.l),d5
		and.w	#$fffe,d5

		cmp.w	#2,got_file-bss(a5)
		bne.s	not_mark_vga
		or.w	#1,d5
not_mark_vga:
		bsr	objc_change

		move.w	#want_rgb_file,d0

		move.l	editfile*4(a3),a0

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.l),d5
		and.w	#$fffe,d5

		cmp.w	#1,want_file-bss(a5)
		bne.s	not_mark_rgb_w
		or.w	#1,d5
not_mark_rgb_w:
		bsr	objc_change

		move.w	#want_tv_file,d0

		move.l	editfile*4(a3),a0

		move.w	work_x-bss(a5),d1
		move.w	work_y-bss(a5),d2
		move.w	work_w-bss(a5),d3
		move.w	work_h-bss(a5),d4

		move.w	d0,d7
		mulu	#24,d7
		move.w	10(a0,d7.w),d5
		and.w	#$fffe,d5

		tst.w	want_file-bss(a5)
		bne.s	not_mark_tv_w
		or.w	#1,d5
not_mark_tv_w:
		bsr	objc_change

		bra	window_handling_loop


appl_init:	move.w	#10,aes_opcode-bss(a5)
		clr.w	aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		bsr	call_aes
		rts

appl_exit:	move.w	#19,aes_opcode-bss(a5)
		clr.w	aes_sintin-bss(a5)
		clr.w	aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		bsr	call_aes
		rts

appl_write:	move.w	#12,aes_opcode-bss(a5)
		move.w	#2,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*application id
		move.w	d1,intin+2-bss(a5)		*length of msg

		move.l	a0,addrin-bss(a5)

		bsr	call_aes
		rts

appl_read:	move.w	#11,aes_opcode-bss(a5)
		move.w	#2,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)
		move.w	d1,intin+2-bss(a5)

		move.l	a0,addrin-bss(a5)

		bsr	call_aes
		rts

shel_read:	move.w	#120,aes_opcode-bss(a5)
		clr.w	aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#2,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.l	a0,addrin-bss(a5)
		move.l	a1,addrin+4-bss(a5)

		bsr	call_aes
		rts

graf_handle:	move.w	#77,aes_opcode-bss(a5)
		clr.w	aes_sintin-bss(a5)
		move.w	#5,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		bsr	call_aes
		rts

open_virtual:	move.w	#100,vdi_opcode-bss(a5)
		clr.w	vdi_sptsin-bss(a5)
		clr.w	vdi_sintout-bss(a5)	*45 auto
		clr.w	vdi_sptsout-bss(a5)	*6 auto
		move.w	#11,vdi_sintin-bss(a5)
		move.w	graf_h-bss(a5),vdi_device-bss(a5)

		move.w	#1,intin-bss(a5)	*0
		move.w	#1,intin+2-bss(a5)	*1
		move.w	#1,intin+4-bss(a5)	*2
		move.w	#1,intin+6-bss(a5)	*3
		move.w	#1,intin+8-bss(a5)	*4
		move.w	#1,intin+10-bss(a5)	 *5
		move.w	#1,intin+12-bss(a5)	 *6
		move.w	#1,intin+14-bss(a5)	 *7
		move.w	#1,intin+16-bss(a5)	 *8
		move.w	#1,intin+18-bss(a5)	 *9
		move.w	d0,intin+20-bss(a5)	 *10

		bsr	call_vdi

		lea	workout-bss(a5),a1
		lea	intout-bss(a5),a0

		moveq	#44,d0

save_workout:	move.w	(a0)+,(a1)+
		dbra	d0,save_workout

		lea	ptsout-bss(a5),a0
		moveq	#11,d0

save_workout2:	move.w	(a0)+,(a1)+
		dbra	d0,save_workout2
		rts

bar:		move.w	#11,vdi_opcode-bss(a5)
		move.w	#2,vdi_sptsin-bss(a5)
		clr.w	vdi_sintout-bss(a5)
		clr.w	vdi_sptsout-bss(a5)
		clr.w	vdi_sintin-bss(a5)
		move.w	#1,vdi_subfunct-bss(a5)
		move.w	graf_h-bss(a5),vdi_device-bss(a5)

		move.w	d0,ptsin-bss(a5)		*x
		move.w	d1,ptsin+2-bss(a5)	*y

		move.w	d2,ptsin+4-bss(a5)	*x2
		move.w	d3,ptsin+6-bss(a5)	*y2

		bsr	call_vdi
		rts

set_fill_pattern:
		move.w	#24,vdi_opcode-bss(a5)
		clr.w	vdi_sptsin-bss(a5)
		move.w	#1,vdi_sintout-bss(a5)
		clr.w	vdi_sptsout-bss(a5)
		move.w	#1,vdi_sintin-bss(a5)
		move.w	#1,vdi_subfunct-bss(a5)
		move.w	graf_h-bss(a5),vdi_device-bss(a5)

		move.w	d0,intin-bss(a5)	*fill pattern

		bsr	call_vdi
		rts

set_fill_style:	move.w	#23,vdi_opcode-bss(a5)
		clr.w	vdi_sptsin-bss(a5)
		move.w	#1,vdi_sintout-bss(a5)
		clr.w	vdi_sptsout-bss(a5)
		move.w	#1,vdi_sintin-bss(a5)
		move.w	#1,vdi_subfunct-bss(a5)
		move.w	graf_h-bss(a5),vdi_device-bss(a5)

		move.w	d0,intin-bss(a5)	*fill style

		bsr	call_vdi
		rts

set_fill_color:	move.w	#25,vdi_opcode-bss(a5)
		clr.w	vdi_sptsin-bss(a5)
		move.w	#1,vdi_sintout-bss(a5)
		clr.w	vdi_sptsout-bss(a5)
		move.w	#1,vdi_sintin-bss(a5)
		move.w	#1,vdi_subfunct-bss(a5)
		move.w	graf_h-bss(a5),vdi_device-bss(a5)

		move.w	d0,intin-bss(a5)	*fill color

		bsr	call_vdi
		rts

set_fill_perimeter:
		move.w	#104,vdi_opcode-bss(a5)
		clr.w	vdi_sptsin-bss(a5)
		move.w	#1,vdi_sintout-bss(a5)
		clr.w	vdi_sptsout-bss(a5)
		move.w	#1,vdi_sintin-bss(a5)
		move.w	#1,vdi_subfunct-bss(a5)
		move.w	graf_h-bss(a5),vdi_device-bss(a5)

		move.w	d0,intin-bss(a5)	*fill color

		bsr	call_vdi
		rts

close_virtual:	move.w	#101,vdi_opcode-bss(a5)
		clr.w	vdi_sptsin-bss(a5)
		clr.w	vdi_sintout-bss(a5)
		clr.w	vdi_sptsout-bss(a5)
		clr.w	vdi_sintin-bss(a5)
		move.w	graf_h-bss(a5),vdi_device-bss(a5)

		bsr	call_vdi

		rts

wind_get:	move.w	#104,aes_opcode-bss(a5)
		move.w	#2,aes_sintin-bss(a5)
		move.w	#5,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)
		move.w	d1,intin+2-bss(a5)

		bsr	call_aes
		rts

wind_update:	move.w	#107,aes_opcode-bss(a5)
		move.w	#1,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)

		bsr	call_aes
		rts

wind_calc:	move.w	#108,aes_opcode-bss(a5)
		move.w	#6,aes_sintin-bss(a5)
		move.w	#5,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d4,intin-bss(a5)
		move.w	d5,intin+2-bss(a5)
		move.w	d0,intin+4-bss(a5)
		move.w	d1,intin+6-bss(a5)
		move.w	d2,intin+8-bss(a5)
		move.w	d3,intin+10-bss(a5)

		bsr	call_aes
		rts

objc_draw:	move.w	#42,aes_opcode-bss(a5)
		move.w	#6,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*object to begin with
		move.w	d1,intin+2-bss(a5)		*depth

		move.w	d2,intin+4-bss(a5)		*the clipping area x,
		move.w	d3,intin+6-bss(a5)		*y

		move.w	d4,intin+8-bss(a5)		*w
		move.w	d5,intin+10-bss(a5)		*h

		move.l	a0,addrin-bss(a5)		*tree address

		bsr	call_aes
		rts

objc_find:	move.w	#43,aes_opcode-bss(a5)
		move.w	#4,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*object to begin with
		move.w	d1,intin+2-bss(a5)		*depth

		move.w	d2,intin+4-bss(a5)		*mouse x
		move.w	d3,intin+6-bss(a5)		*y

		move.l	a0,addrin-bss(a5)		*tree address

		bsr	call_aes
		rts

objc_offset:	move.w	#44,aes_opcode-bss(a5)
		move.w	#1,aes_sintin-bss(a5)
		move.w	#3,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*object #

		move.l	a0,addrin-bss(a5)		*tree address

		bsr	call_aes
		rts

objc_change:	move.w	#47,aes_opcode-bss(a5)
		move.w	#8,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*object to begin with
		clr.w	intin+2-bss(a5)
		move.w	d1,intin+4-bss(a5)		*clipping,x
		move.w	d2,intin+6-bss(a5)		*y
		move.w	d3,intin+8-bss(a5)		*w
		move.w	d4,intin+10-bss(a5)		*h

		move.w	d5,intin+12-bss(a5)		*new status word
		move.w	d6,intin+14-bss(a5)		*redraw flag

		move.l	a0,addrin-bss(a5)		*tree address

		bsr	call_aes
		rts

fsel_input:	move.w	#90,aes_opcode-bss(a5)
		move.w	#0,aes_sintin-bss(a5)
		move.w	#2,aes_sintout-bss(a5)
		move.w	#4,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.l	a0,addrin-bss(a5)		*path
		move.l	a1,addrin+4-bss(a5)		*name
		move.l	a2,addrin+8-bss(a5)		*top msg(not std)
		move.l	a3,addrin+12-bss(a5)		*bottom msg(not std)

		bsr	call_aes
		rts

graf_mouse:	move.w	#78,aes_opcode-bss(a5)
		move.w	#1,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)
		move.l	a0,addrin-bss(a5)		*if d0=255, address
							*shape ...
		bsr	call_aes
		rts

graf_growbox:	move.w	#73,aes_opcode-bss(a5)
		move.w	#8,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*start x
		move.w	d1,intin+2-bss(a5)		*start y
		move.w	d2,intin+4-bss(a5)		*start w
		move.w	d3,intin+6-bss(a5)		*start h

		move.w	d4,intin+8-bss(a5)		*end x
		move.w	d5,intin+10-bss(a5)		*end y
		move.w	d6,intin+12-bss(a5)		*end w
		move.w	d7,intin+14-bss(a5)		*end h

		bsr	call_aes
		rts

graf_shrinkbox:	move.w	#74,aes_opcode-bss(a5)
		move.w	#8,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*start x
		move.w	d1,intin+2-bss(a5)		*start y
		move.w	d2,intin+4-bss(a5)		*start w
		move.w	d3,intin+6-bss(a5)		*start h

		move.w	d4,intin+8-bss(a5)		*end x
		move.w	d5,intin+10-bss(a5)		*end y
		move.w	d6,intin+12-bss(a5)		*end w
		move.w	d7,intin+14-bss(a5)		*end h

		bsr	call_aes
		rts

menu_bar:	move.w	#30,aes_opcode-bss(a5)
		move.w	#1,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*show flag, 1=s,0=e

		move.l	a0,addrin-bss(a5)		*tree address

		bsr	call_aes
		rts

menu_register:	move.w	#35,aes_opcode-bss(a5)
		move.w	#1,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*object #

		move.l	a0,addrin-bss(a5)		*tree address

		bsr	call_aes
		rts

menu_icheck:	move.w	#31,aes_opcode-bss(a5)
		move.w	#2,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*object #
		move.w	d1,intin+2-bss(a5)		*show flag, 1=s,0=e

		move.l	a0,addrin-bss(a5)		*tree address

		bsr	call_aes
		rts

menu_enable:	move.w	#32,aes_opcode-bss(a5)
		move.w	#2,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*object #
		move.w	d1,intin+2-bss(a5)		*act f, 1=a,0=d

		move.l	a0,addrin-bss(a5)		*tree address

		bsr	call_aes
		rts

menu_tnormal:	move.w	#33,aes_opcode-bss(a5)
		move.w	#2,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)		*object # (title #)
		move.w	d1,intin+2-bss(a5)		*rev. flag, 1=n,0=r

		move.l	a0,addrin-bss(a5)		*tree address

		bsr	call_aes
		rts

init_em_parameters:
		move.w	#25,aes_opcode-bss(a5)
		move.w	#16,aes_sintin-bss(a5)
		move.w	#7,aes_sintout-bss(a5)
		move.w	#1,aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		clr.w	intin-bss(a5)
		clr.l	addrin-bss(a5)
		rts

setup_em_keyboard:
		or.w	#1,intin-bss(a5)
		rts

setup_em_mouse1:
		or.w	#4,intin-bss(a5)

		move.w	d0,intin+8-bss(a5)	*moflags, 0=end upon entry
						*1=end upon exit
		move.w	d1,intin+10-bss(a5)	*x
		move.w	d2,intin+12-bss(a5)	*y
		move.w	d3,intin+14-bss(a5)	*w
		move.w	d4,intin+16-bss(a5)	*h
		rts

setup_em_mouse2:
		or.w	#8,intin-bss(a5)

		move.w	d0,intin+18-bss(a5)	*moflags, 0=end upon entry
						*1=end upon exit
		move.w	d1,intin+20-bss(a5)	*x
		move.w	d2,intin+22-bss(a5)	*y
		move.w	d3,intin+24-bss(a5)	*w
		move.w	d4,intin+26-bss(a5)	*h
		rts

setup_em_mesag:
		or.w	#16,intin-bss(a5)

		move.l	a0,addrin-bss(a5)	*address to message buffer

		move.l	a0,d0

		moveq	#0,d1

		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+
		move.l	d1,(a0)+

		move.l	d0,a0
		rts

setup_em_button:
		or.w	#2,intin-bss(a5)

		move.w	d0,intin+2-bss(a5)	*number of clicks
		move.w	d1,intin+4-bss(a5)	*mask
		move.w	d2,intin+6-bss(a5)	*status
		rts

setup_em_timer:
		or.w	#32,intin-bss(a5)

		move.w	d0,intin+28-bss(a5)	*timer, low word
		swap	d0
		move.w	d0,intin+30-bss(a5)	*high word
		rts

do_evnt_multi:
		bsr	call_aes
		rts

wind_create:	move.w	#100,aes_opcode-bss(a5)
		move.w	#5,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d4,intin-bss(a5)
		move.w	d0,intin+4-bss(a5)
		move.w	d1,intin+6-bss(a5)
		move.w	d2,intin+8-bss(a5)
		move.w	d3,intin+10-bss(a5)

		bsr	call_aes
		rts

wind_delete:	move.w	#103,aes_opcode-bss(a5)
		move.w	#1,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)

		bsr	call_aes
		rts

wind_open:	move.w	#101,aes_opcode-bss(a5)
		move.w	#5,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d4,intin-bss(a5)

		move.w	d0,intin+2-bss(a5)
		move.w	d1,intin+4-bss(a5)
		move.w	d2,intin+6-bss(a5)
		move.w	d3,intin+8-bss(a5)

		bsr	call_aes
		rts

wind_close:	move.w	#102,aes_opcode-bss(a5)
		move.w	#1,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)

		bsr	call_aes
		rts

wind_set:	move.w	#105,aes_opcode-bss(a5)
		move.w	#6,aes_sintin-bss(a5)
		move.w	#1,aes_sintout-bss(a5)
		clr.w	aes_saddrin-bss(a5)
		clr.w	aes_saddrout-bss(a5)

		move.w	d0,intin-bss(a5)
		move.w	d1,intin+2-bss(a5)

		move.w	d2,intin+4-bss(a5)
		move.w	d3,intin+6-bss(a5)
		move.w	d4,intin+8-bss(a5)
		move.w	d5,intin+10-bss(a5)

		bsr	call_aes
		rts

init_aes_sys:	lea	aes_pb-bss(a5),a3

		lea	aes_control-bss(a5),a2
		move.l	a2,(a3)+
		lea	aes_global-bss(a5),a2
		move.l	a2,(a3)+
		lea	intin-bss(a5),a2
		move.l	a2,(a3)+
		lea	intout-bss(a5),a2
		move.l	a2,(a3)+
		lea	addrin-bss(a5),a2
		move.l	a2,(a3)+
		lea	addrout-bss(a5),a2
		move.l	a2,(a3)+
		rts

init_vdi_sys:	lea	vdi_pb-bss(a5),a3

		lea	vdi_control-bss(a5),a2
		move.l	a2,(a3)+
		lea	intin-bss(a5),a2
		move.l	a2,(a3)+
		lea	ptsin-bss(a5),a2
		move.l	a2,(a3)+
		lea	intout-bss(a5),a2
		move.l	a2,(a3)+
		lea	ptsout-bss(a5),a2
		move.l	a2,(a3)+
		rts

call_aes:	lea	aes_pb-bss(a5),a0

		move.l	a0,d1
		move.l	#$c8,d0
		trap	#2

		move.w	intout-bss(a5),d0
		rts

call_vdi:	lea	vdi_pb-bss(a5),a0

		move.l	a0,d1
		moveq	#$73,d0
		trap	#2

		move.w	intout-bss(a5),d0
		rts

ob_flags:	mulu	#24,d0
		move.w	8(a0,d0.l),d0
		rts

ob_state:	mulu	#24,d0
		move.w	10(a0,d0.l),d0
		rts

set_ob_flags:	mulu	#24,d0
		move.w	d1,8(a0,d0.l)
		rts

set_ob_state:	mulu	#24,d0
		move.w	d1,10(a0,d0.l)
		rts


init_once:	bsr	init_aes_sys
		bsr	init_vdi_sys

		bsr	appl_init

		move.w	d0,appl_id-bss(a5)
		bmi	quit_right_now

		move.w	aes_version-bss(a5),d0
		beq	auto_load

		lea	$80(a6),a1		*command line address
		lea	path-bss(a5),a0		*path and name of me

		bsr	shel_read

		lea	path-bss(a5),a0		*get path address

find_end_of_prg_path:
		tst.b	(a0)+
		bne	find_end_of_prg_path

		lea	-5(a0),a0		*compensate for .??? + NULL

		move.b	(a0)+,d0
		ror.l	#8,d0 

		move.b	(a0)+,d0
		ror.l	#8,d0 

		move.b	(a0)+,d0
		ror.l	#8,d0 

		move.b	(a0)+,d0
		ror.l	#8,d0 

		cmp.l	#"CCA.",d0
		bne.s	not_acc_loaded

		st	acc_load-bss(a5)
not_acc_loaded:
		clr.w	loaded_rezf-bss(a5)	*rezfool NOT loaded
		bsr	get_cookie

		move.l	text_adr-bss(a5),d0	*rezfool resident ???
		beq.s	no_search_command

		move.w	#1,loaded_rezf-bss(a5)	*mark that it was resident

		tst.b	$80(a6)			*any command line
		bne	auto_load

		bsr	check_for_rezfool	*is there a 'REZFOOL='

		tst.l	enviro_adr-bss(a5)	*if so, skip this shit
		bne	auto_load

no_search_command:
		bsr	graf_handle

		move.w	d0,graf_h-bss(a5)

		move.w	intout+2-bss(a5),char_width-bss(a5)
		move.w	intout+4-bss(a5),char_heigth-bss(a5)

		move.w	#"er",desk_id-bss(a5)

		moveq	#2,d0			*Real Cordinates
		bsr	open_virtual

		bsr	obfix_resource

		move.l	#editfile*4,rcs_screen-bss(a5)
		move.l	#-1,info_temp-bss(a5)

		tst.l	text_adr-bss(a5)
		bne.s	allow_memory_edit

		move.l	tree_pointer-bss(a5),a0
		move.l	editfile*4(a0),a0

		lea	edit_mem*24(a0),a0

		move.l	8(a0),d0
		move.l	d0,org_status_emb-bss(a5)
		and.l	#$fffefffe,d0
		or.l	#8,d0
		move.l	d0,8(a0)		

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#edit_mem_menu,d0
		moveq	#0,d1

		bsr	menu_enable

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#reset_menu,d0
		moveq	#0,d1

		bsr	menu_enable
allow_memory_edit:
		moveq	#0,d4			*output total dimensions
		moveq	#%1011,d5

		move.l	tree_pointer-bss(a5),a0

		move.l	editfile*4(a0),a0	*get first tree information

		move.w	16(a0),d0
		move.w	18(a0),d1
		move.w	20(a0),d2
		move.w	22(a0),d3

		bsr	wind_calc

		move.w	intout+6-bss(a5),d6
		move.w	intout+8-bss(a5),d7

		moveq	#0,d0			*desktop
		moveq	#4,d1			*get size

		bsr	wind_get

		move.w	d6,d2			*width of working area
		move.w	d7,d3			*heigth of working area
		
		move.w	intout+6-bss(a5),d0	*width of desktop
		lsr.w	#1,d0			*/2

		move.w	d2,d4			*width of window
		lsr.w	#1,d4			*/2

		sub.w	d4,d0			*center
		add.w	intout+2-bss(a5),d0	*relocate (this should be 0)

		move.w	intout+8-bss(a5),d1	*heigth of desktop
		lsr.w	#1,d1			*/2

		move.w	d3,d4			*heigth of window
		lsr.w	#1,d4			*/2

		sub.w	d4,d1			*center
		add.w	intout+4-bss(a5),d1	*relocate (this should be 0)
		
		move.w	d0,window_x-bss(a5)
		move.w	d1,window_y-bss(a5)
		move.w	d2,window_w-bss(a5)
		move.w	d3,window_h-bss(a5)
		rts

position_trees:	move.l	tree_pointer-bss(a5),a0
		move.l	4*editfile(a0),a0

		move.w	work_x-bss(a5),16(a0)
		move.w	work_y-bss(a5),18(a0)

		move.l	tree_pointer-bss(a5),a0
		move.l	4*editmem(a0),a0

		move.w	work_x-bss(a5),16(a0)
		move.w	work_y-bss(a5),18(a0)

		move.l	tree_pointer-bss(a5),a0
		move.l	4*info_form(a0),a0

		move.w	work_x-bss(a5),16(a0)
		move.w	work_y-bss(a5),18(a0)

		tst.l	text_adr-bss(a5)
		bne	start_on_memory_screen

		rts

start_on_memory_screen:
		move.l	#editmem*4,rcs_screen-bss(a5)
		rts

popup_window:


		move.w	window_x-bss(a5),d0
		move.w	window_y-bss(a5),d1
		move.w	window_w-bss(a5),d2
		move.w	window_h-bss(a5),d3

		moveq	#%1011,d4

		bsr	wind_create

		move.w	d0,window_handle-bss(a5)

		lea	window_name-data(a4),a0
		move.l	a0,d2
		move.l	d2,d3
		swap	d2

		moveq	#2,d1

		bsr	wind_set

		moveq	#1,d0
		bsr	wind_update

		move.w	window_x-bss(a5),d0
		move.w	window_y-bss(a5),d1
		move.w	window_w-bss(a5),d2
		move.w	window_h-bss(a5),d3

		move.w	d0,d4
		move.w	d1,d5
		move.w	d2,d6
		move.w	d3,d7

		lsr.w	#1,d2
		lsr.w	#1,d3

		add.w	d2,d0
		add.w	d3,d1

		moveq	#1,d2
		moveq	#1,d3

		bsr	graf_growbox

		move.w	window_x-bss(a5),d0
		move.w	window_y-bss(a5),d1
		move.w	window_w-bss(a5),d2
		move.w	window_h-bss(a5),d3
		move.w	window_handle-bss(a5),d4

		bsr	wind_open

		moveq	#0,d0
		bsr	wind_update

		move.w	window_handle-bss(a5),d0
		moveq	#4,d1

		bsr	wind_get

		move.w	intout+2-bss(a5),work_x-bss(a5)
		move.w	intout+4-bss(a5),work_y-bss(a5)
		move.w	intout+6-bss(a5),work_w-bss(a5)
		move.w	intout+8-bss(a5),work_h-bss(a5)

		bsr	position_trees
		rts

close_window:	move.w	window_handle-bss(a5),d0
		bsr	wind_close

		move.w	window_x-bss(a5),d0
		move.w	window_y-bss(a5),d1
		move.w	window_w-bss(a5),d2
		move.w	window_h-bss(a5),d3

		move.w	d0,d4
		move.w	d1,d5
		move.w	d2,d6
		move.w	d3,d7

		lsr.w	#1,d6
		lsr.w	#1,d7

		add.w	d6,d4
		add.w	d7,d5

		moveq	#1,d6
		moveq	#1,d7

		bsr	graf_shrinkbox
		rts

delete_window:
		move.w	window_handle-bss(a5),d0
		bsr	wind_delete
		rts

update_screen:	moveq	#1,d0				*begupd
		bsr	wind_update

		move.w	window_handle-bss(a5),d0	*get workarea
		moveq	#4,d1				*coords

		bsr	wind_get

		move.w	intout+2-bss(a5),work_x-bss(a5)	*save, so we now it's
		move.w	intout+4-bss(a5),work_y-bss(a5)	*current position
		move.w	intout+6-bss(a5),work_w-bss(a5)
		move.w	intout+8-bss(a5),work_h-bss(a5)

		move.l	tree_pointer-bss(a5),a0		*
		add.l	rcs_screen-bss(a5),a0
		move.l	(a0),a0

		move.w	work_x-bss(a5),16(a0)	*update tree coordinates
		move.w	work_y-bss(a5),18(a0)

		move.w	window_handle-bss(a5),d0	*get updatearea
		moveq	#11,d1				*coords rect #1

		bsr	wind_get

update_by_rl_loop:		
		tst.l	intout+6-bss(a5)	*width&height=0? (then done)
		beq	no_more_updating

		move.l	tree_pointer-bss(a5),a0	*tree pointers
		add.l	rcs_screen-bss(a5),a0	*current tree
		move.l	(a0),a0			*get address

		moveq	#0,d0			*start drawing object null
		moveq	#7,d1			*7 sublevels

		move.w	intout+2-bss(a5),d2	*clipping, x
		move.w	intout+4-bss(a5),d3	*clipping, y
		move.w	intout+6-bss(a5),d4	*clipping, w
		move.w	intout+8-bss(a5),d5	*clipping, h

		bsr	objc_draw		*draw it

		move.w	window_handle-bss(a5),d0	*get updatearea
		moveq	#12,d1				*coords rect #n

		bsr	wind_get
		bra.s	update_by_rl_loop
no_more_updating:
		moveq	#0,d0			*endupd
		bsr	wind_update

		bra	window_handling_loop

top_my_window:	move.w	window_handle-bss(a5),d0
		moveq	#10,d1

		bsr	wind_set

		cmp.l	#4*editmem,rcs_screen-bss(a5)
		beq	update_mem_screen

		cmp.l	#4*editfile,rcs_screen-bss(a5)
		beq	update_file_screen
		bra	window_handling_loop

menu_options:	move.w	em_buffer+6-bss(a5),d0
		moveq	#1,d1

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		bsr	menu_tnormal

		move.w	em_buffer+8-bss(a5),d0

		cmp.w	#about,d0
		beq	show_info

		tst.l	text_adr-bss(a5)
		beq	dont_check_mem_mc

		cmp.l	#editmem*4,rcs_screen-bss(a5)
		beq.s	dont_check_mem_mc

		cmp.w	#edit_mem_menu,d0
		bne.s	dont_check_mem_mc

		move.l	#-1,info_temp-bss(a5)
		move.l	#editmem*4,rcs_screen-bss(a5)
		bra	exit_toggle

dont_check_mem_mc:
		cmp.l	#editfile*4,rcs_screen-bss(a5)
		beq.s	dont_check_file_mc

		cmp.w	#edit_file_menu,d0
		bne.s	dont_check_file_mc

		move.l	#-1,info_temp-bss(a5)
		move.l	#editfile*4,rcs_screen-bss(a5)
		bra	exit_toggle

dont_check_file_mc:
		cmp.w	#quit_menu,d0
		beq	close_window_and_exit

		cmp.w	#reset_menu,d0
		beq	reset_sets

		cmp.w	#write_menu,d0
		beq	write_to_file

		bra	window_handling_loop


write_to_file:	move.w	#$19,-(sp)		*get current drive
		trap	#1
		addq.l	#2,sp

		add.b	#"A",d0			*make it a letter
		move.b	d0,path-bss(a5)

		move.b	#":",path+1-bss(a5)

		clr.w	-(sp)
		pea	path+2-bss(a5)
		move.w	#$47,-(sp)
		trap	#1
		addq.l	#8,sp

		lea	path-bss(a5),a0

find_pathend:	tst.b	(a0)+
		bne.s	find_pathend

		subq.l	#1,a0

		move.b	#"\",(a0)+

		lea	filename-bss(a5),a1

		move.b	#"R",(a0)+
		move.b	#"E",(a0)+
		move.b	#"Z",(a0)+
		move.b	#"_",(a0)+
		move.b	#"F",(a0)+
		move.b	#".",(a0)+
		move.b	#"P",(a0)+
		move.b	#"R",(a0)+
		move.b	#"G",(a0)+

		move.b	#"R",(a1)+
		move.b	#"E",(a1)+
		move.b	#"Z",(a1)+
		move.b	#"_",(a1)+
		move.b	#"F",(a1)+
		move.b	#".",(a1)+
		move.b	#"P",(a1)+
		move.b	#"R",(a1)+
		move.b	#"G",(a1)+

		clr.b	(a0)+

		lea	path-bss(a5),a0
		lea	filename-bss(a5),a1
		lea	where_is-data(a4),a2
		lea	rez_fooler_t-data(a4),a3

		bsr	fsel_input

		move.w	intout+2-bss(a5),d0	*cancel selected ?
		beq	cancel_selected

		move.b	path-bss(a5),d0		*change	to	specified	drive
		sub.b	#"A",d0
		and.l	#$ff,d0

		move.w	d0,-(sp)
		move.w	#14,-(sp)
		trap	#1
		addq.l	#4,sp

		lea	path-bss(a5),a0

find_end_of_path:
		tst.b	(a0)+
		bne.s	find_end_of_path

find_path_end:	cmpi.b	#"\",-(a0)
		bne.s	find_path_end

		tst.b	(a0)+

		movea.l	a0,a6
		clr.b	(a0)+

		pea	path-bss(a5)		*set path
		move.w	#$3b,-(sp)
		trap	#1
		addq.l	#6,sp

		tst.w	d0			*can goto that path
		bmi	show_up_box

		lea	filename-bss(a5),a1

		moveq	#11,d7

copy_name:	move.b	(a1)+,(a6)+
		dbra	d7,copy_name

		pea	dta-bss(a5)
		move.w	#$1a,-(sp)
		trap	#1
		addq.l	#6,sp

		move.w	#0,-(sp)
		pea	path-bss(a5)
		move.w	#$4e,-(sp)
		trap	#1
		lea	8(sp),sp

		tst.w	d0			*file coulde be located
		bmi	write_to_file

		lea	decode_table-data(a4),a0

		move.w	got_file-bss(a5),d0
		asl.w	#1,d0

		move.w	0(a0,d0.w),decode_fw-bss(a5)		

		move.w	want_file-bss(a5),d0
		asl.w	#1,d0
		move.w	0(a0,d0.w),decode_fw+2-bss(a5)		

		move.w	#2,-(sp)		*r/w access
		pea	path-bss(a5)
		move.w	#$3d,-(sp)
		trap	#1
		addq.l	#8,sp

		tst.w	d0
		bmi	show_we_box

		move.w	d0,file_handle-bss(a5)

		clr.w	-(sp)
		move.w	file_handle-bss(a5),-(sp)
		pea	$1c.w
		move.w	#$42,-(sp)
		trap	#1
		lea	10(sp),sp

		tst.l	d0
		bmi	show_we_box

		pea	safety_check-bss(a5)
		pea	2.w
		move.w	file_handle-bss(a5),-(sp)
		move.w	#$3f,-(sp)
		trap	#1
		lea	12(sp),sp

		cmp.l	#2,d0
		bne	show_we_box

		move.w	safety_check-bss(a5),d0
		move.w	d0,d1

		and.w	#$ff00,d0		*only high byte
		cmp.w	#$6000,d0		*bra ???
		bne	not_rez_f		*no, faked

		cmp.w	d0,d1			*bra.s ?
		beq	not_rez_f		*no, faked

		pea	decode_fw-bss(a5)
		pea	4.w
		move.w	file_handle-bss(a5),-(sp)
		move.w	#$40,-(sp)
		trap	#1
		lea	12(sp),sp

		cmp.l	#4,d0
		bne	show_we_box

		move.w	file_handle-bss(a5),-(sp)
		move.w	#$3e,-(sp)
		trap	#1
		addq.l	#8,sp

		tst.w	d0
		bmi	show_we_box

		move.l	#good_write*4,d0
		bra.s	show_other_box

cancel_selected:
		bra	window_handling_loop

not_rez_f:	move.l	#faked*4,d0
		bra.s	show_other_box

show_we_box:	move.l	#write_e*4,d0
		bra.s	show_other_box

show_up_box:	move.l	#unknown_path*4,d0

show_other_box:	cmp.l	#editmem*4,rcs_screen-bss(a5)
		bne.s	not_save_on_em_screen

		move.l	#editmem*4,info_temp-bss(a5)
not_save_on_em_screen:
		cmp.l	#editfile*4,rcs_screen-bss(a5)
		bne.s	not_save_on_ef_screen

		move.l	#editfile*4,info_temp-bss(a5)
not_save_on_ef_screen:

		move.l	d0,rcs_screen-bss(a5)

		bsr	exit_toggle
		bra	window_handling_loop

obfix_resource:	lea	resource_file-data(a4),a3

*start by relocating all the object trees...

*
* I know this is dirty, so don't tell me
*

		move.w	18(a3),d7

		lea	0(a3,d7.w),a0

		move.l	a0,tree_pointer-bss(a5)
r_ob_tree_loop:
		move.l	(a0),d0
		beq.s	done_tree_r

		add.l	a3,d0
		move.l	d0,(a0)+
		bra.s	r_ob_tree_loop		
done_tree_r:
		lea	0(a3,d7.w),a2
		lea	top_end_at_buf-4-bss(a5),a1
		lea	default_list-2-bss(a5),a0

r_trees:	move.l	(a2)+,d6
		bne	no_end_of_reloc
		rts

no_end_of_reloc:
		sub.l	a3,d6

		tst.w	(a0)+
		move.w	#-1,(a0)

		moveq	#0,d4
		move.w	2(a3),d4
		sub.l	d4,d6
		divu	#24,d6

		move.l	#"WtP!",(a1)

		moveq	#0,d5
*		move.w	(a3),d5		

		move.w	#"†t",-(sp)
		move.w	d5,-(sp)
		bra	jump_out

r_tree_loop:	move.w	d5,d0
		add.w	d6,d0

*		sub.w	(a3),d0
		mulu	#24,d0
		
		add.w	2(a3),d0

		moveq	#0,d1
		moveq	#0,d2

		move.b	17(a3,d0.w),d1
		mulu	char_width-bss(a5),d1
		move.b	16(a3,d0.w),d2

		add.l	d2,d1

		move.w	d1,16(a3,d0.w)

		moveq	#0,d1
		moveq	#0,d2

		move.b	19(a3,d0.w),d1
		mulu	char_heigth-bss(a5),d1
		move.b	18(a3,d0.w),d2

		add.l	d2,d1
		move.w	d1,18(a3,d0.w)

		moveq	#0,d1
		moveq	#0,d2

		move.b	21(a3,d0.w),d1
		mulu	char_width-bss(a5),d1
		move.b	20(a3,d0.w),d2
		add.l	d2,d1
		move.w	d1,20(a3,d0.w)

		moveq	#0,d1
		moveq	#0,d2

		move.b	23(a3,d0.w),d1
		mulu	char_heigth-bss(a5),d1
		move.b	22(a3,d0.w),d2
		add.l	d2,d1
		move.w	d1,22(a3,d0.w)

		move.w	8(a3,d0.w),d1
		and.w	#7,d1
		cmp.w	#7,d1
		bne.s	not_default

		move.w	d5,(a0)
not_default:
		move.w	6(a3,d0.w),d1

		move.l	a0,-(sp)
		bsr	relocate_object
		move.l	(sp)+,a0

		cmp.w	(a1),d5
		bne	not_last_child

		tst.w	(a1)+
		bra.s	end_of_chain

not_last_child:	move.w	0(a3,d0.w),d1
		bmi	end_of_chain

		move.w	d1,-(sp)

end_of_chain:	move.w	2(a3,d0.w),d1
		bmi	no_children
		
		move.w	d1,-(sp)
		move.w	4(a3,d0.w),-(a1)
no_children:

jump_out:	move.w	(sp)+,d5

		cmp.w	#"†t",d5
		beq	r_trees

		bra	r_tree_loop

relocate_object:
		cmp.w	#20,d1
		beq	no_relocate_object

		cmp.w	#25,d1
		beq	no_relocate_object
r
		cmp.w	#27,d1
		beq	no_relocate_object

		move.l	a3,d2
		add.l	d2,12(a3,d0.w)

		move.l	12(a3,d0.w),a0

		cmp.w	#21,d1
		beq	relocate_tedinfo

		cmp.w	#22,d1
		beq	relocate_tedinfo

		cmp.w	#23,d1
		beq	relocate_bitblk

		cmp.w	#24,d1
		beq	relocate_applblk

		cmp.w	#29,d1
		beq	relocate_tedinfo

		cmp.w	#30,d1
		beq	relocate_tedinfo

		cmp.w	#31,d1
		beq	relocate_iconblk

no_relocate_object:
		rts

relocate_tedinfo:
		add.l	d2,(a0)
		add.l	d2,4(a0)
		add.l	d2,8(a0)
		rts	

relocate_iconblk:
		add.l	d2,(a0)
		add.l	d2,4(a0)
		add.l	d2,8(a0)
		rts	

relocate_bitblk:
		add.l	d2,(a0)
		rts	

relocate_applblk:
		add.l	d2,(a0)
		rts	

check_rezf:	tst.w	loaded_rezf-bss(a5)
		bne.s	return_from_crf

		bsr	get_cookie

		tst.l	text_adr-bss(a5)
		beq.s	return_from_crf

		move.w	#2,loaded_rezf-bss(a5)

		move.l	tree_pointer-bss(a5),a0
		move.l	editfile*4(a0),a0

		lea	edit_mem*24+8(a0),a0

		move.l	org_status_emb-bss(a5),(a0)

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#edit_mem_menu,d0
		moveq	#1,d1

		bsr	menu_enable

		move.l	tree_pointer-bss(a5),a0
		move.l	menu*4(a0),a0

		move.w	#reset_menu,d0
		moveq	#1,d1

		bsr	menu_enable

		move.l	text_adr-bss(a5),a0
		move.l	2(a0),save_mem-bss(a5)	*save got and fool to
return_from_crf:
		rts

get_cookie:	pea	hunt_cookie(pc)
		move.w	#38,-(sp)
		trap	#14
		addq.l	#6,sp

		tst.l	d0
		bmi	cookie_not_found

		move.l	d0,text_adr-bss(a5)
cookie_not_found:
		rts

hunt_cookie:	movem.l d1-d2/a0,-(sp)

		move.l	#"RTFW",d2

		move.l	$5a0.w,d0
		beq.s	no_jar

		move.l	d0,a0

look_for_cookie:
		move.l	(a0)+,d1
		move.l	(a0)+,d0

		cmp.l	d2,d1
		beq.s	found_cookie

		tst.l	d1
		bne.s	look_for_cookie

no_jar:		moveq	#-1,d0
found_cookie:	movem.l	(sp)+,d1-d2/a0
		rts

search_command:	move.l	d0,a1			*text to a1

		lea	$80(a6),a0

		moveq	#0,d6

		moveq	#0,d5
		move.b	(a0)+,d5

		bra.s	init_search_loop

search_command_line:
		move.b	(a0)+,d0

		bsr	upper

		btst	#0,d6
		bne	check_w

		cmp.b	#"G",d0
		beq.s	found_got

check_w:	btst	#1,d6
		bne	init_search_loop

		cmp.b	#"W",d0
		beq.s	found_want

init_search_loop:
		cmp.b	#3,d6
		beq.s	fix_exit_code_asap

		dbra	d5,search_command_line		

end_of_it:	cmp.b	#3,d6
		beq.s	fix_exit_code_asap

		bra	search_rezfool





found_got:	or.b	#1,d6
		move.b	(a0)+,d0
		and.l	#3,d0
		move.w	d0,2(a1)

		dbra	d5,init_search_loop	*fix for dubble read
		bra.s	end_of_it

found_want:	or.b	#2,d6
		move.b	(a0)+,d0
		and.l	#3,d0
		move.w	d0,4(a1)

		dbra	d5,init_search_loop	*fix for dubble read
		bra.s	end_of_it

fix_exit_code_asap:
		move.w	2(a1),d0
		lsl.w	#8,d0
		move.b	5(a1),d0
		bra	quit_right_now


search_rezfool:	move.l	enviro_adr-bss(a5),d0
		beq	auto_loaded

		move.l	d0,a0

		move.b	(a0)+,d0
		beq	auto_loaded

		bsr	upper

		btst	#0,d6
		bne	check_w2

		cmp.b	#"G",d0
		beq.s	found_got2

check_w2:	btst	#1,d6
		bne	check_done_both_gw

		cmp.b	#"W",d0
		beq.s	found_want2

check_done_both_gw:
		cmp.b	#3,d6
		beq.s	fix_exit_code_asap

		bra.s	search_rezfool

found_got2:	or.b	#1,d6
		move.b	(a0)+,d0
		and.l	#3,d0
		move.w	d0,2(a1)
		bra.s	search_rezfool


found_want2:	or.b	#2,d6
		move.b	(a0)+,d0
		and.l	#3,d0
		move.w	d0,4(a1)
		bra.s	search_rezfool

check_for_rezfool:
		move.l	44(a6),a0
		lea	frez-data(a4),a2

		bra	search_enviroment

reset_search:	tst.b	(a0)
		beq.s	no_rezfool

		lea	frez-data(a4),a2

search_enviroment:
		move.b	(a0)+,d0
		bsr	upper

		move.b	(a2)+,d1
		beq.s	found_rezfool

		cmp.b	d0,d1
		beq.s	search_enviroment

find_end_of_cur_var:
		tst.b	d0
		beq.s	reset_search

		move.b	(a0)+,d0
		bra.s	find_end_of_cur_var

found_rezfool:	subq.l	#1,a0
		move.l	a0,enviro_adr-bss(a5)
no_rezfool:
		rts

*
* Converts a to A
*

upper:		cmp.b	#"a",d0
		bmi	ret_upper

		cmp.b	#"z",d0
		bgt	ret_upper

		sub.b	#$20,d0

ret_upper:	rts


		data




*
* {value from cookie}+2; got
*                    +4; want

		even
data:

no_auto_run:	dc.b	$1b,"E","Rez Fooler currently cannot be loaded (w/",$0a,$0d
		dc.b	"interaction) from the \AUTO folder, try loading",$0a,$0d
		dc.b	"from desktop (or your standard shell) instead!",$0a,$0d
		dc.b	$0a,$0d,7,0

		even


*				01234567890123 123456789012
where_is:		dc.b	"Where is the",0
		even
rez_fooler_t:		dc.b	"Rez Fooler ?",0
		even
decode_table:	dc.w	3,1,2,0
		even
window_name:	dc.b	"Rez Fooler Control 1.0",0,0,0,0,0,0
		even
acc_name:	dc.b	"  RF Control",0
		even
frez:		dc.b	"REZFOOL=",0
		even
resource_file:	incbin	"D:\rzf\rez_foo2.rsc"
		even

		dc.l	0

		bss
bss:

aes_pb:		ds.l	6
vdi_pb:		ds.l	5

aes_control:
aes_opcode:	ds.w	1				*command #
aes_sintin:	ds.w	1				*size of intin array, bytes
aes_sintout:	ds.w	1				*size of intout array, bytes
aes_saddrin:	ds.w	1				*size of addrin array, longs
aes_saddrout:	ds.w	1				*size of addrout array, longs

vdi_control:
vdi_opcode:	ds.w	1
vdi_sptsin:	ds.w	1
vdi_sptsout:	ds.w	1
vdi_sintin:	ds.w	1
vdi_sintout:	ds.w	1
vdi_subfunct:	ds.w	1
vdi_device:	ds.w	1
vdi_cd_1:	ds.w	1
vdi_cd_2:	ds.w	1
vdi_cd_3:	ds.w	1
vdi_cd_4:	ds.w	1
vdi_cd_5:	ds.w	1

aes_global:
aes_version:	ds.w	1
aes_count:	ds.w	1
aes_id:		ds.w	1
aes_private:	ds.l	1
aes_tree:	ds.l	1
aes_resv1:	ds.l	1
aes_resv2:	ds.l	1
aes_resv3:	ds.l	1
aes_resv4:	ds.l	1

intin:		ds.w	256
intout:		ds.w	256
ptsin:		ds.w	256
ptsout:		ds.w	256
addrin:		ds.l	128
addrout:	ds.l	128

graf_h:		ds.w	1
appl_id:	ds.w	1
window_handle:	ds.w	1
window_x:	ds.w	1
window_y:	ds.w	1
window_w:	ds.w	1
window_h:	ds.w	1
work_x:		ds.w	1
work_y:		ds.w	1
work_w:		ds.w	1
work_h:		ds.w	1

dta:		ds.b	64
filename:	ds.b	16
path:		ds.b	128+12

em_buffer:	ds.w	256
workout:	ds.w	58
char_width:	ds.w	1
char_heigth:	ds.w	1
rcs_screen:	ds.l	1
tree_pointer:	ds.l	1
info_temp:	ds.l	1
text_adr:	ds.l	1
save_mem:	ds.l	1
got_file:	ds.w	1
want_file:	ds.w	1
enviro_adr:	ds.l	1
decode_fw:	ds.l	1
file_handle:	ds.w	1
safety_check:	ds.w	1
acc_load:	ds.w	1
desk_id:	ds.w	1
default_list:	ds.w	32
org_status_emb:	ds.l	1
loaded_rezf:	ds.w	1
		ds.w	64
top_end_at_buf:	ds.w	1

		ds.l	1024
stack:		ds.l	1
		end
