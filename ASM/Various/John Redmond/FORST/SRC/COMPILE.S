; COMPILE.S: compilation words 20/07/90.
; Copyright <C> John Redmond 1989, 1990.
; Public domain for non-commercial use.
;
        section text
        even
;
;****************************************
;*                                      *
;* general entry for compilation code:  *
;*                                      *
;****************************************
;
ifval = 17
bval = 18
doval = 19
wval = 20
casval = 30
colval = 999
;
fstate: ds.l    1               ;compilation flag
codestart: ds.l 1               ;address of current code
ffa:    ds.l    1               ;address for flags & length
edge:   ds.w    1               ;just expanded a macro?
edges:  ds.l    2               ;active edges
;
call:   lea     mcro,a1
        tst.l   (a1)            ;macros allowed
        beq.s   mustcall        ;force call if not
call2:  bsr     flag
        tst.w   d2
        beq     mustcall        ;not a macro
        move.l  d2,d4
        swap    d4
        and.w   #maxsize,d4     ;max macro length
        lea     longest,a1
        move.l  (a1),d3
        cmp.w   d3,d4
        ble     inline
mustcall: lea   origin,a1
        move.l  (a1),d0
        cmp.l   d0,a0
        bcc     .mc5
        bsr     warn
.mc5:   push    a0              ;code address
        bsr     only_16
        bcs     toofar
        move.l  d1,(a6)         ;replace code address with distance
        push    #$6100          ;bsr
        bsr     _comma          ;opcode
        bsr     only_8
        bne.s   .c5             ;long call
        bsr     tocode          ;in a1
        pop     d0
        move.b  d0,-1(a1)       ;short call
        bra.s   callx
.c5:    bsr     _comma          ;branch value
callx:  bsr     edgeoff
        bsr     clrflag
        bsr     toptypoff
        rts
;
toofar: pop     d0
        sub.l   origin(pc),d0   ;convert code address to an offset
        push    d0
        push    #$203c          ;move.l #32bit,d0
        bsr     _comma          ;opcode
        bsr     _lcomma         ;immed value
        push    #$4eb50800      ;jsr 0(a5,d0.l)
        bsr     _lcomma
        bra     callx
;
warn:   movem.l d2/d4/a0,-(a7)
        lea     pocket,a0
        move.l  (a0),a0
        moveq.l #0,d0
        move.b  (a0)+,d0
        addq.l  #1,d0
        push    a0
        push    d0
        bsr     _type
        movem.l (a7)+,d2/d4/a0
        rts
;
;force compilation of inline code
;
nocall: bsr     tocode          ;force an expansion
        bra     copycode
;
expand: bsr     flag            ;update flag for current word
inline: bsr     tocode
        lea     edge,a2
        move.w  (a2),d5         ;just compiled any pushes?
        tst.w   d5              ;test for pushes
        beq.s   copycode        ;if not
        btst    #31,d2          ;expecting any edges?
        beq     copycode        ;no try at optimisation
        bsr.s   opt             ;otherwise optimise
;
copycode: subq.w #1,d4          ;ready for DBRA
        blt.s   .finis
.nclp:  move.w  (a0)+,(a1)+
        dbra    d4,.nclp
.finis: suba.l  a5,a1           ;offset of dictionary space
        lea     cp,a0
        move.l  a1,(a0)         ;update HERE
        bsr     doedge
        rts
;
tocode: lea     cp,a1
        move.l  (a1),a1
        adda.l  a5,a1           ;free code space
        rts
;
opt:    move.w  -(a1),d1        ;last word compiled
        cmp.w   d1,d2           ;useless push?
        beq.s   .optx
        and.w   #$ffc0,d1
        cmp.w   #$2d00,d1       ;was it a push?
        bne.s   .noopt
        move.w  (a0),d0         ;first word to compile
        and.w   #$f03f,d0
        cmp.w   #$201e,d0       ;is it a pop?
        bne.s   .noopt
        move.w  (a1),d0         ;old push
        and.w   #$f03f,d0       ;mask out dest field
        move.w  (a0),d1         ;new pop
        and.w   #$0fc0,d1       ;get new dest field
        or.w    d1,d0           ;merge into old push
        move.w  d0,(a1)+        ;put it back
.optx:  addq.l  #2,a0           ;push and pop not needed
        subq.w  #1,d4           ;less words to copy
        cmp.w   #99,d5
        beq.s   .opty           ;previous word was a test
        subq.w  #1,d5           ;decrease # edges
        beq     .opty           ;all edges used up
        btst    #30,d2          ;set if 2 edges expected
        beq.s   .opty           ;no further optimization
        bsr     ptchpush        ;patch the lower edge
        moveq   #0,d5           ;no more valid edges
        addq.l  #2,a0           ;yet one less word to compile
        subq.w  #1,d4
        rts
.noopt: addq.l  #2,a1
.opty:  rts
;
;update macro flag for word being compiled:
;
flag:   lea     fstate,a4
        tst.w   d2              ;latest flag
        beq.s   .fl5            ;force change if zero
        move.w  2(a4),d3        ;current flag state
        beq.s   .no
        cmp.w   #-2,d3          ;flag not yet altered?
        bne.s   .no             ;quit if already altered
