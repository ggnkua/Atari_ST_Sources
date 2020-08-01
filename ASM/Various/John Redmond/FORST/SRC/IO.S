; IO.S: ForST i/o utilities
; Copyright <C> John Redmond 1989, 1990
; Public domain for non-commercial use.
;
        section text
        even
;
;character i/o vectors:
;
inp:    offs    _conin
        offs    _conin          ;just a safeguard
        offs    _auxin
        offs    dummy           ;dummy char from printer
        offs    dummy
outp:   offs    _conout         ;another safeguard
        offs    _conout
        offs    _auxout
        offs    _prtout
        offs    _drop           ;dummy output
;
; INCHAR fetches a char from a file (or a buffer accessed with
; tib and toin).  The char is returned (or a neg val if input finished).
inchar: movem.l a2-a3,-(a7)
        lea     src,a0
        move.l  (a0),d0         ;SRC has file handle
        beq.s   .conchar
;
        cmp.l   #-1,d0
        beq     .macchar
        push    d0              ;fetch from file
        bsr     bgetc
        pop     d1              ;get returned char
        bmi.s     .eof          ;return error value
        bra.s   .icx            ;return the char
.delim: move.w  #32,d1          ;replace with a space
        bra.s     .icx
.eof:   moveq.l #-1,d1          ;return negative
        bra.s     .icx
;
.conchar: lea   htib,a2         ;^#chars in buffer
	lea	tib,a1		;^buffer address
        lea     toin,a0
.cc5:	move.l  (a0),d0         ;pointer offset
        cmp.l   (a2),d0         ;reached the end?
        blt.s   .cc6
        moveq.l #-1,d1          ;eof
        bra.s   .icx
.cc6:	addq.l  #1,(a0)         ;bump offset            
        move.l  (a1),a1         ;fetch buffer address
        clr.l   d1
        move.b  (a1,d0.l),d1    ;fetch the char
.icx:   push    d1
        movem.l (a7)+,a2-a3
        rts
;
.macchar:
        lea     hmac,a2         ;^#chars in macro
	lea	macptr,a1       ;^macro  string
	lea	macin,a0	;^pointer offset
        bra.s   .cc5
;
clrin:  lea     instkptr,a0
        move.l  a0,(a0)         ;empty the stack
        lea     src,a0
        clr.l   (a0)            ;input from keyboard
        rts
;
pushin: move.l  a2,-(a7)
        lea     instkptr,a1     ;save source on stack, then redirect
        move.l  (a1),a0
        lea     inbott,a2       ;bottom of instack
        cmpa.l  a0,a2
        blo.s   .pi4
        lea     inserr,a0
        bra     _error          ;in stack overflow
.pi4:	lea     src,a2
        move.l  (a2),d0
        pop     (a2)            ;new source to SRC
	tst.l   d0
        bpl.s   .pi5            ;not presently using a text macro
        lea     macptr,a2
        move.l  (a2),-(a0)      ;text macro source
        lea     hmac,a2
        move.l  (a2),-(a0)      ;# text macro chars left
        lea	macin,a2
        move.l	(a2),-(a0)	;input pointer offset
.pi5:   move.l  d0,-(a0)        ;save source
        move.l  a0,(a1)         ;save instack pointer
        move.l (a7)+,a2
        rts
;
popin:  movem.l  a2/a3,-(a7)
;
; check current source and close file if necessary
        lea     src,a2          ;get source if one is on the stack
        move.l  (a2),d0         ;current source
        beq     .pina           ;finished if from the keyboard
        bmi     .pin5           ;or if from a macro
; close the file
        push    a2              ;src
        push    d0              ;current source
        lea     f1,a0
        sub.l   a0,d0
        divu    #bsize,d0       ;calc # file
        lea     bufflgs,a0
        clr.b   (a0,d0.w)       ;mark file as unused
        bsr     _fclose         ;close file
        pop     a2
        
; check for denesting the input
.pin5:  lea     instkptr,a1
        move.l  (a1),a0
        cmp.l   a0,a1           ;anything on the stack?
        bgt     .pinx           ;if so, get it
        clr.l   (a2)            ;return zero = back to keyboard
        bra     .pina
        
; pop the next higher level of input
.pinx:  move.l  (a0)+,d0
        bpl.s   .pin9           ;not a text macro source
        
; pop the text macro parameters
        lea     macin,a3
        move.l  (a0)+,(a3)      ;input pointer offset
        lea     hmac,a3
        move.l  (a0)+,(a3)      ;# chars in source
        lea     macptr,a3
        move.l  (a0)+,(a3)      ;text macro source

; do the denest
.pin9:  move.l  d0,(a2)         ;restore SRC
        move.l  a0,(a1)         ;save instack pointer
        tst.l   d0		;return non-zero for file or text macro
        bne.s   .piny           ;not keyboard input

; check status of keyboard buffer
.pina   lea     htib,a0
        move.l  (a0),d0		;chars in keyboard buffer?
        lea	toin,a0
        cmp.l	(a0),d0		;return zero = used all of them
