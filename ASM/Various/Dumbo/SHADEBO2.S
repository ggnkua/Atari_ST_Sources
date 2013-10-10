; Shadebob 16 couleurs - mode 16 couleurs
; By Dumbo - XXŠme siŠcle

; 1 : shadebob normal
; 2 : shadebob limit‚ (quand la couleur>15, couleur=15)
version:	EQU	1


wait_key:	MACRO
	movem.l	d0-a6,-(sp)
	move.w	#7,-(sp)
	trap	#1
	addq.l	#2,sp
	movem.l	(sp)+,d0-a6
	ENDM


	TEXT

	move.w	#3,-(sp)
	trap	#14
	move.l	d0,ecrlog
	clr.w	(sp)
	move.l	d0,-(sp)
	move.l	d0,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	move.w	#1000,d7
loooop:
	moveq	#3,d0	; 4*16 pixels de large
	moveq	#63,d1	; 64 de haut
	move.l	ecrlog(pc),a0	; a0 = Adresse affichage
	lea.l	masque(pc),a1	; a1 = adresse du masque

shade:
	move.l	#160,d6
shade_lig:
	move.l	a0,a2
	move.w	d0,d5
loopx:
	move.w	(a1)+,d4	; Masque dans d4
	move.w	d4,d3
	eor.w	d4,(a2)	; Additionne d4 et le plan 1 sur 1 bit
	move.w	(a2)+,d4	; R‚cupŠre d4
	not.w	d4	; Si bits … 0, il peut y avoir des retenues
	and.w	d3,d4	; Ne garde que les retenues
	move.w	d4,d3	; Conserve les retenues dans d3
	eor.w	d4,(a2)	; Mot suivant, meme manip
	move.w	(a2)+,d4
	not.w	d4
	and.w	d3,d4
	move.w	d4,d3
	eor.w	d4,(a2)
	move.w	(a2)+,d4
	not.w	d4
	and.w	d3,d4

	IFNE	version=1	; Shadebob normal
	eor.w	d4,(a2)+
	ELSE
	IFNE	version=2	; Shadebob limit‚
	move.w	d4,d3
	eor.w	d4,(a2)
	move.w	(a2),d4
	not.w	d4
	and.w	d3,d4
	or.w	d4,(a2)
	or.w	d4,-(a2)
	or.w	d4,-(a2)
	or.w	d4,-(a2)
	addq.l	#8,a2
	ENDC
	ENDC

	dbra	d5,loopx
	add.l	d6,a0
	dbra	d1,shade_lig

;	wait_key
	dbra	d7,loooop

	clr.w	-(sp)
	trap	#1


ecrlog:	dc.l	1
masque:	dcb.w	256,65535
