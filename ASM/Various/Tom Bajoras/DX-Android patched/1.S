;*****************************************************************************;
;   module 1 source file Copyright 1986 Tom Bajoras
;   main executive loop, startup/initialization, and finishup routines:
;   _main , startup , initsec , initpri1 , finish , f10proc
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION Main,code

;*****************************************************************************;
;   _main -- main executive loop
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF _main

_main:
   move.w   #4,-(a7)  ; get rez
   trap  #14
   addq.l   #2,a7
   tst.w    d0
   bne   @main
   dc.w    $A00A      ; hide mouse
   move.w   #$1b,-(a7)    ; clear screen / home cursor
   move.w   #2,-(a7)
   trap  #1
   addq.l   #4,a7
   move.w   #$45,-(a7)
   move.w   #2,-(a7)
   trap  #1
   addq.l   #4,a7
   move.l   #badrez,-(a7) ; can't accept low rez
   move.w   #9,-(a7)
   trap  #1
   addq.l   #6,a7
   move.l   #anykey,-(a7) ; prompt for any key
   move.w   #9,-(a7)
   trap  #1
   addq.l   #6,a7
   move.w   #7,-(a7)  ; wait for a key
   trap  #1
   addq.l   #2,a7
   dc.w    $A009     ; show mouse
   rts       ; bail out
badrez   dc.w    $0d0a
   dc.b   "Screen resolution must be set to medium.",0
anykey   dc.w    $0d0a
   dc.b   "Type any key to return to GEM Desktop.",0

; init some stuff once and for all:
@main    bsr   initpri1
   bsr   startup   ; start-up stuff
   tst.b    y1     ; if 'y' to go-prompt, continue,
   beq   finish    ; else exit

main1    bsr   initsec   ; init stuff
   move.l   #-1,x2    ; initscr 2nd arg, no recentx
   lea   brcalls,a0   ; a0 --> brcalls
   moveq    #100,d0   ; start with main menu

 XREF wstoed

main2    subi.l   #100,d0   ; d0.l = menux (0-6)
   cmpi.l   #1,d0
   bne   main3
   jsr   wstoed    ; when going to edit menu, copy ws to e
   clr.b    monedit   ; and set default edit monitoring mode

 XREF initscr

main3    move.l   d0,x1
   jsr   initscr   ; call initscr(menux,-1)

 XREF getmenu

main4    move.l   d0,x1     ; come here after br_x_anch
   jsr   getmenu   ; y1.l = itemx
   move.l   d0,d1     ; d1.l = menux (0-6)
   move.l   y1,d0     ; d0.l = itemx
   cmpi.l   #100,d0
   bge   main2     ; if function key, go to main2
   move.l   d0,x1     ; x1.l = itemx for br_x_anch
   move.l   d1,d0     ; d0.l = menux (0-6)
   lsl.l    #3,d1     ; index into brcalls
   jsr   0(a0,d1.l)   ; call appropriate br_x_anch
   bra   main4     ; loop to get next menu selection

 XREF br1anch
 XREF br2anch
 XREF br3anch
 XREF br4anch
 XREF br5anch
 XREF br6anch
 XREF br7anch
 XREF br8anch

brcalls  jsr   br1anch   ; table of br_x_anch calls
   rts
   jsr   br2anch
   rts
   jsr   br3anch
   rts
   jsr   br4anch
   rts
   jsr   br5anch
   rts
   jsr   br6anch
   rts
   jsr   br7anch
   rts
   jsr   br8anch
   rts

;*****************************************************************************;
;   finish -- prepare for return to desktop
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF finish
 XREF blnkscr
 XREF message
 XREF getkey
 XREF setcolor

finish   jsr   blnkscr   ; "remove data disk"
   move.l   #messss,x1
   add.l    #1800,x1
   move.b   #1,x2
   move.b   #1,x3
   move.b   cprompt,x4
   lea   messsl,a0
   move.b   45(a0),x5
   jsr   message
   jsr   getkey

   jsr   blnkscr   ; blank screen
   move.b   #-2,x1    ; restore saved colors
   jsr   setcolor

   trap  #11    ; enable key-repeat

 XREF prt_on
   jsr   prt_on    ; enable alt-help screen dump

   move.w   #13,-(a7)    ; disable midi thru
   move.w   #26,-(a7)
   trap  #14
   addq.l   #4,a7

.skipthru   move.w   #34,-(a7)    ; enable mouse and pseudo-mouse
   trap  #14
   addq.l   #2,a7
   add.l    #16,d0
   move.l   d0,a0
   move.l   mousvec,(a0)

   rts       ; RETURN TO CST MODULE!

;*****************************************************************************;
;   initpri1 -- init some stuff
;      no entry conditions, no exit conditions
;      no registers are preserved
;   Note:  For copy-protection purposes, the primary initialization code
;       is scattered (daisy-chained) evenly across the entire program!
;       initpri1 calls initpri2 which calls initpri3 which calls initpri4
;       etc. until initpri8 calls protect
;*****************************************************************************;

 XDEF initpri1
 XREF prt_off

initpri1:
   move.l   #an_rte,-(a7)    ; fix up spurious interrupt
   move.w   #24,-(a7)
   move.w   #5,-(a7)
   trap  #13
   addq.l   #8,a7

   jsr   prt_off   ; disable alt-help screen dump

   move.w   #34,-(a7)    ; turn off mouse and pseudo-mouse
   trap  #14
   addq.l   #2,a7
   add.l    #16,d0
   move.l   d0,a0
   move.l   (a0),mousvec
   move.l   #.return,(a0)

   move.w   #$19,-(a7)   ; get default drive
   trap  #1
   addq.l   #2,a7
   cmpi.w   #1,d0
   ble   .drive
   clr.w    d0
.drive   move.w   d0,currdrv

 XREF initpri2

; daisy-chain off to next section of initializing code:
   jsr   initpri2

   lea   editmess,a0
   clr.b    1840(a0)   ; clear crash flag

   trap  #9     ; blank screen

   move.w   startrez,-(a7)  ; go to startup screen rez
   move.l   #-1,-(a7)
   move.l   #-1,-(a7)
   move.w   #5,-(a7)
   trap  #14
   lea 12(sp),sp

   move.b   #-1,x1    ; go to startup colors
   jsr   setcolor

     dc.w    $A000    ; init "A-line" interface
   move.l   a0,vdiaddr    ; vdiaddr --> vdi arg passing area
   clr.l    d0
   move.w   bwflag,d0
   lsl.l    #2,d0      ; d0 = 4 for color, = 8 for b&w
   add.l    d0,a1
   move.l   (a1),a2    ; use the appropriate system font
   move.w   $24(a2),lowascii ; lowest ascii code in the font
   move.l   $48(a2),ofstaddr ; address of character offset table
   move.l   $4C(a2),fontaddr ; fontaddr --> font data
   move.w   $50(a2),formleng ; # bytes per line in font data
   move.w   $52(a2),formhigh ; # scan lines in font data

   move.l   midiaddr,a0
   clr.w    6(a0)      ; clean out MIDI queue
   clr.w    8(a0)

   move.l   #mthru,-(a7)  ; install midi thru routine
   move.w   #64,-(a7)     ; on 2400hz timer A
   move.w   #3,-(a7)
   clr.w    -(a7)
   move.w   #31,-(a7)
   trap  #14
   lea 12(sp),sp
.return  rts        ; exit from initpri1

mthru    movem.l  D0-A6,-(a7)
   move.w   SR,-(a7)
   ori.w    #$700,SR
   movea.l  midiaddr,a0
   move.w   6(a0),d0
   cmp.w    8(a0),d0
   beq   exitthru
   addq.w   #1,d0
   cmp.w    4(a0),d0
   bcs   nowrap
   clr.w    d0
nowrap   move.l   (a0),a1
   move.b   0(a1,d0.w),d1     ; d1.b= MIDI byte
   move.w   d0,6(a0)
   blt   statbyte
   tst.b    sysxflag
   bne   exitthru
   bra   exitsend
statbyte cmpi.b   #$F0,d1
   bne   ne_f0
   move.b   #1,sysxflag
   bra   exitthru
ne_f0    cmpi.b   #$FE,d1
   beq   exitthru
   tst.b    sysxflag
   beq   exitsend
   clr.b    sysxflag
   bra   exitsend
