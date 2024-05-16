************************************************************************
* Replay routine that replays -TCB TRACKER- modules  in normal ST mode *
* Made by Anders Nilsson  10/8/90                                      *
* Uses d6-d7/a2-a6 and usp                                             *
************************************************************************
x:
	jmp	main			*jump to main
save_ints:
	move.b	$fffffa07.w,mfpa07	*save interrupts
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$134,old134
	move.l	$70.w,oldvbl
	rts
init_ints:	
	clr.b	$fffffa09.w		*init interrupts
	clr.b	$fffffa15.w
	move.w	module+$90,d0
	lea	mfp_freqs,a0
	move.b	(a0,d0.w),$fffffa1f.w
	move.b	#2,$fffffa19.w
	move.b	#32,$fffffa07.w
	move.b	#32,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.l	#replay_rot+$8918,$134
	move.l	#vbi,$70.w
	rts
mfp_freqs:
	dc.b	24			*10 and 8.3 Khz
	dc.b	29
ret_ints:	
	move.b	mfpa07,$fffffa07.w	*restore interrupts
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	old134,$134
	move.l	oldvbl,$70.w
	rts
mfpa07:	dc.b	0			*vars for interrupt saving
mfpa09:	dc.b	0
mfpa13:	dc.b	0
mfpa15:	dc.b	0
mfpa19:	dc.b	0
mfpa1f:	dc.b	0
old134:	dc.l	0
oldvbl:	dc.l	0

main:
	pea	0			*supervisor
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk

	move.l	usp,a0			*save usp
	move.l	a0,save_usp

	* you can use all registers here

	lea	module,a0		*a0=module start
	moveq	#-1,d0			*-1=the default soundtable 0=the other
	jsr	replay_rot+$24		*init. replay routine
	
	* don't use d6-d7/a2-a6 from here

	jsr	save_ints		*save interrupts
	jsr	init_ints		*init. interrupts
	clr.w	wfnc
demo_loop:
	cmp.w	#1,wfnc			*wait for video
	bne	demo_loop
	clr.w	wfnc

	* your routines here..... remember d0-d5/a0-a1 !!!!!!

	cmp.b	#185,$fffc02		*space
	bne	demo_loop		*yes/no
	jsr	ret_ints		*restore interrupts

	* now you're back to normal

	move.l	save_usp,a0
	move.l	a0,usp

	move.l	save_stk,-(sp)		*user mode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	(sp)			*exit
	trap	#1
vbi:
	movem.l	d0-d5/a0-a1,-(sp)	*save registers
	jsr	replay_rot+$28		*call replay routine
	move.w	#1,wfnc			*set video flag
	movem.l	(sp)+,d0-d5/a0-a1	*pop registers
	rte
save_usp:
	dc.l	0
wfnc:
	dc.w	0
save_stk:
	dc.l	0
replay_rot:				*the replay routine
	incbin	a:\replay\tracker.rot
	even
module:					*the module
	incbin 	a:\modules.mod\victor.mod
	even