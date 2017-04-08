* last updated 05-1-91 by Tom Bajoras

* File Header

dc.b 'GENr'
dc.w 1,1

*
* copybits
*
* move contiguous streams of bits, 1 to 8 at a time, between two locations
* (in either Data or Edit Buffer)
* V94 = source buffer (0 data, 1 edit)
* V95 = destination buffer (0 data, 1 edit)
* V92 = table number
* V90 = source pre-offset
* V93 = destination pre-offset
* V91 = # bytes to be cleared in destination
* V96 = if non-0, exchange meaning of "source" and "destination"
* each entry in table is:
*   byte = # bits (1-8, 0=end of table)
*   byte = lowest source bit used
*   word = source offset
*   byte = lowest destination bit used
*   word = destination offset
*
dc.l 37
dc.l L000x-L000
L000:
dc.b 'copybits',0,0
        move.l  a2,a0           ; move Edit Buffer pointer out of A2
        move.l  a3,a2           ; for now, source and dest = Data Buffer
        tst.l   94*4(a6)        ; if V94 nonzero, source = Edit Buffer
        beq     .srceset
        move.l  a0,a2           ; (A2 = source)
.srceset:
        tst.l   95*4(a6)        ; if V95 nonzero, dest = Edit Buffer
        beq     .destset
        move.l  a0,a3           ; (A3 = dest)
.destset:
        move.l  92*4(a6),d2     ; init pointer to user's parameter map table
        subq.w  #1,d2
        asl.w   #2,d2
        move.l  0(a1,d2.w),a1
        adda.l  90*4(a6),a2     ; pre-offset into source
        adda.l  93*4(a6),a3     ; pre-offset into destination
        move.l  91*4(a6),d0
        beq     .bitcpygo       ; don't preclear if V91 = 0
        subq.w  #1,d0
        move.l  a3,a0
.bitcpycl:
        clr.b   (a0)+
        dbf     d0,.bitcpycl
.bitcpygo:
        lea     bitmasks(pc),a4 ; init pointer to bitmasks table
.bitcpylp:
        moveq   #0,d2           ; start of loop; guarantee bytes = longs
        moveq   #0,d3
        moveq   #0,d4
        moveq   #0,d5
        moveq   #0,d7
        move.b  (a1)+,d3        ; number of bits
        beq     .bitcpylx       ; exit loop if 0
        move.b  0(a4,d3.w),d4   ; look up corresponding bit mask
        move.b  (a1)+,d2        ; lowest source bit used
        move.b  (a1)+,d6        ; source buffer offset
        lsl.w   #8,d6           ;   (word, but often at odd address)
        move.b  (a1)+,d6
        move.b  (a1)+,d5        ; lowest dest bit used
        move.b  (a1)+,d1        ; dest buffer offset
        lsl.w   #8,d1           ;   (word, but often at odd address)
        move.b  (a1)+,d1

        tst.l   96*4(a6)
		  beq     .bitnoswap
        exg     d2,d5
        exg     d1,d6
.bitnoswap:

        move.b  (a2,d6.w),d7    ; get data from source
        lsr.b   d2,d7           ; shift into right-aligned position
        and.b   d4,d7           ; mask off unused bits
        lsl.w   d5,d7           ; shift into lowest bit used position
        lsl.w   d5,d4           ; shift mask also
        move.w  d4,d3
        not.w   d3              ; invert mask
        move.b  0(a3,d1.w),d0   ; get destination
        and.b   d3,d0           ; mask out conflicting bits from destination
        or.b    d7,d0           ; combine source data bits with destination
        move.b  d0,0(a3,d1.w)   ; put destination back into buffer
        bra     .bitcpylp       ; go around loop until table ends
.bitcpylx:
        rts                     ; all done!
L000x:

* un-ascii
*
* input: V12 = byte offset to source in data buffer
*        V10 = byte offset to target in data buffer
*        V99 = number of bytes in target

dc.l 37
dc.l L001x-L001
L001:
dc.b 'un-ascii',0,0
        move.l  a3,a2
        adda.l  12*4(a6),a2     ; --> source
        adda.l  10*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # bytes in target
.loop:
        move.b  (a2)+,d0        ; ascii high nibble
        bsr     .denibble
        lsl.b   #4,d0
        move.b  d0,d1
        move.b  (a2)+,d0        ; ascii low nibble
        bsr     .denibble
        or.b    d1,d0
        move.b  d0,(a3)+
        subq.l  #1,d7
        bgt     .loop
        rts
.denibble:
        cmpi.b  #'9',d0
        ble     .le9
        subi.b  #'A',d0
        addi.b  #10,d0
        rts
.le9:
        subi.b  #'0',d0
        rts
L001x:

* 8_into_7
*
* If the 7 native bytes are A through G, then this routine assumes
* they're sent over MIDI as:
*
*   0 G7 F7 E7 D7 C7 B7 A7
*   0 A6 A5 A4 A3 A2 A1 A0
*   ...
*   0 G6 G5 G4 G3 G2 G1 G0
*
* input: V12 = byte offset to source in data buffer
*        V10 = byte offset to target in data buffer
*        V99 = number of groups of 8 packed bytes

