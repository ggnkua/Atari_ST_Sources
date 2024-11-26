* Full AES shell routines
*   by James Ingram,  April 1993
*     Written entirely using Devpac 3
*
* some calls use registers to pass the data.
* However, in cases where there are more than 8 peices of data needed
* for aintin, the stack is also used.
* In ALL cases, the command number is passed on the stack.
* My shell will re-adjust the stack itself, so
*	move.w	 #command,-(a7)
*	bsr	aes
*	addq.w	 #2,a7  *** THIS LINE NOT NEEDED!
*
*
* N.B. These routines trash ALL data regs d0 - d7
* and the address regs a0-a1!
*
*
* Tab setting is 8
*
* This code may be INCLUDED in other code
* or assembled to be linked.
* use the source "MK_LIB.S" to include in library file





	ifd	link_library
	MODULE	aes_shel

	XDEF	aes,aes_vars
	endc


*	cargs	aes_command.w

	ifd	link_library
	section	text
	endc

aes:
	pea	(a6)
	move.l	#aes_vars,a6

	movem.l	a2-5,_addr_store+4(a6)

	move.l	(a7)+,a2
	move.l	a2,_addr_store(a6)

* get & store return addr
	move.l	(a7)+,aes_ret_addr
	

* put the command number into the cntrl0 variable!
	move.w	(a7)+,_cntrl0(a6)

	movem.w	d0-d2,_aes_temp(a6)	; store params

	move.w	_cntrl0(a6),d2

	clr.w	d0	; cannot be a moveq, because the MOVEM stores only words!

	lea	_command_list(pc),a5

_get_command:
	move.b	(a5)+,d1
	beq.s	_invalid_command

	cmp.b	d1,d2
	beq.s	_got_command

* not this command!
	addq.w	#2,d0
	bra.s	_get_command

_got_command:
* now jump to paticular routine...
	lea	_routines(pc),a5
	moveq	#0,d1
	move.w	(a5,d0.w),d1

	lea	aes(pc),a5
	add.l	d1,a5

	movem.w	_aes_temp(a6),d0-d2

	jmp	(a5)		; jump to correct routine

_invalid_command:
	movem.w	(a7)+,d0-d2

	moveq	#-1,d0
	move.l	aes_ret_addr,a5
	jmp	(a5)		; return


_unload_resource:
*	none

_wait_keyboard:
*	none

_clean_up:
*	none

_innit_appl:
*	none

	lea	_a_0100(pc),a5
	bra	_do_aes

_a_0100:
	dc.w	0
	dc.w	1
	dc.w	0
	dc.w	0


_store_resource_addr:
*	stucture type	d0
*	index arry	d1
*	tree addr	a0

_reorder:
*	object to move	d0
*	new position	d1
*	tree addr	a0

_add_object:
_menu_item:		; exactly the same parameters!
_toggle_item:
_change_item:
_checkmark:
*	object no of menu item	d0
*	display / erase check	d1
*	tree address		a0

_play_macro:
*	no of actions 		d0
*	speed 			d1
*	buffer to play from .l	a0

_write_mes:
_read_mes:
*	application ID		d0
*	message length		d1
*	message buffer addr .l	a0

	lea	_a_2110(pc),a5
	movem.w	d0-d1,2(a5)
	move.l	a0,10(a5)
	bra	_do_aes

_a_2110:
	dc.w	2,0,0
	dc.w	1
	dc.w	1,0,0
	dc.w	0


_search_file:
*	addr of filename (returns full path)	a0

_load_resource:
*	addr of filename	a0

_write_scrap:
*	addr of new pathname	a0

_read_scrap:
*	addr of buffer for pathname	a0

_wait_message:
*	addr of message buffer .l	a0

_find_id:
*	addr of name to find .l		a0


	lea	_a_0110(pc),a5
	move.l	a0,6(a5)
	bra	_do_aes


_a_0110:
	dc.w	0
	dc.w	1
	dc.w	1,0,0
	dc.w	0


