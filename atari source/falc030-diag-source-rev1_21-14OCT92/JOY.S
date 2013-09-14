        .include hardware
        .include defs
        .include nvram
        .include macros

.macro  TESTPT  x
        movem.l d0-d7/a0-a6,-(sp)
        lea.l   tpmsg,a5
        bsr     dspmsg
        move.l  \x,d1
        bsr     dspwrd
        bsr     crlf
        movem.l (sp)+,d0-d7/a0-a6
.endm

        .globl jvblank,portst
*       Printer and joystick port test

*       July 11, 89: read RAM before video count to get in synch
*       June 22, 89: test STe game controller ports
*       light gun test for lower right corner of screen is commented out
*       Sept 22, 88: do not select floppy
*       Feb 2, 87
* 7/9/92 TLE added genlock test

* NOTE: LIGHT GUN TEST FAILS EVERY TIME WITH A VGA MONITOR

padlo   equ     $10
padhi   equ     $80

        .text
portst:
        movea.l #portmsg,a5
        bsr     dsptst

*       bsr     DSPSSITEST      ; test DSP SSI CONNECTOR

        lea     erflg0,a0
        moveq   #8,d7
pclrfl: clr.b   (a0)+     ;clear error flags
        dbra    d7,pclrfl
        
        move.w  #$2700,sr       ;no interruptions

*       ==============
*       Walk 1 across 8 bits of printer port

*       For data=1,2,4,8...
*         Write out the printer port, latch data, and read in
        lea     psgwr,a0
        lea     psgsel,a1

        move.b  #1,d0
wrpp:   move.b  #$7,(a1)
        move.b  #$c0,(a0)       ;A and B are outputs
        move.b  #$e,(a1)
        move.b  #$27,(a0)       ;set strobe to allow cbusy to change
        move.b  #$f,(a1)        ;select B
        move.b  d0,(a0)  ;output data
        bsr     platch    ;latch printer port output 
        move.b  #$f,(a1)
        move.b  (a1),d1  ;read port
        cmp.b   d0,d1
        beq.s   wrpp0
        or.b    d0,erflg0       ;set flag       
wrpp0:  lsl.b   #1,d0
        bne.s   wrpp

*       Test cbusy
tcbhi:  move.b  #$80,d0
        bsr     tcbusy

        btst    #0,mfp+gpip     ;cbusy=?
        beq.s   tcblo      ;latch output gets inverted, input on cbusy
        bset    #0,erflg1

tcblo:  move.b  #0,d0
        bsr     tcbusy
        btst    #0,mfp+gpip     ;cbusy=?
        bne.s   joytst
        bset    #1,erflg1

*       ========
*       Test joystick ports

joytst:
        move.w  #$2400,sr
        moveq   #$15,d1
        bsr     ikbdput  ;set keyboard to joystick interrogation
        bne     jkbdf      ;br if 6850 time-out
        move.b  #7,(a1)
        move.b  #$c0,(a0)       ;output
        move.b  #$e,(a1)
        move.b  #$27,(a0)       ;strobe hi; disable latch
        move.b  #$f,(a1)

*       Trigger 0
        move.b  #$80,(a0)       ;joy 0 trigger  
;        nop             ; mini delays for COPS keyboards that might be slow
 ;       nop
  ;      nop
   ;     nop
        bsr     wait
        bsr     wait

        bsr     joystat  ;get joystick status
        beq     jkbdf      ;br if t-o
        btst    #7,d0
        bne.s   j1
        bset    #0,erflg2

*       Trigger 1
j1:     move.b  #$40,(a0)       ;joy 1 trigger
;        nop
 ;       nop             ; mini delays for COPS keyboards that might be slow
  ;      nop             ; as yet untested.
   ;     nop
        bsr     wait
        bsr     wait

        bsr     joystat
        beq     jkbdf      ;br if t-o
        btst    #7,d1
        bne.s   j2
        bset    #1,erflg2

*       Test 8 joystick directions
j2:     moveq   #0,d2      ;index for 8 joystick direction bits
        movea.l #joytbl,a2
        movea.l #joyval,a3
jlp:    move.b  0(a2,d2),d1     ;get byte to output 
        move.b  #$f,(a1)
        move.b  d1,(a0)  ;out the printer port, thru mplxer to joystick
