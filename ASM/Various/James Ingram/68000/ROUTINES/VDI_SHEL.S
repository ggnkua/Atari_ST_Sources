* VDI shell routines
*  by James Ingram, June 1993
*
*
* NOTE:
* ALL parameters are passed on the stack, in the order
* VPTSIN then VINTIN!
* then function number (if applicable)
* then any control numbers (if applicable)
* command number follows last
*
* REMEMBER:
*   everything comes off the stack in REVERSE ORDER
*   so stuff for VINTIN & VPTSIN has to go on backwards!
*
*
* NO NEED to tidy stack after call to vdi has been made!
*
*
*


	ifd	link_library
	MODULE	VDI_SHELL
	XDEF	vdi
	endc


* returns:
*	a0 = vintout addr
*	a1 = vptsout addr
*	dx = dependant on the call - results from vintout & vptsout (maybe)


vdi:
* the call handler...


* get return position from the stack
	move.l	(a7)+,vdi_ret_addr

* get command number
	move.w	(a7)+,d0

* match the command with the one I need

	lea	vdi_nos(pc),a0
	lea	vdi_routs(pc),a1

get_vdi_no:
	move.w	(a0)+,d1
	bmi.s	invalid_vdi_no

	cmp.w	d0,d1
	beq.s	got_vdi_no

	addq.l	#4,a1
	bra.s	get_vdi_no

invalid_vdi_no:
	move.l	#"ERR!",d0
	rts

got_vdi_no:
	move.l	(a1),a3
	move.l	#vcontrol,a2	; prepare a2 for routines

	move.w	d0,(a2)+	; and insert 1st control word

	move.l	#vintin,a0
	move.l	#vptsin,a1
	jmp	(a3)		; jump to routine


vdi_term:
	move.l	vdi_ret_addr,a2
	jmp	(a2)		; return from my routines...



stk_to_vintin:
* put d0 params into vintin from stack...

	subq.w	#1,d0
	move.l	(a7)+,a3

vdi_int:
	move.w	(a7)+,(a0)+
	dbra	d0,vdi_int

	jmp	(a3)


stk_to_vptsin:
* put d0 params into vptsin from stack
	subq.w	#1,d0
	move.l	(a7)+,a3

vdi_pts:
	move.w	(a7)+,(a1)+
	dbra	d0,vdi_pts
	jmp	(a3)


do_vdi_open_workstation:
	move.w	(a7)+,12-2(a2)	; put in handle

	moveq	#11,d0
	bsr	stk_to_vintin

	clr.w	(a2)+
	move.w	#11,(a2)

	bsr	do_vdi
	bra	vdi_term



do_vdi_close_workstation:
	clr.l	(a2)

	bsr	do_vdi
	bra	vdi_term


do_vdi_clear_workstation:
	clr.l	(a2)+

	bsr	do_vdi
	bra	vdi_term


do_vdi_update_workstation:
	clr.l	(a2)+

	bsr	do_vdi
	bra	vdi_term


do_vdi_esc_codes:
* must find which ESC code we are dealing with!
	move.w	(a7)+,d0

	cmp.w	#vdi_output_bit_image,d0
	beq.s	do_vdi_o_b_i

* all other routines are standard...
	clr.l	(a2)+
	move.w	d0,(a2)

	bsr	do_vdi
	bra	vdi_term

do_vdi_o_b_i:
	move.w	(a7)+,(a2)+
	move.w	(a7)+,(a2)+
	move.w	d0,(a2)

	bsr	do_vdi
	bra	vdi_term

do_vdi_polyline:
	move.w	(a7)+,d0
	move.w	d0,(a2)
	clr.w	(a2)

	subq.w	#1,d0

	bsr	do_vdi
	bra	vdi_term


do_vdi_graphics_text:
	move.w	#1,(a2)+
	move.w	(a7)+,d0
	move.w	d0,(a2)

	move.w	d0,d1

	bsr	stk_to_vptsin	; put positions in

	move.w	d1,d0
	bsr	stk_to_vintin	; put chars in

	bsr	do_vdi
	bra	vdi_term


do_vdi_filled_area:
	move.w	(a7)+,d0
	move.w	d0,(a2)+
	clr.w	(a2)

	bsr	stk_to_vptsin

	bsr	do_vdi
	bra	vdi_term


do_vdi_gdp:
* get function number
	move.w	(a7)+,d0

	move.w	d0,4(a2)

	lea	vdi_gdp_list(pc),a0
	lea	vdi_gdp_routs(pc),a1

