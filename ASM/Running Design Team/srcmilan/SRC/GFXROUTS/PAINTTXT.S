
PAINTTXT	equ	0


TEXTHEIGHT	equ	10


		text

; ---------------------------------------------------------
; zeiche textstring
; a0 = string
; a6 = screenadresse
paintText
		movem.l	d4-d7/a3/a5-a6,-(sp)
		move.l	a6,ptStartAddress
ptLoop
		move.b	(a0)+,d7
		beq.s	ptOut
		cmpi.b	#13,d7
		bne.s	ptNoNewline

		move.w	lineoffset,d7
		mulu	#TEXTHEIGHT,d7
		lea	ptStartAddress,a5
		movea.l	(a5),a6
		adda.l	d7,a6
		move.l	a6,(a5)
		bra.s	ptLoop
ptNoNewline
		bsr.s	ptOneLetter
		bra.s	ptLoop

ptOut
		movem.l	(sp)+,d4-d7/a3/a5-a6
		rts


; ---------------------------------------------------------
; zeichne buchstaben
; d7 = asciicode
; a6 = screenadresse
; verwendete register: a3/a5/d4-d6
ptOneLetter
		movea.l	a6,a3

		cmpi.b	#$60,d7
		blt.s	ptolNoSmallLetter
		subi.b	#$20,d7
ptolNoSmallLetter

		lea	fontGfx,a5
		andi.w	#$ff,d7
		subi.b	#"!",d7
		bmi.s	ptolIsSpace

		lsl.w	#7,d7
		adda.w	d7,a5

		move.w	lineoffset,d7
		subi.w	#16,d7

		moveq	#7,d4
ptolLoop1	moveq	#7,d5
ptolLoop2	move.w	(a5)+,d6
		beq.s	ptolSkipPixel
		move.w	d6,(a6)
ptolSkipPixel	addq.l	#2,a6
		dbra	d5,ptolLoop2
		adda.w	d7,a6
		dbra	d4,ptolLoop1

ptolIsSpace
		adda.w	#16,a3
		movea.l	a3,a6

		rts




		data


fontGfx		incbin	"include\fonts\fn_8x8-2.fnt"		; z. B. fuer meldungen am oberen bildschirmrand



		bss

ptStartAddress	ds.l	1









		ifne PAINTTXT

;---

pol_font4x8
		lea	font4x8,a5
		andi.w	#$ff,d7
		subi.b	#"!",d7
		bmi.s	pol_space4x8

		lsl.w	#6,d7
		adda.w	d7,a5

		moveq	#7,d4
fn1_4x8_loop	moveq	#3,d5
fn2_4x8_loop	move.w	(a5)+,d6
		beq.s	pol_no_pnt_4x8
		move.w	d6,(a6)
pol_no_pnt_4x8	addq.l	#2,a6
		dbra	d5,fn2_4x8_loop
		lea	320-4*2(a6),a6
		dbra	d4,fn1_4x8_loop
pol_space4x8
		adda.w	#8,a3
		movea.l	a3,a6

		rts

;---------------

;* a0 = textpointer
;* a6 = screenadresse
;* text_height

paint_menutext
                movem.l D3-A0/A3-A6,-(SP)
                move.l  A6,text_start_adr

paint_menutext_loop:
                move.b  (A0)+,D7
                beq.s   paint_menutext_out
                cmpi.b  #13,D7
                bne.s   paint_menu_now

                move.w  text_height(PC),D7
                mulu    true_offi+2,D7
                movea.l text_start_adr(PC),A6
                adda.l  D7,A6
                move.l  A6,text_start_adr
                bra.s   paint_menutext_loop

paint_menu_now	bsr.s   paint_one_menuletter
                bra.s   paint_menutext_loop

paint_menutext_out:
                movem.l (SP)+,D3-A0/A3-A6

                rts

;---------------

; d7 = asciicode
; a6 = screenadresse

; register: a3-a6, d3-d7

paint_one_menuletter:

                movea.l A6,A3

                lea     menufont+128,A5
                andi.w  #$00FF,D7
                cmpi.w  #"0",D7
                blt	its_menuspace
		cmpi.w	#"9"+1,d7
		blt	pmf_number
		cmpi.w	#"A"+36,d7
		blt.s	pmf_letter_or_number
		subi.w	#"A"+36,d7
		mulu	#16*2,d7
		addi.w	#36*11*2,d7

                adda.w  D7,A5

		tst.w	double_scan
		beq.s	pmfola_normal

                moveq   #7,D4
