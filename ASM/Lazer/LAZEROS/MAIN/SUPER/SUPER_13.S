FASTEXIT


	output	d:\lostblub\super\super.prg


	jmp	main


;-----------------------------------------------------------
	include startup.s
;-----------------------------------------------------------

TASK_PTR	= 0		;  1L 
TASK_PRIOR	= 4		;  1W
TASK_FLAGS	= 6		;  1W
TASK_PC		= 8		;  1L
TASK_SR		= 12		;  1W
TASK_REGS	= 14		; 16L


VBL_ANZ=8
TASK_ANZ=8

STACK_SIZE=4000



;-----------------------------------------------------------
ADD_TASK MACRO
	lea	\1,a0
	move.w	\2,d0
	bsr	add_task
	ENDM
;-----------------------------------------------------------
DELETE_TASK MACRO
	lea	\1,a0
	bsr	delete_task
	ENDM
;-----------------------------------------------------------
ADD_VBL MACRO
	lea	\1,a0
	move.w	\2,d0
	bsr	add_vbl
	ENDM
;-----------------------------------------------------------
DELETE_VBL MACRO
	lea	\1,a0
	bsr	delete_vbl
	ENDM
;-----------------------------------------------------------
save_sr MACRO
	move.w	sr,-(sp)
	ENDM
;-----------------------------------------------------------
restore_sr MACRO
	move.w	(sp)+,sr
	ENDM
;-----------------------------------------------------------


;-----------------------------------------------------------
main
	shrink_memory

	bsr	init
	save_stack
	bsr	phoenix_init

	save_interrupts
	set_interrupts




	bsr	init_vbl_queue
	bsr	init_task_queue

	bsr	init_multitask_interrupt

	ADD_VBL test1,#0
	ADD_VBL test2,#0

	move.w	#$2700,sr
	ADD_TASK main_task,#5

	clr.w	-(sp)
	move.l	#main_task,-(sp)
	move.w	#$2300,-(sp)
	rte





*	bsr	test3
*	bsr	test4

.main_loop
*	swapscreens
*	move.l	scr2,d0
*	setscreen
	vsync
	

	cmp.b	#$39,key
	bne	.main_loop

main_exit
	move.w	#$2700,sr
	restore_interrupts
	move.w	#$2300,sr
	bsr	phoenix_exit
	restore_stack
	bsr	exit
	terminate
;-----------------------------------------------------------
main_task
	ADD_TASK test3,#40
	ADD_TASK test4,#40
	ADD_TASK test5,#25
	ADD_TASK test6,#100

	move.w	#19,d1
.2	move.w	#9999,d0
.1	add.l	#$4,$ffff9800.w
	dbf	d0,.1
	dbf	d1,.2

	DELETE_TASK test6
dudu	
	bra.s	dudu
	rts
;-----------------------------------------------------------
test1
	add.w	#1,dada
	and.w	#31,dada

	move.w	dada,d0
	move.l	scr1,a0
	add.l	#384*10,a0

	move.w	#383,d1
.x	move.w	d0,2*384*2(a0)
	move.w	d0,384*2(a0)
	move.w	d0,(a0)+
	addq	#1,d0
	and.w	#31,d0
	dbf	d1,.x
	rts

dada	dc.w	0
;-----------------------------------------------------------
test2
	sub.w	#1,dada2
	and.w	#31,dada2

	move.w	dada2,d0
	move.l	scr1,a0
	add.l	#384*230*2,a0

	move.w	#383,d1
.x	move.w	d0,2*384*2(a0)
	move.w	d0,384*2(a0)
	move.w	d0,(a0)+
	addq	#1,d0
	and.w	#31,d0
	dbf	d1,.x
	rts

dada2	dc.w	0
;-----------------------------------------------------------
test3
	moveq	#0,d0
	moveq	#0,d1
	move.l	scr1,a0
	add.l	#195*2+20*384*2,a0

.loop
	cmp.l	#200000,gugu
	bgt.s	.end
	add.l	#1,gugu

	lea	(a0,d0.w*2),a1
	move.w	d1,d2
	muls	#384*2,d2
	add.l	d2,a1

	move.w	d0,d2
	add.w	d1,d2
	add.w	d2,(a1)

	add.w	#1,d0
	cmp.w	#189,d0
	blt.s	.1
	clr.w	d0
	add.w	#1,d1
	cmp.w	#99,d1
	blt.s	.1
	clr.w	d1
.1

	bra	.loop
.end
	rts
gugu	dc.l	0
;-----------------------------------------------------------
test4
	moveq	#0,d0
	moveq	#0,d1
	move.l	scr1,a0
	add.l	#20*384*2,a0

