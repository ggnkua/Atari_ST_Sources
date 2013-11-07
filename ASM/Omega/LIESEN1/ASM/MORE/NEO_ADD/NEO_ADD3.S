***   Made By Martin Liesen 1992
***********************************************    Dummy Init
rem             EQU 0
                >PART 'NeoShower'
                IF rem=1
                pea     Sture(PC)
                move.w  #38,-(A7)
                trap    #14
                clr.w   -(A7)
                trap    #1

Sture:          move.b  #0,$FFFF8260.w
                move.w  #37,-(A7)
                trap    #14
                move.b  #0,$FFFF820A.w
                move.w  #37,-(A7)
                trap    #14
                move.w  #37,-(A7)
                trap    #14
                move.b  #2,$FFFF820A.w
                move.w  #2,-(A7)
                trap    #14
                addq.l  #8,A7
                movea.l D0,A0
                lea     bild+128(PC),A1
                move.w  #7999,D0
.mupp:          move.l  (A1)+,(A0)+
                dbra    D0,.mupp
                movem.l bild+4(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w
                move.w  #7,-(A7)
                trap    #1
                addq.l  #2,A7
                move.b  #2,$FFFF8260.w
                rts
                PATH 'A:\'
bild:                                   *   IBYTES 'FLORIAN1.NEO'
                IBYTES 'FLORIAN1.NEO'
                ENDC
                ENDPART

                >PART 'INIT'
                pea     testifoc(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
noppa:          bsr     begin
endnop:         clr.w   -(A7)
                trap    #1
                ENDPART
testifoc:       >PART 'TEST IF OMEGACOMMAND EXIST'
                movea.l $00000098.w,A0
                cmpi.l  #"ILAK",2(A0)
                bne.s   oops
                cmpi.w  #$0105,6(A0)
                blo.s   oops
                rts
oops:           lea     noppa(PC),A0
                lea     endnop(PC),A1
nops:           move.w  #$4E71,(A0)+
                cmpa.l  A1,A0
                bne.s   nops
                pea     nooc(PC)
                move.w  #9,-(A7)
                trap    #1
                move.w  #7,-(A7)
                trap    #1
                addq.l  #8,A7
                rts
nooc:           DC.B "ESorry!! You must have Omega Commands V1.05 or better
"
                DC.B "installed in memory...",0
                EVEN
                ENDPART

***********************************************    Program Start

begin:          >PART 'SETUP'
                pea     b2(PC)
                move.w  #38,-(A7)
                trap    #14
                addq.l  #6,A7
                rts
                ENDPART

b2:             >PART 'Super start'
                move.l  A7,savestack

                movem.l $FFFF8240.w,D0-D7
                movem.l D0-D7,old_pal
                move.b  $FFFF8260.w,old_rez
                move.b  $FFFF820A.w,old_hz

                moveq   #2,D0
                trap    #6
                move.l  A0,diskaccess

                lea     stack(PC),A7
                pea     inittext(PC)
                move.w  #9,-(A7)        ; init text
                trap    #1
                addq.l  #6,A7
                ENDPART
                >PART 'Questions'
.again1:        pea     fil1(PC)
                move.w  #9,-(A7)        ; init text
                trap    #1
                addq.l  #6,A7

                pea     input(PC)       ; FIL 1
                move.w  #10,-(A7)
                trap    #1
                addq.l  #6,A7
                tst.b   input+1
                beq     back

                movea.l diskaccess(PC),A0
                move.w  #0,2(A0)
                move.l  #input+2,6(A0)
                move.l  #c,10(A0)
                move.l  #-1,14(A0)
                move.l  #32128,18(A0)
                move.w  #0,24(A0)
                move.w  #0,42(A0)
                jsr     (A0)
                tst.w   22(A0)
                bne.s   .again1

                pea     just_a_min(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                lea     a,A0
                bsr     c_2_fast


.again2:        pea     fil2(PC)        ; FIL 2
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7

                pea     input(PC)
                move.w  #10,-(A7)
                trap    #1
                addq.l  #6,A7
                tst.b   input+1
                beq     back

                movea.l diskaccess(PC),A0
                move.w  #0,2(A0)
                move.l  #input+2,6(A0)
                move.l  #c,10(A0)
                move.l  #-1,14(A0)
                move.l  #32128,18(A0)
                move.w  #0,24(A0)
                move.w  #0,42(A0)
                jsr     (A0)
                tst.w   22(A0)
                bne.s   .again2

                pea     just_a_min(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                lea     b,A0
                bsr     c_2_fast


.again4:        cmpi.b  #2,old_rez      ; Mono?   Force?
                bne     display_choose
                pea     force(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                pea     input(PC)
                move.w  #10,-(A7)
                trap    #1
                addq.l  #6,A7
                tst.b   input+1
                beq     back
                cmpi.b  #'J',input+2
                beq.s   display_choose
                cmpi.b  #'j',input+2
                beq.s   display_choose
                cmpi.b  #'N',input+2
                beq.s   back
                cmpi.b  #'n',input+2
                bne.s   .again4
                bra.s   back

                ENDPART


savea:          >PART 'SPARA NER SKITEN'
                pea     fil3(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7

                pea     input(PC)
                move.w  #10,-(A7)       ; name of data file to save
                trap    #1
                addq.l  #6,A7
                tst.b   input+1
                beq.s   back


                movea.l diskaccess(PC),A0
                move.w  #1,2(A0)
                move.l  #input+2,6(A0)
                move.l  #c,10(A0)
                move.l  #-1,14(A0)
                move.l  #32128,18(A0)
                move.w  #0,24(A0)
                move.w  #0,38(A0)
                jsr     (A0)

                ENDPART

back:           >PART 'RETURN TO CALLER'
                movea.l savestack(PC),A7
                rts
                ENDPART

display_choose: >PART 'Show Pic and set intensity'

                bsr     setup_col

                move.l  #5,plusa
                move.l  #0,a_plusa
                move.l  #0,b_plusa
                move.w  #0,method

.dloop:         lea     $FFFF8240.w,A0
                moveq   #7,D0
.hump:          eori.l  #$07000700,(A0)+
                dbra    D0,.hump
                bsr     calculate
                movem.l c+4(PC),D0-D7
                movem.l D0-D7,$FFFF8240.w
                move.w  #2,-(A7)
                trap    #14
                addq.l  #2,A7
                movea.l D0,A0
                lea     c+128(PC),A1
                move.w  #7999,D0
.scrcopy:       move.l  (A1)+,(A0)+
                dbra    D0,.scrcopy
.kloop:         move.w  #7,-(A7)
                trap    #1
                addq.l  #2,A7
                move.l  D0,D1
                swap    D1

                cmp.b   #$62,D1
                bne.s   .NotHelp
                bsr     restore
                pea     help_text(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                move.w  #7,-(A7)
                trap    #1
                addq.l  #2,A7
                move.l  D0,D1
                swap    D1
                movem.l D0-D1,-(A7)
                bsr     setup_col
                movem.l (A7)+,D0-D1


.NotHelp:       cmp.b   #13,D0
                beq     .klar
                cmp.b   #'A',D0
                blo.s   .notBIG
                cmp.b   #'Z',D0
                bhi.s   .notBIG
                add.b   #'a'-'A',D0
.notBIG:
                cmp.b   #$3B,D1         ; function keys
                blo.s   .notFx
                cmp.b   #$003B+3,D1
                bhi.s   .notFx
                sub.b   #$3B,D1
                move.b  D1,method+1
                bra     .dloop

.notFx:         lea     plusa+2(PC),A0
                cmp.b   #"+",D0
                beq     .plus_key1
                cmp.b   #"-",D0
                beq     .minus_key1
                cmp.b   #"6",D0
                beq     .plus_key2
                cmp.b   #"9",D0
                beq     .minus_key2
                cmp.b   #"5",D0
                beq     .plus_key3
                cmp.b   #"8",D0
                beq     .minus_key3
                cmp.b   #"4",D0
                beq     .plus_key4
                cmp.b   #"7",D0
                beq     .minus_key4

                lea     a_plusa+2(PC),A0
                cmp.b   #"f",D0
                beq.s   .plus_key1
                cmp.b   #"r",D0
                beq.s   .minus_key1
                cmp.b   #"d",D0
                beq.s   .plus_key2
                cmp.b   #"e",D0
                beq.s   .minus_key2
                cmp.b   #"s",D0
                beq.s   .plus_key3
                cmp.b   #"w",D0
                beq.s   .minus_key3
                cmp.b   #"a",D0
                beq.s   .plus_key4
                cmp.b   #"q",D0
                beq.s   .minus_key4

                lea     b_plusa+2(PC),A0
                cmp.b   #"k",D0
                beq.s   .plus_key1
                cmp.b   #"i",D0
                beq.s   .minus_key1
                cmp.b   #"j",D0
                beq.s   .plus_key2
                cmp.b   #"u",D0
                beq.s   .minus_key2
                cmp.b   #"h",D0
                beq.s   .plus_key3
                cmp.b   #"y",D0
                beq.s   .minus_key3
                cmp.b   #"g",D0
                beq.s   .plus_key4
                cmp.b   #"t",D0
                beq.s   .minus_key4
                bra     .kloop

.plus_key1:     subi.w  #1,(A0)
                bra     .dloop
.minus_key1:    addi.w  #1,(A0)
                bra     .dloop
.plus_key2:     subi.w  #3,plusa
                bra     .dloop
.minus_key2:    addi.w  #3,(A0)
                bra     .dloop
.plus_key3:     subi.w  #6,(A0)
                bra     .dloop
.minus_key3:    addi.w  #6,(A0)
                bra     .dloop
.plus_key4:     subi.w  #10,(A0)
                bra     .dloop
.minus_key4:    addi.w  #10,(A0)
                bra     .dloop


.klar:          bsr.s   restore
                bra     savea

setup_col:      move.w  #0,-(A7)        ; Set COLOR safely
                pea     -1
                pea     -1
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7
                move.w  #37,-(A7)
                trap    #14
                addq.l  #2,A7
                bclr    #1,$FFFF820A.w
                move.w  #37,-(A7)
                trap    #14
                addq.l  #2,A7
                bset    #1,$FFFF820A.w
                move.w  #37,-(A7)
                trap    #14
                addq.l  #2,A7
*                move.b  old_hz(PC),$FFFF820A.w
                rts

restore:        movem.l old_pal(PC),D0-D7 ; restore col & rez
                movem.l D0-D7,$FFFF8240.w
                moveq   #0,D0
                move.b  old_rez(PC),D0
                move.w  D0,-(A7)
                pea     -1
                pea     -1
                move.w  #5,-(A7)
                trap    #14
                lea     12(A7),A7
                rts

                ENDPART

calculate:      >PART 'Utf”r ber„kning'

                lea     a,A0
                lea     b,A1
                lea     c+128(PC),A2

                lea     _method_tab(PC),A3
                move.w  method(PC),D0
                add.w   D0,D0
                add.w   D0,D0
                movea.l 0(A3,D0.w),A3

                move.w  #20*200-1,D6
.LoopWord:      moveq   #15,D7
.LoopBit:
                move.b  (A0)+,D0
                sub.b   a_plusa+3(PC),D0
                bmi.s   .Karin1
                cmp.b   #$10,D0
                blt.s   .Sofie1
                moveq   #$0F,D0
                bra.s   .Sofie1
.Karin1:        moveq   #0,D0
.Sofie1:
                move.b  (A1)+,D1
                sub.b   b_plusa+3(PC),D1
                bmi.s   .Karin2
                cmp.b   #$10,D1
                blt.s   .Sofie2
                moveq   #$0F,D1
                bra.s   .Sofie2
.Karin2:        moveq   #0,D1
.Sofie2:
                jsr     (A3)

                sub.b   plusa+3(PC),D0
                bmi.s   .Karin3
                cmp.b   #$10,D0         ; filter
                blt.s   .Sofie3
                moveq   #$0F,D0
                bra.s   .Sofie3
.Karin3:        moveq   #0,D0
.Sofie3:
                roxr.b  #1,D0           ; in i dest
                roxl.w  #1,D2
                roxr.b  #1,D0
                roxl.w  #1,D3
                roxr.b  #1,D0
                roxl.w  #1,D4
                roxr.b  #1,D0
                roxl.w  #1,D5

                dbra    D7,.LoopBit

                move.w  D2,(A2)+
                move.w  D3,(A2)+
                move.w  D4,(A2)+
                move.w  D5,(A2)+

                dbra    D6,.LoopWord
                rts

a_plus_b:       add.b   D1,D0
                rts
a_minus_b:      sub.b   D0,D1
                exg     D0,D1
                rts
b_minus_a:      sub.b   D1,D0
                rts
a_plus_b_div_2: add.b   D1,D0
                lsl.b   #1,D0
                rts

_method_tab:    DC.L a_plus_b
                DC.L a_minus_b
                DC.L b_minus_a
                DC.L a_plus_b_div_2

                ENDPART


c_2_fast:       >PART 'Make fast picture format'
* pic loaded as neo at C
* A0=Dest (64000 bytes)
                lea     c+128(PC),A1
                move.w  #200*20-1,D5
.looplot:       moveq   #15,D4
                movem.w (A1)+,D0-D3
.loop16:
                moveq   #0,D7           ; get add1
                roxl.w  #1,D3
                roxl.w  #1,D7
                roxl.w  #1,D2
                roxl.w  #1,D7
                roxl.w  #1,D1
                roxl.w  #1,D7
                roxl.w  #1,D0
                roxl.w  #1,D7

                move.b  D7,(A0)+
                dbra    D4,.loop16
                dbra    D5,.looplot
                rts
                ENDPART

************************************************   Procedures
                IF rem=1
shex_hex:       >PART 'CONVERT Shex=>hex'
* converts hex string to hex digits   klarar + & minus!!!
* If -$1000 in longword in d0, Digit not aloweed
* if -$2000 there was nothing to convert...
                movem.l D1-D3/A0-A2,-(A7)
                lea     input+1(PC),A0
                lea     hextaltab(PC),A1
                move.l  #-$00002000,D0
                moveq   #0,D1
                move.b  (A0)+,D1
                tst.b   D1
                beq.s   skipshex_hex
                moveq   #0,D0
                subq.w  #1,D1
                cmpi.b  #'-',(A0)
                bne.s   getem_all
                addq.l  #1,A0
                subq.w  #1,D1
getem_all:      move.b  (A0)+,D2
                movea.l A1,A2
                moveq   #0,D3
findhim:        cmp.b   (A2)+,D2
                beq.s   hexcharfound
                addq.w  #1,D3
                tst.b   D2
                bne.s   findhim
                move.l  #-$00001000,D0
                bra.s   skipshex_hex
hexcharfound:   and.w   #$000F,D3
                lsl.l   #4,D0
                or.l    D3,D0
                dbra    D1,getem_all

                cmpi.b  #'-',input+2
                bne.s   skipshex_hex
                neg.l   D0

skipshex_hex:   movem.l (A7)+,D1-D3/A0-A2
                rts
                ENDPART
hex_shex4:      >PART 'CONVERT hex=>Shex4'
* Converts a word to 4 character ascII
* A0=address where digts shall be saved
* d0=word to put at a0
                movem.l D0-D2/A0-A1,-(A7)
                lea     4(A0),A0
                moveq   #3,D2
                lea     hextaltab(PC),A1

do_four:        move.w  D0,D1
                lsr.w   #4,D0
                and.w   #$000F,D1
                move.b  0(A1,D1.w),-(A0)
                dbra    D2,do_four

                movem.l (A7)+,D0-D2/A0-A1
                rts
                ENDPART
                >PART 'HEXTAB'
hextaltab:      DC.B "0123456789ABCDEF"
                DC.B "0123456789abcdef",0
                EVEN
                ENDPART
                ENDC
************************************************   Data

e_d0:           DS.L 1
e_d1:           DS.L 1

savestack:      DS.L 1
diskaccess:     DS.L 1

                >PART 'TEXT'
inittext:
                DC.B 27,"E",27,"e",27,"pBild Plusa v1.20",27,"q",13,10
                DC.B "Program av Martin Liesen (Omega) 1992",13,10,10
                DC.B "Orsak till fortsatt existens:  Sofie & Karin",13,10,10,10
                DC.B "Detta program anv„nds f”r att l„gg ihop tv† bilder med konstant f„rg",13,10
                DC.B "intensitet. Man kan addera, subtrahera (och lite annat) bilderna f”r",13,10
                DC.B "att f† s† bra effekt som m”jligt. (rekommenderar HELP knappen n„r du v„l",13,10
                DC.B "laddat in bilderna).",13,10,10,10,10,0

just_a_min:     DC.B 13,10,"Ett ”gonblick...",0
fil1:           DC.B 13,10
                DC.B "Namn p† in-NEO-fil 1 :",0

fil2:           DC.B 13,10
                DC.B "Namn p† in-NEO-fil 2 :",0
fil3:           DC.B 27,"E"
                DC.B "(tom rad ifall du inte vill spara)",13,10
                DC.B "Spara ny bild som (NEO):",0
force:          DC.B 13,10
                DC.B "Har du Liesen's HIGH FORCE COLOR i minnet (J/N) ?",0


help_text:      DC.B 27,"E"
                DC.B "Martin Liesen 1992",13,10
                DC.B "Tanken „r ifr†n Johannes S”derqvist och UNISPEC..",13,10,10
                DC.B "F1   Bild1 + Bild2",13,10
                DC.B "F2   Bild1 - Bild2",13,10
                DC.B "F3   Bild2 - Bild1",13,10
                DC.B "F4   (Bild1 + Bild2) / 2",13,10,10,10
                DC.B "QWER     TYUI     789-      (Minska f„rg)",13,10
                DC.B "ASDF     GHJK     456+      (™ka f„rg)",13,10,10
                DC.B "(Bild1)  (Bild2)  (Global)",13,10,10
                DC.B "Observera att f”r„ndrings graden ”kar †t v„nster (A>S>D>f)",13,10,10,10
                DC.B "Enter         - Spara bild (eller bara avsluta)",13,10
                DC.B "Annan knapp   - (Space) se p† bilden igen",0

                ENDPART

plusa:          DS.L 1
a_plusa:        DS.L 1
b_plusa:        DS.L 1
method:         DC.W 1          ; 0=Add  1=Sub  2=Mid

old_pal:        DS.W 16
old_rez:        DS.B 1
old_hz:         DS.B 1
input:          DC.B 60
                DC.B 0
                DS.B 60
                BSS
                DS.B 256
stack:

c:              DS.B 32128
a:              DS.B 64000
b:              DS.B 64000
                END

