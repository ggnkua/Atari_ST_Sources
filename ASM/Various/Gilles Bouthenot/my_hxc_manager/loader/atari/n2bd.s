;n2bd02.s : 20111028
;STANDARD:$1FB 138 octets, 152000 B/S
;ASYNC:$201:
;TOWERS1:$1DE 144 octets 160669 B/s <-- recommended
;TOWER5:$1EF
;TOWER6:$1E0 170 octets, 160000 B/s
;TOWER7:$1D7
;TOWER=8:$1D1
;TOWER=9:$1CD
;TOWER10:$1CA


;  n2b_d.ash -- NRV2B decompression in 68000 assembly
;
;  This file is part of the UCL data compression library.
;
;  Copyright (C) 1996-2004 Markus Franz Xaver Johannes Oberhumer
;  All Rights Reserved.
;
;  The UCL library is free software; you can redistribute it and/or
;  modify it under the terms of the GNU General Public License as
;  published by the Free Software Foundation; either version 2 of
;  the License, or (at your option) any later version.
;
;  The UCL library is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with the UCL library; see the file COPYING.
;  If not, write to the Free Software Foundation, Inc.,
;  59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
;
;  Markus F.X.J. Oberhumer
;  <markus@oberhumer.com>
;  http://www.oberhumer.com/opensource/ucl/
;

;N2B_ASYNC       equ     1    ; when set, decrunch will wait if (a4)<a0
                              ; Use this to throttle real time loading. It is advised
                              ; to set (a4) as the current loaded byte - N (N=255 seems good)
                              ; when loading is finished, put -1 in (a4)

;N2B_TOWER       equ     1                                   ; 0,1 or 6-10  0:8  1:14  n:4n+14 bytes

; stack usage: 0

;    OPT O+, OW+
;    OPT O1+,OW1-        ; backward branches
;    OPT O6+,OW6-        ; forward branches

; ------------- DECOMPRESSION -------------

; decompress from a0 to a1
;   note: must preserve d4 and a5-a7

;
; On entry:
;   a0  src pointer
;   a1  dest pointer
;
; On exit:
;   d1.l = 0
;   d2.l = 0
;
; Register usage:
;   a2  decompr_tower
;   a3  m_pos
;  (a4) asynchronous depack : wait until (a4)>=a0 (only if N2B_ASYNC)
;
;   d0  bit buffer
;   d1  m_off
;   d2  m_len
;   d5  last_m_off
;
;   d6  constant: -$d00
;   d7  constant: -1
;
;
; Notes:
;   we have max_match = 65535, so we can use word arithmetics on d2
;











; ------------- constants & macros -------------

    IF    N2B_TOWER>=2
            movem.l  d0-d2/d5-d7/a2-a3,-(a7)
    ELSE
            movem.l  d0-d2/d5-d7/a3,-(a7)
    ENDIF

        ;;move.l  #-$d00,d6             ; 0xfffff300
        moveq.l #-$68,d6                ;   0xffffff98
        lsl.w   #5,d6                   ;   << 5 = 0xfffff300

        moveq.l #-1,d7
        moveq.l #-1,d5                  ; last_off = -1

        ; init d0 with high bit set
        moveq.l #-128,d0                ; init d0.b for FILLBYTES d0.b = $80

        IF N2B_TOWER>=2
                    lea decompr_tower(pc),a2
        ENDIF

        bra.s     decompr_start






; ------------- DECOMPRESSION -------------


decompr_literal:        ;copy 1 byte
        move.b  (a0)+,(a1)+

decompr_start:
decompr_loop:
;get next bit from d0. If d0 is empty, fetch a new byte in d0

        add.b   d0,d0           ; sets Z, C and X       ;  4
        bcc.s   decompr_match   ;bit=0?
        bne.s   decompr_literal ;bit=1? copy 1 byte

    IF N2B_ASYNC
            ;ensures a0 is filled with enough bytes
.waitasync:
        cmp.l   (a4),a0             ; (X untouched)
        IF 0=1
                    bhi.s   .waitasync
        ELSE
                    bls.s   .syncok
            N2B_WAIT_SYNC
            bra.s   .waitasync          ; a0 may be equal to (a4)
.syncok:
        ENDIF
    ENDIF

        ;X=1
        ;d0 is empty. Fill it !
        move.b  (a0)+,d0                                ;  8 note: we shift the X flag through -> must init d0.b with $80
        addx.b  d0,d0           ;sets C and X           ;  4        addx also set to 1 the bit0 of d0 (end of bits marker)
        bcs.s   decompr_literal ;bit=1? copy 1 byte

