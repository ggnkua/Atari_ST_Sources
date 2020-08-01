; EXTRAS: compilation extensions 22/6/90
; Copyright <C> John Redmond 1989,1990
; Public domain for non-commercial use.
;
        section text
        even
;
maxregs = 6                     ;# register variables allowed
perreg = 8                      ;bytes per register in lookup table
maclen = 31                     ;mask for largest macro
;
; system variables and pointers
;
largnumb: dc.w  0               ;# local arguments
regnumb: dc.w   0               ;# register variables
regargs: dc.w   0               ;# register arguments
frdepth: dc.l   0               ;depth of stack frame
argdpth: dc.l   0               ;base of local args
regoffs: dc.l   0               ;^ regvals
rargptr: dc.l   0               ;^ reg arg params
pushptr: dc.l   regpush
pushval: dc.l   0
toptyp: dc.w    0               ;3=local,2=addrreg,1=datreg on top,else 0
adjust: dc.w    0
lastused: dc.l  1               ;offset (for locals) or last register params
;
locops: offs    dofrom
        offs    doaddr
        offs    doto
        offs    doaddto
        offs    dofor
;
regops: offs    regfrom
        offs    strerror        ;no address for a register
        offs    regto
        offs    regaddto
        offs    regfor
;
;pop/push/add opcodes for all registers:
;
;specialist address registers:
         dc.l   $245e2d0a,$d5c00000                     ;a2
         dc.l   $205e2d08,$d1c00000,$225e2d09,$d3c00000 ;a0,a1
         dc.l   $285e2d0c,$d9c00000,$2a5e2d0d,$dbc00000 ;a4,a5
         dc.l   $2c5e2d0e,$ddc00000,$2e5e2d0f,$dfc00000 ;a6,a7
;
;user registers:
regvals: dc.l   $265e2d0b,$d7c00000,$245e2d0a,$d5c00000 ;a3,a2
         dc.l   $2a1e2d05,$da800000,$281e2d04,$d8800000 ;d5,d4
         dc.l   $261e2d03,$d6800000,$241e2d02,$d4800000 ;d3,d2
;
;specialist data registers:
         dc.l   $201e2d00,$d0800000,$221e2d01,$d2800000 ;d0,d1
         dc.l   $2c1e2d06,$dc800000,$2e1e2d07,$de800000 ;d6,d7
         dc.l   $241e2d02,$d4800000                     ;d2
;
;auto preserving of user registers(a3,a2,d5,d4,d3,d2):
regpush: dc.l   $00000000,$08000010,$0c000030,$0c200430
         dc.l   $0c300c30,$0c381c30,$0c3c3c30           ;popm/pushm
;
_loc:   push    a0
        bsr     _ifcomp
        bsr     toptypoff
        pop     a0
        lea     locops,a1
loc2:   push    4(a0)           ;value in pfa
        lea     lastused,a2
        move.l  (a6),(a2)       ;save this as the local offset
        move.w  store(pc),d1
        move.l  (a1,d1.w),d1
        jmp     (a5,d1.l)
;
_reg:   push    a0
        bsr     _ifcomp
        pop     a0
        move.l  4(a0),d0
        push    d0              ;for vectored subroutines
        lea     regvals,a1
        lea     lastused,a2
        move.l  (a1,d0.l),(a2)
        lea     regops,a1
        move.w  store(pc),d1
        move.l  (a1,d1.w),d1
        jmp     (a5,d1.l)
;
setfrom: lea    store,a0
        clr.w   (a0)
        rts
;
dofrom: push    #$202c          ;'move.l xx(a4),d0'
        bsr     _comma
        bsr     _comma          ;negative value of xx
        push    #$2d00          ;push d0
        lea     toptyp,a0
        move.w  #3,(a0)         ;local on top of stack
        bra.s   doaddx
;
_lb:    push    4(a0)           ;value in pfa
doaddr: push    #$41ec          ;lea -xx(a4),a0
        bsr     _comma
        bsr     _comma          ;negative offset
        push    #$2d08          ;push a0
