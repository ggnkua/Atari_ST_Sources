	section text

	macro flashMacro
flash\1
	firstRunOrReturn
	bsr \3
	move.l	#$\2,borderColor
	lea.l	$ffff9800.w,a1
	move.l	#$\2,d0
	move.w	#256-1,d7				
_setPalLoop\1:
	move.l	d0,(a1)+				
	dbra	d7,_setPalLoop\1				
	rts
	endm
	
	flashMacro Start1,ffffffff,video_320x100x8rgb
	flashMacro End1,00000000,video_320x200x16	

	flashMacro Start2,ffffffff,video_320x100x8rgb
	flashMacro End2,00000000,video_320x200x16	

	flashMacro Start3,ffffffff,video_320x100x8rgb
	flashMacro End3,00000000,video_320x200x16	

	;flashMacro Start4,ffffffff,video_320x100x8rgb
	;flashMacro End4,00000000,video_320x200x16

pictureWowInit:
	firstRunOrReturn
	;bsr video_320x200x16
	bsr		clearScreenBuffer
	
	bsr	restoreScr
	move.w	$FFFF820E,oldLineOffset
	
	move.w	#160*3,$FFFF820E

	move.l	scr2,a2
	move.l	a2,a1
	move.l	a2,scr3	

	move.l	scr3,a1
	move.l	a1,hScrollScr3org
	sub.l	#320*2,a1
		
	lea		imageWow,a0	
	bsr	loadTc640200Picture
	move.l	#0,hScrollFrame

	rts

;pictureWowInit2:
;	firstRunOrReturn

;	move.l	scr3,a1
;	sub.l	#320*2,a1
		
;	lea		imageWow,a0	
;	bsr	loadTc640200Picture
;	move.l	#0,hScrollFrame
;	rts


pictureWowEnd:
	firstRunOrReturn
	bsr	clearScreenBuffer
	bsr	restoreScr
	move.w	oldLineOffset,$FFFF820E		
	rts

pictureWowClr:
	move.l	hScrollScr3org,a1
	lea	320(a1),a1
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	#200-1,d7
_loadTcLoop640200Clr
	rept	8
	movem.l	d0-d5/a2-a5,(a1)	; 10regs=20px
	lea		40(a1),a1
	endr
	lea		960+320(a1),a1
	
	dbf		d7,_loadTcLoop640200Clr


	rts

loadTc640200Picture:
	move.l	#200-1,d7
_loadTcLoop640200
	move.l	#8-1,d6
_loadTcLoop640200_1
	rept	4
	movem.l	(a0)+,d0-d5/a2-a5	; 10regs=20px
	movem.l	d0-d5/a2-a5,(a1)
	lea		40(a1),a1
	endr
	dbf		d6,_loadTcLoop640200_1
	lea		320(a1),a1
	
	dbf		d7,_loadTcLoop640200

	rts


pictureWowMain:
	cmp.l	#550,hScrollFrame
	bge.s	_pictureWowNoScroll
	add.l	#1,hScrollFrame

	move.l	scr3,a1
	lea		-2(a1),a1
	move.l	a1,scr3
_pictureWowNoScroll		
		
	cmp.l	#400,hScrollFrame
	bne.s	_pictureWowNoClr
	bsr		pictureWowClr
_pictureWowNoClr
	rts

pictureGouInit:
	firstRunOrReturn
	bsr		clearScreenBuffer3
	bsr 	video_320x200x16
	lea imageGou,a0
	bsr	loadTcPicture160200Fast
	bsr	gou3dInit
	rts


; *** GREY ***

pictureInitGreyPreFlashOn1:
		firstRunOrReturn
		lea	imageGreyPre2,a0
		bsr pictureGreyCopyFlash
		rts

pictureInitGreyPreFlashOn2:
		firstRunOrReturn
		lea	imageGreyPre3,a0
		bsr pictureGreyCopyFlash
		rts

;pictureInitGreyPreFlashOn1:
;		firstRunOrReturn
;		bsr pictureGreyCopyFlash
;		rts

;pictureInitGreyPreFlashOn2:
;		firstRunOrReturn
;		bsr pictureGreyCopyFlash
;		rts

;pictureInitGreyPreFlashOn3:
;		firstRunOrReturn
;		bsr pictureGreyCopyFlash
;		rts

;pictureInitGreyPreFlashOff1:
;		firstRunOrReturn
;		bsr pictureGreyCopyNoFlash
;		rts

;pictureInitGreyPreFlashOff2:
;		firstRunOrReturn
;		bsr pictureGreyCopyNoFlash
;		rts

;pictureInitGreyPreFlashOff3:
;		firstRunOrReturn
;		bsr pictureGreyCopyNoFlash
;		rts

pictureGreyCopyFlash:
	move.l	scr3,a1
	;lea 320*10*2+195*2(a1),a1
	lea 320*11*2+195*2(a1),a1
	
	; 120x70
	move.l	#70-1,d7
_copyGreyFLashLoop
	rept 6
	movem.l	(a0)+,d0-d6/a2-a4	; 10regs=20px
	movem.l	d0-d6/a2-a4,(a1)
	lea		40(a1),a1
	endr
	lea 400(a1),a1
	dbf d7,_copyGreyFLashLoop
	rts


;pictureGreyCopyFlash:
;	lea	imageGreyPre2,a0
;	move.l	scr3,a1
;	lea 320*10*2+195*2(a1),a1
;	
;	; 120x70
;	move.l	#70-1,d7
;_copyGreyFLashLoop
;	rept 6
;	movem.l	(a0)+,d0-d6/a2-a4	; 10regs=20px
;	movem.l	d0-d6/a2-a4,(a1)
;	lea		40(a1),a1
;	endr
;	lea 400(a1),a1
;	dbf d7,_copyGreyFLashLoop
;	rts

;pictureGreyCopyNoFlash:
;	lea	imageGreyPre,a0
;	move.l	scr3,a1
;	lea 320*10*2+195*2(a0),a0
;	lea 320*10*2+195*2(a1),a1
;	
	; 120x70
;	move.l	#70-1,d7
;_copyGreyNoFLashLoop
;	rept 6
;	movem.l	(a0)+,d0-d6/a2-a4	; 10regs=20px
;	movem.l	d0-d6/a2-a4,(a1)
;	lea		40(a1),a1
;	endr
;	lea 400(a0),a0
;	lea 400(a1),a1
;	dbf d7,_copyGreyNoFLashLoop
;	rts


pictureGreyVScrollInit:
	firstRunOrReturn
	bsr		clearScreenBuffer3
	bsr 	video_320x240x16
	bsr 	restoreScr
	; 1=1,2=2,3=3 -> 1=2,2=3,3=1
	bsr		switchScreens

	move.l	scr3,a1
	move.l	a1,a2
	add.l	#320*2*20,a2
	move.l	a2,scr3
	
	move.l	#imageGreyV,a0
	bsr		loadGreyVPicture
	move.l	#0,vScrollFrame
	rts

pictureGreyVScrollMain:
	
	cmp.l	#160,vScrollFrame
	bge.s	_pictureGreyVScrollMainNoScrollDown

	move.l	scr3,a1
	lea		320*2(a1),a1
	move.l	a1,scr3
	bra.s	_pictureGreyVScrollMainNoScrollEnd
	
_pictureGreyVScrollMainNoScrollDown		

	move.l	scr3,a1
	lea		-320*2(a1),a1
	move.l	a1,scr3
_pictureGreyVScrollMainNoScrollEnd		
	add.l	#1,vScrollFrame

	rts

pictureGreyVScrollEnd:
	firstRunOrReturn
	bsr 	video_320x200x16
	bsr 	restoreScr
	bsr 	pictureInitGrey
	rts

pictureInitStart:
	firstRunOrReturn
	bsr 	video_320x200x16
	rts
	
pictureInitTitle:
	firstRunOrReturn
	bsr 	video_320x200x16

	lea	imageTitle,a0
	bsr loadTcPicture180Scr3
	rts

pictureInitTitle2:
	firstRunOrReturn
	bsr 	video_320x200x16

	lea	imageTitle,a0
	bsr loadTcPicture180Scr3
	rts	

pictureInitLogo1a:
	firstRunOrReturn
	bsr	video_320x200x16
	bsr clearScreenBuffer3
	
	lea	imageLogo1,a0
	move.l	scr3,a1
	bsr loadTcPicture80Col
	rts

pictureInitLogo1b:
	firstRunOrReturn
	bsr 	video_320x200x16
	lea	imageLogo1,a0
	move.l	scr3,a1
	lea	80*2(a0),a0
	lea	80*2(a1),a1
	bsr loadTcPicture80Col
	rts
	
pictureInitLogo1c:
	firstRunOrReturn
	bsr 	video_320x200x16
	lea	imageLogo1,a0
	move.l	scr3,a1
	lea	80*2*2(a0),a0
	lea	80*2*2(a1),a1
	bsr loadTcPicture80Col
	rts
	
