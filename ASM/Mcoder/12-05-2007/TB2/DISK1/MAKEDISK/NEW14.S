	output	NEWDOS.PRG
message=$5000
STOREMENU=$84000	;POUR STOCKAGE MAIN MENU SUR 1040
DEBUG=1			;0=DEBUGGER
CHECKSUM=1		:0=CHECKSUM
CPU=1			;0=TEMPS CPU
adresse_loader=$68000
ram=adresse_loader-1026-256	;BUFFER HUFFMANN
;
; loader d‚mo se charge en $500
;
; DEMO 1 = MAIN MENU
;    le menu va modifier $4FE.W et JMP en $500 !!!!
;
; RAJOUTER :
;	PUSHER (A0) POUR ECRAN LOADER
;
; LE LOADER UTILISE LA MEMOIRE ENTRE $140 ET $160 !!!
;
PILE=$426
adresse_menu=$5000
adresse_reset=$8000
basemfp=$100

	OPT	O+
mover:
;
; ATTEND QUE LA VBL SOIT FINIE
;
;WAITVBL:MOVE	$FFFF8240.W,D0
;	AND	#$777,D0
;	BNE.S	WAITVBL
;
; INIT KBD
;
.IKB1
;	addq	#7,$ffff8240.w
	BTST	#1,$FFFFFC00.W
	BEQ.S	.IKB1
	MOVE.B	#$1A,$FFFFFC02.W	;CUT JOYSTICKS
.IKB2
;	addq	#7,$ffff8240.w
	BTST	#1,$FFFFFC00.W
	BEQ.S	.IKB2
	MOVE.B	#$12,$FFFFFC02.W	;CUT MOUSE
;
	MOVE	#$2700,SR
	LEA	CODE(PC),A0
	LEA	FIRSTTRANS\W,A1
	MOVE	#(FIN_LOADER-FIRSTTRANS+3)/4-1,D0
MOVEIT	MOVE.L	(A0)+,(A1)+
	IFEQ	CPU
	move	a0,$ffff8240.w
	ENDC
	DBRA	D0,MOVEIT

	IFEQ	DEBUG
	LEA	$42A+4.W,A0
	LEA	FIRSTTRANS.W,A1
.CLR	CLR	(A0)+
	CMP.L	A1,A0
	BLO.S	.CLR
	ENDC

;	CMP.B	#$38,$FFFFFC02.W
;	BNE.S	.NOALT
;	ADDQ	#1,DEMO.W
;.NOALT
;
; POSITIONNER $4FA ICI
;
	JMP	DEBUT_LOADER\W
CODE:
	offset	$42E
floplock:ds.b	1
loaded:	ds.b	1
	EVEN
adresse_prg:	ds.l	1
track:		ds.w	1
sector:		ds.w	1
nbsec:		ds.w	1
buffer:		ds.l	1
flagdisk:	ds.b	1	;doivent se suivre … une adresse paire !!!
error:		ds.b	1
	even
	LIST

	NOLIST
	section	text

	IFEQ	DEBUG
	ORG	$4FA-4
FIRSTTRANS:
CHK:	DC.L	0
	ELSEIF
	ORG	$4FA
FIRSTTRANS:
	ENDC

TEXTE:	DC.L	0
DEMO:	DC.W	0

DEBUT_LOADER:
	MOVE	#$2700,SR
	LEA	PILE.W,SP		;POSITIONNE LA PILE SUPERVISEUR
	IFEQ	DEBUG
	BSR	DEBUGGER

	IFEQ	CHECKSUM
	LEA	DEBUT_LOADER.W,A0
	LEA	FIN_LOADER.W,A1
	CLR	D0
	CLR	D1
.SUM	MOVE	(A0)+,D2
	ADD	D2,D0
	EOR	D2,D1
	CMP.L	A1,A0
	BLO.S	.SUM
	SWAP	D0
	MOVE	D1,D0

	TST.L	CHK.W
	BEQ.S	.SET

	CMP.L	CHK.W,D0
	BEQ.S	.SAME
	DC.L	$4A780001
.SET
	MOVE.L	D0,CHK.W
.SAME
	ENDC
	ELSEIF
	LEA	8.W,A0
	LEA	RESET(PC),A1
	MOVEQ	#($140-8)/4-1,D0
