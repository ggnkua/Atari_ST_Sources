* 03FEB92 : RWS : Modified for SP030D card & added NOP's to avoid counter critical area
*       May 26, 87 Update for compatability with field service and manufact.
*       April 22, 87 re-wrote bus timing test: display only if error.
*       Oct 31, 86 Shut int (IP) when disabling MFP int. (Spurious int fix)
*       7 Oct, 86 added RAM bus timing test
*       23 july fixed spurious interrupt bug--enable DE int directly (no call
*               to enabint).
*       11 Apr  error codes
*       18 Feb, 86
*       Added Memory Controller video address register test
        
*       =====================
*          MFP timers
*          Glue video timing
*          Memory Controller
*       =====================

.macro  TESTPT  x
        movem.l d0-d7/a0-a6,-(sp)
        lea.l   tpmsg,a5
        bsr     dspmsg
        move.l  \x,d1
        bsr     dspwrd
        bsr     crlf
        movem.l (sp)+,d0-d7/a0-a6
.endm
        .text
****************************************************************** : FROM TIMER.TT
*       Test MFP timers, which can then be used as reference.
*       Set up timer to interrupt after given period of time,
*       wait in loop, then verify that the interrupt has occurred.
        
*       Clear timer control (timers stopped)
timtst: move.w  #$2400,sr       ;RWS:TEST
        lea     timmsg,a5
        bsr     dsptst
        bsr     wait            ;wait for possible data in RS232 port 
        movea.l #mfp,a0         ;to shift out before changing timer
        clr.b   tacr(a0)
        clr.b   tbcr(a0)
        clr.b   tcdcr(a0)

        bclr.b    #6,imrb(a0)     ;mask the keyboard interrupts for critical 
*                               ;timing of tests
  
*       Set timer data
*       4 counts at 2.4576 MHz / 200 = 325.5 us
        move.b  #4,tadr(a0)
        move.b  #4,tbdr(a0)
        move.b  #4,tcdr(a0)
        move.b  #4,tddr(a0)

*       Set interrupt vectors
        move.l  #timerin,a1
        move.l  a1,$110
        move.l  a1,$114
        move.l  a1,$120
        move.l  a1,$134

*       Enable interrupts at CPU
        move.b  keyboard,d0     ;read stat to assure no irq at 6850
        move.b  iodata+keyboard,d0  ;clear data buffer

        clr.b   erflg0
        moveq   #13,d0          ;timer A
        bsr     enabint         ;set enable, mask bits
        moveq   #tacr,d1        ;get offset for later
        move.b  #7,tacr(a0)     ;start timer /200
        bsr     timdel          ;wait for interrupt, test, and stop timer
        moveq   #13,d0
        bsr     disint          ;disable int

        moveq   #8,d0           ;timer B
        bsr     enabint
        moveq   #tbcr,d1
        move.b  #7,tbcr(a0)
        bsr     timdel
        moveq   #8,d0
        bsr     disint

        moveq   #5,d0           ;timer C
        bsr     enabint
        moveq   #tcdcr,d1
        move.b  #$70,tcdcr(a0)
        bsr     timdel
        moveq   #5,d0
        bsr     disint

        moveq   #4,d0           ;timer D
        bsr     enabint
        moveq   #tcdcr,d1
        move.b  #7,tcdcr(a0)
        bsr     timdel
        moveq   #4,d0
        bsr     disint

        bsr     rsinit          ;set up RS232
        tst.b   erflg0
        beq.s   sync
        movea.l #mfptim,a5      ;"Error 4 MFP"
        bsr     dspmsg

***************************************************
*       Vblank, Hblank, Hblank interrupt

sync:   move.b  #10,index1      ;counter for iterations of this test

;       TESTPT  #1
*--------------------------------
*       Test Vertical blanking (IPL=2)

vtime:  move.b  #7,d0           ;2.4576 MHz/200=12288 Hz
        move.b  #175,d1         ;/175=70 Hz     
        bsr     setout          ;set timer to interrupt after 14.2ms
        move.b  #1,lcount
;       TESTPT #$101
        move.w  #$2200,sr
vloop:  tst.b   lcount          ;wait for a Vblank
        beq.s   vb1
        tst.b   timout
        bne.s   vloop
