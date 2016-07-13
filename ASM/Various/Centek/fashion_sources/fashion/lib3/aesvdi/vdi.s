
* VDI Library Copyright (C) HiSoft 1988

* 31.5.88	vqt_extent fixed
* 25.10.89	v_rfbox fixed

* macro to jump to a given VDI routine
govdi	macro	; vdi_number
	IFNE	(\1)<128
	moveq	#\1,d0
	ELSEIF
	move.w	#\1,d0
	ENDC
	bra	CALL_VDI
	endm

DEFV	macro	; name
\1::
;	SECTION	TEXT
;	XREF	CALL_VDI,LOW_VDI
;	XREF	contrl,contrl1,contrl3,contrl6
;	XREF	intin,ptsin,intout,ptsout
;	XREF	vdi_params,current_handle
	endm

new_label	macro	; name	; macro de definition de label VDI
\1	XDEF	\1
	endm

docont	macro	; contrl1,contrl3
	IFEQ	\1
	clr.w	contrl1
	ELSEIF
	move.w	#\1,contrl1
	ENDC
	IFEQ	\2
	clr.w	contrl3
	ELSEIF
	move.w	#\2,contrl3
	ENDC
	endm

	DEFV	Workstations

	new_label	v_opnwk
	moveq	#1,d0
v_opall	docont	0,11
	bsr	LOW_VDI
	move.w	contrl6,current_handle
	rts

	new_label	v_clswk
	docont	0,0
	govdi	2

	new_label	v_opnvwk
	moveq	#100,d0
	move.w	current_handle,contrl6
	bra.s	v_opall

	new_label	v_clsvwk
	docont	0,0
	govdi	101

	new_label	v_clrwk
	moveq	#3,d0
v_zeroz	docont	0,0
	bra	CALL_VDI

	new_label	v_updwk
	moveq	#4,d0
	bra.s	v_zeroz

	new_label	vst_load_fonts
	moveq	#119,d0
vfont_all
	docont	0,1
	clr.w	intin
	bsr	CALL_VDI
	move.w	intout,d0
	rts

	new_label	vst_unload_fonts
	moveq	#120,d0
	bra.s	vfont_all

	new_label	vs_clip
	docont	2,1
	govdi	129

	DEFV	OutputFunctions

	new_label	v_pline
	moveq	#6,d0
v_pall	clr.w	contrl3
	bra	CALL_VDI

	new_label	v_pmarker
	moveq	#7,d0
	bra.s	v_pall

	new_label	v_fillarea
	moveq	#9,d0
	bra.s	v_pall

	new_label	v_gtext
	moveq	#0,d0
	moveq	#0,d1
	lea	intin,a1
.copy	move.b	(a0)+,d1	; convert C string into words
	beq.s	.end
	move.w	d1,(a1)+
	addq.b	#1,d0
	bpl.s	.copy
.end	move.w	d0,contrl3
	move.w	#1,contrl1
	govdi	8

	new_label	v_contourfill
	docont	1,1
	govdi	103

	new_label	vr_recfl
	docont	2,0
	govdi	114

	new_label	v_pieslice
	moveq	#3,d0
	bra.s	gdp_arcpie

	new_label	v_arc
	moveq	#2,d0
gdp_arcpie
	docont	4,2
	clr.l	ptsin+4
	clr.l	ptsin+8
	clr.w	ptsin+14
	bra	gdp_all

	new_label	v_bar
	docont	2,0
	moveq	#1,d0
	bra.s	gdp_all	

	new_label	v_circle
	docont	3,0
	moveq	#4,d0
	clr.l	ptsin+4
	clr.w	ptsin+10
	bra.s	gdp_all

	new_label	v_ellarc
	docont	2,2
	moveq	#6,d0
	bra.s	gdp_all

	new_label	v_ellpie
	docont	2,2
	moveq	#7,d0
	bra.s	gdp_all

	new_label	v_ellipse
	docont	2,0
	moveq	#5,d0
	bra.s	gdp_all

	new_label	v_rbox
	moveq	#8,d0
gdp_box	docont	2,0
gdp_all	move.w	d0,contrl+10
	govdi	11

	new_label	v_rfbox
	moveq	#9,d0
	bra.s	gdp_box

	new_label	v_justified
	moveq	#2,d0
	moveq	#0,d1
	lea	intin+4,a1
.copy	move.b	(a0)+,d1	; convert C string into words
	beq.s	.end
	move.w	d1,(a1)+
	addq.b	#1,d0
	bpl.s	.copy
.end	move.w	d0,contrl3
	move.w	#2,contrl1
	moveq	#10,d0
	bra.s	gdp_all


	DEFV	AttributeFunctions

	new_label	vswr_mode
	docont	0,1
	govdi	32

	new_label	vs_color
	docont	0,4
	govdi	14

	new_label	vsl_type
	docont	0,1
	govdi	15

	new_label	vsl_udsty
	docont	0,1
	govdi	113

	new_label	vsl_width
	docont	1,0
	clr.w	ptsin+2
	govdi	16

	new_label	vsl_color
	docont	0,1
	govdi	17

	new_label	vsl_ends
	docont	0,2
	govdi	108

	new_label	vsm_type
	docont	0,1
	govdi	18

	new_label	vsm_height
	docont	1,0
	clr.w	ptsin
	govdi	19

	new_label	vsm_color
	docont	0,1
	govdi	20

	new_label	vst_height
	docont	1,0
	clr.w	ptsin
	govdi	12

	new_label	vst_point
	docont	0,1
	govdi	107

	new_label	vst_rotation
	docont	0,1
	govdi	13

	new_label	vst_font
	docont	0,1
	govdi	21

	new_label	vst_color
	docont	0,1
	govdi	22

	new_label	vst_effects
	docont	0,1
	govdi	106

	new_label	vst_alignment
	docont	0,2
	govdi	39

	new_label	vsf_interior
	docont	0,1
	govdi	23

	new_label	vsf_style
	docont	0,1
	govdi	24

	new_label	vsf_color
	docont	0,1
	govdi	25

	new_label	vsf_perimeter
	docont	0,1
	govdi	104

	new_label	vsf_updat
	clr.w	contrl1
	govdi	112

	DEFV	RastorOps

	new_label	vro_cpyfm
	docont	4,1
	govdi	109

	new_label	vrt_cpyfm
	docont	4,3
	govdi	121

	new_label	vr_trnfm
	docont	0,0
	govdi	110

	new_label	v_get_pixel
	docont	1,0
	govdi	105


	DEFV	InputFunctions

	new_label	vex_timv
	docont	0,0
	govdi	118

	new_label	v_show_c
	docont	0,1
	govdi	122

	new_label	v_hide_c
	docont	0,0
	govdi	123

	new_label	vq_mouse
	docont	0,0
	govdi	124

	new_label	vex_butv
	docont	0,0
	govdi	125

	new_label	vex_motv
	docont	0,0
	govdi	126

	new_label	vex_curv
	docont	0,0
	govdi	127

	new_label	vq_key_s
	docont	0,0
	govdi	128

	DEFV	InquireFunctions

	new_label	vq_extnd
	docont	0,1
	govdi	102

	new_label	vq_color
	docont	0,2
	govdi	26

	new_label	vql_attributes
	docont	0,0
	govdi	35

	new_label	vqm_attributes
	docont	0,0
	govdi	36

	new_label	vqf_attributes
	docont	0,0
	govdi	37

	new_label	vqt_attributes
	docont	0,0
	govdi	38

	new_label	vqt_extent
	moveq	#0,d0
	moveq	#0,d1
	lea	intin,a1
.copy	move.b	(a0)+,d1		; convert C string into words
	beq.s	.end
	move.w	d1,(a1)+
	addq.b	#1,d0
	bpl.s	.copy
.end	move.w	d0,contrl3
	clr.w	contrl1
	govdi	116

	new_label	vqt_width
	docont	0,1
	govdi	117

	new_label	vqt_name
	docont	0,1
	govdi	130

	new_label	vqt_fontinfo
	docont	0,0
	govdi	131


* the actual calling of the VDI
;	MODULE	LowLevelVDI
	XDEF	CALL_VDI,LOW_VDI
	XDEF	contrl,contrl1,contrl3,contrl6
	XDEF	intin,intout,ptsin,ptsout
	XDEF	current_handle,vdi_params

	SECTION	TEXT
* call a VDI routine
* in:	d0.w=VDI function number
* out	none
* uses	d0-d2/a0-a2
* uses the current handle
CALL_VDI
	move.w	current_handle,contrl6
LOW_VDI	move.w	d0,contrl			; store the op code
	move.l	#vdi_params,d1
	move.w	#115,d0				; function number
	trap	#2
	rts

	SECTION	DATA
* this is a table of pointers to all the VDI arrays
	XDEF	vdi_params
vdi_params	dc.l	contrl,intin,ptsin,intout,ptsout

	SECTION	BSS
* these don't need initialising so can go in the BSS section
	XDEF	current_handle
current_handle	ds.w	1		; used by all VDI calls

contrl	ds.w	1
contrl1	ds.w	1
contrl2	ds.w	1
contrl3	ds.w	1
contrl4	ds.w	1
contrl5	ds.w	1
contrl6	ds.w	1
contrl7	ds.w	1
contrl8	ds.w	1
contrl9	ds.w	1
contrl10	ds.w	1
contrl11	ds.w	1
* le tableau VDI peut etre plus petit, les tailles minis sont indiquees. Mais sait-on
* jamais, les tailles de sorties peuvent grandir (en entree, c'est moins sur).
intin	ds.w	1024		; min 30
intout	ds.w	512		; min 45
ptsin	ds.w	1024		; min 30
ptsout	ds.w	256		; min 12


*********** END OF VDI *****************
