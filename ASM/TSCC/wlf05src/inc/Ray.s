************************************
*
*  void SoundInit()
*
* Initialise sound system
*
************************************

		section	text
SoundInit	tst.w	computer		; YM2149 sound?
		beq.s	.ym

.dma		clr.b	$ffff8901.w		; Stop sound
		move.l	#FeedBufferDMA,$70.w
		rts

.ym		bsr.w	.temp ****
		move.w	#53,SFXBufferLen+2	; Shorten buffer length

		clr.b   $fffffa19.w
		move.l  #EmulateDMA,$134.w	; DMA sound emulator

		ori.b   #%100000,$fffffa07.w	; Mask in timer a
		ori.b   #%100000,$fffffa13.w

		move.b  #78,$fffffa1f.w		; Set timer a to approx. 3.125 khz

		move.l	#FeedBufferYM,$70.w

		lea.l	.vol(pc),a0		; Volume data
		lea.l 	$ffff8800.w,a1		; YM base register

.init		move.w  (a0)+,d0
		bmi.s   .break

		movep.w d0,(a1)
		bra.s   .init

.break		rts

.vol		dc.w $0000
		dc.w $0100
		dc.w $0200
		dc.w $0300
		dc.w $0400
		dc.w $0500
		dc.w $0600
		dc.b $07,%1111111
		dc.w $0d00
		dc.w -1


	**** temporary ****
.temp		lea.l	.samlist(pc),a0

.nextsample:	move.w	(a0)+,d0		  ; Length-1
		bmi.s   .done

		movea.l (a0)+,a1		  ; *Sample
		addq.l  #4,a1
		movea.l a1,a2
		movea.l a1,a3

.preprocess:	move.b	(a1)+,d1		  ; Subsample to 3.125khz
		move.b  (a1)+,d2
		move.b  (a1)+,d3
		move.b  (a1)+,d4

		eori.b  #$80,d1		   ; Unsign
		eori.b  #$80,d2
		eori.b  #$80,d3
		eori.b  #$80,d4

		add.b   d2,d1
		roxr.b  #1,d1
		add.b   d3,d1
		roxr.b  #1,d1
		add.b   d4,d1
		roxr.b  #1,d1

		move.b  d1,(a2)+
		dbra	  d0,.preprocess

		move.l  a2,-(a3)

		bra.s   .nextsample
.done		rts


.samlist	dc.w	(endsam1-sam1-8)/4-1
	        dc.l	sam1+4
	        dc.w	(endsam2-sam2-8)/4-1
	        dc.l	sam2+4
	        dc.w	(endsam3-sam3-8)/4-1
	        dc.l	sam3+4
	        dc.w	(endsam4-sam4-8)/4-1
	        dc.l	sam4+4
 		dc.w	(endsam5-sam5-8)/4-1
	        dc.l	sam5+4
		dc.w	(endsam6-sam6-8)/4-1
	        dc.l	sam6+4
		dc.w	(endsam7-sam7-8)/4-1
	        dc.l	sam7+4
		dc.w	(endsam8-sam8-8)/4-1
	        dc.l	sam8+4
		dc.w	(endsam9-sam9-8)/4-1
	        dc.l	sam9+4
		dc.w	-1



************************************
*
*  void SoundOff()
*
* Shut down all sound voices
*
************************************

SoundOff	movem.l	d0/a0,-(sp)

		lea.l	SFXVoices(pc),a0
		moveq.l #-1,d0
	rept 4
		move.l	d0,(a0)+
	endr

		movem.l	(sp)+,d0/a0
		rts



************************************
*
*  void PlaySound(a0.l *SoundResource)
*
* Play a sound resource
*
************************************

PlaySound	movem.l	d1/a1,-(sp)
		move.l	a0,d1		; Silence?
		beq.s	.break

		moveq.l #3<<2,d1		  ; Wrap channel number beyond 3
		and.w	.current(pc),d1
		addq.w	#4,.current

		lea.l	SFXVoices(pc),a1	  ; VoicePtr
		adda.l	d1,a1

		move.l	a1,(a0) 		  ; SamplePtr = VoicePtr
		addq.l	#8,a0
		move.l	a0,(a1) 		  ; VoicePtr = &Sample.data

		move.l	-(a0),16(a1)		  ; VoicePtr[16] = Sample.limit
		
.break		movem.l	(sp)+,d1/a1
		rts

.current	dc.w 0



************************************
*
*  void StopSound(a0.l *SoundResource)
*
* Stop a sound resource playing
*
************************************

