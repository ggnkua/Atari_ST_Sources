| ( to lut from n )
CODE_XT mapb2b
	move.l  d4,d7 ; POPD    | d7: n
	move.l  d4,a0 ; POPD    | a0: source buffer
	move.l  d4,a2 ; POPD    | a2: 256-byte look-up table
	move.l  d4,a1 ; POPD    | a1: destination buffer
	subq.w  #1,d7
	blt     1f
	moveq.l #0,d0
2:	move.b (a0)+,d0
	move.b (a2,d0.w),(a1)+
	dbf    d7,2b
1:	NEXT

| optimized variant of mapb2b for a buffer of 160 values
CODE_XT mapb2b_160
	POPD                    | ignore n
	move.l  d4,a0 ; POPD    | a0: source buffer
	move.l  d4,a2 ; POPD    | a2: 256-byte look-up table
	move.l  d4,a1 ; POPD    | a1: destination buffer
	bsr.s   _mapb2b_160
	NEXT

_mapb2b_160:
	moveq.l #0,d0
	moveq.l #5-1,d7
2:
	.REP 32
	move.b (a0)+,d0
	move.b (a2,d0.w),(a1)+
	.ENDR
	dbf    d7,2b
1:	rts

DENTRIES mapb2b mapb2b_160

| vim: set ts=16:
