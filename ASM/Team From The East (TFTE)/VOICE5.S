; (c) The Voice 5
; TFTE
*********************************************************************
* TFTE's The Voice zine       * Issue 5	the last one         		*
*********************************************************************
* Oto niespodzianka dzisiejszego wieczoru. * tak na marginesie,     *
* Pelen kod magazynu The Voice.            * kazdy kto sie chce ze  *
* Wynika z tego, ze juz jest malo prawdo - * mna skontaktowac przez *
* podobnym, aby pojawil sie nastepny numer * siec moze to zrobic	*
* The Voice.                               * wysylajac poczte na 	*
* Mozliwe, ze ukaze sie jeszcze pare art.  * adres:					*
* w QM, ale to jest tylko mozliwe.         *-----------------------------
******************************************** kowacz@mutos.ok.ae.wroc.pl |
* Oczywiscie The Voice byl kodowany przez  *-----------------------------
* STRycha/TFTE (ja),ktory ma teraz wszystko* ################       *
* w dupie i nie ma zamiaru (to ja) bawic   *   ## ##- ## ##-		*
* sie w kodowanie.						   *   ## ##  ## ####		*
*********************************************************************
* UWAGA !!!								   * Data:					*
********************************************						*
* Jezeli uzyjesz gdzies choc czesci tego   * 1994-07-02				*
* kodu to napisz przynajmniej, ze ja te    *						*
* czesc kodowalem.						   *						*
*********************************************************************
* Caly ten kod jest lamerski, a na uwage zasluguje tu jedynie fakt  *
* ze to wszystko jakos dziala. 										*
*********************************************************************
* Krotki tekst do Van Ejik'a. Zobacz jak dzielone sa strony i jak   *
* wykonana jest obsluga stron. Program sam dzieli caly tekst 		*
* w ASCII na strony i oblicza ich ilosc ( nie pozwala na ich prze-  *
* kroczenie). Jezeli chcesz uzywac tego kodu jako podstawy do Quast *
* maga to prosze Cie bardzo, ale napisz, ze to byl kiedys TV i ze   *
* ja to kodowalem, hahaha.											*
*********************************************************************
* Na dysku nie ma wszystkich tekstow. Jest natomiast caly kod.		*
*********************************************************************
* Podziekowania dla tych ktorzy nam bardzo ale to bardzo pomogli 	*
* przy wydawaniu TV.												*
*********************************************************************

	Oto oni:

								Bilbo
								Mig 29
								Nemesis
								Marchew
								Wrobel
								STeel
								Rademenes
								Graf
								Vat
								dr. Glue
								Lovespy
								Arcim
								Dick
								Jacek
								Mad guy
								R.K (ST NEWS)
								i every single guy, who
								has written to us.

**********************************************************************
* I to tyle. Fajnie bylo pisac dla Was.								 *
**********************************************************************

														STRych+
													cala redakcja

p.s. Kondolencje nadsylajcie pod naszym stalym adresem, ktory znacie.





	OPT O+,OW-
	SECTION TEXT
	bra X
	dc.b " Coded by STRych/TFTE"
	even

reset_program
	lea $ffff8240.w,a0
	rept 8
	clr.l (a0)+
	endr
   	move.b #2,$ffff820a
	move.l #$f8000,d0
	move.l d0,$44e.w
    lsr.l   #8,d0
    move.b  d0,$ffff8203
    lsr.l   #8,d0
    move.b  d0,$ffff8201
	move.l $44e.w,a1
	move.l #8000,d0
.lp
	clr.l (a1)+
	dbf d0,.lp
	lea stos(pc),a7

	lea reset_p(pc),a0
	move.l $44e.w,a1
	sub.l #34,a1
	bsr ICE_2.34

	move.l $44e,a0
	sub.l #32,a0
	lea $ffff8240.w,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
.kl	bra .kl
reset_p
	incbin dupa.pi1
	even
ICE_2.34
*	MOVEM.L	D0-D7/A0-A6,-(A7)
	BSR.S	ICE_00
	CMPI.L	#$49434521,D0
	BNE.S	NO_PACK
	BSR.S	ICE_00
	LEA	-8(A0,D0.L),A5
	BSR.S	ICE_00
*	MOVE.L	D0,(A7)
	MOVEA.L	A1,A4
	MOVEA.L	A1,A6
	ADDA.L	D0,A6
	MOVEA.L	A6,A3
	MOVE.B	-(A5),D7
	BSR.S	ICE_01
NO_PACK	*MOVEM.L	(A7)+,D0-D7/A0-A6
	RTS
ICE_00	MOVEQ	#3,D1
ICE_02	LSL.L	#8,D0
	MOVE.B	(A0)+,D0
	DBF	D1,ICE_02
	RTS
ICE_01	BSR.S	ICE_03
	BCC.S	ICE_04
	MOVEQ	#0,D1
	BSR.S	ICE_03
	BCC.S	ICE_05
	LEA	ICE_06(PC),A1
	MOVEQ	#4,D3
*	MOVE.W	#$400,$FFFF8240.W
*	MOVE.W	#$FFF,$FFFF8240.W
ICE_11	MOVE.L	-(A1),D0
	BSR.S	ICE_09
	SWAP	D0
	CMP.W	D0,D1
	DBNE	D3,ICE_11
	ADD.L	$14(A1),D1
ICE_05	MOVE.B	-(A5),-(A6)
	DBF	D1,ICE_05
ICE_04	CMPA.L	A4,A6
	BGT.S	ICE_12
	RTS
ICE_03	ADD.B	D7,D7
	BNE.S	ICE_20
	MOVE.B	-(A5),D7
	ADDX.B	D7,D7
ICE_20	RTS
ICE_09	MOVEQ	#0,D1
ICE_21	ADD.B	D7,D7
	BNE.S	ICE_19
	MOVE.B	-(A5),D7
	ADDX.B	D7,D7
ICE_19	ADDX.W	D1,D1
	DBF	D0,ICE_21
	RTS
ICE_12	LEA	ICE_07(PC),A1
	MOVEQ	#3,D2
ICE_13	BSR.S	ICE_03
	DBCC	D2,ICE_13
	MOVEQ	#0,D4
	MOVEQ	#0,D1
	MOVE.B	1(A1,D2.W),D0
	EXT.W	D0
	BMI.S	ICE_14
	BSR.S	ICE_09
ICE_14	MOVE.B	6(A1,D2.W),D4
	ADD.W	D1,D4
	BEQ.S	ICE_16
	LEA	ICE_08(PC),A1
	MOVEQ	#1,D2
ICE_15	BSR.S	ICE_03
	DBCC	D2,ICE_15
	MOVEQ	#0,D1
	MOVE.B	1(A1,D2.W),D0
	EXT.W	D0
	BSR.S	ICE_09
	ADD.W	D2,D2
	ADD.W	6(A1,D2.W),D1
	BPL.S	ICE_10
	SUB.W	D4,D1
	BRA.S	ICE_10
ICE_16	MOVEQ	#0,D1
	MOVEQ	#5,D0
	MOVEQ	#-1,D2
	BSR.S	ICE_03
	BCC.S	ICE_17
	MOVEQ	#8,D0
	MOVEQ	#$3F,D2
ICE_17	BSR.S	ICE_09
	ADD.W	D2,D1
ICE_10	LEA	2(A6,D4.W),A1
	ADDA.W	D1,A1
	MOVE.B	-(A1),-(A6)
ICE_18	MOVE.B	-(A1),-(A6)
	DBF	D4,ICE_18
	BRA	ICE_01
		DC.B $7f,$ff,$00,$0e,$00,$ff,$00,$07
		DC.B $00,$07,$00,$02,$00,$03,$00,$01
		DC.B $00,$03,$00,$01
ICE_06		DC.B $00,$00,$01,$0d,$00,$00,$00,$0e
		DC.B $00,$00,$00,$07,$00,$00,$00,$04
		DC.B $00,$00,$00,$01
ICE_07		DC.B $09,$01,$00,$ff,$ff,$08,$04,$02
		DC.B $01,$00
ICE_08		DC.B $0b,$04,$07,$00,$01,$1F,$FF,$FF
		DC.B $00,$1F,$33,$FC,$00,$01
		DC.W	$0015,$C80A
		DC.W	$6000,$FEEC
		DC.W	$41F9,$0016
;***************************************************************************
	even
	dcb.l 100
stos
X:
				move.w #1,automat
                movea.l 4(SP),A3
                move.l  $0C(A3),D0
                add.l   $14(A3),D0
                add.l   $1C(A3),D0
                add.l   #$0100,D0
                move.l  D0,-(SP)
                move.l  A3,-(SP)
                clr.w   -(SP)
                move.w  #$4A,-(SP)
                trap    #1
                adda.l  #12,SP


                pea     0.W
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
            
    move.l  D0,SAVE_STK

	lea nowe_k,a0
	LEA PANEL1,a1
	movem.l (a0),d0-d7
	movem.l d0-d7,(a1)
	moveq.l #0,d0
	moveq.l #0,d1
	moveq.l #0,d2
	moveq.l #0,d3
	moveq.l #0,d4
	moveq.l #0,d5
	moveq.l #0,d6
	moveq.l #0,d7

				move.b #$12,$fffc02
                lea     SAVE_FF8240,A0
                movea.l #$FFFF8240,A1
                movem.l (A1),D0-D7
                movem.l D0-D7,(A0)
                move.w  #$0117,_PLAN_2_KOL

                lea     FONTY1,A0
                adda.l  #602,A0
                move.l  A0,FONT
                move.l  A0,FONTASY

                move.l  #TXT_SCROLL,TXT_IS_HERE
                move.b  $0484.w,OLD484
                clr.b   $0484.w

				cmp.b   #$0f,$fffffc02.w
				bne  .nie_kontrol_panel

                jsr     SCIEMNIJ(PC)
                move.w #1,-(SP)
                move.l #$e8000,-(sp)
                move.l #$e8000,-(sp)
                move.w  #5,-(SP)
                trap    #14
                adda.l  #12,SP

                move.w  #$0000,$ffff8240.w
                move.w  #$0555,$ffff8242.w
                move.w  #$0333,$ffff8244.w
                move.w  #$0777,$ffff8246.w

				jsr kontrol_panel
.nie_kontrol_panel
				jsr     czytaj_mod
                jsr     SCIEMNIJ(PC)
 
                move.w #0,-(SP)
                move.l #$e8000,-(sp)
                move.l #$e8000,-(sp)
                move.w  #5,-(SP)
                trap    #14
                adda.l  #12,SP

				*jsr 	ugly_kid

                lea     FONTY1,A0
                adda.l  #602,A0
                move.l  A0,FONT
                move.l  A0,FONTASY

                move.l  #TXT_SCROLL,TXT_IS_HERE
                move.b  $0484.w,OLD484
                clr.b   $0484.w


                *move.l  $24.W,SAVE_24
                *move.l #RT,$24
                *move.l #RT,$8
                *move.l #RT,$c
                *move.l #RT,$10
                *move.l #RT,$14
                *move.l #0,$426
	move.l #$31415926,$426.w
	move.l #reset_program,$42a.w
                cmpi.b  #2,$FFFF8260
                beq     MODE_HIGH

                bsr     CLS

                pea     nowe_k
                move.w  #6,-(SP)
                trap    #14
                addq.l  #6,SP

					;0 = MSC mono
					;1 = MSC Stereo
					;2 = YM mono

	move    USP,A0          *SAVE USP
	move.l  A0,SAVE_USP
* lebels
                jsr     OVERSCAN

	lea     MODULE,A0   		** - modul off    
	MOVE.W	#2,REPLAY_ROT+$28		;Intial output device
	moveq.l   #-1,D0        
	JSR	REPLAY_ROT+$1C


* don't use d6-d7/a2-a6 from here

                bsr     SAVE_INTS
                bsr     INIT_INTS


                andi.b  #$DF,$FFFA09
                move.l  $0120.W,ZAP120
                lea     $FFFA06,A0
                lea     MFPZAP,A1
                move.w  #($21-7)/2,D0
LP1:
                move.w  (A0)+,(A1)+
                dbra    D0,LP1

                ori.b   #$01,$FFFA07
                move.b  #2,$FFFA21
                move.l  #TIMER,$0120
                move.b  #8,$FFFA1B
                ori.b   #$01,$FFFA13
                clr.w   WFNC
                bsr     GORA_PAS

                bsr     SCIEMNIJ_TXT
                bsr     CLS_PAGE_ART
                move.l  #FIRST1,TXT_POINT 
                bsr     TXT_NA_EKRAN
                bsr     ROZJASNIJ_TXT
				*jsr 	PAUSE
                bsr     SCIEMNIJ_TXT
                bsr     CLS_PAGE_ART
			
DEMO_LOOP:


************************
* tutaj program        *
************************
PRG1:
                bsr     SCIEMNIJ_TXT
                bsr     CLS_PAGE_ART
                bsr     TV_NAPIS


		move.l  #10*160,LICZNIK_FNT_Y
        move.l  #TEXT,TXT_POINT 
        bsr     TXT_NA_EKRAN
*		jsr menu_pi2

                bsr     ROZJASNIJ_TXT
    move.w  #$0127,_PLAN_2_KOL
    move.w  #$0777,_PLAN_3_KOL
                movea.l PAS_Y(PC),A1
                movea.l $044E.W,A0
                addq.l  #2,A0
                adda.l  A1,A0
                jsr     VSYNC
                jsr     RYS_PAS

*****************************
* Kontrola wybranego artyk. *
*****************************

PROGRAM:
                bsr     WAIT_KEY
				cmp.b #2,d0
				bne E00

				lea wstep,a0
				bsr ustal_strony
				move.l  #Tabela_stron,D5
				bra   JEST
