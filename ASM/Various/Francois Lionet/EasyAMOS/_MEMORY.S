;-----------------------------------------------------------------
; **** *** **** ****
; *     *  *  * *	******************************************
; ****  *  *  * ****	* MEMOIRE / BANQUES
;    *  *  *  *    *	******************************************
; ****  *  **** ****
;-----------------------------------------------------------------

*************** Entetes des banques
BkBob:		dc.b "Bobs    "
BkSpr:		dc.b "Sprites "
BkIco:		dc.b "Icons   "
BkMus:		dc.b "Music   "
BkAmal:		dc.b "Amal    "
BkMenu:		dc.b "Menu    "
BkDat:		dc.b "Datas   "
BkWrk:		dc.b "Work    "
BkAsm:		dc.b "Asm     "
BkSt:		dc.b "S"
BkLn:		dc.b "L"
		even

***********************************************************
*	EFFACEMENT DE LA BANQUE D3
EffBank:
*********
	movem.l	d0-d7/a0-a2,-(sp)
	move.l	ABanks(a5),a2
	lsl.w	#3,d3
	add.w	d3,a2
	move.l	(a2),d0
	beq	EffBx
	move.l	d0,a1
	move.l	(a1),d0
	cmp.l	BkSpr(pc),d0
	beq	EfBSp
	cmp.l	BkIco(pc),d0
	beq	EfBSp

******* Banque normale!
	clr.l	(a2)+
	move.l	(a2),d0
	clr.l	(a2)+
* Appelle les extensions
	bsr	BkChange
* Efface la memoire
	and.l	#$0FFFFFFF,d0
	bsr	RamFree
	bra	EffBx

******* Banque de sprites
EfBSp:	clr.l	(a2)+			* Plus de banque!
	clr.l	(a2)+
	move.l	a1,a2
	move.l	a2,-(sp)
	lea	8(a2),a2		* Saute le nom!
	move.w	(a2)+,d7
* Efface les sprites
	clr.w	d6
EfB1	bsr	EfPointe		* Efface le Sprite/Icon
	addq.l	#8,a2
	addq.w	#1,d6
	cmp.w	d7,d6
	bcs.s	EfB1
* Efface les pointeurs
	move.w	d7,d0
	ext.l	d0
	lsl.w	#3,d0
	add.w	#10+64,d0
	move.l	(sp)+,a1
	bsr	RamFree
	bra	EffBx
******* Fin de l'effacement des banques
EffBx:	movem.l	(sp)+,d0-d7/a0-a2
	rts

******* ROUTINE: efface une definition pointee par A2
EfPointe
	move.l	(a2),d1		* Efface le SPRITE
	beq.s	EfPo1
	move.l	d1,a1
	move.w	(a1),d0
	mulu	2(a1),d0
	lsl.l	#1,d0
	mulu	4(a1),d0
	add.l	#10,d0
	bsr	RamFree
EfPo1:	move.l	4(a2),d1	* Efface le MASQUE
	ble.s	EfPo2
	move.l	d1,a1
	move.l	(a1),d0
	bsr	RamFree
EfPo2	clr.l	(a2)
	clr.l	4(a2)
	rts

***********************************************************
*	EFFACEMENT DE TOUTES LES BANQUES temporaires
EffBanks:
********
	moveq	#0,d3
	move.l	ABanks(a5),a2
EfBks1:	move.l	(a2)+,d0
	move.l	(a2)+,d1
	bmi.s	EfBks2
	tst.l	d0
	beq.s	EfBks2
	bsr	EffBank
EfBks2:	addq.w	#1,d3
	cmp.w	#16,d3
	bcs.s	EfBks1
	bra	SendBanks

***********************************************************
*	EFFACEMENT DE TOUTES LES BANQUES
EffAllBanks:
********
	moveq	#15,d3
EABks:	bsr	EffBank
	dbra	d3,EABks
	bra	SendBanks

***********************************************************
*	ERASE n
Erase:
*******
	bsr	Expentier
	subq.l	#1,d3
	cmp.l	#15,d3
	bhi	FonCall
	bsr	EffBank
	bsr	SendBanks
	bra	InsRet

***********************************************************
*	ENVOIE LES ADRESSES DES BANQUES AUX TRAPPES
SendBanks:
*******
	movem.l	a0-a3/d0-d7,-(sp)
* Appelle les extensions
	bsr	BkChange
