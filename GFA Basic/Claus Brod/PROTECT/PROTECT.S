*************************
* Track 41 Protector
* Machine code routine for
* protecting track 41
*
* Reads and writes track 41 into or from buffer
* (C) 1987 by Claus Brod
*             Am Felsenkeller 2
*             D-8772 Marktheidenfeld
*             Tel. (West Germany) 09391/3206
*
**************************

*************************
* Some definitions for the long way home
*************************

mfp    = $fffa01          * Address of MFP68901 for polling

daccess= $ff8604          * DMA-Controller, FDC access or sector counter
dmode = $ff8606           * DMA-Controller, DMA mode
dlow   = $ff860d          * DMA-Controller, start of transfer, lowbyte
dmid   = $ff860b          * DMA-Controller, start of transfer, midbyte
dhigh  = $ff8609          * DMA-Controller, start of transfer, highbyte
time   = $40000           * Timeout constant
snd    = $ff8800          * Address of sound chip
sndwrt = $ff8802          * I/O of sound chip

*************************
* Jump into the unknown...
*************************

   bra main               * Jump to program start

*************************
* I/O field for parameter passing
*************************

mode:    .dc.l 0                * 0 = read track 41 into buffer
*                               * 1 = write track 41 from buffer
buf:     .dc.l 0                * buffer address

stk:     .dc.l 0                * buffer for stackpointer

***************************
* main routine; inits and dispatches
***************************
main:
   movem.l d0-d7/a0-a6,-(sp)    * hide them away!
   clr.l d0                     * user stack becomes supervisor stack
   bsr super                    * supervisor mode on
   lea stk(pc),a2               * address of stackpointer buffer
   move.l d0,(a2)               * save stackpointer
   move.l mode(pc),d6           * get mode
   st $43e                      * block disk VBL
   cmp.l #0,d6                  * read track?
   beq rdtrack                  * yessir
   cmp.l #1,d6                  * write track?
   beq wrtrack                  * yesma'am

exitus:
   sf $43e                      * free disk VBL
   lea stk(pc),a2               * address of stackpointer buffer
   move.l (a2),d0               * get old stackpointer
   bsr super                    * supervisor mode off 
   movem.l (sp)+,d0-d7/a0-a6    * get registers
   rts                          * and exit

******************************
* wrfdc: send d7.b to controller
******************************
wrfdc:
   move.w #30,d1                * counter is 30
   bsr as_time_goes_by          * time flies...
   move.w d7,daccess            * d7 into access register of DMA chip
   move.w #30,d1                * counter is 30

******************************
* as_time_goes_by: loop with d1 iterations
******************************
as_time_goes_by:
   dbf d1,as_time_goes_by       * Looping (huiii...)
   rts                          * back to the future

******************************
* wait_until_dawn : waits for FDC IRQ
******************************
wait_until_dawn:
   move.w #250,d1               * wait for BUSY
wt:
   dbra d1,wt

   move.l #time,d1              * timeout constant
poll:
   btst #5,mfp                  * IRQ on MFP?
   beq ready                    * yes, command is executed
   subq.l #1,d1                 * timeout counter shrinks
   bne poll                     * ready already?

   bsr irq                      * interrupt controller
   rts                          * go to Hollywood

***************************
* DMA transfer or FDC ready
***************************
ready:
   move.w #$180,dmode           * command register
   move.w #30,d1                * wait
   bsr as_time_goes_by
   move.w daccess,d0            * read FDC status
   move.w #30,d1                * wait
   bra as_time_goes_by

****************************
* dma: set DMA;IN: d7 start address
****************************
dma:
   move.b d7,dlow               * lowbyte
   lsr.l #8,d7                  * shift one byte
   move.b d7,dmid               * midbyte
   lsr.l #8,d7                  * shift one byte
   move.b d7,dhigh              * highbyte
   rts

*****************************
* super: switches from usermode to
* supervisormode and vice versa
* d0: stackpointer
****************************
super:
   move.l d0,-(sp)              * stackpointer to stack
   move.w #$20,-(sp)            * SUPER
   trap #1                      * in GEMDOS
   addq.l #6,sp                 * correct stack
   rts

