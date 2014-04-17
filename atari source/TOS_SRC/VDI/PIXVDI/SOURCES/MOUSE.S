*********************************  mouse.s  ***********************************
*
* $Revision: 3.3 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/mouse.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 12:18:47 $     $Locker:  $
* =============================================================================
*
* $Log:	mouse.s,v $
* Revision 3.3  91/07/30  12:18:47  lozben
* Fixed some bugs created as a result of new linea var structure.
* 
* Revision 3.2  91/02/08  17:18:35  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.1  91/01/28  16:48:21  lozben
* Adjusted the code to work with the multiple linea variable structures.
* 
* Revision 3.0  91/01/03  15:13:27  lozben
* New generation VDI
* 
* Revision 2.9  90/07/17  14:24:43  lozben
* Fixed a bug in cur_diplay(). XOR mode was not working.
* 
* Revision 2.8  90/02/16  12:23:15  lozben
* Fixed some of the code so that it can be assembled with mas.
* 
* Revision 2.7  89/10/17  16:38:32  lozben
* Sped up the mouse code in cur_display.
* 
* Revision 2.6  89/05/19  17:43:24  lozben
* Fixed a bug in curr_replace. It was intorduced while expanding the code
* to 8 planes. The wrap value value in the register was not extended to long.
* 
* Revision 2.5  89/05/15  18:15:02  lozben
* Fixed cur_replace() routine. Mouse background was sometimes
* drawn with a wrong color.
* 
* Revision 2.4  89/05/04  18:24:02  lozben
* Made mouse code faster. It now draws all planes at a time.
* 
* Revision 2.3  89/04/24  18:03:35  lozben
* Changed cur_replace() to deal with 8 plane case. Also started
* using variable v_vt_rez, v_hz_rez instead of DEVTAB[0], DEVTAB[1].
* This way when you set rez esc_init also initializes clipping 
* boundaries for the mouse cursor.
* 
* Revision 2.2  89/04/14  14:38:12  lozben
* Mouse now gets cliped if it's on the sixteenth pixel away from
* the right edge. It wasn't clipped before and it should have been.
* 
* Revision 2.1  89/02/21  17:24:32  kbad
* *** TOS 1.4  FINAL RELEASE VERSION ***
* 
*******************************************************************************


.include	"lineaequ.s"


		.globl	_DIS_CUR	; Global routines declared in this file
		.globl	_HIDE_CUR
		.globl	_MOV_CUR
		.globl	_SET_CUR
		.globl	_VEX_BUTV
		.globl  _VEX_MOTV
		.globl	_VEX_CURV
		.globl	_XFM_CRFM
		.globl	_vq_mouse_status
		.globl	mouse_rel	
		.globl	scrn_clip
		.globl	vb_draw
		.globl	cur_display
		.globl	cur_replace
		.globl	st_cur_display
		.globl	st_cur_replace
		.globl	rel_pblock	; Global data declared in this file
		.globl	arrow_cdb

		.globl	 concat		; Global routines used

		.globl	_v_bas_ad
		.globl	_MOUSE_BT

*******************************************************************************
*
*  MOUSE INTERUPT ROUTINE
*
*  on entry:
*
*     a0	points to IKBD mouse packet
*
*******************************************************************************

mouse_rel:	movem.l	d0-d7/a0-a6,-(sp)
		move.l  _lineAVar,a2		; a2 -> linea var struct

		move.b	(a0),d0			; get header from mouse buffer
		move.b	d0,d1			; save it
		and.b	#$F8,d1			; mask out button bits
		cmp.b	#$F8,d1			; is header relative positioning
		bne	ms_done			; no check just return

		and.w	#3,d0			; IKBD <00>:rt btn  <01>:lf btn
		lsr.b	#1,d0			; VDI <00>:lf btn <01>:rt btn
		bcc	right_up

		bset.l	#1,d0

right_up:	move.b	cur_ms_stat(a2),d1	; d1 <- previous mouse state
		and.w	#3,d1			; d1 <- prev mouse button state
		cmp.b	d1,d0			; update just the pstion if btn
		beq	xy_update		; hasn't chngd since last IRQ

		move.w	d1,-(sp)		; preserve previous mouse state
		move.l	user_but(a2),a1		; get user routine address
		jsr 	(a1)			; call user.
		move.w	(sp)+,d1		; retrieve back previous state

		move.w	d0,_MOUSE_BT(a2)	; save cur mouse button state

		eor.b	d0,d1			; compute which buttons changed
		ror.b	#2,d1			; d1<07:06> <-last ms btn state
		or.b	d1,d0			; d0<07:06> <-delta btn state

		move.b	d0,cur_ms_stat(a2)	; store new button status byte

xy_update:	move.b	1(a0),d0		; has mouse position changed ?
		or.b	2(a0),d0
		bne	new_coord

		bclr.b	#5,cur_ms_stat(a2)	; no motion: clear motion
		bra	ms_done			; status flag and exit

new_coord:	bset.b	#5,cur_ms_stat(a2)	; motion:set motion status flag

		move.l	_GCURXY(a2),d0
		move.l	d0,d1			; d1 <- old mouse cursor Y
		swap	d0			; d0 <- old mouse cursor X

		move.b	 1(a0),d3		; d3 <- delta X from IKBD
		ext.w	d3			; sign extend delta X to word
		add.w	d3,d0			; d0 <- new mouse cursor X

		move.b	 2(a0),d3		; d3 <- delta Y from IKBD
		ext.w	d3			; sign extend delta Y to word
		add.w	d3,d1			; d1 <- new mouse cursor Y

		bsr	scrn_clip		; clip X and Y to screen

		move.l	user_mot(a2),a1
               	jsr 	(a1)			; call user motion routine

		bsr	scrn_clip		; IS THIS TOO PARANOID ?!

		lea	_GCURXY(a2),a1		; save new cursor position
		move.w	d0,(a1)+		; X
		move.w	d1,(a1)			; Y

		move.l	user_cur(a2),a1
		jsr 	(a1)			; call user cur display routine