* Explore toutes les banques
	moveq	#15,d2
	move.l	ABanks(a5),a2
	moveq	#0,d7
SBk1:	move.l	(a2),d0
	beq.s	SBkN
	move.l	d0,a1
	move.l	(a1),d0
	cmp.l	BkSpr(pc),d0
	beq.s	SBkS
SBkN:	addq.l	#8,a2
	dbra	d2,SBk1
* Arrete tout ce qui n'a pas ete vu!
	btst	#0,d7
	bne.s	SBk3
	sub.l	a1,a1
	SyCall	SetSpBank
SBk3:	movem.l	(sp)+,a0-a3/d0-d7
	rts
******* Banque de sprites presente, en 1!!!
SBkS:	cmp.w	#15,d2
	bne.s	SBkN
	lea	8(a1),a1
	SyCall	SetSpBank
	bset	#0,d7
	bra.s	SBkN

******* EXTENSIONS: changement d'adresses de banques!
BkChange
	movem.l	a0-a3/d0-d7,-(sp)
	lea	ExtAdr(a5),a0
	moveq	#26-1,d0
BkCh1:	move.l	12(a0),d1
	beq.s	BkCh2
	move.l	d1,a1
	movem.l	a0/d0,-(sp)
	move.l	d1,a1
	move.l	ABanks(a5),a0
	jsr	(a1)
	movem.l	(sp)+,a0/d0
BkCh2	lea	16(a0),a0
	dbra	d0,BkCh1
	movem.l	(sp)+,a0-a3/d0-d7
	rts

***********************************************************
*	RESERVATION DE LA BANQUE DE SPRITES ou ICONES
*	D0= Effacer ou non?
*	D1= Sprite maximum a reserver!
*	Retour: A1= Debut banque / A2= Descripteur sprite/icone
ResIco:	movem.l	d2-d7/a3/a4,-(sp)
	move.l	ABanks(a5),a3
	lea	8(a3),a3
	lea	BkIco(pc),a4
	moveq	#1,d7
	bra.s	ResSi
ResSpr:	movem.l	d2-d7/a3/a4,-(sp)
	move.l	ABanks(a5),a3
	lea	BkSpr(pc),a4
	moveq	#0,d7
ResSi
******* Taille de la table de pointeurs
	ext.l	d1
	move.l	d1,d2
	lsl.w	#3,d2
	add.w	#10+64,d2
******* Va effacer
	tst.w	d0	
	beq.s	ResS1
ResS0:	move.l	d7,d3
	bsr	EffBank
******* Reserve!
ResS1:	move.l	(a3),d0
	beq.s	ResS2
	move.l	d0,a0
	move.l	(a0),d0
	cmp.l	(a4),d0
	bne.s	ResS0
	beq.s	ResS3
* Reserve pour D1 sprites/icons!
ResS2:	move.l	d2,d0
	bsr	RamFast
	beq	ResSE
	move.l	d0,a0
	move.l	(a4),(a0)
	move.l	4(a4),4(a0)
	move.w	d1,8(a0)
	move.l	a0,(a3)
	move.l	d1,4(a3)
	addq.l	#8,4(a3)
	or.b	#%11000000,4(a3)
* Recopie la palette courante!
	move.w	d1,d3
	lsl.w	#3,d3
	lea	10(a0,d3.w),a2
	move.l	ScOnAd(a5),d2
	beq.s	ResS3
	move.l	d2,a1
	lea	EcPal(a1),a1
	moveq	#32-1,d3
ResS2a:	move.w	(a1)+,(a2)+
	dbra	d3,ResS2a
******* Change la banque?
ResS3:	cmp.w	8(a0),d1
	bls.s	ResS5
* Re-Reserve la memoire!
	move.l	d2,d0
	bsr	RamFast
	beq	ResSE
	move.l	d0,a1
	move.l	d0,(a3)
	move.l	d1,4(a3)
	addq.l	#8,4(a3)
	or.b	#%11000000,4(a3)
	move.l	a0,-(sp)
* Recopie la l'ancienne
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.w	d1,(a1)+
	move.w	(a0)+,d3
	subq.w	#1,d3
ResS4:	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbra	d3,ResS4
	move.l	d0,a1
	lea	-64(a1,d2.l),a1
	moveq	#32-1,d3
ResS4a:	move.w	(a0)+,(a1)+
	dbra	d3,ResS4a