dc.l 37
dc.l L002x-L002
L002:
dc.b '8_into_7',0,0
        move.l  a3,a2
        adda.l  12*4(a6),a2     ; --> source
        adda.l  10*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # packed groups
.loop1:
        move.b  (a2)+,d0
        lsl.w   #8,d0
        moveq   #7,d6
.loop2:
        andi.w  #$FF00,d0
        lsr.w   #1,d0
        move.b  (a2)+,d1
        or.w    d0,d1
        move.b  d1,(a3)+
        subq.w  #1,d6
        bgt     .loop2
        subq.l  #1,d7
        bgt     .loop1
        rts
L002x:

* 7_into_8
*
* input: V12 = byte offset to target in data buffer
*        V10 = byte offset to source in data buffer
*        V99 = number of groups of 7 unpacked bytes

dc.l 37
dc.l L003x-L003
L003:
dc.b '7_into_8',0,0
        move.l  a3,a2
        adda.l  12*4(a6),a2     ; --> target
        adda.l  10*4(a6),a3     ; --> source
        move.l  99*4(a6),d7     ; # unpacked groups
.loop1:
        move.l  a2,a1           ; --> head byte
        addq.w  #1,a2           ; skip head byte
        clr.w   d1
        moveq   #7,d6
.loop2:
        move.b  (a3)+,d0
        move.b  d0,d2
        andi.b  #%10000000,d2
        or.b    d2,d1
        lsr.w   #1,d1
        andi.b  #%01111111,d0
        move.b  d0,(a2)+
        subq.w  #1,d6
        bgt     .loop2
        move.b  d1,(a1)
        subq.l  #1,d7
        bgt     .loop1
        rts
L003x:

* deniblLH
*
* input: V12 = byte offset to source in data buffer
*        V10 = byte offset to target in data buffer
*        V99 = number of bytes resulting in target

dc.l 37
dc.l L004x-L004
L004:
dc.b 'deniblLH',0,0
        move.l  a3,a2
        adda.l  12*4(a6),a2     ; --> source
        adda.l  10*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # bytes in result
.loop:
        move.b  (a2)+,d0
        andi.b  #$0F,d0
        move.b  (a2)+,d1
        lsl.b   #4,d1
        or.b    d0,d1
        move.b  d1,(a3)+
        subq.l  #1,d7
        bgt     .loop
        rts
L004x:

* uppercas
*
* input: V90 = offset to name in edit buffer
*        V91 = how many characters in name

dc.l 37
dc.l L005x-L005
L005:
dc.b 'uppercas',0,0
        move.l  90*4(a6),d2
        adda.l  d2,a2
        move.l  91*4(a6),d1
        subq.w  #1,d1
upperclp:
        cmpi.b  #$60,(a2)
        blt     notupper
        subi.b  #$20,(a2)
notupper:
        cmpi.b  #$20,(a2)
        bge     notcntrl
        move.b  #$20,(a2)
notcntrl:
        addq.l  #1,a2
        dbf     d1,upperclp
        rts
L005x:

* bitunpack
*
* Table 2 in Common Segment is an array of structures,
* indexed by edit buffer offset:
* byte:  number of bits
* byte:  bit # in native format byte corresponding to bit 0 in parameter
* lowest bit used       byte
* data buffer offset    word
* The end of the array is indicated by the "number of bits" being set to 0.

dc.l 37
dc.l L006x-L006
L006:
dc.b 'bitunpack',0
        move.l  15*4(a1),a1     ; init pointer to user's parameter map table
        move.l  201*4(a6),d1    ; max nr table entries = ELN
bitunpack:
        adda.l  90*4(a6),a3
        lea     bitmasks(pc),a4 ; init pointer to bitmasks table
        subq.w  #1,d1           ; set up loop counter for dbf
.bitunplp:
        moveq   #0,d3           ; start of loop; guarantee bytes = longs
        moveq   #0,d4
        moveq   #0,d5
        moveq   #0,d6
        move.b  (a1)+,d3        ; number of bits
        beq     .bitunplx       ; exit loop if 0
        move.b  0(a4,d3.w),d4   ; look up corresponding bit mask
        move.b  (a1)+,d5        ; lowest bit used
        move.b  (a1)+,d6        ; data buffer offset
        asl.w   #8,d6           ;   (word, but often at odd address)
        move.b  (a1)+,d6
        move.b  (a1)+,d0        ; sign-extend flag
        cmp.l   200*4(a6),d6    ; max data buffer offset = DLN
        bge     seterr          ; abort with ERR set if beyond end

        move.b  0(a3,d6.w),d7   ; get 1st byte from data buffer
        lsr.b   d5,d7           ; align (shift right so lowest bit = bit 0)
        and.b   d4,d7           ; mask off bits not for this parameter
        add.b   d3,d5           ; calc nr of bits left to get from next byte
        subq.b  #8,d5
        tst.b   d5
        ble     .bitunpex       ; if 1 or more bits left over:
        move.b  0(a4,d5.w),d4   ;   loop up bit mask
        move.b  1(a3,d6.w),d2   ;   get 2nd byte from data buffer
        sub.b   d5,d3           ;   calc nr of bits obtained from 1st byte
        and.b   d4,d2           ;   mask off other bits
        lsl.b   d3,d2           ;   shift upper bits of parameter left
        or.b    d2,d7           ;   combine upper bits with lower bits
        add.b   d5,d3           ;   restore total nr of bits (for sign extd)
