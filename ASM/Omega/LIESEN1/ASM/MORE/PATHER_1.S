* Use to Fix Path bug in DevPac 2.23
* Martin Liesen 1991
*
                opt P+

s:              >PART 'ReserveMem, Set Stack'

                lea     s(pc),a6
                move.l  a7,_SaveA7-s(a6)
                movea.l a7,a5           ; release memory
                movea.l 4(a5),a7
                lea     128(a7),a7
                move.l  a7,_CommandLine-s(a6)

                lea     _Stack(pc),a7
                movea.l 4(a5),a5

                lea     MEGASLUT(pc),a0
                suba.l  a6,a0
                lea     1024(a0),a0
                move.l  a0,-(a7)
                move.l  a5,-(a7)
                move.w  #0,-(a7)
                move.w  #$004A,-(a7)
                trap    #1
                lea     12(a7),a7


                endpart
                >PART 'Get Old dir'
                lea     _OldPath(pc),a5
                bsr     GetDir
                endpart
                >PART 'Pascal To C'
                movea.l _CommandLine(pc),a0
                move.b  (a0)+,d0
                beq     ErrNoCom
                ext.w   d0
                clr.b   0(a0,d0.w)
                move.l  a0,_CommandLine-s(a6)
                endpart
                >PART 'Split CommandLine'
                movea.l a0,a5
.n0:            move.b  (a0)+,d0
                beq.s   .NameFound
                cmp.b   #'\',d0
                bne.s   .n1
                movea.l a0,a5
.n1:            cmp.b   #':',d0
                bne.s   .n2
                movea.l a0,a5
.n2:            cmp.b   #' ',d0
                bne.s   .n0

.NameFound:     movea.l _CommandLine(pc),a0 ; Directory
                lea     _DirBuf(pc),a1
.CopyDir:       cmpa.l  a0,a5
                beq.s   .StopCopyDir
                move.b  (a0)+,(a1)+
                bra.s   .CopyDir
.StopCopyDir:   clr.b   (a1)+

                lea     _NameBuf(pc),a1 ; FileName
.LoopName:      move.b  (a0)+,d0
                beq.s   .NameEnd
                cmp.b   #' ',d0
                beq.s   .NameEnd
                move.b  d0,(a1)+
                bra.s   .LoopName
.NameEnd:       clr.b   (a1)+
                tst.b   d0
                bne.s   .Sorry
                subq.w  #1,a0           ; Back to zero!
.Sorry:

                lea     _ComBuf(pc),a1  ; CommandLine
                movea.l a1,a2
                moveq   #79,d1
.Rens:          clr.b   (a1)+
                dbra    d1,.Rens
                lea     1(a2),a1
                moveq   #0,d1

.NoCom:         move.b  (a0)+,d0
                beq.s   .ComEnd
                move.b  d0,(a1)+
                addq.b  #1,d1
                bra.s   .NoCom
.ComEnd:
                move.b  d1,(a2)         ; Pascal Format!

                endpart
                >PART 'Start if exists'
                lea     _DirBuf(pc),a5
                bsr.s   SetDir

                clr.w   -(a7)
                pea     _NameBuf(pc)
                move.w  #$004E,-(a7)
                trap    #1
                addq.l  #8,a7
                tst.w   d0
                bmi     ErrorIntern

                pea     _Null(pc)
                pea     _ComBuf(pc)
                pea     _NameBuf(pc)
                clr.w   -(a7)
                move.w  #$004B,-(a7)
                trap    #1
                lea     16(a7),a7
                move.w  d0,_Return-s(a6)
                endpart
                bra.s   Back

SetDir:         >PART 'Set dir to A5'
                movem.l d0-a6,-(a7)
                moveq   #0,d7
                tst.b   (a5)
                beq.s   .nodir
                cmpi.b  #':',1(a5)
                bne.s   .notdrive
                move.b  (a5),d0
                cmp.b   #'Z',d0
                bhi.s   .Small
                sub.b   #'A',d0
                bra.s   .huhu