_fix_objects:
*	object no	d0
*	tree addr	a0

_change_mouse:
*	shape		d0
*	shape addr	a0

_alert_box:
*	default button	d0
*	addr of text	a0

_handle_dialog:
*	editable object		d0
*	tree addr		a0

_delete_object:
_add_item:
*	application ID		d0
*	addr of menu text	a0

_record_macro:
*	no of actions 		d0
*	buffer addr .l		a0


	lea	_a_1110(pc),a5
	move.w	d0,2(a5)
	move.l	a0,8(a5)
	bra	_do_aes


_a_1110:
	dc.w	1,0
	dc.w	1
	dc.w	1,0,0
	dc.w	0



_wait_button:
*	no of clicks 	d0
*	which buttons 	d1
*	button state 	d2


	lea	_a_3500(pc),a5

	movem.w	d0-d2,2(a5)
	bra	_do_aes

_a_3500:
	dc.w	3,0,0,0
	dc.w	5
	dc.w	0
	dc.w	0


_wait_rect:
*	flag for enter / leave	d0
*	x co-ord 		d1
*	y co-ord 		d2
*	width 			d3
*	height 			d4


	lea	a_5500(pc),a5
	movem.w	d0-d4,2(a5)

	bra	_do_aes


a_5500:
	dc.w	5,0,0,0,0,0
	dc.w	5
	dc.w	0
	dc.w	0



_find_window:
*	mousex		d0
*	mousey		d1

_wait_timer:
*	timerlo		d0
*	timerhi		d1


	lea	_a_2100(pc),a5

	movem.w	d0-d1,2(a5)
	
	bra	_do_aes


_a_2100:
	dc.w	2,0,0
	dc.w	1
	dc.w	0
	dc.w	0



_wait_multi:
*	events		d0
*	click to wait	d1
*	buttons		d2
*	state		d3
* {rectangle 1}
*	enter / leave flag	d4
*	rect1 x		d5
*	rect1 y		d6
*	rect1 w		d7
*	rect1 h		stack
* {rectangle 2}
*	rect2 x		stack
*	rect2 y		stack
*	rect2 w		stack
*	rect2 h		stack
*
*	timerlo		stack
*	timerhi		stack
*
*	mesasage buffer	a0

	lea	_wm_vars(pc),a5
	movem.w	d0-d7,(a5)	; put in data regs

	move.l	a0,multi_addr

	lea	_end_multi(pc),a5

	moveq	#8-1,d0
cop_multi:
	move.w	(a7)+,-(a5)	; put in stack vars in reverse
	dbra	d0,cop_multi
	
	lea	a_wait_multi(pc),a5
	bra	_do_aes


a_wait_multi:
	dc.w	16
_wm_vars:
	ds.w	16
_end_multi:
	dc.w	7
	dc.w	1
multi_addr:
	ds.l	1
	dc.w	0


_click_speed:
*	speed of click		d0
*	set / read flag		d1

	lea	_a_click_speed(pc),a5

	movem.w	d0-d1,2(a5)
	bra	_do_aes


_a_click_speed:
	dc.w	2,0,0
	dc.w	1
	dc.w	0
	dc.w	0


_menu_bar:
*	display / erase flag	d0
*	tree address		a0

	lea	_a_menu_bar(pc),a5
	move.w	d0,2(a5)
	move.l	a0,8(a5)
	bra	_do_aes


_a_menu_bar:
	dc.w	1,0
	dc.w	1
	dc.w	1,0,0
	dc.w	0


_draw_tree:
*	first object	d0
*	depth		d1
*	clipx		d2
*	clipy		d3
*	clipw		d4
*	cliph		d5
*	tree address	a0


	lea	_a_6110(pc),a5
	movem.w	d0-d5,2(a5)

	move.l	a0,18(a5)
	bra	_do_aes


_a_6110:
	dc.w	6,0,0,0,0,0,0
	dc.w	1
	dc.w	1,0,0
	dc.w	0


