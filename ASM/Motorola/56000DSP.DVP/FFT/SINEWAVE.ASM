ntin,ptsin,intout,ptsout,vdi_params
	BSR	\1
	endm
	ELSEIF
callvdi	macro	vdiname
	BSR	\1
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

vs_clip	macro	flag,x1,y1,x2,y2
	move.w	\1,intin
	move.w	\2,ptsin
	move.w	\3,ptsin+2
	move.w	\4,ptsin+4
	move.w	\5,ptsin+6
	callvdi	vs_clip
	endm

v_pline	macro	count
	move.w	\1,contrl1
	callvdi	v_pline
	endm

v_pmarker	macro	count
	move.w	\1,contrl1
	callvdi	v_pmarker
	endm

v_gtext	macro	x,y,string
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.l	\3,a0
	callvdi	v_gtext
	endm

v_fillarea	macro	count
	move.w	\1,contrl1
	callvdi	v_fillarea
	endm
	
v_contourfill	mac