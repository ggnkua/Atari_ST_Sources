*	SAM_PLAY is written by Klaus Pedersen (micro@imada.dk), and
*	distributed, together with "NT_COMP" - the NoiseTracker Compiler
*	for Atari [MEGA] ST, STe and TT computers.
*

* TC passes :
*    samples in A0
*    speed   in D0.w
*    repeat  in D1.w

                GLOBL ST_sequence
* void ST_sequence(long *samples, int speed, int repeat);

                GLOBL ROM_sequence
* void ROM_sequence(long *samples, int speed, int repeat);

                GLOBL PRN_sequence
* void PRN_sequence(long *samples, int speed, int repeat);

* TC passes :
*    samples in A0
*    repeat  in D1.w
*    speed   in D0.w
                GLOBL STe_sequence
* void STe_sequence(long *samples, int repeat, int speed);

* TC passes :
*    nothing.
                GLOBL STe_end
* void STe_end(void);




MW_MASK         EQU $FFFF8922 ;Micro Wire interface...
MW_DATA         EQU $FFFF8924
PCM_MODE        EQU $FFFF8920 ;PCM interface...
PCM_CONTROL     EQU $FFFF8900
PCM_START       EQU $FFFF8902
PCM_END         EQU $FFFF890E
MFP_Data        EQU $FFFFFA01 ;Multi functions interface...
MFP_Edge        EQU $FFFFFA03
MFP_PendA       EQU $FFFFFA0B
MFP_ISRA        EQU $FFFFFA0F
MFP_MaskA       EQU $FFFFFA13
MFP_EnblA       EQU $FFFFFA07
MFP_EnblB       EQU $FFFFFA09
MFP_IVR         EQU $FFFFFA17
SFT_PALLETE     EQU $FFFF8240 ;Shifter
SFT_MODE        EQU $FFFF8260
ROMPORTADDR     EQU $FFFB0000

PCM_VECTOR      EQU $013C   ;Interupt vectores.
TA_VECTOR       EQU $0134
VBL_VECTOR      EQU $70

GemDos          EQU 1
Super           EQU $20     ;GEMDOS functions.

                SUPER

***************** RUTINES FOR THE ST SOUND CHIP *****************
ST_sequence:    movem.l D3-D4/A2-A4,-(SP)
                movea.l A0,A2           ; char **samples
                move.l  D0,D3           ; int speed
                cmp.w   #-1,D1
                seq     NoRepeat
                lsl.l   #2,D1           ; int repeat
                adda.w  D1,A0
                move.l  A0,D4
                bsr     GI_set

                lea     ST_Speed_table,A0
                add.w   D3,D3
                move.w  0(A0,D3.w),D3
                lea     GI_sample,A0
                lea     $FFFF8800.w,A3
                bra.b   ST_Seq
ST_Lop1:        moveq   #0,D0           ;  4
                add.b   (A1)+,D0        ;  8
                lsl.w   #3,D0           ; 12 = 6 + 6
                lea     0(A0,D0.w),A4   ; 12
                move.l  (A4)+,D0        ; 12
                move.w  (A4)+,D1        ;  8
                movep.l D0,0(A3)        ; 24
                movep.w D1,0(A3)        ; 16
                move.w  D3,D0           ;  4
ST_wat:         dbra    D0,ST_wat       ; 16 + n*12
                btst    #0,$FFFFFC00.w  ; 16
                bne.b   ST_StopNOW      ;  8
                subq.l  #1,D2           ;  8
                bpl.b   ST_Lop1         ; 12 = 160 + 12*n
ST_Seq:         movea.l (A2)+,A1
                move.l  (A2)+,D2
                cmpa.w  #-1,A1
                bne.b   ST_Lop1
                tst.b   NoRepeat
                bne.b   ST_StopNOW
                movea.l D4,A2
                movea.l (A2)+,A1
                move.l  (A2)+,D2
                cmpa.w  #-1,A2
                bne.b   ST_Lop1

ST_StopNOW:     bsr     GI_clr
                movem.l (SP)+,D3-D4/A2-A4
                rts




