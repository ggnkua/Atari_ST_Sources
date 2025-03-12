* VDI definitions taken from ZZsoft docs

vdi_definitions	equ	1

vdi_open_workstation	equ	1
vdi_close_workstation	equ	2
vdi_clear_workstation	equ	3
vdi_update_workstation	equ	4
vdi_esc_codes		equ	5

***

vdi_inq_alpha_cells		equ	1
vdi_exit_alpha_mode		equ	2
vdi_enter_alpha_mode	equ	3
vdi_alpha_curs_up		equ	4
vdi_alpha_curs_down		equ	5
vdi_alpha_curs_right	equ	6
vdi_alpha_curs_left		equ	7
vdi_alpha_curs_home		equ	8
vdi_era_to_end_of_scrn	equ	9
vdi_era_to_end_of_line	equ	10
vdi_move_curs		equ	11
vdi_output_alpha_text	equ	12
vdi_reverse_video_on	equ	13
vdi_reverse_video_off	equ	14
vdi_inq_curs_addr		equ	15
vdi_inq_tablet_status	equ	16
vdi_dump_screen		equ	17
vdi_place_graph_curs	equ	18
vdi_remove_graph_curs	equ	19
vdi_do_form_feed		equ	20
vdi_output_window		equ	21
vdi_clear_display_list	equ	22
vdi_output_bit_image	equ	23

***

vdi_polyline		equ	6
vdi_polymarker		equ	7
vdi_graphics_text		equ	8
vdi_filled_area		equ	9
vdi_gdp			equ	11


***

vdi_bar			equ	1
vdi_arc			equ	2
vdi_pie			equ	3
vdi_circle			equ	4
vdi_ellipse			equ	5
vdi_elliptical_arc		equ	6
vdi_elliptical_pie		equ	7
vdi_rounded_rect		equ	8
vdi_filled_rounded_rect	equ	9
vdi_justified_graph_text	equ	10

***

vdi_set_char_h_abs		equ	12
vdi_set_char_base_vec	equ	13
vdi_set_colour_rep		equ	14
vdi_set_polyline_type	equ	15
vdi_set_polyline_width	equ	16
vdi_set_polyline_colour_idx	equ	17
vdi_set_polymarker_type	equ	18
vdi_set_polymarker_height	equ	19
vdi_set_polymarker_colour_idx	equ	20
vdi_set_text_face		equ	21
vdi_set_graph_text_colour_idx	equ	22
vdi_set_fill_interior_style	equ	23
vdi_set_fill_style_idx	equ	24
vdi_set_fill_colour_idx	equ	25
vdi_inq_colour_rep		equ	26
vdi_input_loc_req_mode	equ	27
vdi_input_loc_sam_mode	equ	28

*input_val_req_mode	equ	29
*input_val_sam_mode	equ	29
*input_cho_req_mode	equ	30
*input_cho_sam_mode	equ	30
*input_str_req_mode	equ	31
*input_str_sam_mode	equ	31

vdi_set_writing_mode	equ	32
vdi_set_dev_mode		equ	33

vdi_inq_current_polyline_attr	equ	34
vdi_inq_current_polymarker_attr	equ	35
vdi_inq_current_fill_attr		equ	36
vdi_inq_current_text_attr		equ	37

vdi_set_graph_text_align	equ	38

vdi_open_virtual_workstation	equ	100
vdi_close_virtual_workstation	equ	101

vdi_extend_inq		equ	102

vdi_contour_fill		equ	103
vdi_set_perim_fill_visib	equ	104
vdi_get_pixel		equ	105
vdi_set_graph_sfx		equ	106
vdi_set_char_height		equ	107
vdi_set_polyline_end_styles	equ	108

vdi_copy_raster_opaque	equ	109
vdi_transform_form		equ	110

vdi_set_mouse_form		equ	111

vdi_set_user_fill_pat	equ	112
vdi_set_user_line_style	equ	113
vdi_fill_rect		equ	114

vdi_inq_input_mode		equ	115
vdi_inq_text_extent		equ	116
vdi_inq_char_width		equ	117

vdi_exg_int_vector		equ	118

vdi_load_fonts		equ	119
vdi_unload_fonts		equ	120

vdi_copy_raster_trans	equ	121

vdi_show_mouse_pointer	equ	122
vdi_hide_mouse_pointer	equ	123
vdi_sample_mouse_buttons	equ	124

vdi_exg_button_change_vect	equ	125
vdi_exg_mouse_move_vect	equ	126

vdi_exg_curs_vect		equ	127

vdi_sample_keyboard_state	equ	128
vdi_set_clip_rect		equ	129

vdi_inq_face_name_idx	equ	130
vdi_inq_face_info		equ	131

