;a tous les lamers qui ce prennent pour des dieux de l'optimisation.

;aprennez qu'on ne peux pas passer en meme temps dix heures par jour
;a ecrire ces propres sources et dix autres a optimiser les sources
;des autres, en particulier lorsqu'il s'agit de se faire mousser
;au yeux des autres en denigrant le travail de quelqun qui peu
;representer jusqu'a plusieur annees de travail et de recherche.


;                          ALTAIR from VMAX & MCS


;atomik cruncher v3.3 100% coded by ALTAIR.
;completed on 25/3/1991
;
	opt	o+,x+
start:	move.l	4(a7),a5
	bsr	memory_alloc
	bsr	hide_cursor
	move	#4,-(a7)
	trap	#14
	addq	#2,a7
	move	d0,save_rez
	cmp	#2,d0
	beq.s	top_program
	move	#1,-(a7)
	moveq	#-1,d0
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	pea	set_color(pc)
	move	#$26,-(a7)
	trap	#14
	addq	#6,a7
	bra.s	top_program
set_color:	lea	$ffff8240.w,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,save_colors
	move	#$7777,(a0)+
	moveq	#14,d0
.clr:	clr	(a0)+
	dbf	d0,.clr
	rts
top_program:	lea	present(pc),a0
	bsr	print_a0
	lea	ask_mode(pc),a0
	bsr	print_a0
.other_key:	bsr	read_key
	cmp	#"1",d0
	beq.s	.exec_pack
	cmp	#"2",d0
	beq.s	.data_pack
	cmp	#"3",d0
	beq	multi_pack
	cmp	#"4",d0
	beq	set_params
	cmp	#"5",d0
	bne.s	.other_key
	bra	pterm
.data_pack:	st	mode
	lea	stars_extend(pc),a3
	bra.s	.suite
.exec_pack:	sf	mode
	lea	prg_extend(pc),a3
.suite:	move.l	a3,save_extend
	bsr	file_select
	tst	d0
	bne.s	top_program
	lea	present(pc),a0
	bsr	print_a0
	sf	multi_flag
	bsr	load_and_pack
	bra.s	top_program
print_time:	move.l	save2_4ba(pc),d0
	sub.l	save_4ba(pc),d0
	lsr.l	#3,d0
	moveq	#25,d1
	moveq	#0,d2
.next:	sub.l	d1,d0
	bmi.s	.end
	addq.l	#1,d2
	bra.s	.next
.end:	divu	#$3c,d2
	lea	time_saver(pc),a0
	bsr.s	set_time
	swap	d2
	bsr.s	hexa_dec
	bsr.s	set_time2
	clr.b	-(a0)
	lea	exec_time(pc),a0
	bsr	print_a0
	lea	time_saver(pc),a0
	bsr	print_a0
	rts
set_time:	bsr.s	hexa_dec
	move	d3,d4
	lsr	#8,d4
	bne.s	.ok
	moveq	#-$10,d4
.ok:	add	#$30,d4
	move.b	d4,(a0)+
set_time2:	move	d3,d4
	lsr	#4,d4
	and	#$f,d4
	add	#$30,d4
	move.b	d4,(a0)+
	move	d3,d4
	and	#$f,d3
	add	#$30,d3
	move.b	d3,(a0)+
	move.b	#$3a,(a0)+
	rts	
hexa_dec:	moveq	#0,d3
.next1:	subq	#8,d2
	subq	#2,d2
	bmi.s	.end1
	addq	#8,d3
	addq	#8,d3
	bra.s	.next1
.end1:	addq	#8,d2
	addq	#2,d2
	add	d2,d3
	rts
dec_hexa:	moveq	#0,d3
.next1:	subq	#8,d2
	subq	#8,d2
	bmi.s	.end1
	addq	#8,d3
	addq	#2,d3	
	bra.s	.next1
.end1:	addq	#8,d2
	addq	#8,d2
	add	d2,d3
	rts
supexec:	pea	(a0)
	move	#$26,-(a7)
	trap	#14
	addq	#6,a7
	rts
save_hz200:	move.l	$4ba.w,save_4ba
	rts
get_hz200:	move.l	$4ba.w,save2_4ba
	rts
print_a0:	pea	(a0)
	move	#9,-(a7)
	trap	#1
	addq	#6,a7
	rts
read_key:	move	#7,-(a7)
	trap	#1
	addq	#2,a7
	rts
file_select:	movem.l	d1-d3/a0-a2,-(a7)
	bsr	show_cursor
	bsr.s	get_dir
	lea	adr0(pc),a2	
	tst.b	(a2)+
	beq.s	.no_dir
.next:	tst.b	(a2)+
	bne.s	.next
.no_dir:	move.b	#$5c,-1(a2)
.copy:	move.b	(a3)+,(a2)+
	bne.s	.copy
	lea	params(pc),a0
	move.l	a0,d1
	move	#$c8,d0
	trap	#2
	bsr	hide_cursor
	tst	ctrl3+2
	beq.s	.chancel
	bsr.s	set_dir
	moveq	#0,d0
	bra.s	.end_select
.chancel:	moveq	#-1,d0
.end_select:	movem.l	(a7)+,d1-d3/a0-a2
	rts
set_dir:	lea	adr0(pc),a1
	moveq	#0,d0
	move.b	(a1)+,d0
	pea	(a1)
	sub	#$41,d0
	move	d0,-(a7)
	move	#14,-(a7)
	trap	#1
	addq	#4,a7
	move.l	(a7)+,a1
.next_char:	move.b	(a1)+,d0
	beq.s	.end_dir
	cmp.b	#"*",d0
	bne.s	.next_char
	clr.b	-(a1)
.end_dir:	pea	adr0(pc)
	move	#$3b,-(a7)
	trap	#1
	addq	#6,a7
	rts
get_dir:	movem.l	a0-a2,-(a7)
	lea	adr0(pc),a1
	move.l	a1,a2
	moveq	#64,d0
.clear:	clr.b	(a1)+
	dbf	d0,.clear
	move	#$19,-(a7)
	trap	#1
	addq	#2,a7
	add	#$41,d0
	move.b	d0,(a2)+
	move.b	#":",(a2)+
	clr	-(a7)
	pea	(a2)
	move	#$47,-(a7)
	trap	#1
	addq	#8,a7
	movem.l	(a7)+,a0-a2
	rts
struct_file:	lea	filename(pc),a0
	lea	adr0(pc),a1
	bsr.s	get_dir
	rept	2
	move.b	(a1)+,(a0)+
	endr
	tst.b	(a1)
	beq.s	.no_dir
.copy_dir:	move.b	(a1)+,(a0)+
	bne.s	.copy_dir
	subq	#1,a0
.no_dir:	move.b	#$5c,(a0)+
	lea	adr1(pc),a1
.copy_file:	move.b	(a1)+,(a0)+
	bne.s	.copy_file
	rts
hide_cursor:	movem.l	d0-d2/a0-a2,-(a7)
	dc.w	$a00a
	movem.l	(a7)+,d0-d2/a0-a2
	rts
show_cursor:	movem.l	d0-d2/a0-a2,-(a7)
	dc.w	$a009
	movem.l	(a7)+,d0-d2/a0-a2
	rts
memory_alloc:	bsr.s	mshrink
	bsr.s	save_10k
	rts	