ms_done:	movem.l	(sp)+,d0-d7/a0-a6
		rts


*******************************************************************************
*
*	scrn_clip	checks x and y to see if cliped to screen
*
*		entry:	d0 = x coordinate
*			d1 = y coordinate
*			a2 -> linea variable structure
*
*		exit:	d0 = clipped to screen x
*			d1 = clipped to screen y
*
*******************************************************************************

scrn_clip:	tst.w	d0			; is new_x < 0
		bge	cl_xmax
		clr.w	d0
		bra	cl_y

cl_xmax:	cmp.w	v_hz_rez(a2),d0		; is new_x < max resolution
		blt	cl_y
		move.w	v_hz_rez(a2),d0		; clip to max x resolution
		subq.w	#1,d0			; adjust for zero based

cl_y:		tst.w	d1			; is new_y < 0
		bge	cl_ymax
		clr.w	d1
		rts

cl_ymax:	cmp.w	v_vt_rez(a2),d1		; is new_y < max resolution
		blt	cl_done
		move.w	v_vt_rez(a2),d1		; clip to max y resolution
		subq.w	#1,d1			; adjust for zero based

cl_done:	rts

*******************************************************************************
*
* cur_display - go to the proper cursor display routine
*
*******************************************************************************

cur_display:	move.l  _lineAVar,a1		; a0 -> linea var struct
		move.l	V_ROUTINES(a1),a1	; a1 -> routine vector list
		move.l	V_SHOWCUR(a1),a1	; a1 -> display cursor routine
		jmp	(a1)
		
*******************************************************************************
*
* cur_replace - go to the proper cursor hide routine
*
*******************************************************************************

cur_replace:	move.l  _lineAVar,a1		; a0 -> linea var struct
		move.l	V_ROUTINES(a1),a1	; a1 -> routine vector list
		move.l	V_HIDECUR(a1),a1	; a1 -> hide cursor routine
		jmp	(a1)

*  SET UP V-BLANK DRAW PACKET
*
*  VDI user_cur routine: sets up packet for vblank cursor draw routine.
*  Assume that this routine cannot be interrupted
*
*  iN:	d0.w	X
*	d1.w	Y


_MOV_CUR:	move.l  _lineAVar,a0	; a0 -> linea var struct
		move.w	SR,-(sp)	; save old status register
		ori.w	#$0700,SR	; turn off interrupts
		lea	xydraw(a0),a0
		move.w	d0,(a0)+	; new X
		move.w	d1,(a0)+	; new Y
		bset.b	#0,(a0)		; mark data available
		move.w	(sp)+,SR	; restore old SR
		rts


*  V-BLANK CURSOR REDRAW
*
*  If the draw packet flag is set, The cursor form is removed from its 
*  prior location and redrawn in at the position specified in the draw packet.
*  If either HIDE_CNT or mouse_flag are non-zero, the cursor will not be
*  relocated.

vb_draw:	move.l  _lineAVar,a5		; a5 -> linea var struct
		tst.w	_HIDE_CNT(a5)		; HIDE_CNT semaphore controls
		bne	vblank_exit		; access to cur disp routines

		tst.b	mouse_flag(a5)		; cntrl access to ms frm (CDB)
		bne	vblank_exit

		bclr.b	#0,draw_flag(a5)	; control access to cursor position
		beq	vblank_exit		; 1:data valid  0:data invalid

*  RETRIEVE CURSOR X AND Y VIA AN ATOMIC OPERATION: this prevents the
*  mouse position interrupt service routine from altering position data
*  while we are in the process of retrieving it.

		move.l	xydraw(a5),d1		; d1[31:16] <- cursor X
		move.l	d1,d0			; d1[15:00] <- cursor Y
		swap	d0			; d0[15:00] <- cursor X

		movem.l	d0-d1/a5,-(sp)		; Save new xy
		move.l	sv_blk_ptr(a5),a2	; a2 -> save block
		bsr	cur_replace		; Undraw old cursor
		movem.l	(sp)+,d0-d1/a5		; Restore new xy

		move.l	sv_blk_ptr(a5),a2	; a2 -> save block
		lea	mouse_cdb(a5),a0	; a0 -> CDB	
		bsr	cur_display		; and draw new cursor

vblank_exit:	rts


*******************************************************************************
*
*	_VEX_BUTV	exchange button change vector
*
*	entry:	contrl[7], contrl[8]	pointer to user routine
*	exit:	contrl[9], contrl[10]	pointer to old routine
*	destroys: a0-a1
*
*******************************************************************************

_VEX_BUTV:	move.l  _lineAVar,a1		; a1 -> linea var struct
		move.l	_CONTRL(a1),a0		; point to contrl array
		move.l	user_but(a1),18(a0)	; store old pointer in contrl
		move.l	14(a0),user_but(a1)	; store new routine address
		rts

*******************************************************************************
*
*	_VEX_MOTV	exchange coordinate change vector
*
*	entry:	contrl[7], contrl[8]	pointer to user routine
*	exit:	contrl[9], contrl[10]	pointer to old routine
*	destroy: a0-a1
*
*******************************************************************************

