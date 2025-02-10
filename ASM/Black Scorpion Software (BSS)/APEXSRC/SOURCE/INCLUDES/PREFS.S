
*-----------------------------------------------------*
read_prefs:
*-----------------------------------------------------*
	move.l	#prefs_name,sysfile_name
	move.l	#prefs_start,sysfile_ptr
	move.l	#prefs_end-prefs_start,sysfile_size
	move.l	#0,sysfile_index
	jsr		READ_SYSFILE
	lea		prefs_start,a0
*-----------------------------------------------------*
	move.w	(a0)+,NEW_MODECODE
	move.l	(a0)+,PHYS_SIZE		
	move.l	(a0)+,CANVAS_SIZE		
	move.w	(a0)+,X_RESOLUTION
	move.w	(a0)+,Y_RESOLUTION
	move.w	(a0)+,VIDEO_WIDTH
	move.w	(a0)+,VIDEO_HEIGHT
	move.w	(a0)+,CANVAS_WIDTH
	move.w	(a0)+,CANVAS_HEIGHT
	move.w	(a0)+,physwid
	move.w	(a0)+,logwid
	move.w	(a0)+,x_factor
	move.w	(a0)+,y_factor
	move.w	(a0)+,textgap
	move.w	(a0)+,MATCODE
	move.w	(a0)+,COLSHIFT
	move.l	(a0)+,COLMASK
	move.l	(a0)+,SIZE_VAL
	move.l	(a0)+,SPACE_VAL
	move.l	(a0)+,SMOOTH_VAL
	move.l	(a0)+,CANWID_VAL
	move.l	(a0)+,CANHIG_VAL
	move.l	(a0)+,scaler
	move.w	(a0)+,cfnxgap2
	move.w	(a0)+,cfnsmooth
	move.l	(a0)+,REDUCE_VAL
	move.w	(a0)+,colours_needed
*-----------------------------------------------------*
	move.b	(a0)+,TRUE_FLAG
	move.b	(a0)+,EXTEND
	move.b	(a0)+,gensol
	move.b	(a0)+,ACCEL
	move.b	(a0)+,LARGE_HANDLES
	move.b	(a0)+,killspin
	move.b	(a0)+,heavycomp
	addq.l	#1,a0
*-----------------------------------------------------*
	move.w	(a0)+,CURRENT_HUE1POS
	move.w	(a0)+,CURRENT_SAT1POS
	move.w	(a0)+,CURRENT_BRI1POS
	move.w	(a0)+,CURRENT_HUE2POS
	move.w	(a0)+,CURRENT_SAT2POS
	move.w	(a0)+,CURRENT_BRI2POS
	move.w	(a0)+,CURRENT_AIRSIZE
	move.w	(a0)+,CURRENT_AIRFLOW
	move.w	(a0)+,CURRENT_VALPOS
	move.w	(a0)+,CURRENT_TIME
	move.w	(a0)+,LAST_AIRSIZE
	move.w	(a0)+,AIRBRUSH_SIZE
	move.w	(a0)+,AIRBRUSH_FLOW
	move.w	(a0)+,NAIR_SIZE
	move.w	(a0)+,CURRENT_MTHRESH