.SETVEC	MOVE.L	A1,(A0)+
	DBRA	D0,.SETVEC
	ENDC

	IFNE	DEBUG
	MOVE.L	#$31415926,$426.W
	MOVE.L	#RESET,$42A.W
	ENDC

	CMP	#2,DEMO.W
	BLO.S	.GOOD
	MOVE.L	TEXTE.W,A0
	LEA	message.w,A1
.COPYTXT
	MOVE.B	(A0)+,(A1)+
	BPL.S	.COPYTXT
.GOOD

	MOVE.L	#DEBUT_LOADER,$10.W

	BSR	CLR_PALETTE
	MOVE.L	#VBLVEC,$70.W

.VIDE	TST.B	$FFFFFC02.W
	MOVEQ.L	#$A1,D0
	AND.B	$FFFFFC00.W,D0
	BNE.S	.VIDE

	CMP	#1,DEMO.W
	BNE.S	.PAMENU1

	LEA	STOREMENU,A0		;SOURCE
	CMP.L	#'MENU',(A0)+
	BNE.S	.PAMENU1

	MOVE.L	(A0)+,A2
	LEA	adresse_menu.w,A1		;DESTINATION
	MOVE.L	A1,SP
	IFEQ	CHECKSUM
	MOVEQ	#0,D0
	ENDC
.MOVEIT
	IFEQ	CHECKSUM
	MOVE.L	(A0)+,D1
	ADD.L	D1,D0
	MOVE.L	D1,(A1)+
	ENDC
	IFNE	CHECKSUM
	MOVE.L	(A0)+,(A1)+
	ENDC
	CMP.L	A2,A1
	BLO.S	.MOVEIT

	IFEQ	CHECKSUM
	CMP.L	(A0)+,D0
	BNE.S	.ERREUR
	ENDC

	JMP	(SP)
	IFEQ	CHECKSUM
.ERREUR
	DC.L	$4A780001
	ENDC
.PAMENU1
	TST	DEMO.W
	BEQ.S	.INTRO
	MOVE.L	#FIN_LOADER_DEMO,buffer.w
	lea	DEBUT_LOADER_DEMO,a0
	lea	adresse_loader,A1
	BSR	DECRUNCHER
	clr.b	loaded.w
	lea	message.w,a0
	JSR	adresse_loader
.INTRO
;
; D0=NUMERO DE LA DEMO A CHARGER
;
	MOVE	DEMO.W,D0
	BSR	LOADER_DECRUNCH
;
; a1=adresse de fin de programme
;
	CMP	#1,DEMO.W
	BNE.S	.PAMENU
	LEA	STOREMENU,A0
	MOVE.L	#'MENU',(A0)
	CMP.L	#'MENU',(A0)+
	BNE.S	.PAMENU
	MOVE.L	A1,(A0)+
	IFEQ	CHECKSUM
	MOVEQ	#0,D0
	ENDC
	LEA	adresse_menu.w,A2
.COPYMEN
	IFNE	CHECKSUM
	MOVE.L	(A2)+,(A0)+
	ENDC
	IFEQ	CHECKSUM
	MOVE.L	(A2)+,D1
	ADD.L	D1,D0
	MOVE.L	D1,(A0)+
	ENDC

	CMP.L	A1,A2
	BLO.S	.COPYMEN

	IFEQ	CHECKSUM
	MOVE.L	D0,(A0)+
	ENDC
.PAMENU
	move.l	a1,a0
	lea	adresse_loader,a1	;effacement du reste de la m‚moire !!!
	bsr	fast_clear

	st	loaded.w

	move.l	adresse_prg.w,sp
.waiteteint
	tst.b	floplock.w
	beq.s	.waiteteint
;
; attendre ici une touche !!!!
;
	TST	DEMO.W
	BEQ.S	.nokey
.wkey	cmp.b	#$39,$fffffc02.w
	bne.s	.wkey
.wrel	cmp.b	#$B9,$fffffc02.w	;anti-rebond !!!!
	bne.s	.wrel
.nokey

	move	#1,DEMO.W
	MOVE.L	#VBLVEC,$70.W
	BSR.S	INIT_HARD

	lea	adresse_loader,a0	;effacement du reste de la m‚moire !!!
	lea	$80000,a1
	bsr	fast_clear

	IFEQ	1
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	d0,d3
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.l	d0,a0
	move.l	d0,a1
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	ENDC

	jmp	(sp)

