;	int	say(int mode, char *buf)
; prononce la suite de phonemes contenus dans buf.
; mode = 0:	retour immediat, silence en fin de phrase
; mode = 1:	attend la fin de la phrase.
; mode = 2:	retour immediat, sans silence en fin de phrase

TIMAVEC		equ	$000134
GISELECT	equ	$ffff8800
GIDATA		equ	$ffff8802
IPRA		equ	$fffffa0b
ISRA		equ	$fffffa0f
IMRA		equ	$fffffa13

	.globl	_say
	.globl	say
	.globl	_set_pitch
	.globl	set_pitch
	.globl	_set_rate
	.globl	set_rate
	.globl	_say_copyright
	.globl	say_copyright

	.text

_say_copyright:
say_copyright:
	dc.b	$0d,$0a,"MC68000/AY-3-8910 SPEECH SYNTHESIZER V:2.0"
	dc.b	$0d,$0a,"Copyright 1986 A.D.BEVERIDGE & M.N.DAY"
	dc.b	$0d,$0a,"ALL RIGHTS RESERVED.",$0d,$0a,$00
	.even

_set_pitch:
set_pitch:
	link	a6,#0
	move	__set_pitc,d1
	bsr	verif
	bmi	spit2
	move.b	d0,__set_pitc
spit2:
	unlk	a6
	rts

_set_rate:
set_rate:
	link	a6,#0
	move	__set_rate,d1
	bsr	verif
	bmi	srat2
	move.b	d0,__set_rate
srat2:
	unlk	a6
	rts
verif:
	move	8(a6),d0
	bmi	ret_old
	cmpi	#200,d0
	bhs	ret_bad
	cmpi	#20,d0
	blt	ret_bad
	rts
ret_bad:
	moveq	#-1,d0
	rts
ret_old:
	move	d1,d0
	rts

;*********

_say:
say:
	link	a6,#0
	movem.l	d1-d7/a0-a5,-(sp)
	move	8(a6),d0
	cmpi	#3,d0
	bne	saymd			; mode 3: test
	move.l	P3ae2,d0
	beq	realbye
	moveq	#1,d0
	bra	realbye
saymd:
	move	d0,saymode
waitp:
	tst.l	P3ae2			; attend la fin de la phrase
	bne	waitp			; precedente
testptr:
	move.l	10(a6),d0		; si ptr = 0, sortie
	beq	bye
	move.l	d0,a0
	tst.b	(a0)			; si chaine vide, repetition
	bne	decod
	move	badbuf,d0
	beq	repeat			; ... apres verif du buffer
	bra	bye
decod:
	bsr	stopsnd
	bsr	decode			; traitement de la phrase
	tst.l	d0			; sortie si elle est incorrecte
	bne	badret
	lea	phoneme(pc),a1
	lea	P44c2(pc),a5
	bsr	S196a			; traite les AY OY
	bsr	S1a68
	bsr	S1a9a
	bsr	S1ac4
	bsr	S1b08
	bsr	S1b5a
repeat:
	bsr	S2076

	moveq	#0,d0
badret:	move	d0,badbuf
bye:
	cmpi	#1,saymode		; en mode 1,
	bne	realbye			; attend la fin de phrase
waitend:
	tst.l	P3ae2
	bne	waitend
realbye:
	movem.l	(sp)+,d1-d7/a0-a5
	unlk	a6
	rts

uppercase:
	cmpi.b	#$61,d0
	bcs	L18a0
	cmpi.b	#$7b,d0
	bcc	L18a0
	subi.b	#$20,d0
L18a0:	rts

;*****************************************************************************
; entree: a0 = phrase
; decode les phonemes dans 'buffer'
; format de buffer: groupes de 4 octets termines par un mot a $FFFFFFFF
;	2 octets:	rang dans la table des phonemes
;	2 octets:	bits 0..3: hauteur, bit 6: raccourci, bit 7: rallonge
;*****************************************************************************

decode:	lea	buffer,a1
L18a6:	move.l	#$ffffffff,(a1)
	move.b	(a0)+,d0
	beq	L193a

	cmpi.b	#$31,d0			; chiffre 1..9
	bcs	L18d0
	cmpi.b	#$3a,d0
	bcc	L18d0
	subi.b	#$30,d0
	tst.b	-2(a1)
	bne	L1924
	move.b	d0,-2(a1)
	bra	L18a6

L18d0:	cmpi.b	#$3e,d0			; '>'
	bne	L18e4
	move.b	-2(a1),d1
	andi.b	#$C0,d1
	bne	L1924
	ori.b	#$80,-2(a1)
	bra	L18a6

L18e4:	cmpi.b	#$3c,d0			; '<'
	bne	L18f8
	move.b	-2(a1),d1
	andi.b	#$C0,d1
	bne	L1924
	ori.b	#$40,-2(a1)
	bra	L18a6

L18f8:	bsr	uppercase
	move.b	d0,d1
	move.b	(a0),d0
	bsr	uppercase
	lea	phoneme(pc),a2
	moveq	#0,d2
L1906:	cmp.b	0(a2,d2.w),d1
	bne	L191a
	cmpi.b	#$20,1(a2,d2.w)
	beq	L192a
	cmp.b	1(a2,d2.w),d0
	beq	L1928
L191a:	addi.w	#34,d2
	tst.b	0(a2,d2.w)
	bpl	L1906
L1924:	moveq	#-1,d0
	rts

L1928:	addq.l	#1,a0
L192a:	move	d2,(a1)+
	clr.w	(a1)+
	cmpa.l	#buffer+1024,a1
	beq	L1924
	bra	L18a6

L193a:	cmpi	#2,saymode
	beq	Lend
	move	#_Q-phoneme,(a1)+
	clr.w	(a1)+
Lend:
	move.l	#$ffffffff,(a1)+
Lret:	moveq	#0,d0
	rts

;*********
; decale le buffer pour inserer 4 octets: d1.w d2.b et d3.b
;
insert:
	move.l	a1,-(a7)
	lea	buffer+1020,a1
L1950:	cmpa.l	a0,a1
	beq	L195a
	move.l	-(a1),4(a1)
	bra	L1950
L195a:	move	d1,0(a0)
	move.b	d2,2(a0)
	move.b	d3,3(a0)
	movea.l	(a7)+,a1
	rts

;************

S196a:
	lea	buffer,a0
L196e:	moveq	#0,d0
	move	(a0),d0
	bmi	L1a66
	cmpi	#_SPACE-phoneme,d0
	beq	L1a5e
	ble	L199a
	move	2(a1,d0.w),(a0)
	move	4(a1,d0.w),d1
	move.b	2(a0),d2
	moveq	#0,d3
	addq.l	#4,a0
	bsr	insert
	subq.l	#4,a0
	move	(a0),d0

L199a:	cmpi	#_UW-phoneme,d0
	bgt	L19bc
	move	#$0110,d1
	cmpi	#$0044,d0
	ble	L19ae
	move	#$00ee,d1
L19ae:	move.b	2(a0),d2
	moveq	#0,d3
	addq.l	#4,a0
	bsr	insert
	subq.l	#4,a0
	move	(a0),d0
L19bc:	cmpi	#_R-phoneme,d0
	bne	L19e8
	move	-4(a0),d1
	bmi	L1a5e
	cmpi	#_EH-phoneme,d1
	bgt	L1a5e
	move	4(a0),d1
	bmi	L19e0
	cmpi	#_EH-phoneme,d1
	ble	L1a5e
L19e0:	move	#_RX-phoneme,(a0)
	bra	L1a5e
L19e8:	cmpi	#_L-phoneme,d0
	bne	L1a14
	move	-4(a0),d1
	bmi	L1a5e
	cmpi	#_EH-phoneme,d1
	bgt	L1a5e
	move	4(a0),d1
	bmi	L1a0e
	cmpi	#_EH-phoneme,d1
	ble	L1a5e
L1a0e:	move	#_LX-phoneme,(a0)
	bra	L1a5e
L1a14:	cmpi	#_S-phoneme,d0
	bne	L1a5e
	cmpi	#_G-phoneme,-4(a0)
	bne	L1a28
	move	#_Z-phoneme,(a0)
	bra	L1a5e
L1a28:	cmpi	#_EH-phoneme,8(a0)
	bgt	L1a5e
	cmpi	#_P-phoneme,4(a0)
	bne	L1a40
	move	#_B-phoneme,4(a0)
	bra	L1a5e
L1a40:	cmpi	#_T-phoneme,4(a0)
	bne	L1a50
	move	#_D-phoneme,4(a0)
	bra	L1a5e
L1a50:	cmpi	#_K-phoneme,4(a0)
	bne	L1a5e
	move	#_G-phoneme,4(a0)
L1a5e:	addq.l	#4,a0
	tst.w	(a0)
	bpl	L196e
L1a66:	rts

;**********

S1a68:
	lea	buffer,a0
	moveq	#0,d0
L1a6e:	move	(a0),d0
	bpl	L1a74
	rts
L1a74:	cmpi	#_EH-phoneme,d0
	ble	L1a96
	cmpi	#_S-phoneme,d0
	bge	L1a96
	move	4(a0),d0
	bmi	L1a96
	cmpi	#_EH-phoneme,d0
	bgt	L1a96
	move.b	6(a0),d0
	beq	L1a96
	move.b	d0,2(a0)
L1a96:	addq.l	#4,a0
	bra	L1a6e

;***********

S1a9a:
	lea	buffer,a0
L1a9e:	move	(a0),d0
	bmi	L1ac2
	btst	#7,32(a1,d0.w)
	beq	L1abe
	move	d0,d1
	addi.w	#34,d1
	move.b	2(a0),d2
	moveq	#0,d3
	addq.l	#4,a0
	bsr	insert
	bra	L1a9e
L1abe:	addq.l	#4,a0
	bra	L1a9e
L1ac2:	rts

;*********

S1ac4:
	lea	buffer,a0
	moveq	#0,d0
L1aca:	move	(a0),d0
	bpl	L1ad0
	rts
L1ad0:	move.b	3(a1,d0.w),d1
	move.b	2(a0),d2
	bpl	L1ae4
	move.b	d1,d3
	lsr.b	#1,d3
	addq.b	#1,d3
	add.b	d3,d1
	bra	L1af8
L1ae4:	btst	#6,d2
	beq	L1af0
	lsr.b	#1,d1
	addq.b	#1,d1
	bra	L1af8
L1af0:	tst.b	d2
	beq	L1af8
	move.b	2(a1,d0.w),d1
L1af8:	andi.w	#$3f,d2
	move.b	d2,2(a0)
	move.b	d1,3(a0)
	addq.l	#4,a0
	bra	L1aca

;***********

S1b08:
	lea	buffer,a0
	moveq	#0,d0
L1b0e:	move	(a0),d0
	bmi	L1b58
	cmpi	#_S-phoneme,d0
	ble	L1b54
	moveq	#0,d4
L1b1a:	subq.l	#4,d4
	move	0(a0,d4.w),d0
	bmi	L1b54
	cmpi	#_S-phoneme,d0
	bgt	L1b50
	cmpi	#_EH-phoneme,d0
	bgt	L1b1a
	bra	L1b50
L1b30:	move	0(a0,d4.w),d0
	btst	#5,32(a1,d0.w)
	beq	L1b44
	btst	#6,32(a1,d0.w)
	beq	L1b50
L1b44:	move.b	3(a0,d4.w),d1
	lsr.b	#1,d1
	addq.b	#1,d1
	add.b	d1,3(a0,d4.w)
