
* Macro library to call AES & VDI
* Copyright (c) HiSoft 1988

* 31.5.88	fixed appl_read,appl_write,graf_slidebox
* 2.6.88	fixed evnt_multi
* 11.9.88	v_contour_fill corrected (to v_contourfill)
* 25.10.89	vswr_mode fixed (intint typo), added TOS 1.4 AES calls
*		fsel_exinput, wind_new. Added shel_get/put
* 1.5.90	Added form_button/form_keybd
* 29.3.93	AES Additions for Falcon TOS & MultiToS
* 30.4.93	Additions for Speedo & FontGDOS
***********AES Macros******************

* macro to call a given AES routine
aes	macro	aes_number
	XREF	CALL_AES,int_in,addr_in,int_out,addr_out,current_handle
	moveq	#\1,d0
	bsr.l	CALL_AES
	endm
*	may need to change BSR CALL_AES to JSR for large programs

aes_long macro	aes_number
	XREF	CALL_AES,int_in,addr_in,int_out,addr_out,current_handle
	move.w	#\1,d0
	bsr.l	CALL_AES
	endm

appl_init	macro
	aes	10
	endm

appl_read	macro	id,length,buff
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	\3,addr_in
	aes	11
	endm

appl_write	macro	id,length,buffer
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	\3,addr_in
	aes	12
	endm

appl_find	macro	name
	move.l	\1,addr_in
	aes	13
	endm

appl_tplay	macro	mem,num,scale
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	14
	endm

appl_trecord	macro	mem,count
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	15
	endm

appl_search	macro	mode,name
	move.w	\1,int_in
	move.l	\2,addr_in
	aes	18
	endm
	
appl_getinfo	macro	type
	move.w	\1,int_in
	aes_long	130
	endm
appl_exit	macro
	aes	19
	endm

evnt_keybd	macro
	aes	20
	endm

evnt_button	macro	clicks,mask,state
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	aes	21
	endm

evnt_mouse	macro	flags,x,y,w,h
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	aes	22
	endm

evnt_mesag	macro	buffer
	move.l	\1,addr_in
	aes	23
	endm

evnt_timer	macro	longcount
	move.l	\1,d0
	swap	d0
	move.l	d0,int_in
	aes	24
	endm

evnt_multi	macro	flags[,lots]
	move.w	\1,int_in
	IFNC	'\2',''
	move.w	\2,int_in+2
	ENDC
	IFNC	'\3',''
	move.w	\3,int_in+4
	ENDC
	IFNC	'\4',''
	move.w	\4,int_in+6
	ENDC
	IFNC	'\5',''
	move.w	\5,int_in+8
	ENDC
	IFNC	'\6',''
	move.w	\6,int_in+10
	ENDC
	IFNC	'\7',''
	move.w	\7,int_in+12
	ENDC
	IFNC	'\8',''
	move.w	\8,int_in+14
	ENDC
	IFNC	'\9',''
	move.w	\9,int_in+16
	ENDC
	IFNC	'\A',''
	move.w	\A,int_in+18
	ENDC
	IFNC	'\B',''
	move.w	\B,int_in+20
	ENDC
	IFNC	'\C',''
	move.w	\C,int_in+22
	ENDC
	IFNC	'\D',''
	move.w	\D,int_in+24
	ENDC
	IFNC	'\E',''
	move.w	\E,int_in+26
	ENDC
	IFNC	'\F',''
	move.l	\F,addr_in
	ENDC
	IFNC	'\G',''
	move.l	\G,d0
	swap	d0
	move.l	d0,int_in+28
	ENDC
	aes	25
	endm

evnt_dclick	macro	new,getset
	move.w	\1,int_in
	move.w	\2,int_in+2
	aes	26
	endm

menu_bar	macro	tree,show
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	30
	endm

menu_icheck	macro	tree,item,check
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	31
	endm

menu_ienable	macro	tree,item,enable
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	32
	endm

menu_tnormal	macro	tree,title,normal
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	33
	endm

menu_text	macro	tree,item,text
	move.l	\1,addr_in
	move.w	\2,int_in
	move.l	\3,addr_in+4
	aes	34
	endm

