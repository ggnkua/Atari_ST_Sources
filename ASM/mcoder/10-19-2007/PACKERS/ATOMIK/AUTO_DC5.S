top_prg:	bra	instal_auto
auto_decrun:	tst.b	$f8.w
	beq.s	check
	pea	(a0)
	lea	mode(pc),a0
	btst	#5,4(a7)
	beq.s	.user
	sf	(a0)
	cmp	#$3f,10(a7)
	beq.s	read_file
	bra.s	quit
.user:	st	(a0)
	move.l	usp,a0
	cmp	#$3f,(a0)
	beq.s	read_file	
quit:	move.l	(a7)+,a0
check:	jmp	0
read_file:	move.l	(a7)+,a0
	move.l	a7,savesp
	lea	local_pile(pc),a7
	movem.l	d1-a6,-(a7)
	move.b	mode(pc),d0
	bne.s	.user
	move.l	savesp(pc),a6
	addq	#6,a6
	bra.s	.well
.user:	move.l	usp,a6
.well:	movem.l	(a6),d5/d6/a5	;d7=buffer  d6=lenght
	moveq	#$e,d0
	cmp.l	d0,d6
	blt.s	quit3
	movem.l	d5/d6/a5,-(a7)
	pea	suite(pc)
	move	sr,-(a7)
set_trap:	jmp	0
suite:	lea	12(a7),a7
	move.l	d0,lenght_file
	bmi	quit2
	move.l	a5,a0
	addq	#4,a5
	bsr.s	recup
	cmp.l	#"ATM5",d0
	bne	quit2
	lea	4(a5),a0
	bsr.s	recup
	moveq	#12,d1
	add.l	d1,d0
	cmp.l	d0,d6
	blt.s	quit3
	bra.s	depack	
quit3:	movem.l	(a7)+,d1-a6
	move.l	savesp(pc),a7
	bra.s	quit
recup:	moveq	#3,d1
.recup:	lsl.l	#8,d0
	move.b	(a0)+,d0
	dbf	d1,.recup
	rts
depack:	move.l	a5,a0
	bsr.s	recup
	move.l	d0,lenght_file
	move.l	d0,-(a7)
	add.l	d0,a5
	move.l	a5,a4
	bsr.s	recup
	move.l	a0,a6
	add.l	d0,a6
	moveq	#0,d0
	move.b	-(a6),d0
	move.b	d0,s_picn+1
	lsl	#2,d0
	addq	#4,d0
	sub	d0,a4
	lea	$210(a4),a5
	lea	buff_marg(pc),a3
	move	#$20f,d0
.save_m:	move.b	(a4)+,(a3)+
	dbf	d0,.save_m
	movem.l	a3-a4,-(a7)
	link	a2,#-26
	pea	(a5)
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
	tst.b	-26(a2)
	beq.s	.ho_kesako1
	move.b	10-26(a2,d5.w),-(a5)
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
	tst.b	1-26(a2)
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
.its_little:	or.b	2-26(a2),d1
	bra.s	.spe_ofcod3
.take_orof:	or.b	3-26(a2,d5.w),d1
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
	lea	2-26(a2),a1
	move.b	d0,(a1)+
	moveq	#1,d1
	moveq	#6,d2
.next:	cmp.b	d0,d1
	bne.s	.no_off_4b
	addq	#2,d1
.no_off_4b:	move.b	d1,(a1)+
	addq	#2,d1
	dbf	d2,.next
	st	1-26(a2)
	bra.s	.spe_ofcod
.nospe_ofcod:	sf	1-26(a2)
.spe_ofcod:	moveq	#0,d6
	bsr	get_bit2
	beq.s	.relatif
	lea	10-26(a2),a1
	moveq	#15,d0
.next_f:	move.b	-(a6),(a1)+
	dbf	d0,.next_f
	st	-26(a2)
	bra.s	.freq
.relatif:	sf	-26(a2)
.freq:	clr	d3
	move.b	-(a6),d3
	move.b	-(a6),d0
	lsl	#8,d0
	move.b	-(a6),d0
	move.l	a5,a3
	sub	d0,a3
	bra.s	make_jnk
string:	bra	decrunch
work_done:	move.l	(a7)+,a0
	unlk	a2
	bsr.s	decod_picture
	movem.l	(a7)+,a3-a4
	move.l	(a7)+,d0
	bsr	copy_decrun
	move	#$20f,d0
.restore_m:	move.b	-(a3),-(a4)
	dbf	d0,.restore_m
quit2:	movem.l	(a7)+,d1-a6
	move.l	lenght_file(pc),d0
	move.l	savesp(pc),a7	
 	rte
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	0,1,3,4,5,6,7,8
decod_picture:	move	s_picn(pc),d7
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	moveq	#3,d1
.recup:	move.b	-(a0),d0
	ror.l	#8,d0
	dbf	d1,.recup
	lea	0(a5,d0.l),a1
	move.l	a1,d0
	move.l	d0,a3
	lsr	d0
	bcc.s	.no_odd
	move.l	a1,a2
	move.b	-(a1),-(a7)
	move.l	a1,a4
	move	#$1f3f,d0
.copy_graph:	rept	4
	move.b	(a2)+,(a4)+
	endr
	dbf	d0,.copy_graph
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
	move.l	a3,d0
	lsr	d0
	bcc.s	.no_odd2
	move	#$1f3f,d0
	lea	-1(a4),a2
.copy_graph2:	rept	4
	move.b	-(a2),-(a4)
	endr
	dbf	d0,.copy_graph2
	move.b	(a7)+,(a1)+
.no_odd2:	bra.s	.next_picture
copy_decrun:	lsr.l	#4,d0
	lea	-12(a6),a6
.copy_decrun:	move	a5,d1
	lsr	d1
	bcs.s	.odd_adr
.copy_decrun2:	rept	4
	move.l	(a5)+,(a6)+
	endr
	dbf	d0,.copy_decrun2
	rts
.odd_adr:	rept	16
	move.b	(a5)+,(a6)+
	endr
	dbf	d0,.odd_adr
	rts
buff_marg:	dcb.b	$210
lenght_file:	dc.l	0
mode:	dc.b	0
s_picn:	dc.w	0	
savesp:	ds.l	128
local_pile:
instal_auto:	pea	instal1
	move	#$26,-(a7)
	trap	#$e
	addq	#6,a7
	clr	-(a7)
ever_set:	pea	((instal_auto-top_prg)+$100).w
	move	#$31,-(a7)
	trap	#1
instal1:	tst.b	$f8.w
	beq.s	set_auto
	move.l	$84.w,a0
	move.l	a0,a3
	bsr.s	get_check
	beq.s	set_auto
	pea	everset_txt(pc)
	move	#9,-(a7)
	trap	#1
	move	#7,-(a7)
	trap	#1
	addq	#8,a7
	swap	d0
	cmp	#$44,d0
	bne.s	.no_remove
	sf	$f8.w
.no_remove:	rts
get_check:	move.l	a0,a1
	moveq	#0,d1
	move	#(check-auto_decrun)/2,d0
.next_check:	add	(a1)+,d1
	ror.l	#7,d1
	dbf	d0,.next_check
	cmp.l	#$c71ef897,d1
	bne.s	.right
	cmp	#$4ef9,-(a1)
	bne.s	.right
	move	#$4e41,ever_set
	moveq	#-1,d0
	rts
.right:	moveq	#0,d0
	rts
set_auto:	lea	$f0.w,a3
	cmp.l	#"ATM5",(a3)+
	bne.s	.right2
	move.l	(a3)+,a0
	bsr.s	get_check
	beq.s	.right2
	st	(a3)
	rts
.right2:	lea	$f0.w,a3
	move.l	#"ATM5",(a3)+
	lea	auto_decrun(pc),a1
	move.l	$84.w,a0
	move.l	a1,$84.w
	move.l	a1,(a3)+
	st	(a3)	
	move.l	a0,set_trap+2
	move.l	a0,check+2
	rts
everset_txt:	dc.b	$1b,"EAUTO DECRUNCHER Vers 3.5 EVER INSTALLED!",$D,$A,$A
	dc.b	"PRESS F10 TO REMOVE OR ANY KEY TO QUIT.",0
	