* Efface l'ancienne
	move.l	(sp),a1
	move.l	d0,(sp)
	move.w	8(a1),d0
	ext.l	d0
	lsl.w	#3,d0
	add.w	#10+64,d0
	bsr	RamFree
	move.l	(sp)+,a0
******* Change l'adresse de la banque de sprites (si banque de sp)
ResS5	lea	8(a0),a1
	lsl.w	#3,d1
	lea	-8+2(a1,d1.w),a2
	tst.w	d7
	bne.s	ResS6
	SyCall	SetSpBank
ResS6	movem.l	(sp)+,d2-d7/a3/a4
	moveq	#0,d0
	rts
******* Erreur!
ResSE	sub.l	a1,a1
	tst.w	d7
	bne.s	ResS7
	SyCall	SetSpBank
ResS7	movem.l	(sp)+,d2-d7/a3/a4
	moveq	#1,d0
	rts

***********************************************************
*	INS BOB / INS SPRITE / INS ICON n
IISpr	bsr	Par1
	clr.w	-(sp)
	move.l	ABanks(a5),-(sp)
	move.l	BkSpr(pc),d0
* Routine!
RIIS	move.l	(a3)+,d3
	bls	FonCall
	move.l	(sp),a1
	move.l	(a1),d1
	beq	BkNoRes
	move.l	d1,a1
	cmp.l	(a1),d0
	bne	BkNoRes
	addq.l	#8,a1
	move.w	(a1),d2
	addq.w	#1,d2
	ext.l	d2
	move.l	d2,d1
	lsl.l	#3,d1
	moveq	#10+64,d0
	add.l	d1,d0
	bsr	RamFast
	beq	OOfMem
	move.l	(sp),a0
	move.l	d0,(a0)
	addq.w	#1,4+2(a0)
* Recopie
	move.l	d0,a2
	move.l	-8(a1),(a2)+
	move.l	-4(a1),(a2)+
	lea	2(a1),a0
	move.w	d2,(a2)+
	moveq	#0,d4
	subq.w	#1,d3
	cmp.w	d2,d3
	bls.s	RIIs1
	move.w	d2,d3
	subq.w	#1,d3
RIIs1	cmp.w	d3,d4
	beq.s	RIIs2
	move.l	(a0)+,(a2)
	move.l	(a0)+,4(a2)
RIIs2	addq.l	#8,a2
	addq.w	#1,d4
	cmp.w	d4,d2
	bne.s	RIIs1
	moveq	#31,d0
RIIs3	move.w	(a0)+,(a2)+
	dbra	d0,RIIs3
* Va finir
	bra	DSI8

******* DEL SPRITE/BOB n TO n
IDSp1	bsr	Par1
	move.l	(a3),-(a3)
	bra.s	IDSp
IDSp2	bsr	Par2
IDSp	clr.w	-(sp)
	move.l	BkSpr(pc),d0
	move.l	ABanks(a5),-(sp)
DSpIc:	move.l	(sp),a0
	tst.l	(a0)
	beq	BkNoRes
	move.l	(a0),a1
	cmp.l	(a1),d0
	bne	BkNoRes
	lea	8(a1),a1
	move.l	(a3)+,d3
	ble	FonCall
	cmp.w	(a1),d3
	bcs.s	DSI1
	move.w	(a1),d3
DSI1	move.l	(a3)+,d2
	ble	FonCall
	cmp.w	d3,d2
	bhi	FonCall
* Efface les donnees!
DSI2	move.w	d2,d1
	lsl.w	#3,d1
	lea	-8+2(a1,d1.w),a2
	movem.l	d2-d3/a1-a2,-(sp)
	bsr	EfPointe
	movem.l	(sp)+,d2-d3/a1-a2
	addq.w	#1,d2
	cmp.w	d3,d2
	bls.s	DSI2
* Compte le nombre d'images
	moveq	#0,d2
	move.l	a1,a0
	move.w	(a0)+,d0
	subq.w	#1,d0
DSI3	tst.l	(a0)
	beq.s	DSI4
	addq.w	#1,d2
DSI4	addq.l	#8,a0
	dbra	d0,DSI3
* Reduit!
	move.l	d2,d1
	beq	DSIEra
	lsl.l	#3,d1
	moveq	#10+64,d0		* Reserve la nouvelle ram
	add.l	d1,d0
	bsr	RamFast
	beq	OOfMem
	move.l	(sp),a2			* Change la banque
	move.l	d0,(a2)
	move.l	d2,d4
	addq.l	#8,d4
	bset	#31,d4
	bset	#30,d4
	move.l	d4,4(a2)
	move.l	d0,a0			* Entete
	move.l	-8(a1),(a0)+
	move.l	-4(a1),(a0)+
	move.w	d2,(a0)+
	move.l	a1,a2			* Pointeurs
	move.w	(a2)+,d0
	subq.w	#1,d0
DSI5	tst.l	(a2)
	beq.s	DSI6
	move.l	(a2),(a0)+
	move.l	4(a2),(a0)+
DSI6	addq.l	#8,a2
	dbra	d0,DSI5
	moveq	#31,d0			* Palette
DSI7	move.w	(a2)+,(a0)+
	dbra	d0,DSI7
* Efface l'ancienne banque
DSI8	move.w	(a1),d0
	lsl.w	#3,d0
	add.w	#10+64,d0
	ext.l	d0
	subq.l	#8,a1
	bsr	RamFree
* Ca y est---> change la banque...
	move.l	(sp)+,a0
	tst.w	(sp)+
	bne	InsRet
	move.l	(a0),a1
	addq.l	#8,a1
	SyCall	SetSpBank
	bra	InsRet
******* Erase bank!
DSIEra	addq.l	#4,sp
	moveq	#0,d3
	move.w	(sp)+,d3
	bsr	EffBank
	bra	InsRet

***********************************************************
*	RESERVE AS ...

******* RESERVE AS WORK n,l
RsWrk:	pea	BkWrk(pc)
	clr.w	-(sp)
	clr.w	-(sp)
	bsr	RsBq
	bra.s	RsBqX
******* RESERVE AS CHIP WORK n,l
RsCWrk:	pea	BkWrk(pc)
	clr.w	-(sp)
	move.w	#-1,-(sp)
	bsr	RsBq
	bra.s	RsBqX
******* RESERVE AS DATA n,l
RsDat:	pea	BkDat(pc)
	move.w	#-1,-(sp)
	clr.w	-(sp)
	bsr	RsBq
	bra.s	RsBqx
******* RESERVE AS CHIP DATA n,l
RsCDat:	pea	BkDat(pc)
	move.w	#-1,-(sp)
	move.w	#-1,-(sp)
	bsr	RsBq
RsBqX	lea	8(sp),sp
	bra	InsRet
* Reserve!
RsBq:	bsr	Par2
RsBq0:	move.l	(a3)+,d0
	bmi	FonCall
	addq.l	#1,d0
	and.l	#$0FFFFFFE,d0
	addq.l	#8,d0			* Plus le nom!
	move.l	d0,d2
	tst.w	4+2(sp)
	beq.s	RsBk1
	bset	#31,d2
RsBk1:	move.l	(a3)+,d3
	subq.l	#1,d3
	cmp.l	#15,d3
	bhi	FonCall
	lsl.w	#3,d3
	move.l	ABanks(a5),a2
	add.w	d3,a2
	tst.l	(a2)			* Already reserved?
	bne	BkAlRes
	lea	RamFast(pc),a0
	tst.w	4+0(sp)
	beq.s	RsBk1a
	lea	RamChip(pc),a0
	bset	#30,d2
RsBk1a	jsr	(a0)
	beq	OOfMem
	move.l	d0,(a2)+
	move.l	d2,(a2)+
* Copie l'entete
	move.l	d0,a1
	move.l	4+4(sp),a0
	moveq	#7,d0
RsBk2:	move.b	(a0)+,(a1)+
	dbra	d0,RsBk2
	rts

***********************************************************
*	START / LENGTH

******* =START(n)
FnSt:	bsr	FnExpE
	bsr	BkAd
	move.l	a0,d3
	moveq	#0,d2
	bra	OpeRet
******* =LENGTH(n)
FnLn:	bsr	FnExpE
	subq.l	#1,d3
	cmp.l	#15,d3
	bhi	FonCall
	lsl.w	#3,d3
	move.l	ABanks(a5),a0
	moveq	#0,d2
	move.l	4(a0,d3.w),d3
	beq.s	FnLn1
	and.l	#$0FFFFFFF,d3
	subq.l	#8,d3
FnLn1:	bra	OpeRet
	
