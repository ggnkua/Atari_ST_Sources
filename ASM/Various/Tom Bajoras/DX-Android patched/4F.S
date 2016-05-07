;*****************************************************************************;
;   module 4f source file    Copyright 1986 Tom Bajoras
;   utility menu command branching routine: br6anch
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION fourf,code

;*****************************************************************************;
;   br6anch
;      x1 = itemx
;*****************************************************************************;

 XDEF br6anch

 XREF branch1
 XREF branch5
 XREF branch9
 XREF branch11
 XREF branch13
 XREF infobar
 XREF settone
 XREF setdx7
 XREF readbtx7
 XREF readbdx7
 XREF writfdx7
 XREF writdx7
 XREF wstosyn
 XREF value
 XREF initscr
 XREF initdsc
 XREF bell
 XREF readinfo
 XREF unpromp
 XREF getkey
 XREF getyn
 XREF message
 XREF creturn
 XREF writinfo

br6anch  movem.l  D0-A6,-(a7)  ; save registers and x1-x5
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   moveq    #5,d6      ; d6.l = menux = 5
   move.l   x1,d0      ; branch according to itemx
   beq   swap
   cmpi.b   #1,d0
   beq   setmidi
   cmpi.b   #2,d0
   beq   setmon
   cmpi.b   #4,d0
   beq   scrallf
   cmpi.b   #3,d0
   beq   catsyn
   cmpi.b   #5,d0
   beq   scrallb
   cmpi.b   #6,d0
   beq   setup
   cmpi.b   #7,d0
   beq   tones
   cmpi.b   #8,d0
   beq   thru
         ; illegal itemx simply returns
return  move.l   d6,x1
   jsr   infobar   ; update info bar
   move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

swap    jsr   writinfo
   tst.b    y1
   beq   .swap2
   move.l   d6,x1     ; write failed
   jsr   creturn
   move.l   #reason,x1
   add.l    #920,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cmessge,x4
   move.b   reasonl,x5
   jsr   message    ; "cannot write to disk."
   move.l   d6,x1
   jsr   creturn
   move.l   #messss,x1
   add.l    #1320,x1
   move.b   cursory,x3
   lea   messsl,a0
   move.b   33(a0),x5
   jsr   message   ; could cause loss of data
   move.l   d6,x1
   jsr   creturn
   move.l   #-1,x1
   move.l   #37,x2
   jsr   getyn     ; change disks?
   tst.b    y1
   bne   .swap2    ; yes: continue as though successful
   jsr   branch5   ; no: abort
.swap2   move.l   d6,x1     ; write succeeded
   jsr   creturn
   move.l   #messss,x1
   add.l    #1880,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cprompt,x4
   lea   messsl,a0
   move.b   47(a0),x5
   jsr   message   ; "insert new data disk."
   jsr   getkey   ; wait for a key
   jsr   unpromp
   jsr   readinfo
   tst.b    y1    ; read succeeded: go no farther
   bne   .swapbad
   clr.b    lastbank
   bra   return
.swapbad cmpi.b   #3,y1
   beq   .swap3
   move.l   d6,x1    ; can't read
   jsr   creturn
   move.l   #messss,x1
   add.l    #320,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cprompt,x4
   lea   messsl,a0
   move.b   8(a0),x5
   jsr   message   ; "disk drive error.  Format disk?"
   bra   .keyloop
.swap3   move.l   d6,x1     ; disk not a valid data disk
   jsr   creturn
   move.l   #strtmes,x1
   add.l    #80,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cprompt,x4
   lea   strtmesl,a0
   move.b   2(a0),x5
   jsr   message   ; "format it?"
.keyloop jsr   getkey    ; wait for a key
   move.b   y1,d7
   cmp.b    ascin,d7
   beq   .no
   cmp.b    asciy,d7
   beq   .yes
   jsr   bell  ; bad key: ring bell, get another key
   bra   .keyloop
.no   jsr   unpromp  ; no: loop
   bra   .swap2