_watch_obj_rect:
*	reserved		d0
*	object to watch		d1
*	state when on object	d2
*	state when off object	d3
*	tree addr		a0

_find_obj_mouse:
*	firstob to be searched	d0
*	depth			d1
*	x co-ord to search	d2
*	y co-ord to search	d3
*	tree addr		a0

	lea	_a_4110(pc),a5
	movem.w	d0-d3,2(a5)
	move.l	a0,14(a5)
	bra	_do_aes

_a_4110:
	dc.w	4,0,0,0,0
	dc.w	1
	dc.w	1,0,0
	dc.w	0



_find_obj_screen:
*	object to find location of	d0
*	tree addr			a0

	lea	_a_1310(pc),a5
	move.w	d0,2(a5)
	move.l	a0,8(a5)
	bra	_do_aes



_a_1310:
	dc.w	1,0
	dc.w	3
	dc.w	1,0,0
	dc.w	0



_edit_text:
*	object to edit			d0
*	char entered by user (?)	d1
*	pos of next char to enter	d2
*	type of operation		d3
* and presumably...
*	tree addr			a0

	lea	_a_4210(pc),a5
	movem.w	d0-d3,2(a5)
	move.l	a0,14(a5)
	bra	_do_aes

_a_4210:
	dc.w	4,0,0,0,0
	dc.w	2
	dc.w	1,0,0
	dc.w	0


_change_flag:
*	object no	d0
*	reserved = 0	d1
*	clipx		d2
*	clipy		d3
*	clipw		d4
*	cliph		d5
*	state		d6
*	redraw		d7
*	tree addr	a0

	lea	_a_8110(pc),a5
	movem.w	d0-d7,2(a5)
	move.l	a0,22(a5)
	bra	_do_aes


_a_8110:
	dc.w	8,0,0,0,0,0,0,0,0
	dc.w	1
	dc.w	1,0,0
	dc.w	0


_beg_end_dialog:
*	type		d0
*	smallx		d1
*	smally		d2
*	smallw		d3
*	smallh		d4
*	largex		d5
*	largey		d6
*	largew		d7
*	largeh		stack

	lea	_a_9100(pc),a5

	movem.w	d0-d7,2(a5)
	move.w	(a7)+,18(a5)
	bra	_do_aes


_a_9100:
	dc.w	9,0,0,0,0,0,0,0,0,0
	dc.w	1
	dc.w	0
	dc.w	0


_lock_release:
*	lock / release flag	d0

_deallocate_window:
*	window handle	d0

_erase_window:
* window handle	d0

_error_box:
*	error number	d0

	lea	_a_1100(pc),a5
	move.w	d0,2(a5)
	bra	_do_aes


_a_1100:
	dc.w	1,1
	dc.w	1
	dc.w	0
	dc.w	0



_centre_dialog:
*	tree addr	a0

	lea	_a_0510(pc),a5
	move.l	a0,6(a5)
	bra	_do_aes


_a_0510:
	dc.w	0
	dc.w	5
	dc.w	1,0,0
	dc.w	0


_form_do_events:
*	no of obj being edited		d0
*	flag for change in edited obj	d1
*	keycode received		d2
*	tree addr			a0

	lea	_a_3310(pc),a5
	movem.w	d0-d2,2(a5)
	move.l	a0,12(a5)
	bra	_do_aes


_a_3310:
	dc.w	3,0,0,0
	dc.w	3
	dc.w	1,0,0
	dc.w	0


_form_do_mouse:
*	object clicked on	d0
*	clicks made		d1
*	tree addr		a0

	lea	_a_2210(pc),a5
	movem.w	d0-d1,2(a5)
	move.l	a0,12(a5)
	bra	_do_aes


_a_2210:
	dc.w	2,0,0
	dc.w	2
	dc.w	1,0,0
	dc.w	0



_draw_rubber:
*	x	d0
*	y	d1
*	min w	d2
*	min h	d3

	lea	_a_4300(pc),a5
	movem.w	d0-d4,2(a5)
	bra	_do_aes


