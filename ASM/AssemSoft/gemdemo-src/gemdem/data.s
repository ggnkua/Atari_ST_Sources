		data
		
small_rsc	dc.b "gemdem.rsc",0
big_rsc		dc.b "gemdem.rsc",0
	
mtask_name	dc.b "  GemDemo ",0
myname		dc.b "GEMDEMO",0

wt_settings	dc.b "GemDemo Options",0
wti_settings	dc.b "GD Opts",0
wt_about	dc.b "About GemDemo",0
wti_about	dc.b "AboutGD",0
wt_adj		dc.b "                                ",0
wti_adj		dc.b "Adjust",0
wt_stats	dc.b "GemDemo Stats",0
wti_stats	dc.b "Stats",0
null_str	dc.b 0
no_memalrt	dc.b "[3][ Not enough memory!! ][ Exit ]",0

outp_vdi	dc.b "VDI",0
outp_direct	dc.b "Direct",0
mclp_on		dc.b "Clipping On",0
mclp_off	dc.b "Clipping Off",0
clip_on		dc.b "On",0
clip_off	dc.b "Off",0
 
		;     0123456789x123456789x123456789x

gd_id		dc.b 'GEM Demo Executable',0

vslot_unused	dc.b "Unused",0
vslot_zero	dc.b "0",0

afps_updflag	dc.b %1111	;Bit

afps_real	ds.b 20
afps_average	ds.b 20
afps_updates	ds.b 20
afps_seconds	ds.b 20

number		ds.b 20

outp_flag	dc.b 0
gfxmode		dc.b 0
clipping	dc.b -1

;==	
		even
About		ds.l 1
		ds.w 1
		dc.w 0
		dc.l 0

	;Here starts module structures
		dc.l 0
	
Settings	ds.l 1		;Root object addr
		ds.w 1		;Index of root obj
		dc.w 0		;Reserved
		dc.l 0		;Reserved
	
	;Here starts module structures
		dc.l 0		


Adjust		ds.l 1		;Root object addr
		ds.w 1		;Index of root obj
		dc.w 0		;Reserved
		dc.l 0		;Reserved
	
	;Here starts module structures
		dc.l 0		

Stats		ds.l 1		;Root object addr
		ds.w 1		;Index of root obj
		dc.w 0		;Reserved
		dc.l 0		;Reserved
	
	;Here starts module structures
		dc.l 0		

Loading		ds.l 1		;Root object addr
		ds.w 1		;Index of root obj
		dc.w 0		;Reserved
		dc.l 0		;Reserved
	
	;Here starts module structures
		dc.l 0		

;colsel_pop	dc.w 0			;pu_tree
;		dc.w COLSEL		;pu_ootind
;		dc.w 0			;pu_index
;		dc.w 1			;1st obj
;		dc.w 16			;last obj
;		dc.w (1<<put_border)	;type
;		dc.w 0			;Flags
;		dc.w 0			;orient
;		dc.l 0			;param
;colsel_pop1
;		ds.b pu_ssize-(colsel_pop1-colsel_pop)

zoom_pop	dc.w 0			;pu_tree
		dc.w ZOOMPOP		;pu_rootind
		dc.w 0			;pu_index
		dc.w P1_ZOOM1X		;1st obj
		dc.w P1_ZOOM4X		;last obj
		dc.w (1<<put_select)	;Type
		dc.w 0			;Flags
		dc.w (1<<puo_currentx)+(1<<puo_currenty) ;Orient
		dc.l (1<<OS_SELECTED)	;Params
zoom_pop1
		ds.b pu_ssize-(zoom_pop1-zoom_pop)
	
	

adjv_font	dc.w 1
		dc.w 8
		dc.w 1
		dc.w 0
	

adjv		rsset 0
adjv_fghandle	rs.w 1
adjv_demo	rs.l 1
		dc.b __RS
	
adjv_before	dc.l 0
adjv_after	dc.l textframe_moved
		dc.l 0

dial_mods	dc.l 0

demo_init	ds.b di_ssize

		even
demoes:		dc.l 0

		;dcb.b dpb_ssize*numberof_demoes,0

		data

		even

;144*100
demo_mfdb	dc.l screen_buffer
		dc.w 144
		dc.w 100
		dc.w (144+15)/16
		dc.w 1
		dc.w 16
		dc.w 0
		dc.w 0
		dc.w 0
		dc.w 0

		bss
misc_mfdb	ds.b MFDB_ssize

Hz50_reloc:	ds.l 1
	
demdir_end	ds.w 1
demo_cfile	ds.b 200+64+2
demo_dir	ds.b 200
demo_files	ds.b 64*11

		even
screen_buffer	ds.w (144*4)*(100*4)