StopSound	movem.l	d0/a1-a2,-(sp)

		move.l	a0,d0		; Silence?
		beq.s	.break

		move.l	(a0)+,d0
		beq.s	.break

		movea.l d0,a1			  ; *Voice
		movea.l (a1),a2 		  ; Current voice position
		move.l	(a0)+,d2		  ; Samplelimit

		suba.l	a0,a2			  ; Relocate
		sub.l	a0,d2
		cmp.l	a2,d2			  ; Do the ranges match?
		bcs.s	.break

		moveq.l #-1,d0			  ; Stop voice playing
		move.l	d0,(a1)

.break		movem.l	(sp)+,d0/a1-a2
		rts



***********************************
*
*  void interrupt FeedBufferDMA()
*
* Mix soundvoices currently playing, DMA sound version
*
***********************************

SFXBufferLen	dc.l	208

SFXVoices	dcb.l	4,-1
		ds.l	4

SFXBuffer1	ds.l	1
SFXBuffer2	ds.l	1

FeedBufferDMA	movem.l d0-a6,-(sp)

		movem.l SFXVoices(pc),d0-d3	  ; Fetch sample pointers

		lea.l	SFXBuffer1(pc),a0
		movem.l (a0),a4-a5		  ; Swap buffers
		move.l	a5,(a0)+
		move.l	a4,(a0)

		move.l	SFXBufferLen(pc),d6	  ; Length of double buffer

.feedloop	tst.w	d6
		ble.s	.break

		movem.l SFXVoices+4*4(pc),a0-a3   ; Sample limits

		moveq.l #0,d4
		cmp.l	a0,d0			  ; Determine which voices are
		bhs.s	._1			  ; playing currently
		addq.b	#8,d4
._1		cmp.l	a1,d1
		bhs.s	._2
		addq.b	#4,d4
._2		cmp.l	a2,d2
		bhs.s	._3
		addq.b	#2,d4
._3		cmp.l	a3,d3
		bhs.s	._4
		addq.b	#1,d4
._4
		add.b	d4,d4		  ; *= 4
		add.b	d4,d4
		movea.l .fetch(pc,d4.l),a6
		jmp	(a6)

.break		move.b	#%10000001,$ffff8921.w	  ; 12Khz, mono

		move.l	SFXBuffer2(pc),d4
		move.l	a4,d5

		move.b	d4,$ffff8907.w
		lsr.w	#8,d4
		move.l	d4,$ffff8902.w

		move.b	d5,$ffff8913.w
		lsr.w	#8,d5
		move.l	d5,$ffff890e.w

		move.b	#%1,$ffff8901.w	  ; DMA sound enable


.ret		movem.l d0-d3,SFXVoices
		movem.l (sp)+,d0-a6

		bra.w	FadeVBL


.fetch		dc.l	._play0
		dc.l	._play1
		dc.l	._play2
		dc.l	._play3
		dc.l	._play4
		dc.l	._play5
		dc.l	._play6
		dc.l	._play7
		dc.l	._play8
		dc.l	._play9
		dc.l	._playa
		dc.l	._playb
		dc.l	._playc
		dc.l	._playd
		dc.l	._playe
		dc.l	._playf


._play0		moveq.l #-1,d0		  ; %0000
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3

		clr.b	$ffff8901.w
		bra.s	.ret

._play1		move.w	d6,d5		  ; %0001

		move.l	a3,d7		  ; Clip
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play1
		add.w	d7,d5		  ; New length

.play1	 	sub.w	d5,d6

		movea.l d3,a0
		bsr.w	  ._1voice

		moveq.l #-1,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	a0,d3
		bra.w	  .feedloop


._play2		move.w	d6,d5		  ; %0010

		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.play2
		add.w	d7,d5

.play2		sub.w	d5,d6

		movea.l d2,a0
		bsr.w	  ._1voice

		moveq.l #-1,d0
		move.l	d0,d1
		move.l	a0,d2
		move.l	d0,d3
		bra.w	  .feedloop


._play3		move.w	d6,d5		  ; %0011
		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.play3a
		movea.w d7,a5
		add.w	a5,d5

.play3a		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play3b

		cmp.w	a5,d7
		blt.s	.play3b
		move.w	d6,d5
		add.w	d7,d5

.play3b		sub.w	d5,d6

		movea.l d2,a0
		movea.l d3,a1
		bsr.w	  ._2voice

		moveq.l #-1,d0
		move.l	d0,d1
		move.l	a0,d2
		move.l	a1,d3
		bra.w	  .feedloop