.bitunpex:
        tst.b   d0              ; if sign-extend required:
        beq     .bitunppk
        moveq   #8,d0           ;   calc nr of bits to extend by
        sub.b   d3,d0
        lsl.b   d0,d7           ;   shift left (logical), then
        asr.b   d0,d7           ;   shift right arithmetic
.bitunppk:
        move.b  d7,(a2)+        ; put assembled parameter into edit buffer

        dbf     d1,.bitunplp    ; go around loop if more edit buffer left
.bitunplx:
        rts                     ; all done!
bitmasks:
        dc.b    0,1,3,7,15,31   ; number of bits -> bit mask
        dc.b    63,127,255
        dc.b    0               ; make this routine an even length
L006x:

*
* bitpack
*
* pack a set of edit buffer parameters, which can start in any bit
* position ("lowest bit used") of any byte ("data buffer offset")
* of the data buffer (edit buffer if called from SendEdit segment)
* and can continue for 1 to 8 bits ("number of bits"), crossing
* into the low-order bits of the next byte if necessary

dc.l 37
dc.l L007x-L007
L007:
dc.b 'bitpack',0
        move.l  15*4(a1),a1     ; init pointer to user's parameter map table
        move.l  201*4(a6),d1    ; max nr table entries = ELN
bitpack:
        adda.l  90*4(a6),a3
        move.l  91*4(a6),d0
        subq.w  #1,d0
        move.l  a3,a0
.bitpaccl:
        clr.b   (a0)+
        dbf     d0,.bitpaccl

        lea     bitmasks(pc),a4 ; init pointer to bitmasks table
        subq.w  #1,d1           ; set up loop counter for dbf
.bitpaclp:
        moveq   #0,d3           ; start of loop; guarantee bytes = longs
        moveq   #0,d4
        moveq   #0,d5
        moveq   #0,d6
        move.b  (a1)+,d3        ; number of bits
        beq     .bitpaclx       ; exit loop if 0
        move.b  0(a4,d3.w),d4   ; look up corresponding bit mask
        move.b  (a1)+,d5        ; lowest bit used
        move.b  (a1)+,d6        ; data buffer offset
        asl.w   #8,d6           ;   (word, but often at odd address)
        move.b  (a1)+,d6
        addq.l  #1,a1           ; skip over sign-extend flag
        cmp.l   200*4(a6),d6    ; max data buffer offset = DLN
        bge     seterr          ; abort with ERR set if beyond end

        move.b  (a2)+,d7        ; get assembled parameter from edit buffer
        and.b   d4,d7           ; mask off unused bits (eg, sign extension)
        lsl.w   d5,d7           ; shift into lowest bit used position
        lsl.w   d5,d4           ; shift mask also
        move.w  d4,d3
        not.w   d3              ; invert mask
        move.b  0(a3,d6.w),d2   ; get 1st byte from data buffer
        and.b   d3,d2           ; mask out existing bits of this parameter
        or.b    d7,d2           ; combine parameter bits with 1st byte
        move.b  d2,0(a3,d6.w)   ; put 1st byte back into data buffer
        lsr.w   #8,d4           ; shift original mask right one byte
        beq     .bitpacrp       ; if 1 of more bits left over:
        lsr.w   #8,d3           ;   shift inverted mask
        lsr.w   #8,d7           ;   shift parameter byte
        move.b  1(a3,d6.w),d2   ;   get 2nd byte from data buffer
        and.b   d3,d2           ;   mask out existing bits
        or.b    d7,d2           ;   combine parameter bits with 2nd byte
        move.b  d2,1(a3,d6.w)   ;   put 2nd byte back
.bitpacrp:
        dbf     d1,.bitpaclp    ; go around loop if more edit buffer left
.bitpaclx:
        rts                     ; all done!
seterr:
        moveq   #-1,d0
        move.l  d0,107*4(a6)    ; set ERR = -1 to cause abort upon return
        rts
L007x:

* convchar
*
* Expects V90 = NMO
*         V91 = NML
*         V92 = table nr
* The table is an array of bytes, indexed by input-format character byte,
* producing output-format character byte.  In the case where "convchar"
* and "uncnvchr" are both used, "convchar" is Native-to-ASCII conversion,
* via simple lookup; and "uncnvchr" is ASCII-to-native conversion is
* reverse lookup (using same Table) via search.  In cases where only
* "convchar" is used (in GetPatch), it's also a simple lookup but it
* could be in the ASCII-to-native direction.

