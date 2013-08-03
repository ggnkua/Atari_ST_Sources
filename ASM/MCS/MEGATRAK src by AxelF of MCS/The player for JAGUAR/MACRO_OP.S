;
;
;	MACROS
;
;


*-----------------------------------------------------------------------------------------------

; DEFINITION D'UN OBJET DE L'OBJECT-LIST



		offset  0
o_id:		ds.w	1	; Bitmap object structure
obt_data:	ds.l	1
obt_dwidth:	ds.w	1
obt_iwidth:	ds.w	1
obt_height:	ds.w	1
obt_firstpix:	ds.w	1
obt_depth:	ds.l	1
obt_flags:	ds.l	1
obt_xpos:	ds.w	1
obt_ypos:	ds.w	1
obt_link:	ds.l	1
obt_vscale:	ds.b	1
obt_hscale:	ds.b	1

		offset  0
		ds.w	1	; Stop object structure
ost_flag:	ds.w	1
ost_data_lo:	ds.l	1
ost_data_hi:	ds.l	1

		offset  0
		ds.w	1	; GPU object structure
ogpu_data_l0:	ds.w	1
ogpu_data_l1:	ds.w	1
ogpu_data_hi:	ds.l	1

		offset  0
		ds.w	1	; Branch object structure
obr_ypos:	ds.w	1
obr_cc:		ds.l	1
obr_link:	ds.l	1



macro		obj_bitmap data,dwidth,iwidth,height,firstpix,depth,flags,xpos,ypos,link
		dc.w	BITOBJ
		dc.l	\data
		dc.w	\dwidth
		dc.w	\iwidth
		dc.w	\height
		dc.w	\firstpix
		dc.l	\depth
		dc.l	\flags
		dc.w	\xpos
		dc.w	\ypos
		dc.l	\link
endm


macro		obj_scbitmap data,dwidth,iwidth,height,firstpix,depth,flags,xpos,ypos,link,vscale,hscale
		dc.w	SCBITOBJ
		dc.l	\data
		dc.w	\dwidth
		dc.w	\iwidth
		dc.w	\height
		dc.w	\firstpix
		dc.l	\depth
		dc.l	\flags
		dc.w	\xpos
		dc.w	\ypos
		dc.l	\link
		dc.b	\vscale
		dc.b	\hscale
endm

macro		obj_branch ypos,cc,link
		dc.w	BRANCHOBJ
		dc.w	\ypos
		dc.l	\cc
		dc.l	\link
endm

macro		obj_stop flag,data_lo,data_hi
		dc.w	STOPOBJ
		dc.w	\flag
		dc.l	\data_lo
		dc.l	\data_hi
endm


macro		obj_gpu	data_l0,data_l1,data_hi
		dc.w	GPUOBJ
		dc.w	\data_l0
	   	dc.w	\data_l1
		dc.l	\data_hi
endm


macro		obj_goto link
		dc.w	BRANCHOBJ
		dc.w	$7FF
		dc.l	O_BREQ
		dc.l	\link
endm

macro		obj_nop
		dc.w	BRANCHOBJ
		dc.w	$7FF
		dc.l	O_BRLT
		dc.l	0
endm



*-----------------------------------------------------------------------------------------------

; Structure UPDATE

		offset 0
upd_type:	ds.w 1
upd_actif:	ds.w 1
upd_objet:	ds.l 1		
upd_width:	ds.w 1
upd_vscale:	ds.b 1
upd_hscale:	ds.b 1
upd_data:	ds.l 1
upd_xpos:	ds.w 1
upd_ypos:	ds.w 1
upd_height:	ds.w 1
upd_iwidth:	ds.w 1
upd_flg_upd:	ds.w 1
upd_firstpix:	ds.w 1
upd_flags:	ds.l 1
upd_size:	ds.w 0




macro		upd_bitmap objet,data,height,xpos,ypos,iwidth,width,firstpix,index,flags
		dc.w	1,0
		dc.l	\objet
		dc.w	\width
		dc.w	0
		dc.l	\data
		dc.w	\xpos
		dc.w	\ypos
		dc.w	\height
		dc.w	\iwidth
		dc.w	\index<<1+1
		dc.w	\firstpix
		dc.l	\flags
endm

macro		upd_scbitmap objet,data,height,xpos,ypos,iwidth,width,firstpix,index,flags,vscale,hscale
		dc.w	2,0
		dc.l	\objet
		dc.w	\width
		dc.b	\vscale
		dc.b	\hscale
		dc.l	\data
		dc.w	\xpos
		dc.w	\ypos
		dc.w	\height
		dc.w	\iwidth
		dc.w	\index<<1+1
		dc.w	\firstpix
		dc.l	\flags
endm


macro		upd_bitmap_no_upd objet,data,height,xpos,ypos,iwidth,width,firstpix,index,flags
		dc.w	1,0
		dc.l	\objet
		dc.w	\width
		dc.w	0
		dc.l	\data
		dc.w	\xpos
		dc.w	\ypos
		dc.w	\height
		dc.w	\iwidth
		dc.w	\index<<1
		dc.w	\firstpix
		dc.l	\flags
endm


*-----------------------------------------------------------------------------------------------

; offsets blitter

		offset	1	; BLITTER offset
o_a1_flags:	ds.b	1
o_a1_clip:	ds.b	1
o_a1_pixel:	ds.b	1
o_a1_step:	ds.b	1
o_a1_fstep:	ds.b	1
o_a1_fpixel:	ds.b	1
o_a1_inc:	ds.b	1
o_a1_finc:	ds.b	1
o_a2_base:	ds.b	1
o_a2_flags:	ds.b	1
o_a2_mask:	ds.b	1
o_a2_pixel:	ds.b	1
o_a2_step:	ds.b	1
o_b_cmd:	ds.b	1
o_b_count:	ds.b	1
o_b_srcd:	ds.b	2
o_b_dstd:	ds.b	2
o_b_dstz:	ds.b	2
o_b_srcz1:	ds.b	2
o_b_srcz2:	ds.b	2
o_b_patd:	ds.b	2
o_b_iinc:	ds.b	1
o_b_zinc:	ds.b	1
o_b_stop:	ds.b	1

