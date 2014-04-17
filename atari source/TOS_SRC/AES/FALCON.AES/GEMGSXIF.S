*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.2 $	$Source: /u2/MRS/osrevisions/aes/gemgsxif.s,v $
* =======================================================================
*  $Author: mui $	$Date: 89/04/26 18:23:50 $	$Locker: kbad $
* =======================================================================
*  $Log:	gemgsxif.s,v $
* Revision 2.2  89/04/26  18:23:50  mui
* TT
* 
* Revision 2.1  89/02/22  05:27:16  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.2  88/10/24  10:34:08  mui
* move gsx_malloc to geminit.c
* 
* Revision 1.1  88/06/02  12:34:09  lozben
* Initial revision
* 
*************************************************************************
*	Translated by J.Eisenstein	1/19/87
*	Fix	1/21/87			Derek Mui, J.Eisenstein
*	Fix at gsx_mret	4/28/1988	D.Mui	
*	Remove gsx_mfset	5/8/91	D.Mui
*	Add gsx_wsop for six resolutions 4/25/89	D.Mui
* 	Assemble with MAS 900801 kbad
*	Check for sparrow resolution at gsx_wsop	7/19/92	D.Mui	

	.globl	_gl_vdo,_d_rezword		
	.globl	_gsx_fix,_gsx_sta,_dos_all,_dos_fre
	.globl	_far_mchange,_far_bchange,_gsx2
	.globl	 iioff,iooff,pooff,pioff

	.globl	_gl_restype,_gl_rsch,_drwaddr,_xrat,_yrat,_button
	.globl	_gl_width,_gl_heigh,_gl_nrows,_gl_ncols,_gl_wchar
	.globl	_gl_hchar,_gl_wscha,_gl_hscha,_gl_wptsc,_gl_hptsc
	.globl	_gl_wspts,_gl_hspts,_gl_wbox,_gl_hbox,_gl_xclip
	.globl	_gl_yclip,_gl_wclip,_gl_hclip,_gl_nplan,_gl_handl
	.globl	_gl_src,_gl_dst,_gl_ws

	.globl	_contrl,_intin,_ptsin,_intout,_ptsout,_ad_intin

	.globl	_gl_tmp
	.comm	_gl_tmp,20
	.globl	_old_mcod
	.comm 	_old_mcod,4
	.globl	_old_bcod
	.comm	_old_bcod,4
	.globl	_gl_moff
	.comm	_gl_moff,2
	.globl	_gl_mlen
	.comm	_gl_mlen,4
	.globl	_gl_graph
	.comm	_gl_graph,2
	.globl	_gl_mouse
	.comm	_gl_mouse,2


GSX_MFS	.equ	 0*3
V_OPNWK	.equ	 1*3
VST_CLP	.equ	 2*3
VST_HGT	.equ	 3*3
VR_RECT	.equ	 4*3
VRO_CPY	.equ	 5*3
VRT_CPY	.equ	 6*3
VSL_WID	.equ	 7*3


*	.globl _gsx_malloc
*
*_gsx_malloc:
*
*	clr.l	-(sp)
*	clr.l	-(sp)
*	pea	_gl_tmp
*	jsr	_gsx_fix
*
*	move.l	#$00003400,_gl_mlen
*	pea	 $3400
*	jsr	_dos_all
*	move.l	 d0,_gl_tmp
*
*	lea	16(sp),sp		; clean up stack
*	rts



	.globl _gsx_mfre

_gsx_mfre:
	tst.l	_gl_tmp			; Fix 8/3/92
	beq	g1
	move.l	_gl_tmp,-(sp)		; Fix 1/20/87
	jsr	_dos_fre
	addq.l	#4,sp
g1:
	rts



	.globl _gsx_mret

*  in:
*	sp+04	pmaddr
*	sp+08	pmlen

_gsx_mret:

	move.l	4(sp),a0
	move.l	_gl_tmp,(a0)
	move.l  8(sp),a0
	move.l _gl_mlen,(a0)
	rts



	.globl _gsx_ncode

*  in:
*	sp+04	code
*	  +06	n
*	  +08	m

_gsx_ncode:

	lea	4(sp),a0
	lea	_contrl,a1

	move.l	(a0)+,(a1)+
	addq.l	#2,a1
	move.w	(a0)+,(a1)
	addq.l	#6,a1
	move.w	_gl_handl,(a1)

	jmp	_gsx2



	.globl _gsx_1code

*  in:
*	sp+04	code
*	  +06	value

_gsx_1code:

	move.w  6(sp),_intin

	move.l	#$00000001,-(sp)	; Fix 1/20/87
	move.w	4+4(sp),-(sp)
	bsr	_gsx_ncode

	addq.l	#6,sp
	rts



	.globl _gsx_init

_gsx_init:

	bsr	_gsx_wsop
	jsr	_gsx_sta
	bsr	setmb

	moveq.l	#124,d0			; code 124 => vq_mouse
	bsr	vdi_short

	lea	_ptsout,a0
	move.w	(a0)+,_xrat
	move.w  (a0)+,_yrat

	rts




	.globl _gsx_grap

*  in:
*	sp+04	tographic

