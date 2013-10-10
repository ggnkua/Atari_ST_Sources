;*****************************************************************************;
;   routines to set and/or send test tones to synth
;   also: protect() copy protection
;   Copyright 1986 Tom Bajoras
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION TONE,code

;*****************************************************************************;
;   sendtone
;*****************************************************************************;

 XDEF sendtone

sendtone movem.l  D0-A6,-(a7) ; save registers
   lea   synbuf,a6    ; init string pointer

   tst.b    toneflag
   beq   .noteon
   clr.b    d1     ; d1.b = 0 velocity = "note off"
   clr.b    toneflag  ; toggle toneflag state for next time
   bra   .1
.noteon  move.b   #64,d1    ; d1.b = 64 velocity = "note on"
   move.b   #1,toneflag  ; toggle toneflag state for next time

.1    move.b   midich,(a6)
   subq.b   #1,(a6)
   add.b    #$90,(a6)+  ; d0.b = note-on cmd including midi ch

   moveq    #16,d7   ; loop through testones array
   moveq    #0,d6    ; init # of bytes to send (minus 1)
   lea   testones,a5
   lea   tonestat,a4
.loop    move.b   (a5)+,d0 ; note #
   tst.b    (a4)+
   beq   .skipit  ; skip tones that are off
   move.b   d0,(a6)+ ; append note # to string
   move.b   d1,(a6)+ ; append velocity to string
   addq.w   #2,d6    ; increment # bytes to send
.skipit  subq.b   #1,d7
   bgt   .loop

   move.l   #synbuf,-(a7)
   move.w   d6,-(a7)
   move.w   #12,-(a7)
   trap  #14   ; midiws
   addq.l  #8,a7

   movem.l  (a7)+,D0-A6
   rts

;*****************************************************************************;
;   settone
;*****************************************************************************;

 XDEF settone

settone  movem.l  D0-A6,-(a7)  ; save registers
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

 XREF blnkscr
 XREF setcolor
 XREF message
 XREF line
 XREF getkey
 XREF bell
 XREF encode

   jsr   blnkscr   ; start with a blank screen
   move.b   #12,x1     ; change colors
   jsr   setcolor

   move.l   #tonemess,x1
   move.b   xmax,d0
   lea   tonemesl,a0
   sub.b    (a0),d0
   lsr.b    #1,d0
   addq.b   #1,d0
   move.b   d0,x2     ; center heading
   move.b   #1,x3
   move.b   cmenhed,x4
   move.b   (a0),x5
   jsr   message

   add.l    #40,x1
   addq.b   #2,x3
   move.b   #10,x2
   move.b   1(a0),x5
   jsr   message   ; column headings
   add.l    #40,x1
   move.b   #26,x2
   move.b   2(a0),x5
   jsr   message
   add.l    #40,x1
   move.b   #45,x2
   move.b   3(a0),x5
   jsr   message
   add.l    #40,x1
   move.b   #65,x2
   move.b   4(a0),x5
   jsr   message

   clr.w    x1
   move.w   #170,x2
   move.w   #639,x3
   move.w   #170,x4
   move.b   coutlne,x5
   jsr   line   ; draw line above menu

   move.l   #tonemess,x1
   add.l    #280,x1   ; put up menu
   move.b   #7,x2
   move.b   ymax,x3
   subq.b   #2,x3
   move.b   cmenu,x4
   lea   tonemesl,a0
   move.b   7(a0),x5
   jsr   message
   add.l    #40,x1
   addq.b   #1,x3
   move.b   8(a0),x5
   jsr   message
   add.l    #40,x1
   addq.b   #1,x3
   move.b   9(a0),x5
   jsr   message

   add.l    #40,x1
   move.b   #49,x2
   move.b   ymax,x3
   subq.b   #2,x3
   move.b   10(a0),x5
   jsr   message
   add.l    #40,x1
   addq.b   #1,x3
   move.b   11(a0),x5
   jsr   message

   lea   tonestat,a6  ; a6 --> tone status flags
   lea   testones,a5  ; a5 --> test tone array

   moveq    #0,d7     ; for row = 0 to 15
   move.b   cmessge,x4   ; put up row in cmessge
.rowloop bsr   putrow
   addq.b   #1,d7
   cmpi.b   #15,d7
   ble   .rowloop

   moveq    #0,d7     ; init cursor to row 0

