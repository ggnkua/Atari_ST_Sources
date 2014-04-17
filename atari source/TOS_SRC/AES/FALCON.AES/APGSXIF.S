*************************************************************************
*			Revision Control System
* =======================================================================
*  $Revision: 2.3 $	$Source: /u2/MRS/osrevisions/aes/apgsxif.s,v $
* =======================================================================
*  $Author: kbad $	$Date: 89/07/27 03:18:58 $	$Locker: kbad $
* =======================================================================
*  $Log:	apgsxif.s,v $
* Revision 2.3  89/07/27  03:18:58  kbad
* gsx_start: force gl_wbox > gl_wchar+2
* 
* Revision 2.2  89/04/26  18:06:48  mui
* aes30
* 
* Revision 2.1  89/02/22  05:14:52  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
* Revision 1.1  88/06/02  12:26:09  lozben
* Initial revision
* 
*************************************************************************
*
*	Crunched 	2/2/87 		JE
*
*	Change at gsx_start for new pixel ratio	7/26/89	D.Mui
* 	Assemble with MAS 900801 kbad
*	Change at gsx_start to do inquire of number planes 7/7/92	D.Mui

	.globl	_vst_cli,_v_pline,_vrt_cpy,_vro_cpy
	.globl	_vrn_trn,_vst_height,_vsl_width,_vr_recfl
	.globl	_gsx2,_gsx_moff,_gsx_mon,_gsx_ncode,_gsx_1code,_LBWMOV

	.globl	_xrat,_yrat,_button

	.globl	_gl_width
	.comm	_gl_width,2
	.globl	_gl_heigh
	.comm	_gl_heigh,2
	.globl	_gl_nrows
	.comm	_gl_nrows,2
	.globl	_gl_ncols
	.comm	_gl_ncols,2
	.globl	_gl_wchar
	.comm	_gl_wchar,2
	.globl	_gl_hchar
	.comm	_gl_hchar,2
	.globl	_gl_wscha
	.comm	_gl_wscha,2
	.globl	_gl_hscha
	.comm	_gl_hscha,2
	.globl	_gl_wptsc
	.comm	_gl_wptsc,2
	.globl	_gl_hptsc
	.comm	_gl_hptsc,2
	.globl	_gl_wspts
	.comm	_gl_wspts,2
	.globl	_gl_hspts
	.comm	_gl_hspts,2
	.globl	_gl_wbox
	.comm	_gl_wbox,2
	.globl	_gl_hbox
	.comm	_gl_hbox,2
	.globl	_gl_xclip
	.comm	_gl_xclip,2
	.globl	_gl_yclip
	.comm	_gl_yclip,2
	.globl	_gl_wclip
	.comm	_gl_wclip,2
	.globl	_gl_hclip
	.comm	_gl_hclip,2
	.globl	_gl_nplan
	.comm	_gl_nplan,2
	.globl	_gl_handl
	.comm	_gl_handl,2
	.globl	_gl_src
	.comm	_gl_src,20
	.globl	_gl_dst
	.comm	_gl_dst,20
	.globl	_gl_ws
	.comm	_gl_ws,114
	.globl	_contrl
	.comm	_contrl,24
	.globl	_intin
	.comm	_intin,256
	.globl	_ptsin
	.comm	_ptsin,40
	.globl	_intout
	.comm	_intout,20
	.globl	_ptsout
	.comm	_ptsout,20
	.globl	_ad_intin
	.comm	_ad_intin,4
	.globl	_gl_mode
	.comm	_gl_mode,2
	.globl	_gl_mask
	.comm	_gl_mask,2
	.globl	_gl_tcolo
	.comm	_gl_tcolo,2
	.globl	_gl_lcolo
	.comm	_gl_lcolo,2
	.globl	_gl_fis
	.comm	_gl_fis,2
	.globl	_gl_patt
	.comm	_gl_patt,2
	.globl	_gl_font
	.comm	_gl_font,2
	.globl	_gl_rscre
	.comm	_gl_rscre,8
	.globl	_gl_rfull
	.comm	_gl_rfull,8
	.globl	_gl_rzero
	.comm	_gl_rzero,8
	.globl	_gl_rcent
	.comm	_gl_rcent,8
	.globl	_gl_rmenu
	.comm	_gl_rmenu,8
	
IBM	equ	3
SMALL	equ	5


	.globl _gsx_scli

*  call:
*
*	gsx_sclip(pt)
*
*		pt	pointer to GRECT
*
*  in:
*	sp+04	pt

_gsx_scli:

	move.l	4(sp),a0		; a0 -> pt
	move.l	a0,a1			; a1 -> pt

	lea	_ptsin,a2		; a2 -> ptsin[0]
	pea	(a2)			; push it (for vst_clip)
	clr.w	d0			; d0 <- FALSE

*	the moral equivalent of an r_get

	move.w	(a0)+,_gl_xclip		; gl_xclip <- pt->g_x
	move.w	(a0)+,_gl_yclip		; gl_yclip <- pt->g_y
	move.w	(a0)+,_gl_wclip		; gl_wclip <- pt->g_w
	move.w	(a0)+,_gl_hclip		; gl_hclip <- pt->g_h

	beq	L4
	tst.w	_gl_wclip
	beq	L4

	move.l	(a1),(a2)+		; ptsin[0] <- x     ptsin[1] <- y
	move.l	(a1)+,(a2)		; ptsin[2] <- x     ptsin[3] <- y
	move.w	(a1)+,d0		; d0       <-   w
	subq.w	#1,d0			; d0       <-   w-1
	add.w	d0,(a2)+		; ptsin[2] <- x+w-1
	move.w	(a1)+,d0		; d0       <-   h
	subq.w	#1,d0			; d0       <-   h-1
	add.w	d0,(a2)+		; ptsin[3] <- y+h-1

	moveq.l	#1,d0			; d0 <- TRUE

L4:	move.w	d0,-(sp)
	jsr	_vst_cli
	addq.l	#6,sp			; *CS* restore the stack

	moveq.l	#1,d0			; return(TRUE)
	rts



	.globl _gsx_gcli

*  call:
*
*	gsx_gcli(pt)
*
*  in:
*	sp+04	pt	long pointer to GRECT

_gsx_gcli:

	move.l	4(sp),a0		; a0 -> pt
	move.w	_gl_xclip,(a0)+		; pt->g_x <- gl_xclip
	move.w	_gl_yclip,(a0)+
	move.w	_gl_wclip,(a0)+
	move.w	_gl_hclip,(a0)+
	rts


	.globl _gsx_chkc

*  call:
*
*	gsx_chkc(pt)
*
*  in:
*	sp+04	pt	long pointer to GRECT

_gsx_chkc:

	move.w	_gl_wclip,d1		; d1 <- gl_wclip
	beq	L9
	move.w	_gl_hclip,d2		; d2 <- gl_yclip
	beq	L9			; gl_wclip=0 or gl_hclip=0 => ret TRUE

	move.l	4(sp),a0
	lea	_gl_xclip,a1		; a1 -> gl_xclip
	lea	_gl_yclip,a2		; a2 -> gl_yclip

	move.w	(a0)+,d0		; d0 <- pt->g_x
	add.w	(a1),d1			; d1 <- gl_xclip + gl_wclip
	cmp.w	d1,d0			; if  ((gl_xclip + gl_wclip)) <= g_x)
	bge	L10			; return(FALSE)

	move.w	(a0)+,d1		; d1 <- pt->g_y
	add.w	(a2),d2			; d2 <- gl_yclip + gl_hclip
	cmp.w	d2,d1			; if  ((gl_yclip + gl_hclip)) <= g_y)
	bge	L10			; return(FALSE)

	add.w	(a0)+,d0		; d0 <- pt->g_x + pt->g_w
	cmp.w	(a1),d0			; if  ((pt->g_x + pt->g_w) < gl_xclip)
	blt	L10			; return(FALSE)

	add.w	(a0)+,d1		; d1 <- pt->g_y + pt->g_h
	cmp.w	(a2),d1			; if  ((pt->g_y + pt->g_h) < gl_yclip)
	blt	L10			; return(FALSE)