***************** RUTINES FOR D/A ON PRINTER PORT *****************
PRN_sequence:   movem.l D3-D4/A2-A4,-(SP)
                movea.l A0,A2           ; char **samples
                move.l  D0,D3           ; int speed
                cmp.w   #-1,D1
                seq     NoRepeat
                lsl.l   #2,D1           ; int repeat
                adda.w  D1,A0
                move.l  A0,D4
                bsr     GI_set

                lea     PRN_Speed_table,A0
                add.w   D3,D3
                move.w  0(A0,D3.w),D3
                lea     GI_sample,A0
                lea     $FFFF8800.w,A3
                bra.b   PRNSeq
PRNLop1:        move.w  #$0F80,D1       ;  8 - Write all bytes to port B.
                add.b   (A1)+,D1        ;  8
                movep.w D1,0(A3)        ; 16
                move.w  D3,D0           ;  4
PRN_wat:        dbra    D0,PRN_wat      ; 16 + D3*12
                btst    #0,$FFFFFC00.w  ; 16
                bne.b   PRNStopNOW      ;  8
                subq.l  #1,D2           ;  8
                bpl.b   PRNLop1         ; 12 = 96 + 12*n
PRNSeq:         movea.l (A2)+,A1
                move.l  (A2)+,D2
                cmpa.w  #-1,A1
                bne.b   PRNLop1
                tst.b   NoRepeat
                bne.b   PRNStopNOW
                movea.l D4,A2
                movea.l (A2)+,A1
                move.l  (A2)+,D2
                cmpa.w  #-1,A1
                bne.b   PRNLop1

PRNStopNOW:     bsr.b   GI_clr
                movem.l (SP)+,D3-D4/A2-A4
                rts


***************** RUTINES FOR D/A ON THE ROM PORT *****************
ROM_sequence:   movem.l D3-D4/A2-A4,-(SP)
                movea.l A0,A2           ; char **samples
                move.l  D0,D3           ; int speed
                cmp.w   #-1,D1          ; int repeat
                seq     NoRepeat
                lsl.l   #2,D1
                adda.w  D1,A0
                move.l  A0,D4
                bsr.b   GI_set

                lea     ROM_Speed_table,A0
                add.w   D3,D3
                move.w  0(A0,D3.w),D3
                lea     ROMPORTADDR,A3
                bra.b   RomSeq
RomLop1:        move.w  #$80,D0         ;  8
                add.b   (A1)+,D0        ;  8
                add.w   D0,D0           ;  4
                move.b  0(A3,D0.w),D0   ; 16
                move.w  D3,D0           ;  4
Rom_wat:        dbra    D0,Rom_wat      ; 16 + D3*12
                btst    #0,$FFFFFC00.w  ; 16
                bne.b   RomStopNOW      ;  8
                subq.l  #1,D2           ;  8
                bpl.b   RomLop1         ; 12 = 100 + 12*D3
RomSeq:         movea.l (A2)+,A1
                move.l  (A2)+,D2
                cmpa.w  #-1,A1
                bne.b   RomLop1
                tst.b   NoRepeat
                bne.b   RomStopNOW
                movea.l D4,A2
                movea.l (A2)+,A1
                move.l  (A2)+,D2
                cmpa.w  #-1,A1
                bne.b   RomLop1

RomStopNOW:     bsr.b   GI_clr
                movem.l (SP)+,D3-D4/A2-A4
                rts