_VEX_MOTV:	move.l  _lineAVar,a1		; a1 -> linea var struct
		move.l	_CONTRL(a1),a0		; point to contrl array
		move.l	user_mot(a1),18(a0)	; save old routine pointer
		move.l	14(a0),user_mot(a1)	; store new routine address
		rts

*******************************************************************************
*
*	_VEX_CURV	exchange cursor draw vector
*
*	entry:	contrl[7], contrl[8]	-pointer to user routine
*	exit:	contrl[9], contrl[10]	_pointer to old routine
*	destroy: a0
*
*******************************************************************************

_VEX_CURV:	move.l  _lineAVar,a1		; a1 -> linea var struct
		move.l	_CONTRL(a1),a0		; point to contrl array
		move.l	user_cur(a1),18(a0)	; save old routine pointer
		move.l	14(a0),user_cur(a1) 	; store new routine address
		rts


*******************************************************************************
*	                           
* name:	st_cur_display
*                            
* purpose:      this routine BLiTs a "cursor" to the destination by 
*		combining a background color form, foreground color form,
*		and destination: There are two forms. each form is blt'ed
*		in transparent mode. The logic operation is based upon the
*		current color bit for each form.
*
*
* procedure:
*
*	p_loop:		i. set up logic routine addresses based on forgrnd bit
*
*	row loop:	i.  advance to destination pointer to next row
*	      		ii. init and allign BG form and FG form.
*
*	outer loop:	i. advance destination pointer to next plane
*
*	inner loop:	i.   fetch destination and save it.
*	     		ii. combine BG form, FG form, and destination.
*	      		iii.  store value back to destination.
*
*
*  in:		a0.l		points to CDB
*		a2.l		points to SAVE BLOCK
*
*		d0.w		cursor x
*		d1.w		cursor y
* 
*		clobbered:	everything
*
******************************************************************************
                             

C_XHOT		equ	00
C_YHOT		equ	02
C_PLANES	equ	04
C_BGCOL		equ	06
C_FGCOL		equ	08
C_MSKFRM	equ	10

SV_LEN		equ	00
SV_ADDR		equ	02
SV_STAT		equ	06
SV_BUF		equ	08

SP_OFF		equ	00
SP_FG		equ	02
SP_BG		equ	04
                             
RTN_REC	       	equ    	2*4		
LF_OFF		equ	RTN_REC*1
RT_OFF		equ	RTN_REC*2


*	fetching and saving a destination long word
*
*  in:
*	a0.l	points to start of CDB
*	a1.l	points to start of destination
*	a2.l	points to start of save area
*	a3.l	thread to alignment fragment
*	a4.l	thread to logic fragment
*	a5.l	thread to storage segment
*
*	d3.w	offset to next word
*	d4.w	form wrap offset
*	d5.w	row counter
*	d6.w	shift count

st_cur_display:	move.l  _lineAVar,a4		; a4 -> linea var struct
		move.w	C_BGCOL(a0),d4		; d4 <- mouse background color
		move.w	C_FGCOL(a0),d7		; d7 <- mouse foreground color

		movea.w	#0,a3			; a3 <- offset to standard ops
		tst.w	C_PLANES(a0)		; unless plane count < 0
		bge	clip_x

		move.w	#16,a3			; a3 <- offset to extended ops


clip_x:		clr.w	d2			; d2 <- routine offset

		bclr.b	#F_SAVWID,SV_STAT(a2)	; default to word wide format

		sub.w	C_XHOT(a0),d0		; d0 <- left side of dst
		bcs	clip_left

		move.w	v_hz_rez(a4),d3
		sub.w	#17,d3			; check for clip
		cmp	d3,d0			; on right side
		bhi	clip_right		; 17 is the right value !!!

		bset.b	#F_SAVWID,SV_STAT(a2)	; indicate longword save
		bra	clip_y


clip_left:	add.w	#16,d0			; get address of right word
		moveq.l	#LF_OFF,d2		; d2 indexes left 
		bra	clip_y			; clip routine addresses

clip_right:	moveq.l	#RT_OFF,d2		; d2 indexes to rt clip addr

clip_y:		sub.w	C_YHOT(a0),d1		; d1 <- hi y : dst block
		lea	C_MSKFRM(a0),a0		; a0 -> MASK/FORM for cursor
		bcs	clip_up			; if y<0 clip top of form

		move.w	v_vt_rez(a4),d3		; check for clip at 
		sub.w	#16,d3			; bottom of screen
		cmp.w	d3,d1
		bhi	clip_down

		moveq.l	#16,d5			; d5 <- row count
		bra	get_addr


clip_up:	move.w	d1,d5			; calculate row count
		add.w	#16,d5

		asl.w	#2,d1			; a0 -> first visible row
		suba.w	d1,a0			; of MASK/FORM 

		clr.w	d1			; ymin=0
		bra	get_addr


clip_down:	move.w	v_vt_rez(a4),d5		; d5 <- last row on screen + 1
		sub.w	d1,d5			; d5 <- row count

get_addr:	bsr	concat			; x:d0 y:d1   starting offset 

		move.l	_v_bas_ad,a1
		adda.l	d1,a1			; a1 -> dst


*+
* init shift count
*-
shift_lf:	move.w	#16,d6			; compensate for left shift
		sub.w	d0,d6			; d6 <- shift count left
		swap	d6


*+
* init logic fragment routines on the stack
*-
		move.w	_v_planes(a4),d1
		move.w	d1,d3
		subq.w	#1,d1			; set up plane counter

		move.w	d3,d0			; d0 <- # planes
		lsl.w	#2,d0			; make d0 long word offset
		sub.w	d0,sp			; leave enough room on the stack
		move.l	sp,a5			; for logical fragments

