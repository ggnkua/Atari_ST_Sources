        .text
        .globl  aciastat,midiptr        ;used by excep.s
*********************************
*       Test MIDI port          *
*                               *
*********************************

*       Feb 2, 87  edit for madmac
*       Oct 22 86  reset the ACIA if stuck irq
*       11 Apr add error codes

*       MIDI is done 8(*256 bytes) times

* MIDI
* Erflg2:                       data    data    framing parity  overrun
*                               not rcv mismatch

miditst:
        movea.l #midim,a5
        bsr     dsptst          ;if auto, put title at top
        clr.b   erflg2
*~
        move.b  consol,tempb     ;save all flags
*~
        bsr     initkey
        moveq   #6,d0           ;interrupt 6=keybd,midi
        movea.l #midikey,a2     ;address of int routine
        bsr     initint
        bset    #6,mfp+imrb     ;restore keyboard irq ; RWS.TPEX
*~
        move.b  tempb,consol     ;restore all flags
*~

*       initialize the midi buffer record structure
        movea.l #mbufrec,a0
        movea.l #minit,a1
        moveq   #mssize,d0
        bsr     lbmove          ;do block move and return

*       init the midi acia next
        bsr     midiptr                 ;point to midi stuff
        move.b  #rsetacia,comstat(a1)   ;init the acia via master reset

*       init the MIDI acia to /16x clock, 8 bit data, 1 stop bit,
*       no parity, rts low, tx interrupt disabled, rx interrupt enabled
        move.b  #div16+protocol+rtsld+intron,comstat(a1)

        move.b  #8,index1       ;do it 8 times (8*256)

*       Send 256 combinations of data
mrepet: moveq   #0,d2
mxmt:   bsr     midout          ;1 byte at a time

        bsr     midin           
        tst.b   erflg2  
        bne.s   miderr          
        cmp.b   d0,d2           ;compare data 
bne mdaterr  
;        bne.s   mdaterr
        add.b   #1,d2
        bcc     mxmt            ;until 256 bytes done
        subi.b  #1,index1
        bne.s   mrepet

*-------------------------------
*       MIDI passed
        movea.l #pasmsg,a5
        move.b  #t_MIDI,d0
        bsr     dsppf
        rts

*-------------------------------
*       MIDI Errors
*       check status
miderr: move.b  comstat(a1),d3
        btst    #4,d3           ;frame error?
        beq.s   mtst1
        bset    #2,erflg2
        movea.l #mframe,a5
        bsr     dspmsg
mtst1:  btst    #5,d3           ;receiver overrun?
        beq.s   mtst2
        bset    #0,erflg2
        movea.l #mover,a5
        bsr     dspmsg
mtst2:  btst    #6,d3           ;parity error?
        beq.s   mtst3
        bset    #1,erflg2
        movea.l #mparity,a5
mtst3:  andi.b  #$70,d3
        bne.s   midier          ;br if status error

*       If none of above, must be time-out
        movea.l #mtimsg0,a5     ;timed out
        bsr     dspmsg
        bset    #4,erflg2
        bra.s   midier

*       Data mismatch
mdaterr:
        movea.l #mdmatch,a5
        bsr     dspmsg
        bset    #3,erflg2

midier: movea.l #falmsg,a5
        move.b  #t_MIDI,d0
        bsr     dsppf
        move.w  #red,palette

*       Check for stuck irq, reset the ACIA if needed
stk_midi:
        btst    #7,midi         ;check irq
        beq.s   midie1
        move.b  #rsetacia,midi  ;reset the acia 
midie1: rts

*************************************************************************
*               putchar routine for midi port                           *
*                                                                       *
*       This routine transfers a single byte directly                   *
*       to the ACIA output register.                                    *
*       entry:  d2.b - contains character to transfer                   *
*       exit:   all preserved                                           *
*************************************************************************

midout:
        movem.l d7/a0-a1,-(a7)
        bsr     midiptr
midput1:
        bsr     aciastat
        btst    #$1,d7          ;transmit empty?
        beq.s   midput1
        move.b  d2,iodata(a1)   ;give it to transmit register
        movem.l (a7)+,d7/a0-a1
        rts                     ;done for now

*************************************************************************
*                                                                       *
*               get midi receiver buffer status                         *
*                                                                       *
*************************************************************************
midstat:
        bsr     midiptr
        moveq   #$ff,d0         ;set result to true
        lea     ibufhead(a0),a2
        lea     ibuftail(a0),a3
        cmpm.w  (a3)+,(a2)+     ;atomic buffer empty test
        bne.s   midist1         ;branch if not, assume d0 is "clr.w"'ed
        moveq   #$0,d0          ;set result to false
midist1:
        rts

*************************************************************************
*                                                                       *
*               getchar routine for midi port                           *
*                                                                       *
*       this routine transfers characters from a input queue that is    *
*       filled by an automatic interrupt routine.  the interrupt        *
*       routine handles the actual transfer of the character from the   *
*       i/o port.                                                       *
*                                                                       *
*       exit:   d0.b - contains character if carry bit clear,           *
*                      if carry bit set, we had an error                *
*                                                                       *
*************************************************************************

midin:
        move.b  d2,-(a7)        ;save data sent

;        move.w  #10000,d3
        move.w  #18000,d3