*-----------------------------------------------------*
	move.w	(a0)+,BTYPE_BITS
	move.w	(a0)+,DRAW_BITS
	move.w	(a0)+,LINE_BITS
	move.w	(a0)+,CURVE_BITS
	move.w	(a0)+,POLY_BITS
	move.w	(a0)+,CIRCLE_BITS
	move.w	(a0)+,BOX1_BITS
	move.w	(a0)+,BOX2_BITS
	move.w	(a0)+,FILL_BITS
	move.w	(a0)+,AIR_BITS
	move.w	(a0)+,REPL_BITS
	move.w	(a0)+,CUT_BITS
	move.w	(a0)+,PASTE_BITS
	move.w	(a0)+,REMAP_BITS
	move.w	(a0)+,DSIZE_BITS
	move.w	(a0)+,PIP_BITS
	move.w	(a0)+,EXP_BITS
	move.w	(a0)+,ANI_BITS
	move.w	(a0)+,FILM_BITS
	move.w	(a0)+,VIEW_BITS
	move.w	(a0)+,OPER_BITS
	move.w	(a0)+,ENAB_BITS
	move.w	(a0)+,MORPH1_BITS
	move.w	(a0)+,MORPH2_BITS
	move.w	(a0)+,RGB_BITS
	move.w	(a0)+,PCK_BITS
	move.w	(a0)+,TWEEN_BITS
	move.w	(a0)+,DISKFLAG_BITS
	move.w	(a0)+,DISKOP_BITS
	move.w	(a0)+,REDUCE_BITS
	move.w	(a0)+,DISKTYP1_BITS
	move.w	(a0)+,RES_BITS
	move.w	(a0)+,BCOL_BITS
	move.w	(a0)+,VCOL_BITS
	move.w	(a0)+,DIAL_BITS
	move.w	(a0)+,IFACE_BITS
	move.w	(a0)+,HANDLE_BITS
	move.w	(a0)+,PROC_BITS
	move.w	(a0)+,SCALER_BITS
	move.w	(a0)+,SCALER2_BITS
	move.w	(a0)+,COMP_BITS
	move.w	(a0)+,FLAG_BITS
	move.w	(a0)+,exposure
	move.w	(a0)+,shifter
*-----------------------------------------------------*
	move.l	PHYS_SIZE,d0
	divu.l	#5,d0
	tst.b		VGA_FLAG
	bne.s		.vg
	move.l	d0,d1
	lsr.l		#2,d1
	sub.l		d1,d0
.vg	add.l		PHYS_SIZE,d0
	move.l	d0,SCREEN_SIZE
	rts

*-----------------------------------------------------*
write_prefs:
*-----------------------------------------------------*
	lea		prefs_start,a0
*-----------------------------------------------------*
	move.w	NEW_MODECODE,(a0)+
	move.l	PHYS_SIZE,(a0)+	
	move.l	CANVAS_SIZE,(a0)+		
	move.w	X_RESOLUTION,(a0)+
	move.w	Y_RESOLUTION,(a0)+
	move.w	VIDEO_WIDTH,(a0)+
	move.w	VIDEO_HEIGHT,(a0)+
	move.w	CANVAS_WIDTH,(a0)+
	move.w	CANVAS_HEIGHT,(a0)+
	move.w	physwid,(a0)+
	move.w	logwid,(a0)+
	move.w	x_factor,(a0)+
	move.w	y_factor,(a0)+
	move.w	textgap,(a0)+
	move.w	MATCODE,(a0)+
	move.w	COLSHIFT,(a0)+
	move.l	COLMASK,(a0)+
	move.l	SIZE_VAL,(a0)+
	move.l	SPACE_VAL,(a0)+
	move.l	SMOOTH_VAL,(a0)+
	move.l	CANWID_VAL,(a0)+
	move.l	CANHIG_VAL,(a0)+
	move.l	scaler,(a0)+
	move.w	cfnxgap2,(a0)+
	move.w	cfnsmooth,(a0)+
	move.l	REDUCE_VAL,(a0)+
	move.w	colours_needed,(a0)+
*-----------------------------------------------------*
	move.b	TRUE_FLAG,(a0)+
	move.b	EXTEND,(a0)+
	move.b	gensol,(a0)+
	move.b	ACCEL,(a0)+
	move.b	LARGE_HANDLES,(a0)+
	move.b	killspin,(a0)+
	move.b	heavycomp,(a0)+
	addq.l	#1,a0