pictureInitLogo1d:
	firstRunOrReturn
	bsr 	video_320x200x16
	lea	imageLogo1,a0
	move.l	scr3,a1
	lea	80*2*3(a0),a0
	lea	80*2*3(a1),a1
	bsr loadTcPicture80Col
	rts	

pictureInitGreyPre:
	firstRunOrReturn
	bsr 	video_320x200x16
	lea	imageGreyPre,a0
	move.l	scr3,a1
	bsr loadTcPicture
	rts

pictureInitGreyPre4:
	firstRunOrReturn
	;bsr 	video_320x200x16
	lea	imageGreyPre4,a0
	move.l	scr3,a1
	bsr loadTcPicture
	rts

pictureInitGrey:
	firstRunOrReturn
	lea	imageGrey,a0
	bsr loadTcPictureFast
	bsr tex3dInitGrey
	rts

pictureInitCode:
	firstRunOrReturn
	bsr 	video_320x200x16
	bsr clearTcPicture10Fast
	lea	imageCode,a0
	lea	10*640(a0),a0
	bsr loadTcPicture180Fast
	bsr tex3dInitCode
	rts

pictureInitMsx:
	firstRunOrReturn
	lea	imageMsx,a0
	lea	10*640(a0),a0
	bsr loadTcPicture180Fast
	bsr tex3dInitMsx
	rts

pictureInitVisuals:
	firstRunOrReturn
	lea	imageVisuals,a0
	lea	10*640(a0),a0
	bsr loadTcPicture180Fast
	bsr tex3dInitVisuals
	rts

	macro pictureInitIntro	
pictureInitIntro\1:
	firstRunOrReturn

	lea	imageIntro\1,a0
	move.l	scr3,a1
	bsr loadTcPicture
	rts
	endm
	
	;pictureInitIntro 1
	pictureInitIntro 2
	pictureInitIntro 3
	pictureInitIntro 4
	pictureInitIntro 5
	pictureInitIntro 6
	pictureInitIntro 7
	pictureInitIntro 8
	pictureInitIntro 9

pictureInitFade:
	firstRunOrReturn
	bsr 	video_320x200x16

	move.l	#0,fadeFrame
	rts

pictureInitFadeEndLogo:
	firstRunOrReturn
	move.l	#0,fadeFrame
	rts

pictureMainFadeEndLogo:
	lea	fadeData2,a0
	move.l	scr3,a2
	move.l	fadeFrame,d0
	bsr	gradientPicFadeOut
	add.l	#1,fadeFrame
	
	lea	fadeData2,a0
	move.l	scr3,a2
	move.l	fadeFrame,d0
	bsr	gradientPicFadeOut
	add.l	#1,fadeFrame
	rts



;pictureMainIntro1Fade:
;	lea	fadeData,a0
;	lea	imageIntro1,a1
;	move.l	scr3,a2
;	move.l	fadeFrame,d0
;	bsr	gradientPicFade
;	add.l	#1,fadeFrame
;	rts

pictureMainIntro2Fade:
	lea	fadeData2,a0
	lea	imageIntro2,a1
	move.l	scr3,a2
	move.l	fadeFrame,d0
	bsr	gradientPicFade
	add.l	#1,fadeFrame
	rts

; *** pre end

pictureInitPreEnd:
	firstRunOrReturn
	bsr 	video_320x200x16

	lea	imageLogoPreEnd,a0
	bsr loadTcPicture180Scr3
	rts

pictureInitPreEndClr1:
	firstRunOrReturn
	;	208x75-125	_96
	move.l	scr3,a0
	lea	53*320*2+208*2(a0),a0
	bsr	pictureInitPreEndClr
	rts

pictureInitPreEndClr2:
	firstRunOrReturn
	;	10x75-125
	move.l	scr3,a0
	lea	53*320*2+10*2(a0),a0
	bsr	pictureInitPreEndClr
	rts

pictureInitPreEndClr3:
	firstRunOrReturn
	;	110x75-125
	move.l	scr3,a0
	lea	53*320*2+110*2(a0),a0
	bsr	pictureInitPreEndClr
	rts

pictureInitPreEndClr:
	move.l	#70-1,d7
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
_pictureInitPreEndClrLoop
	rept 4
	movem.l	d0-d6/a1-a5,(a0) ; 12r = 24px
	lea 24*2(a0),a0	
	endr
	lea (320-96)*2(a0),a0	

	dbf	d7,_pictureInitPreEndClrLoop	
	
	rts

