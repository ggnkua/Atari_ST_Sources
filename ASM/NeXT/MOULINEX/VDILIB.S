
* VDI Library Copyright (C) HiSoft 1988

* 31.5.88	vqt_extent fixed

* macro to jump to a given VDI routine
govdi	macro	vdi_number
	IFNE	(\1)<128
	moveq	#\1,d0
	ELSEIF
	move.w	#\1,d0
	ENDC
	bra	CALL_VDI
	endm

DEFV	macro	name
	MODULE	\1
	XREF	CALL_VDI,LOW_VDI
	XREF	contrl,contrl1,contrl3,contrl6
	XREF	intin,ptsin,intout,ptsout
	XREF	vdi_params,current_handle
	endm

EXPORT	macro	name
\1	XDEF	\1
	endm

docont	macro	contrl1,contrl3
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

	EXPORT	v_opnwk
	moveq	#1,d0
v_opall	docont	0,11
	bsr	LOW_VDI
	move.w	contrl6,current_handle
	rts

	EXPORT	v_clswk
	docont	0,0
	govdi	2

	EXPORT	v_opnvwk
	moveq	#100,d0
	move.w	current_handle,contrl6
	bra.s	v_opall

	EXPORT	v_clsvwk
	docont	0,0
	govdi	101

	EXPORT	v_clrwk
	moveq	#3,d0
v_zeroz	docont	0,0
	bra	CALL_VDI

	EXPORT	v_updwk
	moveq	#4,d0
	bra.s	v_zeroz

	EXPORT	vst_load_fonts
	moveq	#119,d0
vfont_all
	docont	0,1
	clr.w	intin
	bsr	CALL_VDI
	move.w	intout,d0
	rts

	EXPORT	vst_unload_fonts
	moveq	#120,d0
	bra.s	vfont_all

	EXPORT	vs_clip
	docont	2,1
	govdi	129

	DEFV	OutputFunctions

	EXPORT	v_pline
	moveq	#6,d0
v_pall	clr.w	contrl3
	bra	CALL_VDI

	EXPORT	v_pmarker
	moveq	#7,d0
	bra.s	v_pall

	EXPORT	v_fillarea
	moveq	#9,d0
	bra.s	v_pall

	EXPORT	v_gtext
	moveq	#0,d0
	moveq	#0,d1
	lea	intin,a1
.copy	move.b	(a0)+,d1		convert C string into words
	beq.s	.end
	move.w	d1,(a1)+
	addq.b	#1,d0
	bpl.s	.copy
.end	move.w	d0,contrl3
	move.w	#1,contrl1
	govdi	8

	EXPORT	v_contourfill
	docont	1,1
	govdi	103

	EXPORT	vr_recfl
	docont	2,0
	govdi	114

	EXPORT	v_pieslice
	moveq	#3,d0
	bra.s	gdp_arcpie

	EXPORT	v_arc
	moveq	#2,d0
gdp_arcpie
	docont	4,2
	clr.l	ptsin+4
	clr.l	ptsin+8
	clr.w	ptsin+14
	bra	gdp_all

	EXPORT	v_bar
	docont	2,0
	moveq	#1,d0
	bra.s	gdp_all	

	EXPORT	v_circle
	docont	3,0
	moveq	#4,d0
	clr.l	ptsin+4
	clr.w	ptsin+10
	bra.s	gdp_all

	EXPORT	v_ellarc
	docont	2,2
	moveq	#6,d0
	bra.s	gdp_all

	EXPORT	v_ellpie
	docont	2,2
	moveq	#7,d0
	bra.s	gdp_all

	EXPORT	v_ellipse
	docont	2,0
	moveq	#5,d0
	bra.s	gdp_all

	EXPORT	v_rbox
	moveq	#8,d0
gdp_box	docont	2,0
gdp_all	move.w	d0,contrl+10
	govdi	11

	EXPORT	v_rfbox
	moveq	#8,d0
	bra.s	gdp_box

	EXPORT	v_justified
	moveq	#2,d0
	moveq	#0,d1
	lea	intin+4,a1
.copy	move.b	(a0)+,d1		convert C string into words
	beq.s	.end
	move.w	d1,(a1)+
	addq.b	#1,d0
	bpl.s	.copy