INIT_HARD:
	MOVE.L	#$0707C0C0,$FFFF8800.W
	MOVE.L	#$08080000,$FFFF8800.W
	MOVE.L	#$09090000,$FFFF8800.W
	MOVE.L	#$0A0A0000,$FFFF8800.W

	MOVE.L	#$07078080,$FFFF8200.W
	MOVEQ	#0,D0
	LEA	$FFFF8240.W,A0
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+
	MOVE.L	d0,(A0)+

	MOVE.L	D0,A0
	MOVEP.L	D0,$FFFFFA01(A0)
	MOVEP.L	D0,$FFFFFA09(A0)
	MOVEP.L	D0,$FFFFFA11(A0)
	MOVEP.L	D0,$FFFFFA19(A0)
	MOVE.B	#$40,$FFFFFA17.W
	RTS

CLR_PALETTE:
	BSR.S	INIT_HARD
	MOVE.L	#SECONDVBL,$70.W
	MOVE	#$2300,SR
	STOP	#$2300
	MOVE.B	#1,$FFFF8260.W
	CLR.B	$FFFF820A.W
	STOP	#$2300
	CLR.B	$FFFF8260.W
	MOVE.B	#2,$FFFF820A.W

;	LEA	FIN_LOADER\W,A0
	LEA	$6000.w,A0		;ADRESSE DEBUT USED
	LEA	$80000,A1
;	bra	fast_clear
;
; a0=d‚but
; a1=fin
;
fast_clear:
	move.l	a1,d1
	sub.l	a0,d1
	moveq	#0,d0
	lsr.l	#1,d1
	bcc.s	.pair
	move.b	d0,(a0)+
.pair
	lsr.l	#1,d1
	bcc.s	.pair2
	move	d0,(a0)+
.pair2
	lsr.l	#1,d1
	bcc.s	.pair3
	move.l	d0,(a0)+
.pair3
;
; LEQUEL DES 2 ???
;
	IFEQ	0

	subq.l	#1,d1
	bmi.s	.pair5
.clr
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	dbra	d1,.clr

	ELSEIF

	lsr.l	#1,d1
	bcc.s	.pair4
	move.l	d0,(a0)+
	move.l	d0,(a0)+
.pair4
	tst.l	d1
	beq.s	.pair5
.clr
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	move.l	d0,(a0)+
	subq.l	#1,d1
	bne.s	.clr
	ENDC

.pair5	rts

CLEAREMEM:

RESET	MOVE	#$2700,SR
	LEA	PILE.W,SP
	BSR.s	CLR_PALETTE
	CLR.L	$426.W

	MOVE.L	#FIN_RESET_DEMO,buffer.w
	lea	DEBUT_RESET_DEMO,a0
	lea	adresse_reset,A1
	BSR	DECRUNCHER
	MOVE.L	#$0E0E0707,$FFFF8800.W
	jmp	adresse_reset

CLEARMEM:
	MOVE	#$2700,SR
	LEA	CLEAREMEM(pc),A0
	MOVEQ	#-2,D0			;adresse paire !!!!
	MOVE.L	D0,A1
	BRA.s	fast_clear
VBLVEC:
	TST.b	floplock.w
	BNE.S	.NOCHG

	CMP.L	#$FA52235F,$FA0000	;TEST CARTOUCHE
	BEQ.S	CLEARMEM

	MOVE	#$80,$FFFF8606.W	;EMPECHE BUG...
	MOVE	D0,-(SP)
	MOVE	$FFFF8604.W,D0
	TST.B	D0
	BMI.S	.NOSTOP
	MOVE.L	#$0E0E0707,$FFFF8800.W
	TAS.B	floplock.w		;$80=arret du moteur
.NOSTOP
	MOVE	(SP)+,D0
.NOCHG
SECONDVBL:
	RTE
;
; gestion disque en interruption
;
; contraintes :
;
;	- $ffff8606 est toujours ‚gal … $80
;
; d5 libre
; a5->a4 ???
;
STEP=3
vecdisk=basemfp+$1c
SECLEN=9		;9=512,10=1024
firstsec=1		;num‚ro premier secteur
lastsec=10		;num‚ro dernier secteur
NUMSEC=lastsec-firstsec+1
NBTRK=82		;nb pistes sur disque


GENDIR	MACRO
	DC.L	XX,\1,\2
XX	SET	XX+\1
	ENDM

XX	SET	(1<<SECLEN)*NUMSEC*5		;SIDE 0

directory:
;	GENDIR	15688,$5000	;D:\CMP\PEN2.CMP
;	GENDIR	90570,$5000	;D:\MAIN\MAIN.CMP
;	GENDIR	15688,$5000	;D:\CMP\PEN2.CMP
;	GENDIR	15932,$5000	;D:\PEN2\PEN2.CMP
	GENDIR	15694,$5000	;D:\PEN2\PEN2.CMP
	GENDIR	76256,$5000	;D:\MAIN\MAIN.CMP

	GENDIR	59830,$5000	;B:\FUTUR_M.CMP
	GENDIR	26796,$5000	;B:\LEGACY.CMP
	GENDIR	51634,$5000	;B:\MADVIS.CMP
	GENDIR	61954,$5000	;B:\OXYGENE.CMP
	GENDIR	25270,$8000	;B:\UNDEAD.CMP

HIDDEN	SET	XX

XX	SET	(1<<SECLEN)*NUMSEC*NBTRK		;SIDE 0

	GENDIR	72080,$5000	;B:\DNT.CMP
	GENDIR	66554,$8000	;B:\GENESIS.CMP
	GENDIR	63308,$5000	;B:\HYSTERIA.CMP
	GENDIR	38100,$5000	;B:\NAOS.CMP

	GENDIR	150180,$5000	;D:\CMP\POLTER.CMP
	GENDIR	13686,$58000	;B:\VGT.CMP
	GENDIR	15922,$5000	;B:\ZIGGY.CMP
XX	SET	HIDDEN
	GENDIR	57624,$5000	;D:\FILLER\HIDDEN2.CMP


;	dc.l	-1
;
; LOADER+DECRUNCHER
;
; entr‚e :
;	d0=num‚ro de la d‚mo
;	a0=adresse d‚but … charger
; sortie :
;	a1=adresse dest fin d‚crunch‚
;
LOADER_DECRUNCH:
;
; entr‚e :
;	d0=num‚ro du fichier … charger
;	a0=adresse chargement
;
loader:
;	asl	#3,d0
	MULU	#12,D0
	lea	directory(pc),a1
	movem.l	(A1,d0.w),d0/d1/a0
	move.l	a0,adresse_prg.w
;
; entr‚e :
;	d0.L=num‚ro premier octet … charger
;	d1.L=longueur en octets … charger
;
	MOVEQ	#3,D3			;SIDE 0
	CMP.L	#(1<<SECLEN)*NUMSEC*NBTRK,D0
	BLO.S	.SIDE0
	SUB.L	#(1<<SECLEN)*NUMSEC*NBTRK,D0
	MOVEQ	#2,D3
.SIDE0

	move.l	#1<<SECLEN-1,d2
	add.l	d2,d1			;pour arrondir
	and.l	d0,d2
	add.l	d2,d1
	and	#-(1<<SECLEN),d1

	LEA	ram,a1
	sub.l	d1,a1
	move.l	a1,buffer.w
	add.l	d2,a1

	moveq	#SECLEN,d2
	lsr.l	d2,d0			;premier octet/512=num‚ro secteur logique
	lsr.l	d2,d1			;d1=nb secteurs … charger
	move	d1,nbsec.w
	divu	#NUMSEC,d0
	move	d0,track.w
	swap	d0
	ifne	firstsec
	addq	#firstsec,d0
	endc
	move	d0,sector.w

	ST	floplock.w		;ON EMPECHE ARRET DU MOTEUR
	move.l	#interupt,vecdisk.w
	or.b	#$80,$fffffa09.w	;enable disk
	or.b	#$80,$fffffa15.w

	moveq	#1,d1
	and	$446.w,D1		;DRIVE BOOTANT (0 ou 1)
	eor	#$0e01,D1
	ADD.b	D1,D1
;	ADDQ.b	#3,D1
;	EOR	D3,D1
	ADD	D3,D1

	sub.l	a2,a2
	movep	d1,$ffff8800(a2)
;
; d‚marrage lecture...
;
; GOTO TRK
;
	MOVE	#$86,$FFFF8606.W	;DATA REGISTER
	MOVE	track.w,$FFFF8604.W	;=PISTE A ATTEINDRE
	MOVE	#$80,$FFFF8606.W
	clr	flagdisk.w
	MOVE	#$14+STEP,$FFFF8604.W	;SEEK WITH VERIFY

	exg	a0,a1
	BSR	DECRUNCHER
.waitfin:
	tst	nbsec.w
	bgt.s	.waitfin
	RTS
;
gototrk:
	MOVE	#$86,$FFFF8606.W	;DATA REGISTER
	MOVE	track.w,$FFFF8604.W	;=PISTE A ATTEINDRE
	MOVE	#$80,$FFFF8606.W
	clr	flagdisk.w
	MOVE	#$14+STEP,$FFFF8604.W	;SEEK WITH VERIFY
	rte
seek:
	bne.s	gototrk
	move.l	d0,-(sp)
	moveq	#$18,d0
	and	$ffff8604.w,d0
	movem.l	(sp)+,d0
	beq.s	load
restore:
	move	#$0100,flagdisk.w
	MOVE	#STEP,$FFFF8604.W
	rte
interupt:
	tst.b	flagdisk.w
	bpl.s	seek
	move.l	d0,-(sp)
	moveq	#$18,d0
	and	$ffff8604.w,d0
	movem.l	(sp)+,d0
	bne.s	errload

	add.l	#1<<SECLEN,buffer.w
	subq	#1,nbsec.w
	ble.s	.nomore

	clr.b	error.w
	addq	#1,sector.w
	cmp	#lastsec,sector.w
	bls.s	load
	ifne	firstsec
	move	#firstsec,sector.w
	elseif
	clr	sector.w
	endc
	addq	#1,track.w
	MOVE	#$50+STEP,$FFFF8604.W	;step-in
	clr	flagdisk.w
	rte
.nomore:clr.b	floplock.w
	rte
errload:
	not.b	error.w
	beq.s	restore
load:
	MOVE.B	buffer+3.w,$FFFF860D.W
	MOVE.B	buffer+2.w,$FFFF860B.W
	MOVE.B	buffer+1.w,$FFFF8609.W
	MOVE	#$84,$FFFF8606.W
	MOVE	sector.w,$FFFF8604.W	;SET SECTOR TO LOAD
	MOVE	#$090,$FFFF8606.W
	MOVE	#$190,$FFFF8606.W
	MOVE	#$090,$FFFF8606.W	;CLEAR DMA FIFO
	MOVE	#SECLEN-8,$FFFF8604.W	;CHARGEONS 512 OCTETS
	MOVE	#$80,$FFFF8606.W
	st.b	flagdisk.w
	MOVE	#$80,$FFFF8604.W	;LOAD SECTOR
	rte
;
; nouveau d‚packer optimis‚ !!!
;
; D5 INUTILISE !!!
;
WAITDMA	MACRO
.\@	cmp.l	buffer.w,a0
	bhs.s	.\@
	MOVE	(A0)+,D2
	IFEQ	CPU
	MOVE	D2,$FFFF8240.W		;plus beau
	ENDC
	ADDX	D2,D2
	ENDM
RDBYTE	macro
	move.l	a2,a5
	move	d1,d0
.\@1	add	d2,d2
	bne.s	.\@2
	WAITDMA
.\@2	bcc.s	.\@3
	add	d0,a5
.\@3	move	(a5)+,d0
	bpl.s	.\@1
	endm
;
; DECRUNCHER MIXTE (HUFFMANN+PACK)
;
DECRUNCHER:
;
;	a0=source
;	a1=destination
;	a2=adresse de d‚but de l'arbre (1026+256 octets)
;
; sortie :
;
;	a1=adresse fin fichier
;
	LEA	ram,a2
	TAS	D0
	NEG	D0

	MOVE.L	a2,a3
	BSR.S	.DECODE0
	MOVE	(a2)+,D1
	moveq	#0,d4
	move.l	a3,a4
	moveq	#256/4-1,d0
.clear:	move.l	d4,(a4)+
	dbra	d0,.clear
	lea	.codes2(pc),a4
	moveq	#12-1,d3
.copy:
	bsr	.byte
	move.b	d0,d4
	move.b	(a4)+,(a3,d4.w)
	dbra	d3,.copy

	LEA	.traduit(pc),a6
	jmp	(a6)

.DECODE3:
	ADDQ	#2,a3
	PEA	(a3)
	BSR.S	.DECODE
	MOVE.L	(sp)+,a5
	MOVE	a3,D0
	SUB	a5,D0
	MOVE	D0,-(a5)
.DECODE:
	ADD	D2,D2
	BNE.S	.TSTCARY2
.DECODE0:
	WAITDMA
.TSTCARY2:
	BCC.S	.DECODE3

	MOVE	#$8001,D0
.L1F2EE:ADD	D2,D2
	BNE.S	.TSTCARY3
	WAITDMA
