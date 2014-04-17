*********************************  allgem.s  ***********************************
*
* $Revision: 3.5 $	$Source: /u/lozben/projects/vdi/mtaskvdi/RCS/ttgem.s,v $
* =============================================================================
* $Author: lozben $	$Date: 91/07/30 16:01:22 $     $Locker:  $
* =============================================================================
*
* $Log:	ttgem.s,v $
*******************************************************************************

.include	"lineaequ.s"
.include	"devequ.s"


		.globl	_InitFonts
		.globl	_CLEARMEM
   		.globl	_DINIT_G
   		.globl	_EX_TIMV
   		.globl	_GCHC_KEY
   		.globl	_GCHR_KEY
		.globl	_GLOC_KEY
		.globl	_GSHIFT_S
   		.globl	_INIT_G
		.globl	_v_cellarray
		.globl	_v_nop
		.globl	_vq_cellarray
		.globl	esc_init
		.globl	_esc_init
		.globl	_dev_init
		.globl	rout_init


		.globl	_SETBLT
		

		.globl	_MOV_CUR	; External Routines called
		.globl	_XFM_CRFM
		.globl	gl_f_init
		.globl	normal_ascii


		.globl	esce
		.globl	escf
		.globl	_vblqueue
		.globl	mouse_rel
		.globl	vb_draw

		.globl	_v_bas_ad
		.globl	arrow_cdb
		.globl	con_state
		.globl	cur_ms_stat
		.globl	disab_cnt
		.globl	xydraw
		.globl	kbshift
		.globl	rel_pblock


CON		=	  2
DEV		=	CON		; source of key press
BIOS		=	 13
BCONSTAT	=	  1
BCONIN		=	  2
SETEXC		=	  5
TICKCAL		=	  6
XBIOS		=	 14
BLITMODE	=	$40

		.text

*******************************************************************************
*
*	GET SHIFT STATE		entry: 		none
*				exit:		CTL/SHIFT/ALT status in d0
*				destroys:	nothing
*
*******************************************************************************

_GSHIFT_S:	move.b	kbshift,d0	; Get the keyboard state
		andi.w	#$000F,d0	; We only want the low 4 bits

* Reuse a rts for these stubed routines
_v_cellarray:
_v_nop:
_vq_cellarray:

return:		rts

*******************************************************************************
*
*	CLEAR SCREEN		entry: 		none
*				exit:		none
*				destroys:	a0/d0
*
*******************************************************************************

_CLEARMEM:	move.l  _lineAVar,a0		; a0 -> linea var struct
                move.w	_v_planes(a0),d0	; d0 <- # of planes
		mulu.w	v_hz_rez(a0),d0		; d0 <- (planes) x (hor rez)
		mulu.w	v_vt_rez(a0),d0		; d0 <- (plns)x(hrez)x(vrt rz)
		lsr.l	#3,d0			; d0 <- # bytes to clr (screen)
			
		move.l	_v_bas_ad,-(sp)
		add.l	d0,(sp)			; ending addr
		move.l	_v_bas_ad,-(sp)		; starting address
		jsr	clear			; use general clr routine
		addq.l	#8,sp			; cleanup stack

		rts				; return used as general rts

*+
*
*  Quickly zero (lots of) memory.
*  Copyright 1986 Atari Corp.
*
*  Synopsis:	clear(start, end)
*		    LONG start;	    4(sp) -> first location
*		    LONG end;	    8(sp) -> last location + 1
*
*    Uses:	C registers d0-d2/a0-a2
*
*-
clear:		move.l	4(sp),a0	; a0 -> start
		move.l	8(sp),a1	; a1 -> end+1
		movem.l	d3-d7/a3,-(sp)	; save registers

		move.l  _lineAVar,a3	; a3 -> linea var struct
		move.l	pal_map(a3),d1	; d1 <- desired background col

		move.l	d1,d2		; store background
		move.l	d1,d3		;    into d1-d7/a3
		move.l	d1,d4
		move.l	d1,d5
		move.l	d1,d6
		move.l	d1,d7
		move.l	d1,a3

		move.l	a0,d0		; word align first location
		btst	#0,d0
		beq	clr1		; (not necessary)
		move.b	d1,(a0)+

clr1:		move.l	a1,d0		; d0 = ((a1 - a0) & ~0xff)
		sub.l	a0,d0
		and.l	#$ffffff00,d0	; mask fract bits, d0 = whole part
		beq	clr3		; if (d0 == 0) do end-fraction;
		lea	(a0,d0.l),a0	; a0 -> end of huge area
		move.l	a0,a2		; a2 -> there, too
		lsr.l	#8,d0		; get 256-byte chunk count

