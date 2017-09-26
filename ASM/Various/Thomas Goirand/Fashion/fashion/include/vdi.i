*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*
*********** VDI MACROS *************
	XREF	intin,intout,ptsin,ptsout


* conditional macro definition(!) to call vdi routine
	IFGT	__LK
callvdi	macro	; vdiname
	XREF	\1
	jsr	\1
	endm
	ELSEIF
callvdi	macro	; vdiname
	XREF	\1
	jsr	\1
	endm
	ENDC
* may need to change BSR above to JSR for large progs

v_opnwk	macro
	callvdi	v_opnwk
	endm

v_clswk	macro
	callvdi	v_clswk
	endm

v_opnvwk	macro
	callvdi	v_opnvwk
	endm

v_clsvwk	macro
	callvdi	v_clsvwk
	endm

v_clrwk	macro
	callvdi	v_clrwk
	endm

v_updwk	macro
	callvdi	v_updwk
	endm

vst_load_fonts	macro
	callvdi	vst_load_fonts
	endm

vst_unload_fonts	macro
	callvdi	vst_unload_fonts
	endm

vs_clip	macro	; flag,x1,y1,x2,y2
	move.w	\1,intin
	move.w	\2,ptsin
	move.w	\3,ptsin+2
	move.w	\4,ptsin+4
	move.w	\5,ptsin+6
	callvdi	vs_clip
	endm

v_pline	macro	; count
	move.w	\1,contrl1
	callvdi	v_pline
	endm

v_pmarker	macro	; count
	move.w	\1,contrl1
	callvdi	v_pmarker
	endm

v_gtext	macro	; x,y,string
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.l	\3,a0
	callvdi	v_gtext
	endm

v_fillarea	macro	; count
	move.w	\1,contrl1
	callvdi	v_fillarea
	endm
	
v_contourfill	macro	; x,y,index
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,intin
	callvdi	v_contourfill
	endm

vr_recfl	macro	; x1,y1,x2,y2
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	vr_recfl
	endm

v_bar	macro	; x1,y1,x2,y2
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	v_bar
	endm

v_arc	macro	; x,y,rad,start,end
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+12
	moev.w	\4,intin
	move.w	\5,intin+2
	callvdi	v_arc
	endm

v_pieslice	macro	; x,y,rad,start,end
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+12
	moev.w	\4,intin
	move.w	\5,intin+2
	callvdi	v_pieslice
	endm

v_circle	macro	; x,y,rad
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+8
	callvdi	v_circle
	endm

v_ellarc	macro	; x,y,xr,yr,start,end
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	move.w	\5,intin
	move.w	\6,intin+2
	callvdi	v_ellarc
	endm

v_ellpie	macro	; x,y,xr,yr,start,end
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	move.w	\5,intin
	move.w	\6,intin+2
	callvdi	v_ellpie
	endm

v_ellipse	macro	; x,y,xr,yr
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	v_ellipse
	endm

v_rbox	macro	; x1,y1,x2,y2
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	v_rbox
	endm

v_rfbox	macro	; x1,y1,x2,y2
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	v_rfbox
	endm

v_justified	macro	; x,y,string,length,ws,cs
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\4,ptsin+4
	move.w	\5,intin
	move.w	\6,intin+2
	move.l	\3,a0
	callvdi	v_justified
	endm

vswr_mode	macro	; mode
	move.w	\1,intin
	callvdi	vswr_mode
	endm

vs_color	macro	; index,read,green,blue
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	callvdi	vs_color
	endm

vsl_type	macro	; style
	move.w	\1,intin
	callvdi	vsl_type
	endm

vsl_udsty	macro	; pattern
	move.w	\1,intin
	callvdi	vsl_udsty
	endm

vsl_width	macro	; width
	move.w	\1,ptsin
	callvdi	vsl_width
	endm

vsl_color	macro	; index
	move.w	\1,intin
	callvdi	vsl_color
	endm

vsl_ends	macro	; beg,end
	move.w	\1,intin
	move.w	\2,intin+2
	callvdi	vsl_ends
	endm

vsm_type	macro	; symbol
	move.w	\1,intin
	callvdi	vsm_type
	endm

vsm_height	macro	; height
	move.w	\1,ptsin+2
	callvdi	vsm_height
	endm

vsm_color	macro	; index
	move.w	\1,intin
	callvdi	vsm_color
	endm

vst_height	macro	; height
	move.w	\1,ptsin+2
	callvdi	vst_height
	endm

vst_point	macro	; point
	move.w	\1,intin
	callvdi	vst_point
	endm

vst_rotation	macro	; angle
	move.w	\1,intin
	callvdi	vst_rotation
	endm

vst_font	macro	; font
	move.w	\1,intin
	callvdi	vst_font
	endm

vst_color	macro	; index
	move.w	\1,intin
	callvdi	vst_color
	endm

vst_effects	macro	; effect
	move.w	\1,intin
	callvdi	vst_effects
	endm

vst_alignment	macro	; hor,vert
	move.w	\1,intin
	move.w	\2,intin+2
	callvdi	vst_alignment
	endm

vsf_interior	macro	; style
	move.w	\1,intin
	callvdi	vsf_interior
	endm

vsf_style	macro	; index
	move.w	\1,intin
	callvdi	vsf_style
	endm

vsf_color	macro	; index
	move.w	\1,intin
	callvdi	vsf_color
	endm

vsf_perimeter	macro	; vis
	move.w	\1,intin
	callvdi	vsf_perimeter
	endm

vsf_updat	macro
	callvdi	vsf_updat
	endm

vro_cpyfm	macro	; mode,sourceMFDB,destMFDB
	move.w	\1,intin
	move.l	\2,contrl+14
	move.l	\3,contrl+18
	callvdi	vro_cpyfm
	endm

vrt_cpyfm	macro	; mode,sourceMFDB,destMFDB,index1,index2
	move.w	\1,intin
	move.l	\2,contrl+14
	move.l	\3,contrl+18
	move.w	\4,intin+2
	move.w	\5,intin+4
	callvdi	vrt_cpyfm
	endm

vr_trnfm	macro	; source,dest
	move.l	\1,contrl+14
	move.l	\2,contrl+18
	callvdi	vr_trnfm
	endm

v_get_pixel	macro	; x,y
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	callvdi	v_get_pixel
	endm

vex_timv	macro	; newtimer
	move.l	\1,contrl+14
	callvdi	vex_timv
	endm

v_show_c	macro	; reset
	move.w	\1,intin
	callvdi	v_show_c
	endm

v_hide_c	macro
	callvdi	v_hide_c
	endm

vq_mouse	macro
	callvdi	vq_mouse
	endm

vex_butv	macro	; newxbut
	move.l	\1,contrl+14
	callvdi	vex_butv
	endm

vex_motv	macro	; newmov
	move.l	\1,contrl+14
	callvdi	vex_motv
	endm

vex_curv	macro	; newcursor
	move.l	\1,contrl+14
	callvdi	vex_curv
	endm

vq_key_s	macro
	callvdi	vq_key_s
	endm

vq_extnd	macro	; flag
	move.w	\1,intin
	callvdi	vq_extnd
	endm

vq_color	macro	; index,flag
	move.w	\1,intin
	move.w	\2,intin+2
	callvdi	vq_color
	endm

vql_attributes	macro
	callvdi	vql_attributes
	endm

vqm_attributes	macro
	callvdi	vqm_attributes
	endm

vqf_attributes	macro
	callvdi	vqf_attributes
	endm

vqt_attributes	macro
	callvdi	vqt_attributes
	endm

vqt_extent	macro	; string
	move.l	\1,a0
	callvdi	vqt_extent
	endm

vqt_width	macro	; char
	move.w	\1,intin
	callvdi	vqt_width
	endm

vqt_name	macro	; number
	move.w	\1,intin
	callvdi	vqt_name
	endm

vqt_fontinfo	macro
	callvdi	vqt_fontinfo
	endm

*********** END OF VDI *****************