.cursloop   move.b   cprompt,x4
   bsr   putrow

.keyloop jsr   getkey
   trap  #11    ; key repeat on
   move.b   y1,d4     ; d4.b = gotten key

   cmp.b    asciup,d4
   beq   .up
   cmp.b    ascidwn,d4
   beq   .down
   cmp.b    ascicr,d4
   beq   .return
   cmp.b    ascidel,d4
   beq   .del
   cmp.b    asciplus,d4
   beq   .plus
   cmp.b    ascidash,d4
   beq   .dash
   cmp.b    ascisp,d4
   beq   .sp
   cmp.b    ascibs,d4
   beq   .bs

.bell    jsr   bell   ; illegal key: ring bell, loop
   bra   .keyloop

.up   move.b   cmessge,x4
   bsr   putrow
   subq.b   #1,d7
   bge   .cursloop
   moveq    #15,d7
   bra   .cursloop

.down    move.b   cmessge,x4
   bsr   putrow
   addq.b   #1,d7
   cmpi.b   #15,d7
   ble   .cursloop
   moveq    #0,d7
   bra   .cursloop

.del  tst.b    0(a6,d7.l)   ; toggle tonestat
   beq   .del0
   clr.b    0(a6,d7.l)
   bra   .cursloop
.del0    move.b   #1,0(a6,d7.l)
   bra   .cursloop

.plus    cmpi.b   #126,0(a5,d7.l)
   ble   .plus1
   clr.b    0(a5,d7.l)
   bra   .cursloop
.plus1   addq.b   #1,0(a5,d7.l)
   bra   .cursloop

.dash    tst.b    0(a5,d7.l)
   bne   .dash1
   move.b   #127,0(a5,d7.l)
   bra   .cursloop
.dash1   subq.b   #1,0(a5,d7.l)
   bra   .cursloop

.sp   cmpi.b   #115,0(a5,d7.l)
   bgt   .bell
   add.b    #12,0(a5,d7.l)
   bra   .cursloop

.bs   cmpi.b   #12,0(a5,d7.l)
   blt   .bell
   sub.b    #12,0(a5,d7.l)
   bra   .cursloop

.return  move.l   (a7)+,x5  ; restore registers,x1-x5,return
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6
   rts

;*****************************************************************************;
;   putrow  --  local routine to put up a row on settone screen
;   entry conditions: x4.b = color, d7.l = row (0-15), a6--> tonestat
;         a5.l --> testones
;*****************************************************************************;

putrow   movem.l  D0-A6,-(a7) ; save registers

   move.b   #5,x3
   add.b    d7,x3     ; y-coord

   move.w   d7,x1
   jsr   encode
   move.l   y1,x1
   move.b   #13,x2
   move.b   #2,x5
   jsr   message   ; tone #

   clr.w    d0
   move.b   0(a5,d7.l),d0
   move.w   d0,x1
   jsr   encode
   move.l   y1,x1
   move.b   #30,x2
   move.b   #3,x5
   jsr   message   ; midi note #

   move.l   #tonemess,x1
   move.b   #47,x2
   lea   tonemesl,a0
   move.b   5(a0),x5
   tst.b    0(a6,d7.l)
   beq   .off
   add.l    #200,x1
   bra   .offon
.off  add.l    #240,x1
.offon   jsr   message   ; off/on

   move.l   #notename,x1
   clr.l    d0
   move.b   0(a5,d7.l),d0
   divu  #12,d0
   clr.l    d1
   move.w   d0,d1
   lsr.l    #8,d0
   lsr.l    #7,d0
   add.l    d0,x1
   move.b   #65,x2
   move.b   #2,x5
   jsr   message   ; midi note name
   move.l   #octname,x1
   lsl.l    #1,d1
   add.l    d1,x1
   addq.b   #2,x2
   move.b   #2,x5
   jsr   message   ; midi octave name

   movem.l  (a7)+,D0-A6 ; restore registers
   rts


;******************
; rs232 routines
;******************
; xmit - send char in d0 to serial port
; recv - get char from serial port to d0
; rcvstat - get port status d0=0 no char, d0=-1 char
; crwait - get char w/timeout error checking

xmit:
 move  d0,-(a7)  ; char to send
 move  #1,-(a7)  ; dev=aux
 move  #3,-(a7)  ; bconout
 trap  #13
 addq.l   #6,a7
 rts

