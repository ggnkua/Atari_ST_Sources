	* Programme de points II par LITHIUM
	* Affichage de 1000 points,resultat en jaune
  
DEBUT

	CLR.L 	-(SP)		
	MOVE.W 	#$20,-(SP)	
	TRAP 	#1		
	ADDQ.L 	#6,SP	
	LEA	SAUVE,A0
	MOVE.L 	D0,(A0)	
	
	move.w	#0,-(sp)	
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp
	
	DC.W	$A00A		
	MOVE.B	#$12,$FFFFFC02.W	
	
	MOVE.L	#BUF_SCR,D0	
	ANDI.L	#$FFFFFF00,D0	
	ADD.L	#512,D0		
	LEA	ECRAN,A0
	MOVE.L	D0,(A0)
	
	MOVE.L	#BUF_SCR2,D0	
	ANDI.L	#$FFFFFF00,D0	
	ADD.L	#512,D0		
	LEA	ECRAN2,A0
	MOVE.L	D0,(A0)
	
	MOVEA.L	ECRAN,A0			CLEAR SCREEN AREA
	MOVE.W #7999,D0
CL	CLR.L (A0)+
	DBF D0,CL

	BSR	SAVESYSTEM
	
	LEA     VBL(PC),A0
	MOVE.L  A0,$70.W

	LEA     VBL(PC),A0
	MOVE.L  A0,$70.W

	MOVE.L  ECRAN,D0		SET PHYSBASE
	LSR.W 	#8,D0
	MOVE.L 	D0,$FFFF8200.W
		
	BSR	WAITVSYNC
	
	MOVEM.L	$FFFF8240.W,D0-D7
	MOVEM.L	D0-D7,SAVEPAL
		
	MOVE #$777,D7
fadedown	
	BSR	WAITVSYNC
	BSR	WAITVSYNC
	BSR	WAITVSYNC
	MOVE.W 	D7,$FFFF8240.W
	SUB.W 	#$111,D7
	BGE.S 	fadedown
		
	MOVEM.L	PALETTE,D0-D7
	MOVEM.L	D0-D7,$FFFF8240.W	
	
	BSR	precal_tble
	
	LEA     NEW_VBL(PC),A0
	MOVE.L  A0,$70.W
WAIT2
	JMP   WAIT2
END
SAVESYSTEM
	MOVE.L	$70.W,OLDVBL
	RTS
OLDSYSTEM
	MOVE.W	#$2700,SR
	MOVE.L	OLDVBL(PC),$70.W
	MOVE.W	#$2300,SR
	MOVE.W	#$777,$FFFF8240.W
	MOVE.W	#$000,$FFFF8242.W
	MOVE.W	#$000,$FFFF8244.W
	MOVE.W	#$000,$FFFF8246.W

	move.w	#1,-(sp)	
	move.l	#-1,-(sp)
	move.l	#-1,-(sp)
	move.w	#5,-(sp)
	trap	#14
	add.l	#12,sp

	RTS
; SPACES POUR LA SAUVGARDE DES REGISTRES         
OLDVBL:	DS.L	1
OLDHBL:	DS.L	1
OLDVMFP:DS.L	1
OLDTIMA:DS.L	1
OLDTIMB:DS.L	1
OLDTIMC:DS.L	1
OLDTIMD:DS.L	1
OLDKEYB:DS.L	1
OLDIERA:DS.B	1
OLDIERB:DS.B	1
OLDIMRA:DS.B	1
OLDIMRB:DS.B	1
OLDTACR:DS.B	1
OLDTBCR:DS.B	1
OLDTDCR:DS.B	1
OLDTADR:DS.B	1
OLDTBDR:DS.B	1
OLDTCDR:DS.B	1
OLDTDDR:DS.B	1
KBUFF	DC.W 	0
	EVEN
KEYVEC	
	MOVE.W 	D2,-(SP)
	MOVE.B	$FFFFFC00.W,D2
	BTST 	#7,D2
	BEQ.S 	VECTOREND
	MOVE.B 	$FFFFFC02.W,D2
	LEA	KBUFF(PC),A0
	MOVE.B 	D2,(A0)
	BCLR 	#6,$FFFFFA11.W
VECTOREND
	MOVE.W (SP)+,D2
	RTE
VBL
	ADDQ.W 	#1,VP			
	RTE