clr2:		movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
		movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
		movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
		movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
		movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
		movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
		movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
		movem.l	d1-d7/a3,-(a2)	; clear 32 bytes
		subq.l	#1,d0		; decrement count
		bne	clr2		; while (d0) clear some more...

clr3:		cmp.l	a0,a1		; while (a0 != a1)
		beq	clr4		; (done)
		move.b	d1,(a0)+	; clear a byte
		bra	clr3

clr4:		movem.l	(sp)+,d3-d7/a3	; restore registers
		rts

*******************************************************************************
*
*	INITIALIZE GRAPHICS	entry: 		none
*				exit:		none
*				destroys:	see CLEARMEM
*
*******************************************************************************

_INIT_G:	move.l  _lineAVar,a1		; a1 -> linea var struct
		move.l	#return,tim_addr(a1)	; Tick points to rts

		move	SR,-(sp)		; Disable interrupts
		ori.w	#$0700,SR

		pea	tick_int		; My timer vector
		move.w	#$100,-(sp)		; 100 is timer vector
		move.w	#5,-(sp)		; exchange exception vector
		trap	#13

		move.l  _lineAVar,a1		; a1 -> linea var struct
		addq.l	#8,sp			; clean up stack
		move.l	d0,tim_chain(a1)	; Set up chain before int enabl
		move	(sp)+,SR		; Restore interrupt context

		bsr	mouse_init		; Init the mouse
		jsr	escf			; hide alpha cursor

		bra	_CLEARMEM


*******************************************************************************
*
*	EXCHANGE TIMER VECTOR	entry: 		new vector in CONTRL[7-8]
*				exit:		old vector in CONTRL[9-10]
*				destroys:	a0/a1
*
*******************************************************************************

_EX_TIMV:	move.l  _lineAVar,a1		; a1 -> linea var struct
		move.l	_CONTRL(a1),a0

		move	SR,-(sp)		; Disable interrupts
		ori.w	#$0700,SR		; THIS IS PARANOID !
		move.l	tim_addr(a1),18(a0)
		move.l	14(a0),tim_addr(a1)
		move	(sp)+,SR

		move.w	#TICKCAL,-(sp)		; Get ms/tick
		trap	#BIOS
		addq.l	#2,sp

		move.l  _lineAVar,a1		; a1 -> linea var struct
		move.l	_INTOUT(a1),a0
		move.w	d0,(a0)

		rts


*******************************************************************************
*
*	Timer interrupt routine	entry: 		none
*				exit:		none
*				destroys:	none
*
*******************************************************************************

tick_int:	subq.l  #4,sp			; leave some room on the stack
		movem.l	d0-d7/a0-a6,-(sp)
		move.l  _lineAVar,a1		; a1 -> linea var struct
		move.l	tim_addr(a1),a0		; Invoke user routine
		move.l	tim_chain(a1),60(sp)	; store chained routine
		jsr	(a0)
		movem.l	(sp)+,d0-d7/a0-a6
		rts				; jump to next routine in chain


*******************************************************************************
*
*	DEINITIALIZE GRAPHICS	entry: 		none
*				exit:		none
*				destroys:	a1 + see dinit_mouse, CLEARMEM,
*						esce
*
*******************************************************************************

_DINIT_G:	move.l  _lineAVar,a1		; a1 -> linea var struct
		move.l	tim_chain(a1),-(sp)	; reset timer vector
		move.w	#$100,-(sp)
		move.w	#SETEXC,-(sp)
		trap	#BIOS
		addq.l	#8,sp

		bsr	dinit_mouse
		bsr	_CLEARMEM
		jmp	esce			; Show the alpha cursor. return



*******************************************************************************
*
*
*	GCHC_KEY	get choice for choice input: NOT IMPLEMENTED
*
*			exit:	d0:   0	 nothing happened
*				      1	 choice value
*				      2	 button pressed
*
*				TERM_CH	 16 bit char info
*				
*******************************************************************************

_GCHC_KEY:	move.l  _lineAVar,a1		; a1 -> linea var struct
		move.w	#1,_TERM_CH(a1)		; return dummy choice per 8086
		moveq.l	#1,d0			; indicate choice value
		rts


