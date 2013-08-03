MODE:		EQU	0
PIC_ALGO:	EQU	1
DEC_SPACE:	EQU	$80	 ;MAX IS $7FFE (no odd value!)
RESTORE_SPACE:	EQU	0

MAX_FUNCTION_NUMBER:	equ	3+4

gogo:	movem.l	d0-a6,-(sp)
	cmp.w	#MAX_FUNCTION_NUMBER,d0
	bgt.s	no_function
	add.w	d0,d0
	move.w	function_list(pc,d0.w),d0
	jsr	function_list(pc,d0.w)
no_function:
	movem.l	(sp)+,d0-a6
	rts
	
function_list:
	dc.w	init_depacker-function_list
	dc.w	depack_back-function_list
	dc.w	depack_both-function_list
	dc.w	scroll_left-function_list
	dc.w	scroll_right-function_list
	dc.w	scroll_up-function_list
	dc.w	scroll_down-function_list
	
init_depacker:
	lea	depack_ptrs(pc),a6
	movem.l	a0-a2,(a6)
	rts
	
depack_ptrs:

depack_space:	dc.l	0
back_screen:	dc.l	0
physic_screen:	dc.l	0	
	
block_info:

x_coord:	dc.w	0
y_coord:	dc.w	0
x_size:		dc.w	0
y_size:		dc.w	0	
		
depack_back:
	lea	block_info(pc),a6
	movem.w	d1-d4,(a6)
	move.l	depack_space(pc),a1
	bsr	depack
	move.l	back_screen(pc),a1
	bra	draw						
			
depack_both:
	lea	block_info(pc),a6
	movem.w	d1-d4,(a6)
	move.l	depack_space(pc),a1
	bsr	depack
	move.l	back_screen(pc),a1
	bsr	draw
	move.l	physic_screen(pc),a1
	bra	draw			
			
draw:	move.l	depack_space(pc),a0
	move.w	x_coord(pc),d0
	move.w	y_coord(pc),d1
	lsr.w	#4,d0
	lsl.w	#3,d0
	mulu	#160,d1
	add.w	d1,d0
	lea	(a1,d0.w),a1

	move.w	x_size(pc),d0
	move.w	y_size(pc),d1
	lsr.w	#4,d0
	subq.w	#1,d0
	bmi.s	err
	subq.w	#1,d1								
	bmi.s	err
yl:	move.w	d0,d2
	move.l	a1,a2
xl:	move.l	(a0)+,(a2)+
	move.l	(a0)+,(a2)+
	dbra	d2,xl
	lea	160(a1),a1
	dbra	d1,yl
err:	rts

depack:	movem.l	d0-a6,-(a7)
	cmp.l	#"ATM5",(a0)+
	bne	not_packed
	link	a2,#-28
	move.l	(a0)+,d0
	ifne	MODE
	lea	4(a0,d0.l),a5
	move.l	d0,-(a7)
	elseif
	move.l	a1,a5
	add.l	d0,a5
	endc
	move.l	a5,a4
	ifne	MODE
	ifne	DEC_SPACE
	lea	DEC_SPACE(a4),a5
	endc
	endc
	lea	-$c(a4),a4
	move.l	(a0)+,d0
	move.l	a0,a6
	add.l	d0,a6
	ifne	PIC_ALGO
	moveq	#0,d0
	move.b	-(a6),d0
	move	d0,-2(a2)
	ifne	RESTORE_SPACE
	lsl	#2,d0
	sub	d0,a4
	endc
	elseif
	ifne	RESTORE_SPACE
	clr	-2(a2)
	endc
	subq	#1,a6
	endc
	ifne	RESTORE_SPACE
	lea	buff_marg(pc),a3
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.save
.save_m:	move.b	(a4)+,(a3)+
	subq	#1,d0
.save:	bne.s	.save_m
	movem.l	a3-a4,-(a7)
	endc
	ifne	PIC_ALGO
	pea	(a5)
	endc
	move.b	-(a6),d7
	bra	take_type
decrunch:	move	d3,d5
take_lenght:	add.b	d7,d7
.cont_take:	dbcs	d5,take_lenght
	beq.s	.empty1
	bcc.s	.next_cod
	sub	d3,d5
	neg	d5
	bra.s	.do_copy1
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_take
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15,d5
.do_copy:	add	d3,d5
.do_copy1:	lea	decrun_table(pc),a4
	move	d5,d2
	bne.s	bigger
	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	.ho_kesako
	moveq	#1,d6
	bra.s	word
.ho_kesako:	moveq	#3,d6
	bsr.s	get_bit2
	tst.b	-28(a2)
	beq.s	.ho_kesako1
	move.b	10-28(a2,d5.w),-(a5)
	bra	tst_end