L1b50:	addq.l	#4,d4
	bne	L1b30
L1b54:	addq.l	#4,a0
	bra	L1b0e
L1b58:	rts

;**********

S1b5a:
	lea	buffer,a0
	lea	spchbuff,a2
	moveq	#0,d0			; efface le buffer de parole (9 ko)
	move	#$011f,d1
L1b70:	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	move.l	d0,(a2)+
	dbra	d1,L1b70

	lea	spchbuff,a2
	moveq	#0,d1
	move.b	d0,20(a5)
	move.b	d0,21(a5)
L1b92:	move	(a0),d0
	bmi	L1e12
	move	4(a1,d0.w),2(a5)
	move	8(a1,d0.w),8(a5)
	move	12(a1,d0.w),14(a5)
	move.b	21(a1,d0.w),5(a5)
	move.b	23(a1,d0.w),11(a5)
	move.b	25(a1,d0.w),17(a5)
	move.b	27(a1,d0.w),19(a5)
	moveq	#0,d4
	move	d4,24(a5)
	move	d4,26(a5)
	move.b	20(a5),d4
	cmp.b	3(a0),d4
	ble	L1bdc
	move.b	3(a0),20(a5)
L1bdc:	move.b	21(a5),d4
	cmp.b	3(a0),d4
	ble	L1bec
	move.b	3(a0),21(a5)
L1bec:	bsr	S1f04
	move.b	20(a5),24(a5)
	move.b	21(a5),26(a5)
	move	2(a5),0(a5)
	move	8(a5),6(a5)
	move	14(a5),12(a5)
	move.b	5(a5),4(a5)
	move.b	11(a5),10(a5)
	move.b	17(a5),16(a5)
	move.b	19(a5),18(a5)
	move	4(a0),d1
	bmi	L1e12
	move.b	$0010(a1,d0.w),d2
	cmp.b	$0010(a1,d1.w),d2
	bge	L1c54
	move.b	$0014(a1,d1.w),$0016(a5)
	move.b	$0013(a1,d1.w),$0014(a5)
	move.b	$001f(a1,d1.w),$0017(a5)
	move.b	$001e(a1,d1.w),$0015(a5)
	exg	d0,d1
	bra	L1c6c
L1c54:	move.b	$0014(a1,d0.w),$0014(a5)
	move.b	$0013(a1,d0.w),$0016(a5)
	move.b	$001f(a1,d0.w),$0015(a5)
	move.b	$001e(a1,d0.w),$0017(a5)
L1c6c:	move.b	$0003(a0),d6
	cmp.b	$0014(a5),d6
	bge	L1c7a
	move.b	d6,$0014(a5)
L1c7a:	cmp.b	$0015(a5),d6
	bge	L1c84
	move.b	d6,$0015(a5)
L1c84:	cmpi	#_R-phoneme,d1
	bne	L1c8e
	moveq	#$00,d2
	bra	L1c9a
L1c8e:	move	$0004(a1,d1.w),d2
	move.b	$0011(a1,d0.w),d3
	bsr	S204c
L1c9a:	add.w	$0006(a1,d0.w),d2
	move	d2,$0002(a5)
	move	$0008(a1,d1.w),d2
	move.b	$0011(a1,d0.w),d3
	bsr	S204c
	add.w	$000a(a1,d0.w),d2
	move	d2,$0008(a5)
	move	$000c(a1,d1.w),d2
	move.b	$0012(a1,d0.w),d3
	bsr	S204c
	add.w	$000e(a1,d0.w),d2
	move	d2,$000e(a5)
	move.b	$0015(a1,d1.w),d2
	ext.w	d2
	move.b	$001d(a1,d0.w),d3
	bsr	S204c
	add.b	$0016(a1,d0.w),d2
	move.b	d2,$0005(a5)
	move.b	$0017(a1,d1.w),d2
	ext.w	d2
	move.b	$001d(a1,d0.w),d3
	bsr	S204c
	add.b	$0018(a1,d0.w),d2
	move.b	d2,$000b(a5)
	move.b	$0019(a1,d1.w),d2
	ext.w	d2
	move.b	$001d(a1,d0.w),d3
	bsr	S204c
	add.b	$001a(a1,d0.w),d2
	move.b	d2,$0011(a5)
	move.b	$001b(a1,d1.w),d2
	ext.w	d2
	move.b	$001d(a1,d0.w),d3
	bsr	S204c
	add.b	$001c(a1,d0.w),d2
	move.b	d2,$0013(a5)
	moveq	#$00,d2
	move.b	$0003(a0),d2
	sub.b	$0018(a5),d2
	sub.b	$0014(a5),d2
	ble	L1d6e
	moveq	#$00,d3
	move.b	$0018(a5),d3
	mulu	#$0009,d3
	bra	L1d6a
L1d3e:	move	$0000(a5),d7
	bsr	S205c
	move.b	d7,$0003(a2,d3.w)
	move	$0006(a5),d7
	bsr	S205c
	move.b	d7,$0005(a2,d3.w)
	move	$000c(a5),d7
	bsr	S205c
	move.b	d7,$0007(a2,d3.w)
	addi.w	#$0009,d3
	addq.b	#1,$0018(a5)
L1d6a:	dbra	d2,L1d3e
L1d6e:	moveq	#$00,d2
	move.b	$0003(a0),d2
	sub.b	$001a(a5),d2
	sub.b	$0015(a5),d2
	ble	L1dc6
	moveq	#$00,d3
	move.b	$001a(a5),d3
	mulu	#9,d3
	bra	L1dc2
L1d8a:	move.b	4(a5),d7
	bsr	S2064
	move.b	d7,4(a2,d3.w)
	move.b	10(a5),d7
	bsr	S2064
	move.b	d7,6(a2,d3.w)
	move.b	16(a5),d7
	bsr	S2064
	move.b	d7,8(a2,d3.w)
	move.b	18(a5),d7
	bsr	S2064
	move.b	d7,1(a2,d3.w)
	addi.w	#9,d3
	addq.b	#1,$001a(a5)
L1dc2:	dbra	d2,L1d8a
L1dc6:	bsr	S1f04
	move	$0002(a5),$0000(a5)
	move	$0008(a5),$0006(a5)
	move	$000e(a5),$000c(a5)
	move.b	$0005(a5),$0004(a5)
	move.b	$000b(a5),$000a(a5)
	move.b	$0011(a5),$0010(a5)
	move.b	$0013(a5),$0012(a5)
	move.b	$0016(a5),$0014(a5)
	move.b	$0017(a5),$0015(a5)
	moveq	#0,d0
	move.b	3(a0),d0
	mulu	#9,d0
	adda.l	d0,a2
	addq.l	#4,a0
	bra	L1b92
L1e12:	clr.b	(a2)
	lea	spchbuff,a2
	lea	buffer,a0
L1e1c:	move	(a0),d0
	bmi	L1e3c
	moveq	#0,d1
	move.b	3(a0),d1
	move.b	$0021(a1,d0.w),d2
	bra	L1e34
L1e2c:	move.b	d2,2(a2)
	adda.w	#9,a2
L1e34:	dbra	d1,L1e2c
	addq.l	#4,a0
	bra	L1e1c

L1e3c:	lea	buffer,a0
	lea	spchbuff,a2
	moveq	#$42,d0
	moveq	#0,d2
L1e48:	move	(a0),d4
	bmi	L1f02
	moveq	#$00,d5
	move.b	3(a0),d5
	subq.b	#1,d5
	blt	L1e84
	cmpi	#_SPACE-phoneme,d4
	beq	L1e6a
	cmpi	#_S-phoneme,d4
	bgt	L1ea8
	tst.b	2(a0)
	bne	L1e88
L1e6a:	move.b	d0,0(a2)
	cmpi.b	#$42,d0
	beq	L1e7c
	blt	L1e7a
	subq.b	#1,d0
	bra	L1e7c
L1e7a:	addq.b	#1,d0
L1e7c:	adda.w	#9,a2
	dbra	d5,L1e6a

L1e84:	addq.l	#4,a0
	bra	L1e48

L1e88:	moveq	#0,d0
	move.b	2(a0),d0
	move.b	d0,d7
	add.b	d0,d0
	add.b	d7,d0
	neg.b	d0
	addi.b	#$42,d0
L1e9a:	move.b	d0,0(a2)
	adda.w	#9,a2
	dbra	d5,L1e9a
	bra	L1e84

L1ea8:	moveq	#-$14,d2
	moveq	#0,d3
L1eac:	subi.w	#4,d3
	tst.w	0(a0,d3.w)
	bmi	L1ec8
	cmpi	#_S-phoneme,0(a0,d3.w)
	bgt	L1ec8
	moveq	#0,d4
	add.b	3(a0,d3.w),d2
	blt	L1eac
	moveq	#$00,d2
L1ec8:	addi.b	#$14,d2
	beq	L1efc
	cmpi	#$0880,(a0)
	bne	L1ed8
	moveq	#$01,d1
	bra	L1ee8
L1ed8:	cmpi	#$08c4,(a0)
	bne	L1ee2
	moveq	#-1,d1
	bra	L1ee8
L1ee2:	moveq	#$01,d1
	lsr.b	#1,d2
	addq.b	#1,d2
L1ee8:	ext.w	d2
	muls	#-9,d2
	moveq	#0,d3
L1ef0:	add.b	d1,d3
	add.b	d3,0(a2,d2.w)
	addi	#9,d2
	ble	L1ef0
L1efc:	moveq	#$42,d0
	bra	L1e6a
L1f02:	rts

;**********

S1f04:
	movem.l	d0-d7,-(a7)
	moveq	#0,d0
	move.b	24(a5),d0
	mulu	#9,d0
	lea	0(a2,d0.w),a3
	move	0(a5),d0
	move	2(a5),d1
	lea	3(a3),a4
	moveq	#0,d2
	move.b	20(a5),d2
	bsr	S1fc4
	move	6(a5),d0
	move	8(a5),d1
	lea	5(a3),a4
	moveq	#0,d2
	move.b	20(a5),d2
	bsr	S1fc4
	move	12(a5),d0
	move	14(a5),d1
	lea	7(a3),a4
	moveq	#0,d2
	move.b	20(a5),d2
	bsr	S1fc4
	moveq	#0,d0
	move.b	26(a5),d0
	mulu	#9,d0
	lea	0(a2,d0.w),a3
	move.b	4(a5),d0
	move.b	5(a5),d1
	lea	4(a3),a4
	moveq	#0,d2
	move.b	21(a5),d2
	bsr	S1ffe
	move.b	10(a5),d0
	move.b	11(a5),d1
	lea	6(a3),a4
	moveq	#0,d2
	move.b	21(a5),d2
	bsr	S1ffe
	move.b	16(a5),d0
	move.b	17(a5),d1
	lea	8(a3),a4
	moveq	#0,d2
	move.b	21(a5),d2
	bsr	S1ffe
	move.b	18(a5),d0
	move.b	19(a5),d1
	lea	1(a3),a4
	moveq	#0,d2
	move.b	21(a5),d2
	bsr	S1ffe
	movem.l	(a7)+,d0-d7
	rts

;**********

S1fc4:
	tst.b	d2
	beq	L1ffc
	move	d1,d3
	sub.w	d0,d3
	ext.l	d3
	divs	d2,d3
	move	d3,d4
	asr.w	#1,d4
	add.w	d4,d0
	bra	L1ff8