*-----------------------------------------------------*
	move.w	CURRENT_HUE1POS,(a0)+
	move.w	CURRENT_SAT1POS,(a0)+
	move.w	CURRENT_BRI1POS,(a0)+
	move.w	CURRENT_HUE2POS,(a0)+
	move.w	CURRENT_SAT2POS,(a0)+
	move.w	CURRENT_BRI2POS,(a0)+
	move.w	CURRENT_AIRSIZE,(a0)+
	move.w	CURRENT_AIRFLOW,(a0)+
	move.w	CURRENT_VALPOS,(a0)+
	move.w	CURRENT_TIME,(a0)+
	move.w	LAST_AIRSIZE,(a0)+
	move.w	AIRBRUSH_SIZE,(a0)+
	move.w	AIRBRUSH_FLOW,(a0)+
	move.w	NAIR_SIZE,(a0)+
	move.w	CURRENT_MTHRESH,(a0)+
*-----------------------------------------------------*
	move.w	BTYPE_BITS,(a0)+
	move.w	DRAW_BITS,(a0)+
	move.w	LINE_BITS,(a0)+
	move.w	CURVE_BITS,(a0)+
	move.w	POLY_BITS,(a0)+
	move.w	CIRCLE_BITS,(a0)+
	move.w	BOX1_BITS,(a0)+
	move.w	BOX2_BITS,(a0)+
	move.w	FILL_BITS,(a0)+
	move.w	AIR_BITS,(a0)+
	move.w	REPL_BITS,(a0)+
	move.w	CUT_BITS,(a0)+
	move.w	PASTE_BITS,(a0)+
	move.w	REMAP_BITS,(a0)+
	move.w	DSIZE_BITS,(a0)+
	move.w	PIP_BITS,(a0)+
	move.w	EXP_BITS,(a0)+
	move.w	ANI_BITS,(a0)+
	move.w	FILM_BITS,(a0)+
	move.w	VIEW_BITS,(a0)+
	move.w	OPER_BITS,(a0)+
	move.w	ENAB_BITS,(a0)+
	move.w	MORPH1_BITS,(a0)+
	move.w	MORPH2_BITS,(a0)+
	move.w	RGB_BITS,(a0)+
	move.w	PCK_BITS,(a0)+
	move.w	TWEEN_BITS,(a0)+
	move.w	DISKFLAG_BITS,(a0)+
	move.w	DISKOP_BITS,(a0)+
	move.w	REDUCE_BITS,(a0)+
	move.w	DISKTYP1_BITS,(a0)+
	move.w	RES_BITS,(a0)+
	move.w	BCOL_BITS,(a0)+
	move.w	VCOL_BITS,(a0)+
	move.w	DIAL_BITS,(a0)+
	move.w	IFACE_BITS,(a0)+
	move.w	HANDLE_BITS,(a0)+
	move.w	PROC_BITS,(a0)+
	move.w	SCALER_BITS,(a0)+
	move.w	SCALER2_BITS,(a0)+
	move.w	COMP_BITS,(a0)+
	move.w	FLAG_BITS,(a0)+
	move.w	exposure,(a0)+
	move.w	shifter,(a0)+
*-----------------------------------------------------*
	move.l	#prefs_name,sysfile_name
	move.l	#prefs_start,sysfile_ptr
	move.l	#prefs_end-prefs_start,sysfile_size
	jsr		WRITE_SYSFILE
;	jsr		store_video
	rts
		
prefs_name:	dc.b	'apex.cfg'
		even
		
*-----------------------------------------------------*
*	Video variables						*
*-----------------------------------------------------*

prefs_start:

mode_p		dc.w	bpl8
phys_size_p		dc.l	phys_width*200
canvas_size_p	dc.l	phys_width*200
x_resolution_p	dc.w	phys_width
y_resolution_p	dc.w	200
video_width_p	dc.w	phys_width
video_height_p	dc.w	200
canvas_width_p	dc.w	phys_width
canvas_height_p	dc.w	200
physwid_p		dc.w	phys_width
logwid_p		dc.w	phys_width
x_factor_p		dc.w	1
y_factor_p		dc.w	1
textgap_p		dc.w	6
matcode_p		dc.w	6
colshift_p		dc.w	1<<2
colmask_p		dc.l	%111111001111110011111100
sizeval_p		dc.l	50
spaceval_p		dc.l	100
smoothval_p		dc.l	20
canwidval_p		dc.l	320
canhigval_p		dc.l	200
scaler_p		dc.l	50
cfnxgap2_p		dc.w	100
cfnsmooth_p		dc.w	20
colsneedval_p	dc.l	256
colsneed_p		dc.w	256
true_flag_p		dc.b	0
extend_p		dc.b	0
gensol_p		dc.b	0
accel_p		dc.b	0
handles_p		dc.b	1
killspin_p		dc.b	0
heavycomp_p		dc.b	0
			dc.b	0