.ho_kesako1:	move.b	(a5),d0
	btst	#3,d5
	bne.s	.ho_kesako2
	bra.s	.ho_kesako3
.ho_kesako2:	add.b	#$f0,d5
.ho_kesako3:	sub.b	d5,d0
	move.b	d0,-(a5)
	bra	tst_end
get_bit2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger:	moveq	#2,d6
word:	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	tst.b	1-28(a2)
	bne.s	.spe_ofcod1
	addq	#4,d6
	bra.s	.nospe_ofcod1
.spe_ofcod1:	bsr.s	get_bit2
	move	d5,d1
	lsl	#4,d1
	moveq	#2,d6
	bsr.s	get_bit2
	cmp.b	#7,d5
	blt.s	.take_orof
	moveq	#0,d6
	bsr.s	get_bit2
	beq.s	.its_little
	moveq	#2,d6
	bsr.s	get_bit2
	add	d5,d5
	or	d1,d5
	bra.s	.spe_ofcod2
.its_little:	or.b	2-28(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-28(a2,d5.w),d1
.spe_ofcod3:	move	d1,d5
	bra.s	.spe_ofcod2
.nospe_ofcod1:	bsr.s	get_bit2
.spe_ofcod2:	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d2,.copy_same
	bra.s	tst_end
make_jnk:	add.b	d7,d7
	bne.s	.not_empty
	move.b	-(a6),d7
	addx.b	d7,d7
.not_empty:	bcs.s	string
	move.b	-(a6),-(a5)
tst_end:	cmp.l	a5,a3
	bne.s	make_jnk
	cmp.l	a6,a0
	beq.s	work_done
take_type:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.nospe_ofcod
	move.b	-(a6),d0
	lea	2-28(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-28(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-28(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-28(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-28(a2)
	bra.s	.freq
.relatif:	sf	-28(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:
	ifne	PIC_ALGO
	move.l	(a7)+,a0
	pea	(a2)
	bsr.s	decod_picture
	move.l	(a7)+,a2
	endc
	ifne	RESTORE_SPACE
	movem.l	(a7)+,a3-a4
	endc
	ifne	MODE
	move.l	(a7)+,d0
	bsr	copy_decrun
	endc
	ifne	RESTORE_SPACE
	move	-2(a2),d0
	lsl	#2,d0
	add	#DEC_SPACE+$C,d0
	bra.s	.restore
.restore_m:	move.b	-(a3),-(a4)
	subq	#1,d0
.restore:	bne.s	.restore_m
	endc
	unlk	a2
not_packed:	movem.l	(a7)+,d0-a6
 	rts
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
	ifne	PIC_ALGO
decod_picture:	move	-2(a2),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	lea	0(a5,d0.l),a1
.no_odd:	lea	$7d00(a1),a2
.next_planes:	moveq	#3,d6
.next_word:	move	(a1)+,d0
	moveq	#3,d5
.next_bits:	add	d0,d0
	addx	d1,d1
	add	d0,d0
	addx	d2,d2
	add	d0,d0
	addx	d3,d3
	add	d0,d0
	addx	d4,d4
	dbf	d5,.next_bits
	dbf	d6,.next_word
	movem	d1-d4,-8(a1)
	cmp.l	a1,a2
	bne.s	.next_planes
	bra.s	.next_picture
	endc
	ifne	MODE
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun
	rts
	endc
	ifne	RESTORE_SPACE
buff_marg:	dcb.b	$90+DEC_SPACE+$C
	endc
	
START_Y = 11	
END_Y   = 75	
START_X = 16
END_X   = 272

scroll_left:
	move.l	back_screen(pc),a0
	lea	((START_X/16)*8)+(START_Y*160)(a0),a0
	move.l	a0,a6
	moveq	#4,d4
	move.l	#$000f000f,d5
	move.l	#$80008000,d6	
	move.w	#END_Y-START_Y-1,d7
.s2:	swap	d7
	move.w	#((END_X-START_X)/16)-2-1,d7
	
	movem.w	(a0),d0-d3/a1-a4
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	move.w	a1,d0
	move.w	a2,d1
	move.w	a3,d2
	move.w	a4,d3
	lsl.l	d4,d0
	lsl.l	d4,d1
	lsl.l	d4,d2
	lsl.l	d4,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	not.w	d6
	and.w	d6,d0
	and.w	d6,d1
	and.w	d6,d2
	and.w	d6,d3
	not.w	d6
	and.l	d6,(a0)
	or.w	d0,(a0)+
	or.w	d1,(a0)+
	and.l	d6,(a0)
	or.w	d2,(a0)+
	or.w	d3,(a0)+
	
.s1:	move.w	a1,d0
	move.w	a2,d1
	move.w	a3,d2
	move.w	a4,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	movem.w	8(a0),a1-a4
	move.w	a1,d0
	move.w	a2,d1
	move.w	a3,d2
	move.w	a4,d3
	lsl.l	d4,d0	
	lsl.l	d4,d1	
	lsl.l	d4,d2	
	lsl.l	d4,d3	
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	movem.w	d0-d3,(a0)
	addq.l	#8,a0	
	dbra	d7,.s1
	
	move.w	a1,d0
	move.w	a2,d1
	move.w	a3,d2
	move.w	a4,d3
	lsl.w	d4,d0
	lsl.w	d4,d1
	lsl.w	d4,d2
	lsl.w	d4,d3
	not.w	d5
	and.w	d5,d0
	and.w	d5,d1
	and.w	d5,d2
	and.w	d5,d3
	not.w	d5
	and.l	d5,(a0)
	or.w	d0,(a0)+
	or.w	d1,(a0)+
	and.l	d5,(a0)
	or.w	d2,(a0)+
	or.w	d3,(a0)+
	lea	160(a6),a6
	move.l	a6,a0
	swap	d7
	dbra	d7,.s2
	rts

scroll_right:
	move.l	back_screen(pc),a0
	lea	((START_X/16)*8)+(START_Y*160)(a0),a0
	move.l	a0,a6
	move.w	#4,d4
	move.l	#$00010001,d5
	move.l	#$f800f800,d6	
	move.w	#END_Y-START_Y-1,d7
.s2:	swap	d7
	move.w	#((END_X-START_X)/16)-2-1,d7
	
	movem.w	(a0),d0-d3
	move.w	d0,a1
	move.w	d1,a2
	move.w	d2,a3
	move.w	d3,a4
	lsr.w	d4,d0
	lsr.w	d4,d1
	lsr.w	d4,d2
	lsr.w	d4,d3
	not.w	d6
	and.w	d6,d0
	and.w	d6,d1
	and.w	d6,d2
	and.w	d6,d3
	not.w	d6
	and.l	d6,(a0)
	or.w	d0,(a0)+
	or.w	d1,(a0)+
	and.l	d6,(a0)
	or.w	d2,(a0)+
	or.w	d3,(a0)+
	
.s1:	move.w	a1,d0
	move.w	a2,d1
	move.w	a3,d2
	move.w	a4,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	movem.w	(a0)+,a1-a4
	move.w	a1,d0
	move.w	a2,d1
	move.w	a3,d2
	move.w	a4,d3
	lsr.l	d4,d0	
	lsr.l	d4,d1	
	lsr.l	d4,d2	
	lsr.l	d4,d3	
	movem.w	d0-d3,-8(a0)
	dbra	d7,.s1
	
	move.w	a1,d0
	move.w	a2,d1
	move.w	a3,d2
	move.w	a4,d3
	swap	d0
	swap	d1
	swap	d2
	swap	d3
	movem.w	(a0),a1-a4
	move.w	a1,d0
	move.w	a2,d1
	move.w	a3,d2
	move.w	a4,d3
	lsr.l	d4,d0
	lsr.l	d4,d1
	lsr.l	d4,d2
	lsr.l	d4,d3
	not.w	d5
	and.w	d5,d0
	and.w	d5,d1
	and.w	d5,d2
	and.w	d5,d3
	not.w	d5
	and.l	d5,(a0)
	or.w	d0,(a0)+
	or.w	d1,(a0)+
	and.l	d5,(a0)
	or.w	d2,(a0)+
	or.w	d3,(a0)+
	lea	160(a6),a6
	move.l	a6,a0
	swap	d7
	dbra	d7,.s2
	rts


scroll_up:
	move.l	back_screen(pc),a0
	lea	((START_X/16)*8)+(START_Y*160)(a0),a0
	lea	4*160(a0),a1
	move.w	#END_Y-START_Y-4-1,d0
.c1:	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1),d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,12*4(a0)			
	lea	160(a0),a0
	lea	160-12*4(a1),a1
	dbra	d0,.c1
	rts
	
scroll_down:
	move.l	back_screen(pc),a0
	lea	((START_X/16)*8)+(END_Y*160)(a0),a0
	lea	-4*160(a0),a1
	move.w	#END_Y-START_Y-4-1,d0
.c2:	movem.l	(a1)+,d1-d7/a2-a6
	movem.l	d1-d7/a2-a6,(a0)
	movem.l	(a1),d1-d7/a2-a4
	movem.l	d1-d7/a2-a4,12*4(a0)
	lea	-160(a0),a0
	lea	(-160-12*4)(a1),a1
	dbra	d0,.c2
	rts			
		
endie:		

;	end
	