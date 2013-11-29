;*****************************************************************************;
;   module 10 source file    Copyright 1986 Tom Bajoras
;   character manipulation routines:
;   parsnum,value,parsnam,encode,hashfil,length,findfil,cmpsufx,cmpinfx
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION ten,code

;*****************************************************************************;
;   parsnum
;      x1 --> 10-character buffer to be parsed, y1 = 1/0 bad/good (b)
;*****************************************************************************;

 XDEF parsnum


parsnum  movem.l  D0-A6,-(a7)  ; save registers

   movea.l  x1,a0      ; a0 --> 10-char buffer
   subq.l   #1,a0
   move.b   ascisp,d1
   move.b   asci0,d2
   move.b   asci9,d3

   clr.b    y1      ; loop through all chars in
   clr.l    d0      ; buffer:  if any char is not
parsnum6 addq.l   #1,d0      ; a digit, then parse error.
   cmpi.l   #10,d0     ; Else no parse error.
   bgt   parsnum0   ; end of buffer ends parsing
   cmp.b    0(a0,d0.l),d1
   beq   parsnum0   ; space ends parsing
parsnum7 cmp.b    0(a0,d0.l),d2
   bgt   parsnum8
   cmp.b    0(a0,d0.l),d3
   blt   parsnum8
   bra   parsnum6
parsnum8 move.b   #1,y1
parsnum0 movem.l  (a7)+,D0-A6  ; restore registers and return
   rts

;*****************************************************************************;
;   value
;      x1 --> 10-character buffer , y1 = value (l)
;*****************************************************************************;

 XDEF value

value    movem.l  D0-A6,-(a7)  ; save registers
   movea.l  x1,a0
   adda.l   #10,a0     ; a0 --> end of buffer
   clr.l    y1      ; y1 collects value
   move.l   #1,d1      ; d1 = 1,10,100,...
   moveq.l  #10,d2     ; d2 = 9 to 0
value2   subq.b   #1,d2
   blt   value3     ; start of buffer: end
   move.b   -(a0),d3
   cmp.b    ascisp,d3
   beq   value2     ; space: end
   sub.b    asci0,d3
   andi.l   #$FF,d3    ; d3 = value of character
   mulu  d1,d3      ; multiply value by power of 10
   add.l    d3,y1      ; add to running sum
   mulu  #10,d1     ; d1 = next power of 10
   bra   value2
value3   movem.l  (a7)+,D0-A6  ; restore registers and return
   rts

;*****************************************************************************;
;   parsnam
;      x1 --> 10-character buffer to be parsed , y1 =0/1 good/bad
;      note: exits through parsnum0
;*****************************************************************************;

 XDEF parsnam

parsnam  movem.l  D0-A6,-(a7)  ; save registers
   movea.l  x1,a0      ; a0 --> buffer
   clr.b    y1     ; default good
   moveq    #10,d1     ; loop through all chars in buffer
parsnam2 subq.b   #1,d1
   blt   parsnum0   ; made it through
   move.b   (a0)+,d2
   cmp.b    ascisp,d2
   beq   parsnum0   ; space: end
   cmp.b    ascibsl,d2    ; backslash not allowed because
   beq   parsnam4   ; synth cannot properly display it
   cmp.b    #$7D,d2    ; reject chars > $7D
   bgt   parsnam4
   cmp.b    #$20,d2
   bgt   parsnam2   ; reject chars < $20

parsnam4 move.b   #1,y1      ; error return
   bra   parsnum0

;*****************************************************************************;
;   encode
;      x1 = value (w) , y1 --> 10-character buffer, left-justified
;*****************************************************************************;

 XDEF encode

encode   movem.l  D0-A6,-(a7)  ; save registers
   move.w   x1,d1      ; d1.w = value to encode

   lea   namebuf,a0    ; a0 --> buffer to encode into
   moveq.l  #10,d0     ; zero-fill buffer
.2    subq.b   #1,d0
   blt   .3
   clr.b    (a0)+
   bra   .2

.3    lea   namebuf,a0    ; a0 --> buffer to encode into
   cmpi.w   #1,d1
   bge   .5      ; 0 encoded is '0'
   move.b   asci0,(a0)
.4    move.l   a0,y1
   movem.l  (a7)+,D0-A6  ; restore registers,return
   rts

.5    clr.l    d2
   move.w   d1,d2      ; d2.l = value to encode
   divu  #10,d2
   move.w   d2,d1      ; d1.w = # remaining to be encoded
   lsr.l    #8,d2
   lsr.l    #8,d2      ; d2 = one digit (from R to L)
   add.b    asci0,d2   ; d2 = digit encoded
   moveq    #9,d3      ; shift buffer 1 char to right
.6    subq.l   #1,d3
   blt   .7
   move.l   d3,d4
   addq.l   #1,d4
   move.b   0(a0,d3.l),0(a0,d4.l)
   bra   .6
.7    move.b   d2,(a0)    ; put encoded digit into buffer
   cmpi.w   #1,d1
   blt   .4       ; done?
   bra   .5       ; no : encode remainder

;*****************************************************************************;
;   hashfil
;      namebuf contains name to be hashed
;*****************************************************************************;

 XDEF hashfil

hashfil  movem.l  D0-A6,-(a7)   ; save registers
   lea   namebuf,a0     ; a0 --> file name to hash
   move.w   lprime,d0
   moveq    #16,d7    ; hashing scheme:  file handle =
   clr.l    d1     ; remainder when file name is
   moveq    #10,d2    ; divided by largest prime #
hashfil2 subq.b   #1,d2     ; less than maxfile
   blt   hashfil3
   lsl.l    #4,d1
   add.b    (a0)+,d1
   divu  d0,d1
   lsr.l    d7,d1
   bra   hashfil2

hashfil3 move.w   d1,y1
   addq.w   #1,y1     ; y1 must be > 0
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   length
;   x1 --> 10-character buffer (null or sp-filled on right) , y1 = length (b)
;*****************************************************************************;

 XDEF length

length   movem.l  D0-A6,-(a7)  ; save registers
   movea.l  x1,a0
   adda.l   #10,a0     ; a0 --> end of buffer +1b
   move.b   ascisp,d1

   moveq    #11,d0
.2    subq.b   #1,d0      ; d0=10 to 1
   beq   .3
   subq.l   #1,a0

   cmp.b    (a0),d1
   beq   .2
   tst.b    (a0)
   beq   .2

.3    move.b   d0,y1
   movem.l  (a7)+,D0-A6   ; restore registers, return
   rts

;*****************************************************************************;
;   findfil
;      y1.w = file handle (1-maxfile) if found, 0 if not found
;*****************************************************************************;

 XDEF findfil

findfil  movem.l  D0-A6,-(a7) ; save registers

   clr.l    d0
   lea   fileflg,a0
   subq.l   #1,a0     ; a0 --> file flags - 1b
   lea   filenam,a1
   suba.l   #10,a1    ; a1 --> file names - 10b
   lea   namebuf,a3   ; a3 --> name to be found

   jsr   hashfil
   move.w   y1,d0     ; d0.w = hashed file #
   tst.b    0(a0,d0.w)   ; does it exist?
   beq   findfil4
   move.l   d0,d1     ; yes
   mulu  #10,d1
   movea.l  a1,a2
   adda.l   d1,a2     ; a2 --> file name (hashed)
   movea.l  a3,a4     ; a4 --> input name
   moveq    #10,d2
findfil2 subq.l   #1,d2     ; for d2 = 9 to 0
   blt   findfil3
   cmpm.b   (a2)+,(a4)+  ; are these 2 names the same?
   bne   findfil4
   bra   findfil2
findfil3 move.w   d0,y1     ; found it
   bra   xreturn

findfil4 clr.l    d0     ; no : sequential search
findfil5 addq.l   #1,d0     ; for d0 = 1 to maxfile do
   cmp.w    maxfile,d0
   bgt   findfil7
   tst.b    0(a0,d0.l)   ; skip it if it doesn't exist
   beq   findfil5
   move.l   d0,d1
   mulu  #10,d1
   movea.l  a1,a2
   adda.l   d1,a2     ; a2 --> file name (maybe)
   movea.l  a3,a4     ; a4 --> input name
   moveq    #10,d2    ; for d2 = 9 to 0
findfil6 subq.l   #1,d2
   blt   findfil3
   cmpm.b   (a2)+,(a4)+  ; are these 2 names the same?
   bne   findfil5
   bra   findfil6

findfil7 clr.w    y1     ; not found
xreturn  movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   cmpsufx
;      x1 --> suffix (10 characters, null or space filled on right)
;      x2 --> test word (10 characters, null or space filled on right)
;      x3.b = # characters in suffix
;      y1.b = 1 match found, = 0 failed
;*****************************************************************************;

 XDEF cmpsufx

cmpsufx  movem.l  D0-A6,-(a7) ; save registers

   clr.b    d4     ; flag: d4.b=0 means suffix
   bra   compfix

;*****************************************************************************;
;   cmpinfx
;      x1 --> string (10 chars, null or sp-filled on right) to be found
;      x2 --> test word (10 chars, null or sp-filled on right)
;      x3.b = # chars in string to be found
;      y1.b = 1 match found, =0 failed
;*****************************************************************************;

 XDEF cmpinfx

cmpinfx  movem.l  D0-A6,-(a7)  ; save registers

   moveq    #1,d4      ; d4.b=1 means infix

compfix  move.b   ascisp,d7    ; asci space used throughout
   move.b   #11,d6
   sub.b    x3,d6    ; d6.b = 11-length
   move.l   x1,a0
   subq.l   #1,a0    ; a0 --> string -1b
   move.l   x2,a1
   subq.l   #1,a1    ; a1 --> test word -1b

   clr.w    d0    ; d0= 1 to 10
.loop1   addq.w   #1,d0
   cmpi.w   #10,d0
   bgt   .bad  ; no match found

   tst.b    0(a1,d0.w)
   beq   .bad  ; ran out of tries
   cmp.b    0(a1,d0.w),d7
   beq   .bad  ; ran out of tries

   cmp.b    d6,d0
   bgt   .bad  ; no room left

   move.w   d0,d1
   clr.w    d2
.loop2   addq.w   #1,d2
   cmp.b    x3,d2
   bgt   .check   ; matches: good if infix, maybe if suffix
   move.b   0(a1,d1.w),d3
   cmp.b    0(a0,d2.w),d3
   bne   .loop1   ; doesn't match: try next characters
   addq.w   #1,d1
   bra   .loop2

.check   tst.b    d4    ; any position match is ok for infix
   bne   .good
   cmpi.w   #10,d1   ; match must be at end for suffix
   bgt   .good
   tst.b    0(a1,d1.w)
   beq   .good
   cmp.b    0(a1,d1.w),d7
   beq   .good

   bra   .loop1   ; suffix found in middle, but not at
         ; end, so keep searching
.good    move.b   #1,y1
   bra   .return
.bad  clr.b    y1
.return  movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return