_gsx_grap:

	move.w	4(sp),d0
	lea	_gl_graph,a1
	cmp.w	(a1),d0
	beq	L8

	move.w	d0,(a1)
	beq	L9

	moveq.l #2,d0
	bsr	escape

setmb:	pea	_drwaddr
	pea	_far_mchange
	pea	_far_bchange
	bsr	_gsx_setm
	lea	12(sp),sp

L8:	rts


L9:	moveq.l	#3,d0
	bsr	escape
	bra	_gsx_rese




	.globl _v_hardco

_v_hardco:

	moveq.l	#17,d0
	bra	escape




	.globl _gsx_esca

*  in:
*	sp+04	esc_code

_gsx_esca:

	move.w	4(sp),d0

escape:	move.w	d0,_contrl+10
	moveq.l	#005,d0			; code 005 => escape
	bra	vdi_short



*****	 Open physical work station for 6 resoultions	*****

	.globl _gsx_wsop

_gsx_wsop:

	lea	_intin,a1
	move.l	a1,a2			; a2 -> intin[0]

	moveq.l	#9,d0

L15:	move.w	#1,(a1)+
	dbra	d0,L15

	move.w	#2,(a1)			; intin[10] <- 2

	lea	restable,a0		; look for the drive handle 
	lea	restype,a1		; load in res table
L209:
	move.w	(a1)+,d0
	tst.w	(a0)+
	cmp.w	_gl_restype,d0
	bne	L209

	move.w	-(a0),(a2)		; intin[0] <- screen handle

	pea	_gl_ws
	pea	_gl_handl
	pea	(a2)
			
*	Check for sparrow machine	
		
*	move.l	_gl_vdo,d0		; check for sparrow 	
*	and.l	#$00030000,d0		; 7/17/92
*	cmp.l	#$00030000,d0
*	bne	L20_3
*	lea	_intin,a0
*	move.w	#5,(a0)
*	lea	_intout,a0
*	move.w	_d_rezword,(a0)
	jsr	_setres			; check mode code
L20_3:

	bsr	_v_opnwk
	lea	12(sp),sp

	lea	_gl_ws,a1
	lea	_gl_restype,a2

L20:	
	move.w	#5,(a2)		; default to 1280 x 960 
	
	cmp.w	#639,(a1)	; check for x = 640 ?
	bne	L18
	tst.w	(a1)+
	cmp.w	#199,(a1)	; 640 x 200
	bne	L20_1
	move.w	#2,(a2)
	bra	L22
	
L20_1:	cmp.w	#399,(a1)	; 640 x 400
	bne	L20_2
	move.w	#3,(a2)
	bra	L22
	
L20_2:	move.w	#4,(a2)		; 640 x 480
	bra	L22	

L18:	cmp.w	#319,(a1)+	; check for x = 320 ?
	bne	L22	
	cmp.w	#199,(a1)	; check for y = 200 ?
	bne	L18_1
	move.w	#1,(a2)		; Yes		 
	bra	L22

L18_1:	move.w	#6,(a2)		; No it is 320 x 480

L22:	clr.w	_gl_rsch	; gl_rschange  <- FALSE
	move.w	#1,_gl_graph	; gl_graphic   <- TRUE
	rts



	.globl _gsx_wscl

_gsx_wscl:

	moveq.l	#002,d0			; code 002 => v_clswk
	bra	vdi_short



	.globl _ratinit

_ratinit:

	clr.w	     -(sp)
	move.w	#122,-(sp)		; show cursor: force show
	bsr	_gsx_1code
	addq.l	#4,sp

	clr.w	_gl_moff
	rts


	.globl _bb_set

*  call:
*
*	bb_set (sx, sy, sw, sh, pts1, pts2, pfd, psrc, pdst)
*
*  in:
*	sp+04	 sx		word
*	  +06	 sy		word
*	  +08	 sw		word
*	  +10	 sh		word
*	  +12	*pts1		points to word array
*	  +16	*pts2		points to word array
*	  +20	*pfd		points to MFDB
*	  +24	*psrc		points to MFDB
*	  +28	*pdst		points to MFDB

_bb_set:

	lea	4(sp),a0		; a0 -> stack resident parameters

	move.w	(a0)+,d0		; d0[15:00] <- sx  (XminSRC)
	move.l	(a0)+,d1		; d1[31:16] <- sy  (YminSRC)
*					; d1[15:00] <- sw  (width)
	move.w	(a0)+,d2		; d2[15:00] <- sh  (height)

	add.w	d0,d1			; d1 <- sx + sw = XmaxSRC + 1
	subq.w	#1,d1			; d1 <- XmaxSRC

	lsr.w	#4,d0			; d0 <- XminSRC/16
	lsr.w	#4,d1			; d1 <- XmaxSRC/16
	sub.w	d0,d1			; d1 <- width-1	(in words)
	addq.w	#1,d1			; d1 <- width   (in words)

	lea	_gl_tmp+10,a1		; a1 -> gl_tmp.fd_stand

	move.w	#01,(a1)		; gl_tmp.fd_stand   <- TRUE
	move.w	d1,-(a1)		; gl_tmp.fd_wdwidth <- width in words
	move.w	d2,-(a1)		; gl_tmp.fd_h       <- height in pixels
	lsl.w	#4,d1
	move.w	d1,-(a1)		; gl_tmp.fd_w       <- width in pixels
	
	move.l	(a0)+,a1		; a1 -> pts1 array
	move.l	(a0)+,a2		; a2 -> pts2 array

	clr.l	(a2)+			; pts2[0] <- XminDST=0
