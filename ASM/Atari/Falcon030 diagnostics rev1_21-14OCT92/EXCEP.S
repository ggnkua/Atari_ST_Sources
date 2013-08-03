        .include hardware
        .include defs
        .globl monomon,hiresi,horizbl,timerin,midikey,aciaexit,excep2
        .globl excep15,excep11,excep13,vectb3,vectb2,vectb1
*****************************************************************************
* $Header: $
*****************************************************************************
*    Copyright (c) 1992    Atari Microsystems, Inc.  All Rights Reserved    *
*****************************************************************************
* Revision History
* ----------------
*  7-7-92  mrw Changed all MFP code to Z8530 SCC and deleted all MFP code
*              with features not available on the SCC such as Interrupt
*              controller and general purpose I/O.
*       ( BAD IDEA. MOSTLY PUT BACK )
*****************************************************************************
        .globl  vblank
*************************       
*                       *
*  Exception Handlers   *
*                       *
*************************
*       June 28, 89:    separate routines for timers
*       Nov 6, 87       save break codes in buffer
*       Oct 6, 87       read relative mouse packets
*       May 15, 87      color test int: delay increased to change color
*                       off screen.
*       Feb 26, 87
*       Nov 13, 86      Monochrome int resets system.
*       Oct 22, 86      Check ACIA interrupt before exiting midikey
*       routine to be sure there was no int by the other ACIA while
*       servicing the one.
*       Oct 6 '86       If bus error and wrflg set, return to comlin 
*       Break code for 70-72 = completion code, so kstate must be set
*          to 8 before performing reset test to distinguish codes.

        .text

**************************************************
**                                              **
**      68030 Exceptions                        **
**                                              **
**                                              **
**************************************************

*       Bus error: display message, access address
*       clean stack and return
excep2: movea.l #buserr,a5      ;Bus error
excep2a:
        move    #red,palette
        bsr     rsinit
        move.w  #$ffff,d7       ;set flag (for RAM sizing)
        bsr     dspmsg
xcpprtloc:
        lea     accadd,a5
        bsr     dspmsg
        move.l  $10(sp),a0      ; access address
        bsr     dspadd          ;display access address
        lea     pcmsg,a5
        bsr     dspmsg
        move.l  $2(sp),a0       ; program counter
        move.l  a0,d0
        cmp.l   errorpc,d0      ; are we in a loop?
        beq.s   rpterr
        move.l  a0,errorpc      ;save this location
        bsr     dspadd          ;display pc
        bsr     crlf
        tst.b   wrflg           ;user modifying memory? 
        beq.s   excep1          ;no, return from whence

***~ may 24, 91
        move.l  #comlin,$2(a7)  ;new address (w/r routine)
        move.w  $a(sp),d0       ;get ssw
        and.w   #$ceff,d0       ;clear df, rc, and rb bits
        move.w  d0,$a(sp)       ;save modified ssw on stack
        move.l  #0,errorpc      ;zero err flag, so user can try again 
***~
excep1: rte

*       Repeated bus or address error
rpterr: bsr     dspadd
        bra.s   excdon          ;stop cold
        
*       Address error: same as bus error except message
excep3: movea.l #adderr,a5      
        bra.s   excep2a

excep4: movea.l #illins,a5      ;Illegal instruction
        bra.s   fatexc
excep5: movea.l #ex68k,a5       ;Divide by zero
        bra.s   fatexc

*       Exceptions 6-9 are same as excep5
*excep6 movea.l #ex68k,a5       ;Check
*       bra.s   fatexc
*excep7 movea.l #ex68k,a5       ;Trapv
*       bra.s   fatexc
*excep8 movea.l #ex68k,a5       ;Privilege violation
*       bra.s   fatexc
*excep9 movea.l #ex68k,a5       ;Trace
*       bra.s   fatexc

excep10:
        movea.l #illins,a5      ;1010 op code
        bra.s   fatexc
excep11:
;        movea.l #fpu,a5         ;1111 op code FPU error
;        move.l  a6,sp
;        move.w  #red,palette
;        bsr     crlf
;        bsr     dspmsg
;        add.l   #2,(sp)         ;keep us out of a trap loop
;        rte
        movea.l #illins,a5      ;1111 op code

* ADDED 01APR92 : RWS -- FOR Rev 1 Combels
excep12: movea.l #ex68k,a5
        bra.s   fatexc
excep13: movea.l #ex68k,a5
        bra.s   fatexc
excep14: movea.l #ex68k,a5
        bra.s   fatexc
excep15: movea.l #ex68k,a5
        bra   fatexc


fatexc: move.w  #red,palette
        bsr     crlf
        bsr     dspmsg
        bra     xcpprtloc
excdon: bra.s   excdon          ;no return from one of these exceptions!!!


*       No DTACK or VPA during int ack cycle
spuri:  move.w  #red,palette
        movea.l #spurina,a5     ;spurious interrupt msg
        bsr     dspmsg
        rte

*       Got odd autovector (IPL0), or Glue error?
autov:  move.w  #red,palette
        movea.l #autovm,a5      ;autovector message
        bsr     dspmsg
        rte

********************************
*
*       Vertical Blank
*
********************************
vblank: clr.b   lcount          ;0 line counter
        rte

*****************************************
*       Horizontal Blank                *
*****************************************
*       This is the autovector interrupt, not to be confused
*       with the MFP interrupt, which is higher priority and
*       corresponds to actual scan lines. This interrupt occurs
*       even during vertical blanking.
hblanka:
        clr     intflg          ;nice to know we got here
        rte                     ;however, if this does not occur,
*                               ;there will likely be no display to report it.

**********************************
**                              **
**      MFP INTERRUPTS          **
**                              **
**********************************

*****************************************
*                                       *
*       Monochrome Monitor Detect       *
*                                       *
*****************************************

*       Restart everything
monomon:
        bclr.b  #7,isra+mfp
        move    (sp)+,d1        ;unstack status
        move.l  (sp)+,d0        ;unstack address
        move.l  #start,-(sp)    ;new address=start
        move    d1,-(sp)        ;restore status
        rte

*       Int for hires test
*       Set to hi-res mode; do not re-init software
hiresi: move.w  d0,-(a7)
        move    sr,d0           ;save current int level
        move    #$2200,sr       ;allow verical blank int
        move.b  #1,lcount
hires1: tst.b   lcount          
        bne.s   hires1
        move    d0,sr
        move.b  #2,v_shf_mod
        move.w  #bgrnd,palette
        bclr.b  #7,isra+mfp
        move.w  (a7)+,d0
        rte

*****************************************
*                                       *
*       RS232 Ring Indicator            *
*                                       *
*****************************************

ringin:
        bclr    #6,intflg       ;clear the flag
        bclr    #6,isra+mfp
        rte

*****************************************
*                                       *
*       RS232 Receiver Full             *
*                                       *
*****************************************
*       Collect parity, overrun, frame errors
*       for entire transmit sequence
rcvrint:
;       move.l  d0,-(a7)
;       move.b  rsr+mfp,d0      ;get status
;       andi.b  #$70,d0
;       or.b    d0,rsistat      ;accumulate errors
;       move.b  udr+mfp,rcvbyt  ;get data
;       bclr.b  #$4,isra+mfp
;       move.l  (a7)+,d0
dummy:  rte

*********************************************************
*                                                       *
*       Transmit Buffer Empty interrupt routine         *
*                                                       *
*********************************************************
*       sends an incrementing pattern, stops sending after ff
txrint:
;       move.b  tsr+mfp,rsostat ;read status
;       cmpi.b  #$ff,xmtbyt
;       beq.s   txr1            ;stop after 255
;       addi.b  #1,xmtbyt       ;increment data
;       move.b  xmtbyt,udr+mfp  ;send byte
txr1:  ;  bclr.b  #$2,isra+mfp    ;clear in-service bit
        rte

*************************************************************************
*       RS232 Receiver Error                                            *
*************************************************************************
*       Received data in shift register before buffer was read
rxerror:
;       move.b  rsr+mfp,rsistat ;get status
;       bclr    #$3,isra+mfp
        rte

*************************************************
*       RS232 Transmitter Underrun              *
*************************************************
*       Occurs if transmitter empties before next byte is given to it
*       Normal terminating condition
txerror:
;       move.b  tsr+mfp,rsostat  ;transmitter status register
;       bclr    #$1,isra+mfp
        rte

***************************************************
*
*       Horizontal Blank interrupt
*       From MFP. =display line
*       
***************************************************

