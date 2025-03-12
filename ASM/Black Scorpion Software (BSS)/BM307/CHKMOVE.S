*=======================================================*
*	Collision test module: updated 12/06/97		*
*=======================================================*

Radius=17

check_move:
	sf		no_move
	move.l		nextx,cor_nextx
	move.l		nexty,cor_nexty
	bsr		build_blocks_list	; checks for closest blocks
	move.l		Vertex_Array,a1		; Array of points
	lea		blocks_scan,a3		; list of blocks to check
	move.w		(a3)+,d0		; number of blocks (-1)
line_scan:
	move.w		(a3)+,d1		; block number
	move.l		Blockmap_Array,a2	; Array of blocks
	move.l		(a2,d1.w*4),a2		; current block address
	addq.l		#2,a2			; skips first word
loop_line_scan:
	move.w		(a2)+,d1		; linedef number
	cmpi.w		#$ffff,d1		; = -1 ?
	beq		next_line_scan		; if yes, end of block...
	mulu.w		#14,d1			; * size of a linedef
	move.l		Line_Array,a0		; Array of linedefs
	adda.l		d1,a0			; current linedef address
	movem.w		(a0),d1-d3		; from, to, attributes				
	btst		#0,d3			; test if wall impassible
	beq		next_line		; if passible,jump !
	lea		nextx,a4		;
	bsr		Calculate_Distance	;
	cmpi.l		#Radius*Radius,d4	; d>Radius ?
	bhi		next_line		; If no, move may be permitted
	st		no_move			;
	bsr		Calculate_Slide		;
	move.w		d0,-(sp)
	lea		blocks_scan,a6
	move.w		(a6)+,d0
verify_line_scan:
	move.w		(a6)+,d1
	move.l		Blockmap_Array,a5
	move.l		(a5,d1.w*4),a5
	addq.l		#2,a5
verify_loop_line_scan:
	move.w		(a5)+,d1
	cmpi.w		#$ffff,d1
	beq		verify_next_line_scan
	mulu.w		#14,d1
	move.l		Line_Array,a0
	adda.l		d1,a0
	movem.w		(a0),d1-d3		; from, to, attributes				
	btst		#0,d3			; test if wall impassible
	beq		verify_next_line	; if passible,jump !
	lea		cor_nextx,a4		;
	bsr		Calculate_Distance	;
	cmpi.l		#Radius*Radius,d4	; d>Radius ?
	bhi		verify_next_line	; If not,jump...
	bra.b		end_verify		; Jump...
verify_next_line:
	bra		verify_loop_line_scan	; Jump...
verify_next_line_scan:
	dbf		d0,verify_line_scan
	sf		no_move
	move.l		cor_nextx,nextx
	move.l		cor_nexty,nexty
end_verify:
	move.w		(sp)+,d0
next_line:
	bra		loop_line_scan
next_line_scan:
	dbf		d0,line_scan
	tst.w		no_move
	beq.b		good_move
	;clr.l		right_speed
	;clr.l		front_speed
	move.l		px,cor_nextx
	move.l		py,cor_nexty
good_move
	move.l		cor_nextx,nextx
	move.l		cor_nexty,nexty
	rts

build_blocks_list
	lea		blocks_scan,a0
	move.w		nextx,d0
	move.w		nexty,d1
	sub.w		blockmap_xorigin,d0
	sub.w		blockmap_yorigin,d1
	move.w		blockmap_columns,d2
	move.w		blockmap_rows,d3
	lsr.w		#7,d0
	lsr.w		#7,d1
	subq.w		#1,d0
	subq.w		#1,d1
	move.w		#-1,(a0)+
	moveq		#2,d7
test_blocks_scan_line
	tst.w		d1
	bmi.b		next_blocks_scan_line
	moveq		#2,d6
	move.w		d0,d5
test_blocks_scan_row
	tst.w		d5
	bmi.b		next_blocks_scan_row
	addq.w		#1,blocks_scan
	move.w		d1,d4
	mulu.w		d2,d4
	add.w		d5,d4
	move.w		d4,(a0)+
next_blocks_scan_row
	addq.w		#1,d5
	cmp.w		d5,d2
	bls.b		next_blocks_scan_line
	dbf		d6,test_blocks_scan_row
next_blocks_scan_line
	addq.w		#1,d1
	cmp.w		d1,d3
	bls.b		end_test_blocks_scan
	dbf		d7,test_blocks_scan_line
end_test_blocks_scan
	rts

Calculate_Distance
	move.w		vtx_x(a1,d2.w*4),d3	; x2
	sub.w		vtx_x(a1,d1.w*4),d3	; x2-x1=dx
	move.w		d3,dx			; dx
	muls.w		d3,d3			; dx^2
	move.w		vtx_y(a1,d2.w*4),d4	; y2
	sub.w		vtx_y(a1,d1.w*4),d4	; y2-y1=dy
	move.w		d4,dy			; dy
	muls.w		d4,d4			; dy^2
	add.l		d4,d3			; delta=dx^2+dy^2
	move.l		d3,delta		; saves delta
	move.l		(a4),d3			; Next x player position
	move.w		vtx_x(a1,d1.w*4),d4	; x1
	swap		d4			; swapped
	clr.w		d4			; float part=0
	sub.l		d4,d3			; nextx-x1
	move.w		dx,d4			; dx
	ext.l		d4			; extended
	muls.l		d4,d4:d3		; dx*(nextx-x1)
	divs.l		delta,d4:d3		; dx*(nextx-x1)/delta
	move.l		4(a4),d4		; Next y player position
	move.w		vtx_y(a1,d1.w*4),d5	; y1
	swap		d5			; swapped
	clr.w		d5			; float part=0
	sub.l		d5,d4			; nexty-y1
	move.w		dy,d5			; dy
	ext.l		d5			; extended
	muls.l		d5,d5:d4		; dy*(nexty-y1)
	divs.l		delta,d5:d4		; dy*(nexty-y1)/delta
	add.l		d4,d3			; (dx*(nextx-x1)+dy*(nexty-y1))/delta=B
	cmpi.l		#$10000-1,d3		; B in ]0..1[ ?
	blo.b		Not_Extrems		; if yes, jump...
	bgt.b		Distance2		; if >1 then distance from point 2