decompr_match:
        moveq.l #1,d1                                   ;m_off
        moveq.l #0,d2                                   ;m_len
decompr_l1:
        add.b   d0,d0           ; sets Z, C and X       ;  4       next bit
        bne.s   .getbitl1                                      ; 10 (if jump)

        ;d0 is empty. Fill it !
        move.b  (a0)+,d0                                ;  8 note: we shift the X flag through -> must init d0.b with $80
        addx.b  d0,d0           ;sets C and X           ;  4        addx also set to 1 the bit0 of d0 (end of bits marker)
.getbitl1:
        addx.l  d1,d1                                   ;          feed m_off with BIT
        add.b   d0,d0           ; sets Z, C and X       ;  4       next bit
        bcc.s   decompr_l1      ;bit=0?next bit is for m_off
        bne.s   .break
        
        ;d0 is empty. Fill it !
        move.b  (a0)+,d0                                ;  8 note: we shift the X flag through -> must init d0.b with $80
        addx.b  d0,d0           ;sets C and X           ;  4        addx also set to 1 the bit0 of d0 (end of bits marker)
        bcc.s   decompr_l1      ;bit=0?next bit is for m_off
.break:
    
        subq.l  #3,d1
        bcs.s   decompr_get_mlen        ; use last m_off            m_off<3?

        lsl.l   #8,d1
        move.b  (a0)+,d1
        not.l   d1                      ; m_off = (d1+3)<<8 + (!next byte)
        beq.s   decompr_end             ; m_off=0? end
        move.l  d1,d5                   ; last_m_off=m_off










decompr_get_mlen:
;read 2 bits into m_len
        add.b   d0,d0           ; sets Z, C and X       ;  4       next bit
        bne.s   .getbitm1                               ; 10 (if jump)

        ;d0 is empty. Fill it !
        move.b  (a0)+,d0                                ;  8 note: we shift the X flag through -> must init d0.b with $80
        addx.b  d0,d0           ;sets C and X           ;  4        addx also set to 1 the bit0 of d0 (end of bits marker)
.getbitm1:
        addx.w  d2,d2                                   ;          feed m_len with BIT
        add.b   d0,d0           ; sets Z, C and X       ;  4       next bit
        bne.s   .getbitm2                               ; 10 (if jump)

        ;d0 is empty. Fill it !
        move.b  (a0)+,d0                                ;  8 note: we shift the X flag through -> must init d0.b with $80
        addx.b  d0,d0           ;sets C and X           ;  4        addx also set to 1 the bit0 of d0 (end of bits marker)
.getbitm2:
        addx.w  d2,d2                                   ;          feed m_len with BIT
        tst.w   d2              ; addx doesn't set the Z flag...
        bne.s     decompr_got_mlen                      ;m_len=1,2 or 3 ? use old _mlen
        addq.w  #1,d2


decompr_l2:
        add.b   d0,d0           ; sets Z, C and X       ;  4       next bit
        bne.s   .getbitl2                               ; 10 (if jump)

        ;d0 is empty. Fill it !
        move.b  (a0)+,d0                                ;  8 note: we shift the X flag through -> must init d0.b with $80
        addx.b  d0,d0           ;sets C and X           ;  4        addx also set to 1 the bit0 of d0 (end of bits marker)
.getbitl2:
        addx.w  d2,d2                                   ;          feed m_len with BIT
        add.b   d0,d0           ; sets Z, C and X       ;  4       next bit
        bcc.s   decompr_l2      ; bit=0:next bit is again for m_len
        bne.s   .break

        ;d0 is empty. Fill it !
        move.b  (a0)+,d0                                ;  8 note: we shift the X flag through -> must init d0.b with $80
        addx.b  d0,d0           ;sets C and X           ;  4        addx also set to 1 the bit0 of d0 (end of bits marker)
        bcc.s   decompr_l2      ; bit=0:next bit is again for m_len
.break:
    
        addq.w  #2,d2



decompr_got_mlen:
;d5.l: m_off=last_m_off : offset
;d2.w: m_len
        lea     0(a1,d5.l),a3

        ; must use sub as cmp doesn't affect the X flag
        move.l  d5,d1
        sub.l   d6,d1                                   ; d1 = m_off+$d00
        addx.w  d7,d2                                   ; (m_off<$d00)?m_len-- (not sure...)