mshrink:	move.l	#$1000,d0
	add.l	$c(a5),d0
	add.l	$14(a5),d0
	add.l	$1c(a5),d0
	move.l	d0,-(a7)
	pea	(a5)
	clr	-(a7)
	move	#$4a,-(a7)
	trap	#1
	lea	12(a7),a7
	rts
save_10k:	moveq	#-1,d0
	bsr.s	.malloc
	sub.l	#$2800,d0
	bmi.s	out_of_mem
.malloc:	move.l	d0,-(a7)
	move	#$48,-(a7)
	trap	#1
	addq	#6,a7
	rts
out_of_mem:	lea	out_memory(pc),a0
	bsr	print_a0
	bsr	read_key
pterm:	move	save_rez(pc),-(a7)
	moveq	#-1,d0
	move.l	d0,-(a7)
	move.l	d0,-(a7)
	move	#5,-(a7)
	trap	#14
	lea	12(a7),a7
	pea	restore_colors(pc)
	move	#$26,-(a7)
	trap	#14
	addq	#6,a7
	bsr.s	show_cursor
	clr	-(a7)
	trap	#1
restore_colors:
	movem.l	save_colors(pc),d0-d7
	movem.l	d0-d7,$ffff8240.w
	rts
read_file:	sf	rw_error
	bsr	show_cursor
	move	#2,-(a7)
	pea	filename(pc)
	move	#$3d,-(a7)
	trap	#1
	addq	#8,a7
	tst	d0
	bmi.s	.error
	move	d0,handle
	pea	load_adress
	moveq	#8,d2
	swap	d2
	move.l	d2,-(a7)
	move	d0,-(a7)
	move	#$3f,-(a7)
	trap	#1
	lea	12(a7),a7
	tst.l	d0
	bmi.s	.error1
	move.l	d0,lenght_read
	bra.s	.suite
.error1:	st	rw_error
.suite:	bra.s	close
.error:	bsr	hide_cursor
	rts
write_file:	bsr	show_cursor
	sf	rw_error
	clr	-(a7)
	pea	filename(pc)
	move	#$3c,-(a7)
	trap	#1
	addq	#8,a7
	tst	d0
	bpl.s	.ok_write
	bsr	hide_cursor
	moveq	#-1,d0
	bra.s	create_error
.ok_write:	move	d0,handle
	pea	(a2)
	move.l	d2,-(a7)
	move	d0,-(a7)
	move	#$40,-(a7)
	trap	#1
	lea	12(a7),a7
	tst.l	d0
	bpl.s	close
	st	rw_error
close:	bsr	hide_cursor
	move	handle(pc),-(a7)
	move	#$3e,-(a7)
	trap	#1
	addq	#4,a7
	tst	d0
create_error:	rts
print_d0:	moveq	#0,d3
	lea	String_buffer(pc),a0
	lea	value_buffer(pc),a1
	moveq	#7,d2
.next_digit:	rol.l	#4,d0
	move	d0,d1
	and	#$f,d1
	tst	d3
	bne.s	.no_empty
	tst	d1
	bne.s	.no_empty1
	tst	d2
	beq.s	.digit
	move.b	#$20,(a1)+
	bra.s	.next
.no_empty1:	moveq	#-1,d3
.no_empty:	cmp.b	#9,d1
	bls.s	.digit
	addq	#7,d1
.digit:	add	#'0',d1
	move.b	d1,(a1)+
.next:	dbf	d2,.next_digit
	bsr	print_a0
	rts	
print_lenght:	move.l	end_file(pc),d0
	sub.l	a4,d0
	move.l	d0,crh_lenght
	lea	$1fd(a4),a4
	move.l	a4,next_adress
	lea	to_crunch(pc),a0
	bsr	print_a0
	move.l	crh_lenght(pc),d0
	bsr.s	print_d0
	lea	ever_pack(pc),a0
	bsr	print_a0
	move.l	a5,d0
	lea	pack_adr,a0
	sub.l	a0,d0
	bsr.s	print_d0
	lea	up_line(pc),a0
	bsr	print_a0
	rts
set_params:	lea	present(pc),a0
	bsr	print_a0
	lea	params_txt(pc),a0
	bsr	print_a0
.other_key:	bsr	read_key
	cmp	#"1",d0
	beq.s	.extends
	cmp	#"2",d0
	beq.s	.set_params
	cmp	#"3",d0
	beq.s	.clear_params
	cmp	#"4",d0
	bne.s	.other_key
	bra	top_program
.clear_params:	lea	ask_clr_txt(pc),a0
	bsr	print_a0
.bad_key:	bsr	read_key
	and	#$df,d0
	cmp	#"N",d0
	beq.s	set_params
	cmp	#"Y",d0
	bne.s	.bad_key
.clear:	lea	cleared_txt(pc),a0
	bsr	print_a0
	clr.b	pic_number
	bsr	read_key
	bra.s	set_params
.extends:	lea	present(pc),a0
	bsr	print_a0
	lea	extends_txt(pc),a0
	bsr	print_a0
	bsr	read_key
	bra.s	set_params
.set_params:	lea	ask_pic_num(pc),a0
	bsr	print_a0
	moveq	#2,d3
	moveq	#9,d6
	bsr.s	take_number
	bsr	dec_hexa
	move.b	d3,pic_number
	move	d3,d4
	lea	skip_2lines(pc),a0
	bsr	print_a0
	lea	offset_saver(pc),a2
.get_offset:	tst.b	d4
	beq	set_params
	bsr.s	get_picoff
	move.l	d2,(a2)+
	bra.s	.get_offset
get_picoff:	lea	ask_offset(pc),a0
	bsr	print_a0
	move	d4,d1
	bsr.s	print2_d1
	lea	ask_offset2(pc),a0
	bsr	print_a0
	moveq	#5,d3
	moveq	#$f,d6
	bsr.s	take_number
	lsr	d2
	bcs.s	get_picoff
	add	d2,d2
	subq	#1,d4
	rts
print2_d1:	movem.l	d2/d3,-(a7)
	move	d1,d2
	bsr	hexa_dec
	move	d3,d1
	movem.l	(a7)+,d2/d3
	move	d1,-(a7)
	lsr	#4,d1
	add	#$30,d1
	bsr.s	print_d1
	move	(a7)+,d1
	and	#$f,d1
	add	#$30,d1
	bsr.s	print_d1
	rts
print_d1:	move	d1,-(a7)
	move	#2,-(a7)
	trap	#1
	addq	#4,a7
	rts
take_number:	move	d3,d5
.take_num1:	moveq	#0,d2
.take_num:	bsr	read_key
	cmp	#$d,d0
	beq.s	.end_num
	cmp	#8,d0
	beq.s	.back_space
	move	d0,d1
	cmp	#$39,d0
	bgt.s	.take_num2
	sub	#$30,d0
	bmi.s	.take_num
	bra.s	.fin
.take_num2:	and	#$df,d0
	sub	#$37,d0
	bmi.s	.take_num
.fin:	cmp	d6,d0
	bgt.s	.take_num
	lsl.l	#4,d2
	or.b	d0,d2
	bsr.s	print_d1
	dbf	d3,.take_num
	move	d5,d1
	mulu	#3,d1
	neg	d1
	lea	back_space(pc),a0
	lea	0(a0,d1.w),a0
	bsr	print_a0
	move	d5,d3
	bra.s	.take_num1
