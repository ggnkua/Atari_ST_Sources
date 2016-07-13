					include	"register.h"
					
					export	load_dsp_obj
					import	DSPLOAD, DSPSTUFF

load_dsp_obj:		movem.l	d0-a6,-(sp)
					pea		load_dsp_obj1
					move.w	#$26,-(sp)		
					trap	#14
					addq.l	#6,sp
					movem.l	(sp)+,d0-a6
					rts

load_dsp_obj1:		lea		ym_select,a0
					move    sr,d1
					move    #$2700,sr
					move.b	#14,(a0)
					move.b	(a0),d0
					and.b	#$ef,d0
					move.b	d0,2(a0)			;b5 = 0
					or.b	#$10,d0
					move.b	d0,2(a0)			;b5 = 1, DSP-Reset
					move.w	d1,sr
					move.l	$4ba.w,d0			;200 Hz Timer
					addq.l	#2,d0
wait_dsp_reset:		cmp.l	$4ba.w,d0
					blt.s	wait_dsp_reset
					move    sr,d1
					move    #$2700,sr
					move.b	#14,(a0)
					move.b	(a0),d0
					and.b	#$ef,d0
					move.b	d0,2(a0)			;b5 = 0
					move.w	d1,sr
					lea		DspHost.w,a0
					lea		DSPLOAD,a1
					move.w	#512,d0				;512 DSP-Words laden
					move.w	7(a1),d1			;Anzahl vorhandener DSP-Words
					subq.w	#1,d1				;wegen dbra
					lea		9(a1),a1
boot:				move.b	(a1)+,5(a0)
					move.b	(a1)+,6(a0)
					move.b	(a1)+,7(a0)
					subq.w	#1,d0
					dbra	d1,boot
					
					tst.w	d0
					beq.s	boot_end
null:				clr.b	5(a0)
					clr.b	6(a0)
					clr.b	7(a0)
					subq.w	#1,d0
					bne.s	null
			
boot_end:			lea		DSPSTUFF,a1
					move.l	(a1)+,d0			;Anzahl DSP-Bytes
					divu	#3,d0
					subq.w	#1,d0
load:				btst	#2,2(a0)
					beq.s	load
					move.b	(a1)+,5(a0)			;Memory-Typ
					move.b	(a1)+,6(a0)			;Adresse
					move.b	(a1)+,7(a0)
					dbra	d0,load
					move.b	#-1,5(a0)
					move.w	#-1,6(a0)			;DSP-Prog Start					
load_end:			rts