vdi_get_gdp:
	move.w	(a0)+,d1
	bmi	vdi_gdp_error

	cmp.w	d0,d1
	beq	vdi_got_gdp

	addq.l	#4,a1
	bra.s	vdi_get_gdp

vdi_gdp_error:
	move.l	#"ERR!",d0
	rts


vdi_got_gdp:
	move.l	(a1),a1
	jmp	(a1)


do_vdi_bar:
do_vdi_ellipse:
do_vdi_rounded_rect:
do_vdi_filled_rounded_rect:
	move.w	#2,(a2)+
	clr.w	(a2)

	moveq	#4,d0
	bsr	stk_to_vptsin

	bsr	do_vdi
	bra	vdi_term


do_vdi_arc:
do_vdi_pie:
	move.l	#$00040002,(a2)

	move.w	(a7)+,(a0)+
	move.w	(a7)+,(a0)

	move.w	(a7)+,(a1)+
	move.w	(a7)+,(a1)+

	clr.l	(a1)+
	clr.l	(a1)+

	move.w	(a7)+,(a1)+
	clr.w	(a1)

	bsr	do_vdi
	bra	vdi_term

do_vdi_circle:
	move.w	#3,(a2)+
	clr.w	(a2)

	move.w	(a7)+,(a1)+
	move.w	(a7)+,(a1)+
	clr.l	(a1)+
	move.w	(a7)+,(a1)+
	clr.w	(a1)

	bsr	do_vdi
	bra	vdi_term


do_vdi_elliptical_arc:
do_vdi_elliptical_pie:
	move.l	#$00020002,(a2)

	move.w	(a7)+,(a0)+
	move.w	(a7)+,(a0)

	moveq	#4,d0
	bsr	stk_to_vptsin

	bsr	do_vdi
	bra	vdi_term


do_vdi_justified_graph_text:

	move.w	#2,(a2)+
	move.w	(a7)+,d0
	move.w	d0,(a2)		; put in no of chars

	move.w	(a7)+,(a1)+
	move.w	(a7)+,(a1)+
	move.w	(a7)+,(a1)+
	clr.w	(a1)

	move.w	(a7)+,(a0)+
	move.w	(a7)+,(a0)+

	bsr	stk_to_vintin

	bsr	do_vdi
	bra	vdi_term




vdi_gdp_list:
	dc.w	vdi_bar
	dc.w	vdi_arc
	dc.w	vdi_pie
	dc.w	vdi_circle
	dc.w	vdi_ellipse
	dc.w	vdi_elliptical_arc
	dc.w	vdi_elliptical_pie
	dc.w	vdi_rounded_rect
	dc.w	vdi_filled_rounded_rect
	dc.w	vdi_justified_graph_text
	dc.w	-1

vdi_gdp_routs:
	dc.l	do_vdi_bar
	dc.l	do_vdi_arc
	dc.l	do_vdi_pie
	dc.l	do_vdi_circle
	dc.l	do_vdi_ellipse
	dc.l	do_vdi_elliptical_arc
	dc.l	do_vdi_elliptical_pie
	dc.l	do_vdi_rounded_rect
	dc.l	do_vdi_filled_rounded_rect
	dc.l	do_vdi_justified_graph_text


**********************************************************



do_vdi_set_char_base_vec:

******* DOCUMENTATION INCOMPLETE!


do_vdi_set_colour_rep:
	clr.w	(a2)+
	move.w	#4,(a2)

	moveq	#4,d0
	bsr	stk_to_vintin

	bsr	do_vdi
	bra	vdi_term



do_vdi_set_polyline_type:
do_vdi_set_polyline_colour_idx:
do_vdi_set_polymarker_type:
do_vdi_set_polymarker_colour_idx:
do_vdi_set_text_face:
do_vdi_set_graph_text_colour_idx:
do_vdi_set_fill_interior_style:
do_vdi_set_fill_style_idx:
do_vdi_set_fill_colour_idx:
do_vdi_set_writing_mode:
do_vdi_extend_inq:
do_vdi_set_perim_fill_visib:
do_vdi_set_graph_sfx:
do_vdi_set_char_height:
do_vdi_set_user_line_style:
do_vdi_inq_input_mode:
do_vdi_inq_char_width:
do_vdi_show_mouse_pointer:
do_vdi_inq_face_name_idx:
	clr.w	(a2)+
	move.w	#1,(a2)+

	move.w	(a7)+,(a0)

	bsr	do_vdi
	bra	vdi_term


