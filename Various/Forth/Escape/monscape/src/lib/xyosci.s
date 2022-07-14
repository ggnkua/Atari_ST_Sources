| ( sample screen lines ) draw xy-scope into byte-organized 160x120 screen
CODE_XT draw_xyosci
	move.l d4,d7 ; POPD    | d7: lines to draw
	move.l d4,a0 ; POPD    | a0: destination on screen
	move.l d4,a1           | a1: sample data, interleaved left and right signed bytes
	subq.l #1,d7           | d7: y-loop count
	move.l a1,a2
	addq.l #1,a2           | a2: used for accessing the right sample values
2:
	move.b (a2),d1         | d1: right sample value
	ext.w  d1
	ext.l  d2
	add.l  #8*4,a2         | skip a few right samples

	move.l a1,a3           | a3: used for accessing the left sample values
	moveq  #0,d4
	move.w #160-1,d4       | d4: x-loop count
1:
	move.b (a3),d0         | d0: left sample value
	ext.w  d0
	ext.l  d0
	addq.l #8,a3         | skip a few left samples

	add.l  d1,d0
	asr.l  #1,d0           | d0: average of left and right
	bge    3f
	neg.l  d0
3:
	move.b d0,(a0)+

	dbf   d4,1b
	dbf   d7,2b
	POPD
	NEXT

DENTRIES draw_xyosci

| vim: set ts=16:
