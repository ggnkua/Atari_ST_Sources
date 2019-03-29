* A little source to play mad max music. Originally by Zippy of The
* Medway Boys and modified to run from STOS by Neil W Stewart.
* To use it from STOS:
*    load "music.prg",15
* then "call start (15) + 28" to turn it on/off
* It'll assemble from DEVPAC or Turbo Asm.
*

        tst.w   muson
        bne     ison

        bsr on
        move.w  #1,muson
        rts

ison    bsr off
        clr.w   muson
        rts

zippy   movem.l d0-a6,-(sp)                     
        bsr (music+8)              ; change to +2 for Count Zero
        movem.l (sp)+,d0-a6                     
        move.l oldint,-(sp)                     
        rts                                     

on      move.l $70.w,oldint                     
        moveq #1,d0                ; music number to play                             
        bsr music                               
        move.l #zippy,$70.w                     
        rts

off     move.l oldint,$70.w                     
        move.l #$08080000,$ff8800               
        move.l #$09090000,$ff8800               
        move.l #$0a0a0000,$ff8800               
        rts

oldint  dc.l 0
muson   dc.w 0

music   incbin "madmax.mus"        ; your music file
