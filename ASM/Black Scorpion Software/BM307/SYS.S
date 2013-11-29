*=======================================================*
*	System routines: updated 12/06/97		*
*=======================================================*


*-------------------------------------------------------*
turbo_memcpy:
*-------------------------------------------------------*
	movem.l		d0-d1/a0-a1,-(sp)	
*-------------------------------------------------------*
	tst.l		d0
	ble		.copy_complete
	move.l		a0,d1
	sub.l		a1,d1
	and.w		#16-1,d1
	beq.s		.line_copy
*-------------------------------------------------------*
.long_copy:
*-------------------------------------------------------*
	moveq		#16-1,d1
	add.l		a0,d1
	and.w		#-16,d1
	sub.l		a0,d1
	sub.l		d1,d0	
	bpl.s		.no_cliplong
	add.l		d0,d1
	moveq		#0,d0
.no_cliplong:
*-------------------------------------------------------*
*	0->15 byte preamble				*
*-------------------------------------------------------*
	lsr.l		d1
	bcc.s		.prelong_0
	move.b		(a0)+,(a1)+
.prelong_0:
	lsr.l		d1
	bcc.s		.prelong_1
	move.w		(a0)+,(a1)+
.prelong_1:
	dbra		d1,.prelong_loop
	bra.s		.prelong_done
.prelong_loop:
	move.l		(a0)+,(a1)+
	dbra		d1,.prelong_loop
.prelong_done:
*-------------------------------------------------------*
*	Aligned long-transfer				*
*-------------------------------------------------------*
	move.l		d0,d1
	and.w		#-16,d1
	beq.s		.long_done	
	sub.l		d1,d0
	lsr.l		#4,d1
.long_transfer:
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	move.l		(a0)+,(a1)+
	subq.l		#1,d1
	bne.s		.long_transfer
.long_done:
*-------------------------------------------------------*
*	0->15 byte postamble				*
*-------------------------------------------------------*
	moveq		#-4,d1
	and.l		d0,d1
	sub.l		d1,d0
	lsr.l		#2,d1
	dbra		d1,.postlong_loop
	bra.s		.postlong_done
.postlong_loop:
	move.l		(a0)+,(a1)+
	dbra		d1,.postlong_loop
.postlong_done:
	bclr		#1,d0
	beq.s		.postlong_1
	move.w		(a0)+,(a1)+
.postlong_1:
	bclr		#0,d0
	beq.s		.postlong_0
	move.b		(a0)+,(a1)+
.postlong_0:
	bra		.copy_complete
*-------------------------------------------------------*
.line_copy:
*-------------------------------------------------------*
	cmp.l		#40,cpu
	bmi		.long_copy
	moveq		#16-1,d1
	add.l		a0,d1
	and.w		#-16,d1
	sub.l		a0,d1
	sub.l		d1,d0	
	bpl.s		.no_clipline
	add.l		d0,d1
	moveq		#0,d0
.no_clipline:
*-------------------------------------------------------*
*	0->15 byte preamble				*
*-------------------------------------------------------*
	lsr.l		d1
	bcc.s		.preline_0
	move.b		(a0)+,(a1)+
.preline_0:
	lsr.l		d1
	bcc.s		.preline_start
	move.w		(a0)+,(a1)+
	bra.s		.preline_start
.preline_loop:
	move.l		(a0)+,(a1)+
.preline_start:
	dbra		d1,.preline_loop
*-------------------------------------------------------*
*	Aligned line-transfer				*
*-------------------------------------------------------*
	moveq		#-16,d1
	and.l		d0,d1
	beq.s		.long_done	
	sub.l		d1,d0
	lsr.l		#4,d1
.line_transfer:
	move16		(a0)+,(a1)+
	subq.l		#1,d1
	bne.s		.line_transfer
.line_done:
*-------------------------------------------------------*
*	0->15 byte postamble				*
*-------------------------------------------------------*
	moveq		#-4,d1
	and.l		d0,d1
	sub.l		d1,d0
	lsr.l		#2,d1
	bra.s		.postline_start
.postline_loop:
	move.l		(a0)+,(a1)+
.postline_start:
	dbra		d1,.postline_loop
.postline_done:
	bclr		#1,d0
	beq.s		.postline_1
	move.w		(a0)+,(a1)+
.postline_1:
	bclr		#0,d0
	beq.s		.postline_0
	move.b		(a0)+,(a1)+
.postline_0:
*-------------------------------------------------------*
.copy_complete:
*-------------------------------------------------------*
	movem.l		(sp)+,d0-d1/a0-a1
*-------------------------------------------------------*
	rts

*-------------------------------------------------------*
turbo_memclr:
*-------------------------------------------------------*
	movem.l		d0-d2/a0,-(sp)
*-------------------------------------------------------*
	moveq		#0,d2
	move.l		d2,d1
	swap		d2
	or.l		d2,d1
	move.l		d1,d2
	rol.l		#8,d1
	or.l		d1,d2
*-------------------------------------------------------*
.long_fill:
*-------------------------------------------------------*
	moveq		#16-1,d1
	add.l		a0,d1
	and.w		#-16,d1
	sub.l		a0,d1
	sub.l		d1,d0	
	bpl.s		.no_cliplong
	add.l		d0,d1
	moveq		#0,d0
.no_cliplong:
*-------------------------------------------------------*
*	0->15 byte preamble				*
*-------------------------------------------------------*
	lsr.l		d1
	bcc.s		.prelong_0
	move.b		d2,(a0)+
.prelong_0:
	lsr.l		d1
	bcc.s		.prelong_start
	move.w		d2,(a0)+
	bra.s		.prelong_start
.prelong_loop:
	move.l		d2,(a0)+
.prelong_start:
	dbra		d1,.prelong_loop
*-------------------------------------------------------*
*	Aligned long-transfer				*
*-------------------------------------------------------*
	moveq		#-16,d1
	and.l		d0,d1
	beq.s		.long_done	
	sub.l		d1,d0
	lsr.l		#4,d1
.long_transfer:
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	move.l		d2,(a0)+
	subq.l		#1,d1
	bne.s		.long_transfer
.long_done:
*-------------------------------------------------------*
*	0->15 byte postamble				*
*-------------------------------------------------------*
	moveq		#-4,d1
	and.l		d0,d1
	sub.l		d1,d0
	lsr.l		#2,d1
	bra.s		.postlong_start
.postlong_loop:
	move.l		d2,(a0)+
.postlong_start:
	dbra		d1,.postlong_loop
.postlong_done:
	bclr		#1,d0
	beq.s		.postlong_1
	move.w		d2,(a0)+
.postlong_1:
	bclr		#0,d0
	beq.s		.postlong_0
	move.b		d2,(a0)+
.postlong_0:
*-------------------------------------------------------*
	movem.l		(sp)+,d0-d2/a0
*-------------------------------------------------------*
	rts

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
			datlong
*---------------------------------------------------------------*

vdipb:			dc.l	control,int_in,pts_in,int_out,pts_out
aespb:			dc.l	control,global,int_in,int_out,addr_in,addr_out

cpu:			dc.l	30

*---------------------------------------------------------------*
			bsslong
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
			txtlong
*---------------------------------------------------------------*