.loop
	lea	(a0,d0.w*2),a1
	move.w	d1,d2
	muls	#384*2,d2
	add.l	d2,a1

	move.w	d0,d2
	move.w	d1,d3
	and.w	#31,d2
	and.w	#31,d3
	muls.w	d3,d2
	lsr.w	#3,d2
	and.w	#31,d2
	add.w	#1,d2
	add.w	d2,(a1)

	add.w	#1,d0
	cmp.w	#189,d0
	blt.s	.1
	clr.w	d0
	add.w	#1,d1
	cmp.w	#99,d1
	blt.s	.1
	clr.w	d1
.1

	bra	.loop
	rts
;-----------------------------------------------------------
test5
	moveq	#0,d0
	moveq	#0,d1
	move.l	scr1,a0
	add.l	#120*384*2,a0

.loop
	lea	(a0,d0.w*2),a1
	move.w	d1,d2
	muls	#384*2,d2
	add.l	d2,a1

	add.w	#1,(a1)

	add.w	#1,d0
	cmp.w	#189,d0
	blt.s	.1
	clr.w	d0
	add.w	#1,d1
	cmp.w	#99,d1
	blt.s	.1
	clr.w	d1
.1

	bra	.loop
	rts
;-----------------------------------------------------------
test6
	moveq	#0,d0
	moveq	#0,d1
	move.l	scr1,a0
	add.l	#120*384*2+195*2,a0

.loop
	lea	(a0,d0.w*2),a1
	move.w	d1,d2
	muls	#384*2,d2
	add.l	d2,a1

	add.w	#1,(a1)

	add.w	#1,d0
	cmp.w	#189,d0
	blt.s	.1
	clr.w	d0
	add.w	#1,d1
	cmp.w	#99,d1
	blt.s	.1
	clr.w	d1
.1

	bra	.loop
	rts
;-----------------------------------------------------------


;-----------------------------------------------------------
; ********************** TIME-SHARING **********************
;-----------------------------------------------------------
; -> a0 : pointer to rout
;    d0 : priority
add_task
	save_sr
	move.w	#$2700,sr
	lea	task_queue,a6

	moveq	#0,d6
	move.w	#TASK_ANZ-1,d7
.1	move.l	TASK_PTR(a6),d1
	beq.s	.found
	lea	128(a6),a6
	addq	#1,d6
	dbf	d7,.1
	restore_sr
	rts

.found
	move.l	a0,TASK_PC(a6)
	move.w	#$2300,TASK_SR(a6)
	move.l	a0,TASK_PTR(a6)
	move.b	d0,TASK_PRIOR(a6)

	lea	test_stack,a1
	muls	#STACK_SIZE,d6
	add.l	d6,a1
	add.l	#STACK_SIZE,a1

	move.l	TASK_PTR(a6),-(a1)
	move.l	#task_finished,-(a1)
	clr.w	-(a1)			; 4 word stack frame
	move.l	TASK_PC(a6),-(a1)
	move.w	TASK_SR(a6),-(a1)
	move.l	a1,TASK_REGS+15*4(a6)

	restore_sr
	rts
;-----------------------------------------------------------
task_finished
	move.l	(sp)+,a0
	bsr	delete_task
fuck
	not.l	$ffff9800.w
	bra.s	fuck
	rts
;-----------------------------------------------------------
; -> a0 : pointer to rout
delete_task
	save_sr
	move.w	#$2700,sr
	lea	task_queue,a6

	move.w	#TASK_ANZ-1,d7
.1	move.l	TASK_PTR(a6),a1
	cmp.l	a1,a0
	beq.s	.found
	lea	128(a6),a6
	dbf	d7,.1
	restore_sr
	rts

.found
	clr.l	TASK_PTR(a6)
	clr.w	TASK_PRIOR(a6)
	restore_sr
	rts
;-----------------------------------------------------------
init_task_queue
	lea	task_queue,a0

	lea	test_stack,a1
	add.l	#STACK_SIZE,a1
	
	move.w	#TASK_ANZ-1,d0
.1	clr.l	TASK_PTR(a0)		; pointer
	clr.w	TASK_PRIOR(a0)		; priority
	clr.w	TASK_FLAGS(a0)		; flags
	move.l	a1,TASK_REGS+15*4(a0)
	lea	128(a0),a0
	add.l	#STACK_SIZE,a1
	dbf	d0,.1
	rts
;-----------------------------------------------------------
init_multitask_interrupt
	move.w	#$2700,sr

	move.l	#task_switch,$120.w

	bset	#0,$fffffa07.w			; IERB
	bset	#0,$fffffa13.w			; IMRB

	clr.b	$fffffa1b.w
	move.b	#50,$fffffa21.w		; Timer B Data
	move.b	#7,$fffffa1b.w			; Timer B Control

	move.w	#$2300,sr
	rts
;-----------------------------------------------------------
task_switch
	clr.b	$fffffa1b.w

*	not.l	$ffff9800.w
	movem.l	d0-a7,save_regs

	move.w	active_task,d0
	lea	task_queue,a0
	lsl.w	#7,d0
	lea	(a0,d0.w),a0

	movem.l	d0-a7,TASK_REGS(a0)
	move.l	save_regs,TASK_REGS(a0)
	move.l	save_regs+8*4,TASK_REGS+8*4(a0)

	move.l	2(sp),TASK_PC(a0)
	move.w	(sp),TASK_SR(a0)

