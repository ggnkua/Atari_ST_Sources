; MAGI, Par AGOPIAN Mathias
; pour STMAG.
; Le Falcon est une merveille...
; La preuve :

;english comments & translation by Gunstick

superviseur	MACRO
		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		move.l	d0,oldsp
		ENDM
		
utilisateur	MACRO
		move.l	oldsp,-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		ENDM
	
	lea	finconfig,a2
	lea	config,a0
	lea	$300000,a1
bcl	move.b	(a0)+,(a1)+
	cmp.l	a0,a2
	bhi	bcl
	superviseur
	move.l	$4f2,a0
	jmp	(a0)
	utilisateur

oldsp	dc.l	0

config	dc.l	'MAGI'
	dc.l	0
	dc.l	0
	lea	text1(pc),a0
	bsr	print

	; On met l'arbre de la PMMU hors de danger.
	;save MMU tree
	lea	my_pmmu(pc),a0
	lea	$310700,a1
	move.l	a1,d7
	move.w	#$100-1,d0
.copy	move.b	(a0)+,(a1)+
	dbf	d0,.copy
	
	lea	pmmureg(pc),a0
	pmove.d	crp,(a0)
	move.l	d7,4(a0)
	pmove.d	(a0),crp

	; Puis on initialise correctement la matrice DMA

	; le HP interne ON (beuark)
sound	move.w	#%10111111,-(sp)
	move.w	#$1d,-(sp)
	trap	#14
	addq.l	#4,sp

	;ADDER
	move.w	#3,-(sp)	; Matrice + ADC 
	move.w	#4,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	; ADC INPUT
	move.w	#3,-(sp)	; PSG input 
	move.w	#5,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	; Set prescale
	move.w	#3,-(sp)	; 50Khz 
	move.w	#6,-(sp)
	move.w	#130,-(sp)
	trap	#14
	addq.l	#6,sp

	; Devconnect
	move.w	#1,-(sp)	; DMA -> DAC
	move.w	#0,-(sp)
	move.w	#0,-(sp)
	move.w	#8,-(sp)
	move.w	#0,-(sp)
	move.w	#139,-(sp)
	trap	#14
	lea	12(sp),sp
	
	; Setinterrupt
	move.w	#1,-(sp)	; Play
	move.w	#0,-(sp)	; Timer A
	move.w	#135,-(sp)
	trap	#14
	addq.l	#6,sp
	
	; Ici, c'est les initialisations

	move.w	#$3111,d7	; Active le cache !
	lea	q1(pc),a0
	bsr	print
	bsr	inkey
	cmp.b	#'y',d0
	beq.s	.q1o
	or.w	#$0008,d7	; D‚sactive le cache d'instruction	
.q1o	lea	q2(pc),a0
	bsr	print
	bsr	inkey
	cmp.b	#'y',d0
	beq.s	.q2o
	or.w	#$0800,d7	; D‚sactive le cache de donn‚e	
.q2o	movec	d7,CACR

	; 16 Mhz, normal quoi
	or.b	#$65,$ffff8007.w	
	lea	q3(pc),a0
	bsr	print
	bsr	inkey
	cmp.b	#'y',d0
	beq.s	.q3o
	bclr.b	#0,$ffff8007.w		; 68030 … 8 Mhz
.q3o	lea	q4(pc),a0
	bsr	print
	bsr	inkey
	cmp.b	#'y',d0
	beq.s	.q4o
	bclr.b	#2,$ffff8007.w		; Blitter … 8 Mhz

.q4o	lea	q5(pc),a0
	bsr	print
	bsr	inkey
	cmp.b	#'y',d0
	bne.s	.q5o
	; Emulation STE:
	; Regardez bien le bit 5, c'est une
	; merveille, grace … lui, on va
	; faire des miracles...
	;this disables a lot of BUS errors
	bclr.b	#5,$ffff8007.w		; Mode STE

.q5o	lea	q6(pc),a0
	bsr	print
	bsr	inkey
	cmp.b	#'n',d0
	beq	.q6o

	; VECTEURS

	lea	$0,a0
	lea	my_vectors(pc),a1
	move.w	#1024-1,d0