pictureInitLameboy:
	firstRunOrReturn
	lea	imageLameboy,a0
	move.l	scr3,a1
	bsr loadTcPicture110
	rts

pictureInitLameboy2:
	firstRunOrReturn
	lea	imageLameboy2,a0
	move.l	scr3,a1
	bsr loadTcPicture110
	rts

pictureInitLameboy3:
	firstRunOrReturn
	lea	imageLameboy,a0
	move.l	scr3,a1
	bsr loadTcPicture110
	rts

; *** end scroll ***
;pictureEndScrollInit:
;	firstRunOrReturn
;	bsr		clearScreenBuffer3
;	bsr 	video_320x240x16
;	bsr 	restoreScr
	; 1=1,2=2,3=3 -> 1=2,2=3,3=1
;	bsr		switchScreens

;	move.l	scr3,a1
;	move.l	#imageEndScroll,a0
;	bsr		loadEndScroll
;	move.l	#0,vScrollFrame
;	rts

pictureEndScrollInit2:
	firstRunOrReturn
	bsr		clearScreenBuffer1
	bsr		clearScreenBuffer2
	bsr		clearScreenBuffer3
	bsr 	video_320x240x16
	bsr 	restoreScr
	bsr		clearScreenBuffer1
	bsr		clearScreenBuffer3
	; 1=1,2=2,3=3 -> 1=2,2=3,3=1
	bsr		switchScreens

	move.l	scr3,a1
	add.l	#248*320*2,a1
	move.l	#imageEndScroll,a0
	bsr		loadEndScroll
	move.l	#0,vScrollFrame
	rts

;pictureEndScrollMain:
;	move.l	scr3,a1
;	lea		320*2(a1),a1
;	move.l	a1,scr3

	rts

pictureEndScrollMain2:
	move.l	scr3,a1
	lea		320*2*2(a1),a1
	move.l	a1,scr3

	add.l	#1,vScrollFrame

	rts
	
loadEndScroll:
	move.l	#1920-1,d7
_loadEndScrollLoop
	rept	5
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea		48(a1),a1
	endr
	dbf		d7,_loadEndScrollLoop

	rts
	
	
; *** UTILS ***

loadTcPicture80Col:
	move.l	#200-1,d7
_loadTcLoop80Col
	rept	3
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea		48(a1),a1
	endr
	movem.l	(a0)+,d0-d3	; 4regs=8px
	movem.l	d0-d3,(a1)
	lea		16+240*2(a1),a1
	lea		240*2(a0),a0
	
	dbf		d7,_loadTcLoop80Col
	rts

; load tc picture
loadGreyVPicture:
	move.l	#1133-1,d7
_loadGreyVLoop
	rept	5
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea		48(a1),a1
	endr
	dbf		d7,_loadGreyVLoop
	rept	2
	movem.l	(a0)+,d0-d6/a2-a4	; 10regs=20px
	movem.l	d0-d6/a2-a4,(a1)
	lea		48(a1),a1
	endr

	rts

loadTcPicture:
	move.l	#533-1,d7
_loadTcLoop
	rept	5
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea		48(a1),a1
	endr
	dbf		d7,_loadTcLoop
	rept	2
	movem.l	(a0)+,d0-d6/a2-a4	; 10regs=20px
	movem.l	d0-d6/a2-a4,(a1)
	lea		40(a1),a1
	endr

	rts


loadTcPicture110:
	move.l	#293-1,d7
_loadTcLoop110
	rept	5
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea		48(a1),a1
	endr
	dbf		d7,_loadTcLoop110

	rts


;loadTc640200Picture:
;	move.l	#533-1,d7
;_loadTcLoop640200
;	rept	10
;	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
;	movem.l	d0-d6/a2-a6,(a1)
;	lea		48(a1),a1
;	endr
;	dbf		d7,_loadTcLoop640200
;	rept	4
;	movem.l	(a0)+,d0-d6/a2-a4	; 10regs=20px
;	movem.l	d0-d6/a2-a4,(a1)
;	lea		40(a1),a1
;	endr

	rts


; *** 180 pics ***

loadTcPicture180Scr3:
	move.l	scr3,a1
	lea 	10*320*2(a1),a1
	move.l	scr3,a2
	lea 	200*320*2(a2),a2

	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6

	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6

	move.l	#4-1,d7