.end_num:	cmp	d5,d3
	beq.s	.take_num
	rts
.back_space:	cmp	d5,d3
	beq.s	.take_num
	addq	#1,d3
	lsr.l	#4,d2
	lea	back_space(pc),a0
	bsr	print_a0
	bra.s	.take_num
multi_pack:	lea	present(pc),a0
	bsr	print_a0
	lea	multi_txt(pc),a0
	bsr	print_a0
	clr	file_number
.other_key:	bsr	read_key
	cmp	#"1",d0
	beq.s	.multi_data
	cmp	#"2",d0
	beq.s	.multi_prg
	cmp	#"3",d0
	beq.s	.set_dir
	cmp	#"4",d0
	bne.s	.other_key
	bra	top_program
.set_dir:	lea	stars_extend(pc),a3
	bsr	file_select
	bra.s	multi_pack
.multi_data:	st	mode
	bra.s	.multi		
.multi_prg:	sf	mode
.multi:	bsr	fsfirst
	beq.s	.code
	lea	disk_empty(pc),a0
	bsr	print_a0
	bsr	read_key
	bra.s	multi_pack
.code:	st	multi_flag
.code1:	lea	file_number+1(pc),a0
	bsr	.add_dec
	lea	crunch_number+1(pc),a0
	bsr	.add_dec
	bsr	load_and_pack
	tst.b	quit_flag
	bne.s	.quited
	tst.b	larger_flag
	beq.s	.normal
.quited:	lea	crunch_number+1(pc),a0
	moveq	#1,d1
	move.b	(a0),d0
	sbcd	d1,d0
	move.b	d0,(a0)
	move.b	-(a0),d0
	moveq	#0,d1
	sbcd	d1,d0
	move.b	d0,(a0)
.normal:	bsr.s	fsnext
	beq.s	.code1
	lea	multi_cr_end(pc),a0
	bsr	print_a0
	moveq	#0,d1
	move.b	crunch_number(pc),d1
	bsr	print2_d1
	move.b	crunch_number+1(pc),d1
	bsr	print2_d1
	lea	multi_cr_end1(pc),a0
	bsr	print_a0
	lea	multi_cr_end2(pc),a0
	bsr	print_a0
	move.b	file_number(pc),d1
	bsr	print2_d1
	move.b	file_number+1(pc),d1
	bsr	print2_d1
	lea	multi_cr_end3(pc),a0
	bsr	print_a0
.bip:	lea	bip_code(pc),a0
	bsr	print_a0
	move	#$ff,-(a7)
	move	#6,-(a7)
	trap	#1
	addq	#4,a7
	tst	d0
	beq.s	.bip
	bra	multi_pack
.add_dec:	moveq	#1,d1
	move.b	(a0),d0
	abcd	d1,d0
	move.b	d0,(a0)
	move.b	-(a0),d0
	moveq	#0,d1
	abcd	d1,d0
	move.b	d0,(a0)
	rts
fsnext:	moveq	#$4f,d0
	bra.s	next_file
fsfirst:	moveq	#$4e,d0
next_file:	clr	-(a7)
	pea	stars_extend(pc)
	move	d0,-(a7)
	bsr	fsetdta
	trap	#1
	addq	#8,a7
	bsr.s	.copy_name
	tst	d0	
	rts
.copy_name:	lea	filename2(pc),a0
	lea	adr1(pc),a1
	moveq	#13,d1
.copy_name1:	move.b	(a0)+,(a1)+
	dbf	d1,.copy_name1
	rts
load_and_pack:	bsr	struct_file
	bsr	read_file
	lea	present(pc),a0
	bsr	print_a0
	move.l	lenght_read(pc),d0
	lsr	d0
	bcc.s	.ok_lenght
	add	d0,d0
	addq.l	#2,d0
	bra.s	.odd_lenght
.ok_lenght:	add	d0,d0
.odd_lenght:	move.l	d0,-(a7)
	moveq	#0,d1
	move.b	pic_number(pc),d1
	lea	offset_saver(pc),a0
	bne.s	.picture
	sf	pic_flag
	bra.s	.ok_offset
.picture:	st	pic_flag
	subq	#1,d1
	sub.l	#$7d00,d0
	bmi.s	.error
.next:	cmp.l	(a0)+,d0
	dblt	d1,.next
	bge.s	.ok_offset
.error:	sub.b	pic_number(pc),d1
	neg	d1
	ext	d1
	move	d1,-(a7)
	lea	params_err(pc),a0
	bsr	print_a0
	move	(a7)+,d1
	bsr	print2_d1
	lea	params_err2(pc),a0
	bsr	print_a0
	bsr	read_key
	addq	#4,a7
	st	quit_flag
	bra	quit_code
.ok_offset:	move.l	(a7)+,d0
	moveq	#0,d7
	tst.b	mode
	bne.s	.data
	move.b	pic_number(pc),d7
	beq.s	.no_pic
.data:	move.b	pic_number(pc),d7
	lea	load_adress,a0
	move.l	a0,a2
	add.l	d0,a0
	lea	offset_saver(pc),a1
	move	d7,d6
	subq	#1,d6
	bmi.s	.no_pic0
.copy_offset:	move.l	(a1)+,(a0)+
	dbf	d6,.copy_offset
.no_pic0:	move	d7,(a0)+
	move.l	a0,d0
	sub.l	a2,d0
.no_pic:	move.l	d0,org_lenght
	move.l	d0,crh_lenght
	lea	crunching(pc),a0
	bsr	print_a0
	lea	filename(pc),a0
	bsr	print_a0
	lea	skip_2lines(pc),a0
	bsr	print_a0
	sf	larger_flag
	lea	save_hz200(pc),a0
	bsr	supexec
	bsr	atomik
	tst.b	quit_flag
	bne	quit_code
	lea	get_hz200(pc),a0
	bsr	supexec
	bsr	print_time
	move.l	org_lenght(pc),d0
	move.l	(a5),d1
	lsr	d1
	bcc.s	.ok
	add	d1,d1
	addq.l	#2,d1
	bra.s	.cont
.ok:	add	d1,d1
.cont:	move.l	d1,a0
	addq	#8,a0
	tst.b	mode
	bne.s	.data1
	tst.b	pic_flag
	beq.s	.no_pic1
	lea	$46(a0),a0
.no_pic1:	lea	$23c(a0),a0
	bra.s	.cont1
.data1:	addq	#4,a0
.cont1:	cmp.l	a0,d0
	ble	larger
	move.l	a0,save_lenght
	lea	crunch_leng(pc),a0
	bsr	print_a0
	move.l	save_lenght(pc),d0
	bsr	print_d0
	tst.b	mode
	bne.s	.data2
	move.l	save_lenght(pc),a0
	move.l	a0,d2
	lea	-$20(a0),a0
	move.l	a0,txt_lenght
	move.l	a0,txt_lenght2
	lea	decrun_space2,a1
	lea	decrun_code2(pc),a0
	move	#283,d0
	tst.b	pic_flag
	beq.s	.copy_decrun1
	lea	decrun_space,a1
	lea	decrun_code(pc),a0	
	add	#35,d0
.copy_decrun1:	move.l	a1,a2
.copy_decrun:	move	(a0)+,(a1)+
	dbf	d0,.copy_decrun
	bra.s	save_file
.data2:	lea	pack_adr,a2
	move.l	save_lenght(pc),d2