;        nop
;        nop             ; mini delays for COPS keyboards that might be slow
;        nop
;        nop
        bsr     wait
        bsr     wait

        bsr     joystat
        beq     jkbdf      ;br if t-o
        andi.b  #$f,d0    ;save low 4 bits
        lsl.b   #4,d1      ;move low 4 bits to high
        or.b    d1,d0      ;make it all one byte
        cmp.b   0(a3,d2),d0     ;compare to expected value
        beq.s   jlp1
        bset    d0,erflg3
jlp1:   addq    #1,d2
        cmpi.b  #8,d2
        bne.s   jlp

        move.b  #$c0,(a0)       ;disable mplxer, triggers hi to enable keys
        move.b  #$1a,d1
        bsr     ikbdput  ;normal keyboard mode

        move.w  #300,d0  ;wait some time for keyboard event to happen
jlp2:   bsr     wait        ;...sometimes get $90 back from keyboard
        dbra    d0,jlp2  ;...which stops test in continuous mode

* RWS : 18JUN92 : Added because sparrow chokes. I don't think this ever worked right.
        bsr     ikbdptr         ; get a0 and a1 = ikbdstuff..   
*****
        clr.w   ibufhead(a0)    ;clear buffer pointers
        clr.w   ibuftail(a0)

*       ========
*       Check for errors 
portend:
        tst.b   erflg0
        beq.s   pf1
        movea.l #pportf,a5      ;printer port
        bsr     dspmsg
        moveq   #7,d0      ;display good and bad bits
prte1:  move.b  #'0',d1
        btst    d0,erflg0
        beq.s   prte2
        move.b  #'1',d1
prte2:  bsr     ascii_out       ;display 0 if ok, 1 if bad
        lsr.b   #1,d0
        bne.s   prte1      ;until 8 bits displayed 
        bsr     crlf

pf1:    tst.b   erflg1
        beq.s   pf2
        movea.l #cbusyf,a5      ;cbusy
        bsr     dspmsg
pf2:    btst    #0,erflg2
        beq.s   pf21
        movea.l #joybl,a5       ;left button
        bsr     dspmsg
pf21:   btst    #1,erflg2
        beq.s   pf3
        movea.l #joybr,a5       ;right button
        bsr     dspmsg
pf3:    move.b  erflg3,d0       
        andi.b  #$f,d0
        beq.s   pf4
        movea.l #joydf0,a5      ;joy 0
        bsr     dspmsg
pf4:    move.b  erflg3,d0       
        andi.b  #$f0,d0
        beq.s   gpst0
        movea.l #joydf1,a5      ;joy 1
        bsr     dspmsg
        bra.s   gpst0

*       Timed-out sending or receiving keyboard
jkbdf:  movea.l #joyto,a5       ;keyboard time-out
        bsr     dspmsg
        bset    #7,erflg2

*       Test monochrome monitor input
gpst0:
;       lea     mfp,a0
;       btst    #7,gpip(a0)
;       beq     gundon    ;bra to exit if mono else test game port
        
*       test STe game controller ports

***********************************
*       test joystick direction I/O
*       data latch on test fixture is controlled by printer data lines:
*       pd0=enable lower data latch, pd1=strobe data, pd2=enable upper data
*       collect errors in erflg4,5
gpst:
	lea     psgwr,a1
        lea     psgsel,a2
        move.b  #$7,(a2)
        move.b  #$c0,(a1)       ;psg output
        move.b  #$f,(a2)        ;select psg b
        move.b  #$0,(a1)        ;all low

*       test lower joy data (joy0 + joy2)
        move.l  #1,d0

*       output data, latch it
outgp1: move.b  d0,gamec20      ;output joy data
        move.b  #$f,(a2)        ;select psg b
        move.b  #$2,(a1)        ;strobe high
        nop
        move.b  #$0,(a1)        ;strobe low

*       enable latch 
        move.b  gamec20,d1      ;read joy to make it input
        move.b  #$f,(a2)        ;select psg b
        move.b  #1,(a1)  ;output high to enable latch
        nop

*       read data from joystick port and compare with data written
        move.b  gamec20,d1      ;read back data
        move.b  #$f,(a2)
        move.b  #$0,(a1)        ;disable latch
        cmp.b   d0,d1
        beq.s   nxgpo1
        eor.b   d0,d1
        or.b    d1,erflg4

