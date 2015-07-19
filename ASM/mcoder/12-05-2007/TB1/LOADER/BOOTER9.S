length1=50	;nb secteurs
trk1=74
sec1=2
reloc=$500	;adresse absolue pour boot
		;(mode superviseur obligatoire !!!)
;
disk=0		;DISK A !!!
;
	bsr	encrypt
	tst.l	boot+512
	bne.s	erreur
;
; ‚crit boot-secteur
;
	LEA	BOOT(PC),A0
	MOVE	#-$1234,D1
	MOVE	#255,D0
BC:	ADD	(A0)+,D1
	DBRA	D0,BC
	SUB	D1,CHKSUM

	pea	1.w
	pea	$10000
	move	#disk,-(sp)
	clr.l	-(sp)
	pea	boot(pc)
	move	#9,-(sp)
	trap	#14
	lea	20(sp),sp
	tst.l	d0
	bmi	erreur

ok:	moveq	#0,d7
	illegal
erreur:
	moveq	#-1,d7
	illegal
;
; PROTECTION DU CODE !!!
;
ENCRYPT:
;
; deuxiŠme protection
;
; protection du code du decompacteur
;
	LEA	DEBPREF+2(PC),A2
	MOVE.L	A2,A1
TSTF1:	TST.L	(A1)+
	BNE.S	TSTF1
	LEA	-4(A1),A0
CODPREF:
	MOVE.L	-(A0),D0
	SUB.L	D0,-(A1)
	CMP.L	A2,A1
	BNE.S	CODPREF

	MOVE.L	AUTOPREF+2(PC),D0
	SUB.L	D0,-(A1)		;D0.HW=4 !!
;
; premiŠre protection
;
	LEA	L1EE4E(PC),A2
	MOVE.L	A2,A0
TSTF2:	TST.L	(A0)+
	BNE.S	TSTF2
	SUB.L	#DEBCRY-L1EE4E,A0
CRYPT:
	MOVE.L	-(A0),D0
	SUB.L	D0,DEBCRY-L1EE4E(A0)
	CMP.L	A2,A0
	BNE.S	CRYPT
	RTS

boot:
	bra.s	boot0
	dc.b	'LOADER'	;nom du loader
chksum:	dc.b	$65,$43,$21	;rnd(24 bits)
	dc.b	$00,$02		;octets par secteur (512)
	dc.b	2		;secteurs par cluster (1 cluster=512)
L1EE4E:
	dc.b	$01,$00		;secteurs r‚serv‚s (1 seul=boot)
	dc.b	2		;nb FATs
	dc.b	16,0		;nb entr‚es DIRECTORY
	dc.b	$20,3		;nb secteurs sur DISK (800)
	dc.b	0		;unused
	dc.b	1,0		;nb secteurs par FAT
	dc.b	10,0		;nb secteurs par piste
	dc.b	1,0		;nb faces du DISK
	dc.b	0,0		;nb fichiers cach‚s
boot0:
;
; LOADER.S
;
;
; ENTETE DU PROGRAMME
;
;
; PREMIER DECODAGE
;
; DECODAGE DU TEXTE (POUR LES GOGOS)
;
	MOVE	#$2700,SR
	LEA	BOOT(PC),A0
	LEA	reloc.W,A1
	MOVEQ	#512/4-1,D0
COPY:	MOVE.L	(A0)+,(A1)+
	DBRA	D0,COPY
	JMP	debut-boot+reloc.w	;-512(A1)
debut:
	LEA	L1EE4E-boot+reloc.w,A7
DECRYPT:
	MOVE.L	(A7)+,D0
	ADD.L	D0,DEBCRY-L1EE4E-4(A7)
	BNE.S	DECRYPT
DEBCRY:
;	MOVE	#$2700,SR
;
; PLANTER SI CARTOUCHE
; CHARGER EN 0
;
;	CLR.L	$24.W		;EMPECHE TRACE
;	CLR.L	$426.W		;EMPECHER REBOOT
;
; DEUXIEME DECODAGE
;
; DECODAGE DU DECOMPACTEUR (POUR LES PROS)
;
	LEA	AUTOPREF+2-4-boot+reloc.w,A7
	LEA	DEBPREF-2-boot+reloc.w,A0
	MOVEQ	#512-CT/4-1,D1