dc.l 37
dc.l L008x-L008
L008:
dc.b 'convchar',0,0
        moveq   #0,d0           ; guarantee high bits = 0
        move.l  92*4(a6),d2     ; init pointer to user's character map table
        subq.w  #1,d2
        asl.w   #2,d2
        move.l  0(a1,d2.w),a1
        move.l  90*4(a6),d2     ; offset for 1st char into Edit Buffer
        adda.l  d2,a2
        move.l  91*4(a6),d1     ; nr of chars to process
        subq.w  #1,d1
cnvchrlp:
        move.b  (a2),d0         ; get input character
        move.b  0(a1,d0.w),(a2)+ ; replace with output character from table
        dbf     d1,cnvchrlp     ; repeat for each character in name
        rts
L008x:

* nibbleLH
*
* input: V10 = byte offset to source in data buffer
*        V12 = byte offset to target in data buffer
*        V99 = number of bytes in source

dc.l 37
dc.l L009x-L009
L009:
dc.b 'nibbleLH',0,0
        move.l  a3,a2
        adda.l  10*4(a6),a2     ; --> source
        adda.l  12*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # bytes in source
.loop:
        move.b  (a2)+,d0
        move.b  d0,d1
        and.b   #$F,d1
        move.b  d1,(a3)+
        lsr.b   #4,d0
        move.b  d0,(a3)+
        subq.l  #1,d7
        bgt     .loop
        rts
L009x:

* checksum
*
* Usage:
*   V90 = pointer to bytes to checksum (in data buffer)
*   V91 = count of bytes to checksum
*   var = Execute "checksum"

dc.l 37
dc.l L010x-L010
L010:
dc.b 'checksum',0,0
        move.l  90*4(a6),d2
        adda.l  d2,a3
        move.l  91*4(a6),d1
        moveq   #0,d0
.chksumlp:
        add.b   (a3)+,d0
        subq.l  #1,d1
        bgt     .chksumlp
        rts
L010x:

* uncnvchr
*
* Expects V90 = NMO
*         V91 = NML
*         V92 = table nr
*         V93 = table length (needed this direction of conversion only)
* See notes for "convchar".

dc.l 37
dc.l L011x-L011
L011:
dc.b 'uncnvchr',0,0
        moveq   #0,d0           ; guarantee high bits = 0
        move.l  92*4(a6),d2     ; init pointer to user's character map table
        subq.w  #1,d2
        asl.w   #2,d2
        move.l  0(a1,d2.w),a1
        move.l  90*4(a6),d2     ; offset for 1st char into Edit Buffer
        adda.l  d2,a2
        move.l  91*4(a6),d1     ; nr of chars to process
        subq.w  #1,d1
unconvlp:
        move.b  (a2),d0         ; get ASCII character
        bsr     findasc         ; find this ASCII character in table
        tst.w   d2              ; if found, native char = d2 >= 0
        bpl     unconvfn
        moveq   #32,d0          ; if no match, find match for space instead
        bsr     findasc
unconvfn:
        move.b  d2,(a2)+        ; substitute native character into name
        dbf     d1,unconvlp     ; repeat for each character in name
        rts

findasc:
        move.l  93*4(a6),d2     ; over length of table,
        subq.w  #1,d2
fndasclp:
        cmp.b   0(a1,d2.w),d0   ;   compare table byte against ASCII char
        beq     fndascrt        ;   if found, return w/ d2 = native char
        dbf     d2,fndasclp
fndascrt:                       ; if not found, d2.w is minus
        rts
L011x:

* DWtoEB
*
* Usage:
*   V10 --> first data buffer source word
*   V19 --> first edit buffer destination byte
*   v99 = number of words to be copied

dc.l 37
dc.l L012x-L012
L012:
dc.b 'DW_to_EB',0,0
        move.l  10*4(a6),d0
        lsl.w   #1,d0           ; words
        adda.l  d0,a3           ; --> source
        move.l  19*4(a6),d0
        adda.l  d0,a2           ; --> destination
        move.l  99*4(a6),d0     ; number of words
.loop:
        move.w  (a3)+,d1
        move.b  d1,(a2)+
        subq.l  #1,d0
        bgt     .loop
        rts
L012x:

* EBtoDW
*
* Usage:
*   V10 --> first data buffer destination word
*   V19 --> first edit buffer source byte
*   v99 = number of words to be copied

dc.l 37
dc.l L013x-L013
L013:
dc.b 'EB_to_DW',0,0
        move.l  10*4(a6),d0
        lsl.w   #1,d0           ; words
        adda.l  d0,a3           ; --> destination
        move.l  19*4(a6),d0
        adda.l  d0,a2           ; --> source
        move.l  99*4(a6),d0     ; number of words
