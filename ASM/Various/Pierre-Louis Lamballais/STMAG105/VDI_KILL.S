* VDI Killer...
* Fait planter la machine lors d'un appel VDI pr‚d‚fini
* afin de se retrouver sous le d‚bugger pour v‚rifier les donn‚es...

DEPART:	bra	START		PRG r‚sident donc tˆte en bas!

ANC_TRAP:	
	DC.L	0
NEW_TRAP:	
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
	ILLEGAL
JMP_OLD    
	movea.l	ANC_TRAP(pc),a0 prend ancienne routine GEM
	jmp	(a0)		et nous y allons!
*-----------------------------------------------------------------------*
START:	movea.l	a7,a5
	movea.l	4(a5),a5
       	move.l	$C(a5),d0
	add.l	$14(a5),d0
	add.l	$1C(a5),d0
	add.l	#$500,d0
	move.l	d0,d1
	add.l	a5,d1
	and.l	#$FFFFFFFE,D1 
	movea.l	d1,sp
	move.l	d0,-(sp)
	move.l	a5,-(sp)
	clr.w	-(sp)
	move.w	#$4A,-(sp)
	trap	#1
	adda.l	#12,sp

* Place notre routine  (appel en superviseur)
	move.l	#PUT_TRAP_2,-(sp)
	move.w	#38,-(sp)	Supexec()
	trap	#14		du Xbios
	addq.l	#6,sp
	
* Et nous quittons en restant r‚sidant...
	clr.w	-(sp)
	move.l	#START,d0
	sub.l	#DEPART,d0
	add.l	#256,d0
	move.l	d0,-(sp)
	move.w	#49,-(sp)
	trap	#1
*-----------------------------------------------------------------*
* Nous mettons notre routine en TRAP #2
PUT_TRAP_2:
	move.l	$88,ANC_TRAP
	move.l	#NEW_TRAP,$88
	rts
*-----------------------------------------------------------------*
	END
	