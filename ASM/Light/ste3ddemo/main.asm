|
| 3D demo part of the E605 Atari STE demo by Light.
|
| Coded by Sascha "Percy" Springer in 1992.
|

.equ Zx, 320+160-16
.equ Zy, 160-16-4
.equ Zz, -500

.equ pn, 16      |+8+8
.equ wpn, 8
.equ obj, 7

.equ star_speed, 8
.equ star_x_speed, 0
.equ star_y_speed, 0

.equ on, 1
.equ off, 0

.equ mask, on
.equ sprite, on

.equ planes, 3
.equ words, 2
.equ lines, 32
.equ x_offset, 35
.equ y_offset, 37
.equ x_speed, 3
.equ y_speed, 2
.equ mask_mode, 4
.equ sprite_mode, 7
.equ anzahl, pn

.global _main

.text

_main:
                bsr.s   init
                bsr     smain           | smain
                clr.w   0xffff8900.w
                bsr     restore

                clr.w   -(sp)           | Pterm
                trap    #1

init:           |>PART

                clr.l   -(sp)           | Supervisor on
                move.w  #0x0020,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  d0,savssp

                bsr     minit

                bsr     make_field
                bsr     init_demo

				move.b	0xffff8007.w,oldf030
|				clr.b	0xffff8007.w

                movem.l 0xffff8240.w,d0-d7
                movem.l d0-d7,oldpal
                move.b  0xffff8260.w,oldres
                move.b  0xffff820a.w,oldhz
                move.b  0xffff8201.w,oldscr+1
                move.b  0xffff8203.w,oldscr+2
                move.b  0xffff820d.w,oldscr+3
                move.b  0xffff820f.w,oldlw
                move.b  0xffff8265.w,oldhsc

                move.b  0xfffffa07.w,old07
                move.b  0xfffffa09.w,old09
                move.b  0xfffffa13.w,old13
                move.b  0xfffffa15.w,old15
                bclr    #3,0xfffffa17.w

                move.l  0x00000120.w,oldtimerb
                move.l  0x00000070.w,oldvbl

                move.l  #svbl,0x00000070.w
                move.l  #timer_b,0x00000120.w
                clr.b   0xfffffa1b.w
                move.b  #1,0xfffffa21.w
                move.b  #8,0xfffffa1b.w

                move.b  #1,0xfffffa07.w
                clr.b   0xfffffa09.w
                move.b  #1,0xfffffa13.w
                clr.b   0xfffffa15.w

                clr.b   0xffff8260.w
                move.b  #2,0xffff820a.w

|                movem.l sprite_pic+2,d0-d7
|                movem.l d0-d7,0xffff8240.w

                rts

                |ENDPART

init_demo:      |>PART

                bsr     make_cross

                movem.l font_pic+2,d0-d7
                movem.l d0-d7,star_pals+15*32

                lea     star_pals+15*32,a0
                lea     -32(a0),a1
                move.w  #15-1,d7
i_mp_loop1:     move.w  #4-1,d6
i_mp_loop2:     move.w  (a0),d0
                move.w  (a0)+,(a1)+

                move.w  d0,d1
                and.w   #0x0888,d0
                and.w   #0x0777,d1
                add.w   d1,d1
                lsr.w   #3,d0
                or.w    d1,d0

                move.w  #3-1,d5
i_mp_loop3:     move.w  d0,d1
                and.w   #0x000f,d1
                move.w  (a0)+,d2

                move.w  d2,d4
                and.w   #0x0888,d2
                and.w   #0x0777,d4
                add.w   d4,d4
                lsr.w   #3,d2
                or.w    d4,d2

                move.w  d2,d3
                and.w   #0x000f,d3
                cmp.w   d1,d3
                beq.s   i_mp_ok1
                blt.s   i_mp_add1
                subq.w  #0x01,d2
                bra.s   i_mp_ok1
i_mp_add1:      addq.w  #0x01,d2
i_mp_ok1:
                move.w  d0,d1
                and.w   #0x00f0,d1
                move.w  d2,d3
                and.w   #0x00f0,d3
                cmp.w   d1,d3
                beq.s   i_mp_ok2
                blt.s   i_mp_add2
                sub.w   #0x0010,d2
                bra.s   i_mp_ok2
i_mp_add2:      add.w   #0x0010,d2
i_mp_ok2:
                move.w  d0,d1
                and.w   #0x0f00,d1
                move.w  d2,d3
                and.w   #0x0f00,d3
                cmp.w   d1,d3
                beq.s   i_mp_ok3
                blt.s   i_mp_add3
                sub.w   #0x0100,d2
                bra.s   i_mp_ok3
i_mp_add3:      add.w   #0x0100,d2
i_mp_ok3:
                move.w  d2,d4
                and.w   #0x0eee,d2
                and.w   #0x0111,d4
                lsl.w   #3,d4
                lsr.w   #1,d2
                or.w    d4,d2

                move.w  d2,(a1)+

                dbra    d5,i_mp_loop3
                dbra    d6,i_mp_loop2

                lea     -64(a0),a0
                lea     -64(a1),a1
                dbra    d7,i_mp_loop1

                lea     star_pals,a0
                bsr     make_fade2
                lea     sprite_pic+2,a0
                bsr     make_fade2
                lea     backgnd+2(pc),a0
                bsr     make_fade2
                lea     shade_col(pc),a0
                bsr     make_fade2

                move.l  #-7*50,timer

                lea     mask_pic+34,a0
                lea     sprite_pic+34,a1
                lea     deep_tab,a2
                move.w  #50-40,d0
                move.w  #4-1,d7
id_loop2a:      move.w  #10-1,d6
id_loop2b:
                move.w  d0,d5
                subq.w  #1,d5
id_loop2c:      move.l  a0,(a2)+
                move.l  a1,(a2)+
                dbra    d5,id_loop2c

                addq.w  #2,d0
                lea     16(a0),a0
                lea     16(a1),a1
                dbra    d6,id_loop2b

                lea     160*31(a0),a0
                lea     160*31(a1),a1
                dbra    d7,id_loop2a

|                lea     sprite_pic+2,a0
|                lea     -32(a0),a1
|                bsr     make_fade

                move.l  #screen1,d0
                move.l  d0,work_scr
                move.l  #screen2,d0
                move.l  d0,show_scr
                move.l  #clr_tab1,clr_tab_addr
                move.l  #mask_pic+34,mask_addr
                move.l  #sprite_pic+34,sprite_addr
                move.l  #x_data,x_data_addr

                rts

                |ENDPART

make_field:     |>PART

                lea     stars-612*4,a0
                move.w  #612-1,d7
mf_loop:        move.l  #-1,(a0)+
                dbra    d7,mf_loop

                lea     data,a0
                lea     field_x,a1
                lea     field_y,a2
|                lea     640(A1),A3
|                lea     400(A2),A4

                move.w  #255,d7
mf_loop1:       move.l  (a0)+,d0
                lsl.l   #7,d0
                move.l  d0,d1
                swap    d1
                ext.l   d1

                move.l  #160,d2
                move.w  #160*2,d3
                move.w  #160-1,d6
                clr.w   d4
mf_loop2:
                move.w  d2,d5
                add.w   d5,d5
                add.w   d5,d5
                add.w   d5,d5
                move.w  d5,0(a1,d3.w)
|                move.w  D5,0(A3,D3.w)
                cmp.l   #319,d2
                blt.s   mf_ok1
                move.w  #-1,0(a1,d3.w)
|                move.w  #-1,0(A3,D3.w)
mf_ok1:
                add.w   d0,d4
                addx.l  d1,d2
                addq.w  #2,d3
                dbra    d6,mf_loop2

                move.l  #160,d2
                move.w  #160*2,d3
                move.w  #161-1,d6
                clr.w   d4
mf_loop3:
                move.w  d2,d5
                add.w   d5,d5
                add.w   d5,d5
                add.w   d5,d5
                move.w  d5,0(a1,d3.w)
|                move.w  D5,0(A3,D3.w)
                tst.l   d2
                bpl.s   mf_ok2
                move.w  #-1,0(a1,d3.w)
|                move.w  #-1,0(A3,D3.w)
mf_ok2:
                add.w   d0,d4
                subx.l  d1,d2
                subq.w  #2,d3
                dbra    d6,mf_loop3

                lea     1280/2(a1),a1
|                lea     1280(A3),A3

                move.l  #100,d2
                move.w  #100*2,d3
                move.w  #100-1,d6
                clr.w   d4
mf_loop4:
                move.w  d2,d5
                mulu    #160,d5
                move.w  d5,0(a2,d3.w)
|                move.w  D5,0(A4,D3.w)
                cmp.l   #199,d2
                blt.s   mf_ok5
                move.w  #-1,0(a2,d3.w)
|                move.w  #-1,0(A4,D3.w)
mf_ok5:
                add.w   d0,d4
                addx.l  d1,d2
                addq.w  #2,d3
                dbra    d6,mf_loop4

                move.l  #100,d2
                move.w  #100*2,d3
                move.w  #101-1,d6
                clr.w   d4
mf_loop5:
                move.w  d2,d5
                mulu    #160,d5
                move.w  d5,0(a2,d3.w)
|                move.w  D5,0(A4,D3.w)
                tst.l   d2
                bpl.s   mf_ok9
                move.w  #-1,0(a2,d3.w)
|                move.w  #-1,0(A4,D3.w)
mf_ok9:
                add.w   d0,d4
                subx.l  d1,d2
                subq.w  #2,d3
                dbra    d6,mf_loop5

                lea     800/2(a2),a2
|                lea     800(A4),A4

                dbra    d7,mf_loop1

                lea     star_tab1,a0
                lea     set_data1,a1
                clr.w   d0
mf_loop6:       move.w  d0,d1
                and.w   #0x000f,d1
                lsl.w   #2,d1
                move.l  0(a1,d1.w),2(a0)
                move.w  d0,d2
                and.w   #0xfff0,d2
                lsr.w   #1,d2
                move.w  d2,(a0)
                addq.l  #8,a0
                addq.w  #1,d0
                cmp.w   #320,d0
                bne.s   mf_loop6

                lea     star_tab2,a0
                lea     set_data2,a1
                clr.w   d0
mf_loop7:       move.w  d0,d1
                and.w   #0x000f,d1
                lsl.w   #2,d1
                move.l  0(a1,d1.w),2(a0)
                move.w  d0,d2
                and.w   #0xfff0,d2
                lsr.w   #1,d2
                move.w  d2,(a0)
                addq.l  #8,a0
                addq.w  #1,d0
                cmp.w   #320,d0
                bne.s   mf_loop7

                lea     star_tab3,a0
                lea     set_data3,a1
                clr.w   d0
mf_loop8:       move.w  d0,d1
                and.w   #0x000f,d1
                lsl.w   #2,d1
                move.l  0(a1,d1.w),2(a0)
                move.w  d0,d2
                and.w   #0xfff0,d2
                lsr.w   #1,d2
                move.w  d2,(a0)
                addq.l  #8,a0
                addq.w  #1,d0
                cmp.w   #320,d0
                bne.s   mf_loop8

                rts

                |ENDPART

make_fade:      |>PART

                move.w  #15-1,d7
i_loop1:        move.w  #16-1,d6
i_loop2:        move.w  (a0)+,d0

                move.w  d0,d1
                and.w   #0x0777,d0
                and.w   #0x0888,d1
                add.w   d0,d0
                lsr.w   #3,d1
                or.w    d1,d0

                move.w  d0,d1
                and.w   #0x000f,d1
                beq.s   mf_ok1a
                subq.w  #0x01,d0
mf_ok1a:
                move.w  d0,d1
                and.w   #0x00f0,d1
                beq.s   mf_ok2a
                sub.w   #0x0010,d0
mf_ok2a:
                move.w  d0,d1
                and.w   #0x0f00,d1
                beq.s   mf_ok3a
                sub.w   #0x0100,d0
mf_ok3a:
                move.w  d0,d1
                and.w   #0x0eee,d0
                and.w   #0x0111,d1
                lsr.w   #1,d0
                lsl.w   #3,d1
                or.w    d1,d0

                move.w  d0,(a1)+
                dbra    d6,i_loop2
                suba.l  #16*2*2,a0
                lea     -32(a0),a1
                dbra    d7,i_loop1

                rts

                |ENDPART

make_fade2:     |>PART
| a0.l = palette address

                lea     -32(a0),a1

                move.w  #15-1,d7
mf2_mp_loop4:   move.w  #16-1,d6
mf2_mp_loop5:   move.w  (a0)+,d0

                move.w  d0,d1
                and.w   #0x0888,d0
                lsr.w   #3,d0
                and.w   #0x0777,d1
                add.w   d1,d1
                or.w    d1,d0

                move.w  d0,d1
                and.w   #0x000f,d1
                cmp.w   #0x000f,d1
                beq.s   mf2_mp_noadd1
                addq.w  #0x01,d0
mf2_mp_noadd1:
                move.w  d0,d1
                and.w   #0x00f0,d1
                cmp.w   #0x00f0,d1
                beq.s   mf2_mp_noadd2
                add.w   #0x0010,d0
mf2_mp_noadd2:
                move.w  d0,d1
                and.w   #0x0f00,d1
                cmp.w   #0x0f00,d1
                beq.s   mf2_mp_noadd3
                add.w   #0x0100,d0
mf2_mp_noadd3:
                move.w  d0,d1
                and.w   #0x0eee,d0
                and.w   #0x0111,d1
                lsr.w   #1,d0
                lsl.w   #3,d1
                or.w    d1,d0

                move.w  d0,(a1)+
                dbra    d6,mf2_mp_loop5

                lea     -64(a0),a0
                lea     -64(a1),a1
                dbra    d7,mf2_mp_loop4

                rts

                |ENDPART

minit:          |>PART

|                move.b  #0x12,0xfffffc02.w

                lea     voltab,a0
                move.w  #64,d7
                clr.w   d5
makevtab1:      move.w  #255,d6
                move.w  #0,d0
makevtab2:      move.w  d0,d1
                ext.w   d1
                muls    d5,d1
                divs    #128,d1
                move.b  d1,(a0)+
                addq.w  #1,d0
                dbra    d6,makevtab2
                addq.w  #1,d5
                dbra    d7,makevtab1

                lea     module,a0
                movea.l a0,a1
                clr.l   d0
                move.w  (a0)+,d0
                adda.l  d0,a1
                move.w  (a0)+,d0
                adda.l  d0,a1
                move.w  (a0)+,d0
                adda.l  d0,a1
                move.w  (a0)+,d0
                adda.l  d0,a1           | spladdr
                lea     spltab,a2
                lea     256(a2),a3
                movea.l a1,a4
                move.w  -8(a0),d7
                lsr.w   #4,d7
                subq.w  #1,d7
maketab:        move.l  a1,(a2)+
                move.l  a4,(a3)+
                moveq   #0,d0
                move.w  4(a0),d0        | spllen
                add.l   d0,d0
                lea     0(a1,d0.l),a1
                lea     0(a4,d0.l),a4
                adda.l  #1500,a1

                move.w  14(a0),d0       | replen
|                lsr.w   #1,d0
                add.w   12(a0),d0       | repstrt
                cmp.w   #1,d0
                bne.s   mt_ok
                move.w  4(a0),d0        | spllen
mt_ok:          add.l   d0,d0

                move.w  d0,(a2)+
                move.w  6(a0),(a3)+     | splvol
                moveq   #0,d1
                move.w  14(a0),d1       | repstrt
                add.w   d1,d1
                cmp.l   d0,d1
                bgt.s   mok
                sub.l   d1,d0
mok:            cmpi.w  #0x0001,12(a0)   | replen
                bne.s   mrpt
                moveq   #0,d0
mrpt:           move.w  d0,(a2)+
                move.w  12(a0),(a3)+    | replen
                lea     0x0010(a0),a0
                dbra    d7,maketab

                lea     spltab,a0
                move.w  module,d0
                lsr.w   #4,d0
                subq.w  #1,d0
                move.w  d0,d7
                lsl.w   #3,d0
                lea     0(a0,d0.w),a0
cnvspl1:        movea.l (a0),a1
                addi.l  #0x00008000,(a0)
                movea.l 256(a0),a2
                move.w  4(a0),d0
                subi.w  #0x8000,4(a0)
                tst.w   d0
                beq.s   cnospl
                lea     0(a1,d0.l),a1
                lea     0(a2,d0.l),a2
                movea.l a1,a3
cnvspl2:        move.b  -(a2),-(a1)
                subq.l  #1,d0
                bne.s   cnvspl2

                cmpi.w  #0x0001,262(a0)
                bne.s   makerpt

                movea.l a3,a1
cnospl:         move.w  #1499,d0
clrarea:        clr.b   (a1)+
                dbra    d0,clrarea
                bra.s   norpt

makerpt:        movea.l a3,a1
                move.w  6(a0),d0
                suba.l  d0,a3
                move.w  #1499,d0
makerptl:       move.b  (a3)+,(a1)+
                dbra    d0,makerptl

norpt:          subq.l  #8,a0
                dbra    d7,cnvspl1

                move.l  #block2,block
                lea     spldummy+0x8000,a0
                move.l  a0,sample
                move.l  a0,sample+4
                move.l  a0,sample+8
                move.l  a0,sample+12

                lea     0xffff8900.w,a0
                move.l  #block1,d0
                movep.l d0,0x0001(a0)
                add.l   #500,d0
                movep.l d0,0x000d(a0)
                move.w  #1,0x0020(a0)

                bsr.s   minit2

                rts

                |ENDPART

minit2:         |>PART

                lea     module,a4
                lea     dff000,a5
                lea     ptr_tab,a6
                moveq   #2,d0
                moveq   #0,d1
                movea.l a4,a3
L10016:         adda.w  (a4)+,a3
                move.l  a3,(a6)+
                dbra    d0,L10016
                move.w  (a4)+,d0
                adda.l  d0,a3
                move.l  #0,(a6)+
                move.l  #0x01060100,(a6)+
                move.w  #0x8000,(a6)+
                move.l  d1,(a6)+
                move.l  #jmp_06,(a6)+
                move.l  #jmp_07,(a6)+
                move.l  #jmp_10,(a6)+
                move.l  #jmp_09,(a6)+
                move.l  #L10476,(a6)+
                move.l  #L103F6,(a6)+
                move.l  #L1043C,(a6)+
                move.l  #jmp_08,(a6)+
                move.l  #jmp_03,(a6)+
                move.l  #jmp_01,(a6)+
                move.l  #jmp_02,(a6)+
                move.l  #jmp_05,(a6)+
                move.l  #jmp_04,(a6)+
                moveq   #0,d0
                movea.l a4,a6
                adda.w  -8(a4),a6 | adda.w  0xfff8(a4),a6

                suba.w  #0x000c,a6
                move.l  #0x08000000,d7   | ----
L1008C:         move.l  a3,(a4)
                add.l   d7,(a4)         | ----
                movea.l a3,a2
                move.w  0x000e(a4),d0
                add.w   d0,d0
                adda.l  d0,a2
                move.l  a2,8(a4)
                move.w  4(a4),d0
                add.w   d0,d0
                adda.l  d0,a3
                adda.w  #0x0010,a4
                add.l   #0x08000000,d7   | ----
                cmpa.l  a4,a6
                bne.s   L1008C
|                bset    #1,LBFE001
|                move.w  D1,0x00A8(A5)
|                move.w  D1,0x00B8(A5)
|                move.w  D1,0x00C8(A5)
|                move.w  D1,0x00D8(A5)
|                move.l  #0x000050D6,L78
|                lea     LBFD000,A0
|                tst.b   0x0D00(A0)
|                move.b  #0x7F,0x0D00(A0)
|                move.b  #8,0x0E00(A0)
|                move.b  D1,0x0400(A0)
|                move.b  #2,0x0500(A0)
|                move.b  #0x81,0x0D00(A0)
                rts

                |ENDPART

novbl:          |>PART

                movem.l d0-a6,-(sp)

                move.l  #timer_b,0x00000120.w
                clr.b   0xfffffa1b.w
                move.b  #1,0xfffffa21.w
                move.b  #8,0xfffffa1b.w

                bsr.s   mvbl

                movem.l (sp)+,d0-a6
                rte

                |ENDPART

mvbl:           |>PART

                movem.l d0-a6,-(sp)
                move.w  #3,0xffff8900.w

                lea     0xffff8900.w,a0
notendplay:     clr.l   longer
                movep.l 0x0007(a0),d0
                and.l   #0x00ffffff,d0
                cmpi.l  #block1,block
                bne.s   cmpother
                cmp.l   #block2,d0
                blt.s   beginplay
                move.l  #2,longer
                bra.s   beginplay
cmpother:       cmp.l   #block2,d0
                bge.s   beginplay
                move.l  #2,longer

beginplay:
                bsr     mplay

                lea     freqtab,a0
                lea     frequence,a1
                lea     spltab,a2

                move.w  dff0a8,112(a1)  | volume
                move.w  dff0b8,112+4(a1)
                move.w  dff0c8,112+8(a1)
                move.w  dff0d8,112+12(a1)

                move.l  dff0a0,d0       | frame address
                beq.s   no_set1
                swap    d0
                lsr.w   #8,d0
                subq.l  #8,d0
                movea.l 0(a2,d0.w),a5
                move.l  a5,32(a1)       | spladr
                move.w  4(a2,d0.w),80(a1) | spllen
                move.w  6(a2,d0.w),64(a1) | splrpt
                move.l  #0x00008000,48(a1) | offset
                clr.l   dff0a0
no_set1:
                move.l  dff0b0,d0       | frame address
                beq.s   no_set2
                swap    d0
                lsr.w   #8,d0
                subq.l  #8,d0
                movea.l 0(a2,d0.w),a5
                move.l  a5,32+4(a1)     | spladr
                move.w  4(a2,d0.w),80+4(a1) | spllen
                move.w  6(a2,d0.w),64+4(a1) | splrpt
                move.l  #0x00008000,48+4(a1) | offset
                clr.l   dff0b0
no_set2:
                move.l  dff0c0,d0       | frame address
                beq.s   no_set3
                swap    d0
                lsr.w   #8,d0
                subq.l  #8,d0
                movea.l 0(a2,d0.w),a5
                move.l  a5,32+8(a1)     | spladr
                move.w  4(a2,d0.w),80+8(a1) | spllen
                move.w  6(a2,d0.w),64+8(a1) | splrpt
                move.l  #0x00008000,48+8(a1) | offset
                clr.l   dff0c0
no_set3:
                move.l  dff0d0,d0       | frame address
                beq.s   no_set4
                swap    d0
                lsr.w   #8,d0
                subq.l  #8,d0
                movea.l 0(a2,d0.w),a5
                move.l  a5,32+12(a1)    | spladr
                move.w  4(a2,d0.w),80+12(a1) | spllen
                move.w  6(a2,d0.w),64+12(a1) | splrpt
                move.l  #0x00008000,48+12(a1) | offset
                clr.l   dff0d0
no_set4:
                clr.l   (a1)
                move.w  dff0a6,d0       | frequence
                add.w   d0,d0
                add.w   d0,d0
                cmpi.l  #spldummy+0x8000,32(a1)
                beq.s   no_freq1
                move.l  0(a0,d0.w),(a1)
no_freq1:
                clr.l   4(a1)
                move.w  dff0b6,d0
                add.w   d0,d0
                add.w   d0,d0
                cmpi.l  #spldummy+0x8000,32+4(a1)
                beq.s   no_freq2
                move.l  0(a0,d0.w),4(a1)
no_freq2:
                clr.l   8(a1)
                move.w  dff0c6,d0
                add.w   d0,d0
                add.w   d0,d0
                cmpi.l  #spldummy+0x8000,32+8(a1)
                beq.s   no_freq3
                move.l  0(a0,d0.w),8(a1)
no_freq3:

                clr.l   12(a1)
                move.w  dff0d6,d0
                add.w   d0,d0
                add.w   d0,d0
                cmpi.l  #spldummy+0x8000,32+12(a1)
                beq.s   no_freq4
                move.l  0(a0,d0.w),12(a1)
no_freq4:
startplay:      lea     frequence,a4
                lea     voltab,a0
                move.w  112(a4),d0      | volume
                move.w  112+4(a4),d1
                cmp.w   #0x0040,d0
                blt.s   sp_ok1
                move.w  #0x003f,d0
sp_ok1:
                cmp.w   #0x0040,d1
                blt.s   sp_ok2
                move.w  #0x003f,d1
sp_ok2:
                lsl.w   #8,d0
                lsl.w   #8,d1
                lea     0(a0,d0.w),a2
                lea     0(a0,d1.w),a3
                movea.l 32(a4),a0       | sample
                movea.l 32+4(a4),a1
                move.l  48(a4),d0       | offset
                move.l  48+4(a4),d1
                movea.l block,a6
                move.w  -96(a4),d4      | oldval
                move.w  -96+4(a4),d5
                movea.l 4(a4),a5        | frequence
                move.l  a5,d3
                swap    d3
                movea.l (a4),a4
                move.l  a4,d2
                swap    d2
                moveq   #0,d6

                move.w  #50-1,d7
makeblock1:     .rept 5

                add.w   a4,d4           | 1
                addx.w  d2,d0           | 1
                move.b  0(a0,d0.w),d6   | 4
                move.b  0(a2,d6.w),(a6)+ | 5

                add.w   a5,d5           | 1
                addx.w  d3,d1           | 1
                move.b  0(a1,d1.w),d6   | 4
                move.b  0(a3,d6.w),(a6)+ | 5
|                                         22
                .endr
                dbra    d7,makeblock1

                tst.l   longer
                beq.s   notlonger1
                add.w   a4,d4           | 1
                addx.w  d2,d0           | 1
                move.b  0(a0,d0.w),d6   | 4
                move.b  0(a2,d6.w),(a6)+ | 5

                add.w   a5,d5           | 1
                addx.w  d3,d1           | 1
                move.b  0(a1,d1.w),d6   | 4
                move.b  0(a3,d6.w),(a6)+ | 5
|                                         22
notlonger1:
                lea     frequence,a4

                move.w  d4,-96(a4)      | oldval
                move.w  d5,-96+4(a4)
                move.l  d0,48(a4)
                move.l  d1,48+4(a4)

                cmp.w   80(a4),d0
                blt.s   noreset1
                move.w  64(a4),d5
                beq.s   reset1
sub1:           sub.w   d5,d0
                cmp.w   80(a4),d0
                bgt.s   sub1
                move.l  d0,48(a4)
                bra.s   noreset1
reset1:         clr.w   96(a4)          | portament
                clr.w   -48(a4)         | volumeslide
                clr.b   -64(a4)         | vibrato
                clr.l   (a4)
                move.l  #spldummy+0x8000,32(a4)
noreset1:
                cmp.w   80+4(a4),d1
                blt.s   noreset2
                move.w  64+4(a4),d5
                beq.s   reset2
sub2:           sub.w   d5,d1
                cmp.w   80+4(a4),d1
                bgt.s   sub2
                move.l  d1,48+4(a4)
                bra.s   noreset2
reset2:         clr.w   96+4(a4)        | portament
                clr.w   -48+4(a4)       | volumeslide
                clr.b   -64+4(a4)       | vibrato
                clr.l   4(a4)
                move.l  #spldummy+0x8000,32+4(a4)
noreset2:
                lea     voltab,a0
                move.w  112+12(a4),d0   | volume
                move.w  112+8(a4),d1
                cmp.w   #0x0040,d0
                blt.s   sp_ok3
                move.w  #0x003f,d0
sp_ok3:
                cmp.w   #0x0040,d1
                blt.s   sp_ok4
                move.w  #0x003f,d1
sp_ok4:
                lsl.w   #8,d0
                lsl.w   #8,d1
                lea     0(a0,d0.w),a2
                lea     0(a0,d1.w),a3
                movea.l 32+12(a4),a0    | sample
                movea.l 32+8(a4),a1
                move.l  48+12(a4),d0    | offset
                move.l  48+8(a4),d1
                movea.l block,a6
                move.w  -96+12(a4),d4   | oldval
                move.w  -96+8(a4),d5
                movea.l 8(a4),a5        | frequence
                move.l  a5,d3
                swap    d3
                movea.l 12(a4),a4
                move.l  a4,d2
                swap    d2
                moveq   #0,d6

                move.w  #50-1,d7
makeblock2:     .rept 5

                add.w   a4,d4           | 1
                addx.w  d2,d0           | 1
                move.b  0(a0,d0.w),d6   | 4
                move.b  0(a2,d6.w),d6   | 4
                add.b   d6,(a6)+        | 3

                add.w   a5,d5           | 1
                addx.w  d3,d1           | 1
                move.b  0(a1,d1.w),d6   | 4
                move.b  0(a3,d6.w),d6   | 4
                add.b   d6,(a6)+        | 3
|                                         26
                .endr
                dbra    d7,makeblock2

                tst.l   longer
                beq.s   notlonger2
                add.w   a4,d4           | 1
                addx.w  d2,d0           | 1
                move.b  0(a0,d0.w),d6   | 4
                move.b  0(a2,d6.w),d6   | 4
                add.b   d6,(a6)+        | 3

                add.w   a5,d5           | 1
                addx.w  d3,d1           | 1
                move.b  0(a1,d1.w),d6   | 4
                move.b  0(a3,d6.w),d6   | 4
                add.b   d6,(a6)+        | 3
|                                         26
notlonger2:
                lea     frequence,a4

                move.w  d4,-96+12(a4)   | oldval
                move.w  d5,-96+8(a4)
                move.l  d0,48+12(a4)
                move.l  d1,48+8(a4)

                cmp.w   80+12(a4),d0
                blt.s   noreset3
                move.w  64+12(a4),d5
                beq.s   reset3
sub3:           sub.w   d5,d0
                cmp.w   80+12(a4),d0
                bgt.s   sub3
                move.l  d0,48+12(a4)
                bra.s   noreset3
reset3:         clr.w   96+12(a4)       | portament
                clr.w   -48+12(a4)      | volumeslide
                clr.b   -64+12(a4)      | vibrato
                clr.l   12(a4)
                move.l  #spldummy+0x8000,32+12(a4)
noreset3:
                cmp.w   80+8(a4),d1
                blt.s   noreset4
                move.w  64+8(a4),d5
                beq.s   reset4
sub4:           sub.w   d5,d1
                cmp.w   80+8(a4),d1
                bgt.s   sub4
                move.l  d1,48+8(a4)
                bra.s   noreset4
reset4:         clr.w   96+8(a4)        | portament
                clr.w   -48+8(a4)       | volumeslide
                clr.b   -64+8(a4)       | vibrato
                clr.l   8(a4)
                move.l  #spldummy+0x8000,32+8(a4)
noreset4:
                lea     0xffff8900.w,a0
                cmpi.l  #block2,block
                bne.s   setother
                move.l  #block1,block
                move.l  #block2,d0
                or.l    #0x03000000,d0
                movep.l d0,0x0001(a0)
                add.l   #500,d0
                add.l   longer,d0
                movep.l d0,0x000d(a0)
                bra.s   endplay

setother:       move.l  #block2,block
                move.l  #block1,d0
                or.l    #0x03000000,d0
                movep.l d0,0x0001(a0)
                add.l   #500,d0
                add.l   longer,d0
                movep.l d0,0x000d(a0)

endplay:        movem.l (sp)+,d0-a6
                rts

                |ENDPART

mplay:          |>PART

                moveq   #0,d6
                lea     dff0d0,a4
                lea     L1054A,a6
                subq.b  #1,(a6)
                bhi     L102F6
                lea     ptr_tab,a3
                movea.l (a3)+,a0
                adda.w  6(a6),a0
                move.w  (a0),d0
                movea.l (a3)+,a0
                adda.w  d0,a0
                movea.l (a3)+,a1
                adda.w  8(a6),a1
                lea     L10588,a2
                moveq   #8,d0
                moveq   #0,d5
L10158:         moveq   #0,d1
                move.w  (a0)+,d1
                lea     0(a1,d1.l),a3
                move.b  (a3)+,d1
                move.b  (a3)+,d3
                move.b  (a3)+,d4
                move.b  d3,d7
                lsr.b   #4,d7
                move.b  d1,d2
                andi.w  #1,d2
                beq.s   L10174
                moveq   #0x10,d2
L10174:         lea     module-8,a3
                or.b    d7,d2
                bne.s   L10188
                move.b  1(a2),d2
                lsl.w   #4,d2
                adda.w  d2,a3
                bra.s   L10196
L10188:         move.b  d2,1(a2)
                lsl.w   #4,d2
                adda.w  d2,a3
                move.w  6(a3),4(a2)
L10196:         andi.w  #0x000f,d3
                move.b  d3,2(a2)
                move.b  d4,3(a2)
                andi.w  #0x00fe,d1
                beq.s   L101E2
                move.w  frequency(pc,d1.w),d7
                subq.w  #3,d3
                beq     L102D2
                subq.w  #2,d3
                beq     L102D2
                or.w    d0,d5
                move.b  d1,(a2)
                move.b  d6,0x0031(a2)
                move.w  d7,0x0018(a2)
                move.l  (a3)+,(a4)
                move.w  (a3)+,4(a4)
                addq.w  #2,a3
                move.l  (a3)+,0x0048(a2)
                move.w  (a3)+,0x004c(a2)
                subq.w  #6,d3
                bmi.s   L1023A
                add.w   d3,d3
                add.w   d3,d3
                movea.l 0x2a(a6,d3.w),a3
                jmp     (a3)
L101E2:         subi.w  #0x000b,d3
                bmi.s   L1023A
                add.w   d3,d3
                add.w   d3,d3
                movea.l 0x2a(a6,d3.w),a3
frequency:      jmp     (a3)

                DC.W 0x0358,0x0328,0x02fa,0x02d0,0x02a6,0x0280,0x025c,0x023a,0x021a,0x01fc,0x01e0,0x01c5
                DC.W 0x01ac,0x0194,0x017d,0x0168,0x0153,0x0140,0x012e,0x011d,0x010d,0x00fe,0x00f0,0x00e2,0x00d6
                DC.W 0x00ca,0x00be,0x00b4,0x00aa,0x00a0,0x0097,0x008f,0x0087,0x007f,0x0078,0x0071

L1023A:         move.w  0x0018(a2),6(a4)
L10240:         move.w  4(a2),8(a4)
                addq.w  #6,a2
                suba.w  #0x0010,a4
                lsr.w   #1,d0
                bne     L10158
                move.w  d5,dff096

                move.b  d5,5(a6)
                move.b  1(a6),(a6)
|                move.l  #0x000050AE,L78
|                move.b  #0x19,LBFDE00
                movea.l ptr_tab,a0
                bset    #0,2(a6)
                beq.s   L10288
                addq.w  #3,8(a6)
                cmpi.w  #0x00c0,8(a6)
                bne.s   L102A0
L10288:         move.w  d6,8(a6)
                addq.w  #2,6(a6)
                move.w  6(a6),d0
                cmp.w   -4(a0),d0 | cmp.w   0xfffc(a0),d0
                bne.s   L102A0
                move.w  -2(a0),6(a6) | move.w  0xfffe(a0),6(a6)

L102A0:         rts

jmp_01:         move.b  d4,5(a2)
                bra.s   L1023A

jmp_02:         move.w  d6,2(a6)
                bra.s   L1023A

jmp_03:         move.w  d6,2(a6)
                move.b  d4,7(a6)
                bra.s   L1023A

jmp_04:         move.b  d4,1(a6)
                bra.s   L1023A

jmp_05:                                 |         andi.b  #0xfd,LBFE001
|                or.b    d4,LBFE001
                bra.s   L1023A

L102D2:         move.b  d6,0x0032(a2)
                move.w  d7,0x001a(a2)
                cmp.w   0x0018(a2),d7
                beq.s   L102EE
                bge     L10240
                move.b  #1,0x0032(a2)
                bra     L10240
L102EE:         move.w  d6,0x001a(a2)
                bra     L10240

L102F6:         lea     L10588,a0
                moveq   #3,d0
L102FC:         moveq   #0,d1
                move.b  2(a0),d1
                beq.s   L10314
                subq.w  #8,d1
                bhi.s   L10314
                addq.w  #7,d1
                add.w   d1,d1
                add.w   d1,d1
                movea.l 0x0a(a6,d1.w),a3
                jmp     (a3)
L10314:         addq.w  #6,a0
                suba.w  #0x0010,a4
                dbra    d0,L102FC
                rts

jmp_06:         moveq   #0,d2
                move.b  3(a0),d2
                sub.w   d2,0x0018(a0)
                cmpi.w  #0x0071,0x0018(a0)
                bpl.s   L10338
                move.w  #0x0071,0x0018(a0)
L10338:         move.w  0x0018(a0),6(a4)
                bra.s   L10314

jmp_07:         moveq   #0,d2
                move.b  3(a0),d2
                add.w   d2,0x0018(a0)
                cmpi.w  #0x0358,0x0018(a0)
                bmi.s   L10358
                move.w  #0x0358,0x0018(a0)
L10358:         move.w  0x0018(a0),6(a4)
                bra.s   L10314

jmp_08:         moveq   #0,d2
                move.b  (a6),d2
                sub.b   1(a6),d2
                neg.b   d2
                move.b  L103AC(pc,d2.w),d2
                beq.s   L103A2
                subq.b  #2,d2
                beq.s   L10380
                move.b  3(a0),d2
                lsr.w   #3,d2
                andi.w  #0x000e,d2
                bra.s   L1038A
L10380:         move.b  3(a0),d2
                andi.w  #0x000f,d2
                add.w   d2,d2
L1038A:         add.b   (a0),d2
                cmp.w   #0x0048,d2
                bls.s   L10394
                moveq   #0x48,d2
L10394:         lea     frequency(pc),a3
                move.w  0(a3,d2.w),6(a4)
                bra     L10314
L103A2:         move.w  0x0018(a0),6(a4)
                bra     L10314

L103AC:         DC.B 0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2,0,1,2
                DC.B 0,1
L103CC:         DC.B 0,0x18,0x31,0x4a,0x61,0x78,0x8d,0xa1,0xb4,0xc5,0xd4,0xe0,0xeb,0xf4,0xfa
                DC.B 0xfd,0xff,0xfd,0xfa,0xf4,0xeb,0xe0,0xd4,0xc5,0xb4,0xa1,0x8d,0x78,0x61,0x4a
                DC.B 0x31,0x18

jmp_09:         move.b  3(a0),d3
                beq.s   L103F6
                move.b  d3,0x0030(a0)
L103F6:         move.b  0x0031(a0),d3
                lsr.b   #2,d3
                andi.w  #0x001f,d3
                moveq   #0,d2
                move.b  L103CC(pc,d3.w),d2
                move.b  0x0030(a0),d3
                andi.w  #0x000f,d3
                mulu    d3,d2
                lsr.w   #7,d2
                move.w  0x0018(a0),d3
                tst.b   0x0031(a0)
                bmi.s   L10420
                add.w   d2,d3
                bra.s   L10422
L10420:         sub.w   d2,d3
L10422:         move.w  d3,6(a4)
                move.b  0x0030(a0),d3
                lsr.b   #2,d3
                andi.w  #0x003c,d3
                add.b   d3,0x0031(a0)
                cmp.b   #0x14,d1
                bne     L10314
L1043C:         move.b  3(a0),d2
                add.b   d2,5(a0)
                bmi.s   L1045E
                cmpi.b  #0x40,5(a0)
                bmi.s   L10454
                move.w  #0x0040,4(a0)
L10454:         move.w  4(a0),8(a4)
                bra     L10314
L1045E:         move.w  d6,4(a0)
                move.w  4(a0),8(a4)
                bra     L10314

jmp_10:         move.b  3(a0),d2
                beq.s   L10476
                move.b  d2,0x001d(a0)
L10476:         move.w  0x001a(a0),d2
                beq.s   L1049E
                move.w  0x001c(a0),d3
                tst.b   0x0032(a0)
                bne.s   L104A8
                add.w   d3,0x0018(a0)
                cmp.w   0x0018(a0),d2
                bgt.s   L10498
                move.w  d2,0x0018(a0)
                move.w  d6,0x001a(a0)
L10498:         move.w  0x0018(a0),6(a4)
L1049E:         cmp.b   #0x10,d1
                beq.s   L1043C
                bra     L10314
L104A8:         sub.w   d3,0x0018(a0)
                cmp.w   0x0018(a0),d2
                blt.s   L10498
                move.w  d2,0x0018(a0)
                move.w  d6,0x001a(a0)
                move.w  0x0018(a0),6(a4)
                cmp.b   #0x10,d1
                beq     L1043C
                bra     L10314

                |ENDPART

main:           |>PART

                lea     points(pc),a0
                lea     trans_tab,a1
                move.w  #16*3-1,d7
id_loop1:       move.w  (a0)+,4(a1)
                addq.w  #8,a1
                dbra    d7,id_loop1

                clr.l   0x00000466.w
m_wait_space:   cmpi.b  #0x39,0xfffffc02.w
                beq     m_exit
                tst.l   0x00000466.w
                beq.s   m_wait_space

                lea     points(pc),a0
                lea     work_points,a1
                move.w  #pn-1,d7
m_copy:         move.l  (a0)+,(a1)+
                move.w  (a0)+,(a1)+
                dbra    d7,m_copy

                lea     work_points,a0
                move.w  x_angle,d0
                move.w  y_angle,d1
                move.w  z_angle,d2
                move.w  #pn,d7
                bsr     rotate

                lea     work_points,a0
                movea.l x_ptr,a1
                move.w  (a1),d0
|                add.w   d0,d0
                add.w   #320,d0
                movea.l y_ptr,a1
                move.w  (a1),d1
|                add.w   d1,d1
                add.w   #60,d1
                movea.l z_ptr,a1
                move.w  (a1),d2
                add.w   d2,d2
                add.w   d2,d2
                add.w   #2000,d2

|                lea     work_points,a0
|                move.w  #160+320,d0
|                move.w  #160,d1
|                move.w  #2000,d2
                move.w  #pn,d7
                bsr     translate

|                lea     work_points,a0
|                lea     points_2d2,a1
|                move.w  #pn,d7
|                bsr     calc_2d

                move.w  #pn-1,d7
                bsr     sort

                lea     work_points,a0
                lea     points_2d,a1
                move.w  #pn,d7
                bsr     calc_2d

                move.w  #pn-1,d7
                bsr     convert

                bsr     m_vbl

                cmpi.w  #3,pt_flag2
                bne     main

                move.l  #novbl,0x00000070.w

                move.l  #screen1+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
m_cls_loop1:    move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,m_cls_loop1

                move.l  #screen2+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
m_cls_loop2:    move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,m_cls_loop2

                clr.w   pt_flag3
                clr.l   clr_tab1
                clr.l   clr_tab2
                move.w  #20,pt_flag
                clr.w   pt_flag2
                move.l  #5*50,timer
                move.l  #svbl,0x00000070.w
                bra     smain

m_exit:         rts

                |ENDPART

vbl:            |>PART

|                move.l  #colortab,timer_b+2

                movem.l d0-a6,-(sp)
                addq.l  #1,0x00000466.w
                lea     0xffff8203.w,a0
                move.l  show_scr,d0
|                add.l   #160*60,d0
|                movep.l d0,0(a0)
                move.b  show_scr+1,0xffff8201.w
                move.b  show_scr+2,0xffff8203.w
                move.b  show_scr+3,0xffff820d.w

                addq.l  #1,timer

                movem.l pal_addr(pc),a0
                movem.l (a0),d0-d7
                movem.l d0-d7,0xffff8240.w
                move.w  #0x0111,0xffff8240.w
                swap    d0
                move.w  d0,tb_color

                cmpi.w  #2,pt_flag2
                bge.s   v_no_add1
                cmpi.l  #sprite_pic+2,pal_addr
                beq.s   v_no_add2
                addi.l  #32,pal_addr
                bra.s   v_no_add2
v_no_add1:
                cmpi.l  #sprite_pic+2-32*15,pal_addr
                bne.s   v_no_add3
                move.w  #3,pt_flag2
                bra.s   v_no_add2
v_no_add3:
                subi.l  #32,pal_addr
