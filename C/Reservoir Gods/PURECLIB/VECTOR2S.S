***********************************
*=================================*
* RESERVOIR GODS LIBRARY ROUTINES *
*=================================*
*        |              |         *
*        |VECTOR LIBRARY|         *
*        |              |         *
***********************************
* CODE: MR. PINK | (C): 22/02/96  *
***********************************
* UPDATE: 22/2/96  *
********************

;	SECTION CSECT

	xdef	rlvc_save_vectors
	xdef	rlvc_restore_vectors
	xdef	rlvc_install_vbl
	xdef	rlvc_wait_vbl
	xdef	rlvc_install_vbl_routine
	xdef	rlvc_remove_vbl_routine
	xdef	rlsc_set_screen_vbl
	xdef	rlsc_set_new_physic

**************************************************************************
;	SECTION TEXT
**************************************************************************

	TEXT

rlvc_save_vectors:
	movem.l	a0-a1/d0,-(a7)

	move.w	sr,-(a7)
	move	#$2700,sr

;	movec	CACR,d0
;	move.l	d0,(a0)+
;	movec	VBR,d0
;	move.l	d0,(a0)+
;	movec	MSP,d0
;	move.l	d0,(a0)+
;	movec	USP,d0
;	move.l	d0,(a0)+

	movea.w	#8,a1			;start of vectors
	move.w	#253,d0
.vex:
	move.l	(a1)+,(a0)+
	dbra	d0,.vex

	movea.w	#$fa00,a1		;mfp address
	moveq	#11,d0
.mfp:
	move.l	(a1)+,(a0)+
	dbra	d0,.mfp

	move.w	(a7)+,sr
	movem.l	(a7)+,a0-a1/d0
	rts

rlvc_restore_vectors:
	movem.l	a0-a1/d0,-(a7)

	move.w	sr,-(a7)
	move	#$2700,sr

;	move.l	(a0)+,d0
;	movec	d0,CACR
;	move.l	(a0)+,d0
;	movec	d0,VBR
;	move.l	(a0)+,d0
;	movec	d0,MSP
;	move.l	(a0)+,d0
;	movec	d0,USP

	movea.w	#8,a1
	move.w	#253,d0
.vex2:
	move.l	(a0)+,(a1)+
	dbra	d0,.vex2

	movea.w	#$fa00,a1
	moveq	#11,d0
.mfp2:
	move.l	(a0)+,(a1)+
	dbra	d0,.mfp2
	move.b	#$c0,$fffffa23.w

	move.w	(a7)+,sr
	movem.l	(a7)+,a0-a1/d0
	rts

rlvc_install_vbl:
	move.w	sr,-(a7)
	move.w	#$2700,sr
	move.l	#rlvc_my_vbl,$70.w
	move.w	(a7)+,sr
	rts	

rlvc_wait_vbl:
	move.l	d0,-(a7)
	move.l	$466.w,d0
.wait:
	cmp.l	$466.w,d0
	beq.s	.wait
	move.l	(a7)+,d0
	rts

rlvc_install_vbl_routine:
	movem.l	d0/a0-a1,-(a7)
;	move.l	16(a7),a0

	move.w	sr,-(a7)
	move.w	#$2700,sr
	lea	rlvc_vbl_routines,a1
	moveq	#63,d0				;max 64 routines
.find:
	tst.l	(a1)+
	beq.s	.hole_found
	dbra	d0,.find
	bra.s	.no_hole
.hole_found:
	move.l	a0,-(a1)
.no_hole:
	move.w	(a7)+,sr
	movem.l	(a7)+,d0/a0-a1
	rts

rlvc_remove_vbl_routine:
	movem.l	a1/d0-d1,-(a7)
	move.w	sr,-(a7)
	move.w	#$2700,sr

	lea	rlvc_vbl_routines,a1

	moveq	#63,d0
.find2:
	cmp.l	(a1)+,a0
	bne.s	.neq
	move.w	d0,d1
.shift:
	move.l	(a1)+,-8(a1)		;remove routine
	dbra	d1,.shift
.neq:
	dbra	d0,.find2

	move.w	(a7)+,sr
	movem.l	(a7)+,a1/d0-d1
	rts

rlvc_my_vbl:
	ori.w	#$0700,sr

	tst.w	rlsc_show_new_physic_flag
	beq		.no_new1

	move.l	a0,-(a7)
	move.l	a1,-(a7)
	lea		rlsc_new_physic+1,a0
	movea.w	#$8201,a1				;$fffff8201=screen address
	move.b	(a0)+,(a1)	
	move.b	(a0)+,2(a1)				;$fffff8203
	move.b	(a0),$C(a1)				;$fffff820d
	clr.w	rlsc_show_new_physic_flag
	move.l	(a7)+,a1
	move.l	(a7)+,a0

.no_new1:
	
	movem.l	d0-d7/a0-a6,-(a7)
	
	lea	rlvc_vbl_routines,a0
.next:
	move.l	(a0)+,a1
	cmpa.l	#0,a1
	beq.s	.last
	move.l	a0,-(a7)
	jsr	(a1)
	move.l	(a7)+,a0
	bra.s	.next
.last:
	addq.l	#1,$466.w
	movem.l	(a7)+,d0-d7/a0-a6
	rte

rlsc_set_screen_vbl:
	move.w	sr,-(a7)
	ori.w	#$0700,sr
	movem.l	a0-a1,-(a7)

	tst.w	rlsc_show_new_physic_flag
	beq		.no_new

	lea		rlsc_new_physic+1,a0
	movea.w	#$8201,a1				;$fffff8201=screen address
	move.b	(a0)+,(a1)	
	move.b	(a0)+,2(a1)				;$fffff8203
	move.b	(a0),$C(a1)				;$fffff820d
	clr.w	rlsc_show_new_physic_flag

.no_new:	
	movem.l	(a7)+,a0-a1
	move.w	(a7)+,sr
	rts

rlsc_set_new_physic:
;	move.l	4(a7),rlsc_new_physic
	move.l	d0,rlsc_new_physic
	move.w	#1,rlsc_show_new_physic_flag
	rts

rlsc_show_new_physic_flag:	ds.w	1
rlsc_new_physic:			ds.l	1

rlvc_vbl_routines:	ds.l	64

	END