.fl5:   move.l  d2,d0           ;save macro specs
        and.l   #$c000ffff,d2   ;isolate the edges expected
        move.l  d2,(a4)         ;flag state of first word in definition
        move.l  d0,d2           ;restore macro specs
.no:    tst.w   d2
        rts                     ;return flags for d2
;
kpflag: move.l  #$ffff,d2       ;fake true macro flag
        bsr.s   flag
        rts
;
clrflag: lea    fstate,a0
        clr.l   (a0)
        rts
;
;check whether address is within 32k (16 bits signed relative):
;
only_16: bsr    _here
        pop     d0              ;free dictionary space
        addq.l  #2,d0
        move.l  (a6),d1         ;copy code address
        sub.l   d0,d1           ;how far?
        cmp.l   #-32768,d1
        rts
;
;check whether displacement on stack is within 8 bits signed relative:
;
only_8: move.l  (a6),d1         ;copy displacement
        ext.w   d1
        cmp.w   2(a6),d1
        rts
;
; manipulate the edge flag to indicate how many valid edges:
;
doedge: bsr     toptypoff
        btst    #29,d2          ;returning an edge?
        beq     edgeoff
        btst    #28,d2          ;just done a DUP or SWAP?
        bne     twoon
        btst    #27,d2          ;just done a test?
        bne     doedge3
        btst    #26,d2
        bne     plusedge        ;just done SP@ or RP@?
        beq     oneon           ;force just one new edge
doedge3: move.w #99,d5          ;99 is the test flag
doedge4: lea    edge,a0
        move.w  d5,(a0)         ;update the edge
        lea     edges,a0
        move.l  4(a0),(a0)      ;shuffle left
        bsr     tocode          ;address in a1
        suba.l  #2,a1           ;^ latest push
        move.l  a1,4(a0)
        rts
;
oneon:  moveq   #1,d5           ;force one edge
        bra     doedge4
;
twoon:  lea     edges,a0        ;force two edges
        bsr     tocode          ;address in a1
        suba.l  #2,a1           ;^ latest push
        move.l  a1,4(a0)
        suba.l  #2,a1
        move.l  a1,(a0)         ;^ previous push
        lea     edge,a0
        move.w  #2,(a0)         ;update the edge
        bsr     toptypoff
        rts
;
edgeoff: lea    edge,a0
        clr.w   (a0)            ;no valid edge
        bsr     toptypoff
        rts
;
plusedge: lea   edge,a0
        move.w  (a0),d5
        addq.w  #1,d5
        bra     doedge4
;
toptypoff: lea  toptyp,a0
        clr.w   (a0)
        rts
;
;patch push in second edge to move to register d1:
;
ptchpush: lea   edges,a3
        move.l  (a3),a3         ;^ previous push
        move.w  (a3),d0
        and.w   #$f03f,d0
        or.w    #$0200,d0       ;'move to d1'
        move.w  d0,(a3)         ;patch code back
        rts
;
;system compilation utilities
;
comphead: bsr   _ifcomp
        bsr     _head           ;get cfa
        pop     a0
        rts
;
setstart: lea   cp,a0
        move.l  (a0),d0
        add.l   a5,d0
        lea     codestart,a0
        move.l  d0,(a0)
        rts
;
setffa: push    a0              ;ffa is in d0
        lea     ffa,a0
        move.l  d0,(a0) 
        pop     a0
        rts
;
virgin: lea     mcro,a1
        lea     fstate,a0
        move.l  #$fffe,d0       ;virgin flag state
        and.l   (a1),d0         ;only if macros allowed
        move.l  d0,(a0)
        rts
;       
fillffa: clr.l  d0              ;start with zero ffa
        lea     edge,a0
        move.w  (a0),d0
        beq.s   .ff5
        cmp.w   #1,d0
        bne.s   .ff1
        move.w  #$2000,d0       ;one edge returned
        bra.s   .ff4
.ff1:   cmp.w   #99,d0
        bne.s   .ff2
        move.w  #$2800,d0       ;a test returned
        bra.s   .ff4
.ff2:   move.w  #$3000,d0       ;two edges returned
.ff4:   swap    d0
.ff5:   lea     fstate,a1
        or.l    (a1),d0         ;merge edges expected
        lea     ffa,a0
        move.l  (a0),a0         ;where to store flags & length
        move.l  d0,(a0)         ;do the store
;
        push    a0              ;still need the address
        bsr     _here
        pop     d0
        lea     codestart,a0
        sub.l   (a0),d0
        subq.l  #2,d0           ;ignore RTS
        asr.l   #1,d0           ;convert to words
        and.w   #maxsize,d0     ;limit it to maxsize
        pop     a0              ;address of ffa
        or.w    d0,(a0)         ;merge in the code length
        bsr     edgeoff
        rts