;**********
recv:
 move  #1,-(a7)  ; dev=aux
 move  #2,-(a7)  ; bconin
 trap  #13
 addq.l   #4,a7
 rts

;**********
rcvstat:
 move  #1,-(a7)  ; dev=aux
 move  #1,-(a7)  ; bconstat
 trap  #13
 addq.l   #4,a7
 rts

;**********
crwait:
 bsr   rcvstat
 tst   d0
 beq   nogo   ; no char
 move.l   4(a6),a0  ; a0 --> errcnt
 move  #0,(a0)   ; clear counter
 bra   recv   ; get char

nogo:
 move.l   4(a6),a0  ; a0 --> errcnt
 move  (a0),d0
 addq  #1,d0     ; inc error counter
 cmpi  #5000,d0  ; overflow?
 bne   stillgo   ; keep trying
 clr.l    d0     ; 'no box' message (time-out)
 rts
stillgo:
 move.l   4(a6),a0  ; a0 --> errcnt
 move  d0,(a0)
 bra   crwait    ; keep lookin'

;***************
; CRC routines
;***************
; clrcrc - clear the CRC accumulator
; addcrc - add a byte to the CRC, call w/d0=byte
; fincrc - calculate final CRC

clrcrc:
 move.l   12(a6),a0    ; a0 --> crc
 move.w   #0,(a0)
 rts

;**********
addcrc:
 moveq    #7,d1     ; count
 move.l   12(a6),a0    ; a0 --> crc
 move.w   (a0),d2   ; old value
crcloop:
 lsl.b    #1,d0
 roxl.w   #1,d2
 bcc   skipit
 eori.w   #$8005,d2
skipit:
 dbf   d1,crcloop
 move.l   12(a6),a0    ; a0 --> crc
 move.w   d2,(a0)
 rts

;**********
fincrc:
 moveq.l  #0,d0
 bsr   addcrc
 moveq.l  #0,d0
 bsr   addcrc
 rts

 XDEF protectx
protectx:
 rts     ; this marks the end of code that will be CRC'd

 XDEF setlong
setlong:       ; equivalent to    move.l d0,(a0)
   movem.l  D0-A6,-(a7)
   move.l   d0,saved0
   move.l   a0,savea0
   move.l   #setcode,-(a7)
   move.w   #38,-(a7)
   trap  #14
   addq.l   #6,a7
   movem.l  (a7)+,D0-A6
   rts
setcode  move.l   saved0,d0
   move.l   savea0,a0
   move.l   d0,(a0)
   rts

 XDEF getlong
getlong:      ; equivalent to move.l (d0),d0
   movem.l  D0-A6,-(a7)
   move.l   d0,saved0
   move.l   #getcode,-(a7)
   move.w   #38,-(a7)
   trap  #14
   addq.l   #6,a7
   move.l   saved0,d0
   movem.l  (a7)+,D0-A6
   rts
getcode  move.l   saved0,a0
   move.l   (a0),saved0
   rts

 SECTION _MERGED,bss

saved0  ds.l   4        ; for setlong() and getlong()
savea0  ds.l   4        ; for setlong()

;*****************************************************************************;
;   local data:  midi note names and messages
;*****************************************************************************;

 SECTION _Merged,data

notename dc.b   "C C#D D#E F F#G G#A A#B "
octname  dc.b   "-2-10 1 2 3 4 5 6 7 8 "
tonemess dc.b   "Set Test Tonesxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 0
   dc.b   "Tone #xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 1
   dc.b   "MIDI Note #xxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 2
   dc.b   "On/Offxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 3
   dc.b   "Notexxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 4
   dc.b   "on xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 5
   dc.b   "offxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"   ; 6
   dc.b   "arrows  move cursor xxxxxxxxxxxxxxxxxxxx"   ; 7
   dc.b   "[+][-]  +/- note # xxxxxxxxxxxxxxxxxxxxx"   ; 8
   dc.b   "[sp][bs] +/- octave xxxxxxxxxxxxxxxxxxxx"   ; 9
   dc.b   "[del]  note on/off xxxxxxxxxxxxxxxxxxxxx"   ;10
   dc.b   " [cr]  go to utility menu xxxxxxxxxxxxxx"   ;11
tonemesl dc.b    14,6,11,6,4,3,3,19,18
   dc.b    19,18,25
