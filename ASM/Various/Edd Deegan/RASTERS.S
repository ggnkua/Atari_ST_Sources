* \A long routine that openes the lower border, AND consistently
*  leaves a couple of large rasters on screen.

* \This routine was originally adapted from an article by ST NEWS,
*  written, I think, by Stefan Posthuma, which in turn was based on
*  code fragmments by TEX - The Exceptions.

                clr.l   -(sp)           * Supervisor mode on
                move.w  #$20,-(sp)
                trap    #1
                move.l  D0,savereg
                
                move.l  #$70000,A7      * Place stack at $70000

                move.l  #moff,-(sp)     * Disable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A00A

                move.w  #4,-(sp)        * Get resolution   
                trap    #14
                addq.l  #2,sp
                move.w  D0,oldrez       * Save old resolution
                move.l  $44E,oldscr     * Save old physic address
                move.l  #$70000,screen  * New screen will be at $78000

                movem.l $FFFF8240.w,D0-D7       * Set colors
                movem.l D0-D7,oldpal

                bsr     prepare         * Dummy graphics
                bsr     hblon           * Enable interrupts

* \End of initialisation section

* \User routine comes here...

                move.w  #1,-(sp)        * Wait for a key
                trap    #1
                addq.l  #2,sp

                bsr     hbloff          * Disable interrupts

* \End of usr routine - now restore old data

                movem.l oldpal,D0-D7    * Restore pallette
                movem.l D0-D7,$FFFF8240.w
                move.w  oldrez,-(sp)    * Restore resolution
                move.l  oldscr,-(sp)
                move.l  oldscr,-(sp)
                move.w  #5,-(sp)
                trap    #14
                add.l   #12,sp

                move.l  #mon,-(sp)      * Re-enable mouse
                clr.w   -(sp)
                move.w  #25,-(sp)
                trap    #14
                addq.l  #8,sp
                dc.w    $A009

                move.l  savereg,-(sp)   * Leave supervisor mode
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp

                clr.w   -(sp)           * Back to GEM
                trap    #1
****************************************************************
* \Storage/Variables for above sections

oldrez:         dc.w    0
oldscr:         dc.l    0
savereg:        dc.l    0
screen:         dc.l    0
oldpal:         ds.w    16
mon:            dc.b    $08
moff:           dc.b    $12

                EVEN

hblon:          move.l  $120,oldtb              * Old TimerB Vector
                move.l  $70,old4                * Old VBL vector
                move.l  $70,new4b+2             * New VBL will jump to old
                move.b  $FFFFFA07,old07         * Timer B enable
                move.b  $FFFFFA09,old09         * Timer C enable
                move.b  $FFFFFA0f,old0f         * Timer B in-service
                move.b  $FFFFFA11,old11         * Timer C in-service
                move.b  $FFFFFA1b,old1b         * Timer B control
                and.b   #$DF,$FFFA09            * Disable Timer C
                and.b   #$FE,$FFFA07            * Disable Timer B
                move.l  #newtb2,$120            * New Timer B vector
                move.l  #new4,$70               * New VBL vector
                or.b    #1,$FFFFFA07            * Enable Timer B
                or.b    #1,$FFFFFA13            * Set Timer B mask
                rts

hbloff:         move.w  sr,-(sp)
                move.w  #$2700,sr
                move.b  old07(pc),$FFFFFA07
                move.b  old09(pc),$FFFFFA09
                move.b  old0f(pc),$FFFFFA0F
                move.b  old11(pc),$FFFFFA11
                move.b  old1b(pc),$FFFFFA1B
                move.l  oldtb,$120
                move.l  old4,$70
                move.w  (sp)+,sr
                rts

* \Storage for old Timer values....
old4:           dc.l    0
oldtb:          dc.l    0
old07:          dc.b    0
old09:          dc.b    0
old0f:          dc.b    0
old11:          dc.b    0
old1b:          dc.b    0

                EVEN

*\ This is the new VBL handler

new4:           clr.b   $FFFFFA1B.w     * Disable Timer B
                move.b  #40,$FFFFFA21   * Time for interrupt (40th line)

* \EG: At line 40 - TimerB interrupt occurs, and jump to vector at $120

                move.b  #8,$FFFFFA1B    * Enable Timer B again
                move.w  #$0,$FF8240     * Index 0 - BLACK
                move.l  #newtb2,$120    * Change vector for next interrupt