do_vdi_set_char_h_abs:
do_vdi_set_polyline_width:
	move.w	#1,(a2)+
	clr.w	(a2)

	move.w	(a7)+,(a1)+
	clr.w	(a1)

	bsr	do_vdi
	bra	vdi_term


do_vdi_set_polymarker_height:
	move.w	#1,(a2)+
	clr.w	(a2)

	clr.w	(a1)+
	move.w	(a7)+,(a1)

	bsr	do_vdi
	bra	vdi_term


do_vdi_inq_colour_rep:
	clr.w	(a2)+
	move.w	#2,(a2)

	move.w	(a7)+,(a0)+
	move.w	(a7)+,(a0)

	bsr	do_vdi
	bra	vdi_term


do_vdi_input_loc_req_mode:
do_vdi_input_loc_sam_mode:
do_vdi_get_pixel:
	move.w	#1,(a2)+
	clr.w	(a2)

	move.w	(a7)+,(a1)+
	move.w	(a7)+,(a1)

	bsr	do_vdi
	bra	vdi_term



do_vdi_set_dev_mode:
do_vdi_set_graph_text_align:
do_vdi_set_polyline_end_styles:
	clr.w	(a2)+
	move.w	#2,(a2)

	move.w	(a7)+,(a0)+
	move.w	(a7)+,(a0)+


	bsr	do_vdi
	bra	vdi_term


do_vdi_inq_current_polyline_attr:
	clr.l	(a2)
	moveq	#5,d0
	bsr	stk_to_vintin

	moveq	#2,d0
	bsr	stk_to_vptsin

	bsr	do_vdi
	bra	vdi_term


do_vdi_inq_current_polymarker_attr:
	clr.l	(a2)
	moveq	#3,d0
	bsr	stk_to_vintin

	move.w	(a7)+,(a1)

	bsr	do_vdi
	bra	vdi_term


do_vdi_inq_current_fill_attr:
do_vdi_inq_current_text_attr:
do_vdi_close_virtual_workstation:
	clr.l	(a2)

	bsr	do_vdi
	bra	vdi_term


do_vdi_open_virtual_workstation:
	clr.w	(a2)
	move.w	(a7)+,10(a2)		; put in phys handle

	moveq	#11,d0
	bsr	stk_to_vintin
	bsr	do_vdi

	move.w	vcontrol6,d0		; return handle
	bra	vdi_term


do_vdi_contour_fill:
	move.l	#$00010001,(a2)

	move.w	(a7)+,(a0)
	move.w	(a7)+,(a1)+
	move.w	(a7)+,(a1)

	bsr	do_vdi
	bra	vdi_term



do_vdi_copy_raster_opaque:
	move.l	#$00040001,(a2)
	move.l	(a7)+,14-2(a2)
	move.l	(a7)+,18-2(a2)

	move.w	(a7)+,(a0)

	moveq	#8,d0
	bsr	stk_to_vptsin

	bsr	do_vdi
	bra	vdi_term



do_vdi_transform_form:
	clr.l	(a2)
	move.l	(a7)+,14-2(a2)
	move.l	(a7)+,18-2(a2)


	bsr	do_vdi
	bra	vdi_term


do_vdi_set_mouse_form:
	clr.w	(a2)+
	move.w	#37,(a2)

	moveq	#32,d0
	bsr	stk_to_vintin

	bsr	do_vdi
	bra	vdi_term


do_vdi_set_user_fill_pat:
	clr.w	(a2)+
	move.w	(a7)+,d0	; number of bit planes

	lsl.w	#4,d0		; times 16
	move.w	d0,(a2)

	bsr	stk_to_vintin

	bsr	do_vdi
	bra	vdi_term



do_vdi_fill_rect:
	move.l	#$00020001,(a2)
	moveq	#4,d0
	bsr	stk_to_vptsin

	bsr	do_vdi
	bra	vdi_term



do_vdi_inq_text_extent:
	clr.w	(a2)+
	move.w	(a7)+,d0
	move.w	d0,(a2)+

	bsr	stk_to_vintin

	bsr	do_vdi
	bra	vdi_term



do_vdi_exg_int_vector:
	clr.l	(a2)
	move.l	(a7)+,4(a2)
	move.l	(a7)+,14-2(a2)

	bsr	do_vdi
	bra	vdi_term

	