;
colonbody: lea  hp,a0
        lea     headmark,a1
        move.l  (a0),(a1)       ;in case of error
        bsr     header
        lea     cp,a0
        push    (a0)
        move.l  (a6),-(a6)      ;two copies
        bsr     _there
        pop     d0
        subq.l  #4,d0
        bsr     setffa          ;where to patch flags and length
        bsr     _hcomma         ;offset ^code in cfa
        bsr     _hcomma         ;offset ^code flag in pfa
        bsr     dolength        ;add length field to header
        bsr     setstart        ;mark start of compiled code
        rts
;
;*******************************;
;*  User                        ;
;*  Compilation utilities       ;
;*                              ;
;*******************************;
;
_laddat: pop    a0
        pop     d1
        add.l   d1,(a0)
        rts
;
_ccomma: lea    cp,a0
        move.l  (a0),d0
        addq.l  #1,(a0)
        pop     d1
        move.b  d1,(a5,d0.l)
        rts
;

_comma: bsr     _align
        lea     cp,a0
        move.l  (a0),d0
        addq.l  #2,(a0)
        pop     d1
        move.w  d1,(a5,d0.l)
        rts
;
_lcomma: bsr    _align
        lea     cp,a0
        move.l  (a0),a1
        addq.l  #4,(a0)
        adda.l  a5,a1
        pop     (a1)
        rts
;
_hcomma: bsr    _align
        lea     hp,a0
        move.l  (a0),a1
        addq.l  #4,(a0)
        adda.l  a5,a1
        pop     (a1)
        rts
;
_allot: bsr     _even
        lea     cp,a0
        push    a0
        bsr     _laddat
        rts
;
_hallot: bsr    _even
        lea     hp,a0
        push    a0
        bsr     _laddat
        rts
;
_align: bsr     _here
        pop     d0
        btst    #0,d0
        beq     .alx
        push    #1
        bsr     _allot
.alx:   rts
;
_halign: bsr    _there
        pop     d0
        btst    #0,d0
        beq     .alx
        push    #1
        bsr     _hallot
.alx:   rts
;
_even:  pop     d0
        move.l  d0,d1
        and.l   #1,d1
        add.l   d1,d0
        push    d0
        rts
;
name:   push    #32
        bsr     _word
        move.l  (a6),a0         ;copy ^name
        move.b  (a0),d0
        beq     namerror
        cmp.b   #31,d0
        bgt     lenerror
        bsr     upper
        rts
;
upper:  move.l  (a6),a0         ;copy ^name
        clr.w   d1
        move.b  (a0)+,d1        ;get length
        sub.w   #1,d1
.uplp:  move.b  (a0),d0
        cmp.b   #$61,d0
        blt     .up5
        cmp.b   #$7a,d0
        bgt     .up5
        and.b   #$5f,d0
.up5:   move.b  d0,(a0)+
        dbra    d1,.uplp
        rts
;
;***************************************;
;*                                      ;
;* Higher-level compilation words       ;
;*                                      ;
;***************************************;
;
_literal: bsr   _ifcomp
        bsr.s   bliteral
        push    #$2d00          ;push d0
        bsr     _comma
        bsr     plusedge
;       bsr     toptypoff
        bsr     kpflag
        rts
;
bliteral: move.l (a6),d0        ;copy literal value
        beq.s   .lit2           ;easy if it is zero
        move.l  d0,d1           ;a test copy
        ext.w   d1
        ext.l   d1              ;sign extend 8 bits to 32
        cmp.l   d0,d1
        bne.s   .lit5           ;longer than 8 bits
        andi.l  #$ff,d0         ;mask off high bits
.lit2:  ori.l   #$7000,d0       ;moveq #XX,d0 opcode
        move.l  d0,(a6)         ;overwrite literal value
        bsr     _comma
        moveq.l #-1,d0          ;short literal
        bra.s   .litx
.lit5:  push    #$203c          ;move.l #32-bit,d0
        bsr     _comma
        bsr     _lcomma         ;immediate value
        moveq.l #-2,d0          ;long literal
.litx:  lea     toptyp,a0
        move.w  d0,(a0)
        rts
;
_const: push    4(a0)           ;constant value in pfa
        bsr     stateat
        beq     .cox
        bsr     _literal
.cox:   rts
;
_def:   move.l  4(a0),a0        ;pfa has offset of ^variable address
        adda.l  a5,a0
        push    a0
        bsr     stateat
        beq     dodef
        bsr     bvar
        push    #$2010          ;move.l (a0),d0
        bsr     _comma
        push    #$4eb50800      ;jsr (a5,d0.l)
        bsr     _lcomma
        bsr     toptypoff
        bsr     kpflag
        bsr     edgeoff
        rts
dodef:  pop     a0
        move.l  (a0),d0
        jsr     (a5,d0.l)
        rts
;
_vect:  move.l  4(a0),a0        ;^^code
        adda.l  a5,a0
        push    a0
        bsr     stateat
        beq     dodef
        pop     a0
        move.l  4(a0),d2        ;flags and length
        move.l  (a0),a0
        adda.l  a5,a0           ;code address
        bsr     call
        rts