doaddx: bsr     _comma
        bsr     plusedge
        bsr     setfrom         ;default fetch
        rts
;
doaddto: lea    baddto,a0
        bra     doto1
;
dofor:  push    #$222c          ;move local to d1 to do value test
        bsr     _comma
        push    (a6)            ;copy the offset
        bsr     _comma
        push    #$6f00          ;BLE (counter must start with pos value)
        bsr     _comma
        pop     -(a7)           ;get the offset out of the way
        bsr     _fmark          ;BLE XXXX
        bsr     _bmark          ;HERE
        push    (a7)+           ;offset
        push    #$53ac          ;'subq.l #1,xx(a4)'
        push    #22             ;balance marker
        push    #0
        bsr     pushlve         ;marker on leave stack
        bsr     setfrom
        bsr     edgeoff
        rts
;
doto:   lea     bto,a0
doto1:  move.l  #$80002d00,d2
        move.w  #2,d4
        bsr     expand
dotow:  bsr     _comma
dotox:  bsr     edgeoff
dotoy:  bsr     setfrom         ;fetch is default state
        bsr     toptypoff
        rts
;
whichreg: push  a0              ;^reg opcodes
        moveq.l #2,d1           ;2 = an address register
        cmp.w   #(2*perreg),d0
        blt.s   .wr5
        subq.l  #1,d1           ;1 = a data register
.wr5:   lea     toptyp,a0
        move.w  d1,(a0)
        pop     a0
        rts
;
toregval: lea   regvals,a0
        pop     d0              ;pop pointer offset
        adda.l  d0,a0
        rts
;
regfrom: bsr.s  toregval
        bsr     whichreg
        push    (a0)
        bsr     _comma          ;low bytes of long value
        bsr     plusedge
        bsr     setfrom
        rts
;
regto:  bsr.s   toregval
        move.l  (a0),d0
        move.l  #$80000000,d2   ;1 param no result
        move.w  d0,d2           ;edge
        move.w  #1,d4           ;single word of code (high bytes of d0)
regto1: push    d0
        move.l  a6,a0           ;^code
        bsr     expand
        addq.l  #4,a6           ;clean up stack
        bra     dotox
;
regaddto: bsr.s toregval
        move.l  #$80002d00,d2   ;1 param no result
        move.l  #$201e0000,d0   ;'pop d0'
        move.w  4(a0),d0        ;addto code
        move.w  #2,d4           ;1 word of code after pop
        bra     regto1
;
regfor: push    (a6)            
        bsr     toregval
        move.l  (a0),d0
        and.w   #$0f,d0         ;mask out all irrelevant bits
        or.w    #$2200,d0       ;make it a move to d1 to test value
        push    d0
        bsr     _comma
        push    #$6f00
        bsr     _comma
        pop     -(a7)           ;offset
        bsr     _fmark
        bsr     _bmark
        push    (a7)+           ;offset
        bsr     toregval
        move.l  (a0),d0
        and.w   #$0f,d0         ;mask out all irrelevant bits
        or.w    #$5380,d0       ;make it SUBQ.L #1,reg
        push    d0              ;opcode
        push    #21             ;balance marker
        push    #0
        bsr     pushlve         ;marker on leave stack
        bsr     setfrom
        bsr     edgeoff
        bsr     toptypoff
        rts
;
_next:  bsr     _ifcomp
        pop     d0
        cmp.l   #21,d0
        beq     .reg
        cmp.l   #22,d0
        beq     .loc
        bra     strerror
.reg:   push    (a6)            ;dup opcode on stack
        bsr     _comma          ;'SUBQ.L #1,reg'
        pop     d0
        btst    #3,d0
        beq     .nx5            ;ok if a data register
        and.w   #$0f,d0
        or.w    #$2000,d0       ;'MOVE.L reg,d0'
        push    d0
        bsr     _comma          ;move from addr reg to set flags!
