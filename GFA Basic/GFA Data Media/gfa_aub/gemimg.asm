; file: gemimg.asm
;
             .INCLUDE 'MACRO.INC'
             .INCLUDE 'ATARI.IS'



ALONE        set 0     ;  !=0 generates code for stand-alone version



             .IFNE ALONE
             bra       setup
             .ENDC 



;===========================================================================
;;       Packing and unpacking in GEM Image format
;
;       This code was written for monochrome pictures (one frame only)
;       Line start must be aligned to bytes
;       Minimum line length is a pixel (a byte)
;
;Call:
;
;long=imgcode( mde, destination, source, xpixel, ylines)
;mde==1
;Pack source to destination;
;       Width of source picture is xpixel pixels
;       Height of source picture is ylines lines
;       The source of the packed picture (incl. header)
;       is returned.
;mde !=1:
;Unpack source to destination;
;       Width of source picture is xpixel pixels (multiple
;       of 8). Maximum height of destination picture is ylines pixels
;       0 is returned if picture has been unpacked successfully,
;       else 1.
;
;Note: deviating from Dietmar Schell's encoding scheme, zero bytes
;       and full bytes are always packed as such. Except when they
;       are immediately preceded by a block of unpacked bytes to
;       which the zero bytes can be appended. A sequence of more than
;       two zero or full bytes is always packed separately. Sequences
;       of zero and full bytes at the end of a line are also packed
;       separately.
;
;Actual code
;===========
;
imgcode:     movem.l   d1-d7/a0-a6,-(sp)
             lea.l     (1+14)*4(sp),a5
             move.w    (a5)+,d0             ;Opcode
             movea.l   (a5)+,a2             ;Base destination picture
             movea.l   (a5)+,a3             ;Base source picture
             move.w    (a5)+,d2             ;Width in pixels
             move.w    (a5)+,d3             ;Height in lines
             subq.w    #1,d0                ; assign operation
             beq       encode               ;  ==1: encode; !=1: decode

decode:      move.w    2(a3),d0             ;Check header length
             cmpi.w    #8,d0
             bne       .error
             move.l    12(a3),d7            ;Read picture dimensions
             cmp.w     d7,d3                ;d3 is maximum picture size in bytes
             bhi       .pictwidth
             move.w    d7,d3
.pictwidth:  swap.w    d7                   ;calculate picture width in bytes
             addq.w    #7,d7
             lsr.w     #3,d7
             lea.l     16(a3),a3            ;move to behind IMG header
             move.w    d2,d6                ;calculate width of destination buffer in bytes
             addq.w    #7,d6
             lsr.w     #3,d6
             sub.w     d6,d7                ;calculate difference between line sizes in bytes
             neg.w     d7                   ;  and save: target buffer > source picture
             bmi       .error
             subq.w    #1,d3                ;linecount -1

.decodeline: moveq.l   #0,d4                ;no line repeats so far
             movea.l   a2,a4                ;remember line start
             move.w    d6,d5                ;line size of picture in bytes(-1)
             sub.w     d7,d5
             bra       .nxtsym

.decodesym:  moveq.l   #0,d0                ;read and process next symbol
             move.b    (a3)+,d0             ;============================
             bne       .norepeat
             move.b    (a3)+,d0
             bne       .pattrepeat

.linerepeat: move.b    (a3)+,d0             ;decode a line repeat header
             addq.b    #1,d0                ;===========================
             bne       .error               ;    check syntax
             tst.w     d4                   ;    check double call
             bne       .error               ;
             move.b    (a3)+,d4             ;    read counter
             subq.w    #1,d4                ;    prepare dbf loop
             bra       .decodesym

.pattrepeat: move.b    (a3)+,d2             ;decode pattern repeat
             lsl.w     #8,d2                ;=====================
             move.b    (a3)+,d2             ;    build pattern lword in d1
             move.w    d2,d1
             swap.w    d1
             move.w    d2,d1
             add.w     d0,d0                ;    repeat length in bytes
.doainsert:  sub.w     d0,d5                ;this code will be re-used
             bsr       qinsert              ;       :            :
             bra       .nxtsym              ;       :            :

.norepeat:   bpl       .emptyblock
             andi.w    #$7f,d0
             bne       .fullblock
.unpacked:   moveq.l   #0,d0                ;decode unpacked block
             move.b    (a3)+,d0             ;=====================
             sub.w     d0,d5                ;    copy block and update
             movea.l   a3,a0                ;    Block pointers
             movea.l   a2,a1
             bsr       qcopy
             movea.l   a1,a2
             movea.l   a0,a3
             bra       .nxtsym

.fullblock:  moveq.l   #-1,d1               ;decode full/zero block
             bra       .doainsert           ;======================
.emptyblock: moveq.l   #0,d1                ;    use trivial patterns
             bra       .doainsert           ;    re-use code

.nxtsym:     tst.w     d5                   ;more bytes in line ?
             bne       .decodesym           ;  yes, then continue decoding

.nxtline:    movea.l   a4,a0                ;set source: start of this line
             movea.l   a2,a1                ;set destination: start next line
             adda.w    d7,a1
             bra       .replintst           ;as long as further line exists:
.repline:    moveq.l   #0,d0                ;
             move.w    d6,d0                ;  set size: line length picture
             bsr       qcopy                ;       copy line and
             adda.w    d7,a1                ;       adjust destination pointer to line start
             subq.w    #1,d3                ;       room for more lines ?
             bmi       .done                ;       no, then terminate
.replintst:  dbf       d4,.repline          ;  as long as linerepeat
.morelines:  movea.l   a1,a2                ;then continue
             dbf       d3,.decodeline       ;decode next line if it exists

.done:       moveq.l   #0,d0                ;no error
             bra       finish
.error:      moveq.l   #1,d0                ;error
             bra       finish



;
;Encode a memory block according to GEM IMG encoding scheme
; =========================================================
;
encode:      movea.l   a2,a5                ;a5: start address of unpacked section
             move.w    d2,d4                ;d4: width in bytes (calculate)
             addq.w    #7,d4
             lsr.w     #3,d4

             lea.l     imghdr(pc),a0        ;write standard IMG file header
             move.l    (a0)+,(a2)+
             move.l    (a0)+,(a2)+
             move.l    (a0)+,(a2)+
             move.w    d2,(a2)+             ;d2: Width of the picture
             move.w    d3,(a2)+             ;d3: Height of the picture
             bra       .pictstart           ;append the compressed data
;
;
;test for line repeat
; a3: global - line base of unpacked picture
; d3: global - remaining picture height - 1
; d4: global - picture width in bytes
; d5: local - maximum repeat height
; d6: local - starting value of repeats counter
;
.vertpack:   movea.l   a3,a0                ;Start address current line
             lea.l     0(a3,d4.w),a1        ;Start address next line
             tst.w     d3                   ;only one more line?
             beq       .horipack            ;  yes:  attempt to pack vertically
             move.w    #$00fe,d6            ;  no:   max. 255 repeats (254 comparisons)
             cmp.w     d3,d6                ;        save, not more than remaining height -1
             bcs       .vinlimit
             move.w    d3,d6
.vinlimit:   move.w    d6,d5                ;  remember counter value
             subq.w    #1,d6                ;  and set to value of first iteration
             cmp.w     d0,d0                ;  prepare while loop and start
             bra       .vpltest
.vploop:     movea.l   a0,a3                ;  remember start of last identical line
             move.w    d4,d0                ;  compare line with next until there is a difference
             bsr       qcomp                ;
.vpltest:    dbne      d5,.vploop
             sub.w     d5,d6                ;at least one identical ?
             beq       .horipack            ;  no, then pack only horizontally