save_file:	lea	skip_2lines(pc),a0
	bsr	print_a0
	tst.b	multi_flag
	bne.s	.save
	lea	ask_save(pc),a0
	bsr	print_a0
.other_key:	bsr	read_key
	and	#$df,d0
	cmp	#"Y",d0
	beq.s	.save
	cmp	#"N",d0
	bne.s	.other_key
	bra	quit_code
.save:	tst.b	multi_flag
	bne.s	.multi
	move.l	save_extend(pc),a3
	bsr	file_select
	tst	d0
	bne.s	quit_code
	lea	present(pc),a0
	bsr	print_a0
.multi:	bsr	struct_file
	bsr	write_file
	tst.b	rw_error
	bne.s	write_err
	tst.b	multi_flag
	bne.s	quit_code
	lea	ok_saved_txt(pc),a0
	bsr	print_a0
	lea	filename(pc),a0
	bsr	print_a0
	lea	ok_saved2(pc),a0
	bsr	print_a0
	bsr	read_key
	bra.s	quit_code
write_err:	lea	write_error(pc),a0
	bsr	print_a0
.other_key:	bsr	read_key
	and	#$df,d0
	cmp	#"Y",d0
	beq	save_file
	cmp	#"N",d0
	bne.s	.other_key
	bra.s	quit_code
larger:	st	larger_flag
	lea	larger_txt(pc),a0
	bsr	print_a0
	tst.b	multi_flag
	bne.s	quit_code
	bsr	read_key
quit_code:	rts
fsetdta:	pea	dta_buffer(pc)
	move	#$1a,-(a7)
	trap	#1
	addq	#6,a7
	rts
atomik:	moveq	#0,d7
	move.b	pic_number(pc),d7
	beq.s	.end_code
	lea	offset_saver(pc),a2  	
.next_picture:	dbf	d7,.cod_picture
	bra.s	.end_code
.cod_picture:	lea	coding_txt(pc),a0
	bsr	print_a0
	move	d7,d1
	addq	#1,d1
	bsr	print2_d1
	lea	clear_right(pc),a0
	bsr	print_a0
	lea	load_adress,a0
	add.l	(a2)+,a0
	bsr	cod_graphics
	bra.s	.next_picture
.end_code:	bsr.s	algorythm
	rts	
algorythm:	lea	load_adress,a0
	move.l	a0,next_adress
	lea	pack_adr,a5
	tst.b	mode
	beq.s	.exec
	move.b	#"A",(a5)+
	move.b	#"T",(a5)+
	move.b	#"O",(a5)+
	move.b	#"M",(a5)+
.exec:	move.l	org_lenght(pc),d0
	btst	#0,d0
	bcc.s	.ok_lenght
	addq.l	#1,d0
	move.l	d0,org_lenght
.ok_lenght:	lea	0(a0,d0.l),a6
	move.l	a6,end_file
	moveq	#0,d0
	movep.l	d0,0(a6)
	movep.l	d0,1(a6)
	move.l	a6,d0
	sub.l	a0,d0
	move.l	d0,(a5)+
	addq	#4,a5
	pea	(a5)
	moveq	#0,d3
	moveq	#-$80,d7
	clr.b	quit_flag
	swap	d7
	move	#$41ec,change_code
	move.l	a0,a4
	move.l	a0,next_adress
	movem.l	d0-a6,-(a7)
	bsr	print_lenght
	movem.l	(a7)+,d0-a6
	bsr	make_table
	moveq	#0,d6
	bsr	packing
	tst.b	quit_flag
	beq.s	.normal
	addq	#4,a7
	bra.s	.quited
.normal:	swap	d7
	bsr	calcul_mark
	move.b	d7,(a5)+
	moveq	#0,d0
	movep.l	d0,0(a5)
	movep.l	d0,1(a5)
	move.l	a5,d0
	move.l	(a7)+,a5
	sub.l	a5,d0
	move.l	d0,-(a5)
.quited:	rts
look_lenght:	movem.l	d1-d3/a0-a4,-(a7)
	cmp.l	a4,a5
	blt.s	.ok_lenght
	lea	pack_adr,a5
	add.l	org_lenght(pc),a5
	bra.s	.exit
.ok_lenght:	bsr	print_lenght
	move	#$ff,-(a7)
	move	#6,-(a7)
	trap	#1
	addq	#4,a7
	cmp	#$1b,d0
	bne.s	.cont1
	lea	interupt(pc),a0
	bsr	print_a0
.other_key:	bsr	read_key
	and	#$df,d0
	cmp	#"Y",d0
	beq.s	.quit
	cmp	#"N",d0
	bne.s	.other_key
	bra.s	.cont1
.quit:	st	quit_flag
.exit:	movem.l	(a7)+,d1-d3/a0-a4
	rts
.cont1:	movem.l	(a7)+,d1-d3/a0-a4
	move.b	-1(a4),d0
	bra.s	cont_pack	
packing:	moveq	#0,d0
	lea	offset(pc),a3
	move.l	d0,(a3)+
	move	d0,(a3)
	lea	adress_table(pc),a3
	lea	how_table(pc),a2
	move.b	(a4)+,d0
	cmp.l	next_adress(pc),a4
	bge.s	look_lenght
cont_pack:	move.b	(a4),d1
cont_pakitos:	lea	$3f60(a4),a1
	cmp.l	a1,a6
	bgt.s	ok_offset
change_code:	lea	-1(a4),a0
	bsr	make_table
	bra.s	cont_pakitos
	move.l	a6,a1
ok_offset:	move	d0,d2
	add	d2,d2
	add	d2,a2
	subq	#1,(a2)
	beq.s	.go_finish
	move	(a2),d7
	subq	#1,d7
.ok:	lea	conter_table(pc),a2
	add	d2,a2
	addq	#2,(a2)
	move	(a2),d6
	add	d2,d2
	move.l	0(a3,d2.w),a2
	add.l	d6,a2
.next_offset:	move.l	a0,a3
	add	(a2)+,a3
	cmp.l	a3,a1
	ble.s	.go_finish
	cmp.b	(a3)+,d1
	dbeq	d7,.next_offset
	bne.s	.go_finish
	addq	#1,a4
	cmp.l	a3,a1
	bge.s	.tst_string
	subq	#1,a4
	tst	offset+2
	bge.s	.go_finish
	move.l	a3,d2
	sub.l	a4,d2
	cmp	#$3e0,d2
	bgt.s	.go_finish
	subq	#1,d2
	move	d2,offset
	addq	#2,offset+2
	st	offset+4
.go_finish:	bra	.finish
.tst_string:	move.l	a4,d2
.tst_strlen:	cmp.b	(a4)+,(a3)+
	bne.s	.end_lenght
	cmp.l	a3,a1
	bge.s	.tst_strlen
	sub.l	a4,d2
	neg	d2
	addq	#1,d2
	sub	d2,a4
	cmp	offset+2(pc),d2
	ble	.finish
.ok_len:	move	d2,offset+2
	move.l	a3,d5
	sub.l	a4,d5
	cmp	#2,d2
	bne.s	.bigger
	cmp	#$3e2,d5
	bgt.s	.finish
.bigger:	st	offset+4
	sub	d2,d5
	subq	#1,d5
	move	d5,offset
	bra.s	.finish