fnm21a          moveq   #15,D5
fnm22a          move.w  (A5)+,D6
                beq     pola_mno_paint2
                move.w  D6,(A6)
pola_mno_paint2
		addq.l  #2,A6
                dbra    D5,fnm22a
                lea     640-16*2(A6),A6
                lea     menufont_offi*2-16*2(A5),A5
                dbra    D4,fnm21a

                adda.w  #32,A3
                movea.l A3,A6
                rts


pmfola_normal
                moveq   #15,D4
fnm1a           moveq   #15,D5
fnm2a           move.w  (A5)+,D6
                beq     pola_mno_paint
                move.w  D6,(A6)
pola_mno_paint    
		addq.l  #2,A6
                dbra    D5,fnm2a
                lea     640-16*2(A6),A6
                lea     menufont_offi-16*2(A5),A5
                dbra    D4,fnm1a

                adda.w  #32,A3
                movea.l A3,A6
                rts


pmf_letter_or_number

		cmpi.w	#"A",d7
		blt.s	pmf_number
		subi.w	#"A",d7
		mulu	#11*2,d7
		bra	its_menunormal
pmf_number
		subi.w	#"0",d7
		mulu	#11*2,d7
		addi.w	#26*11*2,d7


its_menunormal
                adda.w  D7,A5

		tst.w	double_scan
		beq.s	pmfol_normal

                moveq   #8,D4
fnm21           moveq   #10,D5
fnm22           move.w  (A5)+,D6
                beq     pol_mno_paint2
                move.w  D6,(A6)
pol_mno_paint2
		addq.l  #2,A6
                dbra    D5,fnm22
                lea     640-11*2(A6),A6
                lea     menufont_offi*2-11*2(A5),A5
                dbra    D4,fnm21

                adda.w  #20,A3
                movea.l A3,A6
                rts


pmfol_normal
                moveq   #17,D4
fnm1            moveq   #10,D5
fnm2            move.w  (A5)+,D6
                beq     pol_mno_paint
                move.w  D6,(A6)
pol_mno_paint    
		addq.l  #2,A6
                dbra    D5,fnm2
                lea     640-11*2(A6),A6
                lea     menufont_offi-11*2(A5),A5
                dbra    D4,fnm1

                adda.w  #20,A3
                movea.l A3,A6
                rts

;---------------

its_menuspace:
                adda.w  #20,A3
                movea.l A3,A6

                rts

;---------------------------------------

; a0 = textpointer
; a6 = screenadresse

paint_text_no_mask:

                movem.l D3-A0/A3-A6,-(SP)
                move.l  A6,text_start_adr

paint_noma_loop:
                move.b  (A0)+,D7
                beq.s   paint_noma_out
                cmpi.b  #13,D7
                bne.s   paint_noma_now

                move.w  text_height(PC),D7
                mulu    true_offi+2,D7
                movea.l text_start_adr(PC),A6
                adda.l  D7,A6
                move.l  A6,text_start_adr
                bra.s   paint_noma_loop

paint_noma_now: bsr.s   paint_one_letter_nm
                bra.s   paint_noma_loop

paint_noma_out:
                movem.l (SP)+,D3-A0/A3-A6

                rts

;---------------

; d7 = asciicode
; a6 = screenadresse

; register: a3-a6, d3-d7

paint_one_letter_nm:

                movea.l A6,A3

                lea     font,A5
                andi.w  #$00FF,D7
                subi.b  #"!",D7
                bmi.s   its_space_nm

                lsl.w   #7,D7
                adda.w  D7,A5

                moveq   #7,D4
fn1_nm:
                move.l  (A5)+,(A6)+
                move.l  (A5)+,(A6)+
                move.l  (A5)+,(A6)+
                move.l  (A5)+,(A6)+

                lea     640-8*2(A6),A6
                dbra    D4,fn1_nm

                adda.w  #16,A3
                movea.l A3,A6

                rts

;---------------

its_space_nm:
                moveq   #7,D4
p_space_nm:
                clr.l   (A6)+
                clr.l   (A6)+
                clr.l   (A6)+
                clr.l   (A6)+

                lea     640-8*2(A6),A6

                dbra    D4,p_space_nm

                adda.w  #16,A3
                movea.l A3,A6

                rts









menufont_offi	equ	656*2

font		incbin	"fnt\fn_8x8-2.fnt"
font4x8		incbin	"fnt\fn_4x8-3.fnt"
font4x5		incbin	"fnt\fn_4x5.fnt"
menufont	incbin	"tpi\menufont.tpi"
menufont_end

		endc