;*****************************************************************************;
;   module 13 source file    Copyright 1986 Tom Bajoras
;   complex screen and keyboard i/o:
;   cannot, getit, abort, errmess, getyn, getabc, tagtry, getslot
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION thirteen,code

;*****************************************************************************;
;   cannot
;      x1 = menux 0-6 (l), x2 = itemx 0-19 (l), x3 = reasonx (l)
;*****************************************************************************;

 XDEF cannot

 XREF creturn
 XREF bell
 XREF unpromp
 XREF getkey
 XREF getchar
 XREF outchar
 XREF message

cannot   movem.l  d0-a6,-(a7)  ; save registers and x1-x5
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   jsr   creturn    ; carriage return

   move.l   x1,d0      ; d0 = menux 0-6 (l)
   mulu  #4,d0
   lea   menuaddr,a3
   movea.l  0(a3,d0.l),a1    ; a1 --> menu items for this menu

   move.l   x1,d0
   mulu  #20,d0
   lea   menulen,a0
   adda.l   d0,a0       ; a0 --> array of lengths of menu items
   move.l   x2,d0
   move.b   0(a0,d0.l),d7    ; d7 =  # chars in this menu item
   mulu  #20,d0
   adda.l   d0,a1      ; a1 --> this menu item
   move.l   x1,d0
   move.l   x3,d1
   lea   reason,a3
   mulu  #40,d1
   adda.l   d1,a3      ; a3 --> reason
   lea   messss,a4
   move.l   a4,x1
   add.l    #160,x1    ; x1 --> "cannot"
   move.b   #1,x2      ; xcoord = 1
   move.b   cursory,x3    ; ycoord = cursory
   move.b   cmessge,x4    ; color = cmessge
   lea   messsl,a4
   move.b   4(a4),x5   ; # of chars in "cannot"
   jsr   message    ; write 'cannot'
   cmpi.b   #3,d0
   bne   cannot2
   lea   catmess,a1    ; menu item for all catalog
   move.b   catmesl,d7    ; menu items is "catalog"
cannot2  move.l   a1,x1
   move.b   x5,x2
   addq.b   #2,x2
   move.b   d7,x5
   jsr   message    ; append menu item

   move.b   asciper,x1    ; append period
   add.b    d7,x2
   jsr   outchar

   move.l   a3,x1
   addq.b   #2,x2
   move.b   reasonl,x5    ; all reasons are 40 chars
   jsr   message    ; append reason

   move.l   (a7)+,x5   ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6  ; restore registers
   rts        ; return

;*****************************************************************************;
;   getit
;      x1 = promptx (l), y1 --> 10-char buffer (l) , y2 = 1/0 abort/no-abort
;*****************************************************************************;

 XDEF getit

getit    movem.l  d0-a6,-(a7)  ; save registers
   move.l   x1,-(a7)   ; save x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)
   move.b   x5,d5      ; default flag

   move.b   #1,allowlc    ; allow lower case input
   move.l   x1,d0      ; d0.l = promptx
   lea   promptl,a0
   move.b   0(a0,d0.l),d1    ; # of chars in this prompt
   move.b   d1,x5
   lea   prompt,a0
   mulu  #40,d0
   adda.l   d0,a0      ; a0 --> prompt
   move.l   a0,x1
   move.b   #1,x2      ; x-coord = 1
   move.b   cursory,x3    ; y-coord = cursory
   move.b   cprompt,x4    ; prompt in color cprompt
   jsr   message    ; prompt

   move.b   ascisp,d3    ; d3 = space
   move.b   cbakgnd,d4   ; d4 = color cbakgnd
   move.b   d1,d2
   addq.b   #2,d2
   move.b   d2,d7     ; d7.b--> start of echo area
   tst.b    d5
   beq   getit2
   move.l   #wksname,x1
   move.b   d2,x2
   move.b   cursory,x3
   move.b   cmessge,x4
   move.b   #10,x5
   jsr   message    ; default w.s. name
   add.b    #10,d2
   move.b   cursory,x2
   move.b   d2,x1
.loop    jsr   getchar   ; search for end of w.s. name
   cmp.b    y1,d3
   beq   .next
   tst.b    y1
   beq   .next
   move.b   x1,d2
   addq.b   #1,d2
   bra   getit2
.next    subq.b   #1,x1
   bne   .loop
   move.b   d7,d2     ; couldn't find end of w.s. name

getit2   jsr   getkey    ; get a key
   move.b   y1,d5     ; d5.b = key

   cmp.b    ascibs,d5    ; process backspace key
   bne   getit3
   cmp.b    d2,d7     ; if already at start of echo area
   beq   getit2    ; do nothing: get another key
   subq.b   #1,d2     ; else blank out character to
   move.b   d3,x1     ; left of invisible "cursor"
   move.b   d2,x2
   move.b   cursory,x3
   move.b   d4,x4
   jsr   outchar
   bra   getit2    ; get another key

getit3   cmp.b    ascidel,d5   ; process delete key
   bne   getit5
   move.b   d7,d2   ; move invisible "cursor" to start of echo area
   move.b   d3,x1
   move.b   cursory,x3
   move.b   d4,x4
   move.b   d7,x2
   move.b   #-1,d6    ; blank out entire echo area (10 chars)
getit4   addq.b   #1,d6     ; and then get another key
   cmpi.b   #9,d6
   bgt   getit2
   jsr   outchar
   add.b    #1,x2
   bra   getit4

getit5   cmp.b    ascicr,d5    ; process carriage return key
   bne   getit8
   jsr   unpromp   ; change the prompt to color cmessge
   move.b   #1,d2     ; abort flag (default = abort)
   lea   namebuf,a1
   move.b   cursory,x2
   move.b   d7,x1
   moveq    #-1,d6    ; loop through the echo area:
getit6   addq.b   #1,d6     ; move all echoed characters into
   cmpi.b   #9,d6     ; namebuf.
   bgt   getit7    ; If any of them are not spaces
   jsr   getchar   ; clear the abort flag.
   add.b    #1,x1     ; (i.e. all spaces = abort)
   move.b   y1,d5
   move.b   d5,(a1)+
   cmp.b    ascisp,d5
   beq   getit6
   clr.b    d2
   bra   getit6
getit7   lea   namebuf,a1
   move.l   a1,y1     ; pass back address of namebuf
   move.b   d2,y2     ; pass back abort flag
   clr.b    allowlc   ; stop allowing lower case input
   move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6 ; restore registers
   rts       ; return

getit8   cmp.b    d3,d5     ; if key is <= space or > delete
   ble   getit9    ; then it is illegal:  ring bell
   cmp.b    ascidel,d5   ; and get another key
   bgt   getit9

   move.b   d7,d5     ; even if key is legal:  if
   addi.b   #10,d5    ; echo area is full (10 non-
   cmp.b    d5,d2     ; spaces) ring bell and get
   beq   getit9    ; another key

   move.b   y1,x1     ; echo the key, at invisible
   move.b   d2,x2     ; "cursor" position, in color cecho
   move.b   cursory,x3
   move.b   cecho,x4
   jsr   outchar
   addq.b   #1,d2     ; move invisible "cursor" one
   bra   getit2    ; space to right and get another key

getit9   jsr   bell   ; ring bell/get another key sequence
   bra   getit2

;*****************************************************************************;
;   abort
;      x1 = menux 0-6 (l) , x2 = itemx 0-19 (l)
;*****************************************************************************;

 XDEF abort

abort    movem.l  d0-a6,-(a7)  ; save registers
   move.l   x1,-(a7)   ; save x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   jsr   creturn    ; carriage return
   move.l   x1,d0
   mulu  #4,d0
   lea   menuaddr,a3
   movea.l  0(a3,d0.l),a1   ; a1 --> menu items for this menu
   move.l   x1,d0
   mulu  #20,d0
   lea   menulen,a0
   adda.l   d0,a0     ; a0 --> array of menu item lengths
   move.l   x2,d0
   adda.l   d0,a0    ; a0 --> length of this menu item
   mulu  #20,d0
   adda.l   d0,a1    ; a1 --> this menu item
   move.l   x1,d0
   cmpi.l   #3,d0
   beq   abort2
   move.b   (a0),d7  ; menu item for all catalog menu items
   bra   abort3   ; is "catalog"
abort2   lea   catmess,a1
   move.b   catmesl,d7