;
_var:   move.l  4(a0),a0        ;pfa has offset of ^variable address
        adda.l  a5,a0
        push    a0              ;code address
        bsr     stateat
        beq.s   direct          ;execution mode
pvar:   bsr.s   bvar
        push    #$2d08          ;'push a0'
        bsr     _comma
        moveq.l #1,d0           ;return non-zero
        bsr     plusedge
direct: rts                     ;return zero if not compiling
;
bvar:   bsr     only_16         ;displacement returned in d1
        bge     .dolea          ;lea if close enough
        pop     a0              ;else get ready for offset reference
        suba.l  a5,a0
        push    a0              ;address offset
        push    #$217c          ;movea.l #32-bit,a0
        bsr     _comma
        bsr     _lcomma         ;32-bit immediate value
        push    #$d1cd          ;adda.l a5,a0
        bsr     _comma
        moveq.l #-4,d0          ;long address
        bra.s   var5
.dolea: move.l  d1,(a6)         ;overwrite address with displacement
        push    #$41fa
        bsr     _comma          ;lea
        bsr     _comma          ;displacement
        moveq.l #-3,d0          ;short address
var5:   lea     toptyp,a0
        move.w  d0,(a0)
;       bsr     toptypoff
        bsr     clrflag
bvarx:  rts
;
_bdoes: move.l  (a7)+,-(a6)     ;get return address
        bsr     castore         ;patch into cfa of generic word
        bsr     _immediate      ;make generic word immediate
        rts
;
xplace: move.l  4(a0),a0        ;pfa has offset of ^variable address
        adda.l  a5,a0
        push    a0
        push    #-1
        bsr     pushin          ;read input from text
        pop     a0
        moveq.l #0,d0
        move.b  (a0)+,d0
        lea     hmac,a1
        move.l  d0,(a1)         ;text length
        lea     macptr,a1
        move.l  a0,(a1)         ;text address
        lea     macin,a1
        clr.l   (a1)            ;zero pointer offset
        rts
;
xdoes:  bsr     _var            ;used during action of generic word
        beq.s   .xd5            ;normal execution mode
        move.l  (a7)+,a1        ;return address = compilation record
        move.l  (a1)+,a0        ;get code offset from compilation record
        move.l  (a1)+,d2        ;and the length and flags
        adda.l  a5,a0           ;point to code
        bsr     call            ;call it
        rts
.xd5:   move.l  (a7)+,a1
        move.l  (a1),d0
        jmp     (a5,d0.l)       ;skip over compilation record
        rts
;
_does:  lea     _bdoes,a0       ;definition of defining word
        bsr     mustcall        ;defining word calls it
        lea     xdoes,a0
        bsr     mustcall        ;defined word calls it
        lea     cp,a0
        move.l  (a0),d0
        lea     hp,a1
        move.l  (a1),a1
        adda.l  a5,a1           ;point to end of header
        move.l  d0,-6(a1)       ;pfa now points to compilation record
        addq.l  #8,d0           ;for now, point past compilation record
        push    d0
        subq.l  #4,d0           ;point back into compilation record
        add.l   a5,d0           ;make it a real address
        bsr     setffa          ;ffa for later patching
        bsr     _lcomma         ;code pointer in compilation record
        push    #0              ;save it for _semicolon
        bsr     _lcomma         ;dummy length and flags
        bsr     setstart        ;new start for code
        bsr     virgin          ;virgin flag state
        bsr     edgeoff
        rts
;
_recurse: lea codestart,a0
        move.l  (a0),a0
        bsr     mustcall        ;latest definition calls itself
        rts
;
_bra:   lea     state,a0
        move.l  #0,(a0)
        rts
;
_ket:   lea     state,a0
        move.l  #-1,(a0)
        rts
;
_create: bsr    header
        lea     _var,a0
        bsr     do_ptrs
        bsr     dolength
        bsr     _immediate
        rts
;
_variable: bsr  _create
        push    #0
        bsr     _lcomma
        rts
;
_constant: bsr  header
        lea     _const,a0
        suba.l  a5,a0           ;convert to offset
        push    a0
        bsr     _hcomma         ;code pointer in cfa
        bsr     _hcomma         ;constant value in pfa
        bsr     dolength
        bsr     _immediate
        rts
;
_address: bsr   header
        lea     _var,a0
        suba.l  a5,a0           ;convert to offset
        push    a0
        bsr     _hcomma         ;code pointer in cfa
        pop     d0
        sub.l   a5,d0           ;convert address to offset
        push    d0
        bsr     _hcomma         ;constant value in pfa
        bsr     dolength
        bsr     _immediate
        rts
;
_defer: bsr     header
        lea     _def,a0
def5:   suba.l  a5,a0           ;convert to offset
        push    a0
        bsr     _hcomma         ;code pointer in cfa
        lea     cp,a0
        push    (a0)
        bsr     _hcomma         ;offset ^value in pfa
        lea     _noop,a0        ;point to noop
        sub.l   a5,a0           ;convert address to offset
        push    a0
        bsr     _lcomma         ;code offset in compilation record
        push    #0              ;dummy length and flag field
        bsr     _lcomma
        bsr     dolength
        bsr     _immediate
        rts
