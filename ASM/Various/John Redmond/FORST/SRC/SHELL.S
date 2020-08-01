; SHELL.S: Forth kernel routines, version 1.22
; Copyright <C> John Redmond 1989,1990
; Public domain for non-commercial use.
;
        section text
        even
;
;
;system vectors:
;
vectors:
tonumber: offs  _number
        dc.l    0
todot:  offs    _dot
        dc.l    0
toadd:  offs    _add
        dc.l    $e0042d00
tosub:  offs    _sub
        dc.l    $e0052d00
tomult: offs    _mult
        dc.l    0
todiv:  offs    _div
        dc.l    0
tomod:  offs    _mod
        dc.l    0
toabs:  offs    _abs
        dc.l    0
tonegate: offs  _negate
        dc.l    $a0032d00
;
toexpect: offs  _expect
        dc.l    0
toword: offs    _word
        dc.l    0
tofind: offs    _bfind
        dc.l    0
;
doword: move.l  toword(pc),d0
        jsr     (a5,d0.l)
        rts
dofind: move.l  tofind(pc),d0
        jsr     (a5,d0.l)
        rts
;
;*******************************************************;
;                                                       ;
;       The ForST outer interpreter                     ;
;                                                       ;
;*******************************************************;
outer:  bsr     prompt
        bsr     _query
        bsr     _interpret
        bra.s   outer
;
_query: lea     dstack,a0       ;keyboard buffer above data stack
        move.l  (a0),a0
        lea     tib,a1
        move.l  a0,(a1)
        move.l  #(kbuffsiz-3),d0 ;avoid a line wrap for input
        movem.l d0/a0,-(a6)
.q5:    bsr     _ekey
        cmp.w   #$4800,d0       ;an up arrow?
        beq.s   .again
        tst.l   d1
        bmi.s   .q5             ;not a valid char
        cmp.w   #$1c0d,d0
        beq.s   .quit           ;carriage return
        move.l  4(a6),a0
        move.b  d0,(a0)         ;char into buffer
        push    #1
        bra.s   .in5
.again: lea     oldlen,a0       ;same input as before
        push    (a0)            ;#chars input before
.in5:   bsr     re_expect
        lea     span,a0
        move.l  (a0),d0
.in7:   lea     htib,a1
        move.l  d0,(a1)         ;length of new input
        lea     oldlen,a1       ;a reserve copy
        move.l  d0,(a1)
        lea	toin,a1
        clr.l	(a1)		;start with zero offset
        rts
.quit:  lea     8(a6),a6        ;drop parms
        moveq.l #0,d0           ;no chars input
        bra.s   .in7
;
prompt: bsr     _cret
        bsr     _getdrv
        add.l   #'A',(a6)
        bsr     _conout
        push    #'>'
        bsr     _conout
        rts
;
_interpret:
        bsr.s   getword
        move.l  (a6),a0
        tst.b   (a0)
        beq.s   .intx           ;stop on zero length
        bsr.s   process_word
        bra.s   _interpret
.intx:  addq.l  #4,a6           ;drop ^pocket
        bsr     popin           ;else denest files
        bne.s   _interpret      ;if no keyboard input needed
.inx:   rts
;
getword: push   #32
        bsr     doword
        rts
;
process_word:
        bsr     dofind
        pop     d0              ;test flag
        beq.s   .not_there
        push    d0              ;replace flag for sign test
        bsr     action
        rts
.not_there:
        move.l  tonumber(pc),d0
        jsr     (a5,d0.l)
        bsr     stateat
        beq.s   .pwx
        bsr     _literal
.pwx:   rts
;
; _WORD: (char--addr) Fetch a word from the input stream and return
; it with a space terminator with address in POCKET.
_word:  movem.l d2/a2-a3,-(a7)
        bsr     _there
        add.l   #$400,(a6)      ;scratch space above heads
        lea     pocket,a1
        move.l  (a6),a0
        move.l  a0,(a1)         ;save pointer in pocket
        clr.l   -(a6)           ;character count
        addq.l  #1,a0           ;first address for a char
        move.l  a0,-(a6)        ;pointer to next char in buffer
.wd1:   bsr     inchar          ;get character from stream
        pop     d1              ;fetch char
        bmi.s   .wdx            ;finish if negative
        move.l  12(a6),d2       ;copy delimiter
        cmp.b   #32,d2          ;is delimiter a space?
        bne.s   .wd2            ;if not, start assembling string
        cmp.b   d1,d2
        beq.s   .wd1            ;skip it if = delimiter
        cmp.b   #13,d1
        beq.s   .wd1            ;CR = white space
        cmp.b   #10,d1
        beq.s   .wd1            ;LF = white space
        cmp.b   #9,d1
        beq.s   .wd1            ;TAB = white space
.wd2:   movem.l (a6)+,a0/a1     ;get pointer and count
        move.b  d1,(a0)+        ;store in
        addq.l  #1,a1           ;bump count
        movem.l a0/a1,-(a6)     ;save pointer and count
        bsr     inchar          ;another character
        pop     d1              ;fetch char
        bmi.s   .wdx            ;quit if no more chars
        move.l  12(a6),d2       ;copy delimiter
        cmp.b   d1,d2           ;is char = delimiter?
        beq.s   .wdx
        cmp.b   #32,d2          ;is delimiter a space?
        bne.s   .wd2            ;if not, get another char
        cmp.b   #9,d1           ;just fetched a TAB?
        beq.s   .wdx
        cmp.b   #10,d1          ;just fetched a CR?
        beq.s   .wdx
        cmp.b   #13,d1          ;just fetched a LF?
        bne.s   .wd2
