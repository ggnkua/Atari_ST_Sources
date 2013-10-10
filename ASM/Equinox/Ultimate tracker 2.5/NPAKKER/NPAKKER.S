*
* Identificateur NOISEPAKKER
*

	.EXPORT	LENGHT_NDPK

LENGHT_NDPK:
	MOVEM.L	D1-D7/A0-A6,-(A7)
	BSR		analyse_module
	MOVE.L	sample_start(PC),A0
	MOVE.L	sample_end(PC),D0
	SUB.L	A0,D0
	MOVEM.L	(A7)+,D1-D7/A0-A6
	RTS

analyse_module: 
		move.l  A0,-(A7)
        lea     $03b8(A0),A1
        moveq   #$7f,D0
        moveq   #0,D4
mt_loop:
		move.l  D4,D2
        subq.w  #1,D0
mt_lop2:
		move.b  (A1)+,D4
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

sample_start:   DC.L 0
sample_end:     DC.L 0

                END
