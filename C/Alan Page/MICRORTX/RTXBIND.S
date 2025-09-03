*************************************************************************
*									*
*	RTXBIND.S							*
*									*
*	(C) Copyright 1986, Beckemeyer Development Tools		*
*	All Rights Reserved						*
*									*
*	RTX interface to Alcyon C.  These are re-entrant.		*
*									*
*************************************************************************
.data
errmsg:
	dc.b	'Fatal: RTX Not Installed',$d,$a,0

.comm rtxbyte,1

.text
rtx_fatal:
	pea errmsg			* address message
	move.w #9,-(sp)			* Cconws(errmsg)
	trap #1				* enter GEMDOS
	addq.l #6,sp			* pop stack
	move.w #-70,-(sp)		* return -70 RTX error
	move.w #$4c,-(sp)		* Pterm(-70)
	trap #1				* enter GEMDOS
	addq.l #6,sp			* loop if it returns
	bra rtx_fatal
	
	
	.globl _rtx_install
_rtx_install:
	pea 0				* go into supervisor mode
	move.w #$20,-(sp)		* Super(0)
	trap #1				* enter GEMDOS
	move.b $94,rtxbyte		* check RTX vector
	move.l d0,2(sp)			* set SSP back
	move.w #$20,(sp)		* Super(savessp)
	trap #1				* enter GEMDOS
	addq.l #6,sp			* restore stack
	tst.b rtxbyte			* RTX there?
	bne rtx_fatal			* no, exit
*
* OK, now do RTX install
*
	move.l 4(sp),-(sp)		* root basepage address
	move.w #0,-(sp)			* rtx_install
	trap #5				* enter RTX
	addq.l #6,sp
	rts

	.globl _p_create
_p_create:
	link a6,#0
	move.l 26(a6),-(sp)		* stack size
	move.l 22(a6),-(sp)		* stack args
	move.w 20(a6),-(sp)		* arg word count
	move.l 16(a6),-(sp)		* load address
	move.w 14(a6),-(sp)		* slice
	move.w 12(a6),-(sp)		* priority
	move.l  8(a6),-(sp)		* name	
	move.w #1,-(sp)			* p_create
	trap #5				* enter RTX
	unlk a6				* restore stack 
	rts

	.globl _p_delete
_p_delete:
	move.l 4(sp),-(sp)		* PID
	move.w #2,-(sp)			* p_delete
	trap #5				* enter RTX
	addq.l #6,sp			* restore stack
	rts


	.globl _p_priority
_p_priority:
	link a6,#0
	move.w 12(a6),-(sp)		* delta
	move.l  8(a6),-(sp)		* PID
	move.w #3,-(sp)			* p_priority
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _p_slice
_p_slice:
	link a6,#0
	move.w 12(a6),-(sp)		* delta
	move.l  8(a6),-(sp)		* PID
	move.w #4,-(sp)			* p_slice
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _q_create
_q_create:
	link a6,#0
	move.w 12(a6),-(sp)		* Q type
	move.l  8(a6),-(sp)		* Q name
	move.w #5,-(sp)			* q_create
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _q_delete
_q_delete:
	move.l 4(sp),-(sp)		* QID
	move.w #6,-(sp)			* q_delete
	trap #5				* enter RTX
	addq.l #6,sp
	rts

	.globl _q_send
_q_send:
	link a6,#0
	move.l 12(a6),-(sp)		* messsage buffer
	move.l  8(a6),-(sp)		* QID
	move.w #7,-(sp)			* q_send	
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _q_req
_q_req:
	link a6,#0
	move.l 18(a6),-(sp)		* timeout
	move.w 16(a6),-(sp)		* nowait option
	move.l 12(a6),-(sp)		* message buffer
	move.l 8(a6),-(sp)		* QID
	move.w #8,-(sp)			* q_req
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _q_jam
_q_jam:
	link a6,#0
	move.l 12(a6),-(sp)		* messsage buffer
	move.l  8(a6),-(sp)		* QID
	move.w #9,-(sp)			* q_jam
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _e_signal
_e_signal:
	link a6,#0
	move.w 12(a6),-(sp)		* event
	move.l  8(a6),-(sp)		* PID
	move.w #$a,-(sp)		* e_signal
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _e_wait
_e_wait:
	link a6,#0
	move.l 14(a6),-(sp)		* timeout
	move.w 12(a6),-(sp)		* condition
	move.l  8(a6),-(sp)		* event buffer
	move.w #$b,-(sp)		* e_wait
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _p_pause
_p_pause:
	move.l 4(sp),-(sp)		* timeout
	move.w #$c,-(sp)		* p_pause
	trap #5				* enter RTX
	addq.l #6,sp
	rts

	.globl _m_alloc