L1fd8:	move	d0,d7
	bsr	S205c
	tst.b	(a4)
	beq	L1ff0
	tst.l	d3
	bmi	L1fec
	cmp.b	(a4),d7
	bgt	L1ff0
	bra	L1ff2
L1fec:	cmp.b	(a4),d7
	bge	L1ff2
L1ff0:	move.b	d7,(a4)
L1ff2:	add.w	d3,d0
	adda.w	#9,a4
L1ff8:	dbra	d2,L1fd8
L1ffc:	rts

;**********

S1ffe:
	tst.b	d2
	beq	L204a
	andi.l	#$ff,d0
	move.b	d1,d3
	sub.b	d0,d3
	lsl.w	#8,d3
	ext.l	d3
	divs	d2,d3
	ext.l	d3
	lsl.l	#8,d3
	move.l	d3,d4
	asr.l	#1,d4
	swap	d0
	add.l	d4,d0
	swap	d0
	bra	L2046
L2022:	move.b	d0,d7
	bsr	S2064
	tst.b	(a4)
	beq	L203a
	tst.l	d3
	bmi	L2036
	cmp.b	(a4),d7
	bgt	L203a
	bra	L203c
L2036:	cmp.b	(a4),d7
	bge	L203c
L203a:	move.b	d7,(a4)
L203c:	swap	d0
	add.l	d3,d0
	swap	d0
	adda.w	#9,a4
L2046:	dbra	d2,L2022
L204a:	rts

;**********

S204c:
	tst.b	d3
	beq	L2058
	subq.b	#1,d3
	bne	L2056
	asr.w	#1,d2
L2056:	rts
L2058:	moveq	#0,d2
	rts
S205c:
	addi.w	#16,d7
	lsr.w	#5,d7
	rts

;**********

S2064:
	move.b	d7,d6
	add.b	d6,d6
	add.b	d6,d7
	subi.b	#$59,d7
	bpl	L2072
	moveq	#$00,d7
L2072:	lsr.b	#2,d7
	rts

;**********

S2076:
	moveq	#$00,d0
	moveq	#$00,d1
	move.b	__set_pitc(pc),d0
	move.b	d0,use_pitc
	move.b	__set_rate(pc),d1
	mulu	#$004d,d1
	divu	d0,d1
	move.b	d1,use_rate
	clr.b	P3ae6
	move.l	#spchbuff,P3ae2
	pea	opwaves(pc)
	move	d0,-(a7)
	move	#1,-(a7)
	clr	-(a7)
	move	#31,-(a7)
	trap	#14
	adda.w	#12,a7
	rts

;	data

