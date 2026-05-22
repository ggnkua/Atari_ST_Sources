export atm_35

;ATOMIK DECRUNCH SOURCE CODE v3.5 (non optimise, pas le temps. sorry...)
; Optimized by Mr Ni! of the TOS-crew

;ce depacker est indissociable du programme ATOMIK V3.5 tous les mecs
;qui garderons se source dans l'espoir de prendre de l'importance
;en se disant moi je l'ai et pas l'autre sont des lamers.

;MODE=1 depack data from a0 to a0
;MODE=0 depack data from a0 to a1 (RESTORE SPACE a 1 inutile! si MODE=0)

; PIC_ALGO = 0 decrunch fichier non encodé avec algorythm d'image spéciale.
; PIC_ALGO = 1 decrunch tous les fichiers avec ou sans image algorythm.

; DEC_SPACE = (un espace de décrochage inférieur est attribué après l'emballage par atomik v3.5)

; RESTORE_SPACE = 1 l'espace de décalage alloué sera restauré.
; RESTORE_SPACE = 0 l'espace de décalage alloué ne sera pas restauré.

, Appelez-le par BSR DEPACK ou JSR DEPACK mais appelez-le!

PIC_ALGO            EQU 1

Offset_tab          equ 0   ; 7 décalages plus 1 décalage spécial
Short_char_tab      equ 8   ; 16 caractères courts
Pic_count           equ 24  ; 1 octet avec le nombre d'image compressées

atm_35:
depack: cmpi.l  #"ATM5",(a0)+
        bne.s   not_packed
        move.l  (a0)+,d0
        movem.l d0-a6,-(SP)
        lea     -26(sp),sp
        adda.l  d0,a1
        move.l  (a0)+,d0
        lea     0(a0,d0.l),a6

IFNE PIC_ALGO
     move.b  -(a6),pic_count(sp)
     move.l  a1,a2
ELSE
     subq.l  #1,a6
ENDC
     move.b  -(a6),d7
     moveq   #7,d4
     bra     get_block_data
; d0
; d1
; d2
; d3 = length bits
; d4 = 7
; d5
; d6
; d7
; a0 = src start
; a1 = dst
; a2 = src end
; a3 = einde block ptr
; a4 = copy pointer
; a5 = table status, .h offsets, .w short chars
; a6 = src

get_bit_empty2: 
            move.b  -(a6),d7
            addx.b  d7,d7
            bra.s   get_bit_cont2

delta_char: move.b  (a1),d0
            cmp.b   d4,d5
            ble.s   not_neg
            add.b   #$F0,d5
not_neg:    sub.b   d5,d0
            move.b  d0,-(a1)
            bra     tst_end

get_bit_empty0:
            move.b  -(a6),d7
            addx.b  d7,d7
            bra.s   get_bit_cont0

length_3bits:
            moveq   #3,d6
            bsr.s   getd6_bits
            tst.w   d5
            bne.s   length_done
length_7bits:
            moveq   #7,d6
            bsr.s   getd6_bits
            tst.w   d5
            beq.s   length_13bits
            add.w   #15,d5
            bra.s   length_done
length_13bits:
            moveq   #13,d6
            bsr.s   getd6_bits
            add.w   #255+15,d5
            bra.s   length_done

length_2:   add.b   d7,d7
            beq.s   get_bit_empty2
get_bit_cont2:
            bcs.s   short_char
            moveq   #1,d6
            bra.s   length_2_end

empty:      move.b  -(a6),d7
            addx.b  d7,d7
            addx.w  d5,d5
            dbra    d6,get_bits_loop
not_packed:
            rts

offset:     DC.W    0,32,96,352,864,1888,3936,8032
bits:       DC.B    0,1,3,4,5,6,7,8

short_char: moveq   #3,d6
            bsr.s   getd6_bits
            move.w  a5,d6                             ; test A5.w
            bne.s   delta_char
            move.b  short_char_tab(sp,d5.w),-(a1)
            bra.s   tst_end

getd6_bits: moveq   #0,d5
get_bits_loop:
            add.b   d7,d7
            beq.s   empty
            addx.w  d5,d5
            dbra    d6,get_bits_loop
            rts

sld_start:  move.w  d3,d5
take_lenght:
            add.b   d7,d7
            beq.s   get_bit_empty0
get_bit_cont0:
            dbcs    d5,take_lenght
            bcc.s   length_3bits
            neg.w   d5
length_done:
            add.w   d3,d5
            beq.s   length_2
            moveq   #2,d6
length_2_end:
            move.w  d5,d2
            bsr.s   getd6_bits
            move.w  d5,d0
            move.b  bits(PC,d0.w),d6
            ext.w   d6
            move.l  a5,d5                     ; test a5.h
            bpl.s   spec_offset
            addq.w  #4,d6
            bsr.s   getd6_bits
special_offset_einde:
            add.w   d0,d0
            add.w   offset(PC,d0.w),d5
            lea     1(a1,d5.w),a4
            move.b  -(a4),-(a1)
copy_loop:  move.b  -(a4),-(a1)
            dbra.w  d2,copy_loop
tst_end:    cmpa.l  a1,a3                     ; block done?
            beq.s   block_end
depack_loop:    
            add.b   d7,d7
            beq.s   get_bit_empty3
get_bit_cont3:
            bcs.s   sld_start
            move.b  -(a6),-(a1)               ; literal
            cmpa.l  a1,a3                     ; block done?
            bne.s   depack_loop               ; nope, next
block_end:  cmpa.l  a6,a0                     ; depack done
            beq.s   work_done                 ; yep
            bra.s   get_block_data

spec_offset:
; use special offset table
             bsr.s   getd6_bits
            move.w  D5,D1
            lsl.w   #4,D1
            moveq   #2,D6
            bsr.s   getd6_bits
            cmp.b   D4,D5
            blt.s   table_offset
            add.b   D7,D7
            beq.s   get_bit_empty4
get_bit_cont4:
            bcc.s   table_offset           ; special offset is table offset #8
             moveq   #2,D6
            bsr.s   getd6_bits
            add.w   D5,D5
            or.w    D1,D5
            bra.s   special_offset_einde

get_bit_empty3:
            move.b  -(A6),D7
            addx.b  D7,D7
            bra.s   get_bit_cont3

table_offset:
            or.b    offset_tab(sp,D5.w),D1
            move.w  D1,D5
            bra.s   special_offset_einde

get_bit_empty4:
            move.b  -(A6),D7
            addx.b  D7,D7
            bra.s   get_bit_cont4

work_done:
IFNE PIC_ALGO
            moveq   #0,d7
            move.b  pic_count(sp),d7          ; no of pictures to decode
            bsr.s   decod_picture
ENDC
            lea     26(sp),sp
            movem.l (SP)+,D0-A6
            rts

get_block_data:
            moveq   #-1,d3
            bsr.s   get_bit
            bcc.s   no_special_offsets
            move.b  -(A6),D0                  ; special offset
            lea     (sp),A4                   ; special offset table
            moveq   #1,D1
            moveq   #6,D2
next_offset:
            cmp.b   D0,D1                     ; special offset?
            bne.s   offset_not_special        ; nope
            addq.w  #2,D1                     ; skip
offset_not_special:
            move.b  D1,(A4)+                  ; store offset
            addq.w  #2,D1                     ; calc next offset
            dbra    D2,next_offset            ; next
            move.b  D0,(A4)+                  ; store special offset
            clr.w   d3                        ; offset table is filled
no_special_offsets:
            swap    d3
            bsr.s   get_bit                   ; short chars?
            bcc.s   relatif                   ; nope
            lea     short_char_tab(sp),A4     ; short char table pointer
            moveq   #15,D0                    ; 16 short chars
next_char:  move.b  -(A6),(A4)+               ; fill table
            dbra    D0,next_char              ; next
            clr.w   d3                        ; short char table is filled
relatif:    move.l  d3,a5                     ; store logic
            moveq   #0,D3
            move.b  -(A6),D3                  ; length bits
            move.b  -(A6),D0                  ; block length
            lsl.w   #8,D0                     ;
            move.b  -(A6),D0                  ; 16 bits
            movea.l A1,A3                     ; calc end of block
            suba.w  D0,A3
            bra     depack_loop               ; depack

get_bit:    add.b   D7,D7
            beq.s   get_bit_empty
            rts

IFNE PIC_ALGO
decod_picture:
            dbra    D7,decod_algo
            rts
decod_algo: subq.l  #4,30(SP)                 ; correct origsize
            move.l  -(A2),D0
            lea     0(A1,D0.l),A5
no_odd:     lea     $7D00(A5),A0
next_plane: moveq   #3,D6
next_word:  move.w  (A5)+,D0
            moveq   #3,D5
next_bits:  add.w   D0,D0
            addx.w  D1,D1
            add.w   D0,D0
            addx.w  D2,D2
            add.w   D0,D0
            addx.w  D3,D3
            add.w   D0,D0
            addx.w  D4,D4
            dbra    D5,next_bits
            dbra    D6,next_word
            movem.w D1-D4,-8(A5)
            cmpa.l  A5,A0
            bne.s   next_plane
            bra.s   decod_picture
ENDC

get_bit_empty:
            move.b  -(A6),D7
            addx.b  D7,D7
            rts

     END