midin0: subi.w  #1,d3
        beq.s   midto           ;br if time out
        bsr     midstat         ;see if data present
        tst     d0
        beq.s   midin0          ;someday, my prince will come...

        move.b  status(a0),d0   ;get status
        andi.b  #$70,d0         ;mask error bits
        bne.s   midto           ;br if error
        bsr     getchr          ;go to general get char routine
midin1: move.b  #0,tadr+mfp     ;reset data count for next time
        move.b  (a7)+,d2
        rts
midto:  bset    #4,erflg2       ;set bit to flag error, data not received
        bra.s   midin1

*************************************************************************
*                                                                       *
*               general put char to output buffer routine               *
*                                                                       *
*       Entry:  a0 - pointer to device i/o buffer record                *
*               d1 - character to drop into the device's output buffer  *
*       Exit:   carry set=error: buffer full                            *
*                                                                       *
*************************************************************************

putchr:
        movem.l d1-d2/a0-a1,-(a7)       ;save affected registers
        move    sr,-(a7)        ;protect this upcoming test
        ori     #$700,sr
        move.w  obuftail(a0),d2 ;get current tail pointer offset from buffer
        bsr     wrapout         ;check for wrap of pointer
        cmp.w   obufhead(a0),d2 ;head=tail?
        beq.s   pc2             ;yes...no buffer space left
        move.l  obufptr(a0),a1  ;get current available buffer storage location
        move.b  d1,0(a1,d2)     ;store char to the buffer
        move.w  d2,obuftail(a0) ;store new tail pointer to buffer record
        move    (a7)+,sr
        andi.b  #%11111110,ccr  ;clear carry flag for normal return
        bra.s   pc3
*       buffer full
pc2:    move    (a7)+,sr        ;
        ori.b   #$01,ccr        ;set carry for error condition
pc3:    movem.l (a7)+,d1-d2/a0-a1       ;restore affected registers
        rts                     ;full buffer and an abnormal return


*************************************************************************
*                                                                       *
*               general get char from buffer routine                    *
*                                                                       *
*       entry   a0 - pointer to device i/o buffer record                *
*       exit    d0 - character grabbed from the device's input buffer   *
*                                                                       *
*************************************************************************

getchr:
        movem.l d1/a0-a1,-(a7)  ;save affected registers
        move    sr,-(a7)        ;protect this upcoming test
        ori     #$700,sr
        move.w  ibufhead(a0),d1 ;get current head pointer offset from buffer
        cmp.w   ibuftail(a0),d1 ;head=tail?
        beq.s   gc5             ;yes
        bsr     wrapin          ;check for wrap of pointer
        move.l  ibufptr(a0),a1  ;get base address of buffer
        move.b  0(a1,d1),d0     ;get character
        move.w  d1,ibufhead(a0) ;store new head pointer to buffer record

        move    (a7)+,sr
        andi.b  #%11111110,ccr  ;clear carry flag for normal return
        bra.s   gc4

gc5:    move    (a7)+,sr
        ori.b   #$01,ccr        ;set carry for error condition just in case...
gc4:    movem.l (a7)+,d1/a0-a1  ;restore affected registers
        rts                     ;normal return

*       Increment head
wrapin:
        addq.w  #1,d1
        cmp.w   ibufsiz(a0),d1
        bcs     wi1
        moveq   #0,d1
wi1:    rts

*       Increment tail
wrapout: 
        addq.w  #1,d2
        cmp.w   obufsiz(a0),d2
        bcs     wo1
        moveq   #0,d2
wo1:    rts


*****************************************************************
*       set pointers for midi                                   *
*       on exit:                                                *
*       a0 points to midi buffer                                *
*       a1 points to midi base register                         *
*****************************************************************

midiptr:
        movea.l #mbufrec,a0     ;point to midi i/o bufrec
        movea.l #midi,a1        ;point to midi register base
        rts

*************************************************************************
*                                                                       *
*               this code grabs an acia status byte.                    *
*       entry   a0 - points to device i/o bufrec                        *
*               a1 - points to device's acia register base              *
*       exit    d7      contains device status                          *
*                                                                       *
*************************************************************************
        
aciastat:
        move.b  comstat(a1),d7  ;grab midi/keyboard status
        move.b  d7,status(a0)   ;save a copy
        rts

        .data
        .even
*****************************************
*                                       *
*       Initialization Table for MIDI   *
*                                       *
*****************************************
minit:
        dc.l    mibuffer
        dc.w    minsize
        dc.w    0
        dc.w    0
        dc.w    kinsize/4
        dc.w    kinsize*3/4

        dc.l    mobuffer
        dc.w    moutsize
        dc.w    0
        dc.w    0
        dc.w    moutsize/4
        dc.w    moutsize*3/4
        dc.w    0

mssize  equ     *-minit-1


*********************************
*                               *
*       Messages                *
*                               *
*********************************       

*       MIDI
midim:  dc.b    'Testing MIDI',cr,lf,eot
mover:  dc.b    'M4 MIDI data overrun',cr,lf,eot
mparity: dc.b   'M3 MIDI parity',cr,lf,eot
mframe: dc.b    'M2 MIDI framing',cr,lf,eot
mdmatch: dc.b   'M1 MIDI data mismatch',cr,lf,eot
mtimsg0: dc.b   'M0 MIDI not received',cr,lf,eot