P20ca:	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0001
	dc.w	$0101,$0101,$0101,$0101,$0101,$0101,$0101,$0101
	dc.w	$0202,$0202,$0202,$0202,$0202,$0202,$0202,$0202
	dc.w	$0202,$0202,$0202,$0202,$0202,$0202,$0202,$0202
	dc.w	$0202,$0202,$0202,$0202,$0202,$0202,$0202,$0202
	dc.w	$0202,$0202,$0202,$0202,$0202,$0202,$0202,$0202
	dc.w	$0201,$0101,$0101,$0101,$0101,$0101,$0101,$0101
	dc.w	$0101,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$00FF
	dc.w	$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE
	dc.w	$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE
	dc.w	$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE
	dc.w	$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE,$FEFE
	dc.w	$FEFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF,$FFFF
	dc.w	$FFFF,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0101,$0101,$0101,$0102
	dc.w	$0202,$0202,$0202,$0203,$0303,$0303,$0303,$0303
	dc.w	$0404,$0404,$0404,$0404,$0404,$0404,$0405,$0505
	dc.w	$0505,$0505,$0505,$0505,$0505,$0505,$0505,$0505
	dc.w	$0505,$0505,$0505,$0505,$0505,$0505,$0505,$0505
	dc.w	$0505,$0505,$0404,$0404,$0404,$0404,$0404,$0404
	dc.w	$0403,$0303,$0303,$0303,$0303,$0202,$0202,$0202
	dc.w	$0202,$0101,$0101,$0101,$0100,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$FFFF,$FFFF,$FFFF,$FFFE
	dc.w	$FEFE,$FEFE,$FEFE,$FEFD,$FDFD,$FDFD,$FDFD,$FDFD
	dc.w	$FCFC,$FCFC,$FCFC,$FCFC,$FCFC,$FCFC,$FCFB,$FBFB
	dc.w	$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB
	dc.w	$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB,$FBFB
	dc.w	$FBFB,$FBFB,$FCFC,$FCFC,$FCFC,$FCFC,$FCFC,$FCFC
	dc.w	$FCFD,$FDFD,$FDFD,$FDFD,$FDFD,$FEFE,$FEFE,$FEFE
	dc.w	$FEFE,$FFFF,$FFFF,$FFFF,$FF00,$0000,$0000,$0000
	dc.w	$0000,$0000,$0001,$0101,$0101,$0202,$0202,$0203
	dc.w	$0303,$0303,$0404,$0404,$0404,$0505,$0505,$0505
	dc.w	$0606,$0606,$0606,$0606,$0707,$0707,$0707,$0707
	dc.w	$0707,$0808,$0808,$0808,$0808,$0808,$0808,$0808
	dc.w	$0808,$0808,$0808,$0808,$0808,$0808,$0808,$0807
	dc.w	$0707,$0707,$0707,$0707,$0706,$0606,$0606,$0606
	dc.w	$0605,$0505,$0505,$0504,$0404,$0404,$0403,$0303
	dc.w	$0303,$0202,$0202,$0201,$0101,$0101,$0000,$0000
	dc.w	$0000,$0000,$00FF,$FFFF,$FFFF,$FEFE,$FEFE,$FEFD
	dc.w	$FDFD,$FDFD,$FCFC,$FCFC,$FCFC,$FBFB,$FBFB,$FBFB
	dc.w	$FAFA,$FAFA,$FAFA,$FAFA,$F9F9,$F9F9,$F9F9,$F9F9
	dc.w	$F9F9,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8
	dc.w	$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F8,$F8F9
	dc.w	$F9F9,$F9F9,$F9F9,$F9F9,$F9FA,$FAFA,$FAFA,$FAFA
	dc.w	$FAFB,$FBFB,$FBFB,$FBFC,$FCFC,$FCFC,$FCFD,$FDFD
	dc.w	$FDFD,$FEFE,$FEFE,$FEFF,$FFFF,$FFFF,$0000,$0000
	dc.w	$0000,$0000,$0101,$0101,$0202,$0203,$0303,$0304
	dc.w	$0404,$0405,$0505,$0506,$0606,$0606,$0707,$0707
	dc.w	$0808,$0808,$0808,$0909,$0909,$0909,$090A,$0A0A
	dc.w	$0A0A,$0A0A,$0A0A,$0A0B,$0B0B,$0B0B,$0B0B,$0B0B
	dc.w	$0B0B,$0B0B,$0B0B,$0B0B,$0B0B,$0A0A,$0A0A,$0A0A
	dc.w	$0A0A,$0A0A,$0909,$0909,$0909,$0908,$0808,$0808
	dc.w	$0807,$0707,$0706,$0606,$0606,$0505,$0505,$0404
	dc.w	$0404,$0303,$0303,$0202,$0201,$0101,$0100,$0000
	dc.w	$0000,$0000,$FFFF,$FFFF,$FEFE,$FEFD,$FDFD,$FDFC
	dc.w	$FCFC,$FCFB,$FBFB,$FBFA,$FAFA,$FAFA,$F9F9,$F9F9
	dc.w	$F8F8,$F8F8,$F8F8,$F7F7,$F7F7,$F7F7,$F7F6,$F6F6
	dc.w	$F6F6,$F6F6,$F6F6,$F6F5,$F5F5,$F5F5,$F5F5,$F5F5
	dc.w	$F5F5,$F5F5,$F5F5,$F5F5,$F5F5,$F6F6,$F6F6,$F6F6
	dc.w	$F6F6,$F6F6,$F7F7,$F7F7,$F7F7,$F7F8,$F8F8,$F8F8
	dc.w	$F8F9,$F9F9,$F9FA,$FAFA,$FAFA,$FBFB,$FBFB,$FCFC
	dc.w	$FCFC,$FDFD,$FDFD,$FEFE,$FEFF,$FFFF,$FF00,$0000
	dc.w	$0000,$0001,$0101,$0202,$0203,$0303,$0404,$0405
	dc.w	$0505,$0606,$0606,$0707,$0708,$0808,$0809,$0909
	dc.w	$0A0A,$0A0A,$0A0B,$0B0B,$0B0B,$0C0C,$0C0C,$0C0C
	dc.w	$0D0D,$0D0D,$0D0D,$0D0D,$0D0D,$0E0E,$0E0E,$0E0E
	dc.w	$0E0E,$0E0E,$0E0E,$0E0D,$0D0D,$0D0D,$0D0D,$0D0D
	dc.w	$0D0C,$0C0C,$0C0C,$0C0B,$0B0B,$0B0B,$0A0A,$0A0A
	dc.w	$0A09,$0909,$0808,$0808,$0707,$0706,$0606,$0605
	dc.w	$0505,$0404,$0403,$0303,$0202,$0201,$0101,$0000
	dc.w	$0000,$00FF,$FFFF,$FEFE,$FEFD,$FDFD,$FCFC,$FCFB
	dc.w	$FBFB,$FAFA,$FAFA,$F9F9,$F9F8,$F8F8,$F8F7,$F7F7
	dc.w	$F6F6,$F6F6,$F6F5,$F5F5,$F5F5,$F4F4,$F4F4,$F4F4
	dc.w	$F3F3,$F3F3,$F3F3,$F3F3,$F3F3,$F2F2,$F2F2,$F2F2
	dc.w	$F2F2,$F2F2,$F2F2,$F2F3,$F3F3,$F3F3,$F3F3,$F3F3
	dc.w	$F3F4,$F4F4,$F4F4,$F4F5,$F5F5,$F5F5,$F6F6,$F6F6
	dc.w	$F6F7,$F7F7,$F8F8,$F8F8,$F9F9,$F9FA,$FAFA,$FAFB
	dc.w	$FBFB,$FCFC,$FCFD,$FDFD,$FEFE,$FEFF,$FFFF,$0000
	dc.w	$0000,$0001,$0102,$0202,$0303,$0404,$0405,$0506
	dc.w	$0606,$0707,$0808,$0809,$0909,$0A0A,$0A0B,$0B0B
	dc.w	$0C0C,$0C0C,$0D0D,$0D0D,$0E0E,$0E0E,$0E0F,$0F0F
	dc.w	$0F0F,$1010,$1010,$1010,$1010,$1010,$1010,$1010
	dc.w	$1010,$1010,$1010,$1010,$1010,$1010,$1010,$100F
	dc.w	$0F0F,$0F0F,$0E0E,$0E0E,$0E0D,$0D0D,$0D0C,$0C0C
	dc.w	$0C0B,$0B0B,$0A0A,$0A09,$0909,$0808,$0807,$0706
	dc.w	$0606,$0505,$0404,$0403,$0302,$0202,$0101,$0000
	dc.w	$0000,$00FF,$FFFE,$FEFE,$FDFD,$FCFC,$FCFB,$FBFA
	dc.w	$FAFA,$F9F9,$F8F8,$F8F7,$F7F7,$F6F6,$F6F5,$F5F5
	dc.w	$F4F4,$F4F4,$F3F3,$F3F3,$F2F2,$F2F2,$F2F1,$F1F1
	dc.w	$F1F1,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0
	dc.w	$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F0,$F0F1
	dc.w	$F1F1,$F1F1,$F2F2,$F2F2,$F2F3,$F3F3,$F3F4,$F4F4
	dc.w	$F4F5,$F5F5,$F6F6,$F6F7,$F7F7,$F8F8,$F8F9,$F9FA
	dc.w	$FAFA,$FBFB,$FCFC,$FCFD,$FDFE,$FEFE,$FFFF,$0000
	dc.w	$0000,$0001,$0102,$0203,$0304,$0405,$0506,$0607
	dc.w	$0708,$0808,$0909,$0A0A,$0B0B,$0B0C,$0C0C,$0D0D
	dc.w	$0E0E,$0E0F,$0F0F,$0F10,$1010,$1111,$1111,$1112
	dc.w	$1212,$1212,$1213,$1313,$1313,$1313,$1313,$1313
	dc.w	$1313,$1313,$1313,$1313,$1313,$1313,$1212,$1212
	dc.w	$1212,$1111,$1111,$1110,$1010,$0F0F,$0F0F,$0E0E
	dc.w	$0E0D,$0D0C,$0C0C,$0B0B,$0B0A,$0A09,$0908,$0808
	dc.w	$0707,$0606,$0505,$0404,$0303,$0202,$0101,$0000
	dc.w	$0000,$00FF,$FFFE,$FEFD,$FDFC,$FCFB,$FBFA,$FAF9
	dc.w	$F9F8,$F8F8,$F7F7,$F6F6,$F5F5,$F5F4,$F4F4,$F3F3
	dc.w	$F2F2,$F2F1,$F1F1,$F1F0,$F0F0,$EFEF,$EFEF,$EFEE
	dc.w	$EEEE,$EEEE,$EEED,$EDED,$EDED,$EDED,$EDED,$EDED
	dc.w	$EDED,$EDED,$EDED,$EDED,$EDED,$EDED,$EEEE,$EEEE
	dc.w	$EEEE,$EFEF,$EFEF,$EFF0,$F0F0,$F1F1,$F1F1,$F2F2
	dc.w	$F2F3,$F3F4,$F4F4,$F5F5,$F5F6,$F6F7,$F7F8,$F8F8
	dc.w	$F9F9,$FAFA,$FBFB,$FCFC,$FDFD,$FEFE,$FFFF,$0000
	dc.w	$0000,$0101,$0202,$0303,$0404,$0506,$0607,$0708
	dc.w	$0809,$090A,$0A0B,$0B0C,$0C0D,$0D0D,$0E0E,$0F0F
	dc.w	$1010,$1011,$1111,$1212,$1213,$1313,$1314,$1414
	dc.w	$1415,$1515,$1515,$1516,$1616,$1616,$1616,$1616
	dc.w	$1616,$1616,$1616,$1616,$1616,$1515,$1515,$1515
	dc.w	$1414,$1414,$1313,$1313,$1212,$1211,$1111,$1010
	dc.w	$100F,$0F0E,$0E0D,$0D0D,$0C0C,$0B0B,$0A0A,$0909
	dc.w	$0808,$0707,$0606,$0504,$0403,$0302,$0201,$0100
	dc.w	$0000,$FFFF,$FEFE,$FDFD,$FCFC,$FBFA,$FAF9,$F9F8
	dc.w	$F8F7,$F7F6,$F6F5,$F5F4,$F4F3,$F3F3,$F2F2,$F1F1
	dc.w	$F0F0,$F0EF,$EFEF,$EEEE,$EEED,$EDED,$EDEC,$ECEC
	dc.w	$ECEB,$EBEB,$EBEB,$EBEA,$EAEA,$EAEA,$EAEA,$EAEA
	dc.w	$EAEA,$EAEA,$EAEA,$EAEA,$EAEA,$EBEB,$EBEB,$EBEB
	dc.w	$ECEC,$ECEC,$EDED,$EDED,$EEEE,$EEEF,$EFEF,$F0F0
	dc.w	$F0F1,$F1F2,$F2F3,$F3F3,$F4F4,$F5F5,$F6F6,$F7F7
	dc.w	$F8F8,$F9F9,$FAFA,$FBFC,$FCFD,$FDFE,$FEFF,$FF00
	dc.w	$0000,$0101,$0203,$0304,$0405,$0606,$0707,$0809
	dc.w	$090A,$0A0B,$0C0C,$0D0D,$0E0E,$0F0F,$1010,$1111
	dc.w	$1212,$1213,$1314,$1414,$1515,$1516,$1616,$1717
	dc.w	$1717,$1818,$1818,$1818,$1919,$1919,$1919,$1919
	dc.w	$1919,$1919,$1919,$1919,$1918,$1818,$1818,$1817
	dc.w	$1717,$1716,$1616,$1515,$1514,$1414,$1313,$1212
	dc.w	$1211,$1110,$100F,$0F0E,$0E0D,$0D0C,$0C0B,$0A0A
	dc.w	$0909,$0807,$0706,$0605,$0404,$0303,$0201,$0100
	dc.w	$0000,$FFFF,$FEFD,$FDFC,$FCFB,$FAFA,$F9F9,$F8F7
	dc.w	$F7F6,$F6F5,$F4F4,$F3F3,$F2F2,$F1F1,$F0F0,$EFEF
	dc.w	$EEEE,$EEED,$EDEC,$ECEC,$EBEB,$EBEA,$EAEA,$E9E9
	dc.w	$E9E9,$E8E8,$E8E8,$E8E8,$E7E7,$E7E7,$E7E7,$E7E7
	dc.w	$E7E7,$E7E7,$E7E7,$E7E7,$E7E8,$E8E8,$E8E8,$E8E9
	dc.w	$E9E9,$E9EA,$EAEA,$EBEB,$EBEC,$ECEC,$EDED,$EEEE
	dc.w	$EEEF,$EFF0,$F0F1,$F1F2,$F2F3,$F3F4,$F4F5,$F6F6
	dc.w	$F7F7,$F8F9,$F9FA,$FAFB,$FCFC,$FDFD,$FEFF,$FF00
	dc.w	$0000,$0102,$0203,$0404,$0506,$0607,$0808,$090A
	dc.w	$0A0B,$0C0C,$0D0D,$0E0F,$0F10,$1011,$1112,$1313
	dc.w	$1414,$1415,$1516,$1617,$1717,$1818,$1819,$1919
	dc.w	$1A1A,$1A1A,$1B1B,$1B1B,$1B1B,$1C1C,$1C1C,$1C1C
	dc.w	$1C1C,$1C1C,$1C1C,$1C1B,$1B1B,$1B1B,$1B1A,$1A1A
	dc.w	$1A19,$1919,$1818,$1817,$1717,$1616,$1515,$1414
	dc.w	$1413,$1312,$1111,$1010,$0F0F,$0E0D,$0D0C,$0C0B
	dc.w	$0A0A,$0908,$0807,$0606,$0504,$0403,$0202,$0100
	dc.w	$0000,$FFFE,$FEFD,$FCFC,$FBFA,$FAF9,$F8F8,$F7F6
	dc.w	$F6F5,$F4F4,$F3F3,$F2F1,$F1F0,$F0EF,$EFEE,$EDED
	dc.w	$ECEC,$ECEB,$EBEA,$EAE9,$E9E9,$E8E8,$E8E7,$E7E7
	dc.w	$E6E6,$E6E6,$E5E5,$E5E5,$E5E5,$E4E4,$E4E4,$E4E4
	dc.w	$E4E4,$E4E4,$E4E4,$E4E5,$E5E5,$E5E5,$E5E6,$E6E6
	dc.w	$E6E7,$E7E7,$E8E8,$E8E9,$E9E9,$EAEA,$EBEB,$ECEC
	dc.w	$ECED,$EDEE,$EFEF,$F0F0,$F1F1,$F2F3,$F3F4,$F4F5
	dc.w	$F6F6,$F7F8,$F8F9,$FAFA,$FBFC,$FCFD,$FEFE,$FF00
	dc.w	$0000,$0102,$0303,$0405,$0606,$0708,$0909,$0A0B
	dc.w	$0B0C,$0D0E,$0E0F,$1010,$1111,$1213,$1314,$1415
	dc.w	$1616,$1717,$1818,$1919,$191A,$1A1B,$1B1B,$1C1C
	dc.w	$1C1D,$1D1D,$1D1E,$1E1E,$1E1E,$1E1E,$1F1F,$1F1F
	dc.w	$1F1F,$1F1F,$1F1E,$1E1E,$1E1E,$1E1E,$1D1D,$1D1D
	dc.w	$1C1C,$1C1B,$1B1B,$1A1A,$1919,$1918,$1817,$1716
	dc.w	$1615,$1414,$1313,$1211,$1110,$100F,$0E0E,$0D0C
	dc.w	$0B0B,$0A09,$0908,$0706,$0605,$0403,$0302,$0100
	dc.w	$0000,$FFFE,$FDFD,$FCFB,$FAFA,$F9F8,$F7F7,$F6F5
	dc.w	$F5F4,$F3F2,$F2F1,$F0F0,$EFEF,$EEED,$EDEC,$ECEB
	dc.w	$EAEA,$E9E9,$E8E8,$E7E7,$E7E6,$E6E5,$E5E5,$E4E4
	dc.w	$E4E3,$E3E3,$E3E2,$E2E2,$E2E2,$E2E2,$E1E1,$E1E1
	dc.w	$E1E1,$E1E1,$E1E2,$E2E2,$E2E2,$E2E2,$E3E3,$E3E3
	dc.w	$E4E4,$E4E5,$E5E5,$E6E6,$E7E7,$E7E8,$E8E9,$E9EA
	dc.w	$EAEB,$ECEC,$EDED,$EEEF,$EFF0,$F0F1,$F2F2,$F3F4
	dc.w	$F5F5,$F6F7,$F7F8,$F9FA,$FAFB,$FCFD,$FDFE,$FF00
	dc.w	$0000,$0102,$0304,$0405,$0607,$0809,$090A,$0B0C
	dc.w	$0D0D,$0E0F,$1010,$1112,$1213,$1414,$1516,$1617
	dc.w	$1818,$1919,$1A1A,$1B1B,$1C1C,$1D1D,$1D1E,$1E1F
	dc.w	$1F1F,$2020,$2020,$2021,$2121,$2121,$2121,$2121
	dc.w	$2121,$2121,$2121,$2121,$2121,$2020,$2020,$201F
	dc.w	$1F1F,$1E1E,$1D1D,$1D1C,$1C1B,$1B1A,$1A19,$1918
	dc.w	$1817,$1616,$1514,$1413,$1212,$1110,$100F,$0E0D
	dc.w	$0D0C,$0B0A,$0909,$0807,$0605,$0404,$0302,$0100
	dc.w	$0000,$FFFE,$FDFC,$FCFB,$FAF9,$F8F7,$F7F6,$F5F4
	dc.w	$F3F3,$F2F1,$F0F0,$EFEE,$EEED,$ECEC,$EBEA,$EAE9
	dc.w	$E8E8,$E7E7,$E6E6,$E5E5,$E4E4,$E3E3,$E3E2,$E2E1
	dc.w	$E1E1,$E0E0,$E0E0,$E0DF,$DFDF,$DFDF,$DFDF,$DFDF
	dc.w	$DFDF,$DFDF,$DFDF,$DFDF,$DFDF,$E0E0,$E0E0,$E0E1
	dc.w	$E1E1,$E2E2,$E3E3,$E3E4,$E4E5,$E5E6,$E6E7,$E7E8
	dc.w	$E8E9,$EAEA,$EBEC,$ECED,$EEEE,$EFF0,$F0F1,$F2F3
	dc.w	$F3F4,$F5F6,$F7F7,$F8F9,$FAFB,$FCFC,$FDFE,$FF00
	dc.w	$0000,$0102,$0304,$0506,$0708,$0809,$0A0B,$0C0D
	dc.w	$0E0E,$0F10,$1112,$1213,$1415,$1516,$1718,$1819
	dc.w	$1A1A,$1B1B,$1C1D,$1D1E,$1E1F,$1F20,$2020,$2121
	dc.w	$2222,$2222,$2323,$2323,$2424,$2424,$2424,$2424
	dc.w	$2424,$2424,$2424,$2424,$2423,$2323,$2322,$2222
	dc.w	$2221,$2120,$2020,$1F1F,$1E1E,$1D1D,$1C1B,$1B1A
	dc.w	$1A19,$1818,$1716,$1515,$1413,$1212,$1110,$0F0E
	dc.w	$0E0D,$0C0B,$0A09,$0808,$0706,$0504,$0302,$0100
	dc.w	$0000,$FFFE,$FDFC,$FBFA,$F9F8,$F8F7,$F6F5,$F4F3
	dc.w	$F2F2,$F1F0,$EFEE,$EEED,$ECEB,$EBEA,$E9E8,$E8E7
	dc.w	$E6E6,$E5E5,$E4E3,$E3E2,$E2E1,$E1E0,$E0E0,$DFDF
	dc.w	$DEDE,$DEDE,$DDDD,$DDDD,$DCDC,$DCDC,$DCDC,$DCDC
	dc.w	$DCDC,$DCDC,$DCDC,$DCDC,$DCDD,$DDDD,$DDDE,$DEDE
	dc.w	$DEDF,$DFE0,$E0E0,$E1E1,$E2E2,$E3E3,$E4E5,$E5E6
	dc.w	$E6E7,$E8E8,$E9EA,$EBEB,$ECED,$EEEE,$EFF0,$F1F2
	dc.w	$F2F3,$F4F5,$F6F7,$F8F8,$F9FA,$FBFC,$FDFE,$FF00
	dc.w	$0000,$0102,$0304,$0506,$0708,$090A,$0B0C,$0D0E
	dc.w	$0F10,$1011,$1213,$1415,$1616,$1718,$1919,$1A1B
	dc.w	$1C1C,$1D1E,$1E1F,$1F20,$2021,$2222,$2223,$2324
	dc.w	$2425,$2525,$2526,$2626,$2627,$2727,$2727,$2727
	dc.w	$2727,$2727,$2727,$2727,$2626,$2626,$2525,$2525
	dc.w	$2424,$2323,$2222,$2221,$2020,$1F1F,$1E1E,$1D1C
	dc.w	$1C1B,$1A19,$1918,$1716,$1615,$1413,$1211,$1010
	dc.w	$0F0E,$0D0C,$0B0A,$0908,$0706,$0504,$0302,$0100
	dc.w	$0000,$FFFE,$FDFC,$FBFA,$F9F8,$F7F6,$F5F4,$F3F2
	dc.w	$F1F0,$F0EF,$EEED,$ECEB,$EAEA,$E9E8,$E7E7,$E6E5
	dc.w	$E4E4,$E3E2,$E2E1,$E1E0,$E0DF,$DEDE,$DEDD,$DDDC
	dc.w	$DCDB,$DBDB,$DBDA,$DADA,$DAD9,$D9D9,$D9D9,$D9D9
	dc.w	$D9D9,$D9D9,$D9D9,$D9D9,$DADA,$DADA,$DBDB,$DBDB
	dc.w	$DCDC,$DDDD,$DEDE,$DEDF,$E0E0,$E1E1,$E2E2,$E3E4
	dc.w	$E4E5,$E6E7,$E7E8,$E9EA,$EAEB,$ECED,$EEEF,$F0F0
	dc.w	$F1F2,$F3F4,$F5F6,$F7F8,$F9FA,$FBFC,$FDFE,$FF00
	dc.w	$0001,$0203,$0405,$0607,$0809,$0A0B,$0C0D,$0E0F
	dc.w	$1011,$1213,$1414,$1516,$1718,$191A,$1A1B,$1C1D
	dc.w	$1E1E,$1F20,$2021,$2222,$2323,$2424,$2525,$2626
	dc.w	$2727,$2828,$2828,$2929,$2929,$2A2A,$2A2A,$2A2A
	dc.w	$2A2A,$2A2A,$2A2A,$2A29,$2929,$2928,$2828,$2827
	dc.w	$2726,$2625,$2524,$2423,$2322,$2221,$2020,$1F1E
	dc.w	$1E1D,$1C1B,$1A1A,$1918,$1716,$1514,$1413,$1211
	dc.w	$100F,$0E0D,$0C0B,$0A09,$0807,$0605,$0403,$0201
	dc.w	$00FF,$FEFD,$FCFB,$FAF9,$F8F7,$F6F5,$F4F3,$F2F1
	dc.w	$F0EF,$EEED,$ECEC,$EBEA,$E9E8,$E7E6,$E6E5,$E4E3
	dc.w	$E2E2,$E1E0,$E0DF,$DEDE,$DDDD,$DCDC,$DBDB,$DADA
	dc.w	$D9D9,$D8D8,$D8D8,$D7D7,$D7D7,$D6D6,$D6D6,$D6D6
	dc.w	$D6D6,$D6D6,$D6D6,$D6D7,$D7D7,$D7D8,$D8D8,$D8D9
	dc.w	$D9DA,$DADB,$DBDC,$DCDD,$DDDE,$DEDF,$E0E0,$E1E2
	dc.w	$E2E3,$E4E5,$E6E6,$E7E8,$E9EA,$EBEC,$ECED,$EEEF
	dc.w	$F0F1,$F2F3,$F4F5,$F6F7,$F8F9,$FAFB,$FCFD,$FEFF

