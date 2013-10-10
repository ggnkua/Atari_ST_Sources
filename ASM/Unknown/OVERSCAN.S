                pea     rutin(PC)
                move.w  #38,-(SP)       ;superexec
                trap    #14
                addq.l  #6,SP

                move.w  #0,-(SP)        ;pterm 0
                trap    #1

rutin:

; save interrupts
                lea     save_buffer(PC),A0
                move.l  $00000068.w,(A0)+
                move.l  $00000070.w,(A0)+
                move.l  $00000134.w,(A0)+
                move.b  $FFFFFA07.w,(A0)+
                move.b  $FFFFFA09.w,(A0)+
                move.b  $FFFFFA13.w,(A0)+
                move.b  $FFFFFA15.w,(A0)+
                move.b  $FFFFFA17.w,(A0)+
                move.b  $FFFFFA19.w,(A0)+
                move.b  $FFFFFA1F.w,(A0)+

; install interrupts
                move    #$2700,SR       ;     stop interrupts
                move.l  #hbi,$00000068.w ;    new hbi
                move.l  #vbi,$00000070.w ;    new vbi
                move.l  #timer_a,$00000134.w ;new timer a
                move.b  #$20,$FFFFFA07.w ;    enable timer a
                move.b  #$20,$FFFFFA13.w ;
                move.b  #0,$FFFFFA09.w  ;     stop interrupts
                move.b  #0,$FFFFFA15.w
                bclr    #3,$FFFFFA17.w  ;     automatic end of innterrupt
                move.b  #0,$FFFFFA19.w  ;     stop timer a
                move    #$2300,SR       ;     start interrupts

no_key:         btst    #0,$FFFFFC00.w  ;  any key waiting?
                beq.s   no_key
                cmpi.b  #$39,$FFFFFC02.w ; space?
                bne.s   no_key

; restore interrupts
                move    #$2700,SR       ; stop interrupts
                lea     save_buffer(PC),A0
                move.l  (A0)+,$00000068.w
                move.l  (A0)+,$00000070.w
                move.l  (A0)+,$00000134.w
                move.b  (A0)+,$FFFFFA07.w
                move.b  (A0)+,$FFFFFA09.w
                move.b  (A0)+,$FFFFFA13.w
                move.b  (A0)+,$FFFFFA15.w
                move.b  (A0)+,$FFFFFA17.w
                move.b  (A0)+,$FFFFFA19.w
                move.b  (A0)+,$FFFFFA1F.w
                move    #$2300,SR       ; start interrupts
                rts

vbi:            move.b  #0,$FFFFFA19.w  ; stop timer a
                move.b  #99,$FFFFFA1F.w ; wait a while
                move.b  #4,$FFFFFA19.w  ; start timer a

                rte

timer_a:
                move    #$2100,SR       ; ipl=1(hbl)
                stop    #$2100          ; wait for processor hbl
                move    #$2700,SR       ; (we are now synced with 8 cycles!!!)
                move.b  #0,$FFFFFA19.w  ; stop timer a
                movem.l D0-D1/A0,-(SP)
                DCB.W 76,$00004E71 ;       wait ??? cycles
                move.b  #0,$FFFF820A.w  ; zap into 60hz
                DCB.W 6,$00004E71 ;       wait ?? cycles
                lea     $FFFF8209.w,A0
                moveq   #127,D1
                move.b  #2,$FFFF820A.w  ; switch back to 50hz

sync:           tst.b   (A0)
                beq.s   sync
                move.b  (A0),D0
                sub.b   D0,D1
                lsr.l   D1,D1


                move.w  #227,D0
                DCB.W 64,$00004E71


; 2-229
scans_228:
                DCB.W 6,$00004E71
                move.b  #2,$FFFF8260.w
                move.b  #0,$FFFF8260.w
                DCB.W 87,$00004E71
                move.b  #0,$FFFF820A.w
                move.b  #2,$FFFF820A.w
                DCB.W 8,$00004E71
                move.b  #1,$FFFF8260.w
                move.b  #0,$FFFF8260.w
                dbra    D0,scans_228

; 230
                DCB.W 1,$00004E71
                move.b  #0,$FFFF820A.w
                move.b  #2,$FFFF8260.w
                move.b  #0,$FFFF8260.w
                move.b  #2,$FFFF820A.w
                DCB.W 83,$00004E71
                move.b  #0,$FFFF820A.w
                move.b  #2,$FFFF820A.w
                DCB.W 6,$00004E71
                move.w  #43,D0
                move.b  #1,$FFFF8260.w
                move.b  #0,$FFFF8260.w
                DCB.W 3,$00004E71

; 231-274
scans_44:
                DCB.W 6,$00004E71
                move.b  #2,$FFFF8260.w
                move.b  #0,$FFFF8260.w
                DCB.W 87,$00004E71
                move.b  #0,$FFFF820A.w
                move.b  #2,$FFFF820A.w
                DCB.W 8,$00004E71
                move.b  #1,$FFFF8260.w
                move.b  #0,$FFFF8260.w
                dbra    D0,scans_44

                movem.l (SP)+,D0-D1/A0
hbi:            rte

                BSS
save_buffer:    DS.B 512
                END
