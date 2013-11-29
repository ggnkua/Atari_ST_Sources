;*****************************************************************************;
;   module 3 source file Copyright 1986 Tom Bajoras
;   low level screen, keyboard, and printer i/o:
;   hardcopy , hardtext , blnkscr , blnkln , outchar , message , getchar
;   unpromp , creturn , getkey , bell , scroll , line, inkey, setcolor
;   prt_on, prt_off, dotline, dot2line
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION three,code

;*****************************************************************************;
;   hardcopy
;      no entry conditions , no exit conditions
;*****************************************************************************;

 XDEF hardcopy

hardcopy movem.l  D0-A6,-(a7)  ; save all registers
   bsr   prt_on     ; enable screen dump

   clr.w    -(a7)     ; check printer status
   move.w   #8,-(a7)  ; if not ready, skip dump
   trap  #13
   move.l   d0,d1
   addq.l  #4,a7
   tst.l    d1
   beq   .return

   cmp.l    #$9BCD2B6D,$5A60 ; ram or rom TOS?
   beq   .ram

   move.l   #disable,-(a7)  ; disable vbl/set dump flag
   move.w   #38,-(a7)
   trap  #14
   addq.l   #6,a7

   move.w   #2,-(a7) ; get screen's physical base
   trap  #14
   move.l   d0,d1
   addq.l   #2,a7
   lea   prtargs,a0
   move.l   d1,(a0)  ; put it into argument area

   move.w   #-1,-(a7)    ; get printer configuration word
   move.w   #33,-(a7)
   trap  #14
   addq.l   #4,a7

   lea   prtargs,a0   ; --> argument area for prtblk
   clr.w    4(a0)     ; always 0
   move.w   #640,6(a0)   ; # pixels per screen width
   move.w   #200,d1
   mulu  bwflag,d1
   move.w   d1,8(a0)  ; # pixels per screen height
   clr.w    10(a0)    ; always 0
   clr.w    12(a0)    ; always 0
   move.w   bwflag,14(a0)   ; screen resolution

   move.w   d0,d1
   lsr.w    #1,d1
   andi.w   #1,d1
   move.w   d1,16(a0)    ; bit 1 of printer config word

   move.l   #dummycol,18(a0) ; colors

   move.w   d0,d1
   andi.l   #7,d1
   lsl.l    #1,d1
   lea   prttabl,a1
   move.w   0(a1,d1.l),22(a0)    ; printer type

   move.w   d0,d1
   lsr.w    #4,d1
   andi.w   #1,d1
   move.w   d1,24(a0)   ; bit 4 of printer config word
   clr.w    26(a0)   ; always 0

   move.l   #prtargs,-(a7)  ; dump screen
   move.w   #36,-(a7)
   trap  #14
   addq.l   #6,a7

   move.l   #enable,-(a7)   ; reset dump flag / enable vbl
   move.w   #38,-(a7)
   trap  #14
   addq.l  #6,a7

   bra   .return

.ram  move.l   #.h,-(a7)
   move.w   #38,-(a7)
   trap  #14
   addq.l   #6,a7
   bra   .return

.h    move.l   #dummycol,$5A92
   jsr   $5544     ; wait for start of a vblank
   clr.w    $4EE   ; set screen-dump flag
   jsr   $5544     ; wait for start of next vblank
   move.l   #$FF8240,$5A92
   rts

.return  bsr   prt_off   ; disable screen dump
   movem.l  (a7)+,D0-A6 ; restore all registers
   rts

disable  clr.w    $452  ; block all vertical blanks
   move.w   #1,$4EE  ; set dump screen flag
   rts
enable   move.w   #-1,$4EE ; reset dump screen flag
   move.w   #1,$452  ; un-block all vertical blanks
   rts

;*****************************************************************************;
;   hardtext
;      x1.b = # of lines to print, no exit conditions
;*****************************************************************************;

 XDEF hardtext

hardtext movem.l  D0-A6,-(a7) ; save registers

;  check for printer status.  if not ready, skip dump.
   clr.w    -(a7)
   move.w   #8,-(a7)
   trap  #13
   move.l   d0,d1
   addq.l   #4,a7
   tst.l    d1
   beq   .return

   lea   scrarray,a6  ; a6 --> text to be printed
   clr.w    d5     ; prepare d5
   move.b   x1,d7     ; row counter
.loop1   move.w   #$0D,-(a7)   ; cr
   clr.w    -(a7)
   move.w   #3,-(a7)
   trap  #13
   addq.l  #6,a7
   move.w   #$0A,-(a7)   ; lf
   clr.w    -(a7)
   move.w   #3,-(a7)
   trap  #13
   addq.l  #6,a7
   moveq    #80,d6    ; column counter
.loop2   move.b   (a6)+,d5
   bne   .not0
   move.b   ascisp,d5    ; convert null to space
.not0    move.w   d5,-(a7)   ; print a character
   clr.w    -(a7)
   move.w   #3,-(a7)
   trap  #13
   addq.l  #6,a7
   subq.l   #1,d6
   bne   .loop2    ; end of column loop
   subq.b   #1,d7
   bne   .loop1    ; end of row loop
   move.w   #$0D,-(a7)   ; extra cr for bidirectional
   clr.w    -(a7)     ; printers.  Doesn't hurt
   move.w   #3,-(a7)  ; for unidirectional.
   trap  #13
   addq.l  #6,a7

.return  movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   blnkscr
;      no entry conditions , no exit conditions
;*****************************************************************************;

 XDEF blnkscr

blnkscr  movem.l  D0-A6,-(a7)  ; save registers

   lea   editmess,a0
   tst.b    1840(a0)
   beq   .skip
   sub.b    #1,1840(a0)
   bne   .skip
   move.l   #0,outchar    ; get ready to crash!
.skip    trap  #9      ; blank screen

   moveq    #0,d1
   lea   scrarray,a0
   lea   colarray,a1
blnkscr2 move.b   ascisp,(a0)+
   move.b   cbakgnd,(a1)+
   addq.l   #1,d1
   cmpi.l   #2000,d1   ;  fill screen array with space
   ble   blnkscr2   ;  characters of background color

   movem.l  (a7)+,D0-A6  ;  restore registers
   rts        ;  return

;*****************************************************************************;
;   blnkln
;      x1 = line 1-ymax (b)
;*****************************************************************************;

 XDEF blnkln

blnkln   movem.l  D0-A6,-(a7)  ;  save registers and x1-x4

   clr.l    d0
   move.b   x1,d0     ; d0 = y-coord (text)
   subq.l   #1,d0
   mulu  #80,d0    ; d0.l = 0,80,160,...
   lea   scrarray,a0  ; a0 --> screen character array
   add.l    d0,a0     ; a0 --> this row of characters
   lea   colarray,a1  ; a1 --> screen color array
   add.l    d0,a1     ; a1 --> this row of colors
   move.b   xmax,d1
.loop    move.b   ascisp,(a0)+ ; blank out row of characters
   move.b   cbakgnd,(a1)+   ; blank out row of colors
   subq.b   #1,d1
   bne   .loop

   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; and return


;*****************************************************************************;
;   outchar
;      x1 = character (b) , x2 = x-coord 1-xmax (b) ,
;      x3 = y-coord 1-ymax (b) , x4 = color (b)
;     invtext.b = 1 invert color 2 , forceinv.b = 1 invert all text
;     ghostch.b = 1 put ascisp/cbakgnd into screen arrays instead of char
;*****************************************************************************;

 XDEF outchar

outchar  movem.l  D0-A6,-(a7) ; save registers
   clr.l    d0
   move.b   x3,d0     ; d0 = y-coord (text)
   subq.l   #1,d0
   mulu  #80,d0
   clr.l    d6
   move.b   x2,d6
   add.l    d6,d0
   subq.l   #1,d0     ; d0 = index into screen arrays
   tst.b    ghostch   ; ghost character?
   bne   .ghost
   lea   scrarray,a0  ; a0 --> screen character array
   move.b   x1,0(a0,d0.w)   ; put character into character array
   lea   colarray,a0  ; a0 --> screen color array
   move.b   x4,0(a0,d0.w)   ; put color into color array
   bra   .outchar
.ghost   lea   scrarray,a0
   move.b   ascisp,0(a0,d0.w)
   lea   colarray,a0
   move.b   cbakgnd,0(a0,d0.w)

.outchar move.l   vdiaddr,a0   ; a0 --> vdi argument passing area

   tst.b    forceinv  ; if (forceinv=1) or
   bne   .inv
   tst.b    invtext   ; if (color=2) and (invtext=1)
   beq   .notinv   ; then inverse text
   cmpi.b   #2,x4
   bne   .notinv
.inv  move.w   #16,$24(a0)
   bra   outchar2  ; else
.notinv  clr.w    $24(a0)   ; vdi replace mode

outchar2 move.b   x4,d0
   beq   outchar3
   cmpi.w   #2,bwflag
   bne   outchar3
   move.b   #1,d0     ; if b/w and color not background then
          ; fake color=1
