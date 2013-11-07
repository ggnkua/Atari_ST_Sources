*  IMG pattern Reducer V1.01
*  Has a fast IMG uncruncher
*  Has a no-packing IMG cruncher
*  Load & Save rutines
*  Free Disk Space routine
*
*    Uses Comandline (good to know if you find it hard to start...)
*
* This source code is Copyright Martin Liesen 1991
* Assembled version is Public Domain

                OUTPUT 'PATREDUC.TTP'
rem             EQU 0

                movea.l 4(A7),A5
                lea     128(A5),A5
                moveq   #0,D0
                move.b  (A5)+,D0
                clr.b   0(A5,D0.w)
                tst.b   (A5)
                beq.s   No_ComL
                move.l  A5,filename_a

                pea     MainText(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7

                lea     Buf2,A6
                movea.l filename_a(PC),A5
                bsr     Load_File

                lea     Buf2,A0
                lea     Buf1(PC),A1
                bsr     Img_Uncrunch

                movea.l A1,A0
                bsr     PixelSabbaren

                lea     Buf1(PC),A0
                lea     Buf2,A1
                bsr     Img_Crunch
                move.l  A1,save_start
                move.l  A2,save_slut

*                lea     Buf1(PC),A1
*                bsr     Show_Pic

                movea.l save_start(PC),A3
                movea.l save_slut(PC),A4
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
                DC.B "IMG pattern eliminator V1.01",13,10
                DC.B "Martin Liesen & Johannes S”derqvist 1991",13,10,10,10
                DC.B "This is Public Domain, and we take no responsibility whatsoever!",13,10,10,10
                DC.B "Just pass the path & filename of the IMG file you wish to 'pattern eliminate'",13,10
                DC.B "for improved result when converting to more intensity levels.",13,10,10,10
                DC.B "Warning: The old IMG file will be overwritten IF there is enough diskspace.",13,10
                DC.B "If there isn't enough disk room, file will NOT be saved (You will be",13,10
                DC.B "informed if this is the case.",13,10,10
                DC.B "Avoid using wildcards as output file might not recive the name one could",13,10
                DC.B "expect (unless one is as bright as me..).",13,10,10
                DC.B "This version uses no crunching algorithm on the output file!",13,10,10,10,10,10,10
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

PixelSabbaren:  >PART 'Random Moving of Pixels'
* a0=address to image
* d1=Hight
* d2=Width in bytes
                movem.l D0-A6,-(A7)
                lea     0(A0,D2.w),A3
                lsr.w   #1,D1
                subq.w  #1,D1
                lea     SLUMP(PC),A2
.PajaY:         move.w  D2,D0
                subq.w  #1,D0
.PajaX:         move.b  (A0),D7
                move.b  (A3),D4
                roxl.w  (A2)
                move.l  (A2)+,D5
                cmpa.l  #ENDSLUMP,A2
                blo.s   .FuckYou
                lea     SLUMP(PC),A2
.FuckYou:       add.w   D5,(A2)

                moveq   #3,D3
.PajaByte1:     rol.l   #1,D5
                bcc.s   .Nice1
                move.b  D7,D6
                and.w   #$0003,D6
                lsr.b   #1,D6
                bcc.s   .Mupp1
                bset    #1,D6
.Mupp1:         and.b   #$FC,D7
                or.b    D6,D7
.Nice1:         ror.b   #2,D7
                dbra    D3,.PajaByte1

                moveq   #3,D3
.PajaByte2:     rol.l   #1,D5
                bcc.s   .Nice2
                move.w  D4,D6
                and.w   #$0003,D6
                lsr.w   #1,D6
                bcc.s   .Mupp2
                bset    #1,D6
.Mupp2:         and.w   #$00FC,D4
                or.w    D6,D4
.Nice2:         ror.b   #2,D4
                dbra    D3,.PajaByte2

                moveq   #7,D3
.YSwitch:       rol.l   #1,D5
                bcc.s   .Nice3
                swap    D0
                move.b  D4,D0
                move.b  D7,D6
                and.b   #$FE,D4
                and.b   #$FE,D7
                and.b   #1,D0
                and.b   #1,D6
                or.b    D0,D7
                or.b    D6,D4
                swap    D0
.Nice3:         rol.b   #1,D7
                rol.b   #1,D4
                dbra    D3,.YSwitch

                move.b  D4,(A3)+
                move.b  D7,(A0)+
                sub.b   D7,D5
                rol.w   D4,D5
                add.l   D5,(A2)
                dbra    D0,.PajaX
                adda.w  D2,A0
                adda.w  D2,A3
                dbra    D1,.PajaY


                movem.l (A7)+,D0-A6
                rts


SLUMP:
                DC.W $F3B4,$EF6B,$D24B,$FE9F,$2BF8,$9FD9,$F967,$9E3E,$A12F,$1F72,$D9B3
                DC.W $97F0,$DE04,$5672,$2DBC,$7E4F,$CFE4,$08D7,$D0CE,$25B8,$72FA,$125B
                DC.W $4AF4,$4046,$3E34,$627B,$1CFC,$B9D7,$4F3C,$B873,$CC70,$D405,$567F
                DC.W $1F3E,$AF9D,$022D,$4329,$299A,$798E,$856A,$AF25,$EE01,$8610,$C89A
                DC.W $0B20,$C2AF,$E5AF,$7C57,$8A86,$B9A2,$29B7,$72FE,$CF83,$DC94,$F034
                DC.W $BA1E,$172B,$0B09,$E24A,$D9E6,$F506,$58CB,$3A7F,$F59E,$68B4,$6EEC
                DC.W $EBDC,$73D3,$40CF,$C6D8,$565D,$9BD1,$4DB4,$A8BB,$B1BD,$21A3,$FD7E
                DC.W $9781,$0979,$7217,$B80B,$7CD5,$F8CD,$BEB7,$FAF5,$9524,$26B4,$C9CF
                DC.W $3BE0,$BB6C,$504C,$6FA9,$7661,$9322,$CA14,$A0FE,$6E57,$B6B1,$5576
                DC.W $0CDA,$C07C,$9B24,$4D8E,$DF28,$2D4D,$7E49,$D737,$3A95,$5506,$72AA
                DC.W $FD0E,$248D,$33A2,$2B93,$8B6F,$313C,$5CDF,$8912,$AC76,$EF8D,$F837
                DC.W $E3F1,$43FE,$152D,$7CE6,$19BD,$0BA4,$6A88,$2DEA,$58C2,$6EC4,$76CA
                DC.W $55FD,$AC0C,$267A,$EBDE,$439C,$4766,$95A1,$D272,$0503,$935D,$E4D6
                DC.W $FD23,$67D6,$F445,$B7DB,$33B3,$A37B,$00FE,$51F0,$EA40,$730E,$A902
                DC.W $60A8,$4016,$9EEB,$CC7D,$D3C0,$4141,$0D2E,$065A,$EEB4,$328C,$1DB2
                DC.W $D820,$C4D1,$FD25,$A799,$57A0,$AC32,$7548,$98DB,$08A1,$F3B4,$25DB
                DC.W $F615,$4AAF,$2EF4,$2947,$6C42,$EE16,$434E,$78BB,$5020,$BFE2,$03DD
                DC.W $5822,$9A29,$D5DE,$8D7F,$8227,$A299,$9A97,$62CE,$1437,$9D6E,$9959
                DC.W $4827,$3A7D,$D662,$0A2F,$DFA5,$9BE7,$ACF2,$1DE7,$0526,$861F,$505A
                DC.W $0A0B,$EA44,$D992,$3B95,$D4E8,$F25C,$B56C,$7161,$E189,$4E89,$E398
                DC.W $7838,$3BBB,$59A9
ENDSLUMP:       DC.W 0,2

                ENDPART

                IF rem=1
Show_Pic:       >PART 'Show it and Wait'
* A1=Source
* D2=Width in bytes

                movem.l D0-A2,-(A7)
                move.w  #2,-(A7)
                trap    #14
                addq.l  #2,A7
                movea.l D0,A3
                movem.l (A7)+,D0-A2


                move.w  #399,D7
.cy:            movea.l A1,A4
                movea.l A3,A5
                moveq   #79,D6
.cx:            move.b  (A4)+,(A5)+
                dbra    D6,.cx
                lea     80(A3),A3
                adda.w  D2,A1
                dbra    D7,.cy

                move.w  #1,-(A7)
                trap    #1
                addq.l  #2,A7
                rts
                ENDPART
                ENDC

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

org_size:       DS.L 1
save_start:     DS.L 1
save_slut:      DS.L 1
filename_a:     DS.L 1
MainText:       DC.B 27,"H"
                DC.B "IMG pattern >Reducer<",0
                EVEN
                BSS
Buf1:           DS.B 320*1024
Buf2:           DS.B 320*1024
                END