;
;Deal with line repeats:
; a2: global - read pointer of packed picture
; d6: local - number of line repeats
;
             sub.w     d6,d3                ;subtract whole item
             addq.w    #1,d6                ; repeats := successful comparison + 1
             clr.b     (a2)+                ;write vertical repeat header
             clr.b     (a2)+                ;  $00,$00,$FF,<cnt>
             move.b    #$ff,(a2)+
             move.b    d6,(a2)+
;
;Pack single lines:
; d5: local - remaining line width (in loop: -1)
;
.horipack:   move.w    d4,d5                ;remember line width
             subq.w    #1,d5                ;  strange
.flushed:    addq.w    #1,d5
             movea.l   a3,a4                ;Unprocessed section starts here
.reentry:    moveq.l   #1,d0                ;  meet While condition
             bra       .eoltst
.nxtbyte:    moveq.l   #0,d0                ;read next byte
             move.b    (a3)+,d0             ;  (full long valid)
             beq       .bempty              ;  == $00:  pack zero bytes
             addq.b    #1,d0
             beq       .bfull               ;  == $FF:  pack full bytes
             subq.b    #1,d0
.trypatt:    cmp.b     1(a3),d0             ;  suspect pattern
.eoltst:     dbeq      d5,.nxtbyte          ;
             bne       .linerdy             ;  eol

.tstpattern: movea.l   a3,a0                ;Check suspected pattern
             rol.w     #8,d0                ;  build 2 bytes pattern
             move.b    (a0)+,d0
             move.w    d0,d1                ;  expand to long word pattern
             swap.w    d1
             move.w    d0,d1
             moveq.l   #0,d0
             move.w    d5,d0                ;  and determine number of pattern repeats
             bsr       qcount               ;  to line end
             movea.l   a0,a6                ;remember digit following pattern
             addq.w    #2,d1                ;pattern number to include first pattern
             lsr.w     #1,d1                ;  div 2, since pattern size
             bcc       .pattfits            ; in words half a pattern?
             subq.w    #1,a6                ;    yes, then remove at once
.pattfits:   cmpi.w    #2,d1                ;  Repeats > 2 ?
             ble       .reentry             ;    no, then add to unpacked ones

.packpatt:   sub.w     d1,d5                ;pack pattern: reduce line length
             sub.w     d1,d5
             swap.w    d1                   ;Secure this figure against being overwritten
             bsr       flunpacked1          ; deal with unpacked section
             swap.w    d1
.pattrephdr: clr.b     (a2)+                ;  generate pattern repeat header with
             move.w    #255,d0              ;  (in each case) a max of 255 repeats
             cmp.w     d0,d1                ;  which are added up to d1.w
             bpl       .prepeat
             move.w    d1,d0
.prepeat:    move.b    d0,(a2)+
             move.b    -1(a3),(a2)+
             move.b    (a3),(a2)+
             sub.w     d0,d1
             bne       .pattrephdr
             movea.l   a6,a3
             bra       .flushed



.bempty:     move.l    a3,d6                ;size of unpacked section
             subq.l    #1,d6                ;  ==0, then pack always
             sub.l     a4,d6
             beq       .packempty2
             tst.w     d5                   ;   line end already?
             beq       .packempty           ;     yes, then pack always
             tst.b     (a3)                 ;   abort if only 1 zero byte
             bne       .trypatt
             cmpi.w    #1,d5                ;   line end now?
             beq       .packempty           ;     yes, then pack always
             tst.b     1(a3)                ;   Abort if only 2 zero bytes
             bne       .trypatt
.packempty:  bsr       flunpacked1          ;pack zero bytes: process unpacked block
.packempty2: movea.l   a3,a0                ;determine precise number of zero bytes
             moveq.l   #0,d0
             move.w    d5,d0                ; rest of line already uses offset -1
             moveq.l   #0,d1
             bsr       qcount
             addq.w    #1,d1                ;  take first zero byte into account
             move.w    d1,d0
             move.w    #$007f,d2            ;  maximum packet size is 127