_a_4300:
	dc.w	4,0,0,0,0
	dc.w	3
	dc.w	0
	dc.w	0


_drag_box:
*	width		d0
*	height		d1
*	beginx		d2
*	beginy		d3
*	boundx		d4
*	boundx		d5
*	boundx		d6
*	boundx		d7

	lea	_a_8300(pc),a5
	movem.w	d0-d7,2(a5)
	bra	_do_aes

_a_8300:
	dc.w	8
		ds.w	8
	dc.w	3
	dc.w	0
	dc.w	0



_change_window:
*	window handle	d0
*	change type	d1
*	x		d2
*	y		d3
*	w		d4
*	h		d5

_draw_moving:
*	width	d0
*	height	d1
*	beginx	d2
*	beginy	d3
*	endx	d4
*	endy	d5

	lea	_a_6100(pc),a5
	movem.w	d0-d5,2(a5)
	bra	_do_aes

_a_6100:
	dc.w	6
		ds.w	6
	dc.w	1
	dc.w	0
	dc.w	0


_draw_contracting:
_draw_expanding:
*	smallx	d0
*	smally	d1
*	smallw	d2
*	smallh	d3
*	largex	d4
*	largex	d5
*	largex	d6
*	largex	d7

	lea	_a_8100(pc),a5
	movem.w	d0-d7,2(a5)
	bra	_do_aes


_a_8100:
	dc.w	8
		ds.w	8
	dc.w	1
	dc.w	0
	dc.w	0


_drag_box_obj:
*	parent array index	d0
*	child array index	d1
*	horiz / vertical flag	d2
*	tree addr		a0

	lea	_a_3110(pc),a5
	movem.w	d0-d2,2(a5)
	move.l	a0,12(a5)
	bra	_do_aes

_a_3110:
	dc.w	3,0,0,0
	dc.w	1
	dc.w	1,0,0
	dc.w	0


_get_mouse:
*	none

_get_phys:
*	none

	lea	_a_0500(pc),a5
	bra	_do_aes

_a_0500:
	dc.w	0
	dc.w	5
	dc.w	0
	dc.w	0

_file:
*	pathname addr	a0
*	filename addr	a1

	lea	_a_0220(pc),a5
	movem.l	a0-a1,6(a5)
	bra	_do_aes

_a_0220:	
	dc.w	0
	dc.w	2
	dc.w	2,0,0,0,0
	dc.w	0


_display_window:
*	window handle	d0
*	x		d1
*	y		d2
*	w		d3
*	h		d4

_allocate_window:
*	controls	d0
*	fullx		d1
*	fully		d2
*	fullw		d3
*	fullh		d4

	lea	_a_5100(pc),a5
	movem.w	d0-d4,2(a5)
	bra	_do_aes

_a_5100:
	dc.w	5
		ds.w	5
	dc.w	1
	dc.w	0
	dc.w	0


_get_window_info:
*	window handle	d0
*	info type	d1

	lea	_a_2500(pc),a5
	movem.w	d0-d1,2(a5)
	bra	_do_aes

_a_2500:
	dc.w	2,0,0
	dc.w	5
	dc.w	0
	dc.w	0


_calc_window:
*	border / work flag	d0
*	window controls flag	d1
*	knownx			d2
*	knowny			d3
*	knownw			d4
*	knownh			d5

	lea	_a_6500(pc),a5
	movem.w	d0-d5,2(a5)
	bra	_do_aes


_a_6500:
	dc.w	6
		ds.w	6
	dc.w	5
	dc.w	0
	dc.w	0


_get_resource_addr:
*	type of structure	d0
*	array index		d1

	lea	_a_2101(pc),a5
	movem.w	d0-d1,2(a5)
	bra	_do_aes

_a_2101:
	dc.w	2,0,0
	dc.w	1
	dc.w	0
	dc.w	1


_search_environment:
*	addr for returned addr		a0
*	addr of text to search for	a1