.copy	move.b	(a0)+,(a1)+
	dbf	d0,.copy

	lea	my_vectors(pc),a1
	lea	buserr(pc),a0
	move.l	a0,$8(a1)
	lea	adderr(pc),a0
	move.l	a0,$c(a1)
	lea	illegal(pc),a0
	move.l	a0,$10(a1)
	lea	div0(pc),a0
	move.l	a0,$14(a1)
	lea	chk(pc),a0
	move.l	a0,$18(a1)
	lea	trapv(pc),a0
	move.l	a0,$1c(a1)
	lea	trace(pc),a0
	move.l	a0,$24(a1)
	lea	my_la(pc),a0
	move.l	a0,$28(a1)
	lea	my_lf(pc),a0
	move.l	a0,$2c(a1)
	
	lea	my_vbl(pc),a0
	move.l	a0,$70(a1)
	lea	my_hbl(pc),a0
	move.l	a0,$68(a1)
	lea	my_mfp(pc),a0
	move.l	a0,$78(a1)
	
	lea	my_ta(pc),a0
	move.l	a0,$134(a1)
	lea	my_tb(pc),a0
	move.l	a0,$120(a1)
	lea	my_tc(pc),a0
	move.l	a0,$114(a1)
	lea	my_td(pc),a0
	move.l	a0,$110(a1)
	lea	my_mn(pc),a0
	move.l	a0,$13c(a1)
	lea	my_blt(pc),a0
	move.l	a0,$10c(a1)
	lea	my_dma(pc),a0
	move.l	a0,$11c(a1)
	lea	my_ikbd(pc),a0
	move.l	a0,$118(a1)
	
	lea	$80(a1),a1
	lea	my_tr0(pc),a0
	move.l	a0,(a1)+
	lea	my_tr1(pc),a0
	move.l	a0,(a1)+
	lea	my_tr2(pc),a0
	move.l	a0,(a1)+
	lea	my_tr3(pc),a0
	move.l	a0,(a1)+
	lea	my_tr4(pc),a0
	move.l	a0,(a1)+
	lea	my_tr5(pc),a0
	move.l	a0,(a1)+
	lea	my_tr6(pc),a0
	move.l	a0,(a1)+
	lea	my_tr7(pc),a0
	move.l	a0,(a1)+
	lea	my_tr8(pc),a0
	move.l	a0,(a1)+
	lea	my_tr9(pc),a0
	move.l	a0,(a1)+
	lea	my_tra(pc),a0
	move.l	a0,(a1)+
	lea	my_trb(pc),a0
	move.l	a0,(a1)+
	lea	my_trc(pc),a0
	move.l	a0,(a1)+
	lea	my_trd(pc),a0
	move.l	a0,(a1)+
	lea	my_tre(pc),a0
	move.l	a0,(a1)+
	lea	my_trf(pc),a0
	move.l	a0,(a1)
	lea	my_vectors(pc),a1
	movec	a1,VBR
	lea	basevec(pc),a0
	move.l	a1,(a0)

.q6o	; Set TIMER A or MFPi7
	lea	q7(pc),a0
	bsr	print
	bsr	inkey
	cmp.b	#'y',d0
	beq.s	.q7o
	; Setinterrupt
	move.w	#1,-(sp)	; Play
	move.w	#1,-(sp)	; MFPi7
	move.w	#135,-(sp)
	trap	#14
	addq.l	#6,sp

.q7o	lea	q8(pc),a0
	bsr	print
	bsr	inkey
	cmp.b	#'n',d0
	beq.s	.q8o
	move.w	#%01000000,-(sp)	; Coupe le HP interne
	move.w	#$1e,-(sp)
	trap	#14
	addq.l	#4,sp

.q8o	; On reboot
	lea	text2(pc),a0
	bsr	print
	bsr	inkey
	move.l	$4c6.w,a0
	eor.w	#$FFFF,(a0)		;detruit la checksum
	move.w	#1,-(sp)
	move.w	#0,-(sp)
	move.w	#0,-(sp)
	move.w	#1,-(sp)
	move.w	#0,-(sp)
	clr.l	-(sp)
	move.l	$4c6,-(sp)
	move.w	#8,-(sp)
	trap	#14
	lea	20(sp),sp
	; somme de controle
	clr.l	d0
	move.l	$4c6.w,a0
	move.w	#255,d7
check	add.w	(a0)+,d0
	dbf	d7,check
	cmp.w	#$1234,d0
	bne.s	.fin
	move.l	$4c6,a0
	jsr	(a0)

