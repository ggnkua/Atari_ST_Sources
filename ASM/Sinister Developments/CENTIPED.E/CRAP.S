	opt	p+
	text
Begin
L0001	equ	Begin-$100

L0002	
.1	lea	biddle+2(pc),a0
	move.l	d0,(a0)
	move.w	#%0000100000001000,d7	; clear caches
	bsr	cache			; do it
	lea	L0039(PC),a0		; start of packed file
	move.l	(a0)+,d0			; unpacked length
	bsr	L000D			; depack it
	movea.l	a5,a3			; a5->unpacked file
	lea	L0001(PC),a6		; basepage
	move.l	2(a3),d0			; load text size 
	add.l	6(a3),d0			; add data size
	add.l	14(a3),d0			; add sym tab size 
	lea	$1C(a3,d0.L),a0		; the end
	move.l	8(a6),d0			; start of text segment
	lea	$1C(a3),a3		; start of unpacked prog
	tst.l	(a0)			; blank reloc table
	beq.s	L0008			; yep
; reloc prog
	adda.l	(a0)+,a3			; start of 1st addr to reloc
	moveq	#0,d1
L0005	add.l	d0,(a3)			; reloc address
L0006	clr.b	-1(a0)			; zap reloc info
	move.b	(a0)+,d1			; next offset
	beq.s	L0008			; blank so exit
	cmp.b	#1,d1			; if not 1 then 
	bne.s	L0007			; carry on
	lea	$FE(a3),a3		; move another 254 bytes into file
	bra.s	L0006			; loop
L0007	adda.w	d1,a3			; move anither d1 bytes into file 
	bra.s	L0005			; loop
; set up basepage
L0008	lea	2(a5),a3			; start of prog header proper
	addq.w	#8,a6			; enter basepage
	movea.l	(a6)+,a2			; start of prog from bp
	move.l	(a3),(a6)+		; move in text length
	move.l	(a3),d6			; load text length
	adda.l	(a3)+,a2			; calc start of data
	move.l	a2,(a6)+			; move in data start
	move.l	(a3),(a6)+		; move in data length
	add.l	(a3),d6			; add data length
	adda.l	(a3)+,a2			; add in data length
	move.l	a2,(a6)+			; move in bss start
	move.l	(a3),(a6)+		; move in bss length
	add.l	(a3),d6			; add bss length
	add.l	(a3),a2			; add bss length
	lea	$400(a2),a2
	lea	L000A(PC),a1
	moveq	#((L000D-L000A)/4)+1,d0
	movea.l	a2,a4
L0009	move.l	(a1)+,(a4)+
	dbf	d0,L0009
	lea	L0002(PC),a3
	move.l	4(a7),d0
	lea	$1C(a5),a5
	pea	(A3)
	jmp	(a2)
L000A	movea.l	a3,a4
L000B	move.l	(a5),(a3)+
	clr.l	(a5)+
	subq.l	#4,d6
	bcc.s	L000B
	move.w	#%0001100100011001,d7	; enable & clear caches,set burst fill
	bsr.s	cache
	lea	-$100(a4),a3
biddle	move.l	#0,d0
	move.l	d0,a6
	move.l	$18(a3),a5
	move.l	$18(a3),a4
	moveq	#0,d7
	move.l	d7,d1
	move.l	d7,d2
	move.l	d7,d3
	move.l	d7,d4
	move.l	d7,d5
	move.l	d7,d6
	move.l	d7,a0
	move.l	d7,a1
	move.l	d7,a2
	move.l	d7,a3
	rts
cache	pea	cache_control(pc)
	move.w	#$26,-(a7)
	trap	#14
	addq	#6,a7
	rts
cache_control
	movea.l	a7,a0
	move.l	$10.w,a1
	lea	.1(PC),a2
	move.l	a2,$10.w
	movec	d7,CACR
.1	move.l	a1,$10.w
	movea.l	a0,a7
	rts

L000D	move.l	d0,-(a7)
	lea	4(a0,d0.L),a5
	move.l	(a0)+,d0
	movea.l	a0,a6
	adda.l	d0,a6
	link	a2,#-$1A
	lea	(a5),a5
	move.b	-(a6),d7
	bra	L002D