*					; pts2[1] <- YminDST=0
	subq.w	#1,d1			; d1      <- width - 1
	move.w	d1,(a2)+		; pts2[2] <- XmaxDST
	subq.w	#1,d2			; d2      <- height -1
	move.w	d2,(a2)+		; pts2[3] <- YmaxDST

	lsl.w	#4,d0			; d0      <- XminSRC/16 *16
	move.w	d0,(a1)+		; pts1[0] <- XminSRC on word boundry
	add.w	d0,d1			; d1      <- XminSRC + width - 1
	move.l	d1,(a1)+		; pts1[1] <- YminSRC:  d1[31:16]
*					; pts1[2] <- XmaxSRC:  d1[15:00]
	swap	d1			; d1      <- YminSRC
	add.w	d1,d2			; d2      <- YminSRC + height -1
	move.w	d2,(a1)+		; pts1[3] <- YmaxSRC

	clr.l	      -(sp)		; gsx_fix(pfd, 0, 0, 0, 0)
	clr.l	      -(sp)
	move.l	(a0)+,-(sp)		; pfd -> space for MFDB
	jsr	_gsx_fix		; build MFDB

	bsr	_gsx_moff		; hide mouse cursor

	lea	12+28(sp),a0		; a0 -> pdst pointer
	move.l	 (a0),-(sp)		; push *pdst
	move.l	-(a0),-(sp)		; push *psrc
	pea	_ptsin			; push *ptsin
	move.w	#3,-(sp)		; replace mode (S_ONLY)
	bsr	_vro_cpyf

	lea	26(sp),sp		; clean the stack up from earlier calls

	bra	_gsx_mon		; show mouse cursor (RETURN from there)




	.globl _bb_save

*  call:
*
*	bb_save (ps->g_x, ps->g_y, ps->g_w, ps->g_h, &ptsin[0], &ptsin[4].
*		 &gl_src, &gl_src, &gl_tmp)
*
*  in:
*	sp+04	ps

_bb_save:

	pea	_gl_tmp
	lea	_gl_src,a1
	pea	 (a1)
	pea	 (a1)
	pea	_ptsin+08
	pea	_ptsin+00

	move.l	4+20(sp),a0		; a0 -> ps.g_w
	move.l	4(a0),-(sp)		; width and height
	move.l	 (a0),-(sp)		; Xmin  and Ymin
	bsr	_bb_set

	lea	28(sp),sp
	rts




	.globl _bb_resto

*  call:
*
*	bb_restore (pr->g_x, pr->g_y, pr->g_w, pr->g_h, &ptsin[4], &ptsin[0].
*		    &gl_dst, &gl_tmp, &gl_dst)
*
*  in:
*	sp+04	pr

_bb_resto:

	lea	_gl_dst,a1
	pea	 (a1)
	pea	_gl_tmp
	pea	 (a1)
	pea	_ptsin+00
	pea	_ptsin+08

	move.l	4+20(sp),a0		; a0 -> ps.g_w
	move.l	4(a0),-(sp)		; ps.g_w and ps.g_h
	move.l	 (a0),-(sp)		; ps.g_x and ps.g_y
	bsr	_bb_set

	lea	28(sp),sp
	rts




	.globl _gsx_setm

*  in:
*	sp+04	boff
*	  +08	moff
*	  +12	pdrwaddr	*** not used ***

_gsx_setm:

	move.l	4(sp),_contrl+14	; contrl[7-8] <- new button vector
	moveq.l	#125,d0
	bsr	vdi_short
	move.l	_contrl+18,_old_bcod

	move.l	8(sp),_contrl+14	; contrl[7-8] <- new motion vector
	moveq.l	#126,d0
	bsr	vdi_short
	move.l	_contrl+18,_old_mcod

	rts



	.globl _gsx_rese

_gsx_rese:

	move.l	_old_bcod,_contrl+14		; reset button vector
	moveq.l	#125,d0
	bsr	vdi_short
	move.l	_old_mcod,_contrl+14		; reset motion vector
	moveq.l	#126,d0
	bra	vdi_short



	.globl _gsx_tick

*  in:
*	sp+04	 tcode
*	  +08	*ptsave

_gsx_tick:

	move.l	4(sp),_contrl+14

	moveq.l	#118,d0			; code 118 => vex_timv
	bsr	vdi_short

	move.l	8(sp),a0
	move.l	_contrl+18,(a0)

	move.w	_intout,d0
	rts


*	.globl _gsx_mfse

*  in:
*	sp+04	pmfnew

*_gsx_mfse:

*	bsr	_gsx_moff		; hide mouse cursor

*	moveq.l	#36,d0			; number of words
*	move.l	4(sp),a0		; source
*	move.l	_ad_intin,a1		; destination


*L32:	move.w	(a0)+,(a1)+		; load mouse form into intin array
*	dbra	d0,L32

*	moveq.l	#GSX_MFS,d0
*	bsr	vdi_call

*	bra	_gsx_mon		; show mouse cursor



	.globl _gsx_mxmy

*  in:
*	sp+04	*pmx
*	  +08	*pmy

_gsx_mxmy:

	lea	4(sp),a0
	move.l	(a0)+,a1
	move.w	_xrat,(a1)
	move.l	(a0)+,a1
	move.w	_yrat,(a1)
	rts



	.globl _gsx_butt

_gsx_butt:

	move.w	_button,d0
	rts



	.globl _gsx_moff
	.globl _ratexit

_ratexit:
_gsx_moff:

	tst.w	_gl_moff
	bne	L35

	moveq.l	#123,d0			; code 123 => v_hide
	bsr	vdi_short

	clr.w	 _gl_mouse

L35:	add.w	#1,_gl_moff
	rts



	.globl _gsx_mon

_gsx_mon:

	moveq.l	#1,d0
	sub.w	d0,_gl_moff
	bne	L37

	move.w	  d0,-(sp)
	move.w	#122,-(sp)		; show cursor: don't force it
	bsr	_gsx_1code
	addq.l	#4,sp

	move.w	#1,_gl_mouse

L37:	rts



	.globl _v_opnwk

*  in:
*	sp+04	pwork_in
*	sp+08	phandle
*	sp+12	pwork_out

_v_opnwk:

	move.l	04(sp),iioff		; _intin array is pwork_in
	move.l	12(sp),a1		; a1 -> pwork_out
	move.l	a1,iooff		; _intout array is pwork_out
	lea	90(a1),a1		; a1 -> pwork_out+45
	move.l	a1,pooff		; _ptsout array is pwork_out+45

	moveq.l	#V_OPNWK,d0
	bsr	vdi_call

	move.l	08(sp),a1		; a1 -> phandle
	move.w	_contrl+12,(a1)		; phandle <- workstation handle
	
	move.l	#_intin,iioff
	move.l	#_intout,iooff
	move.l	#_ptsout,pooff
	rts



	.globl _v_pline

*  in:
*	sp+04	count
*	sp+06	pxyarray

_v_pline:

	lea	4(sp),a0

	clr.w	      -(sp)
	move.w	(a0)+,-(sp)
	move.w	   #6,-(sp)

	bsr	set_pioff
	bra	vdi_cont



	.globl _vst_clip

*  in:
*	sp+04	clip_flag
*	sp+06	pxyarray

_vst_clip:

	lea	4(sp),a0
	move.w	(a0)+,_intin		; intin[0] <- clip flag
	bsr	set_pioff		; redirect ptsin array pointer
	moveq.l	#VST_CLP,d0
	bra	vdi_call


	.globl _vst_heig

*  in:
*	sp+04	height
*	  +06	pchr_wid
*	  +10	pchr_hei
*	  +14	pcell_wi
*	  +18	pcell_he

_vst_heig:

	lea	_ptsin,a1
	clr.w	      (a1)+		; ptsin[0] <- 0
	move.w	4(sp),(a1)+		; ptsin[1] <- height

	moveq.l	#VST_HGT,d0
	bsr	vdi_call

	lea	_ptsout,a0
	lea	6(sp),a1

	move.l	(a1)+,a2		; a2 -> pchar_width
	move.w	(a0)+,(a2)		; pchr_width   <- ptsout[0]
	move.l	(a1)+,a2		; a2 -> pchar_height
	move.w	(a0)+,(a2)		; pchr_height  <- ptsout[1]
	move.l	(a1)+,a2		; a2 -> pcell_width
	move.w	(a0)+,(a2)		; pcell_width  <- ptsout[2]
	move.l	(a1)+,a2		; a2 -> pcell_height
	move.w	(a0)+,(a2)		; pcell_height <- ptsout[3]
	rts



	.globl _vr_recfl

*  in:
*	sp+04	pxyarray
*	sp+08	pdesMFDB

_vr_recfl:

	lea	4(sp),a0
	bsr	set_pioff
	move.l	(a0)+,_contrl+14

	moveq.l	#VR_RECT,d0
	bra	vdi_call



	.globl _vro_cpyf

*  in:
*	sp+04	wr_mode
*	  +06	pxyarray
*	  +10	psrcMFDB
*	  +14	pdesMFDB

_vro_cpyf:

	lea	4(sp),a0		; a0 -> parameters on stack
	move.w	(a0)+,_intin		; intin[0] <- writing mode	  4(sp)
	bsr	set_pioff		; initialize ptsin array pointer  6(sp)
	bsr	mfdb_load		; load MFDBs

	moveq.l	#VRO_CPY,d0
	bra	vdi_call



	.globl _vrt_cpyf

*  in:
*	sp+04	wr_mode
*	  +06	pxyarray
*	  +10	psrcMFDB
*	  +14	pdesMFDB
*	  +18	fgcolor
*	  +20	bgcolor

_vrt_cpyf:

	lea	  4(sp),a0		; a0 -> parameters on stack
	lea	 _intin,a2		; a2 -> intin array
	
	move.w	(a0)+,(a2)+		; intin[0] <- writing mode        4(sp)
	bsr	set_pioff		; initialize ptsin pointer	  6(sp)
	bsr	mfdb_load		; load MFDBs
	move.l	(a0)+,(a2)+		; intin[1] <- foreground color	 18(sp)