*******************************************************************************
*
* title:	_GLOC_KEY
*
* purpose:	Note which buttons have had a state change and whether
*		the mouse has been moved since the previous envocation of
*		this routine. If the button states havn't changed, check
*		for a key press from the console device.
*
* output:
*
*	d0	0	- nothing
*
*		1	- button or key pressed
*
*  			   _TERM_CH = 16 bit char info
*
*		2 	- new coordinates
*
*			   _X1 = new X
*			   _Y1 = new Y
*
*		3	- button or key pressed and new coordinates
*			
*			   _TERM_CH = 16 bit char info
*			   _X1 = new X
*			   _Y1 = new Y
*
* 	NOTE:	THIS ROUTINE REPORTS THE LAST CHANGE IN BUTTON STATE 
*		RATHER THAN REPORTING THE BUTTON STATE ITSELF. THE
*		BUTTON STATE CHANGE FLAGS AND MOTION FLAG ARE CLEARED
*		ON EXIT SO THAT SUBSEQUENT CALLS TO THE ROUTINE WILL NOT 
*		YIELD DUPLICATE REPORTS OF THE SAME EVENT. WHEN USING THIS
*		ROUTINE TO POLL THE MOUSE FOR A PARTICULAR CONDITION, THE 
*		FIRST CALL MAY NOT RETURN CURRENT BUTTON CHANGE STATE DATA 
*		BUT IT WILL INITIALIZE THE SYSTEM FOR SUBSEQUENT CALLS.
*
*******************************************************************************

_GLOC_KEY:	move.l  _lineAVar,a1		; a1 -> linea var struct
		moveq.l	#3,d1		; d1 <- mask for updating cur_ms_stat

		move.w	SR,d0

		or.w	#$0700,SR		; >>>> BEGIN ATOM <<<<
		move.b	cur_ms_stat(a1),d2	; clearing state change flags indicates
		and.b	d1,cur_ms_stat(a1)	; that this data has been processed
		move.l	_GCURXY(a1),_X1(a1)	; X1<-latest X and Y1<-latest Y
		move.w	d0,SR			; >>>>  END ATOM  <<<<

		clr.w	d0		; d0 <- initial status: no change

		btst.l	#5,d2
		beq	test_button

		addq.w	#2,d0		; status: coordinate information valid

test_button:	and.b	#$C0,d2		; test for change in button state
		beq	key_stat	; if no change, check for key press

		move.w	#$20,d1		; d1 <- lf button terminator code: 32
		btst.l	#6,d2		; left button has priority over right.
		bne	button_exit	; if left isn't down then right is.

		addq.w	#1,d1		; d1 <- rt button terminator code: 33

button_exit:	move.w	d1,_TERM_CH(a1)	; store the character code
		addq.w	#1,d0		; status: mouse button pressed
		rts


key_stat:	move.w	 d0,-(sp)	; preserve mouse status
		bsr	_GCHR_KEY	; d0 on return:  0:no key  1:key press
		add.w	 (sp)+,d0	; d0 <- final locator status
		rts

*******************************************************************************
*
*	GCHR_KEY	get char for string input
*			entry: none
*			exit:  d0=1	key pressed
*			       d0=0	nothing happened
*
*			_TERM_CH		16 bit char info
*
*******************************************************************************

_GCHR_KEY:	move.w	#DEV,-(sp)	; see if a character present
		move.w	#BCONSTAT,-(sp)
		trap	#BIOS
		addq.l	#4,sp

		tst.w	d0		; d0=0 => no character
		beq	no_char

		move.w	#DEV,-(sp)	; load proper devoce
		move.w	#BCONIN,-(sp)	; get the character
		trap	#BIOS
		addq.l	#4,sp

		move.l	d0,d1
		swap	d1
		lsl.w	#8,d1		; d0<07:00> <- ascii code
		or.w	d1,d0		; d0<15:08> <- scan code

		move.l  _lineAVar,a1	; a1 -> linea var struct
		move.w	d0,_TERM_CH(a1)	; store character
		moveq.l	#1,d0		; indicate character present

no_char:	rts


*******************************************************************************
*
*  INITIALIZE MOUSE
*
*  on entry:
*
*     _GCURXY	initial XY position of mouse cursor
*
*******************************************************************************

mouse_init:	move.l  _lineAVar,a1		; a1 -> linea var struct
		lea	user_init,a0		; button and motion vectors
		move.l	a0,user_but(a1)		; default to no action (rts)
		move.l	a0,user_mot(a1)
		move.l	#_MOV_CUR,user_cur(a1)	; set up link to vblank display

* Initialize the default mouse form (presently the arrow)

		lea	_INTIN(a1),a0		; a0 -> pointer to INTIN array
		move.l	(a0),-(sp)		; Save the intin pointer and
		move.l	#arrow_cdb,(a0)		; make it point to the arrow
		bsr	_XFM_CRFM		; a1 gets clobered here
		move.l  _lineAVar,a1		; a1 -> linea var struct

		move.l	(sp)+,_INTIN(a1)	; Restore INTIN pointer