menu_register	macro	id,string
	move.w	\1,int_in
	move.l	\2,addr_in
	aes	35
	endm

menu_popup	macro	menu,xpos,ypos,mdata
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.l	\4,addr_in+4
	aes 36
	endm

menu_attach	macro	flag,tree,item,mdata
	move.w	\1,int_in
	move.l	\2,addr_in
	move.w	\3,int_in+2
	move.l	\4,addr_in+4
	aes	37
	endm

menu_istart	macro	flag,tree,imenu,item
	move.w	\1,int_in
	move.l	\2,addr_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	aes	38
	endm


menu_settings	macro	flag,values
	move.l	\1,int_in
	move.l	\2,addr_in
	aes	39
	endm

objc_add	macro	tree,parent,child
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	40
	endm

objc_delete	macro	tree,object
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	41
	endm

objc_draw	macro	tree,startob,depth,x,y,w,h
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.w	\5,int_in+6
	move.w	\6,int_in+8
	move.w	\7,int_in+10
	aes	42
	endm

objc_find	macro	tree,startob,depth,x,y
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.w	\5,int_in+6
	aes	43
	endm

objc_offset	macro	tree,object
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	44
	endm

objc_order	macro	tree,object,newpos
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	45
	endm

objc_edit	macro	tree,object,char,idx,kind
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	move.w	\5,int_in+6
	aes	46
	endm

objc_change	macro	tree,object,x,y,w,h,new,redraw
	move.l	\1,addr_in
	move.w	\2,int_in
	clr.w	int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	aes	47
	endm

objc_sysvar	macro	mode,which,val1,val2
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_int+6
	aes	48
	endm


form_do	macro	tree,startob
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	50
	endm

form_dial	macro	flag,x,y,w,h,x2,y2,w2,h2
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	move.w	\9,int_in+16
	aes	51
	endm

form_alert	macro	button,string
	move.w	\1,int_in
	move.l	\2,addr_in
	aes	52
	endm

form_error	macro	errnum
	move.w	\1,int_in
	aes	53
	endm

form_center	macro	tree
	move.l	\1,addr_in
	aes	54
	endm

form_keybd	macro	form,obj,nxt_obj,thechar
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	aes	55
	endm

form_button	macro	tree,object,clks
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	aes	56
	endm

graf_rubberbox	macro	x,y,w,h
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	aes	70
	endm
	
graf_dragbox	macro	w,h,x,y,bx,bh,bw,bh
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	aes	71
	endm

graf_movebox	macro	w,h,x,y,dx,dy
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	aes	72
	endm

graf_growbox	macro	x,y,w,h,fx,fy,fw,fh
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	aes	73
	endm

graf_shrinkbox	macro	x,y,w,h,sx,sy,sw,sh
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	move.w	\7,int_in+12
	move.w	\8,int_in+14
	aes	74
	endm

graf_watchbox	macro	tree,object,instate,outstate
	clr.w	int_in
	move.l	\1,addr_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	aes	75
	endm

graf_slidebox	macro	tree,parent,obj,vh
	move.l	\1,addr_in
	move.w	\2,int_in
	move.w	\3,int_in+2
	move.w	\4,int_in+4
	aes	76
	endm

graf_handle	macro
	aes	77
	endm

graf_mouse	macro	num<,addr>
	move.w	\1,int_in
	IFNC	'\2',''
	move.l	\2,addr_in
	ENDC
	aes	78
	endm

graf_mkstate	macro
	aes	79
	endm

scrp_read	macro	scrap
	move.l	\1,addr_in
	aes	80
	endm

scrp_write	macro	scrap
	move.l	\1,addr_in
	aes	81
	endm

fsel_input	macro	path,filename
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	aes	90
	endm

fsel_exinput	macro	path,filename,label
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	move.l	\3,addr_in+8		needs bigger addr_in than before!
	aes	91
	endm
	
wind_create	macro	kind,x,y,w,h
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	aes	100
	endm

wind_open	macro	handle,x,y,w,h
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	aes	101
	endm

wind_close	macro	handle
	move.w	\1,int_in
	aes	102
	endm

wind_delete	macro	handle
	move.w	\1,int_in
	aes	103
	endm

