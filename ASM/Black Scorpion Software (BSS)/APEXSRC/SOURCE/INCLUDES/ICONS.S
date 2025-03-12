
DRAWSTATION_ICONS:
	baricon	Draw_brush,000,001*16
	baricon	Draw_line,001,001*16
	baricon	Draw_curve,000,002*16
	baricon	Draw_polygon,001,002*16
	baricon	Draw_circle,000,003*16
	baricon	Draw_box,001,003*16
	baricon	Draw_fill,000,004*16
	baricon	Draw_airbrush,001,004*16
	baricon	Draw_grid,000,005*16
	baricon	Draw_exchange,001,005*16
	icon		WORKSTATION_ICONS

CELLSTATION_ICONS:
	baricon	Cell_cut,000,001*16
	baricon	Cell_autocut,001,001*16
	baricon	Cell_paste,000,002*16
	baricon	Cell_under,001,002*16
	baricon	Cell_move,000,003*16
	baricon	Cell_invert,001,003*16
	baricon	Cell_rotate,000,004*16
	baricon	Cell_distort,001,004*16
	baricon	Cell_rescale,000,005*16
	baricon	Cell_remap,001,005*16
	icon		WORKSTATION_ICONS

COLOURSTATION_ICONS:
	baricon	Colour_cut,000,001*16
	baricon	Colour_paste,001,001*16
	baricon	Colour_exchange,000,002*16
	baricon	Colour_flip,001,002*16
	baricon	Colour_spread,000,003*16
	baricon	Colour_sort,001,003*16
	baricon	Colour_grey,000,004*16
	icon		WORKSTATION_ICONS

VIDEOSTATION_ICONS:
	baricon	Video_size,000,001*16
	baricon	Video_pip,001,001*16
	baricon	Video_photo,000,002*16
	baricon	Video_film,001,002*16
	icon		WORKSTATION_ICONS

PROSTATION_ICONS:
	baricon	Pro_brush,000,001*16
	baricon	Pro_fill,001,001*16
	baricon	Pro_airbrush,000,002*16
	baricon	Pro_mask,000,004*16
	baricon	Pro_options,001,004*16
	baricon	Pro_area,000,005*16
	baricon	Pro_go,001,005*16
	icon		WORKSTATION_ICONS

APROCSTATION_ICONS:
	baricon	Aproc_dolby,000,001*16
	baricon	Aproc_defocus,000,002*16
	baricon	Aproc_mblur,000,003*16
	baricon	Aproc_dejag,001,001*16
	baricon	Aproc_area,000,005*16
	baricon	Aproc_go,001,005*16
	icon		WORKSTATION_ICONS

MORPHSTATION_ICONS:
	baricon	Morph_line,000,001*16
	baricon	Morph_drag,001,001*16
	baricon	Morph_del_l,000,002*16
	baricon	Morph_del_a,001,002*16
	baricon	Morph_options,001,004*16
	baricon	Morph_area,000,005*16
	baricon	Morph_go,001,005*16
	icon		WORKSTATION_ICONS

TEXTSTATION_ICONS:
	baricon	Text_options,000,001*16
	baricon	Text_type,001,001*16
	baricon	Text_clear,000,002*16
;	icon		WORKSTATION_ICONS

last_tool	=	icon_num

WORKSTATION_ICONS:
	baricon	Apex_info,001,006*16
	baricon	Apex_brush,001,007*16
	baricon	Apex_disk,001,008*16
	baricon	Apex_video,001,009*16
	baricon	Apex_quit,001,010*16
	baricon	Tween_menu,000,010*16
	icon		Apex_help,-1,-1,0,0
	icon		Apex_sys,0,176,32,8,help

GENERAL_ICONS:
	baricon	Swap_draw,000,000
	baricon	Swap_cell,001,000
	baricon	Swap_colour,002,000
	baricon	Swap_video,003,000
	baricon	Swap_pro,004,000
	baricon	Swap_aproc,005,000
	baricon	Swap_morph,006,000
	baricon	Swap_text,007,000
	icon		Swap_none,000,000,320,016,help

MACRO_ICONS:
	icon		Extra_Wul,-1,-1,000,000
	icon		Extra_Wu,-1,-1,000,000
	icon		Extra_Wur,-1,-1,000,000
	icon		Extra_Wl,-1,-1,000,000
	icon		Extra_Wr,-1,-1,000,000
	icon		Extra_Wdl,-1,-1,000,000
	icon		Extra_Wd,-1,-1,000,000
	icon		Extra_Wdr,-1,-1,000,000
	icon		Extra_Wzoom,-1,-1,000,000
	icon		Extra_Wpan,-1,-1,000,000
	icon		Extra_center,-1,-1,000,000
	icon		Extra_fix,-1,-1,000,000
	icon		Extra_dummy,-1,-1,000,000
	icon		Extra_Cpick,-1,-1,000,000
	icon		Extra_playright,-1,-1,000,000
	icon		Extra_playleft,-1,-1,000,000
	icon		Extra_reset,-1,-1,000,000
	icon		Extra_xray,-1,-1,000,000
	icon		Extra_gridswitch,-1,-1,000,000
	icon		Special_start,-1,-1,000,000
	icon		Special_end,-1,-1,000,000
	icon		Frame_start,-1,-1,000,000
	icon		Frame_end,-1,-1,000,000
	icon		Undo_changes,-1,-1,000,000
	icon		Restore_image,-1,-1,000,000

SLIDER_ICONS:
	baricon	Frame_left_ins,000,184
	baricon	Frame_right_ins,018,184
	baricon	Frames_delete,019,184
	icon		Frame_clear,019*16,184,016,016

SLIDING_BARS:
	icon		Time_bar,TBAR_Xmin,TBAR_Ymin,TBAR_Xmax-TBAR_Xmin,TBAR_Ymax-TBAR_Ymin,help

FRAME_CTRL_ICONS:
	baricon	Frame_left,001,184
	baricon	Frame_right,017,184
	icon		Frame_bar,PBAR_Xmin,PBAR_Ymin,PBAR_Xmax-PBAR_Xmin,010,help
	icon		Frame_none,32,184,16*(20-5),16,help

PALETTE_BAR_ICONS:
	icon		Palette_colours,000,201,320,019,help
MAIN_WINDOW_ICON:
	icon		Check_draw_window,000,000,320,200,help
NO_ICONS:
	dc.w		-1