.wdx:   movem.l (a6)+,a0-a3     ;a0=^nextch,a1=#chars,a2=^start,a3=delim
        move.b  #32,(a0)+       ;space terminator
        clr.b   (a0)            ;and a null!
        move.l  a1,d0           ;word length
        move.b  d0,(a2)         ;store it at string start
        move.l  a2,-(a6)        ;return address of pocket
        movem.l (a7)+,d2/a2-a3
        rts
;
_abort: move.l  dstack(pc),a6
	bsr	_there
	lea	entry,a0
	pop	(a0)		;give FIND a reasonable entry
_quit:  move.l  stack(pc),a7
        bsr     clrin           ;back to keyboard input
        lea     lpstkptr,a0
        move.l  a0,(a0)         ;clear system stacks
        bra     warm
;
_head:  bsr     name            ;returns cfa
        bsr     dofind
        pop     d0
        bne.s   .ok
        lea     werror,a0
        bra     _error
.ok:    rts
;
_compcomma: bsr _head
        pop     a0
        push    -(a0)
        push    8(a0)
        bsr     _lcomma
        bsr     _lcomma
        rts
;
_tick:  bsr     _head
        pop     a0
        bsr     codehead
        beq.s   .t5
        move.l  4(a0),d0
        add.l   a5,d0           ;convert offset to address
        bra.s   .tx
.t5:    moveq   #0,d0           ;return zero for a constant's address
.tx:    push    d0
        rts
;
_forget: bsr    _head
        move.l  (a6),a0
        lea     fence,a1
        cmp.l   (a1),a0
        bcc.s   .fgx
        lea     fgerror,a0
        bra     _error
.fgx:   bsr     discard
        rts
;
; _SKIP: (char--#chars)
; Fetch chars from the input stream until a specified char encountered.
_skip:  push    #0              ;character count
.sk1:   bsr     inchar          ;another character
        pop     d0              ;fetch char
        bmi.s   .skx            ;quit if no more chars
        add.l   #1,(a6)         ;increase count
        move.l  4(a6),d1        ;copy delimiter
        cmp.b   d0,d1
        bne.s   .sk1
.skx:   move.l  (a6)+,(a6)      ;return #chars skipped
        rts
;
_rbra:  push    #41             ;')'
        bsr     _skip
        addq.l  #4,a6
        rts
;
_bslash: push   #10             ;LF
        bsr     _skip
        addq.l  #4,a6
_noop:  rts
;
        section data
        even
;
        dc.b    $86,'SYSTEM',$a0
        ptrs    _system,20
;
        dc.b    $84,'SAVE',$a0
        ptrs    _save,18
;
        dc.b    $85,'STAR','T'!$80
        ptrs    _noop,18
;
        dc.b    $89,'INTERPRE','T'!$80
        ptrs    _interpret,22
;
        dc.b    $85,'QUER','Y'!$80
        ptrs    _query,18
;
        dc.b    $85,'ABOR','T'!$80
        ptrs    _abort,18
;
        dc.b    $84,'UPTO',$a0
        ptrs    _skip,18
;
        dc.b    $c1,'('!$80
        ptrs    _rbra,14
;
        dc.b    $c1,'\'!$80
        ptrs    _bslash,14
;
        dc.b    $81,39!$80
        ptrs    _tick,14
;
        dc.b    $c5,"'HEA","D"!$80
        ptrs    _head,18
;
        dc.b    $c4,'HEAD',$a0
        ptrs    _head,18
;
        dc.b    $c5,"COMP",","!$80
        ptrs    _compcomma,18
;
        dc.b    $86,'FORGET',$a0
        ptrs    _forget,20
;
        dc.b    $84,'QUIT',$a0
        ptrs    _quit,18
;
        dc.b    $84,'NOOP',$a0
        ptrs    _noop,18
;
        dc.b    $c7,'VECTOR','S'!$80
        vptrs   vectors,20
;
; vectored words:
;
        dc.b    $c6,'EXPECT',$a0
        vectptrs toexpect,20
;
        dc.b    $c4,'WORD',$a0
        vectptrs toword,18
;
        dc.b    $c4,'FIND',$a0
        vectptrs tofind,18
;
        dc.b    $c6,'NUMBER',$a0
        vectptrs tonumber,20
;
        dc.b    $c1,'.'!$80
        vectptrs todot,14
;
        dc.b    $c1,'+'!$80
        vectptrs toadd,14
;
        dc.b    $c1,'-'!$80
        vectptrs tosub,14
;
        dc.b    $c1,'*'!$80
        vectptrs tomult,14
;
        dc.b    $c1,'/'!$80
        vectptrs todiv,14
;
        dc.b    $c3,'MO','D'!$80
        vectptrs tomod,16
;
        dc.b    $c3,'AB','S'!$80
        vectptrs toabs,16
;
        dc.b    $c6,'NEGATE',$a0
        vectptrs tonegate,20
