export ice_depack
export noise_depack


;UNPACK-ROUTINE OF PACK-ICE
ice_depack:
;a0: pointer to packed data
;a1: destinationadress
                movem.l d0-a6,-(sp)
                bsr.s   getinfo
                cmpi.l  #'ICE!',d0
                bne     not_packed
                bsr.s   getinfo
                lea     -8(a0,d0.l),a5
                bsr.s   getinfo
                move.l  d0,(sp)
                movea.l a1,a4
                movea.l a1,a6
                adda.l  d0,a6
                movea.l a6,a3
                move.b  -(a5),d7
                bsr     normal_bytes

                movea.l a3,a6
                bsr     get_1_bit
                bcc.s   not_packed
                move.w  #$0F9F,d7
                bsr     get_1_bit
                bcc.s   ice_00
                moveq   #15,d0
                bsr     get_d0_bits
                move.w  d1,d7
ice_00:         moveq   #3,d6
ice_01:         move.w  -(a3),d4
                moveq   #3,d5
ice_02:         add.w   d4,d4
                addx.w  d0,d0
                add.w   d4,d4
                addx.w  d1,d1
                add.w   d4,d4
                addx.w  d2,d2
                add.w   d4,d4
                addx.w  d3,d3
                dbra    d5,ice_02
                dbra    d6,ice_01
                movem.w d0-d3,(a3)
                dbra    d7,ice_00

not_packed:
                movem.l (sp)+,d0-a6
                rts

getinfo:        moveq   #3,d1
getbytes:       lsl.l   #8,d0
                move.b  (a0)+,d0
                dbra    d1,getbytes
                rts

normal_bytes:
                bsr.s   get_1_bit
                bcc.s   test_if_end
                moveq   #0,d1
                bsr.s   get_1_bit
                bcc.s   copy_direkt
                lea     direkt_tab+20,a1
                moveq   #4,d3
nextgb:         move.l  -(a1),d0
                bsr.s   get_d0_bits
                swap    d0
                cmp.w   d0,d1
                dbne    d3,nextgb
no_more:        add.l   20(a1),d1
copy_direkt:
                move.b  -(a5),-(a6)
                dbra    d1,copy_direkt
test_if_end:
                cmpa.l  a4,a6
                bgt.s   strings
                rts


get_1_bit:      add.b   d7,d7
                bne.s   bitfound
                move.b  -(a5),d7
                addx.b  d7,d7
bitfound:       rts

get_d0_bits:
                moveq   #0,d1
hole_bit_loop:
                add.b   d7,d7
                bne.s   on_d0
                move.b  -(a5),d7
                addx.b  d7,d7
on_d0:          addx.w  d1,d1
                dbra    d0,hole_bit_loop
                rts



strings:        lea     length_tab,a1
                moveq   #3,d2
get_length_bit:
                bsr.s   get_1_bit
                dbcc    d2,get_length_bit
no_length_bit:
                moveq   #0,d4
                moveq   #0,d1
                move.b  1(a1,d2.w),d0
                ext.w   d0
                bmi.s   no_ueber
get_ueber:      bsr.s   get_d0_bits
no_ueber:       move.b  6(a1,d2.w),d4
                add.w   d1,d4
                beq.s   get_offset_2


                lea     more_offset,a1
                moveq   #1,d2
getoffs:        bsr.s   get_1_bit
                dbcc    d2,getoffs
                moveq   #0,d1
                move.b  1(a1,d2.w),d0
                ext.w   d0
                bsr.s   get_d0_bits
                add.w   d2,d2
                add.w   6(a1,d2.w),d1
                bpl.s   depack_bytes
                sub.w   d4,d1
                bra.s   depack_bytes


get_offset_2:
                moveq   #0,d1
                moveq   #5,d0
                moveq   #-1,d2
                bsr.s   get_1_bit
                bcc.s   less_40
                moveq   #8,d0
                moveq   #$3F,d2
less_40:        bsr.s   get_d0_bits
                add.w   d2,d1

depack_bytes:
                lea     2(a6,d4.w),a1
                adda.w  d1,a1
                move.b  -(a1),-(a6)
dep_b:          move.b  -(a1),-(a6)
                dbra    d4,dep_b
                bra     normal_bytes


direkt_tab:
                DC.L $7FFF000E,$FF0007,$070002,$030001,$030001
                DC.L 270-1,15-1,8-1,5-1,2-1

length_tab:
                DC.B 9,1,0,-1,-1
                DC.B 8,4,2,1,0

more_offset:
                DC.B 11,4,7,0
                DC.W $011F,-1,$1F



;DEPACKES A NOISE-PACKED MODULE (ORIGINAL ROUTINE)
noise_depack:
movem.l d0-a6,-(sp)
                bsr     analyse_module       ; find sample start/end

                bsr     init_depack

                movea.l sample_start,A0  ; packed sample
                move.l  sample_end,D0
                sub.l   A0,D0                ; unpacked length

                move.l  D0,-(A7)
                bsr     depack_sample        ; depack over source
                move.l  (A7)+,D0
                
movem.l (sp)+,d0-a6
                rts

; a0=module address

analyse_module: move.l  A0,-(A7)

                lea     $03b8(A0),A1

                moveq   #$7f,D0
                moveq   #0,D4
mt_loop:        move.l  D4,D2
                subq.w  #1,D0
mt_lop2:        move.b  (A1)+,D4
                cmp.b   D2,D4
                bgt.s   mt_loop
                dbra    D0,mt_lop2
                addq.b  #1,D2

                asl.l   #8,D2
                asl.l   #2,D2
                add.l   #$043c,D2
                move.l  D2,D1
                add.l   A0,D2
                movea.l D2,A2

                move.l  A2,sample_start

                moveq   #$1e,D0
mt_lop3:
                moveq   #0,D4
                move.w  42(A0),D4
                add.l   D4,D4
                adda.l  D4,A2
                adda.l  #$1e,A0
                dbra    D0,mt_lop3

                move.l  A2,sample_end

                movea.l (A7)+,A0

                rts

; a0=packed sample (also destination)
; d0=unpacked length

depack_sample:
                lea     depack_hi,A2
                lea     depack_lo,A3

                addq.l  #1,D0
                and.b   #-2,D0               ; round length up
                move.l  D0,D7
                lsr.l   #1,D7                ; sample length in words

                lea     0(A0,D0.l),A1        ; destination end
                adda.l  D7,A0                ; source end

                move.w  #128,D0              ; last byte
                moveq   #0,D1                ; clear temp

depack_loop:    move.b  -(A0),D1             ; get 2 distances
                add.b   0(A2,D1.w),D0
                move.b  D0,-(A1)
                add.b   0(A3,D1.w),D0
                move.b  D0,-(A1)

                subq.l  #1,D7
                bne.s   depack_loop

                rts

init_depack:

                lea     depack_lo,A1
                move.w  #15,D7
init1:          lea     power_bytes,a0
                move.w  #15,D6
init2:          move.b  (A0)+,(A1)+
                dbra    D6,init2
                dbra    D7,init1

                lea     power_bytes,A0
                lea     depack_hi,A1
                move.w  #15,D7
init3:          move.w  #15,D6
                move.b  (A0)+,D0
init4:          move.b  D0,(A1)+
                dbra    D6,init4
                dbra    D7,init3

                rts


power_bytes:    DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64

sample_start:   DC.L 0
sample_end:     DC.L 0

BSS

depack_lo:      DS.B 256
depack_hi:      DS.B 256

END