_clearScrBufLoop10Scr3			
	rept 32
	movem.l	d0-d6/a3-a6,-(a1)	;22px
	movem.l	d0-d6/a3-a6,-(a2)
	endr
	dbf		d7,_clearScrBufLoop10Scr3
	moveq.l	#0,d7
	rept 16
	movem.l	d0-d7/a3-a6,-(a1)
	movem.l	d0-d7/a3-a6,-(a2)	;24p
	endr

	move.l	scr3,a1
	lea 	10*320*2(a1),a1

	move.l	#480-1,d7
_loadTcLoop180Scr
	rept	5
	movem.l	(a0)+,d0-d6/a2-a6	; 12regs=24px
	movem.l	d0-d6/a2-a6,(a1)
	lea		48(a1),a1
	endr
	dbf		d7,_loadTcLoop180Scr

	rts


clearTcPicture10Fast:
			move.l	scr1,a0
			move.l	scr2,a1
			move.l	scr3,a2

			lea 	10*640(a0),a0
			lea 	10*640(a1),a1
			lea 	10*640(a2),a2

			moveq	#0,d0
			moveq	#0,d1
			moveq	#0,d2
			moveq	#0,d3
			moveq	#0,d4
			moveq	#0,d5
			moveq	#0,d6

			move.l	d0,a3
			move.l	d0,a4
			move.l	d0,a5
			move.l	d0,a6

			move.l	#4-1,d7
_clearScrBufLoop10			
			rept 32
			movem.l	d0-d6/a3-a6,-(a0)
			movem.l	d0-d6/a3-a6,-(a1)
			movem.l	d0-d6/a3-a6,-(a2)							;11r = 22px
			endr
			dbf		d7,_clearScrBufLoop10
			moveq.l	#0,d7
			rept 16
			movem.l	d0-d7/a3-a6,-(a0)
			movem.l	d0-d7/a3-a6,-(a1)
			movem.l	d0-d7/a3-a6,-(a2)							;11r = 22px
			endr			

	rts

loadTcPicture180Fast:
	move.l	scr1,a1
	move.l	scr2,a2
	move.l	scr3,a3
	lea		640*10(a1),a1
	lea		640*10(a2),a2
	lea		640*10(a3),a3

	move.l	#160*18/4-1,d7
_loadTcLoop180Fast
	rept 4
	movem.l	(a0)+,d0-d6/a4-a6	; 10r = 20px
	movem.l	d0-d6/a4-a6,(a1)
	movem.l	d0-d6/a4-a6,(a2)
	movem.l	d0-d6/a4-a6,(a3)
	lea		40(a1),a1
	lea		40(a2),a2
	lea		40(a3),a3
	endr
	dbf		d7,_loadTcLoop180Fast

	rts

loadTcPictureFast:
	move.l	scr1,a1
	move.l	scr2,a2
	move.l	scr3,a3

	move.l	#800-1,d7
_loadTcLoopFast
	rept 4
	movem.l	(a0)+,d0-d6/a4-a6	; 10r = 20px
	movem.l	d0-d6/a4-a6,(a1)
	movem.l	d0-d6/a4-a6,(a2)
	movem.l	d0-d6/a4-a6,(a3)
	lea		40(a1),a1
	lea		40(a2),a2
	lea		40(a3),a3
	endr
	dbf		d7,_loadTcLoopFast

	rts

loadTcPicture160200Fast:
	move.l	scr1,a1
	move.l	scr2,a2
	move.l	scr3,a3

	move.l	#200-1,d7
_loadTcLoop160200Fast
	rept 8
	movem.l	(a0)+,d0-d6/a4-a6	; 10r = 20px
	movem.l	d0-d6/a4-a6,(a1)
	movem.l	d0-d6/a4-a6,(a2)
	movem.l	d0-d6/a4-a6,(a3)
	lea		40(a1),a1
	lea		40(a2),a2
	lea		40(a3),a3
	endr
	lea		320(a1),a1
	lea		320(a2),a2
	lea		320(a3),a3
	dbf		d7,_loadTcLoop160200Fast

	move.l	scr1,a1
	move.l	scr2,a2
	move.l	scr3,a3

	lea		320(a1),a1
	lea		320(a2),a2
	lea		320(a3),a3

	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6

	move.l	#200-1,d7
_loadTcLoop160200FastClr
	rept 8
	movem.l	d0-d6/a4-a6,(a1)
	movem.l	d0-d6/a4-a6,(a2)
	movem.l	d0-d6/a4-a6,(a3)
	lea		40(a1),a1
	lea		40(a2),a2
	lea		40(a3),a3
	endr
	lea		320(a1),a1
	lea		320(a2),a2
	lea		320(a3),a3
	dbf		d7,_loadTcLoop160200FastClr

	rts


	