.loop:
        clr.w   d1
        move.b  (a2)+,d1
        move.w  d1,(a3)+
        subq.l  #1,d0
        bgt     .loop
        rts
L013x:

* random
*
* Usage:
*   V98 = low end of range (can be "negative")
*   V99 = high end of range
*   size of range evaluated as word
*   returns random number between V98 and V99 inclusive

dc.l 37
dc.l L014x-L014
L014:
dc.b 'random',0,0
    move.w  #17,-(a7)       ; get random number from TOS in d0
    trap    #14
    addq.l  #2,a7
    andi.l  #$1FFFF,d0      ; make sure divide won't overflow
    move.l  98*4(a6),d1     ; get low end of range
    move.l  99*4(a6),d2     ; get high end of range
    addq.l  #1,d2           ; add 1 to high end for "inclusive"
    sub.w   d1,d2           ; compute size of range
    beq     rand2zer
    divu    d2,d0           ; divide random by range to get remainder
rand2zer:
    clr.w   d0
    swap    d0
    add.l   d1,d0           ; add low end to shift into desired range
    rts
L014x:

* nibbleHL
*
* input: V10 = byte offset to source in data buffer
*        V12 = byte offset to target in data buffer
*        V99 = number of bytes in source

dc.l 37
dc.l L015x-L015
L015:
dc.b 'nibbleHL',0,0
        move.l  a3,a2
        adda.l  10*4(a6),a2     ; --> source
        adda.l  12*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # bytes in source
.loop:
        move.b  (a2)+,d0
        move.b  d0,d1
        and.b   #$F,d1
        lsr.b   #4,d0
        move.b  d0,(a3)+
        move.b  d1,(a3)+
        subq.l  #1,d7
        bgt     .loop
        rts
L015x:

* deniblHL
*
* input: V12 = byte offset to source in data buffer
*        V10 = byte offset to target in data buffer
*        V99 = number of bytes resulting in target

dc.l 37
dc.l L016x-L016
L016:
dc.b 'deniblHL',0,0
        move.l  a3,a2
        adda.l  12*4(a6),a2     ; --> source
        adda.l  10*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # bytes in result
.loop:
        move.b  (a2)+,d0
        lsl.b   #4,d0
        move.b  (a2)+,d1
        or.b    d0,d1
        move.b  d1,(a3)+
        subq.l  #1,d7
        bgt     .loop
        rts
L016x:

* nibble71
*
* input: V10 = byte offset to source in data buffer
*        V12 = byte offset to target in data buffer
*        V99 = number of bytes in source

dc.l 37
dc.l L017x-L017
L017:
dc.b 'nibble71',0,0
        move.l  a3,a2
        adda.l  10*4(a6),a2     ; --> source
        adda.l  12*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # bytes in source
.loop:
        move.b  (a2)+,d0
        move.b  d0,d1
        and.b   #$7F,d1
        lsr.b   #7,d0
        move.b  d1,(a3)+
        move.b  d0,(a3)+
        subq.l  #1,d7
        bgt     .loop
        rts
L017x:

* denibl71
*
* input: V12 = byte offset to source in data buffer
*        V10 = byte offset to target in data buffer
*        V99 = number of bytes resulting in target

dc.l 37
dc.l L018x-L018
L018:
dc.b 'denibl71',0,0
        move.l  a3,a2
        adda.l  12*4(a6),a2     ; --> source
        adda.l  10*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # bytes in result
.loop:
        move.b  (a2)+,d0
        move.b  (a2)+,d1
        lsl.b   #7,d1
        or.b    d0,d1
        move.b  d1,(a3)+
        subq.l  #1,d7
        bgt     .loop
        rts
L018x:

* 7L7Hto14
*
* input: V12 = byte offset to source in data buffer
*        V10 = byte offset to target in data buffer
*        V99 = number of words in source

dc.l 37
dc.l L019x-L019
L019:
dc.b '7L7Hto14',0,0
        move.l  a3,a2
        adda.l  12*4(a6),a2     ; --> source
        adda.l  10*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # words to process
.loop:
        clr.w   d1
        move.b  (a2)+,d1
        clr.w   d0
        move.b  (a2)+,d0
        lsl.w   #7,d0
        or.w    d1,d0
        move.b  d0,d1
        lsr.w   #8,d0
        move.b  d0,(a3)+
        move.b  d1,(a3)+
        subq.l  #1,d7
        bgt     .loop
        rts
L019x:

* 14to7L7H
*
* input: V10 = byte offset to source in data buffer
*        V12 = byte offset to target in data buffer
*        V99 = number of words resulting in target

dc.l 37
dc.l L020x-L020
L020:
dc.b '14to7L7H',0,0
        move.l  a3,a2
        adda.l  10*4(a6),a2     ; --> source
        adda.l  12*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # words to process