*       shift bit across and repeat if not at end
nxgpo1: lsl     d0
        cmp     #$100,d0
        blt     outgp1

*       test joystick upper data (joy1 + joy3)
*       output data, latch it
        move    #1,d0
outgp2: move.b  d0,gamec20      ;output joy data
        move.b  #$f,(a2)        ;select psg b
        move.b  #$2,(a1)        ;strobe high
        nop
        move.b  #$0,(a1)        ;strobe low

*       enable latch (one of two)
        move.b  gamec20,d1      ;read joy to make it input
        move.b  #$f,(a2)        ;select psg b
        move.b  #4,(a1)  ;output high to enable latch
        nop

*       read data from joystick port and compare with data written
        move.b  gamec31,d1      ;read back data
        move.b  #$f,(a2)
        move.b  #$0,(a1)        ;disable latch
        cmp.b   d0,d1
        beq.s   nxgpo2
        eor.b   d0,d1
        or.b    d1,erflg5

*       shift bit across and repeat if not at end
nxgpo2: lsl     d0
        cmp     #$100,d0
        blt     outgp2

        tst.w   erflg4    ;2 bytes of error flag
        beq.s   gpfire

        lea     gpomsg,a5
        bsr     dspmsg    
        move    erflg4,d1
        bsr     dspwrd
        bsr     crlf

*********************************
*       test fire button inputs: use joy 0 outputs
*       erflg6
gpfire:
	lea     gamefr,a0
        move.b  #$fe,d0  ;using joy 0
gpfro:  move.b  d0,2(a0)        ;output joy
;---
        move.w  #20,d3  ; I hope nobody wants this register
.lp:    nop
        dbra    d3,.lp  
;---
        move.b  (a0),d1  ;input fire
        not.b   d1
        or.b    #$f0,d1  ;low nibble is fire button status
        cmp.b   d0,d1
        beq.s   gpfr
        eor.b   d0,d1
        or.b    d1,erflg6
gpfr:   rol.b   d0
        cmp.b   #$ef,d0  ;test 4 bits
        bne.s   gpfro
        cmp.b   #0,erflg6
        beq.s   gppad

        lea     gpfmsg,a5
        bsr     dspmsg
        move.b  erflg6,d1
        bsr     dspbyt
        bsr     crlf

*********************************
*       test paddle inputs:
*       printer d0 controls analog switch for resistance
*       collect errors int erflg7
gppad:
	lea     paddle,a0
        lea     gamec20,a1
        lea     psgsel,a2
        lea     psgwr,a3
        move.b  #$ff,(a1)       ;output for max current
        move.b  #$f,(a2)        ;select psg b
        move.b  #$0,(a3)        ;switch on 1M
        clr     d6
        bsr     getpad    ;read paddles (should be max)
        move.b  #padhi,d7       ;compare against lower limit
        cmp.b   d7,d0
        bhi.s   pad1
        bset    #0,d6
pad1:   cmp.b   d7,d1
        bhi.s   pad2
        bset    #1,d6
pad2:   cmp.b   d7,d2
        bhi.s   pad3
        bset    #2,d6
pad3:   cmp.b   d7,d3
        bhi.s   pad4
        bset    #3,d6
pad4:   move.b  #0,(a1)  ;output for min current
        move.b  #$f,(a2)        ;select psg b
        move.b  #$2,(a3)        ;switch on 100 ohm
        bsr     getpad    ;read paddles (should be min)
        move.b  #padlo,d7       ;compare against upper limit
        cmp.b   d7,d0
        bls.s   pad6
        bset    #4,d6
pad6:   cmp.b   d7,d1
        bls.s   pad7
        bset    #5,d6
pad7:   cmp.b   d7,d2
        bls.s   pad8
        bset    #6,d6
pad8:   cmp.b   d7,d3
        bls.s   pad9
        bset    #7,d6

pad9:   move.b  d6,erflg7
        beq.s   Gunlight
        
gperr:  lea     paderm,a5
        bsr     dspmsg
        move.b  erflg7,d1
        bsr     dspbyt
        bsr     crlf

********************************
*       test light gun circuit
Gunlight:
	move.w	#4,tries
litgun:
        move.w  #$2700,sr
        bsr     getgun
*       bsr     getgun
        bsr     getgun
        move.w  #$2400,sr