E00:		
                cmp.b   #8*2,D0           ;schemat dla art
                bne.s   E1
				lea dlaczego,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E1:
                cmp.b   #6,D0           ;schemat dla art 6/2=3
                bne.s   E2
				lea efik_15,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST

E2:
                cmp.b   #5*2,D0           ;schemat dla art 6/2=3
                bne.s   E3
				lea ACC_real,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E3:
                cmp.b   #9*2,D0           ;schemat dla art 6/2=3
                bne.s   E4
				lea scena,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E4
                cmp.b   #11*2,D0           ;schemat dla art 6/2=3
                bne.s   E5
				lea modem,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E5
                cmp.b   #15*2,D0           ;schemat dla art 6/2=3
                bne.s   E6
				lea miklesz,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E6
                cmp.b   #14*2,D0           ;schemat dla art 6/2=3
                bne.s   E7
				lea SIa,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E7
                cmp.b   #7*2,D0           ;schemat dla art 6/2=3
                bne.s   E8
				lea opw2,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E8
                cmp.b   #10*2,D0           ;schemat dla art 6/2=3
                bne.s   E9
				lea marchew,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E9
                cmp.b   #19*2,D0           ;schemat dla art 6/2=3
                bne.s   E10
				lea Bajtek,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E10
                cmp.b   #6*2,D0           ;schemat dla art 6/2=3
                bne.s   E11
				lea opw1,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E11
                cmp.b   #17*2,D0           ;schemat dla art 6/2=3
                bne.s   E12
				lea army,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E12
                cmp.b   #16*2,D0           ;schemat dla art 6/2=3
                bne.s   E13
				lea paskud,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E13
                cmp.b   #2*2,D0           ;schemat dla art 6/2=3
                bne.s   E14
				lea news,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E14
                cmp.b   #12*2,D0           ;schemat dla art 6/2=3
                bne.s   E15
				lea warczak,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E15
                cmp.b   #4*2,D0           ;schemat dla art 6/2=3
                bne.s   E16
				lea demo,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E16
                cmp.b   #20*2,D0           ;schemat dla art 6/2=3
                bne.s   E17v1
				lea lista_acc,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E17v1
                cmp.b   #21*2,D0           ;schemat dla art 6/2=3
                bne.s   e17v2
				lea jokes,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
e17v2:
                cmp.b   #18*2,D0           ;schemat dla art 6/2=3
                bne.s   E17
				lea charty,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5
                bra   JEST
E17
                cmp.b   #13*2,D0           ; ostatnia pozycja
                bne.s   CHECK_POS
				lea falc,a0
				bsr ustal_strony
                move.l  #Tabela_stron,D5

JEST:                                   ; wyswietlanie stron
                move.w  #$0707,_PLAN_3_KOL	; bylo odwrotnie
                move.w  #$0707,_PLAN_2_KOL
                bsr     STRONA
                bra   PRG1

CHECK_POS:
                cmpi.w  #185,$FFFC02
                beq     FINISH
*		        bra PROGRAM

FINISH:
OUT:
                lea     $FFFA06,A0
                lea     MFPZAP,A1
                move.w  #($21-7)/2,D0
.LOOP2:
                move.w  (A1)+,(A0)+
                dbra    D0,.LOOP2
                move.l  ZAP120,$0120
                ori.b   #$20,$FFFA09
                bsr     RET_INTS
* now you're back to normal
                move.b  OLD484(PC),$0484.w
                move.l  SAVE_24,$24.w
                move.w  #$0777,$FF8240
                move.w  #$00,$FF8242

	movea.l SAVE_USP(PC),A0
	move    A0,USP
                bsr     CLS

                clr.w   -(SP)
                pea     -1
                pea     -1
                move.w  #5,-(SP)
                trap    #14
                adda.l  #12,SP

                move.w  #$0777,$FF8240
                move.w  #$00,$FF8242
                lea     SAVE_FF8240,A0
                movea.l #$FFFF8240,A1
                movem.l (A0),D0-D7
                movem.l D0-D7,(A1)
				move.b #$08,$fffc02

MODE_HIGH:
                move.l  SAVE_STK(PC),-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                clr.w   (SP)            *EXIT
                trap    #1

*******************
* subroutines     *
*******************
diffr_sound:
	MOVE.B	$FFFFFC02.W,D0
	CMPI.B	#$3B,D0				;F1 = MSC mono
	BNE.S	.notF1
	CLR.W	REPLAY_ROT+$28

	lea 	PANEL+34+50*160,a0
	move.l 	$44e,a1
	add.l 	#160*201,a1
	bsr AE

.notF1	CMPI.B	#$3C,D0			;F2 = MSC Stereo
	BNE.S	.notF2
	MOVE.W	#1,REPLAY_ROT+$28
	lea 	PANEL+34,a0
	move.l 	$44e,a1
	add.l 	#160*201,a1
	bsr AE

.notF2	CMPI.B	#$3D,D0			;F3 = YM mono
	BNE.S	.notF3
	MOVE.W	#2,REPLAY_ROT+$28
	lea 	PANEL+34,a0
	move.l 	$44e,a1
	add.l 	#160*201,a1
	bsr AE

.notF3	
	CMPI.B	#$40,D0			;F3 = YM mono
	BNE.S	.notF4
	move.l A0,SAVE_A0
	move.l A1,SAVE_A1
	jsr VSYNC
	lea nowe_k,a0
	lea PANEL1,a1
	moveq.l #16,d0
.tr
	move.w (a0)+,(a1)+	
	dbf d0,.tr
	lea nowe_k+2*4,a0
	lea $ffff8248.w,a1
	moveq.l #11,d0
.tr1
	move.w (a0)+,(a1)+	
	dbf d0,.tr1
	move.l SAVE_A0,a0
	move.l SAVE_A1,a1
	
	bra .notF5

.notF4
	CMPI.B	#$41,D0		
	BNE.S	.notF5
	move.l A0,SAVE_A0
	move.l A1,SAVE_A1
	JSR VSYNC
	lea PANEL+2,a0
	lea PANEL1,a1
	moveq.l #16,d0
.tr2
	move.w (a0)+,(a1)+	
	dbf d0,.tr2
	lea PANEL+2+2*4,a0
	lea $ffff8248.w,a1
	moveq.l #11,d0
.tr3
	move.w (a0)+,(a1)+	
	dbf d0,.tr3

	move.l SAVE_A0,a0
	move.l SAVE_A1,a1
	
.notF5
	
	rts


TXT_NA_EKRAN:                           ; _txt bez sp
                movem.l D0-D5/A0-A1,SCHOWAJ1
                clr.l   D1
                movea.l #0,A0
                movea.l #0,A1
NA_EKRAN:
                movea.l TXT_POINT(PC),A0
                clr.l   D0
                move.b  (A0),D0
                cmp.b   #$FF,D0
                beq     ZAX
                move.b  (A0)+,D0
                cmp.b   #$0D,D0
                bne.s   DALEJ
                move.b  (A0)+,D0
                cmp.b   #$0A,D0
                beq   RETURN

DALEJ:
                bsr     CZYTAJ
                movea.l $044E.W,A1
                adda.l  LICZNIK_FNT_X,A1
                adda.l  LICZNIK_FNT_Y,A1
				cmp.w #1,kolumna_2
			    bne lÑ11
				add.l #4*20,a1			    
lÑ11:
                bsr     PISZ
                movea.l TXT_POINT(PC),A0
                clr.l   D0
                move.b  (A0),D0
                cmp.b   #$FF,D0
                beq     ZAX
                move.b  (A0)+,D0
                cmp.b   #$0D,D0
                bne.s   DALEJ1
                move.b  (A0)+,D0
                cmp.b   #$0A,D0
                beq.s   RETURN1
DALEJ1:
                bsr     CZYTAJ

                movea.l $044E.W,A1
                adda.l  LICZNIK_FNT_X,A1
                adda.l  LICZNIK_FNT_Y,A1
                addq.l  #1,A1
				cmp.w #1,kolumna_2
			    bne lÑ1
				add.l #4*20,a1			    
lÑ1:
                bsr     PISZ
                addi.l  #4,LICZNIK_FNT_X ; dla sredniej roz
                bra     NA_EKRAN

RETURN:
                move.b  (A0),D0
                cmp.b   #$FF,D0
                beq.s   ZAX
                clr.l   D0
                clr.l   LICZNIK_FNT_X
                addq.l  #2,TXT_POINT
                addi.l  #8*160,LICZNIK_FNT_Y
				cmp.l   #23*160*8,LICZNIK_FNT_Y
				beq ZAX
                bra     NA_EKRAN

RETURN1:
                move.b  (A0),D0
                cmp.b   #$FF,D0
                beq.s   ZAX
                clr.l   D0
                clr.l   LICZNIK_FNT_X
                addq.l  #2,TXT_POINT
                addi.l  #8*160,LICZNIK_FNT_Y
				cmp.l   #23*160*8,LICZNIK_FNT_Y
				beq ZAX
                bra     NA_EKRAN

ZAX:
                clr.l   LICZNIK_FNT_X
                clr.l   LICZNIK_FNT_Y
                clr.l   D0
                movem.l SCHOWAJ1,D0-D5/A0-A1
                rts
PISZ:
				cmp.l #1,maska
				beq maskuj
				cmp.w 	#1,underline
				beq 	pisz_z_linia
				cmp.w 	#2,underline
				bne pisz_scroll
				move.w #1,underline
pisz_scroll
                move.b  (A0),(A1)
                move.b  $0100(A0),160(A1)
                move.b  $0200(A0),2*160(A1)
                move.b  $0300(A0),3*160(A1)
                move.b  $0400(A0),4*160(A1)
                move.b  $0500(A0),5*160(A1)
                move.b  $0600(A0),6*160(A1)
                move.b  $0700(A0),7*160(A1)
                rts
pisz_z_linia:
                move.b  (A0),(A1)
                move.b  $0100(A0),160(A1)
                move.b  $0200(A0),2*160(A1)
                move.b  $0300(A0),3*160(A1)
                move.b  $0400(A0),4*160(A1)
                move.b  $0500(A0),5*160(A1)
                move.b  $0600(A0),6*160(A1)
                move.b  #$ff,7*160(A1)
                rts
maskuj:
                move.b  (A0),(A1)
				eor.b #$ff,(a1)
                move.b  $0100(A0),160(A1)
				eor.b #$ff,160(a1)
                move.b  $0200(A0),2*160(A1)
				eor.b #$ff,2*160(a1)
                move.b  $0300(A0),3*160(A1)
				eor.b #$ff,3*160(a1)
                move.b  $0400(A0),4*160(A1)
				eor.b #$ff,4*160(a1)
                move.b  $0500(A0),5*160(A1)
				eor.b #$ff,5*160(a1)
                move.b  $0600(A0),6*160(A1)
				eor.b #$ff,6*160(a1)
                move.b  $0700(A0),7*160(A1)
				eor.b #$ff,7*160(a1)
                rts


CZYTAJ:
                andi.l  #$FF,D0
                cmp.b   #$FF,D0
                beq   ZAX
                cmp.b   #'î',D0
                bne.s   lî4
                move.l  FONT,SAVE_FNT
				move.l  #fonty_poch+602,FONT
				move.l #$20,d0
				bra lî5
lî4:
                cmp.b   #'Ñ',D0
                bne.s   lî5
				move.l  SAVE_FNT,FONT
				move.l #$20,d0
lî5:
                cmp.b   #'Å',D0
                bne.s   lî6
				move.w #2,underline
				move.l #$20,d0
				bra lî7
lî6:
                cmp.b   #'@',D0
                bne.s   lî7
				clr.w 	underline
				move.l #$20,d0
lî7:
                cmp.b   #'[',D0
                bne.s   lî8
				move.l #18*160,LICZNIK_FNT_Y
				clr.l  LICZNIK_FNT_X			    
				move.w #1,kolumna_2
				move.l #$20,d0
lî8:
                cmp.b   #']',D0
                bne.s   lî9
				clr.l  LICZNIK_FNT_X			    
				clr.w kolumna_2
				move.l #$20,d0
lî9:
                addq.l  #1,TXT_POINT
                movea.l FONT(PC),A0
                adda.l  D0,A0
                rts

********************
* menu * klawisze  *
********************

WAIT_KEY:
boys:
			    bsr VSYNC
KEY_LOOP11:

	jsr minus_key_out
	jsr plus_key_out

KEY_LOOP:
	cmpi.b  #$50,$FFFC02
 	beq     MINUS01
	cmpi.b  #$48,$FFFC02
	beq     PLUS01
	cmpi.b  #$4a,$FFFC02
	beq     PLUS00
	cmpi.b  #$4e,$FFFC02
	beq     MINUS00
*	cmp.b   #$0f,$fffc02
*	bne   ROWNAJ
*	jsr kontrol_panel
				
ROWNAJ:
				cmp.b   #$42,$fffffc02
				bne .lo
				cmp.w #1,automat
				bne .j
				clr.w automat
				bra .lo
.j
				move.w #1,automat

.lo				jsr diffr_sound	
                cmpi.b  #$3e,$FFFC02
                bne.s   SS1
                move.l  #FONTY1+602,FONT
				move.l #10*160,LICZNIK_FNT_Y
                move.l  #TEXT,TXT_POINT * TU PODAJ TEXT
                bsr     TXT_NA_EKRAN
SS1:
                cmpi.b  #$3f,$FFFC02
                bne.s   SS2
                move.l  #FONTY,FONT
                addi.l  #602,FONT
				move.l #10*160,LICZNIK_FNT_Y
                move.l  #TEXT,TXT_POINT 
                bsr     TXT_NA_EKRAN
