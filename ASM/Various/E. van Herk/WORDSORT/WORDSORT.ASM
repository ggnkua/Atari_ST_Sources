*
*
*
*                --- *  WORDSORT.ASM V1.1 dd 28/5/1988  * ---
*
*
* This program was written by:
*
*                             E. van Herk
*                             Wakkerstraat 18/1
*                             1097 CE Amsterdam
*                             Netherlands
*
* Purpose: to output an alphabetically sorted list of all words appearing
* in a given input text.
*
* Machine: Atari ST with at least 330 K of free memory.
*
* Designed and tested on an 1040 STF, it should work on all Atari ST
* computers
*
* It is hereby placed in the public domain, with the restriction that
* it shall not be sold for profit, or copied without this header.
*
* This is a program written in assembler, after a C program written by
* E. van Herk, after a Pascal program written by Dick Pountain, in BYTE,
* July 1987 p. 275. The C program was disassembled and the code then 
* extensively rewritten to improve the speed of operation by a factor of
* 3 or 4 and the code size by a factor of 4.
*
* Parts of the program produced by the megamax C compiler may still be
* recognized by being in UPPERCASE.
*
* This sourcecode will assemble without changes on the Hisoft Devpac 
* assembler package, version 1.
*
* Goodie: the program recognizes the Atari characters for Ñç† etc.,
* so that words are not cut in two if a special character turns up.
*
* Restrictions: first letters of words must be in A-Z or a-z, and 
* special characters are sorted on their ascii values.(So that azimuth
* will come before aziâ)
*
* Numbers 0-9 are also allowed. All words are converted to lowercase.
* The program has been tested on Firstword+ files, and probably works 
* on most wordprocessor files.
* Hyphe-nated words are split into two by the program.
* Apostrophes (as in it's) are also regarded as being part of a word.
* 
* The program is quite fast, a 200 K textfile was completely sorted in
* 72 seconds (running from a ramdisk, running the program from floppy disk 
* will be rather slower ), yielding a list of 4700 words,
* and a 30 K file was sorted in just over 5 seconds.
*
* Algorithm: an array of 26 linked lists is kept, one list for each
* starting letter, and every word is read in and linked into its proper
* position. If it is already in the list it is discarded.
*
* The complete list is kept in memory and the space allotted is 300.000
* bytes which should be enough for the largest textfiles. ( something
* like 20,000 different words may be accommodated.) If this should prove 
* restrictive a larger amount may be allotted by changing the value
* in the malloc call.
*
* The author welcomes constructive criticism, bug reports, complaints
* and suggestions for improvement. Send a letter to the above address
* or leave a message to Bart van Herk on BBS Microlines 020-736008
*
* Enjoy the program!
*
* Changes in version 1.1 : 
*
* - 60 bytes of superfluous code have been removed.
* - The program has been speeded up 2 or 3 % by changing the order of the
*   letter validity tests. 
* - A bug which caused every last letter in the output buffer to be 
*   dropped has been corrected.
* - A bug which caused the program to crash if eof occurred right after a
*   valid letter has been corrected
* - A bug which caused the program to write a large output file of garbage
*   if presented with an input file that was empty or contained only 
*   non-letters has been corrected.
* - The disk buffers have been enlarged to 10 K to speed up operation from
*   floppy disk by 10 to 20 % 
*
* ------------------------------------------------------------------------

*        opt d+                 ; decomment to include label locations.
stacksize equ $400              ; 1 K is enough
bufsize equ   $2800             ; default file i/o buffer size 10K

start   move.l  a7,a5           ; save stackpointer in a5
        move.l  4(a5),a5        ; a5 now points to basepage
        move.l  $c(a5),d0       ; prg length
        add.l   $14(a5),d0      ; add initialized data size
        add.l   $1c(a5),d0      ; and unitialized data size
        add.l   #$100,d0        ; and basepage size
        move.l  d0,d6
        add.l   a5,d6
        move.l  d0,-(sp)        ; to stack
        move.l  a5,-(sp)        ; start address
        move.w  #0,-(sp)        ; filler
        move.w  #$4A,-(sp)      ; func #
        trap    #1              ; call gemdos
        lea     12(sp),sp       ; adj sp
        move.l  d6,sp           ; stack to top of alloc'ed mem
        move.l  $1c(a5),d0      ; BSS size
        lea     endcode,a0      ; start of bss
        bra.s   tst2            
tst1    clr.b   (a0)+           ; clear variable memory
tst2    dbra    d0,tst1
        lea     endcode,a4      ; all adressing rel a4
        lea     start,a5        ; to start of prog         
main:
        bsr     aesinit
        bsr     appl_init
        move.w  d0,apid(A4)     ; get application id.
        CMPI    #-1,D0
        BNE.S   L2
        PEA     estr1           ; error cant open app
        MOVE    #1,-(A7)        ; 
        bsr     form_alert
        ADDQ.L  #6,A7
        bra    pterm
L2:
        lea     defpath,a0      ; default path
        lea     inpath(a4),a1   ; get input path address
        lea     outpath(a4),a2  ; and output path address
again   move.b  (a0),(a1)+      ; copy a char ;
        move.b  (a0)+,(a2)+     ; and to other buffer
        bne.s   again           ; until defpath copied
        MOVE    #25,-(A7)       ; getdrive function
        trap    #1
        ADDQ.L  #2,A7
        ADD.b   #65,D0          ; + 'A'
        MOVE.B  D0,drive(a4)
        move.b  d0,inpath(a4)   ; set current drive
        move.b  d0,outpath(a4)  ; in output path, too
        PEA     button(a4)      ;  
        pea     infstr          ; 
        PEA     inpath(a4)      ; 
        bsr     fsel_input      ; call input file selector box
        lea     12(a7),A7
        CMPI    #0,button(a4)   ; cancelled?
        BNE.S   L3
        bra     ex4           ; then exit
L3:
        PEA     infstr
        PEA     inpath(a4)
        bsr     join            ; make a composite path/filename
        ADDQ.L  #8,A7
        MOVE.L  D0,-(A7)        ; pathfilename to stack
        bsr     fopen
        ADDQ.L  #4,A7
        MOVE.L  D0,infile(a4)   ; get FILE * or error
        CMPI.L  #0,D0
        BNE.S   L4
        PEA     estr2           ; can't open input file
        MOVE    #1,-(A7)
        JSR     form_alert(PC)
        ADDQ.L  #6,A7
        bra     ex4
L4:
        PEA     button(a4)
        pea     outfstr
        PEA     outpath(a4)
        bsr     fsel_input      ; select outputfile
        lea     12(a7),a7
        CMPI    #0,button(a4)
        BNE.S   L5
        bra     ex3            ; if cancelled
L5:
        pea     outfstr
        PEA     outpath(a4)
        JSR     join(PC)
        ADDQ.L  #8,A7
        MOVE.L  D0,-(A7)        ; path/filename
        bsr     fcreate
        ADDQ.L  #4,A7
        MOVE.L  D0,outfile(a4)  ; get file 
        CMPI.L  #0,D0           ; error?
        BNE.S   L6
        PEA     estr3
        MOVE    #1,-(A7)
        bsr     form_alert
        ADDQ.L  #6,A7
        bra.s     ex3
L6:
        MOVE.L  #300000,-(A7)           ; malloc memory buffer
        MOVE    #72,-(A7)
        trap    #1
        ADDQ.L  #6,A7
        MOVE.L  D0,memblock(A4)
        CMPI.L  #0,D0
        BNE.S   L7
        PEA     estr4           ; cannot allocate enough memory
        MOVE    #1,-(A7)
        bSR     form_alert
        ADDQ.L  #6,A7
        bra.s     ex2             ; close both files
L7:
        bSR.s   sortword
        bSR   squirtword
        MOVE.L  memblock(A4),-(A7)      ; free allotted mem
        MOVE    #73,-(A7)
        trap    #1
        ADDQ.L  #6,A7

exit    
ex1     bsr     flushbuf                ; flush output buffer
ex2     move.w  outhandle(a4),-(a7)     ; close output file
        move.w  #$3E,-(a7)
        trap    #1
        addq.l  #4,a7
ex3     move.w  inhandle(a4),-(a7)      ; close input file
        move.w  #$3e,-(a7)
        trap    #1
        addq.l  #4,a7
ex4     bSR     appl_exit               ; report off to aes
pterm   clr.w   -(a7)                   ; leave program
        move.w  #$4c,-(a7)
        trap    #1

sortword
        move.l  memblock(a4),freeptr(a4)
        BRA.S   L14
L15:    bSR     readword                ; get a word in freeptr
        tst.l   d0                      ; if zero, end of input file
        beq.s   swout
        MOVE.L  freeptr(a4),-(A7)       ; word to be put current
        MOVE.L  D0,freeptr(a4)          ; new freeptr = returned value
        BSR     placeword
        ADDQ.L  #4,A7
L14:    tst.w   ineof(a4)                 ; infile 
        BEQ.S   L15                     ; if not yet eof...
swout   RTS

readword:                       
        LINK    A6,#-4          ;  -4(a6) is pointer.
        MOVE.L  freeptr(a4),a0  ;
        CLR.L   (A0)+           ; 
        move.l  a0,-4(a6)       ; skip pointer
first   tst.w   ineof(a4)
        BNE     eofin           ; if not eof (infile)
        bSR     fgetc
        CMP     #97,D0          ; c < 'a'?
        Bmi.S   L23
        CMP     #122,D0         ; c <='z'?
        BLs.S   store           ; 
L23:    CMP     #65,D0          ; c < 'A'
        Bmi.S   first
        CMP     #90,D0          ; c > 'Z'
        Bhi.S   first
* so much for the first character.
lower   ADDI.B  #32,d0          ; if c in A..Z then lowercase
store   move.l  -4(a6),a0       ; refresh freeptr
        MOVE.B  d0,(A0)+        ; free++ = c ;
        move.l  a0,-4(a6)       ; update string pointer
L26:    tst.w   ineof(a4)
        BNE.S   notvalid        ; while not eof
        BSR     fgetc

* now, the most likely is that d0 in ['a'..'z']

        CMP     #97,D0          ; 'a'
        Bmi.S   large           ; 
        CMP     #122,D0         ; 'z'
        BLs.S   store           ; it was in a..z
        bra.s   special         ; larger than 'z' -> may be an accent

large   CMP     #65,D0          ; 'A'
        Bmi.S   apo             ; < 'A' - could be a digit or '
        CMP     #90,D0          ; 'Z'
        BLs.S   lower           ; it is an uppercase and must be lowered

apo     CMP     #39,D0          ; apostrophe
        BEQ.S   store           ; it is an apostrophe

num     cmp     #48,d0          ;'0'
        bmi.s   notvalid        ; smaller than '0' - can't be valid
        cmp     #57,d0          ;'9'
        bls.s   store

special cmp     #128,d0         ; c cedille
        bmi.s   notvalid        ;              
        cmp     #154,d0         ; u umlaut
        bls.s   store

sharp   cmp     #160,d0         ; accent aigu
        bmi.s   notvalid
        cmp     #165,d0         ; n tilde
        bls.s   store

notvalid move.l  -4(a6),a0        ; refresh freeptr
        CLR.B   (A0)+            ; end of string byte
        move.l  a0,d0
        ADDQ.L  #1,d0
        bclr    #0,d0             ; make address even for next word...
        bra.s   l18

eofin   moveq.l #0,d0

L18:    UNLK    A6
        RTS

placeword:
        LINK    A6,#0           ; 8(a6) = word address 
        move.l  8(a6),a0        ; word pointer
        addq.l  #4,a0           ; to first char
        move.b  (a0),d0         ; first char
        sub.b   #$61,d0         ; index
        ext.w   d0              ;
        ext.l   d0              ; long value
        asl.w   #2,d0           ; times four for offset
        lea     alfabet(a4),a1  ; get array address
        add.l   d0,a1           ; (a1) now is the pointer to the first word
pw1     move.l  8(a6),a0        ; word pointer
pw4     tst.l   (a1)            ; pointer empty?
        bne.s   pw2
        move.l  a0,(a1)         ; add word at end of list
        bra.s   pwout
pw2     move.l  a1,a2           ; keep previous pointer for insert
        move.l  (a1),a1         ; advance pointer
        move.l  a0,-(a7)        ; word 
        move.l  a1,-(a7)        ; compareword
        bsr     sdif            ; get string difference
        movea.l  (a7)+,a1       ; get back pointers
        movea.l  (a7)+,a0       ; 
* flags still in state from sdif here!
        beq.s   pw3             ; equal -> drop word.
        bhi.s   pw5             ; larger -> insert
        bra.s   pw4             ; smaller, try next
pw3     move.l  a0,freeptr(a4)  ; delete word from buffer!
        bra.s   pwout
pw5     move.l  a0,(a2)         ; previous pointer to word
        move.l  a1,(a0)         ; word pointer to next
pwout   UNLK    A6
        RTS

* string difference
sdif:   move.l  4(a7),a0        ; first word
        move.l  8(a7),a1        ; second word
        addq.l  #4,a0           ; skip pointer
        addq.l  #4,a1           ; here too

sdif1   move.b  (a0)+,d0        ; 8
        beq.s   endstr          ; 10/8     string 1 finished
        sub.b   (a1)+,d0        ; 8
        bne.s   unequal         ; 10/8
        bra.s   sdif1           ; 10    =42ticks  try next byte   

endstr  sub.b   (a1)+,d0        ;         if a1 also ended: done, result 0
unequal 
out2    RTS


squirtword:
        LINK    A6,#-6          ; -6(a6) = starting pointer
        CLR     -2(A6)
        BRA.S   L53
L54:    lea     alfabet(a4),A0
        ADDA    -2(a6),A0
        MOVE.L  (A0),-6(a6)     ; starting pointer
        BRA.S   L57
L58:    MOVE.L  -6(A6),D0       ; pointer
        ADDQ.L  #4,D0
        MOVE.L  D0,-(A7)        ; string
        bSR     fputs
        ADDQ.L  #4,A7
        MOVE.L  -6(A6),A0
        MOVE.L  (A0),-6(a6)     ; chain to next
L57:    CMPI.L  #0,-6(A6)       ; does it have a follower?
        BNE.S   L58
L55:    ADDQ    #4,-2(A6)
L53:    CMPI    #104,-2(A6)
        BLT.S   L54
L52:    UNLK    A6
        RTS

join:                           
* 8(a7)=file 4(a7)=path names to be joined for fopen
        move.l  4(a7),a0        ; pathname
zer1    cmpi.b  #$2A,(a0)       ; is it a '*' ?
        beq.s   join3           ; then we can copy the filename
        tst.b   (a0)+           ; see if finished
        bne.s   zer1            ; no, go on.(a0 to point to eof string zero)
        subq.l  #1,a0           ; to previous position
join3   move.l  8(a7),a1        ; filename
join4   move.b  (a1)+,(a0)+     ; copy filename to path
        bne.s   join4
        move.l  4(a7),d0
        RTS

* create a file, allocate a buffer, and initialize file- 
* -variables in control block (not C compatible )
* calling sequence: move.l      pathfilename,-(a7)
*                   bsr         fcreate
*                   addq.l      #4,a7
*                   tst.l       d0
*                   beq         error
*                   move.l      d0,filepointer(a4)

fcreate  link   a6,#0
* 8(a6) pathname 
        move.w  #0,-(a7)                ; common or garden file
        move.l  8(a6),-(a7)             ; pathfilename
        move.w  #$3C,-(a7)              ; fcreate opcode
        trap    #1                      ; call gemdos
        addq.l  #8,a7                   ; adjust stack for changes HERE
        tst.w   d0
        bpl.s   fcr2                    ; allright
        moveq   #0,d0                   ; couldn't open, error code
        bra.s   fcrexit
fcr2    move.w  d0,outhandle(a4)        ; save handle of open file
        move.w  #1,outmode(a4)          ; 2 = mode (1,write only)
        move.w  #-1,outeof(a4)          ; eof
        lea     outbuf(a4),a0           ; start of buffer
        move.l  a0,outpcur(a4)          ; ...at start of buffer
        add.l   #bufsize,a0             ; max valid
        move.l  a0,outpmax(a4)          ; and set.
        lea     outhandle(a4),a0        ; start of block
        move.l  a0,d0                   ; result pointer
fcrexit unlk    a6
        rts

* write the current contents of the output buffer to disk
flushbuf link   a6,#-4
        lea     outbuf(a4),a0          ; start of buffer
        move.l  outpcur(a4),d0         ; first free byte 
        sub.l   a0,d0                  ; count to write 
        move.l  d0,-4(a6)              ; count
        beq.s   flushed                ; file was empty
        move.l  a0,-(a7)               ; buffer
        move.l  d0,-(a7)               ; count
        move.w  outhandle(a4),-(a7)    ; handle
        move.w  #$40,-(a7)             ; opcode fwrite
        trap    #1                     ; call gemdos
        lea     12(a7),a7              ; adjust stack
        move.l  -4(a6),d1 
        cmp.l   d0,d1                   ; count written=to write?
        bne.s   er1                     ; if not disk full probably!
        lea     outbuf(a4),a0           ; start of buffer
        move.l  a0,outpcur(a4)          ; set current
        add.l   #bufsize,a0             ; maxvalid
        move.l  a0,outpmax(a4)          ; and set
        bra.s   flushed
er1     pea     estr6                   ; error writing file
        move.w  #1,-(a7)
        bsr     form_alert
        addq.l  #6,a7
        bra     ex2                     ; close files and leave
flushed unlk    a6
        rts

* write a char to diskbuffer & flush if necessary
* expects char in d0
fputc   move.l  outpcur(a4),a0  ; get pointer
        move.b  d0,(a0)+        ; write byte
        move.l  a0,outpcur(a4)  ; update counter
        cmpa.l  outpmax(a4),a0  ; is pointer now greater than max?
        blt.s   fputout         ; no, we're done
        bsr     flushbuf        ; else flush buffer
fputout rts

* write a string to a file. expects address of string 
* adds a newline.
fputs   move.l  4(a7),a0        ; string address
        move.l  outpcur(a4),a1  ; get pointer
fputs2  tst.b   (a0)            ; is it a zero?
        beq.s   fputsout        ; then string is done 
        move.b  (a0)+,(a1)+     ; write a byte
        cmpa.l  outpmax(a4),a1  ; is pointer now greater than max?
        blt.s   fputs2          ; no, go for next char
        move.l  a1,outpcur(a4)  ; update counter
        movem.l d0-d3/a0-a3,-(a7) ; yes, save registers
        bsr     flushbuf        ; and flush buffer first
        movem.l (a7)+,d0-d3/a0-a3 ;
        move.l  outpcur(a4),a1  ; reset buffer pointer.
        bra.s   fputs2
fputsout move.l a1,outpcur(a4)  ; update counter
        move.b  #$D,d0          ; CR char
        bsr     fputc           ; output it
        move.b  #$A,d0          ; LF char
        bsr     fputc
        rts

* open a file, allocate a buffer, and initialize file- 
* -variables in control block (not C compatible )
* calling sequence: move.l pathfilename,-(a7)
*                   bsr fopen
*                   addq.l #4,a7
*                   tst.l  d0
*                   beq error
*                   move.l d0,filepointer(a4)
* the global constant bufsize is the max bytes that are read in the buffer.

fopen   link    a6,#0                   ; 8(a6)=pathfilename  
        clr.w   -(a7)                   ; mode
        move.l  8(a6),-(a7)             ; pathfilename
        move.w  #$3D,-(a7)              ; fopen opcode
        trap    #1                      ; call gemdos
        addq.l  #8,a7                   ; adjust stack for changes 
        tst.w   d0
        bpl.s   fop2                    ; allright
        moveq   #0,d0                   ; couldn't open, error code
        bra.s   fopexit
fop2    move.w  d0,inhandle(a4)         ; save handle of open file
        clr.w   inmode(a4)              ; mode 0 read only 
        clr.w   ineof(a4)               ; not yet end of file
        lea     inbuf(a4),a0            ; start
        move.l  a0,inpcur(a4)           ; and set
        adda.l  #bufsize,a0             ; add size
        move.l  a0,inpmax(a4)           ; and set max
        bsr     fillbuf                 ; fill the buffer
        tst.l   d0                      ;
        beq     ex3                     ; file was empty
        lea     inhandle(a4),a0         ; return address
        move.l  a0,d0                   ; return the buffer pointer
fopexit unlk    a6
        rts

* get a character from input file  
fgetc   moveq.l #0,d0           ; 
        tst.w   ineof(a4)       ; eof?
        beq.s   getc            ; not eof, get character
        bra.s   fgetout         ; and exit
getc    move.l  inpcur(a4),a0   ; current pointer
        move.b  (a0)+,d0        ; get byte
        move.l  a0,inpcur(a4)   ; update pointer
        cmpa.l  inpmax(a4),a0   ; compare upper limit
        ble.s   fgetout         ; not there yet, done
        move.w  d0,-(a7)        ; save char
        bsr     fillbuf
        move.w  (a7)+,d0        ; get char
fgetout rts

* routine to fill a data buffer from disk
* buffer structure: 0 - handle
*                   2 - mode
*                   4 - eof (if 0 not eof)
*                   6 - buffer pointer
*                  10 - max valid byte pointer 
*                  14 - start of data
*
fillbuf 
        link    a6,#0           ; no local vars
        tst.w   ineof(a4)       ; eof reached?
        bne.s   fillbuf2        ; if eof then exit
        pea     inbuf(a4)       ; start of buffer
        move.l  #bufsize,-(a7)  ; count
        move.w  inhandle(a4),-(a7) ; handle
        move.w  #$3F,-(a7)      ; fread opcode
        trap    #1              ; call gemdos
        lea     12(a7),a7       ; adjust stack
        tst.l   d0              ; anything read?
        beq.s   eof             ; no bytes read
        bmi.s   err             ; error
        lea     inbuf(a4),a0    ; start of buf
        move.l  a0,inpcur(a4)   ; set pointer
        adda.l  d0,a0           ; end of buf
        move.l  a0,inpmax(a4)   ; max valid byte
        bra.s   filuit          ; success; d0 = bytes read
eof     move.w  #-1,ineof(a4)   ; set eof
        bra.s   fillbuf2
err     pea     estr5
        move.w  #1,-(a7)
        bsr     form_alert
        addq.l  #6,a7
        bsr     exit
fillbuf1
fillbuf2 moveq  #0,d0           ; no bytes read
filuit  unlk    a6
        rts
        
* initialize aes arrays
aesinit   lea       aespb(a4),a0
          lea       control(a4),a1
          move.l    a1,(a0)+
          lea       global(a4),a1
          move.l    a1,(a0)+
          lea       intin(a4),a1
          move.l    a1,(a0)+
          lea       intout(A4),a1
          move.l    a1,(a0)+
          lea       addrin(A4),a1
          move.l    a1,(a0)+
          lea       addrout(A4),a1
          move.l    a1,(a0)+
          rts
*
* Call AES and get returnvalue to d0  
aes       lea       aespb(A4),a0        ; address of aespb
          move.l    a0,d1               ; to d1
          move.w    #$C8,d0             ; opcode aes
          trap #2
          move.w    intout(A4),d0       ; get result parameter
          rts

* initialize application - or rather, report to OS that we're there.
appl_init lea       control(A4),A0
          move.l    #$A0000,(a0)+            ; opcode for applinit
          move.l    #$10000,(a0)+
          move.w    #0,(a0)+
          bsr.s       aes
          rts

* draw an alertbox on screen, C compatible
form_alert    
        MOVE.W  $0004(A7),intin(A4)     ; defaultbutton
        MOVE.L  $0006(A7),addrin(A4)    ; address of alertstring
        lea     control(A4),A0    
        MOVE.l  #$340001,(A0)+          
        move.l  #$10001,(a0)+
        move.w  #0,(a0)+
        bsr     aes
        RTS

* draw a file selector box on screen, C compatible
fsel_input
        move.l  4(a7),addrin(a4)        ; path
        move.l  8(a7),addrin+4(a4)      ; filename
        lea     control(a4),a0          ; 
        move.l  #$5A0000,(a0)+               ; opcode fselect
        move.l  #$20002,(a0)+
        move.w  #0,(a0)+
        bsr     aes
        move.l  12(a7),a0
        move.w  intout+2(a4),(a0)     ; button
        rts

* exit application, C compatible.
appl_exit
        lea control(a4),a0
        move.l  #$130000,(a0)+       ; opcode appl-exit
        move.l  #$10000,(a0)+
        move.w  #0,(a0)+
        bsr     aes
        rts

infstr  dc.b "INPUT.TXT",0,0,0,0
        even
outfstr dc.b "SORTED.OUT",0,0,0
        even
defpath dc.b "A:\*.*",0
        even
estr1   dc.b "[3][Can't open application][ sorry! ]",0
        even
estr2   dc.b "[3][Can't open input file][ sorry! ]",0
        even
estr3   dc.b "[3][Can't open output file][ shit! ]",0
        even
estr4   dc.b "[3][Can't allocate memory|(At least 330 K!)][ sorry! ]",0
        even
estr5   dc.b "[3][Error reading input file.][ shit! ]",0
        even
estr6   dc.b "[3][Write error|(Disk full?)][ shit! ]",0
        even

* and here the space for variables.
endcode
                rsreset
memblock        rs.l    1               ; start of buffer for words
freeptr         rs.l    1               ; points to free memory space
apid            rs.w    1               ; application id
button          rs.w    1               ; exit button of fselect & alert
infile          rs.l    1               ; pointer to input FILE block
outfile         rs.l    1               ; ptr to output FILE block
inpath          rs.b    64              ; 
outpath         rs.b    64
alfabet         rs.l    26              ; array of pointers
drive           rs.w    1               ; current drive
aespb           rs.l    6
control         rs.w    5
global          rs.w    15
intin           rs.w    16
intout          rs.w    7
addrin          rs.l    2
addrout         rs.l    1

inhandle        rs.w    1
inmode          rs.w    1
ineof           rs.w    1
inpmax          rs.l    1
inpcur          rs.l    1
inbuf           rs.b    bufsize

outhandle       rs.w    1
outmode         rs.w    1
outeof          rs.w    1
outpmax         rs.l    1
outpcur         rs.l    1
outbuf          rs.b    bufsize

stapel          rs.b    stacksize
                rsbss
                end
