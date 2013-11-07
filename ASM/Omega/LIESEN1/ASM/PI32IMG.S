*  PI3 to IMG
*
*    Uses Comandline (good to know if you find it hard to start...)
*
* This source code is Copyright Martin Liesen 1991
* Assembled version is Public Domain

                OUTPUT 'PI32IMG.TTP'
rem             EQU 0

                movea.l 4(A7),A5
                lea     128(A5),A5
                moveq   #0,D0
                move.b  (A5)+,D0
                clr.b   0(A5,D0.w)
                tst.b   (A5)
                beq.s   No_ComL
                move.l  A5,filename_a

                lea     Buf2,A6
                movea.l filename_a(PC),A5
                bsr     Load_File

                movea.l filename_a(PC),A0
.lookmore:      cmpi.b  #".",(A0)+
                beq.s   .TjoHo
                tst.b   (A0)
                bne.s   .lookmore

                clr.w   -(A7)               ; Skit Samma!
                trap    #1

.TjoHo:         move.b  #"I",(A0)+
                move.b  #"M",(A0)+
                move.b  #"G",(A0)+
                clr.b   (A0)+

                move.l  #400,D1
                moveq   #80,D2
                lea     Buf2+34,A0
                lea     Buf1(PC),A1
                bsr     Img_Crunch
                movea.l A1,A3
                movea.l A2,A4

                movea.l filename_a(PC),A5
                bsr     Save_File

                clr.w   -(A7)
                trap    #1


No_ComL:        >PART 'Info Text'
                pea     InfoText(PC)
                move.w  #9,-(A7)
                trap    #1
                move.w  #7,-(A7)
                trap    #1
                clr.w   -(A7)
                trap    #1
InfoText:       DC.B 27,"E"
                DC.B "PI3 to IMG",13,10,10
                DC.B "Just pass the name throgh the commandline, the outpufile will recive the",13,10
                DC.B "the same name but with the extension .IMG",13,10,10,10,10
                DC.B "Press any key",0
                EVEN
                ENDPART

DFel:           >PART 'Disk Error'
                pea     Derror(PC)
                move.w  #9,-(A7)
                trap    #1
                move.w  #7,-(A7)
                trap    #1
                clr.w   -(A7)
                trap    #1
Derror:         DC.B 27,"E","Disk Error",0
                EVEN
                ENDPART
MFel:           >PART 'Memory Error'
                pea     Merror(PC)
                move.w  #9,-(A7)
                trap    #1
                move.w  #7,-(A7)
                trap    #1
                clr.w   -(A7)
                trap    #1
Merror:         DC.B 27,"E","File too BIG, hit Liesen!",0
                EVEN
                ENDPART
NoSpace:        >PART 'No DiskSpace'
                pea     T_No(PC)
                move.w  #9,-(A7)
                trap    #1
                move.w  #7,-(A7)
                trap    #1
                clr.w   -(A7)
                trap    #1
T_No:           DC.B 27,"E","Disk full, I refuse to save file!",0
                EVEN
                ENDPART

Load_File:      >PART 'Load A File'
* A5=Address to name
* A6=Address where to Load
                movem.l D0-A4,-(A7)

                clr.w   -(A7)               ; Open
                move.l  A5,-(A7)
                move.w  #$003D,-(A7)
                trap    #1
                addq.l  #8,A7
                tst.l   D0
                bmi     DFel
                move.l  D0,D7

                move.l  A6,-(A7)            ; Read
                move.l  #320*1024,-(A7)
                move.w  D7,-(A7)
                move.w  #$003F,-(A7)
                trap    #1
                lea     12(A7),A7
                tst.l   D0
                bmi     DFel
                cmp.l   #300*1024,D0
                bge     MFel
                move.l  D0,org_size

                move.w  D7,-(A7)            ; Close
                move.w  #$003E,-(A7)
                trap    #1
                addq.l  #4,A7
                tst.l   D0
                bmi     DFel

                movem.l (A7)+,D0-A4
                rts
                ENDPART
Save_File:      >PART 'Save A File'
* A3=Address where to start saving
* A4=Address where to end saving
* A5=Address to name
                movem.l D0-A6,-(A7)
                move.l  A4,D6
                sub.l   A3,D6
                sub.l   org_size(PC),D6
                add.l   #$00001000,D6

                moveq   #0,D0               ; Get Drive
                cmpi.b  #":",1(A5)
                bne.s   .YesMan
                move.b  (A5),D0
                cmp.b   #"a",D0
                blo.s   .BigC
                sub.b   #"a"-1,D0
                bra.s   .YesMan
.BigC:          sub.b   #"A"-1,D0
.YesMan:
                move.w  D0,-(A7)
                pea     d_size(PC)
                move.w  #$0036,-(A7)
                trap    #1
                addq.l  #8,A7
                lea     d_size(PC),A0
                move.l  12(A0),D5
                move.l  8(A0),D0
                muls    D0,D5
                divs    D5,D6
                move.l  (A0),D5
                cmp.w   D5,D6
                bgt     NoSpace

.CoolMan:       clr.w   -(A7)               ; Create
                move.l  A5,-(A7)
                move.w  #$003C,-(A7)
                trap    #1
                addq.l  #8,A7
                tst.l   D0
                bmi     DFel
                move.w  D0,D7

                move.l  A3,-(A7)            ; Write
                move.l  A4,D0
                sub.l   A3,D0
                move.l  D0,-(A7)
                move.w  D7,-(A7)
                move.w  #$0040,-(A7)
                trap    #1
                lea     12(A7),A7
                tst.l   D0
                bmi     DFel

                move.w  D7,-(A7)            ; Close
                move.w  #$003E,-(A7)
                trap    #1
                addq.l  #4,A7
                tst.l   D0
                bmi     DFel

                movem.l (A7)+,D0-A6
                rts

d_size:         DS.L 4

                ENDPART

Img_Crunch:     >PART 'Img Cruncher'
* Stuid Lazy IMG cruncher that really don't pack at all
* a0= Address to the area to pack
* a1= Address to where to pack area (keep BIG)
* d1= hight in pixels
* d2= width in bytes
* Out:  a2=End of packed area

                movem.l D0-A1/A3-A6,-(A7)
                move.w  #1,(A1)+
                move.w  #8,(A1)+
                move.w  #1,(A1)+
                move.w  #2,(A1)+
                move.w  #1,(A1)+
                move.w  #1,(A1)+
                move.w  D2,D7
                lsl.w   #3,D7
                move.w  D7,(A1)+
                move.w  D1,(A1)+

                subq.w  #1,D1
.LoopY:         move.w  D2,D7
.LoopX:         move.b  #$80,(A1)+
                move.w  D7,D6
                and.w   #$00FF,D6
                sub.w   D6,D7
                move.b  D6,(A1)+
                subq.w  #1,D6
.CopyB:         move.b  (A0)+,(A1)+
                dbra    D6,.CopyB
                tst.w   D7
                bne.s   .LoopX
                dbra    D1,.LoopY

                movea.l A1,A2

                movem.l (A7)+,D0-A1/A3-A6
                rts
                ENDPART

org_size:       DS.L 1
save_start:     DS.L 1
save_slut:      DS.L 1
filename_a:     DS.L 1
                BSS
Buf1:           DS.B 100*1024
Buf2:           DS.B 100*1024
                END