.nx5:   push    #$6E00          ;'BGT'
        bsr     _comma
        bsr     _bresolve
        bsr     _fresolve       ;BEQ from start of loop
        bsr     reslve          ;destination for LEAVEs
        rts
.loc:   bsr     _comma          ;'SUBQ.L #1,xx(a4)
        bsr     _comma          ;negative offset
        bra.s   .nx5
;
_addr:  moveq   #4,d0
        bra.s   storeit
_to:    moveq   #8,d0
        bra.s   storeit
_addto: moveq   #12,d0
        bra.s   storeit
_for:   moveq   #16,d0
storeit: lea    store,a0
        move.w  d0,(a0)
        rts
;
bto:    pop     d0
        dc.w    $2940           ;move.l d0,xx(a4)
;
baddto: pop     d0
        dc.w    $d1ac           ;add.l  d0,xx(a4)
;
_inc:   lea     adjust,a0
        move.w  #$00d8,(a0)
        rts
;
_dec:   lea     adjust,a0
        move.w  #$0120,(a0)
        rts
;
lerror: lea     locerr,a0
        bra     _error
;
local:  push    #4
        lea     _loc,a0
dolocal: suba.l a5,a0
        push    a0              ;address of generic code
        bsr     header
        bsr     _hcomma         ;code pointer in cfa
        pop     d0              ;local data size
        lea     frdepth,a0      ;depth of stack frame
        sub.l   d0,(a0)         ;space for a new entry
        push    (a0)            ;get depth to stack
        bsr     _hcomma         ;constant value in pfa
        bsr     dolength
        bsr     _immediate
        rts
;
locsok: cmp.l   #998,4(a6)      ;something really on the stack?
        bne     lerror          ;no parameter count on top
        rts
;
_locals: bsr.s  locsok
        pop     d0              ;#params
locs1:  push    d0              ;entry point for args
.llp:   pop     d0
        beq.s   .lx
        subq.l  #1,d0
        push    d0
        bsr     local
        bra     .llp
.lx:    rts
;
reg:    bsr     header
        lea     _reg,a0
        suba.l  a5,a0
        push    a0
        bsr     _hcomma         ;cfa
        lea     regoffs,a0      
        move.l  (a0),a1
        push    a1
        addq.l  #perreg,a1      ;bump pointer
        move.l  a1,(a0)
        bsr     _hcomma         ;regoffs into pfa
        bsr     dolength
        bsr     _immediate
        lea     pushptr,a0
        move.l  (a0),a1
        addq.l  #4,a1           ;advance pointer
        move.l  a1,(a0)
        lea     pushval,a0
        move.l  (a1),(a0)
        rts
;
_regs:  bsr     locsok
        pop     d0              ;#params
        move.l  d0,d1
        lea     regnumb,a0
        add.w   (a0),d1
        cmp.l   #maxregs,d1
        bhi     lerror          ;too many parameters
        move.w  d1,(a0)         ;update # reg args
        push    d0
rlp:    pop     d0
        beq.s   .rx
        subq.l  #1,d0
        push    d0
        bsr     reg
        bra.s   rlp
.rx:    rts
;
_args:  bsr     locsok
        pop     d0
        lea     largnumb,a0
        move.w  d0,(a0)         ;save for auto pops
        bsr     locs1           ;continue as for locals
        lea     frdepth,a0
        lea     argdpth,a1
        move.l  (a0),(a1)       ;frame offset for auto pops
        rts
;
_regargs: bsr   locsok
        pop     d0              ;# reg args
        cmp.l   #maxregs,d0
        bhi     lerror          ;too many parameters
        lea     regnumb,a0
        tst.w   (a0)
        bne     lerror          ;regargs must be declared before regs
        move.w  d0,(a0)
        push    d0
        bsr     rlp
        lea     pushptr,a0
        lea     rargptr,a1
        move.l  (a0),(a1)       ;needed for auto popm
        rts