.end_lenght:	sub.l	a4,d2
	neg	d2
	addq	#1,d2
	sub	d2,a4
	cmp	#$3f,d2
	ble.s	.ok_lenght
.next_off:	moveq	#0,d4
	move	(a2)+,d4
	add.l	a0,d4
	cmp.l	d4,a3
	ble.s	.last_toskip
	dbf	d7,.next_off
	bra.s	.finish
.last_toskip:	subq	#2,a2
.ok_lenght:	cmp	offset+2(pc),d2
	ble.s	.cont_search
	move	d2,offset+2
	move.l	a3,d5
	sub.l	a4,d5
	cmp	#2,d2
	bgt.s	.bigger1
	cmp	#$3e2,d5
	bgt.s	.cont_search
.bigger1:	st	offset+4
	sub	d2,d5
	subq	#1,d5
	st	offset+4
	move	d5,offset
.cont_search:	dbf	d7,.next_offset	
.finish:	move	offset+4(pc),d2
	bne.s	.packed
	move.l	a4,a2
	lea	8(a4),a1
	cmp.l	end_file(pc),a1
	ble.s	.ok_off0
	move.l	end_file(pc),a1
.ok_off0:	cmp.b	(a2)+,d0
	beq.s	.one_found
	cmp.l	a2,a1
	bgt.s	.ok_off0
	bra.s	.not_found
.one_found:	move.l	a2,d1
	sub.l	a4,d1
	lea	offset+2(pc),a2
	clr	(a2)+
	move	#2,(a2)+
	move	d1,(a2)
	bra.s	.packed
.not_found:	lea	tablus_table3(pc),a2
	moveq	#3,d1
.next_us:	cmp.b	(a2)+,d0
	dbeq	d1,.next_us
	bne.s	.kekouik
	lea	offset+2(pc),a2
	clr	(a2)+
	move	#1,(a2)+
	move	d1,(a2)
	bra.s	.packed
.kekouik:	move.b	d0,(a5)+
	addq.l	#1,d3
	bra.s	.tst_end
.packed:	swap	d7
	bsr.s	calcul
	swap	d7
.tst_end:	cmp.l	a4,a6
	bgt	packing
	blt.s	.end_pack
	move.b	(a4)+,(a5)+
	addq.l	#1,d3
.end_pack:	rts
lenght_tabl:	dc.w	8,9,11,12,13,14,15,16
lenght_tabl2:	dc.w	8,9,10,11,12
calcul:	bsr	calcul_mark
	move	offset+2(pc),d0
	bne.s	.add
	move	offset+6(pc),d0
	cmp.b	#2,offset+5
	beq.s	.offset
	add	#$1c,d0
	move	d0,d1
	bra.s	.contos	
.offset:	subq	#1,d0
	moveq	#1,d1
.next:	subq	#4,d0
	dble	d1,.next
	neg	d1
	addq	#6,d1
	add	d1,d1
	add	d1,d1
	add	d0,d1
	addq	#4,d1
.contos:	moveq	#5,d3
	bra	.copy_bits
.add:	subq	#1,d0
	move	offset(pc),d1
	bsr.s	.set_offset
	move.l	a4,a2
	add	d0,a4
	move	d0,d3
.next_byte:	dbf	d3,.next_recalt
	bra.s	.setstr_len
.next_recalt:	lea	how_table(pc),a3
	move.b	(a2)+,d1
	moveq	#0,d2
	move.b	d1,d2
	add	d2,d2
	add	d2,a3
	subq	#1,(a3)
	lea	conter_table(pc),a3
	add	d2,a3
	addq	#2,(a3)
.last:	bra.s	.next_byte	
.setstr_len:	subq	#7,d0
	bgt.s	.nibble
	addq	#6,d0
	move	d0,d3
	moveq	#-2,d1
	bra	.copy_bits
.nibble:	sub	#15,d0
	bgt.s	.byte
	add	#$7ff,d0
	move	d0,d1
	moveq	#10,d3
	bra.s	.copy_bits
.byte:	sub	#$ff,d0
	bgt.s	.14bits
	add	#$f0ff,d0
	move	d0,d1
	moveq	#15,d3
	bsr.s	.copy_bits
	moveq	#7,d1
	moveq	#2,d3
	bra.s	.copy_bits
.14bits:	move	d0,d1
	moveq	#13,d3
	bsr.s	.copy_bits
	move	#$f000,d1
	moveq	#15,d3
	bsr.s	.copy_bits
	moveq	#7,d1
	moveq	#2,d3
	bra.s	.copy_bits
.set_offset:	cmp	#1,d0
	bne.s	.table1
	lea	offset_table2(pc),a2
	bra.s	.table2
.table1:	lea	offset_table(pc),a2
.table2:	move.l	a2,d3
	swap	d7
.next_offset:	cmp	(a2)+,d1
	blt.s	.ok_found
	sub	-2(a2),d1
	bra.s	.next_offset
.ok_found:	sub.l	a2,d3
	neg	d3
	cmp	#1,d0
	bne.s	.other
	move	code_t2-2(pc,d3.w),d7
	lea	lenght_tabl2(pc),a2
	bra.s	.cont
.other:	move	code_t-2(pc,d3.w),d7	
	lea	lenght_tabl(pc),a2
.cont:	move	-2(a2,d3.w),d3
	or	d7,d1
	subq	#1,d3
.no_mark:	swap	d7
.copy_bits:	lsr	d1
	roxr.b	d7
	dbcs	d3,.copy_bits
	bcc.s	.quit
	move.b	d7,(a5)+
	moveq	#-$80,d7
	dbf	d3,.copy_bits
.quit:	moveq	#0,d3
	rts
code_t:	dc.w	0,$40,$200,$600,$1000,$2800,$6000,$e000
code_t2:	dc.w	0,$40,$100,$300,$800,$a00,$c00,$e00
calcul_mark:	swap	d3
	tst	d3
	bne.s	.mega_jnk
	swap	d3
	cmp	#11,d3
	bgt.s	.byte_jnk
	move	d3,d2
	moveq	#-2,d3
	bra.s	.copy_bits
.byte_jnk:	sub	#11,d3
	cmp	#255,d3
	bgt.s	.mega_jnk2
	add	#$ff00,d3
	moveq	#15,d2
	bsr.s	.copy_bits
	moveq	#15,d3
	moveq	#3,d2
	bra.s	.copy_bits
.mega_jnk:	swap	d3
	subq.l	#8,d3
	subq.l	#3,d3
.mega_jnk2:	moveq	#15,d2
	bsr.s	.copy_bits
	swap	d3
	moveq	#2,d2
	bsr.s	.copy_bits
	moveq	#-1,d3
	not.b	d3
	moveq	#15,d2
	bsr.s	.copy_bits
	swap	d3
	moveq	#3,d2
.copy_bits:	lsr	d3
	roxr.b	d7
	dbcs	d2,.copy_bits
	bcc.s	.quit
	move.b	d7,(a5)+
	moveq	#-$80,d7
	dbf	d2,.copy_bits
 .quit:	rts
cod_graphics:	lea	$7d00(a0),a1
.next_4words:	movem	(a0),d0-d3
	moveq	#3,d6
.next_word:	moveq	#3,d5
.next_nibb:	add	d0,d0
	addx	d4,d4
	add	d1,d1
	addx	d4,d4
	add	d2,d2
	addx	d4,d4
	add	d3,d3
	addx	d4,d4
	dbf	d5,.next_nibb
	move	d4,(a0)+
	dbf	d6,.next_word
	cmp.l	a0,a1
	bne.s	.next_4words
	rts 
