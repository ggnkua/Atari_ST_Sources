*	Created by TT-Digger v7.1
*	Sat Sep 15 22:06:14 2007

*	TT-Digger v7

	ds.b	554
.ENDMOD
.MODULE stat
		movem.l	d3-d4/a2-a5,-(a7)
		lea 	-44(a7),a7
		movea.l	a0,a4
		movea.l	a1,a5
		move	#47,-(a7)	; Fgetdta
		trap	#1		; Gemdos
		addq.l	#2,a7
		movea.l	d0,a3
		move.l	a7,-(a7)
		move	#26,-(a7)	; Fsetdta
		trap	#1		; Gemdos
		addq.l	#6,a7
		move	#49,-(a7)
		move.l	a4,-(a7)
		move	#78,-(a7)	; Fsfirst
		trap	#1		; Gemdos
		addq.l	#8,a7
		tst	d0
		bne 	L812
		move.b	1(a4),d0
		sub.b	#58,d0
		beq.s	L626
		move	#25,-(a7)	; Dgetdrv
		trap	#1		; Gemdos
		addq.l	#2,a7
		bra.s	L638

L626:		clr	d0
		move.b	(a4),d0
		bclr	#5,d0
		sub	#65,d0
L638:		move	d0,(a5)
		move	d0,12(a5)
		clr	2(a5)
		move	#256,d3
		move.b	21(a7),d1
		btst	#4,d1
		beq.s	L668
		move	#16832,d3
		bra.s	L748

L668:		bset	#15,d3
		btst	#0,d1
		bne.s	L682
		bset	#7,d3
L682:		clr	-(a7)
		move.l	a4,-(a7)
		move	#61,-(a7)	; Fopen
		trap	#1		; Gemdos
		addq.l	#8,a7
		tst	d0
		bmi.s	L748
		move	d0,d4
		pea	(a7)
		move.l	#2,-(a7)
		move	d0,-(a7)
		move	#63,-(a7)	; Fread
		trap	#1		; Gemdos
		lea 	12(a7),a7
		cmp.l	#2,d0
		bmi.s	L738
		cmpi	#24602,(a7)
		bne.s	L738
		bset	#6,d3
L738:		move	d4,-(a7)
		move	#62,-(a7)	; Fclose
		trap	#1		; Gemdos
		addq.l	#4,a7
L748:		move	d3,4(a5)
		move	#1,6(a5)
L758:		clr.l	8(a5)
		move.l	26(a7),14(a5)
		lea 	22(a7),a0
		jsr	ftimtose.l
		move.l	d0,18(a5)
		move.l	d0,22(a5)
		move.l	d0,26(a5)
		pea	(a3)
		move	#26,-(a7)	; Fsetdta
		trap	#1		; Gemdos
		addq.l	#6,a7
		clr	d0
L802:		lea 	44(a7),a7
		movem.l	(a7)+,d3-d4/a2-a5
		rts

L812:		move	#2,errno.l
		moveq	#-1,d0
		bra.s	L802