do_vdi_load_fonts:
do_vdi_unload_fonts:
	clr.w	(a2)+
	move.w	#1,(a2)
	clr.w	(a0)

	bsr	do_vdi
	bra	vdi_term



do_vdi_copy_raster_trans:
	move.l	#$00040003,(a2)
	move.l	(a7)+,14-2(a2)
	move.l	(a7)+,18-2(a2)

	moveq	#3,d0
	bsr	stk_to_vintin

	moveq	#8,d0
	bsr	stk_to_vptsin

	bsr	do_vdi
	bra	vdi_term



do_vdi_hide_mouse_pointer:
do_vdi_sample_mouse_buttons:
do_vdi_sample_keyboard_state:
do_vdi_inq_face_info:
	clr.l	(a2)

	bsr	do_vdi
	bra	vdi_term


do_vdi_exg_button_change_vect:
do_vdi_exg_mouse_move_vect:
do_vdi_exg_curs_vect:
	clr.l	(a2)
	move.w	(a7)+,4(a2)
	move.l	(a7)+,14-2(a2)

	bsr	do_vdi
	bra	vdi_term




do_vdi_set_clip_rect:
	move.l	#$00020001,(a2)
	
	move.w	(a7)+,(a0)
	moveq	#4,d0
	bsr	stk_to_vptsin

	bsr	do_vdi
	bra	vdi_term



do_vdi:
	move.l	#vpb,d1
	move.w	#$73,d0
	trap	#2

	move.l	#vintout,a0
	move.l	#vptsout,a1
	rts


vdi_nos:
	dc.w	vdi_open_workstation
	dc.w	vdi_close_workstation
	dc.w	vdi_clear_workstation
	dc.w	vdi_update_workstation
	dc.w	vdi_esc_codes

	dc.w	vdi_polyline
	dc.w	vdi_graphics_text
	dc.w	vdi_filled_area
	dc.w	vdi_gdp

	dc.w	vdi_set_char_h_abs
	dc.w	vdi_set_char_base_vec
	dc.w	vdi_set_colour_rep
	dc.w	vdi_set_polyline_type
	dc.w	vdi_set_polyline_width
	dc.w	vdi_set_polyline_colour_idx
	dc.w	vdi_set_polymarker_type
	dc.w	vdi_set_polymarker_height
	dc.w	vdi_set_polymarker_colour_idx
	dc.w	vdi_set_text_face
	dc.w	vdi_set_graph_text_colour_idx
	dc.w	vdi_set_fill_interior_style
	dc.w	vdi_set_fill_style_idx
	dc.w	vdi_set_fill_colour_idx
	dc.w	vdi_inq_colour_rep
	dc.w	vdi_input_loc_req_mode
	dc.w	vdi_input_loc_sam_mode

	dc.w	vdi_set_writing_mode
	dc.w	vdi_set_dev_mode

	dc.w	vdi_inq_current_polyline_attr
	dc.w	vdi_inq_current_polymarker_attr
	dc.w	vdi_inq_current_fill_attr
	dc.w	vdi_inq_current_text_attr

	dc.w	vdi_set_graph_text_align

	dc.w	vdi_open_virtual_workstation
	dc.w	vdi_close_virtual_workstation

	dc.w	vdi_extend_inq

	dc.w	vdi_contour_fill
	dc.w	vdi_set_perim_fill_visib
	dc.w	vdi_get_pixel
	dc.w	vdi_set_graph_sfx
	dc.w	vdi_set_char_height
	dc.w	vdi_set_polyline_end_styles

	dc.w	vdi_copy_raster_opaque
	dc.w	vdi_transform_form

	dc.w	vdi_set_mouse_form

	dc.w	vdi_set_user_fill_pat
	dc.w	vdi_set_user_line_style
	dc.w	vdi_fill_rect

	dc.w	vdi_inq_input_mode
	dc.w	vdi_inq_text_extent
	dc.w	vdi_inq_char_width

	dc.w	vdi_exg_int_vector

	dc.w	vdi_load_fonts
	dc.w	vdi_unload_fonts

	dc.w	vdi_copy_raster_trans

	dc.w	vdi_show_mouse_pointer
	dc.w	vdi_hide_mouse_pointer
	dc.w	vdi_sample_mouse_buttons

	dc.w	vdi_exg_button_change_vect
	dc.w	vdi_exg_mouse_move_vect

	dc.w	vdi_exg_curs_vect

	dc.w	vdi_sample_keyboard_state
	dc.w	vdi_set_clip_rect

	dc.w	vdi_inq_face_name_idx
	dc.w	vdi_inq_face_info
	dc.w	-1