.fin	lea	text3(pc),a0
	bsr	print
	bsr	inkey
	rts			;-> Bureau GEM

	; Routines Annexes

print	move.l	a0,-(sp)
	move.w	#9,-(sp)
	trap	#1
	addq.l	#6,sp
	rts
	
inkey	move.w	#1,-(sp)
	trap	#1
	addq.l	#2,sp
	rts

	; Ca, c'est la ruse, on piŠge le FALCON !
	; Remarquez, vous pouvez metre ce que
	; vous voulez ici (h‚h‚)
	;here is the new exception table.
	;insert your own routines if you wish
illegal	jmp	([$10])
div0	jmp	([$14])
chk	jmp	([$18])
trapv	jmp	([$1c])
trace	jmp	([$24])
my_hbl	jmp	([$68])
my_vbl	jmp	([$70])
my_mfp	jmp	([$78])
my_ta	jmp	([$134])
my_tb	jmp	([$120])
my_tc	jmp	([$114])
my_td	jmp	([$110])
my_mn	jmp	([$13c])
my_dma	jmp	([$11c])
my_ikbd	jmp	([$118])
my_blt	jmp	([$10c])
my_la	jmp	([$28])
my_lf	jmp	([$2c])
my_tr0	jmp	([$80])
my_tr1	jmp	([$84])
my_tr2	jmp	([$88])
my_tr3	jmp	([$8c])
my_tr4	jmp	([$90])
my_tr5	jmp	([$94])
my_tr6	jmp	([$98])
my_tr7	jmp	([$9c])
my_tr8	jmp	([$a0])
my_tr9	jmp	([$a4])
my_tra	jmp	([$a8])
my_trb	jmp	([$ac])
my_trc	jmp	([$b0])
my_trd	jmp	([$b4])
my_tre	jmp	([$b8])
my_trf	jmp	([$bc])

	; Correction des erreurs bus et adresses
	
	;only for experts... fucking around in the stackframe of
	;bus error to enable a somewhat correct sound on bad adresses
buserr
adderr	move.w	#$2700,sr
	move.l	d0,$300004
	move.l	a0,$300008
	moveq	#0,d0
	move.w	$a(sp),d0	
	btst.l	#8,d0			; DF=1 ?
	beq	BorC			; non

	; Erreur sur un cycle de donn‚e	
	btst.l	#6,d0			; oui, RW=1 ?
	beq.s	ecr			; non, -> ecr
lec	bclr.l	#8,d0			; DF=0
	move.w	d0,$a(sp)
	cmp.w	#$ff88,$11(sp)		; Erreur sur les reg. PSG?
	bne.s	noPSGr			; non
	move.b	$ffff8800.w,d0
	move.b	d0,$2c(sp)		; et oui
	move.b	d0,$2d(sp)		; R‚fl‚chissez un peu
	move.b	d0,$2e(sp)
	move.b	d0,$2f(sp)
	bra	finexec
noPSGr	clr.l	$2c(sp)			; Temps pis, on renvoie zero !
	move.w	#$00f,$ffff8240.w	; Rouge
	bra	finexec

ecr	bclr.l	#8,d0			;DF=0
	move.w	d0,$a(sp)		
	cmp.w	#$ff88,$11(sp)
	bne	notPSGw
	and.w	#$ff02,$12(sp)		; correction de l'adresse
	tst.b	$13(sp)
	bne.s	ff8802 
ff8800	and.w	#$30,d0
	lsr.w	#4,d0
	tst.w	d0
	beq.s	.s2
	cmp.w	#1,d0
	beq.s	.s1
	cmp.w	#2,d0
	beq.s	.s3
.s1	move.b	$1b(sp),$ffff8800.w	; Octet
	bra	finexec	
.s2	move.b	$1a(sp),$ffff8800.w	; Mot
	bra	finexec	
.s3	move.b	$18(sp),$ffff8800.w
	move.b	$1a(sp),$ffff8802.w	; Long mot
	bra	finexec	
	
	;is there a volunteer to check also the movem instruction???

ff8802	and.w	#$30,d0
	lsr.w	#4,d0
	tst.w	d0
	beq.s	.s2
	cmp.w	#1,d0
	beq.s	.s1
	cmp.w	#2,d0
	beq.s	.s3