;
_vector: bsr    header
        lea     _vect,a0
        bra     def5
;
_is:    bsr     _head
        bsr     stateat
        beq     .is7            ;no compilation
        pop     -(a7)           ;header of vector word
        pop     a0              ;header of vectored word
        push    -4(a0)          ;flags and length
        move.l  4(a0),a0        ;code offset from pfa
        adda.l  a5,a0
        push    a0              ;code address
        bsr     bvar            ;'load address to a0'
        bsr     bliteral        ;'flags and length to d0'
        push    #$91cd2208      ;'suba.l a5,a0 move.l a0,d1'
        bsr     _lcomma
        move.l  (a7)+,a1        ;address of vector word
        move.l  4(a1),a1
        adda.l  a5,a1           ;^data fields
        push    a1
        bsr     bvar            ;'dest address to a0'
        push    #$20c12080      ;'move.l d1,(a0)+,move.l d0,(a0)'
        bsr     _lcomma
        rts
.is7:   pop     a1              ;header of vector word
        move.l  4(a1),a1
        adda.l  a5,a1           ;^data fields
        pop     a0              ;header of vectored word
        move.l  -4(a0),4(a1)    ;copy flags and length
        move.l  4(a0),(a1)      ;code offset
        rts
;
_file:  bsr     _create
        push    #24
        bsr     _allot
        rts
;
_colon: bsr     clrlve          ;clear leave stack
        bsr     edgeoff
        bsr     colonbody
        bsr     _ket
        bsr     _smudge
        bsr     virgin          ;initialise push flag
        push    #colval         ;balance marker
        rts
;
_semicolon: bsr _ifcomp
        pop     d0
        cmp.l   #colval,d0
        bne     strerror
        push    #$4e75          ;RTS
        bsr     _comma
        bsr     _bra
        bsr     _smudge
        bsr     fillffa
        rts
;
_dotq:  bsr     _q
        lea     _type,a0
        bsr     mustcall        ;force a call
        rts
;
_abortq: bsr    _if
        bsr     _dotq
        lea     _abort,a0
        bsr     mustcall        ;force a call
        bsr     _then
        rts
;
_q:     bsr     _ifcomp
        lea     _bq,a0
        bsr     mustcall        ;force a call
        bsr     _qcomma
        rts
;
_qcomma: push   #34             ;"
qc2:    bsr     _word           ;get string with this delimiter
        move.l  (a6),a0         ;copy ^name
        clr.l   d0
        move.b  (a0),d0         ;get string length
        beq     namerror
        addq.l  #2,d0
        clr.b   -1(a0,d0.w)     ;null at end of string
        move.l  d0,-(a7)
        bsr     _here           ;destination
        move.l  (a7),-(a6)      ;length
        bsr     _cmove
        move.l  (a7)+,-(a6)     ;length
        bsr     _allot
        bsr     _align
        rts
;
_bq:    move.l  (a7)+,a0        ;^string in a0
        clr.l   d0
        move.b  (a0)+,d0        ;string length
        movem.l d0/a0,-(a6)     ;address and length
        add.l   a0,d0           ;end of string
        addq.l  #1,d0           ;bump past null
        move.l  d0,d1
        andi.l  #1,d1
        add.l   d1,d0           ;adjust to even address
        move.l  d0,-(a7)        ;return address
        rts
;
_rplace: bsr    _ifexec 
        bsr     header
        lea     xplace,a0
        bsr     do_ptrs
        bsr     dolength
        bsr     _immediate
        lea	delim,a0
        push    (a0)		;delimiter has been set
        bsr     qc2
        rts
;
_ifcomp: bsr    stateat
        bne.s   .ifcx
        lea     stterr,a0
        bra     _error
.ifcx:  rts
;
_ifexec: bsr    stateat
        beq.s   .ifex
        lea     exerr,a0
        bra     _error
.ifex:  rts
;
; _compile is used to define a defining word which will compile code
; as it is at the time of definition of the DEFINING word
;
_compile: bsr   comphead
        bsr     special
        bne     .c5
        move.l  4(a0),a0        ;indirection needed
        adda.l  a5,a0
        push    4(a0)           ;length and macro flag if deferred
        bra.s   .c6
.c5:    push    -4(a0)          ;normal length and macro flag
.c6:    move.l  (a0),a0
        adda.l  a5,a0
        push    a0              ;code address
        bsr     bvar            ;'load code address into a0'
        push    #$243c
        bsr     _comma          ;'load immed val of length & flag
        bsr     _lcomma         ;into d2'
        lea     call,a0         ;code for child word
        bsr     mustcall        ;'call or expand in child word'
        rts
;
;_delay is used in a definition of a defining word.  It will compile
;the code to to used by @execute when the defining word is used.
_delay: bsr     comphead
        bsr     special
        bne     deferror        ;cannot delay normal words
        move.l  4(a0),a0        ;indirection needed
        adda.l  a5,a0
        push    a0              ;code address
        bsr     bvar            ;'load comp record address into a0'
        lea     delaycall,a0    ;code for child word
        bsr     mustcall        ;'call or expand in child word'
        rts