.loop:
        move.b  (a2)+,d0
        lsl.w   #8,d0
        move.b  (a2)+,d0
        move.b  d0,d1
        andi.b  #$7F,d1
        move.b  d1,(a3)+
        lsr.w   #7,d0
        andi.b  #$7F,d0
        move.b  d0,(a3)+
        subq.l  #1,d7
        bgt     .loop
        rts
L020x:

* bitpack2
*
* same as "bitpack" except uses any Table number (in V92)
*                    and offset into Edit Buffer (in V93)

dc.l 37
dc.l L021x-L021
L021:
dc.b 'bitpack2',0,0
        move.l  92*4(a6),d2     ; init pointer to user's parameter map table
        subq.w  #1,d2
        asl.w   #2,d2
        move.l  0(a1,d2.w),a1
        adda.l  93*4(a6),a2     ; offset into Edit Buffer before packing
        move.l  201*4(a6),d1    ; max nr table entries = ELN - offset
        sub.l   93*4(a6),d1
        bra     bitpack
L021x:

* bitunpack2
*
* same as "bitunpack" except uses any Table number (in V92)
*                      and offset into Edit Buffer (in V93)

dc.l 37
dc.l L022x-L022
L022:
dc.b 'bitunpack2',0,0
        move.l  92*4(a6),d2     ; init pointer to user's parameter map table
        subq.w  #1,d2
        asl.w   #2,d2
        move.l  0(a1,d2.w),a1
        adda.l  93*4(a6),a2     ; offset into Edit Buffer before unpacking
        move.l  201*4(a6),d1    ; max nr table entries = ELN - offset
        sub.l   93*4(a6),d1
        bra     bitunpack
L022x:

* checksum2
*
* Usage:
*   V90 = pointer to bytes to checksum (in data buffer)
*   V91 = count of bytes to checksum
*   var = Execute "checksum2"

dc.l 37
dc.l L023x-L023
L023:
dc.b 'checksum2',0
        move.l  90*4(a6),d2
        adda.l  d2,a3
        move.l  91*4(a6),d1
        moveq   #0,d0
		  moveq   #0,d2
.chksumlp:
        rol.w   #1,d0
		  move.b  (a3)+,d2
        add.w   d2,d0
        subq.l  #1,d1
        bgt     .chksumlp
        rts
L023x:

* swapbyte - swap low and high bytes in each word in data buffer
*
* Usage:
*   V10 = byte offset of source, in data buffer
*   V12 = byte offset of destination, in data buffer
*   V99 = the number of 16 bit words to process.
*   var = Execute "swapbyte"
*

dc.l 37
dc.l L024x-L024
L024:
dc.b 'swapbyte',0,0
        move.l  a3,a2
        move.l  10*4(a6),d0
        adda.l  d0,a3             ; source
        move.l  12*4(a6),d0
		  adda.l  d0,a2             ; destination
        move.l  99*4(a6),d0       ; how many words
.swaploop:
        move.w  (a3)+,d1          ; xxyy
        move.w  d1,d2             ; xxyy
        lsl.w   #8,d2             ; yy00
		  lsr.w   #8,d1             ; 00xx
        or.w    d2,d1             ; yyxx
        move.w  d1,(a2)+
        subq.l  #1,d0
        bgt     .swaploop
        rts
L024x:

* AddWord - add a value to words in data buffer
*
* Usage:
*   V10 = byte offset of source, in data buffer
*   V12 = byte offset of destination, in data buffer
*   V98 = value to be added to each word
*   V99 = the number of 16 bit words to process.
*   var = Execute "AddWord"
*

dc.l 37
dc.l L025x-L025
L025:
dc.b 'AddWord',0
        move.l  a3,a2
        move.l  10*4(a6),d0
        adda.l  d0,a3             ; source
        move.l  12*4(a6),d0
		  adda.l  d0,a2             ; destination
        move.l  99*4(a6),d0       ; how many words
		  move.w  98*4(a6),d2       ; value to be added
.addlp:
        move.w  (a3)+,d1
		  add.w   d2,d1
		  move.w  d1,(a2)+
        subq.l  #1,d0
        bgt     .addlp
        rts
L025x:

* nibbleSDS - convert a 16 bit word into 3 nibblized bytes used by
* the sample dump standard as follows:
* Input = abcdefgh ijklmnop     Output = 0abcdefg 0hijklmn 0op00000
*
* Usage:
*   V10 = byte offset of source, in data buffer
*   V12 = byte offset of destination, in data buffer
*   V99 = the number of 16 bit words to process.
*   var = Execute "nibbleSDS"
*

dc.l 37
dc.l L026x-L026
L026:
dc.b 'nibbleSDS',0
        move.l  a3,a2
        move.l  10*4(a6),d0
        adda.l  d0,a3             ; source
        move.l  12*4(a6),d0
		  adda.l  d0,a2             ; destination
        move.l  99*4(a6),d0       ; how many words
