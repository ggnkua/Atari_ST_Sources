; --------- Sample Packroutinen
; --------- (c) 1992 DELTA FORCE
; --------- Exclusiv fÅr TOS Magazin
; --------- Dieser Sourcecode ist nicht Public Domain!


init_packer:
; macht Distanztabellen, etc. Muss also vor dem ersten Packen einmal
; aufgerufen werden.

                lea     distance_table(PC),A1
                move.w  #-255,D0

search_neg:     lea     power(PC),A0
                moveq   #0,D1

scan1:          cmp.w   (A0)+,D0
                ble.s   found1
                addq.w  #1,D1
                cmp.w   #8,D1
                bne.s   scan1

found1:         move.b  D1,(A1)+

                addq.w  #1,D0
                bne.s   search_neg

search_pos:     lea     power+32(PC),A0
                moveq   #15,D1

scan2:          move.w  -2(A0),D2
                cmp.w   -(A0),D0
                bge.s   found2
                subq.w  #1,D1
                cmp.w   #7,D1
                bne.s   scan2

found2:         move.b  D1,(A1)+

                addq.w  #1,D0
                cmp.w   #128,D0
                bne.s   search_pos

fill1:          clr.b   (A1)+                ; a+128 und 255 = a-128 und 255
                addq.w  #1,D0
                cmp.w   #256,D0
                bne.s   fill1

                rts



pack_sample:
; Eingabeparameter:
; a0=Zeiger auf ungepacktes Sample
; a1=Ziel
; d0=SamplelÑnge

; RÅckgabewerte:
; d0=Gepackte LÑnge

                lea     distance_table+255(PC),A2
                lea     power_bytes(PC),A3

                addq.l  #1,D0
                and.b   #-2,D0               ; round length up
                move.l  D0,D7
                lsr.l   #1,D7                ; sample length in words

                move.l  D7,-(A7)

                adda.l  D0,A0                ; source end
                adda.l  D7,A1                ; destination end

                moveq   #0,D1                ; clear temp
                moveq   #0,D2                ; clear temp
                moveq   #0,D6                ; last byte

pack_loop:      moveq   #0,D0
                move.b  -(A0),D0
                add.b   #128,D0              ; amiga to st
                sub.w   D6,D0                ; calculate sample delta
                move.b  0(A2,D0.w),D1        ; encoded nibble
                add.b   0(A3,D1.w),D6        ; recalc byte
                lsl.b   #4,D1

                moveq   #0,D0
                move.b  -(A0),D0
                add.b   #128,D0
                sub.w   D6,D0
                move.b  0(A2,D0.w),D2
                add.b   0(A3,D2.w),D6
                or.b    D2,D1

                move.b  D1,-(A1)

                subq.l  #1,D7
                bne.s   pack_loop

                move.l  (A7)+,D0             ; packed length

                rts

analyse_module:
; wird zum packen von Modulen benîtigt. Analysiert Sample start und Ende
; a0 = Zeiger auf Modul

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

                rts

power:          DC.W -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64

power_bytes:    DC.B -128,-64,-32,-16,-8,-4,-2,-1,0,1,2,4,8,16,32,64

sample_start:	DS.L 1
sample_end:	DS.L 1
distance_table:	DS.B 512