L9:	moveq.l	#1,d0			; return(TRUE)
	rts

L10:	moveq.l	#0,d0			; return(FALSE)
	rts



	.globl	_gsx_plin

*  call:
*
*	gsx_pline(xoff, yoff, cnt, pts)
*
*  in:
*	sp+04	xoff		word
*	  +06	yoff		word
*	  +08	cnt		word	number of points
*	  +10	pts		long 	pointer to array of points

_gsx_plin:

	lea	4(sp),a0
	move.w	(a0)+,d0		; d0 <- X offset
	move.w	(a0)+,d1		; d1 <- Y offset
	move.w	(a0)+,d2		; d2 <- point count
	move.l	(a0)+,a1		; a1 -> array of points

	lea	_ptsin,a0		; a0 -> ptsin[0]

	move.l	a0,-(sp)		; set up gsx_xline call
	move.w	d2,-(sp)		; ahead of time

	bra	L13

L12:	move.l	(a1)+,(a0)		; ptsin[2*i]   <- pts[2*i]   + xoff
	add.w	d0,(a0)+		; ptsin[2*i+1] <- pts[2*i+1] + yoff
	add.w	d1,(a0)+

L13:	subq.w	#1,d2			; for (i=0; i<cnt; i++)
	bge	L12			; this is a reasonable substitution

	bsr	_gsx_xline
	addq.l	#6,sp
	rts



	.globl	_gsx_clin

*  call:
*
*	gsx_cline(x1, y1, x2, y2)
*
*  in:
*	sp+04	x1		word
*	  +06	y1		word
*	  +08	x2		word
*	  +10	y2		word

_gsx_clin:

	jsr	_gsx_moff

	lea	4(sp),a0		; a0 -> x1
	move.l	a0,-(sp)		; push pointer to verticies
	move.w	#2,-(sp)		; push the count
	jsr	_v_pline		; draw the line
	addq.l	#6,sp			; clean up the stack

	jsr	_gsx_mon		; show mouse cursor

	rts

	.globl _gsx_attr

*  call:
*
*	gsx_attr(text, mode, color)
*
*  in:
*	sp+04	text		word
*	  +06	mode		word
*	  +08	color		word

_gsx_attr:

	lea	4(sp),a0		; a0 -> parameters
	movem.l	d3-d4/a3-a4,-(sp)

	lea	_intin,a3		; a3 ->  intin[0]
	lea	_contrl,a4		; a4 -> contrl[0]

	move.w	(a3),-(sp)		; save intin[0]

	move.w	(a0)+,d3		; d3 <- text
	move.w	(a0)+,d0		; d0 <- mode
	move.w	(a0)+,d4		; d4 <- color

	clr.w	          02(a4)	; contrl[1] <- 0
	move.w	       #1,06(a4)	; contrl[3] <- 1
	move.w	_gl_handl,12(a4)	; contrl[6] <- gl_handle

	lea	_gl_mode,a0		; skip this call if the requested
	cmp.w	(a0),d0			; mode is the same as the currently
	beq	L18			; selected mode

	move.w	#32,(a4)		; contrl[0] <- SET_WRITING_MODE
	move.w	 d0,(a3)		;  intin[0] <- mode
	move.w	 d0,(a0)		;   gl_mode <- mode
	jsr	_gsx2

L18:	tst.w	d3			; text=1 => text color
	beq	L19			; text=0 => line color

	lea	_gl_tcolo,a0		; if requested text color is the same
	cmp.w	(a0),d4			; as the current text color, don't
	beq	L21			; waste time with the VDI call

	moveq.l	#22,d0			; d0 <- SET_TEXT_COLOR
	bra	L20

L19:	lea	_gl_lcolo,a0		; if the requested line color matches
	cmp.w	(a0),d4			; the current default line color,
	beq	L21			; skip the VDI call to reset it.

	moveq.l	#17,d0			; d0 <- SET_LINE_COLOR

L20:	move.w	d0,(a4)			;    contrl[0] <- op code
	move.w	d4,(a3)			;     intin[0] <- color
	move.w	d4,(a0)			; set gl_tcolor or gl_lcolor
	jsr	_gsx2

L21:	move.w	(sp)+,(a3)		; restore intin[0]
	movem.l	(sp)+,d3-d4/a3-a4	; *CS*
	rts


	.globl _gsx_bxpt

*  call:
*
*	gsx_bxpt(pt)
*
*  in:
*	sp+04	pt	long pointer to GRECT

_gsx_bxpt:

	move.l	4(sp),a0		; a0 -> GRECT

	move.l	(a0)+,d0		; d0[31:16] <- x      d0[15:00] <- y
	move.w	(a0)+,d1
	subq.w	#1,d1			; d1[15:00] <- w-1
	move.w	(a0)+,d2		
	subq.w	#1,d2			; d2[15:00] <- h-1

	lea	_ptsin,a1		; a1 -> ptsin[0]

	move.l	   d0,(a1)+		; ptsin[0] <- x       ptsin[1] <- y  
	move.l	   d0,(a1)		; ptsin[2] <- x       ptsin[3] <- y 
	add.w	   d1,(a1)		; ptsin[2] <- x+w-1
	move.l	(a1)+,(a1)+		; ptsin[4] <- x+w-1   ptsin[5] <- y
	move.l	   d0,(a1)		; ptsin[6] <- x       ptsin[7] <- y
	add.w	  d2,-(a1)		;                     ptsin[5] <- y+h-1
	move.l	(a1)+,(a1)+		; ptsin[8] <- x       ptsin[7] <- y+h-1
	move.w	   d0,(a1)		;                     ptsin[9] <- y
	
	rts


	.globl	_gsx_box

*  call:
*
*	gsx_box(pt)
*
*  in:
*	sp+04	pt	long pointer to GRECT

_gsx_box:

	move.l	4(sp),-(sp)
	bsr	_gsx_bxpt

	move.l	#_ptsin,(sp)
	move.w	#5,-(sp)
	jsr	_v_pline
	addq.l	#6,sp

	rts



	.globl _gsx_fix

*  call:
*
*	gsx_fix(pfd, theaddr, wb, h)
*
*  in:
*	sp+04	    pfd		long pointer to MFDB
*	  +08   theaddr		long
*	  +12	     wb		word
*	  +14	      h		word

_gsx_fix:

	lea	4(sp),a0

	lea	_gl_ws,a1
	move.l	(a0)+,a2		; a2 -> pfd
	move.l	(a0)+,(a2)+		; pfd->fd_addr <- theaddr
	bne	L29			; jump if theaddr=0

	move.w	(a1)+,d0
	addq.w	#1,d0			; d0 <- gl_ws.ws_xres +1
	move.w	d0,(a2)+		; pfd->fd_w = gl_ws.ws_xres +1

	move.w	(a1)+,(a2)
	addq.w	#1,(a2)+		; pfd->fd_h = gl_ws.ws_yres +1

	lsr.w	#4,d0			; d0 <- (gl_ws.ws_xres +1) / 16
	move.w	d0,(a2)+		; pfd->fd_wdwidth = pfd->fd_w / 16

	clr.w	(a2)+			; pfd->fd_stand = FALSE
	move.w	_gl_nplan,(a2)		; pfd->fd_nplanes = gl_nplanes

	rts


L29:	move.w	(a0)+,d0		; d0 <- wb
	lsl.w	#3,d0			; d0 <- wb * 8
	move.w	d0,(a2)+		; pfd->fd_w = wb * 8

	move.w	(a0)+,(a2)+		; pfd->fd_h = h

	lsr.w	#4,d0			; d0 <- (wb * 8) / 16
	move.w	d0,(a2)+		; pfd->fd_wdwidth = pfd->fd_w / 2

	clr.w	(a2)+			; pfd->fd_stand = FALSE
	move.w	#1,(a2)			; pfd->fd_nplanes = 1

	rts



	.globl	_gsx_blt