;
_locbuff: bsr   _even
        lea     _lb,a0
        bra     dolocal
;
endlocs: lea    frdepth,a0
        move.l  (a0),d0
        beq.s   .elx            ;if no local stack frame
        push    #$4e5c          ;'unlk a4'
        bsr     _comma
.elx:   lea     pushval,a0
        move.l  (a0),d0
        beq.s   .ely            ;if no regs used
        swap    d0
        push    d0
        push    #$4cdf          ;'popm'
        bsr     _comma
        bsr     _comma
.ely:   rts
;
kheads: lea     hp,a0
        lea     tothere,a1
        move.l  (a1),d0
        move.l  d0,(a0)         ;delete temporary heads
        add.l   a5,d0
        lea     entry,a0
        move.l  d0,(a0)         ;correct entry point
        rts
;
pushes: lea     pushval,a0
        move.l  (a0),d0
        beq     .pux            ;if no reg variables
        push    d0
        push    #$48e7          ;'pushm to rstack'
        bsr     _comma
        bsr     _comma
        lea     rargptr,a0
        move.l  (a0),a0
        move.l  (a0),d0
        beq     .pux
        swap    d0
        push    d0
        push    #$4cde          ;'popm from dstack'
        bsr     _comma
        bsr     _comma
.pux:   rts
;
frame:  lea     frdepth,a0
        move.l  (a0),d0         ;get stack frame size
        beq     .frx
        push    d0
        push    #$4e54          ;'link a4,#xxxx'
        bsr     _comma
        bsr     _comma          ;frame size
.frx:   rts
;
getargs: lea    largnumb,a0
        move.w  (a0),d0
        beq     .gax
        push    d0              ;# args
        lea     argdpth,a0
        move.l  (a0),d0         ;where to start loading args
        push    d0
        push    #$41ec          ;'lea xx(a4),a0'
        bsr     _comma
        bsr     _comma          ;a0 points to args in stack frame
.galp:  pop     d0
        beq     .gax
        subq.l  #1,d0
        push    d0
        push    #$20de          ;'pop (a0)+'
        bsr     _comma
        bra     .galp
.gax:   rts
;
_cbra:  bsr     _bra
        push    #998            ;balance marker
        rts
;
_cket:  bsr     pushes
        bsr     frame
        bsr     getargs
        pop     d0
        cmp.l   #998,d0
        bne     strerror
        bsr     _ket
        rts
;
regdrop: moveq.l #2,d0
        bra.s   ld5
locdrop: moveq.l #6,d0
ld5:    lea     cp,a2
        sub.l   d0,(a2)
        lea     edge,a2
        subq.w  #1,(a2)
        lea     edges,a2
        move.l  (a2)+,(a2)
        rts
;
kpreg:  lea     lastused,a0     
        move.w  (a0),d0         ;pop opcode
        and.w   #$0fc0,d0
        or.w    #$2008,d0
        push    d0              ;'move.l a0,reg'
        bsr     _comma
        rts
;
kploc:  push    #$2948          ;'move.l a0,xx(a4)'
        bsr     _comma
        lea     lastused,a2
        push    (a2)
        bsr     _comma
        rts
;
ptchptr: bsr    tocode          ;returned in a1
        subq.l  #2,a1           ;point to word to be patched
        move.w  (a1),d0
        move.w  (a0),d1
        and.w   d4,d1
        or.w    d1,d0           ;convert to a fetch pointed to by reg
        move.w  d0,(a1)         ;replace code
        rts
;
ftchadj: moveq.l #$38,d3        ;mask for fetch inc/dec 
        bra.s   ptchadj
