METABALLS_SCR_H	equ 100
METABALLS_SCR_V	equ 100

METABALLS_PADDING equ 15

METABALL1_H	equ	40
METABALL1_V	equ	50
METABALL2_H	equ	50
METABALL2_V	equ	50
METABALL3_H	equ	65
METABALL3_V	equ	65


	macro metaballsInner
	add.l	(a2)+,d\1
	add.l	(a3)+,d\1
	move.w	d\1,d5
	swap	d\1
	move.l	(a4,d\1.w*4),(a0)+
	move.l	(a4,d5.l*4),(a0)+	
	endm

	section text
metaballsInit:
	firstRunOrReturn
	;bsr 	clearScreenBuffer

	lea metaballsDensity+(METABALLS_SCR_H*2*2*METABALLS_SCR_V+METABALLS_SCR_H*2),a0
	lea metaballsAdr,a3
	lea -(METABALLS_SCR_H*METABALL1_V*4+METABALL1_H*2)(a0),a1
	move.l	a1,(a3)+
	lea -(METABALLS_SCR_H*METABALL2_V*4+METABALL2_H*2)(a0),a1
	move.l	a1,(a3)+
	lea -(METABALLS_SCR_H*METABALL3_V*4+METABALL3_H*2)(a0),a1
	move.l	a1,(a3)
	
	move.l	#metaTrack1,metaTrackPtr1
	move.l	#metaTrack2+96,metaTrackPtr2
	move.l	#metaTrack3+196,metaTrackPtr3

	bsr		video_rgb_320x100x16
	bsr		metaClear
	bsr		metaballsLoadTcPicture
	rts

metaClear:
	move.l	scr1,a1
	move.l	scr2,a2
	move.l	scr3,a3

	lea		240(a1),a1
	lea		240(a2),a2
	lea		240(a3),a3

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

	move.l	#100-1,d7
_loadTcLoopMeta
	rept 10
	movem.l	d0-d6/a4-a6,(a1)	; 20px
	movem.l	d0-d6/a4-a6,(a2)
	movem.l	d0-d6/a4-a6,(a3)
	lea		40(a1),a1
	lea		40(a2),a2
	lea		40(a3),a3
	endr
	lea		240(a1),a1
	lea		240(a2),a2
	lea		240(a3),a3
	dbf		d7,_loadTcLoopMeta
	rts


	macro metaMove
	move.l	(a\1),d0
	cmp.l	#-1,d0
	bne.s	_noMetaTrackBack\@1
	sub.l	metaTrackSize\3,a\1
	move.l	(a\1),d0
_noMetaTrackBack\@1	
	add.l	d0,a\2
	lea		4(a\1),a\1
	endm
	
metaballsMain:
	bsr 	switchScreens

	lea 	metaballsAdr,a0
	movem.l	(a0),a1-a3
	lea		metaTrackPtr1,a0
	movem.l	(a0),a4-a6

	metaMove 4,1,1
	metaMove 5,2,2
	metaMove 6,3,3

	lea		metaTrackPtr1,a0
	movem.l	a4-a6,(a0)


	; display
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	lea 	metaballsColor,a4
	;lea 	metaballsAdr,a0
	;movem.l	(a0)+,a1-a3
	move.l	scr1,a0
	;lea		120*2(a0),a0
	;lea 	(320-METABALLS_SCR_H*2)*2/2(a0),a0
	
	lea	240(a0),a0
	
	move.l	#METABALLS_SCR_V-1,d6
_metaballsRgbLoop1
	move.l	#METABALLS_SCR_H/(5*2*2)-1,d7
_metaballsRgbLoop2
	rept 2
	movem.l	(a1)+,d0-d4
	metaballsInner 0
	metaballsInner 1
	metaballsInner 2
	metaballsInner 3
	metaballsInner 4
	endr
	dbf d7,_metaballsRgbLoop2
	lea	320*2-METABALLS_SCR_H*2*2(a0),a0

	lea	METABALLS_SCR_H*2(a1),a1
	lea	METABALLS_SCR_H*2(a2),a2
	lea	METABALLS_SCR_H*2(a3),a3
	dbf d6,_metaballsRgbLoop1		

	rts
	
; a1 - out
metaballsLoadTcPicture:
	lea		metaballsPic,a0
	move.l	scr1,a1
	move.l	scr2,a2
	move.l	scr3,a3

	;lea	400(a1),a1
	;lea	400(a2),a2
	;lea	400(a3),a3

	move.l	#100-1,d7
_metaballsLoadTcPictureYloop
	rept	6
	movem.l	(a0)+,d0-d6/a4-a6	;10r = 20px
	movem.l	d0-d6/a4-a6,(a1)
	movem.l	d0-d6/a4-a6,(a2)
	movem.l	d0-d6/a4-a6,(a3)
	lea	20*2(a1),a1
	lea	20*2(a2),a2
	lea	20*2(a3),a3
	endr
	
	lea	2*320-2*120(a1),a1
	lea	2*320-2*120(a2),a2
	lea	2*320-2*120(a3),a3

	dbf	d7,_metaballsLoadTcPictureYloop

	rts
	
		
	section data
	cnop 0,4
metaballsDensity 	incbin metaballs/density.dat
	cnop 0,4
					incbin metaballs/color.dat
metaballsColor	 	incbin metaballs/color.dat
	cnop 0,4
metaballsPic		incbin metaballs/pic.dat
	cnop 0,4
	include metaballs/track.s
	
	section bss
	even
metaballsAdr		ds.l	4	
metaTrackPtr1		dc.l	0
metaTrackPtr2		dc.l	0
metaTrackPtr3		dc.l	0
;metaballsPos		ds.w	4*2	
;metaballsAdv		ds.w	4*2	

	section text
