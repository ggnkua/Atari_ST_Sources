***   Made By Martin Liesen 1992
***********************************************    Dummy Init
turk            EQU 1
                >PART 'NeoShower'
                IF turk=0
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
                PATH 'K:\'
bild:                                   *   IBYTES 'FLORIAN1.NEO'
                IBYTES 'TESTA.NEO'
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
                move.l  A7,savestack

                moveq   #2,D0
                trap    #6
                move.l  A0,diskaccess

                lea     stack(PC),A7
                pea     inittext(PC)
                move.w  #9,-(A7)        ; init text
                trap    #1
                addq.l  #6,A7
                ENDPART
                >PART 'QUESTIONS'
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
                move.l  #a,10(A0)
                move.l  #-1,14(A0)
                move.l  #32128,18(A0)
                move.w  #0,24(A0)
                move.w  #0,42(A0)
                jsr     (A0)
                tst.w   22(A0)
                bne.s   .again1


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
                move.l  #b,10(A0)
                move.l  #-1,14(A0)
                move.l  #32128,18(A0)
                move.w  #0,24(A0)
                move.w  #0,42(A0)
                jsr     (A0)
                tst.w   22(A0)
                bne.s   .again2

.again3:        pea     addera(PC)      ; Addera med..
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7

                pea     input(PC)
                move.w  #10,-(A7)
                trap    #1
                addq.l  #6,A7
                tst.b   input+1
                beq     back
                bsr     shex_hex
                move.l  D0,plusa
                cmp.l   #-$00001000,D0
                beq.s   .again3
                cmp.l   #-$00002000,D0
                beq.s   .again3


                ENDPART

                PART 'Utf”r ber„kning'
                lea     a(PC),A0
                lea     c,A1
                move.w  #128/4-1,D0
.copy:          move.l  (A0)+,(A1)+
                dbra    D0,.copy

                lea     a+128(PC),A0
                lea     b+128,A1
                lea     c+128,A2

                move.w  #20*200-1,e_d1

.LoopWord:      move.l  (A0)+,D0
                move.l  (A0)+,D1
                move.l  (A1)+,D2
                move.l  (A1)+,D3

                move.w  #16,e_d0

.LoopBit:       moveq   #0,D7           ; get add1
                roxl.w  #1,D1
                roxl.w  #1,D7
                swap    D1
                roxl.w  #1,D1
                roxl.w  #1,D7
                swap    D1
                roxl.w  #1,D0
                roxl.w  #1,D7
                swap    D0
                roxl.w  #1,D0
                roxl.w  #1,D7
                swap    D0

                moveq   #0,D6           ; get add2
                roxl.w  #1,D3
                roxl.w  #1,D6
                swap    D3
                roxl.w  #1,D3
                roxl.w  #1,D6
                swap    D3
                roxl.w  #1,D2
                roxl.w  #1,D6
                swap    D2
                roxl.w  #1,D2
                roxl.w  #1,D6
                swap    D2

                add.w   D6,D7           ; add1 + add2 - v„rde
                sub.w   plusa+2(PC),D7
                bmi.s   .toolow
                cmp.w   #$0010,D7       ; filter
                blt.s   .Roger1
                moveq   #$0F,D7
                bra.s   .Roger1
.toolow:        moveq   #0,D7
.Roger1:

                roxr.w  #1,D7           ; in i dest
                swap    D4
                roxl.w  #1,D4
                roxr.w  #1,D7
                swap    D4
                roxl.w  #1,D4
                roxr.w  #1,D7
                swap    D5
                roxl.w  #1,D5
                roxr.w  #1,D7
                swap    D5
                roxl.w  #1,D5

                subi.w  #1,e_d0
                bne.s   .LoopBit
                move.l  D4,(A2)+
                move.l  D5,(A2)+

                subi.w  #1,e_d1
                bne     .LoopWord

                ENDPART

                >PART 'SPARA NER SKITEN'
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

************************************************   Procedures

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

************************************************   Data

e_d0:           DS.L 1
e_d1:           DS.L 1

savestack:      DS.L 1
diskaccess:     DS.L 1

                >PART 'INIT TEXT'
inittext:
                DC.B 27,"E",10,27,"e",27,"pBild Plusa",27,"q",13,10
                DC.B "Program av Liesen of Omega 1992 (1-2 hours)",13,10,10
                DC.B "Orsak till fortsatt existens:  Sofie  & Karin",13,10,10,10
                DC.B "Tar tv† NEO (!) bilder och plusar ihop f„rgerna och tar minus ett valt",13,10
                DC.B "antal f„rger (f”r att f”rhindra att bilden blir alltf”r ljus).",13,10,10,0
fil1:           DC.B 13,10
                DC.B "Namn p† in-NEO-fil 1 :",0

fil2:           DC.B 13,10
                DC.B "Namn p† in-NEO-fil 2 :",0
fil3:           DC.B 13,10
                DC.B "Spara ny bild som    :",0
addera:         DC.B 13,10,10
                DC.B "Nu skall du ange hur m†nga f„renheter du vill minska med, problemet „r",13,10
                DC.B "att jag „r s† lat s† jag accepterar bara Hexadecimal tal.",13,10
                DC.B "Hexadecimalt fungerar s†h„r:    X*16 +Y   d„r X&Y „r tal mellan 0 och 15",13,10
                DC.B "fast dom representeras utav 0-F (eller 0-f)   N„r du skriver talet beh”ver",13,10
                DC.B "du bara skriva XY (dom hexadecimala siffrorna).",13,10
                DC.B "H„r f”ljer n†gra exempel:",13,10
                DC.B "   minska med 18   - >  $12     (1*16 +2)",13,10
                DC.B "      ”ka med 28   - >  $-1C    (-(1*16 +12))",13,10,10
                DC.B "Minska f„rg med     :$",0
                ENDPART

                >PART 'PROMPT TEXT'
widthtext:      DC.B 13,10,"Width in bytes  :$",0
heighttext:     DC.B 13,10,"Height in lines :$",0
savedatatext:   DC.B 13,10,10,10,"Save new data image as :",0
savepointtext:  DC.B 13,10,"Save pointer tab as    :",0
                ENDPART
                >PART 'CALCULATING TEXT'
firstgo:        DC.B 27,"f",27,"E",27,"pPlease Wait",27,"q",13,10,"Compressing your file!!"
                DC.B 27,"H",10,10,10,"$"
lines_txt:      DC.B "0000 <= Lines to go.",13,10
                DC.B "$0000 <= Lines calculated.",13,10
                DC.B "$0000 <= Lines removed.",0

crunchingtext:  DC.B "H",10,10,10,10,"$"
calculated_txt: DC.B "    ",13,10
                DC.B "$"
removed_txt:    DC.B "    ",0
                ENDPART

                EVEN
plusa:          DS.L 1
input:          DC.B 60
                DC.B 0
                DS.B 60
                BSS
                DS.B 256
stack:

a:              DS.B 32128
b:              DS.B 32128
c:              DS.B 32128
                END