wind_get	macro	handle,field[,in1,in2,in3,in4]
	move.w	\1,int_in
	move.w	\2,int_in+2
	IFNC	'\3',''
	move.w	\3,int_in+4
	ENDC
	IFNC	'\4',''
	move.w	\4,int_in+6
	ENDC
	IFNC	'\5',''
	move.w	\5,int_in+8
	ENDC
	IFNC	'\6',''
	move.w	\6,int_in+10
	ENDC

	aes	104
	endm

wind_set	macro	handle,field
	move.w	\1,int_in
	move.w	\2,int_in+2
	aes	105
	endm

wind_find	macro	x,y
	move.w	\1,int_in
	move.w	\2,int_in+2
	aes	106
	endm

wind_update	macro	begend
	move.w	\1,int_in
	aes	107
	endm

wind_calc	macro	type,kind,inx,iny,inw,inh
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.w	\4,int_in+6
	move.w	\5,int_in+8
	move.w	\6,int_in+10
	aes	108
	endm

wind_new	macro
	aes	109
	endm

rsrc_load	macro	name
	move.l	\1,addr_in
	aes	110
	endm

rsrc_free	macro
	aes	111
	endm

rsrc_gaddr	macro	type,index
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	#112<<16+2,control
	move.l	#1<<16,control+4
	move.w	#1,control+8		unique!
	move.l	#aes_params,d1
	move.w	#200,d0
	trap	#2
	move.w	int_out,d0
	endm

rsrc_saddr	macro	type,index,saddr
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.l	\3,addr_in
	aes	113
	endm

rsrc_obfix	macro	tree,object
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	114
	endm

rsrc_rcfix	macro	header
	move.l	\1,addr_in
	aes	115
	endm

shel_read	macro	command,shell
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	aes	120
	endm

shel_write	macro	doex,sgr,scr,cmd,shell
	move.w	\1,int_in
	move.w	\2,int_in+2
	move.w	\3,int_in+4
	move.l	\4,addr_in
	move.l	\5,addr_in+4
	aes	121
	endm

shel_get	macro	buffer,length
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	122
	endm

shel_put	macro	buffer,length
	move.l	\1,addr_in
	move.w	\2,int_in
	aes	123
	endm

shel_find	macro	buffer
	move.l	\1,addr_in
	aes	124
	endm

shel_envrn	macro	value,string
	move.l	\1,addr_in
	move.l	\2,addr_in+4
	aes	125
	endm


*********** END OF AES *************


*********** VDI MACROS *************

* conditional macro definition(!) to call vdi routine
	IFGT	__LK
callvdi	macro	vdiname
	XREF	\1,contrl,contrl1,contrl3
	XREF	intin,ptsin,intout,ptsout,vdi_params
	BSR.l	\1
	endm
	ELSEIF
callvdi	macro	vdiname
	BSR.l	\1
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
	
v_contourfill	macro	x,y,index
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,intin
	callvdi	v_contourfill
	endm

vr_recfl	macro	x1,y1,x2,y2
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	vr_recfl
	endm

v_bar	macro	x1,y1,x2,y2
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	v_bar
	endm

v_arc	macro	x,y,rad,start,end
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+12
	moev.w	\4,intin
	move.w	\5,intin+2
	callvdi	v_arc
	endm

v_pieslice	macro	x,y,rad,start,end
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+12
	moev.w	\4,intin
	move.w	\5,intin+2
	callvdi	v_pieslice
	endm

v_circle	macro	x,y,rad
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+8
	callvdi	v_circle
	endm

v_ellarc	macro	x,y,xr,yr,start,end
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	move.w	\5,intin
	move.w	\6,intin+2
	callvdi	v_ellarc
	endm

v_ellpie	macro	x,y,xr,yr,start,end
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	move.w	\5,intin
	move.w	\6,intin+2
	callvdi	v_ellpie
	endm

v_ellipse	macro	x,y,xr,yr
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	v_ellipse
	endm

v_rbox	macro	x1,y1,x2,y2
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	v_rbox
	endm

v_rfbox	macro	x1,y1,x2,y2
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\3,ptsin+4
	move.w	\4,ptsin+6
	callvdi	v_rfbox
	endm