;       TESTPT  #$11
vserr:  movea.l #vsmsg,a5
        bsr     dspmsg
        bset    #1,erflg0
        bra     vend

*       Got Vblank, restart timer
vb1:
;       TESTPT #$12
        clr.b   tacr+mfp
        move.b  #175,tadr+mfp
        move.b  #7,tacr+mfp     ;/200
        move.b  #1,lcount
        move.b  #1,timout
vb2:    tst.b   lcount          ;wait for next vblank
        beq.s   hblnk           ;...must be within 14.2 ms
        tst.b   timout          ;...or time-out
        bne.s   vb2
        bra.s   vserr
        
*-------------------------------
*       Test Horizontal Blanking (IPL=0)

*       Get set up done early so no time is wasted
hblnk:
;       TESTPT #2
        move.b  #8,tbcr+mfp     ;timer B=event counter (display enable)
        move.b  #1,tbdr+mfp     ;every event
        move.l  #horizbl,$120   ;vector for Hblank interrupt
        bset    #0,imra+mfp     ;enable Timer B int

        move.b  #1,d0           ;2.4576 MHz/4=614400 Hz
        move.b  #15,d1          ;/15=36141 Hz=> 24 us period
        move.b  #1,intflg
        bsr     setout          ;set timer to interrupt after 24 us
        move.w  #$2000,sr       ;start
hloop:  tst.b   intflg          ;wait for an Hblank
        beq.s   hb1
        tst.b   timout
        bne.s   hloop

*       Horizontal Blank error
hserr:  movea.l #hsmsg,a5
        bset    #2,erflg0
herr:   bsr     dspmsg
        bra.s   vend

*       Display Enable error
deerr:  movea.l #demsg,a5
        bset    #3,erflg0
        bra.s   herr

*-------------------------------
*       Test Display Enable (IPL=4)
*       Got Hblank, restart timer, wait for MFP to interrupt
*       next display line (DE), which is 35 hblanks after vblank 
hb1:
;       TESTPT  #3
        move.w  #$2400,sr
        clr.b   tacr+mfp        ;stop timer
        move.b  #1,intflg
        move.b  #1,timout      
        move.b  #13,tadr+mfp    ;set counter 12*81.3=976us
        move.b  #7,tacr+mfp     ;/200=81.3us (start timer A)
        bset    #0,iera+mfp     ;Enable DE  int
        bset    #5,iera+mfp     ;Enable timer A int
hb2:    tst.b   intflg          ;wait for next DE
        beq.s   vend            ;...must be within 28*35=980us
        tst.b   timout          ;...or time-out
        bne.s   hb2
        bra.s   deerr

vend:   move.w  #$2400,sr
        moveq   #8,d0
        bsr     disint
        moveq   #13,d0
        bsr     disint
        move.l  #timerin,$120   ;restore timer B interrupt vector

        sub.b   #1,index1
        bne     vtime

*       Feb 14,86
*       Test video counter in memory control chip
*       Write screen buffers at 1000,1100,1200,1400,1800,2000,
*       4000,8000,10000,20000,40000,80000,...,top of memory.
*       Change video base every vblank, read video address count
*       every 2 scan lines and verify it is within range (2 scan lines).

        
* RWS : TEST      
*       move.b  #$21,imra(a0)
*       move.b  #$0,imrb(a0)    


vctst:  
;       TESTPT #4
        lea     v_bas_h,a0
        lea     v_bas_m,a1
        lea     vadcnth,a2

        move.l  #vcntint,$120   ;install int routine address
        move.w  #$2200,sr       ;allow vblank

*       Write new screen address into video base
        clr.l   d0
        clr.l   d4
        btst    #1,v_shf_mod
        beq     vctst1
        move.l  #160,d5         ;80 bytes/line hi-res * 2 lines
        bra.s   vert
vctst1: move.l  #320,d5         ;160 bytes/line lo-res * 2 lines
        
********************************
*       Loop while next video address<>top of ram
*       Write new screen address into video address register
vert:   lea     vadtbl,a6
        clr.l   d1
        move.w  0(a6,d0),d1     ;get next address from table
*       d1.w = 2 msbytes of address
        move.w  d1,d7           ;copy for top of memory address
        lsr.w   #8,d7           ;shift msb into low byte