;	text

stopsnd:
	movem.l	d0-d1/a0-a1,-(a7)
	pea	P30e0(pc)
	move	#38,-(a7)
	trap	#14
	addq.l	#6,a7
	movem.l	(a7)+,d0-d1/a0-a1
	rts
P30e0:	ori	#$0700,sr
	move.b	#$07,GISELECT
	move.b	#$7f,GIDATA
	move.l	TIMAVEC,old134
	rts

L30f6:	clr.l	P3ae2
	bclr	#5,IMRA
	bclr	#5,IPRA
	bclr	#5,ISRA
	move	(a7)+,d1
	move.l	(a7)+,d0
	movea.l	(a7)+,a0
	move.b	#$07,GISELECT
	move.b	#$7f,GIDATA
	move.l	old134,TIMAVEC
	rte

opwaves:
	move.l	a0,-(a7)
	move.l	d0,-(a7)
L3144:	move	d1,-(a7)
	subq.b	#1,P3ae6
	bpl	L3210
	move.b	use_rate(pc),P3ae6
	movea.l	P3ae2(pc),a0
	move.b	(a0)+,P3ae7
	beq	L30f6
	move.b	(a0)+,d0
	beq	L31cc
	move.b	#$0a,GISELECT
	move.b	d0,GIDATA
	move.b	#$06,GISELECT
	move.b	(a0)+,GIDATA
	move.b	(a0)+,L329a+3
	move.b	(a0)+,L32b2+2
	move.b	(a0)+,L32a2+3
	move.b	(a0)+,L32b6+2
	move.b	(a0)+,L32aa+3
	move.b	(a0)+,L32ba+2
	move.l	a0,P3ae2
	move.l	#ophiss,TIMAVEC
	move.b	#$07,GISELECT
	move.b	#$5f,GIDATA
	bra	L3278
L31cc:	addq.l	#1,a0
	move.b	(a0)+,L3238+3
	move.b	(a0)+,L3250+2
	move.b	(a0)+,L3240+3
	move.b	(a0)+,L3254+2
	move.b	(a0)+,L3248+3
	move.b	(a0)+,L3258+2
	move.l	#opwaves,TIMAVEC
	move.b	#$07,GISELECT
	move.b	#$7f,GIDATA
	move.l	a0,P3ae2
L3210:	subq.b	#1,P3ae8
	bpl	L3234
	move.b	P3ae7(pc),P3ae8
	moveq	#$00,d0
	move.b	d0,L3250+3
	move.b	d0,L3254+3
	move.b	d0,L3258+3
L3234:	lea	P20ca(pc),a0
L3238:	addi.b	#$00,L3250+3
L3240:	addi.b	#$00,L3254+3
L3248:	addi.b	#$00,L3258+3
L3250:	move.b	$1000(a0),d0
L3254:	add.b	$1000(a0),d0
L3258:	add.b	$1000(a0),d0
	andi.w	#$ff,d0
	lsl.w	#3,d0
	lea	P32e2(pc,d0.w),a0
	move.l	(a0)+,d0
	move	(a0),d1
	lea	GISELECT,a0
	movep.l	d0,0(a0)
	movep.w	d1,0(a0)
L3278:	move	(a7)+,d1
	move.l	(a7)+,d0
	movea.l	(a7)+,a0
	bclr	#5,ISRA
	rte

ophiss:
	move.l	a0,-(a7)
	move.l	d0,-(a7)
	subq.b	#1,P3ae6
	bmi	L3144
	lea	P20ca(pc),a0
L329a:	addi.b	#$00,L32b2+3
L32a2:	addi.b	#$00,L32b6+3
L32aa:	addi.b	#$00,L32ba+3
L32b2:	move.b	$1000(a0),d0
L32b6:	add.b	$1000(a0),d0
L32ba:	add.b	$1000(a0),d0
	andi.w	#$00ff,d0
	lsl.w	#3,d0
	lea	P32e2(pc,d0.w),a0
	move.l	(a0)+,d0
	lea	GISELECT,a0
	movep.l	d0,0(a0)
	move.l	(a7)+,d0
	movea.l	(a7)+,a0
	bclr	#5,ISRA
	rte