make_table:	movem.l	d0-d2/a0-a5,-(a7)
	lea	analys_txt(pc),a0
	bsr	print_a0
	move.l	12(a7),a0
	lea	how_table(pc),a1
	moveq	#0,d0
	moveq	#$7f,d1
.init_table:	rept	2
	move.l	d0,(a1)+
	endr
	dbf	d1,.init_table
	lea	$7fff(a0),a2
	cmp.l	end_file(pc),a2
	blt.s	.ok_offset
	move.l	end_file(pc),a2
	subq	#1,a2
	move	#$6008,change_code
.ok_offset:	move.l	a0,a1
	lea	how_table(pc),a3
.next_b:	moveq	#0,d0
	move.b	(a1)+,d0
	add	d0,d0
	addq	#1,0(a3,d0.w)
	cmp.l	a1,a2
	bge.s	.next_b
	move	#255,d1
	moveq	#0,d0
	lea	mark_table(pc),a4
	lea	adress_table(pc),a6
	move.l	a4,a5
	moveq	#0,d0
.next_adr:	add.l	d0,a5
	move	(a3)+,d0
	move.l	a5,(a6)+
	add	d0,d0
	dbf	d1,.next_adr	
	lea	conter_table(pc),a4
	move.l	a0,a1
	moveq	#0,d1
.next_off:	moveq	#0,d0
	move.b	(a1)+,d0
	move.l	a1,d2
	add	d0,d0
	move.l	a4,a5
	add	d0,a5
	move	(a5),d1
	addq	#2,(a5)
	add	d0,d0
	move.l	adress_table(pc,d0.w),a5
	add.l	d1,a5
	sub.l	a0,d2
	move	d2,(a5)
	cmp.l	a1,a2
	bge.s	.next_off
	move.l	a2,a6
	lea	conter_table(pc),a3
	moveq	#$7f,d0
	moveq	#0,d1
.init_conter:	move.l	d1,(a3)+
	dbf	d0,.init_conter
	lea	clear_right(pc),a0
	bsr	print_a0
	lea	up_2lines(pc),a0
	bsr	print_a0
	movem.l	(a7)+,d0-d2/a0-a5
	rts
adress_table:	dcb.l	$100,0
how_table:	dcb.w	$100,0
conter_table:	dcb.w	$100,0	
decrun_code:	dc.w	$601a
txt_lenght:	dc.l	0
	ds.w	11
decruncher:	move	#2,-(a7)
	trap	#14
	move.l	d0,a0
	move	#$17d,d0
.clear_lines:	clr.l	(a0)+
	dbf	d0,.clear_lines
	move	#4,(a7)
	trap	#14
	tst.b	d0
	lea	hello_txt(pc),a0
	beq.s	.low_res
	move.b	#$39,3(a0)
.low_res:	pea	(a0)
	move	#9,-(a7)
	trap	#1
	addq	#8,a7
	lea	packed_code(pc),a0
	move.l	(a0)+,d0
	bsr	depack
	move.l	a5,a3
	lea	decruncher-$100(pc),a6	
	move.l	2(a3),d0
	add.l	6(a3),d0
	add.l	14(a3),d0
	lea	$1c(a3,d0.l),a0
	move.l	8(a6),d0
	lea	$1c(a3),a3
	lea	16(a0),a4
	tst.l	(a0)	
	beq.s	.adjust_bpage
	add.l	(a0)+,a3
	moveq	#0,d1
.reloc_adr:	add.l	d0,(a3)
.take_next:	clr.b	-1(a0)
	move.b	(a0)+,d1
	beq.s	.adjust_bpage
	cmp.b	#1,d1
	bne.s	.calcul_adr
	lea	$fe(a3),a3
	bra.s	.take_next
.calcul_adr:	add	d1,a3
	bra.s	.reloc_adr
.adjust_bpage:	lea	2(a5),a3
	addq	#8,a6
	move.l	(a6)+,a2
	move.l	(a3),(a6)+
	move.l	(a3),d6
	add.l	(a3)+,a2
	move.l	a2,(a6)+
	move.l	(a3),(a6)+
	add.l	(a3),d6
	add.l	(a3)+,a2
	move.l	a2,(a6)+
	move.l	(a3),(a6)+
	lea	copy_code(pc),a1
	moveq	#((depack-copy_code)/4)-1,d0
	move.l	a4,a2
.copy:	move.l	(a1)+,(a4)+
	dbf	d0,.copy
	lea	decruncher(pc),a3
	move.l	4(a7),d0
	lea	$1c(a5),a5
	jmp	(a2)
copy_code:	move.l	a3,a4
.copy:	move.l	(a5)+,(a3)+
	subq.l	#4,d6
	bcc.s	.copy
.clear:	clr.l	(a2)+
	bra.s	.clear
	clr.l	(a2)+
	jmp	(a4)
depack:	lea	126(a0,d0.l),a5
	pea	(a5)
	move.l	(a0)+,d0	
	lea	0(a0,d0.l),a6
	move.b	-(a6),d7
	bra	make_jnk
tablus:	lea	tablus_table(pc),a4
	moveq	#1,d6
	bsr.s	get_bit2
	bra.s	tablus2
decrunch:	moveq	#6,d6
take_lenght:	add.b	d7,d7
	beq.s	.empty1
.cont_copy:	dbcc	d6,take_lenght
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_copy
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2
	add	#255+15+6,d5