.multempties:          cmp.w                d2,d1 ;  too large, then adapt
             bpl       .bemptok
             move.w    d1,d2
.bemptok:    move.b    d2,(a2)+             ;  append packet to packed picture
             sub.w     d2,d1                ;  any zero bytes left over?
             bne       .multempties         ;  yes, then deal with them
             movea.l   a0,a3                ;line is packed to this point
             sub.w     d0,d5                ;calculate remainder
             bra       .flushed             ;and continue



.bfull:      move.l    a3,d6                ;size of unpacked section
             subq.l    #1,d6                ;   >0, then add full bytes to unpacked
             sub.l     a4,d6                ;       section, except if
             beq       .packfull2           ;       sequence length >= 3 or end of line
             tst.w     d5                   ;   end of line already?
             beq       .packfull            ;     yes, then pack always
             subq.w    #1,d0                ;   (correct byte  $FF)
             cmp.b     (a3),d0              ;   Abort if only 1 full byte
             bne       .trypatt
             cmpi.w    #1,d5                ;   perhaps now end of line ?
             beq       .packfull            ;     yes, then pack always
             cmp.b     1(a3),d0             ;   abort if only 2 full bytes
             bne       .trypatt
.packfull:   bsr       flunpacked1          ;pack full bytes: process unpacked block
.packfull2:  movea.l   a3,a0                ;determine exact number of full bytes
             moveq.l   #0,d0
             move.w    d5,d0                ;  rest of line already uses offset -1
             moveq.l   #-1,d1
             bsr       qcount
             addq.w    #1,d1                ;  take first full byte into account
             move.w    d1,d0
             move.w    #$007f,d2            ;  maximum packet size is 127
.multfulls:  cmp.w     d2,d1                ;  too large, then adapt
             bpl       .bfullok
             move.w    d1,d2
.bfullok:    ori.w     #$80,d2
             move.b    d2,(a2)+             ;  append packet to packed picture
             andi.w    #$7f,d2
             sub.w     d2,d1                ;  any full bytes left?
             bne       .multfulls           ;  yes, then deal with them
             movea.l   a0,a3                ;line is packed to this point
             sub.w     d0,d5
             bra       .flushed



.linerdy:    move.l    a3,d6                ;calculate number of unpacked bytes
             sub.l     a4,d6                ;  and append unpacked block
             beq       .pictstart           ;  if one exists
             bsr       flunpacked2
.pictstart:  dbf       d3,.vertpack
             move.l    a2,d0
             sub.l     a5,d0
finish:      movem.l   (sp)+,d1-d7/a0-a6
             rts       


;============================================================================
;
;flununpacked1  Write unpacked data section
;
; Input:
;       a4: points to   first unpacked byte
;       a3: points behind last unpacked byte
; Output: --
;
; Changed registers:   01234567
;                     D:-----::
;                     A::------
;
;
; flunpacked2
; ===========
;
; Input:
;       a4: points to   first unpacked byte
;       d6: number of unpacked bytes 0B#<65535
; Output:
;       a2: points behind unpacked block
;
;Changed registers:   01234567
;                    D:-----::
;                    A::------
;
flunpacked1: move.l    a3,d6                ;calculate length of unpacked section
             sub.l     a4,d6                ;  and continue with flunpacked2
             subq.w    #1,d6
             beq       flrdy

flunpacked2: movea.l   a2,a1
             movea.l   a4,a0
.flushmore:  move.w    #$ff,d7              ;still unpacked bytes, then pack
             cmp.w     d6,d7                ;  in chunks of max. 255 bytes
             ble       .flthis              ;  255 > remaining bytes?
             move.w    d6,d7                ;   yes, then block size remaining bytes, else 255
.flthis:     move.b    #$80,(a1)+           ;write header for unpacked section
             move.b    d7,(a1)+
             moveq.l   #0,d0                ;and the unpacked bytes
             move.b    d7,d0
             bsr       qcopy
             sub.w     d7,d6                ;calculate number of remaining bytes
             bne       .flushmore           ;  <> 0, then repeat
             movea.l   a1,a2                ;remember final position
