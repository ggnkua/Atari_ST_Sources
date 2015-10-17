		OPT O+,W-
		>PART
		lea	opcode(PC),A5
loop:		moveq	#'$',D0
		bsr.s	print_char
		lea	ea_buf(PC),A3
		clr.b	(A3)
		move.l	A5,-(SP)
		bsr	put_hexw
		bsr	put_hexw
		moveq	#0,D0
		move.b	(A3)+,D0
		clr.b	0(A3,D0.w)
		movea.l A3,A0
		bsr.s	print_line
		moveq	#' ',D0
		bsr.s	print_char
		lea	opcode_buf(PC),A6
		lea	ea_buf(PC),A3
		bsr.s	do_diass
		moveq	#0,D0
		move.b	(A6)+,D0
		clr.b	0(A6,D0.w)
		movea.l A6,A0
		bsr.s	print_line
		moveq	#' ',D0
		bsr.s	print_char
		moveq	#0,D0
		move.b	(A3)+,D0
		clr.b	0(A3,D0.w)
		movea.l A3,A0
		bsr.s	print_line
		moveq	#13,D0
		bsr.s	print_char
		moveq	#10,D0
		bsr.s	print_char
		move.w	#7,-(SP)
		trap	#1		;aus Taste warten
		addq.l	#2,SP
		bra.s	loop

print_line:	move.l	A0,-(SP)
		move.w	#9,-(SP)
		trap	#1		;String A0 ausgeben
		addq.l	#6,SP
		rts
print_char:	move.w	D0,-(SP)
		move.w	#2,-(SP)
		trap	#1		;Zeichen D0 ausgeben
		addq.l	#4,SP
		rts
		ENDPART

		>PART 'Demo-Opcodes'
opcode: 	illegal
		ENDPART

		>PART 'do_disass'
;D0-D2/A0-A2 werden ver„ndert. D0 zeigt hinter den Opcode (A5 auch)
do_diass:	link	A6,#-14
		move.l	A5,-4(A6)	;Zeiger auf den Opcode
		move.l	(A6),-8(A6)	;Der alte Wert von A6
		bsr	disass
		swap	D7
		tst.w	D7		;Fehler beim Disassemblieren?
		beq.s	do_diass1	;Nein! =>
		movea.l -4(A6),A5
		addq.l	#2,A5		;ein Wort fr den Opcode berspringen
		movea.l -8(A6),A0	;Zeiger auf den Stringbuffer
		clr.b	(A0)		;den Buffer leeren
		clr.b	(A3)
		bsr.s	put_str_opc
		DC.B '??','?'|$80 ;'???' fr einen ungltigen Opcode
do_diass1:	move.l	A5,D0		;die n„chste Adresse
		unlk	A6
		rts

put_komma:	moveq	#',',D0 	;ein Komma ausgeben
put_char:	move.b	D0,-(SP)	;ein Zeichen in D0 in den Buffer
		movea.l A3,A0
		move.b	(A0)+,D0	;Bufferpointer
		move.b	(SP)+,0(A0,D0.w) ;Zeichen in den Buffer
		addq.b	#1,(A3) 	;Bufferpointer erh”hen
		rts

put_comment_tab:moveq	#' ',D0 	;Tabulator auf Position 16
		bsr.s	put_char
		move.b	(A3),D0
		cmp.b	#16,D0
		blt.s	put_comment_tab
		bsr.s	put_str_ea
		DC.B ';',' '|$80 ;und einen Kommentar dahinter
		rts

put_Dn: 	movea.l (SP)+,A1	;Datenregister Dn ausgeben
		move.w	D0,-(SP)
		moveq	#'D',D0
		bsr.s	put_char
put_n:		moveq	#7,D0
		and.w	(SP)+,D0	;Ziffer 0-7 ausgeben
		add.w	#'0',D0
		bsr.s	put_char
		jmp	(A1)
put_An: 	movea.l (SP)+,A1	;Adrežregister An ausgeben
		move.w	D0,-(SP)
		moveq	#'A',D0
		bsr.s	put_char
		bra.s	put_n
put_FPn:	movea.l (SP)+,A0	;FPU-Register FPn ausgeben
		move.w	D0,-(SP)
		move.l	A0,-(SP)
		bsr.s	put_str_ea
		DC.B 'F','P'|$80
		movea.l (SP)+,A1
		bra.s	put_n

put_str_ea:	movea.l A3,A1		;Zeiger auf den Stringbuffer
		bra.s	put_str_opc1
put_str_opc:	movea.l -8(A6),A1	;Zeiger auf den Stringbuffer
put_str_opc1:	movea.l (SP)+,A0	;die Rcksprungadresse holen
		move.l	A2,-(SP)	;A2 retten
		bsr.s	str_to_buff1
		movea.l (SP)+,A2	;und A2 zurckholen
		move.l	A0,D0
		btst	#0,D0		;Rcksprungadresse ungerade?
		beq.s	put_str_opc2	;Nein! =>
		tst.b	(A0)+		;begradigen
put_str_opc2:	jmp	(A0)		;und zurck

put_str_n:	movea.l (SP)+,A2	;Rcksprungadresse holen
		movea.l (SP)+,A1	;Ausgabebuffer
		move.w	(SP)+,D0	;Nummer des Strings
		movea.l (SP)+,A0	;Stringadresse
		move.l	A2,-(SP)	;und die Rcksprungadresse zurck
put_str_n1:	subq.w	#1,D0
		blt.s	str_to_buff	;der n. String? Ja! =>
put_str_n2:	tst.b	(A0)+		;String berlesen
		bge.s	put_str_n2
		bra.s	put_str_n1	;zum n„chsten String =>

str_to_buff:	cmpi.b	#$80,(A0)	;ein Leerstring?
		beq.s	str_to_buff3	;Ja! =>
str_to_buff1:	movea.l A1,A2
		clr.w	D1
		move.b	(A1)+,D1	;aktueller Bufferpointer
		adda.w	D1,A1
str_to_buff2:	addq.b	#1,(A2) 	;Bufferpointer erh”hen
		move.b	(A0)+,(A1)	;Zeichen in den Buffer
		bclr	#7,(A1)+	;und das 7.Bit l”schen
		beq.s	str_to_buff2	;Stringende? Nein =>
str_to_buff3:	rts

put_extension:	and.w	#3,D0
		beq.s	put_extension1
		subq.w	#2,D0
		beq.s	put_extension2
		bsr.s	put_str_opc
		DC.B '.','W'|$80
		rts
put_extension1: bsr.s	put_str_opc
		DC.B '.','B'|$80
		rts
put_extension2: bsr.s	put_str_opc
		DC.B '.','L'|$80
		rts

put_regmask:	movea.l (SP)+,A2	;normale Registermaske oder FPU-Maske ausgeben
		move.w	(SP)+,D1	;FPn oder Dn?
		move.w	(SP)+,D2	;die Maske. D5 gibt die Richtung an
		movem.l D3-D7,-(SP)
		move.w	D1,D7
		move.w	D2,D3
		tst.w	D7
		beq.s	put_regmask1
		cmp.w	#4,D5
		beq.s	put_regmask5
		bra.s	put_regmask2
put_regmask1:	cmp.w	#4,D5
		bne.s	put_regmask5
put_regmask2:	move.w	D3,D0
		moveq	#16,D2
put_regmask3:	lsr.w	#1,D1
		btst	#15,D0
		beq.s	put_regmask4
		bset	#15,D1
put_regmask4:	add.w	D0,D0
		subq.w	#1,D2
		bne.s	put_regmask3
		move.w	D1,D3
put_regmask5:	clr.w	D2
		moveq	#1,D4
		moveq	#12,D5
		ror.l	#4,D5
		moveq	#1,D6
put_regmask6:	move.w	D3,D0
		and.w	D4,D0
		beq.s	put_regmask9
		bsr.s	put_regmask15
		tst.w	D7
		beq.s	put_regmask7
		move.w	D2,D0
		bsr	put_FPn
		bra.s	put_regmask8
put_regmask7:	move.w	D2,D0
		bsr	put_Dn
put_regmask8:	moveq	#'/',D0
		bsr	put_char
put_regmask9:	add.l	D4,D4
		rol.l	#1,D5
		addq.w	#1,D2
		cmp.w	#8,D2
		bne.s	put_regmask6
		moveq	#9,D6
put_regmask10:	move.w	D3,D0
		and.w	D4,D0
		beq.s	put_regmask13
		bsr.s	put_regmask15
		tst.w	D7
		beq.s	put_regmask11
		move.w	D2,D0
		bsr	put_FPn
		bra.s	put_regmask12
put_regmask11:	move.w	D2,D0
		bsr	put_An
put_regmask12:	moveq	#'/',D0
		bsr	put_char
put_regmask13:	add.l	D4,D4
		rol.l	#1,D5
		addq.w	#1,D2
		cmp.w	#16,D2
		bne.s	put_regmask10
		tst.b	(A3)
		beq.s	put_regmask14
		subq.b	#1,(A3)
put_regmask14:	movem.l (SP)+,D3-D7
		jmp	(A2)

put_regmask15:	cmp.w	D6,D2
		ble.s	put_regmask17
		move.w	D3,D0
		and.w	D5,D0
		cmp.w	D5,D0
		bne.s	put_regmask17
		tst.w	D7
		beq.s	put_regmask16
		subq.b	#1,(A3)
put_regmask16:	subq.b	#4,(A3)
		moveq	#'-',D0
		bra	put_char
put_regmask17:	rts

put_hexn:	and.w	#$0F,D0 	;Hex-Nibble in den Buffer
		move.b	put_hexn1(PC,D0.w),D0
		bra	put_char
put_hexn1:	DC.B '0123456789ABCDEF'

put_hexb:	movea.l (SP)+,A1	;Hexbyte in den Buffer
		move.w	(SP),D0
		lsr.w	#4,D0
		bsr.s	put_hexn
		move.w	(SP)+,D0
		bsr.s	put_hexn
		jmp	(A1)

put_hexw:	movea.l (SP)+,A2	;Hexword in den Buffer
		move.w	(SP),D0
		lsr.w	#8,D0
		move.w	D0,-(SP)
		bsr.s	put_hexb
		bsr.s	put_hexb
		jmp	(A2)

put_ea_imme:	movea.l (SP),A2 	;Immediate-<ea> ausgeben
		move.w	D0,(SP) 	;die Breite merken
		bsr	put_str_ea
		DC.B '#','$'|$80
		move.w	(SP),D0 	;die Breite zurckholen
		move.l	A2,(SP)
		and.w	#3,D0
		subq.w	#1,D0		;Wortbreite
		beq.s	put_ea_imme2	;Ja! =>
		move.w	(A5)+,-(SP)
		addq.w	#1,D0
		bne.s	put_ea_imme1	;Langwort =>
		bsr.s	put_hexb	;Bytebreite
		rts
put_ea_imme1:	bsr.s	put_hexw
put_ea_imme2:	move.w	(A5)+,-(SP)
		bsr.s	put_hexw
		rts

