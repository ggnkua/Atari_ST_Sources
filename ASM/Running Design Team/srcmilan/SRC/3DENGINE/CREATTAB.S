
CTTLIGHTNINGCOLORS	equ	32768
CTTLIGHTNINGSCOLORS	equ	32
CTTLIGHTNINGSTEPS	equ	8


		text


; ---------------------------------------------------------
; standard
createTruecolorTab0

		lea	lightningTab,a6
		lea	truecolorTab,a0

		moveq	#CTTLIGHTNINGSTEPS-1,d0
ctt0Loop	move.w	(a6)+,d6
		movem.l	d0/a0/a6,-(sp)
		bsr.s	ctt0Now
		movem.l	(sp)+,d0/a0/a6
		adda.l	#CTTLIGHTNINGCOLORS*2,a0
		dbra	d0,ctt0Loop
		rts

ctt0Now
		adda.l	#CTTLIGHTNINGCOLORS*2,a0
		move.w	#CTTLIGHTNINGSCOLORS-1,d7

		move.w	#CTTLIGHTNINGSCOLORS-1,d0
ctt0nLoop1	move.w	#CTTLIGHTNINGSCOLORS-1,d1
ctt0nLoop2	move.w	#CTTLIGHTNINGSCOLORS-1,d2
ctt0nLoop3	move.w	d2,d5
		mulu	d6,d5
		divu	d7,d5

		move.w	d1,d4
		lsl.w	#1,d4
		addq.w	#1,d4
		mulu	d6,d4
		divu	d7,d4

		move.w	d0,d3
		mulu	d6,d3
		divu	d7,d3

		andi.w	#%0000000000011111,d3
		lsl.w	#6,d3
		andi.w	#%0000000000111111,d4
		add.w	d4,d3
		lsl.w	#5,d3
		andi.w	#%0000000000011111,d5
		add.w	d5,d3

		move.w	d3,-(a0)

		dbra	d2,ctt0nLoop3
		dbra	d1,ctt0nLoop2
		dbra	d0,ctt0nLoop1

		rts


; ---------------------------------------------------------
; nachtsichtgeraet
createTruecolorTab1

		lea	lightningTab,a6
		lea	truecolorTab,a0

		moveq	#CTTLIGHTNINGSTEPS-1,d0
ctt1Loop	move.w	(a6)+,d6
		movem.l	d0/a0/a6,-(sp)
		bsr.s	ctt1Now
		movem.l	(sp)+,d0/a0/a6
		adda.l	#CTTLIGHTNINGCOLORS*2,a0
		dbra	d0,ctt1Loop
		rts

ctt1Now
		adda.l	#CTTLIGHTNINGCOLORS*2,a0
		move.w	#CTTLIGHTNINGSCOLORS-1,d7

		move.w	#CTTLIGHTNINGSCOLORS-1,d0
ctt1nLoop1	move.w	#CTTLIGHTNINGSCOLORS-1,d1
ctt1nLoop2	move.w	#CTTLIGHTNINGSCOLORS-1,d2
ctt1nLoop3
		move.w	d1,d4
		lsl.w	#1,d4
		addq.w	#1,d4
		mulu	d6,d4
		divu	d7,d4

		andi.w	#%0000000000111111,d4
		lsl.w	#5,d4

		move.w	d4,-(a0)

		dbra	d2,ctt1nLoop3
		dbra	d1,ctt1nLoop2
		dbra	d0,ctt1nLoop1

		rts


; ---------------------------------------------------------
; infrarot
createTruecolorTab2

		lea	lightningTab,a6
		lea	truecolorTab,a0

		moveq	#CTTLIGHTNINGSTEPS-1,d0
ctt2Loop	move.w	(a6)+,d6
		movem.l	d0/a0/a6,-(sp)
		bsr.s	ctt2Now
		movem.l	(sp)+,d0/a0/a6
		adda.l	#CTTLIGHTNINGCOLORS*2,a0
		dbra	d0,ctt2Loop
		rts

ctt2Now
		adda.l	#CTTLIGHTNINGCOLORS*2,a0
		move.w	#CTTLIGHTNINGSCOLORS-1,d7

		move.w	#CTTLIGHTNINGSCOLORS-1,d0
ctt2nLoop1	move.w	#CTTLIGHTNINGSCOLORS-1,d1
ctt2nLoop2	move.w	#CTTLIGHTNINGSCOLORS-1,d2
ctt2nLoop3	move.w	d0,d3
		mulu	d6,d3
		divu	d7,d3

		andi.w	#%0000000000011111,d3
		lsl.w	#6,d3
		lsl.w	#5,d3

		move.w	d3,-(a0)

		dbra	d2,ctt2nLoop3
		dbra	d1,ctt2nLoop2
		dbra	d0,ctt2nLoop1

		rts


; ---------------------------------------------------------
; nebel
createTruecolorTab3

		lea	lightningTab,a6
		lea	lightningFogTab,a5
		lea	truecolorTab,a0

		moveq	#CTTLIGHTNINGSTEPS-1,d0
ctt3Loop	move.w	(a6)+,d6			; abdunkelungswerte (0..31)
		move.w	(a5)+,d7
		movem.l	d0/a0/a5-a6,-(sp)
		bsr	ctt3Now
		movem.l	(sp)+,d0/a0/a5-a6
		adda.l	#CTTLIGHTNINGCOLORS*2,a0
		dbra	d0,ctt3Loop
                rts

ctt3Now
		move.w	#31,d5
		sub.w	d7,d5
		move.w	#%01111,d4
		mulu	d7,d4
		divu	#31,d4
		adda.l	#CTTLIGHTNINGCOLORS*2,a0
		
		move.w	#31,d0
ctt3nLoop1	move.w	#31,d1
ctt3nLoop2	move.w	#31,d2
ctt3nLoop3	movem.w	d0-d2,-(sp)

		mulu	d6,d2
		divu	#31,d2
		mulu	d5,d2
		divu	#31,d2
		add.w	d4,d2		

		lsl.w	#1,d1
		addq.w	#1,d1
		mulu	d6,d1
		divu	#31,d1
		mulu	d5,d1
		divu	#31,d1
		add.w	d4,d1	
		add.w	d4,d1	

		mulu	d6,d0
		divu	#31,d0
		mulu	d5,d0
		divu	#31,d0
		add.w	d4,d0

		andi.w	#%0000000000011111,d0
		lsl.w	#6,d0
		andi.w	#%0000000000111111,d1
		add.w	d1,d0
		lsl.w	#5,d0
		andi.w	#%0000000000011111,d2
		add.w	d2,d0

		move.w	d0,-(a0)

		movem.w	(sp)+,d0-d2
		dbra	d2,ctt3nLoop3
		dbra	d1,ctt3nLoop2
		dbra	d0,ctt3nLoop1

		rts







; ---------------------------------------------------------
; dunkel
createTruecolorTab4

		lea	lightningOffTab,a6
		lea	truecolorTab,a0

		moveq	#7,d0
ctt4Loop	move.w	(a6)+,d6		; abdunkelungswerte (0..31)
		movem.l	d0/a0/a6,-(sp)
		bsr	ctt4Now
		movem.l	(sp)+,d0/a0/a6
		adda.l	#32768*2,a0
		dbra	d0,ctt4Loop
                rts

ctt4Now
		adda.l	#32768*2,a0
		move.w	#31,d7
		
		move.w	#31,d0
ctt4nLoop1	move.w	#31,d1
ctt4nLoop2	move.w	#31,d2
ctt4nLoop3	move.w	d2,d5
		mulu	d6,d5
		divu	d7,d5

		move.w	d1,d4
		lsl.w	#1,d4
		addq.w	#1,d4
		mulu	d6,d4
		divu	d7,d4

		move.w	d0,d3
		mulu	d6,d3
		divu	d7,d3

		andi.w	#%0000000000011111,d3
		lsl.w	#6,d3
		andi.w	#%0000000000111111,d4
		add.w	d4,d3
		lsl.w	#5,d3
		andi.w	#%0000000000011111,d5
		add.w	d5,d3

		move.w	d3,-(a0)

		dbra	d2,ctt4nLoop3
		dbra	d1,ctt4nLoop2
		dbra	d0,ctt4nLoop1

		rts





		data


truecolorTabsRouts
		dc.l	createTruecolorTab0
		dc.l	createTruecolorTab1
		dc.l	createTruecolorTab2
		dc.l	createTruecolorTab3
		dc.l	createTruecolorTab4
		dc.l	0
		dc.l	0
		dc.l	0

lightningTab	dc.w	31,29,27,25,23,21,19,17
lightningOffTab	dc.w	7,6,5,4,3,2,1,0
lightningFogTab	dc.w	0,2,4,6,8,10,12,14



		bss


truecolorTab	ds.b	32768*2*8