.do_copy:	move	d5,-(a7)
	bne.s	bigger
	lea	decrun_table2(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2
	cmp	#5,d5
	blt.s	contus
	addq	#2,a7
	subq	#6,d5
	bgt.s	tablus
	move.l	a5,a4
	blt.s	.first4
	addq	#4,a4
.first4:	moveq	#1,d6
	bsr.s	get_bit2
tablus2:	move.b	0(a4,d5.w),-(a5)
	bra.s	make_jnk
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
bigger:	lea	decrun_table(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2
contus:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move	(a7)+,d5
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d5,.copy_same
make_jnk:	moveq	#11,d6
	moveq	#11,d5
take_jnk:	add.b	d7,d7
	beq.s	empty
cont_jnk:	dbcc	d6,take_jnk
	bcs.s	next_cod
	sub	d6,d5
	bra.s	copy_jnk1
next_cod:	moveq	#7,d6
	bsr.s	get_bit2
	beq.s	.next_cod1
	addq	#8,d5
	addq	#3,d5
	bra.s	copy_jnk1
.next_cod1:	moveq	#2,d6
	bsr.s	get_bit2
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2
	addq.l	#8,d5
	addq.l	#3,d5	
copy_jnk1:	subq	#1,d5
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk:	move.b	-(a6),-(a5)
	dbf	d5,.copy_jnk
	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word:	cmp.l	a6,a0
.decrunch:	bne	decrunch
	cmp.b	#$80,d7
	bne.s	.decrunch
	move.l	(a7)+,a0
	bsr.s	decod_picture
 	rts
empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	cont_jnk
decrun_table:	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2:	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8
tablus_table:	dc.b	$60,$20,$10,$8
decod_picture:	move	-(a0),d7
	clr	(a0)
.next_picture:	dbf	d7,.decod_algo
	rts
.decod_algo:	move.l	-(a0),d0
	clr.l	(a0)
	lea	0(a5,d0.l),a1
	lea	$7d00(a1),a2
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
hello_txt:	dc.b	$1b,$59,$20,$25,"ATOMIK v3.3 by ALTAIR VMAX/MCS"
packed_code:	
offset_table:	dc.w	32,64,256,512,1024,2048,4096,8192
offset_table2:	dc.w	32,64,128,256,512,512,512,512
decrun_code2:	dc.w	$601a
txt_lenght2:	dc.l	0
	ds.w	11
decruncher2:	move	#2,-(a7)
	trap	#14
	move.l	d0,a0
	move	#$17d,d0
.clear_lines:	clr.l	(a0)+
	dbf	d0,.clear_lines
	move	#4,(a7)
	trap	#14
	tst.b	d0
	lea	hello_txt2(pc),a0
	beq.s	.low_res
	move.b	#$39,3(a0)
.low_res:	pea	(a0)
	move	#9,-(a7)
	trap	#1
	addq	#8,a7	
	lea	packed_code2(pc),a0
	move.l	(a0)+,d0
	bsr	depack2
	move.l	a5,a3
	lea	decruncher2-$100(pc),a6	
	move.l	2(a3),d0
	add.l	6(a3),d0
	add.l	14(a3),d0
	lea	$1c(a3,d0.l),a0
	move.l	8(a6),d0
	lea	$1c(a3),a3
	lea	16(a0),a4
	tst.l	(a0)	
	beq.s	.adjust_bpage
	add.l	(a0)+,a3
	moveq	#0,d1
.reloc_adr:	add.l	d0,(a3)
.take_next:	clr.b	-1(a0)
	move.b	(a0)+,d1
	beq.s	.adjust_bpage
	cmp.b	#1,d1
	bne.s	.calcul_adr
	lea	$fe(a3),a3
	bra.s	.take_next
.calcul_adr:	add	d1,a3
	bra.s	.reloc_adr
.adjust_bpage:	lea	2(a5),a3
	addq	#8,a6
	move.l	(a6)+,a2
	move.l	(a3),(a6)+
	move.l	(a3),d6
	add.l	(a3)+,a2
	move.l	a2,(a6)+
	move.l	(a3),(a6)+
	add.l	(a3),d6
	add.l	(a3)+,a2
	move.l	a2,(a6)+
	move.l	(a3),(a6)+
	lea	copy_code2(pc),a1
	moveq	#((depack2-copy_code2)/4)-1,d0
	move.l	a4,a2
.copy:	move.l	(a1)+,(a4)+
	dbf	d0,.copy
	lea	decruncher2(pc),a3
	move.l	4(a7),d0
	lea	$1c(a5),a5
	jmp	(a2)
copy_code2:	move.l	a3,a4
.copy:	move.l	(a5)+,(a3)+
	subq.l	#4,d6
	bcc.s	.copy
.clear:	clr.l	(a2)+
	bra.s	.clear
	clr.l	(a2)+
	jmp	(a4)
depack2:	lea	126(a0,d0.l),a5
	move.l	(a0)+,d0	
	lea	0(a0,d0.l),a6
	move.b	-(a6),d7
	bra	make_jnk2
tablus_2:	lea	tablus_table2(pc),a4
	moveq	#1,d6
	bsr.s	get_bit2_2
	bra.s	tablus2_2
decrunch2:	moveq	#6,d6
take_lenght2:	add.b	d7,d7
	beq.s	.empty1
.cont_copy:	dbcc	d6,take_lenght2
	bcs.s	.next_cod
	moveq	#6,d5
	sub	d6,d5
	bra.s	.do_copy
.next_cod:	moveq	#3,d6
	bsr.s	get_bit2_2
	beq.s	.next_cod1
	addq	#6,d5
	bra.s	.do_copy
.next_cod1:	moveq	#7,d6
	bsr.s	get_bit2_2
	beq.s	.next_cod2
	add	#15+6,d5
	bra.s	.do_copy
.empty1:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont_copy
.next_cod2:	moveq	#13,d6
	bsr.s	get_bit2_2
	add	#255+15+6,d5
.do_copy:	move	d5,-(a7)
	bne.s	bigger2
	lea	decrun_table2_2(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2_2
	cmp	#5,d5
	blt.s	contus2
	addq	#2,a7
	subq	#6,d5
	bgt.s	tablus_2
	move.l	a5,a4
	blt.s	.first4
	addq	#4,a4
.first4:	moveq	#1,d6
	bsr.s	get_bit2_2
tablus2_2:	move.b	0(a4,d5.w),-(a5)
	bra.s	make_jnk2
get_bit2_2:	clr	d5
.get_bits:	add.b	d7,d7
	beq.s	.empty
.cont:	addx	d5,d5
	dbf	d6,.get_bits
	tst	d5
	rts
.empty:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	.cont
bigger2:	lea	decrun_table_2(pc),a4
	moveq	#2,d6
	bsr.s	get_bit2_2
contus2:	move	d5,d4
	move.b	14(a4,d4.w),d6
	ext	d6
	bsr.s	get_bit2_2
	add	d4,d4
	beq.s	.first
	add	-2(a4,d4.w),d5
.first:	lea	1(a5,d5.w),a4
	move	(a7)+,d5
	move.b	-(a4),-(a5)
.copy_same:	move.b	-(a4),-(a5)
	dbf	d5,.copy_same
make_jnk2:	moveq	#11,d6
	moveq	#11,d5
take_jnk2:	add.b	d7,d7
	beq.s	empty2
cont_jnk2:	dbcc	d6,take_jnk2
	bcs.s	next_cod2
	sub	d6,d5
	bra.s	copy_jnk1_2
next_cod2:	moveq	#7,d6
	bsr.s	get_bit2_2
	beq.s	.next_cod1
	addq	#8,d5
	addq	#3,d5
	bra.s	copy_jnk1_2
.next_cod1:	moveq	#2,d6
	bsr.s	get_bit2_2
	swap	d5
	moveq	#15,d6
	bsr.s	get_bit2_2
	addq.l	#8,d5
	addq.l	#3,d5	
copy_jnk1_2:	subq	#1,d5
	bmi.s	.end_word
	moveq	#1,d6
	swap	d6
.copy_jnk:	move.b	-(a6),-(a5)
	dbf	d5,.copy_jnk
	sub.l	d6,d5
	bpl.s	.copy_jnk
.end_word:	cmp.l	a6,a0
.decrunch:	bne	decrunch2
	cmp.b	#$80,d7
	bne.s	.decrunch
 	rts
empty2:	move.b	-(a6),d7
	addx.b	d7,d7
	bra.s	cont_jnk2
decrun_table_2:
	dc.w	32,32+64,32+64+256,32+64+256+512,32+64+256+512+1024
	dc.w	32+64+256+512+1024+2048,32+64+256+512+1024+2048+4096
	dc.b	4,5,7,8,9,10,11,12
decrun_table2_2:
	dc.w	32,32+64,32+64+128,32+64+128+256
	dc.w	32+64+128+256+512,32+64+128+256+512*2
	dc.w	32+64+128+256+512*3
	dc.b	4,5,6,7,8,8
tablus_table2:	dc.b	$60,$20,$10,$8
hello_txt2:	dc.b	$1b,$59,$20,$25,"ATOMIK v3.3 by ALTAIR VMAX/MCS"
packed_code2:
offset:	dc.w	0
lenght:	dc.w	0
save_size:	dc.l	0
	dc.w	0
save_lenght:	dc.l	0
save_rez:	dc.w	0
mode:	dc.w	0
end_file:	dc.l	0
tablus_table3:	dc.b	$8,$10,$20,$60
present:	dc.b	$1b,"E                          ****************************",$a,$d
	dc.b	"                          *ATOMIK CRUNCHER3 BY ALTAIR*",$a,$d
	dc.b	"                          *v3.3 Comleted on 15/4/1991*",$a,$d
	dc.b	"                          ****************************",$a,$a,$d,0
ask_mode:	dc.b	"                          1: CRUNCH EXECUTABLE |173 %",$A,$D
	dc.b	"                          2: CRUNCH DATA FILE. |ERROR",$A,$D
	dc.b	"                          3: CRUNCH ALL FILES. |FREE!",$A,$A,$D 
	dc.b	"                          4: CRUNCH PARAMETERS |VMAX",$A,$D
	dc.b	"                          5: EXIT FROM ATOMIK. |&MCS",$A,$A,$D,0
params_txt:	dc.b	"                          1: EXTENDS FOR PARAMETERS",$A,$D
	dc.b	"                          2: SET PICTURE PARAMETERS",$A,$A,$D
	dc.b	"                          3: CLEAR ALL PARAMETERS",$A,$D
	dc.b	"                          4: EXIT FROM PARAMETERS",$A,$A,$D,0
ask_pic_num:	dc.b	"                          ENTER PICTURE NUMBER: ",0
ask_offset:	dc.b	$D,"                          ENTER OFFSET N."
clear_right:	dc.b	$1b,"K",0
params_err:	dc.b	"                          PICTURE PARAMETERS N.",0
params_err2:	dc.b	" BAD",$A,$D
	dc.b	"                          OFFSET + 7D00 > FILE LENGHT",0 
ask_offset2:	dc.b	": ",0
coding_txt:	dc.b	$D,"                          ENCODING PICTURE N.",0
ask_clr_txt:	dc.b	"                          CLEAR PARAMETERS? (Y/N) ",0
cleared_txt:	dc.b	$D,"                          PARAMETERS CLEARED!",$1b,"K",0
multi_txt:	dc.b	"                          1: CRUNCH *.* IN DATA MODE",$A,$D
	dc.b	"                          2: CRUNCH *.* IN EXEC MODE",$A,$A,$D
	dc.b	"                          3: SET DIR TO BE CRUNCHED",$A,$D
	dc.b	"                          4: EXIT FROM MULTI CRUNCH",$A,$A,$D,0
disk_empty:	dc.b	$D,"                          HEY! DISK EMPTY!",$1b,"K",0
multi_cr_end:	dc.b	$D,"                          OK ",0
multi_cr_end1:	dc.b	" FILE(S) PACKED",$1b,"K",$A,0
multi_cr_end2:	dc.b	$D,"                          IN ",0
multi_cr_end3:	dc.b	" FILE(S) LOADED",$1b,"K",0
extends_txt:	dc.b	"extends for use.",$A,$A,$D
	dc.b	"for best crunch of picture i use a special bits planes algorythm",$a,$d
	dc.b	"but i cannot detect picture very well without make many analyse",$a,$d
	dc.b	"and test and it's better if you give me the exact offset of the",$a,$d
	dc.b	"first word of the picture from the top of the file",$a,$a,$d
	dc.b	"CAUTION !",$a,$a,$d
	dc.b	"the offset you give me must be the offset of the first plane",$a,$d
	dc.b	"of the picture and not the first word of the picture file.",$a,$a,$d
	dc.b	"exemple:",$a,$a,$d
	dc.b	"for a degelite picture format you must give me the offset of",$a,$d
	dc.b	"the picture file increased of $22 (i just encode $7d00 bytes",$a,$d
	dc.b	"the exact lenght of a screen picture.)",$a,$a,$d
	dc.b	"CAUTION!: offset in Hex,picture number in Dec.",0
out_memory:	dc.b	$1b,"Eout of memory!",0
larger_txt:	dc.b	$d,"                          SORRY CANNOT CRUNCH..",$1b,"K",$a,$d,$1b,"K",0
crunching:	dc.b	"                          CRUNCHING  : ",0
to_crunch:	dc.b	$d,"                          CRUNCH LEFT: ",0
ever_pack:	dc.b	$a,$d,"                          CRUNCH DONE: ",0 
crunch_leng:	dc.b	$a,$d,$1b,"K",$a,"                          SAVE LENGHT:  ",0
ok_saved_txt:	dc.b	$a,$a,$d,"                          FILE: ",0
ok_saved2:	dc.b	" SAVED",$1b,"K",0
write_error:	dc.b	$d,"                          WRITE ERROR! RETRY (Y/N)",$1b,"K",0
exec_time:	dc.b	$d,"                          CRUNCHING TIME:    ",$1b,"K",0
ask_save:	dc.b	$a,$a,$d,"                          SAVE PACK FILE? (Y/N)",$1b,"K",0
interupt:	dc.b	$d,"                              INTERUPTION? (Y/N)",$1b,"K",$A,$D,$1b,"K",$1b,"I",0
analys_txt:	dc.b	$a,$a,$d,"                          ANALYSING",$1b,"K",$d,0
skip_2lines:	dc.b	$a
skip_line:	dc.b	$a,$d,0
up_2lines:	dc.b	$1b,"I"
up_line:	dc.b	$1b,"I",0
back_spaces:	dcb.b	9,8
	rept	8
	dc.b	8,32,8
	endr
back_space:	dc.b	8,32,8,0
bip_code:	dc.b	7,0
prg_extend:	dc.b	"*.PRG",0
stars_extend:	dc.b	"*.*",0
	even
params:	dc.l	ctrl0,ctrl1,ctrl2,ctrl3,ctrl4,ctrl5
ctrl0:	dc.w	$5a,0,2,2
ctrl1:	dc.w	$120,1
ctrl2:	dc.w	0
ctrl3:	dc.w	1,0,0
ctrl4:	dc.l	adr0,adr1
ctrl5:	dc.w	0
adr0:	ds.b	65+14
adr1:	ds.b	65	
filename:	ds.b	65
	even
dta_buffer:	ds.b	30
filename2:	ds.b	14
rw_error:	dc.w	0
handle:	dc.w	0
lenght_read:	dc.l	0	
save_4ba:	dc.l	0
save2_4ba:	dc.l	0
org_lenght:	dc.l	0
crh_lenght:	dc.l	0
next_adress:	dc.l	0
time_saver:	ds.b	8
save_extend:	dc.l	0
offset_saver:	dcb.l	50
pic_number:	dc.b	0
pic_flag:	dc.b	0
multi_flag:	dc.b	0
quit_flag:	dc.b	0
larger_flag:	dc.w	0
file_number:	dc.w	0
crunch_number:	dc.w	0
save_colors:	dcb.l	16,0
String_buffer:	dc.b	" "
value_buffer:	ds.b	8
	dc.b	$1b,$71,0
	BSS
	ds.l	70
mark_table:	dcb.l	$4000,0
decrun_space:	ds.w	35
decrun_space2:	ds.w	284
pack_adr:	ds.l	$1000
load_adress:
