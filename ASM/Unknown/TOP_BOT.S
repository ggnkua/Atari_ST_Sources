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
                move.l  $00000120.w,(A0)+
                move.l  $00000134.w,(A0)+
                move.b  $FFFFFA07.w,(A0)+
                move.b  $FFFFFA09.w,(A0)+
                move.b  $FFFFFA13.w,(A0)+
                move.b  $FFFFFA15.w,(A0)+
                move.b  $FFFFFA17.w,(A0)+
                move.b  $FFFFFA19.w,(A0)+
                move.b  $FFFFFA1B.w,(A0)+
                move.b  $FFFFFA1F.w,(A0)+
                move.b  $FFFFFA21.w,(A0)+

; install interrupts
                move    #$2700,SR       ;     stop interrupts
                move.l  #hbi,$00000068.w ;    new hbi
                move.l  #vbi,$00000070.w ;    new vbi
                move.l  #timer_b,$00000120.w ;new timer b
                move.l  #timer_a,$00000134.w ;new timer a
                move.b  #$21,$FFFFFA07.w ;    enable timer a & b
                move.b  #$21,$FFFFFA13.w ;
                move.b  #0,$FFFFFA09.w  ;     stop interrupts
                move.b  #0,$FFFFFA15.w
                bclr    #3,$FFFFFA17.w  ;     automatic end of innterrupt
                move.b  #0,$FFFFFA19.w  ;     stop timer a
                move.b  #0,$FFFFFA1B.w  ;     stop timer b
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
                move.l  (A0)+,$00000120.w
                move.l  (A0)+,$00000134.w
                move.b  (A0)+,$FFFFFA07.w
                move.b  (A0)+,$FFFFFA09.w
                move.b  (A0)+,$FFFFFA13.w
                move.b  (A0)+,$FFFFFA15.w
                move.b  (A0)+,$FFFFFA17.w
                move.b  (A0)+,$FFFFFA19.w
                move.b  (A0)+,$FFFFFA1B.w
                move.b  (A0)+,$FFFFFA1F.w
                move.b  (A0)+,$FFFFFA21.w
                move    #$2300,SR       ; start interrupts
                rts

vbi:            move.b  #0,$FFFFFA19.w  ; stop timer a
                move.b  #99,$FFFFFA1F.w ; wait a while
                move.b  #4,$FFFFFA19.w  ; start timer a

                move.b  #0,$FFFFFA1B.w  ; stop timer b
                move.b  #228,$FFFFFA21  ; wait 229 lines
                move.b  #8,$FFFFFA1B.w  ; start timer b
                rte

timer_a:
                move    #$2100,SR       ; ipl=1(hbl)
                stop    #$2100          ; wait for processor hbl
                move    #$2700,SR       ; (we are now synced with 8 cycles!!!)
                move.b  #0,$FFFFFA19.w  ; stop timer a
                DCB.W 84,$00004E71 ;       wait 336 cycles
                move.b  #0,$FFFF820A.w  ; zap into 60hz
                DCB.W 10,$00004E71 ;       wait 40 cycles
                move.b  #2,$FFFF820A.w  ; switch back to 50hz
hbi:            rte


timer_b:        move.b  #0,$FFFFFA1B.w  ; stop timer b
                movem.l D0/A0,-(SP)     ; save d0 & a0

; wait for next line

                lea     $FFFFFA21.w,A0
                move.b  #200,(A0)
                move.b  #8,$FFFFFA1B.w  ; start timer b
                move.b  (A0),D0
wait:           cmp.b   (A0),D0
                beq.s   wait
                DCB.W 4,$00004E71 ;        wait 16 cycles
                move.b  #0,$FFFF820A.w  ; into 60 hz
                DCB.W 12,$00004E71 ;       wait 48 cycles
                move.b  #2,$FFFF820A.w  ; into 50 hz
                movem.l (SP)+,D0/A0     ; restore d0 & a0
                rte
		
		BSS
save_buffer	ds.b 128               