P32e2:	dc.b	$08,$0c,$09,$0b,$0a,$09,$00,$00,$08,$0c,$09,$0b,$0a
	dc.b	$09,$00,$00,$08,$0d,$09,$08,$0a,$08,$00,$00,$08,$0b
	dc.b	$09,$0b,$0a,$0b,$00,$00,$08,$0d,$09,$09,$0a,$05,$00
	dc.b	$00,$08,$0c,$09,$0b,$0a,$08,$00,$00,$08,$0d,$09,$09
	dc.b	$0a,$02,$00,$00,$08,$0d,$09,$08,$0a,$06,$00,$00,$08
	dc.b	$0c,$09,$0b,$0a,$07,$00,$00,$08,$0d,$09,$07,$0a,$07
	dc.b	$00,$00,$08,$0c,$09,$0b,$0a,$06,$00,$00,$08,$0c,$09
	dc.b	$0a,$0a,$09,$00,$00,$08,$0b,$09,$0b,$0a,$0a,$00,$00
	dc.b	$08,$0c,$09,$0b,$0a,$02,$00,$00,$08,$0c,$09,$0b,$0a
	dc.b	$00,$00,$00,$08,$0c,$09,$0a,$0a,$08,$00,$00,$08,$0d
	dc.b	$09,$06,$0a,$04,$00,$00,$08,$0d,$09,$05,$0a,$05,$00
	dc.b	$00,$08,$0d,$09,$05,$0a,$04,$00,$00,$08,$0c,$09,$09
	dc.b	$0a,$09,$00,$00,$08,$0d,$09,$04,$0a,$03,$00,$00,$08
	dc.b	$0b,$09,$0b,$0a,$09,$00,$00,$08,$0c,$09,$0a,$0a,$05
	dc.b	$00,$00,$08,$0b,$09,$0a,$0a,$0a,$00,$00,$08,$0c,$09
	dc.b	$09,$0a,$08,$00,$00,$08,$0b,$09,$0b,$0a,$08,$00,$00
	dc.b	$08,$0c,$09,$0a,$0a,$00,$00,$00,$08,$0c,$09,$0a,$0a
	dc.b	$00,$00,$00,$08,$0c,$09,$09,$0a,$07,$00,$00,$08,$0b
	dc.b	$09,$0b,$0a,$07,$00,$00,$08,$0c,$09,$09,$0a,$06,$00
	dc.b	$00,$08,$0b,$09,$0b,$0a,$06,$00,$00,$08,$0b,$09,$0a
	dc.b	$0a,$09,$00,$00,$08,$0b,$09,$0b,$0a,$05,$00,$00,$08
	dc.b	$0a,$09,$0a,$0a,$0a,$00,$00,$08,$0b,$09,$0b,$0a,$02
	dc.b	$00,$00,$08,$0b,$09,$0a,$0a,$08,$00,$00,$08,$0c,$09
	dc.b	$07,$0a,$07,$00,$00,$08,$0c,$09,$08,$0a,$04,$00,$00
	dc.b	$08,$0c,$09,$07,$0a,$06,$00,$00,$08,$0b,$09,$09,$0a
	dc.b	$09,$00,$00,$08,$0c,$09,$06,$0a,$06,$00,$00,$08,$0a
	dc.b	$09,$0a,$0a,$09,$00,$00,$08,$0c,$09,$07,$0a,$03,$00
	dc.b	$00,$08,$0b,$09,$0a,$0a,$05,$00,$00,$08,$0b,$09,$09
	dc.b	$0a,$08,$00,$00,$08,$0b,$09,$0a,$0a,$03,$00,$00,$08
	dc.b	$0a,$09,$0a,$0a,$08,$00,$00,$08,$0b,$09,$0a,$0a,$00
	dc.b	$00,$00,$08,$0b,$09,$09,$0a,$07,$00,$00,$08,$0b,$09
	dc.b	$08,$0a,$08,$00,$00,$08,$0a,$09,$0a,$0a,$07,$00,$00
	dc.b	$08,$0a,$09,$09,$0a,$09,$00,$00,$08,$0c,$09,$01,$0a
	dc.b	$01,$00,$00,$08,$0a,$09,$0a,$0a,$06,$00,$00,$08,$0b
	dc.b	$09,$08,$0a,$07,$00,$00,$08,$0a,$09,$0a,$0a,$05,$00
	dc.b	$00,$08,$0a,$09,$09,$0a,$08,$00,$00,$08,$0a,$09,$0a
	dc.b	$0a,$02,$00,$00,$08,$0a,$09,$0a,$0a,$01,$00,$00,$08
	dc.b	$0a,$09,$0a,$0a,$00,$00,$00,$08,$09,$09,$09,$0a,$09
	dc.b	$00,$00,$08,$0a,$09,$08,$0a,$08,$00,$00,$08,$0b,$09
	dc.b	$08,$0a,$01,$00,$00,$08,$0a,$09,$09,$0a,$06,$00,$00
	dc.b	$08,$0b,$09,$07,$0a,$04,$00,$00,$08,$0a,$09,$09,$0a
	dc.b	$05,$00,$00,$08,$09,$09,$09,$0a,$08,$00,$00,$08,$0a
	dc.b	$09,$09,$0a,$03,$00,$00,$08,$0a,$09,$08,$0a,$06,$00
	dc.b	$00,$08,$0a,$09,$09,$0a,$00,$00,$00,$08,$09,$09,$09
	dc.b	$0a,$07,$00,$00,$08,$09,$09,$08,$0a,$08,$00,$00,$08
	dc.b	$0a,$09,$08,$0a,$04,$00,$00,$08,$09,$09,$09,$0a,$06
	dc.b	$00,$00,$08,$0a,$09,$08,$0a,$01,$00,$00,$08,$09,$09
	dc.b	$09,$0a,$05,$00,$00,$08,$09,$09,$08,$0a,$07,$00,$00
	dc.b	$08,$08,$09,$08,$0a,$08,$00,$00,$08,$09,$09,$09,$0a
	dc.b	$02,$00,$00,$08,$09,$09,$08,$0a,$06,$00,$00,$08,$09
	dc.b	$09,$09,$0a,$00,$00,$00,$08,$09,$09,$07,$0a,$07,$00
	dc.b	$00,$08,$08,$09,$08,$0a,$07,$00,$00,$08,$09,$09,$07
	dc.b	$0a,$06,$00,$00,$08,$09,$09,$08,$0a,$02,$00,$00,$08
	dc.b	$08,$09,$08,$0a,$06,$00,$00,$08,$09,$09,$06,$0a,$06
	dc.b	$00,$00,$08,$08,$09,$07,$0a,$07,$00,$00,$08,$08,$09
	dc.b	$08,$0a,$04,$00,$00,$08,$08,$09,$07,$0a,$06,$00,$00
	dc.b	$08,$08,$09,$08,$0a,$02,$00,$00,$08,$07,$09,$07,$0a
	dc.b	$07,$00,$00,$08,$08,$09,$06,$0a,$06,$00,$00,$08,$08
	dc.b	$09,$07,$0a,$04,$00,$00,$08,$07,$09,$07,$0a,$06,$00
	dc.b	$00,$08,$08,$09,$06,$0a,$05,$00,$00,$08,$08,$09,$06
	dc.b	$0a,$04,$00,$00,$08,$07,$09,$06,$0a,$06,$00,$00,$08
	dc.b	$07,$09,$07,$0a,$04,$00,$00,$08,$08,$09,$05,$0a,$04
	dc.b	$00,$00,$08,$06,$09,$06,$0a,$06,$00,$00,$08,$07,$09
	dc.b	$06,$0a,$04,$00,$00,$08,$07,$09,$05,$0a,$05,$00,$00
	dc.b	$08,$06,$09,$06,$0a,$05,$00,$00,$08,$06,$09,$06,$0a
	dc.b	$04,$00,$00,$08,$06,$09,$05,$0a,$05,$00,$00,$08,$06
	dc.b	$09,$06,$0a,$02,$00,$00,$08,$06,$09,$05,$0a,$04,$00
	dc.b	$00,$08,$05,$09,$05,$0a,$05,$00,$00,$08,$06,$09,$05
	dc.b	$0a,$02,$00,$00,$08,$05,$09,$05,$0a,$04,$00,$00,$08
	dc.b	$05,$09,$04,$0a,$04,$00,$00,$08,$05,$09,$05,$0a,$02
	dc.b	$00,$00,$08,$04,$09,$04,$0a,$04,$00,$00,$08,$04,$09
	dc.b	$04,$0a,$03,$00,$00,$08,$04,$09,$04,$0a,$02,$00,$00
	dc.b	$08,$04,$09,$03,$0a,$03,$00,$00,$08,$03,$09,$03,$0a
	dc.b	$03,$00,$00,$08,$03,$09,$03,$0a,$02,$00,$00,$08,$03
	dc.b	$09,$02,$0a,$02,$00,$00,$08,$02,$09,$02,$0a,$02,$00
	dc.b	$00,$08,$02,$09,$02,$0a,$01,$00,$00,$08,$01,$09,$01
	dc.b	$0a,$01,$00,$00,$08,$02,$09,$01,$0a,$00,$00,$00,$08
	dc.b	$01,$09,$01,$0a,$00,$00,$00,$08,$01,$09,$00,$0a,$00
	dc.b	$00,$00,$08,$00,$09,$00,$0a,$00,$00,$00,$08,$0e,$09
	dc.b	$0d,$0a,$0c,$00,$00,$08,$0f,$09,$03,$0a,$00,$00,$00
	dc.b	$08,$0f,$09,$03,$0a,$00,$00,$00,$08,$0f,$09,$03,$0a
	dc.b	$00,$00,$00,$08,$0f,$09,$03,$0a,$00,$00,$00,$08,$0f
	dc.b	$09,$03,$0a,$00,$00,$00,$08,$0f,$09,$03,$0a,$00,$00
	dc.b	$00,$08,$0e,$09,$0d,$0a,$0b,$00,$00,$08,$0e,$09,$0d
	dc.b	$0a,$0b,$00,$00,$08,$0e,$09,$0d,$0a,$0b,$00,$00,$08
	dc.b	$0e,$09,$0d,$0a,$0b,$00,$00,$08,$0e,$09,$0d,$0a,$0b
	dc.b	$00,$00,$08,$0e,$09,$0d,$0a,$0b,$00,$00,$08,$0e,$09
	dc.b	$0d,$0a,$0b,$00,$00,$08,$0e,$09,$0d,$0a,$0a,$00,$00
	dc.b	$08,$0e,$09,$0d,$0a,$0a,$00,$00,$08,$0e,$09,$0d,$0a
	dc.b	$0a,$00,$00,$08,$0e,$09,$0d,$0a,$0a,$00,$00,$08,$0e
	dc.b	$09,$0c,$0a,$0c,$00,$00,$08,$0e,$09,$0d,$0a,$00,$00
	dc.b	$00,$08,$0d,$09,$0d,$0a,$0d,$00,$00,$08,$0d,$09,$0d
	dc.b	$0a,$0d,$00,$00,$08,$0d,$09,$0d,$0a,$0d,$00,$00,$08
	dc.b	$0d,$09,$0d,$0a,$0d,$00,$00,$08,$0d,$09,$0d,$0a,$0d
	dc.b	$00,$00,$08,$0d,$09,$0d,$0a,$0d,$00,$00,$08,$0e,$09
	dc.b	$0c,$0a,$0b,$00,$00,$08,$0e,$09,$0c,$0a,$0b,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$0b,$00,$00,$08,$0e,$09,$0c,$0a
	dc.b	$0b,$00,$00,$08,$0e,$09,$0c,$0a,$0b,$00,$00,$08,$0e
	dc.b	$09,$0c,$0a,$0b,$00,$00,$08,$0e,$09,$0c,$0a,$0b,$00
	dc.b	$00,$08,$0e,$09,$0c,$0a,$0b,$00,$00,$08,$0e,$09,$0c
	dc.b	$0a,$0a,$00,$00,$08,$0e,$09,$0c,$0a,$0a,$00,$00,$08
	dc.b	$0e,$09,$0c,$0a,$0a,$00,$00,$08,$0e,$09,$0c,$0a,$0a
	dc.b	$00,$00,$08,$0d,$09,$0d,$0a,$0c,$00,$00,$08,$0d,$09
	dc.b	$0d,$0a,$0c,$00,$00,$08,$0e,$09,$0c,$0a,$09,$00,$00
	dc.b	$08,$0e,$09,$0c,$0a,$09,$00,$00,$08,$0e,$09,$0c,$0a
	dc.b	$05,$00,$00,$08,$0e,$09,$0c,$0a,$00,$00,$00,$08,$0e
	dc.b	$09,$0c,$0a,$00,$00,$00,$08,$0e,$09,$0b,$0a,$0b,$00
	dc.b	$00,$08,$0e,$09,$0b,$0a,$0b,$00,$00,$08,$0e,$09,$0b
	dc.b	$0a,$0b,$00,$00,$08,$0e,$09,$0b,$0a,$0b,$00,$00,$08
	dc.b	$0e,$09,$0b,$0a,$0a,$00,$00,$08,$0e,$09,$0b,$0a,$0a
	dc.b	$00,$00,$08,$0e,$09,$0b,$0a,$0a,$00,$00,$08,$0d,$09
	dc.b	$0d,$0a,$0b,$00,$00,$08,$0d,$09,$0d,$0a,$0b,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$0b,$00,$00,$08,$0e,$09,$0b,$0a
	dc.b	$09,$00,$00,$08,$0e,$09,$0b,$0a,$09,$00,$00,$08,$0e
	dc.b	$09,$0b,$0a,$09,$00,$00,$08,$0d,$09,$0c,$0a,$0c,$00
	dc.b	$00,$08,$0d,$09,$0d,$0a,$0a,$00,$00,$08,$0e,$09,$0b
	dc.b	$0a,$07,$00,$00,$08,$0e,$09,$0b,$0a,$00,$00,$00,$08
	dc.b	$0e,$09,$0b,$0a,$00,$00,$00,$08,$0d,$09,$0d,$0a,$09
	dc.b	$00,$00,$08,$0d,$09,$0d,$0a,$09,$00,$00,$08,$0e,$09
	dc.b	$0a,$0a,$09,$00,$00,$08,$0d,$09,$0d,$0a,$08,$00,$00
	dc.b	$08,$0d,$09,$0d,$0a,$07,$00,$00,$08,$0d,$09,$0d,$0a
	dc.b	$04,$00,$00,$08,$0d,$09,$0d,$0a,$00,$00,$00,$08,$0e
	dc.b	$09,$0a,$0a,$04,$00,$00,$08,$0e,$09,$09,$0a,$09,$00
	dc.b	$00,$08,$0e,$09,$09,$0a,$09,$00,$00,$08,$0d,$09,$0c
	dc.b	$0a,$0b,$00,$00,$08,$0e,$09,$09,$0a,$08,$00,$00,$08
	dc.b	$0e,$09,$09,$0a,$08,$00,$00,$08,$0e,$09,$09,$0a,$07
	dc.b	$00,$00,$08,$0e,$09,$08,$0a,$08,$00,$00,$08,$0e,$09
	dc.b	$09,$0a,$01,$00,$00,$08,$0c,$09,$0c,$0a,$0c,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$0a,$00,$00,$08,$0e,$09,$08,$0a
	dc.b	$06,$00,$00,$08,$0e,$09,$07,$0a,$07,$00,$00,$08,$0e
	dc.b	$09,$08,$0a,$00,$00,$00,$08,$0e,$09,$07,$0a,$05,$00
	dc.b	$00,$08,$0e,$09,$06,$0a,$06,$00,$00,$08,$0d,$09,$0c
	dc.b	$0a,$09,$00,$00,$08,$0e,$09,$05,$0a,$05,$00,$00,$08
	dc.b	$0e,$09,$04,$0a,$04,$00,$00,$08,$0d,$09,$0c,$0a,$08
	dc.b	$00,$00,$08,$0d,$09,$0b,$0a,$0b,$00,$00,$08,$0e,$09
	dc.b	$00,$0a,$00,$00,$00,$08,$0d,$09,$0c,$0a,$06,$00,$00
	dc.b	$08,$0d,$09,$0c,$0a,$05,$00,$00,$08,$0d,$09,$0c,$0a
	dc.b	$02,$00,$00,$08,$0c,$09,$0c,$0a,$0b,$00,$00,$08,$0c
	dc.b	$09,$0c,$0a,$0b,$00,$00,$08,$0d,$09,$0b,$0a,$0a,$00
	dc.b	$00,$08,$0d,$09,$0b,$0a,$0a,$00,$00,$08,$0d,$09,$0b
	dc.b	$0a,$0a,$00,$00,$08,$0d,$09,$0b,$0a,$0a,$00,$00,$08
	dc.b	$0c,$09,$0c,$0a,$0a,$00,$00,$08,$0c,$09,$0c,$0a,$0a
	dc.b	$00,$00,$08,$0c,$09,$0c,$0a,$0a,$00,$00,$08,$0d,$09
	dc.b	$0b,$0a,$09,$00,$00,$08,$0d,$09,$0b,$0a,$09,$00,$00
	dc.b	$08,$0d,$09,$0a,$0a,$0a,$00,$00,$08,$0d,$09,$0a,$0a
	dc.b	$0a,$00,$00,$08,$0d,$09,$0a,$0a,$0a,$00,$00,$08,$0c
	dc.b	$09,$0c,$0a,$09,$00,$00,$08,$0c,$09,$0c,$0a,$09,$00
	dc.b	$00,$08,$0c,$09,$0c,$0a,$09,$00,$00,$08,$0d,$09,$0b
	dc.b	$0a,$06,$00,$00,$08,$0c,$09,$0b,$0a,$0b,$00,$00,$08
	dc.b	$0c,$09,$0c,$0a,$08,$00,$00,$08,$0d,$09,$0b,$0a,$00
	dc.b	$00,$00,$08,$0d,$09,$0b,$0a,$00,$00,$00,$08,$0c,$09
	dc.b	$0c,$0a,$07,$00,$00,$08,$0c,$09,$0c,$0a,$06,$00,$00
	dc.b	$08,$0c,$09,$0c,$0a,$05,$00,$00,$08,$0c,$09,$0c,$0a
	dc.b	$03,$00,$00,$08,$0c,$09,$0c,$0a,$01,$00,$00,$08,$0c
	dc.b	$09,$0b,$0a,$0a,$00,$00,$08,$0d,$09,$0a,$0a,$05,$00
	dc.b	$00,$08,$0d,$09,$0a,$0a,$04,$00,$00,$08,$0d,$09,$0a
	dc.b	$0a,$02,$00,$00,$08,$0d,$09,$09,$0a,$08,$00,$00,$08
	dc.b	$0d,$09,$09,$0a,$08,$00,$00