*       This routine used in Display Enable test
*       Decrement the interrupt flag until zero;
*       Clear the interrupt and disable timer A if at zero

horizbl:
        tst.b   intflg
        beq.s   horizb1
        subi.b  #1,intflg       ;decrement count
        beq.s   horizb1
        bclr    #0,isra+mfp
        rte
horizb1:
        bclr    #0,iera+mfp     ;stop timer int
        bclr    #0,isra+mfp     ;clear DE int 
        rte

*       This routine used by color test 
*       Display red, green, blue, cyan,magenta, yellow, white.
*       Interrupt occurs every 3rd scan line, giving 67 lines per screen.
*       There are 56 color changes.
hblank:
        movem.l d0-d1/a0,-(a7)

        cmpi.b  #63,lcount      ;end of screen?
        bgt.s   hbquit          ;do nothing

        cmpi.b  #0,lcount       ;start of screen?
        bne.s   setcol

*       top of display
        clr.b   collin
        
*       Set new colors into palette
setcol: moveq   #33,d0
setcol1:
        dbra    d0,setcol1

        move.l  #coltbl,a0
        moveq   #0,d0
        move.b  collin,d0
        move    0(a0,d0),d1     ;get color
        moveq   #15,d0          ;16 registers
        move.l  #palette,a0
setclp: move    d1,(a0)+        ;put color in hardware
        dbra    d0,setclp       
        
        addq.b  #2,collin       ;increment color index          

hbquit: movea.l #mfp,a0
        bclr    #0,isra(a0)     ;clear in-service
        addq.b  #1,lcount       ;scan line count
        movem.l (a7)+,d0-d1/a0
        rte

coltbl: dc.w    $000,$000,$100,$200,$300,$400,$500,$600,$700
        dc.w    $000,$000,$010,$020,$030,$040,$050,$060,$070
        dc.w    $000,$000,$001,$002,$003,$004,$005,$006,$007
        dc.w    $000,$000,$011,$022,$033,$044,$055,$066,$077
        dc.w    $000,$000,$110,$220,$330,$440,$550,$660,$770
        dc.w    $000,$000,$101,$202,$303,$404,$505,$606,$707
        dc.w    $000,$000,$111,$222,$333,$444,$555,$666,$777
        dc.w    $000

*****************************************
*       Disk Contoller                  *
*****************************************
*       Unused. The Disk I/O is all polled.
dskint:
        bclr.b  #0,intflg
        bclr.b  #$80,isrb+mfp
        rte

*************************************************************************
*       this code handles the midi/keyboard interrupt exception         *
*************************************************************************

midikey:
        movem.l d0-d7/a0-a6,-(a7)       ;save all registers
midiky2:
        bsr     midiptr         ;init address registers for midi
        movea.l vmiderr,a3      ;load in the jump vector
        bsr     astatus         ;goto general acia status check routine

        bsr     ikbdptr         ;init address registers for ikbd
;        jsr     ikbdptr         ;init address registers for ikbd
*~
        movea.l vkbderr,a3      ;load in the jump vector
        bsr     astatus         ;goto general acia status check routine
        movea.l #mfp,a1         ;setup to clear in-service bit
        bclr.b  #$6,isrb(a1)

        btst    #4,gpip(a1)     ;all clear?
        bne.s   midiky1
        bra.s   midiky2         ;nope, get next one
                
midiky1:
        movem.l (a7)+,d0-d7/a0-a6       ;restore all registers
        rte                     ;go back to what was happening!

astatus:
        bsr     aciastat        ; get status, save in d7, buffer
        btst    #7,d7           ; ?irq from midi/keybd?
        beq.s   aciaexit        ;nope...it's empty
        btst    #0,d7           ;see if receiver buffer is full
        beq.s   mk1             ;nope...it's empty

        movem.l a0-a3,-(a7)
        bsr     arcvrint        ;get byte and save
        movem.l (a7)+,a0-a3

        andi.b  #%01111100,d7
        tst.b   d7              ;error bits?
        beq.s   aciaexit        

*       False interrupt or status error
mk1:    move.b  #3,comstat(a1)  ;reset
        move.b  #$96,comstat(a1)
aciaexit:
        rts


