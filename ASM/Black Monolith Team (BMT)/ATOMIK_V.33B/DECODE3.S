
;decrunch source code of ATOMIK by ALTAIR       |je tiens a preciser
;A0=packed code                                 |que j'ai entierement
;A1=depack adr.                                 |ecris ce compacteur
;call it by bsr.                                |environnement compris.
;                                                         
;                                                         
;                                               |oui, oui, ‡a va, je sais!
;
;ATOMIK v3.3b
;------------
;
;new decode version for flexible picture algorithm written by Gaston/BMT!
;
;especially for Ford Perfect's game 'A dragon called Greenhorn!', or
;was it 'Greenhorn likes dragon', strange, I can't remember the name...


                lea     packed(PC),A0
                lea     unpacked(PC),A1
                bsr.s   depack
                illegal

depack:         movem.l D0-A6,-(SP)
                cmpi.l  #"ATOM",(A0)+
                bne     no_crunched
                cmpi.w  #"!!",(A0)+
                bne     no_crunched

                movea.l A1,A5
                adda.l  (A0)+,A5
                pea     (A5)

                move.l  (A0)+,D0
                lea     0(A0,D0.l),A6
                move.b  -(A6),D7
                bra     make_jnk

tablus:         lea     tablus_table(PC),A4
                moveq   #1,D6
                bsr.s   get_bit2
                bra.s   tablus2

decrunch:       moveq   #6,D6
take_lenght:    add.b   D7,D7
                beq.s   empty1
cont_copy:      dbcc    D6,take_lenght
                bcs.s   next_coda
                moveq   #6,D5
                sub.w   D6,D5
                bra.s   do_copy

next_coda:      moveq   #3,D6
                bsr.s   get_bit2
                beq.s   next_cod1
                addq.w  #6,D5
                bra.s   do_copy

next_cod1:      moveq   #7,D6
                bsr.s   get_bit2
                beq.s   next_cod2
                add.w   #15+6,D5
                bra.s   do_copy

empty1:         move.b  -(A6),D7
                addx.b  D7,D7
                bra.s   cont_copy

next_cod2:      moveq   #13,D6
                bsr.s   get_bit2
                add.w   #255+15+6,D5

do_copy:        move.w  D5,-(SP)
                bne.s   bigger
                lea     decrun_table2(PC),A4
                moveq   #2,D6
                bsr.s   get_bit2
                cmp.w   #5,D5
                blt.s   contus
                addq.w  #2,SP
                subq.w  #6,D5
                bgt.s   tablus
                movea.l A5,A4
                blt.s   first4
                addq.w  #4,A4
first4:         moveq   #1,D6
                bsr.s   get_bit2
tablus2:        move.b  0(A4,D5.w),-(A5)
                bra.s   make_jnk
get_bit2:       clr.w   D5
get_bits:       add.b   D7,D7
                beq.s   emptya
conta:          addx.w  D5,D5
                dbra    D6,get_bits
                tst.w   D5
                rts
emptya:         move.b  -(A6),D7
                addx.b  D7,D7
                bra.s   conta

bigger:         lea     decrun_table(PC),A4
cont:           moveq   #2,D6
                bsr.s   get_bit2
contus:         move.w  D5,D4
                move.b  14(A4,D4.w),D6
                ext.w   D6
                bsr.s   get_bit2
                add.w   D4,D4
                beq.s   first
                add.w   -2(A4,D4.w),D5
first:          lea     1(A5,D5.w),A4
                move.w  (SP)+,D5
                move.b  -(A4),-(A5)
copy_same:      move.b  -(A4),-(A5)
                dbra    D5,copy_same
make_jnk:       moveq   #11,D6
                moveq   #11,D5
take_jnk:       add.b   D7,D7
                beq.s   empty
cont_jnk:       dbcc    D6,take_jnk
                bcs.s   next_cod
                sub.w   D6,D5
                bra.s   copy_jnk1
next_cod:       moveq   #7,D6
                bsr.s   get_bit2
                beq.s   next_cod1a
                addq.w  #8,D5
                addq.w  #3,D5
                bra.s   copy_jnk1

next_cod1a:     moveq   #2,D6
                bsr.s   get_bit2
                swap    D5
                moveq   #15,D6
                bsr.s   get_bit2
                addq.l  #8,D5
                addq.l  #3,D5
copy_jnk1:      subq.w  #1,D5
                bmi.s   end_word
                moveq   #1,D6
                swap    D6
copy_jnk:       move.b  -(A6),-(A5)
                dbra    D5,copy_jnk

                sub.l   D6,D5
                bpl.s   copy_jnk
end_word:       cmpa.l  A6,A0
decruncha:      bne     decrunch
                cmp.b   #$80,D7
                bne     decrunch
                movea.l (SP)+,A0
                bsr.s   decod_picture
no_crunched:    movem.l (SP)+,D0-A6
                rts

empty:          move.b  -(A6),D7
                addx.b  D7,D7
                bra.s   cont_jnk

decrun_table:   DC.W 32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
                DC.W 32+64+256+512+1024+2048,$1F60
                DC.B 4,5,7,8,9,10,11,12
decrun_table2:  DC.W 32,32+64,32+64+128,32+64+128+256
                DC.W 32+64+128+256+512,32+64+128+256+512*2
                DC.W 32+64+128+256+512*3
                DC.B 4,5,6,7,8,8
tablus_table:   DC.B $60,$20,$10,$08

decod_picture:  move.w  -(A0),D7
                clr.w   (A0)
                bra.s   *+2
next_picture:   move.w  (SP)+,D7
                dbra    D7,decod_algo
zap:            moveq   #0,D0
                rts

decod_algo:     move.w  D7,-(SP)
                move.b  -(A0),zap+1
                clr.b   (A0)
                clr.b   -(A0)
                move.l  -(A0),D6
                clr.w   (A0)
                move.l  -(A0),D0
                clr.l   (A0)
                lea     0(A5,D0.l),A1
                lea     0(A1,D6.w),A2
next_planes:    moveq   #3,D6
next_word:      move.w  (A1)+,D0
                moveq   #3,D5
next_bits:      add.w   D0,D0
                addx.w  D1,D1
                add.w   D0,D0
                addx.w  D2,D2
                add.w   D0,D0
                addx.w  D3,D3
                add.w   D0,D0
                addx.w  D4,D4
                dbra    D5,next_bits
                dbra    D6,next_word
                movem.w D1-D4,-8(A1)
                cmpa.l  A1,A2
                bne.s   next_planes
                bra.s   next_picture

                DATA
packed:         IBYTES '*.*'

                BSS
unpacked:       DS.W $FFFE

                END