* initialize mouse/draw status and semaphores

		moveq.l	#0,d0
		move.w	d0,_MOUSE_BT(a1)	; clear mouse button state
		move.b	d0,cur_ms_stat(a1)	; clear current mouse status
		move.b	d0,mouse_flag(a1)	; mouse_cdb is unlocked
		move.b	#1,_HIDE_CNT(a1)	; don't display cursor form yet

* Initialize communication packet between mouse interrupt service routine
* and vblank cursor display routine. Insert vblank draw routine into front
* of vblank queue.

		lea	xydraw(a1),a0		; init the draw parameter block

		move.w	v_hz_rez(a1),d0		; d0 <- horizontal rez
		lsr.w	d0			; d0 <- x rez / 2
		move.w	d0,_GCURX(a1)		; init mouse X position

		move.w	v_vt_rez(a1),d0		; d0 <- vrtical rez
		lsr.w	d0			; d0 <- y rez / 2
		move.w	d0,_GCURY(a1)		; init mouse Y position

		move.l	_GCURXY(a1),(a0)+	; to the initial position
		move.b	#1,(a0)			; mark data valid for update

		move.l	_vblqueue,a0		; insert the display routine
		move.l	#vb_draw,(a0)		; at the head of the queue

* Activate mouse interrupt processing

		pea	mouse_rel	; mouse packet interrupt handler
		pea	rel_pblock	; mouse configuration parameter block
		move.w	#1,-(sp)	; enable mouse, in relative mode
		clr.w	-(sp)		; INITMOUSE
		trap	#XBIOS
		lea	12(sp),sp

user_init:	rts



*******************************************************************************
*
*	DEINITIALIZE MOUSE	entry: 		none
*				exit:		none
*				destroys:	a0/d0
*
*******************************************************************************

dinit_mouse:	move.l	_vblqueue,a0	; remove draw routine from vblank queue
		clr.l	(a0)

		moveq.l	#-1,d0
		move.l	d0,-(sp)	; discontinue mouse processing
		move.l	d0,-(sp)
		clr.l	-(sp)		; type=0: disable mouse
		trap	#XBIOS		; INITMOUSE
		lea	12(sp),sp

		rts

	
*******************************************************************************
*			    escape initialization 			      *
*******************************************************************************

*+
* dev_init(devPtr). devPtr points to the proper device structure. Init current
* device pointer in linea variable structure, then drop through to esc_init().
*-
_dev_init:	move.l	_lineAVar,a1			; a1 -> lina var struct
		tst.l	UserDevInit(a1)			; see if vector set
		beq	devI4				; branch if not
		move.l	UserDevInit(a1),a0		; see if vector set
		jsr	(a0)				; execute user routine

devI4:		move.l	4(sp),a0			; a0 -> device struct
		move.l	a0,CUR_DEV(a1)			; init cur dev pointer
		move.l	#_ram8x16,DEVFNTPTR(a0)		; assume 8x16 sys fnt
		cmp.w	#400,DEVYREZ(a0)		; check vertical rez
		bge	devI0				; skip if fnt ok
		move.l	#_ram8x8,DEVFNTPTR(a0)		; set to an 8x8 sys fnt
		tst.l	DEVCURROUTINES(a0)		; see if routines set
		bne	esc_init			; if so don't do it

devI0:		cmp.w	#PIXPACKED,DEVFORMID(a0)	; see if pixel packed
		bne	devI2				; skip if not
		cmp.w	#16,DEVPLANES(a0)		; see if FALCON030
		bne	devI1				; if not init to other
		move.l	#_SPPixSoftList,DEVSOFTROUTINES(a0)
		move.l	#_SPPixHardList,DEVHARDROUTINES(a0)
		move.l	#_SPPixSoftList,DEVCURROUTINES(a0)
		bra	esc_init			; init glass TTY

devI1:		move.l	#_PixSoftList,DEVSOFTROUTINES(a0)
		move.l	#_PixHardList,DEVHARDROUTINES(a0)
		move.l	#_PixSoftList,DEVCURROUTINES(a0)
		bra	esc_init			; init glass TTY

devI2:		move.l	#_STSoftList,DEVSOFTROUTINES(a0)
		move.l	#_STHardList,DEVHARDROUTINES(a0)
		move.l	#_STSoftList,DEVCURROUTINES(a0)
		bra	esc_init			; init glass TTY

_esc_init:
esc_init:	jsr	_InitFonts		; copy font headers into ram

    		move.l  _lineAVar,a1		; a1 -> linea var struct
		tst.l	UserEscInit(a1)		; see if vector set
		beq	esc4			; branch if not
		move.l	UserEscInit(a1),a0	; see if vector set
		jsr	(a0)			; execute user routine

esc4:		move.l	CUR_DEV(a1),a0		; a0 -> curr device structure
		move.w	DEVPLANES(a0),_v_planes(a1)	; set # of planes
		move.w	DEVLINEWRAP(a0),_v_lin_wr(a1)	; set line wrap
		move.w	DEVLINEWRAP(a0),_bytes_lin(a1)	; set line wrap
		move.w	DEVYREZ(a0),v_vt_rez(a1)	; set vertical rez
		move.w	DEVXREZ(a0),v_hz_rez(a1)	; set horizontal rez
		tst.l	DEVVIDADR(a0)			; see if we need to set
		beq	esc2				; if not then skip
		move.l	DEVVIDADR(a0),_v_bas_ad		; set video base adr

esc2:		move.w	#0,byt_per_pix(a1)		; assume 0 bytes/pix
		move.w	DEVFORMID(a0),form_id(a1)   	; init mem config flag 
		cmp.w	#PIXPACKED,DEVFORMID(a0)     	; see if in pix packed
		bne	esc0
		move.w	_v_planes(a1),d1	; # of planes
		lsr.w	#3,d1			; d1 <- # of bytes per pix
		move.w	d1,byt_per_pix(a1)	; load # bytes per pix

esc0:		lea	save_block(a1),a2	; a0 -> save_block
		cmp.w	#4,_v_planes(a1)	; see if we have > 4 planes
		ble	esc1			; if so point to > save buff
		lea	_save_block(a1),a2	; a0 -> save_block
esc1:		move.l	a2,sv_blk_ptr(a1) 	; init ptr to pnt to save_block

		move.l	DEVFNTPTR(a0),a0	; a0 -> desired system font

		jsr	gl_f_init		; init the glob font variables

		move.l  _lineAVar,a1		; a1 -> linea var struct
		moveq.l	#0,d0
		move.w	d0,v_col_fg(a1)		; foreground color is all ones
		move.l	d0,vl_col_fg(a1)	; set in case we are 32 bit mode
		move.w	d0,v_cur_cx(a1)
		move.w	d0,v_cur_cy(a1)
		move.w	d0,v_cur_off(a1)
		move.b	d0,v_delay(a1)		; cursor redisplay interval (immediate)

		not.l	d0
		move.w	d0,v_col_bg(a1)		; background color is all zeros
		move.l	d0,vl_col_bg(a1)	; set in case we are 32 bit mode

		move.l	CUR_DEV(a1),a0		; a0 -> curr device structure
		tst.w	DEVLOOKUPTABLE(a0)     	; see if there is a lookup tble
		beq	esc3			; if not then skip
		not.w	v_col_fg(a1)		; in a lookup table we need
		not.l	vl_col_fg(a1)		;	to switch foreground
		not.w	v_col_bg(a1)		;	and background
		not.l	vl_col_bg(a1)

esc3:		move.l	_v_bas_ad,v_cur_ad(a1)	; home cursor.
		move.l	#-1,col_and_mask(a1)	; init "and" mask for vs_color

		moveq.l	#1,d0
		move.b	d0,v_stat_0(a1)		; flash, nowrap, normal video.
		move.w	d0,disab_cnt(a1)	; cursor disabled 1 level deep.

		move.l	#30,d0
		move.b	d0,v_cur_tim(a1)	;.5 sec blink rate (@60 Hz vbl)
		move.b	d0,vct_init(a1)		;.5 sec blink rate (@60 Hz vbl)

		move.l	#normal_ascii,con_state ; Init conout state machine

		move.w	v_hz_rez(a1),d0		; d0 <- horizontal rez
		lsr.w	d0			; d0 <- x rez / 2
		move.w	d0,_GCURX(a1)		; init mouse X position

		move.w	v_vt_rez(a1),d0		; d0 <- vrtical rez
		lsr.w	d0			; d0 <- y rez / 2
		move.w	d0,_GCURY(a1)		; init mouse Y position

		move.w	#1,-(sp)		; try set Blit mode to hard
		move.w	#BLITMODE,-(sp)		; push funct #
		trap	#XBIOS
		addq.l	#4,sp			; cleanup stack

		jsr	_InitDevTabInqTab	; initialize more variables

		bra	_CLEARMEM		; blank screen. ret from there

		.end