.nibSDSlp:
        move.w  (a3)+,d1          ; abcdefghijklmnop
        move.w  d1,d2
		  lsr.w   #8,d2
		  lsr.w   #1,d2             ; 000000000abcdefg
		  move.b  d2,(a2)+
        move.w  d1,d2             ; abcdefghijklmnop
		  lsr.w   #2,d2             ; 00abcdefghijklmn
		  andi.w  #$7F,d2           ; 000000000hijklmn
		  move.b  d2,(a2)+
		  lsl.w   #5,d1             ; fghijklmnop00000
		  andi.w  #$7F,d1           ; 000000000op00000
		  move.b  d1,(a2)+
        subq.l  #1,d0
        bgt     .nibSDSlp
        rts
L026x:

* filldata - fill data buffer with a byte value
*
* Usage:
*   V10 = byte offset to start of data buffer to be filled
*   V12 = value to be filled (0-255)
*   V99 = the number of bytes to fill
*   Execute "filldata"
*

dc.l 37
dc.l L027x-L027
L027:
dc.b 'filldata',0,0
        move.l  10*4(a6),d2
        adda.l  d2,a3				; --> where to fill
        move.l  12*4(a6),d1		; value to fill with
        move.l  99*4(a6),d0      ; number of bytes to be filled
.fillloop:
        move.b  d1,(a3)+
        subq.l  #1,d0
        bgt     .fillloop
        rts
L027x:

* filledit - fill edit buffer with a byte value
*
* Usage:
*   V10 = byte offset to start of edit buffer to be filled
*   V12 = value to be filled (0-255)
*   V99 = the number of bytes to fill
*   Execute "filledit"
*

dc.l 37
dc.l L028x-L028
L028:
dc.b 'filledit',0,0
        move.l  10*4(a6),d2
        adda.l  d2,a2				; --> where to fill
        move.l  12*4(a6),d1		; value to fill with
        move.l  99*4(a6),d0      ; number of bytes to be filled
.fillloop:
        move.b  d1,(a2)+
        subq.l  #1,d0
        bgt     .fillloop
        rts
L028x:

* wordsumE
*
* Usage:
*   V90 = byte offset to words to checksum (in edit buffer), must be even
*         bytes are in reverse ("Intel") order within each word
*   V91 = count of words to checksum
*   var = Execute "wordsumE"

dc.l 37
dc.l L029x-L029
L029:
dc.b 'wordsumE',0,0
        move.l  90*4(a6),d2
        adda.l  d2,a2
        move.l  91*4(a6),d1
        moveq   #0,d0
.chksumlp:
        move.b  1(a2),d2
		  lsl.w   #8,d2
		  move.b  (a2),d2
		  addq.w  #2,a2
        add.w   d2,d0
        subq.l  #1,d1
        bgt     .chksumlp
        rts
L029x:

* 8_into_7b
*
* If the 7 native bytes are A through G, then this routine assumes
* they're sent over MIDI as:
*
*   0 A7 A6 A5 A4 A3 A2 A1
*   0 A0 B7 B6 B5 B4 B3 B2
*   0 B1 B0 C7 C6 C5 C4 C3
*   ...
*   0 G6 G5 G4 G3 G2 G1 G0
*
* input: V12 = byte offset to source in data buffer
*        V10 = byte offset to target in data buffer
*        V99 = number of groups of 8 packed bytes

dc.l 37
dc.l L030x-L030
L030:
dc.b '8_into_7b',0
        move.l  a3,a2
        adda.l  12*4(a6),a2     ; --> source
        adda.l  10*4(a6),a3     ; --> target
        move.l  99*4(a6),d7     ; # packed groups
.loop1:
        bsr     read4raw
        lsl.l   #4,d1
        bsr     writelong
        subq.l  #1,a3
        lsr.l   #4,d1
        bsr     read4raw
        bsr     writelong
        subq.l  #1,d7
        bgt     .loop1
        rts
read4raw:
        moveq   #3,d6           ; get 4 raw bytes
.loop2:
        lsl.l   #7,d1
        move.b  (a2)+,d0
        or.b    d0,d1
        dbf     d6,.loop2
        rts        
writelong:
        moveq   #3,d6           ; write long which may be at odd address
.loop3:
        rol.l   #8,d1
        move.b  d1,(a3)+
        dbf     d6,.loop3
        rts
L030x:

* 7_into_8b
*
* input: V12 = byte offset to target in data buffer
*        V10 = byte offset to source in data buffer
*        V99 = number of groups of 7 unpacked bytes

dc.l 37
dc.l L031x-L031
L031:
dc.b '7_into_8b',0
        move.l  a3,a2
        adda.l  12*4(a6),a2     ; --> target
        adda.l  10*4(a6),a3     ; --> source
        move.l  99*4(a6),d7     ; # unpacked groups
.loop1:
        bsr     readlong
        subq    #1,a3
        bsr     write4raw
        bsr     readlong
        lsl.l   #4,d1
        bsr     write4raw
        subq.l  #1,d7
        bgt     .loop1
        rts
readlong:
        moveq   #3,d6          ; read long which may be at odd address