*************************************************************************
*                                                                       *
*       ACIA receiver buffer full interrupt routine                     *
*       saves key strokes in keyboard buffer:                           *
*               high byte of word=scan code                             *
*               low byte = ascii (If ascii key. Does not translate      *
*                  using shift or control. Non-ascii returns 0.)        *
* NOW! TRANSLATES USING SHIFT AND CONTROL - SAFE FOR OLD CODE?? : RWS : * 
*       saves midi data in midi buffer                                  *
*                                                                       *
*       Assumes only normal, joystick interrogation, or clock modes     *
*          are used.                                                    *
*       Entry:  a0=buffer record base                                   *
*               a1=hardware base                                        *
*       Exit:   data saved to buffer or joy, time, shift, break, prskey *
*       Preserve: a1,d7                                                 *
*************************************************************************
        
arcvrint:
        moveq   #0,d0
        move.b  iodata(a1),d0   ;grab data byte from acia data register
        cmpa.l  #kbufrec,a0
        bne     midibyte        ;save MIDI data in midi buffer

*       Keyboard. Determine if special code and set keyboard state.
*          Codes are: f0-f3=completion, fd=joystick report, fc=time
*       kstate=0 if normal keyboard mode (returns make/break codes, 
*          mouse/joystick events, or reset completion code)
*       kstate=1 if joystick interrogation mode 
*       kstate=2 if time of day clock mode
*       kstate=4 if reset test mode, expect completion code
*          (f0-f2 are break codes as well as completion codes. kstate bit 3
*           is used to determine which.)
keycode:
        tst.b   kindex          ;data packet?
        beq     keycod0         ;no

*       its joystick, time, or mouse packet
        sub.b   #1,kindex       ;dec number of bytes
        bne     keypak
        clr.b   kstate          ;state complete
keypak: btst    #1,kstate       ;time?
        bne     timpak
*                               ;joystick or mouse packet
        lea     jstat1,a0       ;save in joy status
        bra.s   datpak

timpak: lea     timestat,a0     ;save in time status
datpak: moveq   #0,d1
        move.b  kindex,d1
        move.b  d0,0(a0,d1)     ;save data
        rts
        
*       header code, key make, or key break
keycod0:
        move.b  d0,d1           
        andi.w  #$f0,d1         
        cmpi.b  #$f0,d1         ;special code? (complete,mouse,joy,time)
        bne.s   itsakey         ;br no

*       --------
*       Special code
        cmpi.b  #$f3,d0         
        bgt.s   keycod1         ;br if joy,time,mouse

*       F0-F3, Completion code or break code
        btst    #3,kstate       ;reset test?
        beq     itsakey         ;nope, its a break code
        clr.b   kstate          ;state completed
        lsl.w   #8,d0           ;shift to scan code position
        bra     conin26         ;save comp. code in buffer

keycod1:
        cmpi.b  #$fc,d0         ;time?
        bne.s   keycod2

*       Time header, set kstate and kindex
        bset    #1,kstate
        move.b  #6,kindex       ;# of bytes to follow
        rts

keycod2:
        cmpi.b  #$fd,d0
        bne.s   keycod3

*       Joystick header, set kstate and kindex
        bset    #0,kstate       
        move.b  #2,kindex       ; 2 bytes to follow
        rts

*       F8-FB = mouse packet
keycod3:
        move.b  #2,kindex       ;number of bytes to follow
        move.b  d0,rmb          ;save relative mouse button status      
        rts

*       --------
*       Got a keystroke. d0=scan code
itsakey:
        moveq   #0,d1           
        move.b  d0,d1

*       Check for shift key make/break
        cmpi.b  #$2a,d0         ;left shift?
        bne.s   key2
        bset    #7,kbshift
key1:   andi.w  #$ff,d0         ;hi byte=0, lo byte=scancode

        bra.s   askey           ;get ascii and save

key2:   cmpi.b  #$36,d0         ;right shift?
        bne.s   .key31
        bset    #7,kbshift
        bra.s   key1
************* ADDED 29JAN92 : RWS
.key31:
        cmpi.b  #$1d,d0         ;ctrl key make
        bne.s   .key32
        move.w  #$100,kbctrl
        bra.s   key1
.key32:
        cmpi.b  #$9d,d0         ;ctrl key break?
        bne     key3
        move.w  #$00,kbctrl
*********************************
key3:   cmpi.b  #$aa,d0         ;left shift break?
        bne.s   key4
        bclr    #7,kbshift
