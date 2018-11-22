;
; PALETTE SPLIT
; allow GFABASIC to do a single palette split after a given amount of scanlines
;
; (c) 2007 by Simon Sunnyboy / Paradize
; http://paradize.atari.org/
;
; USE AT YOUR OWN RISK!
;
;
; ** register equates **

palette         EQU $FFFF8240

iera            EQU $FFFFFA07
ierb            EQU $FFFFFA09
ipra            EQU $FFFFFA0B
iprb            EQU $FFFFFA0D
imra            EQU $FFFFFA13
imrb            EQU $FFFFFA15
isra            EQU $FFFFFA0F
isrb            EQU $FFFFFA11
tbdr            EQU $FFFFFA21
tbcr            EQU $FFFFFA1B

count_scanlines EQU 8
; ** TOS system variables **
_vbclock        EQU $0462
_frclock        EQU $0466

; ** ISR locations ***
vbl             EQU $70
timerb          EQU $0120

; ** jump table **
                bra     init_rasters
                bra     stop_rasters
; ** GFABASIC data interface **
raster_address:
                DC.L 0          ; points to a block with 2 palettes
                DC.B 0,0,0
gap_control:    DC.B 0          ; number of scanlines to wait for split
                EVEN
storage:
                DC.L $00,$00
                DC.B $00,$00,$00,$00,$00
                EVEN
                DC.B "TIMER B PALETTE SPLIT KERNEL by Paradize v1",0
                EVEN
; ** init raster interrupt system **
                PART 'init palette split'
init_rasters:
                movem.l D0-A6,-(SP)
; store interrupt context
                lea     storage(PC),A3
                move.l  vbl,(A3)+       ; save old VBL
                move.l  timerb,(A3)+    ; save old Timer B
                move.b  tbcr,(A3)+
                move.b  tbdr,(A3)+
                move.b  iera,(A3)+
                move.b  ierb,(A3)+
                move.b  imra,(A3)+

; set interrupts
                move    #$2700,SR       ; stop interrupts
                lea     rastercontrol_vbl(PC),A1
                move.l  A1,vbl          ; set new VBL
                lea     raster_timerb(PC),A1
                move.l  A1,timerb       ; set new Timer B

; enable Timer B
                ori.b   #1,iera         ; enable Timer B
                ori.b   #1,imra         ; mask Timer B
                clr.b   tbcr            ; stop Timer B

                move    #$2300,SR       ; reenable interrupts
                movem.l (SP)+,D0-A6
                rts
                ENDPART
; ** disable splitscreen **
                PART 'disable palette split'

stop_rasters:
                move.l  A3,-(SP)

                move    #$2700,SR       ; stop irq system

                lea     storage(PC),A3
                move.l  (A3)+,vbl       ; restore old VBL
                move.l  (A3)+,timerb    ; save old Timer B
                move.b  (A3)+,tbcr      ; restore MFP context
                move.b  (A3)+,tbdr
                move.b  (A3)+,iera
                move.b  (A3)+,ierb
                move.b  (A3)+,imra

                move    #$2300,SR       ; reenable irqs

                movea.l (SP)+,A3
                rts
                ENDPART
; ** new VBL to control the rasters **
                PART 'VBL'
rastercontrol_vbl:
                movem.l D0-D7/A3,-(SP)
                clr.b   tbcr            ; stop Timer B
                lea     raster_address(PC),A3
                movea.l (A3),A3
                movem.l (A3),D0-D7      ; load new palette
; set new palette
                movem.l D0-D7,palette   ; get and set new color, update index
; load gap length
                move.b  gap_control(PC),tbdr
; activate Timer B to count raster lines
                move.b  #count_scanlines,tbcr
                movem.l (SP)+,D0-D7/A3
; push old VBL address onto stack
                move.l  storage(PC),-(SP)
                rts                     ; and jump to it :)
                ENDPART
; ** screensplit handling Timer B ISR **
                PART 'Timer B'
raster_timerb:
                movem.l D0-D7/A2,-(SP)

; set new color from table
                lea     raster_address(PC),A2
                movea.l (A2),A2
                movem.l 32(A2),D0-D7    ; load second palette into registers
                movem.l D0-D7,palette   ; set second palette

                bclr    #0,isra         ; acknowledge Timer B

                movem.l (SP)+,D0-D7/A2
                rte
                ENDPART
                END