.yes  jsr   unpromp  ; yes: try to format it
   jsr   initdsc
   move.b   y1,d7     ; protect y1 from initscr
   move.l   d6,x1
   move.l   d0,x2
   jsr   initscr
   tst.b    d7
   bne   .swap2     ; successful? no: try again
   clr.b    lastbank   ; yes: reset most recently selected bank
   bra   return    ; and get out of here

setmidi lea   .setmidi2,a6   ; loop back if bad #
.setmidi2   moveq    #2,d7
   jsr   branch9   ; get #
   jsr   value
   move.l   y1,d1     ; d1.l = #
   ble   .setmidi3    ; bad # if < 1 or > maxmidi
   cmp.l    #$7F,d1
   bgt   .setmidi3
   cmp.b    maxmidi,d1
   bgt   .setmidi3
   move.b   d1,midich    ; midich = #
   bra   return   ; restore x5-x1 and registers,return
.setmidi3   move.l   #1,x2
   jsr   branch11  ; bad # routine

setmon  tst.b    monws     ; toggle monws
   bne   .setmon2
   move.b   #1,monws
   jsr   wstosyn  ; when toggling to monws=1
   jsr   writdx7  ; send w.s. to synth
   move.l   #wkspace,x1
   add.l    #145,x1
   jsr   writfdx7
   bra   return
.setmon2 clr.b    monws
   bra   return

scrallf tst.w    nfiles
   bne   .scrallf2
   move.l   #7,x3    ; error if no files
   jsr   branch1
.scrallf2   tst.w    nfillok
   beq   .scrallf3
   move.l   #21,x3   ;     -- at least 1 file locked
   jsr   branch1
.scrallf3   move.l   d6,x1
   jsr   creturn
   move.l   #9,x1
   move.l   #6,x2
   jsr   getyn    ; prompt 'are you sure? (y/n) '
   tst.b    y1
   bne   .scrallf4
   jsr   branch5    ; if no , abort
.scrallf4   jsr   scrallf  ; scratch all files
   jsr   writinfo
   bra   return  ; restore registers and x1-x5 , return

catsyn  jsr   readbdx7
   tst.b    y1
   beq   .success
   cmpi.b   #2,y1
   beq   synerr
   jsr   readbtx7
   tst.b    y1
   bne   synerr
.success jsr   catsyn     ; catalog synth
   jsr   branch13   ; re-init screen, return
synerr   move.b   y1,d1     ; protect y1
   move.l   d6,x1
   jsr   creturn
   move.l   #messss,x1
   move.b   #1,x2
   move.b   cursory,x3
   move.b   cmessge,x4
   lea   messsl,a0
   cmpi.b   #1,d1
   bne   synerr2
   add.l    #600,x1   ; time-out error
   move.b   15(a0),x5
   bra   synerrx
synerr2  add.l    #1360,x1  ; format error
   move.b   34(a0),x5
synerrx  jsr   message
   bra   return

scrallb tst.b    nbanks
   bne   .scrallb2
   move.l   #22,x3     ; error if no banks on disk
   jsr   branch1
.scrallb2   move.l   d6,x1
   jsr   creturn
   move.l   #12,x1
   move.l   #6,x2
   jsr   getyn      ; are you sure ? (y/n)
   tst.b    y1
   bne   .scrallb3
   jsr   branch5    ; n: abort
.scrallb3   jsr   scrallb    ; scratch all banks
   jsr   writinfo
   clr.b    lastbank  ; reset most recently selected bank
   bra   return    ; restore registers,x1-x5,return

setup   jsr   setdx7
   bra   return

tones   move.b   #1,invtext
   jsr   settone
   clr.b    invtext
   trap  #10
   jsr   branch13

thru    move.w   #13,-(a7)
   tst.b    thruflag  ; toggle thruflag
   bne   .thru2
   move.l   midiaddr,a0
   clr.w    6(a0)
   clr.w    8(a0)     ; first clean out midi buffer
   move.b   #1,thruflag  ; enable interrupt
   move.w   #27,-(a7)
   bra   .thru3
.thru2   clr.b    thruflag  ; disable interrupt
   move.w   #26,-(a7)
.thru3   trap  #14
   addq.l   #4,a7
   bra   return
