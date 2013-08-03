*** MACROS should be loaded first in the mainfile
*** STIK ASM routs by Goof 1995 (arcovang@caiw.nl)
*** I tried to use as much names from the original C source
*** Thanx to Steve Adam

*** Stack pointers fixed/New functions added
*** by Gary Priest in May/June 1997
*** These macros now work properly and are upto STiK 1.13 standards.


*****************************************
*  KRmalloc x.l				*
*  allocate a block of stiks internal	*
*  buffer. returns 0 if failed		*
*  d0=sin otherwise			*
*****************************************
KRmalloc	macro
	move.l	a0,-(sp)	;save A0
	move.l	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	12(a0),a0
	jsr		(a0)
	lea		4(sp),sp
	move.l	(sp)+,a0	
	endm

*****************************************
*  KRfree sin.l				*
*  free a block of stiks internal	*
*  buffer. 				*
*****************************************
KRfree	macro
	move.l	a0,-(sp)	;save A0
	move.l	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	16(a0),a0
	jsr		(a0)
	lea		4(sp),sp
	move.l	(sp)+,a0	
	endm

*****************************************
*  KRgetfree flag.w			*
*****************************************
KRgetfree	macro
	move.l	a0,-(sp)	;save A0
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	20(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*****************************************
*  KRrealloc block.l,size.l		*
*****************************************
KRrealloc	macro
	move.l	a0,-(sp)	;save A0
	move.l	\2,-(sp)	
	move.l	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	24(a0),a0
	jsr		(a0)
	lea		8(sp),sp
	move.l	(sp)+,a0	
	endm

*****************************************
*  get_err_text error.w			*
*****************************************
get_err_text	macro
	move.l	a0,-(sp)	;save A0
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	28(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
*  getvstr	x.l				*
*************************************************
getvstr	macro
	move.l	a0,-(sp)	;save A0
	move.l	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	32(a0),a0
	jsr		(a0)
	lea		4(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* carrier_detect 				*
*************************************************
carrier_detect	macro
	move.l	a0,-(sp)	;save A0
	move.l	tplpointer,a0
	move.l	36(a0),a0
	jsr		(a0)
	move.l	(sp)+,a0	
	endm

*************************************************
* TCP_open h.l,p.w,t.w,o.w			*
*************************************************
TCP_open	macro
	move.l	a0,-(sp)	;save A0
	move.w	\4,-(sp)	
	move.w	\3,-(sp)	
	move.w	\2,-(sp)	
	move.l	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	40(a0),a0
	jsr		(a0)
	lea		10(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* TCP_close x.w,y.w				*
*************************************************
TCP_close	macro
	move.l	a0,-(sp)	;save A0
	move.w	\2,-(sp)	
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	44(a0),a0
	jsr		(a0)
	lea		4(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* TCP_send x.w,y.l,z.w				*
*************************************************
TCP_send	macro
	move.l	a0,-(sp)	;save A0
	move.w	\3,-(sp)	
	move.l	\2,-(sp)	
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	48(a0),a0
	jsr		(a0)
	lea		8(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* TCP_wait_state x.w,y.w,z.w				*
*************************************************
TCP_wait_state	macro
	move.l	a0,-(sp)	;save A0
	move.w	\3,-(sp)	
	move.w	\2,-(sp)	
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	52(a0),a0
	jsr		(a0)
	lea		6(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* TCP_ack_wait x.w,y.w				*
*************************************************
TCP_ack_wait	macro
	move.l	a0,-(sp)	;save A0
	move.w	\2,-(sp)	
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	56(a0),a0
	jsr		(a0)
	lea		4(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* UDP_open x.l,y.w				*
*************************************************
UDP_open	macro
	move.l	a0,-(sp)	;save A0
	move.w	\2,-(sp)	
	move.l	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	60(a0),a0
	jsr		(a0)
	lea		6(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* UDP_close x.w					*
*************************************************
UDP_close	macro
	move.l	a0,-(sp)	;save A0
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	64(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* UDP_send x.w,y.l,z.w				*
*************************************************
UDP_send	macro
	move.l	a0,-(sp)	;save A0
	move.w	\3,-(sp)	
	move.l	\2,-(sp)	
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	68(a0),a0
	jsr		(a0)
	lea		8(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* CNkick x.w					*
*************************************************
CNkick	macro
	move.l	a0,-(sp)	;save A0
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	72(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* CNbyte_count x.w				*
*************************************************
CNbyte_count	macro
	move.l	a0,-(sp)	;save A0
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	76(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* CNget_char x.w				*
*************************************************
CNget_char	macro
	move.l	a0,-(sp)	;save A0
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	80(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* CNget_NDB x.w					*
*************************************************
CNget_NDB	macro
	move.l	a0,-(sp)	;save A0
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	84(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* CNget_block x.w,y.l,z.w					*
*************************************************
CNget_block	macro
	move.l	a0,-(sp)	;save A0
	move.w	\3,-(sp)	
	move.l	\2,-(sp)	
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	88(a0),a0
	jsr		(a0)
	lea		8(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* housekeep					*
*************************************************
housekeep	macro
	move.l	a0,-(sp)	;save A0
	move.l	tplpointer,a0
	move.l	92(a0),a0
	jsr		(a0)
	move.l	(sp)+,a0	
	endm

*************************************************
*  resolve dn.l,rdn.l,returnlist.l,size.w	*
*************************************************
resolve	macro
	move.l	a0,-(sp)	;save A0
	move.w	\4,-(sp)	
	move.l	\3,-(sp)	
	move.l	\2,-(sp)	
	move.l	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	96(a0),a0
	jsr		(a0)
	lea		14(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* ser_disable					*
*************************************************
ser_disable	macro
	move.l	a0,-(sp)	;save A0
	move.l	tplpointer,a0
	move.l	100(a0),a0
	jsr		(a0)
	move.l	(sp)+,a0	
	endm

*************************************************
* ser_enable					*
*************************************************
ser_enable	macro
	move.l	a0,-(sp)	;save A0
	move.l	tplpointer,a0
	move.l	104(a0),a0
	jsr		(a0)
	move.l	(sp)+,a0	
	endm

*************************************************
* set_flag x.w					*
*************************************************
set_flag	macro
	move.l	a0,-(sp)	;save A0
	move.w	/1,-(sp)
	move.l	tplpointer,a0
	move.l	108(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* clear_flag x.w					*
*************************************************
clear_flag	macro
	move.l	a0,-(sp)	;save A0
	move.w	/1,-(sp)
	move.l	tplpointer,a0
	move.l	112(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* CNgetinfo x.w					*
*************************************************
CNgetinfo	macro
	move.l	a0,-(sp)	;save A0
	move.w	/1,-(sp)
	move.l	tplpointer,a0
	move.l	116(a0),a0
	jsr		(a0)
	lea		2(sp),sp
	move.l	(sp)+,a0	
	endm

*following added by Gary Priest

*************************************************
* on_port x.l					*
*************************************************
on_port	macro
	move.l	a0,-(sp)	;save A0
	move.l	\1,-(sp)
	move.l	tplpointer,a0
	move.l	120(a0),a0
	jsr		(a0)
	lea		4(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* off_port x.l					*
*************************************************
off_port	macro
	move.l	a0,-(sp)	;save A0
	move.l	\1,-(sp)
	move.l	tplpointer,a0
	move.l	124(a0),a0
	jsr		(a0)
	lea		4(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* setvstr x.l,y.l				*
*************************************************
setvstr	macro
	move.l	a0,-(sp)	;save A0
	move.l	\2,-(sp)
	move.l	\1,-(sp)
	move.l	tplpointer,a0
	move.l	128(a0),a0
	jsr		(a0)
	lea		8(sp),sp
	move.l	(sp)+,a0	
	endm

*************************************************
* query_port x.l					*
*************************************************
query_port	macro
	move.l	a0,-(sp)	;save A0
	move.l	\1,-(sp)
	move.l	tplpointer,a0
	move.l	132(a0),a0
	jsr		(a0)
	lea		4(sp),sp
	move.l	(sp)+,a0	
	endm


*************************************************
*  g_resolve dn.l,rdn.l,returnlist.l,size.w	*
*************************************************
g_resolve	macro
	move.l	a0,-(sp)	;save A0
	move.w	\4,-(sp)	
	move.l	\3,-(sp)	
	move.l	\2,-(sp)	
	move.l	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	136(a0),a0
	jsr		(a0)
	lea		14(sp),sp
	move.l	(sp)+,a0	
	endm


*************************************************
* g_TCP_wait_state x.w,y.w,z.w				*
*************************************************
g_TCP_wait_state	macro
	move.l	a0,-(sp)	;save A0
	move.w	\3,-(sp)	
	move.w	\2,-(sp)	
	move.w	\1,-(sp)	
	move.l	tplpointer,a0
	move.l	140(a0),a0
	jsr		(a0)
	lea		6(sp),sp
	move.l	(sp)+,a0	
	endm