p_loop:		clr.w	d0			; make two bit op_tab index
		lsr.w	d7
		addx.w	d0,d0			; <bit3> foreground color
		lsr.w	d4			; <bit2> background color
		roxl.w	#3,d0			; longword aligned table

		add.w	a3,d0
		move.l	op_tab(pc,d0.w),(a5)+	; store logic op fragment
		dbra	d1,p_loop


*   6.	init:
*		
*		a. save area address
*		b. save area length (per plane)
*		c. use table to load fetch/store pointers


init:		move.w	d5,d6			; d6 <- row count
		add.w	d6,d6			; make d6 word offset
		tst.w	d2			; see if are saving long words
		bne	init2
		add.w	d6,d6			; make d6 long word offset
		
init2:		move.l	rtn_tab+00(pc,d2.w),a5	; a5 -> store routine

		move.l	a1,SV_ADDR(a2)		; save area: origin of material
		move.w	d5,SV_LEN(a2)		;	     number of rows
		bset.b	#F_SAVRDY,SV_STAT(a2)	; flag the buffer data as valid
		lea	SV_BUF(a2),a2		; a2 -> save area buffer

		move.w	d3,d7			; d7 <- plane count
		subq.w	#1,d7			; d7 <- plane count - 1
		add.w	d3,d3			; d3 <- offset to second word

		swap	d5			; d5 is used as 2 variables
		move.w	_v_lin_wr(a4),d5	; d5 <- line wrap offset
		sub.w	d3,d5			; dest ptr has advanced n planes

		move.l	rtn_tab+04(pc,d2.w),a3	; a3 -> entry point 
		jmp	(a3)

op_tab:		dc.l	s_fg0bg0,s_fg0bg1,s_fg1bg0,s_fg1bg1	; standard
		dc.l	x_fg0bg0,x_fg0bg1,x_fg1bg0,x_fg1bg1	; extended

rtn_tab:	dc.l	store_lw,r_lw_entry
		dc.l	store_rt,r_rt_entry
		dc.l	store_lf,r_lf_entry


*-
*	row controller
*
* in:	a0.l	points to mouse data form
*	a1.l	points to start of destination
*	a2.l	points to start of save buffer
*	a4.l	points to a queue of logic fragment routines
*	a5.l	points to storage fragment
*
*	d3.w	offset to next word
*	d5.l	<31:16> row  counter: <15:0> offset to next row (destination)
*	d6.l	<31:16> shift factor: <15:0> offset to next plane in save_area
*	d7.w	plane count - 1
*
*	fetching and saving a destination long word
*
*  in:	a1.l	points to start of destination
*	a2.l	points to start of save buffer
*	a4.l	points to a queue of logic fragment routines
*
*	d3.w	offset to next word
*	d6.w	form wrap offset of save buffer
*	d7.w	plane count - 1
*+
r_lw_loop:	swap	d6			; restore shift factor
		moveq.l	#0,d0			; pad background form with 0's
		move.w	(a0)+,d0		; a0 -> foreground word
		rol.l	d6,d0			; d0<31:00> <- aligned bg
		moveq.l	#0,d1			; pad foreground form with 0's
		move.w	(a0)+,d1		; a0 -> next background word
		rol.l	d6,d1			; d1<31:00> <- aligned fg
		swap	d6			; restore offset in save_area

		move.l	sp,a4			; a4 -> logic ops routines

* fetch/store/advance row:  long word
		move.w	d7,-(sp)
		move.l	a2,a3
fetch_lw:	move.w	(a1),d2
		swap	d2
		move.w	(a1,d3.w),d2		; d2(31:00) <- destination
		move.l	d2,(a3)			; save original dst
		add.w	d6,a3
		move.l	(a4)+,a6
		jmp	(a6)			; a0 -> logic fragment routine
store_lw:	move.w	d2,(a1,d3.w)
		swap	d2
		move.w	d2,(a1)+		; send long word to screen
enter_lw:	dbra	d7,fetch_lw
		move.w	(sp)+,d7

		addq.w	#4,a2			; increment pntr for save buffer
		swap	d5			; restore line wrap
		adda.w	d5,a1			; advance dest pointer

r_lw_entry:	swap	d5			; restore row counter
		dbra	d5,r_lw_loop                  
		move.l	a4,sp			; restore sp
		rts
*+
* row controller for fetsching right word only
*-
r_rt_loop:	swap	d6			; restore shift factor
		moveq.l	#0,d0			; pad background form with 0's
		move.w	(a0)+,d0		; a0 -> foreground word
		rol.l	d6,d0			; d0<31:00> <- aligned bg
		moveq.l	#0,d1			; pad foreground form with 0's
		move.w	(a0)+,d1		; a0 -> next background word
		rol.l	d6,d1			; d1<31:00> <- aligned fg
		swap	d6			; restore offset in save_area

		move.l	sp,a4			; a4 -> logic ops routines

* fetch/store/advance row:  right word only
		move.w	d7,-(sp)
		move.l	a2,a3
fetch_rt:	move.w	(a1),d2			; fetch destination
		move.w	d2,(a3)			; save it for later
		add.w	d6,a3
		move.l	(a4)+,a6
		jmp	(a6)			; a0 -> logic fragment routine
store_rt:	move.w	d2,(a1)+		; set new dst
enter_rt:	dbra	d7,fetch_rt
		move.w	(sp)+,d7

		addq.w	#2,a2			; increment pntr for save buffer
		swap	d5			; restore line wrap
		adda.w	d5,a1			; advance dest pointer