.Small:         sub.b   #'a',d0
.huhu:          lea     2(a5),a5
.notdrive:      move.w  d0,-(a7)
                move.w  #$000E,-(a7)
                trap    #1
                addq.l  #4,a7
                tst.w   d0
                bmi     ErrorIntern

                move.l  a5,-(a7)
                move.w  #$003B,-(a7)
                trap    #1
                addq.l  #6,a7
                tst.w   d0
                bmi     ErrorIntern

.nodir:         movem.l (a7)+,d0-a6
                rts
                endpart
GetDir:         >PART 'Get dir to A5'
                movem.l d0-a6,-(a7)
                move.w  #$0019,-(a7)
                trap    #1
                addq.l  #2,a7
                move.w  d0,d1
                add.b   #'A',d1
                move.b  d1,(a5)+
                move.b  #':',(a5)+
                clr.w   -(a7)
                move.l  a5,-(a7)
                move.w  #$0047,-(a7)
                trap    #1
                addq.l  #8,a7
                movem.l (a7)+,d0-a6
                rts
                endpart
Back:           >PART 'Back'
                lea     _OldPath(pc),a5
                bsr.s   SetDir
                movea.l _SaveA7(pc),a7
                move.w  _Return(pc),-(a7)
                move.w  #$004C,-(a7)
                trap    #1
                endpart
ErrNoCom:       >PART 'No commandLine!'
                move.w  #-666,_Return-s(a6)
                pea     .nocomT(pc)
                move.w  #9,-(a7)
                trap    #1
                move.w  #7,-(a7)
                trap    #1
                addq.l  #8,a7
                bra.s   Back
.nocomT:        dc.b 27,"E","Pather V1.0    Martin Liesen 1991",13,10,10
                dc.b "Takes the commandline, changes the default dir",13,10
                dc.b "and starts the program. After executing Pather",13,10
                dc.b "restores the default dir and bypasses any error.",13,10,10
                dc.b "Examples:",13,10
                dc.b "Pather D:\ASM\TURBOASM\TURBOASM.PRG",13,10
                dc.b "Pather D:\MODEM\FLASH\FLASH.PRG",13,10
                dc.b "Pather D:\ASM\TURBOASM\TURBOASM.PRG D:\ASM\1.SRC",13,10,10
                dc.b "The last one does this: Change the directory to",13,10
                dc.b "'D:\ASM\TURBOASM\' starts the file 'TURBOASM.PRG'",13,10
                dc.b "with the commandline 'D:\ASM\1.SRC'.",13,10,10
                dc.b "And now the ultimate question; WHY?",13,10
                dc.b "To make it possible to run almost any prog from",13,10
                dc.b "within DevPac 2.23 Developer. Without this program",13,10
                dc.b "you wouldn't be able to run any program that",13,10
                dc.b "uses CFG,RSC,INF ect. files.",13,10,10,10
                dc.b ">Press Any Key<",0
                even
                endpart
ErrorIntern:    >PART 'Error, d0=Error'
                move.w  d0,_Return-s(a6)
                pea     .internT(pc)
                move.w  #9,-(a7)
                trap    #1
                move.w  #7,-(a7)
                trap    #1
                addq.l  #8,a7
                bra     Back
.internT:       dc.b 27,"E","Error understanding/executing",13,10
                dc.b "commandline. This error is caused by",13,10
                dc.b "a not working commandline. Path or file",13,10
                dc.b "may not exist. Pather will return the",13,10
                dc.b "error code on termination.",13,10,10
                dc.b "Observe! PROGRAM was NEVER STARTED!",13,10,10
                dc.b ">Press any Key<",0
                even
                endpart

_Return:        ds.w 1
_SaveA7:        ds.l 1
_CommandLine:   ds.l 1
_Null:          ds.w 1
                bss
                ds.w 200
_Stack:
_OldPath:       ds.b 80
_NameBuf:       ds.b 20
_ComBuf:        ds.b 80
_DirBuf:        ds.b 80

MEGASLUT:
                end