******* Ramene l'adresse d'une banque / D3-> A0
BkAd:	subq.l	#1,d3
	cmp.l	#15,d3
	bhi	FonCall
	lsl.w	#3,d3
	move.l	ABanks(a5),a2
	lea	0(a2,d3.w),a2
	move.l	(a2),a0
	addq.l	#8,a0
	move.l	4(a2),d0
	beq	BkNoRes
	and.l	#$0FFFFFFF,d0
	subq.l	#8,d0
	rts
******* Adoubank (a3) ---> D3
AdOuBank:
	move.l	(a3)+,d3
	beq.s	AdOu1
	cmp.l	#16,d3
	bhi.s	AdOu1
	lsl.w	#3,d3
	move.l	ABanks(a5),a2
	lea	-8(a2,d3.w),a2
	move.l	(a2),d3
	beq	BkNoRes
	addq.l	#8,d3
AdOu1:	rts

******* Ramene l'adresse du BOB D1 -> A2
*	D7-> Nb total de sprites
AdBob	move.l	ABanks(a5),a0
	move.l	(a0),d0
	beq.s	AdBE1
	move.l	d0,a2
	move.l	(a2),d0
	cmp.l	BkSpr(pc),d0
	bne.s	AdBE1
	addq.l	#8,a2
	move.w	(a2),d7
	and.w	#$3FFF,d1
	beq	FonCall
	cmp.w	d7,d1
	bhi.s	AdBE2
	lsl.w	#3,d1
	lea	-8+2(a2,d1.w),a2
	moveq	#0,d0
	rts
AdBE1	moveq	#36,d0
	rts
AdBE2	moveq	#EcEBase+24-1,d0
	rts
AdBE3	moveq	#EcEBase+30-1,d0
	rts

***********************************************************
*	FREE FAST/CHIP

******* =CHIP FREE
FChip:	move.l	#Chip,d1
	bra.s	FFree
******* =FAST FREE
FFast:	move.l	#Fast,d1
FFree:	movem.l	a3-a6,-(sp)
	ExeCall	AvailMem
	movem.l	(sp)+,a3-a6
	move.l	d0,d3
	moveq	#0,d2
	bra	OpeRet

***********************************************************
*	TRANSFERTS MEMOIRE

; TRANSFERT DE MEMOIRE a0/pair->a1/pair, d0 (pair) octets
transmem: 
	move.w 	d0,d1

	move.w	a0,d2
	btst	#0,d2
	bne.s	trimp
	move.w	a1,d2
	btst	#0,d2
	bne.s	trimp
	btst	#0,d0
	bne.s	trimp

* Copy rapide
	and.w	#$0F,d1
        cmp.l 	a0,a1
        bcs.s 	trsmm
; a1>a0: remonter le programme
        add.l 	d0,a0
        add.l 	d0,a1
        movem.l a0/a1,-(sp)
        lsr.l 	#4,d0         ;nombre de mots longs
        beq.s 	trsmm2
trsmm1: move.l 	-(a0),-(a1)
	move.l 	-(a0),-(a1)
	move.l 	-(a0),-(a1)
	move.l 	-(a0),-(a1)  ;transfert mots longs
	subq.l	#1,d0
	bne.s	trsmm1
trsmm2: subq.w 	#1,d1
        bmi.s 	trsmm3b
trsmm3: move.b 	-(a0),-(a1)  ;transfert octets
	dbra	d1,trsmm3
trsmm3b:movem.l	(sp)+,a0/a1 ;pointe la fin des zones
        rts
; a0<a1: descendre le programme
trsmm:  lsr.l 	#4,d0
        beq.s 	trsmm5
trsmm4: move.l 	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	trsmm4
trsmm5: subq.w	#1,d1
        bmi.s 	trsmm7
trsmm6: move.b 	(a0)+,(a1)+
	dbra	d1,trsmm6
trsmm7: rts

* Copie lente
trimp	and.w	#$03,d1
	cmp.l 	a0,a1
        bcs.s 	triup
; a1>a0: remonter le programme
        add.l 	d0,a0
        add.l 	d0,a1
        movem.l a0/a1,-(sp)
        lsr.l 	#2,d0 
        beq.s 	trsmm2
.trsmm1 move.b 	-(a0),-(a1)
	move.b 	-(a0),-(a1)
	move.b 	-(a0),-(a1)
	move.b 	-(a0),-(a1)
	subq.l	#1,d0
	bne.s	.trsmm1
.trsmm2 subq.w 	#1,d1
        bmi.s 	.trsmm3b