SS2:
                cmpi.b  #$14,$FFFC02
                bne.s   SS3
				moveq.l #$a0,d0
				bra sta
SS3:
                cmpi.b  #$39,$FFFC02
                bne   KEY_LOOP11
                clr.l   D0
                move.w  MENU_POZ(PC),D0
sta
                clr.l   D1
                rts

GORA_PAS:
                move.l  A0,SAVE_A0
                move.l  D1,SAVE_D0
                movea.l $044E.W,A0
                addq.l  #2,A0
                move.l  #80*5-1,D1
P5:
                move.w  #$FFFF,(A0)
                addq.l  #4,A0
                dbra    D1,P5
                movea.l SAVE_A0(PC),A0
                move.l  SAVE_D0(PC),D1
                rts

		
PLUS01:
				move.l #2*160,tryb1
				move.l #4,tryb
				bra PLUS
PLUS00:
				move.l #160,tryb1
				move.l #8,tryb
PLUS:
	jsr minus_key_in
				clr.b   $fffc02
                cmpi.l  #10*160,PAS_Y
                beq     boys
                bsr     POZ_PASA_MINUS
                subq.w  #2,MENU_POZ
                bra     ROWNAJ

MINUS01:
				move.l #2*160,tryb1
				move.l #4,tryb
				BRA MINUS
MINUS00:
				move.l #160,tryb1
				move.l #8,tryb
MINUS:
	jsr plus_key_in
				clr.b   $fffc02
                cmpi.l  #21*8*160+2*160,PAS_Y
                beq     boys
                bsr     POZ_PASA
                addq.w  #2,MENU_POZ
                bra     ROWNAJ

POZ_PASA:
                movea.l PAS_Y(PC),A1
                addi.l  #8*160,PAS_Y
                movea.l $044E.W,A0
                addq.l  #2,A0
                adda.l  A1,A0
                move.l  A0,D5
                move.l  tryb,D1					;8
RUCHAJ:
                bsr.s   RYS_PAS
                add.l   tryb1,D5				;1
                movea.l D5,A0
                dbra    D1,RUCHAJ
                rts
POZ_PASA_MINUS:
                movea.l PAS_Y(PC),A1
                subi.l  #8*160,PAS_Y			
                movea.l $044E.W,A0
                addq.l  #2,A0
                adda.l  A1,A0
                move.l  A0,D5
                move.l  tryb,D1				;8
RUCHAJ1:
                bsr.s   RYS_PAS
                sub.l   tryb1,D5				;1
                movea.l D5,A0
                dbra    D1,RUCHAJ1
                rts

RYS_PAS:                                ;a0 pozycja
                bsr     VSYNC
                moveq.l   #7,D2
S1:             bsr     LINE_CLR
                adda.l  #160,A0
                dbra    D2,S1
                moveq.l   #7,D0
                move.w   #$ffff,D2
Q1:
                move.w  d2,(A0)
                move.w  d2,1*4(A0)
                move.w  d2,2*4(A0)
                move.w  d2,3*4(A0)
                move.w  d2,4*4(A0)
                move.w  d2,5*4(A0)
                move.w  d2,6*4(A0)
                move.w  d2,7*4(A0)
                move.w  d2,8*4(A0)
                move.w  d2,9*4(A0)
                move.w  d2,10*4(A0)
                move.w  d2,11*4(A0)
                move.w  d2,12*4(A0)
                move.w  d2,13*4(A0)
                move.w  d2,14*4(A0)
                move.w  d2,15*4(A0)
                move.w  d2,16*4(A0)
                move.w  d2,17*4(A0)
                move.w  d2,18*4(A0)
                move.w  d2,19*4(A0)
                move.w  d2,20*4(A0)
                move.w  d2,21*4(A0)
                move.w  d2,22*4(A0)
                move.w  d2,23*4(A0)
                move.w  d2,24*4(A0)
                move.w  d2,25*4(A0)
                move.w  d2,26*4(A0)
                move.w  d2,27*4(A0)
                move.w  d2,28*4(A0)
                move.w  d2,29*4(A0)
                move.w  d2,30*4(A0)
                move.w  d2,31*4(A0)
                move.w  d2,32*4(A0)
                move.w  d2,33*4(A0)
                move.w  d2,34*4(A0)
                move.w  d2,35*4(A0)
                move.w  d2,36*4(A0)
                move.w  d2,37*4(A0)
                move.w  d2,38*4(A0)
                move.w  d2,39*4(A0)
                adda.l  #160,A0
                dbra    D0,Q1

                moveq.l   #7,D2
S2:             bsr.s   LINE_CLR
                adda.l  #160,A0
                dbra    D2,S2
                rts

LINE_CLR:
                clr.w   (A0)
                clr.w   1*4(A0)
                clr.w   2*4(A0)
                clr.w   3*4(A0)
                clr.w   4*4(A0)
                clr.w   5*4(A0)
                clr.w   6*4(A0)
                clr.w   7*4(A0)
                clr.w   8*4(A0)
                clr.w   9*4(A0)
                clr.w   10*4(A0)
                clr.w   11*4(A0)
                clr.w   12*4(A0)
                clr.w   13*4(A0)
                clr.w   14*4(A0)
                clr.w   15*4(A0)
                clr.w   16*4(A0)
                clr.w   17*4(A0)
                clr.w   18*4(A0)
                clr.w   19*4(A0)
                clr.w   20*4(A0)
                clr.w   21*4(A0)
                clr.w   22*4(A0)
                clr.w   23*4(A0)
                clr.w   24*4(A0)
                clr.w   25*4(A0)
                clr.w   26*4(A0)
                clr.w   27*4(A0)
                clr.w   28*4(A0)
                clr.w   29*4(A0)
                clr.w   30*4(A0)
                clr.w   31*4(A0)
                clr.w   32*4(A0)
                clr.w   33*4(A0)
                clr.w   34*4(A0)
                clr.w   35*4(A0)
                clr.w   36*4(A0)
                clr.w   37*4(A0)
                clr.w   38*4(A0)
                clr.w   39*4(A0)
                rts
VSYNC:
                cmpi.w  #1,WFNC
                bne.s   VSYNC
                clr.w   WFNC
                rts
CLS:
                move.l  A0,SAVE_A0
                move.l  D0,SAVE_D0
                movea.l $044E.W,A0
                move.l  #8080,D0
.BIT:
                clr.l   (A0)+
                dbra    D0,.BIT
                movea.l SAVE_A0(PC),A0
                move.l  SAVE_D0(PC),D0
                rts

STRONA:                                 ; w d5 adr_artykulu
                movem.l D0-D5/A0-A1,SCHOWAJ
                clr.l   D3
                movea.l D5,A0
                movea.l (A0),A1
				move.l  A1,TXT_POINT
                bsr     CLR_PAS
                bsr     SCIEMNIJ_TXT
                bsr     CLS_PAGE
				move.l  #8*160*2,LICZNIK_FNT_Y
                bsr     VSYNC
                bsr     TXT_NA_EKRAN
				jsr obraz_spr
                movea.l $044E.W,A0
                adda.l  #189*160,A0
                move.l  #40*11,D0
WALK:
                clr.l  (A0)+
                dbra    D0,WALK
                move.l  FONT,SAVE_FNT
                move.l  #FONTY+602,FONT

                lea     NAP_STRONA,A0
                move.l  A0,TXT_POINT
                move.l  #160*192,LICZNIK_FNT_Y
                clr.l   LICZNIK_FNT_X
                bsr     VSYNC
                bsr     TXT_NA_EKRAN

                lea     NAP_STRONA,A0
                move.l  A0,TXT_POINT
                move.l  #160*192,LICZNIK_FNT_Y
                move.l  #2,LICZNIK_FNT_X
                bsr     VSYNC
                bsr     TXT_NA_EKRAN
                
                lea     NR_STRONY,A0
                move.l  A0,TXT_POINT
                move.l  #160*192,LICZNIK_FNT_Y
                move.l  #4*5,LICZNIK_FNT_X
                bsr     TXT_NA_EKRAN    

                lea     adres_k_stron,A0
                move.l  (A0),TXT_POINT
                move.l  #160*192,LICZNIK_FNT_Y
                move.l  #4*10,LICZNIK_FNT_X
                bsr     TXT_NA_EKRAN    

                lea     adres_k_stron,A0
                move.l  (A0),TXT_POINT
                move.l  #160*192,LICZNIK_FNT_Y
                move.l  #4*10+2,LICZNIK_FNT_X
                bsr     TXT_NA_EKRAN    
                move.l  SAVE_FNT,FONT

                movea.l $044E.W,A0
                adda.l  #190*160,A0
                move.w  #$FFFF,(A0)
                move.w  #$FFFF,1*4(A0)
                move.w  #$FFFF,2*4(A0)
                move.w  #$FFFF,3*4(A0)
                move.w  #$FFFF,4*4(A0)
                move.w  #$FFFF,5*4(A0)
                move.w  #$FFFF,6*4(A0)
                move.w  #$FFFF,7*4(A0)
                move.w  #$FFFF,8*4(A0)
                move.w  #$FFFF,9*4(A0)
                move.w  #$FFFF,10*4(A0)
                move.w  #$FFFF,11*4(A0)
                move.w  #$FFFF,12*4(A0)
                move.w  #$FFFF,13*4(A0)
                move.w  #$FFFF,14*4(A0)
                move.w  #$FFFF,15*4(A0)
                move.w  #$FFFF,16*4(A0)
                move.w  #$FFFF,17*4(A0)
                move.w  #$FFFF,18*4(A0)
                move.w  #$FFFF,19*4(A0)
                move.w  #$FFFF,20*4(A0)
                move.w  #$FFFF,21*4(A0)
                move.w  #$FFFF,22*4(A0)
                move.w  #$FFFF,23*4(A0)
                move.w  #$FFFF,24*4(A0)
                move.w  #$FFFF,25*4(A0)
                move.w  #$FFFF,26*4(A0)
                move.w  #$FFFF,27*4(A0)
                move.w  #$FFFF,28*4(A0)
                move.w  #$FFFF,29*4(A0)
                move.w  #$FFFF,30*4(A0)
                move.w  #$FFFF,31*4(A0)
                move.w  #$FFFF,32*4(A0)
                move.w  #$FFFF,33*4(A0)
                move.w  #$FFFF,34*4(A0)
                move.w  #$FFFF,35*4(A0)
                move.w  #$FFFF,36*4(A0)
                move.w  #$FFFF,37*4(A0)
                move.w  #$FFFF,38*4(A0)
                move.w  #$FFFF,39*4(A0)
				movea.l $044E.W,A0
                adda.l  #190*160+2,A0
                move.w  #$FFFF,(A0)
                move.w  #$FFFF,1*4(A0)
                move.w  #$FFFF,2*4(A0)
                move.w  #$FFFF,3*4(A0)
                move.w  #$FFFF,4*4(A0)
                move.w  #$FFFF,5*4(A0)
                move.w  #$FFFF,6*4(A0)
                move.w  #$FFFF,7*4(A0)
                move.w  #$FFFF,8*4(A0)
                move.w  #$FFFF,9*4(A0)
                move.w  #$FFFF,10*4(A0)
                move.w  #$FFFF,11*4(A0)
                move.w  #$FFFF,12*4(A0)
                move.w  #$FFFF,13*4(A0)
                move.w  #$FFFF,14*4(A0)
                move.w  #$FFFF,15*4(A0)
                move.w  #$FFFF,16*4(A0)
                move.w  #$FFFF,17*4(A0)
                move.w  #$FFFF,18*4(A0)
                move.w  #$FFFF,19*4(A0)
                move.w  #$FFFF,20*4(A0)
                move.w  #$FFFF,21*4(A0)
                move.w  #$FFFF,22*4(A0)
                move.w  #$FFFF,23*4(A0)
                move.w  #$FFFF,24*4(A0)
                move.w  #$FFFF,25*4(A0)
                move.w  #$FFFF,26*4(A0)
                move.w  #$FFFF,27*4(A0)
                move.w  #$FFFF,28*4(A0)
                move.w  #$FFFF,29*4(A0)
                move.w  #$FFFF,30*4(A0)
                move.w  #$FFFF,31*4(A0)
                move.w  #$FFFF,32*4(A0)
                move.w  #$FFFF,33*4(A0)
                move.w  #$FFFF,34*4(A0)
                move.w  #$FFFF,35*4(A0)
                move.w  #$FFFF,36*4(A0)
                move.w  #$FFFF,37*4(A0)
                move.w  #$FFFF,38*4(A0)
                move.w  #$FFFF,39*4(A0)

NUMER_STRONY:
                bsr     ROZJASNIJ_TXT

STR_LOOP:
                cmpi.b  #$4E,$FFFffC02
                beq   _PLUS
                cmpi.b  #$4A,$FFFffC02
                beq   _MINUS
                cmpi.b  #$50,$FFFffC02
                beq   _PLUS
                cmpi.b  #$48,$FFFffC02
                beq   _MINUS
                cmpi.b  #$36,$FFFffC02
                beq   _plus_10
                cmpi.b  #$2a,$FFFffC02
                beq   _min_10
				jsr diffr_sound

COFNIJ:
                cmpi.b  #$01,$FFFffC02
                bne   STR_LOOP
ALL_DONE:
				clr.w  picy_jest
                movea.l $044E.W,A0
                adda.l  #190*160,A0
                move.l  #40*10,D0
STACH_TO_CHUJ:
                clr.l   (A0)+
                dbra    D0,STACH_TO_CHUJ

                movem.l SCHOWAJ,D0-D5/A0-A1
                rts                     ; koniec

_MINUS:
	bsr ruch_key_minus
	subq.l  #4,D3
	bra   _TU

ruch_key_minus:
	cmp.w #1,automat
	bne .kon
	jsr 	minus_key_in
.wik
	addq.w #1,key_count
	cmp.w #$20ff,key_count
	beq .out
	btst.b  #$7,$FFFC02
	beq.s   .wik
.out	clr.w key_count	
*	jsr 	minus_key_out
.kon
	rts

_min_10:		
	bsr ruch_key_minus
	sub.l  #4*5,D3
	bra.s   _TU
_plus_10			
	bsr 	ruch_key_plus
	add.l  #4*5,D3
	bra.s   _TU

ruch_key_plus:
	cmp.w #1,automat
	bne .kon
	jsr 	plus_key_in
.wik
	addq.w #1,key_count
	cmp.w #$20ff,key_count
	beq .out
	btst.b  #$7,$FFffFC02.w
	beq.s   .wik
.out	clr.w key_count	
*	jsr 	plus_key_out
.kon
	rts

_PLUS:
	bsr ruch_key_plus
	addq.l  #4,D3

_TU:
                movea.l D5,A0
                movea.l 0(A0,D3.w),A1
                cmpa.l  #0,A1
                beq.s   .koniec
				bra _TU1
.koniec
				move.l pages,d4 
				addq.l #4,d4
				cmp.l  d3,d4
				bne .skok
				move.l pages,d3				
				bra.s .skok1
				nop
.skok
				cmp.l #-4,d3
				beq .skok4
				tst.l  d3
				bmi .skok3
				cmp.l  d4,d3
				bgt .skok2
.skok4          clr.l   D3
.skok1          bra     COFNIJ
.skok2			sub.l #4*5,d3
				bra .skok1
.skok3
				add.l #4*5,d3
				bra .skok1

_TU1:
                move.l  A1,TXT_POINT
                bsr     SCIEMNIJ_TXT
                jsr minus_key_out
				jsr plus_key_out
				bsr     CLS_PAGE_ART
				move.l  #8*160*2,LICZNIK_FNT_Y
*               bsr     VSYNC
                bsr     TXT_NA_EKRAN    ; tu musi byc zap. d5

                move.l  FONT,SAVE_FNT
                move.l  #FONTY+602,FONT
                lea     NR_STRONY,A0
                adda.l  D3,A0
                move.l  A0,TXT_POINT
                move.l  #160*192,LICZNIK_FNT_Y
                move.l  #4*5,LICZNIK_FNT_X
                bsr     TXT_NA_EKRAN    ; tu musi byc zap. d5

 *               lea     NR_STRONY,A0
 *               adda.l  D3,A0
 *               move.l  A0,TXT_POINT
 *               move.l  #160*192,LICZNIK_FNT_Y
 *               move.l  #4*5+2,LICZNIK_FNT_X
 *               bsr     TXT_NA_EKRAN    ; tu musi byc zap. d5
                move.l  SAVE_FNT,FONT

				jsr obraz_spr
 				bsr     ROZJASNIJ_TXT
			jsr minus_key_out
			jsr plus_key_out
                bra     COFNIJ

CLS_PAGE:
                move.l  A1,SAVE_A0
                move.l  D0,SAVE_D0
                movea.l $044E.W,A1
                adda.l  #160*12,A1      ;poz_okna_text
                move.l  #200-22,D0
P2:
                clr.w   (A1)
                clr.w   1*4(A1)
                clr.w   2*4(A1)
                clr.w   3*4(A1)
                clr.w   4*4(A1)
                clr.w   5*4(A1)
                clr.w   6*4(A1)
                clr.w   7*4(A1)
                clr.w   8*4(A1)
                clr.w   9*4(A1)
                clr.w   10*4(A1)
                clr.w   11*4(A1)
                clr.w   12*4(A1)
                clr.w   13*4(A1)
                clr.w   14*4(A1)
                clr.w   15*4(A1)
                clr.w   16*4(A1)
                clr.w   17*4(A1)
                clr.w   18*4(A1)
                clr.w   19*4(A1)
                clr.w   20*4(A1)
                clr.w   21*4(A1)
                clr.w   22*4(A1)
                clr.w   23*4(A1)
                clr.w   24*4(A1)
                clr.w   25*4(A1)
                clr.w   26*4(A1)
                clr.w   27*4(A1)
                clr.w   28*4(A1)
                clr.w   29*4(A1)
                clr.w   30*4(A1)
                clr.w   31*4(A1)
                clr.w   32*4(A1)
                clr.w   33*4(A1)
                clr.w   34*4(A1)
                clr.w   35*4(A1)
                clr.w   36*4(A1)
                clr.w   37*4(A1)
                clr.w   38*4(A1)
                clr.w   39*4(A1)
                adda.l  #160,A1
                dbra    D0,P2

                bsr     VSYNC
                movea.l $044E.W,A1
                addq.l  #2,A1
                adda.l  #160*12,A1      ;poz_okna_text
                move.l  #200-12,D0
P4:
                clr.w   (A1)
                clr.w   1*4(A1)
                clr.w   2*4(A1)
                clr.w   3*4(A1)
                clr.w   4*4(A1)
                clr.w   5*4(A1)
                clr.w   6*4(A1)
                clr.w   7*4(A1)
                clr.w   8*4(A1)
                clr.w   9*4(A1)
                clr.w   10*4(A1)
                clr.w   11*4(A1)
                clr.w   12*4(A1)
                clr.w   13*4(A1)
                clr.w   14*4(A1)
                clr.w   15*4(A1)
                clr.w   16*4(A1)
                clr.w   17*4(A1)
                clr.w   18*4(A1)
                clr.w   19*4(A1)
                clr.w   20*4(A1)
                clr.w   21*4(A1)
                clr.w   22*4(A1)
                clr.w   23*4(A1)
                clr.w   24*4(A1)
                clr.w   25*4(A1)
                clr.w   26*4(A1)
                clr.w   27*4(A1)
                clr.w   28*4(A1)
                clr.w   29*4(A1)
                clr.w   30*4(A1)
                clr.w   31*4(A1)
                clr.w   32*4(A1)
                clr.w   33*4(A1)
                clr.w   34*4(A1)
                clr.w   35*4(A1)
                clr.w   36*4(A1)
                clr.w   37*4(A1)
                clr.w   38*4(A1)
                clr.w   39*4(A1)
                adda.l  #160,A1
                dbra    D0,P4
                movea.l SAVE_A0(PC),A1
                move.l  SAVE_D0(PC),D0
                rts
TV_NAPIS:
                move.l  FONT(PC),SAVE_FNT
                move.l  FONTASY(PC),FONT
                move.l  #160*192,LICZNIK_FNT_Y
                clr.l   LICZNIK_FNT_X
                move.l  #TV_TXT,TXT_POINT
                bsr     TXT_NA_EKRAN
                move.l  SAVE_FNT(PC),FONT
                movea.l $044E.W,A0
                adda.l  #190*160,A0
                moveq.l   #39,D0
COLINS:
                move.w  #$FFFF,(A0)
                addq.l  #4,A0
                dbra    D0,COLINS
                rts

SAVE_INTS:
	move.b  $FFFFFA07.w,MFPA07
	move.b  $FFFFFA09.w,MFPA09
	move.b  $FFFFFA13.w,MFPA13
	move.b  $FFFFFA15.w,MFPA15
	move.b  $FFFFFA19.w,MFPA19
	move.b  $FFFFFA1F.w,MFPA1F
	move.l  $0134.W,OLD134
    move.l  $70.w,OLDVBL
    rts

INIT_INTS:
	MOVE.W	#$2700,SR		;Set MFP
	clr.b   $FFFFFA09.w
	clr.b   $FFFFFA15.w
	move.w  MODULE+$90,D0
	lea     MFP_FREQS(PC),A0
	move.b  0(A0,D0.w),$FFFFFA1F.w
	move.b  #2,$FFFFFA19.w
	move.b  #32,$FFFFFA07.w
	move.b  #32,$FFFFFA13.w
	bclr    #3,$FFFFFA17.w
	move.l  #REPLAY_ROT+$868e,$0134.W
    move.l  #VBI,$70.w
	MOVE	#$2300,SR
    rts

MFP_FREQS:
	DC.B 24
	DC.B 26
RET_INTS:
	MOVE.W	#$2700,SR			;restore MFP
	move.b  MFPA07(PC),$FFFFFA07.w 
	move.b  MFPA09(PC),$FFFFFA09.w
	move.b  MFPA13(PC),$FFFFFA13.w
	move.b  MFPA15(PC),$FFFFFA15.w
	move.b  MFPA19(PC),$FFFFFA19.w
	move.b  MFPA1F(PC),$FFFFFA1F.w
	move.l  OLD134(PC),$0134.W
    move.l  OLDVBL(PC),$70.w
	MOVE.W	#$2300,SR			;restore MFP
    rts

CLS_PAGE_ART:
                move.l  A1,SAVE_A1
                move.l  D0,SAVE_D0
                movea.l $044E.W,A1
                adda.l  #160*12,A1      ;poz_okna_text
                move.l  #200-23,D0
P9:
                clr.w   (A1)
                clr.w   1*4(A1)
                clr.w   2*4(A1)
                clr.w   3*4(A1)
                clr.w   4*4(A1)
                clr.w   5*4(A1)
                clr.w   6*4(A1)
                clr.w   7*4(A1)
                clr.w   8*4(A1)
                clr.w   9*4(A1)
                clr.w   10*4(A1)
                clr.w   11*4(A1)
                clr.w   12*4(A1)
                clr.w   13*4(A1)
                clr.w   14*4(A1)
                clr.w   15*4(A1)
                clr.w   16*4(A1)
                clr.w   17*4(A1)
                clr.w   18*4(A1)
                clr.w   19*4(A1)
                clr.w   20*4(A1)
                clr.w   21*4(A1)
                clr.w   22*4(A1)
                clr.w   23*4(A1)
                clr.w   24*4(A1)
                clr.w   25*4(A1)
                clr.w   26*4(A1)
                clr.w   27*4(A1)
                clr.w   28*4(A1)
                clr.w   29*4(A1)
                clr.w   30*4(A1)
                clr.w   31*4(A1)
                clr.w   32*4(A1)
                clr.w   33*4(A1)
                clr.w   34*4(A1)
                clr.w   35*4(A1)
                clr.w   36*4(A1)
                clr.w   37*4(A1)
                clr.w   38*4(A1)
                clr.w   39*4(A1)
                adda.l  #160,A1
                dbra    D0,P9

                movea.l $044E.W,A1
                adda.l  #160*12+2,A1      ;poz_okna_text
                move.l  #200-23,D0
.P10:
                clr.w   (A1)
                clr.w   1*4(A1)
                clr.w   2*4(A1)
                clr.w   3*4(A1)
                clr.w   4*4(A1)
                clr.w   5*4(A1)
                clr.w   6*4(A1)
                clr.w   7*4(A1)
                clr.w   8*4(A1)
                clr.w   9*4(A1)
                clr.w   10*4(A1)
                clr.w   11*4(A1)
                clr.w   12*4(A1)
                clr.w   13*4(A1)
                clr.w   14*4(A1)
                clr.w   15*4(A1)
                clr.w   16*4(A1)
                clr.w   17*4(A1)
                clr.w   18*4(A1)
                clr.w   19*4(A1)
                clr.w   20*4(A1)
                clr.w   21*4(A1)
                clr.w   22*4(A1)
                clr.w   23*4(A1)
                clr.w   24*4(A1)
                clr.w   25*4(A1)
                clr.w   26*4(A1)
                clr.w   27*4(A1)
                clr.w   28*4(A1)
                clr.w   29*4(A1)
                clr.w   30*4(A1)
                clr.w   31*4(A1)
                clr.w   32*4(A1)
                clr.w   33*4(A1)
                clr.w   34*4(A1)
                clr.w   35*4(A1)
                clr.w   36*4(A1)
                clr.w   37*4(A1)
                clr.w   38*4(A1)
                clr.w   39*4(A1)
                adda.l  #160,A1
                dbra    D0,.P10
                movea.l SAVE_A1,A1
                move.l  SAVE_D0,D0
                rts

READ_SCROLL:
                movea.l TXT_IS_HERE,A0
                addq.l  #1,TXT_IS_HERE
                clr.l   D0
                move.b  (A0),D0
                cmp.b   #$0a,D0
                bne.s   .F1
				bra READ_SCROLL
.F1		cmp.b   #$0d,D0
		bne.s   .F2
				bra READ_SCROLL
.F2
                cmp.b   #$FF,D0
                bne.s   FUCK_IS_NOW
                move.l  #$20,D0
                move.l  #TXT_SCROLL,TXT_IS_HERE

FUCK_IS_NOW:
                movea.l FONTASY(PC),A0
                adda.l  D0,A0
                lea     SKLAD,A1
                bsr     pisz_scroll
                rts


SCROLL:
                addq.l  #1,COUNTER
                cmpi.l  #8,COUNTER
                bne.s   SOMEWHERE
                bsr.s   READ_SCROLL
                clr.l   COUNTER

SOMEWHERE:
                movea.l $044E.W,A1
                adda.l  #160,A1
                lea     SKLAD,A0
                moveq   #7,D0
