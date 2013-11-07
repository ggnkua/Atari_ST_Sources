
*-------------------------------------------------------*
clear_bss:
*-------------------------------------------------------*
	lea		bss_start,a0
	move.l		#(bss_end-bss_start)/4,d0
	moveq		#0,d1
.clr:	move.l		d1,(a0)+
	subq.l		#1,d0
	bne.s		.clr
	rts

*---------------------------------------------------------------*
appl_init:
*---------------------------------------------------------------*
	lea		control,a0
	move.w		#10,(a0)+
	move.w		#0,(a0)+
	move.w		#1,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	bsr		AES
	rts

*---------------------------------------------------------------*
appl_exit:
*---------------------------------------------------------------*
	lea		control,a0
	move.w		#19,(a0)+
	move.w		#0,(a0)+
	move.w		#1,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	clr.w		int_out
	bsr		AES
.wait:	tst.w		int_out
	beq.s		.wait
	rts

*---------------------------------------------------------------*
graf_handle:
*---------------------------------------------------------------*
	lea		control,a0
	move.w		#77,(a0)+
	move.w		#0,(a0)+
	move.w		#5,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	bsr		AES
	move.w		int_out,handle
	rts

*---------------------------------------------------------------*
v_opnvwk:
*---------------------------------------------------------------*
	lea		control,a0
	move.w		#100,(a0)+
	move.w		#0,(a0)+
	move.w		#6,(a0)+
	move.w		#11,(a0)+
	move.w		#45,(a0)+
	move.w		#0,(a0)+
	move.w		handle,(a0)+
	lea		int_in,a0
	moveq		#1,d0
	move.w		d0,(a0)+
	move.w		d0,(a0)+
	move.w		d0,(a0)+
	move.w		d0,(a0)+
	move.w		d0,(a0)+
	move.w		d0,(a0)+
	move.w		d0,(a0)+
	move.w		d0,(a0)+
	move.w		d0,(a0)+
	move.w		d0,(a0)+
	move.w		#2,(a0)+
	bsr		VDI
	move.w		control+12,vhandle
	lea		int_out,a0
	move.w		(a0)+,d1
	move.w		(a0)+,d2
	addq.w		#1,d1
	addq.w		#1,d2
	move.w		d1,vwork_w
	move.w		d2,vwork_h
	rts

*---------------------------------------------------------------*
v_extnd:
*---------------------------------------------------------------*
	lea		control,a0
	move.w		#102,(a0)+
	move.w		#0,(a0)+
	move.w		#6,(a0)+
	move.w		#1,(a0)+
	move.w		#45,(a0)+
	move.w		#0,(a0)+
	move.w		handle,(a0)+
	move.w		#1,int_in
	bsr		VDI
	lea		int_out,a0
	move.w		8(a0),vwork_c
	rts

*---------------------------------------------------------------*
v_clsvwk:
*---------------------------------------------------------------*
	lea		control,a0
	move.w		#101,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		vhandle,(a0)+
	bsr		VDI
	rts

*---------------------------------------------------------------*
v_hidemouse:
*---------------------------------------------------------------*
	lea		control,a0
	move.w		#123,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		handle,(a0)+
	move.w		#1,int_in
	bsr		VDI
	rts

*---------------------------------------------------------------*
v_showmouse:
*---------------------------------------------------------------*
	lea		control,a0
	move.w		#122,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		#1,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		handle,(a0)+
	move.w		#1,int_in
	bsr		VDI
	rts

*---------------------------------------------------------------*
v_free:
*---------------------------------------------------------------*
	lea		control,a0
	move.w		#51,(a0)+
	move.w		#9,(a0)+
	move.w		#1,(a0)+
	move.w		#0,(a0)+
	move.w		#0,(a0)+
	move.w		os_screen_w,d1
	move.w		os_screen_h,d2
	lea		int_in,a0
	move.w		#3,(a0)+	; flag
	move.w		#0,(a0)+	; smallbox
	move.w		#0,(a0)+
	move.w		d1,(a0)+
	move.w		d2,(a0)+
	move.w		#0,(a0)+	; largebox
	move.w		#0,(a0)+
	move.w		d1,(a0)+
	move.w		d2,(a0)+
	bsr.s		AES
	rts

AES:	move.l		#aespb,d1
	move.w		#200,d0
	trap		#2	
	rts

VDI:	move.l		#vdipb,d1
	moveq		#115,d0
	trap		#2	
	rts

*---------------------------------------------------------------*
			data
*---------------------------------------------------------------*

vdipb:			dc.l	control,int_in,pts_in,int_out,pts_out
aespb:			dc.l	control,global,int_in,int_out,addr_in,addr_out

*---------------------------------------------------------------*
			bss
*---------------------------------------------------------------*

vwork_w:		ds.w	1
vwork_h:		ds.w	1
vwork_c:		ds.w	1

control:
opcode:			ds.w	1
sintin:			ds.w	1
sintout:		ds.w	1
saddrin:		ds.w	1
saddrout:		ds.w	1
			ds.w	6

global:
apversion:		ds.w	1
apcount:		ds.w	1
apid:			ds.w	1
apprivate:		ds.l	1
apptree:		ds.l	1
ap1resv:		ds.l	1	
ap2resv:		ds.l	1
ap3resv:		ds.l	1
ap4resv:		ds.l	1

int_in:			ds.b	256
pts_in:			ds.b	64
int_out:		ds.b	256
pts_out:		ds.b	64
addr_in:		ds.l	4
addr_out		ds.l	4

handle:			ds.w	1
vhandle:		ds.w	1

*---------------------------------------------------------------*
			text
*---------------------------------------------------------------*