_m_alloc:
	move.l 4(sp),-(sp)		* size
	move.w #$d,-(sp)		* m_alloc
	trap #5				* enter RTX
	addq.l #6,sp
	rts

	.globl _m_free
_m_free:
	move.l 4(sp),-(sp)		* segment
	move.w #$e,-(sp)		* m_free
	trap #5				* enter RTX
	addq.l #6,sp
	rts

	.globl _m_assign
_m_assign:
	link a6,#0
	move.l 12(a6),-(sp)		* PID
	move.l  8(a6),-(sp)		* segment
	move.w #$f,-(sp)		* m_assign
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _p_lookup
_p_lookup:
	move.l 4(sp),-(sp)		* name
	move.w #$10,-(sp)		* p_lookup
	trap #5				* enter RTX
	addq.l #6,sp
	rts

	.globl _q_lookup
_q_lookup:
	move.l 4(sp),-(sp)		* Q name
	move.w #$11,-(sp)		* q_lookup
	trap #5				* enter RTX
	addq.l #6,sp
	rts

	.globl _p_info
_p_info:
	link a6,#0
	move.l 12(a6),-(sp)		* state buffer
	move.l 8(a6),-(sp)		* PID
	move.w #$12,-(sp)		* p_info
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _p_vector
_p_vector:
	link a6,#0
	move.l 12(a6),-(sp)		* vector
	move.l 8(a6),-(sp)		* PID
	move.w #$13,-(sp)		* p_vector
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _p_suspend
_p_suspend:
	link a6,#0
	move.l 8(a6),-(sp)		* PID
	move.w #$14,-(sp)		* p_suspend
	trap #5				* enter RTX
	unlk a6
	rts


	.globl _p_resume
_p_resume:
	link a6,#0
	move.l 8(a6),-(sp)		* PID
	move.w #$15,-(sp)		* p_resume
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _d_install
_d_install:
	link a6,#0
	move.l 30(a6),-(sp)		* cntrl
	move.l 26(a6),-(sp)		* costat
	move.l 22(a6),-(sp)		* conout
	move.l 18(a6),-(sp)		* conin
	move.l 14(a6),-(sp)		* constat
	move.l 10(a6),-(sp)		* name
	move 8(a6),-(sp)		* unit
	move #$16,-(sp)			* d_install
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _d_cntrl
_d_cntrl:
	link a6,#0
	move.l 10(a6),-(sp)		* long word parameter
	move.w 8(a6),-(sp)		* unit number
	move.w #$17,-(sp)		* d_cntrl
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _q_info
_q_info:
	link a6,#0
	move.l 16(a6),-(sp)		* num proc
	move.l 12(a6),-(sp)		* num msg
	move.l 8(a6),-(sp)		* qid
	move.w #$18,-(sp)		* q_info
	trap #5				* enter RTX
	unlk a6
	rts

	.globl _rtx_remove
_rtx_remove:
	move.w #255,-(sp)		* rtx_remove
	trap #5				* enter RTX
	addq.l #2,sp
	rts

*************************************************************************
*									*
*	BIOS, XBIOS, and GEMDOS re-entrant interface for RTX		*
*									*
*************************************************************************
	.globl _bios
.text
_bios:
	move #201,-(sp)
	trap #5			* save real return address
	addq.l #6,sp		* pop return off stack
	trap #13
	move.l d0,-(sp)		* save return value
	move #203,-(sp)
	trap #5			* save real return address
	addq.l #2,sp
	move.l d0,a0
	move.l (sp)+,d0		* set up return value
	jmp (a0)

	.globl _xbios
.text
_xbios:
	move #201,-(sp)
	trap #5			* save real return address
	addq.l #6,sp		* pop return off stack
	trap #14
	move.l d0,-(sp)		* save return value
	move #203,-(sp)
	trap #5			* save real return address
	addq.l #2,sp
	move.l d0,a0
	move.l (sp)+,d0		* set up return value
	jmp (a0)

	.globl _gemdos
.text
_gemdos:
	move #201,-(sp)
	trap #5			* save real return address
	addq.l #6,sp		* pop return off stack
	trap #1	
	move.l d0,-(sp)		* save return value
	move #203,-(sp)
	trap #5			* save real return address
	addq.l #2,sp
	move.l d0,a0
	move.l (sp)+,d0		* set up return value
	jmp (a0)

.data