*       d7.b = msb of display start
        cmp.b   topram,d7     ;compare high byte to top
        bgt     vcend           ;reached top of memory

        clr.l   scrend
        clr.l   scrsta
        lsl.l   #8,d1           ;shift to 24 bit address size
        move.l  d1,scrsta       ;save start
        add.l   #$7bc0,d1       ;calculate end of screen - 2 lines
        move.l  d1,scrend       ;save end
        move.l  scrsta,d1
        lsr.l   #8,d1           ;shift back to 16 bit address 

*       Wait for vblank
        move.b  #1,lcount
vert2:  tst.b   lcount          ;wait for vblank
        bne.s   vert2

*       Write new screen address
        move.b  d1,(a1)         ;write med
        lsr.w   #8,d1           ;shift high to byte size
        move.b  d1,(a0)         ;write high
        clr.b   $c(a0)          ;write low

*       Wait vblank to load address
        move.b  #1,lcount
vert3:  tst.b   lcount
        bne.s   vert3

*       Read video address every 2 lines
        clr.w   hcount
        clr.l   d6
        move.b  #2,tbdr+mfp     ;interrupt every 2 events
        move.b  #8,tbcr+mfp     ;get in event count mode
        bset    #0,mfp+imra     ;mask for DE
        bset    #0,mfp+iera     ;enable DE int

        move.l  #$40000,a6      ; WHAT's THIS FOR?? : RWS
;       clr.w   TP1count        ; RWS : TEST POINT
*********************************
*       Loop while scrsta<end of screen
*       d5=words/line: 80 or 40
*       Uses:   d2,d3,d4 for address counter
*               d6 for line count--0,2,4,...,200 or 400
*               d1 for compare
dsplin: clr.l   d4              ;clear msb
        cmp.w   hcount,d6       ;wait for next display int
        beq     dsplin
        
        nop                     ; RWS : 03FEB92 : SOME OF THESE
        nop                     ; ARE NEEDED TO AVIOD READING
        nop                     ; THE COUNTER AT A CRITICAL TIME
        nop                     ; (EG: LO NEAR $FF)
        nop
        nop
        nop
        move.b  (a2),d4         ;get high
        swap    d4
*
        move.b  2(a2),d1        ; get mid
        lsl.w   #8,d1
        move.b  4(a2),d1
        or.l    d1,d4
*        movep   2(a2),d4       ;get mid & low
        move.w  hcount,d6       ;save new line count

        cmp.l   scrsta,d4       ;compare address count with start of line
        blt.s   memcntl         ;error if count is less than start      
        add.l   d5,scrsta       ;inc to next line
        cmp.l   scrsta,d4
        bgt.s   memcnth         ;error if greater than 2 lines
;       add.w   #1,TP1count     ; RWS : TEST POINT
        move.l  scrsta,d1
        cmp.l   scrend,d1       ;at end?
        blt.s   dsplin

*       end horiz. loop
********************************

        add     #2,d0           ;inc index for next screen
        bra     vert

*       end vert. loop
********************************

*       End on error
memcntl:
        move.l  scrsta,d3       ;upper limit
        add.l   d5,d3           ;lower limit
        bra.s   memcnte
memcnth:
        move.l  scrsta,d3       ;upper limit
        sub.l   d5,scrsta       ;lower limit
memcnte:        
        lea     memcntm,a5
        bsr     dspmsg          ;display error
        bset    #4,erflg0
        move.l  a0,-(sp)        
;       move.l  d1,-(sp)        ;
;       move.w  TP1count,d1     ;RWS : TEST POINT
;       bsr     dspwrd          ;
;       bsr     dspspc          ;
;       move.l  (sp)+,d1        ;
;       move.l  d4,a0
        bsr     dspadd
        bsr     dspspc
        move.l  scrsta,a0
        bsr     dspadd
        bsr     dspspc
        move.l  d3,a0
        bsr     dspadd
        bsr     crlf
        move.l  (sp)+,a0

*       End video. Restore video address before displaying
vcend:  move.w  #$2400,sr       
        moveq   #8,d0
        bsr     disint
        move.b  #scrmemh,(a0)
        move.b  #scrmemm,(a1)