L000E	move.w	d3,d5
L000F	add.b	d7,d7
L0010	dbcs	d5,L000F
	beq.s	L0013
	bcc.s	L0011
	sub.w	d3,d5
	neg.w	d5
	bra.s	L0016
L0011	moveq	#3,d6
	bsr.s	L001C
	beq.s	L0012
	bra.s	L0015
L0012	moveq	#7,d6
	bsr.s	L001C
	beq.s	L0014
	addi.w	#$F,d5
	bra.s	L0015
L0013	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	L0010
L0014	moveq	#$D,d6
	bsr.s	L001C
	addi.w	#$10E,d5
L0015	add.w	d3,d5
L0016	lea	L0037(PC),a4
	move.w	d5,d2
	bne.s	L0020
	add.b	d7,d7
	bne.s	L0017
	move.b	-(a6),d7
	addx.b	d7,d7
L0017	bcs.s	L0018
	moveq	#1,d6
	bra.s	L0021
L0018	moveq	#3,d6
	bsr.s	L001C
	tst.b	-$1A(a2)
	beq.s	L0019
	move.b	-$10(a2,d5.W),-(a5)
	bra	L002C
L0019	move.b	(a5),d0
	btst	#3,d5
	bne.s	L001A
	bra.s	L001B
L001A	addi.b	#-$10,d5
L001B	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	L002C
L001C	clr.w	d5
L001D	add.b	d7,d7
	beq.s	L001F
L001E	addx.w	d5,d5
	dbf	d6,L001D
	tst.w	d5
	rts
L001F	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	L001E
L0020	moveq	#2,d6
L0021	bsr.s	L001C
	move.w	d5,d4
	move.b	$E(a4,d4.W),d6
	ext.w	d6
	tst.b	-$19(a2)
	bne.s	L0022
	addq.w	#4,d6
	bra.s	L0026
L0022	bsr.s	L001C
	move.w	d5,d1
	lsl.w	#4,d1
	moveq	#2,d6
	bsr.s	L001C
	cmp.b	#7,d5
	blt.s	L0024
	moveq	#0,d6
	bsr.s	L001C
	beq.s	L0023
	moveq	#2,d6
	bsr.s	L001C
	add.w	d5,d5
	or.w	d1,d5
	bra.s	L0027
L0023	or.b	-$18(a2),d1
	bra.s	L0025
L0024	or.b	-$17(a2,d5.W),d1
L0025	move.w	d1,d5
	bra.s	L0027
L0026	bsr.s	L001C
L0027	add.w	d4,d4
	beq.s	L0028
	add.w	-2(a4,d4.W),d5
L0028	lea	1(a5,d5.W),a4
	move.b	-(a4),-(a5)
L0029	move.b	-(a4),-(a5)
	dbf	d2,L0029
	bra.s	L002C
L002A	add.b	d7,d7
	bne.s	L002B
	move.b	-(a6),d7
	addx.b	d7,d7
L002B	bcs.s	L0035
	move.b	-(a6),-(a5)
L002C	cmpa.l	a5,a3
	bne.s	L002A
	cmpa.l	a6,a0
	beq.s	L0036
L002D	moveq	#0,d6
	bsr	L001C
	beq.s	L0030
	move.b	-(a6),d0
	lea	-$18(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
L002E	cmp.b	d0,d1
	bne.s	L002F
	addq.w	#2,d1
L002F	move.b	d1,(a1)+
	addq.w	#2,d1
	dbf	d2,L002E
	st	-$19(a2)
	bra.s	L0031
L0030	sf	-$19(a2)
L0031	moveq	#0,d6
	bsr	L001C
	beq.s	L0033
	lea	-$10(a2),a1
	moveq	#$F,d0
L0032	move.b	-(a6),(a1)+
	dbf	d0,L0032
	st	-$1A(a2)
	bra.s	L0034
L0033	sf	-$1A(a2)
L0034	clr.w	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl.w	#8,d0
	move.b	-(a6),d0
	movea.l	a5,a3
	suba.w	d0,a3
	bra.s	L002A
L0035	bra	L000E
L0036	unlk	a2
	move.l	(a7)+,d6
	rts

L0037	DC.B	$00,$20,$00,$60,$01,$60,$03,$60
	DC.B	$07,$60,$0F,$60,$1F,$60,$00,$01
	DC.B	$03,$04,$05,$06,$07,$08	
L0039	incbin	l:\balls