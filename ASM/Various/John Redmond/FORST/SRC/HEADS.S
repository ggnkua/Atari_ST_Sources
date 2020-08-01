; HEADS.S: low-level access words for headers
; and their handlers.
; Copyright <c> John Redmond, 1989,1990
; Public domain for non-commercial use.
;
        section text
        even
;
lensize = 2
macspecs = 4                    ;2 words after name
pointers = 8                    ;2 fields
overmacs = macspecs+1
threeflds = macspecs+pointers
allflds = threeflds+lensize
nxtnfa = pointers+lensize
frstcfa = nxtnfa

; _BFIND: The pointer to string is expected on the stack.
; If a match is found, the code field address is returned
; with +1 or -1, otherwise the string pointer is returned with 0.
_bfind: movem.l a2-a4,-(a7)
        bsr     upper           ;string in pocket to upper case
        bsr     _top            ;normally equivalent to _there
        pop     a0              ;pointer to headers
        pop     a4              ;address of pocket
.bflp:
;point to name in next header
        move.w  -(a0),d0
        beq     .notfnd         ;zero if already at last header
        suba.w  d0,a0           ;point to previous header
        move.l  a0,a2           ;working copy of pointer
;try for a match
        move.l  a4,a1           ;pointer to match string
        move.b  (a2)+,d0
        and.l   #$3f,d0         ;mask off name length & leave smudge bit
        cmp.b   (a1)+,d0
        bne     .bflp           ;length is wrong
        subq.l  #1,d0
.matchlp: move.b (a2)+,d1
        and.b   #$7f,d1         ;mask off high bit
        cmp.b   (a1)+,d1
        bne     .bflp           ;character mismatch
        dbra    d0,.matchlp
        move.w  a2,d0
        btst    #0,d0
        beq     .match9         ;if address is even
        addq.l  #1,a2
.match9: addq.l #4,a2           ;skip length and macro flag
        push    a2              ;cfa of word
        move.l  #-1,d0          ;return -1
        btst    #6,(a0)         ;test immediate bit
        beq     .notimm
        neg.l   d0              ;return +1
.notimm: push   d0              ;true flag
        bra     .fx
.notfnd: push   a4              ;return pocket address
        clr.l   -(a6)           ;with false flag
.fx:    movem.l (a7)+,a2-a4
        rts
;
_traverse: movem.l (a6)+,d0/a0
.trlp:  add.l   d0,a0
        btst    #7,(a0)
        beq     .trlp
        push    a0
        rts
;
_cton:  pop     a0
        subq.l  #overmacs,a0
        push    a0
        push    #-1
        bsr     _traverse       ;get nfa
        rts
;
_ntoc:  push    #1
        bsr     _traverse
        add.l   #overmacs,(a6)
        rts
;
codehead: move.l (a0),d0        ;get code offset
        lea     _const,a1
        suba.l  a5,a1           ;code offset of constant
        cmp.l   a1,d0
        bne     .cy             ;not a constant header
        adda.l  #nxtnfa,a0      ;nfa of next header
        lea     hp,a1
        move.l  (a1),d0
        add.l   a5,d0
        cmp.l   a0,d0
        bls     .cx             ;no more headers
        push    a0
        bsr     _ntoc
        pop     a0              ;cfa of next header
        bra     codehead        ;try again
.cx:    move.l  #0,a0           ;set zero flag
.cy:    rts
;
discard: move.l (a6),a0
        bsr     codehead        ;get a header with its own code
        beq     .d5             ;no code to delete
        lea     cp,a1
        move.l  4(a0),(a1)      ;correct code pointer
.d5:    bsr     _cton
        pop     d0              ;nfa of original header
        lea     entry,a0
        move.l  d0,(a0)         ;entry for find
        sub.l   a5,d0           ;subtract index to get offset
        lea     hp,a0
        move.l  d0,(a0)         ;correct header pointer
        rts
;
castore: bsr    _there
        pop     a0
        suba.l  #frstcfa,a0     ;point to cfa
        pop     d0
        sub.l   a5,d0           ;code offset
        move.l  d0,(a0)
        rts
;
do_ptrs:
        suba.l  a5,a0           ;convert to offset
        push    a0
        bsr     _hcomma
        lea     cp,a0
        push    (a0)
        bsr     _hcomma         ;offset ^value in pfa
        rts
;
header: bsr     name            ;return address of pocket
        bsr     _align
        bsr     _halign
        bsr     _there
        move.l  (a6),-(a7)      ;save copy of nfa
        move.l  4(a6),a0        ;pocket address
        clr.l   d0
        move.b  (a0),d0         ;name length
        addq.l  #1,d0
        push    d0
        move.l  d0,-(a7)        ;save length for later
        bsr     _cmove          ;move name into place
        push    (a7)+           ;length
        bsr     _hallot
        bsr     _halign
        bsr     _there
        pop     a0
        tas     -1(a0)          ;set bit 7 at end of name
        move.l  (a7)+,a0        ;get nfa back
        tas     (a0)            ;set bit 7 of name length
        push    #0
        bsr     _hcomma         ;ready for macro flag and length
        rts
;       
dolength: lea   pocket,a0       ;add in head length at end of head
        move.l  (a0),a0
        moveq.l #0,d0
        move.b  (a0),d0
        add.w   #(threeflds+1),d0 ;length of dimensioned name + 12
        moveq.l #1,d1
        and.w   d0,d1
        add.w   d1,d0           ;add 1 if length odd
        lea     hp,a0
        move.l  (a0),a1
        add.l   #lensize,(a0)
        adda.l  a5,a1
        move.w  d0,(a1)+        ;store the length in the header
        lea     entry,a0
        move.l  a1,(a0)         ;starting address for FIND
        rts
;
fndnfa:	lea	entry,a0
	push	(a0)
	sub.l	#15,(a6)
	push	#-1
	bsr	_traverse
	pop	a0
	rts
;
_immediate: bsr.s fndnfa
        bset    #6,(a0)
        rts
;
_smudge: bsr.s fndnfa
        eori.b  #$20,(a0)
        rts
;
_last:  bsr     _top
        sub.l   #15,(a6)
        push    #-1
        bsr     _traverse
        rts
;
;*******************************************************;
;                                                       ;
; The handlers for the separated headers                ;
;                                                       ;
;*******************************************************;
;
fnfa:   bsr     _head
        sub.l   #overmacs,(a6)
        push    #-1
        bsr     _traverse       ;get nfa
        rts
;
headlen: moveq.l #0,d0
        move.b  (a0),d0
        and.l   #$1f,d0         ;length of name
        move.l  d0,d1
        and.l   #1,d1
        eor.l   #1,d1
        add.b   d1,d0           ;extra byte if length is even
        add.b   #(allflds+1),d0 ;total length of header (add 1+3*4+2)
        rts
;
_from:  bsr     fnfa
        pop     a0
        suba.l  a5,a0
        lea     chop,a1
        move.l  a0,(a1)         ;start of header removal
        bsr     _pad
        pop     a0
        lea     hbase,a1
        move.l  a0,(a1)         ;keep selected headers here
        lea     hnow,a1
        move.l  a0,(a1)         ;place for next header
        lea     hlen,a0
        clr.l   (a0)            ;none so far
        rts
;
_keep:  movem.l a2-a3,-(a7)
        bsr     fnfa
        move.l  (a6),a0         ;copy nfa
        bsr     headlen         ;length in d0
        lea     hlen,a1
        add.l   d0,(a1)         ;increase length of stored headers
        lea     hnow,a2
        move.l  (a2),a3         ;where to move this header
        add.l   d0,(a2)         ;increase store pointer
        push    a3
        push    d0
        bsr     _cmove          ;shift header
        movem.l (a7)+,a2-a3
        rts
;
_hide:  bsr     fnfa
        pop     a0
        bsr     headlen         ;length in d0
        lea     (a0,d0.l),a1
        push    a1
        push    a0
        lea     hp,a0
        move.l  (a0),d1
        add.l   a5,d1           ;^free header space
        sub.l   d0,(a0)         ;adjust hp back
        sub.l   a1,d1           ;size of header block to move
        push    d1
        bsr     _cmove
        bra.s	pbx
;
_public: move.l a2,-(a7)
        lea     hp,a0
        lea     chop,a1
        move.l  (a1),(a0)       ;cut headers back
        move.l  (a0),a1
        adda.l  a5,a1           ;dest for header move
;
        lea     hlen,a2
        move.l  (a2),d0         ;length of saved heads
        add.l   d0,(a0)         ;advance hp
;
        lea     hbase,a2
        move.l  (a2),a2
        push    a2              ;source
        push    a1              ;dest
        push    d0              ;length
        bsr     _cmove
        move.l  (a7)+,a2        ;restore
pbx:    bsr     _there
        lea     entry,a0
        pop     (a0)            ;start for find
        rts
;
        section data
        even
;
        dc.b    $88,'TRAVERSE',$a0
        ptrs    _traverse,22
;
        dc.b    $84,'LAST',$a0
        ptrs    _last,18
;
        dc.b    $84,'HEAD',$a0
        ptrs    _head,18
;
        dc.b    $84,'FROM',$a0
        ptrs    _from,18
;
        dc.b    $84,'KEEP',$a0
        ptrs    _keep,18
;
        dc.b    $84,'HIDE',$a0
        ptrs    _hide,18
;
        dc.b    $86,'PUBLIC',$a0
        ptrs    _public,20
;