storadj: move.l #$01c0,d3       ;mask for fetch inc/dec 
ptchadj: lea    adjust,a0
        move.w  (a0),d1
        clr.w   (a0)            ;clear adjust field
        move.w  d1,d2           ;save the flag
        beq     .pmx
        bsr     tocode
        subq.l  #2,a1           ;point to code to be patched
        move.w  (a1),d0
        and.w   d3,d1
        not.w   d3              ;reverse the mask
        and.w   d3,d0           ;mask out old EA field
        or.w    d1,d0           ;insert new field
        move.w  d0,(a1)         ;replace the patched opcode
        tst.w   d2              ;return the flag
.pmx:   rts
;
useloc: bsr     locdrop
        push    #$206c          ;'move xx(a4),a0'
        bsr     _comma
        lea     lastused,a2
        push    (a2)            ;get last offset
        bsr     _comma          ;compile it
        rts
;
fetchnorm: pop  a0              ;^code
        bsr     expand
        bsr     oneon
        bsr     setfrom         ;fetch is default state
        bsr     toptypoff
        rts
;
_fetchopt: move.l -4(a0),d2     ;expansion flags
        move.l  4(a0),a0        ;pfa has offset of address
        adda.l  a5,a0
        push    a0              ;^code
        bsr     stateat
        beq     do_op           ;execute if not compiling
        move.l  d2,d4
        swap    d4
        and.w   #maclen,d4      ;mask out macro length

        lea     toptyp,a1
        move.w  (a1),d0
        beq     fetchnorm       ;no local on top

        clr.w   (a1)
        cmp.w   #3,d0           ;non-register local?
        beq     .locptr
        cmp.w   #2,d0           ;an address register?
        beq     .addreg
        bra     .datreg         ;must be a data register
        
.addreg: bsr    regdrop
        move.w  #$ffff,d2       ;no edge to look for
        pop     a0              ;^code
        addq.l  #2,a0           ;bump code pointer
        subq.l  #2,d4           ;skip pop and drop push
        bsr     inline
        
        lea     (lastused+2),a0 ;ptchptr needs this
        moveq.l #7,d4           ;mask for push opcode
        bsr     ptchptr
        bsr     ftchadj
        bra.s   .finish
        
.datreg: pop    a0
        subq.l  #1,d4           ;drop final push
        bsr     inline
        
        bsr     ftchadj
        tst.w   d2
        beq.s   .finish
        bsr     kpreg

.finish: push   #$2d00          ;'push d0'
        bsr     _comma
.fox:   bsr     oneon           ;return one edge
        rts
        
.locptr: bsr    useloc          
        move.w  #$ffff,d2       ;no edge to look for
        pop     a0              ;code to copy
        addq.l  #2,a0
        subq.w  #2,d4           ;one word less at each end
        bsr     inline

        bsr     ftchadj
        beq.s   .finish
        
        bsr     kploc
        bra.s   .finish

.doit:  pop     a0
        jsr     (a0)
        rts

storenorm: pop  a0              ;^code
        bsr     expand
        bra     dotox
;
_storeopt: move.l -4(a0),d2     ;expansion flags
        move.l  4(a0),a0        ;pfa has offset of address
        adda.l  a5,a0
        push    a0              ;^code
        bsr     stateat
        beq     do_op           ;execute if not compiling

        move.l  d2,d4
        swap    d4
        and.w   #maclen,d4      ;mask out macro length

        lea     toptyp,a1
        move.w  (a1),d0
        beq     storenorm       ;no local on top

        clr.w   (a1)            ;reset flag
        cmp.w   #3,d0
        beq     .locptr
        cmp.w   #2,d0           ;an address register just pushed?
        beq     .addreg         ;no special pointer used
        bra     .datreg         ;must be a data register
        
.addreg: bsr    regdrop
        move.w  #$2d00,d2       ;'push d0' edge to look for
        pop     a0
        addq.l  #2,a0           ;bump code pointer
        subq.l  #1,d4           ;less code needed
        bsr     inline

        lea     lastused,a0     ;ptchptr needs this
        move.l  #$0e00,d4       ;mask for pop opcode
        bsr     ptchptr
        bsr     storadj
                
