* definitions for AES_SHEL.S

aes_definitions	equ	1

alert	macro

	IIF	NARG<2	fail	NEED 2 PARAMETERS...

	moveq	\1,d0
	lea	\2,a0
	move.w	#display_an_alert_box,-(a7)
	bsr	aes
	endm

selector	macro
* pathname = a0
* filename = a1

	IIF	NARG<2	fail	NEED 2 PARAMETERS...

	lea	\1,a0
	lea	\2,a1
	move.w	#display_file_selector,-(a7)
	bsr	aes
	endm


display_menu	macro

	IIF	NARG<1	FAIL	NEED MENU TREE ADDRESS
	
	moveq	#1,d0
	move.l	\1,a0
	move.w	#display_or_erase_menu_bar,-(a7)
	bsr	aes
	endm


erase_menu	macro

	IIF	NARG<1	FAIL	NEED MENU TREE ADDRESS
	
	moveq	#0,d0
	move.l	\1,a0
	move.w	#display_or_erase_menu_bar,-(a7)
	bsr	aes
	endm


none	macro
	dc.b	"[0]"
	endm

exclam	macro
	dc.b	"[1]"
	endm

quest	macro
	dc.b	"[2]"
	endm

stopp	macro
	dc.b	"[3]"
	endm


initialise_application	equ	10
read_message_pipe	equ	11
write_to_message_pipe	equ	12
find_application_id	equ	13
playback_mouse_and_key_macro	equ	14
record_mouse_and_key_macro	equ	15
clean_up_application	equ	19
wait_for_keyboard_event	equ	20
wait_for_mouse_button_event	equ	21
wait_for_mouse_rectangle_event	equ	22
wait_for_message_event	equ	23
wait_for_timer_event	equ	24
wait_for_multiple_event	equ	25
set_double_click_speed	equ	26
display_or_erase_menu_bar	equ	30
display_or_erase_checkmark	equ	31
enable_or_disable_menu_item	equ	32
toggle_menu_title_highlight	equ	33
change_menu_item_text	equ	34
add_item_to_desk_menu	equ	35
add_an_object_to_a_tree	equ	40
delete_an_object_from_a_tree	equ	41
draw_an_object_tree	equ	42
find_objects_under_mouse_pointer	equ	43
find_objects_screen_position	equ	44
reorder_child_objects	equ	45
let_user_edit_text_objects	equ	46
change_objects_state_flag	equ	47
handle_dialog	equ	50
begin_or_end_dialog	equ	51
display_an_alert_box	equ	52
display_an_error_box	equ	53
centre_the_dialog_box	equ	54
handle_form_do_events	equ	55
handle_form_do_mouse_events	equ	56
draw_a_rubber_box	equ	70
let_the_user_drag_a_box	equ	71
draw_a_moving_box	equ	72
draw_an_expanding_box	equ	73
draw_a_contracting_box	equ	74
watch_an_object_rectangle	equ	75
let_the_user_drag_a_box_object	equ	76
get_the_physical_screen_handle	equ	77
change_the_mouse_pointer	equ	78
get_mouse_and_shift_key_status	equ	79
read_scrap_directory	equ	80
write_scrap_directory	equ	81
display_file_selector	equ	90
allocate_a_window	equ	100
display_a_window	equ	101
erase_a_window		equ	102
deallocate_a_window	equ	103
get_window_information	equ	104
change_window_settings	equ	105
find_window_under_mouse_pointer	equ	106
lock_or_release_screen_for_update	equ	107
calculate_window_area	equ	108
load_a_resource	equ	110
unload_a_resource	equ	111
get_address_of_resource_data	equ	112
store_address_of_resource_data	equ	113
fix_object_location_and_size	equ	114
find_invoking_program	equ	120
run_another_application	equ	121
search_for_filename	equ	124
search_for_environment_string	equ	125
* variables...
	rsreset

_cntrl0	rs.w	1
_cntrl1	rs.w	1
_cntrl2	rs.w	1
_cntrl3	rs.w	1
_cntrl4	rs.w	1


_version	rs.w	1
_count		rs.w	1
_apid		rs.w	1
_private	rs.l	1
_tree	rs.l	1
_resv1	rs.l	1
_resv2	rs.l	1
_resv3	rs.l	1
_resv4	rs.l	1

_aintout	rs.w	8
_aintin		rs.w	18
_addrin		rs.l	3
_addrout	rs.l	2

_aes_temp	rs.w	3
_addr_store	rs.l	5