;
delaycall: move.l 4(a0),d2
        move.l  (a0),a0
        adda.l  a5,a0
        bsr     call
        rts
;
special: move.l (a0),d0
        add.l   a5,d0
        lea     _vect,a1
        cmp.l   d0,a1           ;is it a vectored word?
        beq     .sx
        lea     _def,a1
        cmp.l   d0,a1
.sx:    rts                     ;return zero if OK
;
_call:  bsr     comphead
        move.l  (a0),a0
        adda.l  a5,a0
        bsr     mustcall
        rts
;
_btick: bsr     _ifcomp
        bsr     _tick           ;fetch address
        bsr     pvar            ;code to put it onto stack
        rts
;
_bcompile: bsr  comphead
        move.l  (a0),d0
        cmp.l   4(a0),d0        ;equal in normal words
        beq     .bc5
        bra     deferror
.bc5:   move.l  -4(a0),d2       ;length and macro flag
        move.l  (a0),a0
        adda.l  a5,a0           ;code address
        bsr     call
        rts
;
_stcsp: bsr     _spat
        lea     csp,a0
        pop     (a0)
        rts
;
_pairs: bsr     _equal
        pop     d0
        bne     .pairsx
        lea     strerr,a0
        bra     _error
.pairsx: rts
;
;*********************************************************;
;                                                        ;
; Low-level words for defining logical structures        ;
;                                                        ;
;*********************************************************;
;

_fmark: bsr     _here
        push    #0
        bsr     _comma
        bsr     edgeoff
        rts
;
_bmark: bsr     _here
        bsr     edgeoff
        rts
;
_fresolve:
        bsr     _here
        bsr     _over
        bsr     _sub
        bsr     _swap
        bsr     _wstore
        bsr     edgeoff
        rts
;
_bresolve:
        bsr     _here
        bsr     _sub
        bsr     only_8
        bne     .br5
        bsr     tocode          ;returned in a1
        pop     d0
        move.b  d0,-1(a1)       ;short branch
        bra.s   .brx
.br5:   bsr     _comma
.brx:   bsr     edgeoff
        rts
;
_bif:   pop     d0
        dc.w    $6700           ;beq
        rts
;
doif:   move.w  edge(pc),d0
        cmp.w   #99,d0
        bne     .di5            ;last instruct not a test
        bsr     tocode          ;address in a1
        subq.l  #8,a1
        move.w  (a1),d0
        andi.w  #$0f00,d0
        eori.w  #$0100,d0       ;reverse the logic
        ori.w   #$6000,d0
        move.w  d0,(a1)+        ;replace as a branch
        suba.l  a5,a1
        lea     cp,a0
        move.l  a1,(a0)         ;correct HERE
        bsr     edgeoff
        rts
.di5:   lea     _bif,a0         ;start of code
        move.l  #exp_d0,d2      ;macro flag & one edge
        moveq   #2,d4           ;length
        bsr     inline
        rts
;
clrlve: lea     lstkptr,a0
        move.l  a0,(a0)
        rts
;
pushlve: lea    lstkptr,a1
        move.l  (a1),a0
        subq.l  #4,a0
        pop     (a0)
        move.l  a0,(a1)
        rts
;
poplve: lea     lstkptr,a1
        move.l  (a1),a0
        push    (a0)
        addq.l  #4,a0
        move.l  a0,(a1)
        rts
;
reslve: bsr     poplve          ;value on leave stack
        move.l  (a6),d0
        beq     .reslx
        bsr     _fresolve
        bra     reslve
.reslx: addq.l  #4,a6           ;discard zero
        bsr     edgeoff
        rts
;
_bdo:   move.l  (a7)+,a0
        lea     lpstkptr,a1     ;loop stack pointer
        move.l  (a1),a2
        movem.l d6-d7,-(a2)
        move.l  a2,(a1)         ;keep altered stack pointer
        movem.l (a6)+,d6-d7
        add.l   #$80000000,d7
        sub.l   d7,d6
        cmp.l   #$80000000,d6   ;indexes equal?
        jmp     (a0)
;
_bunloop: lea   lpstkptr,a1
        move.l  (a1),a2
        movem.l (a2)+,d6-d7     ;pop loop stack
        move.l  a2,(a1)
        rts
;
bloop:  addq.l  #1,d6
        dc.w    $6800           ;BVC xxxx
        rts
;
bploop: pop     d0
        add.l   d0,d6
        dc.w    $6800           ;BVC xxxx
        rts
;
bi:     move.l  d6,d0
        add.l   d7,d0
        push    d0
        rts
;
bip:    move.l  d7,d0
        add.l   #$80000000,d0
        push    d0
        rts
;
bj:     lea     lpstkptr,a0
        move.l  (a0),a0
        push    (a0)
        rts
;
bof:    pop     d0
        cmp.l   d0,d6
        dc.w    $6600