*  call:
*
*     gsx_blt(saddr, sx, sy, swb, daddr, dx, dy, dwb, w, h, rule, fgcol, bgcol)
*
*  in:
*	sp+04	saddr		long
*	  +08	   sx		word
*	  +10	   sy		word
*	  +12	  swb		word
*	  +14	daddr		long
*	  +18	   dx		word
*	  +20	   dy		word
*	  +22	  dwb		word
*	  +24	    w		word
*	  +26	    h		word
*	  +28	 rule		word
*	  +30	fgcol		word
*	  +32	bgcol		word

_gsx_blt:

	movem.l	d3-d4/a3-a5,-(sp)
	lea	20+4(sp),a3
	lea	 _gl_src,a4
	lea	 _gl_dst,a5		; *CS*

	move.w	22(a3),d3		; d3 <- h
	
	move.w	d3,-(sp)		; push h
	move.l	(a3)+,a0		; *CS*   a0 <- saddr
	move.l	(a3)+,d4		; d4[31:16] <- sx    d4[15:00] <- sy
	move.w	(a3)+,-(sp)		; push swb
	pea	(a0)			; push saddr
	pea	(a4)			; push *gl_src
	bsr	_gsx_fix

	jsr	_gsx_moff		; hide cursor

	move.w	d3,(sp)			; push h
	move.l	(a3)+,a0		; *CS*   a0 <- daddr
	move.l	(a3)+,d3		; d3[31:16] <- dx    d3[15:00] <- dy
	move.w	(a3)+,-(sp)		; push dwb
	pea	(a0)			; push daddr
	pea	(a5)			; push *gl_dst
	bsr	_gsx_fix

	lea	_ptsin,a0
	move.l	a0,a1
	move.w	(a3)+,d0
	subq.w	#1,d0			; d0 <- w - 1
	move.w	(a3)+,d1
	subq.w	#1,d1			; d1 <- h - 1

	move.l	d4,(a0)+		; ptsin[0] <- sx
	move.l	d4,(a0)			; ptsin[1] <- sy
	add.w	d0,(a0)+		; ptsin[2] <- sx + w - 1
	add.w	d1,(a0)+		; ptsin[3] <- sy + h - 1
	move.l	d3,(a0)+		; ptsin[1] <- dx
	move.l	d3,(a0)			; ptsin[1] <- dy
	add.w	d0,(a0)+		; ptsin[1] <- dx + w - 1
	add.w	d1,(a0)+		; ptsin[1] <- dy + h - 1

	move.w	(a3)+,d0		; d0 <- logic op

	move.l	(a3),(sp)		; push  bgcol   then   push fgcol
	pea	(a5)			; push *gl_dst
	pea	(a4)			; push *gl_src
	pea	(a1)			; push *ptsin
	move.w	d0,-(sp)		; push  logic op

	cmp.w	#-1,(a3)
	beq	L32			; *CS* from bne

	jsr	_vrt_cpy
	bra	L33
	
L32:	jsr	_vro_cpy

L33:	jsr	_gsx_mon		; show cursor

	lea	36(sp),sp
	movem.l	(sp)+,d3-d4/a3-a5
	rts



	.globl _bb_scree

*  call:
*
*	bb_screen(scrule, scsx, scsy, scdx, scdy, scw, sch)
*
*  in:
*	sp+04	scrule		word
*         +06	scsx		word
*         +08	scsy		word
*         +10	scdx		word
*         +12	scdy		word
*         +14	scw		word
*         +16	sch		word

_bb_scree:

	lea	14(sp),a0		; a0 -> scw

	moveq.l	 #-1,d0
	move.l	     d0,-(sp)		; push -1     then    push -1
	move.w	-10(a0),-(sp)		; push scrule
	move.l	   (a0),-(sp)		; push sch    then    push scw
	clr.w	        -(sp)		; push 0
	move.l	  -(a0),-(sp)		; push scdy   then    push scdx
	clr.l	        -(sp)		; push 0x0L
	clr.w	        -(sp)		; push 0
	move.l	  -(a0),-(sp)		; push scsy   then    push scsx
	clr.l	        -(sp)		; push 0x0L
	jsr	_gsx_blt

	lea	30(sp),sp
	rts


	.globl _gsx_tran

*  call:
*
*	gsx_trans(saddr, swb, daddr, dwb, h)
*
*  in:
*	sp+04	saddr		long
*	sp+08	  swb		word (unsigned)
*	sp+10	daddr		long
*	sp+14	  dwb		word (unsigned)
*	sp+16	    h		word

_gsx_tran:

	movem.l a3-a5,-(sp)
	lea	12+16(sp),a3		; a3 -> h

	move.w	   (a3),d3		; d3 <- h
	lea	_gl_src,a4		; a4 -> gl_src
	lea	_gl_dst,a5		; a5 -> gl_dst

	move.w	   d3,-(sp)		; push h
	move.w	-(a3),-(sp)		; push dwb
	move.l	-(a3),-(sp)		; push daddr
	pea	 (a5)			; push gl_dst
	bsr	_gsx_fix

	move.w	   d3,-(sp)		; push h
	move.w	-(a3),-(sp)		; push swb
	move.l	-(a3),-(sp)		; push saddr
	pea	 (a4)			; push gl_src
	bsr	_gsx_fix

	move.l	#$00010001,10(a4)	; gl_src.fd_stand=gl_src.fd_nplanes=1 

	pea	(a5)			; push gl_dst
	pea	(a4)			; push gl_src
	jsr	_vrn_trn

	lea	32(sp),sp
	movem.l	(sp)+,a3-a5
	rts



	.globl _gsx_star

*  call:
*
*	gsx_start()

_gsx_star:

	movem.l	d3-d6,-(sp)

	moveq.l	#-1,d0
	move.w	d0,_gl_lcolo
	move.w	d0,_gl_tcolo
	move.w	d0,_gl_mask
	move.w	d0,_gl_mode
	move.w	d0,_gl_font
	move.w	d0,_gl_patt
	move.w	d0,_gl_fis

	clr.w	_gl_xclip
	clr.w	_gl_yclip

	lea	_gl_ws,a3

	move.w	(a3)+,d3
	addq.w	#1,d3
	move.w	d3,_gl_wclip
	move.w	d3,_gl_width		; d3 = gl_width

	move.w	(a3)+,d4
	addq.w	#1,d4
	move.w	d4,_gl_hclip
	move.w	d4,_gl_heigh		; d4 = gl_height

	lea	_intin,a0
	move.w	#1,(a0)			; intin[0] = 1

	move.w	#1,-(sp)		; gsx_ncode( 102,0,1)
	clr.w	-(sp)
	move.w	#102,-(sp)
	jsr	_gsx_ncode
	addq.l	#6,sp
	lea	_intout,a0	
	move.w	8(a0),_gl_nplan		; gl_nplanes = intout[4]

	clr.l	    -(sp)		; gsx_ncode(38, 0, 0)
	move.w	#38,-(sp)		; inquire text attributes
	jsr	_gsx_ncode

	lea	_ptsout,a1
	move.w	(a1)+,_gl_wptsc		; gl_wptschar  <- ptsout[0]
	move.w	(a1),92(a3)		; gl_ws.chmaxh <- ptsout[1]
	move.w	(a1)+,_gl_hptsc		; gl_hptschar  <- ptsout[1]
	move.w	(a1)+,d5		; gl_wchar     <- ptsout[2]
	move.w	d5,_gl_wchar		; gl_wchar = d5    
	move.w	(a1)+,d6		; gl_hchar     <- ptsout[3]
	move.w	d6,_gl_hchar		; gl_hchar = d6

	pea	_gl_hscha
	pea	_gl_wscha
	pea	_gl_hspts
	pea	_gl_wspts
	move.w	88(a3),-(sp)		; push	gl_ws.ws_chminh
	jsr	_vst_height

	lea	(sp),a0			; a0 -> dummy variable
	pea	(a0)
	pea	(a0)
	pea	(a0)
	pea	(a0)
	move.w	92(a3),-(sp)
	jsr	_vst_height

	move.w	d3,d0			; d0 <- gl_width
	ext.l	d0
	divs	d5,d0			; d0 <- gl_width / gl_wchar
	move.w	d0,_gl_ncols

	move.w	d4,d0			; d0 <- gl_height
	ext.l	d0
	divs	d6,d0			; d0 <- gl_height / gl_hchar
	move.w	d0,_gl_nrows

	addq.w	#3,d6			; d6 <- gl_hbox = gl_height+3
	move.w	d6,_gl_hbox

	addq	#2,a3			; CS -  bump up to next entry
	move.w	(a3)+,d0		; d0 <- gl_ws.ws_wpixel
	move.w	(a3)+,d5		; d5 <- gl_ws.ws_hpixel
	muls	d6,d5			; d5 <- gl_ws.ws_hpixel * gl_hbox
	divs	d0,d5			; d5 <- gl_wbox
	move.w	d5,_gl_wbox

	move.w	d5,d0			; d0 <- gl_wbox
	sub.w	#2,d0
	cmp.w	_gl_wchar,d0		; gl_wbox must >= gl_wchar + 2 
	bge	x_x1
	move.w	_gl_wchar,d5
	add.w	#2,d5
	move.w	d5,_gl_wbox