v_justified	macro	x,y,string,length,ws,cs
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.w	\4,ptsin+4
	move.w	\5,intin
	move.w	\6,intin+2
	move.l	\3,a0
	callvdi	v_justified
	endm

vswr_mode	macro	mode
	move.w	\1,intin
	callvdi	vswr_mode
	endm

vs_color	macro	index,read,green,blue
	move.w	\1,intin
	move.w	\2,intin+2
	move.w	\3,intin+4
	move.w	\4,intin+6
	callvdi	vs_color
	endm

vsl_type	macro	style
	move.w	\1,intin
	callvdi	vsl_type
	endm

vsl_udsty	macro	pattern
	move.w	\1,intin
	callvdi	vsl_udsty
	endm

vsl_width	macro	width
	move.w	\1,ptsin
	callvdi	vsl_width
	endm

vsl_color	macro	index
	move.w	\1,intin
	callvdi	vsl_color
	endm

vsl_ends	macro	beg,end
	move.w	\1,intin
	move.w	\2,intin+2
	callvdi	vsl_ends
	endm

vsm_type	macro	symbol
	move.w	\1,intin
	callvdi	vsm_type
	endm

vsm_height	macro	height
	move.w	\1,ptsin+2
	callvdi	vsm_height
	endm

vsm_color	macro	index
	move.w	\1,intin
	callvdi	vsm_color
	endm

vst_height	macro	height
	move.w	\1,ptsin+2
	callvdi	vst_height
	endm

vst_point	macro	point
	move.w	\1,intin
	callvdi	vst_point
	endm

vst_rotation	macro	angle
	move.w	\1,intin
	callvdi	vst_rotation
	endm

vst_font	macro	font
	move.w	\1,intin
	callvdi	vst_font
	endm

vst_color	macro	index
	move.w	\1,intin
	callvdi	vst_color
	endm

vst_effects	macro	effect
	move.w	\1,intin
	callvdi	vst_effects
	endm

vst_alignment	macro	hor,vert
	move.w	\1,intin
	move.w	\2,intin+2
	callvdi	vst_alignment
	endm

vsf_interior	macro	style
	move.w	\1,intin
	callvdi	vsf_interior
	endm

vsf_style	macro	index
	move.w	\1,intin
	callvdi	vsf_style
	endm

vsf_color	macro	index
	move.w	\1,intin
	callvdi	vsf_color
	endm

vsf_perimeter	macro	vis
	move.w	\1,intin
	callvdi	vsf_perimeter
	endm

vsf_updat	macro
	callvdi	vsf_updat
	endm

vro_cpyfm	macro	mode,sourceMFDB,destMFDB
	move.w	\1,intin
	move.l	\2,contrl+14
	move.l	\3,contrl+18
	callvdi	vro_cpyfm
	endm

vrt_cpyfm	macro	mode,sourceMFDB,destMFDB,index1,index2
	move.w	\1,intin
	move.l	\2,contrl+14
	move.l	\3,contrl+18
	move.w	\4,intin+2
	move.w	\5,intin+4
	callvdi	vrt_cpyfm
	endm

vr_trnfm	macro	source,dest
	move.l	\1,contrl+14
	move.l	\2,contrl+18
	callvdi	vr_trnfm
	endm

v_get_pixel	macro	x,y
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	callvdi	v_get_pixel
	endm

vex_timv	macro	newtimer
	move.l	\1,contrl+14
	callvdi	vex_timv
	endm

v_show_c	macro	reset
	move.w	\1,intin
	callvdi	v_show_c
	endm

v_hide_c	macro
	callvdi	v_hide_c
	endm

vq_mouse	macro
	callvdi	vq_mouse
	endm

vex_butv	macro	newxbut
	move.l	\1,contrl+14
	callvdi	vex_butv
	endm

vex_motv	macro	newmov
	move.l	\1,contrl+14
	callvdi	vex_motv
	endm

vex_curv	macro	newcursor
	move.l	\1,contrl+14
	callvdi	vex_curv
	endm

vq_key_s	macro
	callvdi	vq_key_s
	endm

vq_extnd	macro	flag
	move.w	\1,intin
	callvdi	vq_extnd
	endm