********** SUBRUTINES TO ENTER SUPER, AND SET GI-REGISTERS **********
GI_clr:         bsr.b   st_GI
                move    gemSR,SR
                move.l  OldStack,-(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                rts

GI_set:         clr.l   -(SP)
                move.w  #$20,-(SP)
                trap    #1
                addq.l  #6,SP
                move.l  D0,OldStack
                move    SR,gemSR
                move    #$2700,SR

st_GI:          lea     GI_tbl,A0
                move.b  (A0)+,D0
lp_GI:          move.b  D0,$FFFF8800
                move.b  (A0)+,$FFFF8802
                move.b  (A0)+,D0
                bpl.b   lp_GI
                rts

***************** RUTINES FOR THE STE DMA SOUND *****************
DMAinterupt:    movem.l D0/A0-A1,-(SP)
                bsr.b   DMAmusic
                movem.l (SP)+,D0/A0-A1
                bclr    #7,MFP_ISRA.w
                rte

DMAmusic:       movea.l tablePointer,A0
                cmpi.l  #-1,(A0)
                bne.b   no_repeat
                move.l  inittable,D0
                movea.l D0,A0
                beq.b   no_reload 
no_repeat:      movea.l (A0)+,A1
                move.l  (A0)+,D0
                move.l  A0,tablePointer
                lea     0(A1,D0.l),A0

                move.l  A1,D0
                lea     PCM_START.w,A1  ;Insert Secondary-buffer in the queue.
                movep.w D0,3(A1)
                swap    D0
                move.w  D0,(A1)

                move.l  A0,D0
                movep.w D0,3+PCM_END-PCM_START(A1)
                swap    D0
                move.w  D0,PCM_END-PCM_START(A1)
                rts

no_reload:      ; At this point is the last segment playing - therefor
                ; set the DMA chip into SINGLE, rather than LOOP
                ; playback mode... The DMA chip will then stop after
                ; the sample have been played!
                move.w  #1,PCM_CONTROL.w ; DMA chip in SINGLE mode
                rts


STe_end:        clr.l   -(SP)
                move.w  #Super,-(SP)
                trap    #GemDos
                lea     6(SP),SP

                lea     MFP,A0
                move.b  (A0)+,MFP_EnblA.w
                move.b  (A0)+,MFP_MaskA.w
                move.l  SaveVector,PCM_VECTOR.w
                move.w  #0,PCM_CONTROL.w ;Stop DMA sound chip

                move.l  D0,-(SP)
                move.w  #Super,-(SP)
                trap    #GemDos
                lea     6(SP),SP
                rts


STe_sequence:   move.l  A0,tablePointer ; char **samples
                ext.l   D0
                addq.l  #1,D0           ; int repeat
                beq.b   dontrepeat
                subq.l  #1,D0
                lsl.l   #2,D0
                add.l   A0,D0
                
dontrepeat:     move.l  D0,inittable    ; zero if no rep., else addr.
                
                move.w  D1,-(SP)        ; int speed

                clr.l   -(SP)
                move.w  #Super,-(SP)
                trap    #GemDos
                lea     6(SP),SP
                move.l  D0,OldStack

                lea     MFP,A0
                move.b  MFP_EnblA.w,(A0)+
                move.b  MFP_MaskA.w,(A0)+
                move.l  PCM_VECTOR.w,SaveVector

                move.w  #0,PCM_CONTROL.w ;Stop DMA sound chip
                move.w  (SP),PCM_MODE.w

                move.b  MFP_Data.w,D0   ;Read monitor-type (mono/color)
                eor.b   D0,MFP_Edge.w   ;Enable IRQ on Sound _not_ Active!
                andi.b  #%1111111,MFP_Edge.w ; Sound not Active.
                eor.b   D0,MFP_Edge.w   ; IRQ when sound becomes not active.

                move.l  #DMAinterupt,PCM_VECTOR.w
                bclr    #7,MFP_PendA.w
                bset    #7,MFP_MaskA.w  ;Mask 'Sound Active' interupt.
                bset    #7,MFP_EnblA.w  ;Enable 'Sound Active' interupt

                bsr     DMAmusic
                move.w  #3,PCM_CONTROL.w ;start DMA chip in LOOP mode
                bsr     DMAmusic

                move.l  OldStack,-(SP)
                move.w  #Super,-(SP)
                trap    #GemDos
                lea     8(SP),SP        ;remove params to 'super' and locals...
                rts

                DATA

* soundperiod = (6258,12517,25033)Hz
*             = (1278,639,320,160)Cycles

*               STperiod  = 160 + 12*n
ST_Speed_table: DC.W 93,40,13,0

*               ROMperiod = 96 + 12*n
ROM_Speed_table:DC.W 99,45,19,5


*               PRNperiod = 100 + 12*n
PRN_Speed_table:DC.W 98,45,18,5


GI_tbl:         DC.B $00,$00,$01,$00,$02,$00,$03,$00
                DC.B $04,$00,$05,$00,$06,$00,$07,$FF
                DC.B $08,$00,$09,$00,$0A,$00,$FF,$FF

GI_sample:
                INCLUDE "dac.s"

                BSS
tablePointer:   DS.L 1
inittable:      DS.L 1
OldStack:       DS.L 1
NoRepeat:       DS.W 1
gemSR:          DS.W 1
SaveVector:     DS.L 1
MFP:            DS.B 8
                END
