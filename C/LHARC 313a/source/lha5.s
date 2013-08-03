            export position
            export prev
            export next
            export parent
            export childcount
            export text
            export encode5
            export init_encode5
            export output5
            export insert_node
            export get_next_match
            export in_split
            export output_pos
            export output_mask
            export avail
            import buf
            import c_freq
            import p_freq
            import level
            import blocksize
            import send_block
            import fread_crc
            import start_huf
            import end_huf
            import ProcInd
            import shipout
            import file3


 BUFSIZ          set 16384

    MODULE encode5

        import remainder, printcount, l_mpos
        import  get_next_match
        TEXT
            movem.l D3-D7/A2-A6,-(SP)
            lea     text(PC),A6
            move.l  file3(PC),A1
            move.l  #$2100,D0
            move.l  (A6),A0
            lea     $2000(a0),a0
            jsr     fread_crc
            move.w  D0,remainder-text(a6)
            ext.l   d0
            add.l   d0,printcount-text(a6)
            cmp.w   #$2000,d0
            bcs.s   ind2
proc_ind2:  move.l  blocksize(pc),d0
            cmp.l   printcount(pc),d0
            bhi.s   enc51
            sub.l   d0,printcount-text(a6)
ind2:       jsr     ProcInd
            bra.s   proc_ind2
enc51:
            moveq   #0,D0
            move.w  #$FFFF,D0
            and.l   D0,D1
            and.l   D0,D2
            and.l   D0,D3
            and.l   D0,D4
            and.l   D0,D5
            and.l   D0,D6
            moveq   #0,d7
            moveq   #0,D0
            move.l  parent-text(a6),a2
            move.l  prev-text(a6),a3
            move.l  next-text(a6),a4
            move.l  level-text(a6),a5
            move.w  #$2000,D6
            move.w  D4,-(SP)
            bsr     insert_node
            move.w  (sp)+,D4
            bra.b   encod7

encod1:     move.w  d7,D4
            move.w  D5,l_mpos-text(A6)
            bsr     get_next_match
            cmp.w   remainder(PC),D7
            bls.b   encod2
            move.w  remainder(PC),d7
encod2:     cmp.w   d7,D4
            bcs.b   encod3
            cmp.w   #3,D4
            bcc.b   encod4
encod3:     move.l  text(PC),A0
            moveq   #0,D1
            move.b  -1(A0,D6.w),D1
            moveq   #0,D3
            bsr     output5
            bra.b   encod8

encod4:     move.w  D6,D3
            sub.w   l_mpos(PC),D3
            subq.w  #2,D3
            and.w   #$1FFF,D3
            move.w  D4,D1
            add.w   #$FD,D1
            bsr     output5
            subq.w  #1,D4
            ble.b   encod7
encod5:     bsr     get_next_match
            subq.w  #1,D4
            bgt.b   encod5
encod7:     cmp.w   remainder(PC),D7
            bls.b   encod8
            move.w  remainder(PC),d7
encod8:     move.w  remainder(PC),D0
            bgt.b   encod1
            jsr     end_huf
            bsr     shipout
            movem.l (SP)+,D3-D7/A2-A6
            rts

    ENDMOD

            align


    MODULE output5

    IMPORT output_mask,output_pos,cpos

    TEXT


            move.w  output_pos(pc),D0
            move.l  buf(PC),A1
            adda.l  D0,A1
            subq.w  #1,output_mask-text(A6)
            bpl.b   out5_2
            move.w  #7,output_mask-text(a6)
            cmp.w   #BUFSIZ-$18,D0
            bcs.b   out5_1
            move.w  d1,-(sp)
            bsr     send_block
            moveq   #0,D1
            moveq   #0,D2
            move.w  (sp)+,d1
            move.l  buf(PC),A1
            moveq   #0,D0
out5_1:     move.w  D0,cpos-text(A6)
            clr.b   (A1)+
            addq.w  #1,D0
out5_2:     move.b  D1,(A1)+
            addq.w  #1,D0
            add.w   D1,D1
            lea     c_freq,A0
            addq.w  #1,0(A0,D1.w)
            cmp.w   #$0200,D1
            bcs.b   out5_5
            move.w  output_mask-text(a6),D1
            move.w  cpos(PC),D2
            sub.w   D0,D2
            bset.b  D1,0(A1,D2.w)
            move.w  D3,D1
            lsr.w   #8,D1
            move.b  D1,(A1)+
            bne.b   nout_5_1
            move.b  D3,(A1)+
            addq.w  #2,D0
            moveq   #16,D1
            tst.w   D3
            dbeq    D1,out5_3
            bra.b   out5_4
out5_3:     lsr.w   #1,D3
            dbeq    D1,out5_3
out5_4:     add.w   D1,D1
            neg.w   D1
            lea     p_freq,A0
            addq.w  #1,32(A0,D1.w)
out5_5:     move.w  d0,output_pos-text(a6)
            rts

nout_5_1:   move.b  D3,(A1)+
            addq.w  #2,D0
            moveq   #7,D2
nout5_3:    lsr.b   #1,D1
            dbeq    D2,nout5_3
nout5_4:    add.w   D2,D2
            neg.w   D2
            lea     p_freq,A0
            addq.w  #1,32(A0,D2.w)
            move.w  d0,output_pos-text(a6)
            rts

        ENDMOD

            align

        MODULE insert_node

        IMPORT avail
        EXPORT insert_n

        TEXT

insert_n:

            subq.w  #4,d7
            bmi.b   inode7
            move.l  position-text(a6),A1
            addq.w  #3,d7
            moveq   #1,D4
            add.w   D5,D4
            or.w    #$2000,D4
            add.w   D4,D4
            move.w  0(A2,D4.l),D3
            bne.b   inode1_
inode1:
            move.w  0(A4,D4.l),D4
            move.w  0(A2,D4.l),D3
            beq.b   inode1
inode1_:
            cmp.b   0(A5,D3.l),d7
            bhi.b   inode3_
inode3:     move.w  D3,D4
            move.w  0(A2,D3.l),D3
            cmp.b   0(A5,D3.l),D7
            bls.b   inode3
inode3_:    move.w  D3,D0
            move.w  0(A1,D0.l),D1
            bpl.b   inode5_
inode5:
            move.w  d6,0(A1,D0.l)
            move.w  0(A2,D0.l),D0
            move.w  0(A1,D0.l),D1
            bmi.b   inode5
inode5_:    cmp.w   #$4000,D0
            bhs.b   inode9
            move.w  D6,D2
            or.w    #$8000,D2
            move.w  D2,0(A1,D0.l)
            bra.b   inode9

inode7:     move.l  (a6),A0
            moveq   #0,D3
            move.b  0(A0,D6.w),D3
            add.w   #$2000,D3
            add.w   D3,D3
            moveq   #0,D4
            move.b  1(A0,D6.w),D4
            lsl.w   #5,D4
            add.w   D3,D4
            add.w   #$8000,D4
            move.w  D4,D7
            move.w  D3,(A2)
nchild1:
            move.w  0(A4,D4.l),D4
            cmp.w   0(A2,D4.l),D3
            bne.b   nchild1
            tst.w   D4
            bne.b   inode8
            move.w  0(A4,D7.l),D0
            move.w  D6,D4
            add.w   D4,D4
            move.w  D4,0(A4,D7.l)
            move.w  D0,0(A4,D4.l)
            move.w  D4,0(A3,D0.l)
            move.w  D7,0(A3,D4.l)
            move.w  D3,0(A2,D4.l)
            addq.b  #1,1(A5,D3.l)
            moveq   #1,d7
            rts

inode8:     move.l  position-text(a6),A1
            moveq   #2,d7
inode9:     cmp.w   #$4000,D4
            blo.b   inode10
            move.w  #$0100,d2
            lsr.w   #1,D4
            move.w  D4,D5
            add.w   D4,D4
            bra.b   inode11
inode10:    moveq   #0,d2
            move.b  0(A5,D4.l),D2
            move.w  0(A1,D4.l),D5
            and.w   #$7FFF,D5
inode11:    cmp.w   D5,D6
            bhi.b   inode12
            sub.w   #$2000,D5
inode12:    move.w  D6,D0
            add.w   D7,D0
            move.l  (A6),A0
            lea     0(A0,d0.w),a5
            move.w  D5,D1
            add.w   D7,D1
            lea     0(A0,D1.l),A0
            move.w  D2,D0
            sub.w   D7,D0
            ble.b   inode14
            subq.w  #1,D0