.TSTCARY3:
	ADDX.B	D0,D0
	BCC.S	.L1F2EE
	MOVE	D0,(a3)+
	rts

.sure:
	rts
.base:
	move.b	d0,(a1)+
.traduit:
	RDBYTE

	cmp.l	a3,a5
	bhs.s	.sure
	move.b	d0,d4
	move.b	(a3,d4.w),d4
	jmp	.base(pc,d4.w)
.meth0:
	bsr	.byte
	bra.s	.base
.meth1:
	bsr	.byte
	move.b	d0,d6
.meth3:
	moveq	#0,d3
.meth2xx:
	bsr	.byte
	move.b	d0,d3
	move.b	d6,(a1)+
	move.b	d6,(a1)+
.meth2x:
	move.b	d6,(a1)+
	dbra	d3,.meth2x
	jmp	(a6)
.meth4:
	moveq	#0,d3
.cnt8:
	bsr	.byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	moveq	#0,d3
.copy4:
	bsr.s	.byte
	move.b	d0,d3
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
.meth4x:move.b	(a4)+,(a1)+
	dbra	d3,.meth4x
	jmp	(a6)

.meth2:
	bsr.s	.byte
	move.b	d0,d6

	bsr	.byte8
	bra.s	.meth2xx

.meth5:
	moveq	#0,d3
.cnt16:
	bsr.s	.byte
	move.b	d0,d3
	neg	d3
	lea	-2(a1,d3.w),a4
	bsr.s	.byte8
	bra.s	.copy4
.meth6:
	bsr.s	.byte8
	bra.s	.cnt8
.meth7:
	bsr.s	.byte8
	bra.s	.cnt16
.meth8:
	bsr.s	.byte
	and	#$ff,d0
	neg	d0
	lea	-2(a1,d0.w),a4

	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	move.b	(a4)+,(a1)+
	jmp	(a6)
.meth9:
	bsr.s	.byte
	move.b	d0,d4
	bsr.s	.byte
	move.b	d0,d3
	bsr.s	.byte
	and	#$ff,d0
	addq	#4,d0
.meth9x:
	move.b	d4,(a1)+
	add.b	d3,d4
	dbra	d0,.meth9x
	jmp	(a6)
.meth10:
	bsr.s	.byte
	move.b	d0,d7
.meth11:
	move.b	d7,(a1)+
	bsr.s	.byte
	move.b	d0,d4
	moveq	#8-1,d3
.meth10x:
	move.b	d7,d0
	add.b	d4,d4
	bcc.s	.nomsk1
	bsr.s	.byte
.nomsk1:
	move.b	d0,(a1)+
	dbra	d3,.meth10x
	jmp	(a6)
.byte:
	MOVE.L	a2,a5
	MOVE	D1,D0
.X1:	ADD	D2,D2
	BEQ.S	.X2
	BCC.S	.X3
	ADD	D0,a5
.X3:	MOVE	(a5)+,D0
	BPL.S	.X1
	rts
.X2:
	WAITDMA
	BCC.S	.X4
	ADD	D0,a5
.X4:	MOVE	(a5)+,D0
	BPL.S	.X1
	RTS
.byte8:
	bsr.s	.byte
	addq.b	#1,d0
	move.b	d0,d3
	asl	#8,d3
	rts
.codes2:
	dc.b	.meth11-.base,.meth10-.base,.meth9-.base,.meth8-.base
	dc.b	.meth7-.base,.meth6-.base,.meth5-.base,.meth4-.base
	dc.b	.meth3-.base,.meth2-.base,.meth1-.base,.meth0-.base

	IFEQ	DEBUG
DEBUGGER
	INCBIN	DEBUGGER.BIN
	ENDC
DEBUT_LOADER_DEMO
	INCBIN	LOADER.CMP
FIN_LOADER_DEMO
DEBUT_RESET_DEMO
	IFNE	DEBUG
	INCBIN	FRACTAL.CMP
	ENDC
FIN_RESET_DEMO

;FUCKMESS:
;	dc.b	"LOADING THE KICK ASS MAIN MENU. CREDITS AND OWNER'S MANUAL ARE TOO "
;	dc.b	"LONG TO BE DISPLAYED HERE, SO PRESS HELP WHEN DECRUNCHED FOR USEFUL "
;	dc.b	"INFO...",-1
;	EVEN
FIN_LOADER:
	LIST
