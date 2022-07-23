	section text

greetzInit:
	firstRunOrReturn
	bsr video_320x200x16
	lea	imageGreetz,a0
	move.l	scr3,a1
	bsr loadTcPicture
	
	rts

greetzText:
	firstRunOrReturn
	bsr greetzCopyText

	rts

	macro greetzHeartOnMacro
greetzHeartOn\1	
	firstRunOrReturn
	bsr greetzCopyHeart
	rts
	endm

	greetzHeartOnMacro 1
	greetzHeartOnMacro 2
	greetzHeartOnMacro 3
	greetzHeartOnMacro 4

	macro greetzHeartOffMacro
greetzHeartOff\1	
	firstRunOrReturn
	bsr greetzCopyNoHeart
	rts
	endm
	
	greetzHeartOffMacro 1
	greetzHeartOffMacro 2
	greetzHeartOffMacro 3
	greetzHeartOffMacro 4
	
;greetzMain:
;	add.l	#1,greetzFrame
;	cmp.l	#40,greetzFrame
;	bne.s	_grNo1
;	bsr greetzCopyHeart
;_grNo1	
;	cmp.l	#80,greetzFrame
;	bne.s	_grNo2
;	move.l	#0,greetzFrame
;	bsr greetzCopyNoHeart
;_grNo2	
;	rts

greetzCopyText:
	lea	imageGreetzT,a0
	move.l	scr3,a1
	add.l	#320*65*2+160*2,a1
	
	; 100x90
	move.l	#90-1,d7
_copyTextLoop
	rept 5
	movem.l	(a0)+,d0-d6/a2-a4	; 10regs=20px
	movem.l	d0-d6/a2-a4,(a1)
	lea		40(a1),a1
	endr
	add.l	#(320-100)*2,a1
	dbf d7,_copyTextLoop
	rts


greetzCopyHeart:
	lea	imageGreetzH,a0
	move.l	scr3,a1
	lea 320*29*2+168*2(a1),a1
	
	; 48x45
	move.l	#45-1,d7
_copyHeartLoop
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea		48(a1),a1
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea (320-48)*2+48(a1),a1
	dbf d7,_copyHeartLoop
	rts
	
greetzCopyNoHeart:
	lea	imageGreetz,a0
	move.l	scr3,a1
	lea 320*29*2+168*2(a0),a0
	lea 320*29*2+168*2(a1),a1
	
	; 48x45
	move.l	#45-1,d7
_copyHeartNoLoop
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea		48(a1),a1
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea (320-48)*2(a0),a0	
	lea (320-48)*2+48(a1),a1
	dbf d7,_copyHeartNoLoop
	rts

	macro	copyGreetzSlideMacro
copyGreetzSlideMain\1:
	firstRunOrReturn	
	move.l	#imageGreetz\1,a0
	move.l	scr3,a1
	add.l	#\2,a1
	bsr	copyGreetzSlide
	rts
	endm

	copyGreetzSlideMacro 1,0
	copyGreetzSlideMacro 2,320*2*100
	copyGreetzSlideMacro 3,160*2
	copyGreetzSlideMacro 4,(320*2*100+160*2)
	
	copyGreetzSlideMacro 5,0
	copyGreetzSlideMacro 6,320*2*100
	copyGreetzSlideMacro 7,160*2
	copyGreetzSlideMacro 8,(320*2*100+160*2)	

	copyGreetzSlideMacro 9,0
	copyGreetzSlideMacro 10,320*2*100
	copyGreetzSlideMacro 11,160*2
	copyGreetzSlideMacro 12,(320*2*100+160*2)
	
	copyGreetzSlideMacro 13,0
	copyGreetzSlideMacro 14,320*2*100
	copyGreetzSlideMacro 15,160*2
	copyGreetzSlideMacro 16,(320*2*100+160*2)	

	copyGreetzSlideMacro 17,0
	copyGreetzSlideMacro 18,320*2*100
	copyGreetzSlideMacro 19,160*2
	copyGreetzSlideMacro 20,(320*2*100+160*2)	
	
	copyGreetzSlideMacro 21,0
	copyGreetzSlideMacro 22,320*2*100
	copyGreetzSlideMacro 23,160*2
	copyGreetzSlideMacro 24,(320*2*100+160*2)		

	copyGreetzSlideMacro 25,0
	copyGreetzSlideMacro 26,320*2*100
	copyGreetzSlideMacro 27,160*2
	copyGreetzSlideMacro 28,(320*2*100+160*2)
	
	copyGreetzSlideMacro 29,0
	copyGreetzSlideMacro 30,320*2*100
	copyGreetzSlideMacro 31,160*2
	copyGreetzSlideMacro 32,(320*2*100+160*2)	

	copyGreetzSlideMacro 33,0
	copyGreetzSlideMacro 34,320*2*100
	copyGreetzSlideMacro 35,160*2
	copyGreetzSlideMacro 36,(320*2*100+160*2)	

	copyGreetzSlideMacro 37,0
	
	;a0 in
	;a1 out