inode13:    cmpm.b  (A5)+,(A0)+
            dbne    d0,inode13
            BNE     in_split
            not.w   d0
            add.w   d2,d0
            move.w  d0,d7
inode14:    cmp.w   #$0100,d7
            bge.b   inode17
            move.w  D4,D3
            move.w  D6,0(A1,D4.l)
            moveq   #0,d4
            move.b  (A5),D4
            lsl.w   #5,D4
            add.w   D3,D4
            add.w   #$8000,D4
            move.w  D4,D1
            move.w  D3,(A2)
            move.l  level-text(a6),a5
nchild2:
            move.w  0(A4,D4.l),D4
            cmp.w   0(A2,D4.l),D3
            bne.b   nchild2
            tst.w   D4
            bne.b   inode16
            move.w  0(A4,D1.l),D0
            move.w  D6,D4
            add.w   D4,D4
            move.w  D4,0(A4,D1.l)
            move.w  D0,0(A4,D4.l)
            move.w  D4,0(A3,D0.l)
            move.w  D1,0(A3,D4.l)
            move.w  D3,0(A2,D4.l)
            addq.b  #1,1(A5,d3.l)
            rts

inode16:    addq.w  #1,d7
            bra     inode9

inode17:    move.w  0(A3,D4.l),D1
            move.w  d6,D2
            add.w   D2,D2
            move.w  D1,0(a3,D2.l)
            move.w  D2,0(A4,D1.l)
            move.w  0(A4,D4.l),D1
            move.w  D1,0(A4,D2.l)
            move.w  d2,0(a3,D1.l)
            move.w  D3,0(A2,D2.l)
            clr.w   0(A2,D4.l)
            move.w  d2,0(A4,D4.l)
            move.l  level-text(a6),a5
            rts

    ENDMOD

            align

    MODULE in_split


            not.w   D0
            add.w   D2,D0
            move.w  D0,D7
            MOVE.W  avail-text(A6),D3
            move.l  level-text(a6),a5
            move.l  (a6),A0
            move.w  0(A4,D3.l),avail-text(a6)
            move.b  #2,1(A5,D3.l)
            move.w  0(A3,D4.l),D0
            move.w  D0,0(A3,D3.l)
            move.w  D3,0(A4,D0.l)
            move.w  0(A4,D4.l),D0
            move.w  D0,0(A4,D3.l)
            move.w  D3,0(A3,D0.l)
            move.w  0(A2,D4.l),0(A2,D3.l)
            move.w  D6,0(A1,D3.l)
            move.b  D7,0(A5,D3.l)

            move.w  D5,D0
            ADD.W   d7,D0
            moveq   #0,d2
            move.b  0(A0,D0.l),D2
            lsl.w   #5,D2
            add.w   D3,D2
            add.w   #$8000,D2
            move.w  0(A4,D2.l),D1
            move.w  D4,0(A4,D2.l)
            move.w  D1,0(A4,D4.l)
            move.w  D4,0(A3,D1.l)
            move.w  D2,0(A3,D4.l)
            move.w  D3,0(A2,D4.l)

            move.w  D6,D1
            add.w   D7,D1
            moveq   #0,D4
            move.b  0(A0,D1.W),D4
            lsl.w   #5,D4
            add.w   D3,D4
            add.w   #$8000,D4
            move.w  0(A4,D4.L),D0
            move.w  D6,D1
            add.w   D1,D1
            move.w  D1,0(A4,D4.l)
            move.w  D0,0(A4,D1.l)
            move.w  D1,0(A3,D0.l)
            move.w  D4,0(A3,D1.l)
            move.w  D3,0(A2,D1.l)
            rts
    ENDMOD

            align

    MODULE get_next_match

        EXPORT gnext1,get_next

        IMPORT my_cnt,st_save

    TEXT

get_next:

            subq.w  #1,remainder-text(a6)
            cmpi.w  #$3fff,D6
            beq.b   get_n_m_s
            addq.w  #1,D6
