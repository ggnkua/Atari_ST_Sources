		.globl	_CLEARMEM       * globl routines declared here
		.globl	_DINIT_G
		.globl	_EX_TIMV
		.globl	_GCHC_KEY
		.globl	_GCHR_KEY
		.globl	_GLOC_KEY
		.globl	_GSHIFT_S
		.globl	_INIT_G

		.globl	_MOV_CUR	* External routines used here
		.globl	_XFM_CRFM
		.globl	scrn_clip
		.globl	vb_draw
		.globl	escfn2		* enter graphics mode
		.globl	escfn3		* exit graphics mode

		.globl	ms_buffer	* Global variables declared here
		.globl	delta_x
		.globl	delta_y

		.xdef	_CONTRL		* External variables used here
		.xdef	_GCURX
		.xdef	_GCURY
		.xdef	_HIDE_CNT
		.xdef	_INTIN
		.xdef	_INTOUT
		.xdef	_MOUSE_BT
		.xdef	_TERM_CH
		.xdef	_v_bas_ad
		.xdef	_v_lin_wr
		.xdef	_v_planes
		.xdef	_X1	
		.xdef	_Y1
		.xdef	arrow_cdb
		.xdef	cur_ms_stat
		.xdef	draw_flag
		.xdef	mouse_flag
		.xdef	tim_addr
		.xdef	user_but
		.xdef	user_cur
		.xdef	user_mot

handle	=	2		* leave 2 for console input, change to 1 for auxin

screen_siz	=	8189
v_base		=	$F8000

		.data
copyright	dc.b	'GEMVDI V1.0  8/15/85'
		dc.b	'Lisa 2/5 Screen Driver'
		dc.b	'Serial No. XXXX-0000-654321 '
		dc.b	'All Rights Reserved'
		dc.b	'Copyright (C) 1985 '
		dc.b	'Digital Research Inc.'

		.text
****************************************************************************
*
*	GET SHIFT STATE		entry: 		none
*				exit:		CTL/SHIFT/ALT status in d0
*				destroys:	nothing
*
***************************************************************************

_GSHIFT_S:
	move.w	#-1, -(sp)	* Ask BIOS for status of CTL-ALT-SHIFT
	move.w	#$B, -(sp)
	trap	#13

	addq.l	#4, sp		* Clean up the stack

	andi.w	#$000F, d0	* We only want the low 4 bits
	rts

************************************************************
*
*	CLEAR SCREEN		entry: 		none
*				exit:		none
*				destroys:	d0/a0
*
************************************************************

_CLEARMEM:	move.l	_v_bas_ad,a0
		move.w	#screen_siz,d0
		moveq.l	#0,d1

scr_loop:	move.l	d1,(a0)+
		dbra	d0,scr_loop

just_rts:	rts

************************************************************
*
*	INITIALIZE GRAPHICS	entry: 		none
*				exit:		none
*				destroys:	see CLEARMEM
*
************************************************************

_INIT_G:	move.l	#v_base, _v_bas_ad
		move.w	#90, _v_lin_wr
		move.w	#1, _v_planes

		clr.b	in_proc		* no vblanks in process

		move.l	#just_rts, tim_addr	* Tick points to rts

		clr.w	-(sp)			* get a handle to the clock
		pea	clock			* device
		move.w	#$3d, -(sp)
		trap	#1
		move.w	d0, clock_handle
		addq.l	#8, sp

		move	SR, -(sp)		* Disable interrupts
		ori.w	#$0700, SR

		pea	tick_int		* Get character vector for
		clr.w	-(sp)			* the clock using IOCTL function
		move.w	d0, -(sp)
		move.w	#-1, -(sp)
		move.w	#$44, -(sp)
		trap	#1

		move.l	d0, tim_chain		* Set up chain before ints go on

		add.l	#12, sp			* clean up stack

		move	(sp)+, SR		* Restore interrupt context

		bsr	mouse_init

		bra	escfn2

**************************************************************************
*
*	EXCHANGE TIMER VECTOR	entry: 		new vector in CONTRL[7-8]
*				exit:		old vector in CONTRL[9-10]
*				destroys:	a0
*
**************************************************************************

_EX_TIMV:
		move.l	_CONTRL, a0

		move	SR, -(sp)	* Disable interrupts
		ori.w	#$0700, SR
		move.l	tim_addr,  18(a0)
		move.l	14(a0), tim_addr
		move	(sp)+, SR

		move.w	#6, -(sp)	* Get number of milliseconds per tick
		trap	#13
		addq.l	#2, sp

		move.l	_INTOUT, a0
		move.w	d0, (a0)

		rts

************************************************************
*
*	Timer interrupt routine	entry: 		none
*				exit:		none
*				destroys:	none
*
************************************************************

tick_int:
		tst.b	in_proc			* if we are still running, exit
		bne	timer_exit
		inc.b	in_proc

		movem.l	d0-d7/a0-a6, -(sp)
		move	SR, -(sp)		* Disable interrupts
		ori.w	#$0700, SR

		move.l	tim_addr, a0		* Invoke user routine
		jsr	(a0)

		move	(sp)+, SR		* Restore interrupt context

