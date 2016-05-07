;*****************************************************************************;
;   module 5 source file Copyright 1986 Tom Bajoras
;   file menu menu command processors:
;      initws,catsyn,lockfil,unlkfil,savefil,
;      usefile,scratch,namefil,lockall,unlkall,scrallf
;*****************************************************************************;

 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION five,code


;*****************************************************************************;
;   initws
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF initws

 XREF movemem
 XREF initpri3
 XREF filtows
 XREF readfil
 XREF writfil
 XREF wstofil
 XREF hashfil
 XREF hardtext
 XREF getkey
 XREF message
 XREF setcolor
 XREF blnkscr

initws   move.l   a0,-(a7)   ; save a0
   move.l   x1,-(a7)   ; save x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   #initname,x1
   move.l   #wksname,x2
   move.b   #10,x3
   jsr   movemem    ; set w.s. name = initname

   move.l   #initsnd,x1
   move.l   #wkspace,x2
   move.b   #160,x3
   jsr   movemem    ; set w.s. = initsound*

   move.l   (a7)+,x3   ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   move.l   (a7)+,a0
   rts        ; return

;*****************************************************************************;
;   catsyn
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF catsyn

catsyn   movem.l  D0-A6,-(a7)  ; save registers
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)
   move.l   x4,-(a7)
   move.l   x5,-(a7)   ; save x1-x5

   jsr   blnkscr    ; start with a blank screen
   move.b   #7,x1      ; change colors
   jsr   setcolor

   lea   messsl2,a3    ; synth catalog heading
   move.b   xmax,d0
   sub.b    (a3),d0
   lsr.b    #1,d0
   addq.b   #1,d0
   move.b   d0,x2      ; centered
   move.l   #messs2,x1
   move.b   #1,x3
   move.b   cmenhed,x4
   move.b   (a3),x5
   jsr   message

   lea   synbuf,a0
   addq.l   #6,a0     ; a0 --> 1st byte of data
   add.l    #118,a0   ; a0 --> first name
   lea   bankkeyn,a1
   addq.l   #1,a1     ; a1 --> numerical bankkeys
   clr.l    d1
   move.b   xmax,d1
   sub.b    #26,d1
   divu  #3,d1     ; d1 = tab

   move.b   #3,x3     ; start y-coord
   move.b   d1,d2     ; x-coord for 1st column

   clr.b    d0

.1    move.l   a1,x1
   addq.l   #5,a1
   move.b   d2,x2
   move.b   cmenkey,x4
   move.b   #2,x5
   jsr   message   ; bank key

   addq.b   #3,x2
   move.l   a0,x1
   move.b   cmenu,x4
   move.b   #10,x5
   jsr   message   ; slot name

   add.l    #128,a0
   addq.b   #1,d0
   cmpi.b   #32,d0    ; done?
   beq   .3
   cmpi.b   #16,d0    ; done with first column?
   beq   .2

   addq.b   #1,x3     ; increment y-coord
   bra   .1

.2    add.b    #13,d2
   add.b    d1,d2     ; x-coord for 2nd column
   move.b   #3,x3     ; restart y-coord
   bra   .1

.3    move.l   #messss,x1
   add.l    #960,x1
   move.b   xmax,d0
   sub.b    2(a3),d0
   lsr.b    #1,d0
   move.b   d0,x2     ; center based on 2nd line
   move.b   ymax,x3
   subq.b   #1,x3
   move.b   cprompt,x4
   lea   messsl,a0
   move.b   24(a0),x5
   jsr   message   ; [help] to hardcopy this screen
   move.l   #messs2,x1
   addq.b   #1,x3
   add.l    #80,x1
   move.b   2(a3),x5
   jsr   message   ; prompt for any other key

.4    jsr   getkey    ; get a key
   move.b   y1,d0     ; hardcopy?
   cmp.b    ascihelp,d0
   bne   .5
   move.b   #18,x1
   jsr   hardtext  : yes: dump screen
   bra   .4     ; and get another key