v_no_add2:
                cmpi.l  #11*50,timer
                blt     v_timer1

                addq.w  #1,pt_flag3
                cmpi.w  #6,pt_flag3     | anzahl transformationen (6)
                bne.s   v_no_end
                move.w  #2,pt_flag2
                clr.l   timer
                bra.s   v_timer1
v_no_end:
                move.w  #1,timer_flag

v_transform:    movea.l points_ptr(pc),a0
                lea     trans_tab,a1
                move.w  #16*3-1,d7
v_loop1:        move.w  16*3*2(a0),d0
                move.w  (a0),4(a1)
                sub.w   (a0)+,d0
                ext.l   d0
                bmi.s   v_negativ
                swap    d0
                lsr.l   #6,d0
                move.l  d0,(a1)+
                bra.s   v_not_negativ
v_negativ:
                neg.l   d0
                swap    d0
                lsr.l   #6,d0
                neg.l   d0
                move.l  d0,(a1)+
v_not_negativ:
                addq.w  #4,a1
                dbra    d7,v_loop1

                clr.l   timer
                addi.l  #16*3*2,points_ptr
                cmpi.l  #points_end,points_ptr
                bne.s   v_timer1
                move.l  #points2+16*3*2,points_ptr
v_timer1:
                movea.l points_ptr(pc),a0
                lea     trans_tab,a1
                lea     points(pc),a2
                move.w  #16*3-1,d7
v_loop2:        moveq   #0,d0
                move.w  (a2),d0
                cmp.w   (a0),d0
                beq.s   v_transformed
                move.l  4(a1),d0
                add.l   (a1),d0
                move.l  d0,4(a1)
                swap    d0
                move.w  d0,(a2)
v_transformed:
                addq.w  #2,a0
                addq.w  #8,a1
                addq.w  #2,a2
                dbra    d7,v_loop2

                move.l  #timer_b,0x00000120.w
                clr.b   0xfffffa1b.w
                move.b  #1,0xfffffa21.w
                move.b  #8,0xfffffa1b.w

                movea.l x_rot_ptr,a0
                move.w  (a0)+,d0
                cmp.w   #0x8000,d0
                bne.s   v_ok1
                lea     x_rot,a0
                move.w  (a0)+,d0
v_ok1:
                move.l  a0,x_rot_ptr
                add.w   d0,x_angle

                movea.l y_rot_ptr,a0
                move.w  (a0)+,d0
                cmp.w   #0x8000,d0
                bne.s   v_ok2
                lea     y_rot,a0
                move.w  (a0)+,d0
v_ok2:
                move.l  a0,y_rot_ptr
                add.w   d0,y_angle

                movea.l z_rot_ptr,a0
                move.w  (a0)+,d0
                cmp.w   #0x8000,d0
                bne.s   v_ok3
                lea     z_rot,a0
                move.w  (a0)+,d0
v_ok3:
                move.l  a0,z_rot_ptr
                add.w   d0,z_angle

                tst.w   x_angle
                bpl.s   m_ok1a
                addi.w  #3600,x_angle
m_ok1a:
                cmpi.w  #3600,x_angle
                blt.s   m_ok1
                subi.w  #3600,x_angle
m_ok1:
                tst.w   y_angle
                bpl.s   m_ok2a
                addi.w  #3600,y_angle
m_ok2a:
                cmpi.w  #3600,y_angle
                blt.s   m_ok2
                subi.w  #3600,y_angle
m_ok2:
                tst.w   z_angle
                bpl.s   m_ok3a
                addi.w  #3600,z_angle
m_ok3a:
                cmpi.w  #3600,z_angle
                blt.s   m_ok3
                subi.w  #3600,z_angle
m_ok3:

                tst.w   timer_flag
                beq.s   m_ok6

                addq.l  #2,x_ptr
                cmpi.l  #y_way,x_ptr
                bne.s   m_ok4
                move.l  #x_way,x_ptr
m_ok4:
                addq.l  #2,y_ptr
                cmpi.l  #z_way,y_ptr
                bne.s   m_ok5
                move.l  #y_way,y_ptr
m_ok5:
                addq.l  #2,z_ptr
                cmpi.l  #end_way,z_ptr
                bne.s   m_ok6
                move.l  #z_way,z_ptr
m_ok6:
                bsr     mvbl

                movem.l (sp)+,d0-a6
                rte

                |ENDPART

wmain:          |>PART

                clr.l   0x00000466.w
wm_wait_space:  cmpi.b  #0x39,0xfffffc02.w
                beq     wm_exit
                tst.l   0x00000466.w
                beq.s   wm_wait_space

                lea     wpoints(pc),a0
                lea     work_points,a1
                move.w  #wpn-1,d7
wm_copy:        move.l  (a0)+,(a1)+
                move.w  (a0)+,(a1)+
                dbra    d7,wm_copy

                lea     work_points,a0
                move.w  x_angle,d0
                move.w  y_angle,d1
                move.w  z_angle,d2
                move.w  #wpn,d7
                bsr     rotate

                lea     work_points,a0
                move.w  #160+320,d0
                move.w  #160,d1
                move.w  #2100,d2
                move.w  #wpn,d7
                bsr     translate

                lea     work_points,a0
                lea     points_2d2,a1
                move.w  #wpn,d7
                bsr     calc_2d

                move.w  #wpn-1,d7
                bsr     sort

                lea     work_points,a0
                lea     points_2d,a1
                move.w  #wpn,d7
                bsr     calc_2d

                move.w  #wpn-1,d7
                bsr     convert

                move.l  work_scr,cl_addr
                addi.l  #160*89+44,cl_addr
                movem.l cl_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w

                bsr     wm_vbl

                cmpi.w  #3,pt_flag2
                bne     wmain

                move.l  #novbl,0x00000070.w

                move.l  #screen1+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
wm_cls_loop1:   move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,wm_cls_loop1

                move.l  #screen2+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
wm_cls_loop2:   move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,wm_cls_loop2

                clr.w   pt_flag3
                clr.l   clr_tab1
                clr.l   clr_tab2
                move.w  #20,pt_flag
                clr.w   pt_flag2
                move.l  #5*50,timer
                move.l  #svbl,0x00000070.w
                bra     smain

wm_exit:        rts

                |ENDPART

wvbl:           |>PART

                movem.l d0-a6,-(sp)
                addq.l  #1,0x00000466.w
                lea     0xffff8203.w,a0
                move.l  show_scr,d0
                add.l   #160*60,d0
                movep.l d0,0(a0)
                addq.l  #1,timer

                movem.l pal_addr(pc),a0
                movem.l (a0),d0-d7
                movem.l d0-d7,0xffff8240.w
                move.w  #0x0111,0xffff8240.w
                swap    d0
                move.w  d0,tb_color

                cmpi.w  #2,pt_flag2
                bge.s   wv_no_add1
                cmpi.l  #sprite_pic+2,pal_addr
                beq.s   wv_no_add2
                addi.l  #32,pal_addr
                bra.s   wv_no_add2
wv_no_add1:
                cmpi.l  #sprite_pic+2-32*15,pal_addr
                bne.s   wv_no_add3
                move.w  #3,pt_flag2
                bra.s   wv_no_add2
wv_no_add3:
                subi.l  #32,pal_addr
wv_no_add2:
                cmpi.l  #11*50,timer
                blt.s   wv_timer1

                addq.w  #1,pt_flag3
                cmpi.w  #9,pt_flag3     | anzahl transformationen (9)
                bne.s   wv_no_end
                move.w  #2,pt_flag2
                clr.l   timer
                bra.s   wv_timer1
wv_no_end:
                addi.l  #8*3*2,wpoints_ptr
                cmpi.l  #wpoints_end,wpoints_ptr
                bne.s   wv_transform
                move.l  #wpoints+8*3*2,wpoints_ptr

wv_transform:   movea.l wpoints_ptr(pc),a0
                lea     trans_tab,a1
                move.w  #8*3-1,d7
wv_loop1:       move.w  8*3*2(a0),d0
                move.w  (a0),4(a1)
                sub.w   (a0)+,d0
                ext.l   d0
                bmi.s   wv_negativ
                swap    d0
                lsr.l   #6,d0
                move.l  d0,(a1)+
                bra.s   wv_not_negativ
wv_negativ:
                neg.l   d0
                swap    d0
                lsr.l   #6,d0
                neg.l   d0
                move.l  d0,(a1)+
wv_not_negativ:
                addq.w  #4,a1
                dbra    d7,wv_loop1

                clr.l   timer
wv_timer1:

                movea.l wpoints_ptr(pc),a0
                lea     trans_tab,a1
                lea     wpoints(pc),a2
                move.w  #8*3-1,d7
wv_loop2:       moveq   #0,d0
                move.w  (a2),d0
                cmp.w   8*3*2(a0),d0
                beq.s   wv_transformed
                move.l  4(a1),d0
                add.l   (a1),d0
                move.l  d0,4(a1)
                swap    d0
                move.w  d0,(a2)
wv_transformed:
                addq.w  #2,a0
                addq.w  #8,a1
                addq.w  #2,a2
                dbra    d7,wv_loop2

                move.l  #timer_b,0x00000120.w
                clr.b   0xfffffa1b.w
                move.b  #1,0xfffffa21.w
                move.b  #8,0xfffffa1b.w

                movea.l x_rot_ptr,a0
                move.w  (a0)+,d0
                cmp.w   #0x8000,d0
                bne.s   wv_ok1
                lea     x_rot,a0
                move.w  (a0)+,d0
wv_ok1:
                move.l  a0,x_rot_ptr
                add.w   d0,x_angle

                movea.l y_rot_ptr,a0
                move.w  (a0)+,d0
                cmp.w   #0x8000,d0
                bne.s   wv_ok2
                lea     y_rot,a0
                move.w  (a0)+,d0
wv_ok2:
                move.l  a0,y_rot_ptr
                add.w   d0,y_angle

                movea.l z_rot_ptr,a0
                move.w  (a0)+,d0
                cmp.w   #0x8000,d0
                bne.s   wv_ok3
                lea     z_rot,a0
                move.w  (a0)+,d0
wv_ok3:
                move.l  a0,z_rot_ptr
                add.w   d0,z_angle

                tst.w   x_angle
                bpl.s   wm_ok1a
                addi.w  #3600,x_angle
wm_ok1a:
                cmpi.w  #3600,x_angle
                blt.s   wm_ok1
                subi.w  #3600,x_angle
wm_ok1:
                tst.w   y_angle
                bpl.s   wm_ok2a
                addi.w  #3600,y_angle
wm_ok2a:
                cmpi.w  #3600,y_angle
                blt.s   wm_ok2
                subi.w  #3600,y_angle
wm_ok2:
                tst.w   z_angle
                bpl.s   wm_ok3a
                addi.w  #3600,z_angle
wm_ok3a:
                cmpi.w  #3600,z_angle
                blt.s   wm_ok3
                subi.w  #3600,z_angle
wm_ok3:

                bsr     mvbl

                movem.l (sp)+,d0-a6
                rte

                |ENDPART

m_vbl:          |>PART

                bsr.s   clr_bob
                movea.w #16-1,a0
                bsr.s   set_bob

|                not.w   0xffff8240.w
|                not.w   0xffff8240.w

                bsr     switch

                rts

                |ENDPART

wm_vbl:         |>PART

                bsr.s   clr_bob
                movea.w #8-1,a0
                bsr.s   set_bob

                bsr     draw_it

|                not.w   0xffff8240.w
|                not.w   0xffff8240.w

                bsr     switch

                rts

                |ENDPART

clr_bob:        |>PART

                movem.l cb_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w

                movea.l clr_tab_addr,a0
cb_loop:        move.l  (a0)+,d0
                beq.s   cb_end
                move.l  d0,0xffff8a32.w
                move.w  #lines,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                bra.s   cb_loop
cb_end:         rts

                |ENDPART

set_bob:        |>PART
| a0.w = Anzahl

                movem.l sb_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w

                move.w  a0,d7
                lea     x_data,a0
                lea     deep_tab,a1
                lea     end_mask(pc),a2
                movea.l clr_tab_addr,a3

sb_loop:        move.w  #words,0xffff8a36.w
                move.w  #160-words*8+8,0xffff8a30.w

                movea.l work_scr,a4
                move.w  (a0)+,d0
                move.w  d0,d1
                and.w   #0x000f,d1
                move.b  d1,0xffff8a3d.w

                beq.s   sb_ok1
                ori.b   #0x40,0xffff8a3d.w
                move.w  #words+1,0xffff8a36.w
                move.w  #160-(words+1)*8+8,0xffff8a30.w

sb_ok1:         and.w   #0xfff0,d0
                lsr.w   #1,d0
                adda.w  d0,a4
                adda.l  (a0)+,a4
                move.l  a4,(a3)+

                lsl.w   #2,d1
                move.w  0(a2,d1.w),0xffff8a28.w
                move.w  2(a2,d1.w),0xffff8a2c.w

                move.w  (a0)+,d1
                sub.w   #2000-405,d1
                lsr.w   #3,d1
                add.w   d1,d1
                add.w   d1,d1
                add.w   d1,d1

                .if mask
                move.b  #mask_mode,0xffff8a3b.w
                move.l  0(a1,d1.w),d6

                .rept planes
                move.l  a4,0xffff8a32.w
                move.l  d6,0xffff8a24.w
                move.w  #lines,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                addq.l  #2,a4
                addq.l  #2,d6
                .endr
                subq.l  #planes*2,a4
                .endif

                .if sprite
                move.b  #sprite_mode,0xffff8a3b.w
                move.l  4(a1,d1.w),d6

                .rept planes
                move.l  a4,0xffff8a32.w
                move.l  d6,0xffff8a24.w
                move.w  #lines,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                addq.l  #2,a4
                addq.l  #2,d6
                .endr
                .endif

                dbra    d7,sb_loop

                clr.l   (a3)
                rts

                |ENDPART

draw_it:        |>PART

                moveq   #16,d4
                movea.l work_scr,a0
                addq.w  #4,a0
                lea     points_2d2,a1
                lea     wline_tab(pc),a2

di_loop:        move.w  (a2)+,d1
                bmi.s   di_end
                add.w   d1,d1
                add.w   d1,d1
                move.w  0(a1,d1.w),d0
                add.w   d4,d0
                move.w  2(a1,d1.w),d1
                add.w   d4,d1
                move.w  (a2)+,d3
                add.w   d3,d3
                add.w   d3,d3
                move.w  0(a1,d3.w),d2
                add.w   d4,d2
                move.w  2(a1,d3.w),d3
                add.w   d4,d3

                movem.l d4/a0-a2,-(sp)
                bsr.s   draw_line
                movem.l (sp)+,d4/a0-a2
                bra.s   di_loop

di_end:         rts

                |ENDPART

draw_line:      |>PART
| a0.l = screenaddress
| d0.w = x0
| d1.w = y0
| d2.w = x1
| d3.w = y1

                cmp.w   d0,d2
                bgt.s   dl_no_change
                exg     d0,d2
                exg     d1,d3
dl_no_change:

                moveq   #0,d4
                move.w  d2,d4
                sub.w   d0,d4
                moveq   #0,d5
                move.w  d3,d5
                sub.w   d1,d5

                tst.w   d5
                bmi     dl_mode4

                cmp.w   d5,d4
                blt.s   dl_mode2
                beq     dl_mode3

                move.w  d4,d7
                swap    d5
                divu    d4,d5

                move.w  d0,d6
                lsr.w   #1,d0
                and.w   #0xfff8,d0
                adda.w  d0,a0
                mulu    #160,d1
                adda.l  d1,a0

                lea     dl_start_tab(pc),a1
                and.w   #0x000f,d6
                add.w   d6,d6
                move.w  0(a1,d6.w),d6

                move.w  #0x8000,d0
dl_loop1:       or.w    d6,(a0)
                lsr.w   #1,d6
                bne.s   dl_ok1
                move.w  #0x8000,d6
                addq.l  #8,a0
dl_ok1:
                add.w   d5,d0
                bcc.s   dl_ok2
                lea     160(a0),a0
dl_ok2:
                dbra    d7,dl_loop1

                rts

dl_mode2:       move.w  d5,d7
                swap    d4
                divu    d5,d4

                move.w  d0,d6
                lsr.w   #1,d0
                and.w   #0xfff8,d0
                adda.w  d0,a0
                mulu    #160,d1
                adda.l  d1,a0

                lea     dl_start_tab(pc),a1
                and.w   #0x000f,d6
                add.w   d6,d6
                move.w  0(a1,d6.w),d6

                move.w  #0x8000,d0
dl_loop2:       or.w    d6,(a0)
                lea     160(a0),a0

                add.w   d4,d0
                bcc.s   dl_ok3
                lsr.w   #1,d6
                bne.s   dl_ok3
                move.w  #0x8000,d6
                addq.l  #8,a0
dl_ok3:
                dbra    d7,dl_loop2

                rts

dl_mode3:       move.w  d5,d7

                move.w  d0,d6
                lsr.w   #1,d0
                and.w   #0xfff8,d0
                adda.w  d0,a0
                mulu    #160,d1
                adda.l  d1,a0

                lea     dl_start_tab(pc),a1
                and.w   #0x000f,d6
                add.w   d6,d6
                move.w  0(a1,d6.w),d6

dl_loop3:       or.w    d6,(a0)
                lea     160(a0),a0
                lsr.w   #1,d6
                bne.s   dl_ok5
                move.w  #0x8000,d6
                addq.l  #8,a0
dl_ok5:
                dbra    d7,dl_loop3

                rts

dl_mode4:       neg.w   d5

                cmp.w   d5,d4
                blt.s   dl_mode5
                beq     dl_mode6

                move.w  d4,d7
                swap    d5
                divu    d4,d5

                move.w  d0,d6
                lsr.w   #1,d0
                and.w   #0xfff8,d0
                adda.w  d0,a0
                mulu    #160,d1
                adda.l  d1,a0

                lea     dl_start_tab(pc),a1
                and.w   #0x000f,d6
                add.w   d6,d6
                move.w  0(a1,d6.w),d6

                move.w  #0x8000,d0
dl_loop4:       or.w    d6,(a0)
                lsr.w   #1,d6
                bne.s   dl_ok6
                move.w  #0x8000,d6
                addq.l  #8,a0
dl_ok6:
                add.w   d5,d0
                bcc.s   dl_ok7
                lea     -160(a0),a0
dl_ok7:
                dbra    d7,dl_loop4

                rts

dl_mode5:       move.w  d5,d7
                swap    d4
                divu    d5,d4

                move.w  d0,d6
                lsr.w   #1,d0
                and.w   #0xfff8,d0
                adda.w  d0,a0
                mulu    #160,d1
                adda.l  d1,a0

                lea     dl_start_tab(pc),a1
                and.w   #0x000f,d6
                add.w   d6,d6
                move.w  0(a1,d6.w),d6

                move.w  #0x8000,d0
dl_loop5:       or.w    d6,(a0)
                lea     -160(a0),a0

                add.w   d4,d0
                bcc.s   dl_ok8
                lsr.w   #1,d6
                bne.s   dl_ok8
                move.w  #0x8000,d6
                addq.l  #8,a0
dl_ok8:
                dbra    d7,dl_loop5

                rts

dl_mode6:       move.w  d5,d7

                move.w  d0,d6
                lsr.w   #1,d0
                and.w   #0xfff8,d0
                adda.w  d0,a0
                mulu    #160,d1
                adda.l  d1,a0

                lea     dl_start_tab(pc),a1
                and.w   #0x000f,d6
                add.w   d6,d6
                move.w  0(a1,d6.w),d6

dl_loop6:       or.w    d6,(a0)
                lea     -160(a0),a0
                lsr.w   #1,d6
                bne.s   dl_ok9
                move.w  #0x8000,d6
                addq.l  #8,a0
dl_ok9:
                dbra    d7,dl_loop6

                rts

dl_start_tab:   DC.W 0x8000,0x4000,0x2000,0x1000,0x0800,0x0400,0x0200,0x0100
                DC.W 0x0080,0x0040,0x0020,0x0010,0x0008,0x0004,0x0002,0x0001

                |ENDPART

hemain:         |>PART

                movea.l script2_ptr,a0
                move.w  (a0)+,points_value
                bpl.s   hem_ok4
                move.l  #script2,script2_ptr
                bra.s   hemain
hem_ok4:
                move.l  (a0)+,points2_ptr
                move.l  (a0)+,line2_ptr

                move.l  a0,script2_ptr

                clr.w   heflag
                cmpi.w  #49,points_value
                bne.s   hem_ok5
                move.w  #1,heflag
hem_ok5:

hem_again:      clr.l   0x00000466.w
hem_wait_space: cmpi.b  #0x39,0xfffffc02.w | auf SPACE-Taste warten
                beq     hem_exit
                cmpi.l  #1,0x00000466.w
                blt.s   hem_wait_space

|                move.w  #0x0200,0xFFFF8240.w

                move.l  work_scr,blit_addr
                addi.l  #60*160+32-8,blit_addr
                movem.l blit_clr,d0-d7
                movem.l d0-d7,0xffff8a20.w

                movea.l points2_ptr,a0
                lea     work_points,a1
                move.w  points_value,d7
                subq.w  #1,d7
hem_copy:       move.l  (a0)+,(a1)+
                move.w  (a0)+,(a1)+
                dbra    d7,hem_copy

                tst.w   heflag
                beq.s   hem_patch1

                lea     work_points+41*6,a0
                clr.w   d0
                move.w  ry_angle,d1
                clr.w   d2
                move.w  #8,d7
                bsr     rotate
hem_patch1:

                lea     work_points,a0
                move.w  x_angle,d0
                move.w  y_angle,d1
                move.w  z_angle,d2
                move.w  points_value,d7
                bsr     rotate

                lea     work_points,a0
                movea.l x_ptr,a1
                move.w  (a1),d0
                add.w   d0,d0
                add.w   #320,d0
                movea.l y_ptr,a1
                move.w  (a1),d1
                add.w   d1,d1
                add.w   #60,d1
                movea.l z_ptr,a1
                move.w  (a1),d2
                add.w   d2,d2
                add.w   d2,d2
                add.w   #2000,d2

                move.w  #160+320,d0
                move.w  #160,d1
                move.w  #4500,d2
                move.w  points_value,d7
                bsr     translate

                lea     work_points,a0
                lea     points_2d,a1
                move.w  points_value,d7
                bsr     calc_2d

                tst.w   heflag
                beq.s   he_patch1

                lea     heline_tab3,a0
                lea     points_2d,a1
                bsr     draw_it_poly