x_x1:	pea	$000F0007		;  (sp) <- 15
	jsr	_gsx_1code		; 2(sp) <-  7

	move.w	#1,(sp)
	jsr	_vsl_width
	
	pea	$0071FFFF		;  (sp) <- 113
	jsr	_gsx_1code		; 2(sp) <-  -1

	lea	_gl_rscre,a0		; r_set( &gl_rscreen,...)
	clr.l	   (a0)+		; g_x <- 0	   g_y <- 0
	move.w	d3,(a0)+		; g_w <- gl_width
	move.w	d4,(a0)+		; g_h <- gl_height

	lea	_gl_rfull,a0		; r_set
	clr.w	   (a0)+		; g_x <- 0
	move.w	d6,(a0)+		; g_y <- gl_hbox
	move.w	d3,(a0)+		; g_w <- gl_width
	move.w	d4,(a0)			; g_h <- gl_height
	sub.w	d6,(a0)			; g_h <- gl_height-gl_hbox

	lea	_gl_rzero,a0		; r_set
	clr.l	 (a0)+			; g_x <- 0	  g_y <- 0
	clr.l	 (a0)+			; g_w <- 0	  g_h <- 0

	lea	_gl_rmenu,a0		; r_set
	clr.l	   (a0)+		; g_x <- 0	  g_y <- 0
	move.w	d3,(a0)+		; g_w <- gl_width
	move.w	d6,(a0)			; g_h <- gl_hbox

	lea	_gl_rcent,a0		; r_set
	sub.w	d5,d3			; d3  <- (gl_width - gl_wbox)
	lsr.w	#1,d3			; d3  <- (gl_width - gl_wbox)/2
	move.w	d3,(a0)+		; g_x <- (gl_width - gl_wbox)/2
	move.w	d4,(a0)			; g_h <-  gl_height
	move.w	d6,d0			; d0  <- 		 gl_hbox
	add.w	d0,d0			; d0  <-	      (2*gl_hbox)
	sub.w	d0,(a0)			; g_h <- (gl_height - (2*gl_hbox))
	lsr.w	   (a0)+		; g_h <- (gl_height - (2*gl_hbox))/2
	move.w	d5,(a0)+		; g_w <-  gl_wbox
	move.w	d6,(a0)			; g_h <- gl_hbox

	move.l	#_intin,_ad_intin

	lea	50(sp),sp		; restore stack
	movem.l	(sp)+,d3-d6
	rts



	.globl _bb_fill

*  call:
*
*	bb_fill(mode, fis, patt, hx, hy, hw, hh)
*
*  in:
*	sp+04	mode	word
*	  +06	 fis	word
*	  +08	patt	word
*	  +10	  hx	word
*	  +12	  hy	word
*	  +14	  hw	word
*	  +16	  hh	word

_bb_fill:

	move.l	a3,-(sp)
	lea	4+4(sp),a3			; a3 -> input parameters

	move.w	_gl_tcolo,-(sp)			; gl_tcolor
	move.w	    (a3)+,-(sp)			; mode
	move.w	       #1,-(sp)			; TRUE
	jsr	_gsx_attr

	lea	_gl_fis,a0			; a0 -> gl_fis
	move.w	  (a3)+,d0			; d0 <- fis
	cmp.w	   (a0),d0
	beq	       L41			; if (fis != gl_fis)

	move.w	 d0,(a0)			; gl_fis <- fis

	move.w	 d0,-(sp)			; vsf_interior(fis)
	move.w	#23,-(sp)
	jsr	_gsx_1code
	addq.l	#4,sp

L41:	lea	_gl_patt,a0			; a0 -> gl_patt
	move.w	   (a3)+,d0			; d0 <- patt
	cmp.w	    (a0),d0
	beq		L42			; if (patt != gl_patt)

	move.w	 d0,(a0)			; gl_patt <- patt

	move.w	 d0,-(sp)			; vsf_style(patt)
	move.w	#24,-(sp)
	jsr	_gsx_1code
	addq.l	#4,sp

L42:	lea	_ptsin,a0

	move.l	(a3),(a0)+		; ptsin[0] <- hx	ptsin[1] <- hy
	move.l	(a3)+,(a0)		; ptsin[2] <- hx	ptsin[3] <- hy
	move.w	(a3)+,d0		; d0       <-      hw
	subq.w	   #1,d0		; d0       <-      hw - 1
	add.w	  d0,(a0)+		; ptsin[2] <- hx + hw - 1  *CS*
	move.w	(a3),d0			; d0       <-      hh
	subq.w	   #1,d0		; d0       <-      hh - 1
	add.w	  d0,(a0)		; ptsin[2] <- hy + hh - 1

	lea	_gl_dst,a3	

	clr.l	-(sp)
	clr.l	-(sp)
	pea	 (a3)
	bsr	_gsx_fix		; gsx_fix(&gl_dst, 0x0L, 0, 0)

	pea	 (a3)	
	pea	_ptsin
	jsr	_vr_recfl

	lea	26(sp),sp
	move.l	(sp)+,a3		; *CS*
	rts



	.globl	_gsx_tcal

*  call:
*
*	gsx_tcalc(font, ptext, ptextw, ptexth, pnumchs)
*
*  iN:
*	sp+04	font		word
*	  +06	ptext		pointer to text string
*	  +10	*ptextw		pointer to word
*	  +14	*ptexth		pointer to word
*	  +18	*pnumchs	pointer to word
*
*
*   Calculate the minimum bounding rectangle:
*
*   ptextw < wc * pnumchs
*   ptexth < hc
*
*	ptextw  =  ptextw			(unchanged)
*	ptexth  =  ptexth			(unchanged)
*       pnumchs =  0
*
*   ptextw > wc * pnumchs
*   ptexth < hc
*
*	ptextw  =  wc * number of characters
*	ptexth  =  ptexth			(unchanged)
*       pnumchs =  0
*
*   ptextw < wc * pnumchs
*   ptexth > hc
*
*	ptextw  =  ptextw			(unchanged)
*	ptexth  =  hc
*       pnumchs =  ptextw / wc
*
*   ptextw > wc * pnumchs
*   ptexth > hc
*
*	ptextw  =  wc * number of characters
*	ptexth  =  hc
*       pnumchs =  number of characters