;
.piny:  movem.l (a7)+,a2/a3
        rts
;
getbuff: lea    bufflgs,a0      ;start of buffer flags
        move.l  #(nobuffs-1),d0
.gb3:   tst.b   0(a0,d0.l)
        beq     .bvac
        subq.l   #1,d0
        bpl     .gb3
        lea     xserror,a0
        bra     _error
.bvac:  move.b  #-1,0(a0,d0.l)
        mulu    #bsize,d0
        lea     f1,a0
        add.l   a0,d0           ;return start of file
        push    d0              ;one copy for _fopen
        push    d0              ;and one copy for pushin
        rts
;
_emit:  lea     dest,a0
        move.l  (a0),d0
        bpl.s   .em5            ;output not teed
        neg.l   d0
        move.l  (a6),d1         ;char
        push    d0              ;true file dest
        push    d1              ;second copy of char
        push    #1              ;console output
        bsr     _putc
        bra.s   .em6
.em5:   push    d0
.em6:   bsr     _putc
        rts
;
_type:  movem.l  (a6)+,d1/a0    ;pointer,length on dstack
        tst.l   d1
        beq.s     .tyx
.tylp:  clr.l   d0
        move.b  (a0)+,d0 
        movem.l d0/d1/a0,-(a6) 
        bsr.s     _emit
        movem.l (a6)+,d1/a0 
        subq.l  #1,d1 
        bne     .tylp
.tyx:   rts

;
_ctype: movem.l  (a6)+,d1/a0    ;pointer,length on dstack
        tst.l   d1
        beq.s     .tyx
.tylp:  clr.l   d0
        move.b  (a0)+,d0 
        movem.l d0/d1/a0,-(a6) 
        bsr     _conout
        movem.l (a6)+,d1/a0 
        subq.l  #1,d1 
        bne.s     .tylp
.tyx:   rts
;
_message: bsr   _string         ;print message to the console
        push    #10
        push    #13             ;cr/lf
        bsr     _conout
        bsr     _conout
        rts
;
_string: bsr    _count          ;message to console
        bsr     _ctype
        rts
;
_bspace: push   #8
        bsr     _emit
        push    #32
        bsr     _emit
        push    #8
        bsr     _emit
        rts
;
_bspaces: pop     d0
        ble     .bsx
        subq.l  #1,d0
        push    d0
        bsr     _bspace
        bra     _bspaces
.bsx:   rts
;
_space: push    #32
        bsr     _emit
        rts
; 
_spaces: pop     d0
        ble     .bsx
        subq.l  #1,d0
        push    d0
        bsr     _space
        bra     _spaces
.bsx:   rts
;
; 
_key:   push    #0
        bsr     _getc
        rts
; 
_xkey:  move.w  #7,-(a7)
        trap    #1 
        addq.l  #2,a7 
        move.l  d0,d1
        lsr.l   #8,d1
        or.l    d1,d0                   ;scan code in byte 1
        and.l   #$0ffff,d0
        push    d0                      ;return char & scan code
        rts 