*					; intin[2] <- background color   20(sp)
	moveq.l	#VRT_CPY,d0
	bra	vdi_call



	.globl _vrn_trnf

*  in:
*	sp+04	psrcMFDB
*	  +08	pdesMFDB

_vrn_trnf:

	lea	 4(sp),a0		; a0 -> stack parameters
	bsr	mfdb_load

	moveq.l	#110,d0			; code 110 => vr_trn_fm
	bra	vdi_short



	.globl _vsl_width

*  in:
*	sp+04	width

_vsl_width:

	lea	_ptsin,a1
	move.w	4(sp),(a1)+		; ptsin[0] <- width
	clr.w	      (a1)		; ptsin[1] <- 0

	moveq.l	#VSL_WID,d0
	bra	vdi_call




* in:
*	a0	pointer to SRC and DST MFDBs

mfdb_load:

	lea	_contrl+14,a1		; a1 -> contrl[7]
	move.l (a0)+,(a1)+		; contrl[7] -> SRC MFDB
	move.l (a0)+,(a1)+		; contrl[8] -> DST MFDB
	rts



* in:
*	a0	pointer to ptsin array

set_pioff:

	move.l	(a0)+,pioff
	rts



* in:
*	d0	vdi op code

vdi_short:

	clr.l	-(sp)
	bra	vdi_sh


* in:
*	d0	offset into vdi_list

vdi_call:

	lea	vdi_list(pc,d0.w),a2

	clr.w	d0
	move.b	(a2)+,d0
	move.w	d0,-(sp)
	move.b	(a2)+,d0
	move.w	d0,-(sp)
	move.b	(a2)+,d0
vdi_sh:	move.w	d0,-(sp)

vdi_cont:

	jsr	_gsx_ncode
	addq.l	#6,sp
	move.l	#_ptsin,pioff		; some routines alter this pointer
	rts				; so we shall always reset it.

vdi_list:	

	dc.b	037,000,111		; GSX_MFS	vsc_form
	dc.b	011,000,001		; V_OPNWK	v_opnwk
	dc.b	001,002,129		; VST_CLP	vs_clip
	dc.b	000,001,012		; VST_HGT	vst_height
	dc.b	001,002,114		; VR_RECT	vr_recfl
	dc.b	001,004,109		; VRO_CPY	vro_cpyfm
	dc.b	003,004,121		; VRT_CPY	vrt_cpyfm
	dc.b	000,001,016		; VSL_WID	vsl_width


restable:
	.dc.w	0, 2, 5, 7, 3, 4, 6, 8, 9
restype:
	.dc.w	0, 1, 1, 1, 2, 3, 4, 5, 6