_gsx_tcal:

	lea	4(sp),a0
	movem.l	d3/a3-a5,-(sp)

	move.w	(a0)+,d3		; d3 <- font number
	move.l	(a0)+,-(sp)		; push pointer to text string
	move.l	(a0)+,a3		; a3 -> ptextw
	move.l	(a0)+,a4		; a4 -> ptexth
	move.l	(a0)+,a5		; a5 -> pnumchs

	move.l	_ad_intin,-(sp)		; push pointer to intin array
	jsr	_LBWMOV			; xfer text string to intin array
	addq.l	#8,sp

	cmp.w	#IBM,d3
	bne	L45

	move.w	_gl_wchar,d1		; d1 <- wc for IBM
	move.w	_gl_hchar,d2		; d2 <- hc for IBM
	bra	L46			; *CS*

L45:	cmp.w	#SMALL,d3
	bne	L48e			; ** ERROR **   neither IBM nor SMALL

	move.w	_gl_wscha,d1		; d1 <- wc for SMALL
	move.w	_gl_hscha,d2		; d2 <- hc for SMALL

L46:	muls	d1,d0			; d0 <- number of characters * wc

	cmp.w	(a3),d0			; if ptextw < characters * wc
	ble	L47			; then set minimum width to ptextw

	move.w	(a3),d0			; d0 <- ptextw

L47:	move.w	d0,(a3)			; ptextw <- ptextw (or characters * wc)

	cmp.w	(a4),d2			; if ptexth < hc
	bgt	L48			; ptexth is already the minimum 

	move.w	d2,(a4)			; ptext <- hc *CS*
	ext.l	d0
	divs	d1,d0			; d0 <- ptextw/ws  (or characters)
	bra	L49

L48e:	clr.w	(a3)			; ** ERROR **  neither IBM nor SMALL
	clr.w	(a4)			; ** ERROR **  ptextw=ptexth=pnumchs=0

L48:	clr.w	d0			; d0 <- pnumchs=0 when hc < ptexth

L49:	move.w	d0,(a5)			; set pnumchs
	movem.l	(sp)+,d3/a3-a5
	rts



	.globl	_gsx_tblt

*  call:
*
*	gsx_tblt(tb_f, x, y, tb_nc)
*
*  iN:
*	sp+04	tb_f	word
*	  +06	x	word
*	  +08	y	word
*	  +10	tb_nc	word

_gsx_tblt:

	lea	4(sp),a0		; a0 -> parameter list
	movem.l d3-d5/a3-a4,-(sp)

	lea	_gl_font,a3		; a3 -> gl_font
	move.w	(a0)+,d3		; d3[15:00] <- tb_f
	move.l	(a0)+,d4		; d4[31:16] <- X     d4[15:00] <- Y
	move.w	(a0)+,d5		; d5[15:00] <- tb_nc

	lea	T50(pc),a1		; a1 -> IBM parameters
	cmp.w	#IBM,d3			; try to resize if tb_f = IBM
	beq	L55

	lea	T51(pc),a1		; a1 -> SMALL parameters
	cmp.w	#SMALL,d3		; try to resize if tb_f = SMALL
	bne	L57


L55:	move.l	(a1)+,a4		; a4 -> character width

	cmp.w	(a3),d3			; don't resize the font
	beq	L56			; if gl_font = tb_f

	move.l	(a1)+,-(sp)		; push pointer to cell height
	move.l	(a1)+,-(sp)		; push pointer to cell width
	move.l	(a1)+,-(sp)		; push pointer to character height
	move.l	(a1)+,-(sp)		; push pointer to character width

	move.l	(a1)+,a1		; a1 -> height
	move.w	(a1),-(sp)		; push height

	jsr	_vst_height		; set font height
	lea	18(sp),sp

	move.w	d3,(a3)			; gl_font <- tb_f

L56:	add.w	(a4),d4			; d4[15:00] <- y + char_width


L57:	lea	_contrl,a1
	move.l	#$00080001,(a1)+	; contrl[0] <- 8    contrl[1] <- 1
	addq.l	#2,a1
	move.w	d5,(a1)+		; contrl[3] <- tb_nc
	addq.l	#4,a1
	move.w	_gl_handl,(a1)+		; contrl[6] <- gl_handle

	move.l	d4,_ptsin		; ptsin[0] <- X      ptsin[1] <- Y

	jsr	_gsx2

	movem.l (sp)+,d3-d5/a3-a4
	rts


T50:	dc.l	_gl_hptsc,_gl_hchar,_gl_wchar,_gl_hptsc,_gl_wptsc,_gl_ws+96
T51:	dc.l	_gl_hspts,_gl_hscha,_gl_wscha,_gl_hspts,_gl_wspts,_gl_ws+92




	.globl _gsx_xbox

*  call:
*
*	gsx_xbox(pt)
*
*  in:
*	sp+04	pt	long pointer to GRECT

_gsx_xbox:

	move.l	4(sp),-(sp)		; push *pt
	bsr	_gsx_bxpt

	move.l	#_ptsin,(sp)		; do the top
	move.w	    #4,-(sp)		; right side
	bsr	_gsx_xline		; and bottom

	move.l	  2(sp),a0		; a0 -> ptsin[0]
	addq.l	     #4,a0		; a0 -> ptsin[2]
	move.l	 8(a0),(a0)+		; ptsin[2] <- ptsin[6]
	subq.w	   #1,-(a0)		; ptsin[3] <- ptsin[7] -1

	subq.w	#2,(sp)			; point count = 4-2 = 2
	bsr	_gsx_xline		; now the left side line pattern

	addq.l	#6,sp			; will stay in phase if clipped.
	rts


	.globl _gsx_xcbo

*  call:
*
*	gsx_xcbox(pt)
*
*  in:
*	sp+04	pt	long pointer to GRECT

_gsx_xcbo:

	move.l	4(sp),a0
	movem.l	d3-d6/a3,-(sp)

	move.w	_gl_wbox,d5
	add.w	d5,d5		; d5 <- wa
	move.w	_gl_hbox,d6
	add.w	d6,d6		; d6 <- ha

	lea	_ptsin,a3
	move.l	a3,-(sp)	; set up gsx_xline call
	move.w	#3,-(sp)	

	move.l	 (a0),(a3)+	; ptsin[0] <- x		ptsin[1] <- y
	add.w	 d6,-2(a3)	;			ptsin[1] <- y+ha
	move.l	 (a0),(a3)+	; ptsin[2] <- x		ptsin[3] <- y
	move.l	(a0)+,(a3)	; ptsin[4] <- x		ptsin[5] <- y
	add.w	   d5,(a3)	; ptsin[4] <- x+wa

	move.w	(a0)+,d3
	subq.w	#1,d3		; d3[15:00] <- w-1
	move.w	(a0)+,d4
	subq.w	#1,d4		; d4[15:00] <- h-1

	bsr	_gsx_xline

	sub.w	   d5,(a3)	; ptsin[4] <- x
	add.w	   d3,(a3)	; ptsin[4] <- x+w-1
	move.l	(a3),-(a3)	; ptsin[2] <- x+w-1	ptsin[3] <- y
	move.l	(a3),-(a3)	; ptsin[0] <- x+w-1	ptsin[1] <- y
	sub.w	   d5,(a3)	; ptsin[0] <- x+w-1-wa
	add.w	 d6,10(a3)	;			ptsin[5] <- y+ha
	bsr	_gsx_xline

	add.w	  d4,2(a3)	; 			ptsin[1] <- y+h-1
	move.l	(a3)+,(a3)	; ptsin[2] <- x+w-1-wa	ptsin[3] <- y+h-1
	add.w	   d5,(a3)	; ptsin[2] <- x+w-1
	move.l	(a3)+,(a3)+	; ptsin[4] <- x+w-1	ptsin[5] <- y+h-1
	sub.w	  d6,-(a3)	;			ptsin[5] <- y+h-1-ha
	bsr	_gsx_xline

	sub.w	  d3,-(a3)	; ptsin[4] <- x
	move.l	(a3),-(a3)	; ptsin[2] <- x		ptsin[3] <- y+h-1-ha
	add.w	  d6,2(a3)	; 			ptsin[3] <- y+h-1
	move.l	(a3),-(a3)	; ptsin[0] <- x		ptsin[1] <- y+h-1
	add.w	   d5,(a3)	; ptsin[0] <- x+wa
	bsr	_gsx_xline

	addq.l	#6,sp		; clean up the stack
	bra	quit		; movem.l (sp)+,d3-d6/a3   rts




	.globl	_gsx_xline

*  calling sequence:
*
*	gsx_xline(ptscount, ppoints)
*
*  in:
*	sp+04	ptscount	word
*	  +06	ppoints		pointer to vertex array

_gsx_xline:

	movem.l	d3-d6/a3,-(sp)

	move.l	20+6(sp),a3		; a3 -> ppoints array

	moveq.l	#1,d3			; d3 <- vertex counter
	moveq.l	#1,d4			; d4 <- low bit isolation mask
	move.w	#$5555,d5		; d5 <- default line pattern

	bra	L67


L63:	move.w	(a3)+,d0			; d0 <-  X(n)
	move.w	(a3)+,d1			; d1 <-  Y(n)
	cmp.w	(a3),d0				; a3 -> (X(n+1),Y(n+1))
	bne	L64				; X(n) = X(n+1) => vertical

	eor.w	d0,d1				; The line style "5555" is used
	and.w	d4,d1				; if X and Y are both even or
	move.w	d5,d0				; both odd. "AAAA" is used when
	lsl.w	d1,d0				; X and Y are different.
	bra	L66				; d0 <- vertical line style

L64:	blt	L65				; X(n+1) > X(n) => d1 <- Y(n)
	move.w	2(a3),d1			; X(n+1) < X(n) => d1 <- Y(n+1)

L65:	and.w	d4,d1				; Y is even => d0 <- 5555
	move.w	d5,d0				; Y is odd  => d0 <- AAAA
	lsl.w	d1,d0				; d0 <- horizontal line style

L66:	move.w	  d0,-(sp)			; set line style
	move.w	#113,-(sp)			; call vsl_udsty
	jsr	_gsx_1code
	addq.l	#4,sp

	pea	  -4(a3)			; Push pointer to (X(n),Y(n))
	move.w	#2,-(sp)			
	jsr	_v_pline			; Draw line from  (X(n),Y(n))
	addq.l	#6,sp				;     to (X(n+1),Y(n+1))

	addq.w	#1,d3				; increment vertex counter

L67:	cmp.w	20+4(sp),d3			; if counter < ptscount, loop 
	blt	L63

	pea	$0071FFFF			; restore solid line style
	jsr	_gsx_1code			; call vsl_udsty (op $71)
	addq.l	#4,sp

quit:	movem.l	(sp)+,d3-d6/a3			; d6 is included to be
	rts					; compatible with gsx_xcbox bra


 
*\*	APGSXIF.C	05/06/84 - 02/04/85	Lee Lorenzen		*\
*\*	Reg Opt		03/08/85 - 03/09/85	Derek Mui		*\
*\*	Crunching	4/10/86			Derek Mui		*\
*\*	Fix at gsx_xbox	6/11/86			Derek Mui		*\
*
*\*
**	-------------------------------------------------------------
**	GEM Application Environment Services		  Version 1.0
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
*#define ORGADDR 0x0L
*						/* in GSXBIND.C		*\
*#define vsf_interior( x )	gsx_1code(S_FILL_STYLE, x)
*#define vsl_type( x )		gsx_1code(S_LINE_TYPE, x)
*#define vsf_style( x )		gsx_1code(S_FILL_INDEX, x)
*#define vsf_color( x )		gsx_1code(S_FILL_COLOR, x)
*#define vsl_udsty( x )		gsx_1code(ST_UD_LINE_STYLE, x)
*						/* in OPTIMIZE.C	*\
*EXTERN WORD	max();
*EXTERN WORD	min();
*
*EXTERN WORD	xrat, yrat, button;
*
*GLOBAL WORD	gl_width;
*GLOBAL WORD	gl_height;
*
*GLOBAL WORD	gl_nrows;
*GLOBAL WORD	gl_ncols;
*
*GLOBAL WORD	gl_wchar;
*GLOBAL WORD	gl_hchar;
*
*GLOBAL WORD	gl_wschar;
*GLOBAL WORD	gl_hschar;
*
*GLOBAL WORD	gl_wptschar;
*GLOBAL WORD	gl_hptschar;
*
*GLOBAL WORD	gl_wsptschar;
*GLOBAL WORD	gl_hsptschar;
*
*GLOBAL WORD	gl_wbox;
*GLOBAL WORD	gl_hbox;
*
*GLOBAL WORD	gl_xclip;
*GLOBAL WORD	gl_yclip;
*GLOBAL WORD	gl_wclip;
*GLOBAL WORD	gl_hclip;
*
*GLOBAL WORD 	gl_nplanes;
*GLOBAL WORD 	gl_handle;
*
*GLOBAL FDB		gl_src;
*GLOBAL FDB		gl_dst;
*
*GLOBAL WS		gl_ws;
*GLOBAL WORD		contrl[12];
*GLOBAL WORD		intin[128];
*GLOBAL WORD		ptsin[20];
*GLOBAL WORD		intout[10];
*GLOBAL WORD		ptsout[10];
*
*GLOBAL LONG		ad_intin;
*
*GLOBAL WORD		gl_mode;
*GLOBAL WORD		gl_mask;
*GLOBAL WORD		gl_tcolor;
*GLOBAL WORD		gl_lcolor;
*GLOBAL WORD		gl_fis;
*GLOBAL WORD		gl_patt;
*GLOBAL WORD		gl_font;
*
*GLOBAL GRECT		gl_rscreen;
*GLOBAL GRECT		gl_rfull;
*GLOBAL GRECT		gl_rzero;
*GLOBAL GRECT		gl_rcenter;
*GLOBAL GRECT		gl_rmenu;
*
*
*	VOID
*gsx_sclip(pt)
*	GRECT		*pt;
*{
*	REG WORD	*ppts;
*	ppts = &ptsin[0];
*
*	r_get(pt, &gl_xclip, &gl_yclip, &gl_wclip, &gl_hclip);
*
*	if ( gl_wclip && gl_hclip )
*	{
*	  ppts[0] = gl_xclip;
*	  ppts[1] = gl_yclip;
*	  ppts[2] = gl_xclip + gl_wclip - 1;
*	  ppts[3] = gl_yclip + gl_hclip - 1;
*	  vst_clip( TRUE, &ppts[0]);
*	}
*	else
*	  vst_clip( FALSE, &ppts[0]);
*	return( TRUE );
*}
*
*
*	VOID
*gsx_gclip(pt)
*	GRECT		*pt;
*{
*	r_set(pt, gl_xclip, gl_yclip, gl_wclip, gl_hclip);
*}
*
*
*	WORD
*gsx_chkclip(pt)
*	REG GRECT		*pt;
*{
*						/* if clipping is on	*\
*	if (gl_wclip && gl_hclip)
*	{
* 	  if ((pt->g_y + pt->g_h) < gl_yclip)
*	    return(FALSE);			/* all above	*\
*	  if ((pt->g_x + pt->g_w) < gl_xclip) 
*	    return(FALSE);			/* all left	*\
*	  if ((gl_yclip + gl_hclip) <= pt->g_y)
*	    return(FALSE);			/* all below	*\
*	  if ((gl_xclip + gl_wclip) <= pt->g_x)
*	    return(FALSE);			/* all right	*\
*	}
*	return(TRUE);
*}
*
*
*	VOID
*gsx_pline(offx, offy, cnt, pts)
*	WORD		offx, offy;
*	REG WORD		cnt;
*	REG WORD		*pts;
*{
*	REG WORD		i, j;
*
*	for (i=0; i<cnt; i++)
*	{
*	  j = i * 2;
*	  ptsin[j] = offx + pts[j];
*	  ptsin[j+1] = offy + pts[j+1];
*	}
*
*	gsx_xline( cnt, &ptsin[0]);
*}
*
*						/* in DRAWLINE.A86	*\
*	VOID
*gsx_cline(x1, y1, x2, y2)
*	UWORD		x1, y1, x2, y2;
*{
*	WORD		x, y, w, h;
*
*	gsx_moff();
*	v_pline( 2, &x1 );
*	gsx_mon();
*}
*
*	VOID
*gsx_attr(text, mode, color)
*	UWORD		text;
*	REG UWORD		mode, color;
*{
*	REG WORD		tmp;
*	REG WORD		*pcntr;
*	pcntr = &contrl[0];
*
*	tmp = intin[0];
*	pcntr[1] = 0;
*	pcntr[3] = 1;
*	pcntr[6] = gl_handle;
*	if (mode != gl_mode)
*	{
*	  pcntr[0] = SET_WRITING_MODE;
*	  intin[0] = gl_mode = mode;
*	  gsx2();
*	}
*	pcntr[0] = FALSE;
*	if (text)
*	{
*	  if (color != gl_tcolor)
*	  {
*	    pcntr[0] = S_TEXT_COLOR;
*	    gl_tcolor = color;
*	  }
*	}	
*	else
*	{
*	  if (color != gl_lcolor)
*	  {
*	    pcntr[0] = S_LINE_COLOR;
*	    gl_lcolor = color;
*	  }
*	}
*	if (pcntr[0])
*	{
*	  intin[0] = color;
*	  gsx2();
*	}
*	intin[0] = tmp;
*}
*
*
*	VOID
*gsx_bxpts(pt)
*	REG GRECT		*pt;
*{
*	REG WORD		*ppts;
*	ppts = &ptsin[0];
*
*	ppts[0] = pt->g_x;
*	ppts[1] = pt->g_y;
*	ppts[2] = pt->g_x + pt->g_w - 1;
*	ppts[3] = pt->g_y;
*\*	ppts[4] = pt->g_x + pt->g_w - 1;	*\
*	ppts[4] = ppts[2];
*	ppts[5] = pt->g_y + pt->g_h - 1;
*	ppts[6] = pt->g_x;
*\*	ppts[7] = pt->g_y + pt->g_h - 1;	*\
*	ppts[7] = ppts[5];
*	ppts[8] = pt->g_x;
*	ppts[9] = pt->g_y;
*}
*
*
*	VOID
*gsx_box(pt)
*	GRECT		*pt;
*{
*	gsx_bxpts(pt);
*	v_pline( 5, &ptsin[0] );
*}
*
*
*	VOID
*gsx_xbox(pt)
*	GRECT		*pt;
*{
*
*	gsx_bxpts(pt);
*	gsx_xline( 4, &ptsin[0] );
*	ptsin[2] = ptsin[6];		/* fix the clipping problem of *\
*	ptsin[3] = ptsin[7] - 1;	/* xbox		*\
*	gsx_xline( 2, &ptsin[0] );
*}
*
*
*
*	VOID
*gsx_xcbox(pt)
*	REG GRECT		*pt;
*{
*	REG WORD		wa, ha;
*	REG WORD		*ppts;
*	ppts = &ptsin[0];
*
*	wa = 2 * gl_wbox;
*	ha = 2 * gl_hbox;
*	ppts[0] = pt->g_x;
*	ppts[1] = pt->g_y + ha;
*	ppts[2] = pt->g_x;
*	ppts[3] = pt->g_y;
*	ppts[4] = pt->g_x + wa;
*	ppts[5] = pt->g_y;
*	gsx_xline( 3, &ppts[0] );
*	ppts[0] = pt->g_x + pt->g_w - wa;
*	ppts[1] = pt->g_y;
*	ppts[2] = pt->g_x + pt->g_w - 1;
*	ppts[3] = pt->g_y;
*\*	ppts[4] = pt->g_x + pt->g_w - 1;	*\
*	ppts[4] = ppts[2];
*	ppts[5] = pt->g_y + ha;
*	gsx_xline( 3, &ppts[0] );
*	ppts[0] = pt->g_x + pt->g_w - 1;
*	ppts[1] = pt->g_y + pt->g_h - ha;
*\*	ppts[2] = pt->g_x + pt->g_w - 1;	*\
*	ppts[2] = ppts[0];
*	ppts[3] = pt->g_y + pt->g_h - 1;
*	ppts[4] = pt->g_x + pt->g_w - wa;
*\*	ppts[5] = pt->g_y + pt->g_h - 1;	*\
*	ppts[5] = ppts[3];
*	gsx_xline( 3, &ppts[0] );
*	ppts[0] = pt->g_x + wa;
*	ppts[1] = pt->g_y + pt->g_h - 1;
*	ppts[2] = pt->g_x;
*\*	ppts[3] = pt->g_y + pt->g_h - 1;	*\
*	ppts[3] = ppts[1];
*	ppts[4] = pt->g_x;
*	ppts[5] = pt->g_y + pt->g_h - ha;
*	gsx_xline( 3, &ppts[0] );
*}
*
*
*gsx_fix(pfd, theaddr, wb, h)
*	REG FDB			*pfd;
*	REG LONG		theaddr;
*	REG WORD		wb;
*	WORD		h;
*{
*	if (theaddr == ORGADDR)
*	{
*	  pfd->fd_w = gl_ws.ws_xres + 1;
*	  pfd->fd_wdwidth = pfd->fd_w / 16;
*	  pfd->fd_h = gl_ws.ws_yres + 1;
*	  pfd->fd_nplanes = gl_nplanes;
*	}
*	else
*	{
*	  pfd->fd_wdwidth = wb / 2;
*	  pfd->fd_w = wb * 8;
*	  pfd->fd_h = h;
*	  pfd->fd_nplanes = 1;
*	}
*	pfd->fd_stand = FALSE;
*	pfd->fd_addr = theaddr;
*}
*
*	WORD
*gsx_blt(saddr, sx, sy, swb, daddr, dx, dy, dwb, w, h, rule, fgcolor, bgcolor)
*	LONG		saddr;
*	REG UWORD		sx, sy, swb;
*	LONG		daddr;
*	REG UWORD		dx, dy;
*	UWORD		dwb, w, h, rule;
*	WORD		fgcolor, bgcolor;
*{
*	REG WORD		*ppts;
*	ppts = &ptsin[0];
*
*	gsx_fix(&gl_src, saddr, swb, h);
*	gsx_fix(&gl_dst, daddr, dwb, h);
*
*	gsx_moff();
*	ppts[0] = sx;
*	ppts[1] = sy;
*	ppts[2] = sx + w - 1;
*	ppts[3] = sy + h - 1;
*	ppts[4] = dx;
*	ppts[5] = dy;
*	ppts[6] = dx + w - 1;
*	ppts[7] = dy + h - 1 ;
*	if (fgcolor == -1)
*	  vro_cpyfm( rule, &ppts[0], &gl_src, &gl_dst);
*	else
*	  vrt_cpyfm( rule, &ppts[0], &gl_src, &gl_dst, fgcolor, bgcolor);
*	gsx_mon();
*}
*
*
*	WORD
*bb_screen(scrule, scsx, scsy, scdx, scdy, scw, sch)
*	WORD		scrule, scsx, scsy, scdx, scdy, scw, sch;
*{
*	gsx_blt(0x0L, scsx, scsy, 0, 
*		0x0L, scdx, scdy, 0,
*		scw, sch, scrule, -1, -1);
*}
*
*
*	WORD
*gsx_trans(saddr, swb, daddr, dwb, h, fg, bg)
*	LONG		saddr;
*	UWORD		swb;
*	LONG		daddr;
*	UWORD		dwb;
*	REG UWORD		h;
*	WORD		fg, bg;
*{
*	gsx_fix(&gl_src, saddr, swb, h);
*	gl_src.fd_stand = TRUE;
*	gl_src.fd_nplanes = 1;
*
*	gsx_fix(&gl_dst, daddr, dwb, h);
*	vrn_trnfm( &gl_src, &gl_dst );
*}
*
*
*	WORD
*gsx_start()
*{
*	WORD			dummy;
*
*						/* force update		*\
*	gl_mode = gl_mask = gl_tcolor = gl_lcolor = -1;
*	gl_fis = gl_patt = gl_font = -1;
*	gl_xclip = 0;
*	gl_yclip = 0;
*	gl_width = gl_wclip = gl_ws.ws_xres + 1;
*	gl_height = gl_hclip = gl_ws.ws_yres + 1;
*
*	intin[0] = 1;
*	gsx_ncode( 102, 0, 1 );
*	gl_nplanes = intout[4];
*
*	/* The driver may have more than two fonts.  The large font *\
*	/* to the services is the default font in the driver.  This *\
*	/* font will give us 80 chars across the screen in all but  *\
*	/* 320 pels in x, when it will be the 40 column font.	    *\
*
*	gsx_ncode(38, 0, 0);		/* inquire text attributes	*\
*	gl_wptschar = ptsout[0];
*	gl_ws.ws_chmaxh = gl_hptschar = ptsout[1];
*	gl_wchar = ptsout[2];
*	gl_hchar = ptsout[3];
*
*	vst_height( gl_ws.ws_chminh, &gl_wsptschar, &gl_hsptschar, 
*				&gl_wschar, &gl_hschar );
*
*	vst_height( gl_ws.ws_chmaxh, &dummy, &dummy, &dummy, &dummy);
*
*	gl_ncols = gl_width / gl_wchar;
*	gl_nrows = gl_height / gl_hchar;
*	gl_hbox = gl_hchar + 3;
*	gl_wbox = (gl_hbox * gl_ws.ws_hpixel) / gl_ws.ws_wpixel;
*	/*   7/26/89	*/
*	if ( gl_wbox < ( gl_wchar + 2 )
*	  gl_wbox = gl_wchar + 2;	
*	vsl_type( 7 );
*	vsl_width( 1 );
*	vsl_udsty( 0xffff );
*	r_set(&gl_rscreen, 0, 0, gl_width, gl_height);
*	r_set(&gl_rfull, 0, gl_hbox, gl_width, (gl_height - gl_hbox));
*	r_set(&gl_rzero, 0, 0, 0, 0);
*	r_set(&gl_rcenter, (gl_width-gl_wbox)/2, (gl_height-(2*gl_hbox))/2, 
*			gl_wbox, gl_hbox);
*	r_set(&gl_rmenu, 0, 0, gl_width, gl_hbox);
*	ad_intin = ADDR(&intin[0]);
*}
*
*
*	VOID
*bb_fill(mode, fis, patt, hx, hy, hw, hh)
*	WORD		mode, fis;
*	REG WORD		patt, hx, hy, hw, hh;
*{
*	REG WORD		*ppts;
*	ppts = &ptsin[0];
*
*	gsx_fix(&gl_dst, 0x0L, 0, 0);
*	ppts[0] = hx;
*	ppts[1] = hy;
*	ppts[2] = hx + hw - 1;
*	ppts[3] = hy + hh - 1;
*
*	gsx_attr(TRUE, mode, gl_tcolor);
*	if (fis != gl_fis)
*	{
*	  vsf_interior( fis);
*	  gl_fis = fis;
*	}
*	if (patt != gl_patt)
*	{
*	  vsf_style( patt );
*	  gl_patt = patt;
*	}
*	vr_recfl( &ppts[0], &gl_dst );
*}
*
*
*	UWORD
*ch_width(fn)
*	REG WORD		fn;
*{
*	if (fn == IBM)
*	  return(gl_wchar);
*	if (fn == SMALL)
*	  return(gl_wschar);
*	return(0);
*}
*
*
*
*	UWORD
*ch_height(fn)
*	REG WORD		fn;
*{
*	if (fn == IBM)
*	  return(gl_hchar);
*	if (fn == SMALL)
*	  return(gl_hschar);
*	return(0);
*}
*
*	WORD
*gsx_tcalc(font, ptext, ptextw, ptexth, pnumchs)
*	REG WORD		font;
*	LONG		ptext;
*	REG WORD		*ptextw;
*	REG WORD		*ptexth;
*	REG WORD		*pnumchs;
*{
*	REG WORD		wc;
*	REG WORD		hc;
*
*	wc = ch_width(font);
*	hc = ch_height(font);
*						/* figure out the	*\
*						/*   width of the text	*\
*						/*   string in pixels	*\
*
*	*pnumchs = LBWMOV(ad_intin, ptext);
*	*ptextw = min(*ptextw, *pnumchs * wc );
*						/* figure out the height*\
*						/*   of the text	*\
*	*ptexth = min(*ptexth, hc );
*	if (*ptexth / hc)
*	  *pnumchs = min(*pnumchs, *ptextw / wc );
*	else
*	  *pnumchs = 0;
*}  /* gsx_tcalc *\
*
*
*	WORD
*gsx_tblt(tb_f, x, y, tb_nc)
*	REG WORD		tb_f;
*	REG WORD		x, y;
*	WORD		tb_nc;
*{
*	WORD		i;
*	REG WORD		pts_height;
*
*	if (tb_f == IBM)
*	{
*	  if (tb_f != gl_font)
*	  {
*	    vst_height(gl_ws.ws_chmaxh, &gl_wptschar, &gl_hptschar, 
*				&gl_wchar, &gl_hchar );
*	    gl_font = tb_f;
*	  }
*	  y += gl_hptschar;
*	}
*
*	if (tb_f == SMALL)
*	{
*	  if (tb_f != gl_font)
*	  {
*	    vst_height( gl_ws.ws_chminh, &gl_wsptschar, &gl_hsptschar, 
*				&gl_wschar, &gl_hschar );
*	    gl_font = tb_f;
*	  }
*	  y += gl_hsptschar;
*	}
*
*	contrl[0] = 8;		/* TEXT *\
*	contrl[1] = 1;
*	contrl[6] = gl_handle;
*	ptsin[0] = x;
*	ptsin[1] = y;
*	contrl[3] = tb_nc;
*	gsx2();
*}
*
*
*
*	VOID
*gsx_xline( ptscount, ppoints )
*	WORD		ptscount;
*	REG WORD		*ppoints;
*{
*	static	WORD	hztltbl[2] = { 0x5555, 0xaaaa };
*	static  WORD	verttbl[4] = { 0x5555, 0xaaaa, 0xaaaa, 0x5555 };
*	REG WORD		*linexy;
*	REG WORD		st, i;
*
*	for ( i = 1; i < ptscount; i++ )
*	{
*	  if ( *ppoints == *(ppoints + 2) )
*	  {
*	    st = verttbl[( (( *ppoints) & 1) | ((*(ppoints + 1) & 1 ) << 1))];
*	  }	
*	  else
*	  {
*	    linexy = ( *ppoints < *( ppoints + 2 )) ? ppoints : ppoints + 2;
*	    st = hztltbl[( *(linexy + 1) & 1)];
*	  }
*	  vsl_udsty( st );
*	  v_pline( 2, ppoints );
*	  ppoints += 2;
*	}
*	vsl_udsty( 0xffff );
*}	
*
*
