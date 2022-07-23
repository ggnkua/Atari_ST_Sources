			macro 	firstRunOrReturn
			tst.w	firstOrReturn\@1	
			beq.s	firstRun\@2
			rts
firstOrReturn\@1	dc.w	0
firstRun\@2
			move.w	#1,firstOrReturn\@1
			endm

dummyInt:	
			rte

dummyMain:
			rts

			macro scheduleMacro
			move.l	currentDef,a0
			move.l	(a0)+,d0
			
			cmp.l	currentFrame,d0
			
			bne.s	_noChangeDemoPart\@1
			
			move.l	(a0)+,currentMain
			move.l	a0,currentDef
_noChangeDemoPart\@1
			add.l	#1,currentFrame			
			endm

timer_d:
			movem.l	d0/a0,-(a7)
			scheduleMacro
			movem.l	(a7)+,d0/a0
			bclr	#4,$fffffa11.w				;clear busybit
			rte

vbl:
			; start frame - black
			move.l	borderColor,$ffff9800.w
	
			; vbl
			movem.l	d0-a6,-(sp)

			; set screen
			move.l	scr3,d0			
			move.b	d0,d1					
			lsr.w   #8,d0					
			move.b  d0,$ffff8203.w				
			swap    d0					
			move.b  d0,$ffff8201.w				
			move.b  d1,$ffff820d.w				

			ifeq	SCHED_TD
			scheduleMacro
			endif

			ifne MOD_MSX
			bsr dspmod34_vbl
			endif
			
			; mark vbl finished
			addq.w	#1,_vbl_counter
			movem.l	(sp)+,d0-a6
			rte			

switchScreens:	
			move.l	scr1,d0				
			move.l	scr2,scr1
			move.l	scr3,scr2
			move.l	d0,scr3
			rts
			
switchScreensDbl:	
			move.l	scr1,d0				
			move.l	scr3,scr1
			move.l	d0,scr3
			rts

restoreScr:
			move.l	scr1orig,scr1				
			move.l	scr2orig,scr2				
			move.l	scr3orig,scr3				
			rts

;waitVSync:
;			tst.w	_vbl_counter
;			beq.s	waitVSync
;			clr.w	_vbl_counter
;			rts

clearScreenBuffer:
			lea screenbuffer,a0
			add.l	#3*640*480+256,a0
			moveq	#0,d0
			moveq	#0,d1
			moveq	#0,d2
			moveq	#0,d3
			moveq	#0,d4
			moveq	#0,d5
			moveq	#0,d6

			move.l	d0,a1
			move.l	d0,a2
			move.l	d0,a3
			move.l	d0,a4
			move.l	d0,a5
			move.l	d0,a6

			move.l	#17728/32-1,d7
_clearScrBufLoop			
			rept 32
			movem.l	d0-d6/a1-a6,-(a0)
			endr
			dbf		d7,_clearScrBufLoop		
			rts

clearScreenBuffer3:
			move.l	scr3,a0
			add.l	#320*200*2,a0
			moveq	#0,d0
			moveq	#0,d1
			moveq	#0,d2
			moveq	#0,d3
			moveq	#0,d4
			moveq	#0,d5
			moveq	#0,d6

			move.l	d0,a1
			move.l	d0,a2
			move.l	d0,a3
			move.l	d0,a4
			move.l	d0,a5
			move.l	d0,a6

			move.l	#76-1,d7
_clearScrBufLoop3			
			rept 32
			movem.l	d0-d6/a1-a6,-(a0) ; 13r = 26px
			endr
			dbf		d7,_clearScrBufLoop3		
			rept 32
			movem.l	d0-d6/a1-a5,-(a0) ; 12r = 24px
			endr

			rts

clearScreenBuffer2:
			move.l	scr2,a0
			add.l	#320*200*2,a0
			moveq	#0,d0
			moveq	#0,d1
			moveq	#0,d2
			moveq	#0,d3
			moveq	#0,d4
			moveq	#0,d5
			moveq	#0,d6

			move.l	d0,a1
			move.l	d0,a2
			move.l	d0,a3
			move.l	d0,a4
			move.l	d0,a5
			move.l	d0,a6

			move.l	#76-1,d7
_clearScrBufLoop2			
			rept 32
			movem.l	d0-d6/a1-a6,-(a0) ; 13r = 26px
			endr
			dbf		d7,_clearScrBufLoop2		
			rept 32
			movem.l	d0-d6/a1-a5,-(a0) ; 12r = 24px
			endr
			rts
			
clearScreenBuffer1:
			move.l	scr1,a0
			add.l	#320*200*2,a0
			moveq	#0,d0
			moveq	#0,d1
			moveq	#0,d2
			moveq	#0,d3
			moveq	#0,d4
			moveq	#0,d5
			moveq	#0,d6

			move.l	d0,a1
			move.l	d0,a2
			move.l	d0,a3
			move.l	d0,a4
			move.l	d0,a5
			move.l	d0,a6

			move.l	#76-1,d7
_clearScrBufLoop1			
			rept 32
			movem.l	d0-d6/a1-a6,-(a0) ; 13r = 26px
			endr
			dbf		d7,_clearScrBufLoop1		
			rept 32
			movem.l	d0-d6/a1-a5,-(a0) ; 12r = 24px
			endr
			rts			
						
		; video
		include system/video.s

		; MSX
		ifne MOD_MSX
		include mod/mod.s
		endif

		ifne MP2_MSX
		include mp2/mp2.s
		endif
