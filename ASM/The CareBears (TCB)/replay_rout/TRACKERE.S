******************************************************************
* Replay routine thar replays -TCB TRACKER- modules  in STE mode *
* Made by Anders Nilsson  10/8/90                                *
* Uses d6-d7/a2-a6                                               *
******************************************************************

x:
	jmp	main(pc)		*jump to main rout.
save_ints:				*save interrupts
	move.b	$fffffa07.w,mfpa07
	move.b	$fffffa09.w,mfpa09
	move.b	$fffffa13.w,mfpa13
	move.b	$fffffa15.w,mfpa15
	move.b	$fffffa19.w,mfpa19
	move.b	$fffffa1f.w,mfpa1f
	move.l	$134.w,old134
	move.l	$70.w,oldvbl
	rts
init_ints:				*init. interrupts
	clr.b	$fffffa09.w
	clr.b	$fffffa15.w
	move.w	module+$90,d0
	lea	mfp_freqs(pc),a0
	move.b	(a0,d0.w),$fffffa1f.w
	move.b	#2,$fffffa19.w
	move.b	#32,$fffffa07.w
	move.b	#32,$fffffa13.w
	bclr	#3,$fffffa17.w
	move.l	#replay_rot+$88ca,$134.w
	move.l	#vbi,$70.w
	rts
mfp_freqs:				*10 and 8.3 khz
	dc.b	24
	dc.b	29
ret_ints:				*restore interrupts
	move.b	mfpa07,$fffffa07.w
	move.b	mfpa09,$fffffa09.w
	move.b	mfpa13,$fffffa13.w
	move.b	mfpa15,$fffffa15.w
	move.b	mfpa19,$fffffa19.w
	move.b	mfpa1f,$fffffa1f.w
	move.l	old134,$134.w
	move.l	oldvbl,$70.w
	rts	
mfpa07:	dc.b	0			*the vars for saving interrupts
mfpa09:	dc.b	0
mfpa13:	dc.b	0
mfpa15:	dc.b	0
mfpa19:	dc.b	0
mfpa1f:	dc.b	0
old134:	dc.l	0
oldvbl:	dc.l	0

init_ste:
	move.w	#0,$ffff8900.w		*init. STE
	lea	setsam_dat(pc),a0
	move.w	#3,d0
mwwrite:
	move.w	#$7ff,$ffff8924.w
mwwrite2:
	cmp.w	#$07ff,$ffff8924.w
	bne.s	mwwrite2
	move.w	(a0)+,$ffff8922.w
	dbra	d0,mwwrite

	move.l	#$486,temp			
	move.b	temp+1(pc),$ffff8903.w
	move.b	temp+2(pc),$ffff8905.w
	move.b	temp+3(pc),$ffff8907.w

	move.l	#$488,temp
	move.b	temp+1(pc),$ffff890f.w
	move.b	temp+2(pc),$ffff8911.w
	move.b	temp+3(pc),$ffff8913.w

	move.w	#%0000000000000001,$ffff8920.w
	move.w	#3,$ffff8900.w
	rts
main:
	pea	0			*supervisor on
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,save_stk

	* you can use all registers here
	
	jsr	init_ste(pc)		*init. ste
	lea	module,a0		*a0=module start
	jsr	replay_rot+$20(pc)	*init. replay routine

	* don't use a2-a6/d6-d7 from here

	jsr	save_ints(pc)		*save interrupts
	jsr	init_ints(pc)		*init. interrupts
	clr.w	wfnc
demo_loop:
	cmp.w	#1,wfnc
	bne.s	demo_loop
	clr.w	wfnc

	* your own routines... remember d0-d5/a0-a1 !!!!

	cmp.b	#185,$fffffc02.w	*space
	bne.s	demo_loop		*yes/no
	jsr	ret_ints(pc)

	* you are now back to normal

	move.l	save_stk(pc),-(sp)	*usermode
	move.w	#$20,-(sp)
	trap	#1
	addq.l	#6,sp
	clr.w	(sp)			*exit
	trap	#1
vbi:
	movem.l	d0-d5/a0-a1,-(sp)	*save regs.
	jsr	replay_rot+$24		*jump to music rout
	move.w	#1,wfnc			*set the wait flag
	movem.l	(sp)+,d0-d5/a0-a1	*pop regs.
	rte
wfnc:
	dc.w	0			
save_stk:
	dc.l	0			
temp:
	dc.l	0
setsam_dat:
	dc.w	%0000000011010100  	*mastervol
	dc.w	%0000010010000110  	*treble
	dc.w	%0000010001000110  	*bass
	dc.w	%0000000000000001  	*mixer
replay_rot:				*the replay routine
	incbin	a:\replay\trackere.rot
	even
module:					*the module
	incbin 	a:\modules.mod\victor.mod
	even