key4:   cmpi.b  #$b6,d0         ;right shift break?
        bne.s   key5
        bclr    #7,kbshift

*       Check for break
key5:   btst    #7,d0           ;is it a break code?
        beq.s   askey           ;br if not

*       Got a break code
        move.b  d0,brkcod       ;save the break code

*       for keyboard test, need to buffer break codes
        move.l  brkptrh,a0
brk2:   move.b  d0,(a0)+        ;save in circular queue for keyboard test
        cmpa.l  #brkbuft,a0     ;at end?
        bne.s   brk1
        move.l  #brkbufh,a0     ;wrap ptr if at end
brk1:   move.l  a0,brkptrh
        rts

*       Translate scan code into ascii
askey:  move.l  a0,-(a7)        ;store kbufrec pointer
        movea.l #keytran,a0     ;address of translation table
        add.b   kbshift,d0      ;add 128 if shifted
        adda.w  kbctrl,a0       ;add 256 if control down
        adda.w  d0,a0           ;add offset to start address
        move.b  (a0),d0         ;get ascii from table
        asl.w   #$8,d1          ;shift the scan code to the word's high byte
        add.w   d1,d0           ;form the outgoing word: scancode+ascii

        movea.l (a7)+,a0        ;restore kbufrec pointer

*       Save character in buffer

conin26:
        move.w  ibuftail(a0),d1 ;get current tail pointer offset
        addq    #2,d1           ;index = tail + 2
        cmp.w   ibufsiz(a0),d1  ;check to see if buffer should wrap
        bcs.s   conin1          ;no...
        moveq   #$0,d1          ;wrap pointer
conin1: cmp.w   ibufhead(a0),d1 ;head=tail?
        beq.s   ariend          ;yes
        move.l  ibufptr(a0),a2  ;get buffer pointer
        move.w  d0,0(a2,d1)     ;store the data
        move.w  d1,ibuftail(a0) ;store the new buftail pointer
ariend: rts

*       --------
*       Save MIDI data

midibyte:
        move.w  ibuftail(a0),d1 ;get current tail pointer offset
        addq    #1,d1           ;index = tail + 1
        cmp.w   ibufsiz(a0),d1  ;check to see if buffer should wrap
        bcs.s   mi13            ;no...
        moveq   #$0,d1          ;wrap pointer
mi13:   cmp.w   ibufhead(a0),d1 ;head=tail?
        beq.s   mi14            ;yes
        move.l  ibufptr(a0),a2  ;get buffer pointer
        move.b  d0,0(a2,d1)     ;store the data
        move.w  d1,ibuftail(a0) ;store the new buftail pointer
mi14:   rts

        
*************************************************
*       Scan code to ASCII translation tables   *
*************************************************

keytran:
        dc.b    $00,$1b,$31,$32,$33,$34,$35,$36 ; Lower case keys here
        dc.b    $37,$38,$39,$30,'-','=',$08,$09 ; 29JAN92 : RWS : LC-ED letters
        dc.b    'q','w','e','r','t','y','u','i' ; don't think there's any probs
        dc.b    'o','p','[',']',$0D,$00,'a','s' ; with users of conin.
        dc.b    'd','f','g','h','j','k','l',';' ; cconin-ers I wrote. 
        dc.b    $27,'`',$00,'\\','z','x','c','v'
        dc.b    'b','n','m',',','.','/',$00,$00
        dc.b    $00,$20,$00,$00,$00,$00,$00,$00

        dc.b    $00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,'-',$00,$00,$00,'+',$00
        dc.b    $00,$00,$00,$7f,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,'(',')','/','*','7'
        dc.b    '8','9','4','5','6','1','2','3'
        dc.b    '0','.',$0D,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00

keyshif:
        dc.b    $00,$1b,'!','@','#','$','%','^' ; shifted keys
        dc.b    '&','*','(',')','_','+',$08,$09
        dc.b    'Q','W','E','R','T','Y','U','I'
        dc.b    'O','P','{','}',$0D,$00,'A','S'
        dc.b    'D','F','G','H','J','K','L',':'
        dc.b    '"','~',$00,'|','Z','X','C','V'
        dc.b    'B','N','M','<','>','?',$00,$00
        dc.b    $00,$20,$00,$00,$00,$00,$00,$00

        dc.b    $00,$00,$00,$00,$00,$00,$00,$37
        dc.b    $38,$00,'-',$34,$00,$36,'+',$00
        dc.b    $32,$00,$30,$7f,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,'(',')','/','*','7'
        dc.b    '8','9','4','5','6','1','2','3'
        dc.b    '0','.',$0D,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00