._play4		move.w	d6,d5		  ; %0100

		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.play4
		add.w	d7,d5

.play4	 	sub.w	d5,d6

		movea.l d1,a0
		bsr.w	  ._1voice

		moveq.l #-1,d0
		move.l	a0,d1
		move.l	d0,d2
		move.l	d0,d3
		bra.w	  .feedloop


._play5		move.w	d6,d5		  ; %0101

		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.play5a
		movea.w d7,a5
		add.w	a5,d5

.play5a		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play5b

		cmp.w	a5,d7
		blt.s	.play5b
		move.w	d6,d5
		add.w	d7,d5

.play5b		sub.w	d5,d6

		movea.l d1,a0
		movea.l d3,a1
		bsr.w	  ._2voice

		moveq.l #-1,d0
		move.l	a0,d1
		move.l	d0,d2
		move.l	a1,d3
		bra.w	  .feedloop


._play6		move.w	d6,d5		  ; %0110

		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.play6a
		movea.w d7,a5
		add.w	a5,d5

.play6a		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.play6b

		cmp.w	a5,d7
		blt.s	.play6b
		move.w	d6,d5
		add.w	d7,d5

.play6b		sub.w	d5,d6

		movea.l d1,a0
		movea.l d2,a1
		bsr.w	  ._2voice

		moveq.l #-1,d0
		move.l	a0,d1
		move.l	a1,d2
		move.l	d0,d3
		bra.w	  .feedloop


._play7		move.w	d6,d5		  ; %0111

		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.play7a
		movea.w d7,a5
		add.w	a5,d5

.play7a		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.play7b

		cmp.w	a5,d7
		blt.s	.play7b
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.play7b		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play7c

		cmp.w	a5,d7
		blt.s	.play7c
		move.w	d6,d5
		add.w	d7,d5

.play7c		sub.w	d5,d6

		movea.l d1,a0
		movea.l d2,a1
		movea.l d3,a2
		bsr.w	  ._3voice

		moveq.l #-1,d0
		move.l	a0,d1
		move.l	a1,d2
		move.l	a2,d3
		bra.w	  .feedloop


._play8		move.w	d6,d5		  ; %1000

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.play8
		add.w	d7,d5

.play8		sub.w	d5,d6

		movea.l d0,a0
		bsr.w	  ._1voice

		move.l	a0,d0
		moveq.l #-1,d1
		move.l	d1,d2
		move.l	d1,d3
		bra.w	  .feedloop


._play9		move.w	d6,d5		  ; %1001

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.play9a
		movea.w d7,a5
		add.w	a5,d5

.play9a		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play9b

		cmp.w	a5,d7
		blt.s	.play9b
		move.w	d6,d5
		add.w	d7,d5

.play9b		sub.w	d5,d6

		movea.l d0,a0
		movea.l d3,a1
		bsr.w	  ._2voice

		move.l	a0,d0
		moveq.l #-1,d1
		move.l	d1,d2
		move.l	a1,d3
		bra.w	  .feedloop


._playa		move.w	d6,d5		  ; %1010

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playaa
		movea.w d7,a5
		add.w	a5,d5

.playaa		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.playab

		cmp.w	a5,d7
		blt.s	.playab
		move.w	d6,d5
		add.w	d7,d5

.playab		sub.w	d5,d6

		movea.l d0,a0
		movea.l d2,a1
		bsr.w	  ._2voice

		move.l	a0,d0
		moveq.l #-1,d1
		move.l	a1,d2
		move.l	d1,d3
		bra.w	  .feedloop


._playb		move.w	d6,d5		  ; %1011

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playba
		movea.w d7,a5
		add.w	a5,d5

.playba		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.playbb

		cmp.w	a5,d7
		blt.s	.playbb
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playbb		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.playbc

		cmp.w	a5,d7
		blt.s	.playbc
		move.w	d6,d5
		add.w	d7,d5

.playbc		sub.w	d5,d6

		movea.l d0,a0
		movea.l d2,a1
		movea.l d3,a2
		bsr.w	  ._3voice

		move.l	a0,d0
		moveq.l #-1,d1
		move.l	a1,d2
		move.l	a2,d3
		bra.w	  .feedloop


._playc		move.w	d6,d5		  ; %1100

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playca
		movea.w d7,a5
		add.w	a5,d5

.playca		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.playcb

		cmp.w	a5,d7
		blt.s	.playcb
		move.w	d6,d5
		add.w	d7,d5

.playcb		sub.w	d5,d6

		movea.l d0,a0
		movea.l d1,a1
		bsr.w	  ._2voice

		move.l	a0,d0
		move.l	a1,d1
		moveq.l #-1,d2
		move.l	d2,d3
		bra.w	  .feedloop


._playd		move.w	d6,d5		  ; %1101

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playda
		movea.w d7,a5
		add.w	a5,d5

.playda		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.playdb

		cmp.w	a5,d7
		blt.s	.playdb
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playdb		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.playdc

		cmp.w	a5,d7
		blt.s	.playdc
		move.w	d6,d5
		add.w	d7,d5

.playdc		sub.w	d5,d6

		movea.l d0,a0
		movea.l d1,a1
		movea.l d3,a2
		bsr.w	  ._3voice

		move.l	a0,d0
		move.l	a1,d1
		moveq.l #-1,d2
		move.l	a2,d3
		bra.w	  .feedloop


._playe		move.w	d6,d5		  ; %1110

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playea
		movea.w d7,a5
		add.w	a5,d5

.playea		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.playeb

		cmp.w	a5,d7
		blt.s	.playeb
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playeb		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.playec

		cmp.w	a5,d7
		blt.s	.playec
		move.w	d6,d5
		add.w	d7,d5

.playec		sub.w	d5,d6

		movea.l d0,a0
		movea.l d1,a1
		movea.l d2,a2
		bsr.w	  ._3voice

		move.l	a0,d0
		move.l	a1,d1
		move.l	a2,d2
		moveq.l #-1,d3
		bra.w	  .feedloop



._playf		move.w	d6,d5		  ; %1111

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playfa
		movea.w d7,a5
		add.w	a5,d5

.playfa		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.playfb

		cmp.w	a5,d7
		blt.s	.playfb
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playfb		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.playfc

		cmp.w	a5,d7
		blt.s	.playfc
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playfc		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.playfd

		cmp.w	a5,d7
		blt.s	.playfd
		move.w	d6,d5
		add.w	d7,d5

.playfd		sub.w	d5,d6

		movea.l d0,a0
		movea.l d1,a1
		movea.l d2,a2
		movea.l d3,a3
		bra.s	._4voice

._4loop		move.b	(a0)+,d4	  ; 4 voices playing
		add.b	(a1)+,d4
		add.b	(a2)+,d4
		add.b	(a3)+,d4
		move.b	d4,(a4)+
._4voice	dbra.w	  d5,._4loop

		move.l	a0,d0
		move.l	a1,d1
		move.l	a2,d2
		move.l	a3,d3
		bra.w	  .feedloop



._1loop		move.b	(a0)+,(a4)+	  ; 1 voice playing
._1voice	dbra.w	  d5,._1loop
		rts

._2loop		move.b	(a0)+,d4	  ; 2 voices playing
		add.b	(a1)+,d4
		move.b	d4,(a4)+
._2voice	dbra.w	  d5,._2loop
		rts

._3loop:	move.b	(a0)+,d4	  ; 3 voices playing
		add.b	(a1)+,d4
		add.b	(a2)+,d4
		move.b	d4,(a4)+
._3voice	dbra.w	  d5,._3loop
		rts




***********************************
*
*  void interrupt FeedBufferYM()
*
* Mix soundvoices currently playing, YM2149 version
*
***********************************

FeedBufferYM	movem.l d0-a6,-(sp)
		movem.l SFXVoices(pc),d0-d3	; Fetch sample pointers

		lea.l   SFXBuffer1(pc),a0
		movem.l (a0),a4-a5		; Swap buffers
		move.l  a5,(a0)+
		move.l  a4,(a0)

		move.l  SFXBufferLen(pc),d6	; Length of double buffer

.feedloop	tst.w	d6
		ble.s   .break

		movem.l SFXVoices+4*4(pc),a0-a3	; Sample limits

		moveq   #0,d4
		cmp.l   a0,d0			; Determine which voices are
		bhs.s   ._1			; playing currently
		addq.b  #8,d4
._1		cmp.l	 a1,d1
		bhs.s   ._2
		addq.b  #4,d4
._2		cmp.l	 a2,d2
		bhs.s   ._3
		addq.b  #2,d4
._3		cmp.l	 a3,d3
		bhs.s   ._4
		addq.b  #1,d4
._4
		add.b   d4,d4		; *= 4
		add.b   d4,d4
		movea.l .fetch(pc,d4.l),a6
		jmp	  (a6)

.break		movea.l SFXBuffer2(pc),a0
		move	a0,usp

		move.b	#2,$fffffa19.w

.ret		movem.l d0-d3,SFXVoices

		movem.l (sp)+,d0-a6
		bra.w	FadeVBL


.fetch		dc.l	._play0
		dc.l	._play1
		dc.l	._play2
		dc.l	._play3
		dc.l	._play4
		dc.l	._play5
		dc.l	._play6
		dc.l	._play7
		dc.l	._play8
		dc.l	._play9
		dc.l	._playa
		dc.l	._playb
		dc.l	._playc
		dc.l	._playd
		dc.l	._playe
		dc.l	._playf


._play0		moveq.l #-1,d0		  ; %0000
		move.l	d0,d1
		move.l	d0,d2
		move.l	d0,d3

		clr.b	$fffffa19.w

		bra.s	.ret

._play1		move.w	d6,d5		  ; %0001

		move.l	a3,d7		  ; Clip
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play1
		add.w	d7,d5		  ; New length

.play1	 	sub.w	d5,d6

		movea.l d3,a0
		bsr.w	  ._1voice

		moveq.l #-1,d0
		move.l	d0,d1
		move.l	d0,d2
		move.l	a0,d3
		bra.w	  .feedloop


._play2		move.w	d6,d5		  ; %0010

		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.play2
		add.w	d7,d5

.play2		sub.w	d5,d6

		movea.l d2,a0
		bsr.w	  ._1voice

		moveq.l #-1,d0
		move.l	d0,d1
		move.l	a0,d2
		move.l	d0,d3
		bra.w	  .feedloop


._play3		move.w	d6,d5		  ; %0011
		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.play3a
		movea.w d7,a5
		add.w	a5,d5

.play3a		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play3b

		cmp.w	a5,d7
		blt.s	.play3b
		move.w	d6,d5
		add.w	d7,d5

.play3b		sub.w	d5,d6

		movea.l d2,a0
		movea.l d3,a1
		bsr.w	  ._2voice

		moveq.l #-1,d0
		move.l	d0,d1
		move.l	a0,d2
		move.l	a1,d3
		bra.w	  .feedloop


._play4		move.w	d6,d5		  ; %0100

		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.play4
		add.w	d7,d5

.play4	 	sub.w	d5,d6

		movea.l d1,a0
		bsr.w	  ._1voice

		moveq.l #-1,d0
		move.l	a0,d1
		move.l	d0,d2
		move.l	d0,d3
		bra.w	  .feedloop


._play5		move.w	d6,d5		  ; %0101

		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.play5a
		movea.w d7,a5
		add.w	a5,d5

.play5a		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play5b

		cmp.w	a5,d7
		blt.s	.play5b
		move.w	d6,d5
		add.w	d7,d5

.play5b		sub.w	d5,d6

		movea.l d1,a0
		movea.l d3,a1
		bsr.w	  ._2voice

		moveq.l #-1,d0
		move.l	a0,d1
		move.l	d0,d2
		move.l	a1,d3
		bra.w	  .feedloop


._play6		move.w	d6,d5		  ; %0110

		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.play6a
		movea.w d7,a5
		add.w	a5,d5

.play6a		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.play6b

		cmp.w	a5,d7
		blt.s	.play6b
		move.w	d6,d5
		add.w	d7,d5

.play6b		sub.w	d5,d6

		movea.l d1,a0
		movea.l d2,a1
		bsr.w	  ._2voice

		moveq.l #-1,d0
		move.l	a0,d1
		move.l	a1,d2
		move.l	d0,d3
		bra.w	  .feedloop


._play7		move.w	d6,d5		  ; %0111

		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.play7a
		movea.w d7,a5
		add.w	a5,d5

.play7a		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.play7b

		cmp.w	a5,d7
		blt.s	.play7b
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.play7b		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play7c

		cmp.w	a5,d7
		blt.s	.play7c
		move.w	d6,d5
		add.w	d7,d5

.play7c		sub.w	d5,d6

		movea.l d1,a0
		movea.l d2,a1
		movea.l d3,a2
		bsr.w	  ._3voice

		moveq.l #-1,d0
		move.l	a0,d1
		move.l	a1,d2
		move.l	a2,d3
		bra.w	  .feedloop


._play8		move.w	d6,d5		  ; %1000

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.play8
		add.w	d7,d5

.play8		sub.w	d5,d6

		movea.l d0,a0
		bsr.w	  ._1voice

		move.l	a0,d0
		moveq.l #-1,d1
		move.l	d1,d2
		move.l	d1,d3
		bra.w	  .feedloop


._play9		move.w	d6,d5		  ; %1001

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.play9a
		movea.w d7,a5
		add.w	a5,d5

