*       .text
;        dc.l    $fa52235f       ;magic numbe
isburn:
        lea     $1000,sp
        move.w  #$2700,sr
        bsr     initky         
        bsr     xkeyres
        tst     d0
        bne start
;        bne     .yeskey         ; yes, start normal 
;.nokey:
;        move.w  #blue,palette
;        bra.s   .nokey

;.yeskey:
;        move.w  #green,palette
;        bra.s   .yeskey

       move.l  #EndCartAddr,a0         ; relocated cart is at around $fb0000.
.lp1:
        cmp.b   #$fa,(a0)+      ; search for next cart
        bne     .lp1
        subq.l  #1,a0                   ; put a0 back..

        move.l  #$f0000,a1
        move.w  #$7fff,d0

;       move.l  #$fb0000,a0
.lp2:
        move.w  (a0)+,(a1)+
        dbra    d0,.lp2
*--- check ram & copy.
        move.w  #$7fff,d0
.lp3:
        move.w  -(a0),d1
        cmp.w   -(a1),d1
        bne     start1
        dbra    d0,.lp3

**BurnJump - temp
;        lea.l   YankCartMsg,a5
;        bsr     dspmsg

;        move.w  #$2700,sr
;        bsr     relocVTBL       ; fix the VTBL
;        bsr     initmfp         ; reset the MFP
;        bsr     setdsp
;        bsr     esc_init        ; reset the font pointers

;     move.l  #$fffff,d0
;.1:  nop
;     sub.l    #1,d0,
;     bne      .1

;     move.w  #$ffff,d0
;.1:  nop
;     dbra    d0,.1
;     bne      .1

;        bra     Start
        jmp     $f000a

*=========================================================
;;Trigger:
;;;     Setup to get an interrupt from EX_INT (MFP IO3).
;;* CLEAR GP0
;;      move.w  #1,GPIOC        ; bit is an output
;;      move.w  #0,GPIOD
;;;
;;      move.l  #3,d0           ; 
;;      move.l  #EXint,a2               
;;      move.l  (a2),$4000      ; temp buffer used by timer.s
;;      move.l  #$4000,a2
;;      bsr     initint
;;      move.b  #$00,mfp+gpip
;;      stop    #$2400          ; wait for EXINT : RWS 1.18e
* TURN OFF MFP INTERRUPT.
;;      move.w  #$ffff,d0       ; debounce delay
;;.lp:  nop 
;;      dbra    d0,.lp 
;;      move.b  #3,d0
;;      bsr     disint
;;      rts
;;;
        
start1:
        move.w  #red,palette
        bra.s     start1


*-------------------------------
*       Keyboard reset test
*       Send reset command, wait for self-test status
*       Exit:   d0=0 if pass
*               d0=ff if fail

xkeyres:
        clr.l   d7
        moveq   #$80,d1
        bsr     ikbdput         ;output reset command
        moveq   #$1,d1
        bsr     ikbdput

*       Wait for completion
        move.l  #50000,d6
xkeycomp:
        move.b  comstat(a1),d7  ;grab midi/keyboard status
        btst    #7,d7           ; ?irq from midi/keybd?
        bne.s   xgotstat        ;got response
        sub.l   #1,d6
        bne.s   xkeycomp

        moveq   #$0,d0           ;Fail: time-out no keybd
        rts

xgotstat:
        moveq   #$ff,d0          ;Got status yes keybd
        rts
      
initky:
        movea.l #keyboard,a1            ;point to keyboard register base
        move.b  #rsetacia,comstat(a1)   ;init the acia via master reset
        move.b  #div64+protocol+rtsld+intron,comstat(a1)        
        rts

***********************
************************
*************************
**************************

;ikbdptr:
;        movea.l #kbufrec,a0     ;point to ikbd buffer record
;        movea.l #keyboard,a1    ;point to keyboard register base
;        rts

*-------------------------------
*       Put byte to keyboard                    
*       Exit:   d1=byte                         
*               eq if sent, ne if time-out      
;ikbdput:
;        movem.l d7/a0-a1,-(a7)
;        bsr     ikbdptr
;        moveq   #200,d7
;ikput0: btst    #1,comstat(a1)  ;test xmt empty
;        bne.s   ikput1
;        subq    #1,d7
;        beq.s   ikput2          ;time's up      
;        bra.s   ikput0
;ikput1: move.b  d1,iodata(a1)
;        ori     #4,ccr          ;zero
;ikput3: movem.l (a7)+,d7/a0-a1
;        rts                     ;done for now
;ikput2: andi    #$fb,ccr        ;non-zero
;        bra.s   ikput3

;.include var1
;.include hardware

