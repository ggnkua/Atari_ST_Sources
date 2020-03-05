		output	f:\quast98.tos

ph_branch       EQU $00           ; Startbranch im Header    [Headerinfos]
ph_tlen         EQU $04-2         ; L„nge Textsegment
ph_dlen         EQU $08-2         ; L„nge Datasegment
ph_blen         EQU $0C-2         ; L„nge BSS-Segment
ph_slen         EQU $10-2         ; L„nge Symboltabelle
ph_res1         EQU $14-2         ; reserviert
ph_res2         EQU $18-2         ;     "
ph_flag         EQU $1C-2         ; res. bzw. Relozierflag
ph_len		    EQU	ph_flag+2

        *************    
        lea 	dat1(pC),a0
        lea 	prg(pc),a1
        bsr.b 	DEPACK                        
        lea     prg(pc),a0
        move.l  ph_tlen(A0),D0      ; L„nge TEXT-Segment
        add.l   ph_dlen(A0),D0      ; + L„nge DATA-Segment
        add.l   ph_slen(A0),D0      ; + L„nge Symboltabelle
        lea     ph_len(A0,D0.l),A1  ; Startadresse Reloziertabelle
        lea     ph_len(A0),A0       ; Startadresse Textsegment
        move.l  A0,D0               ; Basisadresse Relozierung
        move.l  (A1)+,D1            ; Erster Relozierwert (32Bit-Offs.)
        beq.b   end_rel             ; =0 => keine Relozierung
        adda.l  D1,A0               ; richtige Adresse.
        add.l   D0,(A0)             ; Offset draufknallen
        moveq   #0,D1               ; als Wortoffset gebraucht
        moveq   #1,D2               ; Vgl. auf 1 optimieren
rel_loop: move.b  (A1)+,D1            ; Byteoffset holen
        beq    prg             ; Nulloffset=Ende der šbertragung
        cmp.b   D2,D1               ; d1=1
        beq.b   add_254             ; 254 Bytes addieren
        adda.l  D1,A0               ; auf n„chsten zu relozierenden Wert
        add.l   D0,(A0)             ; Offset draufhauen
        bra.b   rel_loop            ; n„chsten Byteoffset
add_254: lea     254(A0),A0          ; 254 Bytes drauf.
        bra.b   rel_loop            ; Vielleicht hat's der n„chste.
end_rel:  
        *************    

    even
DEPACK:	
	movem.l d0-a6,-(sp)
	ADDQ.L	#4,A0			;GET PAST ICE! HEADER
	bsr.b	ice04
	lea	-8(a0,d0.l),a5
	bsr.b	ice04
	move.l	d0,(sp)
	movea.l a1,a4
	movea.l a1,a6
	adda.l	d0,a6
	movea.l a6,a3
	move.b	-(a5),d7
	bsr.b	ice06	
ice03:	
        movem.l (sp)+,d0-a6
	rts
ice04:	moveq	#3,d1
ice05:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbra	d1,ice05
	rts
ice06:	bsr.b	ice0a
	bcc.s	ice09
	moveq	#0,d1
	bsr.s	ice0a
	bcc.s	ice08
	lea	ice17(pc),a1
	moveq	#4,d3
ice07:	move.l	-(a1),d0
	bsr.s	ice0c
	swap	d0
	cmp.w	d0,d1
	dbne	d3,ice07
	add.l	20(a1),d1
ice08:	move.b	-(a5),-(a6)
	dbra	d1,ice08
ice09:	cmpa.l	a4,a6
	bgt.s	ice0f
	rts
ice0a:	add.b	d7,d7
	bne.s	ice0b
	move.b	-(a5),d7
	addx.b	d7,d7
ice0b:	rts
ice0c:	moveq	#0,d1
ice0d:	add.b	d7,d7
	bne.s	ice0e
	move.b	-(a5),d7
*	MOVE.W	D7,$FFFF8240.W
	addx.b	d7,d7
ice0e:	addx.w	d1,d1
	dbra	d0,ice0d
	rts
ice0f:	lea	ice18(pc),a1
	moveq	#3,d2
ice10:	bsr.s	ice0a
	dbcc	d2,ice10
	moveq	#0,d4
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bmi.s	ice11
	bsr.s	ice0c
ice11:	move.b	6(a1,d2.w),d4
	add.w	d1,d4
	beq.s	ice13
	lea	ice19(pc),a1
	moveq	#1,d2
ice12:	bsr.s	ice0a
	dbcc	d2,ice12
	moveq	#0,d1
	move.b	1(a1,d2.w),d0
	ext.w	d0
	bsr.s	ice0c
	add.w	d2,d2
	add.w	6(a1,d2.w),d1
	bpl.s	ice15
	sub.w	d4,d1
	bra.s	ice15
ice13:	moveq	#0,d1
	moveq	#5,d0
	moveq	#-1,d2
	bsr.s	ice0a
	bcc.s	ice14
	moveq	#8,d0
	moveq	#$3f,d2
ice14:	bsr.s	ice0c
	add.w	d2,d1
ice15:	lea	2(a6,d4.w),a1
	adda.w	d1,a1
	move.b	-(a1),-(a6)
ice16:	move.b	-(a1),-(a6)
	dbra	d4,ice16
	bra	ice06
	DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
	DC.B $00,$07,$00,$02,$00,$03,$00,$01
	DC.B $00,$03,$00,$01
ice17:	DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
	DC.B $00,$00,$00,$07,$00,$00,$00,$04
	DC.B $00,$00,$00,$01
ice18:	DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
	DC.B $01,$00
ice19:	DC.B $0b,$04,$07,$00,$01,$1f,$ff,$ff
	DC.B $00,$1f                               
dat1    incbin f:\quast.bin             
        even
        section bss
prg 	ds.b	1000000
        
        