he_patch1:
                movea.l line2_ptr,a0
                lea     points_2d,a1
                bsr     draw_it_poly

                tst.w   heflag
                beq.s   he_patch2

                lea     heline_tab2,a0
                lea     points_2d,a1
                bsr     draw_it_poly
he_patch2:
                cmpi.l  #screen1,work_scr
                bne.s   hem_set_other
                move.l  #screen2,work_scr
                move.l  #screen1,show_scr
                bra.s   hem_other
hem_set_other:  move.l  #screen1,work_scr
                move.l  #screen2,show_scr
hem_other:
hem_wait:       cmpi.l  #3,0x00000466.w
                blt.s   hem_wait

|                clr.w   0xFFFF8240.w

                cmpi.w  #3,pt_flag2
                bne     hem_again

                move.l  #novbl,0x00000070.w

                move.l  #screen1+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
hem_cls_loop1:  move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,hem_cls_loop1

                move.l  #screen2+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
hem_cls_loop2:  move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,hem_cls_loop2

                clr.w   pt_flag3
                clr.l   clr_tab1
                clr.l   clr_tab2
                move.w  #20,pt_flag
                clr.w   pt_flag2
                move.l  #5*50,timer
                move.l  #svbl,0x00000070.w
                bra     smain

hem_exit:       rts

                |ENDPART

hevbl:          |>PART

                movem.l d0-a6,-(sp)

                addq.l  #1,timer

                cmpi.l  #50*30,timer    | zeit fï¿½r heli
                bne.s   hev_no_end
                move.w  #2,pt_flag2
hev_no_end:
                addq.l  #1,0x00000466.w
                lea     0xffff8203.w,a0
                move.l  show_scr,d0
|                movep.l d0,0(a0)
                move.b  show_scr+1,0xffff8201.w
                move.b  show_scr+2,0xffff8203.w
                move.b  show_scr+3,0xffff820d.w

                movea.l pal_addr2(pc),a0
                movem.l (a0),d0-d7
                movem.l d0-d7,0xffff8240.w
                move.w  #0x0111,0xffff8240.w
                swap    d0
                move.w  d0,tb_color

                move.l  #timer_b,0x00000120.w
                clr.b   0xfffffa1b.w
                move.b  #1,0xfffffa21.w
                move.b  #8,0xfffffa1b.w

                cmpi.w  #2,pt_flag2
                bge.s   hev_no_add1
                cmpi.l  #backgnd+2,pal_addr2
                beq.s   hev_no_add2
                addi.l  #32,pal_addr2
                bra.s   hev_no_add2
hev_no_add1:
                cmpi.l  #backgnd+2-32*15,pal_addr2
                bne.s   hev_no_add3
                move.w  #3,pt_flag2
                bra.s   hev_no_add2
hev_no_add3:
                subi.l  #32,pal_addr2
hev_no_add2:
                bsr     mvbl

                addi.w  #16,x_angle
                addi.w  #97,ry_angle    | 97
                addi.w  #11,y_angle
                addi.w  #13,z_angle

                cmpi.w  #3600,x_angle
                blt.s   hem_ok1
                subi.w  #3600,x_angle
hem_ok1:
                cmpi.w  #3600,y_angle
                blt.s   hem_ok2
                subi.w  #3600,y_angle
hem_ok2:
                cmpi.w  #3600,z_angle
                blt.s   hem_ok3
                subi.w  #3600,z_angle
hem_ok3:
                cmpi.w  #3600,ry_angle
                blt.s   hem_ok7
                subi.w  #3600,ry_angle
hem_ok7:
|                addq.l  #2,x_ptr
|                cmpi.l  #y_way,x_ptr
|                bne.s   hem_ok4
|                move.l  #x_way,x_ptr
|hem_ok4:
|                addq.l  #2,y_ptr
|                cmpi.l  #z_way,y_ptr
|                bne.s   hem_ok5
|                move.l  #y_way,y_ptr
|hem_ok5:
|                addq.l  #2,z_ptr
|                cmpi.l  #end_way,z_ptr
|                bne.s   hem_ok6
|                move.l  #z_way,z_ptr
|hem_ok6:
                movem.l (sp)+,d0-a6
                rte

                |ENDPART

make_cross:     |>PART

                lea     shpoints,a0
                lea     shline_tab,a1
                lea     area_value,a5

mc_again:       tst.w   (a1)
                bmi     mc_end

                move.w  2(a1),d0
                move.w  d0,d1
                add.w   d1,d1
                add.w   d0,d0
                add.w   d0,d0
                add.w   d1,d0
                movem.w 0(a0,d0.w),d2-d4

                move.w  4(a1),d0
                move.w  d0,d1
                add.w   d1,d1
                add.w   d0,d0
                add.w   d0,d0
                add.w   d1,d0
                movem.w 0(a0,d0.w),d5-d7

                move.w  (a1),d0
                move.w  d0,d1
                add.w   d1,d1
                add.w   d0,d0
                add.w   d0,d0
                add.w   d1,d0
                sub.w   0(a0,d0.w),d2   | ax
                sub.w   0(a0,d0.w),d5   | bx
                sub.w   2(a0,d0.w),d3   | ay
                sub.w   2(a0,d0.w),d6   | by
                sub.w   4(a0,d0.w),d4   | az
                sub.w   4(a0,d0.w),d7   | bz

                move.w  d7,d0
                move.w  d6,d1
                muls    d3,d0
                muls    d4,d1
                sub.l   d1,d0
                movea.l d0,a2           | cx

                move.w  d5,d0
                move.w  d7,d1
                muls    d4,d0
                muls    d2,d1
                sub.l   d1,d0
                movea.l d0,a3           | cy

                move.w  d6,d0
                move.w  d5,d1
                muls    d2,d0
                muls    d3,d1
                sub.l   d1,d0
                movea.l d0,a4           | cz

                move.l  a2,d0
                move.l  a3,d1
                move.l  a4,d2
                muls    d0,d0
                muls    d1,d1
                muls    d2,d2
                add.l   d2,d1
                add.l   d1,d0

                swap    d0
                move.w  d0,(a5)+
                lea     10(a1),a1
                bra     mc_again
mc_end:
                rts

                |ENDPART

shmain:         |>PART

shm_again:
|                cmpi.b  #1,0xFFFFFC02.w
|                beq.s   m_again
                clr.l   0x00000466.w
shm_wait_space: cmpi.b  #0x39,0xfffffc02.w | auf SPACE-Taste warten
                beq     shm_exit
|                btst    #1,mouse_key
|                bne     m_exit
                cmpi.l  #1,0x00000466.w
                blt.s   shm_wait_space

|                move.w  #0x0200,0xFFFF8240.w

                move.l  work_scr,blit_addr
                addi.l  #60*160+32-8,blit_addr
                movem.l blit_clr,d0-d7
                movem.l d0-d7,0xffff8a20.w

                lea     shpoints,a0
                lea     work_points,a1
                move.w  #shpn-1,d7
shm_copy:       move.l  (a0)+,(a1)+
                move.w  (a0)+,(a1)+
                dbra    d7,shm_copy

                lea     work_points,a0
                move.w  x_angle,d0
                move.w  y_angle,d1
                move.w  z_angle,d2
                move.w  #shpn,d7
                bsr     rotate

                lea     work_points,a0
|                move.w  x_pos(pc),d0
                move.w  #320+160,d0
|                move.w  y_pos(pc),d1
                move.w  #160,d1
|                move.w  z_pos(pc),d2
                move.w  #1200,d2
                move.w  #shpn,d7
                bsr     translate

                lea     work_points,a0
                lea     points_2d,a1
                move.w  #shpn,d7
                bsr     calc_2d

                lea     shline_tab,a0
                lea     points_2d,a1
                bsr     sh_draw_it

|                bsr.s   print_values

                cmpi.l  #screen1,work_scr
                bne.s   shm_set_other
                move.l  #screen2,work_scr
                move.l  #screen1,show_scr
                bra.s   shm_other
shm_set_other:  move.l  #screen1,work_scr
                move.l  #screen2,show_scr
shm_other:
|m_wait:         cmpi.l  #1,0x00000466.w
|                blt.s   m_wait

|                subi.w  #0x0100,0xFFFF825E.w
|                clr.w   0xFFFF8240.w

                cmpi.w  #3,pt_flag2
                bne     shmain

                move.l  #novbl,0x00000070.w

                move.l  #screen1+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
shm_cls_loop1:  move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,shm_cls_loop1

                move.l  #screen2+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
shm_cls_loop2:  move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,shm_cls_loop2

                clr.w   pt_flag3
                clr.l   clr_tab1
                clr.l   clr_tab2
                move.w  #20,pt_flag
                clr.w   pt_flag2
                move.l  #5*50,timer
                move.l  #svbl,0x00000070.w
                bra     smain

shm_exit:       rts

                |ENDPART

shvbl:          |>PART

                movem.l d0-a6,-(sp)

                addq.l  #1,timer

                cmpi.l  #50*30,timer    | zeit fï¿½r heli
                bne.s   shv_no_end
                move.w  #2,pt_flag2
shv_no_end:
                addq.l  #1,0x00000466.w
                lea     0xffff8203.w,a0
                move.l  show_scr,d0
|                movep.l d0,0(a0)
                move.b  show_scr+1,0xffff8201.w
                move.b  show_scr+2,0xffff8203.w
                move.b  show_scr+3,0xffff820d.w

                movea.l pal_addr3(pc),a0
                movem.l (a0),d0-d7
                movem.l d0-d7,0xffff8240.w
                move.w  #0x0111,0xffff8240.w
                swap    d0
                move.w  d0,tb_color

                move.l  #timer_b,0x00000120.w
                clr.b   0xfffffa1b.w
                move.b  #1,0xfffffa21.w
                move.b  #8,0xfffffa1b.w

                cmpi.w  #2,pt_flag2
                bge.s   shv_no_add1
                cmpi.l  #shade_col,pal_addr3
                beq.s   shv_no_add2
                addi.l  #32,pal_addr3
                bra.s   shv_no_add2
shv_no_add1:
                cmpi.l  #shade_col-32*15,pal_addr3
                bne.s   shv_no_add3
                move.w  #3,pt_flag2
                bra.s   shv_no_add2
shv_no_add3:
                subi.l  #32,pal_addr3
shv_no_add2:
                bsr     mvbl

                addi.w  #16,x_angle
|                addi.w  #97,ry_angle    | 97
                addi.w  #11,y_angle
                addi.w  #13,z_angle

                cmpi.w  #3600,x_angle
                blt.s   shm_ok1
                subi.w  #3600,x_angle
shm_ok1:
                cmpi.w  #3600,y_angle
                blt.s   shm_ok2
                subi.w  #3600,y_angle
shm_ok2:
                cmpi.w  #3600,z_angle
                blt.s   shm_ok3
                subi.w  #3600,z_angle
shm_ok3:
                movem.l (sp)+,d0-a6
                rte

                |ENDPART

sh_draw_it:     |>PART
| a0.l = line-table address
| a1.l = 2d-point-table address

                movea.l a0,a2
                movea.l work_scr,a0
                lea     sort_table,a3
                lea     work_points,a4
                lea     area_value,a5

shdi_loop:      move.w  (a2),d0
                bmi     shdi_go
                add.w   d0,d0
                add.w   d0,d0
                move.w  2(a1,d0.w),d1   | y1
                move.w  0(a1,d0.w),d0   | x1
                move.w  2(a2),d2
                add.w   d2,d2
                add.w   d2,d2
                move.w  2(a1,d2.w),d3   | y2
                move.w  0(a1,d2.w),d2   | x2
                move.w  4(a2),d4
                add.w   d4,d4
                add.w   d4,d4
                move.w  2(a1,d4.w),d5   | y3
                move.w  0(a1,d4.w),d4   | x3
                sub.w   d0,d2
                sub.w   d0,d4
                sub.w   d1,d3
                sub.w   d1,d5
                muls    d2,d5
                muls    d3,d4
                sub.l   d4,d5
                bmi     shdi_next

                move.w  2(a2),d0        | -------------------
                move.w  d0,d1
                add.w   d1,d1
                add.w   d0,d0
                add.w   d0,d0
                add.w   d1,d0
                movem.w 0(a4,d0.w),d2-d4

                move.w  4(a2),d0
                move.w  d0,d1
                add.w   d1,d1
                add.w   d0,d0
                add.w   d0,d0
                add.w   d1,d0
                movem.w 0(a4,d0.w),d5-d7

                move.w  (a2),d0
                move.w  d0,d1
                add.w   d1,d1
                add.w   d0,d0
                add.w   d0,d0
                add.w   d1,d0
                sub.w   0(a4,d0.w),d2   | ax
                sub.w   0(a4,d0.w),d5   | bx
                sub.w   2(a4,d0.w),d3   | ay
                sub.w   2(a4,d0.w),d6   | by
                sub.w   4(a4,d0.w),d4   | az
                sub.w   4(a4,d0.w),d7   | bz

|                move.w  D7,D0
|                move.w  D6,D1
|                muls    D3,D0
|                muls    D4,D1
|                sub.l   D1,D0
|                movea.l D0,A2           | cx

|                move.w  D5,D0
|                move.w  D7,D1
|                muls    D4,D0
|                muls    D2,D1
|                sub.l   D1,D0
|                movea.l D0,A3           | cy

                move.w  d6,d0
                move.w  d5,d1
                muls    d2,d0
                muls    d3,d1
                sub.l   d1,d0
|                movea.l D0,A4           | cz

|                move.l  A2,D0
|                move.l  A3,D1
|                move.l  A4,D2
|                muls    D0,D0
|                muls    D1,D1
|                muls    D2,D2
|                add.l   D2,D1
|                add.l   D1,D0
                muls    d0,d0
                clr.w   d0
                swap    d0
                move.w  (a5),d1
                lsr.w   #3,d1
                divu    d1,d0
                addq.w  #1,d0
                cmp.w   #8,d0
                blt.s   no_patch1
                move.w  #7,d0
no_patch1:
                add.b   9(a2),d0
                move.b  d0,8(a2)
x:
                move.l  a2,(a3)+
                move.w  (a2),d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                add.w   d0,d0
                move.w  4(a4,d0.w),d2
                move.w  2(a2),d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                add.w   d0,d0
                add.w   4(a4,d0.w),d2
                move.w  4(a2),d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                add.w   d0,d0
                add.w   4(a4,d0.w),d2
                move.w  6(a2),d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                add.w   d0,d0
                add.w   4(a4,d0.w),d2
                ext.l   d2
                lsr.l   #2,d2
                move.w  d2,(a3)+
                clr.w   (a3)+

shdi_next:      lea     10(a2),a2
                addq.w  #2,a5
                bra     shdi_loop
shdi_go:
                move.l  #-1,(a3)
                move.w  #-1,-2(a3)

                lea     sort_table,a3
                tst.l   (a3)
                bmi     shdi_exit
shdi_go_again:  movea.l a3,a4
shdi_loop2:     tst.w   6(a4)
                bne.s   shdi_next1
                move.w  4(a4),d0
                cmp.w   12(a4),d0
                bge.s   shdi_ok
                move.l  (a4),d0
                move.l  8(a4),(a4)
                move.l  d0,8(a4)
                move.w  4(a4),d0
                move.w  12(a4),4(a4)
                move.w  d0,12(a4)
shdi_ok:        addq.l  #8,a4
                bra.s   shdi_loop2

shdi_next1:     move.w  #-1,-2(a4)
                cmpa.l  a3,a4
                bne.s   shdi_go_again

shdi_draw:      lea     sort_table,a2
shdi_loop3:     lea     area,a3
                tst.l   (a2)
                bmi.s   shdi_exit
                movea.l (a2),a4
                move.w  (a4),d6
                move.w  2(a4),d7
                add.w   d6,d6
                add.w   d6,d6
                add.w   d7,d7
                add.w   d7,d7
                move.l  0(a1,d6.w),(a3)+
                move.l  0(a1,d7.w),(a3)+

                move.w  4(a4),d6
                move.w  6(a4),d7
                add.w   d6,d6
                add.w   d6,d6
                add.w   d7,d7
                add.w   d7,d7
                move.l  0(a1,d6.w),(a3)+
                move.l  0(a1,d7.w),(a3)+

                move.b  8(a4),1(a3)

                movem.l a0-a2,-(sp)
                movea.l a0,a1
                lea     area,a0
                bsr     draw_poly4
                movem.l (sp)+,a0-a2

                addq.l  #8,a2
                bra.s   shdi_loop3

shdi_exit:      rts

                |ENDPART

draw_it_poly:   |>PART
| a0.l = line-table address
| a1.l = 2d-point-table address

                movea.l a0,a2
                movea.l work_scr,a0
                lea     sort_table,a3
                lea     work_points,a4

dip_loop:       move.w  (a2),d0
                bmi     dip_go
                add.w   d0,d0
                add.w   d0,d0
                move.w  2(a1,d0.w),d1   | y1
                move.w  0(a1,d0.w),d0   | x1
                move.w  2(a2),d2
                add.w   d2,d2
                add.w   d2,d2
                move.w  2(a1,d2.w),d3   | y2
                move.w  0(a1,d2.w),d2   | x2
                move.w  4(a2),d4
                add.w   d4,d4
                add.w   d4,d4
                move.w  2(a1,d4.w),d5   | y3
                move.w  0(a1,d4.w),d4   | x3
                sub.w   d0,d2
                sub.w   d0,d4
                sub.w   d1,d3
                sub.w   d1,d5
                muls    d2,d5
                muls    d3,d4
                sub.l   d4,d5
                bmi.s   dip_next

                move.l  a2,(a3)+
                move.w  (a2),d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                add.w   d0,d0
                move.w  4(a4,d0.w),d2
                move.w  2(a2),d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                add.w   d0,d0
                add.w   4(a4,d0.w),d2
                move.w  4(a2),d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                add.w   d0,d0
                add.w   4(a4,d0.w),d2
                move.w  6(a2),d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d1,d0
                add.w   d0,d0
                add.w   4(a4,d0.w),d2
                ext.l   d2
                lsr.l   #2,d2
                move.w  d2,(a3)+
                clr.w   (a3)+

dip_next:       lea     10(a2),a2
                bra     dip_loop
dip_go:
                move.l  #-1,(a3)
                move.w  #-1,-2(a3)

                lea     sort_table,a3
                tst.l   (a3)
                bmi     dip_exit
dip_go_again:   movea.l a3,a4
dip_loop2:      tst.w   6(a4)
                bne.s   dip_next1
                move.w  4(a4),d0
                cmp.w   12(a4),d0
                bge.s   dip_ok
                move.l  (a4),d0
                move.l  8(a4),(a4)
                move.l  d0,8(a4)
                move.w  4(a4),d0
                move.w  12(a4),4(a4)
                move.w  d0,12(a4)
dip_ok:         addq.l  #8,a4
                bra.s   dip_loop2

dip_next1:      move.w  #-1,-2(a4)
                cmpa.l  a3,a4
                bne.s   dip_go_again

dip_draw:       lea     sort_table,a2
dip_loop3:      lea     area,a3
                tst.l   (a2)
                bmi.s   dip_exit
                movea.l (a2),a4
                move.w  (a4),d6
                move.w  2(a4),d7
                add.w   d6,d6
                add.w   d6,d6
                add.w   d7,d7
                add.w   d7,d7
                move.l  0(a1,d6.w),(a3)+
                move.l  0(a1,d7.w),(a3)+

                move.w  4(a4),d6
                move.w  6(a4),d7
                add.w   d6,d6
                add.w   d6,d6
                add.w   d7,d7
                add.w   d7,d7
                move.l  0(a1,d6.w),(a3)+
                move.l  0(a1,d7.w),(a3)+

                move.w  8(a4),(a3)

                movem.l a0-a2,-(sp)
                movea.l a0,a1
                lea     area,a0
                bsr.s   draw_poly4
                movem.l (sp)+,a0-a2

                addq.l  #8,a2
                bra.s   dip_loop3

dip_exit:       rts

                |ENDPART

draw_poly4:     |>PART
| a0.l = Coordinateaddress
| a1.l = Screenaddress

                lea     160*15+8(a1),a1

                movem.w (a0),d0-d7
                cmp.w   d1,d3
                blt.s   dp4_exg1
                cmp.w   d1,d5
                blt.s   dp4_exg2
                cmp.w   d1,d7
                blt.s   dp4_exg3
                bra.s   dp4_ok1         | d1
dp4_exg1:       cmp.w   d3,d5
                blt.s   dp4_exg2
                cmp.w   d3,d7
                blt.s   dp4_exg3
                exg     d2,d4           | d3
                exg     d3,d5
                exg     d0,d6
                exg     d1,d7
                exg     d4,d0
                exg     d5,d1
                bra.s   dp4_ok1
dp4_exg2:       cmp.w   d5,d7
                blt.s   dp4_exg3
                exg     d4,d0           | d5
                exg     d5,d1
                exg     d2,d6
                exg     d3,d7
                bra.s   dp4_ok1
dp4_exg3:       exg     d0,d6           | d7
                exg     d1,d7
                exg     d6,d2
                exg     d7,d3
                exg     d6,d4
                exg     d7,d5

dp4_ok1:
                movem.w d0-d7,(a0)

                lea     dp_leftright,a2

                move.w  #0xffff,12(a2)

                move.w  #-1,8(a2)       | ï¿½bertrag (positiv)
                sub.w   d0,d6           | x3-x0
                bpl.s   dp4_ok3
                neg.w   d6
                move.w  #1,8(a2)        | ï¿½bertrag (negativ)
dp4_ok3:
                sub.w   d1,d7           | y3-y0
                addq.w  #1,d7

                ext.l   d6
                divu    d7,d6           | dx/dy
                move.w  d6,(a2)         | Vorkommastelle (l)
                clr.w   d6
                divu    d7,d6
                move.w  d6,2(a2)        | Nachkommastelle (l)

                tst.l   (a2)
                bne.s   dp4_ok4
                clr.w   8(a2)           | ï¿½bertrag