r_rt_entry:	swap	d5			; restore row counter
		dbra	d5,r_rt_loop                  
		move.l	a4,sp			; restore sp
		rts
*+
* row controller for fetsching left word only
*-
r_lf_loop:	swap	d6			; restore shift factor
		moveq.l	#0,d0			; pad background form with 0's
		move.w	(a0)+,d0		; a0 -> foreground word
		rol.l	d6,d0			; d0<31:00> <- aligned bg
		moveq.l	#0,d1			; pad foreground form with 0's
		move.w	(a0)+,d1		; a0 -> next background word
		rol.l	d6,d1			; d1<31:00> <- aligned fg
		swap	d6			; restore offset in save_area

		move.l	sp,a4			; a4 -> logic ops routines

* fetch/store/advance row:  left word only
		move.w	d7,-(sp)
		move.l	a2,a3
fetch_lf:	move.w	(a1),d2			; fetch destination
		move.w	d2,(a3)			; save it for later
		add.w	d6,a3
		swap	d2			; d2(31:16) <- destination word
		move.l	(a4)+,a6
		jmp	(a6)			; a0 -> logic fragment routine
store_lf:	swap	d2
		move.w	d2,(a1)+		; send new dst to screen
enter_lf:	dbra	d7,fetch_lf
		move.w	(sp)+,d7

		addq.w	#2,a2			; increment pointer for save buffer
		swap	d5			; restore line wrap
		adda.w	d5,a1			; advance dest pointer

r_lf_entry:	swap	d5			; restore row counter
		dbra	d5,r_lf_loop                  
		move.l	a4,sp			; restore sp
		rts


*	standard logical operation for cursor interaction with destination
*
*  in:	d0.l	alligned background form padded with 0's (can't clobber)
*	d1.l	alligned foreground form padded with 0's (can't clobber)
*	d2.l	Destination
*
*	a5.l	points to storage code fragment
*
*
*		FORM   MASK
*
*		 0      0	Destination
*		 0	1	BG color
*		 1      0	FG color
*		 1	1	FG color
*

s_fg0bg0:	move.l	d0,d4
		or.l	d1,d4			* D' <- D and [not [M or F]]
		not.l	d4		
		and.l	d4,d2
		jmp	(a5)
	
s_fg0bg1:	or.l	d0,d2			* D' <- D or M and [not F]
		not.l	d1
		and.l	d1,d2
		not.l	d1
		jmp	(a5)

s_fg1bg0:	not.l	d0			* D' <- D and [not M] or F
		and.l	d0,d2
		or.l	d1,d2
		not.l	d0
		jmp	(a5)

s_fg1bg1:	or.l	d0,d2			* D' <- D or M or F
		or.l	d1,d2
		jmp	(a5)	



*		FORM   MASK
*
*		 0      0	Destination
*		 0	1	BG color
*		 1      0	invert Destination
*		 1	1	FG color
*

x_fg0bg0:	eor.l	d1,d2		; D' <- [D xor F] and [not M]
		not.l	d0		
		and.l	d0,d2
		not.l	d0		
		jmp	(a5)

x_fg0bg1:	or.l	d0,d2		; D' <- [D or M] xor F
		eor.l	d1,d2
		jmp	(a5)

x_fg1bg0:	not.l	d0		; D' <- [D and [not M]] xor F
		and.l	d0,d2
		eor.l	d1,d2
		not.l	d0
		jmp	(a5)

x_fg1bg1:	eor.l	d0,d2		; D' <- [D xor F] or M
		or.l	d1,d2
		jmp	(a5)	



* purpose:	replace cursor with data in save area.
*
*      in:	a2.l		points to save block
*
*		SV_BUF	buffer where saved data resides
*		SV_ADDR	points to destination origin of saved block
*		SV_LEN	number of lines to be returned
*		SV_STAT	status and format of save buffer
*
*	_v_planes	number of planes in destination
*	_v_line_wr	line wrap (byte width of form)
*

F_SAVRDY	equ	0	; save buffer status: 0:empty  1:full
F_SAVWID	equ	1	; saved line width:   0:word   1:longword


st_cur_replace:	move.l  _lineAVar,a5		; a5 -> linea var struct
		bclr.b	#F_SAVRDY,SV_STAT(a2)   ; valid data in buffer?
		beq	hang_it_up		; 0:nothing saved

		move.w	SV_LEN(a2),d4		; d4 <- lines per plane
		move.w	d4,d2
		subq.w	#1,d2			; d2 <- adjust counter for dbra
		moveq.l	#0,d3			; clr garbage in the upper word
		move.w	_v_lin_wr(a5),d3	; d3 <- dy wrap value

		move.l	SV_ADDR(a2),a0		; a0 -> destination
		lea	SV_BUF(a2),a1		; a1 -> save buffer

		move.w	_v_planes(a5),d5	; d5 <- rez discriminator
		cmp.w	#8,d5			; see if we are in 8 plane mode
		beq	pln_8
		subq.w	#2,d5
		bhi	pln_4
		beq	pln_2

pln_1:		btst.b	#F_SAVWID,SV_STAT(a2)	; word or longword ?
		bne	pl1_lw_loop


*********************************************************
*		1 Plane case				*
*********************************************************
*
* 1 plane: word wide
*
pl1_wd_loop:	move.w	(a1)+,(a0)
		add.w	d3,a0
		dbra	d2,pl1_wd_loop

		rts