.play9a		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.play9b

		cmp.w	a5,d7
		blt.s	.play9b
		move.w	d6,d5
		add.w	d7,d5

.play9b		sub.w	d5,d6

		movea.l d0,a0
		movea.l d3,a1
		bsr.w	  ._2voice

		move.l	a0,d0
		moveq.l #-1,d1
		move.l	d1,d2
		move.l	a1,d3
		bra.w	  .feedloop


._playa		move.w	d6,d5		  ; %1010

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playaa
		movea.w d7,a5
		add.w	a5,d5

.playaa		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.playab

		cmp.w	a5,d7
		blt.s	.playab
		move.w	d6,d5
		add.w	d7,d5

.playab		sub.w	d5,d6

		movea.l d0,a0
		movea.l d2,a1
		bsr.w	  ._2voice

		move.l	a0,d0
		moveq.l #-1,d1
		move.l	a1,d2
		move.l	d1,d3
		bra.w	  .feedloop


._playb		move.w	d6,d5		  ; %1011

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playba
		movea.w d7,a5
		add.w	a5,d5

.playba		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.playbb

		cmp.w	a5,d7
		blt.s	.playbb
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playbb		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.playbc

		cmp.w	a5,d7
		blt.s	.playbc
		move.w	d6,d5
		add.w	d7,d5

.playbc		sub.w	d5,d6

		movea.l d0,a0
		movea.l d2,a1
		movea.l d3,a2
		bsr.w	  ._3voice

		move.l	a0,d0
		moveq.l #-1,d1
		move.l	a1,d2
		move.l	a2,d3
		bra.w	  .feedloop


._playc		move.w	d6,d5		  ; %1100

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playca
		movea.w d7,a5
		add.w	a5,d5

.playca		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.playcb

		cmp.w	a5,d7
		blt.s	.playcb
		move.w	d6,d5
		add.w	d7,d5

.playcb		sub.w	d5,d6

		movea.l d0,a0
		movea.l d1,a1
		bsr.w	  ._2voice

		move.l	a0,d0
		move.l	a1,d1
		moveq.l #-1,d2
		move.l	d2,d3
		bra.w	  .feedloop


._playd		move.w	d6,d5		  ; %1101

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playda
		movea.w d7,a5
		add.w	a5,d5

.playda		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.playdb

		cmp.w	a5,d7
		blt.s	.playdb
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playdb		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.playdc

		cmp.w	a5,d7
		blt.s	.playdc
		move.w	d6,d5
		add.w	d7,d5

.playdc		sub.w	d5,d6

		movea.l d0,a0
		movea.l d1,a1
		movea.l d3,a2
		bsr.w	  ._3voice

		move.l	a0,d0
		move.l	a1,d1
		moveq.l #-1,d2
		move.l	a2,d3
		bra.w	  .feedloop


._playe		move.w	d6,d5		  ; %1110

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playea
		movea.w d7,a5
		add.w	a5,d5

.playea		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.playeb

		cmp.w	a5,d7
		blt.s	.playeb
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playeb		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.playec

		cmp.w	a5,d7
		blt.s	.playec
		move.w	d6,d5
		add.w	d7,d5

.playec		sub.w	d5,d6

		movea.l d0,a0
		movea.l d1,a1
		movea.l d2,a2
		bsr.w	  ._3voice

		move.l	a0,d0
		move.l	a1,d1
		move.l	a2,d2
		moveq.l #-1,d3
		bra.w	  .feedloop



._playf		move.w	d6,d5		  ; %1111

		move.l	a0,d7
		sub.l	d0,d7
		sub.l	d6,d7
		bpl.s	.playfa
		movea.w d7,a5
		add.w	a5,d5

.playfa		move.l	a1,d7
		sub.l	d1,d7
		sub.l	d6,d7
		bpl.s	.playfb

		cmp.w	a5,d7
		blt.s	.playfb
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playfb		move.l	a2,d7
		sub.l	d2,d7
		sub.l	d6,d7
		bpl.s	.playfc

		cmp.w	a5,d7
		blt.s	.playfc
		move.w	d6,d5
		add.w	d7,d5
		movea.w d7,a5

.playfc		move.l	a3,d7
		sub.l	d3,d7
		sub.l	d6,d7
		bpl.s	.playfd

		cmp.w	a5,d7
		blt.s	.playfd
		move.w	d6,d5
		add.w	d7,d5

.playfd		sub.w	d5,d6

		movea.l d0,a0
		movea.l d1,a1
		movea.l d2,a2
		movea.l d3,a3
		bra.s	._4voice