_find_invoking:
*	addr for program name buffer	a0
*	addr for command line buffer	a1

	lea	_a_0120(pc),a5
	movem.l	a0-a1,6(a5)
	bra	_do_aes

_a_0120:
	dc.w	0
	dc.w	1
	dc.w	2,0,0,0,0
	dc.w	0

_run_another:
*	exit GEM / run another	d0	}
*	graphics / not		d1	} not applicable to ST
*	GEM / not GEM		d2
*	addr of prog name + path	a0
*	addr of command line		a1


	lea	_a_3120(pc),a5
	movem.w	d0-d2,2(a5)
	movem.l	a0-a1,12(a5)
	bra	_do_aes
	

_a_3120:
	dc.w	3,0,0,0
	dc.w	1
	dc.w	2,0,0,0,0
	dc.w	0




_routines:
	dc.w	_innit_appl-aes
	dc.w	_read_mes-aes
	dc.w	_write_mes-aes
	dc.w	_find_id-aes
	dc.w	_play_macro-aes
	dc.w	_record_macro-aes
	dc.w	_clean_up-aes
	dc.w	_wait_keyboard-aes
	dc.w	_wait_button-aes
	dc.w	_wait_rect-aes
	dc.w	_wait_message-aes
	dc.w	_wait_timer-aes
	dc.w	_wait_multi-aes
	dc.w	_click_speed-aes
	dc.w	_menu_bar-aes
	dc.w	_checkmark-aes
	dc.w	_menu_item-aes
	dc.w	_toggle_item-aes
	dc.w	_change_item-aes
	dc.w	_add_item-aes
	dc.w	_add_object-aes
	dc.w	_delete_object-aes
	dc.w	_draw_tree-aes
	dc.w	_find_obj_mouse-aes
	dc.w	_find_obj_screen-aes
	dc.w	_reorder-aes
	dc.w	_edit_text-aes
	dc.w	_change_flag-aes
	dc.w	_handle_dialog-aes
	dc.w	_beg_end_dialog-aes
	dc.w	_alert_box-aes
	dc.w	_error_box-aes
	dc.w	_centre_dialog-aes
	dc.w	_form_do_events-aes
	dc.w	_form_do_mouse-aes
	dc.w	_draw_rubber-aes
	dc.w	_drag_box-aes
	dc.w	_draw_moving-aes
	dc.w	_draw_expanding-aes
	dc.w	_draw_contracting-aes
	dc.w	_watch_obj_rect-aes
	dc.w	_drag_box_obj-aes
	dc.w	_get_phys-aes
	dc.w	_change_mouse-aes
	dc.w	_get_mouse-aes
	dc.w	_read_scrap-aes
	dc.w	_write_scrap-aes
	dc.w	_file-aes
	dc.w	_allocate_window-aes
	dc.w	_display_window-aes
	dc.w	_erase_window-aes
	dc.w	_deallocate_window-aes
	dc.w	_get_window_info-aes
	dc.w	_change_window-aes
	dc.w	_find_window-aes
	dc.w	_lock_release-aes
	dc.w	_calc_window-aes
	dc.w	_load_resource-aes
	dc.w	_unload_resource-aes
	dc.w	_get_resource_addr-aes
	dc.w	_store_resource_addr-aes
	dc.w	_fix_objects-aes
	dc.w	_find_invoking-aes
	dc.w	_run_another-aes
	dc.w	_search_file-aes
	dc.w	_search_environment-aes



_do_aes:
* do the actual calling of the AES

	move.w	(a5)+,d0	; get aintin
	move.w	d0,_cntrl1(a6)
	beq.s	_none_in

* put some stuff into the aintin buffer
	lea	_aintin(a6),a4

_do_aintin:
	move.w	(a5)+,(a4)+
	subq.w	#1,d0
	bne.s	_do_aintin

_none_in:
	move.w	(a5)+,_cntrl2(a6)	; put in aintout

	move.w	(a5)+,d0		; get addrin
	move.w	d0,_cntrl3(a6)
	beq.s	no_addrs

* put in some addrs!
	lea	_addrin(a6),a4