.finish: bsr    edgeoff         ;no edges left
        rts
        
.datreg: pop    a0
        bsr     inline
        bsr     storadj
        beq.s   .finish         ;no register save needed
        
        bsr     kpreg
        bra.s   .finish
        
.locptr: bsr    useloc
        move.w  #$ffff,d2       ;no edge to look for
        pop     a0
        addq.l  #2,a0           ;bump code pointer
        subq.l  #1,d4           ;less code needed
        bsr     inline
        
        bsr     storadj
        beq.s   .finish         ;no register save needed

        bsr     kploc
        bra.s   .finish
                
do_op:  pop     a0
        jsr     (a0)
        rts
;
_notopt: move.l -4(a0),d2       ;expansion flags
        move.l  4(a0),a0        ;pfa has offset of address
        adda.l  a5,a0
        push    a0              ;^code
        bsr     stateat
        beq     do_op           ;execute if not compiling

        pop     a0              ;code address
        lea     mcro,a1
        tst.l   (a1)            ;just expanded a macro?
        bne.s   .no5
        bsr     mustcall        ;compile a call
        rts
;
.no5:   lea     edge,a1
        cmp.w   #99,(a1)        ;a test just performed?
        bne.s   .no6
        
        bsr     tocode          ;returned in a1
        eori.w  #$0100,-8(a1)   ;invert the test logic
        rts

.no6:   bsr     call
        bra     dotoy
;
xcol:   lea     todepth,a0      ;local flag off
        clr.w   (a0)
        lea     pushval,a0
        clr.l   (a0)            ;no regs being used
        lea     frdepth,a0
        clr.l   (a0)            ;initialise stack frame depth
        lea     regoffs,a0      ;remember last address reg used
        clr.l   (a0)
        lea     adjust,a0       ;any inc/dec of address register
        clr.w   (a0)
        lea     regpush,a1
        lea     pushptr,a0
        move.l  a1,(a0)         ;initialize register push values
        lea     rargptr,a0
        move.l  a1,(a0)         ;initialize register push values
        lea     largnumb,a0
        clr.w   (a0)            ;number of local arguments passed
        lea     regnumb,a0
        clr.w   (a0)            ;number of register arguments passed
        bsr     edgeoff
        bsr     setfrom         ;default fetch from stack frame
        bsr     toptypoff
        rts
;
_xcolon: bsr    xcol
        bsr     _colon
        lea     hp,a0
        lea     tothere,a1
        move.l  (a0),(a1)       ;offset of start of temporary heads
        rts
;
_xsemi: bsr     endlocs
        bsr     kheads
        bsr     _semicolon
        rts
;
_xexit: bsr     endlocs
        bsr     _exit
        rts
;
_xdoes: bsr     endlocs
        bsr     xcol
        bsr     _does
        rts
;
_gemdos:push    d2
        push    a2
        trap    #1
        pop     a2
        pop     d2
        rts
;
_xbdos: push    d2
        push    a2
        trap    #2
        pop     a2
        pop     d2
        rts
;
_bios:  push    d2
        push    a2
        trap    #14
        pop     a2
        pop     d2
        rts
;
_xbios: pop     d2
        push    a2
        trap    #13
        pop     a2
        pop     d2
        rts
;
        section data
        even
;
;local definitions group:
;
        dc.b    $83,'AR','G'!$80
        ptrs    _args,16
;
        dc.b    $84,'ARGS',$a0          ;synonym for arg
        ptrs    _args,18
;
        dc.b    $86,'REGARG',$a0
        ptrs    _regargs,20
;
        dc.b    $87,'REGARG','S'!$80    ;synonym for regarg
        ptrs    _regargs,20
;
        dc.b    $85,'LOCA','L'!$80
        ptrs    _locals,18
;
        dc.b    $86,'LOCALS',$a0        ;synonym for local
        ptrs    _locals,20
;
        dc.b    $83,'RE','G'!$80
        ptrs    _regs,16