NEW_VBL
	MOVEM.L	D0-A6,-(SP)
	MOVE.L	ECRAN,LOGBASE
	MOVE.L  LOGBASE,D0		SET PHYSBASE
	LSR.W 	#8,D0
	MOVE.L 	D0,$FFFF8200.W
	JSR	clean_dots
	BSR	PLOT
	MOVE.L	#CLS_BUF2,BUF_DOTS
	MOVE.W	#$770,$FFFF8240.W
	NOP
	NOP
	NOP
	NOP
	MOVE.W	#$000,$FFFF8240.W
	MOVEM.L	(SP)+,D0-A6
	ADDQ.W 	#1,VP			
	MOVE.L	#NEW_VBL2,$70.W
	RTE
	
NEW_VBL2
	MOVEM.L	D0-A6,-(SP)
	MOVE.L	ECRAN2,LOGBASE
	MOVE.L  LOGBASE,D0		SET PHYSBASE
	LSR.W 	#8,D0
	MOVE.L 	D0,$FFFF8200.W
	JSR	clean_dots
	BSR	PLOT
	MOVE.W	#$770,$FFFF8240.W
	NOP
	NOP
	NOP
	NOP
	MOVE.W	#$000,$FFFF8240.W
	MOVE.L	#CLS_BUF,BUF_DOTS
	MOVEM.L	(SP)+,D0-A6
	ADDQ.W 	#1,VP			
	MOVE.L	#NEW_VBL,$70.W
	RTE
STOP_TIMER
	RTE
		
WAITVSYNC
	MOVE.W 	VP,D0	
LO	CMP.W 	VP,D0
	BEQ.S 	LO
	RTS

	SECTION	BSS
ECRAN	DS.L 	1		
ECRAN2	DS.L 	1		
SAUVE	DS.L	1
ANC_ECR	DS.L	1
ANC_VCOUNTHI
	DS.B	1
ANC_VCOUNTMI
	DS.B	1
ANC_VCOUNTVO
	DS.B	1
ANC_VCOUNTLO
	DS.B	1
ANC_VCOUNTHO
	DS.B	1
RES	DS.W	1	
SAVEPAL	DS.L	16
BUF_SCR	
	DS.B	32512
BUF_SCR2
	DS.B	32512
	SECTION	DATA
LOGBASE
	DC.L	0
	EVEN
PALETTE	
	dc.w	$0000,$0007,$0600,$0500,$0400,$0300,$0200,$0100
	dc.w	$0007,$0533,$0622,$0333,$0444,$0555,$0666,$0700
	EVEN
VP	DC.W 	0
	EVEN
	SECTION	TEXT
precal_tble
	
	lea	CLS_BUF,a0
	movea.l	ECRAN,a1
	move.w	#(2400*8)/4-1,d0
dlk
	move.l	(a1)+,(a0)+
	dbf	d0,dlk	
	
	lea	tableau,a0
	moveq	#0,d0
	move.w	#199,d1
turlututu
	move.w	d0,(a0)+
	add.w	#160,d0
	dbra	d1,turlututu
	rts
*
*	Partie interressante du programme
*

PLOT:
	lea	tableau,a0		* A retirer du BSR pour optimisation
	lea	precalc,a2
	movea.l	BUF_DOTS,a6
	move.w	#1000,d7
blop
	move.w	#200,d0			* X		
	move.w	#150,d2			* Y
	movea.l LOGBASE,a1           	* Adresse ecran dans a1
	add.w	0(a0,d2.w*2),a1
	move.w	d0,d1
	lsr.w	d1
	and.w	#248,d1
	add.w	d1,a1
	and.w	#15,d0
	move.w	0(a2,d0.w*2),d1
	or.w	d1,(a1)
	move.l	(a1),(a6)+
	dbra	d7,blop
	rts
clean_dots
	moveq	#0,d0
	movea.l	BUF_DOTS,a1
	rept	1000
	move.w	d0,a1
	endr
	rts
* Data pour la routine de points

pointx	dc.l	0
flag	dc.b	0
	even

* Bss pour la table de mul
tableau	
	ds.w	200
precalc
	dc.w	%1000000000000000
	dc.w	%0100000000000000
	dc.w	%0010000000000000
	dc.w	%0001000000000000
	dc.w	%0000100000000000
	dc.w	%0000010000000000
	dc.w	%0000001000000000
	dc.w	%0000000100000000
	dc.w	%0000000010000000
	dc.w	%0000000001000000
	dc.w	%0000000000100000
	dc.w	%0000000000010000
	dc.w	%0000000000001000
	dc.w	%0000000000000100
	dc.w	%0000000000000010
	dc.w	%0000000000000001
	dc.w	%0000000000000000
	even
BUF_DOTS
	dc.l	CLS_BUF
	even
CLS_BUF
	ds.b	1200*8
CLS_BUF2
	ds.b	1200*8
	