flrdy:       rts       



             .EVEN 
imghdr:      .DC.w 1   ;Mystical number
             .DC.w 8   ;Header length in Bytes
             .DC.w 1   ;Bitplanes (1==monochrome)
             .DC.w 2   ;Pattern size in Bytes
             .DC.w 372 ;Pixel width in Micrometers
             .DC.w 372 ;Pixel height in Micrometers
             .EVEN 




;============================================================================
;
;
;qcount
;======
;Test how often a pattern (4 bytes) is repeated
;
; Input:
;       a0: Start address of memory block to be tested
;       d0: maximum length of block
;       d1: pattern to be tested
;
; Output:
;       a0: first deviant byte
;       d1: number of identical bytes
;
;Changed registers:  01234567
;                   D:::-----
;                   A:-------
;
;
qcount:      move.l    a0,d2                ;remember start position
             btst      #0,d2
             beq       .cnteven
.cntodd:     rol.l     #8,d1                ;uneven: push pattern
             cmp.b     (a0)+,d1             ;  test one byte
             bne       .cnteval             ;  finished if deviant
             dbf       d0,.cnteven          ;  adjust counter
             bra       .cntiseql            ;  end when finished
.cnteven:    ror.l     #2,d0                ;straight: go through with longs
             andi.w    #$3fff,d0            ;
             cmp.w     d0,d0                ;  prepare while loop and start
             bra       .cntltst
.cntlloop:   cmp.l     (a0)+,d1             ;  Test number of longs
.cntltst:    dbne      d0,.cntlloop         ;  for their identity
             beq       .cntword             ;  end even == max. another 3 bytes
             subq.l    #4,a0                ;  end uneven === test first 3 bytes
             moveq.l   #-1,d0
.cntword:    add.l     d0,d0                ;Test word if necessary
             bcc       .cntbyte             ;  no, then perhaps byte
             swap.w    d1                   ;  yes, then adjust pattern
             cmp.w     (a0)+,d1             ;      and test word
             beq       .cntbyte             ;      even, then continue with byte
             subq.l    #2,a0                ;    uneven, then test first byte
             moveq.l   #-1,d0
.cntbyte:    tst.l     d0                   ;Test byte, if necessary
             bpl       .cntiseql            ;  no then finished
             rol.l     #8,d1                ;  yes, then adjust pattern
             cmp.b     (a0)+,d1             ;      compare byte
             beq       .cntiseql            ;      even, then continue
.cnteval:    subq.l    #1,a0                ;    uneven, correct end
.cntiseql:   move.l    a0,d1                ;Finished:
             sub.l     d2,d1                ;    Return value: number of identical bytes >= 0
             rts       


;============================================================================
;
;qinsert        Inserting a pattern block (max. pattern length 4 bytes)
;
; Input:
;       a2: pointer insert start address
;       d0: length of pattern repeat in bytes
;       d1: pattern in d1.l, adjusted for even address
; Output:
;       a2: points to byte behind inserted block
;
; Changed registers:   01234567
;                     D:::-----
;                     A--:-----
;
qinsert:     move.l    a2,d2                ;Test memory shape
             btst      #0,d2
             beq       .inseven
.insodd:     rol.l     #8,d1                ;uneven: push pattern
             move.b    d1,(a2)+             ;  insert one byte to that address is even
             dbf       d0,.inseven          ;  correct length
             bra       .return              ;  finished
.inseven:    ror.l     #2,d0                ;even: counter div 4; remember remainder
             andi.w    #$3fff,d0
             bra       .insltst
.inslloop:   move.l    d1,(a2)+             ;insert correct number of longs
.insltst:    dbf       d0,.inslloop
.insword:    rol.l     #1,d0                ;another word missing ?
             bcc       .insbyte             ;  no, then perhaps byte
             swap.w    d1                   ;  yes, then adjust pattern
             move.w    d1,(a2)+             ;      and insert word