;
        dc.b    $84,'REGS',$a0
        ptrs    _regs,18
;
        dc.b    $c7,'LOCBUF','F'!$80
        ptrs    _locbuff,20
;
        dc.b    $c1,'{'!$80
        ptrs    _cbra,14
;
        dc.b    $81,'}'!$80
        ptrs    _cket,14
;
;user words for locals:
;
        dc.b    $c2,'TO',$a0
        ptrs    _to,16
;
        dc.b    $c5,'ADDT','O'!$80
        ptrs    _addto,18
;
        dc.b    $c4,'ADDR',$a0
        ptrs    _addr,18
;
        dc.b    $c3,'FO','R'!$80        ;loop start
        ptrs    _for,16
;
        dc.b    $c4,'NEXT',$a0          ;loop end
        ptrs    _next,18
;
        dc.b    $c3,'IN','C'!$80
        ptrs    _inc,16
;
        dc.b    $c3,'DE','C'!$80
        ptrs    _dec,16
;
;enhanced definitions of compilation words:
;
        dc.b    $c1,';'!$80
        ptrs    _xsemi,14
;
        dc.b    $81,':'!$80
        ptrs    _xcolon,14
;
        dc.b    $c4,'EXIT',$a0
        ptrs    _xexit,18
;
        dc.b    $c5,'DOES','>'!$80
        ptrs    _xdoes,18
;
;direct access to processor registers:
;
        dc.b    $c2,'A0',$a0
        dc.l    0
        offs    _reg
        dc.l    -(6*perreg)
        dc.w    16
;
        dc.b    $c2,'A1',$a0
        dc.l    0
        offs    _reg
        dc.l    -(5*perreg)
        dc.w    16
;
        dc.b    $c2,'A2',$a0
        dc.l    0
        offs    _reg
        dc.l    -(7*perreg)
        dc.w    16
;
        dc.b    $c2,'A4',$a0
        dc.l    0
        offs    _reg
        dc.l    -(4*perreg)
        dc.w    16
;
        dc.b    $c2,'A5',$a0
        dc.l    0
        offs    _reg
        dc.l    -(3*perreg)
        dc.w    16
;
        dc.b    $c2,'A6',$a0
        dc.l    0
        offs    _reg
        dc.l    -(2*perreg)
        dc.w    16
;
        dc.b    $c2,'A7',$a0
        dc.l    0
        offs    _reg
        dc.l    -(perreg)
        dc.w    16
;
        dc.b    $c2,'D0',$a0
        dc.l    0
        offs    _reg
        dc.l    6*perreg
        dc.w    16
;
        dc.b    $c2,'D1',$a0
        dc.l    0
        offs    _reg
        dc.l    7*perreg
        dc.w    16
;
        dc.b    $c2,'D6',$a0
        dc.l    0
        offs    _reg
        dc.l    8*perreg
        dc.w    16
;
        dc.b    $c2,'D7',$a0
        dc.l    0
        offs    _reg
        dc.l    9*perreg
        dc.w    16
;
        dc.b    $c2,'D2',$a0
        dc.l    0
        offs    _reg
        dc.l    10*perreg
        dc.w    16
;
        dc.b    $c2,'SP',$a0
        dc.l    0
        offs    _reg
        dc.l    -(2*perreg)
        dc.w    16
;
        dc.b    $c2,'RP',$a0
        dc.l    0
        offs    _reg
        dc.l    -(perreg)
        dc.w    16
;
; trap group:
;
        dc.b    $86,'GEMDOS',$a0
        mptrs   _gemdos,noedge,5,0,20
;
        dc.b    $85,'XBDO','S'!$80
        mptrs   _xbdos,noedge,5,0,18
;
        dc.b    $85,'XBIO','S'!$80
        mptrs   _xbios,noedge,5,0,18
;
        dc.b    $84,'BIOS',$a0
        mptrs   _bios,noedge,5,0,18
;