**************************
* irq: interrupts the controller
**************************
irq:
   move.b #$D0,d7               * FORCE IRQ
   bsr wrfdc                    * d7 to FDC
   move.w #250,d1               * 250 loops
   bra as_time_goes_by          * patience!

*****************************
* rdtrack: read track 41, side 0 on drive A
*****************************
rdtrack:
  move.w #2,d4                  * select drive A, side 0
  bsr do_select                 * select routine
  move.w #41,d4                 * track 41
  bsr seek_it                   * go for it!
  bsr rdtrk                     * read track
  move.w #0,d4                  * deselect drive A
  bsr do_select
  bra exitus                    * and back to mothership

*****************************
* rdtrk: read track; IN: d4 track to read
*****************************
rdtrk:
   move.l buf(pc),d7            * address of track buffer
   bsr dma                      * init DMA 
   bsr toggle                   * clear DMA status
   move.w #14,d7                * 14 sectors
   bsr wrfdc                    * d7 to FDC
   move.w #$80,dmode            * command register

   move.w #$E0,d7               * ReadTrack command
   bsr wrfdc                    * d7 to FDC
   bsr wait_until_dawn          * wait for command to terminate
   rts

*****************************
* wrtrack: write track 41, side 0 on drive A
*****************************
wrtrack:
   move.w #2,d4                 * drive A, side 0
   bsr do_select                * select it
   move.w #41,d4                * track 41
   bsr seek_it                  * go for it!

   bsr wrtrk                    * write track from buffer
   move.w #0,d4                 * deselect drives
   bsr do_select
   bra exitus                   * don't leave me this way...

*****************************
* wrtrk: write track; IN: d4 track no
*****************************
wrtrk:
   move.l buf(pc),d7            * track buffer address to d7
   bsr dma                      * init DMA 

   move.w #$190,dmode           * toggle read/write line
   move.w #$90,dmode            * clears DMA status
   move.w #$190,dmode           * select sector counter of DMA chip
   move.w #$1F,d7               * 31 sectors
   bsr wrfdc                    * d7 to FDC
   move.w #$180,dmode           * select command register

   move.w #$F0,d7               * WriteTrack command
   bsr wrfdc                    * d7 to FDC
   bsr wait_until_dawn          * wait for command to terminate
   rts

*****************************
* seek_it   : seek track in d4
*****************************
seek_it:
   move.w #$86,dmode            * select data register
   move.w d4,d7                 * get track number
   bsr wrfdc                    * d7 to FDC
   move.w #$80,dmode            * command register
   move.w #17,d7                * seek command for 3ms step rate
   bsr wrfdc                    * d7 to FDC
   bra wait_until_dawn          * wait for FDC

****************************
* toggle: toggles R/W-line of the DMA chip,
* thereby clearing DMA status
****************************
toggle:
   move.w #$90,dmode
   move.w #$190,dmode
   move.w #$90,dmode            * select DMA sector register
   rts

*****************************
* do_select; IN: d4 drive number (2 for A, 4 for B, side no in bit 0)
*****************************
do_select:
   movem.l d0-d7/a0-a6,-(sp)    * save registers
   move.w d4,d7                 * get drive number
   bne mach_mal                 * if not zero, go to start
   move.w #$80,dmode            * status register
motor:
   move.w daccess,d1            * read FDC status
   btst #7,d1                   * motor still running?
   bne motor                    * yessir
mach_mal:
   eor.b #7,d7                  * invert bits
   and.b #7,d7                  * and mask them
   move.w sr,-(sp)              * save status (not necessary here)
   or.w #$700,sr                * switch off interrupts
   move.b #14,snd               * select port A register
   move.b snd,d0                * read port A
   and.b #$f8,d0                * mask the lower three bits
   or.b d0,d7                   * set new side/drive
   move.b d7,sndwrt             * in port A
   move.w (sp)+,sr              * get status back (not necessary)
   movem.l (sp)+,d0-d7/a0-a6    * get registers
   rts                          * and leave me alone