P3ae2:	dc.l	0
P3ae6:	dc.b	$00
P3ae7:	dc.b	$00
P3ae8:	dc.b	$00,$00

phoneme:
_EY:	dc.b	"EY"		;  0 (0000)
	dc.w	$0e0d,$0262,$012c,$0906,$047e,$0b40,$05a0,$0201
	dc.w	$0105,$0530,$1830,$182a,$1500,$0001,$0505,$4000
_AY:	dc.b	"AY"		;  1 (0022)
	dc.w	$0f0c,$0366,$01ae,$04e2,$026c,$0b04,$0582,$0201
	dc.w	$0105,$0532,$192f,$171f,$0f00,$0001,$0505,$4000
_OY:	dc.b	"OY"		;  2 (0044)
	dc.w	$0f0c,$02a8,$0154,$03e8,$01f4,$0b04,$0582,$0201
	dc.w	$0105,$0532,$192d,$2c1e,$0f00,$0001,$0505,$4000
_AW:	dc.b	"AW"		;  3 (0066)
	dc.w	$0f0c,$0366,$01ae,$0564,$02b2,$0b04,$0582,$0201
	dc.w	$0105,$0532,$192f,$171f,$0f00,$0001,$0505,$4000
_OW:	dc.b	"OW"		;  4 (0088)
	dc.w	$0e0e,$0244,$0122,$03c0,$01e0,$0b04,$0582,$0201
	dc.w	$0104,$0432,$192d,$161e,$0f00,$0001,$0505,$4000
_UW:	dc.b	"UW"		;  5 (00aa)
	dc.w	$0e09,$01a4,$00d2,$0442,$021c,$0a46,$051e,$0201
	dc.w	$0104,$042f,$1728,$141e,$0f00,$0001,$0505,$4000
_AR:	dc.b	"AR"		;  6 (00cc)
	dc.w	$0f0f,$0316,$019a,$0370,$01d6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$1831,$181d,$0e00,$0001,$0404,$4000
_WX:	dc.b	"WX"		;  7 (00ee)
	dc.w	$0808,$01a4,$00d2,$03a2,$01cc,$0a00,$0500,$0501
	dc.w	$0104,$042f,$1728,$141e,$0f00,$0001,$0404,$4000
_YX:	dc.b	"YX"		;  8 (0110)
	dc.w	$0807,$01e0,$00f0,$08a2,$044c,$0ba4,$05d2,$0501
	dc.w	$0104,$0430,$182d,$1627,$1300,$0001,$0404,$4000
_AE:	dc.b	"AE"		;  9 (0132)
	dc.w	$0e08,$0316,$019a,$06f4,$03b6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182f,$1826,$1100,$0001,$0404,$4000
_IY:	dc.b	"IY"		; 10 (0154)
	dc.w	$0b08,$00fa,$006e,$0910,$04a6,$0c94,$062c,$0201
	dc.w	$0104,$0432,$1821,$1124,$1100,$0001,$0404,$4000
_ER:	dc.b	"ER"		; 11 (0176)
	dc.w	$0e0b,$0244,$0122,$058c,$02c6,$09c4,$04c4,$0501
	dc.w	$0104,$0432,$182d,$1521,$1100,$0001,$0404,$4000
_AO:	dc.b	"AO"		; 12 (0198)
	dc.w	$100c,$01ea,$00e6,$0334,$01d6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182d,$1516,$0a00,$0001,$0404,$4000
_UX:	dc.b	"UX"		; 13 (01ba)
	dc.w	$0c0a,$01c2,$00dc,$0488,$0244,$0a46,$051e,$0201
	dc.w	$0104,$0432,$1826,$1111,$0700,$0001,$0404,$4000
_UH:	dc.b	"UH"		; 14 (01dc)
	dc.w	$0c0a,$02bc,$015e,$0550,$02c6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182b,$151f,$0e00,$0001,$0404,$4000
_AH:	dc.b	"AH"		; 15 (01fe)
	dc.w	$0b06,$02e4,$0172,$0582,$02e4,$0ae6,$053c,$0201
	dc.w	$0104,$0432,$182d,$161f,$0e00,$0001,$0404,$4000
_AA:	dc.b	"AA"		; 16 (0220)
	dc.w	$0f0b,$0262,$0122,$0370,$01d6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182f,$1816,$0a00,$0001,$0404,$4000
_OH:	dc.b	"OH"		; 17 (0242)
	dc.w	$0e0a,$0244,$0104,$03c0,$0208,$0b04,$056e,$0a01
	dc.w	$0104,$0432,$182f,$181e,$0e00,$0001,$0404,$4000
_AX:	dc.b	"AX"		; 18 (0264)
	dc.w	$0605,$01ea,$00e6,$05c8,$02c6,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$1832,$1821,$1100,$0001,$0404,$4000
_IX:	dc.b	"IX"		; 19 (0286)
	dc.w	$0605,$01c2,$00d2,$0924,$0460,$0ba4,$05aa,$0501
	dc.w	$0104,$042f,$162c,$1526,$1400,$0001,$0404,$4000
_IH:	dc.b	"IH"		; 20 (02a8)
	dc.w	$0908,$0190,$00aa,$0820,$042e,$0a00,$053c,$0201
	dc.w	$0104,$0432,$1824,$1123,$1100,$0001,$0404,$4000
_EH:	dc.b	"EH"		; 21 (02ca)
	dc.w	$0b08,$0280,$015e,$07e4,$042e,$09c4,$04c4,$0201
	dc.w	$0104,$0432,$182a,$1526,$1100,$0001,$0404,$4000