;
; Words for pictured numeric output.
;
_hash:                                  ;(number,#chars,^buffer)
        lea     base,a0
        push    (a0)
        bsr     _udmod
        bsr     _swap
        bsr     toasc
        bsr     _hold
        rts
;
toasc:  pop     d0
        add.b   #'0',d0
        cmp.b   #'9',d0
        bls     .tox                    ;not a hex number
        addq.b  #7,d0
.tox:   push    d0
        rts
;
_hold:  move.l  d2,-(a7)
        movem.l (a6)+,d0-d2/a0          ;everything off stack
        move.b  d0,-(a0)                ;store char in buffer
        addq.l  #1,d2                   ;increase char count
        movem.l d1/d2/a0,-(a6)          ;for another go
        move.l  (a7)+,d2
        rts
;
_hashs: bsr     _hash
        move.l  (a6),d0
        bne     _hashs
        rts
;
_sign:  tst.l   (a6)+                   ;test quotient
        bpl     .six
        push    #'-'                    ;minus sign
        bsr     _hold
.six:   rts
;
_bhash: bsr     _pad
        pop     a0                      ;buffer pointer
        pop     d0                      ;number for conversion
        clr.l   d1                      ;char counter
        movem.l d0/d1/a0,-(a6)
        rts
;
_hashb: addq.l  #4,a6
        rts
;
_bdot:  move.l  (a6),-(a7)              ;>R to save sign
        bsr     _abs
        bsr     _bhash
        bsr     _hashs
        push    (a7)+                   ;R> to fetch sign
        bsr     _sign
        bsr     _hashb
        rts
;
_dot:   bsr     _bdot
        bsr     _type
        bsr     _space
        rts
;
_udot:  bsr     _bhash
        bsr     _hashs
        bsr     _hashb
        bsr     _type
        bsr     _space
        rts
;
_convert: movem.l d3/a2-a4,-(a7)
        pop     a4                      ;string pointer
        addq.l  #1,a4                   ;point to a char
        lea     base,a3
        move.l  (a3),d3                 ;keep number base in D3
        movem.l d3/a4,-(a7)             ;save pointer and base
.co1:   movem.l (a7)+,d3/a4             ;pointer and base back
        clr.l   d0
        move.b  (a4)+,d0                ;fetch next char
        sub.b   #'0',d0                 ;strip ASCII bias
        bcs.s   .cox                    ;char too low
        cmp.b   #10,d0                  ;decimal char?
        bcs.s   .valid
        cmp.b   #16,d0
        bcs.s   .cox                    ;not a proper hex char
        subq.b  #7,d0
        cmp.b   d3,d0
        bcs.s   .valid
        bra.s   .cox                    ;char too high
.valid: movem.l  d3/a4,-(a7)            ;base and pointer
        move.l  (a7),-(a6)
        move.l  d0,-(a7)                ;save next digit
        bsr     _uxmult
        addq.l  #4,a6                   ;trim to 32 bits
        move.l  (a7)+,d0
        add.l   d0,(a6)                 ;add into number
        lea     dpl,a4
        tst.l   (a4)
        bmi.s   .co1                    ;no punctuation
        add.l   #1,(a4)                 ;increment decimal places
        bra.s   .co1
.cox:   subq.l  #1,a4                   ;back up pointer
        push    a4                      ;and return it on top
        movem.l (a7)+,d3/a2-a4
        rts
;
_number: move.l a4,-(a7)
        lea    dpl,a0
        move.l  #-1,a0                  ;punctuation flag
        pop     a4                      ;^string
        clr.l   -(a6)                   ;number accumulator
        clr.l   d5                      ;sign flag
        cmp.b   #'-',1(a4)              ;minus sign?
        bne.s   .nu1
        addq.l  #1,a4
        subq.l  #1,d5                   ;result negative
.nu1:   move.l  d5,-(a7)                ;save sign
        push    a4
.nu2:   bsr     _convert
        move.l  (a6),a0                 ;copy string pointer
        move.b  (a0),d0                 ;fetch next char
        cmpi.b  #32,d0                  ;pointing to a space?
        beq.s   .nu5                    ;end of valid number
        bsr.s   .punct
        bra.s   .nu2                    ;continue after punct.
.nu5:   addq.l  #4,a6                   ;drop pointer
        tst.l   (a7)+                   ;test sign
        beq.s   .nux
        bsr     _negate
.nux:   move.l  (a7)+,a4
        rts
;
.punct: cmp.b   #44,d0                  ;, char
        blt     .what
        cmp.b   #47,d0                  ;/ char
        bgt     .what
        lea     dpl,a0
        clr.l   (a0)
        rts
;
.what:  lea     werror,a0               ;reject illegal non-numeric
        bra     _error
;
_hex:   lea     base,a0
        move.l  #16,(a0)
        rts
;
_decimal: lea   base,a0
        move.l  #10,(a0)
        rts
;
_cret:  push    #10
        bsr     _emit
        push    #13
        bsr     _emit
        rts
;
        section data
        even
;
; character io words
;
        dc.b    $86,'INCHAR',$a0
        ptrs   inchar,20
;
        dc.b    $83,'KE','Y'!$80
        ptrs    _key,16
;
        dc.b    $84,'XKEY',$a0
        ptrs    _xkey,18
;
        dc.b    $84,'EMIT',$a0
        ptrs    _emit,18
;
        dc.b    $82,'CR',$a0
        ptrs    _cret,16
;
        dc.b    $83,'CL','S'!$80
        ptrs    _cls,16
;
        dc.b    $85,'SPAC','E'!$80
        ptrs    _space,18
;
        dc.b    $86,'SPACES',$a0
        ptrs   _spaces,20
;
; number io words
;
        dc.b    $83,'HE','X'!$80
        ptrs    _hex,16
;
        dc.b    $87,'DECIMA','L'!$80
        ptrs    _decimal,20
;
        dc.b    $87,'INUMBE','R'!$80
        ptrs    _number,20
;
        dc.b    $87,'CONVER','T'!$80
        ptrs    _convert,20
;
        dc.b    $82,'<#',$a0
        ptrs    _bhash,16
;
        dc.b    $82,'#>',$a0
        ptrs    _hashb,16
;
        dc.b    $84,'HOLD',$a0
        ptrs    _hold,18
;
        dc.b    $84,'SIGN',$a0
        ptrs    _sign,18
;
        dc.b    $81,'#'!$80
        ptrs    _hash,14
;
        dc.b    $82,'#S',$a0
        ptrs    _hashs,16
;
        dc.b    $82,'U.',$a0
        ptrs    _udot,16
;
        dc.b    $82,'I.',$a0
        ptrs    _dot,16
;
        dc.b    $85,'INPU','T'!$80
        vptrs   inp,18
;
        dc.b    $c6,'OUTPUT',$a0
        vptrs   outp,20
;