dp4_ok4:
                tst.w   8(a2)           | ï¿½bertrag
                bmi.s   dp4_ok4a
                neg.w   (a2)
dp4_ok4a:

                move.w  #-1,10(a2)      | ï¿½bertrag (positiv)
                sub.w   d0,d2           | x1-x0
                bpl.s   dp4_ok5
                neg.w   d2
                move.w  #1,10(a2)       | ï¿½bertrag (negativ)
dp4_ok5:
                sub.w   d1,d3           | y1-y0
                addq.w  #1,d3
                ext.l   d2
                divu    d3,d2           | dx/dy
                move.w  d2,4(a2)        | Vorkommastelle (r)
                clr.w   d2
                divu    d3,d2
                move.w  d2,6(a2)        | Nachkommastelle (r)

                tst.l   4(a2)
                bne.s   dp4_ok7
                clr.w   10(a2)          | ï¿½bertrag
dp4_ok7:
                tst.w   10(a2)          | ï¿½bertrag
                bmi.s   dp4_ok7a
                neg.w   4(a2)
dp4_ok7a:

                lea     16(a2),a2       | --------------------------------------

                movem.w 4(a0),d2-d3     | restore (x1, y1, x3, y3)
                movem.w 12(a0),d6-d7

                cmp.w   d3,d7
                blt     dp4_xok1

                move.w  #0x00ff,12(a2)
                move.w  6(a0),d0
                sub.w   2(a0),d0
                addq.w  #1,d0
                move.w  d0,14-16(a2)    | lines
                move.l  -16(a2),(a2)
                move.w  8-16(a2),8(a2)

                move.w  #-1,10(a2)      | ï¿½bertrag (positiv)
                sub.w   d2,d4           | x2-x1
                bpl.s   dp4_ok8
                neg.w   d4
                move.w  #1,10(a2)       | ï¿½bertrag (negativ)
dp4_ok8:
                sub.w   d3,d5           | y2-y1
                addq.w  #1,d5
                ext.l   d4
                divu    d5,d4           | dx/dy
                move.w  d4,4(a2)        | Vorkommastelle (r)
                clr.w   d4
                divu    d5,d4
                move.w  d4,6(a2)        | Nachkommastelle (r)

                tst.l   4(a2)
                bne.s   dp4_ok9
                clr.w   10(a2)          | ï¿½bertrag
dp4_ok9:
                tst.w   10(a2)          | ï¿½bertrag
                bmi.s   dp4_ok9a
                neg.w   4(a2)
dp4_ok9a:

                lea     16(a2),a2       | --------------------------------------

                movem.w 8(a0),d4-d5     | restore (x2, y2)

                cmp.w   d5,d7
                blt.s   dp4_xok2

                move.w  #0x00ff,12(a2)
                move.w  10(a0),d0
                sub.w   6(a0),d0
                addq.w  #1,d0
                move.w  d0,14-16(a2)    | lines
                move.l  -16(a2),(a2)
                move.w  8-16(a2),8(a2)

                move.w  #-1,10(a2)      | ï¿½bertrag (positiv)
                sub.w   d4,d6           | x3-x2
                bpl.s   dp4_ok10
                neg.w   d6
                move.w  #1,10(a2)       | ï¿½bertrag (negativ)
dp4_ok10:
                sub.w   d5,d7           | y3-y2
                addq.w  #1,d7
                ext.l   d6
                divu    d7,d6           | dx/dy
                move.w  d6,4(a2)        | Vorkommastelle (r)
                clr.w   d6
                divu    d7,d6
                move.w  d6,6(a2)        | Nachkommastelle (r)

                tst.l   4(a2)
                bne.s   dp4_ok11
                clr.w   10(a2)          | ï¿½bertrag
dp4_ok11:
                tst.w   10(a2)          | ï¿½bertrag
                bmi.s   dp4_ok11a
                neg.w   4(a2)
dp4_ok11a:

                move.w  14(a0),d0
                sub.w   10(a0),d0
                addq.w  #1,d0
                move.w  d0,14(a2)       | lines

                move.w  (a0),d0
                move.w  #1,d1           | ----------
                bra     dp_draw_it      | ----------

dp4_xok2:
                move.w  #0xff00,12(a2)
                move.w  14(a0),d0
                sub.w   6(a0),d0
                addq.w  #1,d0
                move.w  d0,14-16(a2)    | lines
                move.l  4-16(a2),4(a2)
                move.w  10-16(a2),10(a2)

                move.w  #-1,8(a2)       | ï¿½bertrag (positiv)
                sub.w   d6,d4           | x2-x3
                bpl.s   dp4_ok12
                neg.w   d4
                move.w  #1,8(a2)        | ï¿½bertrag (negativ)
dp4_ok12:
                sub.w   d7,d5           | y2-y3
                addq.w  #1,d5
                ext.l   d4
                divu    d5,d4           | dx/dy
                move.w  d4,(a2)         | Vorkommastelle (l)
                clr.w   d4
                divu    d5,d4
                move.w  d4,2(a2)        | Nachkommastelle (l)

                tst.l   (a2)
                bne.s   dp4_ok13
                clr.w   8(a2)           | ï¿½bertrag
dp4_ok13:
                tst.w   8(a2)           | ï¿½bertrag
                bmi.s   dp4_ok13a
                neg.w   (a2)
dp4_ok13a:

                move.w  10(a0),d0
                sub.w   14(a0),d0
                addq.w  #1,d0
                move.w  d0,14(a2)       | lines

                move.w  (a0),d0
                move.w  #1,d1           | ----------
                bra     dp_draw_it      | ----------

dp4_xok1:
                move.w  #0xff00,12(a2)
                move.w  14(a0),d0
                sub.w   2(a0),d0
                addq.w  #1,d0
                move.w  d0,14-16(a2)    | lines
                move.l  4-16(a2),4(a2)
                move.w  10-16(a2),10(a2)

                move.w  #-1,8(a2)       | ï¿½bertrag (positiv)
                sub.w   d6,d4           | x2-x3
                bpl.s   dp4_ok14
                neg.w   d4
                move.w  #1,8(a2)        | ï¿½bertrag (negativ)
dp4_ok14:
                sub.w   d7,d5           | y2-y3
                addq.w  #1,d5
                ext.l   d4
                divu    d5,d4           | dx/dy
                move.w  d4,(a2)         | Vorkommastelle (l)
                clr.w   d4
                divu    d5,d4
                move.w  d4,2(a2)        | Nachkommastelle (l)

                tst.l   (a2)
                bne.s   dp4_ok15
                clr.w   8(a2)           | ï¿½bertrag
dp4_ok15:
                tst.w   8(a2)           | ï¿½bertrag
                bmi.s   dp4_ok15a
                neg.w   (a2)
dp4_ok15a:

                lea     16(a2),a2       | --------------------------------------

                movem.w 8(a0),d4-d5     | restore (x2, y2)

                cmp.w   d5,d3
                blt.s   dp4_xok3

                move.w  #0xff00,12(a2)
                move.w  10(a0),d0
                sub.w   14(a0),d0
                addq.w  #1,d0
                move.w  d0,14-16(a2)    | lines
                move.l  4-16(a2),4(a2)
                move.w  10-16(a2),10(a2)

                move.w  #-1,8(a2)       | ï¿½bertrag (positiv)
                sub.w   d4,d2           | x1-x2
                bpl.s   dp4_ok16
                neg.w   d2
                move.w  #1,8(a2)        | ï¿½bertrag (negativ)
dp4_ok16:
                sub.w   d5,d3           | y1-y2
                addq.w  #1,d3
                ext.l   d2
                divu    d3,d2           | dx/dy
                move.w  d2,(a2)         | Vorkommastelle (l)
                clr.w   d2
                divu    d3,d2
                move.w  d2,2(a2)        | Nachkommastelle (l)

                tst.l   (a2)
                bne.s   dp4_ok17
                clr.w   8(a2)           | ï¿½bertrag
dp4_ok17:
                tst.w   8(a2)           | ï¿½bertrag
                bmi.s   dp4_ok17a
                neg.w   (a2)
dp4_ok17a:

                move.w  6(a0),d0
                sub.w   10(a0),d0
                addq.w  #1,d0
                move.w  d0,14(a2)       | lines

                move.w  (a0),d0
                move.w  #1,d1           | ----------
                bra.s   dp_draw_it      | ----------

dp4_xok3:
                move.w  #0x00ff,12(a2)
                move.w  6(a0),d0
                sub.w   14(a0),d0
                addq.w  #1,d0
                move.w  d0,14-16(a2)    | lines
                move.l  -16(a2),(a2)
                move.w  8-16(a2),8(a2)

                move.w  #-1,10(a2)      | ï¿½bertrag (positiv)
                sub.w   d2,d4           | x2-x1
                bpl.s   dp4_ok18
                neg.w   d4
                move.w  #1,10(a2)       | ï¿½bertrag (negativ)
dp4_ok18:
                sub.w   d3,d5           | y2-y1
                addq.w  #1,d5
                ext.l   d4
                divu    d5,d4           | dx/dy
                move.w  d4,4(a2)        | Vorkommastelle (r)
                clr.w   d4
                divu    d5,d4
                move.w  d4,6(a2)        | Nachkommastelle (r)

                tst.l   4(a2)
                bne.s   dp4_ok19
                clr.w   10(a2)          | ï¿½bertrag
dp4_ok19:
                tst.w   10(a2)          | ï¿½bertrag
                bmi.s   dp4_ok19a
                neg.w   4(a2)
dp4_ok19a:

                move.w  10(a0),d0
                sub.w   6(a0),d0
                addq.w  #1,d0
                move.w  d0,14(a2)       | lines

                move.w  (a0),d0

dp_draw_it:
| a1.l = screenaddress
| d0.w = x position (top point)
| d1.w = color (0...15)

                move.w  2(a0),d7
                mulu    #160,d7
                adda.l  d7,a1

                move.w  16(a0),d1

                lea     dp_leftright,a0
                lea     dp_mask_table(pc),a2
                lea     dp_color_table(pc),a3
                lea     dp_jump_table(pc),a4

                add.w   d1,d1
                add.w   d1,d1
                add.w   d1,d1
                adda.w  d1,a3

                move.w  d0,d1
dpd_again:
                tst.b   12(a0)
                beq.s   dpd_no_add1

                move.w  #0x8000,d2
                tst.w   8(a0)           | Übertrag (l)
                bmi.s   dpd_no_add1     | nach rechts?
                add.w   (a0),d0         | Vorkommastelle (l)
                add.w   2(a0),d2        | Nachkommastelle (l)
                bcc.s   dpd_no_add1
                sub.w   8(a0),d0        | Übertrag (l)
dpd_no_add1:
                tst.b   13(a0)
                beq.s   dpd_no_add2

                move.w  #0x8000,d4
                tst.w   10(a0)          | Übertrag (r)
                bpl.s   dpd_no_add2     | nach links?
                add.w   4(a0),d1        | Vorkommastelle (r)
                add.w   6(a0),d4        | Nachkommastelle (r)
                bcc.s   dpd_no_add2
                sub.w   10(a0),d1       | Übertrag (r)
dpd_no_add2:
                move.w  14(a0),d7
                subq.w  #1,d7

dpd_loop1:      cmp.w   d0,d1
                blt     dpd_end
                move.w  d1,d3
                lsr.w   #4,d3
                move.w  d0,d5
                lsr.w   #4,d5
                sub.w   d5,d3
                add.w   d3,d3
                add.w   d3,d3
                bne.s   dpd_fill

                move.w  d0,d6
                and.w   #0xfff0,d6
                lsr.w   #1,d6
                lea     0(a1,d6.w),a6   | screenaddress
                move.w  d0,d6
                and.w   #0x000f,d6
                add.w   d6,d6
                add.w   d6,d6
                move.l  0(a2,d6.w),d6   | mask (l)
                move.w  d1,d3
                and.w   #0x000f,d3
                add.w   d3,d3
                add.w   d3,d3
                or.l    64(a2,d3.w),d6  | mask (r)

                and.l   d6,(a6)
                and.l   d6,4(a6)
                not.l   d6
                move.l  (a3),d3
                and.l   d6,d3
                or.l    d3,(a6)+
                move.l  4(a3),d3
                and.l   d6,d3
                or.l    d3,(a6)+

                bra.s   dpd_go_on

dpd_fill:       movea.l 0(a4,d3.w),a5
                move.w  d0,d6
                and.w   #0xfff0,d6
                lsr.w   #1,d6
                lea     0(a1,d6.w),a6   | screenaddress
                move.w  d0,d6
                and.w   #0x000f,d6
                add.w   d6,d6
                add.w   d6,d6
                move.l  0(a2,d6.w),d6   | mask (l)
                and.l   d6,(a6)
                and.l   d6,4(a6)
                not.l   d6
                move.l  (a3),d3
                and.l   d6,d3
                or.l    d3,(a6)+
                move.l  4(a3),d3
                and.l   d6,d3
                or.l    d3,(a6)+

                move.l  (a3),d3
                move.l  4(a3),d5
                jsr     (a5)

                move.w  d1,d6
                and.w   #0x000f,d6
                add.w   d6,d6
                add.w   d6,d6
                move.l  64(a2,d6.w),d6  | mask (r)
                and.l   d6,(a6)
                and.l   d6,4(a6)
                not.l   d6
                move.l  (a3),d3
                and.l   d6,d3
                or.l    d3,(a6)+
                move.l  4(a3),d3
                and.l   d6,d3
                or.l    d3,(a6)+
dpd_go_on:
                lea     160(a1),a1

                add.w   (a0),d0
                add.w   2(a0),d2
                bcc.s   dpd_ok1
                sub.w   8(a0),d0
dpd_ok1:
                add.w   4(a0),d1
                add.w   6(a0),d4
                bcc.s   dpd_ok2
                sub.w   10(a0),d1
dpd_ok2:
                dbra    d7,dpd_loop1

                lea     -160(a1),a1

|                addq.l  #8,A3

                sub.w   (a0),d0
                sub.w   2(a0),d2
                bcc.s   dpd_no_sub1
                add.w   8(a0),d0
dpd_no_sub1:
                sub.w   4(a0),d1
                sub.w   6(a0),d4
                bcc.s   dpd_no_sub2
                add.w   10(a0),d1
dpd_no_sub2:
                lea     16(a0),a0
                cmpa.l  #dp_lr_end,a0
                beq.s   dpd_end

                tst.b   12(a0)
                beq.s   dpd_no_add3

                tst.w   8-16(a0)        | Übertrag (l)
                bpl.s   dpd_no_add3     | nach links?
                add.w   -16(a0),d0      | Vorkommastelle (l)
                add.w   2-16(a0),d2     | Nachkommastelle (l)
                bcc.s   dpd_no_add3
                sub.w   8-16(a0),d0     | Übertrag (l)
dpd_no_add3:
                tst.b   13(a0)
                beq.s   dpd_no_add4

                tst.w   10-16(a0)       | Übertrag (r)
                bmi.s   dpd_no_add4     | nach rechts?
                add.w   4-16(a0),d1     | Vorkommastelle (r)
                add.w   6-16(a0),d4     | Nachkommastelle (r)
                bcc.s   dpd_no_add4
                sub.w   10-16(a0),d1    | Übertrag (r)
dpd_no_add4:
                bra     dpd_again
dpd_end:        rts

dpp0:           illegal
dpp1:           rts
dpp2:           move.l  d3,(a6)+
                move.l  d5,(a6)+
                rts
dpp3:           .rept 2
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp4:           .rept 3
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp5:           .rept 4
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp6:           .rept 5
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp7:           .rept 6
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp8:           .rept 7
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp9:           .rept 8
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp10:          .rept 9
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp11:          .rept 10
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp12:          .rept 11
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp13:          .rept 12
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp14:          .rept 13
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp15:          .rept 14
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp16:          .rept 15
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp17:          .rept 16
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp18:          .rept 17
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts
dpp19:          .rept 18
                move.l  d3,(a6)+
                move.l  d5,(a6)+
                .endr
                rts

                |ENDPART

smain:          |>PART

sm_wait_key:    cmpi.b  #0x39,0xfffffc02.w
                beq     sm_exit
                cmpi.w  #3,pt_flag2
                bne.s   sm_wait_key

                move.l  #novbl,0x00000070.w

                move.l  #screen1+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
sm_cls_loop1:   move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,sm_cls_loop1

                move.l  #screen2+160*60,cls_addr
                movem.l cls_blit(pc),d0-d7
                movem.l d0-d7,0xffff8a20.w
                move.w  #19-1,d7
sm_cls_loop2:   move.w  #10,0xffff8a38.w
                move.b  #0xc0,0xffff8a3c.w
                dbra    d7,sm_cls_loop2

                clr.l   clr_tab1
                clr.l   clr_tab2
                clr.w   pt_flag2
                clr.l   timer

                movea.l script_ptr(pc),a0
sm_again:       move.l  (a0)+,d0
                bpl.s   sm_go_on
                lea     script(pc),a0
                bra.s   sm_again
sm_go_on:
                move.l  (a0)+,0x00000070.w
                move.l  a0,script_ptr
                movea.l d0,a0
                jmp     (a0)

sm_exit:        clr.w   0xffff8900.w
                rts

                |ENDPART

svbl:           |>PART

                movem.l d0-a6,-(sp)

                lea     0xffff8203.w,a0
                move.l  screen_ptr1,show_scr
|                movep.l d0,0(a0)
|                move.b  show_scr+1,0xffff8201.w
|                move.b  show_scr+2,0xffff8203.w
|                move.b  show_scr+3,0xffff820d.w

                move.l  #timer_b,0x00000120.w
                clr.b   0xfffffa1b.w
                move.b  #1,0xfffffa21.w
                move.b  #8,0xfffffa1b.w

                cmpi.w  #2,pt_flag2
                bne.s   sv_ok1a

                cmpi.l  #star_pals2,pal_ptr
                beq.s   sv_ok1a
                subi.l  #32,pal_ptr
                cmpi.l  #star_pals2,pal_ptr
                bne.s   sv_ok1a
                move.w  #3,pt_flag2
sv_ok1a:
                tst.w   pt_flag2
                bne.s   sv_ok1b
                cmpi.l  #star_pals,pal_ptr
                bge.s   sv_ok1b
                addi.l  #32,pal_ptr
sv_ok1b:
                movea.l pal_ptr,a0
                movem.l (a0),d0-d7
                movem.l d1-d7,0xffff8244.w
                move.w  d0,0xffff8242.w
                swap    d0
                move.w  d0,tb_color
                move.w  #0x0111,0xffff8240.w

                addq.l  #1,timer

                bsr     mvbl

                cmpi.l  #3*50,timer
                blt.s   sv_no_stars

                bsr     clr_stars
                bsr     set_stars
sv_no_stars:
                bsr.s   print_text

|                not.w   0xFFFF8240.w
|                not.w   0xFFFF8240.w

                cmpi.l  #screen1,screen_ptr1
                bne.s   sv_set_other
                move.l  #screen2,screen_ptr1
                move.l  #screen1,screen_ptr2
                move.l  #clr_tab2,clr_tab_ptr1
                move.l  #clr_tab1,clr_tab_ptr2
                bra.s   sv_ok1
sv_set_other:
                move.l  #screen1,screen_ptr1
                move.l  #screen2,screen_ptr2
                move.l  #clr_tab1,clr_tab_ptr1
                move.l  #clr_tab2,clr_tab_ptr2
sv_ok1:
                movem.l (sp)+,d0-a6
                rte

                |ENDPART

print_text:     |>PART

                cmpi.w  #2,pt_flag2
                bge.s   pt_end

                tst.w   pt_flag
                beq.s   pt_start

                move.l  timer,d0
                and.w   #0x0001,d0
                bne.s   pt_end

                cmpi.w  #1,pt_flag
                beq.s   pt_fade1

                subq.w  #1,pt_flag
                cmpi.l  #star_pals+15*32,pal_ptr
                beq.s   pt_end
                addi.l  #32,pal_ptr
                rts

pt_fade1:       cmpi.l  #star_pals,pal_ptr
                bne.s   pt_fade2
                clr.w   pt_flag

                tst.w   pt_flag2
                beq.s   pt_end
                move.w  #2,pt_flag2
                rts

pt_fade2:       subi.l  #32,pal_ptr

pt_end:         rts

pt_start:       movea.l pt_text_ptr,a0
                clr.w   d0
                move.b  (a0)+,d0
                move.l  a0,pt_text_ptr
                cmp.b   #1,d0
                bne.s   pt_ok1

                move.b  (a0)+,d0
                move.l  a0,pt_text_ptr
                mulu    #25,d0
                move.w  d0,pt_flag      | displaytime
                clr.w   pt_xoffset
                clr.l   pt_yoffset
                rts

pt_ok1:         cmp.w   #10,d0
                bne.s   pt_ok1a
                clr.w   pt_xoffset
                addi.l  #160*10,pt_yoffset
                rts

pt_ok1a:        tst.w   d0
                bne.s   pt_ok1b
                clr.w   pt_xoffset
                clr.l   pt_yoffset
                move.l  #pt_text,pt_text_ptr
                rts

pt_ok1b:        cmp.b   #2,d0
                bne.s   pt_ok1c
                move.w  #1,pt_flag2
                rts

pt_ok1c:        lea     font_pic+34,a0
                sub.b   #' ',d0

                cmp.w   #20,d0
                blt.s   pt_ok2
                lea     10*160(a0),a0
                sub.w   #20,d0
pt_ok2:
                cmp.w   #20,d0
                blt.s   pt_ok3
                lea     10*160(a0),a0
                sub.w   #20,d0
pt_ok3:
                lsl.w   #3,d0
                adda.w  d0,a0

                movea.l pt_screen_ptr1,a1
                movea.l pt_screen_ptr2,a2
                adda.w  pt_xoffset,a1
                adda.w  pt_xoffset,a2
                adda.l  pt_yoffset,a1
                adda.l  pt_yoffset,a2

                move.l  160*0(a0),160*0(a1)
                move.l  160*0(a0),160*0(a2)
                move.l  160*1(a0),160*1(a1)
                move.l  160*1(a0),160*1(a2)
                move.l  160*2(a0),160*2(a1)
                move.l  160*2(a0),160*2(a2)
                move.l  160*3(a0),160*3(a1)
                move.l  160*3(a0),160*3(a2)
                move.l  160*4(a0),160*4(a1)
                move.l  160*4(a0),160*4(a2)
                move.l  160*5(a0),160*5(a1)
                move.l  160*5(a0),160*5(a2)
                move.l  160*6(a0),160*6(a1)
                move.l  160*6(a0),160*6(a2)
                move.l  160*7(a0),160*7(a1)
                move.l  160*7(a0),160*7(a2)
                move.l  160*8(a0),160*8(a1)
                move.l  160*8(a0),160*8(a2)
                move.l  160*9(a0),160*9(a1)
                move.l  160*9(a0),160*9(a2)

                addq.w  #8,pt_xoffset

                rts

                |ENDPART

clr_stars:      |>PART

                movea.l clr_tab_ptr1,a0
cs_loop:        move.l  (a0)+,d0
                beq.s   cs_end
                movea.l d0,a1
                clr.l   (a1)
                bra.s   cs_loop
cs_end:         rts

                |ENDPART

set_stars:      |>PART

                movea.l star_ptr,a0
                lea     field_x,a2
                adda.w  field_x_off,a2
                lea     field_y,a3
                adda.w  field_y_off,a3
                movea.l clr_tab_ptr1,a4
                move.w  #1280/2,d2
                move.w  #800/2,d3
                move.l  screen_ptr2,d4
                add.l   #160*60,d4
                addq.l  #4,d4

                lea     star_tab1,a1
                move.w  #85-1,d7        | 85
ss_loop1:
                movea.l d4,a5
                move.w  (a0)+,d0
                bmi.s   ss_no_set1
                move.w  0(a2,d0.w),d0
                bmi.s   ss_no_set1
                adda.w  0(a1,d0.w),a5
                move.l  2(a1,d0.w),d1
                move.w  (a0),d0
                move.w  0(a3,d0.w),d0
                bmi.s   ss_no_set1
                adda.w  d0,a5
                move.l  a5,(a4)+
                or.l    d1,(a5)
ss_no_set1:
                addq.w  #2,a0

                movea.l d4,a5
                move.w  (a0)+,d0
                bmi.s   ss_no_set1a
                move.w  0(a2,d0.w),d0
                bmi.s   ss_no_set1a
                adda.w  0(a1,d0.w),a5
                move.l  2(a1,d0.w),d1
                move.w  (a0),d0
                move.w  0(a3,d0.w),d0
                bmi.s   ss_no_set1a
                adda.w  d0,a5
                move.l  a5,(a4)+
                or.l    d1,(a5)
ss_no_set1a:
                addq.w  #2,a0
                adda.w  d2,a2
                adda.w  d3,a3
                dbra    d7,ss_loop1

                lea     star_tab2,a1
                move.w  #85-1,d7        | 85
ss_loop2:
                movea.l d4,a5
                move.w  (a0)+,d0
                bmi.s   ss_no_set2
                move.w  0(a2,d0.w),d0
                bmi.s   ss_no_set2
                adda.w  0(a1,d0.w),a5
                move.l  2(a1,d0.w),d1
                move.w  (a0),d0
                move.w  0(a3,d0.w),d0
                bmi.s   ss_no_set2
                adda.w  d0,a5
                move.l  a5,(a4)+
                or.l    d1,(a5)
ss_no_set2:
                addq.w  #2,a0

                movea.l d4,a5
                move.w  (a0)+,d0
                bmi.s   ss_no_set2a
                move.w  0(a2,d0.w),d0
                bmi.s   ss_no_set2a
                adda.w  0(a1,d0.w),a5
                move.l  2(a1,d0.w),d1
                move.w  (a0),d0
                move.w  0(a3,d0.w),d0
                bmi.s   ss_no_set2a
                adda.w  d0,a5
                move.l  a5,(a4)+
                or.l    d1,(a5)
ss_no_set2a:
                addq.w  #2,a0
                adda.w  d2,a2
                adda.w  d3,a3
                dbra    d7,ss_loop2

                lea     star_tab3,a1
                move.w  #75-1,d7
ss_loop3:
                movea.l d4,a5
                move.w  (a0)+,d0
                bmi.s   ss_no_set3
                move.w  0(a2,d0.w),d0
                bmi.s   ss_no_set3
                adda.w  0(a1,d0.w),a5
                move.l  2(a1,d0.w),d1
                move.w  (a0),d0
                move.w  0(a3,d0.w),d0
                bmi.s   ss_no_set3
                adda.w  d0,a5
                move.l  a5,(a4)+
                or.l    d1,(a5)
ss_no_set3:
                addq.w  #2,a0

                movea.l d4,a5
                move.w  (a0)+,d0
                bmi.s   ss_no_set3a
                move.w  0(a2,d0.w),d0
                bmi.s   ss_no_set3a
                adda.w  0(a1,d0.w),a5
                move.l  2(a1,d0.w),d1
                move.w  (a0),d0
                move.w  0(a3,d0.w),d0
                bmi.s   ss_no_set3a
                adda.w  d0,a5
                move.l  a5,(a4)+
                or.l    d1,(a5)
ss_no_set3a:
                addq.w  #2,a0
                adda.w  d2,a2
                adda.w  d3,a3
                dbra    d7,ss_loop3

                clr.l   (a4)

                addi.l  #star_speed,star_ptr
                movea.l star_ptr,a0
                cmpa.l  #stars+512*4,a0
                blt.s   ss_ok1
                subi.l  #512*4,star_ptr
ss_ok1:
                addi.w  #star_x_speed,field_x_off
                bpl.s   ss_ok2
                addi.w  #320*2,field_x_off
                addi.l  #star_speed,star_ptr
ss_ok2:
                cmpi.w  #320*2,field_x_off
                blt.s   ss_ok3
                subi.w  #320*2,field_x_off
                subi.l  #star_speed,star_ptr
ss_ok3:
                addi.w  #star_y_speed,field_y_off
                bpl.s   ss_ok4
                addi.w  #200*2,field_y_off
                addi.l  #star_speed,star_ptr
ss_ok4:
                cmpi.w  #200*2,field_y_off
                blt.s   ss_ok5
                subi.w  #200*2,field_y_off
                subi.l  #star_speed,star_ptr
ss_ok5:
                movea.l star_ptr,a0
                cmpa.l  #stars+512*4,a0
                blt.s   ss_ok6
                subi.l  #512*4,star_ptr
ss_ok6:
                rts

                |ENDPART

rotate:         |>PART
| a0.l = point-table (x.w, y.w, z.w)
| d0.w = x-angle (degrees)
| d1.w = y-angle (degrees)
| d2.w = z-angle (degrees)
| d7.w = number of points

                subq.w  #1,d7
                add.w   d0,d0
                add.w   d1,d1
                add.w   d2,d2
                lea     sinus,a1
                lea     cosinus,a2

rotat_loop:
                move.w  (a0),d3         | x
                move.w  2(a0),d4        | y

                move.w  d3,d5
                muls    0(a2,d2.w),d5   | x*cos(z-angle)
                add.l   d5,d5
                swap    d5
                move.w  d5,(a0)

                move.w  d4,d5
                muls    0(a1,d2.w),d5   | y*sin(z-angle)
                add.l   d5,d5
                swap    d5
                sub.w   d5,(a0)

                move.w  d3,d5
                muls    0(a1,d2.w),d5   | x*sin(z-angle)
                add.l   d5,d5
                swap    d5
                move.w  d5,2(a0)

                move.w  d4,d5
                muls    0(a2,d2.w),d5   | y*cos(z-angle)
                add.l   d5,d5
                swap    d5
                add.w   d5,2(a0)

                move.w  2(a0),d3        | y
                move.w  4(a0),d4        | z

                move.w  d3,d5
                muls    0(a2,d0.w),d5   | y*cos(x-angle)
                add.l   d5,d5
                swap    d5
                move.w  d5,2(a0)

                move.w  d4,d5
                muls    0(a1,d0.w),d5   | z*sin(x-angle)
                add.l   d5,d5
                swap    d5
                sub.w   d5,2(a0)

                move.w  d3,d5
                muls    0(a1,d0.w),d5   | y*sin(x-angle)
                add.l   d5,d5
                swap    d5
                move.w  d5,4(a0)

                move.w  d4,d5
                muls    0(a2,d0.w),d5   | z*cos(x-angle)
                add.l   d5,d5
                swap    d5
                add.w   d5,4(a0)

                move.w  (a0),d3         | x
                move.w  4(a0),d4        | z

                move.w  d3,d5
                muls    0(a2,d1.w),d5   | x*cos(y-angle)
                add.l   d5,d5
                swap    d5
                move.w  d5,(a0)

                move.w  d4,d5
                muls    0(a1,d1.w),d5   | z*sin(y-angle)
                add.l   d5,d5
                swap    d5
                add.w   d5,(a0)

                move.w  d4,d5
                muls    0(a2,d1.w),d5   | z*cos(y-angle)
                add.l   d5,d5
                swap    d5
                move.w  d5,4(a0)

                move.w  d3,d5
                muls    0(a1,d1.w),d5   | x*sin(y-angle)
                add.l   d5,d5
                swap    d5
                sub.w   d5,4(a0)

                addq.w  #6,a0
                dbra    d7,rotat_loop

                rts

                |ENDPART

translate:      |>PART
| a0.l = point-table
| d0.w = x-offset
| d1.w = y-offset
| d2.w = z-offset
| d7.w = number of points

                subq.w  #1,d7
trans_loop:     add.w   d0,(a0)+
                add.w   d1,(a0)+
                add.w   d2,(a0)+
                dbra    d7,trans_loop

                rts

                |ENDPART

sort:           |>PART

s_loop1:        lea     work_points,a0
                subq.w  #1,d7
                bmi.s   so_end
                move.w  d7,d6
s_loop2:        move.w  4(a0),d0
                cmp.w   10(a0),d0
                bgt.s   s_ok
                move.l  (a0),d0
                move.w  4(a0),d1
                move.l  6(a0),(a0)
                move.w  10(a0),4(a0)
                move.l  d0,6(a0)
                move.w  d1,10(a0)
s_ok:
                addq.w  #6,a0
                dbra    d6,s_loop2
                bra.s   s_loop1

so_end:         rts

                |ENDPART

calc_2d:        |>PART
| a0.l = 3d-point-table
| a1.l = 2d-point-table
| d7.w = number of points

                subq.w  #1,d7
calc_loop:      move.w  #Zx,d0
                muls    4(a0),d0
                move.w  #Zz,d1
                muls    (a0),d1
                sub.l   d1,d0
                move.w  4(a0),d1
                sub.w   #Zz,d1
                divs    d1,d0
                move.w  d0,(a1)+

                move.w  #Zy,d0
                muls    4(a0),d0
                move.w  #Zz,d1
                muls    2(a0),d1
                sub.l   d1,d0
                move.w  4(a0),d1
                sub.w   #Zz,d1
                divs    d1,d0
                move.w  d0,(a1)+

                addq.w  #6,a0
                dbra    d7,calc_loop

                rts

                |ENDPART

convert:        |>PART

                lea     points_2d,a0
                lea     x_data,a1
                lea     work_points,a2
                clr.l   d0
c_loop:         move.w  (a0)+,(a1)+
                move.w  (a0)+,d0
                lsl.w   #4,d0
                move.w  d0,d1
                add.w   d0,d0
                add.w   d0,d0
                add.w   d1,d0
                add.w   d0,d0
|                mulu    #160,d0
                move.l  d0,(a1)+
                move.w  4(a2),(a1)+
                addq.w  #6,a2
                dbra    d7,c_loop
                rts

                |ENDPART

switch:         |>PART

                cmpi.l  #screen1,work_scr
                bne.s   s_other
                move.l  #screen2,work_scr
                move.l  #screen1,show_scr
                move.l  #clr_tab2,clr_tab_addr
                bra.s   s_end
s_other:        move.l  #screen1,work_scr
                move.l  #screen2,show_scr
                move.l  #clr_tab1,clr_tab_addr
s_end:
                rts

                |ENDPART

timer_b:        |>PART

                movem.l d0/a0,-(sp)
                lea     coltab2,a0
                .rept 29
                move.w  (a0)+,0xffff8240.w
                .endr
                move.w  tb_color(pc),0xffff8240.w

                lea     0xffff8203.w,a0
                move.l  show_scr,d0
                add.l   #160*60,d0
                movep.l d0,0(a0)

                move.l  #tb2,0x00000120.w
                clr.b   0xfffffa1b.w
                move.b  #194,0xfffffa21.w
                move.b  #8,0xfffffa1b.w

                movem.l (sp)+,d0/a0
                rte

tb2:            move.l  #tb3,0x00000120.w
                rte

tb3:            movem.l d0/a0,-(sp)

                lea     0xfffffa21.w,a0
                move.b  #190,d0
tb2_loop:       cmp.b   (a0),d0
                bne.s   tb2_loop

                lea     coltab2,a0
                nop
                nop
                nop
                nop
                nop
                nop
                nop
                .rept 30
                move.w  (a0)+,0xffff8240.w
                .endr
                move.w  #0x0111,0xffff8240.w

                movem.l (sp)+,d0/a0
                rte

tb_color:       DC.W 0

                |ENDPART

restore:        |>PART

                move.b  old07,0xfffffa07.w
                move.b  old09,0xfffffa09.w
                move.b  old13,0xfffffa13.w
                move.b  old15,0xfffffa15.w

                move.l  oldtimerb,0x00000120.w
                move.l  oldvbl,0x00000070.w

                lea     0xffff8200.w,a0
                movem.l oldpal,d0-d7
                movem.l d0-d7,0x0040(a0)
                move.b  oldres,0x0060(a0)
                move.b  oldhz,0x000a(a0)
                move.b  oldscr+1,0x0001(a0)
                move.b  oldscr+2,0x0003(a0)
                move.b  oldscr+3,0x000d(a0)
                move.b  oldlw,0x000f(a0)
                move.b  oldhsc,0x0065(a0)

				move.b	oldf030,0xffff8007.w

                move.l  savssp,-(sp)    | Supervisor off
                move.w  #0x0020,-(sp)
                trap    #1
                addq.l  #6,sp

                rts

                |ENDPART

                .data

|                PATH 'F:\SOURCE\3D'

pal_addr2:      DC.L backgnd+2-15*32
pal_addr3:      DC.L shade_col-15*32
                DS.W 16*15
backgnd:        .incbin "../backgnd.pi1",0,34
                DS.W 16*15
shade_col:      .incbin "../shade.col"

                |>PART 'draw poly data'

dp_mask_table:  DC.L 0b00000000000000000000000000000000
                DC.L 0b10000000000000001000000000000000
                DC.L 0b11000000000000001100000000000000
                DC.L 0b11100000000000001110000000000000
                DC.L 0b11110000000000001111000000000000
                DC.L 0b11111000000000001111100000000000
                DC.L 0b11111100000000001111110000000000
                DC.L 0b11111110000000001111111000000000
                DC.L 0b11111111000000001111111100000000
                DC.L 0b11111111100000001111111110000000
                DC.L 0b11111111110000001111111111000000
                DC.L 0b11111111111000001111111111100000
                DC.L 0b11111111111100001111111111110000
                DC.L 0b11111111111110001111111111111000
                DC.L 0b11111111111111001111111111111100
                DC.L 0b11111111111111101111111111111110

                DC.L 0b01111111111111110111111111111111
                DC.L 0b00111111111111110011111111111111
                DC.L 0b00011111111111110001111111111111
                DC.L 0b00001111111111110000111111111111
                DC.L 0b00000111111111110000011111111111
                DC.L 0b00000011111111110000001111111111
                DC.L 0b00000001111111110000000111111111
                DC.L 0b00000000111111110000000011111111
                DC.L 0b00000000011111110000000001111111
                DC.L 0b00000000001111110000000000111111
                DC.L 0b00000000000111110000000000011111
                DC.L 0b00000000000011110000000000001111
                DC.L 0b00000000000001110000000000000111
                DC.L 0b00000000000000110000000000000011
                DC.L 0b00000000000000010000000000000001
                DC.L 0b00000000000000000000000000000000

dp_color_table: DC.W 0,0,0,0
                DC.W -1,0,0,0
                DC.W 0,-1,0,0
                DC.W -1,-1,0,0
                DC.W 0,0,-1,0
                DC.W -1,0,-1,0
                DC.W 0,-1,-1,0
                DC.W -1,-1,-1,0
                DC.W 0,0,0,-1
                DC.W -1,0,0,-1
                DC.W 0,-1,0,-1
                DC.W -1,-1,0,-1
                DC.W 0,0,-1,-1
                DC.W -1,0,-1,-1
                DC.W 0,-1,-1,-1
                DC.W -1,-1,-1,-1

dp_jump_table:  DC.L dpp0,dpp1,dpp2,dpp3,dpp4
                DC.L dpp5,dpp6,dpp7,dpp8,dpp9
                DC.L dpp10,dpp11,dpp12,dpp13,dpp14
                DC.L dpp15,dpp16,dpp17,dpp18,dpp19

                |ENDPART

                |>PART 'script'

script_ptr:     DC.L script
script:
                DC.L main,vbl
                DC.L wmain,wvbl
                DC.L hemain,hevbl
                DC.L hemain,hevbl
                DC.L shmain,shvbl
                DC.L -1

script2_ptr:    DC.L script2
script2:
                DC.W 49
                DC.L hepoints,heline_tab
                DC.W 44
                DC.L migpoints,migline_tab
                DC.W -1

                |ENDPART

                |>PART

|                PATH 'F:\E605'

pal_addr:       DC.L sprite_pic+2-32*15

points_ptr:     DC.L points2

wpoints_ptr:    DC.L wpoints

wpoints:
                DC.W -200,-200,200
                DC.W 200,-200,200
                DC.W 200,200,200
                DC.W -200,200,200
                DC.W -200,-200,-200
                DC.W 200,-200,-200
                DC.W 200,200,-200
                DC.W -200,200,-200

                DC.W -200,-200,200
                DC.W 200,-200,200
                DC.W 200,200,200
                DC.W -200,200,200
                DC.W -200,-200,-200
                DC.W 200,-200,-200
                DC.W 200,200,-200
                DC.W -200,200,-200

                DC.W -300,0,300
                DC.W -300,0,100
                DC.W -300,0,-100
                DC.W -300,0,-300
                DC.W 300,0,300
                DC.W 300,0,100
                DC.W 300,0,-100
                DC.W 300,0,-300

                DC.W -200,0,200
                DC.W -400,-100,0
                DC.W -200,0,-200
                DC.W -400,100,0
                DC.W 200,0,200
                DC.W 400,-100,0
                DC.W 200,0,-200
                DC.W 400,100,0

                DC.W -200,0,0
                DC.W -300,200,0
                DC.W -400,0,0
                DC.W -300,-200,0
                DC.W 200,0,0
                DC.W 300,200,0
                DC.W 400,0,0
                DC.W 300,-200,0

                DC.W -300,0,200
                DC.W 0,-100,300
                DC.W 0,-100,-300
                DC.W -300,0,-200
                DC.W 300,0,-200
                DC.W 0,100,-300
                DC.W 0,100,300
                DC.W 300,0,200

                DC.W -300,-300,0
                DC.W -100,-100,0
                DC.W -100,100,0
                DC.W -300,300,0
                DC.W 300,-300,0
                DC.W 100,-100,0
                DC.W 100,100,0
                DC.W 300,300,0

                DC.W 300,0,200
                DC.W 300,0,-200
                DC.W -300,0,200
                DC.W -300,0,-200
                DC.W 0,-300,-200
                DC.W 0,-300,200
                DC.W 0,300,-200
                DC.W 0,300,200

                DC.W 0,0,400
                DC.W 283,0,283
                DC.W 400,0,0
                DC.W 283,0,-283
                DC.W 0,0,-400
                DC.W -283,0,-283
                DC.W -400,0,0
                DC.W -283,0,283

wpoints_end:    DC.W -200,-200,200
                DC.W 200,-200,200
                DC.W 200,200,200
                DC.W -200,200,200
                DC.W -200,-200,-200
                DC.W 200,-200,-200
                DC.W 200,200,-200
                DC.W -200,200,-200

wline_tab:      DC.W 0,1,1,2,2,3,3,0
                DC.W 4,5,5,6,6,7,7,4
                DC.W 0,4,1,5,2,6,3,7
                DC.W 0,6,1,7,2,4,3,5
                DC.W -1

points:
                DC.W -200,-200,-200
                DC.W 200,-200,-200
                DC.W 200,200,-200
                DC.W -200,200,-200
                DC.W -200,-200,200
                DC.W 200,-200,200
                DC.W 200,200,200
                DC.W -200,200,200
                DC.W -200,-200,-200
                DC.W 200,-200,-200
                DC.W 200,200,-200
                DC.W -200,200,-200
                DC.W -200,-200,200
                DC.W 200,-200,200
                DC.W 200,200,200
                DC.W -200,200,200

points2:
                DC.W -200,-200,-200
                DC.W 200,-200,-200
                DC.W 200,200,-200
                DC.W -200,200,-200
                DC.W -200,-200,200
                DC.W 200,-200,200
                DC.W 200,200,200
                DC.W -200,200,200
                DC.W -200,-200,-200
                DC.W 200,-200,-200
                DC.W 200,200,-200
                DC.W -200,200,-200
                DC.W -200,-200,200
                DC.W 200,-200,200
                DC.W 200,200,200
                DC.W -200,200,200

                DC.W 0,-400,0
                DC.W 153,-370,0
                DC.W 282,-282,0
                DC.W 370,-153,0
                DC.W 400,0,0
                DC.W 153,370,0
                DC.W 282,282,0
                DC.W 370,153,0
                DC.W 0,400,0
                DC.W -153,-370,0
                DC.W -282,-282,0
                DC.W -370,-153,0
                DC.W -400,0,0
                DC.W -153,370,0
                DC.W -282,282,0
                DC.W -370,153,0

                DC.W -200,-200,-200
                DC.W 200,-200,-200
                DC.W 200,200,-200
                DC.W -200,200,-200
                DC.W -200,-200,200
                DC.W 200,-200,200
                DC.W 200,200,200
                DC.W -200,200,200
                DC.W -250,-250,-66
                DC.W 250,-250,-66
                DC.W 250,250,-66
                DC.W -250,250,-66
                DC.W -250,-250,66
                DC.W 250,-250,66
                DC.W 250,250,66
                DC.W -250,250,66

                DC.W 0,-300,200
                DC.W 212,-212,200
                DC.W 300,0,200
                DC.W 212,212,200
                DC.W 0,300,200
                DC.W -212,212,200
                DC.W -300,0,200
                DC.W -212,-212,200
                DC.W 0,-300,-200
                DC.W 212,-212,-200
                DC.W 300,0,-200
                DC.W 212,212,-200
                DC.W 0,300,-200
                DC.W -212,212,-200
                DC.W -300,0,-200
                DC.W -212,-212,-200

                DC.W 400,0,0
                DC.W 250,0,0
                DC.W 250,-150,0
                DC.W 250,0,150
                DC.W 100,0,0
                DC.W 250,0,-150
                DC.W 250,150,0
                DC.W 0,0,250
                DC.W -400,0,0
                DC.W -250,0,0
                DC.W -250,-150,0
                DC.W -250,0,150
                DC.W -100,0,0
                DC.W -250,0,-150
                DC.W -250,150,0
                DC.W 0,0,-250

points_end:
                DC.W 0,-400,0
                DC.W 153,-370,0
                DC.W 282,-282,0
                DC.W 370,-153,0
                DC.W 400,0,0
                DC.W 153,370,0
                DC.W 282,282,0
                DC.W 370,153,0
                DC.W 0,400,0
                DC.W -153,-370,0
                DC.W -282,-282,0
                DC.W -370,-153,0
                DC.W -400,0,0
                DC.W -153,370,0
                DC.W -282,282,0
                DC.W -370,153,0

cb_blit:        DC.W 2,160-(words+1)*8+2
                DC.L 0
                DC.W -1,-1,-1
                DC.W 2,160-(words+1)*8+2
                DC.L 0
                DC.W (words+1)*4
                DC.W lines
                DC.B 0,0,0,0
                DC.W 0

sb_blit:        DC.W 8,160-words*8+8
                DC.L 0
                DC.W -1,-1,-1
                DC.W 8,160-(words+1)*8+8
                DC.L 0
                DC.W words+1
                DC.W lines
                DC.B 2,0,0,0
                DC.W 0

cl_blit:        DC.W 8,160-20*8+8
                DC.L 0
                DC.W -1,-1,-1
                DC.W 8,80+8
cl_addr:        DC.L 0
                DC.W 10
                DC.W 150
                DC.B 0,0,0xc0,0
                DC.W 0

cls_blit:       DC.W 2,2
                DC.L 0
                DC.W -1,-1,-1
                DC.W 2,2
cls_addr:       DC.L 0
                DC.W 80
                DC.W 10
                DC.B 0,0,0xc0,0
                DC.W 0

end_mask:       DC.W 0b1111111111111111,0b1111111111111111
                DC.W 0b0111111111111111,0b1000000000000000
                DC.W 0b0011111111111111,0b1100000000000000
                DC.W 0b0001111111111111,0b1110000000000000
                DC.W 0b0000111111111111,0b1111000000000000
                DC.W 0b0000011111111111,0b1111100000000000
                DC.W 0b0000001111111111,0b1111110000000000
                DC.W 0b0000000111111111,0b1111111000000000
                DC.W 0b0000000011111111,0b1111111100000000
                DC.W 0b0000000001111111,0b1111111110000000
                DC.W 0b0000000000111111,0b1111111111000000
                DC.W 0b0000000000011111,0b1111111111100000
                DC.W 0b0000000000001111,0b1111111111110000
                DC.W 0b0000000000000111,0b1111111111111000
                DC.W 0b0000000000000011,0b1111111111111100
                DC.W 0b0000000000000001,0b1111111111111110

mask_pic:       .incbin "../mask.pi1"
                DS.W 16*15
sprite_pic:     .incbin "../sprite.pi1"

sinus:          .incbin "../sinusx.dat",0,1800
cosinus:        .incbin "../cosinusx.dat"

x_ptr:          DC.L x_way+10*2
y_ptr:          DC.L y_way+10*2
z_ptr:          DC.L z_way+50*2

x_way:          .incbin "../x.dat"
y_way:          .incbin "../y.dat"
z_way:          .incbin "../z.dat"
end_way:
                |ENDPART

                |>PART 'colortab'

coltab:         DC.W 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
                DC.W 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
                DC.W 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
                DC.W 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
                DC.W 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
                DC.W 0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000,0x0000
                DC.W 0x0000,0x0800,0x0100,0x0900,0x0200,0x0a00,0x0300,0x0b00
                DC.W 0x0400,0x0c00,0x0500,0x0d00,0x0600,0x0e00,0x0700
coltab1:        DC.W 0x0f00,0x0f08,0x0f01,0x0f09,0x0f02,0x0f0a,0x0f03,0x0f0b,0x0f04
                DC.W 0x0f0c,0x0f05,0x0f0d,0x0f06,0x0f0e,0x0f07,0x0f0f,0x070f
                DC.W 0x0e0f,0x060f,0x0d0f,0x050f,0x0c0f,0x040f,0x0b0f,0x030f
                DC.W 0x0a0f,0x020f,0x090f,0x010f,0x080f,0x000f,0x008f,0x001f
                DC.W 0x009f,0x002f,0x00af,0x003f,0x00bf,0x004f,0x00cf,0x005f
                DC.W 0x00df,0x006f,0x00ef,0x007f,0x00ff,0x00f7,0x00fe,0x00f6
                DC.W 0x00fd,0x00f5,0x00fc,0x00f4,0x00fb,0x00f3,0x00fa,0x00f2
                DC.W 0x00f9,0x00f1,0x00f8,0x00f0,0x08f0,0x01f0,0x09f0,0x02f0
                DC.W 0x0af0,0x03f0,0x0bf0,0x04f0,0x0cf0,0x05f0,0x0df0,0x06f0
                DC.W 0x0ef0,0x07f0,0x0ff0,0x0f70,0x0fe0,0x0f60,0x0fd0,0x0f50
                DC.W 0x0fc0,0x0f40,0x0fb0,0x0f30,0x0fa0,0x0f20,0x0f90,0x0f10
                DC.W 0x0f80
coltab2:        DC.W 0x0f00,0x0f08,0x0f01,0x0f09,0x0f02,0x0f0a,0x0f03,0x0f0b,0x0f04
                DC.W 0x0f0c,0x0f05,0x0f0d,0x0f06,0x0f0e,0x0f07,0x0f0f,0x070f
                DC.W 0x0e0f,0x060f,0x0d0f,0x050f,0x0c0f,0x040f,0x0b0f,0x030f
                DC.W 0x0a0f,0x020f,0x090f,0x010f,0x080f,0x000f,0x008f,0x001f
                DC.W 0x009f,0x002f,0x00af,0x003f,0x00bf,0x004f,0x00cf,0x005f
                DC.W 0x00df,0x006f,0x00ef,0x007f,0x00ff,0x00f7,0x00fe,0x00f6
                DC.W 0x00fd,0x00f5,0x00fc,0x00f4,0x00fb,0x00f3,0x00fa,0x00f2
                DC.W 0x00f9,0x00f1,0x00f8,0x00f0,0x08f0,0x01f0,0x09f0,0x02f0
                DC.W 0x0af0,0x03f0,0x0bf0,0x04f0,0x0cf0,0x05f0,0x0df0,0x06f0
                DC.W 0x0ef0,0x07f0,0x0ff0,0x0f70,0x0fe0,0x0f60,0x0fd0,0x0f50
                DC.W 0x0fc0,0x0f40,0x0fb0,0x0f30,0x0fa0,0x0f20,0x0f90,0x0f10
                DC.W 0x0f80

                |ENDPART

freqtab:        |>PART

                DC.L 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.L 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0x0005e132,0x0005c27a,0x0005a4fd
                DC.L 0x000588a8,0x00056d6a,0x00055332,0x000539f4,0x000521a0,0x00050a2b,0x0004f389,0x0004ddae
                DC.L 0x0004c891,0x0004b428,0x0004a06b,0x00048d50,0x00047ad1,0x000468e6,0x00045788,0x000446b0
                DC.L 0x00043659,0x0004267e,0x00041718,0x00040822,0x0003f999,0x0003eb77,0x0003ddb8,0x0003d058
                DC.L 0x0003c353,0x0003b6a6,0x0003aa4e,0x00039e46,0x0003928d,0x0003871e,0x00037bf8,0x00037117
                DC.L 0x00036679,0x00035c1d,0x000351fe,0x0003481c,0x00033e74,0x00033504,0x00032bca,0x000322c5
                DC.L 0x000319f3,0x00031152,0x000308e0,0x0003009c,0x0002f885,0x0002f099,0x0002e8d7,0x0002e13d
                DC.L 0x0002d9cb,0x0002d27e,0x0002cb57,0x0002c454,0x0002bd73,0x0002b6b5,0x0002b017,0x0002a999
                DC.L 0x0002a33a,0x00029cfa,0x000296d6,0x000290d0,0x00028ae5,0x00028515,0x00027f60,0x000279c4
                DC.L 0x00027441,0x00026ed7,0x00026984,0x00026448,0x00025f23,0x00025a14,0x0002551a,0x00025035
                DC.L 0x00024b65,0x000246a8,0x000241ff,0x00023d68,0x000238e4,0x00023473,0x00023012,0x00022bc4
                DC.L 0x00022785,0x00022358,0x00021f3a,0x00021b2c,0x0002172e,0x0002133f,0x00020f5e,0x00020b8c
                DC.L 0x000207c7,0x00020411,0x00020068,0x0001fccc,0x0001f93d,0x0001f5bb,0x0001f245,0x0001eedc
                DC.L 0x0001eb7e,0x0001e82c,0x0001e4e5,0x0001e1a9,0x0001de79,0x0001db53,0x0001d838,0x0001d527
                DC.L 0x0001d220,0x0001cf23,0x0001cc30,0x0001c946,0x0001c666,0x0001c38f,0x0001c0c1,0x0001bdfc
                DC.L 0x0001bb3f,0x0001b88b,0x0001b5e0,0x0001b33c,0x0001b0a1,0x0001ae0e,0x0001ab83,0x0001a8ff
                DC.L 0x0001a683,0x0001a40e,0x0001a1a0,0x00019f3a,0x00019cda,0x00019a82,0x00019830,0x000195e5
                DC.L 0x000193a0,0x00019162,0x00018f2b,0x00018cf9,0x00018ace,0x000188a9,0x00018689,0x00018470
                DC.L 0x0001825c,0x0001804e,0x00017e45,0x00017c42,0x00017a45,0x0001784c,0x00017659,0x0001746b
                DC.L 0x00017282,0x0001709e,0x00016ebf,0x00016ce5,0x00016b10,0x0001693f,0x00016773,0x000165ab
                DC.L 0x000163e8,0x0001622a,0x0001606f,0x00015eb9,0x00015d08,0x00015b5a,0x000159b1,0x0001580b
                DC.L 0x0001566a,0x000154cc,0x00015333,0x0001519d,0x0001500b,0x00014e7d,0x00014cf2,0x00014b6b
                DC.L 0x000149e8,0x00014868,0x000146eb,0x00014572,0x000143fd,0x0001428a,0x0001411b,0x00013fb0
                DC.L 0x00013e47,0x00013ce2,0x00013b80,0x00013a20,0x000138c4,0x0001376b,0x00013615,0x000134c2
                DC.L 0x00013371,0x00013224,0x000130d9,0x00012f91,0x00012e4c,0x00012d0a,0x00012bca,0x00012a8d
                DC.L 0x00012952,0x0001281a,0x000126e5,0x000125b2,0x00012482,0x00012354,0x00012228,0x000120ff
                DC.L 0x00011fd8,0x00011eb4,0x00011d92,0x00011c72,0x00011b54,0x00011a39,0x00011920,0x00011809
                DC.L 0x000116f4,0x000115e2,0x000114d1,0x000113c2,0x000112b6,0x000111ac,0x000110a3,0x00010f9d
                DC.L 0x00010e98,0x00010d96,0x00010c95,0x00010b97,0x00010a9a,0x0001099f,0x000108a6,0x000107af
                DC.L 0x000106b9,0x000105c6,0x000104d4,0x000103e3,0x000102f5,0x00010208,0x0001011d,0x00010034
                DC.L 0x0000ff4c,0x0000fe66,0x0000fd81,0x0000fc9e,0x0000fbbd,0x0000fadd,0x0000f9ff,0x0000f922,0x0000f847,0x0000f76e
                DC.L 0x0000f695,0x0000f5bf,0x0000f4e9,0x0000f416,0x0000f343,0x0000f272,0x0000f1a3,0x0000f0d4,0x0000f008,0x0000ef3c
                DC.L 0x0000ee72,0x0000eda9,0x0000ece2,0x0000ec1c,0x0000eb57,0x0000ea93,0x0000e9d1,0x0000e910,0x0000e850,0x0000e791
                DC.L 0x0000e6d4,0x0000e618,0x0000e55d,0x0000e4a3,0x0000e3ea,0x0000e333,0x0000e27c,0x0000e1c7,0x0000e113,0x0000e060
                DC.L 0x0000dfae,0x0000defe,0x0000de4e,0x0000dd9f,0x0000dcf2,0x0000dc45,0x0000db9a,0x0000daf0,0x0000da46,0x0000d99e
                DC.L 0x0000d8f7,0x0000d850,0x0000d7ab,0x0000d707,0x0000d663,0x0000d5c1,0x0000d520,0x0000d47f,0x0000d3e0,0x0000d341
                DC.L 0x0000d2a3,0x0000d207,0x0000d16b,0x0000d0d0,0x0000d036,0x0000cf9d,0x0000cf04,0x0000ce6d,0x0000cdd6,0x0000cd41
                DC.L 0x0000ccac,0x0000cc18,0x0000cb85,0x0000caf2,0x0000ca61,0x0000c9d0,0x0000c940,0x0000c8b1,0x0000c823,0x0000c795
                DC.L 0x0000c708,0x0000c67c,0x0000c5f1,0x0000c567,0x0000c4dd,0x0000c454,0x0000c3cc,0x0000c344,0x0000c2be,0x0000c238
                DC.L 0x0000c1b2,0x0000c12e,0x0000c0aa,0x0000c027,0x0000bfa4,0x0000bf22,0x0000bea1,0x0000be21,0x0000bda1,0x0000bd22
                DC.L 0x0000bca4,0x0000bc26,0x0000bba9,0x0000bb2c,0x0000bab0,0x0000ba35,0x0000b9bb,0x0000b941,0x0000b8c8,0x0000b84f
                DC.L 0x0000b7d7,0x0000b75f,0x0000b6e9,0x0000b672,0x0000b5fd,0x0000b588,0x0000b513,0x0000b49f,0x0000b42c,0x0000b3b9
                DC.L 0x0000b347,0x0000b2d5,0x0000b264,0x0000b1f4,0x0000b184,0x0000b115,0x0000b0a6,0x0000b037,0x0000afca,0x0000af5c
                DC.L 0x0000aef0,0x0000ae84,0x0000ae18,0x0000adad,0x0000ad42,0x0000acd8,0x0000ac6e,0x0000ac05,0x0000ab9d,0x0000ab35
                DC.L 0x0000aacd,0x0000aa66,0x0000a9ff,0x0000a999,0x0000a933,0x0000a8ce,0x0000a869,0x0000a805,0x0000a7a1,0x0000a73e
                DC.L 0x0000a6db,0x0000a679,0x0000a617,0x0000a5b5,0x0000a554,0x0000a4f4,0x0000a493,0x0000a434,0x0000a3d4,0x0000a375
                DC.L 0x0000a317,0x0000a2b9,0x0000a25b,0x0000a1fe,0x0000a1a1,0x0000a145,0x0000a0e9,0x0000a08d,0x0000a032,0x00009fd8
                DC.L 0x00009f7d,0x00009f23,0x00009eca,0x00009e71,0x00009e18,0x00009dc0,0x00009d68,0x00009d10,0x00009cb9,0x00009c62
                DC.L 0x00009c0b,0x00009bb5,0x00009b60,0x00009b0a,0x00009ab5,0x00009a61,0x00009a0c,0x000099b8,0x00009965,0x00009912
                DC.L 0x000098bf,0x0000986c,0x0000981a,0x000097c8,0x00009777,0x00009726,0x000096d5,0x00009685,0x00009634,0x000095e5
                DC.L 0x00009595,0x00009546,0x000094f7,0x000094a9,0x0000945b,0x0000940d,0x000093bf,0x00009372,0x00009325,0x000092d9
                DC.L 0x0000928d,0x00009241,0x000091f5,0x000091aa,0x0000915f,0x00009114,0x000090c9,0x0000907f,0x00009035,0x00008fec
                DC.L 0x00008fa3,0x00008f5a,0x00008f11,0x00008ec9,0x00008e81,0x00008e39,0x00008df1,0x00008daa,0x00008d63,0x00008d1c
                DC.L 0x00008cd6,0x00008c90,0x00008c4a,0x00008c04,0x00008bbf,0x00008b7a,0x00008b35,0x00008af1,0x00008aac,0x00008a68
                DC.L 0x00008a24,0x000089e1,0x0000899e,0x0000895b,0x00008918,0x000088d6,0x00008893,0x00008851,0x00008810,0x000087ce
                DC.L 0x0000878d,0x0000874c,0x0000870b,0x000086cb,0x0000868a,0x0000864a,0x0000860b,0x000085cb,0x0000858c,0x0000854d
                DC.L 0x0000850e,0x000084cf,0x00008491,0x00008453,0x00008415,0x000083d7,0x0000839a,0x0000835c,0x0000831f,0x000082e3
                DC.L 0x000082a6,0x0000826a,0x0000822d,0x000081f1,0x000081b6,0x0000817a,0x0000813f,0x00008104,0x000080c9,0x0000808e
                DC.L 0x00008054,0x0000801a,0x00007fe0,0x00007fa6,0x00007f6c,0x00007f33,0x00007ef9,0x00007ec0,0x00007e88,0x00007e4f
                DC.L 0x00007e17,0x00007dde,0x00007da6,0x00007d6e,0x00007d37,0x00007cff,0x00007cc8,0x00007c91,0x00007c5a,0x00007c23
                DC.L 0x00007bed,0x00007bb7,0x00007b80,0x00007b4a,0x00007b15,0x00007adf,0x00007aaa,0x00007a74,0x00007a3f,0x00007a0b
                DC.L 0x000079d6,0x000079a1,0x0000796d,0x00007939,0x00007905,0x000078d1,0x0000789d,0x0000786a,0x00007837,0x00007804
                DC.L 0x000077d1,0x0000779e,0x0000776b,0x00007739,0x00007706,0x000076d4,0x000076a2,0x00007671,0x0000763f,0x0000760e
                DC.L 0x000075dc,0x000075ab,0x0000757a,0x00007549,0x00007519,0x000074e8,0x000074b8,0x00007488,0x00007458,0x00007428
                DC.L 0x000073f8,0x000073c8,0x00007399,0x0000736a,0x0000733b,0x0000730c,0x000072dd,0x000072ae,0x00007280,0x00007251
                DC.L 0x00007223,0x000071f5,0x000071c7,0x00007199,0x0000716b,0x0000713e,0x00007111,0x000070e3,0x000070b6,0x00007089
                DC.L 0x0000705c,0x00007030,0x00007003,0x00006fd7,0x00006fab,0x00006f7f,0x00006f53,0x00006f27,0x00006efb,0x00006ecf
                DC.L 0x00006ea4,0x00006e79,0x00006e4d,0x00006e22,0x00006df8,0x00006dcd,0x00006da2,0x00006d78,0x00006d4d,0x00006d23
                DC.L 0x00006cf9,0x00006ccf,0x00006ca5,0x00006c7b,0x00006c51,0x00006c28,0x00006bff,0x00006bd5,0x00006bac,0x00006b83
                DC.L 0x00006b5a,0x00006b31,0x00006b09,0x00006ae0,0x00006ab8,0x00006a90,0x00006a67,0x00006a3f,0x00006a17,0x000069f0
                DC.L 0x000069c8,0x000069a0,0x00006979,0x00006951,0x0000692a,0x00006903,0x000068dc,0x000068b5,0x0000688e,0x00006868
                DC.L 0x00006841,0x0000681b,0x000067f4,0x000067ce,0x000067a8,0x00006782,0x0000675c,0x00006736,0x00006710,0x000066eb
                DC.L 0x000066c5,0x000066a0,0x0000667b,0x00006656,0x00006631,0x0000660c,0x000065e7,0x000065c2,0x0000659d,0x00006579
                DC.L 0x00006554,0x00006530,0x0000650c,0x000064e8,0x000064c4,0x000064a0,0x0000647c,0x00006458,0x00006435,0x00006411
                DC.L 0x000063ee,0x000063ca,0x000063a7,0x00006384,0x00006361,0x0000633e,0x0000631b,0x000062f8,0x000062d6,0x000062b3
                DC.L 0x00006291,0x0000626e,0x0000624c,0x0000622a,0x00006208,0x000061e6,0x000061c4,0x000061a2,0x00006180,0x0000615f
                DC.L 0x0000613d,0x0000611c,0x000060fa,0x000060d9,0x000060b8,0x00006097,0x00006076,0x00006055,0x00006034,0x00006013
                DC.L 0x00005ff2,0x00005fd2,0x00005fb1,0x00005f91,0x00005f71,0x00005f50,0x00005f30,0x00005f10,0x00005ef0,0x00005ed0
                DC.L 0x00005eb0,0x00005e91,0x00005e71,0x00005e52,0x00005e32,0x00005e13,0x00005df3,0x00005dd4,0x00005db5,0x00005d96
                DC.L 0x00005d77,0x00005d58,0x00005d39,0x00005d1a,0x00005cfc,0x00005cdd,0x00005cbf,0x00005ca0,0x00005c82,0x00005c64
                DC.L 0x00005c45,0x00005c27,0x00005c09,0x00005beb,0x00005bcd,0x00005baf,0x00005b92,0x00005b74,0x00005b56,0x00005b39
                DC.L 0x00005b1b,0x00005afe,0x00005ae1,0x00005ac4,0x00005aa6,0x00005a89,0x00005a6c,0x00005a4f,0x00005a32,0x00005a16
                DC.L 0x000059f9,0x000059dc,0x000059c0,0x000059a3,0x00005987,0x0000596a,0x0000594e,0x00005932,0x00005916,0x000058fa
                DC.L 0x000058de,0x000058c2,0x000058a6,0x0000588a,0x0000586e,0x00005853,0x00005837,0x0000581b,0x00005800,0x000057e5
                DC.L 0x000057c9,0x000057ae,0x00005793,0x00005778,0x0000575d,0x00005742,0x00005727,0x0000570c,0x000056f1,0x000056d6
                DC.L 0x000056bb,0x000056a1,0x00005686,0x0000566c,0x00005651,0x00005637,0x0000561d,0x00005602,0x000055e8,0x000055ce
                DC.L 0x000055b4,0x0000559a,0x00005580,0x00005566,0x0000554c,0x00005533,0x00005519,0x000054ff,0x000054e6,0x000054cc
                DC.L 0x000054b3,0x00005499,0x00005480,0x00005467,0x0000544e,0x00005434,0x0000541b,0x00005402,0x000053e9,0x000053d0
                DC.L 0x000053b8,0x0000539f,0x00005386,0x0000536d,0x00005355,0x0000533c,0x00005324,0x0000530b,0x000052f3,0x000052da
                DC.L 0x000052c2,0x000052aa,0x00005292,0x0000527a,0x00005261,0x00005249,0x00005231,0x0000521a,0x00005202,0x000051ea
                DC.L 0x000051d2,0x000051ba,0x000051a3,0x0000518b,0x00005174,0x0000515c,0x00005145,0x0000512d,0x00005116,0x000050ff
                DC.L 0x000050e8,0x000050d0,0x000050b9,0x000050a2,0x0000508b,0x00005074,0x0000505d,0x00005046,0x00005030,0x00005019
                DC.L 0x00005002,0x00004fec,0x00004fd5,0x00004fbe,0x00004fa8,0x00004f91,0x00004f7b,0x00004f65,0x00004f4e,0x00004f38
                DC.L 0x00004f22,0x00004f0c,0x00004ef6,0x00004ee0,0x00004ec9,0x00004eb4,0x00004e9e,0x00004e88,0x00004e72,0x00004e5c
                DC.L 0x00004e46,0x00004e31,0x00004e1b,0x00004e05,0x00004df0

                |ENDPART

                |>PART 'stars'

screen_ptr1:    DC.L screen1
screen_ptr2:    DC.L screen2
clr_tab_ptr1:   DC.L clr_tab1
clr_tab_ptr2:   DC.L clr_tab2

star_ptr:       DC.L stars-612*4

set_data1:
                DC.L 0b10000000000000001000000000000000
                DC.L 0b01000000000000000100000000000000
                DC.L 0b00100000000000000010000000000000
                DC.L 0b00010000000000000001000000000000
                DC.L 0b00001000000000000000100000000000
                DC.L 0b00000100000000000000010000000000
                DC.L 0b00000010000000000000001000000000
                DC.L 0b00000001000000000000000100000000
                DC.L 0b00000000100000000000000010000000
                DC.L 0b00000000010000000000000001000000
                DC.L 0b00000000001000000000000000100000
                DC.L 0b00000000000100000000000000010000
                DC.L 0b00000000000010000000000000001000
                DC.L 0b00000000000001000000000000000100
                DC.L 0b00000000000000100000000000000010
                DC.L 0b00000000000000010000000000000001
set_data2:
                DC.L 0b00000000000000001000000000000000
                DC.L 0b00000000000000000100000000000000
                DC.L 0b00000000000000000010000000000000
                DC.L 0b00000000000000000001000000000000
                DC.L 0b00000000000000000000100000000000
                DC.L 0b00000000000000000000010000000000
                DC.L 0b00000000000000000000001000000000
                DC.L 0b00000000000000000000000100000000
                DC.L 0b00000000000000000000000010000000
                DC.L 0b00000000000000000000000001000000
                DC.L 0b00000000000000000000000000100000
                DC.L 0b00000000000000000000000000010000
                DC.L 0b00000000000000000000000000001000
                DC.L 0b00000000000000000000000000000100
                DC.L 0b00000000000000000000000000000010
                DC.L 0b00000000000000000000000000000001
set_data3:
                DC.L 0b10000000000000000000000000000000
                DC.L 0b01000000000000000000000000000000
                DC.L 0b00100000000000000000000000000000
                DC.L 0b00010000000000000000000000000000
                DC.L 0b00001000000000000000000000000000
                DC.L 0b00000100000000000000000000000000
                DC.L 0b00000010000000000000000000000000
                DC.L 0b00000001000000000000000000000000
                DC.L 0b00000000100000000000000000000000
                DC.L 0b00000000010000000000000000000000
                DC.L 0b00000000001000000000000000000000
                DC.L 0b00000000000100000000000000000000
                DC.L 0b00000000000010000000000000000000
                DC.L 0b00000000000001000000000000000000
                DC.L 0b00000000000000100000000000000000
                DC.L 0b00000000000000010000000000000000

                DS.L 612
stars:          .incbin "../stars2.dat"
                .incbin "../stars2.dat"

data:           .incbin "../3d_offs.dat"

font_pic:       .incbin "../t_font.pi1"

pal_ptr:        DC.L star_pals-32*15

pt_text_ptr:    DC.L pt_text
pt_screen_ptr1: DC.L screen1+160*60
pt_screen_ptr2: DC.L screen2+160*60
pt_xoffset:     DC.W 0
pt_yoffset:     DC.L 0
pt_flag:        DC.W 0
pt_flag2:       DC.W 0
pt_flag3:       DC.W 0

pt_text:
                DC.B 10,10,10,10
                .ascii " "
                DC.B 10,10
                .ascii "     YO DUDES!      "
                DC.B 10,10
                .ascii "   LIGHT PRESENT    "
                DC.B 10,10
                .ascii "      ANOTHER       "
                DC.B 10,10
                .ascii "STE-ONLY-PRODUCTION "
                DC.B 10,10
                .ascii " "
                DC.B 10,10
                DC.B 1,8    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 1,4    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "  THIS TIME IT'S A  "
                DC.B 10,10
                .ascii "SHORT JOURNEY INTO A"
                DC.B 10,10
                .ascii "  VIRTUAL WORLD OF  "
                DC.B 10,10
                .ascii " THE 3RD DIMENSION! "
                DC.B 10,10
                DC.B 1,8    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "  CREDITS FOR THIS  "
                DC.B 10,10
                .ascii "        DEMO:       "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 1,4    | screen end
                DC.B 10,10,10,10,10,10
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "      ALL CODE      "
                DC.B 10,10
                .ascii "   PERCY OF LIGHT   "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 1,4    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "      GRAPHICS      "
                DC.B 10,10
                .ascii " DR. DEATH OF LIGHT "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 1,4    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "       MUSIX        "
                DC.B 10,10
                .ascii " TIP AND MANTRONIX  "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 1,4    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "NOISEPACKER  ROUTINE"
                DC.B 10,10
                .ascii " TWINS OF PHENOMENA "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 1,4    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "      WARNING:      "
                DC.B 10,10
                .ascii "THIS DEMO ISN'T VERY"
                DC.B 10,10
                .ascii " ORIGINAL SO PLEASE "
                DC.B 10,10
                .ascii "     DON'T CRY!     "
                DC.B 10,10
                DC.B 1,8    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii " LET'S TAKE A LOOK  "
                DC.B 10,10
                .ascii "   AT THE STARS...  "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 1,4    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 1,3    | screen end
                DC.B 10,10,10,10,10,10
                .ascii "  URGH! JUST BORING "
                DC.B 10,10
                .ascii "      3D STARS!     "
                DC.B 10,10
                .ascii "   LET'S TURN TO    "
                DC.B 10,10
                .ascii "   VECTOR-BOBS...   "
                DC.B 10,10
                DC.B 2,1,8  | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "    AND NOW SOME    "
                DC.B 10,10
                .ascii "WEIRD WIRED OBJECTS!"
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 2,1,4  | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "     HELICOPTER     "
                DC.B 10,10
                .ascii "    IN TROUBLE...   "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 2,1,4  | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "        MIG         "
                DC.B 10,10
                .ascii "    IN TROUBLE...   "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 2,1,4  | screen end
                DC.B 10,10,10,10,10,10
                .ascii "                    "
                DC.B 10,10
                .ascii "   LIGHT SOURCED    "
                DC.B 10,10
                .ascii "    SPACESHIP...    "
                DC.B 10,10
                .ascii "                    "
                DC.B 10,10
                DC.B 2,1,4  | screen end
                DC.B 0
                .ascii "                    "

                .align 4

x_rot_ptr:      DC.L x_rot+212*2
z_rot_ptr:      DC.L y_rot+421*2
y_rot_ptr:      DC.L z_rot+3*2
x_rot:          .incbin "../x_rot.dat"
                DC.W 0x8000
y_rot:          .incbin "../y_rot.dat"
                DC.W 0x8000
z_rot:          .incbin "../z_rot.dat"
                DC.W 0x8000

                |ENDPART

                |>PART '3D objects'

points_value:   DS.W 1
points2_ptr:    DS.L 1
line2_ptr:      DS.L 1

blit_clr:       DC.W 2,2
                DC.L backgnd+34
                DC.W -1,-1,-1
                DC.W 2,2+80-16-16
blit_addr:      DC.L 0
                DC.W 48+8,200
                DC.B 0,0,0xc0,0

heflag:         DS.W 1

hepoints:       DC.W -400,50,25 | 0
                DC.W -400,50,-25
                DC.W -400,120,-25
                DC.W -400,120,25

                DC.W -300,0,75 | 4
                DC.W -300,0,-75
                DC.W -300,150,-75
                DC.W -300,150,75

                DC.W -200,50,-75 | 8
                DC.W 0,0,-75
                DC.W 0,-100,-75
                DC.W -150,-100,-75

                DC.W -200,50,75 | 12
                DC.W 0,0,75
                DC.W 0,-100,75
                DC.W -150,-100,75

                DC.W 0,50,-75 | 16
                DC.W 20,50,-225
                DC.W 100,50,-225
                DC.W 100,50,-75

                DC.W 0,50,75 | 20
                DC.W 20,50,225
                DC.W 100,50,225
                DC.W 100,50,75

                DC.W 100,-100,75 | 24
                DC.W 100,150,-75
                DC.W 100,150,75
                DC.W 100,-100,-75

                DC.W 300,0,55 | 28
                DC.W 300,0,-55
                DC.W 300,150,-55
                DC.W 300,150,55

                DC.W 900,70,0 | 32
                DC.W 900,150,0

                DC.W 750,50,0 | 34
                DC.W 950,-50,0
                DC.W 1050,-50,0

                DC.W 1050,-50,175 | 37
                DC.W 1050,-50,-175
                DC.W 970,-50,-175
                DC.W 970,-50,175

                DC.W 800,-150,25 | 41
                DC.W 800,-150,-25
                DC.W -800,-150,-25
                DC.W -800,-150,25

                DC.W 25,-150,-800 | 45
                DC.W -25,-150,-800
                DC.W -25,-150,800
                DC.W 25,-150,800

heline_tab:
                DC.W 0,1,2,3,4 | bug
                DC.W 4,5,1,0,7
                DC.W 1,5,6,2,5
                DC.W 3,2,6,7,4
                DC.W 0,3,7,4,5

                DC.W 5,11,10,8,8 | kanzel (windschutzscheiben)
                DC.W 8,10,9,9,8
                DC.W 5,4,15,11,9
                DC.W 11,15,14,10,10
                DC.W 14,15,4,12,8
                DC.W 14,12,13,13,8

                DC.W 5,8,6,6,13 | kanzel
                DC.W 6,8,9,25,13
                DC.W 10,27,25,9,13
                DC.W 14,24,27,10,14
                DC.W 12,4,7,7,13
                DC.W 12,7,26,13,13
                DC.W 24,14,13,26,13
                DC.W 7,6,25,26,12

                DC.W 21,22,23,20,3 | flügel vorne rechts
                DC.W 23,22,21,20,1

                DC.W 19,18,17,16,3 | flügel vorne links
                DC.W 16,17,18,19,1

                DC.W 27,29,30,25,13 | mittelteil
                DC.W 28,24,26,31,13
                DC.W 27,24,28,29,14
                DC.W 25,30,31,26,12

                DC.W 33,34,35,36,2 | heckflosse
                DC.W 36,35,34,33,2

                DC.W 29,32,33,30,2 | heck
                DC.W 33,32,28,31,2
                DC.W 29,28,32,32,3
                DC.W 31,30,33,33,1

                DC.W 35,40,37,36,3 | flügel hinten rechts
                DC.W 36,37,40,35,1

                DC.W 35,36,38,39,3 | flügel hinten links
                DC.W 39,38,36,35,1
                DC.W -1

heline_tab3:    DC.W 44,43,42,41,12 | rotor unten
                DC.W 48,47,46,45,12
                DC.W -1

heline_tab2:    DC.W 41,42,43,44,15 | rotor oben
                DC.W 45,46,47,48,15
                DC.W -1

migpoints:      DC.W -600,0,0 | spitze
                DC.W -400,-50,50
                DC.W -400,-50,-50
                DC.W -400,50,-50
                DC.W -400,50,50

                DC.W -400,-50,0 | 5
                DC.W -300,-100,0
                DC.W -100,-50,0
                DC.W -300,-50,50
                DC.W -300,-50,-50

                DC.W -300,-50,-100 | 10
                DC.W -200,50,-100
                DC.W -200,50,-50
                DC.W -200,50,50

                DC.W -200,50,100
                DC.W -300,-50,100

                DC.W -100,-50,100 | 16
                DC.W 150,-50,450
                DC.W 300,-50,450
                DC.W 300,-50,100

                DC.W -100,-50,-100 | 20
                DC.W 300,-50,-100
                DC.W 300,-50,-450
                DC.W 150,-50,-450

                DC.W 600,-50,100 | 24
                DC.W 600,50,100
                DC.W 600,50,50
                DC.W 600,-50,50
                DC.W 600,-50,-100
                DC.W 600,50,-100
                DC.W 600,50,-50
                DC.W 600,-50,-50

                DC.W -150,-50,50 | 32
                DC.W -150,-50,-50

                DC.W 500,-50,200 | 34
                DC.W 600,-50,200
                DC.W 600,-50,100
                DC.W 500,-50,-200
                DC.W 600,-50,-200
                DC.W 600,-50,-100

                DC.W 350,-50,0 | 40
                DC.W 550,-200,0
                DC.W 650,-200,0
                DC.W 600,-50,0

migline_tab:    DC.W 0,1,2,2,2 | spitze
                DC.W 0,2,3,3,1
                DC.W 0,3,4,4,1
                DC.W 0,4,1,1,1

                DC.W 5,6,9,9,10 | kanzel
                DC.W 5,8,6,6,9
                DC.W 9,6,7,7,9
                DC.W 6,8,7,7,9

                DC.W 9,10,11,12,9 | turbinen
                DC.W 8,13,14,15,9

                DC.W 16,17,18,19,3 | flügel rechts
                DC.W 19,18,17,16,1

                DC.W 20,21,22,23,3 | flügel links
                DC.W 23,22,21,20,1

                DC.W 24,25,26,27,7 | heck
                DC.W 31,30,29,28,7

                DC.W 8,27,31,7,3
                DC.W 9,7,31,31,3
                DC.W 5,1,8,8,2
                DC.W 2,5,9,9,2
                DC.W 10,9,33,33,3
                DC.W 8,15,32,32,3
                DC.W 10,33,31,28,2
                DC.W 32,15,24,27,2

                DC.W 3,2,9,12,2
                DC.W 13,8,1,4,2

                DC.W 11,10,28,29,2
                DC.W 25,24,15,14,2

                DC.W 4,3,12,13,2
                DC.W 13,12,30,26,2
                DC.W 12,11,29,30,1
                DC.W 14,13,26,25,1

                DC.W 31,27,26,30,1

                DC.W 19,34,35,36,3
                DC.W 36,35,34,19,1
                DC.W 21,39,38,37,3
                DC.W 37,38,39,21,1

                DC.W 40,41,42,43,2
                DC.W 43,42,41,40,2

                DC.W -1

x_angle:        DC.W 0
y_angle:        DC.W 0
z_angle:        DC.W 0
ry_angle:       DC.W 0

                DS.W 1
sort_table:     DS.W 4*200

dp_leftright:   DS.W 8*3
dp_lr_end:

area:           DS.W 9

                |ENDPART

                |>PART 'shade'

.equ shpn, 15

shpoints:       DC.W 0,0,-250

                DC.W -50,-25,-150
                DC.W -50,25,-100
                DC.W 50,-25,-150
                DC.W 50,25,-100

                DC.W 0,-55,-50

                DC.W -50,-25,200
                DC.W -50,25,200
                DC.W 50,-25,200
                DC.W 50,25,200

                DC.W -150,75,50
                DC.W -150,75,150
                DC.W 150,75,50
                DC.W 150,75,150

                DC.W 0,-50,100

shline_tab:     DC.W 1,3,0,0,0
                DC.W 3,4,0,0,0
                DC.W 2,1,0,0,0
                DC.W 4,2,0,0,0

                DC.W 3,1,5,5,8
                DC.W 1,14,5,5,8
                DC.W 14,3,5,5,8

                DC.W 1,10,11,6,0
                DC.W 8,13,12,3,0
                DC.W 14,1,6,6,0
                DC.W 3,14,8,8,0
                DC.W 6,8,14,14,0

                DC.W 1,2,10,10,0
                DC.W 4,3,12,12,0
                DC.W 7,2,4,9,0

                DC.W 7,11,10,2,0
                DC.W 13,9,4,12,0

                DC.W 8,9,13,13,0
                DC.W 7,6,11,11,0
                DC.W 8,6,7,9,8

                DC.W -1

                |ENDPART

ptr_tab:        DS.W 6
L10546:         DS.W 2
L1054A:         DS.W 2
L1054E:         DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
L10588:         DC.W 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
                DC.W 0,0,0,0,0,0
L105D0:         DC.W 0,0,0,0,0,0,0,0,0,0,0,0

|                BSS

                |>PART 'sound'

instlen:        DS.W 1
block:          DS.L 1
spldummy:       DS.W 1
keypress:       DS.W 1

sngadr:         DS.L 1
patadr:         DS.L 1
spladr:         DS.L 1
snglen:         DS.W 1
sngrpt:         DS.W 1
sngcnt:         DS.W 1
sngptr:         DS.L 1
patcnt:         DS.W 1
patptr:         DS.L 1

bfe001:         DS.W 1      | Filter

dff000:         DS.B 0x0096
dff096:         DS.B 0x000a
|                             Channel 0:
dff0a0:         DS.L 1      | Frame-address
dff0a4:         DS.W 1      | Frame-lenght/2
dff0a6:         DS.W 1      | Frequence
dff0a8:         DS.L 2      | Volume

|                             Channel 1:
dff0b0:         DS.L 1      | Frame-address
dff0b4:         DS.W 1      | Frame-lenght/2
dff0b6:         DS.W 1      | Frequence
dff0b8:         DS.L 2      | Volume

|                             Channel 2:
dff0c0:         DS.L 1      | Frame-address
dff0c4:         DS.W 1      | Frame-lenght/2
dff0c6:         DS.W 1      | Frequence
dff0c8:         DS.L 2      | Volume

|                             Channel 3:
dff0d0:         DS.L 1      | Frame-address
dff0d4:         DS.W 1      | Frame-lenght/2
dff0d6:         DS.W 1      | Frequence
dff0d8:         DS.L 2      | Volume

oldval:         DS.L 4      | -96
nt_slide:       DS.L 4      | -80
vibrato:        DS.L 4      | -64
volslide:       DS.L 4      | -48
freqdummy:      DS.L 4      | -23
arpdata:        DS.L 4      | -16
frequence:      DS.L 4      | 0
oldinst:        DS.L 4      | 16
sample:         DS.L 4      | 32
offset:         DS.L 4      | 48
repeat:         DS.L 4      | 64
lenght:         DS.L 4      | 80
portament:      DS.L 4      | 96
volume:         DS.L 4      | 112
longer:         DS.L 1

voltab:         DS.B 16640
spltab:         DS.B 256*2
block1:         DS.B 1000
block2:         DS.B 1000

                |ENDPART

                |>PART

timer:          DS.L 1
timer_flag:     DS.W 1

savssp:         DS.L 1
oldpal:         DS.W 16
oldres:         DS.B 1
oldhz:          DS.B 1
oldlw:          DS.B 1
oldhsc:         DS.B 1
oldscr:         DS.L 1
oldtimerb:      DS.L 1
oldvbl:         DS.L 1
old07:          DS.B 1
old09:          DS.B 1
old13:          DS.B 1
old15:          DS.B 1
oldf030:		DS.B 1

				.align 4

work_scr:       DS.L 1
show_scr:       DS.L 1
x_data_addr:    DS.L 1
clr_tab_addr:   DS.L 1
mask_addr:      DS.L 1
sprite_addr:    DS.L 1

trans_tab:      DS.L 3*16*2

area_value:     DS.L 100

work_points:    DS.W 3*200
points_2d:      DS.W 2*200
points_2d2:     DS.W 2*200
x_data:         DS.W 400

clr_tab1:       DS.L 1000
clr_tab2:       DS.L 1000

deep_tab:       DS.L 50*2*40

star_pals2:     DS.W 15*16
star_pals:      DS.W 16*16

star_tab1:      DS.L 640
star_tab2:      DS.L 640
star_tab3:      DS.L 640

field_x_off:    DS.W 1
field_y_off:    DS.W 1

|                PATH 'G:\SOUND\MODULES'
module:         .incbin "../overload.npm"

                .bss

                DS.L 12000

field_x:        DS.L 40960
field_y:        DS.L 25600

                DS.W 1

screen1:        DS.L 12000
screen2:        DS.L 12000

                |ENDPART

                .end