.5    move.l   (a7)+,x5  ; restore x5-x1
   move.l   (a7)+,x4
   move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   lockfil
;      x1.w = file handle
;*****************************************************************************;

 XDEF lockfil

lockfil  move.l   d0,-(a7) ; save d0
   move.l   a0,-(a7) ; save a0
   move.w   x1,d0
   subq.w   #1,d0    ; d0.w = filex -1
   lea   fillock,a0
   move.b   #1,0(a0,d0.w)   ; set lock flag
   addq.w   #1,nfillok   ; increment # of locked files
   move.l   (a7)+,a0  ; restore a0
   move.l   (a7)+,d0  ; restore d0
   rts       ; return

;*****************************************************************************;
;   unlkfil
;      x1.w = file handle
;*****************************************************************************;

 XDEF unlkfil

unlkfil  move.l   d0,-(a7) ; save d0
   move.l   a0,-(a7) ; save a0
   move.w   x1,d0    ; d0.w = filex -1
   subq.w   #1,d0
   lea   fillock,a0
   clr.b    0(a0,d0.w)   ; clear lock flag
   subq.w   #1,nfillok   ; decrement # of locked files
   move.l   (a7)+,a0  ; restore a0
   move.l   (a7)+,d0  ; restore d0
   rts       ; return

;*****************************************************************************;
;   savefil
;      x1.w = filex (1-maxfile), 0 if it's a new file
;       namebuf contains file name
;      y1.b = disk error codes
;*****************************************************************************;

 XDEF savefil

savefil  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   clr.l    d0    ; prepare d0
   clr.b    d7    ; default new file flag to "not new"
   lea   namebuf,a0  ; a0 --> name
   lea   fileflg,a1
   subq.l   #1,a1    ; a1 --> fileflg -1b
   move.w   x1,d0
   bne   .3

   moveq    #1,d7    ; new file
   jsr   hashfil
   move.w   y1,d0
   tst.b    0(a1,d0.w)
   beq   .3
   moveq    #1,d0    ; hashing collision
.2    tst.b    0(a1,d0.w)
   beq   .3
   addq.w   #1,d0
   cmp.w    maxfile,d0
   bne   .2
   bra   .return  ; shouldn't ever happen

.3    jsr   wstofil  ; pack w.s. into filebuf
   move.w   d0,x1
   jsr   writfil  ; write filebuf to disk
   tst.b    y1    ; do not update info tables if write fails
   bne   .return

   tst.b    d7
   beq   .4
   addq.w   #1,nfiles    ; new file
   move.b   #1,0(a1,d0.w)
.6    lea   revtabl,a3
   subq.l   #1,a3
   clr.b    0(a3,d0.w)
   move.l   a0,x1
   move.l   #filenam,x2
   sub.l    #10,x2
   mulu  #10,d0
   add.l    d0,x2
   move.b   #10,x3
   jsr   movemem
   bra   .return

.4    lea   indflg,a3    ; not a new file
   subq.l   #1,a3
   tst.b    0(a3,d0.w)   ; indexed?
   beq   .6
   clr.b    0(a3,d0.w)
   subq.w   #1,nfilind
   bra   .6

.return  move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x3-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts

;*****************************************************************************;
;   usefile
;      x1.w = file handle, y1.b = disk error codes
;*****************************************************************************;

 XDEF usefile

usefile  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   jsr   readfil   ; read file into filebuf
   tst.b    y1     ; return error code if something
   bne   .return   ; went wrong

   jsr   filtows   ; unpack filebuf into w.s.
   clr.l    d0
   move.w   x1,d0     ; d0.l = filex -1
   subq.w   #1,d0
   mulu  #10,d0
   move.l   #filenam,x1
   add.l    d0,x1     ; x1 --> name of file used
   move.l   #wksname,x2  ; x2 --> w.s. name
   move.b   #10,x3
   jsr   movemem   ; copy file name to w.s. name

.return  move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x3-x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

;*****************************************************************************;
;   scratch
;      x1.w = file handle
;*****************************************************************************;

 XDEF scratch