.loop2:
        lsl.l   #8,d1       
        move.b  (a3)+,d1
        dbf     d6,.loop2
        rts
write4raw:
        moveq   #3,d6           ; write 4 raw bytes
.loop3:
        rol.l   #7,d1
        move.b  d1,d0
        andi.b  #$7F,d0
        move.b  d0,(a2)+
        dbf     d6,.loop3
        rts
L031x:

*
* abs_to_sign
*
* converts absolute-value-plus-sign data (in either Data or Edit Buffer)
* to signed (2's complement)

dc.l 37
dc.l L033x-L033
L033:
dc.b 'abs_to_sign',0
        move.l  91*4(A6),D0         ;V91 = buffer to use
        bne     .editbuf
        move.l  A3,A4               ;0 = data buffer
        bra     .offset
.editbuf:
        move.l  A2,A4               ;1 = edit buffer
.offset:
        move.l  90*4(A6),D0         ;V90 = buffer offset
        adda.l  D0,A4               ;A4 points at initial start of data

        move.l  92*4(A6),D0         ;V92 = table number
        subq.l  #1,D0
        asl.w   #2,D0
        move.l  0(A1,D0.w),A1       ;A1 points to start of table

        move.l  93*4(A6),D5         ;V93 = bit used for sign flag (0-31)

.nextset:
        move.b  (A1)+,D2            ;D2 = data size
        bne     .HLoff
        rts                         ;that's it folks!

.HLoff:
        move.b  (A1)+,D3            ;assemble H and L
        asl.w   #8,D3
        move.b  (A1)+,D3
        tst.w   D3                  ;D3 = offset
        bmi     .nextset            ;no negative offsets

        cmpi.b  #1,D2               ;byte
        beq     ._byte
        cmpi.b  #2,D2               ;word
        beq     ._word
        cmpi.b  #4,D2               ;long
        beq     ._long
        bra     .nextset            ;bad size

._byte:
        move.b  0(A4,D3.w),D4       ;fetch val
		  bclr    D5,D4
        beq     .__byte             ;do nothing if flag bit wasn't set
        neg.b   D4                  ;negate (assume no bits left of flag bit)
        move.b  D4,0(A4,D3.w)       ;store
.__byte:
        bra     .nextset            ;another

._word:
        move.w  0(A4,D3.w),D4
		  bclr    D5,D4
        beq     .__word
        neg.w   D4
        move.w  D4,0(A4,D3.w)
.__word:
        bra     .nextset

._long:
        move.l  0(A4,D3.w),D4
        bclr    D5,D4
        beq     .__long
        neg.l   D4
        move.l  D4,0(A4,D3.w)
.__long:
        bra     .nextset
L033x:

*
* sign_to_abs
*
* converts signed data to absolute value plus sign

dc.l 37
dc.l L034x-L034
L034:
dc.b 'sign_to_abs',0
        move.l  91*4(A6),D0         ;V91 = buffer to use
        bne     .editbuf
        move.l  A3,A4               ;0 = data buffer
        bra     .offset
.editbuf:
        move.l  A2,A4               ;1 = edit buffer
.offset:
        move.l  90*4(A6),D0         ;V90 = buffer offset
        adda.l  D0,A4               ;A4 points at initial start of data

        move.l  92*4(A6),D0         ;V92 = table number
        subq.l  #1,D0
        asl.w   #2,D0
        move.l  0(A1,D0.w),A1       ;A1 points to start of table

        move.l  93*4(A6),D5         ;V93 = bit used for sign flag (0-31)

.nextset:
        move.b  (A1)+,D2            ;D2 = data size
        bne     .HLoff
        rts                         ;that's it folks!

.HLoff:
        move.b  (A1)+,D3            ;assemble H and L
        asl.w   #8,D3
        move.b  (A1)+,D3
        tst.w   D3                  ;D3 = offset
        bmi     .nextset            ;no negative offsets

        cmpi.b  #1,D2               ;byte
        beq     ._byte
        cmpi.b  #2,D2               ;word
        beq     ._word
        cmpi.b  #4,D2               ;long
        beq     ._long
        bra     .nextset            ;bad size

._byte:
        move.b  0(A4,D3.w),D4       ;fetch val
        bpl     .__byte             ;do nothing if pos
        neg.b   D4                  ;abs(x)
        bset    D5,D4               ;set flag bit
        move.b  D4,0(A4,D3.w)       ;store
.__byte:
        bra     .nextset            ;another

._word:
        move.w  0(A4,D3.w),D4
        bpl     .__word
        neg.w   D4
        bset    D5,D4
        move.w  D4,0(A4,D3.w)
.__word:
        bra     .nextset

._long:
        move.l  0(A4,D3.w),D4
        bpl     .__long
        neg.l   D4
        bset    D5,D4
        move.l  D4,0(A4,D3.w)
.__long:
        bra     .nextset
L034x:

* EOF
*
dc.l $FFFFFFFF