; TODO: partly unroll this loop; could use some magic with d7 for address
;       computations, then compute a nice `jmp yyy(pc,dx.w)'

        ;      2,  3,  4,   5,   6,   7,   8,   9,  10,  11,  12    ; m_len
        ;     38, 60, 82, 104, 126, 148, 170, 192, 214, 236, 258    ; original (22 * (m_len - 1) + 16)
        ;     58, 70, 82,  94, 106, 142, 154, 166, 178, 214, 226    ; tower of 6
        ;    -20,-10,  0,  10,  20,   6,  16,  26,  36,  22,  32    ; delta
        ;     58, 70, 82,  94, 106, 118, 130, 142, 154, 190, 202    ; tower of 10
        ;      0,  0,  0,   0,   0,  24,  24,  24,  24,  24,  24    ; delta

        
        ;TODO : move.w d2,d1    lsr.w #2,d1  beq.s  endcopy1  .copy1: reptr 4 move.b endr dbra .d1,copy1 endcopy1: and.w #3,d2 .copy2:move.b dbra d2,.copy2
        
        IF N2B_TOWER=0
                    move.b  (a3)+,(a1)+                             ; 12
.copy:      move.b  (a3)+,(a1)+                             ; 12
            dbra    d2,.copy                                ; 10 / 14
            bra.s   decompr_loop
         ; I tried this, with no result:
         ;  move.w d2,d1  lsr.w #3,d1  bra.s .startcopy1 .copy1:rept 8  move.b (a3)+,(a1)+
         ;  endr  .startcopy1:dbra d1,.copy1  and.w #7,d2  add.w d2,d2  neg.w d2
         ;  jmp 0(a2,d2.w)  REPT 8  move.b  (a3)+,(a1)+  ENDR
         ;  decompr_tower:move.b (a3)+,(a1)+  move.b (a3)+,(a1)+  bra decompr_loop
        ELSE
            IF N2B_TOWER=1
                ;copy d2+1 bytes
                lsr.w   #1,d2
                bcc.s   .copy2                          ;bit0=0: even len, len>0
                move.b  (a3)+,(a1)+
.copy2:         move.b  (a3)+,(a1)+
                move.b  (a3)+,(a1)+
.endcopy1:      dbra    d2,.copy2
                bra   decompr_loop
            ELSE
.copienext:     subq.w  #(N2B_TOWER-2),d2                   ;  4
                bgt.s   .copie8                             ;  8/10     ; when d2> : 72
                neg.w   d2                                  ;  4        ; 0:58
                add.w   d2,d2                               ;  4
                jmp     0(a2,d2.w)                          ; 14

.copie8:        REPT    N2B_TOWER-2
                    move.b  (a3)+,(a1)+                     ; 12
                ENDR
                bra.s   .copienext                          ; 10

decompr_tower:
                REPT    N2B_TOWER
                    move.b  (a3)+,(a1)+                     ; 12
                    ; two moves are always executed because when d2=0, it means "copy 2 bytes"
                ENDR
                bra     decompr_loop
            ENDIF
        ENDIF

;tower of 6:
;d2=0: 34+ 2*12 =   58
;d2=1: 34+ 3*12 =   70
;d2=2: 34+ 4*12 =   82
;d2=3: 34+ 5*12 =   94
;d2=4: 34+ 6*12 =  106
;d2=5: 72 + d2=1 = 142
;d2=6: 72 + d2=2 = 154
;d2=7: 72 + d2=3 = 166
;d2=8: 72 + d2=4 = 178
;d2=9: 72 + d2=5 = 214
;d2=10:72 + d2=6 = 226

;tower of 10:
;d2=0:  34+  2*12 =   58
;d2=1:  34+  3*12 =   70
;d2=2:  34+  4*12 =   82
;d2=3:  34+  5*12 =   94
;d2=4:  34+  6*12 =  106
;d2=5:  34+  7*12 =  118
;d2=6:  34+  8*12 =  130
;d2=7:  34+  9*12 =  142
;d2=8:  34+ 10*12 =  154
;d2=9: 120+  d2=1 =  190
;d2=10:120+  d2=2 =  202

        



decompr_end:
        IF    N2B_TOWER>=2
            movem.l  (a7)+,d0-d2/d5-d7/a2-a3
        ELSE
            movem.l  (a7)+,d0-d2/d5-d7/a3
        ENDIF

; vi:ts=8:et