SNOW:
                roxl.w  (A0)

                roxl.w  39*4(A1)
                roxl.w  38*4(A1)
                roxl.w  37*4(A1)
                roxl.w  36*4(A1)
                roxl.w  35*4(A1)
                roxl.w  34*4(A1)
                roxl.w  33*4(A1)
                roxl.w  32*4(A1)
                roxl.w  31*4(A1)
                roxl.w  30*4(A1)
                roxl.w  29*4(A1)
                roxl.w  28*4(A1)
                roxl.w  27*4(A1)
                roxl.w  26*4(A1)
                roxl.w  25*4(A1)
                roxl.w  24*4(A1)
                roxl.w  23*4(A1)
                roxl.w  22*4(A1)
                roxl.w  21*4(A1)
                roxl.w  20*4(A1)
                roxl.w  19*4(A1)
                roxl.w  18*4(A1)
                roxl.w  17*4(A1)
                roxl.w  16*4(A1)
                roxl.w  15*4(A1)
                roxl.w  14*4(A1)
                roxl.w  13*4(A1)
                roxl.w  12*4(A1)
                roxl.w  11*4(A1)
                roxl.w  10*4(A1)
                roxl.w  9*4(A1)
                roxl.w  8*4(A1)
                roxl.w  7*4(A1)
                roxl.w  6*4(A1)
                roxl.w  5*4(A1)
                roxl.w  4*4(A1)
                roxl.w  3*4(A1)
                roxl.w  2*4(A1)
                roxl.w  1*4(A1)
                roxl.w  (A1)
                adda.l  #160,A1
                adda.l  #160,A0
                dbra    D0,SNOW
RTS1:
                rts
SCIEMNIJ_TXT:
				cmp.l   #1,kolory_zm
				beq .nie_no

	move.w  #$0666,_PLAN_1_KOL
*     move.w  #$0333,_PLAN_3_KOL
*     move.w  #$0444,_PLAN_2_KOL
                bsr     VSYNC

	move.w  #$0555,_PLAN_1_KOL
*   move.w  #$0333,_PLAN_3_KOL
*   move.w  #$0444,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0444,_PLAN_1_KOL
*                move.w  #$0222,_PLAN_3_KOL
*                move.w  #$0444,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0333,_PLAN_1_KOL
                *move.w  #$0222,_PLAN_3_KOL
                *move.w  #$0333,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0222,_PLAN_1_KOL
                *move.w  #$0111,_PLAN_3_KOL
                *move.w  #$0111,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0111,_PLAN_1_KOL
                *move.w  #$0111,_PLAN_3_KOL
                *move.w  #$0111,_PLAN_2_KOL
                bsr     VSYNC
                clr.w   _PLAN_1_KOL
                *clr.w   _PLAN_2_KOL
                *clr.w   _PLAN_3_KOL
                bsr     VSYNC
				bra .k56
.nie_no:
                move.w  #$0111,_PLAN_1_KOL
                *move.w  #$0000,_PLAN_3_KOL
                *move.w  #$0111,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0222,_PLAN_1_KOL
                *move.w  #$0111,_PLAN_3_KOL
                *move.w  #$0111,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0333,_PLAN_1_KOL
                *move.w  #$0222,_PLAN_3_KOL
                *move.w  #$0222,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0444,_PLAN_1_KOL
                *move.w  #$0222,_PLAN_3_KOL
                *move.w  #$0333,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0555,_PLAN_1_KOL
                *move.w  #$0333,_PLAN_3_KOL
                *move.w  #$0444,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0666,_PLAN_1_KOL
                *move.w  #$0333,_PLAN_3_KOL
                *move.w  #$0555,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0777,_PLAN_1_KOL
                *move.w  #$0333,_PLAN_3_KOL
                *move.w  #$0555,_PLAN_2_KOL
                bsr     VSYNC
.k56:           rts

ROZJASNIJ_TXT:
				cmp.l   #1,kolory_zm
				beq .nie_no

                move.w  #$0111,_PLAN_1_KOL
                *move.w  #$0000,_PLAN_3_KOL
                *move.w  #$0111,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0222,_PLAN_1_KOL
                *move.w  #$0111,_PLAN_3_KOL
               * move.w  #$0111,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0333,_PLAN_1_KOL
               * move.w  #$0222,_PLAN_3_KOL
               * move.w  #$0222,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0444,_PLAN_1_KOL
               * move.w  #$0222,_PLAN_3_KOL
               * move.w  #$0333,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0555,_PLAN_1_KOL
               * move.w  #$0333,_PLAN_3_KOL
               * move.w  #$0444,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0666,_PLAN_1_KOL
               * move.w  #$0333,_PLAN_3_KOL
               * move.w  #$0555,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0777,_PLAN_1_KOL
               * move.w  #$0333,_PLAN_3_KOL
               * move.w  #$0555,_PLAN_2_KOL
                bsr     VSYNC
				bra .k56
.nie_no:
                move.w  #$0666,_PLAN_1_KOL
               * move.w  #$0333,_PLAN_3_KOL
               * move.w  #$0444,_PLAN_2_KOL
                bsr     VSYNC

                move.w  #$0555,_PLAN_1_KOL
               * move.w  #$0333,_PLAN_3_KOL
               * move.w  #$0444,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0444,_PLAN_1_KOL
               * move.w  #$0222,_PLAN_3_KOL
               * move.w  #$0444,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0333,_PLAN_1_KOL
               * move.w  #$0222,_PLAN_3_KOL
               * move.w  #$0333,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0222,_PLAN_1_KOL
               * move.w  #$0111,_PLAN_3_KOL
               * move.w  #$0111,_PLAN_2_KOL
                bsr     VSYNC
                move.w  #$0111,_PLAN_1_KOL
               * move.w  #$0111,_PLAN_3_KOL
               * move.w  #$0111,_PLAN_2_KOL
                bsr     VSYNC
                clr.w   _PLAN_1_KOL
               * clr.w   _PLAN_2_KOL
               * clr.w   _PLAN_3_KOL
                bsr     VSYNC
.k56:
                rts
OVERSCAN:
                move.l  #10*160,PAS_Y
                movea.l $044E.W,A0
                adda.l  #160*201,A0
                move.l  #40*48,D0
                lea     PANEL+34,A1
LOOPGORA:
                move.l  (A1)+,(A0)+
                dbra    D0,LOOPGORA

                lea     PANEL1,A0
                movea.l #$FFFF8240,A1
                movem.l (A0),D0-D7
                movem.l D0-D7,(A1)
                move.w  #$00,$FFFF8240
                move.w  #$0666,$FFFF8242
                move.w  #$0711,$FFFF8244
                move.w  #$0777,$FFFF8246
                rts

CLR_PAS:
                move.l  D1,SAVE_D1
                move.l  D0,SAVE_D0
                move.l  A0,SAVE_A0
                move.l  PAS_Y,D1
                moveq.l   #20,D0
                movea.l $044E.W,A1
                addq.l  #2,A1
                adda.l  D1,A1
P11:
                clr.w   (A1)
                clr.w   1*4(A1)
                clr.w   2*4(A1)
                clr.w   3*4(A1)
                clr.w   4*4(A1)
                clr.w   5*4(A1)
                clr.w   6*4(A1)
                clr.w   7*4(A1)
                clr.w   8*4(A1)
                clr.w   9*4(A1)
                clr.w   10*4(A1)
                clr.w   11*4(A1)
                clr.w   12*4(A1)
                clr.w   13*4(A1)
                clr.w   14*4(A1)
                clr.w   15*4(A1)
                clr.w   16*4(A1)
                clr.w   17*4(A1)
                clr.w   18*4(A1)
                clr.w   19*4(A1)
                clr.w   20*4(A1)
                clr.w   21*4(A1)
                clr.w   22*4(A1)
                clr.w   23*4(A1)
                clr.w   24*4(A1)
                clr.w   25*4(A1)
                clr.w   26*4(A1)
                clr.w   27*4(A1)
                clr.w   28*4(A1)
                clr.w   29*4(A1)
                clr.w   30*4(A1)
                clr.w   31*4(A1)
                clr.w   32*4(A1)
                clr.w   33*4(A1)
                clr.w   34*4(A1)
                clr.w   35*4(A1)
                clr.w   36*4(A1)
                clr.w   37*4(A1)
                clr.w   38*4(A1)
                clr.w   39*4(A1)
                adda.l  #160,A1
                dbra    D0,P11
                move.l  SAVE_D1,D1
                move.l  SAVE_D0,D0
                movea.l SAVE_A0,A0
                rts
ustal_strony:				; wymaga podania w a0 tekstu
				movem.l d0-d2/a0-a1,dla_stron	; zwraca d2 = ilosc stron

				cmp.w  #'PI',(a0)
				bne .ok
				addq.l #2,a0

*				clr.l  adres_picy0
*			    move.w #$ffff,strona_picy0
*				clr.w  picy_x0
*				clr.w  picy_y0
*				clr.w  width0
*				clr.w  high0

				clr.l  adres_picy1
			    move.w #$fe0f,strona_picy1
				clr.w  picy_x1
				clr.w  picy_y1
				clr.w  width1
				clr.w  high1

				clr.l  adres_picy2
			    move.w #$fe0f,strona_picy2
				clr.w  picy_x2
				clr.w  picy_y2
				clr.w  width2
				clr.w  high2

				move.w #1,picy_jest
				move.l (a0)+,adres_picy0
			    move.w (a0)+,strona_picy0
				move.w (a0)+,picy_x0
				move.w (a0)+,picy_y0
				move.w (a0)+,width0
				move.w (a0)+,high0
				cmp.l  #'jest',(a0)+
				bne .ok
				move.l (a0)+,adres_picy1
			    move.w (a0)+,strona_picy1
				move.w (a0)+,picy_x1
				move.w (a0)+,picy_y1
				move.w (a0)+,width1
				move.w (a0)+,high1
				cmp.l  #'jest',(a0)+
				bne .ok
				move.l (a0)+,adres_picy2
			    move.w (a0)+,strona_picy2
				move.w (a0)+,picy_x2
				move.w (a0)+,picy_y2
				move.w (a0)+,width2
				move.w (a0)+,high2
			
.ok
				clr.l d2
				clr.l d0
				lea Tabela_stron,a1
				moveq.l #25,d1
.lo1			clr.l (a1)+
				dbf d1,.lo1				
				clr.l d1
				lea Tabela_stron,a1
				move.l #0,4(a1)
				move.l a0,(a1)+
_petla:			move.b (a0)+,d0
				cmp.b #$0d,d0
				bne VAT
				move.b (a0)+,d0
				cmp.b #$0a,d0
				beq jest_l
VAT:			cmp.b #$ff,d0
				bne _petla
				move.l d2,pages
				lea NR_STRONY,a0
				add.l d2,a0
				move.l a0,adres_k_stron
				movem.l dla_stron,d0-d2/a0-a1
				rts
				
jest_l:
				addq.w #1,d1
				cmp.w #21,d1			*19
				beq jest_s
				bra _petla
jest_s:
				move.l #0,4(a1)
				move.l a0,(a1)+
				clr.l d1
				addq.l #4,d2
				bra _petla
				
SCIEMNIJ:
                movea.l #$FFFF8240,A1

                moveq   #6,D4
                moveq   #0,D7
Q425B6:         moveq   #0,D0
Q425B8:         move.w  0(A1,D0.w),D1
                move.w  D1,D2
                move.w  D2,D3
                andi.w  #7,D1
                subq.w  #1,D1
                bpl.s   Q425CA
                moveq   #0,D1
Q425CA:         andi.w  #$70,D2
                subi.w  #$10,D2
                bpl.s   Q425D6
                moveq   #0,D2
Q425D6:         andi.w  #$0700,D3
                subi.w  #$0100,D3
                bpl.s   Q425E2
                moveq   #0,D3
Q425E2:         or.w    D2,D1
                or.w    D3,D1
                move.w  D1,0(A1,D0.w)
                addq.w  #1,D7
                btst    #0,D7
                beq.s   Q425FC
                btst    #1,D7
                beq.s   Q425FC
                btst    #2,D7
                beq.s   Q425FC
                bsr     Q426D4

Q425FC:
                addq.w  #2,D0
                cmpi.w  #$20,D0
                bmi.s   Q425B8
                dbra    D4,Q425B6
Q426D4:
                move.l  D0,-(SP)
                move.l  $0466.w,D0
Q426DA:
                cmp.l   $0466.w,D0
                beq.s   Q426DA
                move.l  (SP)+,D0
                rts

PAUSE:
                move.l  #4000000,D0
Lô2:
                move.l  #800,D1
Lô3:
                nop
                nop
                dbra    D1,Lô3

                nop
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                dbra    D0,Lô2
                rts


ROZJASNIJ:
*                movea.l #BUFOR_ZMIENNY+2,A0
T_V_3:          movea.l #$FFFF8240,A1
                moveq   #6,D4
                move.w  #0,D7
Q1425B6:        moveq   #0,D0
Q1425B8:        move.w  0(A1,D0.w),D1
                move.w  0(A0,D0.w),D5
                move.w  D5,D6
                move.w  D6,QD7
                move.w  D1,D2
                move.w  D2,D3
                andi.w  #7,D1
                addq.w  #1,D1
                andi.w  #7,D5
                cmp.w   D5,D1
                bcs.s   Q1425CA
                move.w  D5,D1
Q1425CA:        andi.w  #$70,D2
                addi.w  #$10,D2
                andi.w  #$70,D6
                cmp.w   D6,D2
                bcs.s   Q1425D6
                move.w  D6,D2
Q1425D6:        andi.w  #$0700,D3
                addi.w  #$0100,D3
                andi.w  #$0700,QD7
                cmp.w   QD7,D3
                bcs.s   Q1425E2
                move.w  QD7,D3
Q1425E2:        or.w    D2,D1
                or.w    D3,D1
                move.w  D1,0(A1,D0.w)
                addq.w  #1,D7
                btst    #0,D7
                beq.s   Q1425FC
                btst    #1,D7
                beq.s   Q1425FC
                btst    #2,D7
                beq.s   Q1425FC
                jsr     Q426D4

Q1425FC:        addq.w  #2,D0
                cmpi.w  #$20,D0
                bmi.s   Q1425B8
                dbra    D4,Q1425B6
                rts

QD7:            DS.W 1