*
* 1 plane: long word
*
pl1_lw_loop:	move.l	(a1)+,(a0)
		add.w	d3,a0
		dbra	d2,pl1_lw_loop

		rts


*********************************************************
*		2 Plane case				*
*********************************************************
pln_2:		move.l	a0,a5			; a5 <- destination
		add.w	d4,d4			; d4 <- word offset

		btst.b	#F_SAVWID,SV_STAT(a2)	; word or longword ?
		bne	pl2_lw_enter

*
* 2 plane: word wide
*
		move.l	a1,a2			; a2 -> second plane (word)
		add.w	d4,a2

pl2_wd_loop:	move.w	(a1)+,(a0)+		; store plane 1
		move.w	(a2)+,(a0)		; store plane 2
		add.w	d3,a5
		move.l	a5,a0			; a0 -> next screen line
		dbra	d2,pl2_wd_loop

		rts


*
* 2 plane: long word
*
pl2_lw_enter:	add.w	d4,d4			; d4 <- plane offset
		move.l	a1,a2
		add.w	d4,a2			; a2 -> second plane (longword)

pl2_lw_loop:	move.w	(a1)+,(a0)+		; 1st plane, hi word
		move.w	(a2)+,(a0)+		; 2nd plane, hi word
		move.w	(a1)+,(a0)+		; 1st plane, lo word
		move.w	(a2)+,(a0)		; 2nd plane, lo word
		add.w	d3,a5
		move.l	a5,a0			; a0 -> next line
		dbra	d2,pl2_lw_loop

		rts


*********************************************************
*		4 Plane case				*
*********************************************************
pln_4:		move.l	a0,a5			; a5 -> current line in plane 1
		add.w	d4,d4			; d4 <- offset to next plane
		btst.b	#F_SAVWID,SV_STAT(a2)	; word or longword ?
		bne	pl4_lw_enter


*
* 4 plane: word wide
*
		move.l	a1,a2
		add.w	d4,a2			; a2 -> 2nd plane	
		move.l	a2,a3
		add.w	d4,a3			; a3 -> 3rd plane
		move.l	a3,a4
		add.w	d4,a4			; a4 -> 4th plane

pl4_wd_loop:	move.w	(a1)+,(a0)+		; store 1st plane
		move.w	(a2)+,(a0)+		; store 2nd plane
		move.w	(a3)+,(a0)+		; store 3rd plane
		move.w	(a4)+,(a0)		; store 4th plane
		add.w	d3,a5
		move.l	a5,a0			; a0 -> next line
		dbra	d2,pl4_wd_loop

		rts

*
* 4 plane: long word
*
pl4_lw_enter:	add.w	d4,d4			; d4 <- plane offset
		move.l	a1,a2			; set up pointers to each plane
		add.w	d4,a2	
		move.l	a2,a3
		add.w	d4,a3
		move.l	a3,a4
		add.w	d4,a4

pl4_lw_loop:	move.w 	(a1)+,(a0)+		; 1st plane, hi word
     		move.w	(a2)+,(a0)+		; 2nd plane, hi word
     		move.w	(a3)+,(a0)+		; 3rd plane, hi word
     		move.w	(a4)+,(a0)+		; 4th plane, hi word
       		move.w 	(a1)+,(a0)+		; 1st plane, lo word
     		move.w	(a2)+,(a0)+		; 2nd plane, lo word
     		move.w	(a3)+,(a0)+		; 3rd plane, lo word
     		move.w	(a4)+,(a0)		; 4th plane, lo word
		add.w	d3,a5
		move.l	a5,a0			; a0 -> next line
	       	dbra   	d2,pl4_lw_loop


		rts

*********************************************************
*		8 Plane case				*
*********************************************************
pln_8:		move.l	a0,d1			; d1 -> current line in plane 1
		add.w	d4,d4			; d4 <- offset to next plane
		btst.b	#F_SAVWID,SV_STAT(a2)	; word or longword ?
		bne	pl8_lw_enter

*
* 8 plane: word wide
*
		move.l	a1,a2
		add.w	d4,a2			; a2 -> 2nd plane	
		move.l	a2,a3
		add.w	d4,a3			; a3 -> 3rd plane
		move.l	a3,a4
		add.w	d4,a4			; a4 -> 4th plane
		move.l	a4,a5
		add.w	d4,a5			; a5 -> 5th plane
		move.l	a5,a6
		add.w	d4,a6			; a6 -> 6th plane

		move.w	d4,d5			; d5 <- offset to next plane
		move.w	d5,d6
		add.w	d4,d6			; d6 <- offset to plne aftr nxt

pl8_wd_loop:	move.w	(a1)+,(a0)+		; store 1st plane
		move.w	(a2)+,(a0)+		; store 2nd plane
		move.w	(a3)+,(a0)+		; store 3rd plane
		move.w	(a4)+,(a0)+		; store 4th plane
		move.w	(a5)+,(a0)+		; store 5th plane
		move.w	(a6)+,(a0)+		; store 6th plane
		move.w	-2(a6,d5.w),(a0)+	; store 7th plane
		move.w	-2(a6,d6.w),(a0)	; store 8th plane
		add.l	d3,d1
		move.l	d1,a0			; a0 -> next line
		dbra	d2,pl8_wd_loop

		rts

*
* 8 plane: word wide
*
pl8_lw_enter:	add.w	d4,d4			; d4 <- plane offset
		move.l	a1,a2
		add.w	d4,a2			; a2 -> 2nd plane	
		move.l	a2,a3
		add.w	d4,a3			; a3 -> 3rd plane
		move.l	a3,a4
		add.w	d4,a4			; a4 -> 4th plane
		move.l	a4,a5
		add.w	d4,a5			; a5 -> 5th plane
		move.l	a5,a6
		add.w	d4,a6			; a6 -> 6th plane

		move.w	d4,d5			; d5 <- offset to next plane
		move.w	d5,d6
		add.w	d4,d6			; d6 <- offset to plne aftr nxt

pl8_lw_loop:	move.w 	(a1)+,(a0)+		; 1st plane, hi word
     		move.w	(a2)+,(a0)+		; 2nd plane, hi word
     		move.w	(a3)+,(a0)+		; 3rd plane, hi word
     		move.w	(a4)+,(a0)+		; 4th plane, hi word
		move.w	(a5)+,(a0)+		; 5th plane, hi word
		move.w	(a6)+,(a0)+		; 6th plane, hi word
		move.w	-2(a6,d5.w),(a0)+	; 7th plane, hi word
		move.w	-2(a6,d6.w),(a0)+	; 8th plane, hi word
       		move.w 	(a1)+,(a0)+		; 1st plane, lo word
     		move.w	(a2)+,(a0)+		; 2nd plane, lo word
     		move.w	(a3)+,(a0)+		; 3rd plane, lo word
     		move.w	(a4)+,(a0)+		; 4th plane, lo word
		move.w	(a5)+,(a0)+		; 5th plane, lo word
		move.w	(a6)+,(a0)+		; 6th plane, lo word
		move.w	-2(a6,d5.w),(a0)+	; 7th plane, lo word
		move.w	-2(a6,d6.w),(a0)	; 8th plane, lo word
		add.l	d3,d1
		move.l	d1,a0			; a0 -> next line
	       	dbra   	d2,pl8_lw_loop

hang_it_up:	rts


* HIDE CURSOR
*
*   Increment HIDE_CNT.
*   Replace cursor with data in save_block when
*   HIDE_CNT transitions from 0 to 1

_HIDE_CUR:	move.l  _lineAVar,a5		; a5 -> linea var structww	
		lea	_HIDE_CNT(a5),a2
		addq.w	#1,(a2)			; increment hide count
		cmp.w	#1,(a2)			; count =1 => hide the cursor
		bne	hid_cur1
	
		move.l	a6,-(sp)
		move.l	sv_blk_ptr(a5),a2	; a2 -> save block
		bsr	cur_replace		; turn it off
		move.l	(sp)+,a6

hid_cur1:	rts


* DISPLAY CURSOR
*
*   Decrement HIDE_CNT. On transition from 1 to 0, redisplay 
*   cursor form. If HIDE_CNT < 0 , reset it to 0 but don't
*   redisplay cursor.

_DIS_CUR:	move.l  _lineAVar,a5		; a5 -> linea var structww
		cmp.w	#1,_HIDE_CNT(a5)	; If cur is to be redisplayed,
		bgt	dec_hide_cnt		; perform the operation prior to
		blt	fix_neg			; decrementing semaphore to 0

*   Redisplay only occurs when HIDE_CNT equals one on entry.

		move.w	SR,d0
		or.w	#$0700,SR		; >>>> BEGIN ATOM <<<<

		move.l	_GCURXY(a5),d1		; retrieve of X and Y

*   Some renegade programs reposition the mouse cursor by hiding the
*   cursor, loading new values into GCURXY and showing the cursor.
*   To accomodate this established expectation as well as avoiding 
*   an unneccessary vblank redraw of the cursor after this routine has 
*   already displayed it, the draw flag in the draw packet is cleared.

		clr.b	draw_flag(a5)		; mark packet data invalid

		move.w	d0,SR			; >>>>  END ATOM  <<<<

		move.l	d1,d0			; d1 <- Y
		swap	d0			; d0 <- X

		move.l	a6,-(sp)
		lea	mouse_cdb(a5),a0	; a0 -> system CDB
		move.l	sv_blk_ptr(a5),a2	; a2 -> save block
		bsr	cur_display
		move.l  _lineAVar,a5		; a5 -> linea var structww	
		move.l	(sp)+,a6

dec_hide_cnt:	subq.w	#1,_HIDE_CNT(a5)	; decrement the redraw semaphore
		rts

fix_neg:	clr.w	_HIDE_CNT(a5)		; this should never be executed.
		rts				; it's just paranoia in action.


*  TRANSFORM CURSOR FORM
*
*  transform user defined cursor to device specific format
*
*  in:
*	intin[0]     - X coordinate of hot spot
*	intin[1]     - Y coordinate of hot spot
*	intin[2]     - reserved for future use. must be 1
*	intin[3]     - Mask color index
*	intin[4]     - Data color index
*	intin[5-20]  - 16 words of cursor mask
*	intin[21-36] - 16 words of cursor data

_XFM_CRFM:	move.l  _lineAVar,a2		; a2 -> linea var struct
		addq.b	#1,mouse_flag(a2)	; deny access to mouse_cdb

		move.l	_INTIN(a2),a0		; a0 -> new cur def block
		lea	mouse_cdb(a2),a1	; a1 -> cdb buffer 

		move.w	(a0)+,d0		; Get x hot spot
		and.w	#$000F,d0		; truncate to < 16
		move.w	d0,m_pos_hx(a2)		; init hot spot x

		move.w	(a0)+,d0		; get y hot spot
		and.w	#$000F,d0		; truncate to < 16
		move.w	d0,m_pos_hy(a2)		; init hot spot y

		move.w	(a0)+,m_planes(a2)	; Save the plane count

		move.w	(a0)+,d0		; d0 <- background/mask color index
		cmp.w	_DEV_TAB+26(a2),d0
		bmi	xfm_bg_col_ok		; if color index is too large

		moveq.l	#1,d0			; clamp it to 1

