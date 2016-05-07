;*****************************************************************************;
;   module 12 source file    Copyright 1986 Tom Bajoras
;   disk i/o routines:
;      readbnk,writbnk,readfil,writfil,readindx,writindx,readinfo,writinfo
;      readdisk, writdisk
;*****************************************************************************;
 OPT DEBUG
 OPT HCLN

 INCLUDE D_A_L.INC
 INCLUDE D_M_Z.INC
 INCLUDE BSS.INC

 SECTION twelve,code

;*****************************************************************************;
;   readbnk
;      x1.b = bank # to read from disk (1-maxbank) into w.b.
;      other input: filebuf contains bank (4096 bytes)
;      y1.b = 0 ok , =1 can't read it
;*****************************************************************************;

 XDEF readbnk

readbnk  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)
   move.l   x2,-(a7)  ; and x1-x2

   clr.w    d7
   move.b   x1,d7
   move.w   d7,x1
   add.w    #517,x1   ; file # for readdisk
   move.l   #filebuf,x2
   jsr   readdisk  ; read bank into filebuf

   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x2-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts

;*****************************************************************************;
;   writbnk
;      x1.b = bank # to write to disk (1-maxbank)
;      y1.b = 0 ok , =2 couldn't write it
;      other output: filebuf contains bank (4096 bytes)
;*****************************************************************************;

 XDEF writbnk

writbnk  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)
   move.l   x2,-(a7)  ; and x1-x2

   clr.w    d7
   move.b   x1,d7
   move.w   d7,x1
   add.w    #517,x1   ; file # for writdisk
   move.l   #filebuf,x2
   jsr   writdisk  ; write filebuf to disk

   move.l   (a7)+,x2  ; restore x2-x1
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return

;*****************************************************************************;
;   readfil
;      x1.w = file # to read (1-maxfile)
;      y1.b = 0 ok , =1 can't read it
;*****************************************************************************;

 XDEF readfil

 XREF movemem
 XREF initpri6
 XREF blnkln4
 XREF blnkln3
 XREF pack
 XREF unpack

readfil  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   clr.l    d7
   move.w   x1,d7
   subq.w   #1,d7
   divu  #4,d7
   move.w   d7,x1
   addq.w   #2,x1     ; file # for readdisk
   move.l   #diskbuf,x2
   jsr   readdisk  ; read 512 bytes into diskbuf
   tst.b    y1     ; go no farther if read failed
   bne   .return

   moveq    #16,d0
   lsr.l    d0,d7
   mulu  #128,d7   ; offset into diskbuf
   move.l   #diskbuf,x1
   add.l    d7,x1
   move.l   #filebuf,x2
   move.b   #128,x3
   jsr   movemem   ; extract 128 bytes

.return  move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x3-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return

;*****************************************************************************;
;   writfil
;      x1.w = file # to write (1-maxfile)
;      other input: filebuf contains file (128 bytes)
;      y1.b = 0 ok , =1 can't read, =2 can't write
;*****************************************************************************;

 XDEF writfil

writfil  movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)  ; save x1-x3

   clr.l    d7
   move.w   x1,d7
   subq.w   #1,d7
   divu  #4,d7
   move.w   d7,x1
   addq.w   #2,x1     ; file # for readdisk
   move.w   x1,d6     ; save file # for writdisk
   move.l   #diskbuf,x2
   jsr   readdisk  ; read 512 bytes into diskbuf
   tst.b    y1
   bne   .return   ; go no farther if read failed

   moveq    #16,d0
   lsr.l    d0,d7
   mulu  #128,d7   ; offset into diskbuf
   move.l   #filebuf,x1
   move.l   #diskbuf,x2
   add.l    d7,x2
   move.b   #128,x3
   jsr   movemem   ; insert 128 bytes

   move.w   d6,x1
   move.l   #diskbuf,x2
   jsr   writdisk  ; write it back

.return  move.l   (a7)+,x3
   move.l   (a7)+,x2
   move.l   (a7)+,x1  ; restore x3-x1
   movem.l  (a7)+,D0-A6 ; and registers
   rts       ; return

;*****************************************************************************;
;   readindx
;      x1.w = index # to read (1-maxfile)
;      x2.l --> addr of indbuf1 or indbuf2
;      y1.b = 0 ok , =1 can't read
;*****************************************************************************;

 XDEF readindx