._4loop		move.b	(a0)+,d4	; 4 voices playing
		add.b	(a1)+,d4
		roxr.b	d4
		add.b	(a2)+,d4
		roxr.b	d4
		add.b	(a3)+,d4
		roxr.b	d4
		move.w	d4,(a4)+
._4voice	dbra.w	d5,._4loop

		move.l	a0,d0
		move.l	a1,d1
		move.l	a2,d2
		move.l	a3,d3
		bra.w	.feedloop



._1loop		move.b	(a0)+,d4	; 1 voice playing
		move.w	d4,(a4)+
._1voice	dbra.w	d5,._1loop
		rts

._2loop		move.b	(a0)+,d4	; 2 voices playing
		add.b	(a1)+,d4
		roxr.b	d4
		move.w	d4,(a4)+
._2voice	dbra.w	d5,._2loop
		rts

._3loop:	move.b	(a0)+,d4	; 3 voices playing
		add.b	(a1)+,d4
		roxr.b	d4
		add.b	(a2)+,d4
		roxr.b	d4
		move.w	d4,(a4)+
._3voice	dbra.w	d5,._3loop
		rts




***********************************
*
*  void interrupt EmulateDMA(usp.l *NextSample)
*
* Emulate the DMA soundsystem via timer a
*
***********************************

EmulateDMA	movem.l d0-d1/a0,-(sp)

		move.l	usp,a0
		move.w	(a0)+,d0
		lsl.w	#3,d0
		move.l	a0,usp

		lea.l	  $ffff8800.w,a0
		movem.l .da(pc,d0.w),d0-d1

		movep.l d0,(a0)
		move.l  d1,(a0)

		movem.l (sp)+,d0-d1/a0
		rte

.da		incbin	'inc\YM2149.dac'	; DAC emulation table


; Video subsystem

*********************************
*
*  void macro BlastScreen()
*
* Swap screen pages
*
*********************************

		section	text
ScreenAdr1	ds.l	1	; Visible page
ScreenAdr2	ds.l	1	; Offscreen page
			
BlastScreen	macro
			
		move.l ScreenAdr2(pc),d0
		move.l ScreenAdr1(pc),ScreenAdr2
		move.l d0,ScreenAdr1

		lsr.w  #8,d0
		move.l d0,$ffff8200.w
		endm
		


*********************************
*
*  void ShowPic(a0.l *LZ77Source)
*
* Show a full screen picture
*
*********************************
		
ShowPic		movea.l	ScreenAdr2(pc),a1
		bsr.w	d_lz77		; Decrunch into inactive page
		BlastScreen		; Flip pages

		movem.l	ScreenAdr1(pc),a0/a1
		move.l	#32000,d0	; Blit into second page
		bra.w	MoveBlock




*********************************
*
*  void SetPalettePtr(a0.l *Source)
*
* Initialize palette from a pointer
*
*********************************

SetPalettePtr	lea.l	PaletteRSC,a2
		lea.l	2(a2),a3
		move.l	a3,fadescale

		lea.l	.shades(pc),a4

		moveq.l	#16-1,d7	; fade scales-1
		
.scale		movea.l	a0,a1
		movea.l	a2,a3

		moveq.l	#0,d5

.parse		move.w	(a1),d0		; Get header word
		bmi.s	.endofpal
	ifeq	0
		bne.s	.fade		; Remove blank entries
		cmpa.l	a0,a1		; except for first and
		beq.s	.fade		; last one
		
		lea.l	34(a1),a1
		tst.w	(a1)
		beq.s	.parse
	endc
.fade		addq.l	#2,a1
		move.w	d0,(a3)+	; Save raster position
	

		
		moveq.l	#16-1,d0	; Fade palette to current shade
.fadeloop	move.w	(a1)+,d1	; Seperate channels
		move.w	d1,d2
		move.w	d1,d3


		moveq.l	#%1110,d6
		add.w	d1,d1		; blue
		bclr.l	#4,d1
		sne.b	d4
		and.w	d6,d1
		sub.b	d4,d1
				
		lsr.w	#3,d2		; green
		bclr.l	#4,d2
		sne.b	d4
		and.w	d6,d2
		sub.b	d4,d2
		
		lsr.w	#7,d3		; red
		bclr.l	#4,d3
		sne.b	d4
		and.w	d6,d3
		sub.b	d4,d3
	
		move.b	(a4,d3.w),d4	; Reorder faded channels
		lsl.b	#4,d4
		or.b	(a4,d2.w),d4
		lsl.w	#4,d4
		or.b	(a4,d1.w),d4
		move.w	d4,(a3)+	; Store color

		dbra	d0,.fadeloop
		bra.s	.parse