scratch  move.l   d0,-(a7) ; save d0 and a0
   move.l   a0,-(a7)
   clr.l    d0
   move.w   x1,d0
   subq.w   #1,d0    ; d0 = filex - 1

   lea   fileflg,a0  ; a0 --> file existence flags
   clr.b    0(a0,d0.w)  ; clear file existence flag
   lea   revtabl,a0
   clr.b    0(a0,d0.w)  ; set revision =0
   subq.w   #1,nfiles   ; decrement # of files on disk
   lea   indflg,a0   ; a0 --> index flags
   tst.b    0(a0,d0.w)   ; file indexed?
   beq   .1
   clr.b    0(a0,d0.w)   ; yes: clear index flag
   subq.w   #1,nfilind   ; and decrement # of indexed files

.1    mulu  #10,d0
   lea   filenam,a0
   adda.l   d0,a0     ; a0 --> this file's name
   moveq    #10,d0   ; for d0 = 10 to 1
.2    subq.b   #1,d0
   blt   .return
   move.b   ascisp,(a0)+ ; space fill the name
   bra   .2

.return  move.l   (a7)+,a0 ; restore a0 and d0
   move.l   (a7)+,d0
   rts      ; return

;*****************************************************************************;
;   namefil
;      x1.w = file handle, namebuf contains name for file
;*****************************************************************************;

 XDEF namefil

namefil  move.l   d0,-(a7) ; save d0
   move.l   x1,-(a7) ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   clr.l    d0
   move.w   x1,d0
   subq.w   #1,d0    ; d0 = filex -1
   mulu  #10,d0
   move.l   #namebuf,x1
   move.l   #filenam,x2
   add.l    d0,x2
   move.b   #10,x3
   jsr   movemem  ; replace the file's name

   move.l   (a7)+,x3 ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   move.l   (a7)+,d0 ; and d0
   rts      ; return

;*****************************************************************************;
;   lockall
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF lockall

lockall  movem.l  D0-A6,-(a7) ; save registers
   move.w   nfillok,d1   ; d1 = # files locked
   lea   fileflg,a0   ; a0 --> file existence flags
   lea   fillock,a1   ; a1 --> file locked flags
   move.w   maxfile,d0   ; d0 = maximum # of files on disk
   subq.w   #1,d0     ; for each file on disk
.1    tst.b    0(a0,d0.w)   ; skip it if it doesn't exist
   beq   .2
   tst.b    0(a1,d0.w)   ; skip it if it's already locked
   bne   .2

   move.b   #1,0(a1,d0.w)   ; lock it
   addq.w   #1,d1     ; increment # of locked files
   cmp.w    nfiles,d1    ; done?
   beq   .return

.2    subq.w   #1,d0
   bge   .1

.return  move.w   nfiles,nfillok  ; all files locked
   movem.l  (a7)+,D0-A6 ; restore registers
   rts

;*****************************************************************************;
;   unlkall
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF unlkall

unlkall  move.l   d0,-(a7) ; save d0,a0,a1
   move.l   a0,-(a7)
   move.l   a1,-(a7)

   lea   fileflg,a0  ; a0 --> file existence flags
   lea   fillock,a1  ; a1 --> file locked flags
   move.w   maxfile,d0  ; d0 = maximum # of files on disk
   subq.w   #1,d0    ; for each file on disk
.1    tst.b    0(a0,d0.w)   ; skip it if it doesn't exist
   beq   .2
   tst.b    0(a1,d0.w)   ; skip it if already unlocked
   beq   .2

   clr.b    0(a1,d0.w)   ; unlock it
   subq.w   #1,nfillok   ; decrement # of locked files
   beq   .return   ; done?

.2    subq.w   #1,d0
   bge   .1

.return  move.l   (a7)+,a1  ; restore a1,a0,d0
   move.l   (a7)+,a0
   move.l   (a7)+,d0
   rts       ; return

;*****************************************************************************;
;   scrallf
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF scrallf

