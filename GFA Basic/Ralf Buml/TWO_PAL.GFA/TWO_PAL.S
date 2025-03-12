***********************************
*                                 *
*   TWO PALETTES IN GFA BASIC     *
*           CODED BY              *
*   SLEDGE HAMMER OF THE GERMS    *
*                                 *
* ORIGINAL BY JEDI OF SECTOR ONE  *
***********************************

                movem.l D0-D7,-(SP)
                movem.l A0-A7,-(SP)     * Save registers
                btst    #3,$FFFFFA1B.w  * Is the routine already
                bne     restore         * present ? => restore

                lea     pal1(PC),A2     * PALETTEN KOPIEREN
                lea     pal2(PC),A3
                moveq   #8-1,D3
COPY_PALS:      move.l  (A0)+,(A2)+
                move.l  (A1)+,(A3)+
                dbra    D3,COPY_PALS

                move.b  D0,SAVE_FIRST
                move.b  D1,SAVE_SECOND


                sf      $FFFFFA1B.w     * stop the timer B
                lea     saves(PC),A0    * saving buffer
                move.l  $0120.w,(A0)+   * old timer B vector
                lea     $FFFFFA09.w,A1  * MFP vector
                move.b  (A1),(A0)+      * save the old one
                andi.b  #$DF,(A1)       * disable some interrupts
                lea     $FFFFFA07.w,A1  * The same thing...
                move.b  (A1),(A0)+      * ...with dis...
                bset    #0,(A1)         * ...register...
                lea     $FFFFFA13.w,A1  * ...and also...
                move.b  (A1),(A0)       * ...for dis...
                bset    #0,(A1)         *  ...one
                lea     $0118.w,A1      * Key vector
                lea     key(PC),A0      * New key routine
                move.l  (A1),keyjmp-key+2(A0) * But jump to the old one..
                move.l  A0,(A1)         * anyway...
                lea     $70.w,A1        * VBL interrupt vector
                lea     vbl(PC),A0      * New VBL routine
                move.l  (A1),vbljmp-vbl+2(A0) * But jump to the old one..
                move.l  A0,(A1)         * anyway...
                bra     sector1         * End of the inits


vbl:            sf      $FFFFFA1B.w     * disable timer B
                move.b  SAVE_FIRST(PC),$FFFFFA21 * first raster 36 lines away
                move.b  #8,$FFFFFA1B    * enable timer B
                movem.l pal1(PC),D0-D7  * initial border (beige)
                movem.l D0-D7,$FFFF8240.w

                pea     (A0)            * Save a0
                lea     hbl(PC),A0      * Our timer B routine
                move.l  A0,$0120.w      * Placed in the vector
                movea.l (SP)+,A0        * Pop a0


vbljmp:         jmp     0               * pass ontrol to OLD vb vector

hbl:            clr.b   $FFFFFA1B.w     * timer stop
                movem.l D0-A1,-(SP)     * save from corruption
                movea.w #$FA21,A1       *  timer B data register (ie scanline!)
                move.b  SAVE_SECOND(PC),(A1) * next interrupt at 22+36= line 58
                move.b  #8,$FFFFFA1B.w  * allow timer B again

                movem.l pal2(PC),D0-D7
                move.w  D0,-(SP)        * save d0
loop:           move.b  (A1),D0         *  more waiting for...
wait:           cmp.b   (A1),D0         * ... next scanline
                beq.s   wait
                move.w  (SP)+,D0
                movem.l D0-D7,$FF8240

                movem.l (SP)+,D0-A1
                bclr    #0,$FFFFFA0F.w  * end of interrupt
                rte


key:            move    #$2500,SR       * Disable some interrupts
keyjmp:         jmp     0               * But exec the old rout

restore:        sf      $FFFFFA1B.w     * Stop the timer B
                lea     saves(PC),A0    * Saving address
                move.l  (A0)+,$0120.w   * Old timer B vector
                move.b  (A0)+,$FFFFFA09.w * Finally, there isn't...
                move.b  (A0)+,$FFFFFA07.w * ..anything better than..
                move.b  (A0),$FFFFFA13.w * ...the good old things !
                move.l  keyjmp+2(PC),$0118.w * Old key vector
                move.l  vbljmp+2(PC),$70.w * Old VBL vector
sector1:        movem.l (SP)+,A0-A7     * Old registers
                movem.l (SP)+,D0-D7
                rts                     * And old PC !


buffer:         DC.L 0          * Address of the buffer
saves:          DS.L 2          * To put old values...
pal1:           DS.W 16
pal2:           DS.W 16
SAVE_FIRST:     DS.B 1
SAVE_SECOND:    DS.B 1
                END