*       compare x and y positions at 3 points. must be within 8 pixels
*       the sampling window is 16 vadcnt counts => 32 pixels 
        cmp     #$40,d0    ;top left - was : $32 : 1.18g
        bhi     literr
        cmp     #0,d1      ;1st line
        bne     literr
        cmp     #$f0,d2	; middleish of screen- was: $100 : 1.18g 
        bls     literr
        cmp     #$60,d3    ;mid line
        bne     literr  
        cmp     #$40,d4  ;lower right   ; was : $4f : 1.18g
        bls     literr
        cmp     #$b8,d5  ;last line             ; RWS: this is ok...
        bne     literr
        bra.s   gundon

literr:
	sub.w	#1,tries	; try again if we have any left...
	bne	litgun

	lea     litmsg,a5
        bsr     dspmsg
        bsr     dspgun
	move.b  #1,erflg8

gundon: 
        bsr     gentst          ;7/9/92 added for genlock testing
        movea.l #pasmsg,a5
        moveq   #0,d0
        or.b    erflg0,d0
        or.b    erflg1,d0
        or.b    erflg2,d0
        or.b    erflg3,d0
        or.b    erflg4,d0
        or.b    erflg5,d0
        or.b    erflg6,d0
        or.b    erflg7,d0
        or.b    erflg8,d0
        beq.s   pquit

*       Test fail
        move.w  #red,palette
        movea.l #falmsg,a5

pquit:  move.b  #t_PRT,d0
        bsr     dsppf
        
        rts


*********************************       
*       Port test subroutines   *
*********************************

jvblank:
        clr     vcount
        rte

jhblank:
        add     #1,vcount
        bclr    #0,mfp+isra
        rte     

AVEC4   equ     $70     ; NOTE THESE ARE OFFSETS FROM VBR ONLY!
AVEC2   equ     $68
*--------------------------------
*       get light gun position at upper left, upper right, lower right
*       exit:   d0-d5 = x,y position
getgun:
*       check at beginning of screen (0,0)
        move.w  #1000,vcount
        movecvbrd0              ; get VBR
        move.l  d0,a0
        move.l  AVEC4(a0),a4
        move.l  AVEC2(a0),a2
        move.l  #jvblank,AVEC4(a0)      ; setup blank counters..
        move.l  #jhblank,AVEC2(a0)

* 04JUN92 : RWS : What was here got chopped for malpractice on sparrow
*               : replacement below does the same trick better.

*----------------------------------------------------
* grab point at beginning on screen.
getbegpt:
        move.w  #$2100,sr       ; enable h & v blanks
.grab:
        move.w  vcount,d0
        cmp.w   #54,d0          ; should be 1st or 2nd line..   
        bne     .grab
        move.w  #$2700,sr

        move.w  #180,d0         ; we're in HBLANK now.. wait till we get out..
.lp:    nop                     ; loops like this are generally bad, but
        dbra    d0,.lp  	; it work(ed) anyway.

        move.b  #1,gamec20      ;output joy0 (=light gun input)
        move.b  #0,gamec20
        move.w  gun_x,d0        ;read x position
        move.w  gun_y,d1        ;read y position

*-----------------------------------------------------
* grab a point in center of screen...
getmidpt:
        move.w  #1000,vcount
        move.w  #$2100,sr       ; enable h & v blanks
.grab:
        move.w  vcount,d6
        cmp.w   #150,d6 
        bne     .grab
        move.w  #$2700,sr

        move.w  #200,d6
.lp:    nop                     ; we're in HBLANK now.. wait till we get out..
        dbra    d6,.lp  

        move.b  #1,gamec20      ;output joy0 (=light gun input)
        move.b  #0,gamec20
        move.w  gun_x,d2        ;read x position
        move.w  gun_y,d3        ;read y position

*----------------------------------------------------
* grab a point in end of screen...
getendpt:
        move.w  #1000,vcount
        move.w  #$2100,sr       ; enable h & v blanks
.grab:
        move.w  vcount,d6
        cmp.w   #240,d6 
        bne     .grab
        move.w  #$2700,sr

        move.w  #220,d6
.lp:    nop                     ; we're in HBLANK now.. wait till we get out..
        dbra    d6,.lp  

        move.b  #1,gamec20      ;output joy0 (=light gun input)
        move.b  #0,gamec20
        move.w  gun_x,d4        ;read x position
        move.w  gun_y,d5        ;read y position
        move.b  #0,gamec20

*-----------------------------------------------------

gtgn_exit:
        move    #$3f8,d7
        and     d7,d0
        and     d7,d1
        and     d7,d2
        and     d7,d3
        and     d7,d4
        and     d7,d5
        move.l  a4,AVEC4(a0)
        move.l  a2,AVEC2(a0)
        rts

*--------------------------------
*       display gun position
*       entry:  d0,d1 = x,y upper left, d2,d3=x,y, upper right,
*              d4,d5 = x,y lower right
dspgun:
        move    d1,-(sp)
        move    d0,d1      ;x
        bsr     dspwrd    
        bsr     dspspc

        move    (sp)+,d1        ;y
        bsr     dspwrd
        bsr     dspspc

        move    d2,d1
        bsr     dspwrd
        bsr     dspspc

        move    d3,d1
        bsr     dspwrd
        bsr     dspspc

        move    d4,d1
        bsr     dspwrd
        bsr     dspspc

        move    d5,d1
        bsr     dspwrd
        Bsr     crlf
        rts
        
*-----------------------
*       read paddle registers
*       exit:   d0-d3 = paddle values
getpad: bsr     wait
        move.b  (a0),d0
        move.b  2(a0),d1
        move.b  4(a0),d2
        move.b  6(a0),d3
        rts

*--------------------------------
*       Latch data on printer port

platch: bset    #0,mfp+ddr      ;cbusy=out
        bclr    #0,mfp+gpip     ;cbusy low
        bset    #0,mfp+gpip     ;cbusy high (latch data)
        bclr    #0,mfp+ddr      ;cbusy=in
        move.b  #$7,(a1)
        move.b  #$40,(a0)       ;make printer port an input
        move.b  #$e,(a1)
        move.b  #0,(a0)  ;strobe low to enable cbusy as input
        rts

*--------------------------------
*       Output on Cbusy line    
*       Entry   d0.b=state (high or low)
tcbusy: move.b  #$e,(a1)
        move.b  #$20,(a0)       ;strobe high to allow cbusy to clock latch
        move.b  #$7,(a1)
        move.b  #$c0,(a0)       ;make A and B outputs
        move.b  #$f,(a1)
        move.b  d0,(a0)
        bsr     platch
        rts
        
*--------------------------------
*                              
*       Get joystick status     
*       Exit: d0 =joy 0  
*            d1 =joy 1   
*       t000dddd t=trigger      
*               d=direction    
*       eq if no status  
joystat:        
        move.w  #10000,d0
        move.w  #$ffff,jstat1   ;flag no status
jwt0:   dbra    d0,jwt0  ;give keyboard time to scan joysticks

*       Request status
        moveq   #$16,d1
        bsr     ikbdput  ;joystick interrogate cmd
        bne.s   jwt1        ;br if t-o

*       Get status report--interrupt routine saves in jstat
        move.w  #10000,d0
jwt2:   dbra    d0,jwt2  ;wait for report

        move.b  jstat0,d0
        move.b  jstat1,d1
jwt1:   cmpi.w  #$ffff,jstat1   ;set eq if no status
        rts

        .data
        .even
*       values output to create joystick closures
joytbl: dc.b    $f8,$f9,$fa,$fb,$fc,$fd,$fe,$ff
*       values returned as joystick status
joyval: dc.b    1,2,4,8,$10,$20,$40,$80


portmsg: dc.b   'Printer/Joystick/Game/Mouse Port test',cr,lf,eot
pportf: dc.b    'P0 Printer port error ',eot
cbusyf: dc.b    'P1 Busy line error',cr,lf,eot
joydf0: dc.b    'J0 Joystick Port 0 error',cr,lf,eot
joydf1: dc.b    'J1 Joystick Port 1 error',cr,lf,eot
joyto:  dc.b    'J2 Joystick time-out',cr,lf,eot
joybl:  dc.b    'J3 Left button line error',cr,lf,eot
joybr:  dc.b    'J4 Right button line error',cr,lf,eot
gpomsg: dc.b    'J5 Aux joystick direction ',eot
gpfmsg: dc.b    'J6 Aux fire button ',cr,lf,eot
paderm: dc.b    'J7 Paddle ',eot
litmsg: dc.b    'J8 Light gun ',eot
tpmsg:	dc.b	'Test',cr,lf,eot
        .include gentst      
             
          
                     