*\*	GEMGSXIF.C	05/06/84 - 02/17/85	Lee Lorenzen		*\
*\*	68k		02/20/85 - 03/25/85	Lowell Webster		*\
*\*	Reg Opt		03/09/85		Derek Mui		*\
*\*	speed bee	05/14/85		jim eisenstein		*\
*\*	Comment something out	07/11/85	Derek Mui		*\
*\*	6 resolutions	1/30/86			Derek Mui		*\
*\*	At gsx_wsopen, at gsx_malloc					*\
*\*	Store mouse addr at gsx_mfset	2/28/86	Derek Mui		*\
*\*	New flag to tell if the mouse is really on 3/3/86	D.Mui	*\
*\*	Take out save mouse address		1/7/87	Derek Mui	*\
*
*\*
**	-------------------------------------------------------------
**	GEM Application Environment Services		  Version 1.1
**	Serial No.  XXXX-0000-654321		  All Rights Reserved
**	Copyright (C) 1985			Digital Research Inc.
**	-------------------------------------------------------------
**\
*
*#include <portab.h>
*#include <machine.h>
*#include <obdefs.h>
*#include <gsxdefs.h>
*#include <bind.h>
*#include <funcdef.h>
*
*
*\*
**	Calls used in Crystal:
**
**	vsf_interior();
**	vr_recfl();
**	vst_height(); 
**	vsl_type();
**	vsl_udsty();
**	vsl_width();
**	v_pline();
**	vst_clip();
**	vex_butv();
**	vex_motv();
**	vex_curv();
**	vex_timv();
**	vr_cpyfm();
**	v_opnwk();
**	v_clswk();
**	vq_extnd();
**	v_clsvwk( handle )
**	v_opnvwk( pwork_in, phandle, pwork_out )
**\
*
*#if LINKED
*EXTERN	WORD	gl_restype;
*EXTERN WORD	gl_rschange;
*#endif
*						/* in GEMDOS.C		*\
*EXTERN LONG	dos_alloc();
*EXTERN WORD	dos_free();
*						/* in DOSIF.A86		*\
*EXTERN WORD	justretf();
*						/* in GSX2.A86		*\
*EXTERN		gsx2();
*EXTERN		i_ptsin();
*EXTERN		i_intin();
*EXTERN		i_ptsout();
*EXTERN		i_intout();
*EXTERN		i_ptr();
*EXTERN		i_ptr2();
*EXTERN		i_lptr1();	
*EXTERN		m_lptr2();
*						/* in OPTIMIZE.C	*\
*EXTERN WORD	max();
*EXTERN WORD	min();
*						/* in DOSIF.A86		*\
*EXTERN WORD	far_bcha();
*EXTERN WORD	far_mcha();
*EXTERN VOID	drawrat();
*EXTERN LONG	drwaddr;
*						/* in APGSXIF.C		*\
*EXTERN WORD	xrat, yrat, button;
*
*EXTERN WORD	gl_width;
*EXTERN WORD	gl_height;
*
*EXTERN WORD	gl_nrows;
*EXTERN WORD	gl_ncols;
*
*EXTERN WORD	gl_wchar;
*EXTERN WORD	gl_hchar;
*
*EXTERN WORD	gl_wschar;
*EXTERN WORD	gl_hschar;
*
*EXTERN WORD	gl_wptschar;
*EXTERN WORD	gl_hptschar;
*
*EXTERN WORD	gl_wsptschar;
*EXTERN WORD	gl_hsptschar;
*
*EXTERN WORD	gl_wbox;
*EXTERN WORD	gl_hbox;
*
*EXTERN WORD	gl_xclip;
*EXTERN WORD	gl_yclip;
*EXTERN WORD	gl_wclip;
*EXTERN WORD	gl_hclip;
*
*EXTERN WORD	gl_nplanes;
*EXTERN	WORD 	gl_handle;
*
*EXTERN FDB		gl_src;
*EXTERN FDB		gl_dst;
*
*EXTERN WS		gl_ws;
*EXTERN WORD		contrl[];
*EXTERN WORD		intin[];
*EXTERN WORD		ptsin[];
*EXTERN WORD		intout[];
*EXTERN WORD		ptsout[];
*EXTERN LONG		ad_intin;
*
*GLOBAL FDB		gl_tmp;
*
*GLOBAL LONG		old_mcode;
*GLOBAL LONG		old_bcode;
*GLOBAL WORD		gl_moff;		/* counting semaphore	*\
*						/*  == 0 implies ON	*\
*						/*  >  0 implies OFF	*\
*GLOBAL LONG		gl_mlen;
*GLOBAL WORD		gl_graphic;
*
*
*GLOBAL	WORD		gl_mouse;	/* mouse on flag		*\
*
*
*
*	WORD
*gsx_mfree()
*{
*	dos_free(gl_tmp.fd_addr);
*}
*
*
*	VOID
*gsx_mret(pmaddr, pmlen)
*	LONG		*pmaddr;
*	LONG		*pmlen;
*{
*	*pmaddr = gl_tmp.fd_addr;
*	*pmlen = gl_mlen;
*}
*
*gsx_ncode(code, n, m)
*	WORD		code;
*	WORD		n, m;
*{
*	REG WORD		*pctrl;
*	pctrl = &contrl[0];
*
*	pctrl[0] = code;
*	pctrl[1] = n;
*	pctrl[3] = m;
*	pctrl[6] = gl_handle;
*	gsx2();
*}
*
*
*gsx_1code(code, value)
*	WORD		code;
*	WORD		value;
*{
*	intin[0] = value;
*	gsx_ncode(code, 0, 1);
*}
*
*
*	WORD
*gsx_init()
*{
*	gsx_wsopen();
*	gsx_start();
*	gsx_setmb(&far_bcha, &far_mcha, &drwaddr);
*	gsx_ncode(MOUSE_ST, 0, 0);
*	xrat = ptsout[0];
*	yrat = ptsout[1];
*}
*
*
*	WORD
*gsx_graphic(tographic)
*	REG WORD		tographic;
*{
*	if (gl_graphic != tographic)
*	{
*	  gl_graphic = tographic;
*	  if (gl_graphic)
*	  {
*	    gsx_escapes(2);
*	    gsx_setmb(&far_bcha, &far_mcha, &drwaddr);
*	  }
*	  else
*	  {
*	    gsx_escapes(3);
*	    gsx_resetmb();
*	  }
*	}
*}
*
*	VOID
*gsx_escapes(esc_code)
*	WORD	esc_code;
*{
*	contrl[5] = esc_code;
*	gsx_ncode(5, 0, 0);
*}
*
*	VOID
*v_hardcopy()
*{
*	gsx_escapes(17);
*}
*
*
*	WORD
*gsx_wsopen()
*{
*	REG WORD		i;
*
*	for(i=0; i<10; i++)
*	  intin[i] = 1;
*	intin[10] = 2;			/* device coordinate space *\
*#if LINKED
*	intin[0] = gl_restype;
*#endif
*	v_opnwk( &intin[0], &gl_handle, &gl_ws );
*#if MULRES
*	  if (gl_ws.ws_yres == 400-1)	/*  X     Y	*\
*	    gl_restype = 4;		/* 640 x 400	*\
*	  else
*	  if (gl_ws.ws_yres == 960-1)
*	    gl_restype = 7;		/* 1280 x 960	*\
*	  else
*	  if (gl_ws.ws_yres == 480-1)
*	  {
*	     if (gl_ws.ws_xres == 640-1)
*	       gl_restype = 6;		/* 640 x 480	*\
*	     else
*	       gl_restype = 5;		/* 320 x 480	*\
*	  }
*	  else
*	  {
*	     if (gl_ws.ws_xres == 640-1)
*		gl_restype = 3;		/* 640 x 200	*\
*	     else
*		gl_restype = 2;		/* 320 x 200	*\
*	  }	
*	  gl_rschange = FALSE;
*
*#else
*	if (gl_ws.ws_xres == 320 - 1)
*	   gl_restype = 2;
*	else if (gl_ws.ws_yres == 400 -1)
*	   gl_restype = 4;
*	else
*	   gl_restype = 3;
*
*	gl_rschange = FALSE;
*
*#endif
*	gl_graphic = TRUE;
*}
*
*
*	VOID
*gsx_wsclose()
*{
*	gsx_ncode(CLOSE_WORKSTATION, 0, 0);
*}
*
*	WORD
*ratinit()
*{
*	gsx_1code(SHOW_CUR, 0);
*	gl_moff = 0;
*}
*
*
*	WORD
*ratexit()
*{
*	gsx_moff();
*}
*
*
*bb_set(sx, sy, sw, sh, pts1, pts2, pfd, psrc, pdst)
*	REG WORD		sx, sy, sw, sh;
*	REG WORD		*pts1, *pts2;
*	FDB		*pfd;
*	FDB		*psrc, *pdst;
*{
*	WORD		oldsx;
*
*						/* get on word boundary	*\
*	oldsx = sx;
*	sx = (sx / 16) * 16;
*	sw = ( ((oldsx - sx) + (sw + 15)) / 16 ) * 16;
*
*	gl_tmp.fd_stand = TRUE;
*	gl_tmp.fd_wdwidth = sw / 16;
*	gl_tmp.fd_w = sw;
*	gl_tmp.fd_h = sh;
*	
*	gsx_moff();
*	pts1[0] = sx;
*	pts1[1] = sy;
*	pts1[2] = sx + sw - 1;
*	pts1[3] = sy + sh - 1;
*	pts2[0] = 0;
*	pts2[1] = 0;
*	pts2[2] = sw - 1;
*	pts2[3] = sh - 1 ;
*
*	gsx_fix(pfd, 0, 0, 0, 0);
*	vro_cpyfm( S_ONLY, &ptsin[0], psrc, pdst );
*	gsx_mon();
*}
*
*
*	VOID
*bb_save(ps)
*	REG GRECT		*ps;
*{	
*	bb_set(ps->g_x, ps->g_y, ps->g_w, ps->g_h, &ptsin[0], &ptsin[4], 
*		&gl_src, &gl_src, &gl_tmp);
*}
*
*
*	VOID
*bb_restore(pr)
*	REG GRECT		*pr;
*{
*	bb_set(pr->g_x, pr->g_y, pr->g_w, pr->g_h, &ptsin[4], &ptsin[0], 
*		&gl_dst, &gl_tmp, &gl_dst);
*}
*
*
*	WORD
*gsx_setmb(boff, moff, pdrwaddr)
*	UWORD		*boff, *moff;
*	LONG		*pdrwaddr;
*{
*	i_lptr1( boff, 0x0 );	
*	gsx_ncode(BUT_VECX, 0, 0);
*	m_lptr2( &old_bcode );
*
*	i_lptr1( moff, 0x0 );	
*	gsx_ncode(MOT_VECX, 0, 0);
*	m_lptr2( &old_mcode );
*
*\*	i_lptr1( justretf, 0x0 );	
*	gsx_ncode(CUR_VECX, 0, 0);
*	m_lptr2( pdrwaddr );		don't intercept draw vector *\
*}
*
*
*	WORD
*gsx_resetmb()
*{
*	i_lptr1( old_bcode );	
*	gsx_ncode(BUT_VECX, 0, 0);
*
*	i_lptr1( old_mcode );
*	gsx_ncode(MOT_VECX, 0, 0);
*
*\*	i_lptr1( drwaddr );	
*	gsx_ncode(CUR_VECX, 0, 0);     dont' replace cursor draw vector *\
*}
*
*	WORD
*gsx_tick(tcode, ptsave)
*	LONG		tcode;
*	LONG		*ptsave;
*{
*	i_lptr1( tcode );	
*	gsx_ncode(TIM_VECX, 0, 0);
*	m_lptr2( ptsave );
*	return(intout[0]);
*}
*
*
*	WORD
*gsx_mfset(pmfnew)
*	LONG		pmfnew;
*{
*	gsx_moff();
*	LWCOPY(ad_intin, pmfnew, 37);
* 	gsx_ncode(ST_CUR_FORM, 0, 37);
*	gsx_mon();
*}
*
*
*	VOID
*gsx_mxmy(pmx, pmy)
*	WORD		*pmx, *pmy;
*{
*	*pmx = xrat;
*	*pmy = yrat;
*}
*
*
*	WORD
*gsx_button()
*{
*	return( button );
*}
*
*\*
*	WORD
*gsx_kstate()
*{
*	gsx_ncode(KEY_SHST, 0, 0);
*	return(intout[0]);
*}
**\
*
*	VOID
*gsx_moff()
*{
*	if (!gl_moff)
*	{
*	  gsx_ncode(HIDE_CUR, 0, 0);
*	  gl_mouse = FALSE;
*	}
*
*	gl_moff++;
*}
*
*
*	VOID
*gsx_mon()
*{
*	gl_moff--;
*	if (!gl_moff)
*	{
*	  gsx_1code(SHOW_CUR, 1);
*	  gl_mouse = TRUE ;
*	}
*}
*
*
*\*
*	WORD
*gsx_char()
*{
*	REG WORD		*pintin;
*	REG WORD		*pintout;
*	pintin = &intin[0];
*	pintout = &intout[0];
*
*	pintin[0] = 4;
*	pintin[1] = 2;
*	gsx_ncode(33, 0, 2);
*
*
*	pintin[0] = -1;
*	pintin[1] = FALSE;
*	gsx_ncode(31, FALSE, 2);
*	if (contrl[4])
*	  return(pintout[0]);
*	else
*	  return(0);
*
*}
**\
*
*	WORD
*v_opnwk( pwork_in, phandle, pwork_out )
*	WORD	*pwork_in;
*REG	WORD	*pwork_out;
*	WORD	*phandle;
*{
*	WORD	*ptsptr;
*
*	ptsptr = pwork_out + 45;
*	i_ptsout( ptsptr );	/* set ptsout to work_out array *\
*	i_intin( pwork_in );	/* set intin to point to callers data  *\
*	i_intout( pwork_out );	/* set intout to point to callers data *\
*	gsx_ncode(OPEN_WORKSTATION, 0, 11);
*
*	*phandle = contrl[6];	
*	i_intin( &intin );
*	i_intout( &intout );
* 	i_ptsin( &ptsin );
*	i_ptsout( &ptsout );
*}
*
*	WORD
*v_pline( count, pxyarray )
*	WORD	count;
*	WORD	*pxyarray;
*{
*	i_ptsin( pxyarray );
*	gsx_ncode(POLYLINE, count, 0);
*	i_ptsin( &ptsin );
*}
*
*
*	WORD
*vst_clip( clip_flag, pxyarray )
*	REG WORD	clip_flag;
*	WORD	*pxyarray;
*{
*	WORD		tmp, value;
*
*	value = ( clip_flag != 0 ) ? 2 : 0;
*	i_ptsin( pxyarray );
*	intin[0] = clip_flag;
*	gsx_ncode(TEXT_CLIP, value, 1);
*	i_ptsin(&ptsin);
*}
*
*
*vst_height( height, pchr_width, pchr_height, pcell_width, pcell_height )
*	WORD	height;
*	WORD	*pchr_width;
*	WORD	*pchr_height;
*	WORD	*pcell_width;
*	WORD	*pcell_height;
*{
*	REG WORD		*ppts;
*	ppts = &ptsout[0];
*
*	ptsin[0] = 0;
*	ptsin[1] = height;
*	gsx_ncode(CHAR_HEIGHT, 1, 0);
*	*pchr_width = ppts[0];
*	*pchr_height = ppts[1];
*	*pcell_width = ppts[2];
*	*pcell_height = ppts[3];
*}
*
*
*	VOID
*vr_recfl( pxyarray, pdesMFDB )
*	WORD	*pxyarray;
*	WORD	*pdesMFDB;
*{
*	i_ptr( pdesMFDB );
*	i_ptsin( pxyarray );
*	gsx_ncode(FILL_RECTANGLE, 2, 1);
*	i_ptsin( &ptsin );
*}
*
*
*	VOID
*vro_cpyfm( wr_mode, pxyarray, psrcMFDB, pdesMFDB, )
*	WORD	wr_mode;
*	WORD	*pxyarray;
*	WORD	*psrcMFDB;
*	WORD	*pdesMFDB;
*{
*	intin[0] = wr_mode;
*	i_ptr( psrcMFDB );
*	i_ptr2( pdesMFDB );
*	i_ptsin( pxyarray );
*	gsx_ncode(COPY_RASTER_FORM, 4, 1);
*	i_ptsin( &ptsin );
*}
*
*
*    WORD
*vrt_cpyfm( wr_mode, pxyarray, psrcMFDB, pdesMFDB, fgcolor, bgcolor )
*	WORD    wr_mode;
*	WORD    *pxyarray;
*	WORD    *psrcMFDB;
*	WORD    *pdesMFDB;
*	WORD	fgcolor, bgcolor;
*{
*	REG WORD		*pintin;
*	pintin = &intin[0];
*
*	pintin[0] = wr_mode;
*	pintin[1] = fgcolor;
*	pintin[2] = bgcolor;
*	i_ptr( psrcMFDB );
*	i_ptr2( pdesMFDB );
*	i_ptsin( pxyarray );
*	gsx_ncode(121, 4, 3);
*	i_ptsin( &ptsin );
*}
*
*
*	VOID
*vrn_trnfm( psrcMFDB, pdesMFDB )
*	WORD	*psrcMFDB;
*	WORD	*pdesMFDB;
*{
*	i_ptr( psrcMFDB );
*	i_ptr2( pdesMFDB );
*	gsx_ncode(TRANSFORM_FORM, 0, 0);
*}
*
*
*	VOID
*vsl_width( width )
*	WORD	width;
*{
*	ptsin[0] = width;
*	ptsin[1] = 0;
*	gsx_ncode(S_LINE_WIDTH, 1, 0);
*}
*