; *** clear ***

;clearScreenBuffer1:
;	firstRunOrReturn
;	bsr clearScreenBuffer
;	rts


; *** fade ***
;	frame		d0
;	fadeData	a0
;	pic			a1
;	scr			a2
gradientPicFade:
	
	move.l	#25-1,d7	
_gFadeVloop
	move.l	#40-1,d6	
_gFadeHloop

	move.b	(a0)+,d1
	cmp.b	d0,d1
	bne.s	_gFadeNoDraw

	movem.l	(a1),d2-d5
	movem.l	d2-d5,(a2)
	movem.l	640*1(a1),d2-d5
	movem.l	d2-d5,640*1(a2)
	movem.l	640*2(a1),d2-d5
	movem.l	d2-d5,640*2(a2)
	movem.l	640*3(a1),d2-d5
	movem.l	d2-d5,640*3(a2)
	movem.l	640*4(a1),d2-d5
	movem.l	d2-d5,640*4(a2)
	movem.l	640*5(a1),d2-d5
	movem.l	d2-d5,640*5(a2)
	movem.l	640*6(a1),d2-d5
	movem.l	d2-d5,640*6(a2)
	movem.l	640*7(a1),d2-d5
	movem.l	d2-d5,640*7(a2)					

_gFadeNoDraw
	; next 16 px chunk
	lea	16(a1),a1
	lea	16(a2),a2

	dbf	d6,_gFadeHloop

	; 8 lines down; 1 line down already
	lea	640*7(a1),a1
	lea	640*7(a2),a2
	
	dbf	d7,_gFadeVloop
	rts

gradientPicFadeOut:
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5

	move.l	#25-1,d7	
_gFadeVloopOut
	move.l	#40-1,d6	
_gFadeHloopOut

	move.b	(a0)+,d1
	cmp.b	d0,d1
	bne.s	_gFadeNoDrawOut

	
	movem.l	d2-d5,(a2)
	movem.l	d2-d5,640*1(a2)
	movem.l	d2-d5,640*2(a2)
	movem.l	d2-d5,640*3(a2)
	movem.l	d2-d5,640*4(a2)
	movem.l	d2-d5,640*5(a2)
	movem.l	d2-d5,640*6(a2)
	movem.l	d2-d5,640*7(a2)					

_gFadeNoDrawOut
	; next 16 px chunk
	lea	16(a2),a2

	dbf	d6,_gFadeHloopOut

	; 8 lines down; 1 line down already
	lea	640*7(a2),a2
	
	dbf	d7,_gFadeVloopOut
	rts

	section data
	cnop 0,4
imageGrey		incbin	'picture/grey.dat'
imageTitle		incbin	'picture/title.dat'
imageCode		incbin	'picture/code.dat'
imageMsx		incbin	'picture/msx.dat'
imageVisuals	incbin	'picture/visual.dat'

imageGreyV		incbin	'picture/greyv.dat'
imageGreyPre	incbin	'picture/greypre.dat'
imageGreyPre2	incbin	'picture/greypre2.dat'
imageGreyPre3	incbin	'picture/greypre3.dat'
imageGreyPre4	incbin	'picture/greypre4.dat'
imageGou		incbin	'picture/gouraud.dat'
imageWow		incbin	'picture/wow.dat'

imageIntro2		incbin	'picture/w1s.dat'
imageIntro3		incbin	'picture/w2s.dat'
imageIntro4		incbin	'picture/w3s.dat'
imageIntro5		incbin	'picture/w4s.dat'
imageIntro6		incbin	'picture/w5s.dat'
imageIntro7		incbin	'picture/w6s.dat'
imageIntro8		incbin	'picture/w7s.dat'
imageIntro9		incbin	'picture/w8s.dat'
imageLogo1		incbin	'picture/logo1.dat'
imageLogoPreEnd	incbin	'picture/lamers_preend.dat'
imageLameboy	incbin	'picture/lameboy.dat'
imageLameboy2	incbin	'picture/lameboy2.dat'
imageEndScroll	incbin	'picture/endscroll.dat'

;fadeData1	 	incbin	'picture/gradient4.dat'
fadeData2	 	incbin	'picture/gradient3.dat'
fadeFrame		dc.l	0

vScrollFrame	dc.l	0
oldLineOffset	dc.w	0
				dc.w	0
hScrollFrame	dc.l	0
hScrollScr3org	dc.l	0
	section text