exitthru move.w   (a7)+,SR
   movem.l  (a7)+,D0-A6
   bclr  #5,$FFFFFA0F
an_rte   rte
sysxflag ds.b   1
exitsend lea   $FFFFFC04,a1
exsdloop move.b   (a1),d2
   btst  #1,d2
   beq   exsdloop
   move.b   d1,2(a1)
   bra   exitthru

;*****************************************************************************;
;   initsec -- init some more stuff
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF initsec
 XREF initws
 XREF initwb
 XREF setdx7
 XREF wstosyn
 XREF writdx7
 XREF writfdx7

initsec  movem.l  D0-A6,-(a7) ; save registers

   move.w   #13,-(a7)    ; disable midi thru
   move.w   #26,-(a7)
   trap  #14
   addq.l   #4,a7

   jsr   initws    ; set ws = initsound/initname
   jsr   initwb    ; set each wb slot = initsound/initname
   move.b   #1,midich    ; default midi ch = 1
   move.b   #1,monws  ; w.s. monitoring on
   jsr   setdx7
   jsr   wstosyn
   jsr   writdx7   ; send initsound to synth
   move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7

   clr.b    lastbank  ; no recently selected bank yet
   lea   testones,a0
   moveq    #16,d0
.loop1   move.b   #60,(a0)+    ; all test tones = middle c
   subq.b   #1,d0
   bgt   .loop1

   lea   midichs,a0
   lea   qustat,a1
   moveq    #1,d0
.loop2   cmpi.b   #16,d0
   bgt   .gt2
   move.b   d0,(a0)+
   move.b   #1,(a1)+
   bra   .next
.gt2  move.b   #1,(a0)+  ; quick-send midi ch's = 1-16,1,1
   clr.b    (a1)+     ; quick-send statuses = 1,1,1...1,0,0
.next    addq.b   #1,d0
   cmpi.b   #18,d0
   ble   .loop2

   lea   tonestat,a0
   move.b   #1,(a0)   ; first tone on, all others off

   movem.l  (a7)+,D0-A6 ; restore registers
   rts

;*****************************************************************************;
;   startup -- put up and process title screen dialogue
;      y1 = 0 to exit = 1 (b) to enter
;*****************************************************************************;

 XDEF startup
 XREF unpromp
 XREF readinfo
 XREF bell

startup  trap  #7     ; put startupfile on screen

   lea   strtmes,a6   ; a6 --> startup screen messages
   lea   strtmesl,a5 ; a5 --> startup screen messages' lengths
   move.b   ascicr,d7   ; d7 = carriage return
   move.b   ymax,x3
   subq.b   #2,x3
   move.b   #20,d0
   tst.w    startrez
   beq   .0
   move.b   #40,d0
.0    sub.b    #19,d0   ; fudge the message length
   move.b   d0,x2
   move.l   a6,x1    ; copyright notice
   add.l    #360,x1
   move.b   cstart,x4
   move.b   9(a5),x5
   jsr   message
   addq.b   #1,x3
   bra   .11

.1    move.b   cprompt,x4
.11   move.l   a6,x1
   move.b   (a5),x5
   jsr   message  ; insert data disk prompt
   add.l    #40,x1   ; (must be done in two parts)
   addq.b   #1,x3
   move.b   1(a5),x5
   jsr   message
   move.b   #1,x2    ; restore x-coord to 1 for all other messages
   jsr   getkey   ; get a key
   move.b   y1,d0    ; d0.b = gotten key
   move.b   x3,cursory
   jsr   unpromp  ; change prompt to color cmessge
   subq.b   #1,cursory
   jsr   unpromp
   cmp.b    d0,d7    ; <cr> aborts out of the program
   beq   .return0
         ; attempt to read info file:
   jsr   readinfo
   jsr   blnkscr
   bsr   normrez  ; go to normal rez
   tst.b    y1    ; readinfo succeeded?
   beq   .return1
   cmpi.b   #1,y1    ; disk drive error
   beq   .y1
   cmpi.b   #3,y1    ; disk is not a valid data disk
   beq   .y3

