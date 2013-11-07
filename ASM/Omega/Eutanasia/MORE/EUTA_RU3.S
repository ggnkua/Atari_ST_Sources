                OUTPUT 'D:\LIESEN\EUTANASI\RUNNER.PRG'
                >PART 'Memory Shrink & Stack'
                movea.l A7,A5
                lea     _Stack(PC),A7
                movea.l 4(A5),A5
                move.l  $000C(A5),D0
                add.l   $0014(A5),D0
                add.l   $001C(A5),D0
                add.l   #$00000100,D0
                move.l  D0,-(A7)
                move.l  A5,-(A7)
                clr.w   -(A7)
                move.w  #$004A,-(A7)
                trap    #1
                lea     12(A7),A7

                ENDPART
                pea     _texten(PC)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7

                lea     _exetab(PC),A6

.runloop:       move.l  (A6)+,D6
                bmi.s   .NoMore
                move.l  (A6)+,D7
                bmi.s   .NoMore

                lea     _t1(PC),A0
                bsr.s   Print
                movea.l D6,A0
                bsr.s   Print
                lea     _t2(PC),A0
                bsr.s   Print
                movea.l D7,A0
                addq.l  #1,A0
                bsr.s   Print
                lea     _t3(PC),A0
                bsr.s   Print

                pea     _enviroment(PC)
                move.l  D7,-(A7)
                move.l  D6,-(A7)
                clr.w   -(A7)
                move.w  #$004B,-(A7)
                trap    #1
                lea     16(A7),A7

                bra.s   .runloop

.NoMore:        clr.w   -(A7)
                trap    #1


Print:          move.l  A0,-(A7)
                move.w  #9,-(A7)
                trap    #1
                addq.l  #6,A7
                rts
*********************************************
_exetab:
                DC.L _ramdiskF,_ramdiskC
                DC.L _autocopyF,_autocopyC
                DC.L _assemblerF,_assemblerC
                DC.L -1,-1

_enviroment:    DC.W 0

_ramdiskF:      DC.B "D:\LIESEN\EUTANASI\OMEGARAM.PRG",0
_ramdiskC:      DC.B 0,0
_autocopyF:     DC.B "C:\PATHER.TTP",0
_autocopyC:     DC.B 31,"D:\LIESEN\EUTANASI\AUTOCOPY.PRG",0
_assemblerF:    DC.B "C:\PATHER.TTP",0
_assemblerC:    DC.B 57,"D:\TURBOASM\_TURBOA_.PRG D:\LIESEN\EUTANASI\WORKING\EUTANAS1.SRC",0

_texten:        DC.B 27,"E"
                DC.B "Eutanasia, AutoStartUp!",13,10,10
                DC.B "Eutanasia (C) Martin Liesen 1991",13,10,10
                DC.B "Anyone outside Synchron Assembly is breaking the law",13,10
                DC.B "if starting this program our any other file that",13,10
                DC.B "belongs to the development of Eutanasia.",0
_t1:            DC.B 13,10,10
                DC.B "Executing  :",0
_t2:            DC.B 13,10
                DC.B "CommandLine:",0
_t3:            DC.B 13,10,10,0
                BSS
                DS.B 500
_Stack:

                EVEN
                END