_do_addrin:
	move.l	(a5)+,(a4)+
	subq.w	#1,d0
	bne.s	_do_addrin

no_addrs:
	move.w	(a5)+,_cntrl4(a6)	; put in addrout


* now make the actual AES call...
	move.l	#apb,d1
	move.w	#$c8,d0
	trap	#2

	movem.w	_aintout(a6),d0-d7	; return ALL aintout codes
	movem.l	_addrout(a6),a0-a1	; and all addresses

	movem.l	_addr_store+4(a6),a2-5	; restore addr regs

	move.l	_addr_store(a6),a6

	move.l	aes_ret_addr,-(a7)
	rts



_command_list:
	dc.b	initialise_application
	dc.b	read_message_pipe	
	dc.b	write_to_message_pipe	
	dc.b	find_application_id	
	dc.b	playback_mouse_and_key_macro	
	dc.b	record_mouse_and_key_macro	
	dc.b	clean_up_application
	dc.b	wait_for_keyboard_event	
	dc.b	wait_for_mouse_button_event	
	dc.b	wait_for_mouse_rectangle_event	
	dc.b	wait_for_message_event
	dc.b	wait_for_timer_event	
	dc.b	wait_for_multiple_event	
	dc.b	set_double_click_speed	
	dc.b	display_or_erase_menu_bar
	dc.b	display_or_erase_checkmark
	dc.b	enable_or_disable_menu_item
	dc.b	toggle_menu_title_highlight
	dc.b	change_menu_item_text
	dc.b	add_item_to_desk_menu
	dc.b	add_an_object_to_a_tree
	dc.b	delete_an_object_from_a_tree
	dc.b	draw_an_object_tree
	dc.b	find_objects_under_mouse_pointer
	dc.b	find_objects_screen_position
	dc.b	reorder_child_objects
	dc.b	let_user_edit_text_objects
	dc.b	change_objects_state_flag
	dc.b	handle_dialog
	dc.b	begin_or_end_dialog
	dc.b	display_an_alert_box
	dc.b	display_an_error_box
	dc.b	centre_the_dialog_box
	dc.b	handle_form_do_events
	dc.b	handle_form_do_mouse_events
	dc.b	draw_a_rubber_box
	dc.b	let_the_user_drag_a_box
	dc.b	draw_a_moving_box
	dc.b	draw_an_expanding_box
	dc.b	draw_a_contracting_box
	dc.b	watch_an_object_rectangle
	dc.b	let_the_user_drag_a_box_object
	dc.b	get_the_physical_screen_handle
	dc.b	change_the_mouse_pointer
	dc.b	get_mouse_and_shift_key_status
	dc.b	read_scrap_directory
	dc.b	write_scrap_directory
	dc.b	display_file_selector
	dc.b	allocate_a_window
	dc.b	display_a_window
	dc.b	erase_a_window
	dc.b	deallocate_a_window
	dc.b	get_window_information
	dc.b	change_window_settings
	dc.b	find_window_under_mouse_pointer
	dc.b	lock_or_release_screen_for_update
	dc.b	calculate_window_area
	dc.b	load_a_resource
	dc.b	unload_a_resource
	dc.b	get_address_of_resource_data
	dc.b	store_address_of_resource_data
	dc.b	fix_object_location_and_size
	dc.b	find_invoking_program
	dc.b	run_another_application
	dc.b	search_for_filename
	dc.b	search_for_environment_string
	dc.b	0
	even





apb:
	dc.l	aes_vars+_cntrl0
	dc.l	aes_vars+_version
	dc.l	aes_vars+_aintin
	dc.l	aes_vars+_aintout
	dc.l	aes_vars+_addrin
	dc.l	aes_vars+_addrout





	ifd	link_library
	section	bss
	endc

aes_vars:
	ds.b	112
*** DO NOT INSERT ANYTHING HERE!
aes_temp:
	ds.w	3
addr_store:
	ds.l	6

aes_ret_addr:
	ds.l	1