.y1   move.l   a6,x1
   add.l    #120,x1
   move.b   #1,x3
   move.b   cmenkey,x4
   move.b   3(a5),x5
   jsr   message  ; disk drive error
   add.l    #40,x1
   addq.b   #1,x3
   move.b   cmessge,x4
   move.b   4(a5),x5
   jsr   message  ; list possible causes
   add.l    #40,x1
   addq.b   #1,x3
   move.b   5(a5),x5
   jsr   message
   add.l    #40,x1
   addq.b   #1,x3
   move.b   6(a5),x5
   jsr   message
   move.l   a6,x1
   add.l    #320,x1
   addq.b   #1,x3
   move.b   8(a5),x5
   jsr   message

   move.l   a6,x1
   add.l    #400,x1
   addq.b   #1,x3
   move.b   cprompt,x4
   move.b   10(a5),x5
   jsr   message  ; what do you want to do about it?
.keyloop jsr   getkey
   move.b   y1,d0
   cmp.b    ascia,d0
   beq   .try
   cmp.b    ascib,d0
   beq   .2
   cmp.b    ascic,d0
   beq   .return0
   jsr   bell
   bra   .keyloop
.try  jsr   blnkscr
   move.b   #1,x3
   bra   .1

.y3   move.l   a6,x1    ; format it?
   add.l    #80,x1
   move.b   #1,x3
   move.b   cprompt,x4
   move.b   2(a5),x5
   jsr   message
.yesno   jsr   getkey
   move.b   y1,d0    ; d0 = gotten key
   cmp.b    asciy,d0
   beq   .2    ; yes: format it
   cmp.b    ascin,d0
   bne   .yesno
   move.b   x3,cursory
   jsr   unpromp

   move.l   a6,x1
   add.l    #280,x1
   addq.b   #1,x3
   move.b   cmessge,x4
   move.b   7(a5),x5
   jsr   message  ; try again
   addq.b   #1,x3
   bra   .1    ; loop back to get another key

 XREF initdsc

.2    jsr   initdsc  ; yes:  format it
   tst.b    y1    ; ok?
   beq   .return1
   jsr   blnkscr
   move.b   #1,x3
   bra   .1

.return0 jsr   blnkscr  ; blank screen
   bsr   normrez  ; go to correct rez and colors
   clr.b    y1    ;  y1.b = 0
   bra   .return
.return1 move.b   #1,y1    ;  y1.b = 1
.return  rts      ;  return

normrez  movem.l  D0-A6,-(a7)
   move.w   bwflag,-(a7) ; go back to medium or high rez
   move.l   #-1,-(a7)
   move.l   #-1,-(a7)
   move.w   #5,-(a7)
   trap  #14
   add.l    #12,a7
   clr.b    x1     ; go to menu screen colors
   jsr   setcolor
   movem.l  (a7)+,D0-A6
   rts

;*****************************************************************************;
;   f10proc -- called from getmenu when F10 key pressed
;      x1.l = menux , no exit conditions
;*****************************************************************************;

 XDEF f10proc

f10proc  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

 XREF creturn
 XREF getyn

   move.l   x1,d7     ; d7.l = menux (for scrolling)
   jsr   creturn   ; move cursor to next line
   move.l   #-1,x1
   move.l   #29,x2
   jsr   getyn     ; quit? (y/n)
   tst.b    y1
   beq   .return   ; n: return to getmenu

 XREF writinfo

   jsr   writinfo  ; try to write info tables to disk
   tst.b    y1
   beq   .exit     ; ok

   move.l   d7,x1
   jsr   creturn   ; move cursor to next line

   move.l   #reason,x1   ; disk drive error
   add.l    #200,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cmessge,x4
   move.b   reasonl,x5
   jsr   message

   move.l   d7,x1
   jsr   creturn   ; move cursor to next line
   move.l   #messss,x1
   add.l    #1640,x1
   move.b   cursory,x3
   lea   messsl,a0
   move.b   41(a0),x5
   jsr   message   ; exiting could cause data loss
   move.l   d7,x1
   jsr   creturn   ; move cursor to next line
   move.l   #-1,x1
   move.l   #29,x2
   jsr   getyn     ; quit anyway?
   tst.b    y1
   beq   .return   ; n: return to getmenu

.exit    add.l    #168,a7   ; pop everything off stack
   bra   finish    ; go to finish
.return  move.l   (a7)+,x5
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore x5-x1, registers
   rts       ; return to getmenu