_DH:	dc.b	"DH"		; 22 (02ec)
	dc.w	$0606,$0118,$00aa,$0640,$04a6,$0a00,$0000,$1401
	dc.w	$0203,$021d,$001f,$001a,$0028,$0000,$0000,$6010
_ZH:	dc.b	"ZH"		; 23 (030e)
	dc.w	$0606,$0118,$00aa,$07e4,$04a6,$0a00,$0000,$1401
	dc.w	$0203,$021d,$001a,$0024,$0028,$0000,$0000,$6010
_CH:	dc.b	"CH"		; 24 (0330)
	dc.w	$0606,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1701
	dc.w	$0002,$0000,$0000,$0000,$0000,$0000,$0000,$a000
	dc.b	"CH"		; 25 (0352)
	dc.w	$0707,$0190,$00aa,$07e4,$04a6,$0a00,$0000,$1601
	dc.w	$0203,$0100,$001f,$002a,$002c,$0000,$0000,$2014
_LX:	dc.b	"LX"		; 26 (0374)
	dc.w	$0b09,$0208,$0104,$04a6,$024e,$0dc0,$06e0,$0801
	dc.w	$0103,$022f,$0028,$001f,$0000,$0000,$0000,$4000
_RX:	dc.b	"RX"		; 27 (0396)
	dc.w	$0a07,$0244,$0122,$0668,$0334,$07c6,$03de,$0201
	dc.w	$0103,$032f,$002d,$0027,$0000,$0000,$0000,$4000
_SH:	dc.b	"SH"		; 28 (03b8)
	dc.w	$0a0a,$0190,$00aa,$07e4,$04a6,$0a00,$0000,$1201
	dc.w	$0203,$0100,$001f,$0028,$002a,$0000,$0000,$2011
_NX:	dc.b	"NX"		; 29 (03da)
	dc.w	$0807,$0136,$006e,$0334,$060e,$0af0,$062c,$0801
	dc.w	$0102,$0132,$0021,$001c,$0000,$0000,$0000,$4000
_TH:	dc.b	"TH"		; 30 (03fc)
	dc.w	$0a0a,$0190,$00aa,$06f4,$04a6,$0a78,$0a78,$1201
	dc.w	$0003,$0100,$001a,$001c,$002a,$0000,$0000,$2010
	dc.b	"/H"		; 31 (041e)
	dc.w	$0707,$01ea,$0000,$05c8,$0000,$09c4,$0000,$1e02
	dc.w	$0200,$041f,$f220,$f216,$f92c,$0002,$0007,$001a
_V:	dc.b	"V "		; 32 (0440)
	dc.w	$0807,$0118,$00aa,$058c,$015e,$0a00,$03d4,$1401
	dc.w	$0103,$021b,$0026,$0022,$0028,$0000,$0000,$6010
_Z:	dc.b	"Z "		; 33 (0462)
	dc.w	$0606,$0118,$00aa,$06b8,$03b6,$0a00,$0000,$1401
	dc.w	$0203,$021d,$0018,$0018,$002c,$0000,$0000,$600e
_J:	dc.b	"J "		; 34 (0484)
	dc.w	$0404,$00c8,$006e,$0848,$044c,$0f28,$0f28,$1a01
	dc.w	$0002,$001f,$0000,$0000,$0000,$0000,$0000,$c000
	dc.b	"J "		; 35 (04a6)
	dc.w	$0606,$00a0,$006e,$09e2,$051e,$0ca8,$0000,$1901
	dc.w	$0203,$012c,$0024,$001f,$002b,$0000,$0000,$4012
_L:	dc.b	"L "		; 36 (04c8)
	dc.w	$0906,$01c2,$00dc,$03c0,$01b8,$0dc0,$06a4,$0901
	dc.w	$0103,$022f,$0028,$001f,$0000,$0000,$0000,$4000
_R:	dc.b	"R "		; 37 (04ea)
	dc.w	$0b0b,$01ea,$0000,$049c,$024e,$0640,$02e4,$0a01
	dc.w	$0103,$022a,$1523,$1123,$1100,$0001,$0505,$4000
_W:	dc.b	"W "		; 38 (050c)
	dc.w	$0808,$0168,$0064,$0302,$015e,$0b40,$0564,$0801
	dc.w	$0103,$022f,$1728,$1428,$1400,$0001,$0203,$4000
_Y:	dc.b	"Y "		; 39 (052e)
	dc.w	$0707,$00fa,$006e,$09c4,$04a6,$0ba4,$05b4,$0a01
	dc.w	$0104,$0432,$1821,$1126,$1100,$0001,$0404,$4000
_Q:	dc.b	"Q "		; 40 (0550)
	dc.w	$0505,$0000,$0000,$0000,$0000,$0000,$0000,$1d00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0002,$0300,$0000
_P:	dc.b	"P "		; 41 (0572)
	dc.w	$0808,$00be,$006e,$02f8,$015e,$09c4,$0000,$1701
	dc.w	$0202,$0200,$0000,$0000,$0000,$0000,$0000,$8000
	dc.b	"P "		; 42 (0594)
	dc.w	$0101,$00be,$0000,$02f8,$0000,$09c4,$0000,$1d00
	dc.w	$0000,$0018,$0028,$0024,$002d,$0000,$0000,$8014
	dc.b	"P "		; 43 (05b6)
	dc.w	$0202,$00be,$006e,$02f8,$015e,$09c4,$0000,$1701
	dc.w	$0202,$0215,$0023,$001e,$002b,$0000,$0000,$0018
_T:	dc.b	"T "		; 44 (05d8)
	dc.w	$0604,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1701
	dc.w	$0002,$0200,$0000,$0000,$0000,$0000,$0000,$8000
	dc.b	"T "		; 45 (05fa)
	dc.w	$0101,$00be,$0000,$06f4,$0000,$0a78,$0000,$1d00
	dc.w	$0000,$0000,$0000,$0026,$002d,$0000,$0000,$8008
	dc.b	"T "		; 46 (061c)
	dc.w	$0202,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1701
	dc.w	$0002,$0100,$0000,$001c,$002b,$0000,$0000,$000a
_K:	dc.b	"K "		; 47 (063e)
	dc.w	$0706,$00be,$006e,$05c8,$060e,$0a3c,$062c,$1701
	dc.w	$0103,$0300,$0000,$0000,$0000,$0000,$0000,$8000
	dc.b	"K "		; 48 (0660)
	dc.w	$0201,$0140,$0000,$0ac8,$0000,$0ca8,$0000,$1d00
	dc.w	$0000,$002d,$002b,$0026,$002d,$0000,$0000,$8008
	dc.b	"K "		; 49 (0682)
	dc.w	$0404,$00be,$006e,$05c8,$060e,$0a3c,$062c,$1701
	dc.w	$0103,$0200,$0000,$0000,$0000,$0000,$0000,$0000
_B:	dc.b	"B "		; 50 (06a4)
	dc.w	$0806,$00be,$006e,$02f8,$015e,$09c4,$0000,$1a01
	dc.w	$0202,$0218,$0000,$0000,$0000,$0000,$0000,$c000
	dc.b	"B "		; 51 (06c6)
	dc.w	$0201,$00be,$0000,$02f8,$0000,$09c4,$0000,$1d00
	dc.w	$0000,$0018,$002e,$0028,$0000,$0000,$0000,$c000
	dc.b	"B "		; 52 (06e8)
	dc.w	$0101,$00be,$006e,$02f8,$015e,$09c4,$0000,$1b01
	dc.w	$0202,$0018,$0018,$0018,$0000,$0000,$0000,$4000
_D:	dc.b	"D "		; 53 (070a)
	dc.w	$0705,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1a01
	dc.w	$0002,$021f,$0000,$0000,$0000,$0000,$0000,$c000
	dc.b	"D "		; 54 (072c)
	dc.w	$0201,$00be,$0000,$06f4,$0000,$0a78,$0000,$1d00
	dc.w	$0000,$0026,$0026,$0023,$0000,$0000,$0000,$c000
	dc.b	"D "		; 55 (074e)
	dc.w	$0101,$00be,$006e,$06f4,$03b6,$0a78,$0a78,$1b01
	dc.w	$0003,$0126,$001c,$0018,$0000,$0000,$0000,$4000
_G:	dc.b	"G "		; 56 (0770)
	dc.w	$0706,$00be,$006e,$05c8,$060e,$0a3c,$062c,$1a01
	dc.w	$0102,$0220,$0000,$0000,$0000,$0000,$0000,$c000
	dc.b	"G "		; 57 (0792)
	dc.w	$0201,$00be,$0000,$05c8,$0000,$0a3c,$0000,$1d00
	dc.w	$0000,$0022,$0028,$0024,$0000,$0000,$0000,$c000
	dc.b	"G "		; 58 (07b4)
	dc.w	$0202,$00be,$006e,$05c8,$060e,$0a3c,$062c,$1b01
	dc.w	$0104,$0100,$0000,$0000,$0000,$0000,$0000,$4000
_M:	dc.b	"M "		; 59 (07d6)
	dc.w	$0807,$00be,$006e,$03e8,$015e,$0898,$0000,$0801
	dc.w	$0201,$012d,$0013,$001a,$0000,$0000,$0000,$4000
_N:	dc.b	"N "		; 60 (07f8)
	dc.w	$0807,$00be,$006e,$0514,$03b6,$0a3c,$0a78,$0801
	dc.w	$0002,$012d,$0013,$001a,$0000,$0000,$0000,$4000
_F:	dc.b	"F "		; 61 (081a)
	dc.w	$0a0a,$0190,$00aa,$058c,$015e,$0a00,$03d4,$1201
	dc.w	$0103,$0100,$0020,$001e,$002a,$0000,$0000,$200a
_S:	dc.b	"S "		; 62 (083c)
	dc.w	$0c0c,$0190,$00aa,$06b8,$03b6,$0a3c,$0000,$1201
	dc.w	$0203,$0100,$001c,$001c,$002c,$0000,$0000,$2007
	dc.b	"- "		; 63 (085e)
	dc.w	$0808,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
	dc.b	". "		; 64 (0880v )
	dc.w	$1212,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
	dc.b	", "		; 65 (08a2)
	dc.w	$0e0e,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
	dc.b	"? "		; 66 (08c4)
	dc.w	$1212,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
_SPACE:	dc.b	"  "		; 67 (08e6)
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$1f00
	dc.w	$0000,$0000,$f600,$f600,$f600,$0001,$0300,$0000
_UL:	dc.b	"UL"		; 68 (0908)
	dc.w	$0264,$04c8,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_UM:	dc.b	"UM"		; 69 (092a)
	dc.w	$0264,$07d6,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_UN:	dc.b	"UN"		; 70 (094c)
	dc.w	$0264,$07f8,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_IL:	dc.b	"IL"		; 71 (096e)
	dc.w	$0286,$04c8,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_IM:	dc.b	"IM"		; 72 (0990)
	dc.w	$0286,$07d6,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
_IN:	dc.b	"IN"		; 73 (09b2)
	dc.w	$0286,$07f8,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$ffff,$ffff

P44c2:	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$ffff,$ffff

__set_rate:
	dc.b	"O"
	.even
__set_pitc:
	dc.b	"M"
	.even
use_rate:
	dc.b	"O"
use_pitc:
	dc.b	"M"
badbuf:
	dc.w	-1

	.bss

	ds.l	1
buffer:	ds.b	1028
spchbuff:
	ds.b	$2400
saymode:
	ds.w	1
old134:
	ds.l	1

	end