abort3   move.b   #1,x2    ; x-coord = 1
   move.b   cursory,x3     ; y-coord = cursory
   move.l   a1,x1     ; x1 --> menu item
   move.b   d7,x5     ; x5 = menu item length
   move.b   cmessge,x4   ; color = cmessge
   jsr   message   ; write menu item

   lea   messss,a0
   adda.l   #120,a0
   move.l   a0,x1     ; x1 --> "aborted."
   add.b    d7,x2     ; append
   addq.b   #1,x2
   lea   messsl,a0
   move.b   3(a0),x5  ; x5 = # chars in "aborted."
   jsr   message   ; append "aborted."

   move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6  ; restore registers
   rts        ; return

;*****************************************************************************;
;   errmess
;      x1 = menux 0-6 (l) , x2 = message index (l)
;*****************************************************************************;

 XDEF errmess

errmess  movem.l  d0-a6,-(a7)  ; save registers
   move.l   x1,-(a7)   ; save x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   jsr   creturn    ; carriage return
   move.l   x2,d7      ; d7.l = message index
   lea   messsl,a0
   move.b   0(a0,d7.l),x5    ; x5 = # chars in message
   mulu  #40,d7
   lea   messss,a0
   adda.l   d7,a0
   move.l   a0,x1      ; x1 --> message
   move.b   #1,x2
   move.b   cmessge,x4    ; color = cmessge
   move.b   cursory,x3    ; y-coord = cursory
   jsr   message    ; write message

   move.l   (a7)+,x5   ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6  ; restore registers
   rts        ; return

;*****************************************************************************;
;   getyn
;      x1 = message index 1 (l) (-1 for none) , x2 = message index 2 (l) ,
;      y1 = 1/0 yes/no (b)
;*****************************************************************************;

 XDEF getyn

getyn    movem.l  d0-a6,-(a7)  ; save registers
   move.l   x1,-(a7)   ; save x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   lea   messsl,a0
   move.b   cursory,x3    ; y-coord = cursory
   move.l   x2,d7      ; d7.l = message 2 index
   move.l   x1,d0      ; d0.l = message 1 index
   bge   .1
   clr.b    d1      ; if message 1 index < 0
   bra   .2      ; then skip first message

.1    move.b   0(a0,d0.l),d1    ; d1 = message 1 length
   move.b   d1,x5      ; x5 = message 1 length
   mulu  #40,d0
   lea   messss,a1
   adda.l   d0,a1
   move.l   a1,x1      ; x1 --> message 1
   move.b   #1,x2      ; x-coord = 1
   move.b   cmessge,x4    ; color = cmessge
   jsr   message    ; write message 1

   addq.b   #1,d1
.2    move.b   0(a0,d7.l),d2    ; d2 = message 2 length
   move.b   d2,x5      ; x5 = message 2 length
   lea   messss,a1
   mulu  #40,d7
   adda.l   d7,a1
   move.l   a1,x1      ; x1 --> message 2
   move.b   d1,x2      ; append
   addq.b   #1,x2
   move.b   cprompt,x4    ; color = cprompt
   jsr   message    ; append message 2

getyn1   jsr   getkey     ; get a key
   move.b   y1,d3      ; d3 = key
   cmp.b    asciy,d3
   beq   getyn2
   cmp.b    ascin,d3
   beq   getyn2
   jsr   bell    ; key not 'y' or 'n':
   bra   getyn1     ; ring bell, get another key

getyn2   jsr   unpromp   ; key 'y' or 'n':
   move.b   d3,x1     ;  echo key
   move.b   d1,x2     ;  to right of message 2
   add.b    d2,x2
   addq.b   #2,x2
   move.b   cecho,x4  ;  color = cecho
   jsr   outchar

   clr.b    y1
   cmp.b    ascin,d3
   beq   getyn3    ; 'n':  y1.b = 0
   move.b   #1,y1     ; 'y':  y1.b = 1

getyn3   move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6 ; restore registers
   rts       ; return
;*****************************************************************************;
;   getabc
;      x1 = message index (l)
;      y1 = 0,1,2 (b) for A,B,C
;*****************************************************************************;

 XDEF getabc

getabc   movem.l  d0-a6,-(a7)  ; save registers
   move.l   x1,-(a7)   ; save x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   lea   messsl,a0
   move.b   cursory,x3    ; y-coord = cursory
   move.l   x1,d7      ; d7.l = message index
   move.b   0(a0,d7.l),d1    ; d1 = message length
   move.b   d1,x5      ; x5 = message length
   mulu  #40,d7
   lea   messss,a1
   adda.l   d7,a1
   move.l   a1,x1      ; x1 --> message
   move.b   #1,x2      ; x-coord = 1
   move.b   cprompt,x4    ; color = cprompt
   jsr   message    ; write message 1