.endofpal	move.w	d0,(a3)		; Terminate palette
		lea.l	PHYSY*34+2(a2),a2
		addq.l	#1,a4

		dbra	d7,.scale
		rts
		
.shades		dcb.b	16,0
		dc.b	$0,$8
		dc.b	$1,$9
		dc.b	$2,$a
		dc.b	$3,$b
		dc.b	$4,$c
		dc.b	$5,$d
		dc.b	$6,$e
		dc.b	$7,$f
		
fadescale	ds.l	1
fadestep	ds.l	1		; Fade in or out?

		section	bss
PaletteRSC	ds.b	16*(PHYSY*34+2)



*********************************
*
*  void FadeTo(a0.l *Palette)
*
* Fade the screen to a palette
*
*********************************

		section	text
FadeTo		move.w	#15,firstframe
		move.l	#34*PHYSY+2,fadestep 	; Force fadein
		bsr.w	SetPalettePtr	; Generate faded sets

		move.w	#$2700,sr	; Disable IRQs

		move.l	#FadeVBL,$70.w	; Initialise VBL & HBL vectors
		move.l	#FadeHBL,$120.w
		
		clr.b	$fffffa07.w	; Stop mfp irqs
		clr.b	$fffffa09.w
	
		bclr.b	#3,$fffffa03.w	; Timer b at the end of a scanline	
		bset.b	#0,$fffffa07.w	; Mask in HBL

		clr.b	$fffffa1b.w	; Stop HBL
			
		move.w	#$2300,sr
		rts
		



*********************************
*
*  void FadeToBlak()
*
* Fade the screen to black and wait
*
*********************************

FadeToBlack	move.l	#-(34*PHYSY+2),fadestep	; Force fadeout		
		move.w	#15,firstframe		; Fade out 15 times

.fizzleout	tst.w	firstframe	; Wait
		bgt.s	.fizzleout
	
	ifeq	0
		move.w	#$2700,sr
		move.l	#idle,$120.w
		move.l	#idle,$70.w
		
		move.b	#%01010000,$fffffa09.w
		move.b	#%01010000,$fffffa15.w
		bset.b	#0,$fffffa07.w
	
		clr.b	$fffffa1b.w	; Stop HBL
		move.w	#$2300,sr
	endc
		rts



*********************************
* 
*  void interrupt FadeVBL()
*
* Display a 256 color picture
*
*********************************

FadeVBL		movem.l	d0-a1,-(sp)

		move.l	fadescale(pc),a0
		movem.l (a0)+,d0-d7	; Set palette for first scanline
		movem.l	d0-d7,$ffff8240.w

		btst.b	#1,$469.w	; Force 15Hz fade
		beq.s	.nofade
		
		move.w	firstframe(pc),d0
		beq.s	.nofade		; Done?
		
		subq.w	#1,d0
		move.w	d0,firstframe
		move.l	fadestep(pc),d0
		add.l	d0,fadescale

.nofade		move.l	a0,rpos

		clr.b	$fffffa21.w	; Restart HBL
		move.b	#8,$fffffa1b.w

		subq.l	#1,$466.w	; _frcnt++
		bra.s	*+6

	

FadeHBL		movem.l d0-a1,-(sp)
		movea.l rpos(pc),a0	; Next chunk

.next		clr.b	$fffffa1b.w	; Stop timer b

		move.w  (a0)+,d0	; Position
		bmi.s   .break		; End of chunk?

		sub.w	-36(a0),d0
		cmp.b	#1,d0		; Grab a single scanline
		beq.s	.short		; to stabilize raster

		move.b  d0,$fffffa21.w	; Set position
		move.b  #8,$fffffa1b.w
		
		movem.l	-34(a0),d1-d7/a1; Get palette
		lea.l	32(a0),a0
		move.l	a0,rpos

.sync1		cmp.b	$fffffa21.w,d0
		beq.s	.sync1

		movem.l d1-d7/a1,$ffff8240.w ; Set colors
		
.break		movem.l (sp)+,d0-a1
		rte


.short		clr.b	$fffffa21.w
		move.b  #8,$fffffa1b.w
		 
		movem.l (a0)+,d1-d7/a1	; Get palette
 		move.l	a0,rpos

.sync2		tst.b	$fffffa21.w
		beq.s	.sync2

		movem.l d1-d7/a1,$ffff8240.w ; Set colors
		bra.w	.next

rpos		ds.l	1
firstframe	ds.w	1