gnext1:     move.w D4,-(sp)

            move.w  d6,D1
            add.w   D1,D1
            move.w  0(A2,D1.l),D3
            beq.b   dnode9_
            move.w  0(A3,D1.l),D2
            move.w  0(A4,D1.l),D4
            move.w  D4,0(A4,D2.l)
            move.w  D2,0(A3,D4.l)
            clr.w   0(A2,D1.l)
            cmp.w   #$4000,D3
            bcs.b   dnodea_
dnode9_:    bsr     insert_node
            move.w (sp)+,d4
            rts

get_n_m_s:
            bra     get_n_m_1

dnodea_:    subq.b  #1,1(A5,D3.L)
            cmpi.b  #1,1(A5,D3.L)
            bhi.b   dnode9_
            move.l  position-text(a6),A1
            move.w  D3,D1
            move.w  0(A1,D1.l),D2
            and.w   #$7FFF,D2
            cmp.w   d6,D2
            blt.b   dnode1
            sub.w   #$2000,D2
dnode1:     move.w  D2,D4
            move.w  d2,a0
            move.w  0(A2,D1.l),D0
            move.w  0(A1,D0.l),d2
            bclr    #15,D2
            beq.b   dnode5_
dnode2:     cmp.w   d6,d2
            blt.b   dnode3
            sub.w   #$2000,d2
dnode3:     cmp.w   d2,D4
            bge.b   dnode4
            move.w  d2,D4
dnode4:     move.w  D4,D1
            or.w    #$2000,D1
            move.w  D1,0(A1,D0.l)
            move.w  0(A2,D0.l),D0
            move.w  0(A1,D0.l),d2
            bclr    #15,D2
            bne.b   dnode2
dnode5_:    cmp.w   #$4000,D0
            bhs.b   dnode8
            cmp.w   d6,d2
            blt.b   dnode6
            sub.w   #$2000,d2
dnode6:     cmp.w   d2,D4
            bge.b   dnode7
            move.w  d2,D4
dnode7:     or.w    #$A000,D4
            move.w  D4,0(A1,D0.l)
dnode8:     moveq   #0,D0
            move.b  0(A5,D3.l),D0
            add.w   a0,D0
            move.l  (a6),A1
            moveq   #0,d4
            move.b  0(A1,D0.l),D4
            lsl.w   #5,D4
            add.w   D3,D4
            add.w   #$8000,D4
            move.w  d3,(A2)
dchild1:    move.w  0(A4,D4.l),D4
            cmp.w   0(A2,D4.l),D3
            bne.b   dchild1
            move.w  0(A3,D4.l),D0
            move.w  0(A4,D4.l),D2
            move.w  D2,0(A4,D0.l)
            move.w  D0,0(A3,D2.l)
            move.w  0(A3,D3.l),D0
            move.w  D0,0(A3,D4.l)
            move.w  D4,0(A4,D0.l)
            move.w  0(A4,D3.l),D0
            move.w  D0,0(A4,D4.l)
            move.w  D4,0(A3,D0.l)
            move.w  0(A2,D3.l),0(A2,D4.l)
            clr.w   0(A2,D3.l)
            move.w  avail-text(a6),0(A4,D3.l)
            move.w  D3,avail-text(a6)
dnode9:     bsr     insert_node
            move.w (sp)+,d4
            rts

get_n_m_1:  move.l (a6),A0
            lea     $2000(A0),A0
            movem.l D1-D7/A2-A6,-(a7)
            move.l  A7,st_save
            move    #7,my_cnt
nxt_cpy:
        REPT 20
            movem.l (a0)+,D0-D7/A1-A7
            movem.l D0-D7/A1-A7,-$203c(a0)
        ENDM
            subq.w  #1,my_cnt
            bne     nxt_cpy
            movem.l (a0)+,D0-D7/A1-A4
            movem.l D0-D7/A1-A4,-$2030(a0)
            move.l  st_save(PC),A7
            movem.l (a7)+,D1-D7/A2-A6
            move.l  file3(PC),A1
            move.l  #$2000,D0
            move.l  (a6),A0
            lea     $2100(A0),A0
            jsr     fread_crc
            add.w   D0,remainder-text(a6)
            move.w  #$2000,D6
            ext.l   d0
            add.l   d0,printcount-text(a6)
            cmp.w   #$2000,d0
            blt.s   ind1
