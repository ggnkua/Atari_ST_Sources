***************************************************************************
*              Programowanie w Assemblerze ~ Quast Magazyn 8              *
*-------------------------------------------------------------------------*
* nazwa      :  Krotki program anty-wirusowy. Zapisuje na dysk bootsektor *
* autor      :  STrych / TFTE                                             *
* inne uwagi :  Uwaga !!! Kasuje 1 sektor. Uzywac tylko do dyskow startu- *
*               jacych z TOSa lub z AUTO. Wyjscie z programu CTRL-C       *
***************************************************************************

                move.w  #$20,-(SP)
                trap    #1
                addq.l  #2,SP
                bra     F
                clr.w   (SP)
                trap    #1
S:
START:
                clr.w   $FF8242
                move.l  $0426.w,D0
                cmp.l   #$31415926,D0
                beq.s   VIRUS
                movea.l $042A.w,A0
                movea.l A0,A4
                lea     $10(A0),A0
                move.l  (A0)+,D0
                cmp.l   #$12123456,D0
                beq.s   VIRUS
                adda.l  #$14,A4
                move.l  (A4),D0
                cmp.l   #$12123456,D0
                beq.s   VIRUS
                move.l  $0472.w,D0
                move.l  $04F2.w,D1
                movea.l D0,A0
                cmpi.l  #$6072606A,(A0)
                beq.s   NO_VIR
                cmp.l   D1,D0
                bls.s   VIRUS
NO_VIR:
*virus:
                pea     TXT(PC)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
                rts
*no_vir:
VIRUS:
                DC.W $A000      ; line_a
                moveq   #1*4,D0         ; numer fontu=1
                lea     FONT(PC),A3
                movea.l 0(A1,D0.w),A1
                adda.l  #604,A1         ; opuscic naglowek fontu
                move.l  A1,(A3)         ; wektor fontu systemowego w "font"
RUN:
                lea     TEKST(PC),A6
LOO:            clr.l   D1
                move.b  (A6)+,D1
                cmpi.b  #0,D1
                bne.s   NO0
                lea     TEKST(PC),A6
                move.b  (A0)+,D1

NO0:            move.w  #7,D6
L0:             move.w  #1,D4
L1:             movea.l $044E,A3        ; w A3 adres ekranu
                adda.l  #$2F80,A3       ; plus ofset pozycji
                movea.l FONT(PC),A2
                andi.l  #$FF,D1
                adda.w  D1,A2
                move.w  #7,D7
L3FE5E:         move.b  (A2),D2
                lsr.w   D6,D2
                andi.b  #1,D2
                move.w  #5,D5
L3FE6A:         andi.b  #$FE,$99(A3)
                or.b    D2,$99(A3)
                adda.l  #$A0,A3
                dbra    D5,L3FE6A
                adda.l  #$0100,A2
                dbra    D7,L3FE5E
                bsr.s   PRZESUN
                dbra    D4,L1
                dbra    D6,L0
                bra.s   LOO             ; jezeli nie nacisniety

*       MOVE.W  #7,-(SP)                                ; zczytaj klawisz
*       TRAP    #1
*       ADDQ.L  #6,SP

                rts

PRZESUN:
                move.w  #$25,-(SP)      ; wsync
                trap    #14
                addq.l  #2,SP
                movea.l $044E,A0        ; przesuw
                adda.l  #$4D78,A0
                movea.l A0,A1
                move.w  #$03BF,D0
SUW:            roxl.w  (A0)
                subq.w  #8,A0
                dbra    D0,SUW
                rts
FONT:           DC.L 1          ; wektor fontu systemowego ($FD4388)
TXT:
                DC.B 13,"                        TFTE Antyvirus",13,10
                DC.B "  	                   No Virus",0
                EVEN
TEKST:
                DC.B " Virus in memory !!!   "
                DC.B 0
                DC.B " This anty-virus was coded by STRych of TFTE. "


F:
FINISH:
                movea.l $044E,A0
                move.l  #$8000,D0
FUK:
                clr.l   (A0)+
                dbra    D0,FUK
                move.l  #TEXT,-(SP)
                move.w  #9,-(SP)
                trap    #1
                addq.l  #6,SP
KLAWISZ:
                move.w  #1,-(SP)

                trap    #1
                addq.l  #2,SP

                move.w  #1,-(SP)
                move.w  #0,-(SP)
                move.w  #0,-(SP)
                move.w  #1,-(SP)
                move.w  #0,-(SP)
                clr.l   -(SP)
                lea     BUFOR(PC),A5
                movea.l A5,A6
                move.l  A5,-(SP)
                move.w  #8,-(SP)
                trap    #14
                adda.l  #20,SP
                tst.w   D0
                bmi.s   ERROR

                move.w  #$601C,(A5)
                adda.l  #$1E,A5
                lea     START(PC),A4
                lea     FINISH(PC),A3
LOOP4:
                move.w  (A4)+,(A5)+
                cmpa.l  A3,A4
                blt.s   LOOP4
                movea.l A6,A5
                move.w  #$FE,D1
                move.w  #$1234,D0
LOOP5:
                sub.w   (A5)+,D0
                dbra    D1,LOOP5
                move.w  D0,(A5)

                move.w  #1,-(SP)
                move.w  #0,-(SP)
                move.w  #0,-(SP)
                move.w  #1,-(SP)
                move.w  #0,-(SP)
                clr.l   -(SP)
                lea     BUFOR(PC),A5
                move.l  A5,-(SP)
                move.w  #9,-(SP)
                trap    #14
                adda.l  #20,SP

                tst.w   D0
                bmi.s   ERROR

                bra     FINISH
ERROR:
                pea     TXT1(PC)
                move.w  #$09,-(SP)
                trap    #1
                addq.l  #6,SP


                bra     KLAWISZ
EXIT:
                clr.w   (SP)
                trap    #1
TXT1:           DC.B 13," Blad dysku !!!!!",13,10
                DC.B " Nacisnij klawisz !!!",$0A,$0D,0
                EVEN
TEXT
                DC.B 27,"E",27,"H",13," (c) '93 TFTE",13,10
                DC.B 13,10
                DC.B " Anty-virus coded by STRych ",13,10
                DC.B 13,10
                DC.B 13,10
                DC.B 13,10
                DC.B " Wloz odbezpieczony dysk i nacisnij klawisz !!!",13,10,0
                EVEN

BUFOR:
                DS.L 1000
                END