getabc1  jsr   getkey     ; get a key
   move.b   y1,d3      ; d3 = key
   cmp.b    ascia,d3
   beq   getabc2
   cmp.b    ascib,d3
   beq   getabc2
   cmp.b    ascic,d3
   beq   getabc2
   jsr   bell    ; bad key:
   bra   getabc1    ; ring bell, get another key

getabc2  jsr   unpromp   ; key A,B, or C:
   move.b   d3,x1     ;  echo key
   move.b   d1,x2     ;  to right of message
   addq.b   #2,x2
   move.b   cecho,x4  ;  color = cecho
   jsr   outchar

   clr.b    y1
   cmp.b    ascia,d3
   beq   getabc3   ; 'A':  y1.b = 0
   move.b   #1,y1
   cmp.b    ascib,d3
   beq   getabc3   ; 'B': y1.b = 1
   move.b   #2,y1     ; 'C': y1.b = 2
getabc3  move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   tagtry
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF tagtry

tagtry   movem.l  d0-a6,-(a7)  ; save registers
   move.l   x1,-(a7)   ; save x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.b   ascisp,d0     ; loop through specified line
   move.b   cursory,x2    ; backwards, looking for a
   move.b   xmax,d1    ; non-space character.
   addq.b   #1,d1      ; non-space character indicates
tagtry2  subq.b   #1,d1      ; end of text on this line.
   cmp.b    #1,d1      ; space = ascii ($20) or null (0)
   beq   tagtry3
   move.b   d1,x1
   jsr   getchar
   cmp.b    y1,d0
   beq   tagtry2
   tst.b    y1
   beq   tagtry2

   addq.b   #2,d1
tagtry3  move.b   d1,x2
   lea   messss,a0
   move.l   a0,x1
   addi.l   #200,x1    ; x1 --> "try again."
   move.b   cursory,x3    ; y-coord = cursory
   move.b   cmessge,x4    ; color = cmessge
   lea   messsl,a0
   move.b   5(a0),x5    ; x5 = length of "try again."
   jsr   message   ; append "try again" to this line.

   move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6  ; restore registers
   rts        ; return

;*****************************************************************************;
;   getslot
;      x1 = promptx (l) , y1 = slotx (b) , y2 = 1/0 abort/no abort (b)
;*****************************************************************************;

 XDEF getslot

getslot  movem.l  d0-a6,-(a7)  ; save registers
   move.l   x1,-(a7)   ; save x1-x5
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)

   move.l   x1,d0     ; d0.l = prompt index
   lea   promptl,a0
   move.b   0(a0,d0.l),d1   ; d1.b = length of this prompt
   move.b   d1,x5     ;   x5 = prompt length
   mulu  #40,d0
   lea   prompt,a0
   adda.l   d0,a0
   move.l   a0,x1      ;  x1 --> prompt
   move.b   #1,x2      ;  x-coord = 1
   move.b   cursory,x3    ;  y-coord = cursory
   move.b   cprompt,x4    ;  color = cprompt
   jsr   message    ;  write prompt

getslot2 jsr   getkey    ; get a key
   move.b   y1,d2     ; d2 = key

   cmp.b    ascicr,d2    ; process carriage return key
   bne   getslot3
   jsr   unpromp   ; change prompt to color cmessge
   clr.b    y1     ; pass back slot = 0
   move.b   #1,y2     ; and abort flag set
getslot0 move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,d0-a6 ; restore registers
   rts       ; return

getslot3 clr.b    d3
   lea   bankkey,a0   ; loop through all bank keys,
getslot4 addq.b   #1,d3     ; looking for the given key
   cmpi.b   #32,d3
   ble   getslot5
   jsr   bell   ; if key not found, ring bell
   bra   getslot2  ; and get another key
getslot5 cmp.b    (a0)+,d2
   bne   getslot4
   move.b   d2,x1     ; key found:
   move.b   d1,x2     ;   echo key to right of prompt
   addq.b   #2,x2
   move.b   cursory,x3
   move.b   cecho,x4
   jsr   outchar

   jsr   unpromp   ; change prompt to color cmessge
   move.b   d3,y1     ; pass back slotx = 1-32 (b)
   clr.b    y2     ; abort flag not set
   bra   getslot0  ; restore x5-x1,registers,return