AUTOPREF:
CT:	equ	AUTOPREF-boot+2
	LEA	4(A7),A7		;ASTUCE !!!
	MOVE.L	(A7)+,D0
	ADD.L	D0,(A0)+
	DBEQ	D1,AUTOPREF+4
DEBPREF:
;
; ici D1=constante … exploiter
;  (contient le nombre de secteurs … charger !!!!)
;
	CLR.L	$426.W
	st	$43E.W
	AND	#1,$446.W	;pour simplifier
	and	#3,$440.W	;pour simplifier code aprŠs

	move.b	#$e,$ffff8800.w
	moveq	#1,d0
	sub	$446.w,d0	;selecte face 0
	add.b	d0,d0
	addq	#3,d0
	move.b	d0,$ffff8802.w

	lea	$ffff8606.w,a1

	MOVE.L	#vbl-boot+reloc,$70.w
	lea	-2(a1),a0	;A0=$FFFF8604.W

	moveq	#0,d0
	lea	$fffffa01.w,a2	;A2=$FFFFFA01.W
	movep.l	d0,0(a2)
	movep.l	d0,8(a2)
	movep.l	d0,16(a2)
	movep.l	d0,24(a2)

	lea	$80000,a7
	move	#$2300,sr

	moveq	#length1-1,d1	;nb secteurs … charger
	moveq	#sec1,d0	;premier secteur

	move	#$86,(a1)
	move	#trk1,(a0)
	move	#$80,(a1)
	moveq	#$10,d2		;goto trk without verify
	bra.s	seek
stepin:
	moveq	#1,d0		;num‚ro secteur
	moveq	#$50,d2
seek:	add	$440.w,d2
	move	d2,(a0)
wait:	btst	#5,(a2)
	bne.s	wait
sector:
	move	#$84,(a1)
	move	d0,(a0)

	clr.b	$ffff860d.w		;adresse de chargement
dmaptr:	move.b	#$00,$ffff860b.w
	move.b	#$04,$ffff8609.w

	move	#$90,(a1)
	move	#$190,(a1)
	move	#$90,(a1)		;clear DMA FIFO
	move	#1,(a0)			;set sector length

	move	#$80,(a1)
	moveq	#$18,d2
	move	#$80,(a0)
	moveq	#-1,d3		;on empeche plantage disk
wait3:	btst	#5,(a2)
	dbeq	d3,wait3	;boucle pendant 11 trames 1/2
	beq.s	notimout
	move	#$D0,(a0)
	moveq	#50,d3		;reset du drive
wtim:	dbra	d3,wtim
	bra.s	sector
notimout:
	and	(a0),d2		;erreur de chargement ?
	bne.s	sector		;oui->retry
	addq.b	#2,dmaptr+3-boot+reloc.w
	addq	#1,d0
	cmp	#11,d0
	dbhs	d1,sector
	dblo	d1,stepin
;
; ici chargement fini !!!
;
; ici $ffff8606.w=$80 !!!
;
	clr	$43E.w		;arrete le moteur sur VBL !!

	LEA	$40000,A0
	MOVE	#LENGTH1*512/2-1,D1
	MOVEQ	#0,D0
CLAIR:	ADD	#$C0DE,D0
	ADD	D0,(A0)+
	DBRA	D1,CLAIR

	JMP	$40000
vbl:
	add.b	#$66/2,cpvbl.w
	bcc.s	stopmot
color0:	equ	*-boot+2+reloc
	move	#$777,$ffff8240.w
	beq.s	stopmot
	sub	#$111,color0.w
stopmot:
	tst	$43E.w
	bne.s	retvbl
	move	d0,-(sp)
	move	$ffff8604.w,d0
	tst.b	d0
	bmi.s	nostop
	move.l	#$0e0e0707,$ffff8800.w
	st	$43E.w
nostop:	move	(sp)+,d0
retvbl:
	rte
cpvbl:	equ	*-boot+reloc
	dc.b	-1
	DC.B	"BOOTCODE,LOADER,RESETDEMO BY MCODER "
	DC.B	"15/08/90 "
	DC.B	"MESSAGE TO ALL LAMERS : "
	DC.B	"I WON'T FUCK ANYBODY ANYMORE !!!"
	even
;
; fini
;
;	dc.w	0
;	dc.l	0,0
	blk.b	$200,0		;remplissage du secteur