****************************************
*       Bus timing tests
*       Copy routines to RAM and execute
*       Routines access PSG and 1772 chips to check bus timing:
*       Slow chips will bus error during RAM execution cycle 
        move.l  8,a4
        move.l  #be_tst,8
        lea     bus1ms,a5       ;Print bus error 1
        lea     bustim1,a1
        move.l  #bust1e,d0
        bsr     bustst

        lea     bus2ms,a5       ;Print bus error 1
        lea     bustim2,a1
        move.l  #bust2e,d0
        bsr     bustst
        move.l  a4,8

********************************
*       End all
        
timend: tst.b   erflg0
        bne.s   timen1
        cmp.b   #$ea,initflg    ;called from init. sequence?
*~
        bne     timen3          ;then don't print pass
;         bra     timen3
*~
        lea     pasmsg,a5
        bra.s   timen2
timen1: lea     falmsg,a5
        move    #red,palette
timen2: move.b  #t_TIME,d0
        bsr     dsppf

timen3:
*~
;;;	bsr	initkey		;RWS.TPES : bad idea to do init2key here. It gets done a bit later tho too. Text is now wrong.
        moveq   #6,d0           ;interrupt 6=keybd,midi
        movea.l #midikey,a2     ;address of int routine
        bsr     initint
;        bset    #6,mfp+imrb     ;restore keyboard irq ; RWS.TPEX
*~
        rts                     ;return to test dispatcher
*
********************************

*       Test chip bus timing
*       Copy routine to RAM ($4000), execute
bustst: move.l  #$4000,a0
        bsr     lbmove          ;copy subroutine into RAM
        clr.l   d7
        move.l  #$4000,a0
        jsr     (a0)            ;access the chip from RAM
        tst     d7
        beq     buspas          ;br if no bus error
        bsr     dspmsg          ;display error message
        bset    #5,erflg0
buspas: rts

*       Write to PSG
bustim1:
        move.b  #0,psgsel
        move.b  #0,psgwr
        rts             
bust1e  equ     *-bustim1

*       read 1770 status
bustim2:
        move.w  #$080,fifo      ; examine 1770 status register
        move.w  #$20,d6         ; 0x20 seems about right...
bustm3: dbra    d6,bustm3       ; busy-loop: give 1770 time to settle
        move.w  dskctl,d0       ; read it
        move.w  #$20,d6         ; 0x20 seems about right...
bustm4: dbra    d6,bustm4       ; busy-loop: give 1770 time to settle
        rts
bust2e  equ     *-bustim2

*-------------------------------
*       Display enable interrupt
vcntint:
        add.w   #2,hcount
        bclr    #0,isra+mfp
        rte

*----------------------------------------
*       Wait for timer interrupt to occur
*       set erflg0 if it does not
*       stop timer
*       d1=timer offset from mfp base address

timdel: moveq   #215,d2         ;215cycles*10cycles/instr*.125us=269us  
        move.b  #3,timflg
wtimer: dbra    d2,wtimer
        tst.b   timflg  
        beq.s   nxtimer

        bset    #0,erflg0       ;no need to know which timer

nxtimer:
        clr.b   0(a0,d1)        ;stop timer
        rts

        .data

timmsg: dc.b    'Testing MFP, Glue timing, Video...',cr,lf,eot
mfptim: dc.b    cr,lf,'T0 MFP timer',cr,lf,eot
vsmsg:  dc.b    cr,lf,'T1 Vertical Sync',cr,lf,eot
hsmsg:  dc.b    cr,lf,'T2 Horizontal Sync',cr,lf,eot
demsg:  dc.b    cr,lf,'T3 Display Enable',cr,lf,eot
memcntm:
        dc.b    cr,lf,'T4 Video Counter in Memory Controller',cr,lf,eot
bus1ms: dc.b    'T5 PSG Bus Test ',tab,eot
bus2ms: dc.b    'T6 1772 Bus Test',tab,eot
        .even
vadtbl: dc.w    $0010,$0011,$0012,$0014,$0018,$0020,$0040,$0080
        dc.w    $0100,$0200,$0300,$0400,$0500,$0600,$0700,$0800
        dc.w    $1000,$2000,$3000,$4000,$8000