.find_active
	move.w	active_task,d0
	lea	task_queue,a0
	moveq	#7,d1
.loop	
	addq	#1,d0
	and.w	#7,d0

	move.w	d0,d2
	lsl.w	#7,d2
	lea	(a0,d2.w),a1
	cmp.l	#0,TASK_PTR(a1)
	bne.s	.found
	dbf	d1,.loop
	bra.s	.not_found
.found
	move.w	d0,active_task

	move.l	TASK_REGS+15*4(a1),a7

	move.b	TASK_PRIOR(a1),$fffffa21.w	; Timer B Data

	move.l	TASK_PC(a1),2(sp)
	move.w	TASK_SR(a1),(sp)

	movem.l	TASK_REGS(a1),d0-a7

	bra.s	.ok
.not_found
	move.b	#50,$fffffa21.w			;######??????
	movem.l	save_regs,d0-a7

.ok

*	not.l	$ffff9800.w

	move.b	#7,$fffffa1b.w			; Timer B Control

	bclr	#0,$fffffa0f.w			; IPRB
	rte
;-----------------------------------------------------------
save_regs	ds.l	16
;-----------------------------------------------------------


;-----------------------------------------------------------
; ********************** VBL-HANDLING **********************
;-----------------------------------------------------------
; -> a0 : pointer to rout
;    d0 : priority
add_vbl
	lea	vbl_queue,a6

	move.w	#VBL_ANZ-1,d7
.1	move.l	(a6),d1
	beq.s	.found
	lea	8(a6),a6
	dbf	d7,.1
	rts

.found
	move.l	a0,(a6)
	move.l	d0,4(a6)
	rts
;-----------------------------------------------------------
; -> a0 : pointer to rout
;    d0 : priority
delete_vbl
	lea	vbl_queue,a6

	move.w	#VBL_ANZ-1,d7
.1	move.l	(a6),a1
	cmp.l	a1,a0
	beq.s	.found
	lea	8(a6),a6
	dbf	d7,.1
	rts

.found
	clr.l	(a6)
	clr.w	4(a6)
	rts
;-----------------------------------------------------------
handle_vbl_list
	bsr	clear_vbl_flags

	lea	vbl_queue,a0

	move.w	#VBL_ANZ-1,d0
.1	move.l	(a0),a6
	cmp.l	#0,a6
	beq.s	.no
	pusha
	jsr	(a6)
	popa
.no
	lea	8(a0),a0
	dbf	d0,.1
	
	rts
;-----------------------------------------------------------
clear_vbl_flags
	lea	vbl_queue,a0
	
	move.w	#VBL_ANZ-1,d0
.1	clr.w	6(a0)
	lea	8(a0),a0
	dbf	d0,.1
	rts
;-----------------------------------------------------------
init_vbl_queue
	lea	vbl_queue,a0
	
	move.w	#VBL_ANZ-1,d0
.1	clr.l	0(a0)		; pointer
	clr.w	4(a0)		; priority
	clr.w	6(a0)		; flags
	lea	8(a0),a0
	dbf	d0,.1
	rts
;-----------------------------------------------------------



;-----------------------------------------------------------
vbl
	move.w	#$2700,sr
	movem.l	d0-a7,vbl_regs
	bsr	handle_vbl_list
	movem.l	vbl_regs,d0-a7

	move.b	key,old_key
	move.b	$fffffc02.w,key

	cmp.b	#$1,key
	beq	main_exit
	move.w	#$2300,sr
	rte

old_vbl	jmp	$12345678

vbl_regs	ds.l	16
;-----------------------------------------------------------
init
	clr_bss

	super_on
	mouse_off

	cache_on

        move.l  $44e.w,old_screen
	save_resolution

	move.l	#screens+256,d0
	clr.b	d0
	move.l	d0,scr1
	add.l	#384*240*2,d0
	move.l	d0,scr2

	move.l	scr1,d0
	setscreen

	lea	rgb_384x240xtrue,a0
	set_resolution

	move.l	#0,$ffff9800.w
        rts
;-----------------------------------------------------------
exit
	
	move.l	old_screen,d0
	setscreen
	restore_resolution

	mouse_on
	super_off
	rts
;-----------------------------------------------------------



;-----------------------------------------------------------
scr1		dc.l	0
scr2		dc.l	0
;-----------------------------------------------------------


active_task	dc.w	0

;-----------------------------------------------------------

	even

	section bss

	ds.l	1000
mystack		ds.l	0

start_bss
screens		ds.b	2*384*240*2+256

test_stack	ds.b	9*STACK_SIZE
	even

vbl_queue	ds.b	8*VBL_ANZ
task_queue	ds.b	128*TASK_ANZ
end_bss
