*-----------------------------------------------------------------------*
*	Keyboard shortcuts								*
*-----------------------------------------------------------------------*

Extra_macros:
	dc.w		0				; ESC
	dc.w		0				; 1
	dc.w		0				; 2
	dc.w		0				; 3
	dc.w		0				; 4
	dc.w		0				; 5
	dc.w		0				; 6
	dc.w		0				; 7
	dc.w		0				; 8
	dc.w		0				; 9
	dc.w		0				; 0
	dc.w		0				; -
	dc.w		0				; =
	dc.w		0				; BS
	dc.w		0				; TAB
	dc.w		0				; Q
	dc.w		0				; W
	dc.w		0				; E
	dc.w		0				; R
	dc.w		0				; T
	dc.w		0				; Y
	dc.w		0				; U
	dc.w		0				; I
	dc.w		0				; O
	dc.w		0				; P
	dc.w		0				; [
	dc.w		0				; ]
	dc.w		0				; RET
	dc.w		0				* CNTL
	dc.w		0				; A
	dc.w		0				; S
	dc.w		0				; D
	dc.w		0				; F
	dc.w		0				; G
	dc.w		0				; H
	dc.w		0				; J
	dc.w		0				; K
	dc.w		0				; L
	dc.w		I_Extra_gridswitch	; ;
	dc.w		0				; '
	dc.w		0				; `
	dc.w		0				* LEFT SHIFT
	dc.w		0				; #
	dc.w		I_Extra_Wzoom		; Z		**
	dc.w		I_Extra_xray		; X
	dc.w		0				; C
	dc.w		0				; V
	dc.w		0				; B
	dc.w		0				; N
	dc.w		0				; M
	dc.w		0				; ,
	dc.w		0				; .
	dc.w		0				; /
	dc.w		0				* RIGHT SHIFT
	dc.w		0	
	dc.w		0				* ALT
	dc.w		I_Extra_center		; SPACE
	dc.w		0				* CAPS
	dc.w		0				; F1
	dc.w		0				; F2
	dc.w		0				; F3
	dc.w		0				; F4
	dc.w		0				; F5
	dc.w		0				; F6
	dc.w		0				; F7
	dc.w		0				; F8
	dc.w		I_Special_start		; F9
	dc.w		I_Special_end		; F10
	dc.w		0
	dc.w		0
	dc.w		0				; CLRHOME
	dc.w		0				; UP ARROW
	dc.w		0
	dc.w		I_Extra_Wpan		; kpd -
	dc.w		0				; LEFT ARROW
	dc.w		0
	dc.w		0				; RIGHT ARROW
	dc.w		I_Extra_Wzoom		; kpd +
	dc.w		0
	dc.w		0				; DOWN ARROW
	dc.w		0
	dc.w		0				; INSERT
	dc.w		0				; DELETE
	ds.w		96-84
	dc.w		I_Extra_Wpan		; \		**
	dc.w		0				; UNDO
	dc.w		0				; HELP
	dc.w		0				; kpd (
	dc.w		0				; kpd )
	dc.w		0				; kpd /
	dc.w		I_Extra_fix			; kpd *
	dc.w		I_Extra_Wul			; kpd 7	*
	dc.w		I_Extra_Wu			; kpd 8	*
	dc.w		I_Extra_Wur			; kpd 9	*
	dc.w		I_Extra_Wl			; kpd 4	*
	dc.w		0				; kpd 5
	dc.w		I_Extra_Wr			; kpd 6	*
	dc.w		I_Extra_Wdl			; kpd 1	*
	dc.w		I_Extra_Wd			; kpd 2	*
	dc.w		I_Extra_Wdr			; kpd 3	*
	dc.w		0				; kpd 0
	dc.w		0				; kpd .
	dc.w		0				; kpd ENTER
	ds.w		3

Draw_macros:
	dc.w		I_Cell_cut			* ESC
*------------------------------------------
	dc.w		I_Draw_brush		* 1
	dc.w		I_Draw_line			* 2
	dc.w		I_Draw_curve		* 3
	dc.w		I_Draw_polygon		* 4
	dc.w		I_Draw_circle		* 5
	dc.w		I_Draw_box			* 6
	dc.w		I_Draw_fill			* 7
	dc.w		I_Draw_airbrush		* 8
	dc.w		I_Draw_grid			* 9
	dc.w		I_Draw_exchange		* 0
*------------------------------------------
	dc.w		I_Colour_spread		; -
	dc.w		I_Tween_menu		; =
	dc.w		I_Restore_image		; BS
	dc.w		I_Cell_autocut		; TAB
	dc.w		I_Apex_quit			; Q
	dc.w		I_Draw_polygon		; W
	dc.w		I_Draw_exchange		; E
	dc.w		I_Cell_rotate		; R
	dc.w		I_Colour_exchange		; T
	dc.w		I_Cell_distort		; Y
	dc.w		I_Cell_under		; U
	dc.w		I_Cell_invert		; I
	dc.w		I_Draw_circle		; O
	dc.w		I_Cell_paste		; P
	dc.w		I_Colour_cut		; [
	dc.w		I_Colour_paste		; ]
	dc.w		I_Apex_disk			; RET
	dc.w		0				* CNTL
	dc.w		I_Draw_airbrush		; A
	dc.w		I_Cell_rescale		; S
	dc.w		I_Draw_brush		; D
	dc.w		I_Draw_fill			; F
	dc.w		I_Colour_grey		; G
	dc.w		I_Colour_flip		; H
	dc.w		I_Colour_sort		; J
	dc.w		I_Draw_curve		; K
	dc.w		I_Draw_line			; L
	dc.w		I_Extra_gridswitch	; ;
	dc.w		0				; '
	dc.w		0				; `
	dc.w		0				* LEFT SHIFT
	dc.w		I_Apex_brush		; #
	dc.w		I_Extra_Wzoom		; Z		**
	dc.w		I_Extra_xray		; X
	dc.w		I_Extra_Cpick		; C
	dc.w		I_Apex_video		; V
	dc.w		I_Draw_box			; B
	dc.w		I_Cell_remap		; N
	dc.w		I_Cell_move			; M
	dc.w		I_Frame_start		; ,
	dc.w		I_Frame_end			; .
	dc.w		I_Apex_info			; /
	dc.w		0				* RIGHT SHIFT
	dc.w		0	
	dc.w		0				* ALT
	dc.w		I_Extra_center		; SPACE
	dc.w		0				* CAPS
	dc.w		I_Swap_draw			; F1
	dc.w		I_Swap_cell			; F2
	dc.w		I_Swap_colour		; F3
	dc.w		I_Swap_video		; F4
	dc.w		I_Swap_pro			; F5
	dc.w		I_Swap_aproc		; F6
	dc.w		I_Swap_morph		; F7
	dc.w		I_Swap_text			; F8
	dc.w		I_Special_start		; F9
	dc.w		I_Special_end		; F10
	dc.w		0
	dc.w		0
	dc.w		I_Frame_clear		; CLRHOME
	dc.w		I_Extra_playleft		; UP ARROW
	dc.w		0
	dc.w		I_Extra_Wpan		; kpd -
	dc.w		I_Frame_left		; LEFT ARROW
	dc.w		0
	dc.w		I_Frame_right		; RIGHT ARROW
	dc.w		I_Extra_Wzoom		; kpd +
	dc.w		0
	dc.w		I_Extra_playright		; DOWN ARROW
	dc.w		0
	dc.w		I_Frame_right_ins		; INSERT
	dc.w		I_Frames_delete		; DELETE
	ds.w		96-84
	dc.w		I_Extra_Wpan		; \		**
	dc.w		I_Undo_changes		; UNDO
	dc.w		I_Apex_help			; HELP
	dc.w		0				; kpd (
	dc.w		0				; kpd )
	dc.w		0				; kpd /
	dc.w		I_Extra_fix			; kpd *
	dc.w		I_Extra_Wul			; kpd 7	*
	dc.w		I_Extra_Wu			; kpd 8	*
	dc.w		I_Extra_Wur			; kpd 9	*
	dc.w		I_Extra_Wl			; kpd 4	*
	dc.w		0				; kpd 5
	dc.w		I_Extra_Wr			; kpd 6	*
	dc.w		I_Extra_Wdl			; kpd 1	*
	dc.w		I_Extra_Wd			; kpd 2	*
	dc.w		I_Extra_Wdr			; kpd 3	*
	dc.w		0				; kpd 0
	dc.w		I_Extra_reset		; kpd .
	dc.w		0				; kpd ENTER
	ds.w		3

