******** Fading ************

* Call:	fade_me

****************************

TRUE_OFF	equ	640
FADE_LINES	equ	120
FADE_SPEED	equ	16

****************************

fade_me
		move.w	#-1,fade_type
		bsr	fade_init
fade_lop_1	jsr	vsync 
		bsr	fade_menu
		move.w	d0,-(sp)
		jsr	swap_me
		move.w	(sp)+,d0
		bpl.s	fade_lop_1

		move.w	#1,fade_type
		bsr	fade_init
fade_lop_2	
		jsr	vsync
		bsr	fade_menu
		move.w	d0,-(sp)
		jsr	swap_me
		move.w	(sp)+,d0
		bpl.s	fade_lop_2

                rts

********* SUBS ***************

fade_init
	
	lea	fade_control,a0
	move.w	#FADE_LINES-1,d7

fade_init_loop

	bsr	random

	moveq	#0,d1
	and.b	#%00011111,d0	* 0-63
	move.b	d0,d1
	move.w	d1,(a0)+
	move.w	#160,(a0)+

	dbra	d7,fade_init_loop
	rts

*****************************

fade_menu

	clr.w	count_fertig

	lea	fade_control,a0
	lea	fade_buffer_1+128,a1
	lea	fade_buffer_2+128,a2
	move.l	screen_1,a3

	tst.w	fade_type
	bmi.s	offset_ok
	lea	TRUE_OFF(a1),a1
	lea	TRUE_OFF(a2),a2
	lea	TRUE_OFF(a3),a3
offset_ok

	move.w	#FADE_LINES-1,d0

fade_loop		

******** For each line ************

	move.l	a3,-(sp)
	move.w	(a0)+,d1
	beq.s	in_action

***** Stopped *****

	subq.w	#1,-2(a0)
	addq.w	#2,a0
	bra	fade_done

***** Select Mode *****

in_action
	move.w	(a0),d1
	beq	wait_for
	cmp.w	#-1,d1
	beq	wait_for
	cmp.w	#-2,d1
	beq	finished

***************************
****** Mode: Normal *******

	tst.w	fade_type
	bmi.s	type_left

******* Typ: nach rechts **********

* first buffer

	move.w	#160,d2
	sub.w	d1,d2
	lea	0(a2,d1.w*4),a4		* buffer start address	
	
	swap	d0
	move.w	d2,d0
	bsr	copy_lines
	swap	d0
	
* second buffer 

	move.l	a1,a4
	move.w	(a0),d1
	
	swap	d0
	move.w	d1,d0
	bsr	copy_lines
	swap	d0
	
	subi.w	#FADE_SPEED,(a0)+	* movement

	bra.s	fade_done

******* Typ: nach links **********

type_left

* first buffer

	move.w	#160,d2	
	sub.w	d1,d2
	lea	0(a1,d2.w*4),a4	* buffer 1 start address

	swap	d0
	move.w	d1,d0
	bsr	copy_lines
	swap	d0
	
* second buffer

	move.l	a2,a4		* second buffer
	move.w	#160,d1
	sub.w	(a0),d1

	swap	d0
	move.w	d1,d0
	bsr	copy_lines
	swap	d0
	
	subi.w	#FADE_SPEED,(a0)+	* movement

	bra.s	fade_done

********************
* Copy Sub Routine *

copy_lines

* d0 = counter
* a4 = source
* a3 = destination

	move.w	d0,-(sp)
	lsr.w	#4,d0
	subq.w	#1,d0
	bmi.s	no_blocking

do_block
	movem.l	(a4)+,d1-d7/a6
	movem.l	d1-d7/a6,(a3)
	movem.l	(a4)+,d1-d7/a6
	movem.l	d1-d7/a6,32(a3)
	lea	64(a3),a3
	dbra	d0,do_block

no_blocking
	move.w	(sp)+,d0
	and.w	#$000f,d0
	subq.w	#1,d0
	bmi.s	no_single

do_single
	move.l	(a4)+,(a3)+
	dbra	d0,do_single
no_single		
	rts


****************************
******* Mode: Fertig *******

finished
	addq.w	#1,count_fertig
	addq.w	#2,a0
	bra.s	fade_done

****************************
****** Mode: Waiting *******

wait_for
	
* second buffer only

	move.l	a2,a4

	swap	d0
	move.w	#160,d0
	bsr	copy_lines
	swap	d0

	subq.w	#1,(a0)+
	

******* End of loop *********

fade_done
	lea	TRUE_OFF*2(a1),a1
	lea	TRUE_OFF*2(a2),a2
	move.l	(sp)+,a3
	lea	TRUE_OFF*2(a3),a3
	dbra	d0,fade_loop	

	cmp.w	#FADE_LINES,count_fertig
	beq.s	really_done
	moveq	#0,d0
	rts
really_done	
	moveq	#-1,d0
	rts

********* Daten **********

count_fertig	dc.w	0
fade_type	dc.w	0
fade_control	ds.l	FADE_LINES

************************************