* see if the mouse needs drawing

		bsr	vb_draw
		clr.b	in_proc		*allow yet another trip through
		movem.l	(sp)+, d0-d7/a0-a6
timer_exit:
		move.l	tim_chain, -(sp)
		rts

************************************************************
*
*	DEINITIALIZE GRAPHICS	entry: 		none
*				exit:		none
*				destroys:	see CLEARMEM
*
************************************************************
_DINIT_G:
		move.l	tim_chain, -(sp)	* reset timer vector
		clr.w	-(sp)
		move.w	clock_handle, -(sp)
		move.w	#-1, -(sp)
		move.w	#$44, -(sp)
		trap	#1
		add.l	#12, sp

		move.w	clock_handle, -(sp)	* close the handle to the
		move.w	#$3E, -(sp)		* clock device
		trap	#1
		addq.l	#4, sp

		bsr	dinit_mouse
		bra	escfn3

************************************************************
*
*	GCHC_KEY	-get choice for choice input
*			entry:	none
*			exit:	d0=0	nothing happened
*				d0=1	choice value
*				d0=2	button pressed
*
*			TERM_CH		16 bit char info
*				
************************************************************

_GCHC_KEY:
		moveq	#1,d0
		move.w  d0, _TERM_CH
		rts

************************************************************
*
*	GCHR_KEY	-get char for string input
*			entry: none
*			exit:  d0=1	button pressed
*			       d0=0	nothing happened
*
*			TERM_CH		16 bit char info
*
************************************************************

_GCHR_KEY:
		move.w	#handle, -(sp)	* see if a character present at aux port
		move.w	#1, -(sp)
		trap	#13
		addq.l	#4, sp

		tst.w	d0
		beq	no_char

		move.w	#handle, -(sp)	* get the character
		move.w	#2, -(sp)	* from auxin
		trap	#13
		addq.l	#4, sp

		move.l	d0, d1
		swap	d1
		lsl.w	#8, d1
		or.w	d1, d0

		move.w	d0,_TERM_CH	* store char
		move.l	#1,d0
		rts
no_char:
		moveq.l	#0,d0
		rts

************************************************************
*
*	INITIALIZE MOUSE	entry: 		none
*				exit:		none
*				destroys:	d0/a0-a1
*
************************************************************

mouse_init:
		lea.l	user_init,a0	* init user_but and user_mot to 
		move.l	a0,user_but	* just rts
		move.l	a0,user_mot	*

		move.l	#_MOV_CUR, user_cur	* initialize user_cur vector

*  Move in the default mouse form (presently the arrow)

		move.l	_INTIN, -(sp)		* Save the intin pointer and make
		move.l	#arrow_cdb, _INTIN	* it point to the arrow

		bsr	_XFM_CRFM

		move.l	(sp)+, _INTIN		* Restore INTIN pointer


*	INIT MOUSE INTERUPT VARIABLES

		moveq	#0, d0
		move.b	d0, cur_ms_stat	* init cur_mouse_stat
		move.b	d0, mouse_flag	* interrupts can happen
		move.b	d0, draw_flag	* No action yet on vblank

* Get mouse execption vector

		clr.w	-(sp)			* get a handle to the mouse
		pea	mouse			* device
		move.w	#$3d, -(sp)
		trap	#1
		move.w	d0, mouse_handle
		addq.l	#8, sp

		move	SR, -(sp)		* Disable interrupts
		ori.w	#$0700, SR

		pea	int_mouse		* Get character vector for
		clr.w	-(sp)			* the mouse using IOCTL function
		move.w	d0, -(sp)
		move.w	#-1, -(sp)
		move.w	#$44, -(sp)
		trap	#1

		move.l	d0, mouse_chain		* Set up chain before ints go on

		add.l	#12, sp			* clean up stack

		move	(sp)+, SR		* Restore interrupt context

user_init:
		rts


************************************************************
*
*	DEINITIALIZE MOUSE	entry: 		none
*				exit:		none
*				destroys:	nothing
*
************************************************************

dinit_mouse:
		move.l	mouse_chain, -(sp)	* reset timer vector
		clr.w	-(sp)
		move.w	mouse_handle, -(sp)
		move.w	#-1, -(sp)
		move.w	#$44, -(sp)
		trap	#1
		add.l	#12, sp

		move.w	mouse_handle, -(sp)	* close the handle to the
		move.w	#$3E, -(sp)		* mouse device
		trap	#1
		addq.l	#4, sp

		rts

************************************************************
*
*	_GLOC_KEY	-get locator key
*
*			entry:	none
*			exit:	d0=0	-nothing
*
*				d0=1	-button pressed
* 					   _TERM_CH = 16 bit char info
*
*				d0=2 	-coordinate info
*					   _X1 = new x
*					   _Y1 = new y
*				d0=4	-NOT IMPLIMENTED IN THIS VERSION
*
************************************************************

_GLOC_KEY:
		move.b	cur_ms_stat,d0
		move.b	d0,d1		* save state
		andi.b	#$c0,d0		* mask out all but button status bits
		cmpi.b	#0,d0		* see if mouse status changed
		beq	key_stat	* nothing go check key stat
		move.w	#$20,_TERM_CH	* send terminator code for left key