.trsmm3 move.b 	-(a0),-(a1)
	dbra	d1,.trsmm3
.trsmm3b
	movem.l	(sp)+,a0/a1
        rts
; Vers le bas
triup	lsr.l 	#2,d0
        beq.s 	.trsmm5
.trsmm4 move.b 	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+
	subq.l	#1,d0
	bne.s	.trsmm4
.trsmm5 subq.w	#1,d1
        bmi.s 	.trsmm7
.trsmm6 move.b 	(a0)+,(a1)+
	dbra	d1,.trsmm6
.trsmm7 rts

; COPY depart(inclus),fin(exclue) TO arrivee: COPIE DE PLAGES MEMOIRE
Icopy:	moveq	#3,d0
	bsr	ParD0
	move.l	(a3)+,a1
	move.l	(a3)+,d0
	move.l	(a3)+,a0
	sub.l	a0,d0
	bls	FonCall
	bsr	TransMem
	bra	InsRet

; FILL depart(inclus) TO fin(exclue), mot long: REMPLI DES PLAGES MEMOIRE
Ifill: 	moveq	#3,d0
	bsr	ParD0
	move.l	(a3)+,d4
	move.l	(a3)+,d2
	bsr	Adoubank
	move.l	d3,a0
fillbis sub.l 	a0,d2
        bcs 	foncall
        move.w 	d2,d1
        lsr.l 	#4,d2         	;travaille par mot long
        beq.s 	fil2
	subq.w	#1,d2
fil1:   move.l 	d4,(a0)+
	move.l	d4,(a0)+
	move.l	d4,(a0)+
	move.l	d4,(a0)+
	dbra	d2,fil1
fil2:   and 	#$000F,d1
        beq.s 	fil4
	subq.w	#1,d1
fil3:   rol.l 	#8,d4
        move.b 	d4,(a0)+
	dbra	d1,fil3
fil4:   bra	InsRet

; HUNT (depart TO fin,chaine$): RAMENE L'ADRESSE D'UNE CHAINE DANS LA MEMOIRE!
FHunt: 	moveq	#3,d0
	bsr	FnParD0
	move.l	(a3)+,a2
	move.w	(a2)+,d2
	bsr	ChVerBuf	
        move.l 	(a3)+,d7     	;adresse de fin
	bsr	AdOuBank
	move.l	d3,a0		;adresse de recherche
        subq.w	#1,d2
        bcs.s 	ht3           	;si chaine nulle: ramene zero!
        move.l 	Buffer(a5),d6
        subq.l 	#1,a0
ht1:    addq.l 	#1,a0        ;passe a l'octet suivant
        move.l 	a0,a1
        cmp.l 	d7,a0         ;pas trouve!
        bcc.s 	ht3
        move.l 	d6,a2        ;pointe la chaine recherchee
        move.w 	d2,d1
ht2:    cmpm.b 	(a2)+,(a1)+
        bne.s 	ht1
        dbra 	d1,ht2
        move.l 	a0,d3        ;TROUVE!
        moveq	#0,d2
        bra	OpeRet
ht3:    moveq	#0,d3
        moveq	#0,d2
       	bra	OpeRet
	
***********************************************************
*	LISTBANK
LBank:
*******
	moveq	#0,d3
LBk1:	bsr	LlBank
	beq.s	LBk2
	move.b	#13,(a1)+
	move.b	#10,(a1)+
	clr.b	(a1)
	bsr	ImpChaine
LBk2:	addq.w	#1,d3
	cmp.w	#16,d3
	bne.s	LBk1
	bra	InsRet

******* Routine Listbank: Ecrit la definition dans BUFFER
LlBank:	movem.l	d1-d7/a2,-(sp)
	move.w	d3,d0
	lsl.w	#3,d0
	move.l	ABanks(a5),a2
	add.w	d0,a2
	move.l	(a2),d0
	beq	LlBkX
* Numero de la banque
	move.l	d0,a1
	move.l	Buffer(a5),a0
	addq.w	#1,d3
	ext.l	d3
	cmp.w	#10,d3
	bcc.s	LlBk1
	move.b	#" ",(a0)+
LlBk1:	move.l	d3,d0
	jsr	LongDec
	move.b	#" ",(a0)+
	move.b	#"-",(a0)+
	move.b	#" ",(a0)+
* Nom de la banque
	move.l	(a1),d0
	cmp.l	BkSpr(pc),d0
	bne.s	.Skip
	move.l	4(a1),d0
	cmp.l	BkSpr+4(pc),d0
	bne.s	.Skip
	lea	BkBob(pc),a1
.Skip	moveq	#7,d0
LlBk2:	move.b	(a1)+,(a0)+
	dbra	d0,LlBk2
	move.b	#" ",(a0)+
* Start
	move.b	BkSt(pc),(a0)+
	move.b	#":",(a0)+
	move.b	#" ",(a0)+
	move.l	(a2),d0
	addq.l	#8,d0
	moveq	#8,d3
	jsr	LongAscii
	move.b	#" ",(a0)+
* Length
	move.b	BkLn(pc),(a0)+
	move.b	#":",(a0)+
	move.b	#" ",(a0)+
	move.l	4(a2),d0
	and.l	#$0FFFFFFF,d0
	subq.l	#8,d0
	moveq	#6,d3
	jsr	LongAscii
* Ok!
	clr.b	(a0)
	move.l	a0,a1
	move.l	Buffer(a5),a0
	moveq	#1,d0
LlBkX:	movem.l	(sp)+,d1-d7/a2
	tst.w	d0
	rts

************************************************************
*	AREG/DREG
IAReg	bsr	FnExpE
	moveq	#3,d0
	moveq	#8,d1
	bra.s	IReg
IDReg	bsr	FnExpE
	moveq	#8,d0
	moveq	#0,d1
IReg:	bsr	RReg
	move.l	a0,-(sp)
	bsr	FnExpE
	move.l	(sp)+,a0
	move.l	d3,(a0)
	bra	InsRet
FAReg	bsr	FnExpE
	moveq	#7,d0
	moveq	#8,d1
	bra.s	FReg
FDReg	bsr	FnExpE
	moveq	#8,d0
	moveq	#0,d1
FReg:	bsr	RReg
	move.l	(a0),d3
	moveq	#0,d2
	bra	OpeRet
* Routinette
RReg:	cmp.l	d0,d3
	bcc	FonCall
	add.w	d1,d3
	lsl.w	#2,d3
	lea	CallReg(a5),a0
	lea	0(a0,d3.w),a0
	rts

************************************************************
*	POKEDOKELOKE
Pok:	bsr	ExpEntier
	move.l	d3,-(sp)
	bsr	FnExpE
	move.l	(sp)+,a0
	move.b	d3,(a0)
	bra	InsRet
Dok:	bsr	ExpEntier
	btst	#0,d3
	bne.s	AdrErr
	move.l	d3,-(sp)
	bsr	FnExpE
	move.l	(sp)+,a0
	move.w	d3,(a0)
	bra	InsRet
Lok:	bsr	ExpEntier
	btst	#0,d3
	bne.s	AdrErr
	move.l	d3,-(sp)
	bsr	FnExpE
	move.l	(sp)+,a0
	move.l	d3,(a0)
	bra	InsRet
AdrErr	moveq	#25,d0
	bra	RunErr
Lik:	bsr	FnExpE
	btst	#0,d3
	bne.s	AdrErr
	move.l	d3,a0
	move.l	(a0),d3
	moveq	#0,d2
	bra	OpeRet
Dik:	bsr	FnExpE
	btst	#0,d3
	bne.s	AdrErr
	move.l	d3,a0
	moveq	#0,d3
	move.w	(a0),d3
	moveq	#0,d2
	bra	OpeRet
Pik:	bsr	FnExpE
	move.l	d3,a0
	moveq	#0,d3
	move.b	(a0),d3
	moveq	#0,d2
	bra	OpeRet

***********************************************************
*	CALL adresse,list of params
ICall	
*******
	move.l	a3,-(sp)
	bsr	Par1
	bsr	AdOuBank
	move.l	d3,CallAd(a5)
* Evalue les params!
ICal0	cmp.w	#TkVir-Tk,(a6)
	bne.s	ICal1
	bsr	FnPar1
	bra.s	ICal0
* Appel
ICal1	movem.l	a4-a6,-(sp)
	lea	CallReg(a5),a6
	movem.l	(a6)+,d0-d7/a0-a2
	move.l	a6,-(sp)
	move.l	CallAd(a5),a6
	jsr	(a6)
	move.l	(sp)+,a6
	movem.l	d0-d7/a0-a2,-(a6)
	movem.l	(sp)+,a4-a6
	move.l	(sp)+,a3
	bra	InsRet
