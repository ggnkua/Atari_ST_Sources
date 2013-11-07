                lea     TestSeq(PC),A0
                bsr.s   Init_U_Seq
                bra.s   Start_U_Seq


us:

Init_U_Seq:     >PART 'Init U Seq'
; a0=Start of U Sequencer
                lea     us(PC),A6
                move.l  A0,_USeqStart-us(A6)
                rts
                ENDPART
Start_U_Seq:
; a6=Fixed
; a5=Stack
; a4=Seq
                lea     us(PC),A6
                lea     _us_Stack(PC),A5
                movea.l _USeqStart(PC),A4

NeverEnd:       move.l  (A4)+,D0
                bsr.s   GetComAddr
                jsr     (A0)
                bra.s   NeverEnd

                >PART 'Hopp kommandon'
co_GOTO:        move.w  (A4),D0
                lea     0(A4,D0.w),A4
                rts
co_GOSB:        move.w  (A4)+,D0
                move.l  A4,-(A5)
                lea     -2(A4,D0.w),A4
                rts
co_I_GO:        move.w  (A4),D0
                move.l  0(A4,D0.w),D0
                movea.l _USeqStart(PC),A4
                adda.l  D0,A4
                rts
co_I_GS:        move.w  (A4)+,D0
                move.l  A4,-(A5)
                move.l  -2(A4,D0.w),D0
                movea.l _USeqStart(PC),A4
                adda.l  D0,A4
                rts
co_RETN:        movea.l (A5)+,A4
                rts
co_POPS:        addq.l  #4,A5
                rts
                ENDPART
                PART 'Variabel kommandon'
co_EQU:         move.w  (A4)+,D0
                lea     -2(A4,D0.w),A1
                move.w  (A4)+,D0
                move.l  (A4)+,D1
                bsr.s   GetTal
                move.l  D0,(A1)
                rts

co_MOV:         move.w  (A4)+,D0
                movea.l A4,A3
                move.l  (A4)+,D1
                bsr     GetTal
                movea.l D0,A0
                move.w  (A4)+,D0
                movea.l A4,A3
                move.l  (A4)+,D1
                bsr     GetTal
                move.l  D0,(A0)
                rts

co_ADD:         move.w  (A4)+,D0
                lea     -2(A4,D0.w),A1
                move.w  (A4)+,D0
                move.l  (A4)+,D1
                bsr.s   GetTal
                add.l   D0,(A1)
                rts

co_SUB:         move.w  (A4)+,D0
                lea     -2(A4,D0.w),A1
                move.w  (A4)+,D0
                move.l  (A4)+,D1
                bsr.s   GetTal
                sub.l   D0,(A1)
                rts

co_AND:         move.w  (A4)+,D0
                lea     -2(A4,D0.w),A1
                move.w  (A4)+,D0
                move.l  (A4)+,D1
                bsr.s   GetTal
                and.l   D0,(A1)
                rts

co_OR_:         move.w  (A4)+,D0
                lea     -2(A4,D0.w),A1
                move.w  (A4)+,D0
                move.l  (A4)+,D1
                bsr.s   GetTal
                or.l    D0,(A1)
                rts

co_XOR:         move.w  (A4)+,D0
                lea     -2(A4,D0.w),A1
                move.w  (A4)+,D0
                move.l  (A4)+,D1
                bsr.s   GetTal
                eor.l   D0,(A1)
                rts

                ENDPART

GetComAddr:     >PART 'Get size and addr'
; d0=Instruktion
; ut:  a0=Address till instruktion
;      d0=Size
                lea     _TransEm(PC),A0
.NextDude:      cmp.l   (A0)+,D0
                beq.s   .GotYaDude
                cmpi.l  #-1,-4(A0)
                bne.s   .Ajeah
                illegal
                DC.B "Unknow USeq"
                EVEN
.Ajeah:         addq.l  #6,A0
                bra.s   .NextDude
.GotYaDude:     move.w  4(A0),D0
                movea.l (A0)+,A0
                rts
                ENDPART
GetTal:         PART 'Get "Tal"'
; d0=mode.w
; d1=data.l
                add.w   D0,D0
                jmp     _GoMan-*-2(PC,D0.w)

_GoMan:         jmp     .Konstant(PC)
                jmp     .LongOfs(PC)
                jmp     .ExaktAddr(PC)
                jmp     .VirtuellAddr(PC)
                jmp     .AddSeqStart(PC)
                jmp     .AddOffset(PC)
.Konstant:      move.l  D1,D0
                rts
.LongOfs:       move.l  A0,-(A7)
                movea.l _USeqStart(PC),A0
                adda.l  D1,A0
                move.l  (A0),D0
                movea.l (A7)+,A0
                rts
.ExaktAddr:     move.l  A0,-(A7)
                movea.l D1,A0
                move.l  (A0),D0
                movea.l (A7)+,A0
                rts
.VirtuellAddr:  rts
.AddSeqStart:   add.l   _USeqStart(PC),D1
                move.l  D1,D0
                rts
.AddOffset:     add.l   A3,D1
                move.l  D1,D0
                rts
                ENDPART
_USeqStart:     DS.L 1

                DS.L 32
_us_Stack:

_TransEm:       DC.L "GOTO",co_GOTO
                DC.W 4
                DC.L "GOSB",co_GOSB
                DC.W 4
                DC.L "I_GO",co_I_GO
                DC.W 4
                DC.L "I_GS",co_I_GS
                DC.W 4
                DC.L "RETN",co_RETN
                DC.W 2
                DC.L "POPS",co_POPS
                DC.W 2

                DC.L "EQU=",co_EQU
                DC.W 12
                DC.L "MOV=",co_MOV
                DC.W 16
                DC.L "ADD=",co_ADD
                DC.W 12
                DC.L "SUB=",co_SUB
                DC.W 12
                DC.L "AND=",co_AND
                DC.W 12
                DC.L "OR_=",co_OR_
                DC.W 12
                DC.L "XOR=",co_COR
                DC.W 12
                DC.L "SWP=",co_SWP
                DC.W 6
                DC.L "SHR=",co_SHR
                DC.W 12
                DC.L "SHL=",co_SHL
                DC.W 12
                DC.L "LSR=",co_LSR
                DC.W 12
                DC.L "LSL=",co_LSL
                DC.W 12
                DC.L "ASR=",co_ASR
                DC.W 12

TestSeq:
                DC.L "I_GO"
                DC.W InDir-*

Tal:            DC.L 0
InDir:          DC.L Hit-TestSeq

Hit:            DC.L "EQU="
                DC.W Tal-*
                DC.W 0
                DC.L $12345678

                DC.L "GOTO"
                DC.W TestSeq-*


                END
