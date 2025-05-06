******************************************************
*                                                    *
*     CORRECTION BUG V_FILLAREA SUR FALCON 030       *
*                                                    *
*              PARX-1996 / Pour ST MAG               *
*                                                    *
******************************************************

* Source de base. Voir l'article pour compl‚ments.

** Zone restant r‚sidente **
DEPART:	bra	START
	dc.b	"XBRA"
	dc.b	"VFIL"
ANC_TRAP	
	dc.l	0
NEW_TRAP
	cmpi.w	#$73,d0		appel VDI?
	bne.s	JMP_OLD		non => bye bye
	movea.l	d1,a0		tableau VDI_PARM_BLK
	movea.l	(a0),a0		adresse CONTROL
	cmpi.w	#$67,(a0)	opcode V_fill_area?
	bne.s	JMP_OLD		non => bye bye
	movea.l	d1,a0		reprend VDI_PARM_BLK
	movea.l	4(a0),a0	tableau Intin
	cmpi.w	#$FFFF,(a0)	remplissage jusqu'… couleur <> ?
	bne.s	JMP_OLD		non => bye bye
	move.l	#NEW_TRACE,$24	place notre routine en TRACE
	ori	#$8000,sr	active mode TRACE dans le ST
JMP_OLD:
	movea.l	ANC_TRAP(pc),a0	et continue l'appel VDI...
	jmp	(a0)
*------------------------------------------------------------*
* Notre routine de TRACE. Elle est plac‚e dans le vecteur
* $24 lors de l'appel … V_fill_area()
NEW_TRACE:
	movem.l	d0/a0,-(a7)
	move.l	$10(a7),d0	prend le PC sur la pile
	cmp.l	#$E0FD04,d0	on est au point critique?
	bne.s	OUT_TRACE	non...
* Nous avons d‚pass‚ la zone buggu‚e, nous devons donc
* corriger la valeur en m‚moire...
	move.w	$1CF4,$1CF2
OUT_TRACE:	
	movem.l	(a7)+,d0/a0
	rte
*--------------------------------------------------*
* D‚but du programme. Le d‚but est … la fin du code car
* compte tenu de l'appel Ptermres() on ne garde une
* partie r‚sident qu'au d‚but du code. Donc la partie
* d'init d'un PRG r‚sident est … la fin, afin de ne pas
* ˆtre conserv‚e en RAM.
START:	movea.l	a7,a5
	movea.l	4(a5),a5
	move.l	$C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	addi.l	#$500,d0
	move.l	d0,d1
	add.l	a5,d1
	andi.l	#$FFFFFFFE,d1
	movea.l	d1,a7
	move.l	d0,-(a7)
	move.l	a5,-(a7)
	clr.w	-(a7)
	move.w	#$4A,-(a7)	Mshrink()
	trap	#1
	adda.l	#12,a7

* Nous pla‡ons notre vecteur en TRAP #2
	move.l	#PUT_TRAP_2,-(sp)
	move.w	#38,-(sp)
	trap	#14
	addq.l	#6,sp
	
* Et nous quittons en restant r‚sident...	
	move.l	#START,d0
	subi.l	#DEPART,d0
	addi.l	#$100,d0
	mods.l	d0,-(a7)
	move.w	#$31,-(a7)
	trap	#1
*------------------------------------------------------*
* Mise en place de notre nouvelle routine en TRAP #2
PUT_TRAP_2:
	move.l	$88,ANC_TRAP
	move.l	#NEW_TRAP,$88
	rts
*------------------------------------------------------*