outchar3 andi.l   #$FF,d0
   move.w   d0,$6A(a0)   ; color
   move.l   fontaddr,$54(a0)   ; --> font data
   move.w   formleng,$58(a0)   ; # bytes per line in font data
   clr.l    d0
   move.b   x1,d0
   sub.b    lowascii,d0
   lsl.l    #1,d0     ; index into character offset table
   move.l   ofstaddr,a1  ; a1 --> character offset table
   move.w   0(a1,d0.w),d1   ; d1 = offset into font data
   move.w   d1,$48(a0)
   clr.w    $4A(a0)   ; vertical offset into font data = 0
   addq.w   #2,d0
   move.w   0(a1,d0.w),d2   ; d2= next char's offset into font data
   sub.w    d1,d2     ; d2= this char's width (pixels)
   move.w   d2,$50(a0)
   clr.l    d0
   move.b   x2,d0
   subq.l   #1,d0
   lsl.l    #3,d0     ; d0 = x-coord (graphics)
   move.w   d0,$4C(a0)
   clr.l    d0
   move.b   x3,d0
   subq.l   #1,d0
   lsl.l    #3,d0     ; d0 = y-coord (graphics)
   mulu  bwflag,d0
   move.w   d0,$4E(a0)
   move.w   formhigh,$52(a0)   ; # scan lines per character
   clr.w    $5A(a0)   ; no special effects
   clr.w    $66(a0)   ; no scaling
   clr.w    $68(a0)   ; no rotation
   clr.w    $46(a0)   ; mono_status flag
   move.w   #$8000,$40(a0)  ; accumulator for textblt x dda

   dc.w    $A008     ; text block transfer

   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   message
;      x1 --> buffer to be written (l) , (x2,x3) = (x,y) screen coords where
;      writing is to start (1-xmax (b) , 1-ymax (b), x4 = color (b) ,
;      x5 = # characters to be written (b)
;*****************************************************************************;

 XDEF message

message  movem.l  D0-A6,-(a7)   ;  save registers and x1-x5
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x5,-(a7)
   movea.l  x1,a0    ;  a0 --> start of buffer to be written
   move.b   xmax,d2  ;  d2 = xmax

messag2  subq.b   #1,x5    ;  for (x5 = 1 to # chars to be written)
   blt   message3
   move.b   (a0)+,x1 ;  x1 = next character to be written
   bsr   outchar  ;  write the character
   addq.b   #1,x2    ;  x2 = x-coord for next character
   cmp.b    x2,d2    ;  if x2 is beyond the screen's right
   bge   messag2  ;  margin then return

message3 move.l   (a7)+,x5 ;  restore x1-x5
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   getchar
;      (x1,x2) = (x,y) screen coords of the character to be read
;      (1-xmax (b) , 1-ymax (b)) , y1 = character read (b) , y2 = color
;      of the character read (b)
;*****************************************************************************;

 XDEF getchar

getchar  movem.l  D0-A6,-(a7) ; save registers
   clr.l    d0
   move.b   x2,d0     ; d0 = y-coord
   subq.b   #1,d0
   mulu  #80,d0
   clr.l    d6
   move.b   x1,d6     ; d6 = x-coord
   add.l    d6,d0
   subq.l   #1,d0     ; d0 = index into screen arrays

   lea   scrarray,a0  ; a0 --> screen character array
   move.b   0(a0,d0.l),y1   ; y1 = character at (x,y)
   lea   colarray,a0  ; a0 --> screen color array
   move.b   0(a0,d0.w),y2   ; y2 = color at (x,y)

   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   unpromp
;      no entry conditions , no exit conditions
;*****************************************************************************;

 XDEF unpromp

unpromp  movem.l  D0-A6,-(a7)   ; save registers and x1-x4
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)

   move.b   cmessge,x4  ; x4 = replacement color = cmessge
   move.b   cursory,x3  ; x3 = line to be "unprompted"
   move.b   cprompt,d4  ; d4 = color to be replaced = cprompt

   clr.b    d0    ; for d0 = 1 to xmax do
unpromp2 addq.b   #1,d0
   cmp.b    xmax,d0
   bgt   unpromp3
   move.b   d0,x1
   move.b   cursory,x2
   bsr   getchar  ; (char,color) = getchar(d0,cursory)
   cmp.b    y2,d4    ; if color at (d0,cursory) is not cprompt
         ; then go to next character in the line
   bne   unpromp2
   move.b   y1,x1
   move.b   d0,x2    ; if color at (d0,cursory) is cprompt then
   bsr   outchar  ; replace it: same char, but color=cmessge
   bra   unpromp2
         ; go to next character in the line
unpromp3 move.l   (a7)+,x4 ; restore x1-x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6  ; restore registers
   rts        ; return

;*****************************************************************************;
;   creturn
;      x1 = menux 0-6 (l) not needed in creturn but passed to scroll routine
;*****************************************************************************;

 XDEF creturn

creturn  movem.l  D0-A6,-(a7)   ; save registers
   move.b   cursory,d1
   cmp.b    ymax,d1
   beq   cretrn2    ; if cursory = last line then call scroll
   addq.b   #1,cursory    ; else move cursor to next line
   move.b   cursory,x1
   bsr   blnkln
   movem.l  (a7)+,D0-A6 ; and restore registers
   rts         ; and return

cretrn2  bsr   scroll
   movem.l  (a7)+,D0-A6   ; restore registers and return
   rts

;*****************************************************************************;
;   getkey and inkey (getkey resets kb buffer first; inkey doesn't)
;      y1 = key code (b)
;*****************************************************************************;

 XDEF getkey
 XDEF inkey

inkey    movem.l  D0-A6,-(a7) ; save registers
   bra   getkey1

getkey   movem.l  D0-A6,-(a7)   ; save registers
keyloop  move.l   kbaddr,a0
   clr.w    6(a0)    ; reset keyboard buffer so that type-
   clr.w    8(a0)    ; ahead is impossible

getkey1  move.w   #7,-(a7)
   trap  #1
   move.l   d0,d7    ; d7.l = raw keystroke
   addq.l  #2,a7

   move.w   #-1,-(a7)   ; get kb shift/ctrl/alt key status
   move.w   #11,-(a7)
   trap  #13
   addq.l   #4,a7
   btst   #2,d0
   bne   .bad  ; no control keys!
   btst   #3,d0
   bne   .bad  ; no alt keys!

   tst.w    d7    ; special key?
   beq   .special

   cmp.b    #$61,d7
   blt   .1
   cmp.b    #$7A,d7
   bgt   .1
   tst.b    allowlc
   bne   .return
   sub.b    #$20,d7  ; convert lower case letter to upper case
   bra   .return

.1    cmp.b    #$20,d7
   bge   .return  ; printable ascii

   cmp.b    asciesc,d7  ; check for various non-printable ascii
   beq   .return
   cmp.b    ascicr,d7
   beq   .return
   cmp.b    ascibs,d7
   beq   .return
   cmp.b    ascitab,d7
   beq   .return
   bra   .bad  ; illegal non-printable ascii

.special lsr.l    #8,d7
   lsr.l    #8,d7    ; check for ascii extensions
   lea   ascif1,a0
.loop    move.b   1(a0),d1
   beq   .bad  ; 0 means end of table
   cmp.b    d7,d1
   bne   .next
   move.b   (a0),d7  ; found it
   bra   .return
.next    addq.l   #2,a0
   bra   .loop

.bad  bsr   bell
   bra   keyloop

.return  move.b   d7,y1
   cmp.b    ascif9,d7
   beq   .tone     ; F9 turns tones on/off
   tst.b    allowms   ; if allowms=0 then reject
   bne   .returnx  ; mouse buttons
   cmp.b    ascimlef,d7
   beq   keyloop
   cmp.b    ascimrit,d7
   beq   keyloop
.returnx movem.l  (a7)+,D0-A6
   rts

 XREF sendtone

.tone    jsr   sendtone
   bra   keyloop

;*****************************************************************************;
;   bell
;      no entry conditions , no exit conditions
;*****************************************************************************;

 XDEF bell

bell  movem.l  D0-A6,-(a7)
   move.w   #$07,-(a7)  ; ctrl-G is bell
   move.w   #2,-(a7)
   trap  #1    ; GEMDOS conout routine
   addq.l  #4,a7
   movem.l  (a7)+,D0-A6
   rts      ; return

;*****************************************************************************;
;   scroll
;      x1 = menux 0-6 (l)
;*****************************************************************************;

 XDEF scroll

scroll   movem.l  D0-A6,-(a7)   ;  save registers and x1
   move.l   x1,-(a7)

   move.l   x1,d1    ;  d1 = menux 0-6 (l)
   lea   ncline,a0
   clr.l    d0
   move.b   ymax,d0
   sub.b    0(a0,d1.l),d0
   addq.l   #1,d0
   mulu  #1280,d0
   trap  #8    ; shift screen text

   move.b   ymax,x1
   bsr   blnkln

   clr.l    d0
   move.b   ymax,d0
   sub.b    0(a0,d1.l),d0
   addq.l   #1,d0
   mulu  #80,d0
   lea   scrarray,a0
   lea   colarray,a1
   add.l    d0,a0
   add.l    d0,a1
   move.l   a0,a2
   move.l   a1,a3
   sub.l    #80,a2
   sub.l    #80,a3
.1    move.l   (a0)+,(a2)+
   move.l   (a1)+,(a3)+
   addq.l   #4,d0
   cmpi.l   #1996,d0
   ble   .1

   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6   ; restore registers
   rts         ; and return

;*****************************************************************************;
;   line, dotline, dot2line
;      x1.w = x1, x2.w = y1, x3.w = x2, x4.w = y2, x5.b = color
;      draw line from (x1,x2) to (x3,x4) in color x5
;*****************************************************************************;

 XDEF line
 XDEF dotline
 XDEF dot2line

line  movem.l  D0-A6,-(a7)  ; save registers
   move.l   vdiaddr,a0    ; a0 --> vdi argument area
   move.w   #$FFFF,34(a0)   ; solid line
   bra   linex

dotline  movem.l  D0-A6,-(a7)  ; save registers
   move.l   vdiaddr,a0    ; a0 --> vdi argument area
   move.w   #$3333,34(a0)    ; dotted line
   bra   linex

dot2line movem.l  D0-A6,-(a7)  ; save registers
   move.l   vdiaddr,a0    ; a0 --> vdi argument area
   move.w   #$0001,34(a0)    ; widely dotted line

linex    clr.w    32(a0)    ; unused
   clr.w    36(a0)    ; replace mode

   move.b   x5,d1     ; if color <> background (0)
   beq   linexx
   cmpi.w   #2,bwflag    ; and monochrome screen
   bne   linexx
   moveq    #1,d1     ; then fake color =1

linexx   clr.w    d0
   move.b   d1,d0
   andi.b   #1,d0
   move.w   d0,24(a0)
   move.b   d1,d0
   lsr.b    #1,d0
   andi.b   #1,d0
   move.w   d0,26(a0)
   move.b   d1,d0
   lsr.b    #2,d0
   andi.b   #1,d0
   move.w   d0,28(a0)
   move.b   d1,d0
   lsr.b    #3,d0
   andi.b   #1,d0
   move.w   d0,30(a0)

   move.w   x1,38(a0)   ; endpoints
   clr.l    d0
   move.w   x2,d0
   mulu  bwflag,d0
   move.w   d0,40(a0)
   move.w   x3,42(a0)
   clr.l    d0
   move.w   x4,d0
   mulu  bwflag,d0
   move.w   d0,44(a0)

   dc.w    $A003    ; do it

   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;  setcolor -- routine to install a set of color registers
;    x1.b = -2 saved colors, = -1 startup screen, =0 original colors/red
;      =1 original colors/violet , =2-n lower level screens
;*****************************************************************************;

 XDEF setcolor

setcolor movem.l  D0-A6,-(a7)
   lea   colorsav,a0
   cmpi.b   #-2,x1
   beq   .doit
   lea   startpal,a0
   cmpi.b   #-1,x1
   beq   .doit
   lea   colorbw,a0
   cmpi.w   #2,bwflag
   beq   .doit
   clr.l    d0
   move.b   x1,d0
   lsl.l    #5,d0     ; d0.l = 0,32,64,...
   lea   color1a,a0
   add.l    d0,a0

.doit    move.l   a0,-(a7)
   move.w   #6,-(a7)
   trap  #14
   addq.l #6,sp

   movem.l  (a7)+,D0-A6
   rts

;*****************************************************************************;
;   prt_off   --   disable screen dump
;*****************************************************************************;

 XDEF prt_off

prt_off  move.l   #.super,-(a7)     ; do this in super mode
   move.w   #38,-(a7)
   trap  #14
   addq.l   #6,a7
   rts

.super   move.l   $4D2,vblsave  ; save 2nd vbl handler
   move.l   #prtoff,$4D2  ; install new vbl handler
   rts

prtoff   move.w   #$FFFF,$4EE   ; new vbl handler: turn off
   rts        ; dump flag

;*****************************************************************************;
;   prt_on   --   enable screen dump
;*****************************************************************************;

 XDEF prt_on

prt_on   move.l   #.super,-(a7)     ; do this in super mode
   move.w   #38,-(a7)
   trap  #14               7
   addq.l   #6,a7
   rts

.super   move.l   vblsave,$4D2  ; re-install vbl handler
   rts