proc_ind1:  move.l  blocksize(pc),d0
            cmp.l   printcount(pc),d0
            bgt.s   gnext1_
            sub.l   d0,printcount-text(a6)
ind1:       jsr     ProcInd
            bra.s   proc_ind1
gnext1_:    moveq   #0,D0
            moveq   #0,D1
            moveq   #0,D2
            bra     gnext1

    ENDMOD

            align

    MODULE init_encode5

        EXPORT init_en
    TEXT

init_en:

            movem.l D2-D7/A2-A6,-(A7)
            moveq   #0,D0
            lea     text(pc),A6
            move.w  d0,output_pos-text(a6)
            move.w  d0,output_mask-text(a6)
            move.l  d0,printcount-text(a6)
            move.w  #2,avail-text(A6)
            moveq   #0,D1
            moveq   #0,D2
            moveq   #0,D3
            moveq   #0,D4
            moveq   #0,D5
            moveq   #0,D6
            moveq   #0,D7
            move.l  D7,A0
            move.l  A0,A1
            move.l  A1,A2
            move.l  A2,A3
            move.l  A3,A4
            move.l  A4,A5
            move.l  position(PC),A6
            lea     ($2100*2)(A6),A6
        REPT 9
            movem.l D0-D7/A0-A5,-(A6)
        ENDM
            movem.l D0-D1,-(A6)
            move.l  parent(PC),A6
            adda.l  #(($2000*2)*2),A6
            move.w  #78-1,D7
qdel_1:
        REPT 4
            movem.l D0-D6/A0-A5,-(A6)
        ENDM
            dbra    D7,qdel_1
        REPT 3
            movem.l D0-D6/A0-A5,-(A6)
        ENDM
            move.l  D0,-(A6)
            move.l  next(PC),A6
            adda.l  #$70F0*2,A6
            move.w  #60-1,D7
qdel_2:
        REPT 8
            movem.l D0-D6/A0-A5,-(A6)
        ENDM
            dbra    D7,qdel_2
            movem.l D0-D6/A0-A5,-(A6)
            movem.l D0-D6/A0-A3,-(A6)
            move.l  #0x00040004,D2
            move.l  d2,D0
            addq    #2,d0
            move.l  next(PC),A6
            clr.w   (a6)+
            move.w  #1023-1,d1
islide6:
        REPT 4
            move.l  D0,(a6)+
            add.l   D2,D0
        ENDM
            dbra    d1,islide6
        REPT 3
            move.l  D0,(a6)+
            add.l   D2,D0
        ENDM

            move.w  d3,(a6)
            move.l  #$01000100,D0
            move.l  d0,d1
            move.l  d1,d2
            move.l  d2,d3
            move.l  d3,d4
            move.l  d4,d5
            move.l  d5,d6
            move.l  d6,d7
            move.l  d7,a0
            move.l  a0,a1
            move.l  a1,a2
            move.l  a2,a3
            move.l  a3,a4
            move.l  a4,a5
            move.l  level(PC),a6
            clr.l   (a6)
            lea     $2100(a6),a6
            lea     $2100(a6),a6
            movem.l D0-D7/A0-A5,-(A6)
            movem.l D0-D7/A0-A5,-(A6)
            movem.l D0-D7/A0-A5,-(A6)
            movem.l D0-D7/A0-A5,-(A6)
            movem.l D0-D7/A0-A5,-(A6)
            movem.l D0-D7/A0-A5,-(A6)
            movem.l D0-D7/A0-A5,-(A6)
            movem.l D0-D7/A0-A5,-(A6)
            movem.l D0-D7,-(A6)
            movem.l D0-D7,-(A6)
            movem.l (A7)+,D2-D7/A2-A6
            jsr     start_huf
            rts

    ENDMOD

    DATA

    align.l

level:      dc.l    0
position:   dc.l    0
next:       dc.l    0
prev:       dc.l    0
parent:     dc.l    0

avail:      dc.l    0
childcount: dc.l    0
text:       dc.l    0
remainder:  dc.l    0
cpos:       dc.w    0
    align.l
printcount: dc.l    0
output_pos: dc.w    0
    align.l
output_mask:dc.w    0
l_mpos:     dc.w    0
st_save:    dc.l    0
my_cnt:     dc.w    0
    align.l

    END
