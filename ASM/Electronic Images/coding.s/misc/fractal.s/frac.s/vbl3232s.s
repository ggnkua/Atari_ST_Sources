bufwd           EQU 80
bufhg           EQU 32
bufsize         EQU bufwd*bufhg
;##############################
;INSERT IN VBL ROUTINE
                movem.l D0-D6/A0-A2,-(SP)

                clr.l   scrlpos
                move.b  $FFFF8201.w,scrlpos+1
                move.b  $FFFF8203.w,scrlpos+2

                movea.l textptr(PC),A1
                moveq   #0,D0
                moveq   #0,D1
                moveq   #0,D2
                moveq   #0,D3
                tst.b   (A1)
                bne.s   notwrap1
		clr.w	scrlflag	;comment this for a loop..
                lea     text(PC),A1
notwrap1:
                move.l  A1,textptr

                moveq   #0,D4
                move.w  scrlcnt(PC),D4


                move.b  (A1),D0
                move.b  1(A1),D1
                bne.s   nozr1
                moveq   #' ',D1
nozr1:
                tst.w   inlet
                bne.s   nosam
                move.w  D0,D1
nosam:
                sub.b   #32,D0
                lsl.w   #7,D0

                sub.b   #32,D1
                lsl.w   #7,D1

                tst.w   inlet
                beq.s   nosam2
                subq.w  #2,D1
                addq.w  #2,D0
nosam2:

                lea     buff,A0
                adda.w  buffptr(PC),A0
                adda.l  whichbuf(PC),A0
                lea     font(PC),A1
                lea     0(A1,D0.w),A2
                lea     2(A1,D1.w),A1

                REPT 32
                move.w  (A1)+,D5
                swap    D5
                move.w  (A2)+,D5
                rol.l   D4,D5
                move.w  D5,(A0)
                move.w  D5,(bufwd/2)(A0)
                lea     bufwd(A0),A0
                addq.w  #2,A1
                addq.w  #2,A2
                ENDR

                lea     buff,A0
                adda.l  whichbuf(PC),A0
                adda.w  cbuff(PC),A0

                movea.l scrlpos(PC),A1
                lea     2(A1),A1	;y offset?
                moveq   #32-1,D0
clines:
scoff           SET 0
                REPT 20
                move.w  (A0),scoff(A1)
                move.w  (a0)+,2+scoff(a1)
scoff           SET scoff+8
                ENDR
                lea     bufwd/2(A0),A0
                lea     160(A1),A1
                dbra    D0,clines

                move.l  whichbuf(PC),D0
                add.l   #bufsize,D0
                cmpi.l  #bufsize*4,D0
                blt.s   nobro
                clr.l   D0
nobro:          move.l  D0,whichbuf

                movea.l textptr(PC),A1
                move.w  scrlcnt(PC),D4
                addq.w  #4,D4
                cmpi.w  #16,D4
                blt.s   nonchar
                clr.w   D4
                addq.w  #1,inlet
                cmpi.w  #2,inlet
                bne.s   samchar
                addq.w  #1,A1
                clr.w   inlet
samchar:

                addq.w  #2,cbuff
                move.w  buffptr(PC),D0
                addq.w  #2,D0
                cmpi.w  #bufwd/2,D0
                blt.s   nobr
                clr.w   D0
                move.w  #2,cbuff
nobr:           move.w  D0,buffptr


nonchar:        move.w  D4,scrlcnt


                move.l  A1,textptr

                movem.l (SP)+,D0-D6/A0-A2
;######