.insbyte:    tst.l     d0                   ;another byte missing ?
             bpl       .return              ;  no, then finished
             rol.l     #8,d1                ;  yes, then adjust pattern
             move.b    d1,(a2)+             ;      and insert byte
.return:     rts       



;==========================================================================
;
;qcopy
;=====
;Fast copy of memory block
;
; Input:
;       a0: Address of source block
;       a1: Address of destination block
;       d0: Length of block in bytes (0 <= length <= 3.145.727)
;           d0 is not checked for correct length!
;
; Output:
;       a0,a1: point to byte behind relevant block
;
; Changed registers:   01234567
;                     D:-------
;                     A::------
qcopy:       movem.l   d1-d7/a2-a6,-(sp)    ;save registers
             move.w    a0,d1                ;check adjustment of blocks
             move.w    a1,d2                ;  different ==> copy bytes
             andi.w    #1,d1                ;  both uneven ==> one byte, then as for even
             andi.w    #1,d2                ;  both even ==> copy block by block
             eor.w     d1,d2
             bne       .copybytes
             tst.w     d1
             beq       .copyeven
.copyodd:    move.b    (a0)+,(a1)+          ;uneven address: copy one byte
             subq.w    #1,d0                ;  adjust counter
             beq       .done                ;  and test end
.copyeven:   divu.w    #12*4,d0             ;even address: copy blocks of 48 bytes
             bra       .vlcpy               ;  descending loop
.vlloop:     movem.l   (a0)+,d1-d7/a2-a6    ;    each loop iteration copies 48 bytes
             movem.l   d1-d7/a2-a6,(a1)     ;    simulating writing with
             lea.l     12*4(a1),a1          ;    postincrement
.vlcpy:      dbf       d0,.vlloop           ;
             swap.w    d0                   ;look at remainder from division
             ext.l     d0                   ;  expand to full register
             ror.l     #2,d0                ;division by 4, remainder in bit 30,31
             bra       .lcpy                ;descending loop
.lloop:      move.l    (a0)+,(a1)+          ;copy counter div 4 longs
.lcpy:       dbf       d0,.lloop
.word:       lsl.l     #1,d0                ;a word left ?
             bcc       .byte                ;  no, then perhaps byte
             move.w    (a0)+,(a1)+          ;  yes, then copy word
.byte:       tst.l     d0                   ;a byte left?
             bpl       .done                ;  no, then finished
             move.b    (a0)+,(a1)+          ;  yes, then copy it
             bra       .done
;
;Blocks are either even or uneven, as bytes are used. Optimisation is not
;worth the effort.
;
.copybytes:  bra       .bytst               ;move memory block byte by byte
.bloop:      move.b    (a0)+,(a1)+          ; since otherwise an address error is generated
.bytst:      dbf       d0,.bloop            ;here loop lower word
             swap.w    d0                   ;look at higher part
             subq.w    #1,d0                ;lower it
             bcs       .done                ;smaller than zero, then finished
             swap.w    d0                   ;else: resort and
             bra       .bloop               ;repeat inner loop,
.done:       movem.l   (sp)+,d1-d7/a2-a6    ;finished
             rts                            ;then return



;============================================================================
;
;qcomp  Compare two memory sections
;=====
;
; Input:
;       a0,a1: start addressed of memory blocks
;          d0: length of blocks (maximum checked)
; Output:
;       ccr: (a1)-(a0) at first deviating position or at
;            last byte
;       a0,a1: points to first different byte
;              or to behind the last to be tested
;
; Changed registers:   01234567
;                     D:..-----
;                     A::------
;
qcomp:       cmpm.b    (a0)+,(a1)+          ;quickly test the simplest case
             bne       .return              ;  end if first byte already different
             subq.w    #1,d0                ;  correct counter
             beq       .return
;
;Memory blocks can now be identical for large parts. The routine was
;designed for large blocks. Execution time is saved where it is needed
;most.
;
             move.w    a0,d1                ;test block adjustments
             move.w    a1,d2                ;  even    ==> compare bytes
             andi.w    #1,d1                ;  both uneven ==> one byte, then as for even
             andi.w    #1,d2                ;  both uneven ==> compare long
             eor.w     d1,d2
             bne       .cmpbytes
             tst.w     d1
             beq       .cmpeven
.cmpodd:     cmpm.b    (a0)+,(a1)+          ;uneven: compare one byte
             bne       .return              ;       finished when uneven
             subq.w    #1,d0                ;     even: adjust counter
             beq       .return              ;          and test
.cmpeven:    ror.l     #2,d0                ;even: compare longs (4 bytes)
             andi.w    #$3fff,d0
             cmp.w     d0,d0                ; prepare and start the loop
             bra       .ltst
.lloop:      cmpm.l    (a0)+,(a1)+          ; test counter div 4 longs
.ltst:       dbne      d0,.lloop            ; for evenness
             bne       .return
.word:       add.l     d0,d0                ;a word remaining?
             bcc       .byte                ;  no, then perhaps a byte
             cmpm.w    (a0)+,(a1)+          ;  yes, then compare word
             bne       .return
.byte:       tst.l     d0                   ;a byte remaining?
             bpl       .return0             ;  no, then finished
             cmpm.b    (a0)+,(a1)+          ;  yes, then test this byte
.return:     rts                            ;  and back with this status
.return0:    cmp.w     d0,d0                ;Everything was even, so we return EQ.
             rts       
;
;Blocks are even or uneven, as bytes are used. Optimisation is not
;worth the effort.
;
.cmpbytes:   cmp.w     d0,d0                ;initialise and start loop
             bra       .bytst               ;  evenness of memory
.bloop:      cmpm.b    (a0)+,(a1)+          ;  block is tested with byte accesses.
.bytst:      dbne      d0,.bloop
             rts       


;===========================================================================


             .IFNE ALONE

;This code is only required for testing with a debugger.;
;
setup:       INITAPP 

             moveq.l   #0,d1                ;erase screen
             bsr       cls
             bsr       pattern              ;build pattern

             Malloc    $200000              ;claim memory
             lea.l     buff(pc),a0
             move.l    d0,(a0)

             move.w    #400,-(sp)           ;pack
             move.w    #640,-(sp)
             bsr       screen
             move.l    d0,-(sp)
             move.l    buff(pc),-(sp)
             move.w    #1,-(sp)
             bsr       imgcode
             lea.l     14(sp),sp

             move.w    #400,-(sp)           ;unpack
             move.w    #640,-(sp)
             move.l    buff(pc),-(sp)
             bsr       screen
             move.l    d0,-(sp)
             move.w    #0,-(sp)
             bsr       imgcode
             lea.l     14(sp),sp

             Mfree     buff(pc)             ;release memory

             EXITAPP 



pattern:     lea.l     file(pc),a0          ;build pattern:
             Fopen     a0,#0                ;  load picture
             tst.l     d0
             move.w    d0,handle
             bsr       screen
             Fread     handle(pc),#34,d0
             bsr       screen
             Fread     handle(pc),#32000,d0
             Fclose    handle(pc)
.done:       rts       

             .EVEN 
file:        .DC.b "e:\test.scn",0
             .EVEN 
handle:      .DC.w 0
             .EVEN 


cls:         bsr       screen               ;erase screen
             move.w    #32000/4-1,d0
.fill:       move.l    d1,(a0)+
             dbf       d0,.fill
             rts       

screen:      movem.l   d1-d7/a1-a7,-(sp)    ;fetch screen address
             Logbase 
             movem.l   (sp)+,d1-d7/a1-a7
             movea.l   d0,a0
             rts       

buff:        .DC.w 1

             .ENDC 



             .END 