readindx movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   move.l   x2,a6     ; save read source pointer
   clr.l    d7
   move.w   x1,d7
   subq.l   #1,d7
   divu  #4,d7
   move.w   d7,x1
   add.w    #260,x1
   move.l   #diskbuf,x2
   jsr   readdisk  ; read it
   tst.b    y1
   bne   .return

   moveq    #16,d0
   lsr.l    d0,d7
   mulu  #128,d7   ; offset into diskbuf
   move.l   #diskbuf,x1
   add.l    d7,x1
   move.l   a6,x2
   move.b   #128,x3
   jsr   movemem   ; extract 128 bytes

.return  move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return


;*****************************************************************************;
;   writindx
;      x1.w = index # to write (1-maxfile)
;      x2.l --> addr of indbuf1 or indbuf2
;      y1.b = 0 ok, =1 can't read, =2 can't write
;*****************************************************************************;

 XDEF writindx

writindx movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)
   move.l   x2,-(a7)
   move.l   x3,-(a7)  ; save x1-x3

   move.l   x2,a6     ; save write target pointer
   clr.l    d7
   move.w   x1,d7
   subq.w   #1,d7
   divu  #4,d7
   move.w   d7,x1
   add.w    #260,x1   ; file # for readdisk
   move.w   x1,d6     ; save file # for writdisk
   move.l   #diskbuf,x2
   jsr   readdisk  ; read 512 bytes to diskbuf
   tst.b    y1     ; go no farther if read failed
   bne   .return

   moveq    #16,d0
   lsr.l    d0,d7
   mulu  #128,d7   ; offset into diskbuf
   move.l   a6,x1
   move.l   #diskbuf,x2
   add.l    d7,x2
   move.b   #128,x3   ; insert 128 bytes
   jsr   movemem

   move.w   d6,x1
   move.l   #diskbuf,x2
   jsr   writdisk  ; write it back

.return  move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts

;*****************************************************************************;
;   readinfo
;      no entry conditions
;      y1.b = 0 ok, =1 can't read, =3 disk not a valid data disk
;      called only during startup, or during swapping disks
;*****************************************************************************;

 XDEF readinfo

readinfo movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   move.w   #1,x1
   move.l   #diskbuf,x2
   jsr   readdisk  ; read info file into diskbuf
   tst.b    y1
   bne   .return

   move.l   diskbuf,d0
   cmp.l    dxosid,d0
   bne   .notdxos

   lea   diskbuf,a0   ; unpack info file
   move.w   8(a0),nfiles
   move.w   10(a0),nfillok
   move.w   12(a0),nfilind
   move.b   14(a0),nbanks
   move.l   a0,x1
   add.l    #15,x1
   move.l   #fileflg,x2
   move.w   maxfile,x3
   jsr   unpack
   move.l   a0,x1
   add.l    #144,x1
   move.l   #fillock,x2
   jsr   unpack
   move.l   a0,x1
   add.l    #273,x1
   move.l   #indflg,x2
   jsr   unpack
   move.l   a0,x1
   add.l    #402,x1
   move.l   #bankflg,x2
   move.b   maxbank,x3
   jsr   movemem
   move.l   a0,x1
   add.l    #420,x1
   move.l   #bnamflg,x2
   jsr   movemem

   move.w   #536,x1
   move.l   #filenam,x2
   jsr   readdisk  ; read file names
   tst.b    y1
   bne   .return

   move.w   #537,x1
   move.l   #bslotnm,x2
   jsr   readdisk  ; read bank slot names
   tst.b    y1
   bne   .return

   move.w   #538,x1
   move.l   #banknam,x2
   jsr   readdisk  ; read bank names
   tst.b    y1
   bne   .return

   move.w   #539,x1
   move.l   #revtabl,x2
   jsr   readdisk  ; read revision table

.return  move.l   (a7)+,x3  ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return
.notdxos move.b   #3,y1
   bra   .return

;*****************************************************************************;
;   writinfo
;      no entry conditions
;      y1.b = disk error codes
;     called only during finish and disk swapping
;*****************************************************************************;

 XDEF writinfo

writinfo movem.l  D0-A6,-(a7) ; save registers
   move.l   x1,-(a7)  ; and x1-x3
   move.l   x2,-(a7)
   move.l   x3,-(a7)

   lea   diskbuf,a0   ; pack info tables into diskbuf
   move.l   dxosid,(a0)
   move.w   nfiles,8(a0)
   move.w   nfillok,10(a0)
   move.w   nfilind,12(a0)
   move.b   nbanks,14(a0)
   move.l   #fileflg,x1
   move.l   a0,x2
   add.l    #15,x2
   move.w   maxfile,x3
   jsr   pack
   move.l   #fillock,x1
   move.l   a0,x2
   add.l    #144,x2
   jsr   pack
   move.l   #indflg,x1
   move.l   a0,x2
   add.l    #273,x2
   jsr   pack
   move.l   #bankflg,x1
   move.l   a0,x2
   add.l    #402,x2
   move.b   maxbank,x3
   jsr   movemem
   move.l   #bnamflg,x1
   move.l   a0,x2
   add.l    #420,x2
   jsr   movemem

   move.w   #1,x1
   move.l   #diskbuf,x2
   jsr   writdisk   ; write info file
   tst.b    y1
   bne   .return

   move.w   #536,x1
   move.l   #filenam,x2
   jsr   writdisk   ; write file names
   tst.b    y1
   bne   .return

   move.w   #537,x1
   move.l   #bslotnm,x2
   jsr   writdisk   ; write bank slot names
   tst.b    y1
   bne   .return

   move.w   #538,x1
   move.l   #banknam,x2
   jsr   writdisk   ; write bank names
   tst.b    y1
   bne   .return

   move.w   #539,x1
   move.l   #revtabl,x2
   jsr   writdisk   ; write revision table
.return  move.l   (a7)+,x3   ; restore x3-x1
   move.l   (a7)+,x2
   move.l   (a7)+,x1
   movem.l  (a7)+,D0-A6  ; restore registers
   rts        ; return

;*****************************************************************************;
;   readdisk
;      x1.w = file # (1-538)
;      x2.l --> area to read into
;      y1.b = 0 no error, =1 can't read from disk
;*****************************************************************************;

 XDEF readdisk

readdisk movem.l  D0-A6,-(a7)  ; save registers
   move.b   #1,d6      ; error code for rdwrdisk failure
   move.w   #8,d5      ; bios function # for read
   bra   rdwrdisk

;*****************************************************************************;
;   writdisk
;     x1.w = file # (1-538)
;     x2.l --> area to write from
;     y1.b = 0 no error, =2 can't write to disk
;*****************************************************************************;

 XDEF writdisk

writdisk movem.l  D0-A6,-(a7) ; save registers
   move.b   #2,d6     ; error code for rdwrdisk failure
   move.w   #9,d5     ; bios function # for write

rdwrdisk: cmpi.w   #18,x1
   bge   .18
   move.w   #1,d0     ; d0 = # of sectors to read/write
   move.w   x1,d1
   add.w    #56,d1    ; d1 = track
   move.w   #9,d2     ; d2 = starting sector
   bra   .doit