clr_bt_stat:
		andi.b	#$23,d0		* clear mouse button status
		move.b	d0,cur_ms_stat	* store cleared state
		move.w	#1,d0		* set button pressed flag
		rts

key_stat:	move.w	#handle, -(sp)	* see if a character present at aux port
		move.w	#1, -(sp)
		trap	#13
		addq.l	#4, sp

		tst.w	d0
		beq	mov_stat	* no char

		move.w	#handle, -(sp)	* get the character
		move.w	#2, -(sp)	* from auxin
		trap	#13
		addq.l	#4, sp
		move.l	d0, d1
		swap	d1
		lsl.w	#8, d1
		or.w	d1, d0
		move.w	d0,_TERM_CH	* store char
		move.l	#1,d0
		rts
mov_stat:
		bclr.l	#5,d1		* test and clear mouse motion flag 
		beq	no_chg

		move.b	d1,cur_ms_stat	* save mouse stat
		move.w	_GCURX,_X1	* set _X1 = _GCURX
		move.w	_GCURY,_Y1	* set _Y1 = _GCURY
		move.l	#2,d0
		rts

no_chg:		move.l	#0,d0
		rts
	
************************************************************
*
*	MOUSE INTERUPT ROUTINE	entry: 	8(sp) = address of mouse buffer
*				exit:		none
*				destroys:	nothing
*
************************************************************

int_mouse:
		tst.b	mouse_flag	* If we are in a show/hide operation
		bne	ms_exit		* just exit.

		link	a6, #0
		movem.l	d0-d7/a0-a5,-(sp)	* save registers used
		move.l	8(a6), d0		* see if we have a mouse packet
		btst.l	#0, d0			* bit 0 = 1 is packet
		beq	ms_done

		move.l	12(a6), a0	* get pointer to mouse packet
		move.b	(a0),d0		* get header from mouse buffer
		move.b	d0,d1		* save it

		move.b	cur_ms_stat,d1	* get previous mouse state

		andi.w	#3,d1		* mask out state codes bits 6,7
		cmp.b	d1,d0		* has button state changed
		beq	xy_update	* no go test x,y change

		move.w	d1,-(sp)	* save previous mouse state
		move.l	user_but,a1	* get user routine address
		move.w	SR, -(sp)	* Call user with interrupts off
		ori.w	#$0700, SR
		jsr 	(a1)

		move.w	(sp)+, SR	* restore interrupt context
		move.w	(sp)+, d1	* get back previous state
		move.w	d0,_MOUSE_BT

		eor.b	d0, d1		* compute which buttons have changed
		ror.b	#2, d1		* put deltas in bits 6 & 7
		or.b	d1, d0		* combine deltas and states

		move.b	d0, cur_ms_stat	* store change in button stat

xy_update:
		move.b	1(a0), d0
		or.b	2(a0), d0
		bne	new_coord

		bclr.b	#5,cur_ms_stat	* no motion clear motion status
		bra	ms_done		* no change done bye-bye

new_coord:
		bset.b	#5,cur_ms_stat	* motion set motion status

		move.w	_GCURX,d0	* init d0 to _GCURX
		move.b	1(a0), d1

		ext.w	d1		* sign extend to word
		add.w	d1, d0		* d0 contains new x coordinate

		move.w	_GCURY,d1	* init d1 to _GCURY
		move.b	2(a0), d3
		ext.w	d3		* sign extend to word
		add.w	d3, d1		* d1 contains new x coordinate

		bsr	scrn_clip
		move.l	user_mot,a1	* get user routine address
		move.w	SR, -(sp)	* Call user with interrupts off
		ori.w	#$0700, SR
		jsr	(a1)		* call user to modify x,y
		move.w	(sp)+, SR	* restore interrupt context
		bsr	scrn_clip

		move.w	d0,_GCURX	* save new X location
		move.w	d1,_GCURY	* save new y location

		move.l	user_cur,a1	* get user routine address
		move.w	SR, -(sp)	* Call user with interrupts off
		ori.w	#$0700, SR
		jsr	(a1)		* call user to draw cursor
		move.w	(sp)+, SR	* restore interrupt context
*					* d0 contains new x position
*					* d1 contains new y position
ms_done:
		movem.l	(sp)+,d0-d7/a0-a5	* restore old registers
		unlk	a6
ms_exit:
		move.l	mouse_chain, -(sp)	* chain to next guy
		rts

		.bss
_v_bas_ad	ds.l	1

in_proc		ds.b	1	* non-zero if my timer code is running
ms_buffer	ds.b	1	* mouse_buffer (header and button info)
delta_x		ds.b	1	* change in x pos. 2's comp
delta_y		ds.b	1	* change in y pos. 2's comp
clock_handle	ds.w	1
mouse_handle	ds.w	1
tim_chain	ds.l	1
mouse_chain:	ds.l	1
		.data
clock		.dc.b	'CLOCK:',0
mouse		.dc.b	'MOUSE:',0
		.end