.s1	move.b	$1b(sp),$ffff8802.w
	bra	finexec	
.s2	move.b	$1a(sp),$ffff8802.w
	bra	finexec	
.s3	move.b	$18(sp),$ffff8802.w
	move.b	$1a(sp),$ffff8800.w
	bra	finexec	
notPSGw	move.w	#$0f0,$ffff8240.w
	bra	finexec		; bah, on fait rien, y'a rien a faire !

BorC	btst.l	#14,d0
	beq.s	etageB
	btst.l	#15,d0
	beq.s	etageC
	bra	finexec		; Ceci ne doit JAMAIS arriver
etageB	move.w	#$f00,$ffff8240.w
	bclr.l	#12,d0		; RB=0
	move.w	d0,$a(sp)		
	cmp.w	#$a,6(sp)	; format $A ?
	bne.s	.fB
.fA	move.w	2(sp),a0	; simulons, simulons
	move.w	a0,$e(sp)	; bof, bof!
	bra	finexec
.fB	move.w	$24(sp),a0	; on simule, mais...
	move.w	-2(a0),$e(sp)	; bof!
	bra	finexec
etageC	move.w	#$f0f,$ffff8240.w
	bclr.l	#13,d0		; RC=0
	move.w	d0,$a(sp)		
	cmp.w	#$a,6(sp)	; format $A ?
	bne.s	.fB
.fA	move.w	2(sp),a0	; on simule encore
	move.w	2(a0),$c(sp)	; on peut rien faire d'autre!
	bra	finexec
.fB	move.w	$24(sp),a0
	move.w	-2(a0),$c(sp)	; bof!
finexec	move.l	$300004,d0
	move.l	$300008,a0
	rte


regd0	dc.l	0
rega0	dc.l	0
pmmu	dcb.b	$200
pmmureg	dc.l	0
	dc.l	0
basevec	dc.l	0

text1	dc.b	27,'E'
	dc.b	'Reconfiguration programm',$d,$a
	dc.b	'for Falcon 030',$d,$a,$d,$a,0
text2	dc.b	$d,$a,$d,$a,'Inserez the disk to boot from',$d,$a,$d,$a,0
text3	dc.b	'To load AUTO folder programs',$d,$a
	dc.b	'hold down ALTERNATE.',$d,$a,0
q1	dc.b	$d,$a,'Enable instruction cache (Y/N) ',0
q2	dc.b	$d,$a,'Enable data cache        (Y/N) ',0
q3	dc.b	$d,$a,'Set 68030 to 16Mhz       (Y/N) ',0
q4	dc.b	$d,$a,'Set Blitter to 16Mhz     (Y/N) ',0
q5	dc.b	$d,$a,'STE-mode (no bus errors) (Y/N) ',0
q6	dc.b	$d,$a,'Trap exceptions          (Y/N) ',0
q7	dc.b	$d,$a,'DMA Sound on TimerA-IRQ  (Y/M) ',0
q8	dc.b	$d,$a,'Disable internal speaker (Y/N) ',0
my_vectors
	dcb.b	1024
my_pmmu	DC.L	$0031074A,$10000001,$20000001,$30000001 
	DC.L	$40000001,$50000001,$60000001,$70000001 
	DC.L	$80000041,$90000041,$A0000041,$B0000041 
	DC.L	$C0000041,$D0000041,$E0000041
	DC.L	$0031078A 
	DC.L	$003107CA,$01000001,$02000001,$03000001 
	DC.L	$04000001,$05000001,$06000001,$07000001 
	DC.L	$08000001,$09000001,$0A000001,$0B000001 
	DC.L	$0C000001,$0D000001,$0E000001,$0F000001 
	DC.L	$F0000041,$F1000041,$F2000041,$F3000041 
	DC.L	$F4000041,$F5000041,$F6000041,$F7000041 
	DC.L	$F8000041,$F9000041,$FA000041,$FB000041 
	DC.L	$FC000041,$FD000041,$FE000041
	DC.L	$003107CA 
	DC.L	$00000019,$00100019,$00200019,$00300019 
	DC.L	$00400001,$00500001,$00600001,$00700001 
	DC.L	$00800001,$00900001,$00A00001,$00B00001 
	DC.L	$00C00001,$00D00001,$00E00009,$00F00059 
finconfig