Video_macros:
	dc.w		I_Cell_cut			* ESC
*------------------------------------------
	dc.w		I_Draw_brush		* 1
	dc.w		I_Draw_line			* 2
	dc.w		I_Draw_curve		* 3
	dc.w		I_Draw_polygon		* 4
	dc.w		I_Draw_circle		* 5
	dc.w		I_Draw_box			* 6
	dc.w		I_Draw_fill			* 7
	dc.w		I_Draw_airbrush		* 8
	dc.w		I_Draw_grid			* 9
	dc.w		I_Draw_exchange		* 0
*------------------------------------------
	dc.w		I_Colour_spread		; -
	dc.w		I_Tween_menu		; =
	dc.w		I_Restore_image		; BS
	dc.w		I_Cell_autocut		; TAB
	dc.w		I_Apex_quit			; Q
	dc.w		I_Draw_polygon		; W
	dc.w		I_Draw_exchange		; E
	dc.w		I_Cell_rotate		; R
	dc.w		I_Colour_exchange		; T
	dc.w		I_Cell_distort		; Y
	dc.w		I_Cell_under		; U
	dc.w		I_Cell_invert		; I
	dc.w		I_Draw_circle		; O
	dc.w		I_Cell_paste		; P
	dc.w		I_Colour_cut		; [
	dc.w		I_Colour_paste		; ]
	dc.w		I_Apex_disk			; RET
	dc.w		0				* CNTL
	dc.w		I_Draw_airbrush		; A
	dc.w		I_Cell_rescale		; S
	dc.w		I_Draw_brush		; D
	dc.w		I_Draw_fill			; F
	dc.w		I_Video_photo		; G
	dc.w		I_Video_film		; H
	dc.w		I_Video_size		; J
	dc.w		I_Draw_curve		; K
	dc.w		I_Draw_line			; L
	dc.w		I_Extra_gridswitch	; ;
	dc.w		0				; '
	dc.w		0				; `
	dc.w		0				* LEFT SHIFT
	dc.w		I_Apex_brush		; #
	dc.w		I_Extra_Wzoom		; Z		**
	dc.w		I_Extra_xray		; X
	dc.w		I_Extra_Cpick		; C
	dc.w		I_Apex_video		; V
	dc.w		I_Draw_box			; B
	dc.w		I_Cell_remap		; N
	dc.w		I_Cell_move			; M
	dc.w		I_Frame_start		; ,
	dc.w		I_Frame_end			; .
	dc.w		I_Apex_info			; /
	dc.w		0				* RIGHT SHIFT
	dc.w		0	
	dc.w		0				* ALT
	dc.w		I_Extra_center		; SPACE
	dc.w		0				* CAPS
	dc.w		I_Swap_draw			; F1
	dc.w		I_Swap_cell			; F2
	dc.w		I_Swap_colour		; F3
	dc.w		I_Swap_video		; F4
	dc.w		I_Swap_pro			; F5
	dc.w		I_Swap_aproc		; F6
	dc.w		I_Swap_morph		; F7
	dc.w		I_Swap_text			; F8
	dc.w		I_Special_start		; F9
	dc.w		I_Special_end		; F10
	dc.w		0
	dc.w		0
	dc.w		I_Frame_clear		; CLRHOME
	dc.w		I_Extra_playleft		; UP ARROW
	dc.w		0
	dc.w		I_Extra_Wpan		; kpd -
	dc.w		I_Frame_left		; LEFT ARROW
	dc.w		0
	dc.w		I_Frame_right		; RIGHT ARROW
	dc.w		I_Extra_Wzoom		; kpd +
	dc.w		0
	dc.w		I_Extra_playright		; DOWN ARROW
	dc.w		0
	dc.w		I_Frame_right_ins		; INSERT
	dc.w		I_Frames_delete		; DELETE
	ds.w		96-84
	dc.w		I_Extra_Wpan		; \		**
	dc.w		I_Undo_changes		; UNDO
	dc.w		I_Apex_help			; HELP
	dc.w		0				; kpd (
	dc.w		0				; kpd )
	dc.w		0				; kpd /
	dc.w		I_Extra_fix			; kpd *
	dc.w		I_Extra_Wul			; kpd 7	*
	dc.w		I_Extra_Wu			; kpd 8	*
	dc.w		I_Extra_Wur			; kpd 9	*
	dc.w		I_Extra_Wl			; kpd 4	*
	dc.w		0				; kpd 5
	dc.w		I_Extra_Wr			; kpd 6	*
	dc.w		I_Extra_Wdl			; kpd 1	*
	dc.w		I_Extra_Wd			; kpd 2	*
	dc.w		I_Extra_Wdr			; kpd 3	*
	dc.w		0				; kpd 0
	dc.w		I_Extra_reset		; kpd .
	dc.w		0				; kpd ENTER
	ds.w		3

Pro_macros:
	dc.w		I_Cell_cut			* ESC
*------------------------------------------
	dc.w		I_Draw_brush		* 1
	dc.w		I_Draw_line			* 2
	dc.w		I_Draw_curve		* 3
	dc.w		I_Draw_polygon		* 4
	dc.w		I_Draw_circle		* 5
	dc.w		I_Draw_box			* 6
	dc.w		I_Draw_fill			* 7
	dc.w		I_Draw_airbrush		* 8
	dc.w		I_Draw_grid			* 9
	dc.w		I_Draw_exchange		* 0
*------------------------------------------
	dc.w		I_Colour_spread		; -
	dc.w		I_Tween_menu		; =
	dc.w		I_Restore_image		; BS
	dc.w		I_Cell_autocut		; TAB
	dc.w		I_Apex_quit			; Q
	dc.w		I_Draw_polygon		; W
	dc.w		I_Draw_exchange		; E
	dc.w		I_Pro_airbrush		; R
	dc.w		I_Colour_exchange		; T
	dc.w		I_Cell_distort		; Y
	dc.w		I_Cell_under		; U
	dc.w		I_Cell_invert		; I
	dc.w		I_Pro_options		; O
	dc.w		I_Cell_paste		; P
	dc.w		I_Colour_cut		; [
	dc.w		I_Colour_paste		; ]
	dc.w		I_Apex_disk			; RET
	dc.w		0				* CNTL
	dc.w		I_Pro_area			; A
	dc.w		I_Cell_rescale		; S
	dc.w		I_Pro_brush			; D
	dc.w		I_Pro_fill			; F
	dc.w		I_Pro_go			; G
	dc.w		I_Colour_flip		; H
	dc.w		I_Colour_sort		; J
	dc.w		I_Draw_curve		; K
	dc.w		I_Draw_line			; L
	dc.w		I_Extra_gridswitch	; ;
	dc.w		0				; '
	dc.w		0				; `
	dc.w		0				* LEFT SHIFT
	dc.w		I_Apex_brush		; #
	dc.w		I_Extra_Wzoom		; Z		**
	dc.w		I_Extra_xray		; X
	dc.w		I_Extra_Cpick		; C
	dc.w		I_Apex_video		; V
	dc.w		I_Draw_box			; B
	dc.w		I_Cell_remap		; N
	dc.w		I_Pro_mask			; M
	dc.w		I_Frame_start		; ,
	dc.w		I_Frame_end			; .
	dc.w		I_Apex_info			; /
	dc.w		0				* RIGHT SHIFT
	dc.w		0	
	dc.w		0				* ALT
	dc.w		I_Extra_center		; SPACE
	dc.w		0				* CAPS
	dc.w		I_Swap_draw			; F1
	dc.w		I_Swap_cell			; F2
	dc.w		I_Swap_colour		; F3
	dc.w		I_Swap_video		; F4
	dc.w		I_Swap_pro			; F5
	dc.w		I_Swap_aproc		; F6
	dc.w		I_Swap_morph		; F7
	dc.w		I_Swap_text			; F8
	dc.w		I_Special_start		; F9
	dc.w		I_Special_end		; F10
	dc.w		0
	dc.w		0
	dc.w		I_Frame_clear		; CLRHOME
	dc.w		I_Extra_playleft		; UP ARROW
	dc.w		0
	dc.w		I_Extra_Wpan		; kpd -
	dc.w		I_Frame_left		; LEFT ARROW
	dc.w		0
	dc.w		I_Frame_right		; RIGHT ARROW
	dc.w		I_Extra_Wzoom		; kpd +
	dc.w		0
	dc.w		I_Extra_playright		; DOWN ARROW
	dc.w		0
	dc.w		I_Frame_right_ins		; INSERT
	dc.w		I_Frames_delete		; DELETE
	ds.w		96-84
	dc.w		I_Extra_Wpan		; \		**
	dc.w		I_Undo_changes		; UNDO
	dc.w		I_Apex_help			; HELP
	dc.w		0				; kpd (
	dc.w		0				; kpd )
	dc.w		0				; kpd /
	dc.w		I_Extra_fix			; kpd *
	dc.w		I_Extra_Wul			; kpd 7	*
	dc.w		I_Extra_Wu			; kpd 8	*
	dc.w		I_Extra_Wur			; kpd 9	*
	dc.w		I_Extra_Wl			; kpd 4	*
	dc.w		0				; kpd 5
	dc.w		I_Extra_Wr			; kpd 6	*
	dc.w		I_Extra_Wdl			; kpd 1	*
	dc.w		I_Extra_Wd			; kpd 2	*
	dc.w		I_Extra_Wdr			; kpd 3	*
	dc.w		0				; kpd 0
	dc.w		I_Extra_reset		; kpd .
	dc.w		0				; kpd ENTER
	ds.w		3

Morph_macros:
	dc.w		0				* ESC
*------------------------------------------
	dc.w		0				* 1
	dc.w		0				* 2
	dc.w		0				* 3
	dc.w		0				* 4
	dc.w		0				* 5
	dc.w		0				* 6
	dc.w		0				* 7
	dc.w		0				* 8
	dc.w		0				* 9
	dc.w		0				* 0
*------------------------------------------
	dc.w		0				; -
	dc.w		I_Tween_menu		; =
	dc.w		I_Morph_del_l		; BS
	dc.w		0				; TAB
	dc.w		I_Apex_quit			; Q
	dc.w		0				; W
	dc.w		0				; E
	dc.w		0				; R
	dc.w		0				; T
	dc.w		0				; Y
	dc.w		0				; U
	dc.w		0				; I
	dc.w		I_Morph_options		; O
	dc.w		0				; P
	dc.w		0				; [
	dc.w		0				; ]
	dc.w		I_Apex_disk			; RET
	dc.w		0				* CNTL
	dc.w		I_Morph_area		; A
	dc.w		0				; S
	dc.w		I_Morph_drag		; D
	dc.w		0				; F
	dc.w		I_Morph_go			; G
	dc.w		0				; H
	dc.w		0				; J
	dc.w		I_Morph_del_a		; K
	dc.w		I_Morph_line		; L
	dc.w		I_Extra_gridswitch	; ;
	dc.w		0				; '
	dc.w		0				; `
	dc.w		0				* LEFT SHIFT
	dc.w		I_Apex_brush		; #
	dc.w		I_Extra_Wzoom		; Z		**
	dc.w		0				; X
	dc.w		I_Extra_Cpick		; C
	dc.w		I_Apex_video		; V
	dc.w		0				; B
	dc.w		0				; N
	dc.w		0				; M
	dc.w		I_Frame_start		; ,
	dc.w		I_Frame_end			; .
	dc.w		I_Apex_info			; /
	dc.w		0				* RIGHT SHIFT
	dc.w		0	
	dc.w		0				* ALT
	dc.w		I_Extra_center		; SPACE
	dc.w		0				* CAPS
	dc.w		I_Swap_draw			; F1
	dc.w		I_Swap_cell			; F2
	dc.w		I_Swap_colour		; F3
	dc.w		I_Swap_video		; F4
	dc.w		I_Swap_pro			; F5
	dc.w		I_Swap_aproc		; F6
	dc.w		I_Swap_morph		; F7
	dc.w		I_Swap_text			; F8
	dc.w		I_Special_start		; F9
	dc.w		I_Special_end		; F10
	dc.w		0
	dc.w		0
	dc.w		0				; CLRHOME
	dc.w		I_Extra_playleft		; UP ARROW
	dc.w		0
	dc.w		I_Extra_Wpan		; kpd -
	dc.w		I_Frame_left		; LEFT ARROW
	dc.w		0
	dc.w		I_Frame_right		; RIGHT ARROW
	dc.w		I_Extra_Wzoom		; kpd +
	dc.w		0
	dc.w		I_Extra_playright		; DOWN ARROW
	dc.w		0
	dc.w		I_Frame_right_ins		; INSERT
	dc.w		I_Frames_delete		; DELETE
	ds.w		96-84
	dc.w		I_Extra_Wpan		; \		**
	dc.w		I_Undo_changes		; UNDO
	dc.w		I_Apex_help			; HELP
	dc.w		0				; kpd (
	dc.w		0				; kpd )
	dc.w		0				; kpd /
	dc.w		I_Extra_fix			; kpd *
	dc.w		I_Extra_Wul			; kpd 7	*
	dc.w		I_Extra_Wu			; kpd 8	*
	dc.w		I_Extra_Wur			; kpd 9	*
	dc.w		I_Extra_Wl			; kpd 4	*
	dc.w		0				; kpd 5
	dc.w		I_Extra_Wr			; kpd 6	*
	dc.w		I_Extra_Wdl			; kpd 1	*
	dc.w		I_Extra_Wd			; kpd 2	*
	dc.w		I_Extra_Wdr			; kpd 3	*
	dc.w		0				; kpd 0
	dc.w		I_Extra_reset		; kpd .
	dc.w		0				; kpd ENTER
	ds.w		3

Aproc_macros:
	dc.w		I_Cell_cut			* ESC
*------------------------------------------
	dc.w		I_Draw_brush		* 1
	dc.w		I_Draw_line			* 2
	dc.w		I_Draw_curve		* 3
	dc.w		I_Draw_polygon		* 4
	dc.w		I_Draw_circle		* 5
	dc.w		I_Draw_box			* 6
	dc.w		I_Draw_fill			* 7
	dc.w		I_Draw_airbrush		* 8
	dc.w		I_Draw_grid			* 9
	dc.w		I_Draw_exchange		* 0
*------------------------------------------
	dc.w		I_Colour_spread		; -
	dc.w		I_Tween_menu		; =
	dc.w		I_Restore_image		; BS
	dc.w		I_Cell_autocut		; TAB
	dc.w		I_Apex_quit			; Q
	dc.w		I_Draw_polygon		; W
	dc.w		I_Draw_exchange		; E
	dc.w		I_Cell_rotate		; R
	dc.w		I_Colour_exchange		; T
	dc.w		I_Cell_distort		; Y
	dc.w		I_Cell_under		; U
	dc.w		I_Cell_invert		; I
	dc.w		I_Draw_circle		; O
	dc.w		I_Cell_paste		; P
	dc.w		I_Colour_cut		; [
	dc.w		I_Colour_paste		; ]
	dc.w		I_Apex_disk			; RET
	dc.w		0				* CNTL
	dc.w		I_Aproc_area		; A
	dc.w		I_Cell_rescale		; S
	dc.w		I_Aproc_defocus		; D
	dc.w		I_Draw_fill			; F
	dc.w		I_Aproc_go			; G
	dc.w		I_Colour_flip		; H
	dc.w		I_Aproc_dejag		; J
	dc.w		I_Draw_curve		; K
	dc.w		I_Draw_line			; L
	dc.w		I_Extra_gridswitch	; ;
	dc.w		0				; '
	dc.w		0				; `
	dc.w		0				* LEFT SHIFT
	dc.w		I_Apex_brush		; #
	dc.w		I_Extra_Wzoom		; Z		**
	dc.w		I_Extra_xray		; X
	dc.w		I_Extra_Cpick		; C
	dc.w		I_Apex_video		; V
	dc.w		I_Aproc_mblur		; B
	dc.w		I_Aproc_dolby		; N
	dc.w		I_Cell_move			; M
	dc.w		I_Frame_start		; ,
	dc.w		I_Frame_end			; .
	dc.w		I_Apex_info			; /
	dc.w		0				* RIGHT SHIFT
	dc.w		0	
	dc.w		0				* ALT
	dc.w		I_Extra_center		; SPACE
	dc.w		0				* CAPS
	dc.w		I_Swap_draw			; F1
	dc.w		I_Swap_cell			; F2
	dc.w		I_Swap_colour		; F3
	dc.w		I_Swap_video		; F4
	dc.w		I_Swap_pro			; F5
	dc.w		I_Swap_aproc		; F6
	dc.w		I_Swap_morph		; F7
	dc.w		I_Swap_text			; F8
	dc.w		I_Special_start		; F9
	dc.w		I_Special_end		; F10
	dc.w		0
	dc.w		0
	dc.w		I_Frame_clear		; CLRHOME
	dc.w		I_Extra_playleft		; UP ARROW
	dc.w		0
	dc.w		I_Extra_Wpan		; kpd -
	dc.w		I_Frame_left		; LEFT ARROW
	dc.w		0
	dc.w		I_Frame_right		; RIGHT ARROW
	dc.w		I_Extra_Wzoom		; kpd +
	dc.w		0
	dc.w		I_Extra_playright		; DOWN ARROW
	dc.w		0
	dc.w		I_Frame_right_ins		; INSERT
	dc.w		I_Frames_delete		; DELETE
	ds.w		96-84
	dc.w		I_Extra_Wpan		; \		**
	dc.w		I_Undo_changes		; UNDO
	dc.w		I_Apex_help			; HELP
	dc.w		0				; kpd (
	dc.w		0				; kpd )
	dc.w		0				; kpd /
	dc.w		I_Extra_fix			; kpd *
	dc.w		I_Extra_Wul			; kpd 7	*
	dc.w		I_Extra_Wu			; kpd 8	*
	dc.w		I_Extra_Wur			; kpd 9	*
	dc.w		I_Extra_Wl			; kpd 4	*
	dc.w		0				; kpd 5
	dc.w		I_Extra_Wr			; kpd 6	*
	dc.w		I_Extra_Wdl			; kpd 1	*
	dc.w		I_Extra_Wd			; kpd 2	*
	dc.w		I_Extra_Wdr			; kpd 3	*
	dc.w		0				; kpd 0
	dc.w		I_Extra_reset		; kpd .
	dc.w		0				; kpd ENTER
	ds.w		3

Text_macros:
	dc.w		I_Cell_cut			* ESC
*------------------------------------------
	dc.w		I_Draw_brush		* 1
	dc.w		I_Draw_line			* 2
	dc.w		I_Draw_curve		* 3
	dc.w		I_Draw_polygon		* 4
	dc.w		I_Draw_circle		* 5
	dc.w		I_Draw_box			* 6
	dc.w		I_Draw_fill			* 7
	dc.w		I_Draw_airbrush		* 8
	dc.w		I_Draw_grid			* 9
	dc.w		I_Draw_exchange		* 0
*------------------------------------------
	dc.w		I_Colour_spread		; -
	dc.w		I_Tween_menu		; =
	dc.w		I_Restore_image		; BS
	dc.w		I_Cell_autocut		; TAB
	dc.w		I_Apex_quit			; Q
	dc.w		I_Draw_polygon		; W
	dc.w		I_Text_clear		; E
	dc.w		I_Cell_rotate		; R
	dc.w		I_Text_type			; T
	dc.w		I_Cell_distort		; Y
	dc.w		I_Cell_under		; U
	dc.w		I_Cell_invert		; I
	dc.w		I_Text_options		; O
	dc.w		I_Cell_paste		; P
	dc.w		I_Colour_cut		; [
	dc.w		I_Colour_paste		; ]
	dc.w		I_Apex_disk			; RET
	dc.w		0				* CNTL
	dc.w		I_Draw_airbrush		; A
	dc.w		I_Cell_rescale		; S
	dc.w		I_Draw_brush		; D
	dc.w		I_Draw_fill			; F
	dc.w		I_Colour_grey		; G
	dc.w		I_Colour_flip		; H
	dc.w		I_Colour_sort		; J
	dc.w		I_Draw_curve		; K
	dc.w		I_Draw_line			; L
	dc.w		I_Extra_gridswitch	; ;
	dc.w		0				; '
	dc.w		0				; `
	dc.w		0				* LEFT SHIFT
	dc.w		I_Apex_brush		; #
	dc.w		I_Extra_Wzoom		; Z		**
	dc.w		I_Extra_xray		; X
	dc.w		I_Extra_Cpick		; C
	dc.w		I_Apex_video		; V
	dc.w		I_Draw_box			; B
	dc.w		I_Cell_remap		; N
	dc.w		I_Cell_move			; M
	dc.w		I_Frame_start		; ,
	dc.w		I_Frame_end			; .
	dc.w		I_Apex_info			; /
	dc.w		0				* RIGHT SHIFT
	dc.w		0	
	dc.w		0				* ALT
	dc.w		I_Extra_center		; SPACE
	dc.w		0				* CAPS
	dc.w		I_Swap_draw			; F1
	dc.w		I_Swap_cell			; F2
	dc.w		I_Swap_colour		; F3
	dc.w		I_Swap_video		; F4
	dc.w		I_Swap_pro			; F5
	dc.w		I_Swap_aproc		; F6
	dc.w		I_Swap_morph		; F7
	dc.w		I_Swap_text			; F8
	dc.w		I_Special_start		; F9
	dc.w		I_Special_end		; F10
	dc.w		0
	dc.w		0
	dc.w		I_Frame_clear		; CLRHOME
	dc.w		I_Extra_playleft		; UP ARROW
	dc.w		0
	dc.w		I_Extra_Wpan		; kpd -
	dc.w		I_Frame_left		; LEFT ARROW
	dc.w		0
	dc.w		I_Frame_right		; RIGHT ARROW
	dc.w		I_Extra_Wzoom		; kpd +
	dc.w		0
	dc.w		I_Extra_playright		; DOWN ARROW
	dc.w		0
	dc.w		I_Frame_right_ins		; INSERT
	dc.w		I_Frames_delete		; DELETE
	ds.w		96-84
	dc.w		I_Extra_Wpan		; \		**
	dc.w		I_Undo_changes		; UNDO
	dc.w		I_Apex_help			; HELP
	dc.w		0				; kpd (
	dc.w		0				; kpd )
	dc.w		0				; kpd /
	dc.w		I_Extra_fix			; kpd *
	dc.w		I_Extra_Wul			; kpd 7	*
	dc.w		I_Extra_Wu			; kpd 8	*
	dc.w		I_Extra_Wur			; kpd 9	*
	dc.w		I_Extra_Wl			; kpd 4	*
	dc.w		0				; kpd 5
	dc.w		I_Extra_Wr			; kpd 6	*
	dc.w		I_Extra_Wdl			; kpd 1	*
	dc.w		I_Extra_Wd			; kpd 2	*
	dc.w		I_Extra_Wdr			; kpd 3	*
	dc.w		0				; kpd 0
	dc.w		I_Extra_reset		; kpd .
	dc.w		0				; kpd ENTER
	ds.w		3