new4b:          jmp     $12345678       * JMP to old routine....

* \The JMP $12345678 will have been replaced with the old address,
*  with move.l  old,new4b+2!

newtb2:         clr.b   $FFFFFA1B.w             * Disable TimerB
                movem.l D0-D7/A0-A1,-(sp)       * Store Registers
                move.w  #$FA21,A1               * A1 = FFFFA21
                move.b  #40,(A1)        * Down another 40 lines
                move.l  #newtb3,$120    * Place the new vector address
                move.b  #8,$FFFFFA1B.w  * Enable Timer

                move.w  #14,D1          * Raster is 14 scanlines
                move.l  #pal1,A0        * Point to palette
loop2           move.b  (A1),D0         * Read TimerB into D0
wait2           cmp.b   (A1),D0
                beq     wait2           * Wait 1 scanline
                move.w  (A0)+,$FF8240   * Colours over black only
                dbra    D1,loop2

                movem.l pal1,D1-D7/A0   * Store palette data
                move.b  (A1),D0
waity           cmp.b   (A1),D0
                beq     waity           * Wait one scanline
                movem.l D1-D7/A0,$FF8240
                
                movem.l (sp)+,D0-D7/A0-A1       * Restore registers
                bclr    #0,$FFFFFA0f.w          * Disabel interrupt
                rte

* The above 'newtb's set the bars.


newtb3:         clr.b   $FFFFFA1B.w             * Disable interrupt
                movem.l D0-D7/A0-A1,-(sp)       * Store registers
                move.w  #$FA21,A1               * A1 = FFFFA21
                move.b  #119,(A1)                * Kill border at line 199
                move.l  #killborder,$120        * Set vector
                move.b  #8,$FFFFFA1B.w          * Enable TimerB

                move.w  #14,D1
                move.l  #pal1+26,A0     * Point to other table
loop3           move.b  (A1),D0         * Wait for scanline
wait3           cmp.b   (A1),D0
                beq     wait3
                move.w  (A0)+,$FF8240   * Set colours
                dbra    D1,loop3

                movem.l pal1,D1-D7/A0   * Store palette in registers
                move.b  (A1),D0
waitz           cmp.b   (A1),D0
                beq     waitz           * Wait for a scanline
                movem.l D1-D7/A0,$FF8240        * Set the colours
                
                movem.l (sp)+,D0-D7/A0-A1       * Restore registers
                bclr    #0,$FFFFFA0f.w  * End of interrupt
                rte

* \Removes the lower border

killborder      clr.b   $FFFFFA1B.w     * Disable B
                movem.l D0-D1/A0-A1,-(sp)       * Store registers
                move.w  #$fA21,A1               * A1 = FFFFFA21
                move.b  #200,(A1)
                move.b  #8,$FFFFFA1B.w          * Enable TimerB

                move.b  (A1),D0
wait4:          cmp.b   (A1),D0         * wait last scanline
                beq     wait4           
                clr.b   $FFFF820A.w     * 60 Hz
                moveq   #4,D0
nopi2:          nop                     * wait a while
                dbf     D0,nopi2
                move.b  #2,$FFFF820A.w  * 50 Hz
                movem.l (sp)+,D0-D1/A0-A1       * Restore Registers      
                bclr    #0,$FFFFFA0f.w  * End of interrupt
                rte

* Now some routines to set the graphics

prepare:        move.w  #0,-(sp)        ;set low res
                move.l  screen(pc),-(sp)
                move.l  screen(pc),-(sp)
                move.w  #5,-(sp)
                trap    #14
                add.l   #12,sp

                movem.l graphic(pc),D6-D7
                move.l  screen(pc),A0
                move.w  #260-1,D1       ;fill 260 scanlines

line:           moveq   #20-1,D0        ;20 planes = one scanline
fill:           move.l  D6,(A0)+
                move.l  D7,(A0)+
                dbf     D0,fill
                dbf     D1,line

                movem.l pal1(pc),D0-D3
                movem.l D0-D3,$FFFF8240.w
                rts

graphic:        dc.w    $55AA,$33CC,$0FF0,$0000

pal1:           dc.w    $000,$100,$200,$300,$400,$500,$600,$700
                dc.w    $600,$500,$400,$300,$200,$100
                dc.w    $110,$220,$330,$440,$550,$660,$770
                dc.w    $660,$550,$440,$330,$220,$110,$000
