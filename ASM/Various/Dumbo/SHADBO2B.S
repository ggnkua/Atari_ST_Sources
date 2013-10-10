; Shadebob 16 couleurs - mode 16 couleurs
; Routine sous GFA BASIC
; By Dumbo - XXŠme siŠcle

; 0 : shadebob normal
; 1 : shadebob limit‚ (quand la couleur>15, couleur=15)
; 2 : shadebob d‚cr‚mental
; 3 : shadebob d‚cr‚mental limit‚

	
shade_i:	MACRO
shade_lig\@:
	move.l	a0,a2
	move.w	d0,d5
loopx\@:
	move.w	(a1)+,d4	; Masque dans d4
	move.w	d4,d3
	eor.w	d4,(a2)	; Additionne d4 et le plan 1 sur 1 bit
	move.w	(a2)+,d4	; R‚cupŠre d4
	IFNE	(\1&2)=0
	not.w	d4	; Si bits … 0, il peut y avoir des retenues
	ENDC
	and.w	d3,d4	; Ne garde que les retenues
	move.w	d4,d3	; Conserve les retenues dans d3
	eor.w	d4,(a2)	; Mot suivant, meme manip
	move.w	(a2)+,d4
	IFNE	(\1&2)=0
	not.w	d4
	ENDC
	and.w	d3,d4
	move.w	d4,d3
	eor.w	d4,(a2)
	move.w	(a2)+,d4
	IFNE	(\1&2)=0
	not.w	d4
	ENDC
	and.w	d3,d4
	IFNE	(\1&1)=0	; Shadebob normal
	eor.w	d4,(a2)+
	ELSE
	IFNE	(\1&1)=1	; Shadebob limit‚
	move.w	d4,d3
	eor.w	d4,(a2)
	move.w	(a2),d4
	IFNE	(\1&2)=0
	not.w	d4
	ENDC
	and.w	d3,d4
	IFNE	(\1&2)=0
	or.w	d4,(a2)
	or.w	d4,-(a2)
	or.w	d4,-(a2)
	or.w	d4,-(a2)
	ELSE
	eor.w	d4,(a2)
	eor.w	d4,-(a2)
	eor.w	d4,-(a2)
	eor.w	d4,-(a2)
	ENDC
	addq.l	#8,a2
	ENDC
	ENDC

	dbra	d5,loopx\@
	add.l	d6,a0
	dbra	d1,shade_lig\@

	rts
	ENDM



	TEXT

	move.l	4(sp),a0	; a0 = adresse affichage
	move.l	8(sp),a1	; a1 = adresse masque
	move.w	12(sp),d2	; d2 = type du bob
	move.w	14(sp),d0	; d0 = largeur/16
	move.w	16(sp),d1	; d1 = hauteur
	move.l	#160,d6
	subq.w	#1,d2
	beq	shade1
	subq.w	#1,d2
	beq	shade2
	subq.w	#1,d2
	beq	shade3
shade0:	shade_i	0
shade1:	shade_i	1
shade2:	shade_i	2
shade3:	shade_i	3
