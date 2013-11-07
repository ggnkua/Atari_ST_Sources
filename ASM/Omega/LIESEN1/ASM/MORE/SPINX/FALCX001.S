***   Font And Logo Compressor V1.0
***   Made By Martin Liesen 1991
***********************************************    Dummy Init

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
                pea     input(PC)
                move.w  #10,-(A7)       ; name of source
                trap    #1
                addq.l  #6,A7
                tst.b   input+1
                beq     back

                movea.l diskaccess(PC),A0
                move.w  #0,2(A0)
                move.l  #input+2,6(A0)
                move.l  #a,10(A0)
                move.l  #-1,14(A0)
                move.l  #128*1024,18(A0)
                move.w  #0,24(A0)
                move.w  #0,42(A0)
                jsr     (A0)

                pea     widthtext(PC)   ; width
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                pea     input(PC)
                move.w  #10,-(A7)
                trap    #1
                addq.l  #6,A7
                bsr     shex_hex
                tst.w   D0
                bmi     back
                move.w  D0,width

                pea     heighttext(PC)  ; height
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                pea     input(PC)
                move.w  #10,-(A7)
                trap    #1
                addq.l  #6,A7
                bsr     shex_hex
                tst.w   D0
                bmi     back
                move.w  D0,height
                ENDPART

                >PART 'INIT TEXT CALCULATING'
                lea     lines_txt(PC),A0
                move.w  height(PC),D0
                bsr     hex_shex4

                pea     firstgo(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,-(A7)
                ENDPART
                >PART 'INIT CALCULATING"'
                move.w  height(PC),D7
                subq.w  #1,D7
                moveq   #0,D6
                move.w  width(PC),D6
                move.l  D6,lwidth
                lsr.w   #1,D6
                subq.w  #1,D6
                move.w  D6,hwidth
                clr.w   calc
                clr.w   removed
                clr.w   saved

                lea     pointers(PC),A6
                ENDPART

***********************************************    Calculate

loopa:          >PART 'SKRIV UT P SKŽRMEN'
                bsr     newvalues       ; Print Info
                pea     crunchingtext(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                ENDPART
                >PART 'PLACER IN DEN NYE RŽTT'
                lea     a(PC),A5
                lea     b,A4
                moveq   #0,D0
                move.w  calc(PC),D0     ; Get line calculating on
                mulu    width(PC),D0
                lea     0(A5,D0.l),A5

                moveq   #0,D5
                moveq   #0,D3

samelook:       cmp.w   saved(PC),D5
                beq.s   notfound

                lea     0(A4,D3.l),A3
                movea.l A5,A2
                move.w  hwidth(PC),D4
samma:          cmpm.w  (A2)+,(A3)+
                bne.s   notsame
                dbra    D4,samma
                addq.w  #1,removed
                move.w  D5,(A6)+        ; Found an identical!!!
                bra.s   getnext

notsame:        add.l   lwidth(PC),D3
                addq.w  #1,D5
                bra.s   samelook

********************************************

notfound:       move.w  saved(PC),D0    ; A new line
                move.w  D0,(A6)+
                addq.w  #1,saved

                mulu    width(PC),D0
                lea     0(A4,D0.l),A4

                move.w  hwidth(PC),D0
copying:        move.w  (A5)+,(A4)+
                dbra    D0,copying
                ENDPART

getnext:        addq.w  #1,calc
                dbra    D7,loopa

************************************************   Save

                >PART 'SKRIV UT P SKŽRMEN'
                bsr     newvalues       ; Print Info
                pea     crunchingtext(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                ENDPART
                >PART 'SPARA NER SKITEN'
                pea     savedatatext(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7

                pea     input(PC)
                move.w  #10,-(A7)       ; name of data file to save
                trap    #1
                addq.l  #6,A7
                tst.b   input+1
                beq     back

                movea.l diskaccess(PC),A0
                move.w  #1,2(A0)
                move.l  #input+2,6(A0)
                move.l  #b,10(A0)
                move.l  #-1,14(A0)
                moveq   #0,D0
                move.w  saved(PC),D0
*                subq.l  #1,D0
                mulu    width(PC),D0
                move.l  D0,18(A0)
                move.w  #0,24(A0)
                move.w  #0,38(A0)
                jsr     (A0)


                pea     savepointtext(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7

                pea     input(PC)
                move.w  #10,-(A7)       ; name of pointer file to save
                trap    #1
                addq.l  #6,A7
                tst.b   input+1
                beq.s   back

                movea.l diskaccess(PC),A0
                move.w  #1,2(A0)
                move.l  #input+2,6(A0)
                move.l  #pointers,10(A0)
                move.l  #-1,14(A0)
                moveq   #0,D0
                move.w  height(PC),D0
*                subq.l  #1,D0
                add.l   D0,D0
                move.l  D0,18(A0)
                move.w  #0,24(A0)
                move.w  #0,38(A0)
                jsr     (A0)
                ENDPART

back:           >PART 'RETURN TO CALLER'
                movea.l savestack(PC),A7
                rts
                ENDPART

************************************************   Procedures

newvalues:      >PART 'SŽTT IN TALEN I TEXTEN'
                lea     calculated_txt(PC),A0
                move.w  calc(PC),D0
                bsr.s   hex_shex4
                lea     removed_txt(PC),A0
                move.w  removed(PC),D0
                bsr.s   hex_shex4
                rts
                ENDPART

shex_hex:       >PART 'CONVERT Shex=>hex'
* converts hex string to hex digits
* If -1 in longword in d0, Digit not aloweed
* if -2 there was nothing to convert...
                movem.l D1-D3/A0-A2,-(A7)
                lea     input+1(PC),A0
                lea     hextaltab(PC),A1
                moveq   #-2,D0
                moveq   #0,D1
                move.b  (A0)+,D1
                tst.b   D1
                beq.s   skipshex_hex
                moveq   #0,D0
                subq.w  #1,D1
getem_all:      move.b  (A0)+,D2
                movea.l A1,A2
                moveq   #0,D3
findhim:        cmp.b   (A2)+,D2
                beq.s   hexcharfound
                addq.w  #1,D3
                tst.b   D2
                bne.s   findhim
                moveq   #-1,D0
                bra.s   skipshex_hex
hexcharfound:   and.w   #$000F,D3
                lsl.l   #4,D0
                or.l    D3,D0
                dbra    D1,getem_all

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

savestack:      DS.L 1
width:          DS.W 1
hwidth:         DS.W 1
lwidth:         DS.L 1
height:         DS.W 1
diskaccess:     DS.L 1
removed:        DS.W 1
saved:          DS.W 1
calc:           DS.W 1

                >PART 'INIT TEXT'
inittext:       DC.B 27,"E",10,27,"e",27,"pFont And Logo Compressor",27,"q",13,10
                DC.B "Made By Liesen of Omega 1991",13,10,10
                DC.B "Dedicated to Sofia, wish you would call back again!!!",13,10,10,10
                DC.B "Removes all lines that contains the same data.",13,10
                DC.B "To be able to find the right data a tabell is",13,10
                DC.B "build. One word, saying which line in the data tabel",13,10
                DC.B "to use for this very line (the line the word is representing).",13,10
                DC.B "The first line points at NULL. The scond will also point at",13,10
                DC.B "null, that is if  it contains the same data as the first",13,10
                DC.B "line, otherwise it will contain one.",13,10,10
                DC.B "Name of file to compress :",0
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
input:          DC.B 60
                DC.B 0
                DS.B 60
                BSS
                DS.B 256
stack:

pointers:       DS.B 16*1024
a:              DS.B 128*1024
b:              DS.B 128*1024
                END
