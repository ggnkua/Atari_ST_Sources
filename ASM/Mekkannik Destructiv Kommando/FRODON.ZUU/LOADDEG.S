  clr.l -(a7)
	move.w #$20,-(a7)
	trap #01
	addq.l #6,a7
	
	lea fich,a0
	move.l screen,a1
	sub.l #34,a1
	move.l #32034,d2
	jsr loader
loader	move.w #2,-(a7)   ouverture
	move.l a0,-(a7)
	move.w #$3d,-(a7)
	trap #01
	lea 8(a7),a7

	move.w d0,d1     handler du fichier

	move.l a1,-(a7)  lecture
	move.l d2,-(a7)
	move.w d1,-(a7)
	move.w #$3f,-(a7)
	trap #01
	lea 12(a7),a7

	move.w d1,-(a7)    fermeture
	move.w #$3e,-(a7)
	trap #01
	addq.l #4,a7

	move.w #$20,-(a7)
	trap #01
	addq.l #6,a7
          move.w #7,-(a7)
          trap   #1
          addq.l #2,-(a7)
          move.w #0,-(a7)
          trap   #1
fich	dc.b '\frodon.zuu\domi.pi1',0
screen		dc.l $38000