;
;***************************************;
;*                                      ;
;* User words for logical structures    ;
;*                                      ;
;***************************************;
;
_case:  bsr     _ifcomp
        push    #0
        bsr     pushlve         ;zero marker
        push    #$2f062c1e      ;move.l d6,-(a7) pop d6
        bsr     _lcomma
        push    #casval
        bsr     edgeoff
        rts
;
_endcase: bsr   _ifcomp
        pop     d0
        cmp.l   #casval,d0
        bne     strerror
        bsr     reslve
        push    #$2c1f          ;move.l (a7)+,d6
        bsr     _comma
        rts
;       
_of:    move.l  (a6),d0
        cmp.l   #casval,d0
        bne     strerror
        lea     bof,a0
        move.l  #exp_d0,d2      ;one edge, 'pop d0' required
        move.w  #3,d4
        bsr     inline
        bsr.s   if2
        rts
;
_endof: bsr     _ifcomp
        pop     d0
        cmp.l   #ifval,d0
        bne     strerror
        bsr     lv2
        bsr     _fresolve
        rts
;
_if:    bsr     _ifcomp
        bsr     doif
if2:    bsr     _fmark
        push    #ifval
        rts
;
_then:  bsr     _ifcomp
        pop     d0
        cmp.l   #ifval,d0
        bne     strerror
        bsr     _fresolve
        rts
;
_else:  bsr     _ifcomp
        pop     d0
        cmp.l   #ifval,d0
        bne     strerror
        push    #$6000          ;bra
        bsr     _comma 
        bsr     _fmark
        bsr     _swap
        bsr     _fresolve
        push    #ifval
        rts
;
_begin: bsr     _ifcomp
        push    #0
        bsr     pushlve         ;zero marker
        bsr     _bmark
        push    #bval
        rts
;
_until: bsr     _ifcomp
        pop     d0
        cmp.l   #bval,d0
        bne     strerror
        bsr     doif
        bsr     _bresolve
        bsr     reslve
        rts
;
_again: bsr     _ifcomp
        pop     d0
        cmp.l   #bval,d0
        bne     strerror
        push    #$6000
        bsr     _comma
        bsr     _bresolve
        bsr     reslve
        rts
;
_while: bsr     _ifcomp
        pop     d0
        cmp.l   #bval,d0
        bne     strerror
        bsr     doif
        bsr     _fmark
        push    #wval
        rts
;
_repeat: bsr    _ifcomp
        pop     d0
        cmp.l   #wval,d0
        bne     strerror
        push    #$6000          ;bra
        bsr     _comma
        bsr     _swap
        bsr     _bresolve
        bsr     _fresolve
        bsr     reslve
        rts
;
_leave: bsr     _ifcomp
lv2:    push    #$6000          ;bra
        bsr     _comma
        bsr     _fmark
        bsr     pushlve
        rts
;
_exit:  push    #$4e75          ;rts
        bsr     _comma
        rts
;
_do:    bsr     _ifcomp
        push    #0
        bsr     pushlve         ;zero marker
        lea     _bdo,a0
        bsr     mustcall
        push    #$6700
        bsr     _comma
        bsr     _fmark          ;beq XXXX
        bsr     _bmark          ;for backward branch
        push    #doval
        rts
;
_loop:  bsr     _ifcomp
        pop     d0
        cmp.l   #doval,d0
        bne     strerror
        lea     bloop,a0
        moveq   #2,d4           ;length
        bsr     nocall
lp5:    bsr     _bresolve       ;<resolve
        bsr     reslve
        bsr     _fresolve       ;>resolve if indexes equal
        lea     _bunloop,a0
        bsr     mustcall
        bsr     edgeoff
        rts
;
_ploop: bsr     _ifcomp
        pop     d0
        cmp.l   #doval,d0
        bne     strerror
        lea     bploop,a0       ;start of inline code
        move.l  #exp_d0,d2      ;look for one edge
        move.w  #3,d4
        bsr     inline
        bra     lp5
;
_i:     bsr     _ifcomp
        lea     bi,a0
        move.l  #ret1_any,d2
        moveq   #3,d4           ;length
        bsr     inline
        rts
;
_ip:    bsr     _ifcomp
        move.l  #ret1_any,d2
        lea     bip,a0
        moveq   #5,d4           ;length
        bsr     inline
        rts
;
_j:     bsr     _ifcomp
        lea     bj,a0
        bsr     mustcall
        rts
;
        section data
        even
;
        dc.b    $c6,'MACROS',$a0
        ptrs    _macros,20
;
        dc.b    $c5,'CALL','S'!$80
        ptrs    _calls,18
;
        dc.b    $c1,'I'!$80
        ptrs    _i,14
;
        dc.b    $c1,'J'!$80
        ptrs    _j,14
;
        dc.b    $c2,"I'",$a0
        ptrs    _ip,16
;
        dc.b    $c2,'R>',$a0
        ptrs    _rgt,16
;
        dc.b    $c2,'>R',$a0
        ptrs    _gtr,16
;
        dc.b    $c2,'R@',$a0
        ptrs    _rat,16
;
        dc.b    $c1,'['!$80
        ptrs    _bra,14
;
        dc.b    $c1,']'!$80
        ptrs    _ket,14