xfm_bg_col_ok:	move.l	#_MAP_COL,a1		; convert color index to a pixel value 
		add.w	d0,d0
		move.w	0(a1,d0.w),m_cdb_bg(a2)

		move.w	(a0)+,d0		; d0 <- foreground/form color index
		cmp.w	_DEV_TAB+26(a2),d0
		bmi	xfm_fg_col_ok		; if color index is too large

		moveq.l	#1,d0			; clamp it to 1

xfm_fg_col_ok:	add.w	d0,d0			; convert color index to a pixel value
		move.w	0(a1,d0.w),m_cdb_fg(a2)

		moveq.l	#15,d0			; mask and data are 16 lines high
		lea	mask_form(a2),a1

xfm_move_loop:	move.w	(a0)+,(a1)+
		move.w	30(a0),(a1)+		; interleave mask and form
		dbra	d0,xfm_move_loop


*  If invisible, the new cursor form will be displayed immediately upon the 
*  SHOW operation. If the cursor is currently visible, the new cursor form 
*  will be displayed at the next vblank. In previous versions of XFM_CRFM, 
*  the new cursor form, if visible, would only be redisplayed at the GCURXY
*  position only after a mouse interrupt was recieved and processed. In this 
*  version the new cursor form, if visible, is displayed at the following 
*  vblank regardless of new mouse events. The vblank draw packet is loaded 
*  with coordinates from GCURXY to maintain behavioral consistancy with
*  privious systems.

		lea	xydraw(a2),a0		; a0 -> vblank draw packet

		move.w	SR,d0
		or.w	#$0700,SR		; >>>> BEGIN ATOM <<<<

		move.l	_GCURXY(a2),(a0)+	; setup the vblank draw packet
		bset.b	#0,(a0)

		move.w	d0,SR			; >>>>  END ATOM  <<<<

		subq.b	#1,mouse_flag(a2)	; unlock mouse_cdb semaphore

		rts


*  SET MOUSE CURSOR POSITION
*
*  	void SET_CUR( NEWX, NEWY )
*
*  Set a new cursor position atomically. Update both GCURXY and the
*  vblank draw parameter block. Mark the parameter block data as valid.


_SET_CUR:	move.l  _lineAVar,a1		; a1 -> linea var struct
		lea	xydraw(a1),a0		; a0 -> vblank draw parameter block
		move.l	4(sp),d1		; d1<31:16> <- newX   d1<15:00> <- newY

		move.w	SR,d0
		or.w	#$0700,SR		; >>>> BEGIN ATOM <<<<

		move.l	d1,_GCURXY(a1)		; set GCURX and GCURY
		move.l	d1,(a0)+		; set vblank draw packet
		bset.b	#0,(a0)			; mark data valid

		move.w	d0,SR			; >>>>  END ATOM  <<<<

		rts



*  INQUIRE MOUSE STATUS
*
*	Implement vq_mouse_status with atomic retrieval of
*	mouse position and button state

_vq_mouse_status:
		move.l  _lineAVar,a2		; a2 -> linea var struct
		move.l	_INTOUT(a2),a0		; a0 -> INTOUT[0]
		move.l	_PTSOUT(a2),a1		; a1 -> PTSOUT[0]

		move.w	 SR,d0
		or.w	 #$0700,SR		; >>>> BEGIN ATOM <<<<

		move.w	_MOUSE_BT(a2),(a0)	; INTOUT[0]   <- button status
		move.l	_GCURXY(a2),(a1)	; PTSOUT[0-1] <- mouse X and Y

		move.w	 d0,SR			; >>>>  END ATOM  <<<<

		move.l	_CONTRL(a2),a0
		moveq.l	 #1,d0
		move.w	 d0,4(a0)		; CONTRL[2] <- INTOUT length
		move.w	 d0,8(a0)		; CONTRL[4] <- PTSOUT length

		rts


* paramater block for a relative mouse BIOS call

rel_pblock:	dc.b	0	; Y=0 at the top of the screen
		dc.b	0	; Generate interrupts on make and break
		dc.b	1	; Mouse X threshold
		dc.b	1	; Mouse Y threshold

* arrow cursor

arrow_cdb:	dc.w	1,0,1,0,1    
		dc.w	%1100000000000000
		dc.w	%1110000000000000
		dc.w	%1111000000000000
		dc.w	%1111100000000000
		dc.w	%1111110000000000
		dc.w	%1111111000000000
		dc.w	%1111111100000000
		dc.w	%1111111110000000
		dc.w	%1111111111000000
		dc.w	%1111111111100000
		dc.w	%1111111000000000
		dc.w	%1110111100000000
		dc.w	%1100111100000000
		dc.w	%1000011110000000
		dc.w	%0000011110000000
		dc.w	%0000001110000000
                          
* arrow data              

	       	dc.w  	%0000000000000000
		dc.w	%0100000000000000
		dc.w	%0110000000000000
		dc.w	%0111000000000000
		dc.w	%0111100000000000
		dc.w	%0111110000000000
		dc.w	%0111111000000000
		dc.w	%0111111100000000
		dc.w	%0111111110000000
		dc.w	%0111110000000000
		dc.w	%0110110000000000
		dc.w	%0100011000000000
		dc.w	%0000011000000000
		dc.w	%0000001100000000
		dc.w	%0000001100000000
		dc.w	%0000000000000000

		.end