kontrol_panel:
	movem.l d0-d5/a0/a1,I_like_milk
	bsr zapamieci
*	bsr VSYNC
	move.l #$0000ffff,d5
	move.l #$ffff0000,d4
	move.l $44e,a0
	add.l #160*8+4,a0
	add.l #20*160+3*4,a0
	move.l a0,a1
	move.l #160,d0
okular
	move.w (a1),2(a0)
	move.w 4(a1),6(a0)
	move.w 8(a1),10(a0)
	move.w 12(a1),14(a0)
	move.w 16(a1),18(a0)
	move.w 20(a1),22(a0)
	move.w 24(a1),26(a0)
	move.w 28(a1),30(a0)
	move.w 32(a1),34(a0)
	move.w 36(a1),38(a0)
	move.w 40(a1),42(a0)
	move.w 44(a1),46(a0)
	clr.w (a1)
	clr.w 4(a1)
	clr.w 8(a1)
	clr.w 12(a1)
	clr.w 16(a1)
	clr.w 20(a1)
	clr.w 24(a1)
	clr.w 28(a1)
	clr.w 32(a1)
	clr.w 36(a1)
	clr.w 40(a1)
	clr.w 44(a1)
	move.w 4+44(a1),6+44(a0)
	move.w 8+44(a1),10+44(a0)
	move.w 12+44(a1),14+44(a0)
	move.w 16+44(a1),18+44(a0)
	move.w 20+44(a1),22+44(a0)
	move.w 24+44(a1),26+44(a0)
	move.w 28+44(a1),30+44(a0)
	move.w 32+44(a1),34+44(a0)
	move.w 36+44(a1),38+44(a0)
	move.w 40+44(a1),42+44(a0)
	move.w 44+44(a1),46+44(a0)
	clr.w 4+44(a1)
	clr.w 8+44(a1)
	clr.w 12+44(a1)
	clr.w 16+44(a1)
	clr.w 20+44(a1)
	clr.w 24+44(a1)
	clr.w 28+44(a1)
	clr.w 32+44(a1)
	clr.w 36+44(a1)
	clr.w 40+44(a1)
	clr.w 44+44(a1)

	move.w 4+44+44(a1),6+44+44(a0)
	move.w 8+44+44(a1),10+44+44(a0)
	move.w 12+44+44(a1),14+44+44(a0)
	move.w 16+44+44(a1),18+44+44(a0)
	move.w 20+44+44(a1),22+44+44(a0)
	move.w 24+44+44(a1),26+44+44(a0)
	move.w 28+44+44(a1),30+44+44(a0)
	move.w 32+44+44(a1),34+44+44(a0)
	clr.w 4+44+44(a1)
	clr.w 8+44+44(a1)
	clr.w 12+44+44(a1)
	clr.w 16+44+44(a1)
	clr.w 20+44+44(a1)
	clr.w 24+44+44(a1)
	clr.w 28+44+44(a1)
	clr.w 32+44+44(a1)
	add.l #160,a0
	add.l #160,a1
	dbf d0,okular

	*bsr VSYNC
	move.l $44e,a0
	add.l #20*160+3*4,a0

	move.l d4,(a0)
	move.l d4,4(a0)
	move.l d4,8(a0)
	move.l d4,12(a0)
	move.l d4,16(a0)
	move.l d4,20(a0)
	move.l d4,24(a0)
	move.l d4,28(a0)
	move.l d4,32(a0)
	move.l d4,36(a0)
	move.l d4,40(a0)
	move.l d4,44(a0)

	move.l d4,4+44(a0)
	move.l d4,8+44(a0)
	move.l d4,12+44(a0)
	move.l d4,16+44(a0)
	move.l d4,20+44(a0)
	move.l d4,24+44(a0)
	move.l d4,28+44(a0)
	move.l d4,32+44(a0)
	move.l d4,36+44(a0)
	move.l d4,40+44(a0)
	move.l d4,44+44(a0)

	move.l d4,4+44+44(a0)
	move.l d4,8+44+44(a0)
	move.l d4,12+44+44(a0)
	move.l d4,16+44+44(a0)
	move.l d4,20+44+44(a0)
	move.l d4,24+44+44(a0)
	move.l d4,28+44+44(a0)
	move.l d4,32+44+44(a0)

	add.l #160,a0
	move.l #%10101010101010100101010101010101,d3
	move.l #%10101010101010100000000000000000,d1
	move.l #%01010101010101010000000000000000,d2
*	move.l #%01010101010101011010101010101010,d4
	move.l #%01010101010101010000000000000000,d4

	moveq.l #4,d0
ki
	move.l d4,(a0)
	move.l d4,4(a0)
	move.l d4,8(a0)
	move.l d4,12(a0)
	move.l d4,16(a0)
	move.l d4,20(a0)
	move.l d4,24(a0)
	move.l d4,28(a0)
	move.l d4,32(a0)
	move.l d4,36(a0)
	move.l d4,40(a0)
	move.l d4,44(a0)
	move.l d4,4+44(a0)
	move.l d4,8+44(a0)
	move.l d4,12+44(a0)
	move.l d4,16+44(a0)
	move.l d4,20+44(a0)
	move.l d4,24+44(a0)
	move.l d4,28+44(a0)
	move.l d4,32+44(a0)
	move.l d4,36+44(a0)
	move.l d4,40+44(a0)
	move.l d4,44+44(a0)
	move.l d4,4+44+44(a0)
	move.l d4,8+44+44(a0)
	move.l d4,12+44+44(a0)
	move.l d4,16+44+44(a0)
	move.l d4,20+44+44(a0)
	move.l d4,24+44+44(a0)
	move.l d4,28+44+44(a0)
	bset  #7,36+44+44(a0)
	add.l #160,a0

	move.l d3,(a0)
	move.l d3,4(a0)
	move.l d3,8(a0)
	move.l d3,12(a0)
	move.l d3,16(a0)
	move.l d3,20(a0)
	move.l d3,24(a0)
	move.l d3,28(a0)
	move.l d3,32(a0)
	move.l d3,36(a0)
	move.l d3,40(a0)
	move.l d3,44(a0)
	move.l d3,4+44(a0)
	move.l d3,8+44(a0)
	move.l d3,12+44(a0)
	move.l d3,16+44(a0)
	move.l d3,20+44(a0)
	move.l d3,24+44(a0)
	move.l d3,28+44(a0)
	move.l d3,32+44(a0)
	move.l d3,36+44(a0)
	move.l d3,40+44(a0)
	move.l d3,44+44(a0)
	move.l d3,4+44+44(a0)
	move.l d3,8+44+44(a0)
	move.l d3,12+44+44(a0)
	move.l d3,16+44+44(a0)
	move.l d3,20+44+44(a0)
	move.l d3,24+44+44(a0)
	move.l d3,28+44+44(a0)
	bset  #7,36+44+44(a0)
	add.l #160,a0
	dbf d0,ki

	move.l #(160-10)/2,d0

loopoki
	move.l d1,(a0)
	move.l d1,4(a0)
	move.l d1,8(a0)
	move.l d1,12(a0)
	move.l d1,16(a0)
	move.l d1,20(a0)
	move.l d1,24(a0)
	move.l d1,28(a0)
	move.l d1,32(a0)
	move.l d1,36(a0)
	move.l d1,40(a0)
	move.l d1,44(a0)

	move.l d1,4+44(a0)
	move.l d1,8+44(a0)
	move.l d1,12+44(a0)
	move.l d1,16+44(a0)
	move.l d1,20+44(a0)
	move.l d1,24+44(a0)
	move.l d1,28+44(a0)
	move.l d1,32+44(a0)
	move.l d1,36+44(a0)
	move.l d1,40+44(a0)
	move.l d1,44+44(a0)

	move.l d1,4+44+44(a0)
	move.l d1,8+44+44(a0)
	move.l d1,12+44+44(a0)
	move.l d1,16+44+44(a0)
	move.l d1,20+44+44(a0)
	move.l d1,24+44+44(a0)
	move.l d1,28+44+44(a0)
	move.l d1,32+44+44(a0)
	bset  #7,36+44+44(a0)

	add.l #160,a0

	move.l d2,(a0)
	move.l d2,4(a0)
	move.l d2,8(a0)
	move.l d2,12(a0)
	move.l d2,16(a0)
	move.l d2,20(a0)
	move.l d2,24(a0)
	move.l d2,28(a0)
	move.l d2,32(a0)
	move.l d2,36(a0)
	move.l d2,40(a0)
	move.l d2,44(a0)

	move.l d2,4+44(a0)
	move.l d2,8+44(a0)
	move.l d2,12+44(a0)
	move.l d2,16+44(a0)
	move.l d2,20+44(a0)
	move.l d2,24+44(a0)
	move.l d2,28+44(a0)
	move.l d2,32+44(a0)
	move.l d2,36+44(a0)
	move.l d2,40+44(a0)
	move.l d2,44+44(a0)

	move.l d2,4+44+44(a0)
	move.l d2,8+44+44(a0)
	move.l d2,12+44+44(a0)
	move.l d2,16+44+44(a0)
	move.l d2,20+44+44(a0)
	move.l d2,24+44+44(a0)
	move.l d2,28+44+44(a0)
	move.l d2,32+44+44(a0)
	bset  #7,36+44+44(a0)

	add.l #160,a0
	dbf d0,loopoki

	move.w d5,(a0)
	move.w d5,4(a0)
	move.w d5,8(a0)
	move.w d5,12(a0)
	move.w d5,16(a0)
	move.w d5,20(a0)
	move.w d5,24(a0)
	move.w d5,28(a0)
	move.w d5,32(a0)
	move.w d5,36(a0)
	move.w d5,40(a0)
	move.w d5,44(a0)

	move.w d5,4+44(a0)
	move.w d5,8+44(a0)
	move.w d5,12+44(a0)
	move.w d5,16+44(a0)
	move.w d5,20+44(a0)
	move.w d5,24+44(a0)
	move.w d5,28+44(a0)
	move.w d5,32+44(a0)
	move.w d5,36+44(a0)
	move.w d5,40+44(a0)
	move.w d5,44+44(a0)

	move.w d5,4+44+44(a0)
	move.w d5,8+44+44(a0)
	move.w d5,12+44+44(a0)
	move.w d5,16+44+44(a0)
	move.w d5,20+44+44(a0)
	move.w d5,24+44+44(a0)
	move.w d5,28+44+44(a0)
	move.w d5,32+44+44(a0)

	move.l $44e,a0
	add.l #32*160+3*4,a0
	move.l #150,d0
	move.l #$ffffffff,d3
opÅ
	move.l d3,(a0)
	move.l d3,4(a0)
	move.l d3,8(a0)
	move.l d3,12(a0)
	move.l d3,16(a0)
	move.l d3,20(a0)
	move.l d3,24(a0)
	move.l d3,28(a0)
	move.l d3,32(a0)
	move.l d3,36(a0)
	move.l d3,40(a0)
	move.l d3,44(a0)
	move.l d3,4+44(a0)
	move.l d3,8+44(a0)
	move.l d3,12+44(a0)
	move.l d3,16+44(a0)
	move.l d3,20+44(a0)
	move.l d3,24+44(a0)
	move.l d3,28+44(a0)
	move.l d3,32+44(a0)
	move.l d3,36+44(a0)
	move.l d3,40+44(a0)
	move.l d3,44+44(a0)
	move.l d3,4+44+44(a0)
	move.l d3,8+44+44(a0)
	move.l d3,12+44+44(a0)
	move.l d3,16+44+44(a0)
	move.l d3,20+44+44(a0)
	move.l d3,24+44+44(a0)
	move.l d3,28+44+44(a0)
	move.l d3,32+44+44(a0)
	add.l #160,a0
	dbf d0,opÅ	
	
	move.l $44e,a0	
	add.l #20*160+3*4+41+160*2,a0
	add.l #48+28,a0	
	move.b #%00000000,(a0)
	move.b #%00000000,3(a0)
	move.b #%00000011,160(a0)
	move.b #%11111111,163(a0)
	move.b #%00000010,2*160(a0)
	move.b #%00000001,2*160+3(a0)
	move.b #%00000010,3*160(a0)
	move.b #%00000001,3*160+3(a0)
	move.b #%00000010,4*160(a0)
	move.b #%00000001,4*160+3(a0)
	move.b #%00000010,5*160(a0)
	move.b #%00000001,5*160+3(a0)
	move.b #%00000011,6*160(a0)
	move.b #%11111111,6*160+3(a0)
	move.b #%00000000,7*160(a0)
	move.b #%00000000,7*160+3(a0)
	move.b #%00000000,8*160(a0)
	move.b #%00000000,8*160+3(a0)


*	move.l #34*160,LICZNIK_FNT_Y
*	move.l #15*4,LICZNIK_FNT_X
*	move.l #credits,TXT_POINT
	move.l #1,maska	
*	bsr TXT_NA_EKRAN	
*	move.l #34*160,LICZNIK_FNT_Y
*	move.l #15*4+2,LICZNIK_FNT_X
*	move.l #credits,TXT_POINT
*	bsr TXT_NA_EKRAN	

	move.l #44*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits1,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #44*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits1,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #54*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits2,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #54*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits2,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #64*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits3,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #64*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits3,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #74*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits4,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #74*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits4,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #84*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits5,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #84*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits5,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #94*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits6,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #94*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits6,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #104*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits7,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #104*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits7,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #114*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits8,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #114*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits8,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #124*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits9,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #124*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits9,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #134*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits10,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #134*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits10,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #144*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits11,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #144*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits11,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #154*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits12,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #154*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits12,TXT_POINT
	bsr TXT_NA_EKRAN	

	move.l #164*160,LICZNIK_FNT_Y
	move.l #4*4,LICZNIK_FNT_X
	move.l #credits13,TXT_POINT
	bsr TXT_NA_EKRAN	
	move.l #164*160,LICZNIK_FNT_Y
	move.l #4*4+2,LICZNIK_FNT_X
	move.l #credits13,TXT_POINT
	bsr TXT_NA_EKRAN	

	clr.l maska


asas
	cmp.b #$3b,$fffc02
	beq func1
	cmp.b #$3c,$fffc02
	beq func2
	cmp.b #$3d,$fffc02
	beq func3
	cmp.b #$3e,$fffc02
	beq func4

	bra asas
func1:
	lea mod_pisz,a0
	move.l #'PAPE',(a0)+
	move.l #'R_IN',(a0)+
	bra skocz
func2:
	lea mod_pisz,a0
	move.l #'VECT',(a0)+
	move.l #'ORTV',(a0)+
	bra skocz
func3:
	lea mod_pisz,a0
	move.l #'SMOT',(a0)+
	move.l #'H_TV',(a0)+
	bra skocz
func4:
	lea mod_pisz,a0
	move.l #'COMP',(a0)+
	move.l #'UTER',(a0)+
skocz
	move.l #'.MOD',(a0)+
	move.l $44e,a0
	lea sh_na_okno,a1
	add.l #20*160+3*4,a0
	move.l #180,d0
.loop	
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	add.l #160-(3*14)*4,a0
	dbf d0,.loop
	movem.l I_like_milk,d0-d5/a0/a1
	rts
	
zapamieci:	
	move.l $44e,a1
	lea sh_na_okno,a0
	add.l #20*160+3*4,a1
	move.l #180,d0
.loop	
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+
	move.l (a1)+,(a0)+

	add.l #160-(3*14)*4,a1
	dbf d0,.loop
	rts
Oruj:
	move.l $44e,a0
	add.l #31*160+3*4,a0
	move.l #151,d0
.okular
	eor.w d5,(a0)
	eor.w d5,4(a0)
	eor.w d5,8(a0)
	eor.w d5,12(a0)
	eor.w d5,16(a0)
	eor.w d5,20(a0)
	eor.w d5,24(a0)
	eor.w d5,28(a0)
	eor.w d5,32(a0)
	eor.w d5,36(a0)
	eor.w d5,40(a0)
	eor.w d5,44(a0)
	add.l #160,a0
	dbf d0,.okular
	rts


POMPEY:
      MOVEA.L   A4,A0 
      MOVEA.L   A4,A2 
      ADDQ.L    #4,A2 
      MOVE.L    -(A0),D6
      MOVE.L    -(A0),D2
      SUBA.L    D2,A2 
      MOVEA.L   A2,A4 
      ADDA.L    D6,A2 
      MOVEQ     #0,D0 
      MOVEA.L   #$FF8240,A6 
      MOVE.W    (A6),D7 
L003F:MOVE.B    -(A0),D0
      BEQ.B     L003F 
L0040:MOVEQ     #0,D2 
      BSR       L004D 
      BCS.B     L0043 
      MOVE.B    -(A0),D2
L0041:MOVE.B    D2,-(A2)
      BRA.B     L0045 
L0042:MOVEQ     #$F,D4
      MOVEQ     #2,D3 
      BSR       L0050 
      BNE.B     L004B 
      MOVE.W    D4,D2 
      BRA.B     L0041 
L0043:BSR.B     L004D 
      BCC.B     L0047 
      BSR.B     L004D 
      BCC.B     L0042 
      BSR.B     L004D 
      BCS.B     L0044 
      MOVEQ     #2,D1 
      BSR       L0053 
      EXG       D2,D1 
      ADDQ.W    #1,D2 
      BSET      D1,D2 
      BRA.B     L0041 
L0044:BSR.B     L004D 
      BCS.B     L0046 
      MOVEQ     #$F,D4
      MOVE.W    #3,D3 
      BSR.B     L0050 
      BNE.B     L004B 
      MOVE.B    (A2),-(A2)
L0045:
*      MOVE.W    D7,(A6) 
*	  NEG.W     (A6)
	  move.W     d0,(A6)

      CMPA.L    A2,A4 
      BLT.B     L0040 
      MOVE.W    D7,(A6) 
      RTS 
L0046:MOVEQ     #4,D3 
      BRA.B     L004A 
L0047:BSR.B     L004D 
      BCS.B     L0057 
      MOVEQ     #1,D1 
L0048:LSR.B     #1,D0 
      BNE.B     L0049 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L0049:ADDX.W    D2,D2 
      DBF       D1,L0048
      MOVE.W    D2,D1 
      BEQ.B     L0056 
      ADDQ.W    #1,D1 
      ADD.W     D1,D1 
      SUBQ.W    #1,D1 
      BSR.B     L0053 
      MOVE.W    D2,D3 
L004A:BSR.B     L004F 
L004B:MOVEA.L   A2,A1 
      ADDA.L    D2,A1 
L004C:MOVE.B    -(A1),-(A2) 
      DBF       D3,L004C
      BRA.B     L0045 
L004D:LSR.B     #1,D0 
      BNE.B     L004E 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L004E:RTS 

L004F:MOVEQ     #0,D4 
L0050:MOVEQ     #1,D1 
      MOVEQ     #0,D2 
L0051:LSR.B     #1,D0 
      BNE.B     L0052 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L0052:ADDX.W    D2,D2 
      DBF       D1,L0051
      MOVE.W    D2,D1 
      ADDQ.W    #1,D1 
      LSL.W     #2,D1 
      SUBQ.W    #1,D1 
      EOR.B     D1,D4 
      BNE.B     L0053 
      RTS 
      MOVEQ     #7,D1 
L0053:MOVEQ     #0,D2 
L0054:LSR.B     #1,D0 
      BNE.B     L0055 
      MOVE.B    -(A0),D0
      ROXR.B    #1,D0 
L0055:ADDX.W    D2,D2 
      DBF       D1,L0054
      RTS 
L0056:BSR.B     L004F 
      MOVE.W    D2,D3 
      MOVEQ     #1,D2 
      BRA.B     L004B 
L0057:MOVEQ     #1,D3 
      MOVE.B    -(A0),D2
      BRA.B     L004B 
L0058:BSR       L005C 
      MOVEM.L   A0/D0-D1,-(A7)
      MOVEA.L   #0,A0 
L0059 EQU       *-4 
      MOVE.L    #$7D0,D1
      MOVEQ     #0,D0 
L005A:MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      MOVE.L    D0,(A0)+
      DBF       D1,L005A
      BSR       L005B 
      DC.B      'L',$DF,$01,$03,'Nu'
L005B:DC.B      'H',$E7,$E0,$F0,$A0,$00,' h'
      DC.B      $00,$08,'BP',$A0,$09,'L',$DF
      DC.B      $0F,$07,'Nu'
L005C:DC.B      'H',$E7 
      ASR       10(A0,A2.W) 
      MOVEM.L   (A7)+,A0-A3/D0-D2 
      RTS 
obraz_spr:
		cmp.w #1,picy_jest
		bne okyy
		cmp.w  strona_picy0,d3
		bne .a1
		move.l adres_picy0,adres_picy
		move.w picy_x0,picy_x
		move.w picy_y0,picy_y
		move.w width0,width
		move.w high0,high
		bra no_need
.a1		cmp.w  strona_picy1,d3
		bne .a2
		move.l adres_picy1,adres_picy
		move.w picy_x1,picy_x
		move.w picy_y1,picy_y
		move.w width1,width
		move.w high1,high
		bra no_need			
.a2		cmp.w  strona_picy2,d3
		bne okyy
		move.l adres_picy2,adres_picy
		move.w picy_x2,picy_x
		move.w picy_y2,picy_y
		move.w width2,width
		move.w high2,high

no_need
		movem.l d0-d4/a0/a1,love_a

		moveq.l #0,d0
		moveq.l #0,d1
		moveq.l #0,d2

		move.l $44e,a0
		move.w picy_x,d0
		move.w picy_y,d1
		mulu  #160,d1
		
		add.l d1,a0
		add.l d0,a0

		move.l adres_picy,a1
		move.w width,d1			; szer, il. 16.
 		move.w high,d0			; wys
		move.l d1,d2
		mulu #4,d2
		move.l #160,d4
		sub.l d2,d4
		subq.l #4,d4
.loop1	
		move.w width,d1			; szer, il. 16.
.loop
		move.l (a1)+,(a0)+
		dbf d1,.loop				
		add.l d4,a1		
		add.l d4,a0		
		dbf d0,.loop1
.ok
		movem.l love_a,d0-d4/a0/a1

okyy
		rts
*************************
* przerwania            *
*************************

VBI:
	movem.l D0-D5/A0-A1,-(SP)
	move.b  #0,$FFFFFA1B.w
	move.b  #199,$FFFFFA21.w
	move.b  #8,$FFFFFA1B.w
	move.b  #1,$FFff8260.w
	move.w  _plan_0_kol,$FFFF8240.w
	*move.w  #$202,$FFFF8240
	move.w  _PLAN_1_KOL,$FFFF8242
	move.w  #$0711,$FFFF8244
	move.w  #$0775,$FFFF8246
	BTST	#1,$FFFF820A.W
	BNE		.not60
	SUBQ.W	#1,hz_cont
	BNE.S	.not60
	MOVE.W	#6,hz_cont
	BRA		.all
.not60
.all
	rept 3
	bsr     SCROLL
	endr
 	JSR	REPLAY_ROT+$20

.as
	cmp.b #0,$ffff8209.w
	beq .as
*	move.w  #$737,$FFFF8240.w

	moveq.l #80,d0
.loop
	REPT 8
	nop
	ENDR
	dbf d0,.loop
		move.w  #1,WFNC

	clr.w    $FFFF8240.w       *
	move.w  _PLAN_2_KOL,$FFFF8244.w	* plan 2
	move.w  _PLAN_3_KOL,$FFFF8246.w	* plan 3 (PLAN_3_KOL)
	move.l $44e,a0
	move.l #$0000ffff,(a0)
	movem.l (SP)+,D0-D5/A0-A1
	rte

TIMER:
                clr.b   $FFFFFA1B.w
                move.b  #199,$FFFFFA21.w
                move.b  #8,$FFFFFA1B.w
P1:             cmp.b   #199,$FFFFFA21.w
                beq.s   P1
                clr.b   $FFff8260.w
                move.b  #0,$FFFF820A.w
                move.w  #$737,$ffff8240.w
				rept 9              
				nop
				endr
                move.b  #2,$FFFF820A.w
				move.l  A0,SAVE_A0
                move.l  a1,SAVE_D0
				lea 	PANEL1,a0
                lea 	$ffff8240.w,a1
*                move.w  #$0553,$FFFF8242
                move.w  4(a0),4(a1)
                move.w  2(a0),2(a1)
                move.w  6(a0),6(a1)
                move.w  8(a0),8(a1)
*                move.w  (a0),(a1)
	rept 67
	nop
	endr
                move.w  #$202,$ffff8240.w
                bclr    #0,$FFFFFA0F.w

                movea.l SAVE_A0(PC),A0
                move.l  SAVE_D0(PC),a1
                bclr    #0,$FFFA0F      *REJ PRZERW TMR A
RT:             rte
minus_key_in:
	lea 	PANEL+34+14*8+50*160,a0
	move.l 	$44e,a1
	add.l 	#160*201+14*8,a1
	bsr AE
	rts

plus_key_in:
	lea 	PANEL+34+17*8+50*160,a0
	move.l 	$44e,a1
	add.l 	#160*201+17*8,a1
	bsr AE
	rts
minus_key_out:
	lea 	PANEL+34+14*8,a0
	move.l 	$44e,a1
	add.l 	#160*201+14*8,a1
	bsr AE
	rts

plus_key_out:
	lea 	PANEL+34+17*8,a0
	move.l 	$44e,a1
	add.l 	#160*201+17*8,a1
	bsr AE
	rts

AE:
	move.l d0,zap_d0
	moveq.l #50,d0
.loop4
	move.l (a0),(a1)				
	move.l 1*4(a0),1*4(a1)				
	move.l 2*4(a0),2*4(a1)				
	move.l 3*4(a0),3*4(a1)				
	move.l 4*4(a0),4*4(a1)				
	move.l 5*4(a0),5*4(a1)				
	add.l #160,a1
	add.l #160,a0
	dbf d0,.loop4
	move.l zap_d0,d0
	rts

ugly_kid:
	jsr CLS
	lea    porno+34,a0
	move.l #40*200,d0
	move.l $44e,a1
.loopy
	move.l (a0)+,(a1)+
	dbf d0,.loopy
    lea porno+2,A0
	bsr T_V_3
	bsr PAUSE
	bsr SCIEMNIJ
	lea    dupam+34,a0
	move.l #40*200,d0
	move.l $44e,a1
.loopx
	move.l (a0)+,(a1)+
	dbf d0,.loopx
    lea dupam+2,A0
	bsr T_V_3
	bsr PAUSE
	bsr SCIEMNIJ
	jsr CLS
	rts
czytaj_mod
czytaj_porno:
*	move.l #filename,d1
*	move.l #dupam,d2
*	move.l #11830,d3
*	bsr read_file

*	move.l #filename1,d1
*	move.l #porno,d2
*	move.l #17338,d3
*	bsr read_file

	pea dta
	move #$1a,-(sp)
	trap #1
	addq.l #6,sp

	move.w #$0,-(sp)
	pea name_mod
	move.w #$4e,-(sp)
	trap #1
	addq.l #8,sp
.er	tst d0
	bmi .er
	lea 	dta,a0
	clr.b 	44(a0)
	move.l 26(a0),d3
	add.l #30,a0