*-----------------------------------------------------*
*	General variables						*
*-----------------------------------------------------*

current_hue1pos_p	dc.w	64
current_sat1pos_p	dc.w	128
current_bri1pos_p	dc.w	255
current_hue2pos_p	dc.w	128
current_sat2pos_p	dc.w	128
current_bri2pos_p	dc.w	128
current_airsize_p	dc.w	20
current_airflow_p	dc.w	20
current_valpos_p	dc.w	128
current_time_p	dc.w	0
last_airsize_p	dc.w	20
airbrush_size_p	dc.w	20
airbrush_flow_p	dc.w	20
nair_size_p		dc.w	4

current_mthresh_p	dc.w	512

*-----------------------------------------------------*
*	General variables						*
*-----------------------------------------------------*

btype_p		dc.w	1<<Bit_BTYPE_NORM
draw_p		dc.w	1<<Bit_DRAW_NORM
line_p		dc.w	1<<Bit_LINE_NORM
curve_p		dc.w	1<<Bit_CURVE_BEZIER
poly_p		dc.w	1<<Bit_POLY_SOLID
circle_p		dc.w	1<<Bit_CIRCLE_SOLID
box1_p		dc.w	0
box2_p		dc.w	1<<Bit_BOX2_SOLID
fill_p		dc.w	1<<Bit_FILL_SOLID
air_p			dc.w	1<<Bit_AIR_CTRL
repl_p		dc.w	1<<Bit_REPL_NRM
cut_p			dc.w	1<<Bit_CUT_RECT
paste_p		dc.w	1<<Bit_PASTE_XRAY
remap_p		dc.w	1<<Bit_REMAP_BLOCK
dsize_p		dc.w	1<<Bit_DSIZE_N512
pip_p			dc.w	0
exp_p			dc.w	1<<Bit_EXP_FAST
ani_p			dc.w	1<<Bit_ANI_A128
film_p		dc.w	0
view_p		dc.w	0
oper_p		dc.w	1<<Bit_OPER_WASH
enab_p		dc.w	1<<Bit_ENAB_HUE
morph1_p		dc.w	1<<Bit_MORPH1_PICTURE
morph2_p		dc.w	1<<Bit_MORPH2_DISTORT
rgb_p			dc.w	1<<Bit_RGB_HSV
pck_p			dc.w	1<<Bit_PCK_HSV
tween_p		dc.w	0
diskflag_p		dc.w	1<<Bit_DISKFLAG_NEWCOL
diskop_p		dc.w	1<<Bit_DISKOP_REPLACE
reduce_p		dc.w	1<<Bit_REDUCE_SPAC
disktyp1_p		dc.w	1<<Bit_DISKTYP1_FLI
res_p			dc.w	1<<Bit_RES_LOW
bcol_p		dc.w	1<<Bit_BCOL_BIT18
vcol_p		dc.w	1<<Bit_VCOL_COL256
dial_p		dc.w	1<<Bit_DIAL_CYB
iface_p		dc.w	1<<Bit_IFACE_PROT
handle_p		dc.w	1<<Bit_HANDLE_LARGE
proc_p		dc.w	1<<Bit_PROC_STD
scalertype_p	dc.w	1<<Bit_SCALER_FINE
scaler2_p		dc.w	1<<Bit_SCALER2_KEEP
comp_p		dc.w	1<<Bit_COMP_SKIP
flag_p		dc.w	1<<Bit_FLAG_BYTEPIXEL
exposure_p		dc.w	0
shifter_p		dc.w	0

prefs_end:

*-----------------------------------------------------*

