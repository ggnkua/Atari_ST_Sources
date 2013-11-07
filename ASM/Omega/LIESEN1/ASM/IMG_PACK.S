                move.w  #2,-(A7)
                trap    #14
                addq.l  #2,A7
                movea.l D0,A0

                move.l  #400,D1
                moveq   #80,D2

                lea     Buf1(PC),A1
                bsr     Img_Crunch
                move.l  A1,save_start
                move.l  A2,save_slut

                movea.l save_start(PC),A3
                movea.l save_slut(PC),A4
                movea.l filename_a(PC),A5
                bsr     Save_File

                move.l  save_slut(PC),D0
                sub.l   save_start(PC),D0

                rts

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
Save_File:      >PART 'Save A File'
* A3=Address where to start saving
* A4=Address where to end saving
* A5=Address to name
                movem.l D0-A6,-(A7)
                move.l  A4,D6
                sub.l   A3,D6
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
* a1= Address to where to pack area (keep BIG) (least 64Kb)
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
Img_Crunch2:    PART 'Img Cruncher'
* Slow but well packing IMG
* a0= Address to the area to pack
* a1= Address to where to pack area (keep BIG) (least 64Kb)
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
.LoopX:

                movea.l A0,A2
                move.w  D7,D6




                move.b  #$80,(A1)+
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
Img_Uncrunch:   >PART 'Img UnCruncher'
* a0= Address to the crunched area
* a1= Address to where to save the unchrunched data
* out:
* d0=width in pixels
* d1=hight in pixels
* d2=width in bytes
* d3=width fixer   0=width by 1    1=width by 2  2=width by 4 (bytes)
* a2=address to end of uncrunched area
.s:             movem.l D3-A1/A3-A6,-(A7)
                lea     .s(PC),A6

                move.w  2(A0),D7
                add.w   D7,D7
                lea     0(A0,D7.w),A2       ; a2=start of crunched image
                moveq   #0,D0
                moveq   #0,D1
                move.w  12(A0),D0           ; d0=width
                move.w  14(A0),D1           ; d1=hight
                move.l  D0,D2
                add.w   #7,D2
                lsr.w   #3,D2               ; d2=bytes wide

***************************************************


.LineLoop:      movea.l A1,A3               ; a3=start of line
                lea     0(A3,D2.w),A4       ; a4=end of line
                move.b  #1,.Linjer-.s(A6)

.ScanLoop:      move.b  (A2)+,D7
                bne.s   .EjNoll

                move.b  (A2)+,D7
                bne.s   .EjLinje

                move.b  (A2)+,D7            ; Scanline run
                move.b  (A2)+,.Linjer-.s(A6)
                bra.s   .ComDone

.EjLinje:       subq.w  #1,D7               ; Pattern run
.pat2_loop:     movea.l A2,A6
                move.w  6(A0),D6
                subq.w  #1,D6
.pat1_loop:     move.b  (A5)+,(A1)+
                dbra    D6,.pat1_loop
                dbra    D7,.pat2_loop
                adda.w  6(A0),A2
                bra.s   .ComDone

.EjNoll:
                cmp.b   #$80,D7
                bne.s   .SolidRun

                moveq   #0,D7               ; Uncompressed run
                move.b  (A2)+,D7
                subq.w  #1,D7
.unc_loop:      move.b  (A2)+,(A1)+
                dbra    D7,.unc_loop
                bra.s   .ComDone

.SolidRun:      moveq   #0,D6               ; Solid run
                btst    #7,D7
                beq.s   .nulls
                moveq   #-1,D6
.nulls:         and.w   #$007F,D7
                subq.w  #1,D7
.sol_loop:      move.b  D6,(A1)+
                dbra    D7,.sol_loop

.ComDone:       cmpa.l  A1,A4
                bne.s   .ScanLoop

.LineCopy:      sub.w   #1,D1
                beq.s   .VeryDone
                subi.b  #1,.Linjer-.s(A6)
                beq.s   .LineLoop

                movea.l A3,A4
                move.w  D2,D7
                subq.w  #1,D7
.copyloop:      move.b  (A4)+,(A1)+
                dbra    D7,.copyloop
                bra.s   .LineCopy


.VeryDone:      movea.l A1,A2
                movem.l (A7)+,D3-A1/A3-A6

                move.w  12(A0),D0           ; d0=width
                move.w  14(A0),D1           ; d1=hight
                move.l  D0,D2
                add.w   #7,D2
                lsr.w   #3,D2               ; d2=bytes wide
                rts

.Linjer:        DC.B 0
                EVEN
                ENDPART

save_start:     DS.L 1
save_slut:      DS.L 1
filename_a:     DC.L filn
filn:           DC.B "D:\LIESEN\A_TEST.IMG",0
                EVEN
                BSS
Buf1:           DS.B 320*1024
                END