Distance1
	move.l		(a4),d3			; Next x player position
	move.w		vtx_x(a1,d1.w*4),d4	; x1
	swap		d4			; swapped
	clr.w		d4			; float part=0
	sub.l		d4,d3			; nextx-x1
	muls.l		d3,d4:d3		; (nextx-x1)^2
	move.l		4(a4),d5		; Next y player position
	move.w		vtx_y(a1,d1.w*4),d6	; y1
	swap		d6			; swapped
	clr.w		d6			; float part=0
	sub.l		d6,d5			; nexty-y1
	muls.l		d5,d6:d5		; (nexty-y1)^2
	cmp.l		d6,d4			; (nextx-x1)^2>(nexty-y1)^2 ?
	bgt		End_Calculate		; if yes,jump...
	move.l		d6,d4			; (nexty-y1)^2
	bra		End_Calculate		; jump

Distance2
	move.l		(a4),d3			; Next x player position
	move.w		vtx_x(a1,d2.w*4),d4	; x2
	swap		d4			; swapped
	clr.w		d4			; float part=0
	sub.l		d4,d3			; nextx-x2
	muls.l		d3,d4:d3		; (nextx-x2)^2
	move.l		4(a4),d5		; Next y player position
	move.w		vtx_y(a1,d2.w*4),d6	; y2
	swap		d6			; swapped
	clr.w		d6			; float part=0
	sub.l		d6,d5			; nexty-y2
	muls.l		d5,d6:d5		; (nexty-y2)^2
	cmp.l		d6,d4			; (nextx-x2)^2>(nexty-y2)^2 ?
	bgt		End_Calculate		; if yes,jump...
	move.l		d6,d4			; (nexty-y2)^2
	bra		End_Calculate		; jump

Not_Extrems
	move.l		delta,d6
	bsr		square_root

;	swap		d7

	move.l		(a4),d3			; Next x player position
	move.w		vtx_x(a1,d1.w*4),d4	; x1
	swap		d4			; swapped
	clr.w		d4			; float part=0
	sub.l		d4,d3			; nextx-x1

	clr.l		d4
	move.w		dy,d4			; dy
	swap		d4

;	move.w		dy,d4			; dy
;	ext.l		d4			; extended

	muls.l		d4,d4:d3		; dy*(nextx-x1)	
	divs.l		d7,d4:d3
	move.l		4(a4),d4		; Next y player position
	move.w		vtx_y(a1,d1.w*4),d5	; y1
	swap		d5			; swapped
	clr.w		d5			; float part=0
	sub.l		d5,d4			; nexty-y1

	clr.l		d5
	move.w		dx,d5			; dx
	swap		d5

;	move.w		dx,d5			; dx
;	ext.l		d5			; extended

	muls.l		d5,d5:d4		; dx*(nexty-y1)	
	divs.l		d7,d5:d4
	sub.l		d4,d3			; dy*(nextx-x1)-dx*(nexty-y1)
	muls.l		d3,d4:d3		; (dy*(nextx-x1)-dx*(nexty-y1))^2
End_Calculate
	rts
	
Calculate_Slide
	move.w		dx,d5			; dx
	move.w		dy,d6			; dy
	muls.w		d5,d5			; dx^2
	muls.w		d6,d6			; dy^2
	add.l		d5,d6			; dx^2+dy^2=N^2
	move.l		d6,d7			; Idem
	move.l		nextx,d1		; Next x player position
	move.l		px,d2			; Actual x player position
	sub.l		d2,d1			; nextx-px
	move.w		dx,d2			; dx
	ext.l		d2			; Extended
	muls.l		d2,d1			; (nextx-px)*dx
	move.l		nexty,d2		; Next y player position
	move.l		py,d3			; Actual y player position
	sub.l		d3,d2			; nexty-py
	move.w		dy,d3			; dy
	ext.l		d3			; Extended
	muls.l		d3,d2			; (nexty-py)*dy
	add.l		d2,d1			; (nextx-px)*dx+(nexty-py)*dy=P
	move.l		d1,d3			; Idem
	move.w		dx,d5			; dx
	ext.l		d5			; Extended
	muls.l		d5,d2:d1		; dx*P
	divs.l		d7,d2:d1		; dx*P/N^2=(dx/N)*(P/N)
	move.w		dy,d6			; dy
	ext.l		d6			; Extended
	muls.l		d6,d4:d3		; dy*P
	divs.l		d7,d4:d3		; dy*P/N^2=(dy/N)*(P/N)
	move.l		px,d4			; Actual x player position
	add.l		d4,d1			; + New x move
	move.l		d1,cor_nextx		; = Next x player position
	move.l		py,d5			; Actual y player position
	add.l		d5,d3			; + New y move
	move.l		d3,cor_nexty		; = Next y player position
	rts
	
*-------------------------------------------------------*
			bsslong
*-------------------------------------------------------*

blocks_scan
	ds.w 10
nextx
	ds.l 1
nexty
	ds.l 1	
cor_nextx
	ds.l 1
cor_nexty
	ds.l 1
dx
	ds.w 1
dy
	ds.w 1
delta
	ds.l 1
no_move
	ds.w 1
GOGO
	ds.w 1

*-------------------------------------------------------*
			txtlong
*-------------------------------------------------------*