keycl:                                          
        dc.b    $00,$1b,'1','2','3','4','5','6' ; NOW!! Control keys
        dc.b    '7','8','9','0','-','=',$08,$09 ; RWS : 29JAN92
        dc.b    $11,$17,$05,$12,$14,$19,$15,$09 ; THESE MAY BE IN ERROR!
        dc.b    $0f,$10,$1b,$1d,$0D,$00,$01,$13 ; IF A CTRL KEY DOESN'T
        dc.b    $04,$06,$07,$08,$0a,$0b,$0c,$3b ; WORK, TRY CHECKING HERE
        dc.b    $27,'`',$00,$1c,$1a,$18,$03,$16
        dc.b    $02,$0e,$0d,',','.','/',$00,$00
        dc.b    $00,$20,$00,$00,$00,$00,$00,$00

        dc.b    $00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $38,$00,'-',$34,$00,$36,'+',$00
        dc.b    $32,$00,$00,$7f,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,'(',')','/','*','7'
        dc.b    '8','9','4','5','6','1','2','3'
        dc.b    '0','.',$0D,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00

        dc.b    $00,$1b,'1','2','3','4','5','6' ; NOW!! Control+Shift keys
        dc.b    '7','8','9','0','-','=',$08,$09 ; RWS : 29JAN92
        dc.b    $11,$17,$05,$12,$14,$19,$15,$09 ; (THESE MAY BE IN ERROR
        dc.b    $0f,$10,$1b,$1d,$0D,$00,$01,$13 ; IF A CTRL KEY DOESN'T
        dc.b    $04,$06,$07,$08,$0a,$0b,$0c,$3b ; WORK, TRY LOOKING HERE)
        dc.b    $27,'`',$00,$1c,$1a,$18,$03,$16
        dc.b    $02,$0e,$0d,',','.','/',$00,$00
        dc.b    $00,$20,$00,$00,$00,$00,$00,$00

        dc.b    $00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $38,$00,'-',$34,$00,$36,'+',$00
        dc.b    $32,$00,$00,$7f,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,'(',')','/','*','7'
        dc.b    '8','9','4','5','6','1','2','3'
        dc.b    '0','.',$0D,$00,$00,$00,$00,$00
        dc.b    $00,$00,$00,$00,$00,$00,$00,$00

*****************************************************************
*       Time-out timer A interrupt                              *
*       Decrement timout                                        *
*****************************************************************
timerav:
        tst.b   timout
        beq.s   timera1
        subi.b  #1,timout       ;dec timeout counter
timera1:
        clr.b   timflg
        bclr    #5,isra+mfp     ;clear timer A interrupt
        rte

*****************************************************************
*                                                               *
*       Timer interrupts--used at start to test 4 MFP timers.   *
*       Clears bit 0 of timflg                                  *
*       Clears bit 1 of timflg if interrupt in-service is set   *       
*       Entry:  d0=interrupt number (timer test only)           *
*****************************************************************
timerin:
        cmpi.b  #13,d0          
        bne.s   timein1
        btst    #5,isra+mfp     ;test in service bit
        beq.s   timret
        bclr    #1,timflg       ;clear in service bit error flag
        bclr    #5,isra+mfp     ;clear in service bit
        bra.s   timret
timein1:
        cmpi.b  #8,d0           ;timer B?
        bne.s   timein2
        btst    #0,isra+mfp
        beq.s   timret
        bclr    #1,timflg
        bclr    #0,isra+mfp
        bra.s   timret
timein2:
        cmpi.b  #5,d0           ;timer C?
        bne.s   timein3
        btst    #5,isrb+mfp
        beq.s   timret
        bclr    #1,timflg
        bclr    #5,isrb+mfp
timein3:
        btst    #4,isrb+mfp     ;must be timer D
        beq.s   timret
        bclr    #1,timflg
        bclr    #4,isrb+mfp
timret:
        bclr    #0,timflg       ;just indicate we got here
        rte
*****************************************************************
*                                                               *
*       Timer interrupts--used at start to test 4 MFP timers.   *
*       Clears bit 0 of timflg                                  *
*       Clears bit 1 of timflg if interrupt in-service is set   *       
*****************************************************************
timeria:
        btst    #5,isra+mfp     ;test in service bit
        beq.s   timret
        bclr    #1,timflg       ;clear in service bit error flag
        bclr    #5,isra+mfp     ;clear in service bit
        bra.s   timret
timerib:
        btst    #0,isra+mfp
        beq.s   timret
        bclr    #1,timflg
        bclr    #0,isra+mfp
        bra.s   timret
timeric:
        btst    #5,isrb+mfp
        beq.s   timret
        bclr    #1,timflg
        bclr    #5,isrb+mfp
timerid:
        btst    #4,isrb+mfp     
        beq.s   timret
        bclr    #1,timflg
        bclr    #4,isrb+mfp
*timret:
        bclr    #0,timflg       ;just indicate we got here
        rte

*
gpudon:
        bclr    #3,isrb+mfp     
        rte

*
*       Clear to Send
ctsint:
*       Clear flag to know we got here
        bclr    #2,intflg
        bclr    #2,isrb+mfp
        rte

*       Data Carrier Detect
dcdint:
*       Clear flag to know we got here
        bclr    #1,intflg
        bclr    #1,isrb+mfp
        rte
*
*       Centronics port busy
cbusy:
*       Clear flag to know we got here
        bclr    #0,intflg
        bclr    #0,isrb+mfp
        rte

        .data

********************************
*                              *
*  exception vector tables     *
********************************

*  vector 2-11
***     68000 EXCEPTION ENTRY POINTS
vectb1: dc.l    excep2
        dc.l    excep3
        dc.l    excep4
        dc.l    excep5
        dc.l    excep5
        dc.l    excep5
        dc.l    excep5
        dc.l    excep5
        dc.l    excep10
        dc.l    excep11
* ADDED 01APR92 : RWS
        dc.l    excep12
        dc.l    excep13
        dc.l    excep14
        dc.l    excep15        

*  vector 24-31
vectb2: dc.l    spuri
        dc.l    autov           ;unused
        dc.l    hblanka         ;Autovector 2=horizontal blank
        dc.l    autov           ;unused
        dc.l    vblank          ;Autovector 4=vertical blank
        dc.l    autov           ;unused
        dc.l    autov           ;unused--level 6=user interrupt (MFP)
        dc.l    autov   
*
*  MFP interrupts--vector 64-79
*vectb3: dc.l    cbusy           ;$100
*        dc.l    dcdint
*        dc.l    ctsint
*        dc.l    gpudon          ;$10c
*        dc.l    timerid         ;$110 timer D
*        dc.l    timeric         ;$114 timer C
*        dc.l    midikey
*        dc.l    dskint
*        dc.l    timerib         ;$120 timer B
*        dc.l    txerror
*        dc.l    txrint          ;$128
*        dc.l    rxerror
*        dc.l    rcvrint         ;$130
*        dc.l    timeria         ;$134 timer A
*        dc.l    ringin
*        dc.l    monomon         ;$13c
*
*  MFP interrupts--vector 64-79
vectb3: dc.l    cbusy           ;$100
        dc.l    dcdint
        dc.l    ctsint
        dc.l    gpudon          ;$10c
        dc.l    timerin         ;$110 timer D
        dc.l    timerin         ;$114 timer C
        dc.l    midikey
        dc.l    dskint
        dc.l    timerin         ;$120 timer B
        dc.l    txerror
        dc.l    txrint          ;$128
        dc.l    rxerror
        dc.l    rcvrint         ;$130
        dc.l    timerin         ;$134 timer A
        dc.l    ringin
        dc.l    monomon         ;$13c

        .data
        
*       Messages
autovm: dc.b    'E6 Autovector error',cr,lf,eot
spurina: dc.b   'E7 Spurious Interrupt',cr,lf,eot
ex68k:  dc.b    'E8 Exception error',cr,lf,eot ;no legitimate occurance,
*                                       must be 68000 error
illins: dc.b    'E9 Bad instruction fetch ',cr,lf,eot     
buserr: dc.b    cr,lf,'EB Bus Error ',eot       
adderr: dc.b    'EA Address Error ',eot
accadd: dc.b    ' Access Address: ',eot
pcmsg:  dc.b    ' Program Counter: ',eot
              