vq_color	macro	index,flag
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

vqt_extent	macro	string
	move.l	\1,a0
	callvdi	vqt_extent
	endm

vqt_width	macro	char
	move.w	\1,intin
	callvdi	vqt_width
	endm

vqt_name	macro	number
	move.w	\1,intin
	callvdi	vqt_name
	endm

vqt_fontinfo	macro
	callvdi	vqt_fontinfo
	endm

v_bez_on	macro
	callvdi	v_bez_on
	endm

v_bez_off	macro
	callvdi	v_bez_off
	endm

v_set_app_buff	macro address,nparas
	move.l	\1,d0
	swap	d0
	move.l	d0,intin
	move.w	\2,intin+4
	callvdi	v_set_app_buff
	endm

v_bez	macro	count
	move.w	\1,d0
	callvdi	v_bez
	endm

v_bez_fill	macro	count
	move.w	\1,d0
	callvdi	v_bez_fill
	endm

v_bez_qual	macro percent
	move.w	\1,intin+4
	callvdi	v_bez_qual
	endm

vqt_fontheader	macro	buffer
	move.l	\1,intin
	callvdi	vqt_fontheader
	endm	
	
vqt_trackkern	macro
	callvdi	vqt_trackkern
	endm

vqt_pairkern	macro	first,second
	move.w	\1,intin
	move.w	\2,intin+2
	callvdi	vqt_pairkern
	endm

vst_charmap	macro	mode
	move.w	\1,intin
	callvdi	vst_charmap
	endm

vst_kern	macro	tmode,pmode
	move.w	\1,intin
	move.w	\2,intin+2
	callvdi	vst_kern
	endm

v_getbitmap_info	macro	ch
	move.w	\1,intin
	callvdi	v_getbitmap_info
	endm

vqt_f_extent	macro	string
	move.l	\1,a0
	callvdi	vqt_f_extent
	endm
		
v_ftext	macro	x,y,string
	move.w	\1,ptsin
	move.w	\2,ptsin+2
	move.l	\3,a0
	callvdi	v_ftext
	endm

v_ftext_offset	macro	string		ptsin must be set up
	move.l	\1,a0
	callvdi	v_ftext
	endm
	
v_getoutline	macro	ch,xyarray,bezarray,maxverts
	move.w	\1,intin
	move.l	\2,intin+4
	move.l	\3,intin+8
	move.w	\4,intin+2
	callvdi	v_getoutline
	endm

vst_scratch	macro	mode
	move.w	\1,intin
	callvdi	vst_scratch
	endm

vst_error	macro	mode,errorcode
	move.w	\1,intin
	move.l	\2,intin+2
	callvdi	vst_error
	endm

vst_arbpt	macro	point [fix]
	move.w	\1,intin
	IFNC	'\2',''
	move.w	\2,int_in+4
	move.w	#2,contrl+6
	ELSE
	move.w	#1,contrl+6
	ENDC
	callvdi	vst_arbpt
	endm

vqt_advance	macro	ch
	move.w	\1,intin
	callvdi	vqt_advance
	endm

vqt_devinfo	macro	devnum
	move.w	\1,intin
	callvdi	vqt_devinfo
	endm

v_savecache	macro	fname
	move.l	\1,a0
	callvdi	v_savecache
	endm

v_loadcache	macro	fname,mode
	move.w	\1,intin
	move.l	\2,a0
	callvdi	v_loadcache
	endm
	
v_flushcahce	macro
	callvdi	v_flushcahe
	endm

;vst_setsize	macro	point
;	move.w	\1,intin
;	endm

;vst_setsize	macro	point [fix]
;	move.w	\1,intin
;	IFNC	'\2',''
;	move.w	\2,int_in+4
;	move.w	#2,contrl+6
;	ELSE
;	move.w	#1,contrl+6
;	ENDC
;	callvdi	vst_setsize
;	endm

vst_skew	macro
	move.w	\1,intin
	callvdi	vst_skew
	endm

vqt_get_table	macro
	callvdi	vqt_get_table
	endm

vqt_cachesize	macro	which
	move.w	\1,intin
	callvdi	vqt_cachesize
	endm

	
*********** END OF VDI *****************