;
        dc.b    $84,'!CSP',$a0
        ptrs    _stcsp,18
;
        dc.b    $86,'?PAIRS',$a0
        ptrs    _pairs,20
;
        dc.b    $85,'>MAR','K'!$80
        ptrs    _fmark,18
;
        dc.b    $88,'>RESOLVE',$a0
        ptrs    _fresolve,22
;
        dc.b    $85,'<MAR','K'!$80
        ptrs    _bmark,18
;
        dc.b    $88,'<RESOLVE',$a0
        ptrs    _bresolve,22
;
        dc.b    $85,'?COM','P'!$80
        ptrs    _ifcomp,18
;
        dc.b    $85,'?EXE','C'!$80
        ptrs    _ifexec,18
;
        dc.b    $c3,"['","]"!$80
        ptrs    _btick,16
;
        dc.b    $c7,'LITERA','L'!$80
        ptrs    _literal,20
;
        dc.b    $c6,'SMUDGE',$a0
        ptrs    _smudge,20
;
        dc.b    $c9,'IMMEDIAT','E'!$80
        ptrs    _immediate,22
;
        dc.b    $85,'ALLO','T'!$80
        ptrs    _allot,18
;
        dc.b    $84,'EVEN',$a0
        ptrs    _even,18
;
        dc.b    $85,'ALIG','N'!$80
        ptrs    _align,18
;
        dc.b    $81,','!$80
        ptrs    _lcomma,14
;
        dc.b    $82,'W,',$a0
        ptrs    _comma,16
;
        dc.b    $82,'C,',$a0
        ptrs    _ccomma,16
;
        dc.b    $82,'",',$a0
        ptrs    _qcomma,16
;
        dc.b    $81,':'!$80
        ptrs    _colon,14
;
        dc.b    $c1,';'!$80
        ptrs    _semicolon,14
;
        dc.b    $c2,'IF',$a0
        ptrs    _if,16
;
        dc.b    $c4,'ELSE',$a0
        ptrs    _else,18
;
        dc.b    $c4,'THEN',$a0
        ptrs    _then,18
;
        dc.b    $c2,'DO',$a0
        ptrs    _do,16
;
        dc.b    $c4,'LOOP',$a0
        ptrs    _loop,18
;
        dc.b    $c5,'+LOO','P'!$80
        ptrs    _ploop,18
;
        dc.b    $c5,'LEAV','E'!$80
        ptrs    _leave,18
;
        dc.b    $c4,'EXIT',$a0
        ptrs    _exit,18
;
        dc.b    $c5,'BEGI','N'!$80
        ptrs    _begin,18
;
        dc.b    $c5,'UNTI','L'!$80
        ptrs    _until,18
;
        dc.b    $c5,'AGAI','N'!$80
        ptrs    _again,18
;
        dc.b    $c5,'WHIL','E'!$80
        ptrs    _while,18
;
        dc.b    $c6,'REPEAT',$a0
        ptrs    _repeat,20
;
        dc.b    $c4,'CASE',$a0
        ptrs    _case,18
;
        dc.b    $c7,'ENDCAS','E'!$80
        ptrs    _endcase,20
;
        dc.b    $c2,'OF',$a0
        ptrs    _of,16
;
        dc.b    $c5,'ENDO','F'!$80
        ptrs    _endof,18
;
        dc.b    $86,'CREATE',$a0
        ptrs    _create,20
;
        dc.b    $c5,'DOES','>'!$80
        ptrs    _does,18
;
        dc.b    $87,'REPLAC','E'!$80
        ptrs    _rplace,20
;
        dc.b    $c6,'ABORT"',$a0
        ptrs    _abortq,20
;
        dc.b    $c2,46,34,$a0
        ptrs    _dotq,16
;
        dc.b    $c1,34!$80
        ptrs    _q,14
;
        dc.b    $88,'VARIABLE',$A0
        ptrs    _variable,22
;
        dc.b    $88,'CONSTANT',$a0
        ptrs    _constant,22
;
        dc.b    $87,'ADDRES','S'!$80
        ptrs    _address,20
;
        dc.b    $c5,'DEFE','R'!$80
        ptrs    _defer,18
;
        dc.b    $c2,'IS',$a0
        ptrs    _is,16
;
        dc.b    $c7,'COMPIL','E'!$80
        ptrs    _compile,20
;
        dc.b    $c9,'[COMPILE',']'!$80
        ptrs    _bcompile,22
;
        dc.b    $c5,'DELA','Y'!$80
        ptrs    _delay,18
;
        dc.b    $c4,'CALL',$a0
        ptrs    _call,18
;       
        dc.b    $c6,'VECTOR',$a0
        ptrs    _vector,20
;
        dc.b    $84,'FILE',$a0
        ptrs    _file,18
;
        dc.b    $c7,'RECURS','E'!$80
        ptrs    _recurse,20
;
        dc.b    $87,'EXECUT','E'!$80
        ptrs    _execute,20
;
        dc.b    $88,'@EXECUTE',$a0
        ptrs    _atexec,22
;