copyGreetzSlide:
	move.l	#100-1,d7
_copyGreetzSlideLoop	
	rept 6
	movem.l	(a0)+,d0-d6/a2-a6	; 12 - 24px
	movem.l	d0-d6/a2-a6,(a1)
	lea	24*2(a1),a1
	endr
	movem.l	(a0)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)	
	lea	16*2+160*2(a1),a1
	dbf d7,_copyGreetzSlideLoop
	rts

	section data
	cnop 0,4
imageGreetz		incbin	'greetz/greetz_ok.dat'
imageGreetzT	incbin	'greetz/greetz_text.dat'
imageGreetzH	incbin	'greetz/greetz_heart.dat'

imageGreetz1	incbin	'greetz/greetz_Aldi.dat'
imageGreetz2	incbin	'greetz/greetz_Altair.dat'
imageGreetz3	incbin	'greetz/greetz_Anadune.dat'
imageGreetz4	incbin	'greetz/greetz_ASD.dat'
imageGreetz5	incbin	'greetz/greetz_Auchan.dat'
imageGreetz6	incbin	'greetz/greetz_Biedronka.dat'
imageGreetz7	incbin	'greetz/greetz_Carrefour.dat'
imageGreetz8	incbin	'greetz/greetz_Cocoon.dat'
imageGreetz9	incbin	'greetz/greetz_Conspiracy.dat'
imageGreetz10	incbin	'greetz/greetz_DHS.dat'
imageGreetz11	incbin	'greetz/greetz_DMA.dat'
imageGreetz12	incbin	'greetz/greetz_Dune.dat'
imageGreetz13	incbin	'greetz/greetz_Elude.dat'
imageGreetz14	incbin	'greetz/greetz_Fairlight.dat'
imageGreetz15	incbin	'greetz/greetz_Farbrausch.dat'
imageGreetz16	incbin	'greetz/greetz_505.dat'
imageGreetz17	incbin	'greetz/greetz_FUTURIS.dat'
imageGreetz18	incbin	'greetz/greetz_Ghostown.dat'
imageGreetz19	incbin	'greetz/greetz_Intermarche.dat'
imageGreetz20	incbin	'greetz/greetz_Lidl.dat'
imageGreetz21	incbin	'greetz/greetz_MAWI.dat'
imageGreetz22	incbin	'greetz/greetz_MysticBytes.dat'
imageGreetz23	incbin	'greetz/greetz_Netto.dat'
imageGreetz24	incbin	'greetz/greetz_Paradox.dat'
imageGreetz25	incbin	'greetz/greetz_PiotriPawel.dat'
imageGreetz26	incbin	'greetz/greetz_PixelTwins.dat'
imageGreetz27	incbin	'greetz/greetz_Plastic.dat'
imageGreetz28	incbin	'greetz/greetz_PoloMarket.dat'
imageGreetz29	incbin	'greetz/greetz_Real.dat'
imageGreetz30	incbin	'greetz/greetz_SectorOne.dat'
imageGreetz31	incbin	'greetz/greetz_SpeccyPL.dat'
imageGreetz32	incbin	'greetz/greetz_SPKR.dat'
imageGreetz33	incbin	'greetz/greetz_Spolem.dat'
imageGreetz34	incbin	'greetz/greetz_TBL.dat'
imageGreetz35	incbin	'greetz/greetz_Tesco.dat'
imageGreetz36	incbin	'greetz/greetz_WantedTeam.dat'
imageGreetz37	incbin	'greetz/greetz_Zabka.dat'
;imageGreetz37	incbin	'greetz/greetz_AndYou.dat'

	section bss
greetzFrame		dc.l	0
	section text