put_4bit_imme:	move.w	D0,-(SP)	;4bit (z.B. TRAP #) ausgeben
		bsr	put_str_ea
		DC.B '#','$'|$80
		move.w	(SP)+,D0
		bra.s	put_hexn

put_reg:	and.w	#$0F,D0 	;Dn bzw. An ausgeben
		btst	#3,D0
		bne	put_An
		bra	put_Dn

put_relativ_l:	move.l	(A5)+,D0	;der Langwort-Offset
		bra.s	put_relativ
put_relativ_w:	move.w	(A5)+,D0	;Wort-Offset
		ext.l	D0
		bra.s	put_relativ
put_relativ_b:	movea.l (SP)+,A2	;die Rcksprungadresse retten
		move.w	(SP)+,D0	;der Byte-Offset
		move.l	A2,-(SP)	;die Rcksprungadresse wieder auf den Stack
		ext.w	D0
		ext.l	D0
put_relativ:	movea.l D0,A1		;den Offset merken
		moveq	#'$',D0 	;ein '$' vor die Adresse
		bsr	put_char
		movea.l (SP)+,A2	;die Rcksprungadresse
		adda.l	A5,A1		;die aktuelle Adresse zum Offset
		suba.w	(SP)+,A1	;der bergebene (negative) Offset
		move.l	A2,-(SP)	;die Rcksprungadresse wieder zurck
		move.l	A1,-(SP)
		bsr	put_hexb	;Adressewort ausgeben
		bsr.s	put_hexw
		rts

put_ea: 	movea.l (SP)+,A0	;die Rcksprungadresse retten
		move.w	(SP)+,D2	;Breite (0=Byte, 1=Word, 2=Long)
		move.w	(SP)+,D1	;Register bzw. erweiterter Mode
		move.w	(SP)+,D0	;Mode-Bits
		move.l	A0,-(SP)	;und die Rcksprungadr wieder auf den SP
		movem.w D3-D5,-(SP)	;einige Register retten
		move.w	D0,D3		;Mode-Bits merken
		move.w	D1,D4		;Register bzw. erweiterter Mode
		move.w	D2,D5
		move.w	D3,D1		;Mode-Bits
		add.w	D1,D1
		move.w	put_ea1(PC,D1.w),D1
		jmp	put_ea1(PC,D1.w)
		BASE DC.W,put_ea1
put_ea1:	DC.W put_ea_Dn	;0 = 000
		DC.W put_ea_An	;1 = 001
		DC.W put_ea_An_ind ;2 = 010
		DC.W put_ea_An_inc ;3 = 011
		DC.W put_ea_An_dec ;4 = 100
		DC.W put_ea_An16dis ;5 = 101
		DC.W put_ea_ind ;6 = 110
		DC.W put_ea_more ;7 = 111

put_ea_bracket: movea.l (SP)+,A2
		move.w	(A5)+,-(SP)
		move.w	(SP),D2
		btst	#8,D2
		bne.s	put_ea_bracket1
		jmp	2(A2)
put_ea_bracket1:moveq	#'(',D0
		bsr	put_char
		and.w	#7,D2
		beq.s	put_ea_bracket2
		moveq	#'[',D0
		bsr	put_char
put_ea_bracket2:jmp	(A2)

put_ea_scale:	movea.l (SP)+,A2
		move.w	(SP),D2
		move.w	D2,D0
		rol.w	#4,D0
		bsr	put_reg
		btst	#11,D2
		beq.s	put_ea_scale1
		bsr	put_str_ea
		DC.B '.','L'|$80
		bra.s	put_ea_scale2
put_ea_scale1:	bsr	put_str_ea
		DC.B '.','W'|$80
put_ea_scale2:	rol.w	#7,D2
		and.w	#3,D2
		beq.s	put_ea_scale3
		moveq	#'*',D0
		bsr	put_char
		moveq	#1,D0
		lsl.w	D2,D0
		add.w	#'0',D0
		bsr	put_char
put_ea_scale3:	move.w	(SP)+,D2
		jmp	(A2)

put_ea_indAn:	moveq	#'(',D0
		bsr	put_char
		move.w	D4,D0
		bsr	put_An
		moveq	#')',D0
		bra	put_char

put_ea_Dn:	move.w	D4,D0
		bsr	put_Dn
		bra.s	put_ea_exit2
put_ea_An:	move.w	D4,D0
		bsr	put_An
		bra.s	put_ea_exit2
put_ea_An_ind:	bsr.s	put_ea_indAn
		bra.s	put_ea_exit2
put_ea_An_inc:	bsr.s	put_ea_indAn
		moveq	#'+',D0
		bsr	put_char
		bra.s	put_ea_exit2
put_ea_An_dec:	moveq	#'-',D0
		bsr	put_char
		bsr.s	put_ea_indAn
put_ea_exit2:	bra	put_ea_exit
put_ea_An16dis: moveq	#'$',D0
		bsr	put_char
		move.w	(A5)+,-(SP)	;den Offset merken
		bsr	put_hexw	;den Offset ausgeben
		bsr.s	put_ea_indAn	;(An) ausgeben
		bra.s	put_ea_exit2
put_ea_ind:	bsr	put_ea_bracket
		bra.s	put_ea_ind2
		moveq	#'$',D0
		bsr	put_char
		move.w	(SP),D0
		and.w	#$FF,D0
		move.w	D0,-(SP)
		bsr	put_hexb
		moveq	#'(',D0
		bsr	put_char
		move.w	D4,D0
		bsr	put_An
		bsr	put_komma
put_ea_ind1:	bsr	put_ea_scale
		moveq	#')',D0
		bsr	put_char
		bra.s	put_ea_exit2
put_ea_ind2:	move.w	(SP),D2
		move.w	D2,D1
		lsr.w	#4,D1
		and.w	#3,D1
		beq	put_ea_illegalx
		subq.w	#2,D1
		bgt.s	put_ea_ind3
		blt.s	put_ea_ind5
		moveq	#'$',D0
		bsr	put_char
		bra.s	put_ea_ind4
put_ea_ind3:	moveq	#'$',D0
		bsr	put_char
		move.w	(A5)+,-(SP)
		bsr	put_hexw
put_ea_ind4:	move.w	(A5)+,-(SP)
		bsr	put_hexw
		bra.s	put_ea_ind6
put_ea_ind5:	moveq	#'0',D0
		bsr	put_char
put_ea_ind6:	btst	#7,D2
		beq.s	put_ea_ind7
		btst	#6,D2
		bne.s	put_ea_ind9
		bsr	put_komma
		moveq	#'Z',D0
		bsr	put_char
		bra.s	put_ea_ind8
put_ea_ind7:	bsr	put_komma
put_ea_ind8:	move.w	D4,D0
		bsr	put_An
put_ea_ind9:	moveq	#7,D0
		and.w	D2,D0
		beq.s	put_ea_ind10
		subq.w	#4,D0
		blt.s	put_ea_ind10
		beq	put_ea_illegalx
		btst	#6,D2
		bne	put_ea_illegalx
		moveq	#']',D0
		bsr	put_char
put_ea_ind10:	btst	#6,D2
		beq.s	put_ea_ind11
		tst.w	(SP)+
		bra.s	put_ea_ind12
put_ea_ind11:	bsr	put_komma
		bsr	put_ea_scale
put_ea_ind12:	and.w	#7,D2
		beq.s	put_ea_ind13
		cmp.w	#3,D2
		bgt.s	put_ea_ind13
		moveq	#']',D0
		bsr	put_char
put_ea_ind13:	and.w	#3,D2
		subq.w	#2,D2
		bgt.s	put_ea_ind14
		blt.s	put_ea_ind16
		bsr	put_str_ea
		DC.B ',','$'|$80
		bra.s	put_ea_ind15
put_ea_ind14:	bsr	put_str_ea
		DC.B ',','$'|$80
		move.w	(A5)+,-(SP)
		bsr	put_hexw
put_ea_ind15:	move.w	(A5)+,-(SP)
		bsr	put_hexw
put_ea_ind16:	moveq	#')',D0
		bsr	put_char
		bra.s	put_ea_pc16dis1

put_ea_more:	lea	put_ea_moretab(PC),A0
		clr.w	D1
		move.b	0(A0,D4.w),D1
		lea	put_ea_more(PC),A0
		jmp	0(A0,D1.w)
put_ea_short:	moveq	#'$',D0
		bsr	put_char
		bra.s	put_ea_long1
put_ea_long:	moveq	#'$',D0
		bsr	put_char
		move.w	(A5)+,-(SP)
		bsr	put_hexw
put_ea_long1:	move.w	(A5)+,-(SP)
		bsr	put_hexw
		bra.s	put_ea_pc16dis1
put_ea_pc16dis: move.w	#2,-(SP)
		bsr	put_relativ_w
put_ea_pc16dis1:bra.s	put_ea_exit
put_ea_alg_ind: bsr	put_ea_bracket
		bra.s	put_ea_alg_ind1
		move.w	#2,-(SP)
		move.w	2(SP),-(SP)
		bsr	put_relativ_b
		moveq	#'(',D0
		bsr	put_char
		bra	put_ea_ind1
put_ea_alg_ind1:move.w	(SP),D2
		move.w	D2,D1
		lsr.w	#4,D1
		and.w	#3,D1
		beq.s	put_ea_illegalx
		subq.w	#2,D1
		bgt.s	put_ea_alg_ind2
		blt.s	put_ea_alg_ind3
		move.w	#4,-(SP)
		bsr	put_relativ_w
		bra.s	put_ea_alg_ind4
put_ea_alg_ind2:move.w	#6,-(SP)
		bsr	put_relativ_l
		bra.s	put_ea_alg_ind4
put_ea_alg_ind3:moveq	#'0',D0
		bsr	put_char
put_ea_alg_ind4:bra	put_ea_ind9
put_ea_imm:	move.w	D5,D0
		bsr	put_ea_imme
		bra.s	put_ea_exit
put_ea_illegalx:tst.w	(SP)+
put_ea_illegal: bset	#16,D7
put_ea_exit:	movem.w (SP)+,D3-D5	;die geretteten Register zurck
		rts
		BASE DC.B,put_ea_more
put_ea_moretab: DC.B put_ea_short ;0 = 000
		DC.B put_ea_long ;1 = 001
		DC.B put_ea_pc16dis ;2 = 010
		DC.B put_ea_alg_ind ;3 = 011
		DC.B put_ea_imm ;4 = 100
		DC.B put_ea_illegal ;5 = 101
		DC.B put_ea_illegal ;6 = 110
		DC.B put_ea_illegal ;7 = 111

;Opcode ab A5 disassemblieren
disass: 	movea.l -8(A6),A0	;Zeiger auf den Stringbuffer
		clr.b	(A0)		;den Buffer leeren
		clr.b	(A3)
		moveq	#0,D7
		move.w	(A5)+,D7	;der Opcode
		move.w	D7,D6
		move.w	D6,D5
		lsr.w	#3,D5
		move.w	D5,D4
		lsr.w	#3,D4
		move.w	D4,D3
		lsr.w	#3,D3
		move.w	D3,D0
		lsr.w	#3,D0
		moveq	#7,D2
		and.w	D2,D6		;Bit 0-2
		and.w	D2,D5		;Bit 3-5
		and.w	D2,D4		;Bit 6-8
		and.w	D2,D3		;Bit 9-11
		move.w	D0,D1		;Bit 12-15 = oberes Nibble
		add.w	D1,D1		;mal 2
		move.w	disass1(PC,D1.w),D1
		jmp	disass1(PC,D1.w)
		BASE DC.W,disass1
disass1:	DC.W disass_n0
		DC.W disass_n1
		DC.W disass_n2
		DC.W disass_n3
		DC.W disass_n4
		DC.W disass_n5
		DC.W disass_n6
		DC.W disass_n7
		DC.W disass_n8
		DC.W disass_n9
		DC.W disass_na
		DC.W disass_nb
		DC.W disass_nc
		DC.W disass_nd
		DC.W disass_ne
		DC.W disass_nf
disass_n0_31:	moveq	#3,D0
		and.w	D4,D0
		lea	disass_n0_32(PC),A0
		move.l	A0,-(SP)
		move.w	D0,-(SP)
		move.l	-8(A6),-(SP)	;Zeiger auf den Stringbuffer
		bsr	put_str_n
		rts
disass_n0_32:	DC.B 'BTS','T'|$80
		DC.B 'BCH','G'|$80
		DC.B 'BCL','R'|$80
		DC.B 'BSE','T'|$80
disass_n0:	btst	#8,D7
		beq.s	disass_n0_8
		cmp.w	#1,D5
		beq.s	disass_n0_3
		bsr.s	disass_n0_31
		bsr.s	disass_Dn
disass_n0_1:	bsr	put_komma
disass_n0_2:	move.w	D5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		move.w	#1,-(SP)	;Wortbreite
		bsr	put_ea
		rts
disass_n0_3:	bsr	put_str_opc
		DC.B 'MOVE','P'|$80
		EVEN
		moveq	#1,D0
		and.w	D4,D0
		addq.w	#1,D0
		bsr	put_extension
		tst.b	D7
		bpl.s	disass_n0_5
		bsr.s	disass_Dn
		bsr	put_komma
disass_n0_4:	move.w	#5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		clr.w	-(SP)		;Bytebreite
		bsr	put_ea
		rts
disass_n0_5:	bsr.s	disass_n0_4
disass_kommaDn: bsr	put_komma
disass_Dn:	move.w	D3,D0
		bsr	put_Dn
		rts
disass_n0_8:	moveq	#3,D0
		and.w	D4,D0
		subq.w	#3,D0
		bne.s	disass_n0_9
		cmp.w	#4,D3
		bne	disass_n0_22
disass_n0_9:	lea	disass_n0_30(PC),A0
		clr.w	D1
		move.b	0(A0,D3.w),D1
		lea	disass_n0_9(PC),A0
		jmp	0(A0,D1.w)
disass_n0_10:	bsr	put_str_opc
		DC.B 'OR','I'|$80
		EVEN
disass_n0_11:	move.w	D4,D0
		bsr	put_extension
		move.w	D4,D0
		bsr	put_ea_imme
		cmp.w	#7,D5
		bne.s	disass_n0_17
		cmp.w	#4,D6
		bne.s	disass_n0_17
		bsr	put_komma
		tst.w	D4
		beq	disass_n4_19
		subq.w	#1,D4
		bra	disass_n4_22
disass_n0_12:	bsr	put_str_opc
		DC.B 'AND','I'|$80
		bra.s	disass_n0_11
disass_n0_13:	bsr	put_str_opc
		DC.B 'SUB','I'|$80
disass_n0_14:	move.w	D4,D0
		bsr	put_extension
		move.w	D4,D0
		bsr	put_ea_imme
		bra.s	disass_n0_17
disass_n0_15:	bsr	put_str_opc
		DC.B 'ADD','I'|$80
		bra.s	disass_n0_14
disass_n0_16:	bsr	disass_n0_31
		clr.w	D0
		bsr	put_ea_imme
disass_n0_17:	bra	disass_n0_1
disass_n0_18:	bsr	put_str_opc
		DC.B 'EOR','I'|$80
		bra.s	disass_n0_11
disass_n0_19:	bsr	put_str_opc
		DC.B 'CMP','I'|$80
		bra.s	disass_n0_14
disass_n0_20:	bsr	put_str_opc
		DC.B 'MOVE','S'|$80
		move.w	D4,D0
		bsr	put_extension
		move.w	(A5)+,D2
		btst	#11,D2
		beq.s	disass_n0_21
		rol.w	#4,D2
		move.w	D2,D0
		bsr	put_reg
		bra.s	disass_n0_17
disass_n0_21:	move.w	D2,-(SP)
		bsr	disass_n0_2
		bsr	put_komma
		move.w	(SP)+,D2
		rol.w	#4,D2
		move.w	D2,D0
		bsr	put_reg
		rts
disass_n0_22:	btst	#11,D7
		bne.s	disass_n0_28
		cmp.w	#3,D3
		beq.s	disass_n0_26
		move.w	(A5)+,D2
		move.w	D2,D0
		rol.w	#4,D0
		move.w	D0,-(SP)
		btst	#11,D2
		beq.s	disass_n0_23
		bsr	put_str_opc
		DC.B 'CHK','2'|$80
		bra.s	disass_n0_24
disass_n0_23:	bsr	put_str_opc
		DC.B 'CMP','2'|$80
disass_n0_24:	move.w	D3,D0
		bsr	put_extension
		bsr	disass_n0_2
		bsr	put_komma
		move.w	(SP)+,D0
disass_n0_25:	bsr	put_reg
		rts
disass_n0_26:	cmp.w	#1,D5
		ble.s	disass_n0_27
		bsr	put_str_opc
		DC.B 'CALL','M'|$80
		clr.w	D0
		bsr	put_ea_imme
		bra	disass_n0_1
disass_n0_27:	bsr	put_str_opc
		DC.B 'RT','M'|$80
		move.w	D7,D0
		bra.s	disass_n0_25
disass_n0_28:	move.w	(A5)+,D2
		cmp.w	#7,D5
		bne.s	disass_n0_29
		cmp.w	#4,D6
		bne.s	disass_n0_29
		bsr	put_str_opc
		DC.B 'CAS','2'|$80
		move.w	D3,D0
		subq.w	#1,D0
		bsr	put_extension
		move.w	(A5)+,-(SP)
		move.w	D2,D0
		bsr	put_Dn
		moveq	#':',D0
		bsr	put_char
		move.w	(SP),D0
		bsr	put_Dn
		bsr	put_komma
		move.w	D2,D0
		lsr.w	#6,D0
		bsr	put_Dn
		moveq	#':',D0
		bsr	put_char
		move.w	(SP),D0
		lsr.w	#6,D0
		bsr	put_Dn
		bsr	put_str_ea
		DC.B ',','('|$80
		rol.w	#4,D2
		move.w	D2,D0
		bsr	put_reg
		bsr	put_str_ea
		DC.B '):','('|$80
		move.w	(SP)+,D0
		rol.w	#4,D0
		bsr	put_reg
		moveq	#')',D0
		bra	put_char
disass_n0_29:	bsr	put_str_opc
		DC.B 'CA','S'|$80
		move.w	D3,D0
		subq.w	#1,D0
		bsr	put_extension
		move.w	D2,D0
		bsr	put_Dn
		bsr	put_komma
		lsr.w	#6,D2
		move.w	D2,D0
		bsr	put_Dn
		bra	disass_n0_1
		BASE DC.B,disass_n0_9
disass_n0_30:	DC.B disass_n0_10
		DC.B disass_n0_12
		DC.B disass_n0_13
		DC.B disass_n0_15
		DC.B disass_n0_16
		DC.B disass_n0_18
		DC.B disass_n0_19
		DC.B disass_n0_20

disass_n1:	bsr	put_str_opc
		DC.B 'MOVE.','B'|$80
		move.w	D5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		clr.w	-(SP)		;Bytebreite
		bsr	put_ea
disass_n1_1:	bsr	put_komma
		move.w	D4,-(SP)	;Mode
		move.w	D3,-(SP)	;Register
		clr.w	-(SP)		;Bytebreite
		bsr	put_ea
		rts

disass_n2:	cmp.w	#1,D4
		bne.s	disass_n2_1
		bsr	put_str_opc
		DC.B 'MOVEA.','L'|$80
		bra.s	disass_n2_2
disass_n2_1:	bsr	put_str_opc
		DC.B 'MOVE.','L'|$80
disass_n2_2:	move.w	D5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		move.w	#2,-(SP)	;Langwortbreite
		bsr	put_ea
		bra.s	disass_n1_1

disass_n3:	cmp.w	#1,D4
		bne.s	disass_n3_1
		bsr	put_str_opc
		DC.B 'MOVEA.','W'|$80
		bra.s	disass_n3_2
disass_n3_1:	bsr	put_str_opc
		DC.B 'MOVE.','W'|$80
disass_n3_2:	bsr	disass_n0_2
		bra.s	disass_n1_1

disass_n4:	move.w	D4,D0
		subq.w	#4,D0
		bne.s	disass_n4_1
		bsr	put_str_opc
		DC.B 'CHK.','L'|$80
		move.w	D5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		move.w	#2,-(SP)	;Langwortbreite
		bsr	put_ea
		bra.s	disass_n4_3
disass_n4_1:	subq.w	#2,D0
		bne.s	disass_n4_4
		bsr	put_str_opc
		DC.B 'CHK.','W'|$80
disass_n4_2:	bsr	disass_n0_2
disass_n4_3:	bra	disass_kommaDn
disass_n4_4:	subq.w	#1,D0
		bne.s	disass_n4_6
		tst.w	D5
		bne.s	disass_n4_5
		bsr	put_str_opc
		DC.B 'EXTB.','L'|$80
		bra	disass_n4_30
disass_n4_5:	bsr	put_str_opc
		DC.B 'LE','A'|$80
		bra	disass_n9_4
disass_n4_6:	btst	#8,D7
		beq.s	disass_n4_8
disass_err3:	bset	#16,D7
		rts
disass_n4_8:	move.w	D3,D1
		add.w	D1,D1
		move.w	disass_n4_9(PC,D1.w),D1
		jmp	disass_n4_9(PC,D1.w)
		BASE DC.W,disass_n4_9
disass_n4_9:	DC.W disass_n4_10
		DC.W disass_n4_15
		DC.W disass_n4_17
		DC.W disass_n4_20
		DC.W disass_n4_23
		DC.W disass_n4_37
		DC.W disass_n4_40
		DC.W disass_n4_48
disass_n4_10:	cmp.w	#3,D4
		bne.s	disass_n4_12
		bsr	put_str_opc
		DC.B 'MOV','E'|$80
		bsr.s	disass_n4_22
disass_n4_11:	bra	disass_n0_1
disass_n4_12:	bsr	put_str_opc
		DC.B 'NEG','X'|$80
disass_n4_13:	move.w	D4,D0
		bsr	put_extension
disass_n4_14:	bra	disass_n0_2
disass_n4_15:	cmp.w	#3,D4
		bne.s	disass_n4_16
		bsr	put_str_opc
		DC.B 'MOV','E'|$80
		bsr.s	disass_n4_19
		bra.s	disass_n4_11
disass_n4_16:	bsr	put_str_opc
		DC.B 'CL','R'|$80
		bra.s	disass_n4_13
disass_n4_17:	cmp.w	#3,D4
		beq.s	disass_n4_18
		bsr	put_str_opc
		DC.B 'NE','G'|$80
		bra.s	disass_n4_13
disass_n4_18:	bsr	put_str_opc
		DC.B 'MOV','E'|$80
		bsr.s	disass_n4_14
		bsr	put_komma
disass_n4_19:	bsr	put_str_ea
		DC.B 'CC','R'|$80
		rts
disass_n4_20:	cmp.w	#3,D4
		beq.s	disass_n4_21
		bsr	put_str_opc
		DC.B 'NO','T'|$80
		bra.s	disass_n4_13
disass_n4_21:	bsr	put_str_opc
		DC.B 'MOV','E'|$80
		bsr.s	disass_n4_14
		bsr	put_komma
disass_n4_22:	bsr	put_str_ea
		DC.B 'S','R'|$80
		rts
disass_n4_23:	lea	disass_n4_36(PC),A0
		clr.w	D1
		move.b	0(A0,D4.w),D1
		lea	disass_n4_23(PC),A0
		jmp	0(A0,D1.w)
disass_n4_24:	cmp.w	#1,D5
		bne.s	disass_n4_25
		bsr	put_str_opc
		DC.B 'LINK.','L'|$80
		move.w	D6,D0
		bsr	put_An
		bsr	put_komma
		moveq	#2,D0
		bsr	put_ea_imme
		rts
disass_n4_25:	bsr	put_str_opc
		DC.B 'NBC','D'|$80
disass_n4_26:	bra	disass_n0_2
disass_n4_27:	tst.w	D5
		beq.s	disass_n4_29
		cmp.w	#1,D5
		bne.s	disass_n4_28
		bsr	put_str_opc
		DC.B 'BKP','T'|$80
		move.w	D6,D0
		bsr	put_4bit_imme
		rts
disass_n4_28:	bsr	put_str_opc
		DC.B 'PE','A'|$80
		bra.s	disass_n4_26
disass_n4_29:	bsr	put_str_opc
		DC.B 'SWA','P'|$80
disass_n4_30:	move.w	D6,D0
		bsr	put_Dn
		rts
disass_n4_31:	tst.w	D5
		bne.s	disass_n4_32
		bsr	put_str_opc
		DC.B 'EXT.','W'|$80
		bra.s	disass_n4_30
disass_n4_32:	bsr	put_str_opc
		DC.B 'MOVEM.','W'|$80
disass_n4_33:	move.w	(A5)+,-(SP)
		clr.w	-(SP)
		bsr	put_regmask
		bra	disass_n0_1
disass_n4_34:	tst.w	D5
		bne.s	disass_n4_35
		bsr	put_str_opc
		DC.B 'EXT.','L'|$80
		bra.s	disass_n4_30
disass_n4_35:	bsr	put_str_opc
		DC.B 'MOVEM.','L'|$80
		bra.s	disass_n4_33
		BASE DC.B,disass_n4_23
disass_n4_36:	DC.B disass_n4_24
		DC.B disass_n4_27
		DC.B disass_n4_31
		DC.B disass_n4_34
disass_n4_37:	cmp.w	#3,D4
		bne.s	disass_n4_39
		cmp.w	#7,D5
		bne.s	disass_n4_38
		cmp.w	#4,D6
		bne.s	disass_n4_38
		bsr	put_str_opc
		DC.B 'ILLEGA','L'|$80
		rts
disass_n4_38:	bsr	put_str_opc
		DC.B 'TA','S'|$80
		bra	disass_n0_2
disass_n4_39:	bsr	put_str_opc
		DC.B 'TS','T'|$80
		bra	disass_n4_13
disass_n4_40:	move.w	(A5)+,-(SP)
		move.w	(SP),D2
		tst.w	D4
		bne.s	disass_n4_44
		btst	#11,D2
		bne.s	disass_n4_41
		bsr	put_str_opc
		DC.B 'MULU.','L'|$80
		bra.s	disass_n4_42
disass_n4_41:	bsr	put_str_opc
		DC.B 'MULS.','L'|$80
disass_n4_42:	move.w	D5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		move.w	#2,-(SP)	;Langwortbreite
		bsr	put_ea
		bsr	put_komma
		move.w	(SP)+,D2
		btst	#10,D2
		beq.s	disass_n4_43
		move.w	D2,D0
		bsr	put_Dn
		moveq	#':',D0
		bsr	put_char
disass_n4_43:	rol.w	#4,D2
		move.w	D2,D0
		bsr	put_Dn
		rts
disass_n4_44:	cmp.w	#1,D4
		bne.s	disass_n4_47
		btst	#10,D2
		bne.s	disass_n4_45
		moveq	#7,D0
		and.w	D2,D0
		move.w	D2,D1
		lsr.w	#8,D1
		lsr.w	#4,D1
		cmp.w	D0,D1
		beq.s	disass_n4_45
		bsr	put_str_opc
		DC.B 'T'|$80
		bset	#2,(SP)
disass_n4_45:	btst	#11,D2
		bne.s	disass_n4_46
		bsr	put_str_opc
		DC.B 'DIVU.','L'|$80
		bra.s	disass_n4_42
disass_n4_46:	bsr	put_str_opc
		DC.B 'DIVS.','L'|$80
		bra.s	disass_n4_42
disass_n4_47:	bsr	put_str_opc
		DC.B 'MOVE','M'|$80
		moveq	#1,D0
		and.w	D4,D0
		addq.w	#1,D0
		bsr	put_extension
		bsr.s	disass_n4_51
		bsr	put_komma
		clr.w	-(SP)
		bsr	put_regmask
		rts
disass_n4_48:	lea	disass_n4_81(PC),A0
		clr.w	D1
		move.b	0(A0,D4.w),D1
		lea	disass_n4_48(PC),A0
		jmp	0(A0,D1.w)
disass_err4:	bset	#16,D7
		rts
disass_n4_50:	bsr	put_str_opc
		DC.B 'JS','R'|$80
disass_n4_51:	bra	disass_n0_2
disass_n4_52:	bsr	put_str_opc
		DC.B 'JM','P'|$80
		bra.s	disass_n4_51
disass_n4_53:	moveq	#6,D0
		and.w	D5,D0
		bne.s	disass_n4_54
		bsr	put_str_opc
		DC.B 'TRA','P'|$80
		move.w	D7,D0
		bsr	put_4bit_imme
		rts
disass_n4_54:	lea	disass_n4_82(PC),A0
		clr.w	D1
		move.b	0(A0,D5.w),D1
		lea	disass_n4_54(PC),A0
		jmp	0(A0,D1.w)
disass_n4_55:	bsr	put_str_opc
		DC.B 'LIN','K'|$80
		move.w	D6,D0
		bsr	put_An
disass_n4_56:	bsr	put_komma
disass_n4_57:	moveq	#1,D0
		bsr	put_ea_imme
		rts
disass_n4_58:	bsr	put_str_opc
		DC.B 'UNL','K'|$80
		bra.s	disass_n4_63
disass_n4_59:	bsr	put_str_opc
		DC.B 'MOV','E'|$80
		move.w	D6,D0
		bsr	put_An
		bsr	put_komma
disass_n4_60:	bsr	put_str_ea
		DC.B 'US','P'|$80
		rts
disass_n4_61:	bsr	put_str_opc
		DC.B 'MOV','E'|$80
		bsr.s	disass_n4_60
disass_n4_62:	bsr	put_komma
disass_n4_63:	move.w	D6,D0
		bsr	put_An
		rts
disass_n4_64:	lea	disass_n4_83(PC),A0
		clr.w	D1
		move.b	0(A0,D6.w),D1
		lea	disass_n4_64(PC),A0
		jmp	0(A0,D1.w)
disass_n4_65:	bsr	put_str_opc
		DC.B 'RESE','T'|$80
		rts
disass_n4_66:	bsr	put_str_opc
		DC.B 'NO','P'|$80
		rts
disass_n4_67:	bsr	put_str_opc
		DC.B 'STO','P'|$80
disass_n4_68:	bra.s	disass_n4_57
disass_n4_69:	bsr	put_str_opc
		DC.B 'RT','E'|$80
		rts
disass_n4_70:	bsr	put_str_opc
		DC.B 'RT','D'|$80
		bra.s	disass_n4_68
disass_n4_71:	bsr	put_str_opc
		DC.B 'RT','S'|$80
		rts
disass_n4_72:	bsr	put_str_opc
		DC.B 'TRAP','V'|$80
		rts
disass_n4_73:	bsr	put_str_opc
		DC.B 'RT','R'|$80
		rts
disass_n4_74:	bsr	put_str_opc
		DC.B 'MOVE','C'|$80
		move.w	(A5)+,D2
		btst	#0,D7
		bne.s	disass_n4_75
		bsr.s	disass_n4_76
		bsr	put_komma
		rol.w	#4,D2
		move.w	D2,D0
		bsr	put_reg
		rts
disass_n4_75:	move.w	D2,D0
		rol.w	#4,D0
		bsr	put_reg
		bsr	put_komma
disass_n4_76:	move.w	D2,D1
		and.w	#$07F8,D1
disass_n4_77:	bne	disass_err3
		moveq	#7,D1
		and.w	D2,D1
		btst	#11,D2
		beq.s	disass_n4_78
		cmp.w	#4,D1
		bgt.s	disass_n4_77
		bra.s	disass_n4_79
disass_n4_78:	cmp.w	#2,D1
		bgt.s	disass_n4_77
		addq.w	#5,D1
disass_n4_79:	lea	disass_n4_80(PC),A0
		move.l	A0,-(SP)
		move.w	D1,-(SP)
		move.l	A3,-(SP)
		bsr	put_str_n
		rts
disass_n4_80:	DC.B 'US','P'|$80
		DC.B 'VB','R'|$80
		DC.B 'CAA','R'|$80
		DC.B 'MS','P'|$80
		DC.B 'IS','P'|$80
		DC.B 'SF','C'|$80
		DC.B 'DF','C'|$80
		DC.B 'CAC','R'|$80
		BASE DC.B,disass_n4_48
disass_n4_81:	DC.B disass_err4
		DC.B disass_n4_53
		DC.B disass_n4_50
		DC.B disass_n4_52
		BASE DC.B,disass_n4_54
disass_n4_82:	DC.B disass_n4_55
		DC.B disass_n4_55
		DC.B disass_n4_55
		DC.B disass_n4_58
		DC.B disass_n4_59
		DC.B disass_n4_61
		DC.B disass_n4_64
		DC.B disass_n4_74
		BASE DC.B,disass_n4_64
disass_n4_83:	DC.B disass_n4_65
		DC.B disass_n4_66
		DC.B disass_n4_67
		DC.B disass_n4_69
		DC.B disass_n4_70
		DC.B disass_n4_71
		DC.B disass_n4_72
		DC.B disass_n4_73

disass_n5:	moveq	#3,D0
		and.w	D4,D0
		subq.w	#3,D0
		bne.s	disass_n5_5
		cmp.w	#1,D5
		beq.s	disass_n5_9
		cmp.w	#7,D5
		bne.s	disass_n5_4
		cmp.w	#1,D6
		ble.s	disass_n5_4
		subq.w	#4,D6
		bne.s	disass_n5_1
		bsr	put_str_opc
		DC.B 'T'|$80
		bsr.s	disass_n5_10
		bra.s	disass_n5_3
disass_n5_1:	bgt	disass_err3
		bsr	put_str_opc
		DC.B 'T','P'|$80
		bsr.s	disass_n5_10
disass_n5_2:	and.w	#1,D6
		addq.w	#1,D6
		move.w	D6,D0
		bsr	put_extension
		move.w	D6,D0
		bsr	put_ea_imme
disass_n5_3:	rts
disass_n5_4:	bsr	put_str_opc
		DC.B 'S'|$80
		bsr.s	disass_n5_10
		bra	disass_n0_2
disass_n5_5:	btst	#8,D7
		beq.s	disass_n5_6
		bsr	put_str_opc
		DC.B 'SUB','Q'|$80
		bra.s	disass_n5_7
disass_n5_6:	bsr	put_str_opc
		DC.B 'ADD','Q'|$80
disass_n5_7:	move.w	D4,D0
		bsr	put_extension
		move.w	D3,D0
		tst.w	D0
		bne.s	disass_n5_8
		addq.w	#8,D0
disass_n5_8:	bsr	put_4bit_imme
		bra	disass_n0_1
disass_n5_9:	bsr	put_str_opc
		DC.B 'D','B'|$80
		bsr.s	disass_n5_10
		bsr	disass_n4_30
		bsr	put_komma
		bra.s	disass_n6_4
disass_n5_10:	move.w	D7,D0
		lsr.w	#8,D0
		and.w	#$0F,D0
disass_n5_11:	lea	disass_n5_12(PC),A0
		move.l	A0,-(SP)
		move.w	D0,-(SP)
		move.l	-8(A6),-(SP)	;Zeiger auf den Stringbuffer
		bsr	put_str_n
		rts
disass_n5_12:	DC.B 'T'|$80
		DC.B 'F'|$80
		DC.B 'H','I'|$80
		DC.B 'L','S'|$80
		DC.B 'C','C'|$80
		DC.B 'C','S'|$80
		DC.B 'N','E'|$80
		DC.B 'E','Q'|$80
		DC.B 'V','C'|$80
		DC.B 'V','S'|$80
		DC.B 'P','L'|$80
		DC.B 'M','I'|$80
		DC.B 'G','E'|$80
		DC.B 'L','T'|$80
		DC.B 'G','T'|$80
		DC.B 'L','E'|$80

disass_n6:	bsr	put_str_opc
		DC.B 'B'|$80
		move.w	D7,D0
		lsr.w	#8,D0
		and.w	#$0F,D0
		beq.s	disass_n6_1
		cmp.w	#1,D0
		beq.s	disass_n6_2
		bsr.s	disass_n5_11
		bra.s	disass_n6_3
disass_n6_1:	bsr	put_str_opc
		DC.B 'R','A'|$80
		bra.s	disass_n6_3
disass_n6_2:	bsr	put_str_opc
		DC.B 'S','R'|$80
disass_n6_3:	tst.b	D7
		bne.s	disass_n6_5
disass_n6_4:	move.w	#2,-(SP)
		bsr	put_relativ_w
		rts
disass_n6_5:	cmp.b	#-1,D7
		bne.s	disass_n6_7
disass_n6_6:	bsr	put_extension2
		move.w	#4,-(SP)
		bsr	put_relativ_l
		rts
disass_n6_7:	bsr	put_str_opc
		DC.B '.','S'|$80
		clr.w	-(SP)
		move.w	D7,-(SP)
		bsr	put_relativ_b
		rts

disass_n7:	btst	#8,D7		;fehler?
		bne	disass_err3	;Ja! =>
		bsr	put_str_opc
		DC.B 'MOVE','Q'|$80
		bsr	put_str_ea
		DC.B '#','$'|$80
		move.w	D7,-(SP)
		bsr	put_hexb
disass_n7_3:	bra	disass_kommaDn

disass_n8:	move.w	D4,D2
		subq.w	#3,D2
		beq.s	disass_n8_7
		subq.w	#4,D2
		beq.s	disass_n8_9
		btst	#8,D7
		beq.s	disass_n8_10
		cmp.w	#1,D5
		bgt.s	disass_n8_10
		addq.w	#3,D2
		beq.s	disass_n8_3
		subq.w	#1,D2
		beq.s	disass_n8_1
		bsr	put_str_opc
		DC.B 'UNP','K'|$80
		bra.s	disass_n8_2
disass_n8_1:	bsr	put_str_opc
		DC.B 'PAC','K'|$80
disass_n8_2:	bsr.s	disass_n8_4
		bra	disass_n4_56
disass_n8_3:	bsr	put_str_opc
		DC.B 'SBC','D'|$80
disass_n8_4:	tst.w	D5
		bne.s	disass_n8_6
		bsr	disass_n4_30
disass_n8_5:	bra.s	disass_n7_3
disass_n8_6:	move.w	#4,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		clr.w	-(SP)		;Bytebreite
		bsr	put_ea
		bsr	put_komma
		move.w	#4,-(SP)	;Mode
		move.w	D3,-(SP)	;Register
		clr.w	-(SP)		;Bytebreite
		bsr	put_ea
		rts
disass_n8_7:	bsr	put_str_opc
		DC.B 'DIVU.','W'|$80
disass_n8_8:	bra	disass_n4_2
disass_n8_9:	bsr	put_str_opc
		DC.B 'DIVS.','W'|$80
		bra.s	disass_n8_8
disass_n8_10:	bsr	put_str_opc
		DC.B 'O','R'|$80
disass_n8_11:	move.w	D4,D0
		bsr	put_extension
		btst	#8,D7
		bne.s	disass_n8_12
		bsr.s	disass_n8_13
		bra.s	disass_n8_5
disass_n8_12:	bsr	disass_Dn
		bsr	put_komma
disass_n8_13:	move.w	D5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		moveq	#3,D0
		and.w	D4,D0
		move.w	D0,-(SP)	;Breite
		bsr	put_ea
		rts

disass_n9:	move.w	D4,D2
		subq.w	#3,D2
		beq.s	disass_n9_3
		subq.w	#4,D2
		beq.s	disass_n9_6
		btst	#8,D7
		beq.s	disass_n9_2
		cmp.w	#1,D5
		bgt.s	disass_n9_2
		bsr	put_str_opc
		DC.B 'SUB','X'|$80
disass_n9_1:	move.w	D4,D0
		bsr	put_extension
		bra	disass_n8_4
disass_n9_2:	bsr	put_str_opc
		DC.B 'SU','B'|$80
		bra.s	disass_n8_11
disass_n9_3:	bsr	put_str_opc
		DC.B 'SUBA.','W'|$80
disass_n9_4:	bsr	disass_n0_2
disass_n9_5:	bsr	put_komma
		move.w	D3,D0
		bsr	put_An
		rts
disass_n9_6:	bsr	put_str_opc
		DC.B 'SUBA.','L'|$80
disass_n9_7:	move.w	D5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		move.w	#2,-(SP)	;Langwortbreite
		bsr	put_ea
		bra.s	disass_n9_5

disass_na:	bsr	put_str_opc
		DC.B 'LINEA',' '|$80
		moveq	#'$',D0
		bsr	put_char
		move.w	D7,-(SP)
		bsr	put_hexw
		rts

disass_nb:	move.w	D4,D2
		subq.w	#3,D2
		beq.s	disass_nb_2
		subq.w	#4,D2
		beq.s	disass_nb_3
		btst	#8,D7
		beq.s	disass_nb_4
		cmp.w	#1,D5
		beq.s	disass_nb_5
		bsr	put_str_opc
		DC.B 'EO','R'|$80
disass_nb_1:	bra	disass_n8_11
disass_nb_2:	bsr	put_str_opc
		DC.B 'CMPA.','W'|$80
		bra.s	disass_n9_4
disass_nb_3:	bsr	put_str_opc
		DC.B 'CMPA.','L'|$80
		bra.s	disass_n9_7
disass_nb_4:	bsr	put_str_opc
		DC.B 'CM','P'|$80
		bra.s	disass_nb_1
disass_nb_5:	bsr	put_str_opc
		DC.B 'CMP','M'|$80
		move.w	D4,D0
		bsr	put_extension
		move.w	#3,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		clr.w	-(SP)		;Bytebreite
		bsr	put_ea
		bsr	put_komma
		move.w	#3,-(SP)	;Mode
		move.w	D3,-(SP)	;Register
		clr.w	-(SP)		;Bytebreite
		bsr	put_ea
		rts

disass_nc:	move.w	D4,D2
		subq.w	#3,D2
		beq.s	disass_nc_6
		subq.w	#4,D2
		beq.s	disass_nc_8
		btst	#8,D7
		beq.s	disass_nc_9
		cmp.w	#1,D5
		bgt.s	disass_nc_9
		addq.w	#3,D2
		bne.s	disass_nc_1
		bsr	put_str_opc
		DC.B 'ABC','D'|$80
		bra	disass_n8_4
disass_nc_1:	bsr	put_str_opc
		DC.B 'EX','G'|$80
		subq.w	#1,D2
		beq.s	disass_nc_3
		subq.w	#1,D2
		bne	disass_err3
		tst.w	D5
		beq	disass_err3
		bsr	disass_Dn
disass_nc_2:	bra	disass_n4_62
disass_nc_3:	tst.w	D5
		beq.s	disass_nc_4
		move.w	D3,D0
		bsr	put_An
		bra.s	disass_nc_2
disass_nc_4:	bsr	disass_Dn
disass_nc_5:	bsr	put_komma
		bra	disass_n4_30
disass_nc_6:	bsr	put_str_opc
		DC.B 'MULU.','W'|$80
disass_nc_7:	bra	disass_n4_2
disass_nc_8:	bsr	put_str_opc
		DC.B 'MULS.','W'|$80
		bra.s	disass_nc_7
disass_nc_9:	bsr	put_str_opc
		DC.B 'AN','D'|$80
disass_nc_10:	bra	disass_n8_11

disass_nd:	move.w	D4,D2
		subq.w	#3,D2
		beq.s	disass_nd_2
		subq.w	#4,D2
		beq.s	disass_nd_3
		btst	#8,D7
		beq.s	disass_nd_1
		cmp.w	#1,D5
		bgt.s	disass_nd_1
		bsr	put_str_opc
		DC.B 'ADD','X'|$80
		bra	disass_n9_1
disass_nd_1:	bsr	put_str_opc
		DC.B 'AD','D'|$80
		bra.s	disass_nc_10
disass_nd_2:	bsr	put_str_opc
		DC.B 'ADDA.','W'|$80
		bra	disass_n9_4
disass_nd_3:	bsr	put_str_opc
		DC.B 'ADDA.','L'|$80
		bra	disass_n9_7

disass_ne:	moveq	#3,D0
		and.w	D4,D0
		subq.w	#3,D0
		beq.s	disass_ne_5
		moveq	#3,D0
		and.w	D5,D0
		add.w	D0,D0
		btst	#8,D7
		beq.s	disass_ne_1
		addq.w	#1,D0
disass_ne_1:	bsr.s	disass_ne_6
		move.w	D4,D0
		bsr	put_extension
		btst	#5,D7
		beq.s	disass_ne_2
		bsr	disass_Dn
		bra.s	disass_ne_4
disass_ne_2:	move.w	D3,D0
		tst.w	D0
		bne.s	disass_ne_3
		addq.w	#8,D0
disass_ne_3:	bsr	put_4bit_imme
disass_ne_4:	bra	disass_nc_5
disass_ne_5:	btst	#11,D7
		bne.s	disass_ne_8
		move.w	D7,D0
		lsr.w	#8,D0
		and.w	#7,D0
		bsr.s	disass_ne_6
		moveq	#1,D0
		bsr	put_extension
		bra	disass_n0_2
disass_ne_6:	lea	disass_ne_7(PC),A0
		move.l	A0,-(SP)
		move.w	D0,-(SP)
		move.l	-8(A6),-(SP)	;Zeiger auf den Stringbuffer
		bsr	put_str_n
		rts
disass_ne_7:	DC.B 'AS','R'|$80
		DC.B 'AS','L'|$80
		DC.B 'LS','R'|$80
		DC.B 'LS','L'|$80
		DC.B 'ROX','R'|$80
		DC.B 'ROX','L'|$80
		DC.B 'RO','R'|$80
		DC.B 'RO','L'|$80

disass_ne_8:	move.w	D7,D2
		lsr.w	#8,D2
		and.w	#7,D2
		lea	disass_ne_17(PC),A0
		move.l	A0,-(SP)
		move.w	D2,-(SP)
		move.l	-8(A6),-(SP)	;Zeiger auf den Stringbuffer
		bsr	put_str_n
		move.w	(A5)+,-(SP)
		btst	#8,D7
		beq.s	disass_ne_9
		subq.w	#7,D2
		bne.s	disass_ne_10
		move.w	(SP),D2
		bsr.s	disass_ne_11
		bsr	put_komma
disass_ne_9:	bsr.s	disass_ne_12
		rts
disass_ne_10:	bsr.s	disass_ne_12
		bsr	put_komma
disass_ne_11:	bra	disass_n4_43
disass_ne_12:	bsr	disass_n0_2
		moveq	#'{',D0
		bsr	put_char
		movea.l (SP)+,A2
		move.w	(SP)+,D2
		move.l	A2,-(SP)
		move.w	D2,D0
		lsr.w	#6,D0
		btst	#11,D2
		beq.s	disass_ne_13
		and.w	#7,D0
		bsr	put_Dn
		bra.s	disass_ne_14
disass_ne_13:	and.w	#$1F,D0
		move.w	D0,-(SP)
		moveq	#'$',D0
		bsr	put_char
		bsr	put_hexb
disass_ne_14:	moveq	#':',D0
		bsr	put_char
		move.w	D2,D0
		btst	#5,D2
		beq.s	disass_ne_15
		and.w	#7,D0
		bsr	put_Dn
		bra.s	disass_ne_16
disass_ne_15:	and.w	#$1F,D0
		move.w	D0,-(SP)
		moveq	#'$',D0
		bsr	put_char
		bsr	put_hexb
disass_ne_16:	moveq	#'}',D0
		bra	put_char
disass_ne_17:	DC.B 'BFTS','T'|$80
		DC.B 'BFEXT','U'|$80
		DC.B 'BFCH','G'|$80
		DC.B 'BFEXT','S'|$80
		DC.B 'BFCL','R'|$80
		DC.B 'BFFF','O'|$80
		DC.B 'BFSE','T'|$80
		DC.B 'BFIN','S'|$80
		ENDPART

disass_nf:	cmp.b	pmmu_id(PC),D3	;PMMU?
		bne	disass_nf_1	;Nein =>
		>PART 'disass-PMMU'
		bsr	put_str_opc
		DC.B 'P'|$80
		move.w	D4,D0
		add.w	D0,D0
		move.w	disass_nfpmmu(PC,D0.w),D0
		jmp	disass_nfpmmu(PC,D0.w)
		BASE DC.W,disass_nfpmmu
disass_nfpmmu:	DC.W disass_nfpmmu1
		DC.W disass_nfpmmu44
		DC.W disass_nfpmmu52
		DC.W disass_nfpmmu52
		DC.W disass_nfpmmu53
		DC.W disass_nfpmmu54
		DC.W disass_nf_exit
		DC.W disass_nf_exit

disass_nfpmmu1: move.w	(A5)+,D3
		move.w	D3,D4
		rol.w	#6,D4
		and.w	#7,D4
		move.w	D3,D0
		lsr.w	#8,D0
		lsr.w	#5,D0
		move.w	D0,D1
		add.w	D1,D1
		move.w	disass_nfpmmu2(PC,D1.w),D1
		jmp	disass_nfpmmu2(PC,D1.w)
		BASE DC.W,disass_nfpmmu2
disass_nfpmmu2: DC.W disass_nfpmmu20
		DC.W disass_nfpmmu10
		DC.W disass_nfpmmu22
		DC.W disass_nfpmmu31
		DC.W disass_nfpmmu41
		DC.W disass_nfpmmu43
		DC.W disass_nf_exit
		DC.W disass_nf_exit

disass_nfpmmu3: btst	#9,D3
		beq.s	disass_nfpmmu4
		bsr	put_str_opc
		DC.B 'R'|$80
		rts
disass_nfpmmu4: bsr	put_str_opc
		DC.B 'W'|$80
		rts
disass_nfpmmu5: btst	#4,D3
		beq.s	disass_nfpmmu6
		bsr	put_str_ea
		DC.B '#','$'|$80
		move.w	D3,D0
		bsr	put_hexn
		rts
disass_nfpmmu6: btst	#3,D3
		beq.s	disass_nfpmmu7
		move.w	D3,D0
		bsr	put_Dn
		rts
disass_nfpmmu7: moveq	#7,D0
		and.w	D3,D0
		bne.s	disass_nfpmmu8
		bsr	put_str_ea
		DC.B 'SF','C'|$80
		rts
disass_nfpmmu8: subq.w	#1,D0
		bne.s	disass_pmmu_err
		bsr	put_str_ea
		DC.B 'DF','C'|$80
		rts
disass_pmmu_err:bset	#16,D7
		rts
disass_nfpmmu10:move.w	D4,D0
		bne.s	disass_nfpmmu11
		bsr	put_str_opc
		DC.B 'LOA','D'|$80
		bsr.s	disass_nfpmmu3
		bsr.s	disass_nfpmmu5
		bsr	put_komma
		bsr	disass_n0_2
		move.w	D3,D0
		lsr.w	#5,D0
		and.w	#$0F,D0
		beq.s	disass_nfpmmu17
		bra.s	disass_nfpmmu13
disass_nfpmmu11:subq.w	#2,D0
		bne.s	disass_nfpmmu12
		bsr	put_str_ea
		DC.B 'VA','L'|$80
		move.w	D3,D0
		and.w	#$03FF,D0
		bne.s	disass_nfpmmu13
		bra.s	disass_nfpmmu14
disass_nfpmmu12:subq.w	#1,D0
		bne.s	disass_nfpmmu16
		move.w	D3,D0
		bsr	put_An
		move.w	D3,D0
		and.w	#$03F8,D0
disass_nfpmmu13:bne	disass_nf_exit
disass_nfpmmu14:bsr	put_str_opc
		DC.B 'VALI','D'|$80
disass_nfpmmu15:bra	disass_n0_1
disass_nfpmmu16:bsr	put_str_opc
		DC.B 'FLUS','H'|$80
		btst	#9,D3
		bne.s	disass_nfpmmu13
		subq.w	#1,D4
		bne.s	disass_nfpmmu18
		bsr	put_str_opc
		DC.B 'A'|$80
disass_nfpmmu17:rts
disass_nfpmmu18:bsr	disass_nfpmmu5
		bsr	put_str_ea
		DC.B ',#','$'|$80
		move.w	D3,D0
		lsr.w	#5,D0
		bsr	put_hexn
		subq.w	#3,D4
		beq.s	disass_nfpmmu17
		subq.w	#1,D4
		bne.s	disass_nfpmmu19
		bsr	put_str_opc
		DC.B 'S'|$80
		bra.s	disass_nfpmmu17
disass_nfpmmu19:subq.w	#1,D4
		beq.s	disass_nfpmmu15
		bsr	put_str_opc
		DC.B 'S'|$80
		bra.s	disass_nfpmmu15
disass_nfpmmu20:cmp.w	#2,D4
		beq.s	disass_nfpmmu21
		cmp.w	#3,D4
		bne	disass_nf_exit
disass_nfpmmu21:addq.w	#6,D4
disass_nfpmmu22:bsr	put_str_opc
		DC.B 'MOV','E'|$80
		move.w	D3,D2
		and.w	#$01FF,D2
		bne	disass_nf_exit
		btst	#9,D3
		beq.s	disass_nfpmmu23
		bsr.s	disass_nfpmmu24
		bra	disass_n0_1
disass_nfpmmu23:bsr.s	disass_nfpmmu26
		bsr	put_komma
disass_nfpmmu24:lea	disass_nfpmmu25(PC),A0
		move.l	A0,-(SP)
		move.w	D4,-(SP)
		move.l	A3,-(SP)
		bsr	put_str_n
		rts
disass_nfpmmu25:DC.B 'T','C'|$80
		DC.B 'DR','P'|$80
		DC.B 'SR','P'|$80
		DC.B 'CR','P'|$80
		DC.B 'CA','L'|$80
		DC.B 'VA','L'|$80
		DC.B 'SC','C'|$80
		DC.B 'A','C'|$80
		DC.B 'TT','0'|$80
		DC.B 'TT','1'|$80

disass_nfpmmu26:clr.w	D0
		cmp.w	#7,D5
		bne.s	disass_nfpmmu27
		cmp.w	#4,D6
		beq.s	disass_nfpmmu28
disass_nfpmmu27:move.w	D5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		move.w	D0,-(SP)	;Breite
		bsr	put_ea
		rts
disass_nfpmmu28:move.b	disass_nfpmmu30(PC,D4.w),D0
		bsr	put_ea_imme
		moveq	#14,D1
		btst	D4,D1
		bne.s	disass_nfpmmu29
		rts
disass_nfpmmu29:bsr	disass_nf_fpu8
		rts
disass_nfpmmu30:DC.B 2,2,2,2,0,0,0,1,2,2

disass_nfpmmu31:bsr	put_str_opc
		DC.B 'MOV','E'|$80
		btst	#9,D3
		beq.s	disass_nfpmmu34
		subq.w	#1,D4
		bne.s	disass_nfpmmu32
		bsr	put_str_ea
		DC.B 'PCS','R'|$80
		and.w	#$01FF,D3
		bne.s	disass_nfpmmu37
		bra.s	disass_nfpmmu33
disass_nfpmmu32:addq.w	#1,D4
		bsr.s	disass_nfpmmu35
disass_nfpmmu33:bra	disass_n0_1
disass_nfpmmu34:bsr	disass_n0_2
		bsr	put_komma
disass_nfpmmu35:tst.w	D4
		bne.s	disass_nfpmmu36
		bsr	put_str_ea
		DC.B 'PS','R'|$80
		and.w	#$01FF,D3
		bne.s	disass_nfpmmu37
		rts
disass_nfpmmu36:move.w	D3,D0
		and.w	#$01E3,D0
disass_nfpmmu37:bne	disass_nf_exit
		subq.w	#4,D4
		bne.s	disass_nfpmmu38
		bsr	put_str_ea
		DC.B 'BA','D'|$80
		bra.s	disass_nfpmmu40
disass_nfpmmu38:subq.w	#1,D4
		bne.s	disass_nfpmmu39
		bsr	put_str_ea
		DC.B 'BA','C'|$80
		bra.s	disass_nfpmmu40
disass_nfpmmu39:bset	#16,D7
disass_nfpmmu40:movea.l (SP)+,A1
		move.w	D3,D0
		lsr.w	#2,D0
		move.w	D0,-(SP)
		bra	put_n
disass_nfpmmu41:bsr	put_str_opc
		DC.B 'TES','T'|$80
		bsr	disass_nfpmmu3
		bsr	disass_nfpmmu5
		bsr	put_komma
		bsr	disass_n0_2
		bsr	put_str_ea
		DC.B ',#','$'|$80
		move.w	D4,D0
		bsr	put_hexn
		btst	#8,D3
		beq.s	disass_nfpmmu42
		bsr	put_komma
		lsr.w	#5,D3
		move.w	D3,D0
		bsr	put_An
disass_nfpmmu42:rts
disass_nfpmmu43:bsr	put_str_opc
		DC.B 'FLUSH','R'|$80
		and.w	#$1FFF,D3
		bne	disass_nf_exit
		moveq	#1,D4
		bra	disass_nfpmmu26
disass_nfpmmu44:move.w	(A5)+,D2
		move.w	D2,D1
		lsr.w	#6,D1
		bne.s	disass_nfpmmu45
		move.w	D5,D0
		subq.w	#1,D0
		beq.s	disass_nfpmmu48
		subq.w	#6,D0
		bne.s	disass_nfpmmu47
		cmp.w	#1,D6
		ble.s	disass_nfpmmu47
		cmp.w	#4,D6
		blt.s	disass_nfpmmu46
disass_nfpmmu45:bne	disass_nf_exit
		bsr	put_str_opc
		DC.B 'T'|$80
		bsr.s	disass_nfpmmu49
		rts
disass_nfpmmu46:bsr	put_str_opc
		DC.B 'T','P'|$80
		bsr.s	disass_nfpmmu49
		bra	disass_n5_2
disass_nfpmmu47:bsr	put_str_opc
		DC.B 'S'|$80
		bsr.s	disass_nfpmmu49
		bra	disass_n0_2
disass_nfpmmu48:bsr	put_str_opc
		DC.B 'D','B'|$80
		bsr.s	disass_nfpmmu49
		bra	disass_nf_fpu68
disass_nfpmmu49:cmp.w	#$0F,D2
		ble.s	disass_nfpmmu50
		tst.l	(SP)+
		bra	disass_nf_exit
disass_nfpmmu50:lea	disass_nfpmmu51(PC),A0
		move.l	A0,-(SP)
		move.w	D2,-(SP)
		move.l	-8(A6),-(SP)	;Zeiger auf den Stringbuffer
		bsr	put_str_n
		rts
disass_nfpmmu51:DC.B 'B','S'|$80
		DC.B 'B','C'|$80
		DC.B 'L','S'|$80
		DC.B 'L','C'|$80
		DC.B 'S','S'|$80
		DC.B 'S','C'|$80
		DC.B 'A','S'|$80
		DC.B 'A','C'|$80
		DC.B 'W','S'|$80
		DC.B 'W','C'|$80
		DC.B 'I','S'|$80
		DC.B 'I','C'|$80
		DC.B 'G','S'|$80
		DC.B 'G','C'|$80
		DC.B 'C','S'|$80
		DC.B 'C','C'|$80

disass_nfpmmu52:moveq	#$3F,D2
		and.w	D7,D2
		bsr	put_str_opc
		DC.B 'B'|$80
		bsr.s	disass_nfpmmu49
		bra	disass_nf_fpu74
disass_nfpmmu53:bsr	put_str_opc
		DC.B 'SAV','E'|$80
		bra.s	disass_nfpmmu55
disass_nfpmmu54:bsr	put_str_opc
		DC.B 'RESTOR','E'|$80
disass_nfpmmu55:bra	disass_n0_2
		ENDPART

disass_nf_1:	cmp.b	fpu_id(PC),D3	;FPU?
		bne	disass_nf_exit	;Nein! =>
		>PART 'disass-FPU'
		bsr	put_str_opc
		DC.B 'F'|$80
		move.w	D4,D0
		add.w	D0,D0
		move.w	disass_nf_fpu(PC,D0.w),D0
		jmp	disass_nf_fpu(PC,D0.w)
		BASE DC.W,disass_nf_fpu
disass_nf_fpu:	DC.W disass_nf_fpu10
		DC.W disass_nf_fpu63
		DC.W disass_nf_fpu72
		DC.W disass_nf_fpu73
		DC.W disass_nf_fpu75
		DC.W disass_nf_fpu76
		DC.W disass_nf_exit
		DC.W disass_nf_exit

disass_nf_fpu1: clr.w	D0
		cmp.w	#7,D5
		bne.s	disass_nf_fpu2
		cmp.w	#4,D6
		beq.s	disass_nf_fpu3
disass_nf_fpu2: move.w	D5,-(SP)	;Mode
		move.w	D6,-(SP)	;Register
		move.w	D0,-(SP)	;Breite
		bsr	put_ea
		rts
disass_nf_fpu3: moveq	#$2E,D1
		btst	D4,D1
		bne.s	disass_nf_fpu4
		move.b	disass_nf_fpu9(PC,D4.w),D0
		bsr	put_ea_imme
		rts
disass_nf_fpu4: bsr	put_str_ea
		DC.B '#"','$'|$80
		bsr.s	disass_nf_fpu8
		move.w	D4,D0
		subq.w	#2,D0
		beq.s	disass_nf_fpu5
		subq.w	#1,D0
		beq.s	disass_nf_fpu5
		subq.w	#2,D0
		beq.s	disass_nf_fpu6
		bra.s	disass_nf_fpu7
disass_nf_fpu5: bsr.s	disass_nf_fpu8
disass_nf_fpu6: bsr.s	disass_nf_fpu8
disass_nf_fpu7: moveq	#'"',D0
		bsr	put_char
		rts
disass_nf_fpu8: move.l	(A5)+,-(SP)
		bsr	put_hexw
		bsr	put_hexw
		rts
disass_nf_fpu9: DC.B 2,2,2,2,1,2,0,2
		DC.B 0,1,1,1,0,1,0,1

disass_nf_fpu10:move.w	(A5)+,D3
		move.w	D3,D4
		rol.w	#6,D4
		and.w	#7,D4
		move.w	D3,D0
		lsr.w	#8,D0
		lsr.w	#5,D0
		move.w	D0,D1
		add.w	D1,D1
		move.w	disass_nf_fpu11(PC,D1.w),D1
		jmp	disass_nf_fpu11(PC,D1.w)
		BASE DC.W,disass_nf_fpu11
disass_nf_fpu11:DC.W disass_nf_fpu12
		DC.W disass_nf_exit
		DC.W disass_nf_fpu29
		DC.W disass_nf_fpu40
		DC.W disass_nf_fpu44
		DC.W disass_nf_fpu44
		DC.W disass_nf_fpu56
		DC.W disass_nf_fpu56

disass_nf_fpu12:tst.w	D5
		bne.s	disass_nf_fpu13
		tst.w	D6
disass_nf_fpu13:bne	disass_nf_exit
		bsr.s	disass_nf_fpu20
		bra.s	disass_nf_fpu19
		bra.s	disass_nf_fpu18
		move.w	D4,D0
		bsr	put_FPn
disass_nf_fpu14:bsr	put_komma
		move.w	D3,D0
		bsr	put_FPn
		moveq	#':',D0
		bsr	put_char
disass_nf_fpu15:lsr.w	#7,D3
disass_nf_fpu16:move.w	D3,D0
		bsr	put_FPn
disass_nf_fpu17:rts
disass_nf_fpu18:move.w	D4,D3
		bra.s	disass_nf_fpu16
disass_nf_fpu19:move.w	D4,D0
		bsr	put_FPn
		lsr.w	#7,D3
		and.w	#7,D3
		cmp.w	D3,D4
		beq.s	disass_nf_fpu17
		bsr	put_komma
		bra.s	disass_nf_fpu16
disass_nf_fpu20:moveq	#$7F,D2
		and.w	D3,D2
		cmp.w	#$28,D2
		bgt.s	disass_nf_fpu23
		lea	disass_nf_fpu26(PC),A0
		move.l	A0,-(SP)
		move.w	D2,-(SP)
		move.l	-8(A6),-(SP)	;Zeiger auf den Stringbuffer
		bsr	put_str_n
		movea.l -8(A6),A0	;Zeiger auf den Stringbuffer
		cmpi.b	#1,(A0)
		bne.s	disass_nf_fpu22
disass_nf_fpu21:bset	#16,D7
disass_nf_fpu22:rts
disass_nf_fpu23:cmp.w	#$38,D2
		bne.s	disass_nf_fpu24
		bsr	put_str_opc
		DC.B 'CM','P'|$80
		bra.s	disass_nf_fpu22
disass_nf_fpu24:cmp.w	#$3A,D2
		bne.s	disass_nf_fpu25
		bsr	put_str_opc
		DC.B 'TES','T'|$80
		movea.l (SP)+,A2
		jmp	2(A2)
disass_nf_fpu25:cmp.w	#$30,D2
		blt.s	disass_nf_fpu21
		cmp.w	#$37,D2
		bgt.s	disass_nf_fpu21
		bsr	put_str_opc
		DC.B 'SINCO','S'|$80
		movea.l (SP)+,A2
		jmp	4(A2)
disass_nf_fpu26:DC.B 'MOV','E'|$80
		DC.B 'IN','T'|$80
		DC.B 'SIN','H'|$80
		DC.B 'INTR','Z'|$80
		DC.B 'SQR','T'|$80
		DC.B $80
		DC.B 'LOGNP','1'|$80
		DC.B $80
		DC.B 'ETOXM','1'|$80
		DC.B 'TAN','H'|$80
		DC.B 'ATA','N'|$80
		DC.B $80
		DC.B 'ASI','N'|$80
		DC.B 'ATAN','H'|$80
		DC.B 'SI','N'|$80
		DC.B 'TA','N'|$80
		DC.B 'ETO','X'|$80
		DC.B 'TWOTO','X'|$80
		DC.B 'TENTO','X'|$80
		DC.B $80
		DC.B 'LOG','N'|$80
		DC.B 'LOG1','0'|$80
		DC.B 'LOG','2'|$80
		DC.B $80
		DC.B 'AB','S'|$80
		DC.B 'COS','H'|$80
		DC.B 'NE','G'|$80
		DC.B $80
		DC.B 'ACO','S'|$80
		DC.B 'CO','S'|$80
		DC.B 'GETEX','P'|$80
		DC.B 'GETMA','N'|$80
		DC.B 'DI','V'|$80
		DC.B 'MO','D'|$80
		DC.B 'AD','D'|$80
		DC.B 'MU','L'|$80
		DC.B 'SGLDI','V'|$80
		DC.B 'RE','M'|$80
		DC.B 'SCAL','E'|$80
		DC.B 'SGLMU','L'|$80
		DC.B 'SU','B'|$80

disass_nf_fpu27:lea	disass_nf_fpu28(PC),A0
		move.l	A0,-(SP)
		move.w	D4,-(SP)
		move.l	-8(A6),-(SP)	;Zeiger auf den Stringbuffer
		bsr	put_str_n
		rts

disass_nf_fpu28:DC.B '.','L'|$80
		DC.B '.','S'|$80
		DC.B '.','X'|$80
		DC.B '.','P'|$80
		DC.B '.','W'|$80
		DC.B '.','D'|$80
		DC.B '.','B'|$80
		DC.B '.','P'|$80

disass_nf_fpu29:cmp.w	#7,D4
		beq.s	disass_nf_fpu34
		bsr	disass_nf_fpu20
		bra.s	disass_nf_fpu32
		bra.s	disass_nf_fpu30
		bsr.s	disass_nf_fpu27
		bsr.s	disass_nf_fpu31
		bra	disass_nf_fpu14
disass_nf_fpu30:bsr.s	disass_nf_fpu27
disass_nf_fpu31:bra	disass_nf_fpu1
disass_nf_fpu32:bsr.s	disass_nf_fpu27
		bsr.s	disass_nf_fpu31
disass_nf_fpu33:bsr	put_komma
		bra	disass_nf_fpu15
disass_nf_fpu34:bsr	put_str_opc
		DC.B 'MOVEC','R'|$80
		bsr	put_str_ea
		DC.B '#','$'|$80
		moveq	#$7F,D2
		and.w	D3,D2
		move.w	D2,-(SP)
		bsr	put_hexb
		bsr.s	disass_nf_fpu33
		tst.w	D2
		bne.s	disass_nf_fpu35
		moveq	#$0A,D2
disass_nf_fpu35:cmp.w	#$0A,D2
		blt.s	disass_nf_fpu38
		cmp.w	#$0F,D2
		ble.s	disass_nf_fpu36
		cmp.w	#$30,D2
		blt.s	disass_nf_fpu38
		cmp.w	#$3F,D2
		bgt.s	disass_nf_fpu38
		sub.w	#$20,D2
disass_nf_fpu36:bsr	put_comment_tab ;Konstante als Kommentar dazu
		cmp.w	#18,D2		;2er Potenzen?
		blt.s	disass_nf_fpu37 ;Nein! =>
		bsr	put_str_ea
		DC.B '10*','*'|$80
disass_nf_fpu37:sub.w	#10,D2
		lea	disass_nf_fpu39(PC),A0
		move.l	A0,-(SP)
		move.w	D2,-(SP)
		move.l	A3,-(SP)
		bsr	put_str_n
disass_nf_fpu38:rts
disass_nf_fpu39:DC.B 'P','i'|$80
		DC.B 'Log10(2',')'|$80
		DC.B 'e'|$80
		DC.B 'Log2(e',')'|$80
		DC.B 'Log10(e',')'|$80
		DC.B '0.','0'|$80
		DC.B 'Ln(2',')'|$80
		DC.B 'Ln(10',')'|$80
		DC.B '0'|$80
		DC.B '1'|$80
		DC.B '2'|$80
		DC.B '4'|$80
		DC.B '8'|$80
		DC.B '1','6'|$80
		DC.B '3','2'|$80
		DC.B '6','4'|$80
		DC.B '12','8'|$80
		DC.B '25','6'|$80
		DC.B '51','2'|$80
		DC.B '102','4'|$80
		DC.B '204','8'|$80
		DC.B '409','6'|$80

disass_nf_fpu40:bsr	put_str_opc
		DC.B 'MOV','E'|$80
		bsr	disass_nf_fpu27
		move.w	D3,-(SP)
		bsr	disass_nf_fpu15
		bsr	put_komma
		bsr	disass_nf_fpu1
		move.w	(SP)+,D3
		move.w	D4,D0
		subq.w	#3,D0
		bne.s	disass_nf_fpu41
		bsr	put_str_ea
		DC.B '{#','$'|$80
		add.b	D3,D3
		asr.b	#1,D3
		ext.w	D3
		move.w	D3,-(SP)
		bsr	put_hexw
		bra.s	disass_nf_fpu42
disass_nf_fpu41:subq.w	#4,D0
		bne.s	disass_nf_fpu43
		moveq	#'{',D0
		bsr	put_char
		lsr.w	#4,D3
		move.w	D3,D0
		bsr	put_Dn
disass_nf_fpu42:bsr	disass_ne_16
disass_nf_fpu43:rts
disass_nf_fpu44:move.w	D3,D0
		and.w	#$03FF,D0
		bne	disass_nf_exit
		bsr	put_str_opc
		DC.B 'MOV','E'|$80
		move.w	D4,D0
		subq.w	#1,D0
		beq.s	disass_nf_fpu45
		subq.w	#1,D0
		beq.s	disass_nf_fpu45
		subq.w	#2,D0
		beq.s	disass_nf_fpu45
		bsr	put_str_opc
		DC.B 'M'|$80
disass_nf_fpu45:move.w	D4,-(SP)
		btst	#13,D3
		bne.s	disass_nf_fpu47
		cmp.w	#7,D5
		bne.s	disass_nf_fpu46
		cmp.w	#4,D6
		bne.s	disass_nf_fpu46
		move.b	disass_nf_fpu50(PC,D4.w),D4
		adda.w	D4,A5
disass_nf_fpu46:clr.w	D4
		bsr.s	disass_nf_fpu49
		bsr	put_komma
		bsr.s	disass_nf_fpu51
		rts
disass_nf_fpu47:bsr.s	disass_nf_fpu51
disass_nf_fpu48:bsr	put_komma
disass_nf_fpu49:bra	disass_nf_fpu1
disass_nf_fpu50:DC.B 0,0,0,4,0,4,4,8

disass_nf_fpu51:movea.l (SP)+,A2
		btst	#12,D3
		beq.s	disass_nf_fpu52
		bsr	put_str_ea
		DC.B 'FPC','R'|$80
		moveq	#'/',D0
		bsr	put_char
disass_nf_fpu52:btst	#11,D3
		beq.s	disass_nf_fpu53
		bsr	put_str_ea
		DC.B 'FPS','R'|$80
		moveq	#'/',D0
		bsr	put_char
disass_nf_fpu53:btst	#10,D3
		beq.s	disass_nf_fpu54
		bsr	put_str_ea
		DC.B 'FPIA','R'|$80
		moveq	#'/',D0
		bsr	put_char
disass_nf_fpu54:tst.w	(SP)+
		beq.s	disass_nf_fpu55
		subq.b	#1,(A3)
disass_nf_fpu55:jmp	(A2)
disass_nf_fpu56:cmp.w	#4,D5
		bne.s	disass_nf_fpu57
		btst	#12,D3
		bne	disass_nf_exit
		btst	#13,D3
		beq	disass_nf_exit
disass_nf_fpu57:bsr	put_str_opc
		DC.B 'MOVE','M'|$80
		btst	#11,D3
		bne.s	disass_nf_fpu58
		moveq	#0,D0
		move.b	D3,D0
		move.w	D0,-(SP)
		move.w	D0,-(SP)
disass_nf_fpu58:btst	#13,D3
		beq.s	disass_nf_fpu61
		btst	#11,D3
		bne.s	disass_nf_fpu59
		bsr	put_regmask
		bra.s	disass_nf_fpu60
disass_nf_fpu59:bsr.s	disass_nf_fpu62
disass_nf_fpu60:bra	disass_nf_fpu48
disass_nf_fpu61:bsr	disass_nf_fpu1
		bsr	put_komma
		btst	#11,D3
		bne.s	disass_nf_fpu62
		bsr	put_regmask
		rts
disass_nf_fpu62:lsr.w	#4,D3
		bra	disass_Dn
disass_nf_fpu63:move.w	(A5)+,D2
		move.w	D2,D1
		lsr.w	#6,D1
		bne.s	disass_nf_fpu64
		move.w	D5,D0
		subq.w	#1,D0
		beq.s	disass_nf_fpu67
		subq.w	#6,D0
		bne.s	disass_nf_fpu66
		cmp.w	#1,D6
		ble.s	disass_nf_fpu66
		cmp.w	#4,D6
		blt.s	disass_nf_fpu65
disass_nf_fpu64:bne	disass_nf_exit
		bsr	put_str_opc
		DC.B 'T'|$80
		bsr.s	disass_nf_fpu69
		rts
disass_nf_fpu65:bsr	put_str_opc
		DC.B 'T','P'|$80
		bsr.s	disass_nf_fpu69
		bra	disass_n5_2
disass_nf_fpu66:bsr	put_str_opc
		DC.B 'S'|$80
		bsr.s	disass_nf_fpu69
		bra	disass_nf_fpu1
disass_nf_fpu67:bsr	put_str_opc
		DC.B 'D','B'|$80
		bsr.s	disass_nf_fpu69
disass_nf_fpu68:bsr	disass_n4_30
		bsr	put_komma
		move.w	#2,-(SP)
		bsr	put_relativ_w
		rts
disass_nf_fpu69:cmp.w	#$1F,D2
		ble.s	disass_nf_fpu70
		tst.l	(SP)+
		bra	disass_nf_exit
disass_nf_fpu70:lea	disass_nf_fpu71(PC),A0
		move.l	A0,-(SP)
		move.w	D2,-(SP)
		move.l	-8(A6),-(SP)	;Zeiger auf den Stringbuffer
		bsr	put_str_n
		rts
disass_nf_fpu71:DC.B 'F'|$80
		DC.B 'E','Q'|$80
		DC.B 'OG','T'|$80
		DC.B 'OG','E'|$80
		DC.B 'OL','T'|$80
		DC.B 'OL','E'|$80
		DC.B 'OG','L'|$80
		DC.B 'O','R'|$80
		DC.B 'U','N'|$80
		DC.B 'UE','Q'|$80
		DC.B 'UG','T'|$80
		DC.B 'UG','E'|$80
		DC.B 'UL','T'|$80
		DC.B 'UL','E'|$80
		DC.B 'N','E'|$80
		DC.B 'T'|$80
		DC.B 'S','F'|$80
		DC.B 'SE','Q'|$80
		DC.B 'G','T'|$80
		DC.B 'G','E'|$80
		DC.B 'L','T'|$80
		DC.B 'L','E'|$80
		DC.B 'G','L'|$80
		DC.B 'GL','E'|$80
		DC.B 'NGL','E'|$80
		DC.B 'NG','L'|$80
		DC.B 'NL','E'|$80
		DC.B 'NL','T'|$80
		DC.B 'NG','E'|$80
		DC.B 'NG','T'|$80
		DC.B 'SNE','Q'|$80
		DC.B 'S','T'|$80

disass_nf_fpu72:moveq	#$3F,D2
		and.w	D7,D2
		bne.s	disass_nf_fpu73
		tst.w	(A5)
		bne.s	disass_nf_fpu73
		tst.w	(A5)+
		bra	disass_n4_66
disass_nf_fpu73:moveq	#$3F,D2
		and.w	D7,D2
		bsr	put_str_opc
		DC.B 'B'|$80
		bsr	disass_nf_fpu69
disass_nf_fpu74:btst	#6,D7
		beq	disass_n6_4
		bra	disass_n6_6
disass_nf_fpu75:bsr	put_str_opc
		DC.B 'SAV','E'|$80
		bra.s	disass_nf_fpu77
disass_nf_fpu76:bsr	put_str_opc
		DC.B 'RESTOR','E'|$80
disass_nf_fpu77:bra	disass_nf_fpu1
disass_nf_exit: bset	#16,D7
		rts
		ENDPART

		DATA
pmmu_id:	DC.B 0		;Co-Prozessor ID der PMMU
fpu_id: 	DC.B 1		;Co-Prozessor ID der FPU

		BSS
opcode_buf:	DS.B 80 	;Hier kommt der Opcode hin
ea_buf: 	DS.B 80 	;und hier kommt die <ea> (evtl. + Kommentar) hin
		END