*	move.l a0,d1
	move.l #name_mod,d1
	move.l #MODULE,d2
	bsr read_file

	lea 	dta,a0
	move.l 26(a0),d3
	subq.l #4,d3
   lea     MODULE,A4
	add.l 	d3,a4
	cmp.l   #'POPI',(a4)
	bne .tu
   bsr     POMPEY
.tu
*    lea     porno,A4
*	add.l 	#17338-4,a4
*    bsr     POMPEY

*    lea     dupam,A4
*	add.l 	#11830-4,a4
*    bsr     POMPEY
	rts

read_file:				;d1-nazwa, d2-buffor, d3 - dlugosc	
	move.w #0,-(sp)
	move.l d1,-(sp)
	move.w #$3d,-(sp)
	trap #1
	addq.l #8,sp
.err
	tst.w d0
	bmi .err
	move d0,handle
	move.l d2,-(sp)			;dupam
	move.l d3,-(sp)
	move.w handle,-(sp)
	move.w #$3f,-(sp)
	trap #1
	add.l #12,sp
	tst.l d0
	bmi .err
	
	move.w handle,-(sp)
	move.w #$3e,-(sp)
	trap #1
	addq.l #4,sp
	tst.w d0
	bmi .err
	rts
**************************
* dane                   *
**************************
	SECTION DATA
SAVE_24:        DC.L 0
handle:			dc.l 0
filename:		dc.b "a:voice.4\tv2.dat",0
				even
filename1:		dc.b "a:voice.4\tv1.dat",0
				even
name_mod		dc.b "a:modules.mod\"
mod_pisz:		dc.b "vectortv.mod",0,0,0
				even
_PLAN_1_KOL:    DC.W $0666
_plan_0_kol:	dc.w $0000
_PLAN_2_KOL:	dc.w $0707    *dc.w $0333
_PLAN_3_KOL:	dc.w $0707    *dc.w $0555
FONTASY:        DC.L 0
tryb:			dc.l 9
tryb1:			dc.l 160
OLD484:         DC.L 0
SAVE_A0:        DC.L 0
SAVE_D0:        DC.L 0
SAVE_A1:        DC.L 0
SAVE_D1:        DC.L 0
TXT_POINT:      DC.L 0
LICZNIK_FNT_X:  DC.L 0
LICZNIK_FNT_Y:  DC.L 0
hz_cont:		DC.W 6
FONT:           DC.L 0
maska:			dc.l 0
alfa:			dc.l 0
picy_jest:		dc.w 0
strona_picy:	dc.w 0
adres_picy:		dc.l 0
PAS_Y:          DC.L 0
MENU_POZ:       DC.W 2
MFPA07:         DC.B 0
MFPA09:         DC.B 0
MFPA13:         DC.B 0
MFPA15:         DC.B 0
MFPA19:         DC.B 0
MFPA1F:         DC.B 0
                EVEN
key_count:		dc.w 0
adres_picy0: 	dc.l 0
strona_picy0:	dc.w 0
picy_x0:		dc.w 0
picy_y0:		dc.w 0
width0:			dc.w 0
high0:			dc.w 0

adres_picy2: 	dc.l 0
strona_picy2:	dc.w 0
picy_x2:		dc.w 0
picy_y2:		dc.w 0
width2:			dc.w 0
high2:			dc.w 0

adres_picy1: 	dc.l 0
strona_picy1:	dc.w 0
picy_x1:		dc.w 0
picy_y1:		dc.w 0
width1:			dc.w 0
high1:			dc.w 0

picy_x			dc.w 0
picy_y			dc.w 0
width			dc.w 0
high			dc.w 0
OLD134:         DC.L 0
OLDVBL:         DC.L 0
SAVE_FNT:       DC.L 0
SAVE_USP:       DC.L 0
WFNC:           DC.W 0
SAVE_STK:       DC.L 0
TXT_IS_HERE:    DC.L TXT_SCROLL
COUNTER:        DC.L 0
                EVEN
nowe_k:			dc.w $0,$051,$777,$110,$100,$010,$020,$021,$030,$031,$040,$041,$042,$777,$070,$061
kolory_zm:		dc.l 0
underline:		dc.w 0
kolumna_2		dc.w 0
credits13:		dc.b "--------------------------------------------------------",$ff
				even
credits1:		dc.b "        (((((  (((((( ((((((       ((   (( (((((",$ff
				even
credits2:		dc.b "       ((      ((       ((         ((   (( ((  ((",$ff
				even
credits3:		dc.b "        ((((   ((((     ((  (((((( ((   (( (((((",$ff
				even
credits4:		dc.b "           ((  ((       ((         ((   (( ((",$ff
				even
credits5:		dc.b "       (((((   ((((((   ((          (((((  ((",$ff
				even
credits6:		dc.b "--------------------------------------------------------",$ff
				even
credits7:		dc.b "              The Voice zine 5 - Select module",$ff
				even
credits8:		dc.b " ",$ff
				even
credits9:		dc.b "                F1. Paper-in by RFR/ILLUSIONS",$ff
				even
credits10:		dc.b "                F2. Vector (default)",$ff
				even
credits11:		dc.b "                F3. Smoth criminal",$ff
				even
credits12:		dc.b "                F4. Amiga conversion",$ff
				even
dla_stron:		dcb.l 0,60
                EVEN
				dc.l 0				
Tabela_stron:	dcb.l 0,100
				
REPLAY_ROT:     INCBIN 'TRACKER.ROT'
                EVEN

PANEL:			incbin 'panani21.pi1'
				even
fonty_poch:		
FONTY:          INCBIN 'SYS_pol1.FNT'
                EVEN
FONTY1:         INCBIN 'sys1.FNT'
                EVEN
PUSTO:
                DC.B $0D,$0A
                DC.B $0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B "                                                                                ",$0D,$0A
                DC.B $FF
                EVEN
TV_TXT:
                DC.B "                           The Voice numer 5 / 1994-01-30  ",$FF
                EVEN

TEXT:

         		incbin 'MENU.doc'
                DC.B $FF
    EVEN
dlaczego
                INCBIN 'dlaczego.asc'
                DC.B $FF
	even
efik_15:
                INCBIN 'flipo.asc'
                DC.B $FF
	even
falc:
                INCBIN 'sfalcon.asc'
                DC.B $FF
	even
scena:
*				dc.b 'PI'		; gdzie obr punk(collage)
*				dc.l porno+34   ; uwzgl. poz x, y
*				dc.w 6*4		;+1
*				dc.w 0	; x	w slowach(max. 40)
*				dc.w 17+9*4+1  	; y
*				dc.w (267/16)	; szer w slowach 16*2 np. 10=10*16
*				dc.w 124		    ; wysokosc
*				dc.l 'jest'

*				dc.l dupam+34   ; uwzgl. poz x, y
*				dc.w 11*4		;+1
*				dc.w 0*4	; x	w slowach(max. 40)
*				dc.w 17+10  	; y
*				dc.w (220/16)	; szer w slowach 16*2 np. 10=10*16
*				dc.w 134		    ; wysokosc
*				dc.l 'jest'

*				dc.l dupam+34+(238/8)*2+2   ; uwzgl. poz x, y
*				dc.w 13*4		;+1
*				dc.w 80	; x	w slowach(max. 40)
**				dc.w 17+4*9+1  	; y
*				dc.w (316/16)	; szer w slowach 16*2 np. 10=10*16
*				dc.w 115		    ; wysokosc

				incbin 'Acc.asc'

                DC.B $FF
	even
ACC_real:
                INCBIN 'realtime.asc'
                DC.B $FF
	even
SIa:
				incbin 'real_pro.asc'
                DC.B $FF
	even
miklesz:
				incbin 'st.asc'
                DC.B $FF
	even
marchew:
				incbin 'Marchew.asc'
                DC.B $FF
	even
opw2
*				dc.b 'PI'		; gdzie obr punk(mr.byte)
*				dc.l porno+34+128*160   ; uwzgl. poz x, y
*				dc.w 0*4		;+1
*				dc.w 0*4	; x	w slowach(max. 40)
*				dc.w 43  	; y
*				dc.w (75/8)	; szer w slowach 16*2 np. 10=10*16
*				dc.w 72		    ; wysokosc
*				dc.l 'nie '
				
				incbin "op2.asc"
                DC.B $FF
	even
charty:			incbin 'delirka.asc'
				dc.b $ff
	even
opw1			incbin "op1.asc"
                DC.B $FF
	even
Bajtek			incbin "mojegry.asc"
                DC.B $FF
	even
army			incbin "army_wyw.asc"
                DC.B $FF
	even
paskud:
				incbin "paskud.asc"
                DC.B $FF
	even
modem:
				incbin 'modem.asc'
                DC.B $FF
	even
news:
		incbin stf_news.asc
		dc.b $ff
	even
lista_acc
*				dc.b 'PI'		; gdzie obr punk(mr.byte)

*				dc.l porno+34+(160/4)*2+95*160   ; uwzgl. poz x, y
*				dc.w 16*4		;+1
*				dc.w 1*4 ;(160/8)*4	; x	w slowach(max. 40)
*				dc.w 188-104  	; y
*				dc.w (140/8)	; szer w slowach 16*2 np. 10=10*16
*				dc.w 102		    ; wysokosc
*				dc.l 'jest'

*				dc.l porno+34+(160/4)*2   ; uwzgl. poz x, y
*				dc.w 21*4		;+1
*				dc.w ((196-20)/8)*4	; x	w slowach(max. 40)
*				dc.w 188-95  	; y
*				dc.w (144/8)-1	; szer w slowach 16*2 np. 10=10*16
*				dc.w 95		    ; wysokosc
*				dc.l 'nie '

				incbin listaacc.asc
                DC.B $FF
	even
jokes
				incbin joke_tv5.asc
                DC.B $FF
	even

FIRST1:
                DC.B $0D,$0A
                DC.B $0D,$0A
			*incbin first.doc
                DC.B $FF
			even
warczak:
				incbin warczak.asc
                DC.B $FF
	even
wstep:
				incbin wstep.asc
                DC.B $FF
	even
demo:
*				dc.b 'PI'
*				dc.l porno+34   ; uwzgl. poz
*				dc.w 1*4		;+1
*				dc.w 0*4			; x	w slowach(max. 40)
*				dc.w 18			; y
*				dc.w 21			; szer w slowach 16*2 np. 10=10*16
*				dc.w 169		; wysokosc
*				dc.l 'nie '

				incbin 'wosp.asc'
				dc.b $ff
    EVEN
tfte_l
porno
	*			incbin save\tfte.pi2         ;tv42por.pi2
	dcb.b 0,160
	even
dupam*
				*incbin thevoic2.pi1        ;tv4_marh.pi2
                DC.L 0
NAP_STRONA:
                DC.B "  Strona:       z                          (c) The Voice #5/ T.F.T.E. & Friends ",$FF
                EVEN


NR_STRONY:
                DC.B "001",$FF
                DC.B "002",$FF
                DC.B "003",$FF
                dc.b "004",$FF
                DC.B "005",$FF
                DC.B "006",$FF
                DC.B "007",$FF
                DC.B "008",$FF
                DC.B "009",$FF
                DC.B "010",$FF
                DC.B "011",$FF
                DC.B "012",$FF
                DC.B "013",$FF
                DC.B "014",$FF
                DC.B "015",$FF
                DC.B "016",$FF
                DC.B "017",$FF
                DC.B "018",$FF
                DC.B "019",$FF
                DC.B "020",$FF
                DC.B "021",$FF
                DC.B "022",$FF
                DC.B "023",$FF
                DC.B "024",$FF
                DC.B "025",$FF
                DC.B "026",$FF
                DC.B "027",$FF
                DC.B "028",$FF
                DC.B "029",$FF
                DC.B "030",$FF
                DC.B "031",$FF
                DC.B "032",$FF
                DC.B "033",$FF
                DC.B "034",$FF
                DC.B "035",$FF
                DC.B "036",$FF
                DC.B "037",$FF
                DC.B "038",$FF
                DC.B "039",$FF
                DC.B "040",$FF
                DC.B "041",$FF
                DC.B "042",$FF
                DC.B "043",$FF
                DC.B "044",$FF
                DC.B "045",$FF
                DC.B "046",$FF
                DC.B "047",$FF
                DC.B "048",$FF
                DC.B "049",$FF
                DC.B "050",$FF
                DC.B "051",$FF
                DC.B "052",$FF
                DC.B "053",$FF
                DC.B "054",$FF
                DC.B "055",$FF
                DC.B "056",$FF
                DC.B "057",$FF
                DC.B "058",$FF
                DC.B "059",$FF
                DC.B "060",$FF
                DC.B "061",$FF
                EVEN

TXT_SCROLL:
                incbin 'scr.asc'
                dc.b $ff
                EVEN
*MODULE:         incbin mod.mod *'scoopex.mod' *ds.b 135*1024
	even
	SECTION BSS

PANEL1:			ds.w 17
automat:		ds.w 1
pages:			ds.l 1
				even
dta				ds.b 46
adres_k_stron:	ds.l 1
ZAP70:          DS.L 1
ZAP120:         DS.L 1
SPIZARNIA:      DS.L 20
SCHOWAJ:        DS.L 20
SCHOWAJ1:       DS.L 20
SAVE_FF8240:    DS.L 20
SKLAD:          DS.B 160*10
MFPZAP:         DS.B $20
love_a:			ds.l 16
zap_d0:			ds.l 1
I_like_milk		ds.l 9
old70_1:		ds.l 1
sh_na_okno:		ds.l 3*14*200
BOOT1:          DS.B 1024*2
                EVEN
MODULE:         *incbin mod.mod *'scoopex.mod' *ds.b 135*1024
	even
	end