vdi_routs:
	dc.l	do_vdi_open_workstation
	dc.l	do_vdi_close_workstation
	dc.l	do_vdi_clear_workstation
	dc.l	do_vdi_update_workstation
	dc.l	do_vdi_esc_codes

	dc.l	do_vdi_polyline
	dc.l	do_vdi_graphics_text
	dc.l	do_vdi_filled_area
	dc.l	do_vdi_gdp

	dc.l	do_vdi_set_char_h_abs
	dc.l	do_vdi_set_char_base_vec
	dc.l	do_vdi_set_colour_rep
	dc.l	do_vdi_set_polyline_type
	dc.l	do_vdi_set_polyline_width
	dc.l	do_vdi_set_polyline_colour_idx
	dc.l	do_vdi_set_polymarker_type
	dc.l	do_vdi_set_polymarker_height
	dc.l	do_vdi_set_polymarker_colour_idx
	dc.l	do_vdi_set_text_face
	dc.l	do_vdi_set_graph_text_colour_idx
	dc.l	do_vdi_set_fill_interior_style
	dc.l	do_vdi_set_fill_style_idx
	dc.l	do_vdi_set_fill_colour_idx
	dc.l	do_vdi_inq_colour_rep
	dc.l	do_vdi_input_loc_req_mode
	dc.l	do_vdi_input_loc_sam_mode

	dc.l	do_vdi_set_writing_mode
	dc.l	do_vdi_set_dev_mode

	dc.l	do_vdi_inq_current_polyline_attr
	dc.l	do_vdi_inq_current_polymarker_attr
	dc.l	do_vdi_inq_current_fill_attr
	dc.l	do_vdi_inq_current_text_attr

	dc.l	do_vdi_set_graph_text_align

	dc.l	do_vdi_open_virtual_workstation
	dc.l	do_vdi_close_virtual_workstation

	dc.l	do_vdi_extend_inq

	dc.l	do_vdi_contour_fill
	dc.l	do_vdi_set_perim_fill_visib
	dc.l	do_vdi_get_pixel
	dc.l	do_vdi_set_graph_sfx
	dc.l	do_vdi_set_char_height
	dc.l	do_vdi_set_polyline_end_styles

	dc.l	do_vdi_copy_raster_opaque
	dc.l	do_vdi_transform_form

	dc.l	do_vdi_set_mouse_form

	dc.l	do_vdi_set_user_fill_pat
	dc.l	do_vdi_set_user_line_style
	dc.l	do_vdi_fill_rect

	dc.l	do_vdi_inq_input_mode
	dc.l	do_vdi_inq_text_extent
	dc.l	do_vdi_inq_char_width

	dc.l	do_vdi_exg_int_vector

	dc.l	do_vdi_load_fonts
	dc.l	do_vdi_unload_fonts

	dc.l	do_vdi_copy_raster_trans

	dc.l	do_vdi_show_mouse_pointer
	dc.l	do_vdi_hide_mouse_pointer
	dc.l	do_vdi_sample_mouse_buttons

	dc.l	do_vdi_exg_button_change_vect
	dc.l	do_vdi_exg_mouse_move_vect

	dc.l	do_vdi_exg_curs_vect

	dc.l	do_vdi_sample_keyboard_state
	dc.l	do_vdi_set_clip_rect

	dc.l	do_vdi_inq_face_name_idx
	dc.l	do_vdi_inq_face_info




vpb:
	dc.l	vcontrol,vintin,vptsin,vintout,vptsout

	ifd	link_library
	section	bss
	endc


vcontrol:
vcontrol0	ds.w	1
vcontrol1	ds.w	1
vcontrol2	ds.w	1
vcontrol3	ds.w	1
vcontrol4	ds.w	1
vcontrol5	ds.w	1
vcontrol6	ds.w	1
vcontrol7	ds.w	1
vcontrol8	ds.w	1
vcontrol9	ds.w	1
vcontrol10	ds.w	1
vcontrol11	ds.w	1

vintin	ds.w	128
vptsin	ds.w	128
vintout	ds.w	128
vptsout	ds.w	128

vdi_ret_addr	ds.l	1