.18   cmpi.w   #518,x1
   bge   .518
   move.w   #1,d0
   clr.l    d7
   move.w   x1,d7
   divu  #9,d7
   move.w   d7,d1
   swap d7       ; ( moveq  #16,d2 /  lsr.l    d2,d7 )
   move.w   d7,d2
   addq.w   #1,d2
   bra   .doit

.518  cmpi.w   #536,x1
   bge   .536
   move.w   #8,d0
   move.w   #1,d2
   move.w   x1,d1
   sub.w    #460,d1
   bra   .doit

.536  cmpi.w   #536,x1
   beq   @rdwr536
   cmpi.w   #537,x1
   beq   @rdwr537  ; these are special
   cmpi.w   #539,x1
   beq   @rdwr539

   move.w   #1,d0     ; #538 (bank names)
   move.w   #78,d1
   move.w   #7,d2

.doit    move.w   d0,-(a7)  ; count
   clr.w    -(a7)     ; side A
   move.w   d1,-(a7)  ; track #
   move.w   d2,-(a7)  ; sector # (start)
   move.w   currdrv,-(a7)   ; disk drive #
   clr.l    -(a7)     ; filler
   move.l   x2,-(a7)  ; buffer to read into / write from
   move.w   d5,-(a7)  ; function #
   trap  #14     ; do it
   add.l    #20,a7
   clr.b    y1
   tst.l    d0
   beq   @return   ; ok?
error   move.b   d6,y1
@return  movem.l  (a7)+,D0-A6 ; restore registers
   rts       ; return

@rdwr536 move.l   x2,a6
   move.w   #9,-(a7)  ; count
   clr.w    -(a7)     ; side A
   move.w   #76,-(a7)    ; track #
   move.w   #1,-(a7)  ; sector # (start)
   move.w   currdrv,-(a7)   ; disk drive #
   clr.l    -(a7)     ; filler
   move.l   a6,-(a7)  ; buffer to read into / write from
   move.w   d5,-(a7)  ; function #
   trap  #14     ; do it
   add.l    #20,a7
   tst.l    d0
   bne   error

   add.l    #4608,a6
   move.w   #9,-(a7)  ; count
   clr.w    -(a7)     ; side A
   move.w   #77,-(a7)    ; track #
   move.w   #1,-(a7)  ; sector # (start)
   move.w   currdrv,-(a7)   ; disk drive #
   clr.l    -(a7)     ; filler
   move.l   a6,-(a7)  ; buffer to read into / write from
   move.w   d5,-(a7)  ; function #
   trap  #14     ; do it
   add.l    #20,a7
   tst.l    d0
   bne   error

   add.l    #4608,a6
   move.w   #3,-(a7)  ; count
   clr.w    -(a7)     ; side A
   move.w   #78,-(a7)    ; track #
   move.w   #1,-(a7)  ; sector # (start)
   move.w   currdrv,-(a7)   ; disk drive #
   clr.l    -(a7)     ; filler
   move.l   a6,-(a7)  ; buffer to read into / write from
   move.w   d5,-(a7)  ; function #
   trap  #14     ; do it
   add.l    #20,a7
   tst.l    d0
   bne   error
   clr.b    y1
   bra   @return

@rdwr537 move.l   x2,a6
   move.w   #9,-(a7)  ; count
   clr.w    -(a7)     ; side A
   move.w   #79,-(a7)    ; track #
   move.w   #1,-(a7)  ; sector # (start)
   move.w   currdrv,-(a7)   ; disk drive #
   clr.l    -(a7)     ; filler
   move.l   a6,-(a7)  ; buffer to read into / write from
   move.w   d5,-(a7)  ; function #
   trap  #14     ; do it
   add.l    #20,a7
   tst.l    d0
   bne   error

   add.l    #4608,a6
   move.w   #3,-(a7)  ; count
   clr.w    -(a7)     ; side A
   move.w   #78,-(a7)    ; track #
   move.w   #4,-(a7)  ; sector # (start)
   move.w   currdrv,-(a7)   ; disk drive #
   clr.l    -(a7)     ; filler
   move.l   a6,-(a7)  ; buffer to read into / write from
   move.w   d5,-(a7)  ; function #
   trap  #14     ; do it
   add.l    #20,a7
   tst.l    d0
   bne   error
   clr.b    y1
   bra   @return

@rdwr539 move.l   x2,a6
   move.w   #3,-(a7)  ; count
   clr.w    -(a7)     ; side A
   move.w   #57,-(a7)    ; track #
   move.w   #6,-(a7)  ; sector # (start)
   move.w   currdrv,-(a7)   ; disk drive #
   clr.l    -(a7)     ; filler
   move.l   a6,-(a7)  ; buffer to read into / write from
   move.w   d5,-(a7)  ; function #
   trap  #14     ; do it
   add.l    #20,a7
   tst.l    d0
   bne   error
   clr.b    y1
   bra   @return

;*****************************************************************************;
;   initpri5 -- part of primary initialization daisy chain
;      load in startup file
;*****************************************************************************;

 XDEF initpri5

initpri5:
   move.w   bwflag,startrez ; in case startup file isn't there
   lea   color1a,a0   ; startup screen will come up
   lea   startpal,a1  ; in default rez and colors
   moveq    #16,d0
.loop    move.w   (a0)+,(a1)+
   subq.b   #1,d0
   bne   .loop
   clr.w    -(a7)     ; open startup screen file
   cmpi.w   #1,bwflag
   bne   .bw
   move.l   #startcol,-(a7)
   bra   .bwcol
.bw   move.l   #startmon,-(a7)
.bwcol   move.w   #$3D,-(a7)
   trap  #1
   addq.l   #8,a7
   cmpi.l   #0,d0
   blt   .skip
   move.w   d0,d7     ; d7.w = startupfile handle
   move.l   #startrez,-(a7) ; read in startup rez,colors,and
   move.l   #28194,-(a7) ; bit map
   move.w   d7,-(a7)
   move.w   #$3F,-(a7)
   trap  #1
   add.l    #12,a7
   move.w   d7,-(a7)
   move.w   #$3E,-(a7)
   trap  #1     ; close startupfile
   addq.l   #4,a7

; daisy-chain on to next link
.skip    jsr   initpri6
   rts
