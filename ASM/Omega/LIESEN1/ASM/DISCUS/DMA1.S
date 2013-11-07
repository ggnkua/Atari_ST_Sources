                OPT P+
                pea     super(pc)
                move.w  #38,-(a7)
                trap    #14
                addq.l  #6,a7
                clr.w   -(a7)
                trap    #1

super:

                lea     dma_load(pc),a0
                lea     buffert(pc),a1
                move.l  a1,2(a0)
                move.w  #0,6(a0)
                move.w  #0,8(a0)
                move.w  #1,10(a0)
                move.w  #100,12(a0)
                lea     dma_done(pc),a1
                move.l  a1,14(a0)
                jsr     (a0)

loop:           not.w   $FFFF8240.w
a:              bra.s   loop
                rts

dma_done:       lea     a(pc),a0
                move.w  #$4E71,(a0)
                rts


dma_load:       >PART 'DMA Loader'
**************************************************************
z1:             bra.s   dma_start
dest_addr:      DS.L 1                            ; 2
side:           DS.W 1                            ; 6    ; 0-1
track:          DS.W 1                            ; 8    ; 0-79
sector:         DS.W 1                            ; 10   ; 1-9
sector_count:   DS.W 1                            ; 12
finished_jsr:   DS.L 1                            ; 14  (jumped when finished)

* Made by LYNX, altered by Omega to make IRQ knowledge and sending
* data to loader. Omega also made it PC relative.

dma_start:      btst    #1,$FFFFFC00.w            *Wait for dma
                beq.s   dma_start
                move.l  a0,-(a7)
                lea     z1(pc),a0
                move.b  $FFFF8209.w,mfp-z1(a0)
                move.b  $FFFFFA15.w,mfp+1-z1(a0)
                move.b  $FFFFFA11.w,mfp+2-z1(a0)

                move.b  dest_addr+3(pc),$FF860D   ;Address
                move.b  dest_addr+2(pc),$FF860B
                move.b  dest_addr+1(pc),$FF8609

                move.b  #14,$FFFF8800.w           *Side 0
                move.b  $FFFF8800.w,d0
                and.b   #$F8,d0                   ; maska
                tst.w   side-z1(a0)
                bne.s   otherside
                bset    #0,d0
otherside:      move.b  d0,$FFFF8802.w

                move.w  #200,sector_count-z1(a0)

                bset    #7,$FFFFFA09.w
                bset    #7,$FFFFFA15.w

                move.w  #$86,$FFFF8606.w          *Seek track!
                move.w  track(pc),$FFFF8604.w
                move.w  #$80,$FFFF8606.w
                move.w  #$13,$FFFF8604.w

                move.l  $011C.w,safe_irq-z1(a0)
                lea     dma_irq(pc),a0
                move.l  a0,$011C.w
                bclr    #7,$FFFFFA11.w
                movea.l (a7)+,a0

dummy:          rts


dma_irq:        move.l  a0,-(a7)
                move.w  #$90,$FFFF8606.w          *Read sector
                move.w  #$0190,$FFFF8606.w
                move.w  #$90,$FFFF8606.w
                move.w  #1,$FFFF8604.w
                move.w  #$84,$FFFF8606.w
                move.w  sector(pc),$FFFF8604.w
                move.w  #$80,$FFFF8606.w
                move.w  #$80,$FFFF8604.w

                lea     irq(pc),a0
                move.l  a0,$011C.w
                bclr    #7,$FFFFFA11.w

                movea.l (a7)+,a0
                rte
**************
irq:            move.l  a0,-(a7)
                lea     sector_count(pc),a0
                subq.w  #1,(a0)                   *Decrease counter
                tst.w   (a0)
                bne.s   not_finish

                move.l  safe_irq(pc),$011C.w      ; --Done
                move.b  mfp(pc),$FFFF8209.w
                move.b  mfp+1(pc),$FFFFFA15.w
                move.b  mfp+2(pc),$FFFFFA11.w
                movea.l finished_jsr(pc),a0
                jsr     (a0)
                movea.l (a7)+,a0
                rte

not_finish:     lea     sector(pc),a0
                addq.w  #1,(a0)                   *Add sector
                cmpi.w  #9,(a0)
                ble.s   no_step1                  *Time for step?
                move.w  #1,(a0)
                lea     track(pc),a0
                addq.w  #1,(a0)

                move.w  #$80,$FFFF8606.w          *Step in
                move.w  #$51,$FFFF8604.w

                lea     no_step2(pc),a0
                move.l  a0,$011C.w
                bclr    #7,$FFFFFA11.w

                movea.l (a7)+,a0
                rte

no_step1:       movea.l (a7)+,a0
no_step2:       bra     dma_irq


*#########################
mfp:            DS.L 1
safe_irq:       DS.L 1
******************************************************************
                ENDPART

buffert:        DS.B 200*512
                END