scrallf  movem.l  D0-A6,-(a7) ; save registers
   lea   fileflg,a0   ; a0 --> file existence flags
   lea   indflg,a1    ; a1 --> file indexed flags
   lea   filenam,a2   ; a2 --> file names
   lea   revtabl,a3   ; a3 --> revision table

   clr.w    d0   ; d0.w = 0 to maxfile-1
   clr.l    d1   ; d1.l = 10*d0

.1    tst.b    0(a0,d0.w)   ; exists?
   beq   .4     ; no: skip it
   clr.b    0(a0,d0.w)   ; clear existence flag
   clr.b    0(a3,d0.w)   ; set revision to 0
   tst.b    0(a1,d0.w)   ; indexed?
   beq   .2
   clr.b    0(a1,d0.w)   ; yes: clear indexed flag
   subq.w   #1,nfilind   ; and decrement # of files indexed

.2    move.l   a2,a6
   add.l    d1,a6   ; a6 --> this file name
   moveq    #10,d7  ; d7 = 10 to 1
.3    move.b   ascisp,(a6)+ ; space-fill name
   subq.b   #1,d7
   bne   .3

   subq.w   #1,nfiles    ; decrement # of files
   beq   .return   ; all files gone?

.4    addq.w   #1,d0
   add.l    #10,d1
   cmp.w    maxfile,d0
   bne   .1     ; not done: loop until all files gone

.return  movem.l  (a7)+,D0-A6 ; restore registers
   rts

;*****************************************************************************;
;   initpri2 -- part of primary initialization daisy chain
;      set up trap handlers
;      no entry conditions, no exit conditions
;*****************************************************************************;

 XDEF initpri2

initpri2:
   move.l   #trap10,-(a7)
   move.w   #$2A,-(a7)
   move.w   #5,-(a7)
   trap  #13    ; set trap #10 for key-repeat off
   addq.l   #8,a7

   move.l   #trap11,-(a7)
   move.w   #$2B,-(a7)
   move.w   #5,-(a7)
   trap  #13    ; set trap #11 for key-repeat on
   addq.l   #8,a7

; daisy-chain on to next section of initializing code:
   jsr   initpri3

   move.l   #trap9,-(a7) ; set trap #9 to vector through illegal
   move.w   #$29,-(a7)
   move.w   #5,-(a7)
   trap  #13
   addq.l   #8,a7

   move.l   #trap8,-(a7)
   move.w   #$28,-(a7)
   move.w   #5,-(a7)
   trap  #13    ; set trap #8 to vector through trace
   addq.l   #8,a7

   move.l   #trap7,-(a7)
   move.w   #$27,-(a7)
   move.w   #5,-(a7)
   trap  #13    ; set trap #7 for startup screen
   addq.l   #8,a7

   rts

trap10   bclr  #1,$484    ; trap handlers
   rte

trap11   bset  #1,$484
   rte

trap9    movem.l  D0-A6,-(a7)
   move.l   $44E,a0    ; a0 --> base of screen
   moveq    #0,d0
   moveq    #0,d1
.blankx  move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   move.l   d1,(a0)+
   addq.l   #1,d0
   cmpi.l   #$800,d0
   bne   .blankx
   movem.l  (a7)+,D0-A6
   rte

trap8    movem.l  D0-A6,-(a7)
   move.l   $44E,a0    ; a0 --> a line of text
   add.l    d0,a0
   move.l   a0,a1
   sub.l    #1280,a1   ; a1 --> previous line of text
.tracex  move.l   (a0)+,(a1)+
   addq.l   #4,d0
   cmpi.l   #31996,d0
   ble   .tracex
   movem.l  (a7)+,D0-A6
   rte

trap7    move.l   $44E,a0
   lea   startimg,a1
   moveq    #0,d0
trap7x   move.l   (a1)+,(a0)+
   move.l   (a1)+,(a0)+
   move.l   (a1)+,(a0)+
   move.l   (a1)+,(a0)+
   addq.l   #1,d0
   cmpi.l   #$800,d0
   bne   trap7x
   rte
