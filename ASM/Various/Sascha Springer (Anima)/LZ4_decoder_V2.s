;input:
; a0.l = lz4 compressed data address
; a1.l = destination address


lz4_decode:
	addq.l    #7,a0
	lea       little_endian+4,a2
	moveq     #0,d2
	move.w    #$f,d4

next_block:
	move.b    (a0)+,-(a2)
	move.b    (a0)+,-(a2)
	move.b    (a0)+,-(a2)
	move.b    (a0)+,-(a2)
	move.l    (a2)+,d3
	bmi       copy_uncompressed_block
	beq       end_of_compressed_data

	lea       (a0,d3.l),a4

next_token:
	moveq     #0,d0
	move.b    (a0)+,d0

	move.w    d0,d1
	lsr.w     #4,d1
	beq.s     match_data_only

	cmp.w     d4,d1
	beq.s     additional_literal_length

	subq.w    #1,d1

short_literal_copy_loop:
	move.b    (a0)+,(a1)+

	dbra      d1,short_literal_copy_loop

	bra.s     process_match_data

additional_literal_length:
	move.b    (a0)+,d2
	add.w     d2,d1
	not.b     d2
	beq.s     additional_literal_length

	move.w    d1,d3
	lsr.w     #4,d1
	and.w     d4,d3
	add.w     d3,d3
	neg.w     d3
	jmp       literal_copy_start(pc,d3.w)

long_literal_copy_loop:
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
	move.b    (a0)+,(a1)+
literal_copy_start:
	dbra      d1,long_literal_copy_loop

process_match_data:
	cmpa.l    a4,a0
	beq.s     next_block

match_data_only:
	moveq     #0,d3
	move.b    (a0)+,-(a2)
	move.b    (a0)+,-(a2)
	move.w    (a2)+,d3
	neg.l     d3
	lea       (a1,d3.l),a3

	and.w     d4,d0
	cmp.w     d4,d0
	beq.s     additional_match_length

	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
short_match_copy_loop:
	move.b    (a3)+,(a1)+

	dbra      d0,short_match_copy_loop

	bra.s     next_token

additional_match_length:
	move.b    (a0)+,d2
	add.w     d2,d0
	not.b     d2
	beq.s     additional_match_length

	move.w    d0,d3
	lsr.w     #4,d0
	and.w     d4,d3
	add.w     d3,d3
	neg.w     d3
	jmp       match_copy_start(pc,d3.w)

long_match_copy_loop:
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
match_copy_start:
	dbra      d0,long_match_copy_loop

	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+
	move.b    (a3)+,(a1)+

	bra       next_token

copy_uncompressed_block:
	andi.l    #$7fffffff,d3
block_copy_loop:
	move.b    (a0)+,(a1)+

	subq.l    #1,d3
	bne.s     block_copy_loop

	bra       next_block
 
end_of_compressed_data:
	rts

little_endian:
   ds.l   1