.end	move.w	d0,contrl3
	move.w	#2,contrl1
	moveq	#10,d0
	bra.s	gdp_all


	DEFV	AttributeFunctions

	EXPORT	vswr_mode
	docont	0,1
	govdi	32

	EXPORT	vs_color
	docont	0,4
	govdi	14

	EXPORT	vsl_type
	docont	0,1
	govdi	15

	EXPORT	vsl_udsty
	docont	0,1
	govdi	113

	EXPORT	vsl_width
	docont	1,0
	clr.w	ptsin+2
	govdi	16

	EXPORT	vsl_color
	docont	0,1
	govdi	17

	EXPORT	vsl_ends
	docont	0,2
	govdi	108

	EXPORT	vsm_type
	docont	0,1
	govdi	18

	EXPORT	vsm_height
	docont	1,0
	clr.w	ptsin
	govdi	19

	EXPORT	vsm_color
	docont	0,1
	govdi	20

	EXPORT	vst_height
	docont	1,0
	clr.w	ptsin
	govdi	12

	EXPORT	vst_point
	docont	0,1
	govdi	107

	EXPORT	vst_rotation
	docont	0,1
	govdi	13

	EXPORT	vst_font
	docont	0,1
	govdi	21

	EXPORT	vst_color
	docont	0,1
	govdi	22

	EXPORT	vst_effects
	docont	0,1
	govdi	106

	EXPORT	vst_alignment
	docont	0,2
	govdi	39

	EXPORT	vsf_interior
	docont	0,1
	govdi	23

	EXPORT	vsf_style
	docont	0,1
	govdi	24

	EXPORT	vsf_color
	docont	0,1
	govdi	25

	EXPORT	vsf_perimeter
	docont	0,1
	govdi	104

	EXPORT	vsf_updat
	clr.w	contrl1
	govdi	112

	DEFV	RastorOps

	EXPORT	vro_cpyfm
	docont	4,1
	govdi	109

	EXPORT	vrt_cpyfm
	docont	4,3
	govdi	121

	EXPORT	vr_trnfm
	docont	0,0
	govdi	110

	EXPORT	v_get_pixel
	docont	1,0
	govdi	105


	DEFV	InputFunctions

	EXPORT	vex_timv
	docont	0,0
	govdi	118

	EXPORT	v_show_c
	docont	0,1
	govdi	122

	EXPORT	v_hide_c
	docont	0,0
	govdi	123

	EXPORT	vq_mouse
	docont	0,0
	govdi	124

	EXPORT	vex_butv
	docont	0,0
	govdi	125

	EXPORT	vex_motv
	docont	0,0
	govdi	126

	EXPORT	vex_curv
	docont	0,0
	govdi	127

	EXPORT	vq_key_s
	docont	0,0
	govdi	128

	DEFV	InquireFunctions

	EXPORT	vq_extnd
	docont	0,1
	govdi	102

	EXPORT	vq_color
	docont	0,2
	govdi	26

	EXPORT	vql_attributes
	docont	0,0
	govdi	35

	EXPORT	vqm_attributes
	docont	0,0
	govdi	36

	EXPORT	vqf_attributes
	docont	0,0
	govdi	37

	EXPORT	vqt_attributes
	docont	0,0
	govdi	38

	EXPORT	vqt_extent
	moveq	#0,d0
	moveq	#0,d1
	lea	intin,a1
.copy	move.b	(a0)+,d1		convert C string into words
	beq.s	.end
	move.w	d1,(a1)+
	addq.b	#1,d0
	bpl.s	.copy
.end	move.w	d0,contrl3
	clr.w	contrl1
	govdi	116

	EXPORT	vqt_width
	docont	0,1
	govdi	117

	EXPORT	vqt_name
	docont	0,1
	govdi	130

	EXPORT	vqt_fontinfo
	docont	0,0
	govdi	131


* the actual calling of the VDI
	MODULE	LowLevelVDI
	XDEF	CALL_VDI,LOW_VDI
	XDEF	contrl,contrl1,contrl3,contrl6
	XDEF	intin,intout,ptsin,ptsout
	XDEF	current_handle,vdi_params

* call a VDI routine
* in:	d0.w=VDI function number
* out	none
* uses	d0-d2/a0-a2
* uses the current handle
CALL_VDI
	move.w	current_handle,contrl6
LOW_VDI	move.w	d0,contrl			store the op code
	move.l	#vdi_params,d1
	move.w	#115,d0			function number
	trap	#2
	rts

* this is a table of pointers to all the VDI arrays
vdi_params	dc.l	contrl,intin,ptsin,intout,ptsout

* these don't need initialising so can go in the BSS section

current_handle	ds.w	1		used by all VDI calls

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

intin	ds.w	128		min 30
intout	ds.w	128		min 45
ptsin	ds.w	128		min 30
ptsout	ds.w	128		min 12


*********** END OF VDI *****************
