;
; escape for 'quick' exit, extra life every 100000
;
*-------- sprite data structure layout --------*

status	equ	0	.w
x1	equ	2	.w
y1	equ	4	.w
born_cnt	equ	6	.w
born_flag	equ	8	.w
rest_cnt	equ	10	.w
die_cnt	equ	12	.w
die_flag	equ	14	.w
spr_ptr1	equ	16	.l
spr_ptr2	equ	20	.l
spr_num	equ	24	.w
spr_move_mode	equ	26	.w
spr_die_flag	equ	28	.w
spr_x_move_val	equ	30	.w
spr_y_move_val	equ	32	.w
spr_move_flag	equ	34	.w
spr_anim_val	equ	36	.w
spr_move_dir	equ	38	.w
skew_store	equ	40	.w
mask_op	equ	42	.b
sprite_op	equ	43	.b
;
; software sprite data
;
spr_rout_flag	equ	44	.w	; 0=blitter/-1=software
spr_skew_tab	equ	46	.l	; valute to multiply skew val (0-15)
spr_store_addr	equ	50	.l	; store background rout address
spr_rest_addr	equ	54	.l	; restore background rout address
spr_draw_addr	equ	58	.l	; sprite draw rout address
spr_gfx_addr	equ	62	.l	; address of actual sprite gfx
spr_anim_tab	equ	66	.l	; size of 1 sprite for animation
;
; wave data
;
spr_sin_tab	equ	70	.l
spr_sin_reset	equ	74	.l
spr_score	equ	78	.w
x_reset	equ	80	.l
y_reset	equ	84	.l
spr_frames	equ	88	.w
die_gfx	equ	90	.l
die_frames	equ	94	.w
die_adjust_x	equ	96	.w
die_adjust_y	equ	98	.w
spr_energy	equ	100	.w
spr_power	equ	102	.w
pickup_type	equ	104	.w
sample_start	equ	106	.l
sample_end	equ	110	.l
hit_flag	equ	114	.w
hit_count	equ	116	.w
spr_x_flag	equ	118	.w
spr_x_cnt	equ	120	.w
spr_y_flag	equ	122	.w
spr_y_cnt	equ	124	.w
spr_mask_flag	equ	126	.w
multi_hit_flag	equ	128	.w
gun_rotate_flag	equ	130	.w
diag_move	equ	132	.w
; 0=create normal bullet
; 1=don't create normal bullet
; 2=gun_die_sprites
; 3=boss weak point * always *
; 4=gun_baddie_sprites1
; 5=gun_baddie_sprites2
; 6=big_baddie_sprites1
; 7=big_baddie_sprites2
; 8=boss_shot_sprites
; 9=walker_sprites1
; 10=walker_sprites2
; 11=rockets
; 12=triffid 1
; 13=triffid 2
; 14=plant 1
; 15=plant 2
; 16=trace diag1
; 17=trace diag2
; 18=homing missile appear
; 19=bounce laser
; 20=boss mouth
; 21=bydo sheild
; 22=bydo sheild
; 23=spin
; 24=duct
; 25/26=v/h crawl
; 27/28=pump
; 29=stage 5 big
; 30=stage 5 protect
spr_type	equ	134	.w
spr_move_cnt	equ	136	.w
spr_anim_cnt	equ	138	.w
move_x_dir	equ	140	.w
move_y_dir	equ	142	.w
pump_mode	equ	144	.w
pump_dir	equ	146	.w
;
; background data
;
old_depth1	equ	148	.w
old_depth2	equ	150	.w

old_width1	equ	152	.w
old_height1	equ	154	.w
old_width2	equ	156	.w
old_height2	equ	158	.w
scrn_ptr1	equ	160	.l
scrn_ptr2	equ	164	.l
back_ptr1	equ	168	.l
back_ptr2	equ	172	.l
cls_offset1	equ	176	.l
cls_offset2	equ	180	.l

old_spr_rout1	equ	184	.w
old_spr_rout2	equ	186	.w

sprite_size	equ	188	.b	; structure size

*-------- tile data structure layout --------*

tile_num	equ	0	.w
tile_flag	equ	2	.w
tile_x1	equ	4	.w
tile_y1	equ	6	.w
tile_x2	equ	8	.w
tile_y2	equ	10	.w

tile_size	equ	12	.b	; structure size

*-------- animated tile data structure layout --------*

anim_tile_stat	equ	0	.w's	; status
anim_tile_x	equ	2
anim_tile_y	equ	4
anim_tile_num	equ	6	; current frame (pre mul?)
anim_tile_max	equ	8	; max frame num (pre mul?)
anim_tile_cnt1	equ	10	; frame counter
anim_tile_cnt2	equ	12	; frame counter reset
anim_tile_anim	equ	14	; type of animation

anim_tile_gfx	equ	16	; image pointer
anim_tile_img	equ	20	; image size

anim_tile_y_inc	equ	24	; scrn_width-(8*tile_width)
anim_tile_x_cnt	equ	26	; scrn_width-(4*tile_width)+1
anim_tile_y_cnt	equ	28	; tile height

anim_tile_type	equ	30	; tile type (0=normal/-1=boss weak)

anim_tile_die	equ	32

anim_tile_size	equ	34	; structure size

*-------- other equates --------*

num_anim_tiles	equ	8
num_beams	equ	32	; 5 on screen*(1 player+4 max beam) thus 5*5
num_baddies	equ	40
num_big_baddies	equ	5
num_pickup	equ	2
num_bullets	equ	40	;12+8
num_stars	equ	30	; stars at beginning of level 1
powerup_wait	equ	8	; vbl's before 'powerup' is displayed
lv1_boss_wait	equ	(50*30)/2	; time to take on boss before it 'attacks'
lv2_boss_wait	equ	(50*30)/2+(50*2)	; time to take on boss before it 'attacks'
lv3_boss_wait	equ	(50*30)/2+(50*4)	; time to take on boss before it 'attacks'
lv4_boss_wait	equ	(50*30)/2+(50*4)	; time to take on boss before it 'attacks'
lv5_boss_wait	equ	(50*30)/2+(50*10)	; time to take on boss before it 'attacks'
lv6_boss_wait	equ	(50*30)/2+(50*4)	; time to take on boss before it 'attacks'
lv7_boss_wait	equ	((50*30)/2+(50*4))*2	; time to take on boss before it 'attacks'
lv8_boss_wait	equ	(50*40)	; time to take on boss before it 'attacks'
fps	equ	1	; game screen update (0=50,1=25,2=12.5 etc)
max_stages	equ	8
final	equ	0	; 0=devpac/1=final version

;	org	$30000+200000	; use in final version

	opt	x+,o+,w-

game_start	bra.s	clear_bss

	dc.l	game_info
level_point	dc.l	level_data

clear_bss	tst.w	game_init_flag
	bne.s	.skip_it0
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	lea	bss_start,a0
	lea	bss_end,a1
.l1	
x	set	0
	rept	10
	movem.l	d0-d7/a2-a6,x(a0)
x	set	x+(4*13)
	endr
	lea	(4*13)*10(a0),a0
	cmp.l	a1,a0
	ble.s	.l1
.skip_it0

	ifeq	final
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	endc

	move.l	a7,old_stack
	lea	stack,a7

	movem.l	$fffff8240.w,d0-d7
	movem.l	d0-d7,oldpal
	move.l	$fffff8200.w,oldphys
	move.b	$fffff8260.w,oldrez
	move.b	$fffff820a.w,oldhz
	movem.l	blank,d0-d7
	movem.l	d0-d7,$fffff8240.w

	move.l	screen2,d0
	add.l	#(376*64)+(8*3),d0
	move.b	d0,d1
	lsr.l	#8,d0
	move.b	d0,$fffff8203.w
	lsr.w	#8,d0
	move.b	d0,$fffff8201.w
	move.b	d1,$fffff820d.w
	clr.b	$fffff8260.w
	move.b	#2,$fffff820a.w

	moveq	#$12,d0
	jsr	ikbd
	moveq	#$14,d0	; turn on joystick
	jsr	ikbd
	jsr	flush
	jsr	silence

	jsr	initialise_level_data
	tst.w	game_init_flag
	bne.s	.skip_it1
	jsr	make_star_tab
	jsr	pre_shift_sprites
	sf	intro_done	; start intro bit
.skip_it1
	clr.w	restart_point
	
	ifeq	final
	move.w	#3,num_credits
	endc

	jsr	set_volume

	jsr	install_ints

	move.w	#-1,cheat_flag

;	move.w	#-1,demo_mode

	cmp.w	#1,stage
	beq.s	ids
	st	intro_done
ids

	ifeq	final
	move.w	#3,set_lives
	endc

	move.l	$466.w,seed

	move.l	hi_score_table,hi_score

	tst.w	game_init_flag
	bne.s	continue_stage
	move.w	set_lives,lives

continue_stage	st	fade_flag

	move.l	hi_score_table,hi_score

	jsr	vsync

	move.w	stage,d0
	subq.w	#1,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	stage1_score,a0
	add.w	d0,a0
	move.l	a0,stage_score_pos
	clr.l	(a0)

	tst.w	demo_mode
	beq.s	.demo_lives
	move.w	#3,lives
.demo_lives



	clr.w	hi_score_flag
	sf	continue_flag

	jsr	vsync
	move.b	#191-2,timer_line
	move.l	#status_tb,timer_rout
	clr.b	set_rez

	ifeq	final
	move.l	stage_score_pos,a0
	move.l	#95000,(a0)
	move.l	#95000,total_score
	endc

stage_start	cmp.w	#0,lives
	ble	forced_title

;	clr.w	$fffff8900.w		; stop dma

	cmp.w	#2,tune_num
	bne.s	.no_deselect
	jsr	stop_music
	
.no_deselect	cmp.w	#1,tune_num
	beq.s	.no_reinit
	move.w	#1,tune_num
	jsr	init_music
.no_reinit

	bsr	copy_coords
	jsr	init_structures
	jsr	init_stage
	jsr	init_baddies

	jsr	init_old_stars

	sf	player_dead	; were alive!


	jsr	vsync
	sf	line_flag
	move.b	#92+(8*2),$fffff820f.w	820f
	move.b	#191-2,timer_line
	move.l	#status_tb,timer_rout
	clr.b	set_rez
	clr.w	player_1_cnt
	clr.w	player_1_ind

	jsr	init_screens
	sf	draw_score_flag

;	move.w	#-1,fade_cnt
;	move.w	#3,fade_speed
;	jsr	fade_in_status	; fade in status
	st	music_flag	; turn on music

	move.w	#-1,fade_cnt
	move.w	#3,fade_speed
	move.w	#1-1,fade_rout	; fade in playfield
	move.l	#pal,pal_pos	
	sf	fade_flag

	move.w	#fps,vbl_count

; the intro is now done within the main game loop
; a flag is set to turn certain routine off and some on!

	tst.b	intro_done
	bne.s	.set_init
	move.w	#1,boost_struct+status
	move.w	#-64,player_struct+x1

.set_init	move.w	#-1,game_init_flag

loop	clr.w	motor_cnt
	jsr	restore_background
	jsr	restore_stage_fx

	bsr	draw_tiles
	jsr	draw_anim_tiles
	jsr	draw_duct
	jsr	do_pump_boss

	jsr	store_background
	jsr	store_stage_fx

	bsr	draw_player_sprite
	jsr	draw_player_sprites
	jsr	do_explosion
	jsr	do_baddies
	jsr	do_baddies_bullets
	jsr	draw_stage_fx

	bsr	draw_player_mask

*** enemy/enemy bullets must be drawn here!

; do pixel perfect collision detection here
;	bsr	pixel_detect
;	move.w	#$0,$fffff8240.w

;	lea	player_struct,a0
;	bsr	draw_sprite


	jsr	do_level_4_boss
	jsr	draw_demo_mode

	jsr	extra_life_check

	jsr	sync
	jsr	swap_screens
	jsr	offset_screen


	jsr	do_counters

	bsr	player_anim

	bsr	move_force

	jsr	copy_baddie_waves
	jsr	do_baby
	jsr	copy_anim_tile_waves

	jsr	beam_and_baddies	* coll detect
	jsr	beam_and_bullet
	jsr	move_beam
	bsr	do_joystick

	tst.w	demo_mode
	beq.s	.bod
	clr.b	joy1_status
.bod


;	tst.w	demo_mode
;	beq	.no_demo
;
;	tst.b	intro_done
;	beq.s	.no_demo
; 
;	cmp.b	#$1f,kbuff
;	beq	exit_end
;
;	move.l	demo_buff_pos,a0
;	move.b	joy1_status,(a0)+
;	move.l	a0,demo_buff_pos
;
;
;.no_demo

	jsr	check_baddie_hits

	jsr	chain_reaction

	jsr	read_intro_table

	jsr	scroll_screen
	bsr	update_map_coords

	jsr	search_4_baddie
	jsr	generate_bullet
	jsr	move_baddies
	jsr	move_bullets
	jsr	move_pickup
	jsr	move_anim_tiles
	jsr	sprite_coll_detect

	bsr	copy_map_coords
	jsr	map_coll_detect
	jsr	move_stage_fx

	jsr	do_animation

	jsr	do_keys

	jsr	flush

	tst.b	player_dead	; have we died?
	beq.s	.no_player_die
	jmp	player_die
.no_player_die
	tst.b	stage_clear_flag
	bne	next_stage

	tst.b	map_end_flag
	bne	next_stage

	tst.b	cheat_key_flag
	bne	cheat_load_end_part

	bra	loop

exit_end	jsr	restore_ints
;	jsr	stop_music

	move.w	#1,tune_num
	jsr	stop_music

	clr.w	$fffff8900.w		; stop dma

	jsr	silence

	moveq	#$8,d0
	jsr	ikbd
	moveq	#$16,d0
	jsr	ikbd
	jsr	flush

	jsr	vsync
	movem.l	blank,d0-d7
	movem.l	d0-d7,$fffff8240.w

	clr.b	$fffff820f.w
	clr.b	$fffff8265.w		; no line offset
	move.l	oldphys,$fffff8200.w
	move.b	oldrez,$fffff8260.w
	move.b	oldhz,$fffff820a.w

	movem.l	oldpal,d0-d7
	movem.l	d0-d7,$fffff8240.w

	move.l	old_stack,a7
;	bsr	save_data

exit2	
	ifeq	final
	clr.w	-(sp)
	trap	#1
	else
	illegal
	endc

;save_data	tst.w	demo_mode
;	beq	.no_demo
;
;	move.l	#demo_buff,d0
;	move.l	demo_buff_pos,d1
;	sub.l	d1,d0
;	tst.l	d0
;	bpl.s	.s1
;	neg.l	d0
;.s1
;	move.l	d0,flen
;
;	clr.w	-(sp)
;	pea	fname
;	move.w	#$3c,-(sp)
;	trap	#1
;	addq.w	#8,sp
;	move.w	d0,handle
;
;	pea	demo_buff
;	move.l	flen,-(sp)
;	move.w	handle,-(sp)
;	move.w	#$40,-(sp)
;	trap	#1
;	add.l	#12,sp
;
;	move.w	handle,-(sp)
;	move.w	#$3e,-(sp)
;	trap	#1
;	addq.w	#4,sp
;
;.no_demo	rts

;handle	dc.w	0
;flen	dc.l	0
;fname	dc.b	"demomode.tab",0
;	even

;forced_end	move.w	#2,error_flag
;	bra.s	exit_end

forced_title	clr.w	error_flag
	move.w	#1,level_load

;	cmp.l	#pal_end,pal_pos
;	bgt.s	.s1
;	move.w	#-1,fade_cnt
;	move.w	#3,fade_speed
;	bsr	fade_out_status
;.s1
	bra	exit_end

boss_score	dc.w	0

next_stage
; defeated boss score
	moveq	#0,d0
	move.w	boss_score,d0
	add.l	d0,total_score
	move.l	stage_score_pos,a0
	add.l	d0,(a0)

	move.w	#-1,fade_cnt
	move.w	#3,fade_speed

	jsr	fade_out_play_area

	jsr	vsync
	st	draw_score_flag
	move.b	#191-2,timer_line
	move.l	#status_tb,timer_rout
	clr.b	set_rez
	st	line_flag
	jsr	vsync
	clr.b	$fffff8265.w
	clr.b	$fffff820f.w

	jsr	clearscreen

	move.w	stage,d0
	lea	stage_num,a0
	add.w	d0,a0
	move.b	(a0),comp_stage_score

	lea	stage_comp_text,a0
	move.l	screen1,a3
	lea	((160*8)*7)(a3),a3
	jsr	print

	jsr	vsync
	move.l	screen1,d0
	jsr	set_screen

	move.l	#cont_pal,pal_pos
	move.w	#-1,fade_cnt
	move.w	#2,fade_speed
	move.w	#3-1,fade_rout
	sf	fade_flag

	clr.w	$fffff8900.w		; stop dma
	move.l	#count_sfx+12,d0
	move.b	d0,$fffff8907.w
	lsr.w	#8,d0
	move.l	d0,$fffff8902.w
	move.l	#count_sfx_end,d0
	move.b	d0,$fffff8913.w
	lsr.w	#8,d0
	move.l	d0,$fffff890e.w
	move.w	#%0000000010000001,$fffff8920.w	; freq
	move.w	#%0000000000000011,$fffff8900.w	; start dma (looping)

	bsr	count_score

	clr.w	$fffff8900.w		; stop dma

	move.w	#((50*1)*5)-1,d0
	jsr	pause

	move.l	#cont_pal_end,pal_pos
	move.w	#-1,fade_cnt
	move.w	#2,fade_speed
	move.w	#4-1,fade_rout
	sf	fade_flag

	moveq	#(50*1)-1,d0
	jsr	pause

	jsr	stop_music

	lea	player_struct,a0
	move.w	#1,status(a0)	; invincible
	move.w	#48,x1(a0)
	move.w	#89,y1(a0)
	move.w	#50*2,born_cnt(a0)
	clr.w	born_flag(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)
	clr.w	die_flag(a0)
	move.l	#player_sprites,spr_ptr1(a0)
	move.w	#3-1,spr_num(a0)

	move.w	#2,level_load

***** cheat on/off
	tst.w	cheat_flag
	bpl	.no_cheat
	;tst.w	demo_mode
	;bmi	.no_cheat

	jsr	vsync
	st	fade_flag
	jsr	vsync
	movem.l	blank,d0-d7
	movem.l	d0-d7,palbuff

	move.l	screen1,d0
	jsr	set_screen

	move.l	#cheat_text,prop_text_pos
	jsr	clearscreen

	jsr	vsync
	move.l	prop_text_pos,a0
	move.l	screen1,a3
	lea	(160*8)*12(a3),a3
	jsr	prop_text
	jsr	vsync
	move.l	#$00000057,palbuff
	move.l	#$07770577,palbuff+4
.level_select	moveq	#0,d0
	move.b	kbuff,d0
	cmp.b	#$02,d0
	blt.s	.level_select
	cmp.b	#$09,d0
	bgt.s	.level_select
	sub.b	#$02,d0
	addq.b	#1,d0
	move.w	stage,d1
	move.w	d0,stage

	cmp.w	d0,d1
	bne.s	.not_1
	move.w	#2,player_struct+status	; cheat on - no invinc flash
	clr.w	restart_point
	jsr	set_up_pointers

	jsr	vsync

	movem.l	blank,d0-d7
	movem.l	d0-d7,palbuff

	jsr	vsync
	jsr	clearscreen

	jmp	continue_stage
.not_1
	move.w	#2,player_struct+status	; cheat on - no invinc flash
	clr.w	restart_point

	jsr	vsync

	movem.l	blank,d0-d7
	movem.l	d0-d7,palbuff

	jsr	vsync
	jsr	clearscreen
	bra	.skip
.no_cheat
	addq.w	#1,stage
.skip
***** 

	move.w	stage,d0
	subq.w	#1,d0
	cmp.w	#max_stages,d0
	blt.s	.no_end
	move.w	#max_stages,stage
	jsr	do_game_report
	move.w	#1,stage
	move.w	#1,level_load
	clr.w	game_init_flag
	clr.w	lives
	clr.w	num_credits

	move.w	#3,error_flag	; end of game screen
.no_end	bra	exit_end

count_score	move.l	stage_score_pos,a0
	jsr	hex_dec

	moveq	#0,d2
	lea	dec_buff,a0
	moveq	#6-1-1,d0
.l0	move.w	(a0)+,d1
	cmp.w	#0,d1
	bne.s	.s0
	addq.w	#1,d2
	dbf	d0,.l0
.s0
	moveq	#6-1,d0
	sub.w	d2,d0
	move.w	d0,count_loop
	move.w	d0,count_loop2
	add.w	d2,d2
	move.w	d2,num_offset

	move.l	#$000a000a,count_buff
	move.l	#$000a000a,count_buff+4
	move.l	#$000a000a,count_buff+8


.l1	jsr	vsync
	jsr	vsync
	bsr	draw_counted_score
	bsr	do_count

	lea	dec_buff,a0
	lea	count_buff,a1
	add.w	num_offset,a0
	add.w	num_offset,a1

	move.w	count_loop,d2
.l3	tst.w	d2
	bmi.s	.s1
	move.w	(a0)+,d0
	move.w	(a1)+,d1
	cmp.w	d0,d1
	bne.s	.l1
	dbf	d2,.l3
.s1

	rts

do_count	;cmp.l	#0,score
	;ble	.s2

	lea	dec_buff,a0
	lea	count_buff,a1
	add.w	num_offset,a0
	add.w	num_offset,a1
	moveq	#0,d2
	move.w	count_loop,d2
.l1
	sub.w	#$01,(a1)
	cmp.w	#$00,(a1)
	bge.s	.s1
	move.w	#$0a,(a1)
.s1
	addq.w	#2,a0
	addq.w	#2,a1
	dbf	d2,.l1

	subq.w	#2,a0
	subq.w	#2,a1

	move.w	(a0),d0
	move.w	(a1),d1

	cmp.w	d0,d1
	bne.s	.s2

	subq.w	#1,count_loop
	tst.w	count_loop
	bmi.s	.s2

	lea	count_buff,a0
	add.w	num_offset,a0	

	moveq	#0,d0
	move.w	count_loop,d0
.l2	move.w	#$000a,(a0)+
	dbf	d0,.l2

.s2

	rts

draw_counted_score
	move.w	#7,.mod+2

	move.l	screen1,a2
	lea	((160*8)*10)+(8*11)+1(a2),a2

	cmp.w	#6-1,count_loop2
	bge.s	.s0

	moveq	#6-1-1,d0
	sub.w	count_loop2,d0
	move.l	#$00010007,d1

	move.w	d0,d2
	and.w	#2-1,d2
	tst.w	d2
	bne.s	.l0
	move.w	#1,.mod+2

.l0	add.w	d1,a2
	swap	d1
	dbf	d0,.l0
.s0

	lea	count_buff,a0
	add.w	num_offset,a0

	moveq	#0,d0
	move.w	count_loop,d0
	sf	.flag	; 0

	moveq	#0,d7
	move.w	count_loop,d7
.l1	move.w	(a0)+,d0
	subq.w	#1,d0

;
; check no zeros appear before score.
; i.e. 176500 instead of 0176500
;
	tst.b	.flag
	bne.s	.s1

	cmp.w	#0,d0	; is this digit > 0?
	bgt.s	.s1
	lea	font+(16*16),a1	; if yes print one '0'

	cmp.w	#0,d7	; have we gone through whole score
	bgt.s	.s2	; and reached the last digit?
	lea	font+(16*16),a1	; if yes print one '0'
	bra.s	.s2

.s1	st	.flag	; switch off '0' checking (d2=-1)

	lsl.w	#4,d0
	lea	font+(16*16),a1
	add.w	d0,a1
.s2
	movem.w	(a1)+,d0-d6
	movep.w	d0,(a2)
	movep.w	d1,160*1(a2)
	movep.w	d2,160*2(a2)
	movep.w	d3,160*3(a2)
	movep.w	d4,160*4(a2)
	movep.w	d5,160*5(a2)
	movep.w	d6,160*6(a2)

	opt	o-
.mod	add.w	#1,a2
	opt	o+
	eor.w	#6,.mod+2
	dbf	d7,.l1
	rts

.flag	dc.b	0
	even


cheat_load_end_part
	move.w	#3,error_flag

	st	escape_flag
	move.w	#-1,fade_cnt
	move.w	#3,fade_speed
	move.w	#2-1,fade_rout	; fade out playfield
	sf	fade_flag
	jsr	fade_out_play_area

;	move.w	#-1,fade_cnt
;	move.w	#3,fade_speed
;	jsr	fade_out_status

	move.w	#1,stage
	move.w	#1,level_load
	clr.w	game_init_flag
	bra	exit_end

check_attach_detach_force
	tst.w	demo_mode
	bne.s	.e1

	lea	force_struct,a0	; force active?
	cmp.w	#0,status(a0)
	ble.s	.e1

	cmp.b	#$39,kbuff
	beq.s	.n1

; don't think this is the best way of doing this but hey it works!
	tst.b	release_flag
	beq.s	.r2

.r1	cmp.b	#$39,kbuff
	bne.s	.n2
.r2
	bsr.s	do_attach_detach

.e1	rts

.n1	st	space_pressed_flag
	st	release_flag
	bra.s	.r1

.n2	st	space_released_flag
	sf	attach_sfx_flag
	bra.s	.r2


do_attach_detach

	tst.b	space_pressed_flag
	beq	.e1
	tst.b	space_released_flag
	beq	.e1
	tst.b	attached_flag
	beq	.s2

	tst.b	attach_sfx_flag
	bne.s	.n1
	move.l	#attach_sfx+12,d5
	move.l	#attach_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx
.n1
	st	attach_sfx_flag

; detach force

	move.w	#4,spr_move_mode(a0)
	sf	detach_flag
	sf	attached_flag
	sf	attach_sfx_flag

	lea	player_struct,a1

	tst.b	force_front_rear_flag
	beq.s	.s1
	move.w	x1(a1),d0
	add.w	#32,d0
	move.w	d0,x1(a0)
.s1
	move.w	y1(a1),y1(a0)

; center force vertically with r9
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d3	; get sprite
	lsl.w	#5,d3
	add.w	d3,a2

	move.w	12(a2),d3	; get force height
	sub.w	#14,d3	; sub r9 height
	tst.w	d3
	bpl.s	.bod_skip1
	neg.w	d3
.bod_skip1	lsr.w	#2,d3	; divide by 2
	sub.w	d3,y1(a0)

;	cmp.l	#force_low_sprites,spr_ptr1(a0)
;	beq	.bod_skip1
;	subq.w	#2,y1(a0)
;.bod_skip1
	sf	space_pressed_flag
	sf	space_released_flag
	sf	release_flag

	tst.b	force_front_rear_flag
	bne.s	.s3
	subq.w	#2,force_struct+x1
.s3
	bra.s	.e1
.s2

; attach force

	move.w	#3,spr_move_mode(a0)

	sf	space_pressed_flag
	sf	space_released_flag
	sf	release_flag

.e1	rts

force_table	ds.b	6*12

move_force	tst.b	intro_done
	beq.s	.return

	tst.b	attached_flag
	bne.s	.return

	lea	force_struct,a0
	cmp.w	#0,status(a0)
	beq.s	.return

	clr.b	force_bit
	move.w	spr_move_mode(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.lookup(pc,d0.w),a1
	jmp	(a1)

;	cmp.b	#0,force_table+2+4+1
;	bne.s	.s1
;	bsr	check_force_x
;.s1
;	rts

.lookup	dc.l	.return
	dc.l	move_force_appear
	dc.l	move_force_search
	dc.l	attach_force
	dc.l	detach_force

.return	rts

check_force_x	lea	force_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1
	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.return2
	st	force_start_x_flag
	rts

.table2	dc.l	.return
	dc.l	.detect

.detect
	;tst.b	force_start_x_flag
	;bmi	.n1

	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt.s	.n1
	cmp.w	d5,d3	;y1
	blt.s	.n1

	cmp.w	d6,d0	;x2
	bgt.s	.n1
	cmp.w	a4,d1	;y2
	bgt.s	.n1

	tst.b	attached_flag
	bne.s	.n3

;	tst.b	force_x_correct_flag
;	bne.s	.n2

	move.w	d4,x1(a0)

	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d1
	lsl.w	#5,d1
	add.w	d1,a2
	move.w	8(a2),d1
	sub.w	d1,x1(a0)
	subq.w	#1,x1(a0)

;	sub.w	#3+1,x1(a0)
	sf	force_x_flag
;	st	force_hit

.n3

	move.w	#-1,pop_flag1

.n1
	rts

attach_force	
	
	lea	player_struct,a0
	lea	force_struct,a1
	bsr.s	attach_force_x

	lea	player_struct,a0
	lea	force_struct,a1
	bsr	attach_force_y

	bsr	plr_and_force_rear
	bsr	plr_and_force_front
	rts

attach_force_x	move.w	x1(a0),d0
	move.w	x1(a1),d1

	cmp.w	d1,d0
	beq.s	.s3

	move.w	d1,d2
	subq.w	#3,d1
	addq.w	#3,d2


	cmp.w	d1,d0
	blt.s	.s1
	cmp.w	d2,d0
	bgt.s	.s1
	move.w	x1(a0),x1(a1)
	bra.s	.s3
.s1
	st	attach_x_flag
	sub.w	d1,d0
	tst.w	d0
	bpl.s	.s2
	sf	attach_x_flag
	
	subq.w	#4,x1(a1)
	bset	#1,force_bit
	bra.s	.s3
.s2	addq.w	#4,x1(a1)
	bset	#0,force_bit
.s3

	lea	force_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active	clr.w	pop_flag1

	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height
	move.w	8(a1),force_width_store

	move.l	map_buff_pos,a1
	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect
	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt.s	.n1
	cmp.w	d5,d3	;y1
	blt.s	.n1

	cmp.w	d6,d0	;x2
	bgt.s	.n1
	cmp.w	a4,d1	;y2
	bgt.s	.n1

	tst.b	attach_x_flag
	beq.s	.n2

;	btst.b	#0,force_bit
;	beq	.n3

	sub.w	force_width_store,d4
	subq.w	#4,d4
	move.w	d4,x1(a0)
	bra.s	.n3
.n2
;	btst.b	#1,force_bit
;	beq	.n3

	move.w	d6,x1(a0)
	subq.w	#4,x1(A0)

.n3	move.w	#-1,pop_flag1

.n1
	rts


attach_force_y	move.w	y1(a0),d0
	move.w	y1(a1),d1
	cmp.w	d1,d0
	beq	.s3

	move.w	d1,d2
	subq.w	#2,d1
	addq.w	#2,d2

	move.l	spr_ptr1(a1),a2
	addq.w	#6,a2
	move.w	spr_num(a1),d3	; get sprite
	lsl.w	#5,d3
	add.w	d3,a2

	move.w	12(a2),d3	; get height
	lsr.w	#1,d3	; divide by 2
	sub.w	d3,d1
	add.w	d3,d2


	cmp.w	d1,d0
	blt.s	.s1
	cmp.w	d2,d0
	bgt.s	.s1
	move.w	y1(a0),y1(a1)

; center force vertically with r9
	move.l	spr_ptr1(a1),a2
	addq.w	#6,a2
	move.w	spr_num(a1),d3	; get sprite
	lsl.w	#5,d3
	add.w	d3,a2

	move.w	12(a2),d3	; get force height
	sub.w	#14,d3	; sub r9 height
	lsr.w	#1,d3	; divide by 2
	tst.w	d3
	bpl.s	.bod_skip1
	neg.w	d3
.bod_skip1	sub.w	d3,y1(a1)
	bset	#3,force_bit

	bra.s	.s3

.s1
	st	attach_y_flag
	sub.w	d1,d0
	tst.w	d0
	bpl.s	.s2
	sf	attach_y_flag
	subq.w	#4,y1(a1)
	bset	#3,force_bit
	bra.s	.s3
.s2	addq.w	#4,y1(a1)
	bset	#2,force_bit
.s3
	lea	force_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height
	move.w	12(a1),force_height_store

	move.l	map_buff_pos,a1
	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect
	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt.s	.n1
	cmp.w	d5,d3	;y1
	blt.s	.n1

	cmp.w	d6,d0	;x2
	bgt.s	.n1
	cmp.w	a4,d1	;y2
	bgt.s	.n1

	tst.b	attach_y_flag
	beq.s	.n2

	btst.b	#2,force_table+2+2+1
;	btst.b	#2,force_bit
	beq	.n3

	sub.w	force_height_store,d5
	subq.w	#4,d5
	move.w	d5,y1(a0)
	bra.s	.n3
.n2
;	btst.b	#3,force_bit
;	beq	.n3

	move.w	a4,y1(a0)
	subq.w	#4,y1(A0)

.n3	move.w	#-1,pop_flag1

.n1
	rts

detach_force
	sf	force_start_x_flag

; detach force routine
;	sf	force_hit

	tst.b	force_front_rear_flag
	beq	detach_rear

	cmp.w	#3,force_power
	bne.s	.j1
	move.l	#force_high_sprites2,force_struct+spr_ptr1
.j1
;	st	force_x_correct_flag

	tst.b	detach_flag
	bmi	.jump1

	add.w	#12,x1(a0)
	bset	#0,force_bit
	bclr	#1,force_bit
	
	move.w	x1(a0),d0

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d1
	lsl.w	#5,d1
	add.w	d1,a1

	move.w	#319-1,d1
	sub.w	8(a1),d1

	cmp.w	d1,d0
	blt.s	.s1
	move.w	d1,x1(a0)
	st	detach_flag

;	move.w	#2,spr_move_mode(a0)
;	st	force_x_flag

;	set	0
;	rept	12
;	move.w	x1(a0),force_table+x
;	move.w	y1(a0),force_table+2+x
;	clr.w	force_table+4+x
;x	set	x+6
;	endr


.s1	sf	attached_flag
	sf	attach_sfx_flag


	lea	force_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jsr	(a1)

	bsr	plr_and_force_rear
	bsr	plr_and_force_front
	rts

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.jump1	subq.w	#3,x1(a0)
	bset	#1,force_bit
	bclr	#0,force_bit
	
	cmp.w	#319-64-32,x1(a0)
	bgt	.skip1
	move.w	#319-64-32,x1(a0)

	move.w	#2,spr_move_mode(a0)
	st	force_x_flag

x	set	0
	rept	12
	move.w	x1(a0),force_table+x
	move.w	y1(a0),force_table+2+x
	clr.w	force_table+4+x
x	set	x+6
	endr

.skip1

	bra	.s1


.active	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height
	move.w	8(a1),force_width_store

	move.l	map_buff_pos,a1
	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect
	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt	.n1
	cmp.w	d5,d3	;y1
	blt	.n1

	cmp.w	d6,d0	;x2
	bgt	.n1
	cmp.w	a4,d1	;y2
	bgt	.n1

	btst.b	#0,force_bit
	beq	.check_rear

	st	force_x_flag
	;st	force_hit
	sub.w	force_width_store,d4
	subq.w	#6,d4
	move.w	d4,x1(a0)
	move.w	#2,spr_move_mode(a0)

x	set	0
	rept	12
	move.w	x1(a0),force_table+x
	move.w	y1(a0),force_table+2+x
	clr.w	force_table+4+x
x	set	x+6
	endr
	move.w	#-1,pop_flag1
	bra	.n1

.check_rear	btst.b	#1,force_bit
	beq	.n1

	sf	force_x_flag
	move.w	d6,x1(a0)
	subq.w	#4,x1(A0)
	move.w	#2,spr_move_mode(a0)

x	set	0
	rept	12
	move.w	x1(a0),force_table+x
	move.w	y1(a0),force_table+2+x
	clr.w	force_table+4+x
x	set	x+6
	endr


	move.w	#-1,pop_flag1

.n1
	rts


detach_rear	
	cmp.w	#3,force_power
	bne.s	.j1
	move.l	#force_high_sprites3,force_struct+spr_ptr1
.j1

;	sf	force_x_correct_flag

	tst.b	detach_flag
	bmi	.jump1

	bset	#1,force_bit
	bclr	#0,force_bit
	sub.w	#12,x1(a0)
	cmp.w	#0,x1(a0)	; -25
	bgt	.s1
	clr.w	x1(a0)	; -25
	st	detach_flag
;	move.w	#2,spr_move_mode(a0)
;	sf	force_x_flag

;x	set	0
;	rept	12
;	move.w	x1(a0),force_table+x
;	move.w	y1(a0),force_table+2+x
;	clr.w	force_table+4+x
;x	set	x+6
;	endr

.s1
	sf	attached_flag
	sf	attach_sfx_flag

	lea	force_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jsr	(a1)
	bsr	plr_and_force_rear
	bsr	plr_and_force_front
	rts

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.jump1	addq.w	#3,x1(a0)
	bset	#0,force_bit
	bclr	#1,force_bit
	
	cmp.w	#64+32,x1(a0)
	blt	.skip1
	move.w	#64+32,x1(a0)

	move.w	#2,spr_move_mode(a0)
	st	force_x_flag

x	set	0
	rept	12
	move.w	x1(a0),force_table+x
	move.w	y1(a0),force_table+2+x
	clr.w	force_table+4+x
x	set	x+6
	endr

.skip1	bra	.s1

.active	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1
	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect
	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt	.n1
	cmp.w	d5,d3	;y1
	blt	.n1

	cmp.w	d6,d0	;x2
	bgt	.n1
	cmp.w	a4,d1	;y2
	bgt	.n1

	btst.b	#1,force_bit
	beq	.check_rear


	sf	force_x_flag
	move.w	d6,x1(a0)
	subq.w	#4,x1(A0)
	move.w	#2,spr_move_mode(a0)

x	set	0
	rept	12
	move.w	x1(a0),force_table+x
	move.w	y1(a0),force_table+2+x
	clr.w	force_table+4+x
x	set	x+6
	endr



	move.w	#-1,pop_flag1
	bra	.n1

.check_rear	btst.b	#0,force_bit
	beq	.n1

	st	force_x_flag
	;st	force_hit
	sub.w	force_width_store,d4
	subq.w	#6,d4
	move.w	d4,x1(a0)
	move.w	#2,spr_move_mode(a0)

x	set	0
	rept	12
	move.w	x1(a0),force_table+x
	move.w	y1(a0),force_table+2+x
	clr.w	force_table+4+x
x	set	x+6
	endr

	move.w	#-1,pop_flag1

.n1
	rts


move_force_appear
	bset	#0,force_bit


	addq.w	#2,x1(a0)
	cmp.w	#20*3,x1(a0)
	blt	.s1
	move.w	#20*3,x1(a0)

;	move.w	#2,spr_move_mode(a0)

;x	set	0
;	rept	12
;	move.w	x1(a0),force_table+x
;	move.w	y1(a0),force_table+2+x
;	clr.w	force_table+4+x
;x	set	x+6
;	endr

.s1
	bsr	plr_and_force_rear
	bsr	plr_and_force_front
	rts

move_force_search
	bra	.n2

	cmp.w	#3,force_power
	bne.s	.j1
	move.l	#force_high_sprites1,force_struct+spr_ptr1
;	clr.w	force_struct+spr_num
.j1
x	set	0
	rept	12
	subq.w	#1,force_table+x
x	set	x+6
	endr
	subq.w	#1,force_struct+x1
;	cmp.w	#0,force_struct+x1
;	bgt.s	.s1
;	clr.w	force_struct+x1
;.s1

	move.w	x1(a0),d0
	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d1
	lsl.w	#5,d1
	add.w	d1,a1

	move.w	8(a1),d1
	neg.w	d1
;	addq.w	#2,d1
;	sub.w	#15,d1
;	sf	force_start_x_flag

	cmp.w	d1,d0
	bgt.s	.s1

	move.w	d1,x1(a0)
	move.w	#96,y1(a0)

	move.w	#1,spr_move_mode(a0)	; appear again!
	bra	.return
;	sf	force_x_correct_flag
.s1
	
	bsr	move_force_x
	bsr	move_force_y

	lea	force_table+6,a1
	lea	-6(a1),a2
	rept	11
	move.l	(a1)+,(a2)+
	move.w	(a1)+,(a2)+
	endr

	moveq	#0,d0
	move.b	force_bit,d0
	move.w	d0,force_table+(6*11)+4

; keep force onscreen

	cmp.w	#0,y1(a0)
	bgt.s	.n1
	clr.w	y1(a0)
.n1
	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d0
	lsl.w	#5,d0
	add.w	d0,a1

	move.w	#192-1,d0
	sub.w	12(a1),d0
	move.w	y1(a0),d1
	cmp.w	d0,d1
	blt.s	.n2
	move.w	d0,y1(a0)
.n2
	
	
	clr.w	pop_flag1
	bsr.s	plr_and_force_rear

	tst.w	pop_flag1
	bne.s	.return
	bsr	plr_and_force_front
.return	rts

plr_and_force_rear
	lea	player_struct,a0
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	sub.w	#16,d2

	add.w	12(a1),d3	; height

	lea	force_struct,a1
	move.w	x1(a1),d4
	move.w	y1(a1),d5
	move.l	spr_ptr1(a1),a2
	addq.w	#6,a2
	move.w	spr_num(a1),d6
	lsl.w	#5,d6
	add.w	d6,a2

	move.w	d4,d6
	move.w	d5,d7

	add.w	8(a2),d6	; width in pixels
	add.w	12(a2),d7	; height

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	d7,d1
	bgt.s	.s1
	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

;	cmp.w	#0,rest_cnt(a0)	; wait for 2 backgrounds to be stored
;	bgt.s	.s1

	st	attached_flag
	sf	force_front_rear_flag

	tst.b	attach_sfx_flag
	bne.s	.s4
	tst.w	die_flag(a0)
	bne.s	.s4

	move.l	#attach_sfx+12,d5
	move.l	#attach_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx
.s4
	st	attach_sfx_flag

	move.w	#-1,pop_flag1

.s1	rts

plr_and_force_front
	lea	player_struct,a0
	move.w	x1(a0),d0
	move.w	y1(a0),d1
	add.w	#16,d0

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	sub.w	#16,d2

	add.w	12(a1),d3	; height

	lea	force_struct,a1
	move.w	x1(a1),d4
	move.w	y1(a1),d5
	move.l	spr_ptr1(a1),a2
	addq.w	#6,a2
	move.w	spr_num(a1),d6
	lsl.w	#5,d6
	add.w	d6,a2

	move.w	d4,d6
	move.w	d5,d7

	add.w	8(a2),d6	; width in pixels
	add.w	12(a2),d7	; height

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	d7,d1
	bgt.s	.s1
	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

;	cmp.w	#0,rest_cnt(a0)	; wait for 2 backgrounds to be stored
;	bgt.s	.s1

	st	attached_flag
	st	force_front_rear_flag

	tst.b	attach_sfx_flag
	bne.s	.s4
	tst.w	die_flag(a0)
	bne.s	.s4
	move.l	#attach_sfx+12,d5
	move.l	#attach_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx
.s4
	st	attach_sfx_flag

.s1	rts

move_force_x
;	tst.b	force_hit
;	beq.s	.bod
;	subq.w	#1,x1(a0)
;.bod

	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; height

	lea	player_struct,a1
	move.w	x1(a1),d4
	move.w	y1(a1),d5
	move.l	spr_ptr1(a1),a3
	addq.w	#6,a3
	move.w	spr_num(a1),d2
	lsl.w	#5,d2
	add.w	d2,a3

	move.w	d4,d6
	move.w	d5,d7

	add.w	8(a3),d6	; width in pixels
	add.w	12(a3),d7	; height

	sub.w	#80,d4
	sub.w	#80,d5

	add.w	#80,d6
	add.w	#80,d7
	sub.w	8(a2),d6	; width in pixels
	sub.w	12(a2),d7	; height

	cmp.w	d4,d2	;x1
	blt	.s4
	cmp.w	d5,d3	;y1
	blt	.s4

	cmp.w	d6,d0	;x2
	bgt	.s4
	cmp.w	a4,d1	;y2
	bgt	.s4

	tst.b	force_x_flag
	beq	.s1

	subq.w	#3,x1(a0)
	bset	#1,force_bit

	move.w	x1(a0),d0
	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d1
	lsl.w	#5,d1
	add.w	d1,a1

	move.w	8(a1),d1
	neg.w	d1
	subq.w	#2,d1
;	sub.w	#15,d1
	sf	force_start_x_flag

	cmp.w	d1,d0
	bgt.s	.s2

	move.w	d1,x1(a0)
	move.w	#96,y1(a0)

	move.w	#1,spr_move_mode(a0)	; appear again!

;	sf	force_x_correct_flag
.s2
	move.w	x1(a0),d0
;	move.w	player_struct+x1,d1
;	add.w	#64+32,d1
;	cmp.w	d0,d1
;	bgt	.s4

	move.w	player_struct+x1,d1
	subq.w	#3,d0
	cmp.w	d0,d1
	blt	.s4
	addq.w	#6,d0
	cmp.w	d0,d1
	bgt	.s4

	move.w	d1,x1(a0)
	bra.s	.s4
.s1
	addq.w	#3,x1(a0)
	bset	#0,force_bit
	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d0
	lsl.w	#5,d0
	add.w	d0,a1
	move.w	x1(a0),d0
	move.w	#320-1,d1
	sub.w	8(a1),d1
	sf	force_start_x_flag
	cmp.w	d1,d0
	blt.s	.s3

	move.w	d1,x1(a0)
;	st	force_x_correct_flag
.s3

	move.w	x1(a0),d0
;	move.w	player_struct+x1,d1
;	sub.w	#64,d1
;	cmp.w	d0,d1
;	blt.s	.s4

	move.w	player_struct+x1,d1
	subq.w	#3,d0
	cmp.w	d0,d1
	blt.s	.s4
	addq.w	#6,d0
	cmp.w	d0,d1
	bgt.s	.s4
	move.w	d1,x1(a0)

.s4

	lea	force_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active
	bsr	check_x_first
	bsr	check_x_last
.return	rts

check_x_first	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1
	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
;	tst.w	pop_flag1
;	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.return2
	st	force_start_x_flag
	rts

.table2	dc.l	.return
	dc.l	.detect

.detect
	;tst.b	force_start_x_flag
	;bmi	.n1

	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt	.n1
	cmp.w	d5,d3	;y1
	blt.s	.n1

	cmp.w	d6,d0	;x2
	bgt.s	.n1
	cmp.w	a4,d1	;y2
	bgt.s	.n1

	tst.b	attached_flag
	bne.s	.n3

;	tst.b	force_x_correct_flag
;	bne.s	.n2

	btst.b	#1,force_table+2+2+1
;	btst.b	#1,force_bit
	beq	.n2


	move.w	d6,x1(a0)
	addq.w	#1,x1(a0)

	bsr	.copy_coords1

;	add.w	#3+1,x1(a0)
	st	force_x_flag
;	st	force_hit
	addq.l	#4,sp
	bra	check_x_first
;	bra	.s4
.n2
	btst.b	#0,force_table+2+2+1
;	btst.b	#0,force_bit
	beq	.n3

	move.w	d4,x1(a0)
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d1
	lsl.w	#5,d1
	add.w	d1,a2
	move.w	8(a2),d1
	sub.w	d1,x1(a0)
	subq.w	#2,x1(a0)


	bsr	.copy_coords1
;	sub.w	#3+1,x1(a0)

	sf	force_x_flag
;	st	force_hit

	addq.l	#4,sp
	bra	check_x_first
;	bra	.s4
.n3

	move.w	#-1,pop_flag1

.n1
	rts

.copy_coords1
x	set	0
	rept	12
	move.w	x1(a0),force_table+x
;	bset	#0,force_table+4
;	bclr	#1,force_table+4
x	set	x+6
	endr
	rts

.copy_coords2
x	set	0
	rept	12
	move.w	x1(a0),force_table+x
;	bset	#1,force_table+4
;	bclr	#0,force_table+4
x	set	x+6
	endr
	rts

check_x_last	clr.w	pop_flag1
	move.w	force_table+(6*11),d0
	move.w	force_table+(6*11)+2,d1
;	move.w	x1(a0),d0
;	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1
	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
;	tst.w	pop_flag1
;	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.return2
	st	force_start_x_flag
	rts

.table2	dc.l	.return
	dc.l	.detect

.detect
	;tst.b	force_start_x_flag
	;bmi	.n1

	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt.s	.n1
	cmp.w	d5,d3	;y1
	blt.s	.n1

	cmp.w	d6,d0	;x2
	bgt.s	.n1
	cmp.w	a4,d1	;y2
	bgt.s	.n1

	tst.b	attached_flag
	bne.s	.n3

;	tst.b	force_x_correct_flag
;	bne.s	.n2

	btst.b	#1,force_table+(6*11)+2+2+1
;	btst.b	#1,force_bit
	beq	.n2
	bclr.b	#1,force_table+(6*11)+2+2+1

;	move.w	d6,force_table+(6*11)
;	addq.w	#1,force_table+(6*11)

;	move.w	d6,x1(a0)
;	addq.w	#1,x1(a0)

;	bsr	.copy_coords1

	add.w	#2,force_table+(6*11)
;	st	force_x_flag
;	st	force_hit
	addq.l	#4,sp
	bra	check_x_last
;	bra	.s4
.n2
	btst.b	#0,force_table+(6*11)+2+2+1
;	btst.b	#0,force_bit
	beq	.n3
	bclr.b	#0,force_table+(6*11)+2+2+1

;	move.w	d4,x1(a0)
;	move.l	spr_ptr1(a0),a2
;	addq.w	#6,a2
;	move.w	spr_num(a0),d1
;	lsl.w	#5,d1
;	add.w	d1,a2
;	move.w	8(a2),d1
;	sub.w	d1,x1(a0)
;	subq.w	#2,x1(a0)

;	sub.w	d1,force_table+(6*11)
;	subq.w	#2,force_table+(6*11)

	sub.w	#2+1,force_table+(6*11)
;	bsr	.copy_coords2
;	sub.w	#3+1,x1(a0)

;	sf	force_x_flag
;	st	force_hit

	addq.l	#4,sp
	bra	check_x_last
.n3

	move.w	#-1,pop_flag1

.n1
	rts

.copy_coords1
x	set	0
	rept	12
	move.w	x1(a0),force_table+x
	bset	#0,force_table+4
	bclr	#1,force_table+4
x	set	x+6
	endr
	rts

.copy_coords2
x	set	0
	rept	12
	move.w	x1(a0),force_table+x
	bset	#1,force_table+4
	bclr	#0,force_table+4
x	set	x+6
	endr
	rts


move_force_y
;	tst.b	force_y_flag
;	bne.s	.s1

	move.w	player_struct+y1,force_table+(6*11)+2
;	subq.w	#2,force_table+(6*11)+2
	move.w	force_table+2,y1(a0)
;	subq.w	#2,y1(a0)
	bset	#3,force_bit
	sf	force_start_y_flag
	cmp.w	#0,y1(a0)
	bgt.s	.s2
	clr.w	y1(a0)
;	sf	force_y_correct_flag
.s2
	move.w	y1(a0),d0
	move.w	player_struct+y1,d1
	subq.w	#3,d0
	cmp.w	d0,d1
	blt	.s4
	addq.w	#6,d0
	cmp.w	d0,d1
	bgt	.s4

	cmp.w	#2,force_power
	bne.s	.j1
	subq.w	#3,d1
	bra.s	.j2
.j1	cmp.w	#3,force_power
	bne.s	.j2
	subq.w	#6,d1
	cmp.l	#force_high_sprites3,spr_ptr1(a0)
	bne.s	.j2
	subq.w	#3,d1
.j2

	move.w	d1,y1(a0)
;	bra.s	.s4
.s1
;	addq.w	#2,force_table+(6*11)+2
;	move.w	force_table+2,y1(a0)
;	addq.w	#2,y1(a0)
;	bset	#2,force_bit
;	move.l	spr_ptr1(a0),a2
;	addq.w	#6,a2
;	move.w	spr_num(a0),d0
;	lsl.w	#5,d0
;	add.w	d0,a2
;	move.w	y1(a0),d0
;	move.w	#200-8,d1

;	sub.w	8(a2),d1
;	sf	force_start_y_flag
;	cmp.w	d1,d0
;	blt.s	.s3
;	move.w	d1,y1(a0)
;	st	force_y_correct_flag
;.s3

;	move.w	y1(a0),d0
;	move.w	player_struct+y1,d1

;	subq.w	#3,d0
;	cmp.w	d0,d1
;	blt.s	.s4
;	addq.w	#6,d0
;	cmp.w	d0,d1
;	bgt.s	.s4

;	cmp.w	#2,force_power
;	bne.s	.j3
;	subq.w	#3,d1
;	bra.s	.j4
;.j3	cmp.w	#3,force_power
;	bne.s	.j4
;	subq.w	#6,d1
;	cmp.l	#force_high_sprites3,spr_ptr1(a0)
;	bne.s	.j4
;	subq.w	#3,d1
;.j4
;
;	move.w	d1,y1(a0)
.s4

	lea	force_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active
	bsr	check_y_first
	bsr	check_y_last
.return	rts

check_y_first	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1
	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
;	tst.w	pop_flag1
;	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.return2	st	force_start_y_flag
	rts

.table2	dc.l	.return
	dc.l	.detect

.detect	;tst.b	force_start_y_flag
	;bmi	.n1

	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt.s	.n1
	cmp.w	d5,d3	;y1
	blt.s	.n1

	cmp.w	d6,d0	;x2
	bgt.s	.n1
	cmp.w	a4,d1	;y2
	bgt.s	.n1

;	tst.b	force_y_correct_flag
;	bne.s	.n2

	btst.b	#3,force_table+2+2+1
;	btst.b	#3,force_bit
	beq	.n2
	move.w	a4,y1(a0)
	addq.w	#1,y1(a0)


;	add.w	#3+1,y1(a0)
	st	force_y_flag
	bsr	.copy_coords1

	addq.l	#4,sp
	bra	check_y_first
;	bra	.s4
;	bra	.n3
.n2
	btst.b	#2,force_table+2+2+1
;	btst.b	#2,force_bit
	beq	.n3

	move.w	d5,y1(a0)
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d1
	lsl.w	#5,d1
	add.w	d1,a2
	move.w	12(a2),d1
	sub.w	d1,y1(a0)
	subq.w	#2,y1(a0)


;	sub.w	#3+1,y1(a0)

	sf	force_y_flag
	bsr	.copy_coords1
	addq.l	#4,sp
	bra	check_y_first
;	bra	.s4

.n3
	move.w	#-1,pop_flag1

.n1	rts

.copy_coords1
x	set	0
	rept	12
	move.w	y1(a0),force_table+2+x
;	bset	#2,force_table+4+x
;	bclr	#3,force_table+4+x
x	set	x+6
	endr
	rts

.copy_coords2
x	set	0
	rept	12
	move.w	y1(a0),force_table+2+x
;	bset	#3,force_table+4+x
;	bclr	#2,force_table+4+x
x	set	x+6
	endr
	rts

check_y_last	clr.w	pop_flag1
	move.w	force_table+(6*11),d0
	move.w	force_table+(6*11)+2,d1
;	move.w	x1(a0),d0
;	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1
	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
;	tst.w	pop_flag1
;	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.return2	st	force_start_y_flag
	rts

.table2	dc.l	.return
	dc.l	.detect

.detect	;tst.b	force_start_y_flag
	;bmi	.n1

	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt.s	.n1
	cmp.w	d5,d3	;y1
	blt.s	.n1

	cmp.w	d6,d0	;x2
	bgt.s	.n1
	cmp.w	a4,d1	;y2
	bgt.s	.n1

;	tst.b	force_y_correct_flag
;	bne.s	.n2

	btst.b	#3,force_table+(6*11)+2+2+1
;	btst.b	#3,force_bit
	beq	.n2
	bclr.b	#3,force_table+(6*11)+2+2+1
;	move.w	a4,y1(a0)
;	addq.w	#1,y1(a0)

;	move.w	a4,force_table+(6*11)+2
;	addq.w	#1,force_table+(6*11)+2

	add.w	#2,force_table+(6*11)+2
;	st	force_y_flag
;	bsr	.copy_coords1

	addq.l	#4,sp
	bra	check_y_last
;	bra	.s4
;	bra	.n3
.n2
	btst.b	#2,force_table+(6*11)+2+2+1
;	btst.b	#2,force_bit
	beq	.n3
	bclr.b	#2,force_table+(6*11)+2+2+1

;	move.w	d5,y1(a0)
;	move.l	spr_ptr1(a0),a2
;	addq.w	#6,a2
;	move.w	spr_num(a0),d1
;	lsl.w	#5,d1
;	add.w	d1,a2
;	move.w	12(a2),d1
;	sub.w	d1,y1(a0)
;	subq.w	#2,y1(a0)

;	sub.w	d1,force_table+(6*11)+2
;	subq.w	#2,force_table+(6*11)+2

	sub.w	#2,force_table+(6*11)+2
;	sub.w	#3+1,y1(a0)

;	sf	force_y_flag
;	bsr	.copy_coords2
	addq.l	#4,sp
	bra	check_y_last
;	bra	.s4

.n3
	move.w	#-1,pop_flag1

.n1	rts

.copy_coords1
x	set	0
	rept	12
	move.w	y1(a0),force_table+2+x
	bset	#2,force_table+4+x
	bclr	#3,force_table+4+x
x	set	x+6
	endr
	rts

.copy_coords2
x	set	0
	rept	12
	move.w	y1(a0),force_table+2+x
	bset	#3,force_table+4+x
	bclr	#2,force_table+4+x
x	set	x+6
	endr
	rts

draw_player_mask
	lea	player_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.lookup(pc,d0.w),a1
	jmp	(a1)

.lookup	dc.l	.s2
	dc.l	.born_draw
	dc.l	.s2	; draw_mask
	dc.l	.s2

.born_draw
	subq.w	#1,born_cnt(a0)
	tst.w	born_cnt(a0)
	bpl.s	.s1
	move.w	#2,status(a0)
	bra.s	.s2
.s1
	subq.w	#1,born_flag(a0)
	tst.w	born_flag(a0)
	bpl.s	.s2

;	bsr	draw_mask
.s2	rts

draw_player_sprite
	lea	player_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.lookup(pc,d0.w),a1
	jmp	(a1)

.lookup	dc.l	.s1
	dc.l	.born_draw
	dc.l	draw_sprite
	dc.l	.s1

.born_draw
	tst.w	born_flag(a0)
	bpl.s	.s1
	move.w	#2-1,born_flag(a0)

	bsr	draw_sprite
	bra.s	.s2
.s1
	bsr	swap_spr_ptrs
.s2	rts

old_hbl_sr	dc.w	0
screen_addr	dc.l	0
timer_rout	dc.l	status_tb
timer_line	dc.b	191-2
set_rez	dc.b	0
line_width	dc.b	0
fine_offset	dc.b	0
	even

hbl	move.b	fine_offset(pc),$fffff8265.w
	move.b	line_width(pc),$fffff820f.w	8*3
hbl2	move.l	#null_rte,$68.w
null_rte	rte

vbl	move.l	#hbl,$68.w
	tst.b	line_flag
	beq.s	.n1
	move.l	#hbl2,$68.w
.n1	move.w	#$2100,sr
	addq.w	#1,$466+2.w

	clr.b	$fffffa1b.w
	move.l	timer_rout(pc),$120.w
	move.b	timer_line(pc),$fffffa21.w
	move.b	#8,$fffffa1b.w

	move.b	set_rez(pc),$fffff8260.w
	move.b	#2,$fffff820a.w

	move.b	$fffff8205.w,scrn_temp+1
	move.b	$fffff8207.w,scrn_temp+2
	move.b	$fffff8209.w,scrn_temp+3

	movem.l	d0-d7/a0-a6,-(sp)
	movem.l	palbuff,d0-d7
	movem.l	d0-d7,$fffff8240.w

	jsr	do_fade

	jsr	draw_status_stuff
	tst.b	music_flag
	beq.s	.s4
	jsr 	play_music
.s4	
	movem.l	(sp)+,d0-d7/a0-a6

	ifeq	final
	cmp.b	#$62,kbuff
	beq	exit_end
	endc
	rte

status_tb	move.w	#$2700,sr
	bclr	#7,$fffff8a3c.w

	movem.l	d0-d1/a0-a1,-(sp)
	moveq	#0,d0
	lea	$fffffa21.w,a0
	lea	stat_palbuff,a1
	move.b	(a0),d0
.l1	cmp.b	(a0),d0
	beq.s	.l1

	move.b	$fffff8205.w,scrn_count+1
	move.b	$fffff8207.w,scrn_count+2
	move.b	$fffff8209.w,scrn_count+3

	move.l	scrn_count,d0
	sub.l	scrn_temp,d0
	cmp.l	#376*(192-2),d0
	bgt.s	.s1

	move.b	(a0),d0
.l2	cmp.b	(a0),d0
	beq.s	.l2


.s1
	move.b	(a0),d0
.l3	cmp.b	(a0),d0
	beq.s	.l3

	move.b	status_addr+1,$fffff8205.w
	move.b	status_addr+2,$fffff8207.w
	move.b	status_addr+3,$fffff8209.w
	clr.b	$fffff8265.w
	clr.b	$fffff820f.w
;	move.w	#$100,$fffff8240.w

	move.l	(a1)+,$fffff8242.w
	move.l	(a1)+,$fffff8242+(4*1).w
	move.l	(a1)+,$fffff8242+(4*2).w
	move.l	(a1)+,$fffff8242+(4*3).w
	move.w	(a1)+,$fffff8242+(4*4).w

	moveq	#7-1,d1
.l5	move.b	(a0),d0
.l4	cmp.b	(a0),d0
	beq.s	.l4
	dbf	d1,.l5

	move.b	(a0),d0
.l6	cmp.b	(a0),d0
	beq.s	.l6

	clr.b	$fffff820a.w
	dcb.w	17,$4e71
	move.b	#2,$fffff820a.w

	movem.l	(sp)+,d0-d1/a0-a1

	bset	#7,$fffff8a3c.w
	move.w	#$2300,sr
	clr.b	$fffffa1b.w
	move.b	#9,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#lower_tb,$120.w
.tb	rte

lower_tb	
x	set	0
	rept	8
	clr.l	$fffff8240+x.w
x	set	x+4
	endr
	clr.b	$fffffa1b.w
	move.b	#45-8-9,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.ltb2,$120.w
	rte

.ltb2	subq.w	#1,vbl_count
	addq.w	#1,motor_cnt
	clr.b	$fffffa1b.w
	move.b	#-1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.ltb3,$120.w
.ltb3	rte

scrn_count	dc.l	0
scrn_temp	dc.l	0
status_addr	dc.l	0

store_demo_mode

	tst.w	demo_mode
	beq	.e1

	add.w	scroll_skew,d0

	and.w	#-16,d0
	lsr.w	#1,d0

	move.l	screen1,a0
	add.l	#(376*64)+(8*3)+((376*8)*11)+(8*7),a0
	add.w	word_inc,a0
	add.w	d0,a0

	move.w	scroll_offset,d0
	and.w	#16-1,d0
	bne.s	.no_sub
	subq.w	#8,a0
.no_sub

	move.l	a0,demo_store1

	move.l	old_demo_pos1,a1
x	set	0
y	set	0
	rept	7
	movem.l	y(a0),d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,x(a1)
	movem.l	y+(4*12)(a0),d0-d1
	movem.l	d0-d1,x+(4*12)(a1)
x	set	x+(4*14)
y	set	y+376
	endr
.e1	rts


restore_demo_mode

	tst.w	demo_mode
	beq	.e1

	tst.w	demo_mode_rest_cnt
	bpl	.e1

	move.l	old_demo_pos1,a0
	move.l	demo_store1,a1
x	set	0
	rept	7
	movem.l	(a0)+,d0-d7/a2-a5
	movem.l	d0-d7/a2-a5,x(a1)
	movem.l	(a0)+,d0-d1
	movem.l	d0-d1,x+(8*6)(a1)
x	set	x+376
	endr

.e1	rts

draw_demo_mode

	tst.w	demo_mode
	beq	.e1

	subq.w	#1,demo_mode_rest_cnt
	tst.w	demo_mode_rest_cnt
	bpl	.e1
	move.w	#-1,demo_mode_rest_cnt

	moveq	#0,d0
	add.w	scroll_skew,d0

	and.w	#16-1,d0
	add.w	d0,d0
	lea	demo_mode_tab(pc),a0
	add.w	d0,a0
	move.w	(a0),d0

	lea	demo_mode_gfx,a0
	add.l	d0,a0
	
	move.l	demo_store1,a1

	subq.w	#1,demo_mode_cnt
	tst.w	demo_mode_cnt
	bpl.s	.s1
	move.w	#12-1,demo_mode_cnt
	not.w	demo_mode_ind
.s1
	tst.w	demo_mode_ind
	beq	.e1

x	set	0
	rept	7
	movem.l	(a0)+,d0-d7
	and.l	d0,x(a1)
	or.l	d1,x(a1)
	and.l	d0,x+4(a1)

	and.l	d2,x+(8*1)(a1)
	or.l	d3,x+(8*1)(a1)
	and.l	d2,x+(8*1)+4(a1)

	and.l	d4,x+(8*2)(a1)
	or.l	d5,x+(8*2)(a1)
	and.l	d4,x+(8*2)+4(a1)

	and.l	d6,x+(8*3)(a1)
	or.l	d7,x+(8*3)(a1)
	and.l	d6,x+(8*3)+4(a1)

	movem.l	(a0)+,d0-d5

	and.l	d0,x+(8*4)(a1)
	or.l	d1,x+(8*4)(a1)
	and.l	d0,x+(8*4)+4(a1)

	and.l	d2,x+(8*5)(a1)
	or.l	d3,x+(8*5)(a1)
	and.l	d2,x+(8*5)+4(a1)

	and.l	d4,x+(8*6)(a1)
	or.l	d5,x+(8*6)(a1)
	and.l	d4,x+(8*6)+4(a1)

x	set	x+376
	endr

.e1	move.l	demo_store1,d0
	move.l	demo_store2,demo_store1
	move.l	d0,demo_store2

	move.l	old_demo_pos1,d0
	move.l	old_demo_pos2,old_demo_pos1
	move.l	d0,old_demo_pos2
	rts

demo_mode_tab
x	set	0
	rept	16
	dc.w	x
x	set	x+((8*7)*7)
	endr

demo_store1	dc.l	0
demo_store2	dc.l	0
demo_mode_rest_cnt
	dc.w	0

restore_back
	cmp.w	#3,stage
	bge	.skip_it
	cmp.w	#3,spr_type(a0)
	beq	.return
	cmp.w	#20,spr_type(a0)
	beq	.return
.skip_it

	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jmp	(a1)

.table	dc.l	.return	; dead
	dc.l	.restore	; born
	dc.l	.restore	; alive
	dc.l	.restore	; dying

.return	rts

.restore
	cmp.w	#19,spr_move_mode(a0)
	beq	.skip_it2

	cmp.w	#320+16,x1(a0)
	bge.s	.return
.skip_it2
	cmp.w	#200+16,y1(a0)
	bge.s	.return
	
	subq.w	#1,rest_cnt(a0)
	tst.w	rest_cnt(a0)
	bpl.s	.return
	move.w	#-1,rest_cnt(a0)

	move.l	back_ptr1(a0),a2
	move.l	scrn_ptr1(a0),a3

	tst.w	old_spr_rout1(a0)
	bne	software_restore

	moveq	#-1,d0
	move.l	d0,$fffff8a28.w	; endmasks
	clr.w	$fffff8a2c.w
	clr.b	$fffff8a3d.w	; skew

	move.l	spr_ptr1(a0),a1	; get sprites used
	addq.w	#6,a1	; skip header

	moveq	#0,d0
	move.w	spr_num(a0),d0
	lsl.w	#5,d0
	add.l	d0,a1

	move.w	old_width1(a0),d0	; width
	move.w	d0,d1

; calculate dest y inc
	lsr.w	#1,d0	; divide by 2 - 32/2=16 pixels
	addq.w	#8,d0	; add extra 16 pixels for skew

	sub.w	#376,d0	; deduct linewidth
	tst.w	d0
	bpl.s	.j1
	neg.w	d0	; make positive
.j1
; calculate x cnt
;	lsr.w	#2,d1	; divide by 4 - 32/4=8
;	addq.w	#4+1,d1	; add an extra 4+1=12+1 words to copy
	lsr.w	#4,d1	; divide by 4 - 32/4=8
	addq.w	#1+1,d1	; add an extra 4+1=12+1 words to copy

; 4 bitplane restore?
;	cmp.w	#4-1,14(a1)
;	beq	.4_bit

	move.w	#8,$fffff8a20.w	; src x inc 2
	move.w	d0,$fffff8a22.w	; dest y inc

	move.w	#8,$fffff8a2e.w	; dest x inc 2
	move.w	d0,$fffff8a30.w	; dest y inc

	move.b	#%10,$fffff8a3a.w	; hop
	move.b	#%0011,$fffff8a3b.w	; replace copy

	moveq	#0,d0
	move.w	old_depth1(a0),d0

	move.l	cls_offset1(a0),a4
	add.w	(a4),a2
	add.w	(a4)+,a3

.l1	move.l	a2,$fffff8a24.w	; source address
	move.l	a3,$fffff8a32.w	; dest address
	move.w	d1,$fffff8a36.w	; x cnt+1
	move.w	old_height1(a0),$fffff8a38.w	; y cnt

	move.b	#%10000000,$fffff8a3c.w
	bset	#7,$fffff8a3c.w
	nop
	bne.s	*-8
	add.w	(a4),a2
	add.w	(a4)+,a3
;	addq.w	#2,a2
;	addq.w	#2,a3
	dbf	d0,.l1
	rts

.4_bit
;	moveq	#-1,d0
;	move.l	d0,$fffff8a28.w		; endmasks
;	clr.w	$fffff8a2c.w
;	clr.b	$fffff8a3d.w		; skew

	move.w	#2,$fffff8a20.w		; src x inc
	move.w	d0,$fffff8a22.w		; src y inc
	move.l	a2,$fffff8a24.w		; source address

	move.w	#2,$fffff8a2e.w		; dest x inc
	move.w	d0,$fffff8a30.w		; dest y inc
	move.l	a3,$fffff8a32.w		; dest address

	move.b	#%10,$fffff8a3a.w		; hop
	move.b	#%0011,$fffff8a3b.w		; replace copy

	move.w	d1,$fffff8a36.w	; x cnt
	move.w	d1,$fffff8a38.w	; y cnt

	move.b	#%10000000,$fffff8a3c.w
.l2	bset	#7,$fffff8a3c.w
	nop
	bne.s	.l2
	rts

store_back	cmp.w	#3,stage
	bge	.skip_it
	cmp.w	#3,spr_type(a0)
	beq	.return
	cmp.w	#20,spr_type(a0)
	beq	.return
.skip_it
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jmp	(a1)

.table	dc.l	.return	; dead
	dc.l	.store	; born
	dc.l	.store	; alive
	dc.l	.store	; dying

.return	rts

.store	cmp.w	#320+16,x1(a0)
	bge.s	.return
	cmp.w	#200+16,y1(a0)
	bge.s	.return
	
	moveq	#1,d0
	cmp.w	#1,scroll_cnt
	bne.s	.s0
	moveq	#0,d0
.s0	moveq	#0,d1
	add.w	scroll_skew,d0
	add.w	x1(a0),d0		; get x1
	move.w	y1(a0),d2
	move.w	d0,d1

	move.l	screen1,a2
	lea	(376*64)+(8*3)(a2),a2
	add.w	word_inc,a2
	move.w	scroll_offset,d3
	and.w	#16-1,d3
	bne.s	.no_sub
	subq.w	#8,a2
.no_sub	bsr.s	.do_xy

	move.l	a2,scrn_ptr1(a0)

	moveq	#1,d0
	cmp.w	#1,scroll_cnt
	bne.s	.s0_1
	moveq	#0,d0
.s0_1	moveq	#0,d1
	add.w	scroll_skew,d0
	add.w	x1(a0),d0		; get x1
	move.w	y1(a0),d2
	move.w	d0,d1

	lea	back_scrn+(376*64)+(8*3),a2
	add.w	word_inc,a2
	move.w	scroll_offset,d3
	and.w	#16-1,d3
	bne.s	.no_sub2
	subq.w	#8,a2
.no_sub2	bsr.s	.do_xy
	move.l	a2,back_ptr1(a0)

	move.l	spr_ptr1(a0),a3
	addq.w	#6,a3	; skip header
	moveq	#0,d0
	move.w	spr_num(a0),d0
	lsl.w	#5,d0
	add.l	d0,a3
	move.w	10(a3),old_width1(a0)	; width
	move.w	12(a3),old_height1(a0)	; height

	rts

.do_xy

	tst.w	d0
	bpl.s	.s1

	cmp.w	#19,spr_move_mode(a0)
	bne.s	.bod1

	cmp.w	#-(16*7),d0
	bgt.s	.n1_a
	moveq	#-(16*7),d0
.n1_a	neg.w	d0	; fix negative x coords
	move.w	#16*7,d1
	sub.w	d0,d1
	move.w	d1,d0
	lea	-(8*7)(a2),a2

	bra	.s1
.bod1

	cmp.w	#4,stage
	bne.s	.bod2
	cmp.w	#3,spr_type(a0)
	bne.s	.bod2

	cmp.w	#-(16*6),d0
	bgt.s	.n1_b
	moveq	#-(16*6),d0
.n1_b	neg.w	d0	; fix negative x coords
	move.w	#16*6,d1
	sub.w	d0,d1
	move.w	d1,d0
	lea	-(8*6)(a2),a2

	bra	.s1
.bod2

	cmp.w	#-64,d0
	bgt.s	.n1
	moveq	#-64,d0
.n1	neg.w	d0	; fix negative x coords
	moveq	#64,d1
	sub.w	d0,d1
	move.w	d1,d0
	lea	-(8*4)(a2),a2

.s1	and.w	#16-1,d0
	move.w	d0,skew_store(a0)
	and.w	#-16,d1
	lsr.w	#1,d1

	tst.w	d2
	bpl.s	.s3
	cmp.w	#-64,d2
	bgt.s	.n3
	moveq	#-64,d2
.n3	neg.w	d2

	add.w	d2,d2
	add.w	d2,d2
	sub.l	mul_tab(pc,d2.w),a2
	add.l	d1,a2
	bra.s	.s4
.s3
	add.w	d2,d2
	add.w	d2,d2
	add.l	mul_tab(pc,d2.w),a2
	add.l	d1,a2

.s4	rts

mul_tab
x	set	0
	rept	200+(64*2)
	dc.l	x
x	set	x+376
	endr

draw_sprite	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jmp	(a1)

.table	dc.l	.return	; dead
	dc.l	plot_sprite	; born
	dc.l	plot_sprite	; alive
	dc.l	swap_spr_ptrs	; dying

.return	rts

swap_spr_ptrs2	move.w	old_depth1(a0),d0
	move.w	old_depth2(a0),old_depth1(a0)
	move.w	d0,old_depth2(a0)

	movem.l	old_width1(a0),d0-d5
	exg	d0,d1
	exg	d2,d3
	exg	d4,d5
	movem.l	d0-d5,old_width1(a0)

	rts

plot_sprite	cmp.w	#3,stage
	bge	.skip_it

	cmp.w	#3,spr_type(a0)	; weak
	beq	return_rts
	cmp.w	#20,spr_type(a0)	; mouth
	beq	return_rts
.skip_it

	cmp.w	#19,spr_move_mode(a0)
	beq	.skip_it2
	cmp.w	#320+16,x1(a0)
	bge.s	swap_spr_ptrs2
.skip_it2

	;cmp.w	#-31,y1(a0)
	;ble.s	swap_spr_ptrs2
	cmp.w	#200+16,y1(a0)
	bge.s	swap_spr_ptrs2

	move.w	spr_rout_flag(a0),old_spr_rout1(a0)

	tst.w	spr_rout_flag(a0)
	bne	software_draw

	move.w	skew_store(a0),d0
	moveq	#-1,d1
	moveq	#-1,d2
	lsr.w	d0,d1
	move.w	d1,$fffff8a28.w	; right endmask
	move.w	d2,$fffff8a2a.w	; mid endmask
	not.w	d1
	move.w	d1,$fffff8a2c.w	; left endmask
	move.b	#%01000000,$fffff8a3d.w	; skew
	or.b	d0,$fffff8a3d.w	; skew

	move.l	spr_ptr1(a0),a1	; get sprites used
	addq.w	#6,a1		; skip header

	moveq	#0,d0
	move.w	spr_num(a0),d0	; get correct sprite data block
	lsl.w	#5,d0
	add.l	d0,a1
	move.l	a1,a4
	lea	16(a4),a4
	move.l	a4,cls_offset1(a0)

	move.l	4(a1),a2		; get sprite data

	move.l	scrn_ptr1(a0),a3	; screen address

	move.w	10(a1),d0	; width
	move.w	d0,d1

	lsr.w	#1,d0	; calculate y_inc
	sub.w	#376,d0
	tst.w	d0
	bpl.s	.j1
	neg.w	d0
.j1	
	lsr.w	#4,d1	; calculate draw x_cnt
	addq.w	#1,d1

	move.w	#8,$fffff8a20.w	; src x inc
	move.w	#8,$fffff8a22.w		; src y inc

	move.w	#8,$fffff8a2e.w	; dest x inc
	move.w	d0,$fffff8a30.w	; dest y inc

	move.b	#%10,$fffff8a3a.w	; hop - source only

	move.b	sprite_op(a0),$fffff8a3b.w

;	cmp.b	#%00001101,mask_op(a0)	; source or target
;	bne.s	.s1
;	addq.w	#2,a3
;.s1
	move.w	12(a1),d2
	move.w	d2,old_height1(a0)

	moveq	#0,d0
	move.w	14(a1),d0	; planes used
	move.w	d0,old_depth1(a0)

	add.w	(a4),a2
	add.w	(a4)+,a3
.l1
	move.l	a2,$fffff8a24.w	; source address
	move.l	a3,$fffff8a32.w	; dest address
	move.w	d1,$fffff8a36.w	; x cnt+1
	move.w	d2,$fffff8a38.w	; y cnt

	move.b	#%10000000,$fffff8a3c.w
	bset	#7,$fffff8a3c.w
	nop
	bne.s	*-8

	add.w	(a4),a2
	cmp.b	#%00001101,mask_op(a0)	; source or target
	beq.s	.s2
	add.w	(a4),a3
.s2	addq.w	#2,a4

	dbf	d0,.l1

swap_spr_ptrs	move.w	old_depth1(a0),d0
	move.w	old_depth2(a0),old_depth1(a0)
	move.w	d0,old_depth2(a0)

	move.w	old_spr_rout1(a0),d0
	move.w	old_spr_rout2(a0),old_spr_rout1(a0)
	move.w	d0,old_spr_rout2(a0)

	movem.l	old_width1(a0),d0-d7
	exg	d0,d1
	exg	d2,d3
	exg	d4,d5
	exg	d6,d7
	movem.l	d0-d7,old_width1(a0)

return_rts	rts

software_restore
	move.l	spr_rest_addr(a0),a4
	jmp	(a4)

;a2=source/a3=dest

software_draw	move.l	spr_draw_addr(a0),a4
	jmp	(a4)


draw_stage	lea	map_buff+tile_size,a0

	moveq	#6-1,d7
.l2
	move.l	a3,a2
	moveq	#12-1,d6
.l1
	moveq	#0,d0
	move.w	tile_num(a0),d0
	lsl.w	#8,d0
	lsl.w	#1,d0

	move.l	level_point,a1
	lea	12+2+(4*4)(a1),a1
	move.l	(a1),a1

;	lea	tiles,a1
	add.l	d0,a1

x	set	0
	rept	4
	movem.l	(a1)+,d0-d5/a4-a5
	move.l	d0,x(a2)
	move.l	d1,x+4(a2)
	move.l	d2,x+(376*1)(a2)
	move.l	d3,x+(376*1)+4(a2)
	move.l	d4,x+(376*2)(a2)
	move.l	d5,x+(376*2)+4(a2)
	move.l	a4,x+(376*3)(a2)
	move.l	a5,x+(376*3)+4(a2)
x	set	x+(376*4)
	endr

x	set	(8*1)
	rept	4
	movem.l	(a1)+,d0-d5/a4-a5
	move.l	d0,x(a2)
	move.l	d1,x+4(a2)
	move.l	d2,x+(376*1)(a2)
	move.l	d3,x+(376*1)+4(a2)
	move.l	d4,x+(376*2)(a2)
	move.l	d5,x+(376*2)+4(a2)
	move.l	a4,x+(376*3)(a2)
	move.l	a5,x+(376*3)+4(a2)
x	set	x+(376*4)
	endr

x	set	(8*2)
	rept	4
	movem.l	(a1)+,d0-d5/a4-a5
	move.l	d0,x(a2)
	move.l	d1,x+4(a2)
	move.l	d2,x+(376*1)(a2)
	move.l	d3,x+(376*1)+4(a2)
	move.l	d4,x+(376*2)(a2)
	move.l	d5,x+(376*2)+4(a2)
	move.l	a4,x+(376*3)(a2)
	move.l	a5,x+(376*3)+4(a2)
x	set	x+(376*4)
	endr

x	set	(8*3)
	rept	4
	movem.l	(a1)+,d0-d5/a4-a5
	move.l	d0,x(a2)
	move.l	d1,x+4(a2)
	move.l	d2,x+(376*1)(a2)
	move.l	d3,x+(376*1)+4(a2)
	move.l	d4,x+(376*2)(a2)
	move.l	d5,x+(376*2)+4(a2)
	move.l	a4,x+(376*3)(a2)
	move.l	a5,x+(376*3)+4(a2)
x	set	x+(376*4)
	endr

	lea	((tile_size*7)*2)(a0),a0
	lea	376*16(a2),a2
	dbf	d6,.l1
	lea	-(((tile_size*7)*12)*2)+12(a0),a0
	lea	8*4(a3),a3
	dbf	d7,.l2

	rts

copy_coords	moveq	#0,d1
	lea	map_buff,a0
	move.w	#(2304/16)-1,d0
.l1	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,.l1

	moveq	#0,d0
	move.w	restart_point,d0
	mulu	#tile_size*12,d0

	move.l	level_point,a0
	lea	12+2+4+4(a0),a0
	move.l	(a0),a0
	addq.w	#6,a0
;	lea	map+6,a0
	add.l	d0,a0

	lea	map_buff+tile_size,a1
	moveq	#6-1,d3
.l2
x	set	0
	rept	12
	movem.l	(a0)+,d0-d2
	movem.l	d0-d2,x(a1)
	movem.l	d0-d2,x+(tile_size*7)(a1)
x	set	x+((tile_size*7)*2)
	endr
	lea	tile_size(a1),a1
	dbf	d3,.l2

	move.w	#320-1,d0
	lea	map_buff+tile_size,a0
	moveq	#6-1,d2
.l4	moveq	#12-1,d1
.l3	tst.w	tile_flag(a0)
	beq.s	.s1
	sub.w	d0,tile_x1(a0)
	sub.w	d0,tile_x2(a0)
.s1	lea	(tile_size*7)*2(a0),a0
	dbf	d1,.l3
	lea	-(((tile_size*7)*2)*12)+12(a0),a0
	sub.w	#64,d0
	dbf	d2,.l4
	rts


draw_tiles	move.l	map_buff_pos,a0
	lea	tile_size*6(a0),a0

	move.l	screen1,a2
	lea	(376*64)(a2),a2
	add.w	word_inc,a2
	lea	8*23(a2),a3

	lea	back_scrn+(376*64),a4
	add.w	word_inc,a4
	lea	8*23(a4),a5
	

x	set	0
	rept	12
	moveq	#0,d0
	move.w	tile_num+x(a0),d0
	lsl.w	#8,d0
	lsl.w	#1,d0

	move.l	level_point,a1
	lea	12+2+(4*4)(a1),a1
	move.l	(a1),a1

;	lea	tiles,a1
	add.w	map_add,a1
	add.l	d0,a1

	movem.l	(a1)+,d0-d7
	move.l	d0,(a2)
	move.l	d1,4(a2)
	move.l	d2,(376*1)(a2)
	move.l	d3,(376*1)+4(a2)
	move.l	d4,(376*2)(a2)
	move.l	d5,(376*2)+4(a2)
	move.l	d6,(376*3)(a2)
	move.l	d7,(376*3)+4(a2)

	move.l	d0,(a3)
	move.l	d1,4(a3)
	move.l	d2,(376*1)(a3)
	move.l	d3,(376*1)+4(a3)
	move.l	d4,(376*2)(a3)
	move.l	d5,(376*2)+4(a3)
	move.l	d6,(376*3)(a3)
	move.l	d7,(376*3)+4(a3)

	move.l	d0,(a4)
	move.l	d1,4(a4)
	move.l	d2,(376*1)(a4)
	move.l	d3,(376*1)+4(a4)
	move.l	d4,(376*2)(a4)
	move.l	d5,(376*2)+4(a4)
	move.l	d6,(376*3)(a4)
	move.l	d7,(376*3)+4(a4)

	move.l	d0,(a5)
	move.l	d1,4(a5)
	move.l	d2,(376*1)(a5)
	move.l	d3,(376*1)+4(a5)
	move.l	d4,(376*2)(a5)
	move.l	d5,(376*2)+4(a5)
	move.l	d6,(376*3)(a5)
	move.l	d7,(376*3)+4(a5)

	movem.l	(a1)+,d0-d7
	move.l	d0,(376*4)(a2)
	move.l	d1,(376*4)+4(a2)
	move.l	d2,(376*5)(a2)
	move.l	d3,(376*5)+4(a2)
	move.l	d4,(376*6)(a2)
	move.l	d5,(376*6)+4(a2)
	move.l	d6,(376*7)(a2)
	move.l	d7,(376*7)+4(a2)

	move.l	d0,(376*4)(a3)
	move.l	d1,(376*4)+4(a3)
	move.l	d2,(376*5)(a3)
	move.l	d3,(376*5)+4(a3)
	move.l	d4,(376*6)(a3)
	move.l	d5,(376*6)+4(a3)
	move.l	d6,(376*7)(a3)
	move.l	d7,(376*7)+4(a3)

	move.l	d0,(376*4)(a4)
	move.l	d1,(376*4)+4(a4)
	move.l	d2,(376*5)(a4)
	move.l	d3,(376*5)+4(a4)
	move.l	d4,(376*6)(a4)
	move.l	d5,(376*6)+4(a4)
	move.l	d6,(376*7)(a4)
	move.l	d7,(376*7)+4(a4)

	move.l	d0,(376*4)(a5)
	move.l	d1,(376*4)+4(a5)
	move.l	d2,(376*5)(a5)
	move.l	d3,(376*5)+4(a5)
	move.l	d4,(376*6)(a5)
	move.l	d5,(376*6)+4(a5)
	move.l	d6,(376*7)(a5)
	move.l	d7,(376*7)+4(a5)

	movem.l	(a1)+,d0-d7
	move.l	d0,(376*8)(a2)
	move.l	d1,(376*8)+4(a2)
	move.l	d2,(376*9)(a2)
	move.l	d3,(376*9)+4(a2)
	move.l	d4,(376*10)(a2)
	move.l	d5,(376*10)+4(a2)
	move.l	d6,(376*11)(a2)
	move.l	d7,(376*11)+4(a2)

	move.l	d0,(376*8)(a3)
	move.l	d1,(376*8)+4(a3)
	move.l	d2,(376*9)(a3)
	move.l	d3,(376*9)+4(a3)
	move.l	d4,(376*10)(a3)
	move.l	d5,(376*10)+4(a3)
	move.l	d6,(376*11)(a3)
	move.l	d7,(376*11)+4(a3)

	move.l	d0,(376*8)(a4)
	move.l	d1,(376*8)+4(a4)
	move.l	d2,(376*9)(a4)
	move.l	d3,(376*9)+4(a4)
	move.l	d4,(376*10)(a4)
	move.l	d5,(376*10)+4(a4)
	move.l	d6,(376*11)(a4)
	move.l	d7,(376*11)+4(a4)

	move.l	d0,(376*8)(a5)
	move.l	d1,(376*8)+4(a5)
	move.l	d2,(376*9)(a5)
	move.l	d3,(376*9)+4(a5)
	move.l	d4,(376*10)(a5)
	move.l	d5,(376*10)+4(a5)
	move.l	d6,(376*11)(a5)
	move.l	d7,(376*11)+4(a5)

	movem.l	(a1)+,d0-d7
	move.l	d0,(376*12)(a2)
	move.l	d1,(376*12)+4(a2)
	move.l	d2,(376*13)(a2)
	move.l	d3,(376*13)+4(a2)
	move.l	d4,(376*14)(a2)
	move.l	d5,(376*14)+4(a2)
	move.l	d6,(376*15)(a2)
	move.l	d7,(376*15)+4(a2)

	move.l	d0,(376*12)(a3)
	move.l	d1,(376*12)+4(a3)
	move.l	d2,(376*13)(a3)
	move.l	d3,(376*13)+4(a3)
	move.l	d4,(376*14)(a3)
	move.l	d5,(376*14)+4(a3)
	move.l	d6,(376*15)(a3)
	move.l	d7,(376*15)+4(a3)

	move.l	d0,(376*12)(a4)
	move.l	d1,(376*12)+4(a4)
	move.l	d2,(376*13)(a4)
	move.l	d3,(376*13)+4(a4)
	move.l	d4,(376*14)(a4)
	move.l	d5,(376*14)+4(a4)
	move.l	d6,(376*15)(a4)
	move.l	d7,(376*15)+4(a4)

	move.l	d0,(376*12)(a5)
	move.l	d1,(376*12)+4(a5)
	move.l	d2,(376*13)(a5)
	move.l	d3,(376*13)+4(a5)
	move.l	d4,(376*14)(a5)
	move.l	d5,(376*14)+4(a5)
	move.l	d6,(376*15)(a5)
	move.l	d7,(376*15)+4(a5)

x	set	x+(tile_size*7)*2
	lea	376*16(a2),a2
	lea	376*16(a3),a3
	lea	376*16(a4),a4
	lea	376*16(a5),a5
	endr

	rts

update_map_coords
	move.w	scroll_cnt,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a0
	jmp	(a0)

.tab	dc.l	.update
	dc.l	.return

.update	;cmp.w	#0,scroll_cnt
	;bgt	.e1
	moveq	#1,d1
;	move.l	map_buff_pos,a0
	lea	map_buff,a0
	moveq	#(7*2)-1,d0
.l1
x	set	0
	rept	12
	tst.w	tile_flag+x(a0)
	beq.s	*+10
	sub.w	d1,tile_x1+x(a0)
	sub.w	d1,tile_x2+x(a0)
x	set	x+((tile_size*7)*2)
	endr
	lea	tile_size(a0),a0
	dbf	d0,.l1
.return	rts


copy_map_coords
	move.w	scroll_cnt,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a0
	jmp	(a0)

.tab	dc.l	.update
	dc.l	.return

.return	rts

.update	;cmp.w	#0,scroll_cnt
	;bgt	.s1


	tst.w	map_cnt
	bpl	.s1
	move.w	#4-1,map_cnt
	clr.w	map_add

	move.w	tile_offset,d0

	move.l	restart_pos,a0
	move.l	level_point,a1
	lea	12+2+(4*7)(a1),a1
	move.l	(a1),a1
;	cmp.l	#restart_tab_end,a0
	cmp.l	a1,a0
	blt.s	.j1
	subq.l	#8,restart_pos
	move.l	restart_pos,a0
.j1	move.w	(a0)+,d1
	cmp.w	d1,d0
	bne.s	.j2
	move.w	d1,restart_point
	move.l	(a0)+,restart_baddie_pos
	move.w	(a0)+,restart_x_offset

	addq.l	#8,restart_pos
.j2	addq.w	#1,tile_offset

	add.l	#12*12,map_pos

	move.l	map_pos,a0
	move.l	map_end_pos,a1
	lea	-((tile_size*12)*4)(a1),a1

;	cmp.l	#map_end-((tile_size*12)*4),map_pos
	cmp.l	a1,a0
	blt.s	.s2
;	move.l	#map+6,map_pos
	move.l	map_end_pos,a1
	lea	-(tile_size*12)(a1),a1
	move.l	a1,map_pos
;	move.l	#map_end-(tile_size*12),map_pos

	tst.w	cheat_flag
	beq.s	.s2

	st	map_end_flag

.s2
	add.l	#12,map_buff_pos
	cmp.l	#map_buff+(12*6),map_buff_pos
	blt.s	.s3
	move.l	#map_buff,map_buff_pos
.s3

	move.l	map_pos,a0

	move.l	map_buff_pos,a1
;	lea	12(a1),a1
	
x	set	0
	rept	12/4
	movem.l	(a0)+,d0-d7/a2-a5
	movem.l	d0-d2,x(a1)
	movem.l	d0-d2,x+(12*6)(a1)
	movem.l	d3-d5,x+(((12*7)*2)*1)(a1)
	movem.l	d3-d5,x+(((12*7)*2)*1)+(12*6)(a1)
	movem.l	d6-d7/a2,x+(((12*7)*2)*2)(a1)
	movem.l	d6-d7/a2,x+(((12*7)*2)*2)+(12*6)(a1)
	movem.l	a3-a5,x+(((12*7)*2)*3)(a1)
	movem.l	a3-a5,x+(((12*7)*2)*3)+(12*6)(a1)
x	set	x+(((12*7)*2)*4)
	endr

.s1	rts


do_demo	moveq	#0,d0
	move.b	joy1_status,d0
	btst	#7,d0
	bne	exit_demo

	tst.b	intro_done
	beq	null

	cmp.l	#demo_buff_end-(2*18),demo_buff_pos
	blt.s	.no_fade
	tst.b	demo_fade_flag
	bne.s	.no_fade
	st	demo_fade_flag
	move.w	#-1,fade_cnt
	move.w	#3,fade_speed
	move.w	#2-1,fade_rout	; fade out playfield
	sf	fade_flag
.no_fade

	move.l	demo_buff_pos,a0
	cmp.l	#demo_buff_end,a0
	bge.s	exit_demo

	move.b	(a0)+,joy1_status
	move.l	a0,demo_buff_pos

	bra	do_demo2

exit_demo	addq.l	#4,sp
	move.w	#1,stage
	move.w	#1,level_load
	clr.w	game_init_flag
	clr.w	error_flag
	bra	exit_end

do_joystick	tst.w	demo_mode
	bne	do_demo

	tst.b	intro_done
	beq	null

do_demo2	cmp.w	#3,force_power
	bne.s	.s1
	tst.b	attached_flag
	beq.s	.s1
	move.l	#force_high_sprites1,force_struct+spr_ptr1
;	clr.w	force_struct+spr_num
.s1
	sf	ship_flag	; turn *on* ship restore rout

	tst.b	bounce_flag
	beq	.s2
	move.w	#-1,weapon_cnt

	move.l	d0,-(sp)
	bsr	do_force_beam
	move.l	(sp)+,d0

	subq.w	#1,bounce_coord_cnt
	tst.w	bounce_coord_cnt
	bpl.s	.s3
	move.w	#-1,bounce_coord_cnt
	sf	bounce_flag
	sf	bounce_coord_flag1
	sf	bounce_coord_flag2
	sf	bounce_coord_flag3

.s3

	tst.b	bounce_fx_flag
	beq.s	.j1
	sf	bounce_fx_flag
	move.l	#bounce_sfx+12,d5
	move.l	#bounce_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx
.j1
	moveq	#0,d0
	move.b	joy1_status,d0
	btst	#7,d0
	bne	no_fire

	bra	.bod
.s2

	tst.b	trace_flag
	beq	.skip_1
	move.w	#-1,weapon_cnt

	move.l	d0,-(sp)
	bsr	do_force_beam
	move.l	(sp)+,d0

	subq.w	#1,trace_coord_cnt
	tst.w	trace_coord_cnt
	bpl.s	.s4
	move.w	#-1,trace_coord_cnt
	sf	trace_flag
	sf	trace_coord_flag2
	sf	trace_coord_flag3

.s4
	tst.b	trace_fx_flag
	beq.s	.j2
	sf	trace_fx_flag
	move.l	#trace_sfx+12,d5
	move.l	#trace_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx
.j2
	moveq	#0,d0
	move.b	joy1_status,d0
	btst	#7,d0
	bne	no_fire

	bra	.bod
.skip_1

	sf	fire_hit
	moveq	#0,d0
	move.b	joy1_status,d0
	btst	#7,d0
	bne	no_fire
	st	fire_hit

	move.l	d0,-(sp)
	bsr	generate_beam
	move.l	(sp)+,d0

.bod	lea	power_struct,a0
	move.w	status(a0),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.lookup(pc,d1.w),a1
	jmp	(a1)

.lookup	dc.l	do_joystick2
	dc.l	do_joystick2
	dc.l	.set_die
	dc.l	.die_check

.set_die	move.w	#3,status(a0)
	bra.s	do_joystick2

.die_check	bsr	die_check

do_joystick2	and.w	#16-1,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	player_struct,a0
;	move.l	.jlt(pc,d0.w),a1

	lea	.jlt(pc),a1
	add.w	d0,a1
	cmp.l	#.jlt+(4*15),a1
	bge.s	null

	move.l	(a1),a1
	jmp	(a1)

.jlt	dc.l	null,up,down,null,left,up_left,down_left,null
	dc.l	right,up_right,down_right,null,null,null,null,null

null	rts

left	cmp.w	#3,force_power
	bne.s	.j1
	tst.b	attached_flag
	beq.s	.j1
	move.l	#force_high_sprites3,force_struct+spr_ptr1
;	clr.w	force_struct+spr_num

.j1

	tst.b	force_front_rear_flag
	bne.s	.n0

	sf	force_x_flag
.n0

	tst.b	attached_flag
	beq.s	.n1
	sf	force_dir
.n1
	move.w	plr_speed,d0
	sub.w	d0,x1(a0)
	cmp.w	#0,x1(a0)
	bgt.s	.s1
	add.w	d0,x1(a0)

	cmp.w	#3,force_power
	bne.s	.s1
	move.l	#force_high_sprites1,force_struct+spr_ptr1
;	clr.w	force_struct+spr_num
.s1
	rts

right
	cmp.w	#3,force_power
	bne.s	.j1
	tst.b	attached_flag
	beq.s	.j1
	move.l	#force_high_sprites2,force_struct+spr_ptr1
;	clr.w	force_struct+spr_num
.j1

	tst.b	force_front_rear_flag
	bne.s	.n0
	st	force_x_flag
.n0
	tst.b	attached_flag
	beq.s	.n1
	st	force_dir
.n1
	move.w	plr_speed,d0
	add.w	d0,x1(a0)
	cmp.w	#319-32-16,x1(a0)
	blt.s	.s1
	sub.w	d0,x1(a0)
	cmp.w	#3,force_power
	bne.s	.s1
	move.l	#force_high_sprites1,force_struct+spr_ptr1
;	clr.w	force_struct+spr_num
.s1	rts

up
	tst.b	force_front_rear_flag
	bne.s	.n0
	sf	force_y_flag
.n0
	tst.b	attached_flag
	beq.s	.n1
	sf	force_dir
.n1
	move.w	plr_speed,d0
	sub.w	d0,y1(a0)
	cmp.w	#0,y1(a0)
	bgt.s	.s1
	add.w	d0,y1(a0)
.s1	bsr.s	ship_up
	rts

down
	tst.b	force_front_rear_flag
	bne.s	.n0
	st	force_y_flag
.n0
	tst.b	attached_flag
	beq.s	.n1

	st	force_dir
.n1
	move.w	plr_speed,d0
	add.w	d0,y1(a0)
	cmp.w	#191-14,y1(a0)
	blt.s	.s1
	sub.w	d0,y1(a0)

.s1	bsr.s	ship_down
	rts

up_right	bsr.s	up
	bsr	right
	rts

down_right	bsr.s	down
	bsr	right
	rts

up_left	bsr	up
	bsr	left
	rts

down_left	bsr.s	down
	bsr	left
	rts

;
; animtion of player while moving vertically
;
ship_up	st	ship_flag
	subq.l	#2,plr_gfx_pos
	cmp.l	#plr_gfx_tab,plr_gfx_pos
	bgt.s	.s1
	move.l	#plr_gfx_tab,plr_gfx_pos
.s1	move.l	plr_gfx_pos,a1
	move.w	(a1),spr_num(a0)
	rts

ship_down	st	ship_flag
	addq.l	#2,plr_gfx_pos
	cmp.l	#plr_gfx_end,plr_gfx_pos
	blt.s	.s1
	move.l	#plr_gfx_end,plr_gfx_pos
.s1	move.l	plr_gfx_pos,a1
	move.w	(a1),spr_num(a0)
	rts

;
; if stopped moving vertically - restore player to sprite frame 2
;
player_anim	tst.b	ship_flag
	bne.s	.s3
	cmp.l	#plr_gfx_tab+(2*12),plr_gfx_pos
	beq.s	.s3
	blt.s	.s2
	subq.l	#2,plr_gfx_pos
	bra.s	.s1
.s2	addq.l	#2,plr_gfx_pos
.s1	move.l	plr_gfx_pos,a0
	lea	player_struct,a1
	move.w	(a0),spr_num(a1)
.s3	rts

no_fire
	cmp.b	#$80,d0
	bne.s	no_move_and_fire
	st	fire_flag

	addq.w	#2,beam_val
	cmp.w	#powerup_wait,beam_val
	blt.s	.s1

	lea	power_struct,a1
	cmp.w	#0,status(a1)
	bgt.s	.s1

	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)
	clr.w	spr_die_flag(a1)
	clr.w	spr_x_move_val(a1)	; pixels to move
	clr.w	spr_move_flag(a1)
	clr.w	spr_anim_val(a1)

	move.l	#power_sprites,spr_ptr1(a1)
	clr.w	spr_num(a1)

	move.l	#power_sfx+12,d5
	move.l	#power_sfx_end,d6
	move.l	#power_sfx_end-(1024*2)-512,d7	; loop address
	jsr	play_sfx

.s1	rts

no_move_and_fire
	st	fire_flag

	addq.w	#2,beam_val
	cmp.w	#powerup_wait,beam_val
	blt.s	.s1

	lea	power_struct,a1
	cmp.w	#0,status(a1)
	bgt.s	.s1
	
	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)
	clr.w	spr_die_flag(a1)
	clr.w	spr_x_move_val(a1)	; pixels to move
	clr.w	spr_move_flag(a1)
	clr.w	spr_anim_val(a1)

	move.l	#power_sprites,spr_ptr1(a1)
	clr.w	spr_num(a1)

	move.l	#power_sfx+12,d5
	move.l	#power_sfx_end,d6
	move.l	#power_sfx_end-(1024*2)-512-128,d7	; loop address
	jsr	play_sfx

.s1
	moveq	#0,d0
	move.b	joy1_status,d0
	bclr	#7,d0
	bra	do_joystick2

; don't use d0
generate_beam
	tst.b	fire_flag
	beq.s	.e1
	sf	fire_flag


	bsr	do_player_beam
	bsr.s	do_force_beam

	clr.w	beam_val
	
.e1	rts

******************************************

do_force_beam	subq.w	#1,weapon_cnt
	tst.w	weapon_cnt
	bpl	.beam_return2
	move.w	#2-1,weapon_cnt

	tst.l	beam_type	; if beam is 'powered up'
	bne	.beam_return2	; don't create force shot

	cmp.w	#0,force_struct+status
	beq	.beam_return2

	move.w	force_power,d1
	lsl.w	#3,d1
	lea	force_power_tab,a1
	add.w	d1,a1
	move.l	(a1)+,a4
	move.l	(a1)+,a5
	move.l	a4,a1
	move.l	a5,a4
	move.w	#2-1,trace_cnt
	move.w	#3-1,bounce_cnt

	clr.w	circle_inc
	clr.w	pop_flag1
x	set	0
	rept	num_beams
	tst.w	pop_flag1
	bne	.beam_return2
	lea	beam_struct+x,a0
	move.w	status(a0),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	.table(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr

.beam_return2	rts

.table	dc.l	set_up_force_beam	; dead
	dc.l	.beam_return2	; born
	dc.l	.beam_return2	; alive
	dc.l	.beam_return2	; dying

force_power_tab
	dc.l	0,0
	dc.l	force_power_low,force_power_low_end
	dc.l	force_power_med,force_power_med_end
	dc.l	force_power_high,force_power_high_end


force_power_low
	dc.l	force_beam_sprite1	; gfx
	dc.w	0		; dir
	dc.w	6	; vertical offset
	dc.w	-1	; spr_rout_flag
	dc.l	mul_16x4_2_bpl	; spr mul val
	dc.l	0	; spr_store_addr
	dc.l	restore_16x4_2_bpl	; spr_rest_addr
	dc.l	draw_16x4_2_bpl	; spr_draw_addr
	dc.l	force_beam_sprite1_gfx	; gfx
	dc.l	0	; anim frame val
	dc.w	1	; power
force_power_low_end

force_power_med
	dc.l	force_diag_beam_sprite1
	dc.w	1
	dc.w	3+2
	dc.w	-1	; spr_rout_flag
	dc.l	mul_16x6_2_bpl	; spr mul val
	dc.l	0	; spr_store_addr
	dc.l	restore_16x6_2_bpl	; spr_rest_addr
	dc.l	draw_16x6_2_bpl	; spr_draw_addr
	dc.l	force_diag_beam_sprite1_gfx	; gfx
	dc.l	0	; anim frame val
	dc.w	1

	dc.l	force_diag_beam_sprite2
	dc.w	2
	dc.w	9+2
	dc.w	-1	; spr_rout_flag
	dc.l	mul_16x6_2_bpl	; spr mul val
	dc.l	0	; spr_store_addr
	dc.l	restore_16x6_2_bpl	; spr_rest_addr
	dc.l	draw_16x6_2_bpl	; spr_draw_addr
	dc.l	force_diag_beam_sprite2_gfx	; gfx
	dc.l	0	; anim frame val
	dc.w	1
force_power_med_end

force_power_high
	dc.l	force_diag_beam_sprite1
	dc.w	1
	dc.w	3+5
	dc.w	-1	; spr_rout_flag
	dc.l	mul_16x6_2_bpl	; spr mul val
	dc.l	0	; spr_store_addr
	dc.l	restore_16x6_2_bpl	; spr_rest_addr
	dc.l	draw_16x6_2_bpl	; spr_draw_addr
	dc.l	force_diag_beam_sprite1_gfx	; gfx
	dc.l	0	; anim frame val
	dc.w	1

	dc.l	force_diag_beam_sprite2
	dc.w	2
	dc.w	9+5
	dc.w	-1	; spr_rout_flag
	dc.l	mul_16x6_2_bpl	; spr mul val
	dc.l	0	; spr_store_addr
	dc.l	restore_16x6_2_bpl	; spr_rest_addr
	dc.l	draw_16x6_2_bpl	; spr_draw_addr
	dc.l	force_diag_beam_sprite2_gfx	; gfx
	dc.l	0	; anim frame val
	dc.w	1

	dc.l	force_vertical_beam_sprite1
	dc.w	3
	dc.w	8
	dc.w	-1	; spr_rout_flag
	dc.l	mul_16x12_2_bpl	; spr mul val
	dc.l	0	; spr_store_addr
	dc.l	restore_16x12_2_bpl	; spr_rest_addr
	dc.l	draw_16x12_2_bpl	; spr_draw_addr
	dc.l	force_vertical_beam_sprite1_gfx
	dc.l	0	; anim frame val
	dc.w	1

	dc.l	force_vertical_beam_sprite2
	dc.w	4
	dc.w	8
	dc.w	-1	; spr_rout_flag
	dc.l	mul_16x12_2_bpl	; spr mul val
	dc.l	0	; spr_store_addr
	dc.l	restore_16x12_2_bpl	; spr_rest_addr
	dc.l	draw_16x12_2_bpl	; spr_draw_addr
	dc.l	force_vertical_beam_sprite2_gfx
	dc.l	0	; anim frame val
	dc.w	1
force_power_high_end

set_up_force_beam
;	cmp.l	#beam_struct+(sprite_size*num_beams),a0
;	bge	.return

	tst.b	attached_flag
	bne	do_weapon

	clr.w	spr_type(a0)
	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_move_dir(a0)
	clr.w	spr_die_flag(a0)
	move.w	#15,spr_x_move_val(a0)	; pixels to move
	move.w	#15/4,spr_y_move_val(a0)	; pixels to move

	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)
	clr.w	hit_flag(a0)
	move.w	#-1,hit_count(a0)
	
	lea	force_struct,a2
	move.l	spr_ptr1(a2),a3
	addq.w	#6,a3
	move.w	spr_num(a2),d1
	lsl.w	#5,d1
	add.w	d1,a3
	move.w	x1(a2),d1
	add.w	8(a3),d1
	move.w	d1,x1(a0)

	move.l	(a1)+,spr_ptr1(a0)
	clr.w	spr_num(a0)

	cmp.l	#force_vertical_beam_sprite1,spr_ptr1(a0)
	bne.s	.j0
	move.w	#15,spr_y_move_val(a0)	; pixels to move
.j0	cmp.l	#force_vertical_beam_sprite2,spr_ptr1(a0)
	bne.s	.j1
	move.w	#15,spr_y_move_val(a0)	; pixels to move
.j1

; set vertical beam positions correctly
	cmp.w	#3,(a1)
	bne.s	.s1
	sub.w	#16,x1(a0)
	bra.s	.s2
.s1	cmp.w	#4,(a1)
	bne.s	.s2
	sub.w	#16,x1(a0)
.s2
	move.w	(a1)+,spr_move_dir(a0)
	move.w	y1(a2),d1
	add.w	(a1)+,d1
	move.w	d1,y1(a0)

	move.w	(a1)+,spr_rout_flag(a0)

;	movem.l	(a1)+,d1-d6
;	movem.l	d1-d6,spr_skew_tab(a0)

	move.l	(a1)+,spr_skew_tab(a0)
	move.l	(a1)+,spr_store_addr(a0)
	move.l	(a1)+,spr_rest_addr(a0)
	move.l	(a1)+,spr_draw_addr(a0)
	move.l	(a1)+,spr_gfx_addr(a0)
	move.l	(a1)+,spr_anim_tab(a0)

	move.w	(a1)+,spr_power(a0)
	move.w	#-1,spr_mask_flag(a0)

	cmp.l	a4,a1
	blt.s	.return
	move.w	#-1,pop_flag1	; pop address off stack

.return	rts


do_weapon	move.w	weapon_type,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.lookup(pc,d1.w),a1
	jmp	(a1)

.lookup	dc.l	.return
	dc.l	set_up_laser
	dc.l	set_up_bounce	; bounce lazer
	dc.l	set_up_trace

.return	move.w	#-1,pop_flag1
	rts

set_up_laser	move.w	force_power,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.lookup(pc,d1.w),a1
	jmp	(a1)

.lookup	dc.l	.return
	dc.l	.return
	dc.l	go_snake
	dc.l	go_circle

*** low
.return	move.l	#beam_sfx1+12,d5
	move.l	#beam_sfx1_end,d6
	moveq	#-1,d7	; non-looping
	jsr	play_sfx
	move.w	#-1,pop_flag1
	rts
*** med
go_snake	move.w	circle_inc,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.lookup(pc,d1.w),a1
	jmp	(a1)

.lookup	dc.l	do_force_snake1
	dc.l	do_force_snake2
	dc.l	do_pod_snake1	; snake 1
	dc.l	do_pod_snake2	; snake 2

*** high
go_circle	move.w	circle_inc,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.lookup(pc,d1.w),a1
	jmp	(a1)

.lookup	dc.l	do_circle
	dc.l	do_pod_snake1	; snake 1
	dc.l	do_pod_snake2	; snake 2

do_circle	addq.w	#1,circle_inc

	tst.b	circle_laser_flag
	bne	.e1
	st	circle_laser_flag

	clr.w	spr_type(a0)
	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_move_dir(a0)
	clr.w	spr_die_flag(a0)
	move.w	#16,spr_x_move_val(a0)
	clr.w	spr_move_flag(a0)
	move.w	#2,spr_anim_val(a0)

	move.w	#4,spr_power(a0)

	move.l	#circle_laser,spr_ptr1(a0)
	clr.l	beam_type

	clr.w	spr_num(a0)

	move.w	player_struct+x1,d1
	add.w	#32,d1
	tst.b	force_front_rear_flag
	bne.s	.s1
	move.w	#5,spr_move_dir(a0)
	sub.w	#64+32,d1
.s1	move.w	d1,x1(a0)

	move.w	player_struct+y1,d1
	sub.w	#9,d1
	move.w	d1,y1(a0)

	clr.w	spr_rout_flag(a0)
	move.w	#-1,spr_mask_flag(a0)

	move.l	#circle_sfx+12,d5
	move.l	#circle_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx

.e1	rts

do_pod_snake1	cmp.w	#0,pod_struct1+status
	beq	.return_pop

	addq.w	#1,circle_inc

	tst.b	attached_flag
	beq	.return

	clr.w	spr_type(a0)
	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_move_dir(a0)
	clr.w	spr_die_flag(a0)
	move.w	#20,spr_x_move_val(a0)
	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)
	move.w	#4,spr_power(a0)

	move.l	#snake_laser,spr_ptr1(a0)
	clr.l	beam_type

	clr.w	spr_num(a0)

	move.w	pod_struct1+x1,d1
	add.w	#16,d1

	tst.b	force_front_rear_flag
	bne.s	.s1
	sub.w	#32+16,d1
	move.w	#2,spr_num(a0)
	move.w	#5,spr_move_dir(a0)
.s1
	move.w	d1,x1(a0)

	move.w	pod_struct1+y1,d1
	addq.w	#5,d1
	move.w	d1,y1(a0)

	cmp.w	#-4,y1(a0)
	bgt.s	.s2
	move.w	#3,status(a0)
	bra.s	.return
.s2	cmp.w	#192+4,y1(a0)
	blt.s	.s3
	move.w	#3,status(a0)
	bra.s	.return
.s3
	move.w	#-1,spr_rout_flag(a0)
;	movem.l	.soft_tab(pc),d1-d6
;	movem.l	d1-d6,spr_skew_tab(a0)

	move.l	.soft_tab(pc),spr_skew_tab(a0)
	move.l	.soft_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.soft_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.soft_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.soft_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.soft_tab+(4*5)(pc),spr_anim_tab(a0)

	move.l	#circle_sfx+12,d5
	move.l	#circle_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx

.return	rts

.return_pop	move.w	#-1,pop_flag1
	rts

.soft_tab	dc.l	mul_32x4_4_bpl
	dc.l	0
	dc.l	restore_32x4_4_bpl
	dc.l	draw_32x4_4_bpl
	dc.l	snake_sprites_gfx
	dc.l	snake_mul_tab

do_pod_snake2	cmp.w	#0,pod_struct2+status
	beq	.return_pop

	clr.w	circle_inc

	tst.b	attached_flag
	beq	.return

	clr.w	spr_type(a0)
	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_move_dir(a0)
	clr.w	spr_die_flag(a0)
	move.w	#20,spr_x_move_val(a0)
	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)
	move.w	#4,spr_power(a0)

	move.l	#snake_laser,spr_ptr1(a0)
	clr.l	beam_type

	move.w	#1,spr_num(a0)

	move.w	pod_struct2+x1,d1
	add.w	#16,d1

	tst.b	force_front_rear_flag
	bne.s	.s1
	sub.w	#32+16,d1
	move.w	#3,spr_num(a0)
	move.w	#5,spr_move_dir(a0)
.s1
	move.w	d1,x1(a0)

	move.w	pod_struct2+y1,d1
	addq.w	#5,d1
	move.w	d1,y1(a0)

	cmp.w	#-4,y1(a0)
	bgt.s	.s2
	move.w	#3,status(a0)
	bra.s	.return
.s2	cmp.w	#192+4,y1(a0)
	blt.s	.s3
	move.w	#3,status(a0)
	bra.s	.return
.s3
	move.w	#-1,spr_rout_flag(a0)
;	movem.l	.soft_tab(pc),d1-d6
;	movem.l	d1-d6,spr_skew_tab(a0)

	move.l	.soft_tab(pc),spr_skew_tab(a0)
	move.l	.soft_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.soft_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.soft_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.soft_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.soft_tab+(4*5)(pc),spr_anim_tab(a0)

	move.l	#circle_sfx+12,d5
	move.l	#circle_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx

.return_pop	move.w	#-1,pop_flag1
.return	rts

.soft_tab	dc.l	mul_32x4_4_bpl
	dc.l	0
	dc.l	restore_32x4_4_bpl
	dc.l	draw_32x4_4_bpl
	dc.l	snake_sprites_gfx
	dc.l	snake_mul_tab

do_force_snake1	cmp.w	#0,force_struct+status
	beq	.return	; return pop

	addq.w	#1,circle_inc

	tst.b	attached_flag
	beq	.return

	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_move_dir(a0)
	clr.w	spr_die_flag(a0)
	move.w	#20,spr_x_move_val(a0)
	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)
	move.w	#4,spr_power(a0)

	move.l	#snake_laser,spr_ptr1(a0)
	clr.l	beam_type

	clr.w	spr_num(a0)

	move.w	force_struct+x1,d1
	add.w	#16,d1

	tst.b	force_front_rear_flag
	bne.s	.s1
	sub.w	#32+16,d1
	move.w	#2,spr_num(a0)
	move.w	#5,spr_move_dir(a0)
.s1
	move.w	d1,x1(a0)

	move.w	player_struct+y1,y1(a0)
;	subq.w	#2,d1
;	move.w	d1,y1(a0)

	cmp.w	#-4,y1(a0)
	bgt.s	.s2
	move.w	#3,status(a0)
	bra.s	.return
.s2	cmp.w	#192+4,y1(a0)
	blt.s	.s3
	move.w	#3,status(a0)
	bra.s	.return
.s3
	move.w	#-1,spr_rout_flag(a0)
;	movem.l	.soft_tab(pc),d1-d6
;	movem.l	d1-d6,spr_skew_tab(a0)
	move.l	.soft_tab(pc),spr_skew_tab(a0)
	move.l	.soft_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.soft_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.soft_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.soft_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.soft_tab+(4*5)(pc),spr_anim_tab(a0)

	move.l	#circle_sfx+12,d5
	move.l	#circle_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx

.return	rts

.return_pop	move.w	#-1,pop_flag1
	rts

.soft_tab	dc.l	mul_32x4_4_bpl
	dc.l	0
	dc.l	restore_32x4_4_bpl
	dc.l	draw_32x4_4_bpl
	dc.l	snake_sprites_gfx
	dc.l	snake_mul_tab

do_force_snake2	cmp.w	#0,force_struct+status
	beq	.return	; return pop

	addq.w	#1,circle_inc

	tst.b	attached_flag
	beq	.return

	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_move_dir(a0)
	clr.w	spr_die_flag(a0)
	move.w	#20,spr_x_move_val(a0)
	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)
	move.w	#4,spr_power(a0)

	move.l	#snake_laser,spr_ptr1(a0)
	clr.l	beam_type

	move.w	#1,spr_num(a0)

	move.w	force_struct+x1,d1
	add.w	#16,d1

	tst.b	force_front_rear_flag
	bne.s	.s1
	sub.w	#32+16,d1
	move.w	#3,spr_num(a0)
	move.w	#5,spr_move_dir(a0)
.s1
	move.w	d1,x1(a0)

	move.w	player_struct+y1,d1
	add.w	#12,d1
	move.w	d1,y1(a0)

	cmp.w	#-4,y1(a0)
	bgt.s	.s2
	move.w	#3,status(a0)
	bra.s	.return
.s2	cmp.w	#192+4,y1(a0)
	blt.s	.s3
	move.w	#3,status(a0)
	bra.s	.return
.s3
	move.w	#-1,spr_rout_flag(a0)
;	movem.l	.soft_tab(pc),d1-d6
;	movem.l	d1-d6,spr_skew_tab(a0)
	move.l	.soft_tab(pc),spr_skew_tab(a0)
	move.l	.soft_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.soft_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.soft_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.soft_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.soft_tab+(4*5)(pc),spr_anim_tab(a0)

	move.l	#circle_sfx+12,d5
	move.l	#circle_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx

.return	rts

.return_pop	move.w	#-1,pop_flag1
	rts

.soft_tab	dc.l	mul_32x4_4_bpl
	dc.l	0
	dc.l	restore_32x4_4_bpl
	dc.l	draw_32x4_4_bpl
	dc.l	snake_sprites_gfx
	dc.l	snake_mul_tab

set_up_bounce	move.w	force_power,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.lookup(pc,d1.w),a1
	jmp	(a1)

.lookup	dc.l	.return
	dc.l	.return
	dc.l	go_med_bounce
	dc.l	go_high_bounce

*** low
.return
	move.w	#-1,pop_flag1
	rts

go_med_bounce
go_high_bounce

	move.w	bounce_cnt(pc),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.tab(pc,d1.w),a1
	jmp	(a1)

.tab
	dc.l	set_up_bounce_diag2
	dc.l	set_up_bounce_diag1
	dc.l	set_up_bounce_horizontal


bounce_cnt	dc.w	0

set_up_bounce_horizontal


	move.w	#19,spr_type(a0)
	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_die_flag(a0)
	move.w	#15+1,spr_x_move_val(a0)
	clr.w	spr_y_move_val(a0)
	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)

	move.w	#1,spr_power(a0)
	clr.w	spr_energy(a0)

	clr.w	hit_flag(a0)
	move.w	#-1,hit_count(a0)

	move.l	#bounce_sprites,spr_ptr1(a0)
	clr.l	beam_type

	move.w	#-1,spr_mask_flag(a0)

	move.w	#-1,spr_rout_flag(a0)
	move.l	.bounce_tab(pc),spr_skew_tab(a0)
	move.l	.bounce_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.bounce_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.bounce_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.bounce_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.bounce_tab+(4*5)(pc),spr_anim_tab(a0)

	move.w	#0,spr_x_flag(a0)
	move.w	#8-1,spr_x_cnt(a0)	; bounces
	clr.w	spr_y_cnt(a0)
	move.w	#-2,spr_y_flag(a0)

	clr.w	spr_num(a0)

	move.w	#8,spr_move_dir(a0)
	move.w	#-1,spr_x_flag(a0)
	tst.b	force_front_rear_flag
	bne.s	.s0
	clr.w	spr_x_flag(a0)
	move.w	#15,spr_x_move_val(a0)
.s0


	tst.b	fire_hit
	beq.s	.no_fire
	tst.b	bounce_coord_flag1
	bne	.j1
	tst.w	bounce_fire_cnt1
	bmi	.no_fire
	clr.w	status(a0)
	bra	.j2
.no_fire

	tst.b	bounce_coord_flag1
	bne	.j1
	st	bounce_coord_flag1

	move.w	#15+1,spr_x_move_val(a0)
	clr.w	spr_y_move_val(a0)

	tst.b	force_front_rear_flag
	bne.s	.s0_1
;	clr.w	spr_x_flag(a0)
	move.w	#15,spr_x_move_val(a0)
.s0_1

	move.w	player_struct+x1,d1
	add.w	#(32+16)-8,d1
	tst.b	force_front_rear_flag
	bne.s	.s1
;	move.w	#-1,spr_x_flag(a0)
;	move.w	#5,spr_move_dir(a0)

	move.w	player_struct+x1,d1
	sub.w	#16+8,d1
.s1
	move.w	d1,x1(a0)
	move.w	d1,x_reset(a0)
	move.w	d1,bounce_coord1

	move.w	player_struct+y1,d1
	add.w	#6,d1
	move.w	d1,y1(a0)
	move.w	d1,bounce_coord1+2

	move.w	#8-1,bounce_fire_cnt1
	move.w	#3-1,bounce_coord_cnt
	cmp.w	#3,force_power
	bne.s	.j0
	move.w	#7-1,bounce_coord_cnt
	move.w	#16-1,bounce_fire_cnt1
.j0
	st	bounce_flag
	st	bounce_fx_flag

	cmp.w	#1,scroll_cnt
	beq.s	.skip1_a
	subq.w	#1,bounce_coord1
	subq.w	#1,x1(a0)
	bra.s	.skip2_a
.skip1_a	move.w	#15,spr_x_move_val(a0)
.skip2_a
	
	bra	.j2
.j1
	cmp.w	#1,scroll_cnt
	beq.s	.skip1
	subq.w	#1,bounce_coord1
	bra.s	.skip2
.skip1	move.w	#15,spr_x_move_val(a0)
.skip2

	move.w	bounce_coord1,x1(a0)
	move.w	bounce_coord1+2,y1(a0)
	moveq	#0,d0
	add.w	d0,x1(a0)

.j2
	move.w	#-1,weapon_cnt
	subq.w	#1,bounce_cnt
	tst.w	bounce_cnt
	bpl.s	.s2
	move.w	#-1,bounce_cnt

	move.w	#-1,pop_flag1

.s2	rts

.bounce_tab	dc.l	mul_16x3_2_bpl
	dc.l	0
	dc.l	restore_16x3_2_bpl
	dc.l	draw_16x3_2_bpl
	dc.l	bounce_sprites_gfx1
	dc.l	0


set_up_bounce_diag1

	move.w	#19,spr_type(a0)
	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_die_flag(a0)
	move.w	#15+1,spr_x_move_val(a0)
	move.w	#15,spr_y_move_val(a0)
	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)

	move.w	#1,spr_power(a0)
	clr.w	spr_energy(a0)

	clr.w	hit_flag(a0)
	move.w	#-1,hit_count(a0)

	move.l	#bounce_sprites,spr_ptr1(a0)
	clr.l	beam_type

	move.w	#8-1,spr_x_cnt(a0)	; bounces
	move.w	#-1,spr_x_flag(a0)
	move.w	#8-1,spr_y_cnt(a0)	; bounces
	clr.w	spr_y_flag(a0)


	move.w	#-1,spr_rout_flag(a0)
	move.w	#-1,spr_mask_flag(a0)
	move.l	.bounce_tab(pc),spr_skew_tab(a0)
	move.l	.bounce_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.bounce_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.bounce_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.bounce_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.bounce_tab+(4*5)(pc),spr_anim_tab(a0)

	move.w	#1,spr_num(a0)
	move.w	#9,spr_move_dir(a0)

	move.w	#1,diag_move(a0)
	tst.b	force_front_rear_flag
	bne.s	.s0
	clr.w	diag_move(a0)
	clr.w	spr_x_flag(a0)
;	move.w	#14,spr_x_move_val(a0)
.s0

	tst.b	fire_hit
	beq.s	.no_fire
	tst.b	bounce_coord_flag2
	bne	.j1
	tst.w	bounce_fire_cnt2
	bmi	.no_fire
	clr.w	status(a0)
	bra	.j2
.no_fire

	tst.b	bounce_coord_flag2
	bne	.j1
	st	bounce_coord_flag2

	move.w	#15+1,spr_x_move_val(a0)
;	move.w	#15,spr_y_move_val(a0)

	move.w	player_struct+x1,d1
	add.w	#(32+16)-8,d1
	tst.b	force_front_rear_flag
	bne.s	.s1
	move.w	#2,spr_num(a0)

	move.l	#bounce_sprites_gfx3,spr_gfx_addr(a0)

	move.w	player_struct+x1,d1
	sub.w	#16+8,d1
.s1
	move.w	d1,x1(a0)
	move.w	d1,x_reset(a0)
	move.w	d1,bounce_coord2

	move.w	player_struct+y1,d1
	subq.w	#4,d1
	move.w	d1,y1(a0)
	move.w	d1,bounce_coord2+2
	move.l	spr_gfx_addr(a0),bounce_coord2+4

	move.w	#8-1,bounce_fire_cnt2
	cmp.w	#3,force_power
	bne.s	.j0
	move.w	#16-1,bounce_fire_cnt2
.j0
	cmp.w	#1,scroll_cnt
	beq.s	.skip1_a
	subq.w	#1,bounce_coord2
	subq.w	#1,x1(a0)
	bra.s	.skip2_a
.skip1_a	move.w	#15,spr_x_move_val(a0)
.skip2_a

	bra	.j2
.j1
	cmp.w	#1,scroll_cnt
	beq.s	.skip1
	subq.w	#1,bounce_coord2
	bra.s	.skip2
.skip1	move.w	#15,spr_x_move_val(a0)
.skip2

	move.w	bounce_coord2,x1(a0)
	move.w	bounce_coord2+2,y1(a0)
	move.l	bounce_coord2+4,spr_gfx_addr(a0)
	moveq	#0,d0
	add.w	d0,x1(a0)
	sub.w	d0,y1(a0)

.j2
	move.w	#-1,weapon_cnt

	subq.w	#1,bounce_cnt
	tst.w	bounce_cnt
	bpl.s	.s2
	move.w	#-1,bounce_cnt
	move.w	#-1,pop_flag1

.s2	rts

.bounce_tab	dc.l	mul_16x16_2_bpl
	dc.l	0
	dc.l	restore_16x16_2_bpl
	dc.l	draw_16x16_2_bpl
	dc.l	bounce_sprites_gfx2
	dc.l	0

set_up_bounce_diag2

	move.w	#19,spr_type(a0)
	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_die_flag(a0)
	move.w	#15+1,spr_x_move_val(a0)
	move.w	#15,spr_y_move_val(a0)
	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)

	move.w	#1,spr_power(a0)
	clr.w	spr_energy(a0)

	clr.w	hit_flag(a0)
	move.w	#-1,hit_count(a0)

	move.l	#bounce_sprites,spr_ptr1(a0)
	clr.l	beam_type


	move.w	#8-1,spr_x_cnt(a0)	; bounces
	move.w	#-1,spr_x_flag(a0)
	move.w	#8-1,spr_y_cnt(a0)	; bounces
	move.w	#-1,spr_y_flag(a0)


	move.w	#-1,spr_mask_flag(a0)
	move.w	#-1,spr_rout_flag(a0)
	move.l	.bounce_tab(pc),spr_skew_tab(a0)
	move.l	.bounce_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.bounce_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.bounce_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.bounce_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.bounce_tab+(4*5)(pc),spr_anim_tab(a0)

	move.w	#1,spr_num(a0)

	move.w	#9,spr_move_dir(a0)

	move.w	#2,diag_move(a0)
	tst.b	force_front_rear_flag
	bne.s	.s0
	move.w	#3,diag_move(a0)
	clr.w	spr_x_flag(a0)
;	move.w	#14,spr_x_move_val(a0)
.s0

	tst.b	fire_hit
	beq.s	.no_fire
	tst.b	bounce_coord_flag3
	bne	.j1
	tst.w	bounce_fire_cnt3
	bmi	.no_fire
	clr.w	status(a0)
	bra	.j2
.no_fire

	tst.b	bounce_coord_flag3
	bne	.j1
	st	bounce_coord_flag3

	move.w	#15+1,spr_x_move_val(a0)
;	move.w	#15,spr_y_move_val(a0)

	move.w	player_struct+x1,d1
	add.w	#(32+16)-8,d1
	tst.b	force_front_rear_flag
	bne.s	.s1

	move.w	#1,spr_num(a0)

	move.l	#bounce_sprites_gfx2,spr_gfx_addr(a0)

	move.w	player_struct+x1,d1
	sub.w	#16+8,d1
.s1
	move.w	d1,x1(a0)
	move.w	d1,x_reset(a0)
	move.w	d1,bounce_coord3

	move.w	player_struct+y1,d1
	addq.w	#2,d1
	move.w	d1,y1(a0)
	move.w	d1,bounce_coord3+2
	move.l	spr_gfx_addr(a0),bounce_coord3+4

	move.w	#8-1,bounce_fire_cnt3
	cmp.w	#3,force_power
	bne.s	.j0
	move.w	#16-1,bounce_fire_cnt3
.j0
	cmp.w	#1,scroll_cnt
	beq.s	.skip1_a
	subq.w	#1,bounce_coord3
	subq.w	#1,x1(a0)
	bra.s	.skip2_a
.skip1_a	move.w	#15,spr_x_move_val(a0)
.skip2_a

	bra	.j2
.j1
	cmp.w	#1,scroll_cnt
	beq.s	.skip1
	subq.w	#1,bounce_coord3
	bra.s	.skip2
.skip1	move.w	#15,spr_x_move_val(a0)
.skip2

	move.w	bounce_coord3,x1(a0)
	move.w	bounce_coord3+2,y1(a0)
	move.l	bounce_coord3+4,spr_gfx_addr(a0)
	moveq	#0,d0
	add.w	d0,x1(a0)
	add.w	d0,y1(a0)

.j2
	move.w	#-1,weapon_cnt

	subq.w	#1,bounce_cnt
	tst.w	bounce_cnt
	bpl.s	.s2
	move.w	#-1,bounce_cnt

	move.w	#-1,pop_flag1

.s2	rts

.bounce_tab	dc.l	mul_16x16_2_bpl
	dc.l	0
	dc.l	restore_16x16_2_bpl
	dc.l	draw_16x16_2_bpl
	dc.l	bounce_sprites_gfx3
	dc.l	0

******************************************

set_up_trace	move.w	force_power,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.lookup(pc,d1.w),a1
	jmp	(a1)

.lookup	dc.l	.return
	dc.l	.return
	dc.l	go_med_trace
	dc.l	go_high_trace

*** low
.return
	move.w	#-1,pop_flag1
	rts

go_med_trace
go_high_trace

	move.w	trace_cnt(pc),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.tab(pc,d1.w),a1
	jmp	(a1)


.tab
	dc.l	set_up_trace_diag2
	dc.l	set_up_trace_diag1


trace_cnt	dc.w	0
trace_coord_cnt	dc.w	0

set_up_trace_diag1

	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_die_flag(a0)
	move.w	#15+1-6,spr_x_move_val(a0)
	move.w	#15-6,spr_y_move_val(a0)
	clr.w	spr_move_flag(a0)
	move.w	#6,spr_anim_val(a0)
	move.w	#4-1,spr_frames(a0)

	move.w	#16,spr_type(a0)
	move.w	#1,spr_power(a0)
	clr.w	spr_energy(a0)

	clr.w	hit_flag(a0)
	move.w	#-1,hit_count(a0)

	move.l	#trace_sprites,spr_ptr1(a0)
	clr.l	beam_type

	move.w	#8-1,spr_x_cnt(a0)	; bounces
	move.w	#-1,spr_x_flag(a0)
	move.w	#8-1,spr_y_cnt(a0)	; bounces
	clr.w	spr_y_flag(a0)


	move.w	#-1,spr_rout_flag(a0)
	move.w	#-1,spr_mask_flag(a0)
	move.l	.trace_tab(pc),spr_skew_tab(a0)
	move.l	.trace_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.trace_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.trace_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.trace_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.trace_tab+(4*5)(pc),spr_anim_tab(a0)

	move.w	#0,spr_num(a0)
	move.w	#10,spr_move_dir(a0)

	move.w	#1,diag_move(a0)
	tst.b	force_front_rear_flag
	bne.s	.s0
	clr.w	diag_move(a0)
	clr.w	spr_x_flag(a0)
;	move.w	#14,spr_x_move_val(a0)
.s0

	tst.b	fire_hit
	beq.s	.no_fire
	tst.b	trace_coord_flag2
	bne	.j1
	tst.w	trace_fire_cnt2
	bmi	.no_fire
	clr.w	status(a0)
	bra	.j2
.no_fire

	tst.b	trace_coord_flag2
	bne	.j1
	st	trace_coord_flag2

	move.w	#15+1-6,spr_x_move_val(a0)
;	move.w	#15,spr_y_move_val(a0)

	move.w	player_struct+x1,d1
	add.w	#(32+16)-8,d1
	tst.b	force_front_rear_flag
	bne.s	.s1
	move.w	#0,spr_num(a0)

	move.l	#trace_sprites_gfx,spr_gfx_addr(a0)

	move.w	player_struct+x1,d1
	sub.w	#16+8,d1
.s1
	move.w	d1,x1(a0)
	move.w	d1,x_reset(a0)
	move.w	d1,trace_coord2

	move.w	player_struct+y1,d1
	subq.w	#4,d1
	move.w	d1,y1(a0)
	move.w	d1,trace_coord2+2
	move.l	spr_gfx_addr(a0),trace_coord2+4

	move.w	#8-1,trace_fire_cnt2
	move.w	#3-1,trace_coord_cnt
	cmp.w	#3,force_power
	bne.s	.j0
	move.w	#16-2-1,trace_fire_cnt2
	move.w	#7-2-1,trace_coord_cnt
.j0

	st	trace_flag
	st	trace_fx_flag
	cmp.w	#1,scroll_cnt
	beq.s	.skip1_a
	subq.w	#1,trace_coord2
	subq.w	#1,x1(a0)
	bra.s	.skip2_a
.skip1_a	move.w	#15-6,spr_x_move_val(a0)
.skip2_a

	bra	.j2
.j1
	cmp.w	#1,scroll_cnt
	beq.s	.skip1
	subq.w	#1,trace_coord2
	bra.s	.skip2
.skip1	move.w	#15-6,spr_x_move_val(a0)
.skip2

	move.w	trace_coord2,x1(a0)
	move.w	trace_coord2+2,y1(a0)
	move.l	trace_coord2+4,spr_gfx_addr(a0)
	moveq	#0,d0
	add.w	d0,x1(a0)
	sub.w	d0,y1(a0)

.j2
	move.w	#-1,weapon_cnt

	subq.w	#1,trace_cnt
	tst.w	trace_cnt
	bpl.s	.s2
	move.w	#-1,trace_cnt
	move.w	#-1,pop_flag1

.s2	rts

.trace_tab
	dc.l	mul_16x14_4_bpl
	dc.l	0
	dc.l	restore_16x14
	dc.l	draw_16x14_4_bpl
	dc.l	trace_sprites_gfx
	dc.l	trace_mul_tab

trace_coord2	ds.b	8
trace_fire_cnt2
	dc.w	0
trace_coord_flag2
	dc.b	0
	even

set_up_trace_diag2

	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_die_flag(a0)
	move.w	#15+1-6,spr_x_move_val(a0)
	move.w	#15-6,spr_y_move_val(a0)
	clr.w	spr_move_flag(a0)
	move.w	#6,spr_anim_val(a0)
	move.w	#4-1,spr_frames(a0)

	move.w	#17,spr_type(a0)
	move.w	#1,spr_power(a0)
	clr.w	spr_energy(a0)

	clr.w	hit_flag(a0)
	move.w	#-1,hit_count(a0)

	move.l	#trace_sprites,spr_ptr1(a0)
	clr.l	beam_type


	move.w	#8-1,spr_x_cnt(a0)	; bounces
	move.w	#-1,spr_x_flag(a0)
	move.w	#8-1,spr_y_cnt(a0)	; bounces
	move.w	#-1,spr_y_flag(a0)


	move.w	#-1,spr_mask_flag(a0)
	move.w	#-1,spr_rout_flag(a0)
	move.l	.trace_tab(pc),spr_skew_tab(a0)
	move.l	.trace_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.trace_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.trace_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.trace_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.trace_tab+(4*5)(pc),spr_anim_tab(a0)

	move.w	#0,spr_num(a0)

	move.w	#10,spr_move_dir(a0)

	move.w	#2,diag_move(a0)
	tst.b	force_front_rear_flag
	bne.s	.s0
	move.w	#3,diag_move(a0)
	clr.w	spr_x_flag(a0)
;	move.w	#14,spr_x_move_val(a0)
.s0

	tst.b	fire_hit
	beq.s	.no_fire
	tst.b	trace_coord_flag3
	bne	.j1
	tst.w	trace_fire_cnt3
	bmi	.no_fire
	clr.w	status(a0)
	bra	.j2
.no_fire

	tst.b	trace_coord_flag3
	bne	.j1
	st	trace_coord_flag3

	move.w	#15+1-6,spr_x_move_val(a0)
;	move.w	#15,spr_y_move_val(a0)

	move.w	player_struct+x1,d1
	add.w	#(32+16)-8,d1
	tst.b	force_front_rear_flag
	bne.s	.s1

	move.w	#0,spr_num(a0)

	move.l	#trace_sprites_gfx,spr_gfx_addr(a0)

	move.w	player_struct+x1,d1
	sub.w	#16+8,d1
.s1
	move.w	d1,x1(a0)
	move.w	d1,x_reset(a0)
	move.w	d1,trace_coord3

	move.w	player_struct+y1,d1
	addq.w	#2,d1
	move.w	d1,y1(a0)
	move.w	d1,trace_coord3+2
	move.l	spr_gfx_addr(a0),trace_coord3+4

	move.w	#8-1,trace_fire_cnt3
	cmp.w	#3,force_power
	bne.s	.j0
	move.w	#16-2-1,trace_fire_cnt3
.j0
	cmp.w	#1,scroll_cnt
	beq.s	.skip1_a
	subq.w	#1,trace_coord3
	subq.w	#1,x1(a0)
	bra.s	.skip2_a
.skip1_a	move.w	#15-6,spr_x_move_val(a0)
.skip2_a

	bra	.j2
.j1
	cmp.w	#1,scroll_cnt
	beq.s	.skip1
	subq.w	#1,trace_coord3
	bra.s	.skip2
.skip1	move.w	#15-6,spr_x_move_val(a0)
.skip2

	move.w	trace_coord3,x1(a0)
	move.w	trace_coord3+2,y1(a0)
	move.l	trace_coord3+4,spr_gfx_addr(a0)
	moveq	#0,d0
	add.w	d0,x1(a0)
	add.w	d0,y1(a0)

.j2
	move.w	#-1,weapon_cnt

	subq.w	#1,trace_cnt
	tst.w	trace_cnt
	bpl.s	.s2
	move.w	#-1,trace_cnt

	move.w	#-1,pop_flag1

.s2	rts

.trace_tab	dc.l	mul_16x14_4_bpl
	dc.l	0
	dc.l	restore_16x14
	dc.l	draw_16x14_4_bpl
	dc.l	trace_sprites_gfx
	dc.l	trace_mul_tab

trace_coord3	ds.b	8
trace_fire_cnt3
	dc.w	0
trace_coord_flag3
	dc.b	0
	even
******************************************

do_player_beam
	bsr	do_homing_missiles

	clr.w	pop_flag1
x	set	0
	rept	num_beams
	tst.w	pop_flag1
	bne	.beam_return1
	lea	beam_struct+x,a0
	move.w	status(a0),d1
	add.w	d1,d1
	add.w	d1,d1

	lea	.table(pc),a1
	add.w	d1,a1
	move.l	(a1),a1


	jsr	(a1)
x	set	x+sprite_size
	endr

.beam_return1	rts

.table	dc.l	.set_up_beam	; dead
	dc.l	.return	; born
	dc.l	.return	; alive
	dc.l	.return	; dying

.set_up_beam
;	cmp.l	#beam_struct+(sprite_size*num_beams),a0
;	bge	.return


	clr.w	spr_type(a0)
	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	clr.w	spr_move_dir(a0)
	clr.w	spr_die_flag(a0)
	move.w	#14,spr_x_move_val(a0)	; pixels to move
	clr.w	spr_move_flag(a0)
	move.w	#1,spr_anim_val(a0)

	clr.w	hit_flag(a0)
	move.w	#-1,hit_count(a0)

;	move.w	#5,spr_power(a0)

	move.w	beam_val(pc),d2
	and.w	#56-1,d2

	move.w	d2,d3
	lsr.w	#4,d3
	addq.w	#2,d3
	move.w	d3,spr_power(a0)

	add.w	d2,d2

	lea	beam_tab(pc),a1
	add.w	d2,a1
	move.w	(a1),d1

	move.w	d1,d2
	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1
	lea	.beam_sprite_tab(pc),a1
	add.w	d1,a1
	move.l	(a1)+,spr_ptr1(a0)
	move.l	(a1)+,beam_type

	clr.w	spr_num(a0)

	move.w	player_struct+x1,d1
	add.w	#32,d1
	tst.b	attached_flag
	beq.s	.s1
	tst.b	force_front_rear_flag
	beq.s	.s1

	lea	force_struct,a2
	move.l	spr_ptr1(a2),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d3
	lsl.w	#5,d3
	add.w	d3,a2

	add.w	8(a2),d1
.s1	move.w	d1,x1(a0)

	add.w	d2,d2

	move.w	player_struct+y1,d1
;	add.w	.vert_tab(pc,d2.w),d1
	lea	.vert_tab(pc),a2
	add.w	d2,a2
	add.w	(a2),d1

	move.w	d1,y1(a0)

	clr.w	spr_rout_flag(a0)

	cmp.l	#beam_sprite1,spr_ptr1(a0)
	bne.s	.s2
	move.w	#1,spr_power(a0)

	move.w	#18,spr_x_move_val(a0)	; pixels to move
	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)
; use a software rout for this beam

	move.w	#-1,spr_rout_flag(a0)

;	movem.l	.beam_sprite1_tab(pc),d1-d6
;	movem.l	d1-d6,spr_skew_tab(a0)

	move.l	.beam_sprite1_tab(pc),spr_skew_tab(a0)
	move.l	.beam_sprite1_tab+(4*1)(pc),spr_store_addr(a0)
	move.l	.beam_sprite1_tab+(4*2)(pc),spr_rest_addr(a0)
	move.l	.beam_sprite1_tab+(4*3)(pc),spr_draw_addr(a0)
	move.l	.beam_sprite1_tab+(4*4)(pc),spr_gfx_addr(a0)
	move.l	.beam_sprite1_tab+(4*5)(pc),spr_anim_tab(a0)

	tst.b	attached_flag
	beq.s	.j1
	cmp.w	#0,weapon_type
	bne.s	.s3
.j1	move.l	#beam_sfx1+12,d5
	move.l	#beam_sfx1_end,d6
	moveq	#-1,d7	; non-looping
	jsr	play_sfx
	bra.s	.s3
.s2	move.l	#beam_sfx2+12,d5
	move.l	#beam_sfx2_end,d6
	moveq	#-1,d7	; non-looping
	jsr	play_sfx
.s3
	move.w	#-1,pop_flag1	; pop address off stack

.return	rts

.vert_tab	dc.w	6,2,2,2,2	; vertical offsets for beam(s)

; beam sprite,beam type flag

.beam_sprite_tab
	dc.l	beam_sprite1,0
	dc.l	beam_sprite2,-1
	dc.l	beam_sprite3,-1
	dc.l	beam_sprite4,-1
	dc.l	beam_sprite5,-1

.beam_sprite1_tab
	dc.l	mul_16x4_2_bpl
	dc.l	0
	dc.l	restore_16x4_2_bpl
	dc.l	draw_16x4_2_bpl
	dc.l	beam_sprite1_gfx
	dc.l	0

beam_tab	dcb.w	11,0
	dcb.w	11,1
	dcb.w	11,2
	dcb.w	11,3
	dcb.w	12+1,4
beam_val	dc.w	0

animate_beam	
x	set	0
	rept	num_beams
	lea	beam_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.table(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.return	rts

.table	dc.l	.return
	dc.l	.animate
	dc.l	.animate
	dc.l	.return

.animate	move.w	spr_anim_val(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table2(pc,d0.w),a2
	jmp	(a2)

.table2	dc.l	.return
	dc.l	.animate_beam
	dc.l	.animate_circle
	dc.l	.animate_home1
	dc.l	.animate_home2
	dc.l	.animate_home3
	dc.l	.animate_trace

.animate_beam
;	cmp.l	#beam_struct+(sprite_size*num_beams),a0
;	bge.s	.e1

	subq.w	#1,big_beam_cnt
	tst.w	big_beam_cnt
	bpl.s	.e1
	move.w	#2,big_beam_cnt

	clr.w	spr_num(a0)
	not.b	big_beam_flag
	tst.b	big_beam_flag
	bne.s	.e1
	move.w	#1,spr_num(a0)
.e1	rts

.animate_circle
;	cmp.l	#beam_struct+(sprite_size*num_beams),a0
;	bge.s	.e3

	tst.b	force_front_rear_flag
	bne.s	.s1

	addq.w	#1,spr_num(a0)
	cmp.w	#4-1,spr_num(a0)
	ble.s	.e2
	clr.w	spr_num(a0)
.e2	rts

.s1	subq.w	#1,spr_num(a0)
	tst.w	spr_num(a0)
	bpl.s	.e3
	move.w	#4-1,spr_num(a0)
.e3	rts

.animate_home1	move.w	#2-1,spr_num(a0)
	not.w	spr_x_flag(a0)
	tst.w	spr_x_flag(a0)
	beq.s	.s2
	move.w	#3-1,spr_num(a0)
.s2	rts

.animate_home2	move.w	#4-1,spr_num(a0)
	not.w	spr_x_flag(a0)
	tst.w	spr_x_flag(a0)
	beq.s	.s3
	move.w	#5-1,spr_num(a0)
.s3	rts

.animate_home3	move.w	#6-1,spr_num(a0)
	not.w	spr_x_flag(a0)
	tst.w	spr_x_flag(a0)
	beq.s	.s4
	move.w	#7-1,spr_num(a0)
.s4	rts

.animate_trace	not.w	spr_x_flag(a0)
	tst.w	spr_x_flag(a0)
	beq.s	.s5

	tst.b	force_front_rear_flag
	bne.s	.s6

	addq.w	#1,spr_num(a0)
	cmp.w	#4-1,spr_num(a0)
	blt.s	.s5
	clr.w	spr_num(a0)
.s5	rts

.s6	subq.w	#1,spr_num(a0)
	tst.w	spr_num(a0)
	bpl.s	.s7
	move.w	#4-1,spr_num(a0)
.s7	rts

move_beam

x	set	0
	rept	num_beams
	lea	beam_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.table(pc),a1
	add.w	d0,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+sprite_size
	endr
.return	rts

.table	dc.l	.return
	dc.l	.move
	dc.l	.move
	dc.l	.move

.move
;	cmp.l	#beam_struct+(sprite_size*num_beams),a0
;	bge.s	.return

	tst.w	spr_die_flag(a0)
	bne	.no_beam_move

	move.w	#-1,spr_move_flag(a0)

	move.w	spr_move_dir(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.beam_move_tab(pc,d0.w),a1
	jmp	(a1)

.beam_move_tab	dc.l	.move_left_to_right

	dc.l	.move_up_right
	dc.l	.move_down_right

	dc.l	.move_up
	dc.l	.move_down

	dc.l	.move_right_to_left

; homing missiles
	dc.l	.home_up
	dc.l	.home_down

	dc.l	.move_bounce_horizontal
	dc.l	.move_bounce_diag
	dc.l	move_trace


.home_up
	;move.w	spr_y_move_val(a0),d0	
	subq.w	#2,y1(a0)
	cmp.w	#-16,y1(a0)
	bgt.s	.s9
	move.w	#-16,y1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s9
	subq.w	#1,spr_y_cnt(a0)
	tst.w	spr_y_cnt(a0)
	bpl.s	.home_set1
	clr.w	spr_move_dir(a0)
	move.w	#2,spr_num(A0)
	move.w	#3,spr_anim_val(a0)
	clr.w	spr_type(a0)
.home_set1
	rts

.home_down	;move.w	spr_y_move_val(a0),d0	
	addq.w	#2,y1(a0)
	cmp.w	#216,y1(a0)
	blt.s	.s10
	move.w	#216,y1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s10
	subq.w	#1,spr_y_cnt(a0)
	tst.w	spr_y_cnt(a0)
	bpl.s	.home_set2
	clr.w	spr_move_dir(a0)
	move.w	#2,spr_num(A0)
	move.w	#3,spr_anim_val(a0)
	clr.w	spr_type(a0)
.home_set2
	rts

.move_left_to_right

	move.w	spr_x_move_val(a0),d0	
	add.w	d0,x1(a0)
	cmp.w	#320,x1(a0)
	blt.s	.s1
	move.w	#320,x1(a0)
	move.w	#3,status(a0)

	bra	die_check
.s1
	cmp.l	#homing_sprites,spr_ptr1(a0)
	beq	home_check
	rts

.move_up_right
	move.w	spr_x_move_val(a0),d0	
	add.w	d0,x1(a0)
	cmp.w	#320,x1(a0)
	blt.s	.s2
	move.w	#320,x1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s2

	move.w	spr_y_move_val(a0),d0	
;	lsr.w	#2,d0	; /4
	sub.w	d0,y1(a0)

	cmp.w	#2,force_struct+spr_move_mode
	bne.s	.n1
	tst.b	force_y_flag
	beq.s	.n1
	sub.w	d0,y1(a0)
.n1

	cmp.w	#0,y1(a0)
	bgt.s	.s3
	move.w	#0,y1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s3
	rts

.move_down_right
	move.w	spr_x_move_val(a0),d0	
	add.w	d0,x1(a0)
	cmp.w	#320,x1(a0)
	blt.s	.s4
	move.w	#320,x1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s4
	move.w	spr_y_move_val(a0),d0	
;	lsr.w	#2,d0
	add.w	d0,y1(a0)

	cmp.w	#2,force_struct+spr_move_mode
	bne.s	.n2

	tst.b	force_y_flag
	bne.s	.n2
	add.w	d0,y1(a0)
.n2
	cmp.w	#200,y1(a0)
	blt.s	.s5
	move.w	#200,y1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s5
	rts

.move_up	move.w	spr_y_move_val(a0),d0	
	sub.w	d0,y1(a0)
	cmp.w	#0,y1(a0)
	bgt.s	.s6
	move.w	#0,y1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s6
	rts

.move_down
	move.w	spr_y_move_val(a0),d0	
	add.w	d0,y1(a0)
	cmp.w	#200,y1(a0)
	blt.s	.s7
	move.w	#200,y1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s7
	rts

.move_right_to_left
	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d1
	lsl.w	#5,d1
	add.w	d1,a1

	move.w	8(a1),d1
	neg.w	d1

	move.w	spr_x_move_val(a0),d0	
	sub.w	d0,x1(a0)
	move.w	x1(a0),d0

	cmp.w	d1,d0
	bgt.s	.s8
	move.w	d0,x1(a0)
	move.w	#3,status(a0)

	bra	die_check
.s8
	rts

.move_bounce_horizontal
	tst.w	spr_x_flag(a0)
	beq	.s_5

	move.w	spr_x_move_val(a0),d0	
	add.w	d0,x1(a0)
	subq.w	#1,x1(a0)
	cmp.w	#320,x1(a0)
	blt.s	.s_6
	move.w	#320,x1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s_5

	move.w	spr_x_move_val(a0),d0	
	sub.w	d0,x1(a0)
	cmp.w	#-32,x1(a0)
	bgt.s	.s_6
	move.w	#-32,x1(a0)
	move.w	#3,status(a0)
	bra	die_check
.s_6	rts

.move_bounce_diag
;	cmp.w	#1,scroll_cnt
;	bne.s	.skip2
;	move.w	#15,spr_y_move_val(a0)
;.skip2

	move.w	diag_move(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.diag_tab(pc,d0.w),a1
	jmp	(a1)

.diag_tab	dc.l	.up_left
	dc.l	.up_right
	dc.l	.down_right
	dc.l	.down_left

.up_left
;	cmp.w	#1,scroll_cnt
;	bne.s	.no_scroll1
;	addq.w	#1,x1(a0)
;.no_scroll1
	move.w	spr_x_move_val(a0),d1
	sub.w	d1,x1(a0)
;	addq.w	#1,x1(a0)
	move.l	#bounce_sprites_gfx3,spr_gfx_addr(a0)
	bsr	bounce_and_map
	move.w	spr_y_move_val(a0),d1
	sub.w	d1,y1(a0)
.e1	bra	.edge_check

.up_right	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll2
	subq.w	#2,x1(a0)
.no_scroll2	move.w	spr_x_move_val(a0),d1
	add.w	d1,x1(a0)
	move.l	#bounce_sprites_gfx2,spr_gfx_addr(a0)
	bsr	bounce_and_map
	move.w	spr_y_move_val(a0),d1
	sub.w	d1,y1(a0)
	bra	.edge_check

.down_right	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll3
	subq.w	#2,x1(a0)
.no_scroll3	move.w	spr_x_move_val(a0),d1
	add.w	d1,x1(a0)
	move.l	#bounce_sprites_gfx3,spr_gfx_addr(a0)
	bsr	bounce_and_map
	move.w	spr_y_move_val(a0),d1
	add.w	d1,y1(a0)
	bra	.edge_check

.down_left
;	cmp.w	#1,scroll_cnt
;	bne.s	.no_scroll4
;;	addq.w	#1,x1(a0)
;.no_scroll4

	move.w	spr_x_move_val(a0),d1
	sub.w	d1,x1(a0)
;	addq.w	#1,x1(a0)
	move.l	#bounce_sprites_gfx2,spr_gfx_addr(a0)
	bsr	bounce_and_map
	move.w	spr_y_move_val(a0),d1
	add.w	d1,y1(a0)

.edge_check	cmp.w	#-32,x1(a0)
	bgt.s	.j1
	move.w	#-32,x1(a0)
	move.w	#3,status(a0)
	bra.s	die_check
.j1
	cmp.w	#320,x1(a0)
	blt.s	.j2
	move.w	#320,x1(a0)
	move.w	#3,status(a0)
	bra.s	die_check
.j2
	cmp.w	#-32,y1(a0)
	bgt.s	.j3
	move.w	#-32,y1(a0)
	move.w	#3,status(a0)
	bra.s	die_check
.j3
	cmp.w	#192,y1(a0)
	blt.s	.j4
	move.w	#192,y1(a0)
	move.w	#3,status(a0)
	bra.s	die_check
.j4	rts

.no_beam_move	move.w	#3,status(a0)	; beam die

die_check	subq.w	#1,die_cnt(a0)
	tst.w	die_cnt(a0)
	bpl.s	.s9
	move.w	#-1,die_cnt(a0)
	clr.w	status(a0)
	cmp.l	#circle_laser,spr_ptr1(a0)
	bne.s	.s9
	sf	circle_laser_flag
.s9	rts

move_trace	move.w	diag_move(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.diag_tab(pc,d0.w),a1
	jmp	(a1)

.diag_tab	dc.l	.up_left
	dc.l	.up_right
	dc.l	.down_right
	dc.l	.down_left

.up_left
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll1
	subq.w	#1,x1(a0)
.no_scroll1
	move.w	spr_x_move_val(a0),d1
;	sub.w	d1,x1(a0)


	bsr	trace_and_map
	move.w	spr_y_move_val(a0),d1
	sub.w	d1,y1(a0)
.e1	bra	.edge_check

.up_right	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll2
	subq.w	#1,x1(a0)
.no_scroll2	move.w	spr_x_move_val(a0),d1
	;add.w	d1,x1(a0)
	;addq.w	#1,x1(a0)
	bsr	trace_and_map
	move.w	spr_y_move_val(a0),d1
	sub.w	d1,y1(a0)
	bra	.edge_check

.down_right	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll3
	subq.w	#1,x1(a0)
.no_scroll3	move.w	spr_x_move_val(a0),d1
	;add.w	d1,x1(a0)
	;addq.w	#1,x1(a0)
	bsr	trace_and_map
	move.w	spr_y_move_val(a0),d1
	add.w	d1,y1(a0)
	bra	.edge_check

.down_left
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll4
	subq.w	#1,x1(a0)
.no_scroll4

	move.w	spr_x_move_val(a0),d1
	;sub.w	d1,x1(a0)

	bsr	trace_and_map
	move.w	spr_y_move_val(a0),d1
	add.w	d1,y1(a0)

.edge_check	cmp.w	#-32,x1(a0)
	bgt.s	.j1
	move.w	#-32,x1(a0)
	move.w	#3,status(a0)
	bra	die_check
.j1
	cmp.w	#320,x1(a0)
	blt.s	.j2
	move.w	#320,x1(a0)
	move.w	#3,status(a0)
	bra	die_check
.j2
	cmp.w	#-32,y1(a0)
	bgt.s	.j3
	move.w	#-32,y1(a0)
	move.w	#3,status(a0)
	bra	die_check
.j3
	cmp.w	#192,y1(a0)
	blt.s	.j4
	move.w	#192,y1(a0)
	move.w	#3,status(a0)
	bra	die_check
.j4	rts

.no_beam_move	move.w	#3,status(a0)	; beam die
	bra	die_check

trace_and_map
	move.l	d1,-(sp)
	move.l	d2,-(sp)

	move.w	#2-1,bullet_cnt2
.l0
	move.w	x1(A0),d0
	move.w	y1(a0),d1
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3
	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; add height

	move.l	map_buff_pos,a3

	moveq	#12-1,d7
.l2
	moveq	#6-1,d6

.l1	cmp.w	#0,tile_flag(a3)
	beq	.s1 

	movem.w	tile_x1(a3),d4/d5/a5/a6	; tile coords

.l3	cmp.w	a5,d0
	bgt	.s1
	cmp.w	a6,d1
	bgt	.s1
	cmp.w	d4,d2
	blt	.s1
	cmp.w	d5,d3
	blt	.s1

	subq.w	#1,spr_x_cnt(a0)
	tst.w	spr_x_cnt(a0)
	bpl.s	.b1
	move.w	#-1,spr_x_cnt(a0)
	bra	.e1
.b1

	cmp.w	#1,diag_move(a0)
	bne.s	.skip1
	move.w	spr_x_move_val(a0),d1
	sub.w	d1,x1(a0)
	clr.w	diag_move(a0)
	move.w	#-1,spr_x_flag(a0)
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll1
	addq.w	#1,x1(a0)
.no_scroll1

	bra	.e1
.skip1	cmp.w	#2,diag_move(a0)
	bne.s	.skip2
	move.w	spr_x_move_val(a0),d1
	sub.w	d1,x1(a0)
	move.w	#3,diag_move(a0)
	move.w	#-1,spr_x_flag(a0)
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll2
	addq.w	#1,x1(a0)
.no_scroll2
	bra	.e1

.skip2


	cmp.w	#0,diag_move(a0)
	bne.s	.skip3
	move.w	spr_x_move_val(a0),d1
	add.w	d1,x1(a0)
	move.w	#1,diag_move(a0)
	move.w	#-1,spr_x_flag(a0)
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll3
	subq.w	#1,x1(a0)
.no_scroll3
	bra	.e1
.skip3	cmp.w	#3,diag_move(a0)
	bne.s	.skip4
	move.w	spr_x_move_val(a0),d1
	add.w	d1,x1(a0)
	move.w	#2,diag_move(a0)
	move.w	#-1,spr_x_flag(a0)
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll4
	subq.w	#1,x1(a0)

.no_scroll4
	bra	.e1
.skip4

.s1	lea	tile_size(a3),a3
	dbf	d6,.l1

.s2	lea	-(tile_size*6)+((tile_size*7)*2)(a3),a3
	dbf	d7,.l2

.s3
;	lea	sprite_size(a0),a0
	subq.w	#1,bullet_cnt2
	tst.w	bullet_cnt2
	bpl	.l0

.e1
	move.l	(sp)+,d2
	move.l	(sp)+,d1

	rts

bounce_and_map
	move.l	d1,-(sp)
	move.l	d2,-(sp)

	move.w	#2-1,bullet_cnt2
.l0
	move.w	x1(A0),d0
	move.w	y1(a0),d1
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3
	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; add height

	move.l	map_buff_pos,a3

	moveq	#12-1,d7
.l2
	moveq	#6-1,d6

.l1	cmp.w	#0,tile_flag(a3)
	beq	.s1 

	movem.w	tile_x1(a3),d4/d5/a5/a6	; tile coords

.l3	cmp.w	a5,d0
	bgt	.s1
	cmp.w	a6,d1
	bgt	.s1
	cmp.w	d4,d2
	blt	.s1
	cmp.w	d5,d3
	blt	.s1

	subq.w	#1,spr_x_cnt(a0)
	tst.w	spr_x_cnt(a0)
	bpl.s	.b1
	move.w	#-1,spr_x_cnt(a0)
	bra	.e1
.b1

	cmp.w	#1,diag_move(a0)
	bne.s	.skip1
	move.w	spr_x_move_val(a0),d1
	sub.w	d1,x1(a0)
	clr.w	diag_move(a0)
	move.l	#bounce_sprites_gfx3,spr_gfx_addr(a0)
	move.w	#-1,spr_x_flag(a0)
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll1
	addq.w	#1,x1(a0)
.no_scroll1

	bra	.e1
.skip1	cmp.w	#2,diag_move(a0)
	bne.s	.skip2
	move.w	spr_x_move_val(a0),d1
	sub.w	d1,x1(a0)
	move.w	#3,diag_move(a0)
	move.l	#bounce_sprites_gfx2,spr_gfx_addr(a0)
	move.w	#-1,spr_x_flag(a0)
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll2
	addq.w	#1,x1(a0)
.no_scroll2
	bra	.e1

.skip2


	cmp.w	#0,diag_move(a0)
	bne.s	.skip3
	move.w	spr_x_move_val(a0),d1
	add.w	d1,x1(a0)
	move.w	#1,diag_move(a0)
	move.l	#bounce_sprites_gfx2,spr_gfx_addr(a0)
	move.w	#-1,spr_x_flag(a0)
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll3
	subq.w	#1,x1(a0)
.no_scroll3
	bra	.e1
.skip3	cmp.w	#3,diag_move(a0)
	bne.s	.skip4
	move.w	spr_x_move_val(a0),d1
	add.w	d1,x1(a0)
	move.w	#2,diag_move(a0)
	move.l	#bounce_sprites_gfx3,spr_gfx_addr(a0)
	move.w	#-1,spr_x_flag(a0)
	cmp.w	#1,scroll_cnt
	beq.s	.no_scroll4
	subq.w	#1,x1(a0)

.no_scroll4
	bra	.e1
.skip4

.s1

	lea	tile_size(a3),a3
	dbf	d6,.l1

.s2	lea	-(tile_size*6)+((tile_size*7)*2)(a3),a3
	dbf	d7,.l2

.s3
;	lea	sprite_size(a0),a0
	subq.w	#1,bullet_cnt2
	tst.w	bullet_cnt2
	bpl	.l0

.e1
	move.l	(sp)+,d2
	move.l	(sp)+,d1

	rts

home_check	clr.w	pop_flag1

x	set	0
	rept	num_baddies
	tst.w	pop_flag1
	bmi	.return
	lea	baddie_struct+x,a1
	move.w	status(a1),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	.tab(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)

x	set	x+sprite_size
	endr

.return	rts

.tab	dc.l	.return
	dc.l	.check_it
	dc.l	.check_it
	dc.l	.return

.check_it	;tst.w	spr_x_cnt(a0)
	;bmi.s	.return
	tst.w	spr_die_flag(a1)
	bmi.s	.return
	cmp.w	#-2,spr_energy(a1)
	beq.s	.return

; missile
	move.w	x1(a0),d0
	move.w	y1(a0),d1
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; add height

; baddie

	move.w	x1(a1),d4
	move.w	y1(a1),d5

	move.l	spr_ptr1(a1),a2
	addq.w	#6,a2

	move.w	spr_num(a1),d6
	lsl.w	#5,d6
	add.w	d6,a2

	move.w	d4,d6
	move.w	d5,d7
	add.w	8(a2),d6	; width in pixels
	add.w	12(a2),d7	; height

	tst.w	spr_y_flag(a0)
	bmi.s	.s2

;	moveq	#0,d0
	moveq	#0,d1

	cmp.w	d6,d0	x2,x1
	bgt.s	.s1
	cmp.w	d7,d1	y2,y1
	bgt.s	.s1

	cmp.w	d4,d2	x1,x2
	blt.s	.s1
	cmp.w	d5,d3	y1,y2
	blt.s	.s1
	move.w	#3,spr_num(a0)

	move.w	#3,spr_move_dir(a0)
	move.w	#4,spr_anim_val(a0)
;	move.w	#-1,spr_x_cnt(a0)

	move.w	#-1,pop_flag1
.s1	rts

.s2
;	moveq	#0,d0
;	moveq	#0,d1

	move.w	#320-1,d3

	cmp.w	d6,d0	x2,x1
	bgt.s	.s3
	cmp.w	d7,d1	y2,y1
	bgt.s	.s3

	cmp.w	d4,d2	x1,x2
	blt.s	.s3
	cmp.w	d5,d3	y1,y2
	blt.s	.s3

	move.w	#5,spr_num(a0)

	move.w	#4,spr_move_dir(a0)
	move.w	#5,spr_anim_val(a0)
;	move.w	#-1,spr_x_cnt(a0)

	move.w	#-1,pop_flag1
.s3	rts


do_homing_missiles
	tst.b	homing_flag
	beq	.beam_return1

	tst.w	homing_cnt
	bpl	.beam_return1
	move.w	#-1,homing_cnt

; set-up 2 missiles
	move.w	#2-1,.home_cnt

	clr.w	pop_flag1
x	set	0
	rept	num_beams
	tst.w	pop_flag1
	bne	.beam_return1
	lea	beam_struct+x,a0
	move.w	status(a0),d1
	add.w	d1,d1
	add.w	d1,d1

	lea	.table(pc),a1
	add.w	d1,a1
	move.l	(a1),a1


	jsr	(a1)
x	set	x+sprite_size
	endr

.beam_return1	rts

.table	dc.l	.set_up_homing	; dead
	dc.l	.return	; born
	dc.l	.return	; alive
	dc.l	.return	; dying

.set_up_homing
;	cmp.l	#beam_struct+(sprite_size*num_beams),a0
;	bge	.return
	move.w	#40-1,homing_cnt
	move.w	#18,spr_type(a0)

	move.w	#2,status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)

	move.w	#6,spr_move_dir(a0)	; home up
	clr.w	spr_die_flag(a0)
	move.w	#14-4,spr_x_move_val(a0)	; pixels to move
	move.w	#14-4-2,spr_y_move_val(a0)	; pixels to move
	clr.w	spr_move_flag(a0)
;	move.w	#1,spr_anim_val(a0)

	clr.w	hit_flag(a0)
	move.w	#-1,hit_count(a0)

	move.w	#1,spr_power(a0)

	move.l	#homing_sprites,spr_ptr1(a0)

	clr.w	spr_num(a0)

	move.w	player_struct+x1,d1
	add.w	#(32/2)-8,d1
	move.w	d1,x1(a0)

	move.w	player_struct+y1,d1
	move.w	d1,y1(a0)

	clr.w	spr_move_flag(a0)
	clr.w	spr_anim_val(a0)
; use a software rout for this beam

	move.w	#-1,spr_rout_flag(a0)

	movem.l	.homing_tab(pc),d1-d6
	movem.l	d1-d6,spr_skew_tab(a0)

	move.w	#8-1,spr_y_cnt(a0)
	clr.w	spr_y_flag(a0)

	clr.w	spr_x_flag(a0)
;	clr.w	spr_x_cnt(a0)

	subq.w	#1,.home_cnt
	tst.w	.home_cnt
	bpl.s	.return
	move.w	#-1,.home_cnt
	move.w	#-1,spr_y_flag(a0)
	move.w	#7,spr_move_dir(a0)	; home down

	move.w	#-1,pop_flag1	; pop address off stack

.return	rts

.homing_tab	dc.l	mul_16x16_4_bpl
	dc.l	0
	dc.l	restore_16x16
	dc.l	draw_16x16_4_bpl
	dc.l	homing_sprites_gfx
	dc.l	turret_mul_tab

.home_cnt	dc.w	0

do_animation	bsr	animate_power
	bsr	animate_force
	bsr	animate_pods
	bsr	animate_boost
	bsr	animate_beam

	jsr	animate_baddies
	jsr	animate_bullets
	bsr	animate_pickup
	bsr	do_speed_up_anim
	rts

animate_pickup
x	set	0
	rept	num_pickup
	lea	pickup_struct+x,a0
	move.w	pickup_type(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jsr	(a1)
x	set	x+sprite_size
	endr
	rts

.table	dc.l	.s1
	dc.l	.s1
	dc.l	.s1
	dc.l	.s1
	dc.l	.s1
	dc.l	.s1
	dc.l	.do_it

.do_it	subq.w	#1,pick_pod_cnt
	tst.w	pick_pod_cnt
	bpl.s	.s1
	move.w	#1,pick_pod_cnt

	addq.w	#1,spr_num(a0)
	cmp.w	#11,spr_num(a0)
	ble.s	.s1
	clr.w	spr_num(a0)
.s1	rts

animate_force	lea	force_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jmp	(a1)

.table	dc.l	.return
	dc.l	.animate
	dc.l	.animate
	dc.l	.animate

.animate	lea	player_struct,a1	; player dead?

	tst.b	attached_flag	; force attached to ship?
	beq	.n1
	sf	force_offset_flag

	move.w	x1(a1),d0

	tst.b	force_front_rear_flag
	beq.s	.j1

	add.w	#32,d0
	bra.s	.j2

.j1	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d1
	lsl.w	#5,d1
	add.w	d1,a2

	sub.w	8(a2),d0

.j2	move.w	d0,x1(a0)

	move.w	y1(a1),d0
	tst.w	die_flag(a1)
	beq.s	.s4
	addq.w	#8,d0
.s4

	cmp.w	#2,force_power
	bne.s	.n2
	subq.w	#3,d0

;	clr.w	spr_num(a0)
	move.l	#force_med_sprites1,spr_ptr1(a0)
	tst.b	force_front_rear_flag
	bne.s	.n2
	move.l	#force_med_sprites2,spr_ptr1(a0)
	subq.w	#2,x1(a0)
	bra.s	.n3
.n2
	cmp.w	#3,force_power
	bne.s	.n3

	tst.b	force_front_rear_flag
	beq.s	.j3
	subq.w	#2,x1(a0)
.j3
	subq.w	#6,d0
	cmp.l	#force_high_sprites3,spr_ptr1(a0)
	bne.s	.n3
	addq.w	#3,x1(a0)
	subq.w	#3,d0
.n3	move.w	d0,y1(a0)
	bra.s	.n5

.n1
	cmp.w	#2,force_power
	bne.s	.n4
	tst.b	force_offset_flag
	bne.s	.n5
	st	force_offset_flag
	subq.w	#3,y1(a0)
	bra.s	.n5
.n4
	cmp.w	#3,force_power
	bne.s	.n5
	tst.b	force_offset_flag
	bne.s	.n5
	st	force_offset_flag
	subq.w	#6,y1(a0)
	cmp.l	#force_high_sprites3,spr_ptr1(a0)
	bne.s	.n5
	subq.w	#3,y1(a0)
.n5
	
	subq.w	#1,force_cnt
	tst.w	force_cnt
	bpl.s	.return
	move.w	#1,force_cnt

	tst.b	force_dir
	beq.s	.s2

	subq.w	#1,spr_num(a0)
	cmp.w	#0,spr_num(a0)
	bge.s	.return
	move.l	spr_ptr1(a0),a2
	move.w	4(a2),spr_num(a0)
	bra.s	.return

.s2	addq.w	#1,spr_num(a0)

	move.w	spr_num(a0),d0
	move.l	spr_ptr1(a0),a2
	move.w	4(a2),d1

	cmp.w	d1,d0
	ble.s	.return
	clr.w	spr_num(a0)

.return	rts


animate_pods	bsr	animate_pod1
	bsr	animate_pod2
	rts

animate_pod1	lea	pod_struct1,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.look_up(pc,d0.w),a1
	jmp	(a1)

.look_up	dc.l	.s1
	dc.l	.animate
	dc.l	.animate
	dc.l	.animate

.animate	lea	pod_move_table1+4,a1
	lea	-4(a1),a2
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+

; align pod 1 to players ship
	move.w	player_struct+x1,d0
	move.w	player_struct+y1,d1
	addq.w	#8,d0
	sub.w	#14+12,d1
	tst.b	player_dead
	beq.s	.n1
	addq.w	#8,d1
.n1	move.w	d0,pod_move_table1+(4*3)
	move.w	d1,pod_move_table1+(4*3)+2
	move.w	pod_move_table1,x1(a0)
	move.w	pod_move_table1+2,y1(a0)

; animate it
	subq.w	#1,pod_cnt1
	tst.w	pod_cnt1
	bpl.s	.s1
	move.w	#1,pod_cnt1

	subq.w	#1,spr_num(a0)
	cmp.w	#0,spr_num(a0)
	bge.s	.s1
	move.w	#11,spr_num(a0)
.s1	rts

animate_pod2	lea	pod_struct2,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.look_up(pc,d0.w),a1
	jmp	(a1)

.look_up	dc.l	.s1
	dc.l	.animate
	dc.l	.animate
	dc.l	.animate

.animate	lea	pod_move_table2+4,a1
	lea	-4(a1),a2
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+
	move.l	(a1)+,(a2)+

; align pod 2 to players ship
	move.w	player_struct+x1,d0
	move.w	player_struct+y1,d1
	addq.w	#8,d0
	add.w	#14+12,d1
	tst.b	player_dead
	beq.s	.n1
	subq.w	#8,d1
.n1	move.w	d0,pod_move_table2+(4*3)
	move.w	d1,pod_move_table2+(4*3)+2
	move.w	pod_move_table2,x1(a0)
	move.w	pod_move_table2+2,y1(a0)

; animate it
	subq.w	#1,pod_cnt2
	tst.w	pod_cnt2
	bpl.s	.s1
	move.w	#1,pod_cnt2

	addq.w	#1,spr_num(a0)
	cmp.w	#11,spr_num(a0)
	ble.s	.s1
	clr.w	spr_num(a0)
.s1	rts

animate_power	lea	power_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jmp	(a1)

.table	dc.l	.return
	dc.l	.animate
	dc.l	.animate
	dc.l	.return

.animate	move.w	player_struct+x1,d0
	add.w	#32,d0
	tst.b	attached_flag	; force attached to ship?
	beq.s	.s1
	tst.b	force_front_rear_flag
	beq.s	.s1
	lea	force_struct,a1
	move.l	spr_ptr1(a1),a2
	addq.w	#6,a2
	move.w	spr_num(a1),d1
	lsl.w	#5,d1
	add.w	d1,a2

	add.w	8(a2),d0
	subq.w	#2,d0
	cmp.w	#1,force_power
	beq.s	.s1
	subq.w	#8,d0
.s1	move.w	d0,x1(a0)

	move.w	player_struct+y1,d0
	subq.w	#7,d0
	move.w	d0,y1(a0)

	subq.w	#1,power_cnt
	tst.w	power_cnt
	bpl.s	.return
	move.w	#1,power_cnt

	addq.w	#1,spr_num(a0)
	cmp.w	#8,spr_num(a0)
	blt.s	.return
	clr.w	spr_num(a0)
.return	rts

animate_boost	lea	boost_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jmp	(a1)

.table	dc.l	.return
	dc.l	.animate
	dc.l	.animate
	dc.l	.return

.animate	move.w	player_struct+x1,d0
	sub.w	#29,d0
	move.w	d0,x1(a0)

	move.w	player_struct+y1,d0
	subq.w	#8,d0
	move.w	d0,y1(a0)

	addq.w	#1,spr_num(a0)
	cmp.w	#3,spr_num(a0)
	ble.s	.return
	clr.w	spr_num(a0)
.return	rts


scroll_screen	moveq	#0,d0
	move.w	scroll_cnt,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.scr_tab(pc,d0.w),a0
	jmp	(a0)

.scr_tab	dc.l	.scroll
	dc.l	.pause

.scroll	addq.w	#1,scroll_offset
	cmp.w	#320+(16*4)-16,scroll_offset
	blt.s	.s1
	clr.w	scroll_offset
.s1
	move.w	scroll_offset,d0
	and.w	#-16,d0
	lsr.w	#1,d0
	move.w	d0,word_inc

	addq.l	#1,level_offset

	tst.b	scroll_flag	; done check
	bne	.n2	; n1

	move.l	level_offset,d0
	move.l	boss_offset,d1
	sub.w	#64*4,d1	; check for boss zik (lev 1)

	cmp.w	#2,stage
	bne.s	.no_lev2
	sub.w	#32,d1
.no_lev2

	cmp.l	d1,d0
	blt	.n0

; change palette for boss
	move.w	stage,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	pal_change_tab(pc),a0
	add.w	d0,a0
	move.l	(a0),a0
	jsr	(a0)

	tst.b	boss_tune_flag
	bne.s	.no_reinit
	move.w	#1,tune_num
	jsr	stop_music
	move.w	#2,tune_num
	jsr	init_music
.no_reinit	st	boss_tune_flag

.n0

	move.l	level_offset,d0
	move.l	boss_offset,d1
	cmp.l	d1,d0
	blt.s	.n1
	move.w	#1,scroll_cnt

; fix bounce lazer bug? (scrolling to no-scrolling midway)
	lea	beam_struct,a0
	moveq	#num_beams-1,d0
.change_loop	cmp.w	#0,status(a0)
	beq.s	.change_skip
	cmp.w	#16,spr_type(a0)	; trace
	beq.s	.change_x
	cmp.w	#17,spr_type(a0)
	beq.s	.change_x
	cmp.w	#19,spr_type(a0)	; bounce
	beq.s	.change_x
.change_skip	lea	sprite_size(a0),a0
	dbf	d0,.change_loop

.n1	rts

.change_x	move.w	#15,spr_x_move_val(a0)
	bra.s	.change_skip

.n2	subq.w	#1,boss_die_offset
	rts

.pause	move.w	#2000,boss_score	; killed boss score
	subq.w	#1,scroll_pause
	tst.w	scroll_pause
	bpl.s	.return
	cmp.w	#6,stage
	beq.s	.stage_6
	clr.w	boss_score	; timed out score
.stage_6

	move.w	#-1,scroll_pause

;	cmp.w	#1,stage
	cmp.w	#2,stage
	beq.s	.return2
	cmp.w	#3,stage
	beq.s	.return2
	cmp.w	#4,stage
	beq.s	.return2
	cmp.w	#5,stage
	beq.s	.return2
	cmp.w	#6,stage
	beq.s	.return2
	cmp.w	#7,stage
	beq.s	.return2
	cmp.w	#8,stage
	beq.s	.return3

	clr.w	scroll_cnt
	st	scroll_flag
;	move.w	#1-1,map_cnt
;	sub.w	#8*16,map_add

.return	rts

.return2	st	stage_clear_flag
	rts


.return3	lea	baddie_struct,a0
	moveq	#num_baddies-1,d0
.l1	cmp.w	#0,status(a0)
	beq.s	.s2
	cmp.w	#23,spr_type(a0)
	bne.s	.s2
	move.w	#17,spr_move_mode(a0)
.s2	lea	sprite_size(a0),a0
	dbf	d0,.l1
	rts

pal_change_tab	dc.l	.no_change

	dc.l	.set_pal_lvl_1
	dc.l	.set_pal_lvl_2
	dc.l	.no_change
	dc.l	.set_pal_lvl_4
	dc.l	.set_pal_lvl_5
	dc.l	.no_change
	dc.l	.no_change
	dc.l	.no_change

.set_pal_lvl_1	lea	level1_boss_pal,a0
	bsr.s	.copy_pal
	rts

.set_pal_lvl_2	lea	level2_boss_pal,a0
	bsr.s	.copy_pal
	rts

.set_pal_lvl_4	lea	level4_boss_pal,a0
	bsr.s	.copy_pal
	rts

.set_pal_lvl_5	lea	level5_boss_pal,a0
	bsr.s	.copy_pal
	rts

.copy_pal	lea	pal,a1
x	set	0
	rept	20
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,x(a1)
x	set	x+32+(2*9)
	endr

	lea	-32(a0),a0

	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,palbuff

.no_change	rts

offset_screen	moveq	#0,d0
	move.w	scroll_cnt,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.scr_tab(pc,d0.w),a0
	jmp	(a0)

.scr_tab	dc.l	.scroll
	dc.l	.pause

.scroll	move.w	scroll_offset,d0
	add.w	#(16*3),d0
	and.w	#16-1,d0
	
	bne.s	.fix

	add.w	#8*16,map_add
	subq.w	#1,map_cnt

	move.b	#92+(8*2),line_width	8*3
	bra.s	.fix2
.fix
	move.b	#88+(8*2),line_width
.fix2
	move.w	d0,scroll_skew
	move.b	d0,fine_offset

.pause	rts

init_screens	lea	back_scrn+(376*64)+(8*3),a3
	bsr	draw_stage

	jsr	clearscreen
	rept	2
	move.l	screen1,a3
	lea	(376*64)+(8*3)(a3),a3
	jsr	draw_stage
	jsr	vsync
	jsr	swap_screens
	endr
	add.l	#(12*12)*4,map_pos
	rts

install_ints	move.w	#$2700,sr
	lea	old_ints,a0
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa0f.w,(a0)+
	move.b	$fffffa11.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa1b.w,(a0)+
	move.b	$fffffa21.w,(a0)+
	move.l	#hbl,$68.w
	move.l	#vbl,$70.w
	move.l	#keyvector,$118.w
	move.l	#status_tb,$120.w
	move.b	#%00000001,$fffffa07.w	; timer a/b
	move.b	#%01000000,$fffffa09.w	; keyboard
	move.b	#%00000001,$fffffa13.w	; timer a/b
	move.b	#%01000000,$fffffa15.w	; keyboard
	bclr	#3,$fffffa17.w
	move.w	#$2300,sr
	rts

restore_ints
	move.w	#$2700,sr
	lea	old_ints,a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa0f.w
	move.b	(a0)+,$fffffa11.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa1b.w
	move.b	(a0)+,$fffffa21.w
	move.b	#$c0,$fffffa23.w	; fix key repeat
	jsr	flush
	move.w	#$2300,sr
	rts


keyvector	move.w	sr,-(sp)
	move.w	d0,-(sp) 

;	move.w	#$2500,sr

	clr.w	d0

.l1	move.b	$fffffc00.w,d0
	btst	#$7,d0
	beq.s	.s1
	move.b	$fffffc02.w,d0

	tst.b	joy1_flag 
	bne.s	.s2 
	tst.b	joy2_flag 
	bne.s	.s4 

	cmp.b	#$fe,d0 
	beq.s	.s3 
	cmp.b	#$ff,d0 
	beq.s	.s7 

	tst.b	d0
	bmi.s	.s6 

	move.b	d0,kbuff

.j1	btst	#4,$fffffa01.w 
	beq.s	.l1 
.s1
	move.w	(sp)+,d0
	move.w	(sp)+,sr 

	bclr	#6,$fffffa11.w
	rte

.s2	move.b	d0,joy1_status 
	sf	joy1_flag 
	bra.s	.l1

.s4	;move.b	d0,joy2_status 
	sf	joy2_flag
	bra	.l1

.s7	st	joy1_flag 
	bra	.l1

.s3	st	joy2_flag 
	bra	.l1

.s6	sf	kbuff 
	bra.s	.j1

draw_status_stuff
	tst.b	draw_score_flag
	bne.s	.e1
	jsr	draw_lives
	jsr	draw_beam_meter
	tst.b	paused_flag
	bne.s	.s1
	bsr	flash_1p
.s1	bsr	draw_score
	bsr	draw_hi_score
.e1	rts

flash_1p	tst.w	player_1_ind
	bpl.s	.s1
	lea	player_1_gfx,a0
	lea	status_panel+(160*9)+(8*1)+2,a1
x	set	0
	rept	7
	move.w	(a0)+,x(a1)
	move.w	(a0)+,x+8(a1)
x	set	x+160
	endr
	bra.s	.s2
.s1
	moveq	#0,d0
	lea	status_panel+(160*9)+(8*1)+2,a0
x	set	0
	rept	7
	move.w	d0,x(a0)
	move.w	d0,x+8(a0)
x	set	x+160
	endr
.s2
	subq.w	#1,player_1_cnt
	tst.w	player_1_cnt
	bpl.s	.s3
	move.w	#24-1,player_1_cnt

	not.w	player_1_ind

.s3	rts

player_1_gfx	DC.L	$18FE00,$38E300
	DC.L	$18E33F,$18E33F
	DC.L	$18FE00,$18E000
	DC.L	$3CE000

draw_score
;	tst.w	demo_mode
;	bne	.e1
	lea	status_panel+(160*9)+(8*3)+1,a2

	lea	total_score,a0
	bsr	hex_dec

	move.w	#7,.mod+2

	lea	dec_buff,a0

	sf	.flag	; 0

	moveq	#6-1,d7
.l1	move.w	(a0)+,d0

;
; check no zeros appear before score.
; i.e. 176500 instead of 0176500
;
	tst.b	.flag
	bne.s	.s1

	cmp.w	#0,d0	; is this digit > 0?
	bgt.s	.s1
	lea	blank_num,a1

	cmp.w	#0,d7	; have we gone through whole score
	bgt.s	.s2	; and reached the last digit?
	lea	numbers(pc),a1	; if yes print one '0'
	bra.s	.s2

.s1	st	.flag	; switch off '0' checking (d2=-1)

	lsl.w	#5,d0
	lea	numbers(pc),a1
	add.w	d0,a1
.s2
	movem.l	(a1)+,d0-d6
	movep.l	d0,(a2)
	movep.l	d1,160*1(a2)
	movep.l	d2,160*2(a2)
	movep.l	d3,160*3(a2)
	movep.l	d4,160*4(a2)
	movep.l	d5,160*5(a2)
	movep.l	d6,160*6(a2)

	opt	o-
.mod	add.w	#1,a2
	opt	o+
	eor.w	#6,.mod+2
	dbf	d7,.l1
.e1	rts

.flag	dc.b	0
	even

draw_hi_score
;	tst.w	demo_mode
;	bne	.e1
	lea	status_panel+(160*9)+(8*4)+(8*7),a2

	move.l	total_score,d0
	move.l	hi_score,d1
	cmp.l	d1,d0
	blt.s	.skip
	move.l	total_score,hi_score
.skip
	lea	hi_score,a0
	bsr	hex_dec

	move.w	#1,.mod+2

	lea	dec_buff,a0

	sf	.flag	; 0

	moveq	#6-1,d7
.l1	move.w	(a0)+,d0

;
; check no zeros appear before score.
; i.e. 176500 instead of 0176500
;
	tst.b	.flag
	bne.s	.s1

	cmp.w	#0,d0	; is this digit > 0?
	bgt.s	.s1
	lea	blank_num,a1

	cmp.w	#0,d7	; have we gone through whole score
	bgt.s	.s2	; and reached the last digit?
	lea	numbers(pc),a1	; if yes print one '0'
	bra.s	.s2

.s1	st	.flag	; switch off '0' checking (d2=-1)

	lsl.w	#5,d0
	lea	numbers(pc),a1
	add.w	d0,a1
.s2
	movem.l	(a1)+,d0-d6
	movep.l	d0,(a2)
	movep.l	d1,160*1(a2)
	movep.l	d2,160*2(a2)
	movep.l	d3,160*3(a2)
	movep.l	d4,160*4(a2)
	movep.l	d5,160*5(a2)
	movep.l	d6,160*6(a2)

	opt	o-
.mod	add.w	#1,a2
	opt	o+
	eor.w	#6,.mod+2
	dbf	d7,.l1
.e1	rts

.flag	dc.b	0
	even


numbers	DC.L	$FE0000FE,$E600E600
	DC.L	$C6C60000,$C6000000
	DC.L	$C6C60000,$CE00CE00
	DC.L	$FE0000FE,0
	DC.L	$30000030,$30003000
	DC.L	$30300000,$30000000
	DC.L	$30300000,$30003000
	DC.L	$30000030,0
	DC.L	$FE0000FE,$6000600
	DC.L	$6060000,$FE000000
	DC.L	$C0C00000,$C000C000
	DC.L	$FE0000FE,0
	DC.L	$FE0000FE,$6000600
	DC.L	$6060000,$FE000000
	DC.L	$6060000,$6000600
	DC.L	$FE0000FE,0
	DC.L	$CC0000CC,$CC00CC00
	DC.L	$CCCC0000,$CC000000
	DC.L	$FEFE0000,$C000C00
	DC.L	$C00000C,0
	DC.L	$FE0000FE,$C000C000
	DC.L	$C0C00000,$FE000000
	DC.L	$6060000,$6000600
	DC.L	$FE0000FE,0
	DC.L	$FE0000FE,$C000C000
	DC.L	$C0C00000,$FE000000
	DC.L	$C6C60000,$C600C600
	DC.L	$FE0000FE,0
	DC.L	$FE0000FE,$6000600
	DC.L	$6060000,$6000000
	DC.L	$6060000,$6000600
	DC.L	$6000006,0
	DC.L	$7C00007C,$C600C600
	DC.L	$C6C60000,$FE000000
	DC.L	$C6C60000,$C600C600
	DC.L	$FE0000FE,0
	DC.L	$FE0000FE,$C600C600
	DC.L	$C6C60000,$FE000000
	DC.L	$6060000,$6000600
	DC.L	$FE0000FE,0


hex_dec	move.l	(a0),d2
	cmp.l	#999999,d2	; dont exceed
	blt.s	.s1
	move.l	#999999,d2
.s1	move.l	d2,(a0)

	clr.l	dec_buff
	clr.l	dec_buff+4
	clr.l	dec_buff+8

	lea	hex_tab(pc),a0
	lea	dec_buff,a1 
.l1	move.l	(a0)+,d0 
	bmi.s	.e1 
	moveq	#0,d1 
.l2	addq.w	#1,d1 
	sub.l	d0,d2 
	bpl.s	.l2 
	add.l	d0,d2 
	subq.w	#1,d1 
	move.w	d1,(a1)+ 
	bra.s	.l1 
.e1	rts

hex_tab	;dc.l	$f4240
	dc.l	$186a0
	dc.l	$2710
	dc.l	$3e8
	dc.l	$64
	dc.l	$a
	dc.l	1
	dc.l	-1

draw_beam_meter
	move.w	beam_val,d0
	cmp.w	#56,d0
	blt.s	.s1
	moveq	#56,d0
	move.w	d0,beam_val
.s1	add.w	d0,d0
	add.w	d0,d0
	lea	beam_gfx_tab(pc),a0
	add.w	d0,a0
	move.l	(a0),a0

	lea	status_panel+(160*2)+(8*8)+2,a1

;	tst.w	demo_mode
;	bne	.e1

	movem.w	(a0),d0-d6

	move.w	d0,4(a1)
	move.w	d1,(8*1)+4(a1)
	move.w	d2,(8*2)+4(a1)
	move.w	d3,(8*3)+4(a1)
	move.w	d4,(8*4)+4(a1)
	move.w	d5,(8*5)+4(a1)
	move.w	d6,(8*6)+4(a1)

	move.w	d0,(160*1)+2(a1)
	move.w	d1,(160*1)+(8*1)+2(a1)
	move.w	d2,(160*1)+(8*2)+2(a1)
	move.w	d3,(160*1)+(8*3)+2(a1)
	move.w	d4,(160*1)+(8*4)+2(a1)
	move.w	d5,(160*1)+(8*5)+2(a1)
	move.w	d6,(160*1)+(8*6)+2(a1)

	move.w	d0,(160*2)(a1)
	move.w	d1,(160*2)+(8*1)(a1)
	move.w	d2,(160*2)+(8*2)(a1)
	move.w	d3,(160*2)+(8*3)(a1)
	move.w	d4,(160*2)+(8*4)(a1)
	move.w	d5,(160*2)+(8*5)(a1)
	move.w	d6,(160*2)+(8*6)(a1)

	move.w	d0,(160*3)+2(a1)
	move.w	d1,(160*3)+(8*1)+2(a1)
	move.w	d2,(160*3)+(8*2)+2(a1)
	move.w	d3,(160*3)+(8*3)+2(a1)
	move.w	d4,(160*3)+(8*4)+2(a1)
	move.w	d5,(160*3)+(8*5)+2(a1)
	move.w	d6,(160*3)+(8*6)+2(a1)

	move.w	d0,(160*4)+4(a1)
	move.w	d1,(160*4)+(8*1)+4(a1)
	move.w	d2,(160*4)+(8*2)+4(a1)
	move.w	d3,(160*4)+(8*3)+4(a1)
	move.w	d4,(160*4)+(8*4)+4(a1)
	move.w	d5,(160*4)+(8*5)+4(a1)
	move.w	d6,(160*4)+(8*6)+4(a1)
.e1	rts

beam_gfx_tab
x	set	0
	rept	56+1
	dc.l	beam_gfx+x
x	set	x+(2*7)
	endr

beam_gfx	incbin	beam_up.dat
	even

draw_lives
;	tst.w	demo_mode
;	bne	.e1

	movem.l	blank,d0-d7/a1-a2	; clear old lives before plotting!
	lea	status_panel+160,a0
x	set	0
	rept	7
	movem.l	d0-d7/a1-a2,x(a0)
x	set	x+160
	endr

	move.w	#7,.mod+2
	moveq	#0,d0
	move.w	lives,d0
	cmp.w	#0,d0
	ble.s	.e1

	cmp.w	#9-1,d0
	blt.s	.s1
	moveq	#10-1,d0	; max 8 lives *drawn*
.s1	subq.w	#2,d0
	cmp.w	#-1,d0
	beq.s	.e1

	movem.l	.lives_gfx(pc),d1-d7
	lea	status_panel+160+1,a1

.l1
	movep.l	d1,(a1)
	movep.l	d2,160*1(a1)
	movep.l	d3,160*2(a1)
	movep.l	d4,160*3(a1)
	movep.l	d5,160*4(a1)
	movep.l	d6,160*5(a1)
	movep.l	d7,160*6(a1)

	opt	o-
.mod	add.w	#7,a1
	opt	o+
	eor.w	#6,.mod+2
	dbf	d0,.l1

.e1	rts

.lives_gfx	dc.l	$30101000,$78787800,$fc787800,$fc000000,$fc000000,$b4484800,$484800

extra_life_check
	move.l	total_score,d0
	lea	.tab(pc),a0
	cmp.w	#1,difficulty
	bne.s	.s0
	lea	.hard_tab(pc),a0
.s0	add.w	extra_life_inc,a0
	cmp.l	#-1,(a0)
	beq.s	.s1
	move.l	(a0),d1
	cmp.l	d1,d0
	blt.s	.s1
	addq.w	#1,lives
	addq.w	#4,extra_life_inc

.s1	rts

.tab	dc.l	50000,150000,250000,400000,600000,-1
.hard_tab	dc.l	100000,200000,350000,500000,700000,-1

init_level_stuff
	moveq	#0,d0
	move.w	stage,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a0
	jmp	(a0)

.tab	dc.l	.do_nowt	;0
	dc.l	.stage1	;1-8
	dc.l	.stage2
	dc.l	.stage3
	dc.l	.stage4
	dc.l	.stage5
	dc.l	.stage6
	dc.l	.stage7
	dc.l	.stage8

.stage1	move.w	#(64*3)-16,boss_die_offset
	move.w	#50*2,boss_weak_cnt
	move.w	#lv1_boss_wait,scroll_pause
	lea	original_level1_pal,a0
	bsr	.copy_pal
.do_nowt	rts

.stage2	move.w	#(64*1)-16,boss_die_offset
	move.w	#(50*3)+25,boss_weak_cnt
	move.l	#lv2_boss_weak_tab,lv2_boss_weak_pos
	move.w	#lv2_boss_wait,scroll_pause
	lea	original_level2_pal,a0
	bsr	.copy_pal
	rts

.stage3
;	move.w	#(64*1)-16,boss_die_offset
	move.w	#-1,boss_weak_cnt
;	move.w	#(50*3)+25,boss_weak_cnt
;	move.l	#lv2_boss_weak_tab,lv2_boss_weak_pos
	move.w	#lv3_boss_wait,scroll_pause
	lea	original_level3_pal,a0
	bsr	.copy_pal
	rts

.stage4
;	move.w	#(64*1)-16,boss_die_offset
	move.w	#-1,boss_weak_cnt
;	move.l	#lv2_boss_weak_tab,lv2_boss_weak_pos
	move.w	#lv4_boss_wait,scroll_pause
	lea	original_level4_pal,a0
	bsr	.copy_pal
	rts

.stage5
;	move.w	#(64*1)-16,boss_die_offset
	move.w	#-1,boss_weak_cnt
;	move.l	#lv2_boss_weak_tab,lv2_boss_weak_pos
	move.w	#lv5_boss_wait,scroll_pause
	lea	original_level5_pal,a0
	bsr	.copy_pal
	rts

.stage6
;	move.w	#(64*1)-16,boss_die_offset
;	move.w	#(50*3)+25,boss_weak_cnt
;	move.l	#lv2_boss_weak_tab,lv2_boss_weak_pos
	move.w	#lv6_boss_wait,scroll_pause
	lea	original_level6_pal,a0
	bsr	.copy_pal
	rts

.stage7	;move.w	#(64*1)-16,boss_die_offset
	move.w	#-1,boss_weak_cnt
	;move.l	#lv2_boss_weak_tab,lv2_boss_weak_pos
	move.w	#lv7_boss_wait,scroll_pause
	lea	original_level7_pal,a0
	bsr	.copy_pal
	rts

.stage8
;	move.w	#(64*1)-16,boss_die_offset
	move.w	#-1,boss_weak_cnt
;	move.w	#(50*3)+25,boss_weak_cnt
;	move.l	#lv2_boss_weak_tab,lv2_boss_weak_pos
	move.w	#lv8_boss_wait,scroll_pause
	lea	original_level8_pal,a0
	bsr	.copy_pal
	rts

.copy_pal	lea	pal,a1
	moveq	#20-1,d7
.l1	movem.l	(a0)+,d0-d6/a2
	movem.l	d0-d6/a2,(a1)
	lea	32+(2*9)(a1),a1
	dbf	d7,.l1
	rts

init_stage	bsr	init_level_stuff

	clr.w	lv4_boss_x_offset
	clr.w	lvl_4_ex_cnt

	lea	lvl_4_boss_tab,a0
	rept	3
	clr.w	(a0)+
	clr.w	(a0)+
	clr.w	(a0)+
	clr.l	(a0)+
	endr

	move.w	#3-1,level4_cnt
	clr.w	eye_cnt
	move.w	#12,start_duct_cnt
	move.w	#5-1,duct_anim_cnt
	clr.w	duct_frame
	move.w	#(4*8)*3,duct_offset
	clr.w	duct_rout
	clr.w	trash_cnt
	clr.w	pump_cnt
	sf	duct_sfx_flag
	clr.w	tank_rout
	move.l	#tank_tab,tank_pos
	clr.w	tank_ind

	clr.w	lv7_boss_cnt
	move.w	#(128+164)-1,lv7_boss_wait_cnt
	move.l	#lv7_boss_tab,lv7_boss_pos

	move.w	#40-1,baby_start_cnt

	move.l	#bydo_sheild_tab,bydo_sheild_pos1_a
	move.l	#bydo_sheild_tab,bydo_sheild_pos2_a
	move.l	#bydo_sheild_tab_b,bydo_sheild_pos1_b
	move.l	#bydo_sheild_tab_b,bydo_sheild_pos2_b
	move.l	#bydo_tab,bydo_pos

	move.w	#2,spin_cnt
	move.w	#3,triff_fire_cnt1
	move.w	#3,triff_fire_cnt2
	clr.w	triff_fire_flag1
	clr.w	triff_fire_flag2
	clr.w	plant_flag
	clr.w	triff_gap_cnt

	move.w	#2-1,star_rest_cnt
	move.w	#2-1,demo_mode_rest_cnt
	move.w	#70-1,big_shot_cnt1
	move.w	#6-1,big_shot_cnt2	; number of sprites
	move.w	#6-1,big_shot_cnt3
	clr.w	boss_shot_dec
	clr.w	bounce_fire_cnt1
	clr.w	bounce_fire_cnt2
	clr.w	bounce_fire_cnt3
	clr.w	trace_fire_cnt2
	clr.w	trace_fire_cnt3
	move.w	#-1,bounce_coord_cnt
	move.w	#-1,trace_coord_cnt

	move.w	difficulty,bullet_cnt

	move.w	#320+8,gun_column_x1
	move.w	#320+8+40,gun_column_x2
	move.w	#320+8+(64*3)-8,gun_column_x3
	move.w	#320+8+40+(64*3)-8,gun_column_x4


	tst.w	demo_mode
	beq.s	.s1
	st	intro_done
	move.w	#4-1,restart_point

	move.l	level_point,a0
	lea	12+2+(4*7)(a0),a0
	move.l	(a0),restart_baddie_pos

;	move.l	#restart_tab1,restart_baddie_pos
	clr.w	restart_x_offset
.s1
	moveq	#0,d0
	moveq	#0,d1
	move.w	restart_point,d0
	move.l	d0,d1
	move.w	d0,tile_offset
	mulu	#64,d0
	add.l	#64*5,d0
	move.l	d0,level_offset

	mulu	#tile_size*12,d1

	move.l	level_point,a0
	lea	12+2+4+4(a0),a0
	move.l	(a0),a0
	addq.w	#6,a0

;	lea	map+6,a0
	add.l	d1,a0
	move.l	a0,map_pos	

;	tst.w	demo_mode
;	beq.s	.s2
;	move.l	#(64*5)+172,level_offset
;.s2

	clr.w	word_inc
	clr.w	scroll_skew
	clr.w	scroll_offset

	st	line_flag
	jsr	vsync
	clr.b	$fffff8265.w
	clr.b	$fffff820f.w

	clr.w	scroll_cnt
	sf	scroll_flag

	clr.w	map_add
;	move.w	#4-1,map_cnt

	move.w	#-1,map_cnt

;	move.l	#map+6,map_pos
	move.l	#map_buff+(12*6),map_buff_pos
;	move.l	#map_buff,map_buff_pos

	sf	fire_flag
	sf	ship_flag
	clr.w	beam_val

	move.l	#plr_gfx,plr_gfx_pos

;	lea	boost_struct,a0
;	clr.w	status(a0)

	
	sf	attached_flag	; force detached from ship
	sf	force_front_rear_flag
	cmp.w	#0,force_struct+status
	beq.s	.n1
	st	attached_flag	; force detached from ship
	st	force_front_rear_flag
.n1
	tst.w	game_init_flag
	bne.s	.n2
	clr.w	weapon_type
	clr.w	force_power
	move.w	set_lives,lives
	move.w	#2*2,plr_speed
	sf	homing_flag
	clr.w	bit_cnt

.n2

	sf	attach_sfx_flag
	st	force_x_flag	; make it the opposite direction
	sf	force_y_flag
	sf	circle_laser_flag
	sf	pause_adjust
	sf	map_end_flag
	sf	cheat_key_flag
	sf	boss_tune_flag
	sf	speed_up_flag
	sf	stage_clear_flag
	sf	chain_react_flag
	sf	boss_weak_flag1
	sf	escape_flag
;	sf	force_x_correct_flag
;	sf	force_y_correct_flag
	st	force_start_x_flag
	st	force_start_y_flag
	sf	bounce_coord_flag1
	sf	bounce_coord_flag2
	sf	bounce_coord_flag3
	sf	bounce_flag
	sf	trace_flag
	sf	trace_coord_flag2
	sf	trace_coord_flag3
;	sf	force_hit
	move.w	#-1,weapon_cnt
	move.w	#12,speed_up_cnt

	clr.w	boss_weak_anim_cnt
	move.w	#16-1,mouth_cnt
	move.w	#25-1,boss_chain_react_cnt1
	clr.w	boss_chain_react_cnt2

	clr.w	homing_cnt

	move.l	level_point,a0
	lea	12+2+(4*9)(a0),a0
	move.l	(a0),boss_explode_pos
	move.l	(a0),boss_explode_reset

	move.l	#status_panel,d0
	move.b	d0,status_addr+3
	lsr.l	#8,d0
	move.b	d0,status_addr+2
	lsr.w	#8,d0
	move.b	d0,status_addr+1
	
	rts

do_speed_up_anim
	tst.b	speed_up_flag
	beq.s	.s1

	tst.b	player_dead
	beq.s	.s0
	move.w	#12,speed_up_cnt
	sf	speed_up_flag
	move.w	#3,boost_struct+status
	bra.s	.s1
.s0
	subq.w	#1,speed_up_cnt
	tst.w	speed_up_cnt
	bpl.s	.s1
	move.w	#12,speed_up_cnt
	sf	speed_up_flag
	move.w	#3,boost_struct+status
.s1	rts


restart_baddie_pos
	dc.l	0	;restart_tab1

restart_x_offset
	dc.w	0

restart_pos	dc.l	0

boss_offset	dc.l	0

init_structures
	bsr	clear_structure_data

	move.w	#48,player_struct+x1
	move.w	#89,player_struct+y1

;	move.w	#-64,force_struct+x1
;	move.w	#-64,force_struct+y1
	clr.w	force_struct+hit_flag

	move.w	#-64,pod_struct1+x1
	move.w	#-64,pod_struct1+y1
	move.w	#-64,pod_struct2+x1
	move.w	#-64,pod_struct2+y1

	move.w	#-64,boost_struct+x1
	move.w	#-64,boost_struct+y1

	tst.w	game_init_flag
	bne.s	.s1

	bsr	init_player_structures

.s1

	lea	back_scrn,a0
	lea	beam_struct,a1
	moveq	#num_beams-1,d0
.l1	clr.w	status(a1)	; no force
	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	move.w	#2,rest_cnt(a1)
;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a1)	; source and target
	move.b	#%00000111,sprite_op(a1)	; source or target
	move.l	a0,back_ptr1(a1)
	move.l	a0,back_ptr2(a1)
	lea	sprite_size(a1),a1
	dbf	d0,.l1

	lea	back_scrn,a0
	lea	baddie_struct,a1
	moveq	#num_baddies-1,d0
.l2	clr.w	status(a1)	; no force
	move.w	#-1,spr_x_cnt(a1)	; grey wave
	move.w	#-1,spr_y_cnt(a1)	; grey wave
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)
	clr.w	die_flag(a1)
;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a1)	; source and target
	move.b	#%00000111,sprite_op(a1)	; source or target
	clr.l	old_width1(a1)
	clr.l	old_width2(a1)
	move.l	a0,back_ptr1(a1)
	move.l	a0,back_ptr2(a1)
	lea	sprite_size(a1),a1
	dbf	d0,.l2

	lea	back_scrn,a0
	lea	pickup_struct,a1
	moveq	#num_pickup-1,d0
.l3	clr.w	status(a1)	; no force
	move.w	#2,rest_cnt(a1)
;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a1)	; source and target
	move.b	#%00000111,sprite_op(a1)	; source or target
	move.l	a0,back_ptr1(a1)
	move.l	a0,back_ptr2(a1)
	lea	sprite_size(a1),a1
	dbf	d0,.l3

	lea	back_scrn,a0
	lea	bullet_struct,a1
	moveq	#num_bullets-1,d0
.l4	clr.w	status(a1)	; no force
	move.w	#2,rest_cnt(a1)
;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a1)	; source and target
	move.b	#%00000111,sprite_op(a1)	; source or target
	move.l	a0,back_ptr1(a1)
	move.l	a0,back_ptr2(a1)
	lea	sprite_size(a1),a1
	dbf	d0,.l4

	rts

init_player_structures
	lea	player_struct,a0
	move.w	#2,status(a0)	; player's alive
	move.w	#48,x1(a0)		; x1
	move.w	#89,y1(a0)		; y1
	move.w	#50*2,born_cnt(a0)
	clr.w	born_flag(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)
	clr.w	die_flag(a0)
	move.l	#player_sprites,spr_ptr1(a0)	; data block
	move.w	#3-1,spr_num(a0)	; sprite number


;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a0)	; source or target
	move.b	#%00000111,sprite_op(a0)	; source and target
	clr.w	spr_mask_flag(a0)
	move.l	#back_scrn,back_ptr1(a0)
	move.l	#back_scrn,back_ptr2(a0)


	lea	force_struct,a0
	clr.w	status(a0)	; no force
	move.w	#-20,x1(a0)	; -20
	move.w	#96,y1(a0)
	cmp.w	#4,stage
	bne.s	.no_y_set
	move.w	#(16*4)+8,y1(a0)
.no_y_set

	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)
	clr.w	die_flag(a0)
	clr.w	spr_move_mode(a0)
	move.w	#4,spr_power(a0)
;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a0)	; source and target
	move.b	#%00000111,sprite_op(a0)	; source or target
	move.l	#back_scrn,back_ptr1(a0)
	move.l	#back_scrn,back_ptr2(a0)
	move.l	#force_low_sprites,spr_ptr1(a0)
	move.w	#-2,spr_energy(a0)
	clr.w	spr_num(a0)
	move.w	#1,spr_move_mode(a0)
	move.w	#-1,spr_move_flag(a0)

	lea	boost_struct,a0
	clr.w	status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)
	clr.w	die_flag(a0)
	move.l	#boost_sprites,spr_ptr1(a0)
	clr.w	spr_num(a0)
;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a0)	; source and target
	move.b	#%00000111,sprite_op(a0)	; source or target
	move.l	#back_scrn,back_ptr1(a0)
	move.l	#back_scrn,back_ptr2(a0)

	lea	power_struct,a0
	clr.w	status(a0)
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)
	clr.w	die_flag(a0)
;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a0)	; source and target
	move.b	#%00000111,sprite_op(a0)	; source or target
	move.l	#back_scrn,back_ptr1(a0)
	move.l	#back_scrn,back_ptr2(a0)

	lea	pod_struct1,a0
	clr.w	status(a0)	; no force
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)
	clr.w	die_flag(a0)
	move.l	#pod_sprites,spr_ptr1(a0)
	clr.w	spr_num(a0)
	clr.w	spr_move_mode(a0)
	move.w	#4,spr_power(a0)
	move.w	#-2,spr_energy(a0)
	move.w	#-1,spr_move_flag(a0)
; use a software rout for this beam

	clr.w	spr_rout_flag(a0)
;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a0)	; source and target
	move.b	#%00000111,sprite_op(a0)	; source or target
	move.l	#back_scrn,back_ptr1(a0)
	move.l	#back_scrn,back_ptr2(a0)

	lea	pod_struct2,a0
	clr.w	status(a0)	; no force
	move.w	#2,rest_cnt(a0)
	move.w	#2,die_cnt(a0)
	move.l	#pod_sprites,spr_ptr1(a0)
	move.w	#6,spr_num(a0)
	clr.w	die_flag(a0)
	clr.w	spr_move_mode(a0)
	move.w	#4,spr_power(a0)
	move.w	#-2,spr_energy(a0)
	move.w	#-1,spr_move_flag(a0)

	clr.w	spr_rout_flag(a0)
;		  xxxx		; unused bits
	move.b	#%00000001,mask_op(a0)	; source and target
	move.b	#%00000111,sprite_op(a0)	; source or target
	move.l	#back_scrn,back_ptr1(a0)
	move.l	#back_scrn,back_ptr2(a0)
	rts

clear_structure_data
	lea	pickup_struct,a0
	move.w	#(sprite_size*num_pickup)-1,d0
.l1	clr.b	(a0)+
	dbf	d0,.l1

	lea	beam_struct,a0
	move.w	#(sprite_size*num_beams)-1,d0
.l2	clr.b	(a0)+
	dbf	d0,.l2

	lea	baddie_struct,a0
	move.w	#(sprite_size*num_baddies)-1,d0
.l3	clr.b	(a0)+
	dbf	d0,.l3

	lea	bullet_struct,a0
	move.w	#(sprite_size*num_bullets)-1,d0
.l4	clr.b	(a0)+
	dbf	d0,.l4

	lea	anim_tile_struct,a0
	move.w	#(anim_tile_size*num_anim_tiles)-1,d0
.l5	clr.b	(a0)+
	dbf	d0,.l5
	rts

map_coll_detect
	tst.b	intro_done
	beq	.s2

	tst.w	demo_mode
	bne.s	.s1


	jsr	plr_and_map	*
.s1
	bsr	beam_and_map	*

	tst.w	demo_mode
	bne.s	.s2
	jsr	bullet_and_map
.s2
	rts

sprite_coll_detect
	tst.b	intro_done
	beq	.s3

	tst.w	demo_mode
	bne.s	.s1
	jsr	plr_and_bullets	*
	jsr	plr_and_baddies	*
.s1
	lea	force_struct,a0
	jsr	baddies_check	*
	tst.w	demo_mode
	bne.s	.s2
	lea	pod_struct1,a0
	jsr	baddies_check	*
	lea	pod_struct2,a0
	jsr	baddies_check	*
	lea	force_struct,a0
	jsr	bullets_check	*
	lea	pod_struct1,a0
	jsr	bullets_check	*
	lea	pod_struct2,a0
	jsr	bullets_check	*
.s2

;	bsr	beam_and_baddies	*
;	jsr	beam_and_bullet

	jsr	plr_and_pickup	*

	tst.w	demo_mode
	bne.s	.s3
	lea	force_struct,a0
	jsr	force_and_bullet
	lea	pod_struct1,a0
	jsr	force_and_bullet
	lea	pod_struct2,a0
	jsr	force_and_bullet
.s3
	rts

draw_baddie	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jmp	(a1)

.table	dc.l	.return	; dead
	dc.l	.plot	; born
	dc.l	.plot	; alive
	dc.l	swap_spr_ptrs	; dying

.plot	cmp.w	#0,spr_die_flag(a0)
	beq	plot_sprite
.return	rts

draw_explosion	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jmp	(a1)

.table	dc.l	.return	; dead
	dc.l	.plot	; born
	dc.l	.plot	; alive
	dc.l	.return	; dying

.plot	cmp.w	#-1,spr_die_flag(a0)
	beq	plot_sprite
	cmp.w	#-2,spr_die_flag(a0)
	beq	plot_sprite
.return	rts


mul_16x3_2_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(8*3)
	endr


draw_16x3_2_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	movem.l	(a2)+,d0-d5
	or.l	d0,(a3)
	or.l	d1,(8*1)(a3)
	or.l	d2,(376*1)(a3)
	or.l	d3,(376*1)+(8*1)(a3)
	or.l	d4,(376*2)(a3)
	or.l	d5,(376*2)+(8*1)(a3)

	bra	swap_spr_ptrs

mul_16x4_2_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(8*4)
	endr

draw_16x4_2_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address
	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)
	or.l	d1,(8*1)(a3)
	or.l	d2,(376*1)(a3)
	or.l	d3,(376*1)+(8*1)(a3)
	or.l	d4,(376*2)(a3)
	or.l	d5,(376*2)+(8*1)(a3)
	or.l	d6,(376*3)(a3)
	or.l	d7,(376*3)+(8*1)(a3)

	bra	swap_spr_ptrs

mul_16x6_2_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(8*6)
	endr

draw_16x6_2_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address
	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)
	or.l	d1,(8*1)(a3)
	or.l	d2,(376*1)(a3)
	or.l	d3,(376*1)+(8*1)(a3)
	or.l	d4,(376*2)(a3)
	or.l	d5,(376*2)+(8*1)(a3)
	or.l	d6,(376*3)(a3)
	or.l	d7,(376*3)+(8*1)(a3)
	movem.l	(a2)+,d0-d3
	or.l	d0,(376*4)(a3)
	or.l	d1,(376*4)+(8*1)(a3)
	or.l	d2,(376*5)(a3)
	or.l	d3,(376*5)+(8*1)(a3)

	bra	swap_spr_ptrs

mul_16x16_2_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(8*16)
	endr

draw_16x16_2_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

x	set	0
	rept	4
	movem.l	(a2)+,d0-d7
	or.l	d0,x(a3)
	or.l	d1,x+(8*1)(a3)
	or.l	d2,x+(376*1)(a3)
	or.l	d3,x+(376*1)+(8*1)(a3)
	or.l	d4,x+(376*2)(a3)
	or.l	d5,x+(376*2)+(8*1)(a3)
	or.l	d6,x+(376*3)(a3)
	or.l	d7,x+(376*3)+(8*1)(a3)
x	set	x+(376*4)
	endr

	bra	swap_spr_ptrs

mul_16x12_2_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(8*12)
	endr

draw_16x12_2_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address
	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2
x	set	0
	rept	3
	movem.l	(a2)+,d0-d7
	or.l	d0,x(a3)
	or.l	d1,x+(8*1)(a3)
	or.l	d2,x+(376*1)(a3)
	or.l	d3,x+(376*1)+(8*1)(a3)
	or.l	d4,x+(376*2)(a3)
	or.l	d5,x+(376*2)+(8*1)(a3)
	or.l	d6,x+(376*3)(a3)
	or.l	d7,x+(376*3)+(8*1)(a3)
x	set	x+(376*4)
	endr
	bra	swap_spr_ptrs

mul_16x16_4_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(16*16)
	endr


draw_32x4_4_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.w	spr_num(a0),d2
	move.l	spr_anim_tab(a0),a5
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a5
	add.l	(a5),a2

	rept	4
	movem.l	(a2)+,d0-d5
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+
	or.l	d4,(a3)+
	or.l	d5,(a3)+
	lea	376-(8*3)(a3),a3
	endr
	bra	swap_spr_ptrs

rocket_mul_tab
x	set	0
	rept	16
	dc.l	x
x	set	x+((16*16)*16)
	endr

turret_mul_tab
x	set	0
	rept	12
	dc.l	x
x	set	x+((16*16)*16)
	endr

snake_mul_tab
x	set	0
	rept	4
	dc.l	x
x	set	x+((24*4)*16)
	endr

mul_32x4_4_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(24*4)
	endr

draw_16x16_4_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.w	spr_num(a0),d2
	move.l	spr_anim_tab(a0),a5
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a5
	add.l	(a5),a2

	rept	16/2
	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+
	lea	376-(8*2)(a3),a3
	or.l	d4,(a3)+
	or.l	d5,(a3)+
	or.l	d6,(a3)+
	or.l	d7,(a3)+
	lea	376-(8*2)(a3),a3
	endr
	bra	swap_spr_ptrs

bullet_mul_tab
x	set	0
	rept	4
	dc.l	x
x	set	x+((16*6)*16)
	endr

mul_16x6_4_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(16*6)
	endr

draw_16x6_4_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.w	spr_num(a0),d2
	move.l	spr_anim_tab(a0),a5
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a5
	add.l	(a5),a2

	rept	6/2
	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+
	lea	376-(8*2)(a3),a3
	or.l	d4,(a3)+
	or.l	d5,(a3)+
	or.l	d6,(a3)+
	or.l	d7,(a3)+
	lea	376-(8*2)(a3),a3
	endr

	jmp	swap_spr_ptrs

mul_16x9_4_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(16*9)
	endr

sperm_mul_tab
x	set	0
	rept	3
	dc.l	x
x	set	x+((16*9)*16)
	endr


draw_16x9_4_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.w	spr_num(a0),d2
	move.l	spr_anim_tab(a0),a5
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a5
	add.l	(a5),a2

	rept	4
	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+
	lea	376-(8*2)(a3),a3
	or.l	d4,(a3)+
	or.l	d5,(a3)+
	or.l	d6,(a3)+
	or.l	d7,(a3)+
	lea	376-(8*2)(a3),a3
	endr

	movem.l	(a2)+,d0-d3
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+

	jmp	swap_spr_ptrs


restore_16x9
x	set	0
	rept	9
	movem.l	x(a2),d0-d3
	movem.l	d0-d3,x(a3)
x	set	x+376
	endr
	rts

restore_16x4
x	set	0
	rept	4
	movem.l	x(a2),d0-d3
	movem.l	d0-d3,x(a3)
x	set	x+376
	endr
	rts


restore_16x12
x	set	0
	rept	12
	movem.l	x(a2),d0-d3
	movem.l	d0-d3,x(a3)
x	set	x+376
	endr
	rts

restore_16x13
x	set	0
	rept	13
	movem.l	x(a2),d0-d3
	movem.l	d0-d3,x(a3)
x	set	x+376
	endr
	rts

restore_32x4_4_bpl
x	set	0
	rept	4
	movem.l	x(a2),d0-d5
	movem.l	d0-d5,x(a3)
x	set	x+376
	endr
	rts

restore_16x3_2_bpl
x	set	0
	rept	3
	move.l	x(a2),x(a3)
	move.l	x+8(a2),x+8(a3)
x	set	x+376
	endr
	rts

restore_16x4_2_bpl
x	set	0
	rept	4
	move.l	x(a2),x(a3)
	move.l	x+8(a2),x+8(a3)
x	set	x+376
	endr
	rts

restore_16x6_2_bpl
x	set	0
	rept	6
	move.l	x(a2),x(a3)
	move.l	x+8(a2),x+8(a3)
x	set	x+376
	endr
	rts

restore_16x12_2_bpl
x	set	0
	rept	12
	move.l	x(a2),x(a3)
	move.l	x+8(a2),x+8(a3)
x	set	x+376
	endr
	rts

restore_16x16_2_bpl
x	set	0
	rept	16
	move.l	x(a2),x(a3)
	move.l	x+8(a2),x+8(a3)
x	set	x+376
	endr
	rts

restore_16x10
x	set	0
	rept	10
	movem.l	x(a2),d0-d3
	movem.l	d0-d3,x(a3)
x	set	x+376
	endr
	rts

restore_16x14
x	set	0
	rept	14
	movem.l	x(a2),d0-d3
	movem.l	d0-d3,x(a3)
x	set	x+376
	endr
	rts


restore_16x16
x	set	0
	rept	16
	movem.l	x(a2),d0-d3
	movem.l	d0-d3,x(a3)
x	set	x+376
	endr
	rts

restore_16x6
x	set	0
	rept	6
	movem.l	x(a2),d0-d3
	movem.l	d0-d3,x(a3)
x	set	x+376
	endr
	rts

mul_16x12_4_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(16*12)
	endr

boss_tail_mul_tab1
x	set	0
	rept	4
	dc.l	x
x	set	x+((16*12)*16)
	endr

draw_16x12_4_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.w	spr_num(a0),d2
	move.l	spr_anim_tab(a0),a5
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a5
	add.l	(a5),a2

	rept	12/2
	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+
	lea	376-(8*2)(a3),a3
	or.l	d4,(a3)+
	or.l	d5,(a3)+
	or.l	d6,(a3)+
	or.l	d7,(a3)+
	lea	376-(8*2)(a3),a3
	endr
	jmp	swap_spr_ptrs

mul_16x13_4_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(16*13)
	endr

boss_tail_mul_tab2
x	set	0
	rept	7
	dc.l	x
x	set	x+((16*13)*16)
	endr

draw_16x13_4_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.w	spr_num(a0),d2
	move.l	spr_anim_tab(a0),a5
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a5
	add.l	(a5),a2

	rept	12/2
	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+
	lea	376-(8*2)(a3),a3
	or.l	d4,(a3)+
	or.l	d5,(a3)+
	or.l	d6,(a3)+
	or.l	d7,(a3)+
	lea	376-(8*2)(a3),a3
	endr
	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+

	jmp	swap_spr_ptrs

mul_16x10_4_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(16*10)
	endr

big_shot_mul_tab
	dc.l	0	; only 1 sprite

draw_16x10_4_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.w	spr_num(a0),d2
	move.l	spr_anim_tab(a0),a5
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a5
	add.l	(a5),a2

	rept	10/2
	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+
	lea	376-(8*2)(a3),a3
	or.l	d4,(a3)+
	or.l	d5,(a3)+
	or.l	d6,(a3)+
	or.l	d7,(a3)+
	lea	376-(8*2)(a3),a3
	endr
	jmp	swap_spr_ptrs

trace_mul_tab
x	set	0
	rept	4
	dc.l	x
x	set	x+((16*14)*16)
	endr


mul_16x14_4_bpl
x	set	0
	rept	16
	dc.w	x
x	set	x+(16*14)
	endr

draw_16x14_4_bpl
	move.w	skew_store(a0),d0
	move.l	spr_skew_tab(a0),a4
	move.w	spr_num(a0),d2
	move.l	spr_anim_tab(a0),a5
	move.l	spr_gfx_addr(a0),a2
	move.l	scrn_ptr1(a0),a3	; screen address

	add.w	d0,d0
	add.w	d0,a4
	add.w	(a4),a2

	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a5
	add.l	(a5),a2

	rept	14/2
	movem.l	(a2)+,d0-d7
	or.l	d0,(a3)+
	or.l	d1,(a3)+
	or.l	d2,(a3)+
	or.l	d3,(a3)+
	lea	376-(8*2)(a3),a3
	or.l	d4,(a3)+
	or.l	d5,(a3)+
	or.l	d6,(a3)+
	or.l	d7,(a3)+
	lea	376-(8*2)(a3),a3
	endr
	jmp	swap_spr_ptrs


beam_and_map

	lea	beam_struct,a0

	move.w	#num_beams-1,bullet_cnt2
.l0
	cmp.w	#0,status(a0)
	beq	.s3
	cmp.w	#3,status(a0)
	beq	.s3

	move.w	x1(A0),d0
	move.w	y1(a0),d1
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3
	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; add height

	move.l	map_buff_pos,a3

	moveq	#12-1,d7
.l2
	moveq	#6-1,d6

.l1	cmp.w	#0,tile_flag(a3)
	beq	.s1 

	movem.w	tile_x1(a3),d4/d5/a5/a6	; tile coords

	cmp.l	#circle_laser,spr_ptr1(a0)
	bne.s	.l3
	addq.w	#7,d5
	lea	-8(a6),a6

.l3	cmp.w	a5,d0
	bgt	.s1
	cmp.w	a6,d1
	bgt	.s1
	cmp.w	d4,d2
	blt	.s1
	cmp.w	d5,d3
	blt	.s1

	cmp.w	#18,spr_type(a0)
	bne.s	.no_home
	move.w	#3,status(a0)
	bra	.e1
.no_home

	tst.w	spr_move_flag(a0)
	bne.s	.n1
	clr.w	status(a0)

	cmp.l	#circle_laser,spr_ptr1(a0)
	bne.s	.j0
	sf	circle_laser_flag
.j0

	bra	.s1
.n1
	tst.w	spr_die_flag(a0)
	bne	.s1
	move.w	#-1,spr_die_flag(a0)

	move.w	d0,-(sp)
	move.w	spr_move_dir(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.spr_set_tab(pc),a4
	add.w	d0,a4
	move.l	(a4),a4
	jsr	(a4)
	move.w	(sp)+,d0

	bra.s	.s3

.s1
	lea	tile_size(a3),a3
	dbf	d6,.l1

.s2	lea	-(tile_size*6)+((tile_size*7)*2)(a3),a3
	dbf	d7,.l2

.s3	lea	sprite_size(a0),a0
	subq.w	#1,bullet_cnt2
	tst.w	bullet_cnt2
	bpl	.l0

.e1	rts

.spr_set_tab	dc.l	.left_right
	dc.l	.e1
	dc.l	.e1
	dc.l	.up
	dc.l	.down
	dc.l	.right_left
	dc.l	.up	; homing missiles
	dc.l	.down

	dc.l	bounce_horizontal
	dc.l	bounce_diag

	dc.l	trace_diag

.up_right	bsr.s	.up
	bsr.s	.left_right
	rts

.down_right	bsr.s	.down
	bsr.s	.left_right
	rts

.left_right	move.w	tile_x1(a3),d0
	sub.w	8(a2),d0
	subq.w	#3+1,d0
	move.w	d0,x1(a0)
	rts

.up	move.w	tile_y2(a3),d0
	addq.w	#2,d0
	move.w	d0,y1(a0)
	rts

.down	move.w	tile_y1(a3),d0
	sub.w	12(a2),d0
	subq.w	#2,d0
	move.w	d0,y1(a0)
	rts

.right_left	move.w	tile_x2(a3),d0
	subq.w	#3+1,d0
	move.w	d0,x1(a0)
	rts

bounce_horizontal
	subq.w	#1,spr_x_cnt(a0)
	tst.w	spr_x_cnt(a0)
	bpl.s	.b1
	move.w	#-1,spr_x_cnt(a0)
	bra.s	.s3
.b1
	tst.w	spr_x_flag(a0)
	beq.s	.s1
	sub.w	#15,x1(a0)
	bra.s	.s2
.s1	add.w	#15,x1(a0)
.s2
	not.w	spr_x_flag(a0)
	clr.w	spr_die_flag(a0)

.s3	rts

bounce_diag


; bounces counter

	subq.w	#1,spr_x_cnt(a0)
	tst.w	spr_x_cnt(a0)
	bpl.s	.b1
	move.w	#-1,spr_x_cnt(a0)
	bra	.e1
.b1
	clr.w	spr_die_flag(a0)

	move.w	diag_move(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.diag_tab(pc,d0.w),a1
	jmp	(a1)

.diag_tab	dc.l	.up_left
	dc.l	.up_right
	dc.l	.down_right
	dc.l	.down_left

.up_left	add.w	#15,y1(a0)
	move.w	#3,diag_move(a0)
	move.l	#bounce_sprites_gfx2,spr_gfx_addr(a0)
.e1	rts

.up_right	add.w	#15,y1(a0)
	move.w	#2,diag_move(a0)
	move.l	#bounce_sprites_gfx3,spr_gfx_addr(a0)
	rts

.down_right	sub.w	#15,y1(a0)
	move.w	#1,diag_move(a0)
	move.l	#bounce_sprites_gfx2,spr_gfx_addr(a0)
	rts

.down_left	sub.w	#15,y1(a0)
	clr.w	diag_move(a0)
	move.l	#bounce_sprites_gfx3,spr_gfx_addr(a0)
	rts

trace_diag


; bounces counter

	subq.w	#1,spr_x_cnt(a0)
	tst.w	spr_x_cnt(a0)
	bpl.s	.b1
	move.w	#-1,spr_x_cnt(a0)
	bra	.e1
.b1
	clr.w	spr_die_flag(a0)

	move.w	diag_move(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.diag_tab(pc,d0.w),a1
	jmp	(a1)

.diag_tab	dc.l	.up_left
	dc.l	.up_right
	dc.l	.down_right
	dc.l	.down_left

.up_left	add.w	#15,y1(a0)
	move.w	#3,diag_move(a0)
;	move.l	#bounce_sprites_gfx2,spr_gfx_addr(a0)
.e1	rts

.up_right	add.w	#15,y1(a0)
	move.w	#2,diag_move(a0)
;	move.l	#bounce_sprites_gfx3,spr_gfx_addr(a0)
	rts

.down_right	sub.w	#15,y1(a0)
	move.w	#1,diag_move(a0)
;	move.l	#bounce_sprites_gfx2,spr_gfx_addr(a0)
	rts

.down_left	sub.w	#15,y1(a0)
	clr.w	diag_move(a0)
;	move.l	#bounce_sprites_gfx3,spr_gfx_addr(a0)
	rts

beam_and_bullet
	clr.w	pop_flag1

x	set	0
	rept	num_beams

	tst.w	pop_flag1
	bne	.return

	lea	beam_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a1
	add.w	d0,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+sprite_size
	endr

.return	rts

.tab	dc.l	coll_return
	dc.l	.check
	dc.l	.check
	dc.l	coll_return

.check
	clr.w	pop_flag2
	move.w	x1(a0),d0
	move.w	y1(a0),d1
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; add height

x	set	0
	rept	num_bullets
	tst.w	pop_flag2
	bmi	.return
	lea	bullet_struct+x,a1
	move.w	status(a1),d4
	add.w	d4,d4
	add.w	d4,d4
	lea	.baddie_tab(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
	rts

.baddie_tab	dc.l	coll_return
	dc.l	.check2
	dc.l	.check2
	dc.l	coll_return

.check2	cmp.l	#rocket_sprites,spr_ptr1(a1)
	bne	.return

	bra	baddie_check


beam_and_baddies
	clr.w	pop_flag1

x	set	0
	rept	num_beams

	tst.w	pop_flag1
	bne	.return

	lea	beam_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a1
	add.w	d0,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+sprite_size
	endr

.return	rts

.tab	dc.l	coll_return
	dc.l	.check
	dc.l	.check
	dc.l	coll_return

.check
	clr.w	pop_flag2
	move.w	x1(a0),d0
	move.w	y1(a0),d1
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; add height

x	set	0
	rept	num_baddies
	tst.w	pop_flag2
	bmi	.return
	lea	baddie_struct+x,a1
	move.w	status(a1),d4
	add.w	d4,d4
	add.w	d4,d4
	lea	.baddie_tab(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
	rts

.baddie_tab	dc.l	coll_return
	dc.l	baddie_check
	dc.l	baddie_check
	dc.l	coll_return

battle_weak_tab
	dc.w	4,4,4,4,4,12,20,28,32,38,38,42,42,44

baddie_check
	cmp.w	#-3,spr_energy(a1)
	beq	coll_return
	cmp.w	#-2,spr_die_flag(a1)
	beq	rotate_check

	tst.w	gun_rotate_flag(a1)
 	bne	still_detect
	tst.w	gun_rotate_flag(a1)
	bne	still_detect

	tst.w	spr_die_flag(a1)
	bmi	coll_return


still_detect

;	cmp.w	#12,spr_type(a1)
;	bne.s	.not_triffid
;	tst.w	spr_move_cnt(a1)
;	bpl	coll_return
;	cmp.w	#4-1,spr_num(a1)	; triffid not open
;	blt	coll_return
;.not_triffid

	move.w	x1(a1),d4
	move.w	y1(a1),d5

	bsr	boss_weak_offset

	move.l	spr_ptr1(a1),a2
	addq.w	#6,a2

	moveq	#0,d6
	move.w	spr_num(a1),d6
	lsl.w	#5,d6
	add.l	d6,a2
	moveq	#0,d6

	move.w	d4,d6
	move.w	d5,a3
	add.w	8(a2),d6	; width in pixels
	add.w	12(a2),a3	; height

	cmp.w	#3,stage
	bne	.nb
	cmp.w	#3,spr_type(a1)
	bne	.nb

	move.w	d0,-(sp)
	move.l	a4,-(sp)
	move.w	spr_num(a1),d0
	add.w	d0,d0
	lea	battle_weak_tab,a4
	add.w	d0,a4
	add.w	(a4),d4
	move.l	(sp)+,a4
	move.w	(sp)+,d0
.nb
	cmp.w	d6,d0
	bgt	coll_return
	cmp.w	a3,d1
	bgt	coll_return

	cmp.w	d4,d2
	blt	coll_return
	cmp.w	d5,d3
	blt	coll_return

	cmp.w	#3,stage
	bne.s	.no_battle
	cmp.w	#3,spr_type(a1)
	bne	.no_battle
	cmp.w	#14-1,spr_num(a1)
	bge	.no_battle

	cmp.l	#force_low_sprites,spr_ptr1(a0)
	beq.s	.no_battle1
	cmp.l	#force_med_sprites1,spr_ptr1(a0)
	beq.s	.no_battle1
	cmp.l	#force_med_sprites2,spr_ptr1(a0)
	beq.s	.no_battle1
	cmp.l	#force_high_sprites1,spr_ptr1(a0)
	beq.s	.no_battle1
	cmp.l	#force_high_sprites2,spr_ptr1(a0)
	beq.s	.no_battle1
	cmp.l	#force_high_sprites3,spr_ptr1(a0)
	beq.s	.no_battle1
	cmp.l	#pod_sprites,spr_ptr1(a0)
	beq.s	.no_battle1

	move.w	#3,status(a0)
	bra	coll_return

.no_battle1
	cmp.w	#14-1,spr_num(a1)
	blt	coll_return

.no_battle


	cmp.w	#27,spr_type(a1)
	bne	.no_pump1

	add.w	#32,d4

	cmp.w	d6,d0
	bgt	no_pump_return
	cmp.w	a3,d1
	bgt	no_pump_return
	cmp.w	d4,d2
	blt	no_pump_return
	cmp.w	d5,d3
	blt	no_pump_return
	tst.w	spr_move_flag(a0)
	bpl	no_pump_return

	bra	.no_pump2
.no_pump1
	cmp.w	#28,spr_type(a1)
	bne	.no_pump2

	sub.w	#32,d6

	cmp.w	d6,d0
	bgt	no_pump_return
	cmp.w	a3,d1
	bgt	no_pump_return

	cmp.w	d4,d2
	blt	no_pump_return
	cmp.w	d5,d3
	blt	no_pump_return
	tst.w	spr_move_flag(a0)
	bpl	no_pump_return
.no_pump2
	cmp.w	#3,spr_type(a1)
	bne.s	.not_weak
	cmp.w	#8,stage
	blt	.not_weak
	tst.w	spr_move_flag(a0)
	bpl	no_pump_return
.not_weak
	cmp.w	#7,stage
	bne	.no_lv7
	cmp.w	#3,spr_type(a1)
	bne	.no_lv7
	cmp.w	#319,x1(a1)
	bge	coll_return
.no_lv7

	tst.w	hit_count(a1)
	bpl	coll_return2

	cmp.w	#16,spr_type(a0)
	bne.s	.no_trace1
	lea	beam_struct,a4
	moveq	#num_beams-1,d4
.trace_loop1	cmp.w	#0,status(a4)
	beq.s	.trace_skip1
	cmp.w	#16,spr_type(a4)
	bne.s	.trace_skip1
	move.w	#3,status(a4)
.trace_skip1	lea	sprite_size(a4),a4
	dbf	d4,.trace_loop1
	sf	trace_coord_flag2
	bra	.bod
.no_trace1

	cmp.w	#17,spr_type(a0)
	bne.s	.no_trace2
	lea	beam_struct,a4
	moveq	#num_beams-1,d4
.trace_loop2	cmp.w	#0,status(a4)
	beq.s	.trace_skip2
	cmp.w	#17,spr_type(a4)
	bne.s	.trace_skip2
	move.w	#3,status(a4)
.trace_skip2	lea	sprite_size(a4),a4
	dbf	d4,.trace_loop2
	sf	trace_coord_flag3
	bra	.bod
.no_trace2

	cmp.w	#-2,spr_energy(a1)
	beq	invincible_check

	tst.w	spr_die_flag(a1)
	bmi	coll_return

	bsr	circular_check

	bsr	min_beam_check

.bod	bsr	decrease_energy

	tst.w	spr_energy(a1)
	bpl	multi_hit_check
	move.w	#-1,spr_energy(a1)

	moveq	#0,d6
	move.w	spr_score(a1),d6
	add.l	d6,total_score
	move.l	stage_score_pos,a2
	add.l	d6,(a2)

	bsr	stage_clear_check

	move.w	die_adjust_x(a1),d6
	sub.w	d6,x1(a1)
	move.w	die_adjust_y(a1),d6
	sub.w	d6,y1(a1)

	lea	anim_tile_struct,a2
	moveq	#num_anim_tiles-1,d0
.tile_l1	cmp.w	#0,anim_tile_stat(a2)
	beq.s	.tile_s2
	tst.w	anim_tile_type(a2)
	bpl.s	.tile_s2
	clr.w	anim_tile_num(a2)
	bra.s	.tile_s1	
.tile_s2	lea	anim_tile_size(a2),a2
	dbf	d0,.tile_l1
.tile_s1

	clr.w	lvl_4_boss_cnt
	clr.w	spr_num(a1)
	move.w	#-1,spr_die_flag(a1)
	clr.w	spr_rout_flag(a1)

	cmp.w	#4,stage
	bne	.not_lvl_4
	cmp.w	#3,spr_type(a1)
	bne	.not_lvl_4

	moveq	#0,d0
	move.w	lvl_4_ex_cnt,d0
	mulu	#10,d0
	lea	lvl_4_boss_tab,a2
	add.w	d0,a2
	move.w	#1,(a2)+
	move.w	x_reset(a1),(a2)+
	move.w	y_reset(a1),(a2)+
	move.l	#lvl_4_boss_explode_tab,(a2)+
	addq.w	#1,lvl_4_ex_cnt
	cmp.w	#3,lvl_4_ex_cnt
	blt.s	.not_lvl_4
	move.w	#3,lvl_4_ex_cnt
.not_lvl_4
	move.w	#1,spr_type(a1)


	move.l	level_point,a2
	move.l	12+2(a2),a2
	move.l	2+(4*4)(a2),d0
	move.l	spr_ptr1(a1),d1
	cmp.l	d0,d1
	bne.s	.r1
	move.w	#-2,spr_die_flag(a1)
.r1
	move.l	2+(4*5)(a2),d0
	cmp.l	d0,d1
	bne.s	.r2
	move.w	#-2,spr_die_flag(a1)
.r2
	move.l	die_gfx(a1),spr_ptr1(a1)

	bsr	set_up_pickup

	tst.w	spr_energy(a1)
	bmi	.s1

	tst.w	hit_flag(a0)
	bne	coll_return
.s1

	move.l	sample_start(a1),d5
	move.l	sample_end(a1),d6
	moveq	#-1,d7
	jsr	play_sfx

	move.w	#-1,pop_flag1
	move.w	#-1,pop_flag2
coll_return	rts

no_pump_return	cmp.l	#pod_sprites,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_low_sprites,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_med_sprites1,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_med_sprites2,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_high_sprites1,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_high_sprites2,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_high_sprites3,spr_ptr1(a0)
	beq.s	.s1
	move.w	#3,status(a0)
.s1	rts

coll_return2	move.l	level_point,a2
	move.l	12+2(a2),a2
	move.l	2+(4*7)(a2),d4
	move.l	spr_ptr1(a1),d5
	cmp.l	d4,d5
	bne.s	.r0
	cmp.l	#force_low_sprites,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_med_sprites1,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_med_sprites2,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_high_sprites1,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_high_sprites2,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_high_sprites3,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#pod_sprites,spr_ptr1(a0)
	beq.s	.r0
	cmp.w	#3,spr_type(a1)
	beq.s	.still_kill
	tst.w	spr_power(a0)
	bpl.s	.r0
.still_kill	move.w	#3,status(a0)
.r0	rts

boss_weak_offset
	move.w	d0,-(sp)
	move.w	stage,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a2
	jsr	(a2)
	move.w	(sp)+,d0
	rts


.tab	dc.l	.s1
	dc.l	.stage1
	dc.l	.stage2
	dc.l	.s1
	dc.l	.s1
	dc.l	.s1
	dc.l	.s1
	dc.l	.s1
	dc.l	.s1

.stage1
;	move.w	d4,-(sp)
;	move.w	d5,-(sp)
;	move.l	level_point,a2
;	move.l	12+2(a2),a2
;	move.l	2+(4*7)(a2),d4
;	move.l	spr_ptr1(a1),d5
;	cmp.l	d4,d5
;	bne.s	.r1
;	move.w	(sp)+,d5
;	move.w	(sp)+,d4
;	add.w	#16,d4	; x
;	bra.s	.s1
;.r1	move.w	(sp)+,d5
;	move.w	(sp)+,d4

.s1	rts

.stage2	move.w	d4,-(sp)
	move.w	d5,-(sp)
	move.l	level_point,a2
	move.l	12+2(a2),a2
	move.l	2+(4*7)(a2),d4
	move.l	spr_ptr1(a1),d5
	cmp.l	d4,d5
	bne.s	.r2
	move.w	(sp)+,d5
	move.w	(sp)+,d4
	add.w	#16,d5	; y
	bra.s	.s2
.r2	move.w	(sp)+,d5
	move.w	(sp)+,d4
.s2	rts

rotate_check	move.w	x1(a1),d4
	move.w	y1(a1),d5

	move.l	spr_ptr1(a1),a2
	addq.w	#6,a2

	move.w	spr_num(a1),d6
	lsl.w	#5,d6
	add.w	d6,a2

	move.w	d4,d6
	move.w	d5,a3
	add.w	8(a2),d6	; width in pixels
	add.w	12(a2),a3	; height

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	a3,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

	cmp.l	#force_low_sprites,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_med_sprites1,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_med_sprites2,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_high_sprites1,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_high_sprites2,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#force_high_sprites3,spr_ptr1(a0)
	beq.s	.s1
	cmp.l	#pod_sprites,spr_ptr1(a0)
	beq.s	.s1

	cmp.w	#3,spr_type(a1)
	beq.s	.still_kill
	tst.w	spr_power(a0)
	bpl.s	.s1
.still_kill	move.w	#3,status(a0)
.s1	rts

multi_hit_check
	move.l	level_point,a2
	move.l	12+2(a2),a2
	move.l	2+(4*7)(a2),d4
	move.l	spr_ptr1(a1),d5
	cmp.l	d4,d5
	bne.s	.r0
	cmp.l	#force_low_sprites,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_med_sprites1,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_med_sprites2,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_high_sprites1,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_high_sprites2,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#force_high_sprites3,spr_ptr1(a0)
	beq.s	.r0
	cmp.l	#pod_sprites,spr_ptr1(a0)
	beq.s	.r0
	cmp.w	#3,spr_type(a1)
	beq.s	.still_kill
	tst.w	spr_power(a0)
	bpl.s	.r0
.still_kill	move.w	#3,status(a0)
.r0

	tst.w	multi_hit_flag(a1)
	beq	multi_return

	tst.w	hit_flag(a0)
	bne	multi_return


	move.w	stage,d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	multi_tab(pc,d4.w),a2
	jmp	(a2)

multi_return	rts

multi_tab	dc.l	multi_stage1	; devpac
	dc.l	multi_stage1
	dc.l	multi_stage2
	dc.l	multi_stage3
	dc.l	multi_stage4
	dc.l	multi_stage5
	dc.l	multi_stage6
	dc.l	multi_stage7
	dc.l	multi_stage8

multi_stage1
; boss weak detect
	cmp.w	#3,spr_type(a1)
	bne	.s1

; wait till head fully appears
	cmp.w	#8-1,spr_num(a1)
	blt	multi_return
	
.s1	bra	do_multi


multi_stage2
; boss weak detect
	cmp.w	#3,spr_type(a1)
	bne	.s1

	tst.w	boss_weak_cnt
	bpl	multi_return
.s1	bra	do_multi

multi_stage3
; boss weak detect
	cmp.w	#3,spr_type(a1)
	bne	.s1

	tst.w	boss_weak_cnt
	bpl	multi_return
.s1	bra	do_multi

multi_stage4
; boss weak detect
	cmp.w	#3,spr_type(a1)
	bne	.s1

	tst.w	boss_weak_cnt
	bpl	multi_return
.s1	bra	do_multi

multi_stage5
; boss weak detect
	cmp.w	#3,spr_type(a1)
	bne	.s1

	tst.w	boss_weak_cnt
	bpl	multi_return
.s1	bra	do_multi

	nop

multi_stage6
; boss weak detect
	cmp.w	#3,spr_type(a1)
	bne	.s1

	tst.w	boss_weak_cnt
	bpl	multi_return
.s1	bra	do_multi

	nop

multi_stage7
; boss weak detect
	cmp.w	#3,spr_type(a1)
	bne	.s1

	tst.w	boss_weak_cnt
	bpl	multi_return
.s1	bra	do_multi

	nop


multi_stage8
; boss weak detect
	cmp.w	#3,spr_type(a1)
	bne	.s1

	tst.w	boss_weak_cnt
	bpl	multi_return
.s1	bra	do_multi

	nop

do_multi
	move.l	#weak_sfx+12,d5
	move.l	#weak_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx

	move.b	#%00001101,mask_op(a1)	; source or target
	clr.w	spr_mask_flag(a1)

	move.w	#5,hit_count(a1)

;	moveq	#0,d6
;	move.w	spr_score(a1),d6
;	add.l	d6,total_score
;	move.l	stage_score_pos,a2
;	add.l	d6,(a2)

	lea	anim_tile_struct,a2
	moveq	#num_anim_tiles-1,d0
.l1	cmp.w	#0,anim_tile_stat(a2)
	beq.s	.s2
	tst.w	anim_tile_type(a2)
	bpl.s	.s2

	move.l	level_point,a3
	lea	10+2+2+(4*12)(a3),a3
	move.l	(a3),a3
	addq.w	#2,a3
	move.l	(a3),a3
	lea	14(a3),a3
	move.l	(a3),a3

	cmp.w	#1,stage
	bne.s	.n1
	lea	(((8*2)*25)*8)(a3),a3
	bra.s	.n2
.n1	lea	(((8*4)*32)*8)(a3),a3
.n2	move.l	a3,anim_tile_gfx(a2)
	bra.s	.s1

.s2	lea	anim_tile_size(a2),a2
	dbf	d0,.l1


.s1	move.w	#-1,pop_flag1
	move.w	#-1,pop_flag2

.e1	rts


decrease_energy
	move.w	stage,d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	decrease_tab(pc,d4.w),a2
	jmp	(a2)

decrease_return	rts

decrease_tab	dc.l	decrease_stage1	;devpac
	dc.l	decrease_stage1
	dc.l	decrease_stage2
	dc.l	decrease_stage3
	dc.l	decrease_stage4
	dc.l	decrease_stage5
	dc.l	decrease_stage6
	dc.l	decrease_stage7
	dc.l	decrease_stage8

decrease_stage1	cmp.w	#3,spr_type(a1)
	bne	.s0

; wait till head fully appears
	cmp.w	#8-1,spr_num(a1)
	blt	decrease_return
.s0	bra	decrease_it

decrease_stage2	cmp.w	#3,spr_type(a1)
	bne.s	.s0

	tst.w	boss_weak_cnt
	bpl	decrease_return

.s0	bra	decrease_it
	nop

decrease_stage3	cmp.w	#3,spr_type(a1)
	bne.s	.s0

	tst.w	boss_weak_cnt
	bpl	decrease_return

.s0	bra	decrease_it
	nop

decrease_stage4	cmp.w	#3,spr_type(a1)
	bne.s	.s0

	tst.w	boss_weak_cnt
	bpl	decrease_return

.s0	bra	decrease_it

	nop

decrease_stage5	cmp.w	#3,spr_type(a1)
	bne.s	.s0

	tst.w	boss_weak_cnt
	bpl	decrease_return

.s0	bra	decrease_it

	nop

decrease_stage6	cmp.w	#3,spr_type(a1)
	bne.s	.s0

	tst.w	boss_weak_cnt
	bpl	decrease_return

.s0	bra	decrease_it

	nop

decrease_stage7	cmp.w	#3,spr_type(a1)
	bne.s	.s0

	tst.w	boss_weak_cnt
	bpl	decrease_return

.s0	bra	decrease_it

	nop

decrease_stage8	cmp.w	#3,spr_type(a1)
	bne.s	.s0

	tst.w	boss_weak_cnt
	bpl	decrease_return

.s0	bra	decrease_it

	nop

decrease_it	cmp.w	#-2,spr_energy(a1)
	beq.s	.s1
	move.w	spr_power(a0),d6
	sub.w	d6,spr_energy(a1)
.s1
; every time a sprite is hit decrease beam's ppwer
	cmp.w	#-2,spr_energy(a0)
	beq	.s2
	subq.w	#1,spr_power(a0)
	tst.w	spr_power(a0)
	bpl.s	.s2
	clr.w	spr_power(a0)

	move.w	#3,status(a0)
.s2
	cmp.w	#30,spr_type(a1)
	bne.s	.no_protect

	cmp.l	#pod_sprites,spr_ptr1(a0)
	beq.s	.no_protect
	cmp.l	#force_low_sprites,spr_ptr1(a0)
	beq.s	.no_protect
	cmp.l	#force_med_sprites1,spr_ptr1(a0)
	beq.s	.no_protect
	cmp.l	#force_med_sprites2,spr_ptr1(a0)
	beq.s	.no_protect
	cmp.l	#force_high_sprites1,spr_ptr1(a0)
	beq.s	.no_protect
	cmp.l	#force_high_sprites2,spr_ptr1(a0)
	beq.s	.no_protect
	cmp.l	#force_high_sprites3,spr_ptr1(a0)
	beq.s	.no_protect
	move.w	#3,status(a0)
	bra	multi_return
.no_protect

	rts

invincible_check
	tst.w	spr_move_flag(a0)
	bne.s	.s2
	cmp.w	#-2,spr_energy(a0)
	beq	.s1
	move.w	#3,status(a0)
	;clr.w	status(a0)
	bra	.s1

.s2	cmp.w	#-2,spr_energy(a0)
	beq	.s1
	move.w	#3,status(a0)
	bra	coll_return

.s1	rts

;5/8/9
circular_check
*** circular guns check
	cmp.w	#0,spr_move_dir(a0)
	beq.s	.check
	cmp.w	#4,spr_move_dir(a0)
	beq.s	.check
	cmp.w	#5,spr_move_dir(a0)
	beq.s	.check
	cmp.w	#8,spr_move_dir(a0)
	beq.s	.check
	cmp.w	#9,spr_move_dir(a0)
	beq.s	.check
	cmp.w	#10,spr_move_dir(a0)
	beq.s	.check
	rts

.check	;cmp.w	#0,spr_move_dir(a0)	; 0=left to right,5=right to left
	;bne.s	.e1

;	move.w	#$700,palbuff

	move.w	gun_column_x1,d4
	moveq	#0,d5
	move.w	gun_column_x2,d6
	move.w	#200-8-1,a3

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	a3,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

	addq.l	#4,sp
	cmp.w	#-2,spr_energy(a0)
	beq	.e1
	move.w	#3,status(a0)
	bra	.e1

.s1
	cmp.w	#5,spr_type(a1)
	bne.s	.e1

	st	chain_react_flag
	clr.w	chain_react_cnt
	move.w	#11-1,chain_kill_cnt

	cmp.w	#-2,spr_energy(a0)
	beq	.e1
	move.w	#3,status(a0)

.e1	rts

stage_clear_check
	cmp.w	#3,spr_type(a1)
	bne	.n1

	cmp.w	#4,stage
	bne.s	.no_stage4
; counter for the 3 ships of level 4
	subq.w	#1,level4_cnt
	tst.w	level4_cnt
	bpl	.n1
	move.w	#-1,level4_cnt
.no_stage4
	st	stage_clear_flag
.skip_it

	cmp.w	#5,stage
	bne	.no_stage5
	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.l	d1,-(sp)
	lea	baddie_struct,a0
	moveq	#num_baddies-1,d1
.prot_loop1	cmp.w	#0,status(a0)
	beq.s	.prot_skip1
	cmp.w	#30,spr_type(a0)
	bne.s	.prot_skip1

	move.w	die_adjust_x(a0),d0
	sub.w	d0,x1(a0)
	move.w	die_adjust_y(a0),d0
	sub.w	d0,y1(a0)

	move.l	die_gfx(a0),spr_ptr1(a0)

	move.w	#1,spr_type(a0)
	clr.w	spr_num(a0)
	move.w	#-1,spr_die_flag(a0)
	clr.w	spr_rout_flag(a0)
	move.w	#-1,spr_energy(a0)

	move.l	sample_start(a0),d5
	move.l	sample_end(a0),d6
	moveq	#-1,d7
	jsr	play_sfx

.prot_skip1	lea	sprite_size(a0),a0
	dbf	d1,.prot_loop1
	move.l	(sp)+,d1
	move.l	(sp)+,d0
	move.l	(sp)+,a0
	bra	.no_stage8
.no_stage5

	cmp.w	#8,stage
	bne	.no_stage8
; destry bydo sheilds!
	move.l	a1,-(sp)
	move.l	d0,-(sp)
	lea	baddie_struct,a1
	move.w	#num_baddies-1,d0
.l1	cmp.w	#0,status(a1)
	beq.s	.skip2
	cmp.w	#21,spr_type(a1)
	bne.s	.skip
	bsr	.set_explode
	bra	.skip2
.skip	cmp.w	#22,spr_type(a1)
	bne.s	.skip2
	bsr	.set_explode
.skip2	lea	sprite_size(a1),a1
	dbf	d0,.l1
	move.l	(sp)+,d0
	move.l	(sp)+,a1
.no_stage8

	moveq	#0,d6
	move.w	#10000,d6	; boss dead score
	add.l	d6,total_score
	move.l	stage_score_pos,a2
	add.l	d6,(a2)

.n1	rts

.set_explode	move.w	die_adjust_x(a1),d0
	sub.w	d0,x1(a1)
	move.w	die_adjust_y(a1),d0
	sub.w	d0,y1(a1)

	move.w	x1(a1),x_reset(a1)
	move.w	y1(a1),y_reset(a1)

	clr.w	spr_anim_val(a1)

	move.w	#2,status(a1)	; alive
;	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)
	move.w	#10,spr_move_mode(a1)

	clr.w	spr_mask_flag(a1)

	move.w	#1,spr_type(a1)
	move.l	die_gfx(a1),spr_ptr1(a1)
	clr.w	spr_num(a1)
	move.w	#-1,spr_die_flag(a1)
	clr.w	spr_rout_flag(a1)
	move.w	#-1,spr_energy(a1)

	move.l	#bad_die_sfx2+12,d5
	move.l	#bad_die_sfx2_end,d6
	moveq	#-1,d7
	jsr	play_sfx
	rts

check_baddie_hits
	clr.w	pop_flag1
x	set	0
	rept	num_baddies
	tst.w	pop_flag1
	bne	.return
	lea	baddie_struct+x,a0
	move.w	status(a0),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	.baddie_tab(pc),a1
	add.w	d1,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+sprite_size
	endr
.return	rts

.baddie_tab	dc.l	.return
	dc.l	.baddie_check
	dc.l	.baddie_check
	dc.l	.baddie_check

.baddie_check
	tst.w	multi_hit_flag(a0)
	beq	.s3

	subq.w	#1,hit_count(a0)
	tst.w	hit_count(a0)
	bpl.s	.s3
	move.w	#-1,hit_count(a0)

	clr.w	spr_mask_flag(a0)
	move.b	#%00000001,mask_op(a0)

	lea	anim_tile_struct,a1
	moveq	#num_anim_tiles-1,d0
.l1	cmp.w	#0,anim_tile_stat(a1)
	beq.s	.s2
	tst.w	anim_tile_type(a1)
	bpl.s	.s2

	move.l	level_point,a3
	lea	10+2+2+(4*12)(a3),a3
	move.l	(a3),a3
	addq.w	#2,a3
	move.l	(a3),a3
	lea	14(a3),a3
	move.l	(a3),a3
	move.l	a3,anim_tile_gfx(a1)
	bra.s	.s3

.s2	lea	anim_tile_size(a1),a1
	dbf	d0,.l1

.s3	rts
	

; small beams are removed when hit by baddie
; or certain shots hit be certain sprites

min_beam_check	move.w	spr_move_dir(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a2
	jmp	(a2)

.tab	dc.l	.set1	; hor
	dc.l	.set2	; diag
	dc.l	.set2	; diag
	dc.l	.set2	; ver
	dc.l	.set2	; ver
	dc.l	.set1	; hor (backwards)
	dc.l	.s1	; homing
	dc.l	.s1
	dc.l	.s1	; bounce
	dc.l	.s1
	dc.l	.s1	; trace

.set1	cmp.w	#14,spr_x_move_val(a0)	; powered up beam
	beq.s	.s2
	cmp.w	#16,spr_x_move_val(a0)	; circle
	beq.s	.s1
	cmp.w	#20,spr_x_move_val(a0)	; snake
	beq.s	.s1
.set2
	cmp.w	#-2,spr_energy(a0)
	beq.s	.s1
	move.w	#3,status(a0)
.s1	rts

.s2	cmp.w	#4,spr_type(a1)
	beq.s	.set2
	cmp.w	#5,spr_type(a1)
	beq.s	.set2
	rts

chain_reaction	move.w	stage,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a0
	jmp	(a0)

.table	dc.l	.return
	dc.l	.rotated_guns_chain	; stages 1-8
	dc.l	.rotated_guns_chain
	dc.l	.rotated_guns_chain
	dc.l	.return
	dc.l	.return
	dc.l	.return
	dc.l	.return
	dc.l	.return

.rotated_guns_chain
	tst.b	chain_react_flag
	beq	.return

	subq.w	#1,chain_react_cnt
	tst.w	chain_react_cnt
	bpl	.return
	move.w	#4,chain_react_cnt

	clr.w	pop_flag1

x	set	0
	rept	num_baddies

	tst.w	pop_flag1
	bne	.return

	lea	baddie_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a1
	add.w	d0,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+sprite_size
	endr

.return	rts

.tab	dc.l	.return
	dc.l	.check
	dc.l	.check
	dc.l	.return

.check	cmp.w	#4,spr_move_mode(a0)
	bne	.e1

	cmp.w	#2,spr_type(a0)
	beq.s	.e1

	move.w	die_adjust_x(a0),d0
	sub.w	d0,x1(a0)
	move.w	die_adjust_y(a0),d0
	sub.w	d0,y1(a0)

	move.w	spr_score(a0),d0
	add.l	d0,total_score
	move.l	stage_score_pos,a1
	add.l	d0,(a1)

	move.l	die_gfx(a0),spr_ptr1(a0)

	move.w	#2,spr_type(a0)
	clr.w	spr_num(a0)
	move.w	#-2,spr_die_flag(a0)
	clr.w	spr_rout_flag(a0)

	move.l	sample_start(a0),d5
	move.l	sample_end(a0),d6
	moveq	#-1,d7
	jsr	play_sfx

	subq.w	#1,chain_kill_cnt
	tst.w	chain_kill_cnt
	bpl.s	.n1
	move.w	#-1,chain_kill_cnt
	sf	chain_react_flag
.n1
	

	move.w	#-1,pop_flag1
.e1	rts

lvl_4_ex_cnt	dc.w	0
lvl_4_boss_cnt	dc.w	0
lvl_4_boss_tab	ds.b	10*3

lvl_4_boss_explode_tab
	DC.W	$22,$1B,5,4
	DC.W	$28,$D,7,$13
	DC.W	$21,2,$C,$23
	DC.W	$11,$1A,$1E,$16
	dc.w	-1,-1

do_level_4_boss
	cmp.w	#4,stage
	bne	.return
	cmp.w	#1,scroll_cnt
	bne	.return
	subq.w	#1,lvl_4_boss_cnt
	tst.w	lvl_4_boss_cnt
	bpl	.return
	move.w	#5-1,lvl_4_boss_cnt
	
	moveq	#0,d0

x	set	0
	rept	num_baddies
	tst.w	d0
	bmi	.return
	lea	baddie_struct+x,a1
	move.w	status(a1),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	.tab(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)

x	set	x+sprite_size
	endr

.return	rts

.tab	dc.l	.copy
	dc.l	.return
	dc.l	.return
	dc.l	.return


.copy
	moveq	#0,d1
x	set	0
	rept	3
	lea	lvl_4_boss_tab+x,a0
	move.w	(a0),d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.copy_tab(pc,d1.w),a2
	jsr	(a2)
x	set	x+10
	endr
	rts

.copy_tab	dc.l	.return
	dc.l	.go

.go	;tst.w	spr_die_flag(a1)
	;bpl	.return

	move.w	2(a0),d1
	move.w	4(a0),d2

	move.l	6(a0),a2
	move.w	(a2)+,d3
	cmp.w	#-1,d3
	bne.s	.s2
	clr.w	(a0)
	bra	.return
.s2	move.w	(a2)+,d4
	move.l	a2,6(a0)
	
	add.w	d3,d1
	add.w	d4,d2

	move.w	d1,x_reset(a1)
	move.w	d2,y_reset(a1)
	move.w	d1,x1(a1)
	move.w	d2,y1(a1)

	clr.w	die_adjust_x(a1)
	clr.w	die_adjust_y(a1)
	clr.w	spr_score(a1)

	;move.w	#9-1,spr_frames(a1)
	move.w	#8-1,die_frames(a1)
;	clr.w	spr_num(a1)
;	move.w	#-1,spr_die_flag(a1)
	clr.w	spr_anim_val(a1)

	move.w	#2,status(a1)	; alive
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)
;	clr.w	spr_rout_flag(a1)

;	clr.w	spr_move_dir(a1)
;	clr.w	spr_move_flag(a1)
	move.w	#10,spr_move_mode(a1)

;	clr.w	spr_x_flag(a1)
;	clr.w	spr_x_cnt(a1)
;	clr.w	spr_y_flag(a1)
;	clr.w	spr_y_cnt(a1)
;	clr.w	hit_flag(a1)
;	move.w	#-1,hit_count(a1)
;	clr.w	spr_power(a1)
;	clr.w	spr_energy(a1)
;	clr.w	pickup_type(a1)

;	move.w	#1,spr_x_move_val(a1)
;	clr.w	spr_y_move_val(a1)

	clr.w	spr_mask_flag(a1)

	move.l	#big_die_sprites,spr_ptr1(a1)
	move.l	#big_die_sprites,die_gfx(a1)
;	cmp.w	#8,stage
;	blt.s	.no_blue1
;	move.l	#blue_big_die_sprites,spr_ptr1(a1)
;	move.l	#blue_big_die_sprites,die_gfx(a1)
;.no_blue1

	move.w	#1,spr_type(a1)
	move.l	die_gfx(a1),spr_ptr1(a1)
	clr.w	spr_num(a1)
	move.w	#-1,spr_die_flag(a1)
	clr.w	spr_rout_flag(a1)
	move.w	#-1,spr_energy(a1)

;	cmp.w	#1,scroll_cnt
;	beq.s	.s0
;	move.w	spr_x_move_val(a0),d0
;	sub.w	d0,boss_die_offset
;.s0

	move.l	#bad_die_sfx2+12,d5
	move.l	#bad_die_sfx2_end,d6
	moveq	#-1,d7
	jsr	play_sfx

.e1
	move.l	(sp)+,d0
	moveq	#-1,d0
.e2	rts

do_boss_explode
	tst.b	escape_flag
	bne	.return

;	cmp.w	#1,stage
	cmp.w	#2,stage
	beq	.s0
	cmp.w	#3,stage
	beq	.s0
	cmp.w	#4,stage
	beq	.return
	cmp.w	#5,stage
	beq	.return
	cmp.w	#6,stage
	beq	.return
	cmp.w	#7,stage
	beq	.s0
	cmp.w	#8,stage
	beq	.s0
	bsr	boss_chain_reaction
.s0

	subq.w	#1,boss_explode_cnt
	tst.w	boss_explode_cnt
	bpl	.e1
	move.w	#5-1,boss_explode_cnt

	moveq	#0,d0

x	set	0
	rept	num_baddies
	tst.w	d0
	bmi	.return
	lea	baddie_struct+x,a1
	move.w	status(a1),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	.tab(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)

x	set	x+sprite_size
	endr

.return	rts

.tab	dc.l	.copy
	dc.l	.return
	dc.l	.return
	dc.l	.return

.copy

;	cmp.w	#5,stage
;	beq	.e1
;	cmp.w	#6,stage
;	beq	.e1

	move.l	boss_explode_pos,a0
	move.w	(a0)+,d1
	cmp.w	#-1,d1
	bne.s	.s1
	move.l	boss_explode_reset,a0
	move.w	(a0)+,d1
.s1	move.w	(a0)+,d2
	move.l	a0,boss_explode_pos

	cmp.w	#2,stage
	beq	.no_offset
	cmp.w	#3,stage
	beq	.no_offset
;	cmp.w	#4,stage
;	beq	.no_offset
	cmp.w	#5,stage
	beq	.no_offset
	cmp.w	#6,stage
	beq	.no_offset
	cmp.w	#7,stage
	beq	.no_offset
	cmp.w	#8,stage
	beq	.no_offset
	add.w	boss_die_offset,d1
.no_offset

	move.w	d1,x1(a1)
	move.w	d2,y1(a1)

	move.w	d1,x_reset(a1)
	move.w	d2,y_reset(a1)
	clr.w	die_adjust_x(a1)
	clr.w	die_adjust_y(a1)

	;move.w	#9-1,spr_frames(a1)
	move.w	#11-1,die_frames(a1)
;	clr.w	spr_num(a1)
;	move.w	#-1,spr_die_flag(a1)
	clr.w	spr_anim_val(a1)

	move.w	#2,status(a1)	; alive
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)
;	clr.w	spr_rout_flag(a1)

;	clr.w	spr_move_dir(a1)
;	clr.w	spr_move_flag(a1)
	move.w	#10,spr_move_mode(a1)

;	clr.w	spr_x_flag(a1)
;	clr.w	spr_x_cnt(a1)
;	clr.w	spr_y_flag(a1)
;	clr.w	spr_y_cnt(a1)
;	clr.w	hit_flag(a1)
;	move.w	#-1,hit_count(a1)
;	clr.w	spr_power(a1)
;	clr.w	spr_energy(a1)
;	clr.w	pickup_type(a1)

;	move.w	#1,spr_x_move_val(a1)
;	clr.w	spr_y_move_val(a1)

	clr.w	spr_mask_flag(a1)

	move.l	#big_die_sprites,spr_ptr1(a1)
	move.l	#big_die_sprites,die_gfx(a1)
;	cmp.w	#8,stage
;	blt.s	.no_blue1
;	move.l	#blue_big_die_sprites,spr_ptr1(a1)
;	move.l	#blue_big_die_sprites,die_gfx(a1)
;.no_blue1

	move.w	#1,spr_type(a1)
	move.l	die_gfx(a1),spr_ptr1(a1)
	clr.w	spr_num(a1)
	move.w	#-1,spr_die_flag(a1)
	clr.w	spr_rout_flag(a1)
	move.w	#-1,spr_energy(a1)

;	cmp.w	#1,scroll_cnt
;	beq.s	.s0
;	move.w	spr_x_move_val(a0),d0
;	sub.w	d0,boss_die_offset
;.s0

	move.l	#bad_die_sfx2+12,d5
	move.l	#bad_die_sfx2_end,d6
	moveq	#-1,d7
	jsr	play_sfx


.e1	moveq	#-1,d0
	rts


boss_die_offset	dc.w	0

boss_explode_reset
	dc.l	0
boss_explode_pos
	dc.l	0

boss_chain_reaction

	subq.w	#1,boss_chain_react_cnt1
	tst.w	boss_chain_react_cnt1
	bpl	.return
	move.w	#-1,boss_chain_react_cnt1

	subq.w	#1,boss_chain_react_cnt2
	tst.w	boss_chain_react_cnt2
	bpl	.return
	move.w	#4,boss_chain_react_cnt2

	clr.w	pop_flag1

x	set	0
	rept	num_baddies

	tst.w	pop_flag1
	bne	.return

	lea	baddie_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a1
	add.w	d0,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+sprite_size
	endr


.return	rts

.tab	dc.l	.return
	dc.l	.check
	dc.l	.check
	dc.l	.return

.check	cmp.w	#12,spr_move_mode(a0)
	bne.s	.e1
	tst.w	spr_die_flag(a0)
	bne.s	.e1

	move.w	die_adjust_x(a0),d0
	sub.w	d0,x1(a0)
	move.w	die_adjust_y(a0),d0
	sub.w	d0,y1(a0)

;	move.w	spr_score(a0),d0
;	add.l	d0,total_score
;	move.l	stage_score_pos,a1
;	add.l	d0,(a1)

	move.l	die_gfx(a0),spr_ptr1(a0)

	move.w	#1,spr_type(a0)
	clr.w	spr_num(a0)
	move.w	#-1,spr_die_flag(a0)
	clr.w	spr_rout_flag(a0)
	move.w	#-1,spr_energy(a0)

	move.l	sample_start(a0),d5
	move.l	sample_end(a0),d6
	moveq	#-1,d7
	bsr	play_sfx

	move.w	#-1,pop_flag1
.e1	rts

generate_bullet	tst.b	intro_done
	beq	.e1
	tst.w	demo_mode
	bmi	.e1

	subq.w	#1,bullet_cnt
	tst.w	bullet_cnt
	bpl	.e1
	move.w	#-1,bullet_cnt
	cmp.w	#1,difficulty
	bgt.s	.skip
	move.w	difficulty,bullet_cnt
.skip

	jsr	rand
	move.l	seed,d0
	and.l	#num_baddies-1,d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.baddie_tab(pc),a0
	add.w	d0,a0
	move.l	(a0),a0

	clr.w	pop_flag1

x	set	0
	rept	num_bullets
	tst.w	pop_flag1
	bmi	.e1
	lea	bullet_struct+x,a1
	move.w	status(a1),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr

.e1	rts

.tab	dc.l	.create_bullet
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1

.baddie_tab
x	set	0
	rept	num_baddies
	dc.l	baddie_struct+x
x	set	x+sprite_size
	endr


.create_bullet
	cmp.w	#2,status(a0)
	bne	.e1

	tst.w	spr_die_flag(a0)
	bmi	.e1

	cmp.w	#0,x1(a0)
	blt	.e1
	cmp.w	#320-32,x1(a0)
	bgt	.e1

	cmp.w	#25,spr_type(a0)
	beq	.do_crawl
	cmp.w	#26,spr_type(a0)
	beq	.do_crawl

	cmp.w	#0,y1(a0)
	blt	.e1
	cmp.w	#200-8-32,y1(a0)
	bgt	.e1
.do_crawl
	move.w	spr_type(a0),d0
;	cmp.w	#12,d0	; max table entry
;	bgt	.return
	add.w	d0,d0
	add.w	d0,d0
	move.l	.lookup_tab(pc,d0.w),a2
	jmp	(a2)

.lookup_tab	dc.l	.do_bullet
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.check1
	dc.l	.check1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1	*s3
	dc.l	.do_bullet

	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1
	dc.l	.do_laser
	dc.l	.e1

	dc.l	.do_bullet
	dc.l	.do_bullet

	dc.l	.e1
	dc.l	.e1
	dc.l	.do_laser
	dc.l	.e1

.do_bullet	move.w	difficulty,bullet_cnt

	cmp.l	#bullet_struct+(sprite_size*(num_bullets-8)),a1
	bge	.e1

	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	8(a2),d0
	move.w	12(a2),d1
	lsr.w	#1,d0
	lsr.w	#1,d1

	move.w	x1(a0),d2
	move.w	y1(a0),d3
	add.w	d0,d2
	add.w	d1,d3

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	subq.w	#3,d2
	subq.w	#3,d3


	move.w	d2,x_reset(a1)
	move.w	d3,y_reset(a1)

	sub.w	player_struct+x1,d2
	clr.w	spr_x_flag(a1)
	tst.w	d2
	bmi.s	.s2
	move.w	#-1,spr_x_flag(a1)

	cmp.w	#25,spr_type(a0)
	bne.s	.s2
	sub.w	#11,x_reset(a1)
	bra	.no_crawl1

.s2	cmp.w	#25,spr_type(a0)
	bne.s	.no_crawl1
	add.w	#11,x_reset(a1)
.no_crawl1

	sub.w	player_struct+y1,d3
	clr.w	spr_y_flag(a1)
	tst.w	d3
	bmi.s	.s3
	move.w	#-1,spr_y_flag(a1)

	cmp.w	#26,spr_type(a0)
	bne.s	.s3
	sub.w	#11,y_reset(a1)
	bra	.no_crawl2

.s3	cmp.w	#26,spr_type(a0)
	bne.s	.no_crawl2
	add.w	#11,y_reset(a1)
.no_crawl2
	
	move.l	#bullet_sprites,spr_ptr1(a1)
	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_mode(a1)
	move.w	#6,spr_move_dir(a1)	; home up
	clr.w	spr_die_flag(a1)

	jsr	rand
	move.l	seed,d0
	and.l	#4-1,d0
	addq.w	#2,d0
	move.w	d0,spr_x_move_val(a1)	; pixels to move

	jsr	rand
	move.l	seed,d0
	and.l	#4-1,d0
	addq.w	#2,d0
	move.w	d0,spr_y_move_val(a1)	; pixels to move

	clr.w	spr_move_flag(a1)
	move.w	#1,spr_anim_val(a1)

	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	move.w	#-1,spr_mask_flag(a1)

	move.w	#5,spr_power(a1)

	clr.w	spr_num(a1)

	clr.w	spr_score(a1)
	move.w	#-1,spr_rout_flag(a1)

	movem.l	.bullet_tab(pc),d1-d6
	movem.l	d1-d6,spr_skew_tab(a1)

	move.w	#-1,pop_flag1	; pop address off stack

	cmp.w	#3,spr_anim_val(a0)
	beq	.set_turret1
	cmp.w	#4,spr_anim_val(a0)
	beq	.set_turret2


.return	rts

.do_laser	cmp.w	#8,stage
	bge	.return

	move.w	difficulty,bullet_cnt

	cmp.l	#bullet_struct+(sprite_size*(num_bullets-8)),a1
	bge	.e1

	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	8(a2),d0
	move.w	12(a2),d1
	lsr.w	#1,d0
	lsr.w	#1,d1

	move.w	x1(a0),d2
	move.w	y1(a0),d3
	add.w	d0,d2
	add.w	d1,d3

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	sub.w	#32,d2
	subq.w	#2,d3

	move.w	d2,x_reset(a1)
	move.w	d3,y_reset(a1)

	cmp.w	#29,spr_type(a0)
	bne.s	.bod
	jsr	rand
	move.l	seed,d0
	and.l	#4-1,d0
	mulu	#11,d0
	sub.w	#6,x_reset(a1)
	move.w	y1(a0),y_reset(a1)
	add.w	d0,y_reset(a1)
	add.w	#5,y_reset(a1)
.bod
	move.w	#-1,spr_x_flag(a1)
	move.l	#spin_laser,spr_ptr1(a1)
	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_mode(a1)
	move.w	#5,spr_move_dir(a1)	; home up
	clr.w	spr_die_flag(a1)

	move.w	#6-1,spr_x_move_val(a1)	; pixels to move

	clr.w	spr_y_move_val(a1)	; pixels to move

	clr.w	spr_move_flag(a1)
	move.w	#1,spr_anim_val(a1)

	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	move.w	#-1,spr_mask_flag(a1)

	move.w	#-2,spr_power(a1)

	clr.w	spr_num(a1)

	clr.w	spr_score(a1)
	clr.w	spr_rout_flag(a1)

	;move.w	#-1,spr_rout_flag(a1)

	;movem.l	.bullet_tab(pc),d1-d6
	;movem.l	d1-d6,spr_skew_tab(a1)

	move.w	#-1,pop_flag1	; pop address off stack

;	cmp.w	#3,spr_anim_val(a0)
;	beq	.set_turret1
;	cmp.w	#4,spr_anim_val(a0)
;	beq	.set_turret2


	rts

.check1	move.w	player_struct+x1,d0
	move.w	player_struct+y1,d1
	move.w	d0,d2
	move.w	d1,d3
	add.w	#32,d2
	add.w	#14,d3
	move.w	x_reset(a0),d4
	move.w	y_reset(a0),d5
	add.w	#32,d4
	add.w	#16,d5
	move.w	d4,d6
	move.w	d5,d7
	add.w	#(64*3)-64,d6
	add.w	#(16*12)-(16*2)-(32*2),d7

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	d7,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1


	bra	.do_bullet

.s1
	move.w	#-1,pop_flag1
	rts

.bullet_tab	dc.l	mul_16x6_4_bpl
	dc.l	0
	dc.l	restore_16x6
	dc.l	draw_16x6_4_bpl
	dc.l	bullet_sprites_gfx
	dc.l	bullet_mul_tab

.set_turret1	move.w	spr_num(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.t_tab1(pc,d0.w),a2
	jmp	(a2)

.t_tab1	dc.l	.t0_a
	dc.l	.t1_a
	dc.l	.t2_a
	dc.l	.t3_a
	dc.l	.t4_a
	dc.l	.t5_a

.t0_a	move.w	#-2,spr_y_flag(a1)	; no movement
	move.w	#-1,spr_x_flag(a1)
	bra	.return

.t1_a	move.w	#-1,spr_y_flag(a1)
	move.w	#-1,spr_x_flag(a1)
	move.w	spr_y_move_val(a1),spr_x_move_val(a1)
	bra	.return

.t2_a	move.w	#-2,spr_x_flag(a1)
	move.w	#-1,spr_y_flag(a1)
	bra	.return

.t3_a	move.w	#-2,spr_x_flag(a1)
	move.w	#-1,spr_y_flag(a1)
	bra	.return

.t4_a	move.w	#-1,spr_y_flag(a1)
	clr.w	spr_x_flag(a1)
	move.w	spr_y_move_val(a1),spr_x_move_val(a1)
	bra	.return

.t5_a	move.w	#-2,spr_y_flag(a1)
	clr.w	spr_x_flag(a1)
	bra	.return

.set_turret2	move.w	spr_num(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.t_tab2(pc,d0.w),a2
	jmp	(a2)

.t_tab2	dc.l	.t0_b
	dc.l	.t1_b
	dc.l	.t2_b
	dc.l	.t3_b
	dc.l	.t4_b
	dc.l	.t5_b

.t0_b	move.w	#-2,spr_y_flag(a1)
	move.w	#-1,spr_x_flag(a1)
	bra	.return

.t1_b	move.w	#-1,spr_x_flag(a1)
	clr.w	spr_y_flag(a1)
	move.w	spr_y_move_val(a1),spr_x_move_val(a1)
	bra	.return

.t2_b	move.w	#-2,spr_x_flag(a1)
	clr.w	spr_y_flag(a1)
	bra	.return

.t3_b	move.w	#-2,spr_x_flag(a1)
	clr.w	spr_y_flag(a1)
	bra	.return

.t4_b	clr.w	spr_x_flag(a1)
	clr.w	spr_y_flag(a1)
	move.w	spr_y_move_val(a1),spr_x_move_val(a1)
	bra	.return

.t5_b	move.w	#-2,spr_y_flag(a1)
	clr.w	spr_x_flag(a1)
	bra	.return

move_bullets	tst.b	intro_done
	beq	.return

x	set	0
	rept	num_bullets
	lea	bullet_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab1(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.return	rts

.tab1	dc.l	.return
	dc.l	.move_em
	dc.l	.move_em
	dc.l	.die_check

.move_em	tst.w	spr_die_flag(a0)
	bne.s	.return
	move.w	spr_move_mode(A0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab2(pc,d0.w),a2
	jmp	(a2)

.tab2	dc.l	move_normal_bullet
	dc.l	move_big_shot_bullet
	dc.l	move_boss_shot
	dc.l	move_rocket_shot

.die_check	subq.w	#1,die_cnt(a0)
	tst.w	die_cnt(a0)
	bpl.s	.s1
	move.w	#-1,die_cnt(a0)
	clr.w	status(a0)
.s1	rts

move_normal_bullet
	;tst.w	spr_die_flag(a0)
	;bmi	.e1


	subq.w	#1,x_reset(a0)

	cmp.w	#-2,spr_x_flag(a0)
	beq	.s1

	move.w	spr_x_move_val(a0),d0
	tst.w	spr_x_flag(a0)
	bpl	.s2

	sub.w	d0,x_reset(a0)
	cmp.w	#-48,x_reset(a0)
	bgt.s	.s1
	move.w	#-48,x_reset(a0)
	move.w	#3,status(a0)
	bra	.e1
.s2
	add.w	d0,x_reset(a0)
	cmp.w	#320-1,x_reset(a0)
	blt.s	.s1
	move.w	#320-1,x_reset(a0)
	move.w	#3,status(a0)
	bra	.e1
.s1

	cmp.w	#-2,spr_y_flag(a0)
	beq	.s3
	move.w	spr_y_move_val(a0),d0
	tst.w	spr_y_flag(a0)
	bpl	.s4

	sub.w	d0,y_reset(a0)
	cmp.w	#-4,y_reset(a0)
	bgt.s	.s3
	move.w	#-4,y_reset(a0)
	move.w	#3,status(a0)
	bra	.e1
.s4
	add.w	d0,y_reset(a0)
	cmp.w	#200-8-1,y_reset(a0)
	blt.s	.s3
	move.w	#200-8-1,y_reset(a0)
	move.w	#3,status(a0)
	bra	.e1
.s3
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)
.e1	rts

move_big_shot_bullet
	;tst.w	spr_die_flag(a0)
	;bmi	.e1

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.s0
	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)
.e1	rts

move_boss_shot	;tst.w	spr_die_flag(a0)
	;bmi	.e1

	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	subq.w	#4,d1

	sub.w	boss_shot_dec,d0

	cmp.w	#$ffea,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.l	a2,spr_sin_tab(a0)

	move.w	d0,x_reset(a0)
	move.w	d1,y_reset(a0)

	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)
.e1	rts

move_rocket_shot
	;tst.w	spr_die_flag(a0)
	;bmi	.e1

	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	move.w	(a2)+,spr_num(a0)

	cmp.w	#-1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.l	a2,spr_sin_tab(a0)

	move.w	x_reset(a0),d2
	move.w	y_reset(a0),d3

	tst.w	spr_x_flag(a0)
	bne.s	.j1
	add.w	d0,d2
	bra.s	.j2
.j1
	sub.w	d0,d2
.j2
	add.w	d1,d3

	move.w	d2,x1(a0)
	move.w	d3,y1(a0)

	cmp.w	#1,scroll_cnt
	beq.s	.e1
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.e1	rts



animate_bullets
	subq.w	#1,bullet_animate_cnt

	cmp.w	#0,bullet_animate_cnt
	bgt	.return
	move.w	#2,bullet_animate_cnt

x	set	0
	rept	num_bullets
	lea	bullet_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a1
	add.w	d0,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+sprite_size
	endr

.return	rts

.tab	dc.l	.return
	dc.l	.return
	dc.l	.animate
	dc.l	.return

.animate	tst.w	spr_die_flag(a0)
	beq.s	.skip
	jmp	anim_kill
.skip
	move.w	spr_anim_val(a0),d0
	tst.w	d0
	bmi	.return
	add.w	d0,d0
	add.w	d0,d0
	move.l	.anim_tab(pc,d0.w),a1
	jmp	(a1)

.anim_tab	dc.l	.s1
	dc.l	.anim_normal
	dc.l	.anim_big_shot1
	rept	17-3
	dc.l	.s1
	endr

.anim_normal	subq.w	#1,spr_num(a0)
	tst.w	spr_num(a0)
	bpl.s	.s1
	move.w	#4-1,spr_num(a0)
.s1	rts

.anim_big_shot1	
	clr.w	spr_num(a0)
	not.b	big_shot_flag
	tst.b	big_shot_flag
	bne.s	.s2
	move.w	#1,spr_num(a0)
.s2	rts

search_4_baddie
	tst.b	intro_done
	beq	.e1
	tst.w	demo_mode
	bmi	.e1

	bsr	offset_boss_shot

	subq.w	#1,big_shot_cnt1
	tst.w	big_shot_cnt1
	bpl	.e1
	move.w	#-1,big_shot_cnt1

x	set	0
	rept	num_baddies
	lea	baddie_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.baddie_tab(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
	rts

.baddie_tab	dc.l	.e1
	dc.l	.active
	dc.l	.active
	dc.l	.e1

.active	clr.w	pop_flag1
x	set	0
	rept	num_bullets
	tst.w	pop_flag1
	bmi	.e1
	lea	bullet_struct+x,a1
	move.w	status(a1),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.bullet_tab(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.e1	rts

.bullet_tab	dc.l	.do_bullet
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1

.do_bullet
	cmp.w	#6,spr_type(a0)
	beq	.set_up1

	cmp.w	#7,spr_type(a0)
	beq	.set_up2
	cmp.w	#3,spr_type(a0)
	beq	.set_up3
	rts

.set_up1
	move.w	#40-1,big_shot_cnt1

	move.w	#1,spr_num(a0)

	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	8(a2),d0
	move.w	12(a2),d1
	lsr.w	#1,d0
	lsr.w	#1,d1

	move.w	x1(a0),d2
	move.w	y1(a0),d3
	add.w	d0,d2
	add.w	d1,d3

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	sub.w	#32+16,d2
	sub.w	#12,d3
	move.w	d2,x_reset(a1)
	move.w	d3,y_reset(a1)

	move.l	#big_shot_sprite1,spr_ptr1(a1)
	move.w	#1,spr_move_mode(a1)
	move.w	#2,spr_anim_val(a1)
	move.w	#8,spr_x_move_val(a1)	; pixels to move
	clr.w	spr_y_move_val(a1)	; pixels to move
	move.w	#2-1,spr_frames(a1)

	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	move.w	#6,spr_move_dir(a1)	; home up
	clr.w	spr_die_flag(a1)

	clr.w	spr_move_flag(a1)

	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	move.w	#-1,spr_mask_flag(a1)

	move.w	#-2,spr_power(a1)

	clr.w	spr_num(a1)
	clr.w	spr_score(a1)
	clr.w	pickup_type(a1)

	clr.w	spr_rout_flag(a1)
	move.w	#-1,pop_flag1
	rts

.set_up2	move.w	#24-1,big_shot_cnt1

	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	8(a2),d0
	move.w	12(a2),d1
	lsr.w	#1,d0
	lsr.w	#1,d1

	move.w	x1(a0),d2
	move.w	y1(a0),d3
	add.w	d0,d2
	add.w	d1,d3

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	sub.w	#32+4,d2
	sub.w	#14,d3
	move.w	d2,x_reset(a1)
	move.w	d3,y_reset(a1)

	move.l	#big_shot_sprite2,spr_ptr1(a1)
	move.w	#1,spr_move_mode(a1)
	clr.w	spr_anim_val(a1)
	move.w	#10,spr_x_move_val(a1)	; pixels to move
	clr.w	spr_y_move_val(a1)	; pixels to move
	clr.w	spr_frames(a1)

	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	move.w	#6,spr_move_dir(a1)	; home up
	clr.w	spr_die_flag(a1)

	clr.w	spr_move_flag(a1)

	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	move.w	#-1,spr_mask_flag(a1)

	move.w	#5,spr_power(a1)

	clr.w	spr_num(a1)
	clr.w	spr_score(a1)
	clr.w	pickup_type(a1)

	move.w	#-1,spr_rout_flag(a1)

	movem.l	.big_shot_tab(pc),d1-d6
	movem.l	d1-d6,spr_skew_tab(a1)

	move.w	#-1,pop_flag1
	rts

.big_shot_tab	dc.l	mul_16x10_4_bpl
	dc.l	0
	dc.l	restore_16x10
	dc.l	draw_16x10_4_bpl
	dc.l	big_shot_sprites2_gfx
	dc.l	big_shot_mul_tab

.set_up3	cmp.w	#2,stage
	beq	.e1
	cmp.w	#3,stage
	beq	.e1

	cmp.w	#8-1,spr_num(a0)	; weak point appeared?
	blt	.e1

	subq.w	#1,big_shot_cnt3
	tst.w	big_shot_cnt3
	bpl	.return
	move.w	#6-1,big_shot_cnt3	; gap
	
	subq.w	#1,big_shot_cnt2
	tst.w	big_shot_cnt2
	bpl.s	.skip1
	move.w	#6-1,big_shot_cnt2	; number of sprites
	move.w	#70-1,big_shot_cnt1	; number between shots


.skip1

	move.w	#-1,x1(a1)
	move.w	#-1,x_reset(a1)

	move.w	#-1,y1(a1)
	move.w	#-1,y_reset(a1)

	move.l	level_point,a2
	lea	12+2(a2),a2
	move.l	(a2),a2
	addq.w	#2,a2
	move.l	4*15(a2),spr_ptr1(a1)

;	move.l	#boss_shot_sprites,spr_ptr1(a1)
	move.w	#2,spr_move_mode(a1)
	move.w	#1,spr_anim_val(a1)
	move.w	#10,spr_x_move_val(a1)	; pixels to move
	clr.w	spr_y_move_val(a1)	; pixels to move
	clr.w	spr_frames(a1)

	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	move.w	#6,spr_move_dir(a1)	; home up
	clr.w	spr_die_flag(a1)

	clr.w	spr_move_flag(a1)

	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	move.w	#-1,spr_mask_flag(a1)

	move.w	#-2,spr_power(a1)

	clr.w	spr_num(a1)
	clr.w	spr_score(a1)
	clr.w	pickup_type(a1)

	clr.w	spr_rout_flag(a1)

	move.w	player_struct+x1,d0
	move.w	player_struct+y1,d1
	move.w	d0,d2
	move.w	d1,d3
	add.w	#32,d2
	add.w	#14,d3

	moveq	#0,d4
	moveq	#0,d5
	move.w	#319,d6
	move.w	#99,d7

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	d7,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

	move.l	#.boss_sinus1,spr_sin_tab(a1)
	move.w	#8,spr_type(a1)
	bra	.return

.s1
	moveq	#0,d4
	move.w	#99+25,d5
	move.w	#319,d6
	move.w	#200-8,d7

	cmp.w	d6,d0
	bgt.s	.s2
	cmp.w	d7,d1
	bgt.s	.s2

	cmp.w	d4,d2
	blt.s	.s2
	cmp.w	d5,d3
	blt.s	.s2

	move.l	#.boss_sinus2,spr_sin_tab(a1)
	move.w	#8,spr_type(a1)

	bra	.return

.s2
	move.l	#.boss_sinus3,spr_sin_tab(a1)
	move.w	#8,spr_type(a1)

.return	move.w	#-1,pop_flag1

	rts

.boss_sinus1	DC.W	$E2,$63,$DE,$63
	DC.W	$DA,$63,$D6,$63
	DC.W	$D2,$63,$CE,$63
	DC.W	$CA,$63,$C6,$63
	DC.W	$C2,$63,$BE,$63
	DC.W	$BA,$63,$B6,$62
	DC.W	$B2,$62,$AE,$62
	DC.W	$AA,$61,$A6,$61
	DC.W	$A2,$60,$9E,$5F
	DC.W	$9A,$5F,$96,$5E
	DC.W	$92,$5D,$8E,$5C
	DC.W	$8A,$5B,$86,$5A
	DC.W	$82,$59,$7E,$58
	DC.W	$7A,$57,$76,$55
	DC.W	$72,$54,$6E,$53
	DC.W	$6A,$52,$66,$50
	DC.W	$62,$4F,$5E,$4D
	DC.W	$5A,$4C,$56,$4A
	DC.W	$52,$49,$4E,$47
	DC.W	$4A,$45,$46,$44
	DC.W	$42,$42,$3E,$41
	DC.W	$3A,$3F,$36,$3D
	DC.W	$32,$3B,$2E,$3A
	DC.W	$2A,$38,$26,$36
	DC.W	$22,$34,$1E,$33
	DC.W	$1A,$31,$16,$2F
	DC.W	$12,$2D,$E,$2B
	DC.W	$A,$2A,6,$28
	DC.W	2,$26,$FFFE,$25
	DC.W	$FFFA,$23,$FFF6,$21
	DC.W	$FFF2,$1F,$FFEE,$1E
	DC.W	$FFEA,$1C

.boss_sinus2	DC.W	$E2,$63,$DE,$63
	DC.W	$DA,$63,$D6,$63
	DC.W	$D2,$63,$CE,$63
	DC.W	$CA,$63,$C6,$63
	DC.W	$C2,$64,$BE,$64
	DC.W	$BA,$64,$B6,$65
	DC.W	$B2,$65,$AE,$65
	DC.W	$AA,$66,$A6,$66
	DC.W	$A2,$67,$9E,$68
	DC.W	$9A,$68,$96,$69
	DC.W	$92,$6A,$8E,$6A
	DC.W	$8A,$6B,$86,$6C
	DC.W	$82,$6D,$7E,$6E
	DC.W	$7A,$6E,$76,$6F
	DC.W	$72,$70,$6E,$71
	DC.W	$6A,$72,$66,$73
	DC.W	$62,$74,$5E,$75
	DC.W	$5A,$76,$56,$77
	DC.W	$52,$78,$4E,$79
	DC.W	$4A,$7A,$46,$7C
	DC.W	$42,$7D,$3E,$7E
	DC.W	$3A,$7F,$36,$80
	DC.W	$32,$81,$2E,$82
	DC.W	$2A,$83,$26,$85
	DC.W	$22,$86,$1E,$87
	DC.W	$1A,$88,$16,$89
	DC.W	$12,$8A,$E,$8B
	DC.W	$A,$8C,6,$8D
	DC.W	2,$8E,$FFFE,$90
	DC.W	$FFFA,$91,$FFF6,$92
	DC.W	$FFF2,$93,$FFEE,$94
	DC.W	$FFEA,$94


.boss_sinus3
x	set	0
	rept	18+16+16+16-3
	dc.w	x+320+16+2-(64*2)+16	; x
	dc.w	((16*6)-2-3)+8	; y
x	set	x-4
	endr

offset_boss_shot
x	set	0
	rept	num_baddies
	lea	baddie_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.baddie_tab(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.e1	rts

.baddie_tab	dc.l	.e1
	dc.l	.active
	dc.l	.active
	dc.l	.e1

.active	cmp.w	#2,stage
	beq.s	.j0
	cmp.w	#3,spr_type(a0)
	bne.s	.j0
	cmp.w	#8-1,spr_num(a0)
	blt.s	.j0
	cmp.w	#1,scroll_cnt
	beq.s	.j0
	addq.w	#1,boss_shot_dec
.j0	rts

bullet_and_map	lea	bullet_struct,a0

	move.w	#num_bullets-1,bullet_cnt2
.l0

	cmp.w	#8,spr_type(a0)
	beq	.s3

	cmp.w	#0,status(a0)
	beq	.s3
	cmp.w	#3,status(a0)
	beq	.s3

	move.w	x1(A0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3
	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; add height

	move.l	map_buff_pos,a3

	moveq	#12-1,d7
.l2
	moveq	#6-1,d6

.l1	cmp.w	#0,tile_flag(a3)
	beq	.s1 

	movem.w	tile_x1(a3),d4/d5/a5/a6	; tile coords

.l3	cmp.w	a5,d0
	bgt.s	.s1
	cmp.w	a6,d1
	bgt.s	.s1
	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

	tst.w	spr_die_flag(a0)
	bne	.s3
	move.w	#-1,spr_die_flag(a0)

	cmp.l	#rocket_sprites,spr_ptr1(a0)
	bne.s	.j1

	move.w	d0,-(sp)
	move.w	die_adjust_x(a0),d0
	sub.w	d0,x1(a0)
	move.w	die_adjust_y(a0),d0
	sub.w	d0,y1(a0)
	move.w	(sp)+,d0

	move.l	die_gfx(a0),spr_ptr1(a0)

	move.w	#1,spr_type(a0)
	clr.w	spr_num(a0)
	move.w	#-1,spr_die_flag(a0)
	clr.w	spr_rout_flag(a0)
	clr.w	spr_anim_val(a0)

	bra	.s3

.j1	tst.w	spr_move_flag(a0)
	bne.s	.n1
	move.w	#3,status(a0)

	bra	.s1
.n1
	bra.s	.s3

.s1
	lea	tile_size(a3),a3
	dbf	d6,.l1

.s2	lea	-(tile_size*6)+((tile_size*7)*2)(a3),a3
	dbf	d7,.l2

.s3	lea	sprite_size(a0),a0
	subq.w	#1,bullet_cnt2
	tst.w	bullet_cnt2
	bpl	.l0

.e1	rts

plr_and_bullets
	tst.w	cheat_flag	; cheat on - can't die!
	bne	.return
	
	lea	player_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

x	set	0
	rept	num_bullets
	tst.w	pop_flag1
	bne	.return
	lea	bullet_struct+x,a1
	move.w	status(a1),d4
	add.w	d4,d4
	add.w	d4,d4
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.return	rts

.table2	dc.l	.return
	dc.l	.return
	dc.l	.detect
	dc.l	.return

.detect	tst.w	spr_die_flag(a1)
	bne	.s1

	move.l	spr_ptr1(a1),a3
	addq.w	#6,a3

	move.w	spr_num(a1),d4
	lsl.w	#5,d4
	add.w	d4,a3

	move.w	x1(a1),d4
	move.w	y1(a1),d5

	move.w	d4,d6
	move.w	d5,d7

	add.w	8(a3),d6	; width in pixels
	add.w	12(a3),d7	; height

;	movem.w	(a3),d4-d6/a3	; tile coords

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	d7,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

;	cmp.w	#0,rest_cnt(a0)	; wait for 2 backgrounds to be stored
;	bgt.s	.s1

;	move.w	#$700,$fffff8240.w

	tst.w	cheat_flag	; cheat on - can't die!
	bne.s	.n1
	st	player_dead
.n1
	move.w	#-1,pop_flag1


.s1	rts

force_and_bullet
;	tst.w	cheat_flag	; cheat on - can't die!
;	bne	.return
	
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

x	set	0
	rept	num_bullets
	tst.w	pop_flag1
	bne	.return
	lea	bullet_struct+x,a1
	move.w	status(a1),d4
	add.w	d4,d4
	add.w	d4,d4
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.return	rts

.table2	dc.l	.return
	dc.l	.return
	dc.l	.detect
	dc.l	.return

.detect	tst.w	spr_die_flag(a1)
	bne	.s1

	move.l	spr_ptr1(a1),a3
	addq.w	#6,a3

	move.w	spr_num(a1),d4
	lsl.w	#5,d4
	add.w	d4,a3

	move.w	x1(a1),d4
	move.w	y1(a1),d5

	move.w	d4,d6
	move.w	d5,d7

	add.w	8(a3),d6	; width in pixels
	add.w	12(a3),d7	; height

;	movem.w	(a3),d4-d6/a3	; tile coords

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	d7,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

;	cmp.w	#0,rest_cnt(a0)	; wait for 2 backgrounds to be stored
;	bgt.s	.s1

;	move.w	#$700,$fffff8240.w

;	tst.w	cheat_flag	; cheat on - can't die!
;	bne.s	.n1
;	st	player_dead
;.n1
	cmp.w	#-2,spr_power(a1)
	beq.s	.j1
	move.w	#3,status(a1)
.j1

	move.w	#-1,pop_flag1

.s1	rts

plr_and_map	lea	player_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	addq.w	#5,d0

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	subq.w	#1,d2

	move.l	map_buff_pos,a1

	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect
	movem.w	(a3),d4-d6/a3	; tile coords

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	a3,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

;	cmp.w	#0,rest_cnt(a0)	; wait for 2 backgrounds to be stored
;	bgt.s	.s1

;	move.w	#$700,$fffff8240.w

	tst.w	cheat_flag	; cheat on - can't die!
	bne.s	.n1
	st	player_dead
.n1

	move.w	#-1,pop_flag1


.s1	rts

plr_and_baddies
	tst.w	cheat_flag	; cheat on - can't die!
	bne	.return
	
	lea	player_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

x	set	0
	rept	num_baddies
	tst.w	pop_flag1
	bne	.return
	lea	baddie_struct+x,a1
	move.w	status(a1),d4
	add.w	d4,d4
	add.w	d4,d4
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.return	rts

.table2	dc.l	.return
	dc.l	.return
	dc.l	.detect
	dc.l	.return

.detect	tst.w	spr_die_flag(a1)
	bne	.s1

	move.l	spr_ptr1(a1),a3
	addq.w	#6,a3

	move.w	spr_num(a1),d4
	lsl.w	#5,d4
	add.w	d4,a3

	move.w	x1(a1),d4
	move.w	y1(a1),d5

	move.w	d4,d6
	move.w	d5,d7

	add.w	8(a3),d6	; width in pixels
	add.w	12(a3),d7	; height

;	movem.w	(a3),d4-d6/a3	; tile coords

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	d7,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

;	cmp.w	#0,rest_cnt(a0)	; wait for 2 backgrounds to be stored
;	bgt.s	.s1

;	move.w	#$700,$fffff8240.w

	tst.w	cheat_flag	; cheat on - can't die!
	bne.s	.n1
	st	player_dead
.n1
	move.w	#-1,pop_flag1


.s1	rts

; 2=speed,3=bit
plr_and_pickup	lea	player_struct,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jmp	(a1)

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

x	set	0
	rept	num_pickup
	tst.w	pop_flag1
	bne	.return
	lea	pickup_struct+x,a1
	move.w	status(a1),d4
	add.w	d4,d4
	add.w	d4,d4
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.return	rts

.table2	dc.l	.return
	dc.l	.return
	dc.l	.detect
	dc.l	.return

.detect	;tst.w	spr_die_flag(a1)
	;bne	.s1

	move.l	spr_ptr1(a1),a3
	addq.w	#6,a3

	move.w	spr_num(a1),d4
	lsl.w	#5,d4
	add.w	d4,a3

	move.w	x1(a1),d4
	move.w	y1(a1),d5

	move.w	d4,d6
	move.w	d5,d7

	add.w	8(a3),d6	; width in pixels
	add.w	12(a3),d7	; height

	cmp.w	d6,d0
	bgt	.s1
	cmp.w	d7,d1
	bgt	.s1

	cmp.w	d4,d2
	blt	.s1
	cmp.w	d5,d3
	blt	.s1

;	cmp.w	#0,rest_cnt(a0)	; wait for 2 backgrounds to be stored
;	bgt.s	.s1

;	move.w	#$700,$fffff8240.w

;	tst.w	spr_die_flag(a1)
;	bne	.s1
;	move.w	#-1,spr_move_flag(a1)

	bsr	add_weapon

	move.w	#3,status(a1)

	move.l	#600,d6
	add.l	d6,total_score
	move.l	stage_score_pos,a2
	add.l	d6,(a2)

	move.l	#pickup_sfx+12,d5
	move.l	#pickup_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx

	move.w	#-1,pop_flag1

.s1	rts

add_weapon	move.w	pickup_type(a1),d4
	add.w	d4,d4
	add.w	d4,d4
	move.l	.tab(pc,d4.w),a3
	jmp	(a3)

.tab	dc.l	.return
	dc.l	.set_power	; red
	dc.l	.set_power	; blue
	dc.l	.set_power	; yellow
	dc.l	.set_missile	; missile
	dc.l	.speed_up	; speed
	dc.l	.do_bit	; bit

.set_missile	st	homing_flag
	rts

.set_power	addq.w	#1,force_power
	cmp.w	#3,force_power
	blt.s	.s1
	move.w	#3,force_power
.s1
	cmp.w	#2,force_power
	blt.s	.s2
	move.w	pickup_type(a1),weapon_type
	cmp.w	#3,weapon_type
	blt.s	.s2
	move.w	#3,weapon_type
.s2
	move.w	force_power,d4
	add.w	d4,d4
	add.w	d4,d4
	lea	.spr_tab1(pc),a3
	tst.b	attached_flag
	beq.s	.j1
	lea	.spr_tab2(pc),a3
.j1	add.w	d4,a3
	move.l	(a3),force_struct+spr_ptr1
	move.w	#2,force_struct+status

	clr.w	force_struct+spr_num

.return	rts

.spr_tab1	dc.l	force_low_sprites
	dc.l	force_low_sprites
	dc.l	force_med_sprites1
	dc.l	force_high_sprites1

.spr_tab2	dc.l	force_low_sprites
	dc.l	force_low_sprites
	dc.l	force_med_sprites2
	dc.l	force_high_sprites1

.speed_up	st	speed_up_flag	; do anim
	move.w	#1,boost_struct+status
	addq.w	#1,plr_speed
	cmp.w	#(2*2)+5,plr_speed
	blt.s	.s3
	move.w	#5,plr_speed
.s3
	rts

.do_bit	move.w	bit_cnt,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.bit_tab(pc,d0.w),a0
	jmp	(a0)

.bit_tab	dc.l	.do_bit1
	dc.l	.do_bit2
	dc.l	.do_bit3

.do_bit1	move.w	player_struct+x1,d0	
	move.w	player_struct+y1,d1	
	addq.w	#8,d0
	sub.w	#14+12,d1
	lea	pod_move_table1,a2
	rept	4
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	endr

	move.w	#2,pod_struct1+status
	move.w	#1,pod_cnt1
	addq.w	#1,bit_cnt
	rts

.do_bit2	move.w	player_struct+x1,d0	
	move.w	player_struct+y1,d1	
	addq.w	#8,d0
	add.w	#14+12,d1
	lea	pod_move_table2,a2
	rept	4
	move.w	d0,(a2)+
	move.w	d1,(a2)+
	endr

	moveq	#0,d0
	move.w	pod_struct1+spr_num,d0
	addq.w	#5,d0
	move.b	.spr_tab(pc,d0.w),d0
	move.w	d0,pod_struct2+spr_num

	move.w	#2,pod_struct2+status
	move.w	pod_cnt1,pod_cnt2
	addq.w	#1,bit_cnt
.do_bit3	rts

.spr_tab	rept	2
	dc.b	11,10,9,8,7,6,5,4,3,2,1,0
	endr

set_up_pickup	cmp.w	#0,pickup_type(a1)
	beq	.return

	movem.l	d0-d7/a0-a6,-(sp)

	clr.w	pop_flag3
x	set	0
	rept	num_pickup
	tst.w	pop_flag3
	bne.s	.s1
	lea	pickup_struct+x,a2
	move.w	status(a2),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a3
	jsr	(a3)
x	set	x+sprite_size
	endr

.s1
	movem.l	(sp)+,d0-d7/a0-a6

.return	rts

.tab	dc.l	.set
	dc.l	.return
	dc.l	.return
	dc.l	.return

.set

;	move.w	#-64,x1(a2)
;	move.w	#-64,y1(a2)


	clr.w	spr_power(a2)

	move.w	#2,status(a2)	; alive
	move.w	#2,rest_cnt(a2)
	move.w	#2,die_cnt(a2)

	clr.w	spr_move_dir(a2)
	clr.w	spr_die_flag(a2)
	clr.w	spr_move_flag(a2)

	move.l	#pickup_sprites,spr_ptr1(a2)
	move.w	#1,spr_type(a2)
	move.w	pickup_type(a1),d0
	move.w	d0,pickup_type(a2)
	subq.w	#1,d0
	move.w	d0,spr_num(a2)


; offset icon coords
	move.w	pickup_type(a1),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.offset_tab(pc,d0.w),a3
	jmp	(a3)

.offset_tab	dc.l	.return2
	dc.l	.gem	; red
	dc.l	.gem	; blue
	dc.l	.gem	; yellow
	dc.l	.miss	; missile
	dc.l	.speed	; speed
	dc.l	.bit	; bit

.gem
	move.w	x1(a1),d0
	addq.w	#4,d0
	move.w	d0,x1(a2)

	move.w	y1(a1),d0
	addq.w	#7,d0
	move.w	d0,y1(a2)

.return2
	move.w	#-1,pop_flag1
	move.w	#-1,pop_flag2
	move.w	#-1,pop_flag3
	rts

.miss	move.w	x1(a1),d0
	addq.w	#4,d0
	move.w	d0,x1(a2)

	move.w	y1(a1),d0
	addq.w	#7,d0
	move.w	d0,y1(a2)

	move.w	#-1,pop_flag1
	move.w	#-1,pop_flag2
	move.w	#-1,pop_flag3
	rts

.speed	move.w	x1(a1),d0
	addq.w	#2,d0
	move.w	d0,x1(a2)

	move.w	y1(a1),d0
	addq.w	#1,d0
	move.w	d0,y1(a2)

	move.w	#4,spr_num(a2)

	move.w	#-1,pop_flag1
	move.w	#-1,pop_flag2
	move.w	#-1,pop_flag3
	rts

.bit	move.w	x1(a1),d0
	addq.w	#8,d0
	move.w	d0,x1(a2)

	move.w	y1(a1),d0
	add.w	#9,d0
	move.w	d0,y1(a2)

	move.l	#pod_sprites,spr_ptr1(a2)
	clr.w	spr_num(a2)
	move.w	#1,pick_pod_cnt

	move.w	#-1,pop_flag1
	move.w	#-1,pop_flag2
	move.w	#-1,pop_flag3
	rts

baddies_check	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jsr	(a1)
	rts

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active
	clr.w	pop_flag1
	clr.w	pop_flag2
	move.w	x1(a0),d0
	move.w	y1(a0),d1
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; add height


	cmp.l	#force_high_sprites2,spr_ptr1(a0)
	bne.s	.j0
	addq.w	#2,d1
	subq.w	#2,d3
.j0

x	set	0
	rept	num_baddies
	tst.w	pop_flag1
	bmi	.return
	lea	baddie_struct+x,a1
	move.w	status(a1),d4
	add.w	d4,d4
	add.w	d4,d4
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.return	rts

.table2	dc.l	coll_return
	dc.l	.check2	; baddie_check
	dc.l	.check2
	dc.l	coll_return

.check2	jmp	baddie_check

bullets_check	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table1(pc,d0.w),a1
	jsr	(a1)
	rts

.table1	dc.l	.return
	dc.l	.return
	dc.l	.active
	dc.l	.return

.active
	clr.w	pop_flag1
	clr.w	pop_flag2
	move.w	x1(a0),d0
	move.w	y1(a0),d1
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a2),d2	; width in pixels
	add.w	12(a2),d3	; add height


	cmp.l	#force_high_sprites2,spr_ptr1(a0)
	bne.s	.j0
	addq.w	#2,d1
	subq.w	#2,d3
.j0

x	set	0
	rept	num_bullets
	tst.w	pop_flag1
	bmi	.return
	lea	bullet_struct+x,a1
	move.w	status(a1),d4
	add.w	d4,d4
	add.w	d4,d4
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.return	rts

.table2	dc.l	.return
	dc.l	.check2	; baddie_check
	dc.l	.check2
	dc.l	.return

.check2	cmp.l	#rocket_sprites,spr_ptr1(a1)
	bne.s	.return

	jmp	baddie_check

do_fade	tst.b	fade_flag
	bne.s	.return
	move.w	fade_rout,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a1
	jsr	(a1)
.return	rts

.table	dc.l	fade_in_playfield
	dc.l	fade_out_playfield
	dc.l	fade_in_continue
	dc.l	fade_out_continue

fade_in_playfield
	subq.w	#1,fade_cnt
	tst.w	fade_cnt
	bpl.s	.s1
	move.w	fade_speed,fade_cnt

	add.l	#(16*2)+(9*2),pal_pos
	cmp.l	#pal_end,pal_pos
	blt.s	.s1
	move.l	#pal_end,pal_pos

	st	fade_flag
	
.s1
	move.l	pal_pos,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,palbuff

	move.l	(a0)+,stat_palbuff
	move.l	(a0)+,stat_palbuff+(4*1)
	move.l	(a0)+,stat_palbuff+(4*2)
	move.l	(a0)+,stat_palbuff+(4*3)
	move.w	(a0)+,stat_palbuff+(4*4)
	rts

fade_out_playfield
	subq.w	#1,fade_cnt
	tst.w	fade_cnt
	bpl.s	.s1
	move.w	fade_speed,fade_cnt

	sub.l	#(16*2)+(9*2),pal_pos
	cmp.l	#pal,pal_pos
	bgt.s	.s1
	move.l	#pal,pal_pos

	st	fade_flag
.s1
	move.l	pal_pos,a0
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,palbuff

	move.l	(a0)+,stat_palbuff
	move.l	(a0)+,stat_palbuff+(4*1)
	move.l	(a0)+,stat_palbuff+(4*2)
	move.l	(a0)+,stat_palbuff+(4*3)
	move.w	(a0)+,stat_palbuff+(4*4)

	rts


fade_in_continue
	subq.w	#1,fade_cnt
	tst.w	fade_cnt
	bpl.s	.s1
	move.w	fade_speed,fade_cnt

	addq.l	#2*4,pal_pos
	cmp.l	#cont_pal_end,pal_pos
	blt.s	.s1
	move.l	#cont_pal_end,pal_pos

	st	fade_flag
.s1
	move.l	pal_pos,a0
	move.l	(a0)+,palbuff
	move.l	(a0)+,palbuff+4
	rts

fade_out_continue
	subq.w	#1,fade_cnt
	tst.w	fade_cnt
	bpl.s	.s1
	move.w	fade_speed,fade_cnt

	subq.l	#2*4,pal_pos
	cmp.l	#cont_pal,pal_pos
	bgt.s	.s1
	move.l	#cont_pal,pal_pos

	st	fade_flag
.s1
	move.l	pal_pos,a0
	move.l	(a0)+,palbuff
	move.l	(a0)+,palbuff+4
	rts


ikbd	lea	$fffffc00.w,a1
.l1	move.b	(a1),d1
	btst	#1,d1
	beq.s	.l1
	move.b	d0,2(a1)
	rts

flush	move.w	d0,-(sp)
.l1	btst.b	#0,$fffffc00.w
	beq.s	.s1
	move.b	$fffffc02.w,d0
	bra.s	.l1
.s1	move.w	(sp)+,d0
	rts

swap_screens	move.l	screen1,d0
	move.l	screen2,screen1
	move.l	d0,screen2
	add.l	#(376*64)+(8*3),d0
	add.w	word_inc,d0
set_screen
	move.l	d0,screen_addr
	move.b	d0,d1
	lsr.l	#8,d0
	move.b	d0,$fffff8203.w
	lsr.w	#8,d0
	move.b	d0,$fffff8201.w
	move.b	d1,$fffff820d.w

	rts

clearscreen	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	move.l	screen1,a0
	move.l	screen2,a1
	move.w	#(64+200+64)-1,d7
.l1
x	set	0
	rept	7
	movem.l	d0-d6/a2-a6,x(a0)
	movem.l	d0-d6/a2-a6,x(a1)
x	set	x+(12*4)
	endr
	movem.l	d0-d6/a2-a4,x(a0)
	movem.l	d0-d6/a2-a4,x(a1)
	lea	((12*4)*7)+(10*4)(a0),a0
	lea	((12*4)*7)+(10*4)(a1),a1
	dbf	d7,.l1
	rts

sync	tst.w	vbl_count	; multiple vbl's
	bgt.s	sync

	move.w	vbl_count,d0
.l1	cmp.w	vbl_count,d0
	beq.s	.l1

	move.w	#fps,vbl_count
	rts

vsync	move.w	d0,-(sp)
	move.w	$466+2.w,d0
.l1	cmp.w	$466+2.w,d0
	beq.s	.l1
	move.w	(sp)+,d0
	rts

silence	lea	$fffff8800.w,a0
	move.l	#$700ff00,(a0)
	move.l	#$8000000,(a0)
	move.l	#$9000000,(a0)
	move.l	#$a000000,(a0)
	rts

;
; this is for calling a particular effect that
; is only required on a particular stage, in this
; case the starfield at the beginning of stage 1
;

store_stage_fx
	move.w	stage,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a0
	jmp	(a0)

.table	dc.l	.return
	rept	8
	dc.l	store_stars	;1-8
	endr

.return	rts

store_stars	move.l	screen1,a3
	lea	(376*64)+(8*3)(a3),a3
	add.w	word_inc,a3

	move.w	scroll_offset,d0
	and.w	#16-1,d0
	bne.s	.no_sub
	subq.w	#8,a3
.no_sub
	move.l	old_star_pos1,a4
	move.w	scroll_skew,d3
	lea	calculated_stars,a6

	lea	star_data,a0

	rept	num_stars/3
	move.w	(a0)+,d0
	move.w	(a0)+,d2
	add.w	d3,d0

	mulu	#6,d0
	lea	star_tab(pc),a1
	add.w	d0,a1

	move.w	(a1)+,(a6)+	; store bit

	move.l	a3,a2
	add.w	(a1)+,a2

	add.w	d2,d2
	add.w	d2,d2
	lea	mul_tab,a5
	add.w	d2,a5
	add.l	(a5),a2
	move.l	a2,(a6)+	; store screen pos

	move.l	a2,(a4)+	; save screen pos
	move.l	(a2)+,(a4)+	; save screen data
	move.l	(a2)+,(a4)+

	move.w	(a1)+,(a6)+	; store pixel

	endr

	rept	num_stars/3
	move.w	(a0)+,d0
	move.w	(a0)+,d2
	add.w	d3,d0

	mulu	#6,d0
	lea	star_tab(pc),a1
	add.w	d0,a1

	move.w	(a1)+,(a6)+	; store bit

	move.l	a3,a2
	add.w	(a1)+,a2

	add.w	d2,d2
	add.w	d2,d2
	lea	mul_tab,a5
	add.w	d2,a5
	add.l	(a5),a2
	move.l	a2,(a6)+	; store screen pos

	move.l	a2,(a4)+	; save screen pos
	move.l	(a2)+,(a4)+	; save screen data
	move.l	(a2)+,(a4)+

	move.w	(a1)+,(a6)+	; store pixel
	endr

	rept	num_stars/3
	move.w	(a0)+,d0
	move.w	(a0)+,d2
	add.w	d3,d0

	mulu	#6,d0
	lea	star_tab(pc),a1
	add.w	d0,a1

	move.w	(a1)+,(a6)+	; store bit

	move.l	a3,a2
	add.w	(a1)+,a2

	add.w	d2,d2
	add.w	d2,d2
	lea	mul_tab,a5
	add.w	d2,a5
	add.l	(a5),a2
	move.l	a2,(a6)+	; store screen pos

	move.l	a2,(a4)+	; save screen pos
	move.l	(a2)+,(a4)+	; save screen data
	move.l	(a2)+,(a4)+

	move.w	(a1)+,(a6)+	; store pixel
	endr
	rts

star_tab	ds.b	(6*16)*21

draw_stage_fx
	move.w	stage,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a0
	jmp	(a0)

.table	dc.l	.return
	rept	8
	dc.l	draw_stars	; 1-8
	endr

.return	rts

draw_stars	moveq	#0,d0
	moveq	#0,d1
	lea	calculated_stars,a0

	rept	num_stars/3
	move.w	(a0)+,d0
	move.l	(a0)+,a1
	move.w	(a0)+,d1

	move.l	a1,a2

	move.w	(a1)+,d3
	or.w	(a1)+,d3
	or.w	(a1)+,d3
	or.w	(a1)+,d3

	btst	d0,d3
	bne.s	*+6
	or.w	d1,6(a2)

	endr

	rept	num_stars/3
	move.w	(a0)+,d0
	move.l	(a0)+,a1
	move.w	(a0)+,d1

	move.l	a1,a2

	move.w	(a1)+,d3
	or.w	(a1)+,d3
	or.w	(a1)+,d3
	or.w	(a1)+,d3

	btst	d0,d3
	bne.s	*+8
	or.w	d1,(a2)
	or.w	d1,6(a2)

	endr

	rept	num_stars/3
	move.w	(a0)+,d0
	move.l	(a0)+,a1
	move.w	(a0)+,d1

	move.l	a1,a2

	move.w	(a1)+,d3
	or.w	(a1)+,d3
	or.w	(a1)+,d3
	or.w	(a1)+,d3

	btst	d0,d3
	bne.s	*+10
	or.w	d1,2(a2)
	or.w	d1,6(a2)
	endr

	move.l	old_star_pos1,d0
	move.l	old_star_pos2,old_star_pos1
	move.l	d0,old_star_pos2
	rts

restore_stage_fx
	move.w	stage,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a0
	jmp	(a0)

.table	dc.l	.return
	rept	8
	dc.l	restore_stars	; 1-8
	endr

.return	rts

star_rest_cnt	dc.w	2-1

restore_stars	subq.w	#1,star_rest_cnt
	tst.w	star_rest_cnt
	bpl	.s1
	move.w	#-1,star_rest_cnt
	move.l	old_star_pos1,a0
	rept	num_stars
	move.l	(a0)+,a1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	endr
.s1	rts

move_stage_fx	move.w	stage,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.table(pc,d0.w),a0
	jmp	(a0)

.table	dc.l	.return
	rept	8
	dc.l	move_stars	; 1-8
	endr


.return	rts


move_stars
	lea	star_data,a0

	rept	(num_stars/3)
	subq.w	#2,(a0)
	cmp.w	#0,(a0)
	bgt.s	*+6
	add.w	#319,(a0)	; add
	addq.w	#4,a0
	endr

	rept	(num_stars/3)
	subq.w	#3,(a0)
	cmp.w	#0,(a0)
	bgt.s	*+6
	add.w	#319,(a0)
	addq.w	#4,a0
	endr

	rept	(num_stars/3)
	subq.w	#4,(a0)
	cmp.w	#0,(a0)
	bgt.s	*+6
	add.w	#319,(a0)
	addq.w	#4,a0
	endr

.e1	rts

make_star_tab	moveq	#0,d1	; scrn offset

	lea	star_tab,a0

	moveq	#21-1,d4
.l2
	moveq	#16-1,d0	; bit check
	move.w	#%1000000000000000,d2	; pixel to plot

	moveq	#16-1,d3
.l1	move.w	d0,(a0)+
	move.w	d1,(a0)+
	move.w	d2,(a0)+
	subq.w	#1,d0
	lsr.w	#1,d2
	dbf	d3,.l1
	addq.w	#8,d1
	dbf	d4,.l2
	rts

; d5=start of sample
; d6=end of sample
; d7=sample loop restart (-1=non looping)
play_sfx
	clr.w	$fffff8900.w		; stop dma


	move.b	d5,$fffff8907.w
	lsr.w	#8,d5
	move.l	d5,$fffff8902.w

	move.b	d6,$fffff8913.w
	lsr.w	#8,d6
	move.l	d6,$fffff890e.w

	move.w	#%0000000010000001,$fffff8920.w	; freq

	move.w	#%0000000000000001,$fffff8900.w	; start dma

	tst.l	d7
	bmi.s	.s1

	move.b	d7,$fffff8907.w	; change start address
	lsr.w	#8,d7
	move.l	d7,$fffff8902.w

	or.w	#%0000000000000010,$fffff8900.w	; set loop
.s1	rts

do_keys	tst.b	intro_done
	beq	do_keys_end

	jsr	check_attach_detach_force

	cmp.b	#$19,kbuff
	beq	paused

paused_return	tst.w	cheat_flag
	beq.s	.s3
	tst.w	demo_mode
	bne.s	.s3
	cmp.b	#$01,kbuff
	bne.s	.s3
	st	cheat_key_flag
.s3

do_keys_end	rts

read_intro_table
	tst.b	intro_done
	bne	.i_s2
	lea	player_struct,a1
	lea	boost_struct,a2

	moveq	#0,d0
	move.l	intro_x_pos,a0
	move.w	(a0)+,d0
	cmp.w	#-1,d0
	bne.s	.i_s0
	st	intro_done
	bra.s	.i_s2
.i_s0	move.l	a0,intro_x_pos
	move.w	d0,x1(a1)

	cmp.w	#320-38-32-64,d0
	blt.s	.i_s1
	move.w	#3,status(a2)
.i_s1
	tst.b	intro_flag
	bne.s	.i_s2
	move.l	intro_pos,a0
	move.w	(a0)+,d0
	cmp.w	#-1,d0
	bne.s	.i_s3
	st	intro_flag
	bra.s	.i_s2
.i_s3	move.l	a0,intro_pos
	move.w	d0,spr_num(a1)
.i_s2	rts

paused	tst.w	demo_mode
	bne.s	.e1

	tst.b	intro_done
	beq.s	.e1

	bsr.s	store_paused
	bsr	draw_paused
	st	paused_flag

; wait for 'p' to be released
.pause_release	cmp.b	#$19,kbuff
	beq.s	.pause_release

.l0	cmp.b	#$19,kbuff	; 'p' pressed?
	bne.s	.s1
.l1	cmp.b	#$19,kbuff	; wait for release
	beq.s	.l1
	bra.s	.e0	; exit pause

.s1	moveq	#0,d0	; 'fire' pressed?
	move.b	joy1_status,d0
	btst	#7,d0
	beq.s	.s2

.l2	moveq	#0,d0	; wait for release
	move.b	joy1_status,d0
	btst	#7,d0
	bne.s	.l2
	bra.s	.e0	; exit pause

.s2	bra.s	.l0	; loop!

.e0	bsr	vsync
	bsr	restore_paused
	sf	paused_flag
	bra	paused_return
.e1	rts

store_paused	add.w	scroll_skew,d0

	and.w	#-16,d0
	lsr.w	#1,d0

	move.l	screen2,a0
	add.l	#(376*64)+(8*3)+((376*8)*11)+(8*8),a0
	add.w	word_inc,a0
	add.w	d0,a0

	move.w	scroll_offset,d0
	and.w	#16-1,d0
	bne.s	.no_sub
	subq.w	#8,a0
.no_sub

	move.l	a0,paused_store1

	move.l	old_paused_pos1,a1
x	set	0
y	set	0
	rept	7
	movem.l	y(a0),d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,x(a1)
x	set	x+(4*10)
y	set	y+376
	endr
.e1	rts


restore_paused

	move.l	old_paused_pos1,a0
	move.l	paused_store1,a1
x	set	0
	rept	7
	movem.l	(a0)+,d0-d7/a2-a3
	movem.l	d0-d7/a2-a3,x(a1)
x	set	x+376
	endr

.e1	rts

draw_paused

	moveq	#0,d0
	add.w	scroll_skew,d0

	and.w	#16-1,d0
	add.w	d0,d0
	lea	paused_tab(pc),a0
	add.w	d0,a0
	move.w	(a0),d0

	lea	paused_gfx,a0
	add.l	d0,a0
	
	move.l	paused_store1,a1

x	set	0
	rept	7
	movem.l	(a0)+,d0-d7
	and.l	d0,x(a1)
	or.l	d1,x(a1)
	and.l	d0,x+4(a1)

	and.l	d2,x+(8*1)(a1)
	or.l	d3,x+(8*1)(a1)
	and.l	d2,x+(8*1)+4(a1)

	and.l	d4,x+(8*2)(a1)
	or.l	d5,x+(8*2)(a1)
	and.l	d4,x+(8*2)+4(a1)

	and.l	d6,x+(8*3)(a1)
	or.l	d7,x+(8*3)(a1)
	and.l	d6,x+(8*3)+4(a1)

	move.l	(a0)+,d0
	move.l	(a0)+,d1

	and.l	d0,x+(8*4)(a1)
	or.l	d1,x+(8*4)(a1)
	and.l	d0,x+(8*4)+4(a1)
x	set	x+376
	endr

	rts

paused_tab
x	set	0
	rept	16
	dc.w	x
x	set	x+((8*5)*7)
	endr

paused_store1	dc.l	0

init_old_stars	move.l	screen1,a0
	move.l	screen2,a1
	lea	(376*64)+(8*3)(a0),a0
	lea	(376*64)+(8*3)(a1),a1
	lea	old_star1,a2
	lea	old_star2,a3
	moveq	#0,d1
	moveq	#num_stars-1,d0
.l1	move.l	a0,(a2)+	; store address
	move.l	d1,(a2)+	; clear nowt
	move.l	d1,(a2)+
	move.l	a1,(a2)+
	move.l	d1,(a2)+
	move.l	d1,(a2)+
	dbf	d0,.l1
	rts


fade_out_play_area
	move.l	#pal_end,pal_pos
	move.w	#-1,boss_explode_cnt
	move.w	#50*2,fade_out_play_area_cnt

	cmp.w	#3,stage
	bne.s	.j1_a
	move.w	#50,fade_out_play_area_cnt
.j1_a
	cmp.w	#6,stage
	bne.s	.j0
	move.w	#50*3,fade_out_play_area_cnt
.j0
	cmp.w	#5,stage
	bne.s	.j0_a
	move.w	#16,fade_out_play_area_cnt
.j0_a
	cmp.w	#4,stage
	bne.s	.j0_b
	move.w	#16*5,fade_out_play_area_cnt
.j0_b
	tst.b	cheat_key_flag
	bpl.s	.j1
	clr.w	fade_out_play_area_cnt
.j1
	sf	fade_out_play_area_flag

.l1	jsr	restore_background
	jsr	restore_stage_fx

	jsr	draw_tiles
	jsr	draw_anim_tiles
	jsr	draw_duct
;	jsr	do_pump_boss

	jsr	store_background
	bsr	store_stage_fx

	jsr	draw_player_sprite
;	jsr	plr_and_map_stuff
	jsr	draw_player_sprites
	jsr	do_explosion
	jsr	do_baddies
	jsr	do_baddies_bullets
	jsr	draw_stage_fx

	jsr	draw_player_mask


*** enemy/enemy bullets must be drawn here!

; do pixel perfect collision detection here
;	bsr	pixel_detect
;	move.w	#$0,$fffff8240.w

;	lea	player_struct,a0
;	bsr	draw_sprite

	jsr	do_level_4_boss
	jsr	do_boss_explode
	jsr	draw_demo_mode

	jsr	extra_life_check

	jsr	sync

	bsr	swap_screens
	jsr	offset_screen


	jsr	do_counters

	jsr	player_anim

	cmp.w	#6,stage
	bne.s	.no_stage6
	tst.b	fade_out_play_area_flag
	bmi.s	.no_stage6
	jsr	beam_and_baddies	* coll detect
	jsr	beam_and_bullet
.no_stage6
	jsr	move_beam

	jsr	move_force

	jsr	copy_baddie_waves
	jsr	do_baby
	jsr	copy_anim_tile_waves


	jsr	do_joystick
	tst.w	demo_mode
	beq.s	.bod
	clr.b	joy1_status
.bod

	jsr	check_baddie_hits

	jsr	chain_reaction

;	jsr	read_intro_table

	jsr	scroll_screen
	jsr	update_map_coords

	jsr	search_4_baddie
	jsr	generate_bullet
	jsr	move_baddies
	jsr	move_bullets
	jsr	move_pickup
	jsr	move_anim_tiles
	cmp.w	#6,stage
	bne.s	.no_stage6_a
	tst.b	fade_out_play_area_flag
	bmi.s	.no_stage6_a
	jsr	sprite_coll_detect
.no_stage6_a

	jsr	copy_map_coords

	jsr	beam_and_map	*
	bsr	bullet_and_map
;	bsr	map_coll_detect
	jsr	move_stage_fx

	jsr	do_animation

;	jsr	do_keys

	bsr	flush

	subq.w	#1,fade_out_play_area_cnt
	tst.w	fade_out_play_area_cnt
	bpl	.s1
	move.w	#-1,fade_out_play_area_cnt

	tst.b	fade_out_play_area_flag
	bne	.s1
	st	fade_out_play_area_flag

	move.w	#2-1,fade_rout
	sf	fade_flag

	tst.b	cheat_key_flag
	bmi.s	.s1

;	move.w	#4,tune_num
	jsr	stop_music

	move.w	#3,tune_num
	jsr	init_music

.s1	cmp.l	#pal,pal_pos
	bgt	.l1
	rts

player_die	;move.l	#force_high_sprites1,force_struct+spr_ptr1

	clr.w	beam_val
	lea	power_struct,a0
	cmp.w	#0,status(a0)
	beq.s	.n1
	move.w	#3,status(a0)
	jsr	die_check
.n1

	lea	boost_struct,a0
	cmp.w	#0,status(a0)
	beq.s	.n2
	move.w	#3,status(a0)
	jsr	die_check
.n2


	lea	player_struct,a0
	subq.w	#8,y1(a0)
	move.w	#-1,die_flag(a0)
	move.l	#player_die_sprites,spr_ptr1(a0)
	move.b	#%00000001,mask_op(a0)	; source and target
	move.b	#%00000111,sprite_op(a0)	; source or target
	clr.w	player_die_anim_cnt
	move.l	#player_die_anim,player_die_anim_pos

	move.l	#player_die_sfx+12,d5
	move.l	#player_die_sfx_end,d6
	moveq	#-1,d7
	bsr	play_sfx

	move.l	#pal_end,pal_pos

.l1	subq.w	#1,player_die_anim_cnt
	tst.w	player_die_anim_cnt
	bpl.s	.s1
	move.w	#2-1,player_die_anim_cnt

	moveq	#0,d0
	lea	player_struct,a1
	move.l	player_die_anim_pos,a0
	move.w	(a0)+,d0
	cmp.w	#-1,d0
	bne.s	.n0
	subq.w	#2,a0
	moveq	#6,d0	; max 7 sprites
	move.w	#-1,fade_cnt
	move.w	#3,fade_speed
	move.w	#2-1,fade_rout
	sf	fade_flag
	move.w	#3,status(a1)
.n0	move.l	a0,player_die_anim_pos
	move.l	#player_die_sprites,spr_ptr1(a1)
	move.w	d0,spr_num(a1)
.s1

;	bsr	vsync


	bsr	restore_background
	bsr	restore_stage_fx

	jsr	draw_tiles
	jsr	draw_anim_tiles
	jsr	draw_duct
	jsr	do_pump_boss

	bsr	store_background
	bsr	store_stage_fx

	bsr	draw_player_sprites
	jsr	do_explosion
	jsr	do_baddies
	jsr	do_baddies_bullets
	bsr	draw_stage_fx


	lea	player_struct,a0
	jsr	draw_sprite

	jsr	do_level_4_boss
	jsr	draw_demo_mode

	jsr	extra_life_check

	jsr	sync

	bsr	swap_screens
	jsr	offset_screen


	jsr	do_counters

;	bsr	player_anim
	jsr	move_beam

	jsr	move_force
	jsr	copy_baddie_waves
	jsr	do_baby
	jsr	copy_anim_tile_waves

	jsr	check_baddie_hits
	jsr	chain_reaction

	jsr	scroll_screen
	jsr	update_map_coords
	bsr	bullet_and_map
	bsr	move_stage_fx
	jsr	search_4_baddie
	jsr	generate_bullet
	bsr	move_baddies
	jsr	move_bullets
	jsr	move_pickup
	jsr	move_anim_tiles
	jsr	copy_map_coords

	jsr	do_animation

;	jsr	do_joystick
;	bsr	flush

	cmp.l	#pal,pal_pos
	bgt	.l1

do_game_over	move.b	#%00000001,$fffffa07.w	; timer b bit 0
	move.b	#%00000001,$fffffa13.w	; timer b

	subq.w	#1,lives
	cmp.w	#0,lives
	bgt	.s4


; draw game over text

	movem.l	blank,d0-d7
	movem.l	d0-d7,palbuff

	bsr	vsync
	move.b	#191-2,timer_line
	move.l	#status_tb,timer_rout
	move.b	#1,set_rez

	st	line_flag
	bsr	vsync
	clr.b	$fffff8265.w
	clr.b	$fffff820f.w

	bsr	clearscreen
	bsr	draw_game_over


	move.l	#game_over_ready_pal,game_over_ready_pal_pos

	jsr	vsync
	move.w	#$2700,sr
	move.b	#90,timer_line
	move.l	#game_over_ready_tb,timer_rout
	move.w	#$2300,sr

	bsr	vsync
	move.l	screen1,d0
	bsr	set_screen

;	cmp.w	#2,tune_num
;	bne.s	.no_deselect1
;	jsr	stop_music
;	bra.s	.no_deselect2
;.no_deselect1	move.w	#1,tune_num
;	jsr	stop_music
;.no_deselect2
	jsr	stop_music

	move.w	#4,tune_num
	jsr	init_music

;	movem.l	ready_pal,d0-d7
;	movem.l	d0-d7,palbuff

	move.w	#(50*6)-1,d0
	jsr	pause


	bsr	fade_out_game_over

	bsr	clearscreen

	bra	.e1

.s4
	cmp.w	#0,lives
	ble.s	.s4

	movem.l	blank,d0-d7
	movem.l	d0-d7,palbuff

	bsr	vsync
	move.b	#191-2,timer_line
	move.l	#status_tb,timer_rout
	move.b	#1,set_rez

	st	line_flag
	bsr	vsync
	clr.b	$fffff8265.w
	clr.b	$fffff820f.w

	bsr	clearscreen
	bsr	draw_ready

	bsr	vsync
	move.l	screen1,d0
	bsr	set_screen


	move.w	#4-1,loop_val1
.flash_loop	bsr	vsync
	move.l	#game_over_ready_pal,game_over_ready_pal_pos
	move.b	#90,timer_line
	move.l	#game_over_ready_tb,timer_rout

	moveq	#20-1,d0
	jsr	pause

	move.b	#191-2,timer_line
	move.l	#status_tb,timer_rout

	movem.l	blank,d0-d7
	movem.l	d0-d7,palbuff

	moveq	#20-1,d0
	jsr	pause
	subq.w	#1,loop_val1
	tst.w	loop_val1
	bpl.s	.flash_loop

	bsr	clearscreen

	bra	.e2

.e1	;move.w	#-1,fade_cnt
	;move.w	#3,fade_speed
	;bsr	fade_out_status

	bsr	do_game_report

	bsr	do_continue

	tst.b	continue_flag
	beq.s	.j1

	clr.l	stage1_score
	clr.l	stage2_score
	clr.l	stage3_score
	clr.l	stage4_score
	clr.l	stage5_score
	clr.l	stage6_score
	clr.l	stage7_score
	clr.l	stage8_score
	clr.l	total_score

	jsr	init_player_structures

	clr.w	weapon_type
	clr.w	force_power
	
	move.w	set_lives,lives
	move.w	#2*2,plr_speed
	sf	homing_flag
	clr.w	bit_cnt
	move.w	#1,player_struct+status
	clr.w	extra_life_inc
	jmp	continue_stage

.j1

	cmp.w	#0,num_credits
	ble.s	.e2

	move.b	#199,timer_line
	move.l	#null_tb,timer_rout

;	move.b	#191-2,timer_line
;	move.l	#status_tb,timer_rout

	move.w	#-1,fade_cnt
	move.w	#2,fade_speed
	move.w	#4-1,fade_rout
	sf	fade_flag

	moveq	#(50*1)-1,d0
	jsr	pause

;	move.w	#-1,fade_cnt
;	move.w	#3,fade_speed
;	bsr	fade_out_status

.e2

	jsr	init_player_structures

	clr.w	weapon_type
	clr.w	force_power
;	move.w	set_lives,lives
	move.w	#2*2,plr_speed
	sf	homing_flag

	clr.w	bit_cnt
	move.w	#1,player_struct+status
	jmp	stage_start

name_tb	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.l	coin_flash_pos,a0
	move.w	(a0)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	lea	coin_flash,a0
	move.w	(a0)+,d0
.s1	move.l	a0,coin_flash_pos
	move.w	d0,$fffff8240+6.w
	move.l	(sp)+,d0
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#40-1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#status_tb,$120.w
null_tb	rte

do_game_report	bsr	sort_scores

	cmp.w	#0,hi_score_pos	; score too low
	ble	.e1

	move.w	#5,tune_num
	jsr	init_music

	bsr	set_up_scores_text

	move.w	hi_score_pos,d0
	subq.w	#1,d0
	add.w	d0,d0
	lea	position_text,a0
	lea	hi_score_position_text,a1
	add.w	d0,a0
	move.b	(a0)+,(a1)+
	move.b	(a0)+,(a1)+

	move.w	hi_score_pos,d0
	subq.w	#1,d0
	moveq	#9,d1
	sub.w	d0,d1
	move.w	d1,hi_score_pos

	move.w	#-1,hi_score_flag

	bsr	clearscreen

	bsr	vsync

	move.l	#coin_flash,coin_flash_pos
	move.b	#(8*19)-1-1,timer_line
	move.l	#name_tb,timer_rout
	clr.b	set_rez
	st	line_flag
	bsr	vsync
	clr.b	$fffff8265.w
	clr.b	$fffff820f.w

	move.l	cont_pal_end,palbuff
	move.l	cont_pal_end+4,palbuff+4

	bsr	vsync
	move.l	screen1,d0
	bsr	set_screen

	lea	stage_report_text,a0
	move.l	screen1,a3
	bsr	print2

	lea	stage_report_scores1,a0
	move.l	screen1,a3
	bsr	print2

	cmp.w	#4,stage
	ble.s	.s1

	lea	stage_report_scores2,a0
	move.l	screen1,a3
	bsr	print2

.s1
	lea	total_score_text,a0
	move.l	screen1,a3
	bsr	print2

	lea	enter_name_text,a0
	move.l	screen1,a3
	bsr	print2

	bsr	init_name
	sf	enter_name_flag
	move.l	#name_buff,name_buff_pos
	move.l	#char_tab,char_tab_pos

	move.w	#(10*50)-1,time
; enter name loop!
.l1	bsr	vsync
	bsr	check_joystick
	bsr	draw_name
	subq.w	#1,time
	tst.w	time
	bmi.s	.e2
	tst.b	enter_name_flag
	beq.s	.l1
.e2

	move.w	#(50*5)-1,d0
	jsr	pause

	move.b	#191-2,timer_line
	move.l	#status_tb,timer_rout

	move.l	#cont_pal_end,pal_pos
	move.w	#-1,fade_cnt
	move.w	#2,fade_speed
	move.w	#4-1,fade_rout
	sf	fade_flag

	moveq	#(50*1)-1,d0
	jsr	pause

;	move.w	#5,tune_num
	jsr	stop_music

;	clr.w	tune_num

	bsr	check_4_blank_name
	bsr	copy_score_and_name
.e1	rts

check_joystick
	moveq	#0,d0
	move.b	joy1_status,d0	; fire

	cmp.b	#4,d0	; left
	beq	dec_char

	cmp.b	#8,d0	; right
	beq	inc_char

	btst	#7,d0	; fire
	bne.s	accept_char
	rts

accept_char
	moveq	#0,d0
	move.b	joy1_status,d0	; fire
	btst	#7,d0
	bne.s	accept_char

	move.w	#(10*50)-1,time

	move.l	char_tab_pos,a0
	move.l	name_buff_pos,a1

	move.l	(a0),a0

	move.w	4(a0),d0
	cmp.b	#-1,d0
	bne.s	.s1

	move.l	char_tab_pos,a0
	cmp.l	#name_buff,name_buff_pos
	ble.s	.n1
	move.l	#name_font_tab,(a0)
.n1
	subq.l	#4,char_tab_pos
	subq.l	#1,name_buff_pos
	cmp.l	#name_buff,name_buff_pos
	bge.s	.s2
	move.l	#name_buff,name_buff_pos
	move.l	#char_tab,char_tab_pos
	bra	.e2
.s2
	move.l	char_tab_pos,a0
	move.l	#name_font_tab+(6*26)+(6*5),(a0)

	move.b	#$20,(a1)

	move.l	#accept_sfx+12,d5
	move.l	#accept_sfx_end,d6
	moveq	#-1,d7
	bsr	play_sfx

	bra.s	.e2
.s1
	cmp.w	#-2,d0
	bne.s	.s3
	move.b	#$20,(a1)
	st	enter_name_flag

	move.l	char_tab_pos,a0

	move.l	#name_font_tab,(a0)

	move.l	#accept_sfx+12,d5
	move.l	#accept_sfx_end,d6
	moveq	#-1,d7
	bsr	play_sfx

	bra.s	.e2
.s3
	move.b	d0,(a1)
	addq.l	#4,char_tab_pos
	addq.l	#1,name_buff_pos
	cmp.l	#name_buff_end,name_buff_pos
	blt.s	.e1
	st	enter_name_flag
.e1
	move.l	#accept_sfx+12,d5
	move.l	#accept_sfx_end,d6
	moveq	#-1,d7
	bsr	play_sfx

.e2
	rts

inc_char	moveq	#8-1,d0
.l1	bsr	vsync
	dbf	d0,.l1
	move.w	#(10*50)-1,time

	move.l	#select_sfx+12,d5
	move.l	#select_sfx_end,d6
	moveq	#-1,d7
	bsr	play_sfx

	move.l	char_tab_pos,a0
	addq.l	#6,(a0)
	cmp.l	#name_font_tab_end,(a0)
	blt.s	.s1
	move.l	#name_font_tab,(a0)
.s1	rts

dec_char	moveq	#8-1,d0
.l1	bsr	vsync
	dbf	d0,.l1
	move.w	#(10*50)-1,time

	move.l	#select_sfx+12,d5
	move.l	#select_sfx_end,d6
	moveq	#-1,d7
	bsr	play_sfx

	move.l	char_tab_pos,a0
	subq.l	#6,(a0)
	cmp.l	#name_font_tab,(a0)
	bge.s	.s1
	move.l	#name_font_tab_end-6,(a0)
.s1	rts


draw_name	lea	char_tab,a0
	move.l	name_buff_pos,a4
	move.l	screen1,a3
	lea	((160*8)*19)+(8*10)+(160*8)(a3),a3
	moveq	#7-1,d1
.l1
	move.l	(a0)+,a1
	move.l	(a1)+,a2
	move.w	(a1)+,d0

	move.b	d0,(a4)
x	set	0
	rept	8
	move.w	(a2)+,d0
	movep.w	d0,x(a3)
x	set	x+160
	endr
	addq.w	#8,a3
	dbf	d1,.l1
	rts

check_4_blank_name
	lea	name_buff,a0
	moveq	#7-1,d0
.l1	cmp.b	#-1,(a0)
	beq.s	.s1
	cmp.b	#-2,(a0)
	beq.s	.s1

	cmp.b	#$20,(a0)
	bne.s	.e1
.s1	addq.w	#1,a0
	dbf	d0,.l1

; equales=heart
	move.l	#"= BO",name_buff
	move.w	#"D ",name_buff+4
	move.b	#"=",name_buff+4+2

.e1	rts

init_name	moveq	#" ",d1
	lea	name_buff,a0
	moveq	#7-1,d0
.l1	move.b	d1,(a0)+
	dbf	d0,.l1

	lea	name_font_tab,a0
	lea	char_tab,a1
	moveq	#7-1,d0
.l2	move.l	a0,(a1)+
	dbf	d0,.l2
	rts

sort_scores	moveq	#0,d1	; start with first score
	move.l	total_score,d0

	lea	hi_score_table+(4*9),a1
	lea	hi_name_table+(7*9),a3
	lea	-4(a1),a0
	lea	-7(a3),a2

.l1	cmp.l	(a1),d0
	blt.s	.s1
	cmp.l	#hi_score_table,a1
	blt.s	.s1

	addq.w	#1,d1
	subq.w	#4,a0
	subq.w	#4,a1
	subq.w	#7,a2
	subq.w	#7,a3
	bra.s	.l1
.s1
	move.w	d1,hi_score_pos
	move.l	a1,score_pos
	move.l	a3,name_pos
	addq.l	#4,score_pos
	addq.l	#7,name_pos

	cmp.w	#1,d1	; min hiscore table pos
	ble.s	.e1
	cmp.w	#11,d1	; max hiscore table pos+1
	bge.s	.e1

	move.w	d1,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,a0
	add.w	d2,a1

	move.w	d1,d2
	mulu	#7,d2
	add.w	d2,a2
	add.w	d2,a3

	subq.w	#2,d1

.l3	move.l	(a0)+,(a1)+
	moveq	#7-1,d0
.l2	move.b	(a2)+,(a3)+
	dbf	d0,.l2
	subq.w	#8,a0
	subq.w	#8,a1
	lea	-14(a2),a2
	lea	-14(a3),a3
	dbf	d1,.l3

.e1	rts

copy_score_and_name
	lea	total_score,a0
	move.l	score_pos,a1
	move.l	(a0),(a1)

	lea	name_buff,a0
	move.l	name_pos,a1
	moveq	#7-1,d0
.l1	move.b	(a0)+,(a1)+
	dbf	d0,.l1
.s1	rts


set_up_scores_text
	move.l	#$20202020,d1
	move.l	#$20200102,d2
	lea	stage1_score_text,a0
	lea	stage5_score_text,a1
	moveq	#3-1,d0
.l1	move.l	d1,(a0)
	move.l	d2,4(a0)
	move.l	d1,(a1)
	move.l	d2,4(a1)
	lea	22(a0),a0
	lea	22(a1),a1
	dbf	d0,.l1

	move.l	d1,(a0)
	move.w	d1,4(a0)
	clr.b	6(a0)
	move.l	d1,(a1)
	move.w	d1,4(a1)
	clr.b	6(a1)

; only print scores from stages played
	move.w	stage,d0
	subq.w	#1,d0
	lsl.w	#2,d0
	lea	stage_score_tab,a0
	add.w	d0,a0
	move.l	(a0),a0
	clr.b	(a0)

x	set	0
y	set	0
	rept	4
	lea	stage1_score+x,a0
	jsr	hex_dec
	lea	dec_buff,a0
	lea	stage1_score_text+y,a1
	jsr	copy_score
x	set	x+4
y	set	y+22
	endr

x	set	0
y	set	0
	rept	4
	lea	stage5_score+x,a0
	jsr	hex_dec
	lea	dec_buff,a0
	lea	stage5_score_text+y,a1
	jsr	copy_score
x	set	x+4
y	set	y+22
	endr

	lea	total_score,a0
	jsr	hex_dec
	lea	dec_buff,a0
	lea	total,a1

copy_score	sf	d2
	moveq	#6-1,d1
.l1	move.w	(a0)+,d0
	tst.b	d2
	bne.s	.s1
	cmp.b	#0,d0
	bgt.s	.s1
	moveq	#" ",d0
	cmp.w	#0,d1
	bgt.s	.s2
	moveq	#"0",d0
	bra.s	.s2
.s1	st	d2

	move.b	.num(pc,d0.w),d0

.s2	move.b	d0,(a1)+
	dbf	d1,.l1
	rts

.num	dc.b	"0123456789"
	even


do_continue	subq.w	#1,num_credits
	cmp.w	#0,num_credits
	ble	.e1

	bsr	clearscreen

	bsr	vsync
	move.b	#191-2,timer_line
	move.l	#status_tb,timer_rout
	clr.b	set_rez
	st	line_flag
	bsr	vsync
	clr.b	$fffff8265.w
	clr.b	$fffff820f.w

	bsr	vsync
	move.l	screen1,d0
	bsr	set_screen


	rept	2
	lea	cont_text,a0
	move.l	screen1,a3
	bsr	print

	lea	text_num9,a0
	move.l	screen1,a3
	bsr	print

	move.w	num_credits,d0
	move.l	screen1,a1
	lea	((160*8)*20)+(8*12)+(160*8)(a1),a1
	bsr	draw_digit

	bsr	vsync

	move.l	screen1,d0
	move.l	screen2,screen1
	move.l	d0,screen2
	move.l	screen1,d0
	bsr	set_screen

	endr

	move.l	#text_num_tab,text_num_pos

	move.l	#coin_flash,coin_flash_pos
	move.l	#cont_pal,pal_pos
	move.w	#-1,fade_cnt
	move.w	#2,fade_speed
	move.w	#3-1,fade_rout
	sf	fade_flag

	moveq	#(50*1)-1,d0
	jsr	pause

	move.b	#((18*8)+8)-1,timer_line
	move.l	#cont_tb,timer_rout
	move.w	#6,tune_num
	jsr	init_music

.l1
	move.l	text_num_pos,a1
	move.l	(a1)+,a0
	cmp.l	#-1,a0
	beq	.e1
	move.l	a1,text_num_pos

	move.l	a0,-(sp)
	bsr	clear_cont_num
	move.l	(sp)+,a0

	move.l	screen1,a3
	bsr	print
	bsr	vsync

	move.l	screen1,d0
	move.l	screen2,screen1
	move.l	d0,screen2
	move.l	screen2,d0
	bsr	set_screen
	
	move.w	#63-1,time

.l3	bsr	vsync

	moveq	#0,d0
	move.b	joy1_status,d0	; fire
	btst	#7,d0
	beq.s	.s0

.l2
	moveq	#0,d0
	move.b	joy1_status,d0	; wait 4 fire release
	btst	#7,d0
	bne.s	.l2

	bra.s	.s1

.s0	subq.w	#1,time
	tst.w	time
	bpl.s	.l3

	bra	.l1

.s1
; go here if continue taken
	bsr	vsync
	movem.l	blank,d0-d7
	movem.l	d0-d7,palbuff
	move.b	#191-2,timer_line
	move.l	#status_tb,timer_rout
	clr.b	set_rez
	st	continue_flag
	move.l	#pal,pal_pos
	sf	music_flag	; turn off music

;	move.w	#6,tune_num
	jsr	stop_music
;	clr.w	tune_num

	move.l	#accept_sfx+12,d5
	move.l	#accept_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx
 
.e1	rts

clear_cont_num	moveq	#0,d0
	move.l	screen1,a0
	lea	((160*8)*6)+(8*8)+(160*8)(a0),a0
	moveq	#9-1,d1
.l1
x	set	0
	rept	8
	move.l	d0,x(a0)
	move.l	d0,x+(8*1)(a0)
	move.l	d0,x+(8*2)(a0)
	move.l	d0,x+(8*3)(a0)
x	set	x+160
	endr
	lea	160*8(a0),a0
	dbf	d1,.l1
	rts

print	move.w	#1,.m1+2
	move.l	a3,a2
.l1	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#0,d0
	beq	.e1
	cmp.b	#1,d0	; add a row
	bne.s	.s2
	move.b	(a0)+,d0
	mulu	#160*8,d0
	add.l	d0,a3
	move.l	a3,a2
	move.w	#1,.m1+2
	bra.s	.l1
.s2
	cmp.b	#2,d0	; add a column
	bne.s	.s3
	moveq	#0,d0
	move.b	(a0)+,d0
	add.w	d0,a2

	move.w	#7,.m1+2
	and.b	#2-1,d0
	tst.b	d0
	bne.s	.s4
	move.w	#1,.m1+2
.s4
	bra.s	.l1
.s3
	cmp.b	#$20,d0
	beq.s	.s1
	sub.b	#$20,d0
	lsl.w	#4,d0
	lea	font,a1
	add.w	d0,a1
x	set	0
	rept	8
	move.w	(a1)+,d0
	movep.w	d0,x(a2)
x	set	x+160
	endr
.s1
	opt	o-
.m1	add.w	#1,a2
	opt	o+
	eor.w	#6,.m1+2
	bra	.l1
.e1	rts

print2	move.w	#1,.m1+2
	move.l	a3,a2
.l1	moveq	#0,d0
	move.b	(a0)+,d0
	cmp.b	#0,d0
	beq	.e1
	cmp.b	#1,d0	; add a row
	bne.s	.s2
	move.b	(a0)+,d0
	mulu	#160*8,d0
	add.l	d0,a3
	move.l	a3,a2
	move.w	#1,.m1+2
	bra.s	.l1
.s2
	cmp.b	#2,d0	; add a column
	bne.s	.s3
	moveq	#0,d0
	move.b	(a0)+,d0
	add.w	d0,a2

	move.w	#7,.m1+2
	and.b	#2-1,d0
	tst.b	d0
	bne.s	.s4
	move.w	#1,.m1+2
.s4
	bra.s	.l1
.s3
	cmp.b	#$20,d0
	beq.s	.s1
	cmp.b	#"_",d0
	bne.s	.s5
	lea	name_font,a1
	bra.s	.p1
.s5
	sub.b	#$20,d0
	lsl.w	#4,d0
	lea	font,a1
	add.w	d0,a1
.p1
	bsr	vsync
x	set	0
	rept	8
	move.w	(a1)+,d0
	movep.w	d0,x(a2)
x	set	x+160
	endr
.s1
	opt	o-
.m1	add.w	#1,a2
	opt	o+
	eor.w	#6,.m1+2
	bra	.l1
.e1	rts

digit_tab
	dc.l	font+((16*1)*16)
	dc.l	font+((16*1)*17)
	dc.l	font+((16*1)*18)
	dc.l	font+((16*1)*19)
	dc.l	font+((16*1)*20)
	dc.l	font+((16*1)*21)

draw_digit
	add.w	d0,d0
	add.w	d0,d0
	move.l	digit_tab(pc,d0.w),a0
x	set	0
	rept	8
	move.w	(A0)+,d0
	movep.w	d0,x(a1)
x	set	x+160
	endr
	rts

prop_text	moveq	#0,d3
	moveq	#1,d1
.l1	moveq	#0,d0		; work out the total
	move.b	(a0)+,d0		; width of the line to
	cmp.b	#-1,d0
	beq	.e1
	cmp.b	#0,d0
	beq.s	.e1
	addq.w	#8,d3	; 8
	addq.w	#1,d1
	bra.s	.l1
.e1	sub.w	d1,a0
	sub.w	#320-1,d3		; (screen width-line width)
	cmp.w	#0,d3		; make safe a line that's too
	blt.s	.s2		; big for a screen line!
	moveq	#0,d3
	bra.s	.l2
.s2	neg.w	d3		; make positive
	lsr.w	#1,d3		; halve it!


.l2	moveq	#0,d0
	move.b	(a0)+,d0

	cmp.b	#-1,d0		; next line check
	beq	.e2
	cmp.b	#0,d0	; next line check
	bne.s	.s1
	moveq	#1,d1
	moveq	#0,d3
	lea	160*8(a3),a3
	bra.s	.l1
.s1

	sub.b	#$20,d0
	lsl.w	#4,d0
	lea	font,a1
	add.w	d0,a1
	move.w	d3,d1
	move.w	d3,d2
	and.w	#16-1,d1
	and.w	#-16,d2	; -16
	lsr.w	#1,d2
	move.l	a3,a2
	add.w	d2,a2

x	set	0
	rept	8
	moveq	#0,d0
	move.b	(a1)+,d0
	lsl.w	#8,d0	; coz font is a byte not a word
	ror.l	d1,d0
	or.w	d0,x(a2)
	swap	d0
	or.w	d0,x+8(a2)

	moveq	#0,d0
	move.b	(a1)+,d0
	lsl.w	#8,d0	; coz font is a byte not a word
	ror.l	d1,d0
	or.w	d0,x+2(a2)
	swap	d0
	or.w	d0,x+8+2(a2)

x	set	x+160
	endr



.s3	add.w	#8,d3	; 8
	bra	.l2
.e2	rts

cont_tb	move.l	a0,-(sp)
	move.l	d0,-(sp)
	move.l	coin_flash_pos,a0
	move.w	(a0)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	lea	coin_flash,a0
	move.w	(a0)+,d0
.s1	move.l	a0,coin_flash_pos
	move.w	d0,$fffff8240+2.w
	move.l	(sp)+,d0
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#9,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.tb1,$120.w
	rte

.tb1	move.l	palbuff,$fffff8240.w
	move.w	palbuff+4,$fffff8240+4.w
	clr.b	$fffffa1b.w
	move.b	#199-((18*8)+8+9)-1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.n1,$120.w
.n1	rte

game_over_ready_tb
	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#3,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.tb1,$120.w
	rte

.tb1	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	2(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.tb2,$120.w
	rte

.tb2	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	4(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	move.l	#.tb3,$120.w
	rte

.tb3	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	6(A0),$fffff8240+2.w
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.tb4,$120.w
	rte

.tb4	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	8(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	move.l	#.tb5,$120.w
	rte

.tb5	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	10(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.tb6,$120.w
	rte

.tb6	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	8(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.tb7,$120.w
	rte

.tb7	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	6(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	move.l	#.tb8,$120.w
	rte

.tb8	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	4(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	move.l	#.tb9,$120.w
	rte

.tb9	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	2(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	move.l	#.tb10,$120.w
	rte

.tb10	move.l	a0,-(sp)
	move.l	game_over_ready_pal_pos,a0
	move.w	(a0),$fffff8240+2.w
	move.l	(sp)+,a0
	clr.b	$fffffa1b.w
;	move.b	#87,$fffffa21.w
	move.b	#-1,$fffffa21.w
	move.b	#8,$fffffa1b.w
;	move.l	#status_tb,$120.w
	move.l	#.n1,$120.w
.n1	rte

fade_out_game_over
	bsr	vsync
	bsr	vsync
	add.l	#2*6,game_over_ready_pal_pos
	cmp.l	#game_over_ready_pal_end,game_over_ready_pal_pos
	blt.s	fade_out_game_over
	rts

game_over_ready_pal_pos
	dc.l	game_over_ready_pal
game_over_ready_pal
	DC.W	$200,$680,$F20,$F40,$F61,$FF4
	DC.W	$200,$680,$720,$740,$761,$774
	DC.W	$200,$680,$E20,$E40,$E61,$EE4
	DC.W	$200,$680,$620,$640,$661,$664
	DC.W	$200,$D80,$D20,$D40,$DD1,$DD4
	DC.W	$200,$580,$520,$540,$551,$554
	DC.W	$200,$C80,$C20,$C40,$CC1,$CC4
	DC.W	$200,$480,$420,$440,$441,$444
	DC.W	$200,$B80,$B20,$BB0,$BB1,$BBB
	DC.W	$200,$380,$320,$330,$331,$333
	DC.W	$200,$A80,$A20,$AA0,$AA1,$AAA
	DC.W	$200,$280,$220,$220,$221,$222
	DC.W	$900,$980,$990,$990,$991,$999
	DC.W	$100,$180,$110,$110,$111,$111
	DC.W	$800,$880,$880,$880,$888,$888
	ds.w	6
game_over_ready_pal_end
	ds.w	6

draw_ready	lea	ready_gfx,a0
	move.l	screen1,a1
	lea	(160*91)+(4*16)(a1),a1
	moveq	#18-1,d1
.l2	moveq	#8-1,d0
.l1	move.w	(a0)+,(a1)
	addq.w	#4,a1
	dbf	d0,.l1
	lea	160-(4*8)(a1),a1
	dbf	d1,.l2
	rts

draw_game_over	lea	game_over_gfx,a0

	move.l	screen1,a1
	lea	(160*91)+(4*13)(a1),a1
	moveq	#18-1,d1
.l2	moveq	#14-1,d0
.l1	move.w	(a0)+,(a1)
	addq.w	#4,a1
	dbf	d0,.l1
	lea	160-(4*14)(a1),a1
	dbf	d1,.l2
	rts

restore_background
x	set	0
	rept	num_bullets
	lea	bullet_struct+x,a0
	jsr	restore_back
x	set	x+sprite_size
	endr

x	set	0
	rept	num_pickup
	lea	pickup_struct+x,a0
	jsr	restore_back
x	set	x+sprite_size
	endr

x	set	0
	rept	num_beams
	lea	beam_struct+x,a0
	jsr	restore_back
x	set	x+sprite_size
	endr

	lea	boost_struct,a0
	jsr	restore_back

	lea	power_struct,a0
	jsr	restore_back

	lea	force_struct,a0
	jsr	restore_back

	lea	pod_struct1,a0
	jsr	restore_back
	lea	pod_struct2,a0
	jsr	restore_back

	lea	player_struct,a0
	jsr	restore_back

x	set	0
	rept	num_baddies
	lea	baddie_struct+x,a0
	jsr	restore_back
x	set	x+sprite_size
	endr

	jsr	restore_demo_mode
	rts

store_background
x	set	0
	rept	num_bullets
	lea	bullet_struct+x,a0
	jsr	store_back
x	set	x+sprite_size
	endr

x	set	0
	rept	num_pickup
	lea	pickup_struct+x,a0
	jsr	store_back
x	set	x+sprite_size
	endr

x	set	0
	rept	num_beams
	lea	beam_struct+x,a0
	jsr	store_back
x	set	x+sprite_size
	endr

	lea	boost_struct,a0
	jsr	store_back

	lea	power_struct,a0
	jsr	store_back

	lea	force_struct,a0
	jsr	store_back

	lea	pod_struct1,a0
	jsr	store_back
	lea	pod_struct2,a0
	jsr	store_back

	lea	player_struct,a0
	jsr	store_back

x	set	0
	rept	num_baddies
	lea	baddie_struct+x,a0
	jsr	store_back
x	set	x+sprite_size
	endr

	jsr	store_demo_mode

	rts


draw_player_sprites

x	set	0
	rept	num_beams
	lea	beam_struct+x,a0
	jsr	draw_sprite
x	set	x+sprite_size
	endr


x	set	0
	rept	num_pickup
	lea	pickup_struct+x,a0
	jsr	draw_sprite
x	set	x+sprite_size
	endr


	lea	boost_struct,a0
	jsr	draw_sprite

	lea	power_struct,a0
	jsr	draw_sprite

	lea	pod_struct1,a0
	jsr	draw_sprite

	lea	pod_struct2,a0
	jsr	draw_sprite

	lea	force_struct,a0
	jsr	draw_sprite
	rts

do_explosion
x	set	0
	rept	num_baddies
	lea	baddie_struct+x,a0
	jsr	draw_explosion
x	set	x+sprite_size
	endr

	rts

do_baddies
x	set	0
	rept	num_baddies
	lea	baddie_struct+x,a0
	jsr	draw_baddie
x	set	x+sprite_size
	endr

	rts

do_baddies_bullets
x	set	0
	rept	num_bullets
	lea	bullet_struct+x,a0
	jsr	draw_sprite
x	set	x+sprite_size
	endr
	rts

move_pickup
x	set	0
	rept	num_pickup
	lea	pickup_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a1
	jsr	(a1)
x	set	x+sprite_size
	endr
	rts

.tab	dc.l	.s1
	dc.l	.s1
	dc.l	.move_em
	dc.l	.restore

.restore	subq.w	#1,die_cnt(a0)
	tst.w	die_cnt(a0)
	bpl.s	.s1
	clr.w	status(a0)
	rts

.move_em	;tst.w	spr_die_flag(a0)
	;bne.s	.s1

	moveq	#0,d1
	subq.w	#1,x1(a0)

	move.w	x1(a0),d0
	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	sub.w	8(a1),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
.s1	rts

move_baddies	tst.b	intro_done
	beq	.return

	subq.w	#1,explode_cnt
	cmp.w	#0,explode_cnt
	bgt	.return
	move.w	#1,explode_cnt

	sf	circular_flag
	sf	lv4_boss_flag

	move.w	#10-1,lv5_boss_index
x	set	0
	rept	num_baddies
	lea	baddie_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab1(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.return	rts

.tab1	dc.l	.return
	dc.l	.return
	dc.l	.move_em
	dc.l	.restore

.restore	subq.w	#1,die_cnt(a0)
	tst.w	die_cnt(a0)
	bpl.s	.return
	clr.w	status(a0)
	rts

.move_em	;tst.w	spr_die_flag(a0)
	;bne.s	.return
	move.w	spr_move_mode(A0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab2(pc,d0.w),a2
	jmp	(a2)

.tab2	dc.l	move_baddie_right_left_vertical_sinus
	dc.l	move_baddie_right_left
	dc.l	move_baddie_follow_sinus
	dc.l	move_baddie_follow_sinus_with_scroll
	dc.l	move_circular_guns
	dc.l	move_grey_baddies

	dc.l	move_walker1	;x
	dc.l	move_walker1	;y

	dc.l	move_blue_walker
	dc.l	move_big_baddie2
	dc.l	return	; boss explode/weak point
	dc.l	return
	dc.l	move_boss_tail

	dc.l	move_plant1
	dc.l	move_plant2

	dc.l	move_spin1
	dc.l	move_spin2
	dc.l	move_spin3
	dc.l	move_lv7_boss

	dc.l	move_tank

	dc.l	move_crawl

	dc.l	move_pump

	dc.l	lv5_boss_move

	dc.l	move_baddie_left_right
	dc.l	move_baddie_up
	dc.l	move_baddie_down

	dc.l	lv4_boss_appear
	dc.l	lv4_boss_move

return	rts

lv4_boss_x_offset
	dc.w	0
lv4_boss_flag	dc.b	0
	even

lv4_boss_move
	rts

lv4_boss_appear	tst.w	spr_die_flag(a0)
	bmi	.bod

	tst.b	lv4_boss_flag
	bmi.s	.s1
	st	lv4_boss_flag
	addq.w	#2,lv4_boss_x_offset
	cmp.w	#256-48-1,lv4_boss_x_offset
	blt.s	.s1
	move.w	#256-48-1,lv4_boss_x_offset

	move.w	lv4_boss_x_offset,d0
	add.w	x_reset(a0),d0
	move.w	d0,x_reset(a0)
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)
	move.w	#27,spr_move_mode(a0)
	bra.s	.e1
.s1
	move.w	lv4_boss_x_offset,d0
	add.w	x_reset(a0),d0
	move.w	d0,x1(a0)

	move.w	y_reset(a0),y1(a0)
.e1	rts

.bod	move.w	lv4_boss_x_offset,d0
	add.w	x_reset(a0),d0
	move.w	d0,x_reset(a0)
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)
	move.w	#10,spr_move_mode(a0)
	rts

move_baddie_left_right
	cmp.l	#blue_big_die_sprites,spr_ptr1(a0)
	beq.s	.skip
	tst.w	spr_die_flag(a0)
	bne.s	.e1
.skip

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_x_move_val(a0),d0
	add.w	d0,x_reset(a0)
.s0

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	cmp.w	#320-1,d0
	blt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

.e1	rts

move_baddie_up
	cmp.l	#blue_big_die_sprites,spr_ptr1(a0)
	beq.s	.skip
	tst.w	spr_die_flag(a0)
	bne.s	.e1
.skip

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_y_move_val(a0),d0
	sub.w	d0,y_reset(a0)
.s0

	moveq	#0,d1
	move.w	y_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	cmp.w	#1,scroll_cnt
	beq	.no_scr
	subq.w	#1,x_reset(a0)
.no_scr
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

.e1	rts

move_baddie_down
	cmp.l	#blue_big_die_sprites,spr_ptr1(a0)
	beq.s	.skip
	tst.w	spr_die_flag(a0)
	bne.s	.e1
.skip

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_y_move_val(a0),d0
	add.w	d0,y_reset(a0)
.s0

	moveq	#0,d1
	move.w	y_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	cmp.w	#200-1,d0
	blt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	cmp.w	#1,scroll_cnt
	beq	.no_scr
	subq.w	#1,x_reset(a0)
.no_scr
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

.e1	rts

lv5_boss_move	;tst.w	spr_die_flag(a0)
	;bne	return

	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	cmp.w	#-1,d0
	bne.s	.s0
	move.l	spr_sin_reset(A0),spr_sin_tab(a0)
	move.l	spr_sin_tab(a0),a2
	lea	392(a2),a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
.s0	move.l	a2,spr_sin_tab(a0)
	add.w	x_reset(a0),d0
	add.w	y_reset(a0),d1
	move.w	d0,x1(a0)
	move.w	d1,y1(a0)
.e1	rts

move_pump	move.w	pump_mode(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.mode_tab(pc,d0.w),a2
	jmp	(a2)

.mode_tab	dc.l	.read_first
	dc.l	.do_move

.read_first	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d0
	cmp.w	#-1,d0
	bne.s	.no1
	move.w	#3,status(a0)
	bra	.return
.no1	move.w	d0,pump_dir(a0)
	move.l	a2,spr_sin_tab(a0)

	move.w	#1,pump_mode(a0)
	bra	move_pump

.do_move	move.w	pump_dir(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.dir_tab(pc,d0.w),a2
	jmp	(a2)

.dir_tab	dc.l	.return
	dc.l	.up
	dc.l	.down
	dc.l	.left
	dc.l	.right

.return	rts

.up	cmp.l	#blue_big_die_sprites,spr_ptr1(a0)
	beq.s	.u_skip
	tst.w	spr_die_flag(a0)
	bne	.return
.u_skip

	cmp.w	#1,scroll_cnt
	beq.s	.u_s2
	subq.w	#1,x_reset(a0)

.u_s2
	move.w	y_reset(a0),d0
	sub.w	spr_y_move_val(a0),d0
	move.w	d0,y_reset(a0)
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

	cmp.w	#-64,y_reset(a0)
	bgt	.u_s3
	move.w	#3,status(a0)
	bra	.return
.u_s3

;collision detect
	bra	pump_detect

.down	cmp.l	#blue_big_die_sprites,spr_ptr1(a0)
	beq.s	.d_skip
	tst.w	spr_die_flag(a0)
	bne	.return
.d_skip

	cmp.w	#1,scroll_cnt
	beq.s	.d_s2
	subq.w	#1,x_reset(a0)


.d_s2
	move.w	y_reset(a0),d0
	add.w	spr_y_move_val(a0),d0
	move.w	d0,y_reset(a0)
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

	cmp.w	#200,y_reset(a0)
	blt	.d_s3
	move.w	#3,status(a0)
	bra	.return
.d_s3

;collision detect
	bra	pump_detect

.left	cmp.l	#blue_big_die_sprites,spr_ptr1(a0)
	beq.s	.l_skip
	tst.w	spr_die_flag(a0)
	bne	.return
.l_skip

;	cmp.w	#1,scroll_cnt
;	beq.s	.l_s2

	move.w	x_reset(a0),d0
	sub.w	spr_x_move_val(a0),d0
	move.w	d0,x_reset(a0)
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)


.l_s2
	cmp.w	#-64,x_reset(a0)
	bgt	.l_s3
	move.w	#3,status(a0)
	bra	.return
.l_s3

;collision detect
	bra	pump_detect

.right	cmp.l	#blue_big_die_sprites,spr_ptr1(a0)
	beq.s	.r_skip
	tst.w	spr_die_flag(a0)
	bne	.return
.r_skip

;	cmp.w	#1,scroll_cnt
;	beq.s	.r_s2

	move.w	x_reset(a0),d0
	add.w	spr_x_move_val(a0),d0
	move.w	d0,x_reset(a0)
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

.r_s2
	cmp.w	#320,x_reset(a0)
	blt	.r_s3
	move.w	#3,status(a0)
	bra	.return
.r_s3

;collision detect

pump_detect
	clr.w	pop_flag1
	
	move.w	x_reset(a0),d0
	move.w	y_reset(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d3
	lsl.w	#5,d3
	add.w	d3,a2

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1

	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
;	tst.w	pop_flag1
;	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3

	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt.s	.s1
	cmp.w	d5,d3	;y1
	blt.s	.s1

	cmp.w	d6,d0	;x2
	bgt.s	.s1
	cmp.w	a4,d1	;y2
	bgt.s	.s1

	move.w	pump_dir(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.correct_tab(pc,d0.w),a2
	jsr	(a2)

	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d0
	cmp.w	#-1,d0
	bne.s	.no1
	move.w	#3,status(a0)
	bra	.s1
.no1	move.w	d0,pump_dir(a0)
	move.l	a2,spr_sin_tab(a0)


	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)
	move.l	(sp)+,pop
	bra	move_pump
;	move.w	#-1,pop_flag1

.s1	rts

.correct_tab	dc.l	.s1
	dc.l	.up
	dc.l	.down
	dc.l	.left
	dc.l	.right

.up	add.w	#1,a4
	move.w	a4,y_reset(a0)
	rts

.down	sub.w	#32+1,d5
	move.w	d5,y_reset(a0)
	rts

.left	addq.w	#2,d6
	move.w	d6,x_reset(a0)
	rts

.right	sub.w	#48+2,d4
	move.w	d4,x_reset(a0)
	rts

tank_rout	dc.w	0

move_tank	move.w	tank_rout,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a2
	jmp	(a2)

.tab	dc.l	move_tank_right
	dc.l	move_tank_left

move_tank_right	tst.w	spr_die_flag(a0)
	bne.s	.e1

	not.w	tank_ind
	tst.w	tank_ind
	beq	.e1
	move.l	tank_pos,a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	cmp.w	#-256,d1
	bne.s	.s1
	move.w	#1,tank_rout
	move.w	#1,spr_x_move_val(a0)
;	move.w	#3,status(a0)
	bra	.e1

.s1	move.l	a2,tank_pos
.s2
;	move.w	y_reset(a0),d1
;	add.w	d2,d1
;	move.w	d1,y1(a0)

	move.w	d0,x_reset(a0)
	move.w	d1,y_reset(a0)
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

.e1	rts

move_tank_left
	cmp.l	#blue_big_die_sprites,spr_ptr1(a0)
	beq.s	.skip
	tst.w	spr_die_flag(a0)
	bne.s	.e1
.skip

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.s0

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

;	cmp.w	#1,scroll_cnt
;	beq.s	.e1
;	subq.w	#1,x1(a0)
;
.e1	rts

tank_pos	dc.l	tank_tab
tank_tab
x	set	-(16*7)
	rept	(16*7)+160+6
	dc.w	x,(16*5)
x	set	x+1
	endr
	dc.w	-256,-256
tank_ind	dc.w	0

lv7_boss_cnt	dc.w	0
lv7_boss_wait_cnt
	dc.w	0
lv7_boss_pos	dc.l	lv7_boss_tab

lv7_boss_tab
x	set	64
	rept	64/2
	dc.w	x,0
x	set	x-2
	endr
	rept	4
	dc.w	x,0,x,0,x,0,x,0,x,0,x,0,x,0,x,0
	endr
	dc.w	x,1,x,1,x,1,x,1,x,1,x,1
	dc.w	x,2,x,2,x,2,x,2,x,2,x,2
	dc.w	x,3,x,3,x,3,x,3,x,3,x,3
	dc.w	x,2,x,2,x,2,x,2,x,2,x,2
	dc.w	x,1,x,1,x,1,x,1,x,1,x,1
	rept	4
	dc.w	x,0,x,0,x,0,x,0,x,0,x,0,x,0,x,0
	endr
	rept	64/2
	dc.w	x,0
x	set	x+2
	endr

	rept	10
	dc.w	x,0,x,0,x,0,x,0,x,0,x,0,x,0,x,0
	endr
	dc.w	-1,-1

move_lv7_boss	tst.w	spr_die_flag(a0)
	bne	return

	moveq	#0,d0
	move.w	lv7_boss_cnt,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a2
	jmp	(a2)

.tab	dc.l	lv7_boss_wait_a_bit
	dc.l	do_lv7_boss

lv7_boss_wait_a_bit
	jsr	move_baddie_right_left

	subq.w	#1,lv7_boss_wait_cnt
	tst.w	lv7_boss_wait_cnt
	bpl.s	.s1
	move.w	#-1,lv7_boss_wait_cnt
	move.w	#1,lv7_boss_cnt
.s1
	rts

do_lv7_boss	jsr	move_baddie_right_left

	move.l	lv7_boss_pos,a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	lea	lv7_boss_tab,a1
	move.w	(a1)+,d0
.s1	move.w	(a1)+,spr_num(a0)
	move.l	a1,lv7_boss_pos

	move.w	x_reset(a0),d1
	sub.w	#64,d1
	add.w	d0,d1
	move.w	d1,x1(a0)

	rts

move_spin1
	tst.w	spr_die_flag(a0)
	bne.s	.e1

;	cmp.w	#1,scroll_cnt
;	beq.s	.s0
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
	cmp.w	#0,x_reset(a0)
	bgt.s	.s0
	clr.w	x_reset(a0)
	move.w	#16,spr_move_mode(a0)
	move.l	#bydo_circ_tab,spr_sin_tab(a0)
	move.l	#bydo_circ_tab,spr_sin_reset(a0)
.s0

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

;	cmp.w	#1,scroll_cnt
;	beq.s	.e1
;	subq.w	#1,x1(a0)
;
.e1	rts

move_spin2	tst.w	spr_die_flag(a0)
	bne.s	.e1

;	cmp.w	#1,scroll_cnt
;	beq.s	.s0

	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
	cmp.w	#-1,d0
	bne.s	.s0
	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1
.s0	move.l	a2,spr_sin_tab(a0)

	move.w	d0,x_reset(a0)
	move.w	d1,y_reset(a0)

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

;	cmp.w	#1,scroll_cnt
;	beq.s	.e1
;	subq.w	#1,x1(a0)
;
.e1	rts

move_spin3	bsr.s	home_spin_x
	bsr.s	home_spin_y
	rts

home_spin_x	move.w	x1(a0),d0
	move.w	player_struct+x1,d1
	cmp.w	d0,d1
	beq.s	.s2
	cmp.w	d0,d1
	bgt.s	.s1
	subq.w	#2,x1(a0)
	bra.s	.s3
.s1	cmp.w	d0,d1
	blt.s	.s2
	addq.w	#2,x1(a0)
	bra.s	.s3
.s2	move.w	d1,x1(a0)
.s3	rts

home_spin_y	move.w	y1(a0),d0
	move.w	player_struct+y1,d1
	cmp.w	d0,d1
	beq.s	.s2
	cmp.w	d0,d1
	bgt.s	.s1
	subq.w	#2,y1(a0)
	bra.s	.s3
.s1	cmp.w	d0,d1
	blt.s	.s2
	addq.w	#2,y1(a0)
	bra.s	.s3
.s2	move.w	d1,y1(a0)
.s3	rts

bydo_circ_tab	incbin	bydocirc.tab
	dc.w	-1,-1

move_plant1	;tst.w	spr_die_flag(a0)
	;bmi	.e1

	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d0
	move.w	(a2)+,d1

	cmp.w	#-1,d0
	bgt.s	.s1
	move.w	#14,spr_move_mode(a0)
	move.w	x1(a0),x_reset(a0)
	move.w	y1(a0),y_reset(a0)
	bra	.e1
.s1
	move.l	a2,spr_sin_tab(a0)

	move.w	x_reset(a0),d2
	move.w	y_reset(a0),d3

	tst.w	spr_x_flag(a0)
	bne.s	.j1
	add.w	d0,d2
	bra.s	.j2
.j1	sub.w	d0,d2
.j2
	tst.w	spr_y_flag(a0)
	bne.s	.j3
	add.w	d1,d3
	bra.s	.j4
.j3	sub.w	d1,d3
.j4


;	add.w	d1,d3

	move.w	d2,x1(a0)
	move.w	d3,y1(a0)

	cmp.w	#1,scroll_cnt
	beq.s	.e1
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.e1	rts

move_plant2	;tst.w	spr_die_flag(a0)
	;bmi	.e1
;	moveq	#0,d0
;	moveq	#0,d1

	addq.w	#2,y_reset(a0)
	cmp.w	#192,y_reset(a0)
	blt.s	.s2
	move.w	#3,status(a0)
	bra.s	.e1
.s2
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

;	tst.w	spr_x_flag(a0)
;	bne.s	.j1
;	add.w	d0,d2
;	bra.s	.j2
;.j1	sub.w	d0,d2
;.j2

;	add.w	d1,d3

;	move.w	d2,x1(a0)
;	move.w	d3,y1(a0)

	cmp.w	#1,scroll_cnt
	beq.s	.e1
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.e1	rts

move_boss_tail
	tst.w	spr_die_flag(a0)
	bne.s	.e1
	cmp.w	#1,scroll_cnt
	beq.s	.s0

	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.s0
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d2
	move.w	(a2)+,d3
	cmp.w	#-1,d2
	bne.s	.s1
	move.l	spr_sin_reset(a0),a2
	move.w	(a2)+,d2
	move.w	(a2)+,d3
.s1	move.w	(a2)+,spr_num(a0)

	move.l	a2,spr_sin_tab(a0)
	add.w	d2,x1(a0)
	add.w	d3,y1(a0)

	moveq	#0,d1
	move.w	x1(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1
	sub.w	#32+32,d1

	cmp.w	d1,d0
	bgt.s	.s2
	move.w	#3,status(a0)
.s2

.e1	rts


move_grey_baddies
	tst.w	spr_die_flag(a0)
	bne.s	.e1

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.s0

	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	moveq	#0,d1
	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	cmp.w	#319,x_reset(a0)
	bgt.s	.s2

	bsr	move_x
	bsr	move_y

	bsr	check_y
.s2

	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

.e1
	rts

move_x

;	subq.w	#1,spr_x_cnt(a0)
;	tst.w	spr_x_cnt(a0)
;	bpl	.e0
;	move.w	#-1,spr_x_cnt(a0)

	move.w	player_struct+x1,d0
	move.w	x_reset(a0),d1
	cmp.w	d0,d1
	beq	.e1
	cmp.w	d0,d1
	blt.s	.s1

	move.l	level_point,a2
	lea	12+2(a2),a2
	move.l	(a2),a2
	addq.w	#2,a2
	move.l	4*2(a2),spr_ptr1(a0)

	clr.w	spr_x_flag(a0)
	subq.w	#1,x_reset(a0)
	cmp.w	#0,x_reset(a0)
	bgt.s	.j1
	clr.w	x_reset(a0)
.j1	bra.s	.e0
.s1
	move.l	level_point,a2
	lea	12+2(a2),a2
	move.l	(a2),a2
	addq.w	#2,a2
	move.l	4*3(a2),spr_ptr1(a0)

	move.w	#-1,spr_x_flag(a0)
	addq.w	#2,x_reset(a0)
	cmp.w	#320,x_reset(a0)
	blt.s	.e0
	move.w	#320,x_reset(a0)
.e0	rts

.e1	;move.w	#16,spr_x_cnt(a0)
	rts

move_y	;subq.w	#1,spr_y_cnt(a0)
	;tst.w	spr_y_cnt(a0)
	;bpl.s	.e0
	;move.w	#-1,spr_y_cnt(a0)

	move.w	player_struct+y1,d0
	move.w	y_reset(a0),d1
	cmp.w	d0,d1
	beq.s	.e1
	cmp.w	d0,d1
	blt.s	.s1
	clr.w	spr_y_flag(a0)
	subq.w	#1,y_reset(a0)
	cmp.w	#0,y_reset(a0)
	bgt.s	.j1
	clr.w	y_reset(a0)
.j1	bra.s	.e0
.s1	move.w	#-1,spr_y_flag(a0)
	addq.w	#1,y_reset(a0)
	cmp.w	#200-8-32,y_reset(a0)
	blt.s	.e0
	move.w	#200-8-32,y_reset(a0)
.e0	rts

.e1	;move.w	#16,spr_y_cnt(a0)
	rts

check_y	clr.w	pop_flag1
	;move.w	x1(a0),d0
	
	move.w	x_reset(a0),d0
	move.w	y_reset(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d3
	lsl.w	#5,d3
	add.w	d3,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1

	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3

	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect	movem.w	(a3),d4-d6/a4	; tile coords

	cmp.w	d4,d2	;x1
	blt.s	.s1
	cmp.w	d5,d3	;y1
	blt.s	.s1
	cmp.w	d6,d0	;x2
	bgt.s	.s1
	cmp.w	a4,d1	;y2
	bgt.s	.s1

;	cmp.w	#0,rest_cnt(a0)	; wait for 2 backgrounds to be stored
;	bgt.s	.s1

;	move.w	#$700,$fffff8240.w

;	tst.w	cheat_flag	; cheat on - can't die!
;;	bne.s	.n1
;	st	player_dead
;.n1
	tst.w	spr_x_flag(a0)
	beq.s	.s2
	subq.w	#2,x_reset(a0)
	bra.s	.s3
.s2	addq.w	#1,x_reset(a0)
.s3


	tst.w	spr_y_flag(a0)
	beq.s	.s4
	subq.w	#1,y_reset(a0)
	bra.s	.s5
.s4	addq.w	#1,y_reset(a0)
.s5
	move.w	#-1,spr_x_cnt(a0)
	move.w	#-1,spr_y_cnt(a0)
	move.w	#-1,pop_flag1

.s1	rts

move_baddie_right_left_vertical_sinus
	tst.w	spr_die_flag(a0)
	bne.s	.e1
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.w	x_reset(a0),x1(a0)

	move.w	y_reset(a0),d1	; y
	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,d2
	cmp.w	#-1,d2
	bne.s	.s2
	move.l	spr_sin_reset(a0),a2
	move.w	(a2)+,d2
.s2	move.l	a2,spr_sin_tab(a0)
	add.w	d2,d1
	move.w	d1,y1(a0)

.e1	rts


move_baddie_right_left
	cmp.l	#blue_big_die_sprites,spr_ptr1(a0)
	beq.s	.skip
	tst.w	spr_die_flag(a0)
	bne.s	.e1
.skip

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.s0

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

;	cmp.w	#1,scroll_cnt
;	beq.s	.e1
;	subq.w	#1,x1(a0)
;
.e1	rts

move_baddie_follow_sinus
	tst.w	spr_die_flag(a0)
	bne.s	.e1


	move.l	spr_sin_tab(a0),a2
	move.w	(a2)+,x1(a0)
	move.w	(a2)+,d2
	cmp.w	#-1,d2
	bne.s	.s1
	move.w	#3,status(a0)
	bra	.e1

.s1
	move.w	(a2)+,spr_num(a0)


	move.l	a2,spr_sin_tab(a0)
	move.w	y_reset(a0),d1
	add.w	d2,d1
	move.w	d1,y1(a0)

.e1	rts


move_baddie_follow_sinus_with_scroll
	tst.w	spr_die_flag(a0)
	bne	.e1

.l1	move.l	spr_sin_tab(a0),a2

	move.w	x_reset(a0),d0
	add.w	(a2)+,d0
	cmp.w	#-64,d0
	bne.s	.s1

	cmp.w	#25,spr_type(a0)
	bne.s	.bod1

	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	bra	.l1
.bod1
	move.w	#3,status(a0)
	bra	.e1
.s1
	move.w	d0,x1(a0)

	move.w	y_reset(a0),d2
	add.w	(a2)+,d2
	cmp.w	#-64,d2
	bne.s	.s2
	cmp.w	#25,spr_type(a0)
	bne.s	.bod2
	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	bra	.l1
.bod2
	move.w	#3,status(a0)
	bra	.e1

.s2	move.w	d2,y1(a0)

	cmp.w	#7,stage
	bne	.n3
	cmp.w	#1,scroll_cnt
	beq	.n2
.n3
	move.w	(a2)+,d3
	cmp.w	#-64,d3
	bne.s	.n1

	cmp.w	#25,spr_type(a0)
	bne.s	.bod3
	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	bra	.l1
.bod3

	move.w	#3,status(a0)
	bra	.e1
.n1	move.w	d3,spr_num(a0)
.n2
	subq.w	#1,spr_move_cnt(a0)
	tst.w	spr_move_cnt(a0)
	bmi.s	.s3
	subq.w	#6,a2
	bra.s	.s4
.s3	move.w	#-1,spr_move_cnt(a0)
.s4

	move.l	a2,spr_sin_tab(a0)

	cmp.w	#1,scroll_cnt
	beq	.no_scr
	subq.w	#1,x_reset(a0)

	cmp.w	#25,spr_type(a0)
	bne.s	.no_scr
	cmp.w	#-(80+32),x_reset(a0)
	bgt	.no_scr
	move.w	#3,status(a0)
.no_scr
.e1	rts

move_crawl
	tst.w	spr_die_flag(a0)
	bne	.e1

.l1	move.l	spr_sin_tab(a0),a2

	move.w	x_reset(a0),d0
	add.w	(a2)+,d0
	cmp.w	#-(80+32),d0
	bne.s	.s1

	cmp.w	#25,spr_type(a0)
	bne.s	.bod1
	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	bra	.l1
.bod1
	cmp.w	#26,spr_type(a0)
	bne.s	.bod1_a
	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	bra	.l1
.bod1_a
	move.w	#3,status(a0)
	bra	.e1
.s1
	move.w	d0,x1(a0)

	move.w	y_reset(a0),d2
	add.w	(a2)+,d2
	cmp.w	#-(80+32),d2
	bne.s	.s2
	cmp.w	#25,spr_type(a0)
	bne.s	.bod2
	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	bra	.l1
.bod2
	cmp.w	#26,spr_type(a0)
	bne.s	.bod2_a
	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	bra	.l1
.bod2_a

	move.w	#3,status(a0)
	bra	.e1

.s2	move.w	d2,y1(a0)

	cmp.w	#7,stage
	bne	.n3
	cmp.w	#1,scroll_cnt
	beq	.n2
.n3
	move.w	(a2)+,d3
	cmp.w	#-(80+32),d3
	bne.s	.n1

	cmp.w	#25,spr_type(a0)
	bne.s	.bod3
	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	bra	.l1
.bod3
	cmp.w	#26,spr_type(a0)
	bne.s	.bod3_a
	move.l	spr_sin_reset(a0),spr_sin_tab(a0)
	bra	.l1
.bod3_a

	move.w	#3,status(a0)
	bra	.e1
.n1	move.w	d3,spr_num(a0)
.n2
	subq.w	#1,spr_move_cnt(a0)
	tst.w	spr_move_cnt(a0)
	bmi.s	.s3
	subq.w	#6,a2
	bra.s	.s4
.s3	move.w	#-1,spr_move_cnt(a0)
.s4

	move.l	a2,spr_sin_tab(a0)

	cmp.w	#1,scroll_cnt
	beq	.no_scr
	subq.w	#1,x_reset(a0)

	cmp.w	#25,spr_type(a0)
	bne.s	.bod4
	cmp.w	#-(80+32),x_reset(a0)
	bgt	.bod4
	move.w	#3,status(a0)
.bod4
	cmp.w	#26,spr_type(a0)
	bne.s	.bod4_a
	cmp.w	#-(80+32),x_reset(a0)
	bgt	.bod4_a
	move.w	#3,status(a0)
.bod4_a

.no_scr
.e1	rts

move_circular_guns
;	tst.w	spr_die_flag(a0)
;	bne.s	.e1

	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)

	addq.l	#2*3,spr_sin_tab(a0)
	move.l	spr_sin_tab(a0),a1
	cmp.w	#-1,(a1)
	bne.s	.s1
	move.l	spr_sin_reset(a0),a1
.s1	move.l	a1,spr_sin_tab(a0)

	move.w	x_reset(a0),d1	; x
	move.w	y_reset(a0),d2	; y

	add.w	(a1),d1
	add.w	2(a1),d2

	tst.b	circular_flag
	bmi	.s2
	st	circular_flag

	subq.w	#1,gun_column_x1
	subq.w	#1,gun_column_x2
	subq.w	#1,gun_column_x3
	subq.w	#1,gun_column_x4
.s2

	cmp.w	#320+16,d1
	bge	.e1


	move.w	d1,x1(a0)
	move.w	d2,y1(a0)

	move.w	x1(a0),d0	; x_reset
	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1
	moveq	#0,d1
	sub.w	8(a1),d1
	sub.w	#32+32,d1

	cmp.w	d1,d0
	bgt.s	.e1
	move.w	#3,status(a0)

.e1	rts


move_walker1	move.w	spr_move_mode(a0),d0
	subq.w	#6,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a1
	jmp	(a1)

.tab	dc.l	.move_x
	dc.l	.move_y

.move_x	tst.w	spr_die_flag(a0)
	bne.s	.e1

	tst.w	spr_x_flag(a0)
	bne	.n1

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.s0

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

	bsr	walker_check_x
.e1	rts

.n1	cmp.w	#1,scroll_cnt
	beq.s	.s2
	move.w	spr_x_move_val(a0),d0
	subq.w	#1,d0
	add.w	d0,x_reset(a0)
.s2
	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s3
	move.w	#3,status(a0)
	bra.s	.e2
.s3
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

	bsr	walker_check_x
.e2	rts

.move_y	tst.w	spr_die_flag(a0)
	bne.s	.e3


	cmp.w	#1,scroll_cnt
	beq.s	.s4
;	move.w	spr_x_move_val(a0),d0
;	moveq	#1,d0
	subq.w	#1,x_reset(a0)
.s4

	subq.w	#1,spr_y_cnt(a0)
	tst.w	spr_y_cnt(a0)
	bpl.s	.e3
	move.w	#-1,spr_y_cnt(a0)

	addq.w	#3,y_reset(a0)

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s5
	move.w	#3,status(a0)
	bra.s	.e3
.s5

	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

	
	bsr	walker_check_y
.e3	rts

move_blue_walker
	tst.w	spr_die_flag(a0)
	bne	.e1

	tst.w	demo_mode
	bne.s	.j1

	cmp.w	#16,x1(a0)
	ble	.j1

	subq.w	#1,spr_x_cnt(a0)
	tst.w	spr_x_cnt(a0)
	bpl.s	.j1
	move.w	#2-1,spr_x_cnt(a0)
	move.w	#1,spr_move_mode(a0)
	move.w	#1,spr_x_move_val(a0)
	move.w	#12-1,spr_anim_val(a0)
	move.w	#7-1,spr_num(a0)
	tst.w	spr_x_flag(a0)
	beq.s	.j1
	move.w	#17-1,spr_num(a0)
.j1
	tst.w	spr_x_flag(a0)
	bne	.n1

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.s0

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

	bsr	walker_check_x
.e1	rts

.n1	cmp.w	#1,scroll_cnt
	beq.s	.s2
	move.w	spr_x_move_val(a0),d0
	subq.w	#1,d0
	add.w	d0,x_reset(a0)
.s2
	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s3
	move.w	#3,status(a0)
	bra.s	.e2
.s3
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

	bsr	walker_check_x
.e2	rts

; has walker hit a tile? if so change x direction

walker_check_x	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1

	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect	movem.w	(a3),d4-d6/a3	; tile coords
	subq.w	#5,d4
	subq.w	#5,d6

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	a3,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

	not.w	spr_x_flag(a0)
	cmp.w	#10,spr_type(a0)
	bne.s	.s3
	tst.w	spr_x_flag(a0)
	beq.s	.s2
	addq.w	#1,x_reset(a0)
	bra.s	.s3
.s2	subq.w	#1,x_reset(a0)
.s3
	move.w	#-1,walk_animate_cnt

	move.w	#-1,pop_flag1

.s1	rts


; has walker hit a tile? if so change to x movement

walker_check_y	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1

	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect
	movem.w	(a3),d4-d6/a3	; tile coords

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	a3,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

;	not.w	spr_x_flag(a0)
;	move.w	#-1,walk_animate_cnt

	cmp.w	#1,stage
	bne.s	.not_stage1
	move.w	#(16*12)-(32+16)-1,y_reset(a0)
	move.w	#(16*12)-(32+16)-1,y1(a0)
	bra.s	.not_stage6
.not_stage1	cmp.w	#6,stage
	bne.s	.not_stage6
	move.w	#-1,y_reset(a0)
	move.w	#-1,y1(a0)
.not_stage6

	move.w	#6,spr_move_mode(a0)

	move.w	#-1,pop_flag1

.s1	rts

move_big_baddie2
	tst.w	spr_die_flag(a0)
	bne.s	.e1

	tst.w	spr_x_flag(a0)
	bne	.n1

	cmp.w	#1,scroll_cnt
	beq.s	.s0
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
.s0

	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s1
	move.w	#3,status(a0)
	bra.s	.e1
.s1
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

	bsr	big_baddie_check_x
.e1	rts

.n1	cmp.w	#1,scroll_cnt
	beq.s	.s2
	move.w	spr_y_move_val(a0),d0
	subq.w	#1,d0
	sub.w	d0,y_reset(a0)
	subq.w	#1,x_reset(a0)
.s2
	cmp.w	#75,y_reset(a0)
	bgt.s	.s3
	move.w	#75,y_reset(a0)
.s3
	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s4
	move.w	#3,status(a0)
	bra.s	.e2
.s4
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

;	bsr	big_baddie_check_x
.e2	rts

; has walker hit a tile? if so change x direction

big_baddie_check_x
	clr.w	pop_flag1
	move.w	x1(a0),d0
	move.w	y1(a0),d1

	move.l	spr_ptr1(a0),a1
	addq.w	#6,a1

	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a1

	move.w	d0,d2
	move.w	d1,d3

	add.w	8(a1),d2	; width in pixels
	add.w	12(a1),d3	; height

	move.l	map_buff_pos,a1

	moveq	#0,d4
	moveq	#12-1,d7
.l1
x	set	0
	rept	6
	tst.w	pop_flag1
	bne	.return
	move.w	tile_flag+x(a1),d4
;	move.l	.table2(pc,d4.w),a2
	lea	.table2(pc),a2
	add.w	d4,a2
	move.l	(a2),a2

	move.l	a1,a3
	lea	tile_x1+x(a3),a3
	jsr	(a2)
x	set	x+tile_size
	endr
	lea	((tile_size*7)*2)(a1),a1
	dbf	d7,.l1
.return	rts

.table2	dc.l	.return
	dc.l	.detect

.detect	movem.w	(a3),d4-d6/a3	; tile coords
;	subq.w	#5,d4
;	subq.w	#5,d6

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	a3,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

	move.w	#-1,spr_x_flag(a0)
;	move.w	#-1,walk_animate_cnt

	move.w	spr_x_move_val(a0),d0
	add.w	d0,x_reset(a0)

	move.w	#5-1,spr_num(a0)
	clr.w	spr_y_flag(a0)
	move.w	#-1,pop_flag1

.s1	rts

animate_baddies
	subq.w	#1,grey_animate_cnt
	subq.w	#1,walk_animate_cnt
	subq.w	#1,big_animate_cnt

	subq.w	#1,animate_cnt
	cmp.w	#0,animate_cnt
	bgt	.return
	move.w	#2,animate_cnt

x	set	0
	rept	num_baddies
	lea	baddie_struct+x,a0
	move.w	status(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a1
	add.w	d0,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+sprite_size
	endr

.return
	tst.w	walk_animate_cnt
	bpl.s	.skip1
	move.w	#2,walk_animate_cnt

.skip1
	tst.w	grey_animate_cnt
	bpl.s	.skip2
	move.w	#2,grey_animate_cnt

.skip2	tst.w	big_animate_cnt
	bpl.s	.return2
	move.w	#2,big_animate_cnt
.return2	rts

.tab	dc.l	.return2
	dc.l	.return2
	dc.l	anim_baddie
	dc.l	.return2

anim_baddie	tst.w	spr_die_flag(a0)
	bne	anim_kill

	move.w	spr_anim_val(a0),d0

	tst.w	d0
	bmi	.return

	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a1
	jmp	(a1)

.tab	dc.l	.return
	dc.l	anim_cycle
	dc.l	anim_grey
	dc.l	anim_follow_player1
	dc.l	anim_follow_player2
	dc.l	anim_rotated_guns
	dc.l	anim_boss_weak
	dc.l	anim_walker1
	dc.l	anim_blue_walker
	dc.l	anim_big_baddie2
	dc.l	anim_boss_mouth
	dc.l	anim_blue_walker_up
	dc.l	anim_blue_walker_fire
	dc.l	anim_blue_walker_down
	dc.l	anim_blue_walker_reset
	dc.l	anim_triffid
	dc.l	anim_plant1
	dc.l	anim_plant2
	dc.l	anim_bydo_sheild1_a
	dc.l	anim_bydo_sheild2_a
	dc.l	anim_bydo_sheild1_b
	dc.l	anim_bydo_sheild2_b
	dc.l	anim_bydo
	dc.l	.return
.return	rts


anim_bydo_sheild1_a
	move.l	bydo_sheild_pos1_a,a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	move.l	#bydo_sheild_tab,bydo_sheild_pos1_a
	clr.w	spr_anim_val(a0)
	bra	.s2

.s1	move.l	a1,bydo_sheild_pos1_a
	move.w	d0,spr_num(a0)

	move.w	#-3,spr_energy(a0)
	cmp.w	#3,spr_num(a0)
	bgt.s	.s2
	move.w	#-2,spr_energy(a0)


.s2	rts

anim_bydo_sheild2_a
	move.l	bydo_sheild_pos2_a,a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1

	move.l	#bydo_sheild_tab,bydo_sheild_pos2_a
	clr.w	spr_anim_val(a0)
	sf	spin_flag

	lea	baddie_struct,a1
	move.w	#num_baddies-1,d0
.l1	cmp.w	#0,status(a1)
	beq.s	.skip
	cmp.w	#3,spr_type(a1)
	bne.s	.skip
	move.w	#22,spr_anim_val(a1)
	bra	.s2
.skip	lea	sprite_size(a1),a1
	dbf	d0,.l1

	bra	.s2

.s1	move.l	a1,bydo_sheild_pos2_a
	move.w	d0,spr_num(a0)

	move.w	#-3,spr_energy(a0)
	cmp.w	#3,spr_num(a0)
	bgt.s	.s2
	move.w	#-2,spr_energy(a0)

	
.s2	rts

bydo_sheild_pos1_a
	dc.l	bydo_sheild_tab
bydo_sheild_pos2_a
	dc.l	bydo_sheild_tab

bydo_sheild_tab
	rept	15
	dc.w	0,1,2,3,2,1
	endr
	dc.w	0,1,2,3,4,5,6,7,8
	dc.w	-1

anim_bydo_sheild1_b
	move.l	bydo_sheild_pos1_b,a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	move.l	#bydo_sheild_tab_b,bydo_sheild_pos1_b
	move.w	#18,spr_anim_val(a0)
	clr.w	animate_cnt
	bra	.s2

.s1	move.l	a1,bydo_sheild_pos1_b
	move.w	d0,spr_num(a0)

	move.w	#-3,spr_energy(a0)
	cmp.w	#3,spr_num(a0)
	bgt.s	.s2
	move.w	#-2,spr_energy(a0)


.s2	rts

anim_bydo_sheild2_b
	move.l	bydo_sheild_pos2_b,a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1

	move.l	#bydo_sheild_tab_b,bydo_sheild_pos2_b

	move.w	#19,spr_anim_val(a0)
	clr.w	animate_cnt
	bra	.s2

.s1	move.l	a1,bydo_sheild_pos2_b
	move.w	d0,spr_num(a0)

	move.w	#-3,spr_energy(a0)
	cmp.w	#3,spr_num(a0)
	bgt.s	.s2
	move.w	#-2,spr_energy(a0)
	
.s2	rts

bydo_sheild_pos1_b
	dc.l	bydo_sheild_tab_b
bydo_sheild_pos2_b
	dc.l	bydo_sheild_tab_b

bydo_sheild_tab_b
	dc.w	7,6,5,4,3,2,1

	dc.w	-1

anim_bydo	move.l	bydo_pos,a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	move.l	#bydo_tab,bydo_pos
	clr.w	spr_anim_val(a0)

	lea	baddie_struct,a1
	move.w	#num_baddies-1,d0
.l1	cmp.w	#0,status(a1)
	beq.s	.skip2

	cmp.w	#21,spr_type(a1)
	bne.s	.skip
	move.w	#20,spr_anim_val(a1)
	bra	.skip2
.skip
	cmp.w	#22,spr_type(a1)
	bne.s	.skip2
	move.w	#21,spr_anim_val(a1)
.skip2
	lea	sprite_size(a1),a1
	dbf	d0,.l1

	bra	.s2

.s1	move.l	a1,bydo_pos
	move.w	d0,spr_num(a0)

	cmp.w	#4,d0
	beq	set_spin
	
.s2	rts

bydo_pos	dc.l	bydo_tab
bydo_tab	dc.w	0,0,1,1,2,2,3,3,4,4
	dc.w	4,4,4,4,4,4,4,4,4,4
	dc.w	4,4,3,3,2,2,1,1,0,0
	dc.w	-1

spin_cnt	dc.w	0
spin_flag	dc.b	0
	even

set_spin
	tst.b	spin_flag
	bmi	.e1
	st	spin_flag

	subq.w	#1,spin_cnt
	tst.w	spin_cnt
	bmi	.e2

	clr.w	pop_flag1

x	set	0
	rept	num_bullets
	tst.w	pop_flag1
	bmi	.e1
	lea	baddie_struct+x,a1
	move.w	status(a1),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.baddie_tab(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.e1	rts

.e2	move.w	#-1,spin_cnt
	rts

.baddie_tab	dc.l	.set_up
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1

.set_up	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	move.w	#(64*3)+32,x_reset(a1)
	move.w	#(16*3)+32,y_reset(a1)

	move.l	level_point,a2
	lea	12+2(a2),a2
	move.l	(a2),a2
	addq.w	#2,a2
	move.l	4*15(a2),spr_ptr1(a1)

	move.w	#15,spr_move_mode(a1)
	move.w	#1,spr_anim_val(a1)
	move.w	#8,spr_x_move_val(a1)
	clr.w	spr_y_move_val(a1)
	move.w	#3-1,spr_frames(a1)

	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)
	clr.w	spr_die_flag(a1)

	clr.w	spr_move_flag(a1)

	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	move.w	#-1,spr_mask_flag(a1)

	move.w	#-2,spr_power(a1)

	clr.w	spr_num(a1)
	clr.w	spr_score(a1)
	clr.w	pickup_type(a1)

	clr.w	spr_rout_flag(a1)

	move.w	#-2,spr_energy(a1)

	move.w	#23,spr_type(a1)

	move.w	#-1,pop_flag1
	rts

anim_plant1	addq.w	#1,spr_num(a0)
	cmp.w	#4-1,spr_num(a0)
	blt.s	.s1
	clr.w	spr_num(a0)
.s1
	subq.w	#1,spr_anim_cnt(a0)
	tst.w	spr_anim_cnt(a0)
	bpl.s	.s2
	move.w	#-1,spr_anim_cnt(a0)
	move.w	#17,spr_anim_val(a0)
.s2	rts

anim_plant2	addq.w	#1,spr_num(a0)
	cmp.w	#12-1,spr_num(a0)
	blt.s	.s1
	move.w	#9-1,spr_num(a0)
.s1	rts

anim_triffid	subq.w	#1,spr_move_cnt(a0)
	tst.w	spr_move_cnt(a0)
	bpl.s	.s1
	move.w	#-1,spr_move_cnt(a0)

	tst.w	walk_animate_cnt
	bpl.s	.s1

	addq.w	#1,spr_num(a0)
	cmp.w	#4-1,spr_num(a0)
	blt.s	.s1
	move.w	#4-1,spr_num(a0)
	bsr	do_triff_fire
.s1	rts

triff_gap_cnt	dc.w	0
triff_fire_cnt1	dc.w	0
triff_fire_cnt2	dc.w	0
triff_fire_flag1
	dc.w	0
triff_fire_flag2
	dc.w	0
plant_flag	dc.w	0

;14/15=triff 1/triff 2
do_triff_fire
	subq.w	#1,triff_gap_cnt
	tst.w	triff_gap_cnt
	bpl	.e1
	move.w	#8-1,triff_gap_cnt
x	set	0
	rept	num_bullets
	tst.w	pop_flag1
	bmi	.e1
	lea	baddie_struct+x,a1
	move.w	status(a1),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.baddie_tab(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.e1	rts

.baddie_tab	dc.l	.create
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1

.create

	cmp.w	#12,spr_type(a0)
	beq.s	.setup1
	cmp.w	#13,spr_type(a0)
	beq.s	.setup2
	rts

.setup1	tst.w	triff_fire_flag1
	bmi.s	.n1
	subq.w	#1,triff_fire_cnt1
	tst.w	triff_fire_cnt1
	bpl.s	.n1_a
	move.w	#-1,triff_fire_flag1
	clr.w	triff_gap_cnt
	bra.s	.n1
.n1_a	bsr.s	.setup
.n1	rts

.setup2	tst.w	triff_fire_flag2
	bmi.s	.n2
	subq.w	#1,triff_fire_cnt2
	tst.w	triff_fire_cnt2
	bpl.s	.n2_a
	move.w	#-1,triff_fire_flag2
	bra.s	.n2
.n2_a	bsr.s	.setup
.n2	rts

.setup	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	move.w	x1(a0),d0
	move.w	y1(a0),d1
	add.w	#13,d0
;	tst.w	spr_x_flag(a0)
;	beq.s	.bod
;	subq.w	#8,d0
;.bod
	cmp.w	#12,spr_type(a0)
	beq.s	.j0
	add.w	#$56+16,d1

	bra.s	.j1
.j0	sub.w	#$56,d1
.j1



;	sub.w	#32,d1
	move.w	d0,x_reset(a1)
	move.w	d1,y_reset(a1)

	move.l	level_point,a2
	lea	14(a2),a2
	move.l	(a2),a2
	lea	2+(4*10)(a2),a2
	move.l	(a2),spr_ptr1(a1)

;	move.l	#rocket_sprites,spr_ptr1(a1)
	move.w	#14,spr_type(a1)
	move.w	#13,spr_move_mode(a1)
	move.w	#16,spr_anim_val(a1)
	move.w	#1,spr_x_move_val(a1)	; pixels to move
	clr.w	spr_y_move_val(a1)	; pixels to move
	clr.w	spr_frames(a1)

	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)	;6
	clr.w	spr_die_flag(a1)

	clr.w	spr_move_flag(a1)

	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	move.w	#-1,spr_mask_flag(a1)

	move.w	#1,spr_power(a1)
	move.w	#4,spr_energy(a1)
	move.w	#-1,multi_hit_flag(a1)

	clr.w	spr_num(a1)

	move.w	plant_flag,spr_x_flag(a1)
	not.w	plant_flag
	clr.w	spr_x_cnt(a1)

	clr.w	spr_y_flag(a1)
	cmp.w	#13,spr_type(a0)
	bne.s	.j2
	move.w	#-1,spr_y_flag(a1)
.j2

	clr.w	spr_y_cnt(a1)

	move.l	#baddie_die_sprites1,die_gfx(a1)
	cmp.w	#8,stage
	blt.s	.no_blue1
	move.l	#blue_baddie_die_sprites1,die_gfx(a1)
.no_blue1

	move.l	#bad_die_sfx2+12,sample_start(a1)
	move.l	#bad_die_sfx2_end,sample_end(a1)
	clr.w	die_adjust_x(a1)
	clr.w	die_adjust_y(a1)
	move.w	#6-1,die_frames(a1)
	clr.w	pickup_type(a1)
	clr.w	spr_score(a1)

	clr.w	spr_rout_flag(a1)

	move.l	#plant_sin1,spr_sin_tab(a1)

	move.w	#4-1,spr_anim_cnt(a1)

;	move.w	player_struct+x1,d0
;	move.w	player_struct+y1,d1
;	move.w	d0,d2
;	move.w	d1,d3
;	add.w	#32,d2
;	add.w	#14,d3

;	moveq	#0,d4
;	moveq	#0,d5
;	move.w	x1(a0),d6
;	add.w	#16,d6
;	move.w	#319,d6
;	move.w	#200-8,d7

;	cmp.w	d6,d0
;	bgt.s	.s1
;	cmp.w	d7,d1
;	bgt.s	.s1
;
;	cmp.w	d4,d2
;;	blt.s	.s1
;	cmp.w	d5,d3
;	blt.s	.s1
;
;	move.l	#.rocket_sin2,spr_sin_tab(a1)
;	move.w	#-1,spr_x_flag(a1)
;
.exit
	move.w	#-1,pop_flag1
	rts

plant_sin1
y	set	$10+(32*2)
	rept	32/2
	dc.w	0,y
y	set	y-4
	endr

	dc.w	1,$10
	dc.w	1,$e
	dc.w	2,$c
	dc.w	3,$b
	dc.w	4,9
	dc.w	6,8
	dc.w	7,6
	dc.w	8,5
	dc.w	$a,4
	dc.w	$c,3
	dc.w	$d,2
	dc.w	$f,1
	dc.w	$11,0
	dc.w	$13,0
	dc.w	$15,0
	dc.w	$17,0
	dc.w	$19,0
	dc.w	$1b,0
	dc.w	$1d,0
	dc.w	$1f,1
	dc.w	$20,1
	dc.w	$22,2
	dc.w	$24,3
	dc.w	$26,4
	dc.w	$27,5
	dc.w	$29,7
	dc.w	$2a,8
	dc.w	$2b,$a
	dc.w	$2c,$b
	dc.w	$2d,$d
	dc.w	$2e,$f
	dc.w	$2f,$11

	dc.w	-1,-1

anim_big_baddie2
	tst.w	big_animate_cnt
	bpl.s	.s2

	tst.w	spr_x_flag(a0)
	bne	.n1

	move.l	spr_sin_tab(a0),a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	move.l	spr_sin_reset(a0),a1
	move.w	(a1)+,d0
.s1	move.l	a1,spr_sin_tab(a0)
	move.w	d0,spr_num(a0)

	rts

.n1	move.w	#5-1,spr_num(a0)
	not.w	spr_y_flag(a0)
	tst.w	spr_y_flag(a0)
	bne.s	.s2
	move.w	#6-1,spr_num(a0)
.s2	rts

anim_boss_mouth
	tst.b	stage_clear_flag
	bne	.s1

	subq.w	#1,mouth_cnt
	tst.w	mouth_cnt
	bpl.s	.s1
	move.w	#16-1,mouth_cnt

	move.l	spr_sin_tab(a0),a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s2
	move.l	spr_sin_reset(a0),a1
	move.w	(a1)+,d0
.s2	move.l	a1,spr_sin_tab(a0)
	move.w	d0,spr_num(a0)

	lea	anim_tile_struct,a1
	moveq	#num_anim_tiles-1,d0
.tile_l1	cmp.w	#0,anim_tile_stat(a1)
	beq.s	.tile_s2
	tst.w	anim_tile_type(a1)
	bmi.s	.tile_s2
	move.w	spr_num(a0),anim_tile_num(a1)
	bra.s	.s1
.tile_s2	lea	anim_tile_size(a1),a1
	dbf	d0,.tile_l1
.s1	rts

anim_blue_walker

	tst.w	spr_x_flag(a0)
	bne.s	.n1

	move.l	spr_sin_tab(a0),a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	move.l	spr_sin_reset(a0),a1
	move.w	(a1)+,d0
.s1	move.l	a1,spr_sin_tab(a0)
	move.w	d0,spr_num(a0)

.s0	rts

.n1	move.l	spr_sin_tab(a0),a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s2
	move.l	spr_sin_reset(a0),a1
	move.w	(a1)+,d0
.s2	move.l	a1,spr_sin_tab(a0)
	add.w	#10,d0
	move.w	d0,spr_num(a0)
	rts


anim_blue_walker_up
	subq.w	#1,spr_x_cnt(a0)
	tst.w	spr_x_cnt(a0)
	bpl.s	.s1

	move.w	#(8*2)-1,spr_x_cnt(a0)

	addq.w	#1,spr_num(a0)
	move.w	#13-1,spr_anim_val(a0)
.s1	rts

anim_blue_walker_down
	subq.w	#1,spr_x_cnt(a0)
	tst.w	spr_x_cnt(a0)
	bpl.s	.s1
	move.w	#-1,spr_x_cnt(a0)

	subq.w	#1,spr_num(a0)
	move.w	#15-1,spr_anim_val(a0)
.s1	rts

anim_blue_walker_reset
	jsr	rand
	move.l	seed,d0
	and.l	#64-1,d0
	add.l	#32-1,d0
	move.w	d0,spr_x_cnt(a0)

	move.w	#9-1,spr_anim_val(a0)
	move.w	#9-1,spr_move_mode(a0)
	move.w	#3,spr_x_move_val(a0)
.s1	rts

anim_blue_walker_fire
	subq.w	#1,spr_y_cnt(a0)
	tst.w	spr_y_cnt(a0)
	bpl.s	.s1
	move.w	#2-1,spr_y_cnt(a0)

	subq.w	#1,spr_x_cnt(a0)
	tst.w	spr_x_cnt(a0)
	bpl.s	.s0
	move.w	#2-1,spr_x_cnt(a0)
	move.w	#14-1,spr_anim_val(a0)

	move.w	#7-1,spr_num(a0)
	tst.w	spr_x_flag(a0)
	beq.s	.j2
	move.w	#17-1,spr_num(a0)
.j2	bra.s	.s1

.s0	tst.w	spr_x_flag(a0)
	bne.s	.j1
	addq.w	#1,spr_num(a0)
	cmp.w	#10-1,spr_num(a0)
	blt.s	.s1
	move.w	#8-1,spr_num(a0)
	bsr	do_blue_fire
.s1	rts

.j1	addq.w	#1,spr_num(a0)
	cmp.w	#20-1,spr_num(a0)
	blt.s	.s2
	move.w	#18-1,spr_num(a0)
	bsr	do_blue_fire
.s2	rts

do_blue_fire
x	set	0
	rept	num_bullets
	tst.w	pop_flag1
	bmi	.e1
	lea	bullet_struct+x,a1
	move.w	status(a1),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.baddie_tab(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr
.e1	rts

.baddie_tab	dc.l	.create
	dc.l	.e1
	dc.l	.e1
	dc.l	.e1

.create

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	move.w	x1(a0),d0
	move.w	y1(a0),d1
	add.w	#13,d0
	tst.w	spr_x_flag(a0)
	beq.s	.bod
	subq.w	#8,d0
.bod
	sub.w	#$56,d1
	move.w	d0,x_reset(a1)
	move.w	d1,y_reset(a1)

	move.l	#rocket_sprites,spr_ptr1(a1)
	move.w	#11,spr_type(a1)
	move.w	#3,spr_move_mode(a1)
	clr.w	spr_anim_val(a1)
	move.w	#1,spr_x_move_val(a1)	; pixels to move
	clr.w	spr_y_move_val(a1)	; pixels to move
	clr.w	spr_frames(a1)

	move.w	#2,status(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	move.w	#6,spr_move_dir(a1)
	clr.w	spr_die_flag(a1)

	clr.w	spr_move_flag(a1)

	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	move.w	#-1,spr_mask_flag(a1)

	move.w	#1,spr_power(a1)
	clr.w	spr_energy(a1)
	clr.w	multi_hit_flag(a1)

	clr.w	spr_num(a1)

	clr.w	spr_x_flag(a1)
	clr.w	spr_x_cnt(a1)
	clr.w	spr_y_flag(a1)
	clr.w	spr_y_cnt(a1)

	move.l	#baddie_die_sprites2,die_gfx(a1)
	move.l	#bad_die_sfx2+12,sample_start(a1)
	move.l	#bad_die_sfx2_end,sample_end(a1)
	move.w	#8,die_adjust_x(a1)
	move.w	#8,die_adjust_y(a1)
	move.w	#6-1,die_frames(a1)
	clr.w	pickup_type(a1)
	clr.w	spr_score(a1)

	move.w	#-1,spr_rout_flag(a1)
	movem.l	.rocket_tab(pc),d1-d6
	movem.l	d1-d6,spr_skew_tab(a1)

	move.l	#.rocket_sin1,spr_sin_tab(a1)

	move.w	player_struct+x1,d0
	move.w	player_struct+y1,d1
	move.w	d0,d2
	move.w	d1,d3
	add.w	#32,d2
	add.w	#14,d3

	moveq	#0,d4
	moveq	#0,d5
	move.w	x1(a0),d6
	add.w	#16,d6
;	move.w	#319,d6
	move.w	#200-8,d7

	cmp.w	d6,d0
	bgt.s	.s1
	cmp.w	d7,d1
	bgt.s	.s1

	cmp.w	d4,d2
	blt.s	.s1
	cmp.w	d5,d3
	blt.s	.s1

	move.l	#.rocket_sin2,spr_sin_tab(a1)
	move.w	#-1,spr_x_flag(a1)

.s1	move.w	#-1,pop_flag1
	rts

.rocket_tab	dc.l	mul_16x16_4_bpl
	dc.l	0
	dc.l	restore_16x16
	dc.l	draw_16x16_4_bpl
	dc.l	rocket_sprites_gfx
	dc.l	rocket_mul_tab

.rocket_sin1
y	set	$10+(32*2)
	rept	32/2
	dc.w	0,y,0
y	set	y-4
	endr

	dc.w	1,$10,1
	dc.w	1,$e,1
	dc.w	2,$c,1
	dc.w	3,$b,1
	dc.w	4,9,1
	dc.w	6,8,2
	dc.w	7,6,2
	dc.w	8,5,2
	dc.w	$a,4,2
	dc.w	$c,3,2
	dc.w	$d,2,3
	dc.w	$f,1,3
	dc.w	$11,0,3
	dc.w	$13,0,3
	dc.w	$15,0,3
	dc.w	$17,0,4
	dc.w	$19,0,4
	dc.w	$1b,0,4
	dc.w	$1d,0,4
	dc.w	$1f,1,4
	dc.w	$20,1,5
	dc.w	$22,2,5
	dc.w	$24,3,5
	dc.w	$26,4,5
	dc.w	$27,5,5
	dc.w	$29,7,6
	dc.w	$2a,8,6
	dc.w	$2b,$a,6
	dc.w	$2c,$b,6
	dc.w	$2d,$d,6
	dc.w	$2e,$f,7
	dc.w	$2f,$11,7

y	set	0
	rept	(32+30)-16
	dc.w	$2f,$11+1+y,8
y	set	y+4
	endr

	dc.w	-1,-1,-1

.rocket_sin2
y	set	$10+(32*2)
	rept	32/2
	dc.w	0,y,0
y	set	y-4
	endr

	dc.w	1,$10,15
	dc.w	1,$e,15
	dc.w	2,$c,15
	dc.w	3,$b,15
	dc.w	4,9,15
	dc.w	6,8,14
	dc.w	7,6,14
	dc.w	8,5,14
	dc.w	$a,4,14
	dc.w	$c,3,14
	dc.w	$d,2,13
	dc.w	$f,1,13
	dc.w	$11,0,13
	dc.w	$13,0,13
	dc.w	$15,0,13
	dc.w	$17,0,12
	dc.w	$19,0,12
	dc.w	$1b,0,12
	dc.w	$1d,0,12
	dc.w	$1f,1,12
	dc.w	$20,1,11
	dc.w	$22,2,11
	dc.w	$24,3,11
	dc.w	$26,4,11
	dc.w	$27,5,11
	dc.w	$29,7,10
	dc.w	$2a,8,10
	dc.w	$2b,$a,10
	dc.w	$2c,$b,10
	dc.w	$2d,$d,10
	dc.w	$2e,$f,10
	dc.w	$2f,$11,10

y	set	0
	rept	(32+30)-16
	dc.w	$2f,$11+1+y,8
y	set	y+4
	endr

	dc.w	-1,-1,-1

anim_walker1	cmp.w	#7,spr_move_mode(a0)
	beq	.s3

	tst.w	walk_animate_cnt
	bpl.s	.s0
	tst.w	spr_x_flag(a0)
	bne.s	.n1

	move.l	spr_sin_tab(a0),a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	move.l	spr_sin_reset(a0),a1
	move.w	(a1)+,d0
.s1	move.l	a1,spr_sin_tab(a0)
	move.w	d0,spr_num(a0)
.s0	rts

.n1	move.l	spr_sin_tab(a0),a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s2
	move.l	spr_sin_reset(a0),a1
	move.w	(a1)+,d0
.s2	move.l	a1,spr_sin_tab(a0)
	subq.w	#6,d0
	move.w	d0,spr_num(a0)
	rts

.s3	move.w	#7-1,spr_num(a0)
	not.w	.flag
	tst.w	.flag
	beq.s	.s4
	move.w	#8-1,spr_num(a0)
.s4	rts

.flag	dc.w	0

anim_rotated_guns
	tst.w	spr_die_flag(a0)
	bne.s	.s2
	cmp.w	#2,spr_type(a0)
	beq.s	.s2
	move.l	spr_sin_tab(a0),a1
	move.w	4(a1),spr_num(a0)
.s2
	rts

anim_grey
	tst.w	grey_animate_cnt
	bpl.s	.s0
	move.l	spr_sin_tab(a0),a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	move.l	spr_sin_reset(a0),a1
	move.w	(a1)+,d0
.s1	move.l	a1,spr_sin_tab(a0)
	move.w	d0,spr_num(a0)
.s0	rts

anim_cycle	cmp.w	#6,spr_type(a0)
	beq.s	.e2
	subq.w	#1,spr_num(a0)
	tst.w	spr_num(a0)
	bpl.s	.e1
	move.w	spr_frames(a0),spr_num(a0)
.e1	rts

.e2	cmp.w	#(40/2)-1,big_shot_cnt1
	bgt.s	.e1
	clr.w	spr_num(a0)
	rts

anim_follow_player1
	tst.b	player_dead	; have we died?
	bne.s	.e1
	move.w	player_struct+x1,d0
	move.w	player_struct+y1,d1
	add.w	#16,d0
	addq.w	#7,d1
	bsr	.bottom_right
	bsr	.top_right
	bsr	.top_mid2
	bsr	.top_mid1
	bsr	.top_left
	bsr	.bottom_left
.e1	rts

.bottom_right
	move.w	x1(a0),d2	; x1
	add.w	#16,d2
	move.w	y1(a0),d3	; y2
	move.w	#320,d4	; x2
	move.w	#192,d5	; y2

	cmp.w	d2,d0	; x1
	blt.s	.s1
	cmp.w	d3,d1	; y1
	blt.s	.s1

	cmp.w	d4,d0	; x2
	bgt.s	.s1
	cmp.w	d5,d1	; y2
	bgt.s	.s1
	move.w	#5,spr_num(a0)
	addq.l	#4,sp
.s1	rts

.top_right

	move.w	x1(a0),d2	; x1
	add.w	#16,d2
	moveq	#0,d3	; y1
	move.w	#320,d4	; x2
	move.w	y1(a0),d5	; y2

	cmp.w	d2,d0	; x1
	blt.s	.s2
	cmp.w	d3,d1	; y1
	blt.s	.s2

	cmp.w	d4,d0	; x2
	bgt.s	.s2
	cmp.w	d5,d1	; y2
	bgt.s	.s2
	move.w	#4,spr_num(a0)
	addq.l	#4,sp
.s2	rts

.top_mid2

	move.w	x1(a0),d2	; x2
	addq.w	#8,d2
	moveq	#0,d3	; y1

	move.w	d2,d4	; x2
	addq.w	#8,d4
	move.w	y1(a0),d5	; y2

	cmp.w	d2,d0	; x1
	blt.s	.s3
	cmp.w	d3,d1	; y1
	blt.s	.s3

	cmp.w	d4,d0	; x2
	bgt.s	.s3
	cmp.w	d5,d1	; y2
	bgt.s	.s3
	move.w	#3,spr_num(a0)
	addq.l	#4,sp
.s3	rts

.top_mid1

	move.w	x1(a0),d2	; x2
	moveq	#0,d3	; y1

	move.w	d2,d4	; x2
	addq.w	#8,d4
	move.w	y1(a0),d5	; y2

	cmp.w	d2,d0	; x1
	blt.s	.s4
	cmp.w	d3,d1	; y1
	blt.s	.s4

	cmp.w	d4,d0	; x2
	bgt.s	.s4
	cmp.w	d5,d1	; y2
	bgt.s	.s4
	move.w	#2,spr_num(a0)
	addq.l	#4,sp
.s4	rts

.top_left	moveq	#0,d2	; x1
	moveq	#0,d3	; y1
	move.w	x1(a0),d4	; x2
	move.w	y1(a0),d5	; y1

	cmp.w	d2,d0	; x1
	blt.s	.s5
	cmp.w	d3,d1	; y1
	blt.s	.s5

	cmp.w	d4,d0	; x2
	bgt.s	.s5
	cmp.w	d5,d1	; y2
	bgt.s	.s5
	move.w	#1,spr_num(a0)
	addq.l	#4,sp
.s5	rts

.bottom_left	moveq	#0,d2	; x1
	move.w	y1(a0),d3	; y1
	move.w	x1(a0),d4	; x2
	move.w	#192,d5	; y2

	cmp.w	d2,d0	; x1
	blt.s	.s6
	cmp.w	d3,d1	; y1
	blt.s	.s6

	cmp.w	d4,d0	; x2
	bgt.s	.s6
	cmp.w	d5,d1	; y2
	bgt.s	.s6
	clr.w	spr_num(a0)
	addq.l	#4,sp
.s6	rts

anim_follow_player2
	tst.b	player_dead	; have we died?
	bne.s	.e1
	move.w	player_struct+x1,d0
	move.w	player_struct+y1,d1
	add.w	#16,d0
	addq.w	#7,d1

	bsr	.top_left
	bsr	.bottom_left
	bsr	.bottom_mid1
	bsr	.bottom_mid2
	bsr	.bottom_right
	bsr	.top_right
.e1	rts

.top_left	moveq	#0,d2	; x1
	moveq	#0,d3	; y1
	move.w	x1(a0),d4	; x2
	move.w	y1(a0),d5	; y2
	add.w	#16,d5

	cmp.w	d2,d0	; x1
	blt.s	.s1
	cmp.w	d3,d1	; y1
	blt.s	.s1

	cmp.w	d4,d0	; x2
	bgt.s	.s1
	cmp.w	d5,d1	; y2
	bgt.s	.s1
	clr.w	spr_num(a0)
	addq.l	#4,sp
.s1	rts

.bottom_left	moveq	#0,d2	; x1
	move.w	y1(a0),d3	; y1
	add.w	#16,d3
	move.w	x1(a0),d4	; x2
	move.w	#192,d5	; y2

	cmp.w	d2,d0	; x1
	blt.s	.s2
	cmp.w	d3,d1	; y1
	blt.s	.s2

	cmp.w	d4,d0	; x2
	bgt.s	.s2
	cmp.w	d5,d1	; y2
	bgt.s	.s2
	move.w	#1,spr_num(a0)
	addq.l	#4,sp
.s2	rts

.bottom_mid1	move.w	x1(a0),d2	; x2
	move.w	y1(a0),d3	; y2
	add.w	#16,d3
	move.w	d2,d4	; x2
	addq.w	#8,d4
	move.w	#192,d5	; y2

	cmp.w	d2,d0	; x1
	blt.s	.s3
	cmp.w	d3,d1	; y1
	blt.s	.s3

	cmp.w	d4,d0	; x2
	bgt.s	.s3
	cmp.w	d5,d1	; y2
	bgt.s	.s3
	move.w	#2,spr_num(a0)
	addq.l	#4,sp
.s3	rts

.bottom_mid2	move.w	x1(a0),d2	; x2
	addq.w	#8,d2
	move.w	y1(a0),d3	; y2
	add.w	#16,d3
	move.w	d2,d4	; x2
	addq.w	#8,d4
	move.w	#192,d5	; y2

	cmp.w	d2,d0	; x1
	blt.s	.s4
	cmp.w	d3,d1	; y1
	blt.s	.s4

	cmp.w	d4,d0	; x2
	bgt.s	.s4
	cmp.w	d5,d1	; y2
	bgt.s	.s4
	move.w	#3,spr_num(a0)
	addq.l	#4,sp
.s4	rts

.bottom_right	move.w	x1(a0),d2	; x1
	move.w	y1(a0),d3	; y1
	add.w	#16,d2
	add.w	#16,d3
	move.w	#320,d4
	move.w	#192,d5

	cmp.w	d2,d0	; x1
	blt.s	.s5
	cmp.w	d3,d1	; y1
	blt.s	.s5

	cmp.w	d4,d0	; x2
	bgt.s	.s5
	cmp.w	d5,d1	; y2
	bgt.s	.s5
	move.w	#4,spr_num(a0)
	addq.l	#4,sp
.s5	rts

.top_right	move.w	x1(a0),d2	; x1
	add.w	#16,d2
	moveq	#0,d3	; y1
	move.w	#320,d4	; x2
	move.w	y1(a0),d5	; y2
	add.w	#16,d5

	cmp.w	d2,d0	; x1
	blt.s	.s6
	cmp.w	d3,d1	; y1
	blt.s	.s6

	cmp.w	d4,d0	; x2
	bgt.s	.s6
	cmp.w	d5,d1	; y2
	bgt.s	.s6
	move.w	#5,spr_num(a0)
	addq.l	#4,sp
.s6	rts

anim_boss_weak	move.w	stage,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a1
	jmp	(a1)

.return	rts

.tab	dc.l	.return
	dc.l	level_1_weak
	dc.l	level_2_weak
	dc.l	level_3_weak
	dc.l	.return
	dc.l	.return
	dc.l	.return
	dc.l	.return
	dc.l	.return


level_1_weak	tst.b	boss_weak_flag1
	bne.s	.s1
	subq.w	#1,boss_weak_cnt
	tst.w	boss_weak_cnt
	bpl	.s1
	move.w	#-1,boss_weak_cnt

	sub.w	#1,boss_weak_anim_cnt
	tst.w	boss_weak_anim_cnt
	bpl	.s1
	move.w	#6,boss_weak_anim_cnt

	cmp.w	#8-1,spr_num(a0)
	blt	.s2
	move.w	#8-1,spr_num(a0)
	st	boss_weak_flag1
	bra	.s1
.s2	add.w	#1,spr_num(a0)

	lea	anim_tile_struct,a1
	moveq	#num_anim_tiles-1,d0
.l1	cmp.w	#0,anim_tile_stat(a1)
	beq.s	.s3
	tst.w	anim_tile_type(a1)
	bpl.s	.s3
	move.w	spr_num(a0),anim_tile_num(a1)
	bra.s	.s1	
.s3	lea	anim_tile_size(a1),a1
	dbf	d0,.l1

.s1	rts

level_2_weak
;	tst.b	boss_weak_flag1
;	bne.s	.s1

	subq.w	#1,boss_weak_cnt
	tst.w	boss_weak_cnt
	bpl	.s1
	move.w	#-1,boss_weak_cnt

	sub.w	#1,boss_weak_anim_cnt
	tst.w	boss_weak_anim_cnt
	bpl	.s1
	move.w	#0,boss_weak_anim_cnt

	move.l	lv2_boss_weak_pos,a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne	.s2
	lea	lv2_boss_weak_tab,a1
	move.w	(a1)+,d0
.s2	move.l	a1,lv2_boss_weak_pos
	move.w	d0,spr_num(a0)

	lea	anim_tile_struct,a1
	moveq	#num_anim_tiles-1,d0
.l1	cmp.w	#0,anim_tile_stat(a1)
	beq.s	.s3
	move.w	spr_num(a0),anim_tile_num(a1)
	bra.s	.s1	
.s3	lea	anim_tile_size(a1),a1
	dbf	d0,.l1

.s1	rts

lv2_boss_weak_pos
	dc.l	lv2_boss_weak_tab

lv2_boss_weak_tab
	dc.w	0,1,2,3,4,5,6,7,6,5,4,3,2,1,-1

level_3_weak	sub.w	#1,boss_weak_anim_cnt
	tst.w	boss_weak_anim_cnt
	bpl	.s0
	move.w	#1,boss_weak_anim_cnt

	moveq	#0,d0
	move.l	spr_sin_tab(a0),a1
	move.w	(a1)+,d0
	cmp.w	#-1,d0
	bne.s	.s1
	move.l	spr_sin_reset(a0),a1
	move.w	(a1)+,d0
.s1	move.l	a1,spr_sin_tab(a0)
	move.w	d0,spr_num(a0)
.s0	rts

level_8_weak	;tst.b	boss_weak_flag1
	;bne.s	.s1
	subq.w	#1,boss_weak_cnt
	tst.w	boss_weak_cnt
	bpl	.s1
	move.w	#-1,boss_weak_cnt
.s1	rts

eye_cnt	dc.w	0
start_duct_cnt	dc.w	12
duct_anim_cnt	dc.w	5-1
duct_frame	dc.w	0
duct_offset	dc.w	(4*8)*3
duct_rout	dc.w	0
trash_cnt	dc.w	0
duct_sfx_flag	dc.b	0
	even
duct_gfx	incbin	duct.dat
	even

draw_duct
	cmp.w	#7,stage
	bne	.e1
	cmp.w	#1,scroll_cnt
	bne	.e1

	move.w	duct_rout,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a0
	jmp	(a0)

.e1	rts

.tab	dc.l	do_duct
	dc.l	do_trash

do_duct	subq.w	#1,start_duct_cnt
	tst.w	start_duct_cnt
	bpl	.e1
	move.w	#-1,start_duct_cnt

	subq.w	#1,duct_anim_cnt
	tst.w	duct_anim_cnt
	bpl.s	.s1
	move.w	#5-1,duct_anim_cnt

	add.w	#(8*4)*32,duct_frame
	cmp.w	#(((8*4)*32)*4)-1,duct_frame
	blt.s	.s1

	clr.w	duct_frame
	sub.w	#8*4,duct_offset
	sf	duct_sfx_flag
	tst.w	duct_offset
	bpl	.s1
	move.w	#1,duct_rout
	bra	.e1

.s1
	tst.b	duct_sfx_flag
	bmi	.s2
	st	duct_sfx_flag

	clr.w	$fffff8900.w		; stop dma
	move.l	#duct_sfx,d5
	move.b	d5,$fffff8907.w
	lsr.w	#8,d5
	move.l	d5,$fffff8902.w

	move.l	#duct_sfx_end,d5
	move.b	d5,$fffff8913.w
	lsr.w	#8,d5
	move.l	d5,$fffff890e.w
	move.w	#%0000000010000001,$fffff8920.w	; freq
	move.w	#%0000000000000001,$fffff8900.w	; start dma
.s2

	lea	duct_gfx,a0
	add.w	duct_frame,a0
	move.l	screen1,a1
	lea	(376*64)+(8*3)+(376*16)(a1),a1
	lea	back_scrn+(376*64)+(8*3)+(376*16),a2
	add.w	duct_offset,a1
	add.w	duct_offset,a2
	add.w	word_inc,a1
	add.w	word_inc,a2

	move.w	scroll_offset,d3
	and.w	#16-1,d3
	bne.s	.no_sub
	subq.w	#8,a1
	subq.w	#8,a2
.no_sub

x	set	0
	rept	32
	movem.l	(a0)+,d0-d7
	movem.l	d0-d7,x(a1)
	movem.l	d0-d7,x(a2)
x	set	x+376
	endr

.e1	rts

pump_cnt	dc.w	0

do_pump_boss	cmp.w	#6,stage
	bne	pump_return
	cmp.w	#1,scroll_cnt
	bne	pump_return

	subq.w	#1,pump_cnt
	tst.w	pump_cnt
	bpl	pump_return
	move.w	#40-1,pump_cnt
	clr.w	pop_flag1

x	set	0
	rept	num_baddies
	tst.w	pop_flag1
	bmi	pump_return
	lea	baddie_struct+x,a1
	move.w	status(a1),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	pump_tab(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr

pump_return	rts

pump_tab	dc.l	copy_pump
	dc.l	pump_return
	dc.l	pump_return
	dc.l	pump_return

copy_pump	move.l	level_point,a0
	move.l	12+2+(4*13)(a0),a0
	addq.w	#2,a0

	bsr	rand
	move.l	seed,d0
	and.l	#4-1,d0
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a0
	move.l	(a0),a0
	addq.w	#2,a0

	clr.w	pump_mode(a1)
	clr.w	pump_dir(a1)

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	clr.w	spr_x_flag(a1)
	clr.w	spr_x_cnt(a1)
	clr.w	spr_y_flag(a1)
	clr.w	spr_y_cnt(a1)

	clr.w	spr_die_flag(a1)
	move.w	(a0)+,x_reset(a1)
	move.w	(a0)+,y_reset(a1)

	move.w	(a0)+,spr_x_move_val(a1)
	move.w	(a0)+,spr_y_move_val(a1)

	move.w	(a0)+,spr_move_mode(a1)

	move.w	(a0)+,spr_num(a1)

	move.w	(a0)+,spr_anim_val(a1)

	move.l	(a0)+,spr_ptr1(a1)

	move.w	(a0)+,spr_frames(a1)

	move.l	#big_die_sprites,die_gfx(a1)

	addq.w	#2,a0

	move.w	(a0)+,die_frames(a1)

	move.l	(a0)+,spr_sin_tab(a1)
	move.l	(a0)+,spr_sin_reset(a1)

	move.l	#bad_die_sfx2+12,sample_start(a1)
	move.l	#bad_die_sfx2_end,sample_end(a1)
	addq.w	#2,a0

	move.w	(a0)+,spr_score(a1)
	move.w	(a0)+,die_adjust_x(a1)
	move.w	(a0)+,die_adjust_y(a1)
	move.w	(a0)+,spr_energy(a1)
	move.w	(a0)+,pickup_type(a1)

	move.w	(a0)+,spr_rout_flag(a1)

	lea	4*6(a0),a0

	move.w	(a0)+,spr_mask_flag(a1)
	move.w	(a0)+,multi_hit_flag(a1)

	move.w	(a0)+,spr_type(a1)
	move.w	(a0)+,spr_move_cnt(a1)
	
	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	clr.w	spr_power(a1)

	move.w	#2,status(a1)	; alive
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)
	clr.w	spr_move_flag(a1)
	clr.w	gun_rotate_flag(a1)


	move.w	#-1,pop_flag1
	rts

do_trash	bsr	do_eye
	subq.w	#1,trash_cnt
	tst.w	trash_cnt
	bpl	trash_return
	move.w	#12-1,trash_cnt
	clr.w	pop_flag1

x	set	0
	rept	num_baddies
	tst.w	pop_flag1
	bmi	trash_return
	lea	baddie_struct+x,a1
	move.w	status(a1),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	trash_tab(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr

trash_return	rts

trash_tab	dc.l	copy_trash
	dc.l	trash_return
	dc.l	trash_return
	dc.l	trash_return

copy_trash	move.l	level_point,a0
	move.l	12+2+(4*13)(a0),a0
	move.l	2(a0),a0
	addq.w	#2,a0

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	clr.w	spr_x_flag(a1)
	clr.w	spr_x_cnt(a1)
	clr.w	spr_y_flag(a1)
	clr.w	spr_y_cnt(a1)

	clr.w	spr_die_flag(a1)
	move.w	(a0)+,x_reset(a1)
	move.w	(a0)+,y_reset(a1)
	clr.w	x_reset(a1)
	clr.w	y_reset(a1)

	move.w	(a0)+,spr_x_move_val(a1)
	move.w	(a0)+,spr_y_move_val(a1)

	move.w	(a0)+,spr_move_mode(a1)

	move.w	(a0)+,spr_num(a1)

	move.w	(a0)+,spr_anim_val(a1)

	move.l	(a0)+,spr_ptr1(a1)

	move.w	(a0)+,spr_frames(a1)

	move.l	#baddie_die_sprites1,die_gfx(a1)

	addq.w	#2,a0

	move.w	(a0)+,die_frames(a1)

	move.l	(a0)+,spr_sin_tab(a1)
	move.l	(a0)+,spr_sin_reset(a1)

	move.l	#bad_die_sfx1+12,sample_start(a1)
	move.l	#bad_die_sfx1_end,sample_end(a1)
	addq.w	#2,a0

	move.w	(a0)+,spr_score(a1)
	move.w	(a0)+,die_adjust_x(a1)
	move.w	(a0)+,die_adjust_y(a1)
	move.w	(a0)+,spr_energy(a1)
	move.w	(a0)+,pickup_type(a1)

	move.w	(a0)+,spr_rout_flag(a1)

	lea	4*6(a0),a0

	move.w	(a0)+,spr_mask_flag(a1)
	move.w	(a0)+,multi_hit_flag(a1)

	move.w	(a0)+,spr_type(a1)
	move.w	(a0)+,spr_move_cnt(a1)
	
	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	clr.w	spr_power(a1)

	move.w	#2,status(a1)	; alive
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)
	clr.w	spr_move_flag(a1)
	clr.w	gun_rotate_flag(a1)

	bsr	rand
	move.l	seed,d0
	and.l	#4-1,d0
	add.l	d0,d0
	add.l	d0,d0
	lea	duct_wave_list,a0
	add.l	d0,a0
	move.l	(a0),spr_sin_tab(a1)

	bsr	rand
	move.l	seed,d0
	and.l	#8-1,d0
	move.w	d0,spr_num(a1)
	
	move.w	#-1,pop_flag1
	rts

duct_wave_list	dc.l	duct_wave_tab1
	dc.l	duct_wave_tab2
	dc.l	duct_wave_tab3
	dc.l	duct_wave_tab4

duct_wave_tab1
x	set	16
y	set	16*2
	rept	(232-(16*2))/4
	dc.w	x,y
y	set	y+4
	endr
	dc.w	-64,-64

duct_wave_tab2
x	set	16+((16*4)*1)
y	set	16*2
	rept	(232-(16*2))/4
	dc.w	x,y
y	set	y+4
	endr
	dc.w	-64,-64

duct_wave_tab3
x	set	16+((16*4)*2)
y	set	16*2
	rept	(232-(16*2))/4
	dc.w	x,y
y	set	y+4
	endr
	dc.w	-64,-64

duct_wave_tab4
x	set	16+((16*4)*3)
y	set	16*2
	rept	(232-(16*2))/4
	dc.w	x,y
y	set	y+4
	endr
	dc.w	-64,-64

do_eye	subq.w	#1,eye_cnt
	tst.w	eye_cnt
	bpl	eye_return
	move.w	#80-1,eye_cnt
	clr.w	pop_flag1

x	set	0
	rept	num_baddies
	tst.w	pop_flag1
	bmi	eye_return
	lea	baddie_struct+x,a1
	move.w	status(a1),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	eye_tab(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr

eye_return	rts

eye_tab	dc.l	copy_eye
	dc.l	eye_return
	dc.l	eye_return
	dc.l	eye_return

copy_eye	move.l	level_point,a0
	move.l	12+2+(4*13)(a0),a0
	move.l	2+4(a0),a0
	addq.w	#2,a0

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	clr.w	spr_x_flag(a1)
	clr.w	spr_x_cnt(a1)
	clr.w	spr_y_flag(a1)
	clr.w	spr_y_cnt(a1)

	clr.w	spr_die_flag(a1)
	move.w	(a0)+,x_reset(a1)
	move.w	(a0)+,y_reset(a1)
	clr.w	x_reset(a1)
	clr.w	y_reset(a1)

	move.w	(a0)+,spr_x_move_val(a1)
	move.w	(a0)+,spr_y_move_val(a1)

	move.w	(a0)+,spr_move_mode(a1)

	move.w	(a0)+,spr_num(a1)

	move.w	(a0)+,spr_anim_val(a1)

	move.l	(a0)+,spr_ptr1(a1)

	move.w	(a0)+,spr_frames(a1)

	move.l	#big_die_sprites,die_gfx(a1)

	addq.w	#2,a0

	move.w	(a0)+,die_frames(a1)

	move.l	(a0)+,spr_sin_tab(a1)
	move.l	(a0)+,spr_sin_reset(a1)

	move.l	#bad_die_sfx2+12,sample_start(a1)
	move.l	#bad_die_sfx2_end,sample_end(a1)
	addq.w	#2,a0

	move.w	(a0)+,spr_score(a1)
	move.w	(a0)+,die_adjust_x(a1)
	move.w	(a0)+,die_adjust_y(a1)
	move.w	(a0)+,spr_energy(a1)
	move.w	(a0)+,pickup_type(a1)

	move.w	(a0)+,spr_rout_flag(a1)

	lea	4*6(a0),a0

	move.w	(a0)+,spr_mask_flag(a1)
	move.w	(a0)+,multi_hit_flag(a1)

	move.w	(a0)+,spr_type(a1)
	move.w	(a0)+,spr_move_cnt(a1)
	
	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	clr.w	spr_power(a1)

	move.w	#2,status(a1)	; alive
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)
	clr.w	spr_move_flag(a1)
	clr.w	gun_rotate_flag(a1)

	bsr	rand
	move.l	seed,d0
	and.l	#4-1,d0
	add.l	d0,d0
	add.l	d0,d0
	lea	eye_table,a0
	add.l	d0,a0
	move.l	(a0),spr_sin_tab(a1)

	move.w	#-1,pop_flag1
	rts

eye_table	dc.l	eye_tab1
	dc.l	eye_tab2
	dc.l	eye_tab3
	dc.l	eye_tab4

eye_tab1
x	set	16*2
y	set	200
	rept	(64/4)+4
	dc.w	x,y,0
y	set	y-4
	endr

	dc.w	x,y,0
	dc.w	x,y,0
	dc.w	x,y,1
	dc.w	x,y,1
	dc.w	x,y,2
	dc.w	x,y,2
	dc.w	x,y,3
	dc.w	x,y,3
	dc.w	x,y,4
	dc.w	x,y,4
	dc.w	x,y,5
	dc.w	x,y,5
	dc.w	x,y,6
	dc.w	x,y,6
	dc.w	x,y,7
	dc.w	x,y,7
	dc.w	x,y,8
	dc.w	x,y,8
	dc.w	x,y,7
	dc.w	x,y,7
	dc.w	x,y,6
	dc.w	x,y,6
	dc.w	x,y,5
	dc.w	x,y,5
	dc.w	x,y,4
	dc.w	x,y,4
	dc.w	x,y,3
	dc.w	x,y,3
	dc.w	x,y,2
	dc.w	x,y,2
	dc.w	x,y,1
	dc.w	x,y,1

	rept	(64/4)+4
	dc.w	x,y,0
y	set	y+4
	endr

	dc.w	-1,-1,-1

eye_tab2
x	set	16*6
y	set	200
	rept	(64/4)+4
	dc.w	x,y,0
y	set	y-4
	endr

	dc.w	x,y,0
	dc.w	x,y,0
	dc.w	x,y,1
	dc.w	x,y,1
	dc.w	x,y,2
	dc.w	x,y,2
	dc.w	x,y,3
	dc.w	x,y,3
	dc.w	x,y,4
	dc.w	x,y,4
	dc.w	x,y,5
	dc.w	x,y,5
	dc.w	x,y,6
	dc.w	x,y,6
	dc.w	x,y,7
	dc.w	x,y,7
	dc.w	x,y,8
	dc.w	x,y,8
	dc.w	x,y,7
	dc.w	x,y,7
	dc.w	x,y,6
	dc.w	x,y,6
	dc.w	x,y,5
	dc.w	x,y,5
	dc.w	x,y,4
	dc.w	x,y,4
	dc.w	x,y,3
	dc.w	x,y,3
	dc.w	x,y,2
	dc.w	x,y,2
	dc.w	x,y,1
	dc.w	x,y,1

	rept	(64/4)+4
	dc.w	x,y,0
y	set	y+4
	endr

	dc.w	-1,-1,-1

eye_tab3
x	set	16*10
y	set	200
	rept	(64/4)+4
	dc.w	x,y,0
y	set	y-4
	endr

	dc.w	x,y,0
	dc.w	x,y,0
	dc.w	x,y,1
	dc.w	x,y,1
	dc.w	x,y,2
	dc.w	x,y,2
	dc.w	x,y,3
	dc.w	x,y,3
	dc.w	x,y,4
	dc.w	x,y,4
	dc.w	x,y,5
	dc.w	x,y,5
	dc.w	x,y,6
	dc.w	x,y,6
	dc.w	x,y,7
	dc.w	x,y,7
	dc.w	x,y,8
	dc.w	x,y,8
	dc.w	x,y,7
	dc.w	x,y,7
	dc.w	x,y,6
	dc.w	x,y,6
	dc.w	x,y,5
	dc.w	x,y,5
	dc.w	x,y,4
	dc.w	x,y,4
	dc.w	x,y,3
	dc.w	x,y,3
	dc.w	x,y,2
	dc.w	x,y,2
	dc.w	x,y,1
	dc.w	x,y,1

	rept	(64/4)+4
	dc.w	x,y,0
y	set	y+4
	endr

	dc.w	-1,-1,-1

eye_tab4
x	set	16*14
y	set	200
	rept	(64/4)+4
	dc.w	x,y,0
y	set	y-4
	endr

	dc.w	x,y,0
	dc.w	x,y,0
	dc.w	x,y,1
	dc.w	x,y,1
	dc.w	x,y,2
	dc.w	x,y,2
	dc.w	x,y,3
	dc.w	x,y,3
	dc.w	x,y,4
	dc.w	x,y,4
	dc.w	x,y,5
	dc.w	x,y,5
	dc.w	x,y,6
	dc.w	x,y,6
	dc.w	x,y,7
	dc.w	x,y,7
	dc.w	x,y,8
	dc.w	x,y,8
	dc.w	x,y,7
	dc.w	x,y,7
	dc.w	x,y,6
	dc.w	x,y,6
	dc.w	x,y,5
	dc.w	x,y,5
	dc.w	x,y,4
	dc.w	x,y,4
	dc.w	x,y,3
	dc.w	x,y,3
	dc.w	x,y,2
	dc.w	x,y,2
	dc.w	x,y,1
	dc.w	x,y,1

	rept	(64/4)+4
	dc.w	x,y,0
y	set	y+4
	endr
	dc.w	-1,-1,-1


anim_kill
	move.w	#-1,spr_die_flag(a0)
	move.w	spr_anim_val(a0),d0
	tst.w	d0
	bmi	.return
	add.w	d0,d0
	add.w	d0,d0
	move.l	.tab(pc,d0.w),a1
	jmp	(a1)

.tab	rept	5
	dc.l	.set_explode
	endr
	dc.l	.set_rotated_guns
	dc.l	.set_boss_weak
	rept	17-1
	dc.l	.set_explode
	endr
	dc.l	.set_explode	; l4 boss explode

.set_explode
	move.w	spr_num(a0),d0
	move.w	die_frames(a0),d1
	cmp.w	d1,d0
	blt	.inc_frame
	
	move.w	#3,status(a0)
;	bra.s	.return
.return
	rts

.set_rotated_guns
	move.w	spr_num(a0),d0
	move.w	die_frames(a0),d1
	cmp.w	d1,d0
	blt	.inc_frame

	move.l	level_point,a2
	move.l	12+2(a2),a2
	move.l	2+(4*6)(a2),spr_ptr1(a0)

;	move.l	#gun_die_sprites,spr_ptr1(a0)
	clr.w	spr_num(a0)
	move.w	#-2,spr_energy(a0)
	clr.w	spr_die_flag(a0)
	move.w	#2,spr_type(a0)
	move.w	#-1,spr_anim_val(a0)
	move.w	die_adjust_x(a0),d0
	add.w	d0,x1(a0)
	move.w	die_adjust_y(a0),d0
	add.w	d0,y1(a0)
	clr.w	animate_cnt
	rts

.set_boss_weak
; move explosions if screen is scrolling and it's
; the boss weak point/explosions for death

	cmp.w	#1,scroll_cnt		
	beq.s	.s1
	move.w	spr_x_move_val(a0),d0
	sub.w	d0,x_reset(a0)
	move.w	x_reset(a0),x1(a0)
	move.w	y_reset(a0),y1(a0)

.s1
	moveq	#0,d1
	move.w	x_reset(a0),d0
	move.l	spr_ptr1(a0),a2
	addq.w	#6,a2
	move.w	spr_num(a0),d2
	lsl.w	#5,d2
	add.w	d2,a2

	sub.w	8(a2),d1

	cmp.w	d1,d0
	bgt.s	.s3
	move.w	#3,status(a0)
	bra	.return
.s3

	move.w	spr_num(a0),d0
	move.w	die_frames(a0),d1
	cmp.w	d1,d0
	blt.s	.inc_frame

	cmp.w	#1,scroll_cnt		
	beq.s	.s4
	subq.w	#7,x_reset(a0)
	move.w	x_reset(a0),x1(a0)
.s4
;	move.l	level_point,a2
;	move.l	12+2(a2),a2
;	move.l	2+(4*7)(a2),spr_ptr1(a0)

	move.w	#3,status(a0)
;	move.l	#boss_weak_sprites,spr_ptr1(a0)
	clr.w	spr_num(a0)
	move.w	#-2,spr_energy(a0)
	clr.w	spr_die_flag(a0)
	move.w	#2,spr_type(a0)
	move.w	#-1,spr_anim_val(a0)
	move.w	die_adjust_x(a0),d0
	add.w	d0,x1(a0)
	move.w	die_adjust_y(a0),d0
	add.w	d0,y1(a0)
	clr.w	animate_cnt
	rts

.inc_frame	addq.w	#1,spr_num(a0)
	rts

init_baddies	tst.b	intro_done
	beq	.return

	lea	back_scrn,a4
;	lea	old_baddies+2560,a5	; 768

	move.l	restart_baddie_pos,a3

.l1	cmp.l	#-1,(a3)
	beq	.return

	move.l	(a3)+,a0

	moveq	#0,d0
	move.w	(a0)+,d0

	lea	baddie_struct,a1
	moveq	#num_baddies-1,d2
.l2	tst.w	d0
	bmi.s	.l1
	move.w	status(a1),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	.tab(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)
;	lea	2560*2(a4),a4
;	lea	2560*2(a5),a5
	lea	sprite_size(a1),a1
	dbf	d2,.l2

.return	rts

.tab	dc.l	.copy
	dc.l	.return
	dc.l	.return
	dc.l	.return

.copy
	move.l	a4,back_ptr1(a1)
	move.l	a4,back_ptr2(a1)
;	move.l	a5,back_ptr2(a1)

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	move.w	(a0)+,x_reset(a1)
	move.w	(a0)+,y_reset(a1)

	sub.w	#320+2,x_reset(a1)
	move.w	restart_x_offset,d1
	add.w	d1,x_reset(a1)

	move.w	(a0)+,spr_x_move_val(a1)
	move.w	(a0)+,spr_y_move_val(a1)

	move.w	(a0)+,spr_move_mode(a1)
	move.w	(a0)+,spr_num(a1)
	move.w	(a0)+,spr_anim_val(a1)

	move.l	(a0)+,spr_ptr1(a1)

	cmp.w	#3,stage
	beq.s	.s1
	cmp.l	#gun_turret_sprites1,spr_ptr1(a1)
	beq.s	.s1
	cmp.l	#gun_turret_sprites2,spr_ptr1(a1)
	beq.s	.s1
	add.w	#(320+2)-(64*1),x_reset(a1)
.s1
	move.w	(a0)+,spr_frames(a1)

	move.l	#baddie_die_sprites1,die_gfx(a1)
	cmp.w	#8,stage
	blt.s	.no_blue1
	move.l	#blue_baddie_die_sprites1,die_gfx(a1)
.no_blue1
	tst.w	(a0)
	beq.s	.s2
	move.l	#baddie_die_sprites2,die_gfx(a1)
.s2	addq.w	#2,a0

	move.w	(a0)+,die_frames(a1)

	move.l	(a0)+,spr_sin_tab(a1)
	move.l	(a0)+,spr_sin_reset(a1)

	move.l	#bad_die_sfx1+12,sample_start(a1)
	move.l	#bad_die_sfx1_end,sample_end(a1)
	tst.w	(a0)	; sfx flag
	beq.s	.s3
	move.l	#bad_die_sfx2+12,sample_start(a1)
	move.l	#bad_die_sfx2_end,sample_end(a1)
.s3	addq.w	#2,a0

	move.w	(a0)+,spr_score(a1)
	move.w	(a0)+,die_adjust_x(a1)
	move.w	(a0)+,die_adjust_y(a1)
	move.w	(a0)+,spr_energy(a1)
	move.w	(a0)+,pickup_type(a1)

	move.w	(a0)+,spr_rout_flag(a1)
; 0=blitter sprite,-1=software sprite
	tst.w	spr_rout_flag(a1)
	beq.s	.s4
	move.l	(a0)+,spr_skew_tab(a1)
	move.l	(a0)+,spr_store_addr(a1)
	move.l	(a0)+,spr_rest_addr(a1)
	move.l	(a0)+,spr_draw_addr(a1)
	move.l	(a0)+,spr_gfx_addr(a1)
	move.l	(a0)+,spr_anim_tab(a1)
	bra.s	.s5
.s4	lea	4*6(a0),a0
.s5
	move.w	(a0)+,spr_mask_flag(a1)
	move.w	(a0)+,multi_hit_flag(a1)
	move.w	(a0)+,spr_type(a1)
	move.w	(a0)+,spr_move_cnt(a1)

	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	clr.w	spr_power(a1)

	move.w	#2,status(a1)	; alive
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)
	clr.w	spr_die_flag(a1)
	clr.w	spr_move_flag(a1)

	subq.w	#1,d0

	rts

copy_baddie_waves
	tst.b	intro_done
	beq	.return

	move.l	level_offset,d0

	move.l	baddie_wave_tab_pos,a1

;	lea	baddie_wave_tab,a1
.l1
	move.l	(a1)+,d1
	move.l	(a1)+,a0
	cmp.l	#-1,a0
	beq	.return
	
	cmp.l	d0,d1
	bne.s	.l1

;	cmp.l	#-1,a0
;	bne.s	.s1
;	lea	baddie_wave_tab,a1
;	addq.w	#4,a1	; skip map pos check
;	move.l	(a1)+,a0
;.s1
;	move.l	a1,baddie_wave_tab_pos

	moveq	#0,d2	; multiplex switch
	moveq	#0,d0
	move.w	(a0)+,d0

x	set	0
	rept	num_baddies
	tst.w	d0
	bmi	.return
	lea	baddie_struct+x,a1
	move.w	status(a1),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	.tab(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)


x	set	x+sprite_size
	endr

.return	rts


.tab	dc.l	.copy
	dc.l	.return
	dc.l	.return
	dc.l	.return


.copy

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	clr.w	spr_x_flag(a1)
	clr.w	spr_x_cnt(a1)
	clr.w	spr_y_flag(a1)
	clr.w	spr_y_cnt(a1)

	clr.w	spr_die_flag(a1)
	move.w	(a0)+,x_reset(a1)
	move.w	(a0)+,y_reset(a1)

	move.w	(a0)+,spr_x_move_val(a1)
	move.w	(a0)+,spr_y_move_val(a1)

	move.w	(a0)+,spr_move_mode(a1)

	move.w	(a0)+,spr_num(a1)
	move.w	(a0)+,spr_anim_val(a1)

	move.l	(a0)+,spr_ptr1(a1)

	move.w	(a0)+,spr_frames(a1)

	move.l	#baddie_die_sprites1,die_gfx(a1)
	cmp.w	#8,stage
	blt.s	.no_blue1
	move.l	#blue_baddie_die_sprites1,die_gfx(a1)
.no_blue1
	tst.w	(a0)
	beq.s	.s2
	move.l	#baddie_die_sprites2,die_gfx(a1)
.s2
	cmp.w	#-2,(a0)
	bne.s	.s8
	move.l	#big_die_sprites,die_gfx(a1)
.s8
	cmp.w	#-3,(a0)
	bne	.s8_a

	move.w	x_reset(a1),x1(a1)
	move.w	y_reset(a1),y1(a1)
	move.l	#blue_big_die_sprites,die_gfx(a1)
	move.l	#blue_big_die_sprites,spr_ptr1(a1)
	move.w	#2,status(a1)	; alive
	move.w	#-1,spr_die_flag(a1)
	clr.w	die_adjust_x(a1)
	clr.w	die_adjust_y(a1)
	move.w	#11-1,die_frames(a1)
	clr.w	spr_anim_val(a1)
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)
	move.w	#1,spr_move_mode(a1)
	clr.w	spr_mask_flag(a1)
	move.w	#1,spr_type(a1)
	clr.w	spr_num(a1)
	move.w	#-1,spr_die_flag(a1)
	clr.w	spr_rout_flag(a1)
	move.w	#-1,spr_energy(a1)

	move.l	#scene_sfx+12,d5
	move.l	#scene_sfx_end,d6
	moveq	#-1,d7
	jsr	play_sfx
	bra	.r1
.s8_a
	addq.w	#2,a0

	move.w	(a0)+,die_frames(a1)

	move.l	(a0)+,spr_sin_tab(a1)
	move.l	(a0)+,spr_sin_reset(a1)

	move.l	#bad_die_sfx1+12,sample_start(a1)
	move.l	#bad_die_sfx1_end,sample_end(a1)
	tst.w	(a0)	; sfx flag
	beq.s	.s3
	move.l	#bad_die_sfx2+12,sample_start(a1)
	move.l	#bad_die_sfx2_end,sample_end(a1)
.s3	addq.w	#2,a0

	move.w	(a0)+,spr_score(a1)
	move.w	(a0)+,die_adjust_x(a1)
	move.w	(a0)+,die_adjust_y(a1)
	move.w	(a0)+,spr_energy(a1)
	move.w	(a0)+,pickup_type(a1)

	move.w	(a0)+,spr_rout_flag(a1)
; 0=blitter sprite,-1=software sprite
	tst.w	spr_rout_flag(a1)
	beq.s	.s4

;	movem.l	(a0)+,d1-d6
;	movem.l	d1-d6,spr_skew_tab(a1)

	move.l	(a0)+,spr_skew_tab(a1)
	move.l	(a0)+,spr_store_addr(a1)
	move.l	(a0)+,spr_rest_addr(a1)
	move.l	(a0)+,spr_draw_addr(a1)
	move.l	(a0)+,spr_gfx_addr(a1)
	move.l	(a0)+,spr_anim_tab(a1)


	bra.s	.s5
.s4	lea	4*6(a0),a0
.s5
	move.w	(a0)+,spr_mask_flag(a1)
	move.w	(a0)+,multi_hit_flag(a1)

	move.w	(a0)+,spr_type(a1)
	move.w	(a0)+,spr_move_cnt(a1)
	
	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	clr.w	spr_power(a1)

	move.w	#2,status(a1)	; alive
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)
	clr.w	spr_move_flag(a1)
	clr.w	gun_rotate_flag(a1)

	cmp.w	#9,spr_type(a1)
	bne.s	.s6

	cmp.w	#7,spr_move_mode(a1)
	bne.s	.s7
	move.w	#40-1,spr_y_cnt(a1)
	bra.s	.s6
.s7
	move.w	#9-1,spr_num(a1)
.s6

	cmp.w	#10,spr_type(a1)
	bne.s	.s9
	jsr	rand
	move.l	seed,d1
	and.l	#64-1,d1
	add.l	#32-1,d1
	move.w	d1,spr_x_cnt(a1)
.s9

	cmp.w	#27,spr_type(a1)
	bne.s	.no_pump1
	clr.w	pump_mode(a1)
	clr.w	pump_dir(a1)
	bra.s	.no_pump2
.no_pump1
	cmp.w	#28,spr_type(a1)
	bne.s	.no_pump2
	clr.w	pump_mode(a1)
	clr.w	pump_dir(a1)
.no_pump2
	cmp.w	#4,spr_type(a1)
	beq.s	.die_detect
	cmp.w	#5,spr_type(a1)
	beq.s	.die_detect
.r1
	subq.w	#1,d0
	rts

.die_detect	move.w	#-1,gun_rotate_flag(a1)
	bra.s	.r1

do_counters	subq.w	#1,homing_cnt
	tst.w	homing_cnt
	bpl.s	.home_skip
	move.w	#-1,homing_cnt
.home_skip
	subq.w	#1,bounce_fire_cnt1
	tst.w	bounce_fire_cnt1
	bpl.s	.bounce_skip1
	move.w	#-1,bounce_fire_cnt1
.bounce_skip1
	subq.w	#1,bounce_fire_cnt2
	tst.w	bounce_fire_cnt2
	bpl.s	.bounce_skip2
	move.w	#-1,bounce_fire_cnt2
.bounce_skip2
	subq.w	#1,bounce_fire_cnt3
	tst.w	bounce_fire_cnt3
	bpl.s	.bounce_skip3
	move.w	#-1,bounce_fire_cnt3
.bounce_skip3

	subq.w	#1,trace_fire_cnt2
	tst.w	trace_fire_cnt2
	bpl.s	.trace_skip2
	move.w	#-1,trace_fire_cnt2
.trace_skip2
	subq.w	#1,trace_fire_cnt3
	tst.w	trace_fire_cnt3
	bpl.s	.trace_skip3
	move.w	#-1,trace_fire_cnt3
.trace_skip3
	rts

baby_cnt	dc.w	0
baby_start_cnt	dc.w	0
baby_flag	dc.w	0
	even

do_baby	cmp.w	#8,stage
	bne	.return

	subq.w	#1,baby_start_cnt
	tst.w	baby_start_cnt
	bpl	.return
	move.w	#-1,baby_start_cnt

	subq.w	#1,baby_cnt
	tst.w	baby_cnt
	bpl	.return
	move.w	#12-1,baby_cnt

	clr.w	pop_flag1
x	set	0
	rept	num_baddies
	tst.w	pop_flag1
	bmi	.return
	lea	baddie_struct+x,a1
	move.w	status(a1),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a2
	add.w	d0,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+sprite_size
	endr

.return	rts


.tab	dc.l	.copy
	dc.l	.return
	dc.l	.return
	dc.l	.return


.copy	bsr	rand
	move.l	seed,d0
	and.l	#16-1,d0
	add.w	d0,d0
	add.w	d0,d0
	move.l	level_point,a0
	move.l	14+(4*13)(a0),a0
	addq.w	#2,a0
	add.w	d0,a0
	move.l	(a0),a0
	addq.w	#2,a0

	move.w	#-64,x1(a1)
	move.w	#-64,y1(a1)

	clr.w	spr_x_flag(a1)
	clr.w	spr_x_cnt(a1)
	clr.w	spr_y_flag(a1)
	clr.w	spr_y_cnt(a1)

	move.w	(a0)+,x_reset(a1)
	move.w	(a0)+,y_reset(a1)

	move.w	(a0)+,spr_x_move_val(a1)
	move.w	(a0)+,spr_y_move_val(a1)

	move.w	(a0)+,spr_move_mode(a1)

	move.w	(a0)+,spr_num(a1)
	move.w	(a0)+,spr_anim_val(a1)

	move.l	(a0)+,spr_ptr1(a1)

	move.w	(a0)+,spr_frames(a1)

	move.l	#baddie_die_sprites1,die_gfx(a1)
	cmp.w	#8,stage
	blt.s	.no_blue1
	move.l	#blue_baddie_die_sprites1,die_gfx(a1)
.no_blue1
	tst.w	(a0)
	beq.s	.s2
	move.l	#baddie_die_sprites2,die_gfx(a1)
.s2
	cmp.w	#-2,(a0)
	bne.s	.s8
	move.l	#big_die_sprites,die_gfx(a1)
.s8
	cmp.w	#-3,(a0)
	bne.s	.s8_a
	move.l	#blue_big_die_sprites,die_gfx(a1)
	move.l	#blue_big_die_sprites,spr_ptr1(a1)
	move.w	#-1,spr_die_flag(a1)
.s8_a


	addq.w	#2,a0

	move.w	(a0)+,die_frames(a1)

	move.l	(a0)+,spr_sin_tab(a1)
	move.l	(a0)+,spr_sin_reset(a1)

	move.l	#bad_die_sfx1+12,sample_start(a1)
	move.l	#bad_die_sfx1_end,sample_end(a1)
	tst.w	(a0)	; sfx flag
	beq.s	.s3
	move.l	#bad_die_sfx2+12,sample_start(a1)
	move.l	#bad_die_sfx2_end,sample_end(a1)
.s3	addq.w	#2,a0

	move.w	(a0)+,spr_score(a1)
	move.w	(a0)+,die_adjust_x(a1)
	move.w	(a0)+,die_adjust_y(a1)
	move.w	(a0)+,spr_energy(a1)
	move.w	(a0)+,pickup_type(a1)

	move.w	(a0)+,spr_rout_flag(a1)
; 0=blitter sprite,-1=software sprite
	tst.w	spr_rout_flag(a1)
	beq.s	.s4

;	movem.l	(a0)+,d1-d6
;	movem.l	d1-d6,spr_skew_tab(a1)

	move.l	(a0)+,spr_skew_tab(a1)
	move.l	(a0)+,spr_store_addr(a1)
	move.l	(a0)+,spr_rest_addr(a1)
	move.l	(a0)+,spr_draw_addr(a1)
	move.l	(a0)+,spr_gfx_addr(a1)
	move.l	(a0)+,spr_anim_tab(a1)


	bra.s	.s5
.s4	lea	4*6(a0),a0
.s5
	move.w	(a0)+,spr_mask_flag(a1)
	move.w	(a0)+,multi_hit_flag(a1)

	move.w	(a0)+,spr_type(a1)
	move.w	(a0)+,spr_move_cnt(a1)
	
	clr.w	hit_flag(a1)
	move.w	#-1,hit_count(a1)
	clr.w	spr_power(a1)

	move.w	#2,status(a1)	; alive
	move.w	#2,rest_cnt(a1)
	move.w	#2,die_cnt(a1)

	clr.w	spr_move_dir(a1)
	clr.w	spr_die_flag(a1)
	clr.w	spr_move_flag(a1)
	clr.w	gun_rotate_flag(a1)

	cmp.w	#9,spr_type(a1)
	bne.s	.s6

	cmp.w	#7,spr_move_mode(a1)
	bne.s	.s7
	move.w	#40-1,spr_y_cnt(a1)
	bra.s	.s6
.s7
	move.w	#9-1,spr_num(a1)
.s6

	cmp.w	#10,spr_type(a1)
	bne.s	.s9
	jsr	rand
	move.l	seed,d1
	and.l	#64-1,d1
	add.l	#32-1,d1
	move.w	d1,spr_x_cnt(a1)
.s9

	cmp.w	#4,spr_type(a1)
	beq.s	.die_detect
	cmp.w	#5,spr_type(a1)
	beq.s	.die_detect
.r1
	move.w	spr_move_cnt(a1),d1

	cmp.w	#0,scroll_cnt
	beq.s	.scroll
	add.w	#64,d1
	bra	.scroll1
.scroll
	not.w	baby_flag
	tst.w	baby_flag
	bne.s	.scroll2
	sub.w	#64+64,d1
	bra.s	.scroll1
.scroll2	add.w	#64,d1
.scroll1

	sub.w	d1,x_reset(a1)
	clr.w	spr_move_cnt(a1)

	move.w	#-1,pop_flag1
	rts


.die_detect	move.w	#-1,gun_rotate_flag(a1)
	bra.s	.r1

pause	jsr	vsync
	dbf	d0,pause
	rts

draw_anim_tiles
x	set	0
	rept	num_anim_tiles
	lea	anim_tile_struct+x,a0
	move.w	anim_tile_stat(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a1
	add.w	d0,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+anim_tile_size
	endr

.return	rts

.tab	dc.l	.return
	dc.l	.draw	; draw
	dc.l	.delete

.draw
	moveq	#0,d0
	moveq	#0,d1

	move.w	anim_tile_x(a0),d0
	move.w	d0,d1
	move.w	anim_tile_y(a0),d2

	add.w	d2,d2
	add.w	d2,d2
	lea	mul_tab,a1
	add.w	d2,a1
	move.l	(a1),d2

	move.l	anim_tile_img(a0),a1
	move.w	anim_tile_num(a0),d3
	add.w	d3,d3
	add.w	d3,a1
	move.w	(a1),d3
	move.l	anim_tile_gfx(a0),a1
	add.w	d3,a1

	move.l	screen1,a2
	add.w	word_inc,a2
	lea	(376*64)+(8*3)(a2),a2

;	move.w	scroll_offset,d3
;	and.w	#16-1,d3
;	bne.s	.no_sub
;	subq.w	#8,a2
;.no_sub
	bsr	.do_xy

	and.w	#-16,d1
	lsr.w	#1,d1

	add.w	d1,a2
	add.l	d2,a2

.b1	moveq	#-1,d0
	move.l	d0,$fffff8a28.w		; endmasks
	clr.w	$fffff8a2c.w
	clr.b	$fffff8a3d.w		; skew

	move.w	#2,$fffff8a20.w		; src x inc
	clr.w	$fffff8a22.w		; src y inc
	move.l	a1,$fffff8a24.w		; source address

	move.w	#2,$fffff8a2e.w		; dest x inc
	move.w	anim_tile_y_inc(a0),$fffff8a30.w		; dest y inc
	move.l	a2,$fffff8a32.w		; dest address

	move.b	#%10,$fffff8a3a.w		; hop
	move.b	#%0011,$fffff8a3b.w		; replace copy

	move.w	anim_tile_x_cnt(a0),$fffff8a36.w	; x cnt
	move.w	anim_tile_y_cnt(a0),$fffff8a38.w	; y cnt

	move.b	#%10000000,$fffff8a3c.w
.l1	bset	#7,$fffff8a3c.w
	nop
	bne.s	.l1
	rts

.delete	moveq	#0,d0
	moveq	#0,d1

	move.w	anim_tile_x(a0),d0
	move.w	d0,d1
	move.w	anim_tile_y(a0),d2

	add.w	d2,d2
	add.w	d2,d2
	lea	mul_tab,a1
	add.w	d2,a1
	move.l	(a1),d2

	lea	back_scrn+(376*64)+(8*3),a2

;	move.w	scroll_offset,d3
;	and.w	#16-1,d3
;	bne.s	.no_sub
;	subq.w	#8,a2
;.no_sub
	bsr	.do_xy

	and.w	#-16,d1
	lsr.w	#1,d1

	add.w	d1,a2
	add.l	d2,a2

	move.l	a2,a1

	move.l	screen1,a2
	add.w	word_inc,a2
	lea	(376*64)+(8*3)(a2),a2

;	move.w	scroll_offset,d3
;	and.w	#16-1,d3
;	bne.s	.no_sub
;	subq.w	#8,a2
;.no_sub
	bsr.s	.do_xy

	and.w	#-16,d1
	lsr.w	#1,d1

	add.w	d1,a2
	add.l	d2,a2

	subq.w	#2,anim_tile_die(a0)
	tst.w	anim_tile_die(a0)
	bpl.s	.s2
	move.w	#-1,anim_tile_die(a0)
	clr.w	anim_tile_stat(a0)
.s2	rts

.b2	moveq	#-1,d0
	move.l	d0,$fffff8a28.w		; endmasks
	clr.w	$fffff8a2c.w
	clr.b	$fffff8a3d.w		; skew

	move.w	#2,$fffff8a20.w		; src x inc
	move.w	anim_tile_y_inc(a0),$fffff8a22.w		; src y inc
	move.l	a1,$fffff8a24.w		; source address

	move.w	#2,$fffff8a2e.w		; dest x inc
	move.w	anim_tile_y_inc(a0),$fffff8a30.w		; dest y inc
	move.l	a2,$fffff8a32.w		; dest address

	move.b	#%10,$fffff8a3a.w		; hop
	move.b	#%0011,$fffff8a3b.w		; replace copy

	move.w	anim_tile_y_cnt(a0),$fffff8a36.w	; x cnt
	move.w	anim_tile_y_cnt(a0),$fffff8a38.w	; y cnt

	move.b	#%10000000,$fffff8a3c.w
.l2	bset	#7,$fffff8a3c.w
	nop
	bne.s	.l2
	rts

.do_xy	tst.w	d0
	bpl.s	.s1

	cmp.w	#-64,d0
	bgt.s	.n1
	moveq	#-64,d0
.n1
	neg.w	d0	; fix negative x coords
	moveq	#64,d1
	sub.w	d0,d1
	move.w	d1,d0
	lea	-(8*4)(a2),a2

.s1	rts

move_anim_tiles
x	set	0
	rept	num_anim_tiles
	lea	anim_tile_struct+x,a0
	move.w	anim_tile_stat(a0),d0
	add.w	d0,d0
	add.w	d0,d0
	lea	.tab(pc),a1
	add.w	d0,a1
	move.l	(a1),a1
	jsr	(a1)
x	set	x+anim_tile_size
	endr

.return	rts

.tab	dc.l	.return
	dc.l	.move	; draw
	dc.l	.return

.move	move.w	scroll_offset,d0
	and.w	#16-1,d0
	cmp.w	#0,d0
	bgt.s	.s1
	sub.w	#16,anim_tile_x(a0)
.s1
	cmp.w	#-64,anim_tile_x(a0)
	bgt.s	.e1
	move.w	#2,anim_tile_stat(a0)
.e1	rts

copy_anim_tile_waves

	move.l	level_offset,d0

	move.l	anim_tile_pos,a1
	cmp.l	#-1,a1
	beq	.return
	
;	lea	baddie_wave_tab,a1
.l1
	move.l	(a1)+,d1
	move.l	(a1)+,a0
	cmp.l	#-1,a0
	beq	.return
	
	cmp.l	d0,d1
	bne.s	.l1

;	cmp.l	#-1,a0
;	bne.s	.s1
;	lea	baddie_wave_tab,a1
;	addq.w	#4,a1	; skip map pos check
;	move.l	(a1)+,a0
;.s1
;	move.l	a1,anim_tile_pos

x	set	0
	rept	anim_tile_num
	lea	anim_tile_struct+x,a1
	move.w	status(a1),d1
	add.w	d1,d1
	add.w	d1,d1
	lea	.tab(pc),a2
	add.w	d1,a2
	move.l	(a2),a2
	jsr	(a2)
x	set	x+anim_tile_size
	endr

.return	rts

.tab	dc.l	.copy
	dc.l	.return
	dc.l	.return
	dc.l	.return

.copy	move.w	#1,anim_tile_stat(a1)
	move.w	(a0)+,anim_tile_x(a1)
	move.w	(a0)+,anim_tile_y(a1)
	move.w	(a0)+,anim_tile_num(a1)
	move.w	(a0)+,anim_tile_max(a1)
	move.w	(a0)+,anim_tile_cnt1(a1)
	move.w	(a0)+,anim_tile_cnt2(a1)
	move.w	(a0)+,anim_tile_anim(a1)

	move.l	(a0)+,anim_tile_gfx(a1)
	move.l	(a0)+,anim_tile_img(a1)

	move.w	(a0)+,anim_tile_y_inc(a1)
	move.w	(a0)+,anim_tile_x_cnt(a1)
	move.w	(a0)+,anim_tile_y_cnt(a1)

	move.w	(a0)+,anim_tile_type(a1)

	move.w	#2,anim_tile_die(a1)

	move.l	(sp)+,pop
	bra	.return

pre_shift_sprites
; skip header, data block and mask
	lea	beam_sprite1+6+32+(2*4),a0
	lea	beam_sprite1_gfx,a3
	moveq	#4-1,d2
	bsr	shift_it_2_planes_16

	lea	force_beam_sprite1+6+32+(2*4),a0
	lea	force_beam_sprite1_gfx,a3
	moveq	#4-1,d2
	bsr	shift_it_2_planes_16

	lea	force_vertical_beam_sprite1+6+32+(2*12),a0
	lea	force_vertical_beam_sprite1_gfx,a3
	moveq	#12-1,d2
	bsr	shift_it_2_planes_16

	lea	force_vertical_beam_sprite2+6+32+(2*12),a0
	lea	force_vertical_beam_sprite2_gfx,a3
	moveq	#12-1,d2
	bsr	shift_it_2_planes_16

	lea	force_diag_beam_sprite1+6+32+(2*6),a0
	lea	force_diag_beam_sprite1_gfx,a3
	moveq	#6-1,d2
	bsr	shift_it_2_planes_16

	lea	force_diag_beam_sprite2+6+32+(2*6),a0
	lea	force_diag_beam_sprite2_gfx,a3
	moveq	#6-1,d2
	bsr	shift_it_2_planes_16

	lea	big_shot_sprite2+6+32+(2*10),a0
	lea	big_shot_sprites2_gfx,a3
	moveq	#10-1,d2
	bsr	shift_it_4_planes_16

	lea	bounce_sprites+6+(32*3)+(2*3),a0
	lea	bounce_sprites_gfx1,a3
	moveq	#3-1,d2
	bsr	shift_it_2_planes_16

	lea	bounce_sprites+6+(32*3)+(2*3)+(8*3)+(2*16),a0
	lea	bounce_sprites_gfx2,a3
	moveq	#16-1,d2
	bsr	shift_it_2_planes_16

	lea	bounce_sprites+6+(32*3)+(2*3)+(8*3)+(2*16)+(8*16)+(2*16),a0
	lea	bounce_sprites_gfx3,a3
	moveq	#16-1,d2
	bsr	shift_it_2_planes_16

	bsr	shift_bullets1
	bsr	shift_rockets
	bsr	shift_homing
	bsr	shift_turrets
	bsr	shift_sperm
	bsr	shift_snake
	bsr	shift_trace
	bsr	shift_tail
	bsr	shift_tail_end
	rts

shift_rockets	lea	rocket_sprites+6+(32*16)+(2*16),a0
	lea	rocket_sprites_gfx,a3

	moveq	#16-1,d2	; sprite height

	moveq	#16-1,d3	; num sprites

.l1	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr	shift_it_4_planes_16
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	lea	(2*16)+(8*16)(a0),a0
	lea	(16*16)*16(a3),a3
	dbf	d3,.l1
	rts

shift_tail	lea	boss_tail_sprites1+6+(32*4)+(2*12),a0
	lea	boss_tail_sprites1_gfx,a3

	moveq	#12-1,d2	; sprite height

	moveq	#4-1,d3	; num sprites

.l1	move.l	d3,-(sp)
	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr	shift_it_4_planes_16
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	move.l	(sp)+,d3
	lea	(2*12)+(8*12)(a0),a0
	lea	(16*12)*16(a3),a3
	dbf	d3,.l1
	rts

shift_tail_end	lea	boss_tail_sprites2+6+(32*7)+(2*13),a0
	lea	boss_tail_sprites2_gfx,a3

	moveq	#13-1,d2	; sprite height

	moveq	#7-1,d3	; num sprites

.l1	move.l	d3,-(sp)
	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr	shift_it_4_planes_16
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	move.l	(sp)+,d3
	lea	(2*13)+(8*13)(a0),a0
	lea	(16*13)*16(a3),a3
	dbf	d3,.l1
	rts

shift_snake	lea	snake_laser+6+(32*4)+(4*4),a0
	lea	snake_sprites_gfx,a3

	moveq	#4-1,d2	; sprite height

	moveq	#4-1,d3	; num sprites

.l1	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr	shift_it_4_planes_32
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	lea	(4*4)+(16*4)(a0),a0
	lea	(24*4)*16(a3),a3
	dbf	d3,.l1
	rts


shift_it_4_planes_32
	move.l	a3,a1

	move.l	d2,d0
.l1
	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+

	clr.l	(a1)+
	clr.l	(a1)+
	dbf	d0,.l1

	move.l	a3,a0

	moveq	#15-1,d1
.l4
	move.l	a1,a2

	move.l	d2,d0
.l2	rept	24/4
	move.l	(a0)+,(a1)+
	endr
	dbf	d0,.l2

	move.l	a2,a1
	move.l	d2,d0
.l3
x	set	0
	rept	4
	roxr.w	x(a1)
	roxr.w	x+8(a1)
	roxr.w	x+16(a1)
x	set	x+2
	endr
	lea	24(a1),a1
	dbf	d0,.l3
	dbf	d1,.l4
	rts

shift_bullets1	lea	bullet_sprites+6+(32*4)+(2*6),a0
	lea	bullet_sprites_gfx,a3

	moveq	#6-1,d2	; sprite height

	moveq	#4-1,d3	; num sprites

.l1	move.l	d3,-(sp)
	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr	shift_it_4_planes_16
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	move.l	(sp)+,d3
	lea	(2*6)+(8*6)(a0),a0
	lea	(16*6)*16(a3),a3
	dbf	d3,.l1
	rts

shift_homing	lea	homing_sprites+6+(32*7)+(2*16),a0
	lea	homing_sprites_gfx,a3

	moveq	#16-1,d2	; sprite height

	moveq	#7-1,d3	; num sprites

.l1	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr	shift_it_4_planes_16
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	lea	(2*16)+(8*16)(a0),a0
	lea	(16*16)*16(a3),a3
	dbf	d3,.l1
	rts

shift_sperm	lea	sperm_sprites+6+(32*3)+(2*9),a0
	lea	sperm_sprites_gfx,a3

	moveq	#9-1,d2	; sprite height

	moveq	#3-1,d3	; num sprites

.l1	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr	shift_it_4_planes_16
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	lea	(2*9)+(8*9)(a0),a0
	lea	(16*9)*16(a3),a3
	dbf	d3,.l1
	rts

shift_turrets
	lea	gun_turret_sprites1+6+(32*6)+(2*16),a0
	lea	turret_sprites_gfx1,a3

	moveq	#16-1,d2	; sprite height

	moveq	#6-1,d3	; num sprites

.l1	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr.s	shift_it_4_planes_16
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	lea	(2*16)+(8*16)(a0),a0
	lea	(16*16)*16(a3),a3
	dbf	d3,.l1


	lea	gun_turret_sprites2+6+(32*6)+(2*16),a0
	lea	turret_sprites_gfx2,a3

	moveq	#16-1,d2	; sprite height

	moveq	#6-1,d3	; num sprites

.l2	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr.s	shift_it_4_planes_16
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	lea	(2*16)+(8*16)(a0),a0
	lea	(16*16)*16(a3),a3
	dbf	d3,.l2
	rts

shift_trace	lea	trace_sprites+6+(32*4)+(2*14),a0
	lea	trace_sprites_gfx,a3

	moveq	#14-1,d2	; sprite height

	moveq	#4-1,d3	; num sprites

.l1	move.l	a0,-(sp)
	move.l	a3,-(sp)
	bsr.s	shift_it_4_planes_16
	move.l	(sp)+,a3
	move.l	(sp)+,a0
	lea	(2*14)+(8*14)(a0),a0
	lea	(16*14)*16(a3),a3
	dbf	d3,.l1
	rts

shift_it_4_planes_16
	move.l	a3,a1

	move.l	d2,d0
.l1	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	clr.l	(a1)+
	dbf	d0,.l1

	move.l	a3,a0

	moveq	#15-1,d1
.l4
	move.l	a1,a2

	move.l	d2,d0
.l2	rept	16/4
	move.l	(a0)+,(a1)+
	endr
	dbf	d0,.l2

	move.l	a2,a1
	move.l	d2,d0
.l3
x	set	0
	rept	4
	roxr.w	x(a1)
	roxr.w	x+8(a1)
x	set	x+2
	endr
	lea	16(a1),a1
	dbf	d0,.l3
	dbf	d1,.l4
	rts

shift_it_2_planes_16
	move.l	a3,a1

	move.l	d2,d0
.l1	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	addq.w	#4,a0
	dbf	d0,.l1

	move.l	a3,a0

	moveq	#15-1,d1
.l4
	move.l	a1,a2

	move.l	d2,d0
.l2	move.l	(a0)+,(a1)+
	move.l	(a0)+,(a1)+
	dbf	d0,.l2

	move.l	a2,a1
	move.l	d2,d0
.l3
x	set	0
	rept	2
	roxr.w	x(a1)
	roxr.w	x+4(a1)
x	set	x+2
	endr
	addq.w	#8,a1
	dbf	d0,.l3
	dbf	d1,.l4

	rts

rand	move.l	d0,-(sp)
	move.l	seed,d0
	ror.l	#8,d0
	sub.w	$466+2.w,d0
	add.b	$fffff8209.w,d0
	move.l	d0,seed
	move.l	(sp)+,d0
	rts

initialise_level_data
	move.l	level_point,a0
	tst.w	12(a0)
	bne.s	.e1
	jsr	init_level
	jsr	init_anim_tiles
	jsr	init_baddie_data_blocks
	jsr	init_waves
	jsr	init_random
	move.l	level_point,a0
	move.w	#-1,12(a0)
.e1	jsr	set_up_pointers
	rts

init_random	move.l	level_point,a0
	tst.l	14+(4*13)(a0)
	bmi.s	.e1
	move.l	a0,a2
	moveq	#0,d0
	move.l	14+(4*13)(a0),a0
	move.w	(a0)+,d0
.l1	move.l	(a0),a1
	add.l	a2,a1
	move.l	a1,(a0)+
	dbf	d0,.l1
.e1	rts

init_level	move.l	level_point,a0

	lea	12+2(a0),a1	; skip header

; do the 10 offsets to map, waveforms, music etc...
	moveq	#16-1,d1
.l1	move.l	(a1),d0
	tst.l	d0
	bmi.s	.s1
	add.l	a0,d0
	move.l	d0,(a1)
.s1	addq.w	#4,a1
	dbf	d1,.l1

; do sprite offsets
	tst.l	12+2(a0)
	bmi.s	.s2
	move.l	12+2(a0),a1

	moveq	#2-1,d2
.l3	moveq	#0,d1
	move.w	(a1)+,d1
	tst.w	d1
	bmi.s	.s4
.l2	move.l	(a1),d0
	tst.l	d0
	bmi.s	.s3
	add.l	a0,d0
.s3	move.l	d0,(a1)+
	dbf	d1,.l2
.s4	dbf	d2,.l3

.s2

;
; convert wave data back to addresses
;

	lea	12+2+4(a0),a1
	move.l	(a1),a1
.l4	move.l	4(a1),d0
	cmp.l	#-1,d0
	beq.s	.e2
	add.l	a0,d0
	move.l	d0,4(a1)
	addq.w	#8,a1
	bra.s	.l4
.e2
*** restart stuff
	move.l	12+2+(4*6)(a0),a1
	move.l	12+2+(4*7)(a0),a2
.l5	move.l	2(a1),d0
	add.l	a0,d0
	move.l	d0,2(a1)
	addq.w	#8,a1
	cmp.l	a2,a1
	blt.s	.l5

	move.l	12+2+(4*6)(a0),a1
	move.l	12+2+(4*7)(a0),a2

.l6	move.l	2(a1),a3
	cmp.l	#-1,(a3)
	beq.s	.s5

.l7	move.l	(a3),d0
	add.l	a0,d0
	move.l	d0,(a3)+
	cmp.l	#-1,(a3)
	bne.s	.l7

.s5	addq.w	#8,a1
	cmp.l	a2,a1
	blt.s	.l6

.e0
	rts

set_up_pointers
	move.l	level_point,a0
*** pointers
	lea	12+2+4(a0),a1
	move.l	(a1),baddie_wave_tab_pos

	lea	12+2+(4*2)(a0),a1
	move.l	(a1),a1
	addq.w	#6,a1
	move.l	a1,map_pos

	lea	12+2+(4*3)(a0),a1
	move.l	(a1),map_end_pos

	lea	12+2+(4*6)(a0),a1
	move.l	(a1),restart_pos

	lea	12+2+(4*8)(a0),a1
	move.l	(a1),a1
	move.l	(a1),boss_offset

	lea	12+2+(4*7)(a0),a1
	move.l	(a1),restart_baddie_pos

	lea	14+(4*11)(a0),a1
	move.l	(a1),a1
	move.l	a1,anim_tile_pos

	rts

init_waves	move.l	level_point,a0
	move.l	a0,a5

	move.l	12+2+4(a0),a0

	tst.l	12+2+(4*10)(a5)
	bmi	.e1
	move.l	12+2+(4*10)(a5),a5
	addq.w	#2,a5

;	moveq	#0,d0
;	move.l	level_point,a5
;	lea	12+2(a5),a5
;	move.l	(a5),a5
;	move.w	(a5)+,d0
;	addq.w	#1,d0
;	add.w	d0,d0
;	add.w	d0,d0
;	add.l	d0,a5
;	addq.w	#2,a5



;	lea	baddie_wave_tab,a0

.l1	move.l	4(a0),a1
	cmp.l	#-1,a1
	beq.s	.e1

	moveq	#0,d0
	moveq	#0,d2

	move.w	(a1)+,d0

	move.w	d0,d2
	addq.w	#1,d2
	mulu	#70+2+2+2+2,d2
	move.l	a1,a3
	add.l	d2,a3

.l2
; init sprite address

	move.l	14(a1),d1
	add.l	d1,d1
	add.l	d1,d1

;	lea	.tab1(pc),a2
	move.l	a5,a2


	add.l	d1,a2
	move.l	(a2),14(a1)

; init sine table

	move.l	a3,a4
	add.l	24(a1),a4
	move.l	a4,24(a1)	; sinus start offset
	
	move.l	a3,a4
	add.l	28(a1),a4
	move.l	a4,28(a1)

;	move.l	a3,28(a1)	; sinus reset

; init software routine if required

	tst.w	42+2(a1)	; blitter or software?
	beq.s	.s1
	move.l	44+2(a1),d1
	add.l	d1,d1
	add.l	d1,d1
	lea	.tab2(pc),a2
	add.l	d1,a2
	move.l	(a2),a2
	jsr	(a2)
.s1

	lea	42+26+2+2+2+2+2(a1),a1
	dbf	d0,.l2

	addq.w	#8,a0
	bra.s	.l1
.e1	rts

.gun_turrets1_16x16
	movem.l	.turret_software_tab1(pc),d1-d6
	movem.l	d1-d6,44+2(a1)
	rts

.gun_turrets2_16x16
	movem.l	.turret_software_tab2(pc),d1-d6
	movem.l	d1-d6,44+2(a1)
	rts

.boss_tail1
	movem.l	.boss_tail_tab1(pc),d1-d6
	movem.l	d1-d6,44+2(a1)
	rts

.boss_tail2
	movem.l	.boss_tail_tab2(pc),d1-d6
	movem.l	d1-d6,44+2(a1)
	rts

.sperm_set
	move.l	#sperm_sprites,14(a1)

	movem.l	.sperm_tab(pc),d1-d6
	movem.l	d1-d6,44+2(a1)
	
	rts

;
; this table will need to be set-up when stage data+gfx
; are read from a file on disk.
; each entry must be the correct offset into the level file
; for a specific sprite within the stage
;
;.tab1	dc.l	red_baddie_sprites
;	dc.l	rotated_baddie_sprites
;	dc.l	gun_turret_sprites1
;	dc.l	gun_turret_sprites2
;	dc.l	baddie_pickup_sprites
;	dc.l	gun_baddie_sprites1
;	dc.l	gun_baddie_sprites2
;	dc.l	boss_weak_sprites
;	dc.l	grey_baddie_sprites1
;	dc.l	walker_sprites1
;	dc.l	walker_sprites2
;	dc.l	boss_mouth_sprites
;	dc.l	big_baddie_sprites1
;	dc.l	big_baddie_sprites2
;	dc.l	boss_tail_sprites1
;	dc.l	boss_tail_sprites2


; the following 5 tables will have to be used just for stage 1
; i.e. have a list, read the stage and use tables accordingly
; for a particular stage.
;

.tab2	dc.l	.gun_turrets1_16x16
	dc.l	.gun_turrets2_16x16
	dc.l	.boss_tail1
	dc.l	.boss_tail2

	dc.l	.sperm_set

.turret_software_tab1
	dc.l	mul_16x16_4_bpl
	dc.l	0
	dc.l	restore_16x16
	dc.l	draw_16x16_4_bpl
	dc.l	turret_sprites_gfx1
	dc.l	turret_mul_tab

.turret_software_tab2
	dc.l	mul_16x16_4_bpl
	dc.l	0
	dc.l	restore_16x16
	dc.l	draw_16x16_4_bpl
	dc.l	turret_sprites_gfx2
	dc.l	turret_mul_tab

.boss_tail_tab1	dc.l	mul_16x12_4_bpl
	dc.l	0
	dc.l	restore_16x12
	dc.l	draw_16x12_4_bpl
	dc.l	boss_tail_sprites1_gfx
	dc.l	boss_tail_mul_tab1

.boss_tail_tab2	dc.l	mul_16x13_4_bpl
	dc.l	0
	dc.l	restore_16x13
	dc.l	draw_16x13_4_bpl
	dc.l	boss_tail_sprites2_gfx
	dc.l	boss_tail_mul_tab2

.sperm_tab	dc.l	mul_16x9_4_bpl
	dc.l	0
	dc.l	restore_16x9
	dc.l	draw_16x9_4_bpl
	dc.l	sperm_sprites_gfx
	dc.l	sperm_mul_tab

;
; turn baddie sprite+mask offsets into addresses
;
init_baddie_data_blocks
	moveq	#0,d2
	move.l	level_point,a4
	lea	12+2(a4),a4
	tst.l	(a4)
	bmi.s	.e1
	move.l	(a4),a4
	move.w	(a4)+,d2
	tst.w	d2
	bmi.s	.e1
.l0	tst.l	(a4)
	bmi.s	.s1
	move.l	(a4),a0
	bsr.s	.init
.s1	addq.w	#4,a4
	dbf	d2,.l0
.e1	rts

.init	moveq	#0,d0
	moveq	#0,d1
	move.w	4(a0),d0	; num sprites
	move.w	d0,d1	; set loop

	addq.w	#1,d0
	lsl.w	#5,d0	; num sprites*32

	addq.w	#6,a0	; offset to start of block

	move.l	a0,a3
	add.w	d0,a3	; start of gfx

.l1	move.l	a3,a1	; mask
	move.l	a3,a2	; sprite
	add.l	(a0),a1	; add mask offset
	add.l	4(a0),a2	; add sprite offset
	move.l	a1,(a0)	; put mask address back
	move.l	a2,4(a0)	; put sprite address back
	lea	32(a0),a0	; next data block
	dbf	d1,.l1
	rts

anim_tile_pos	dc.l	0

init_anim_tiles	jsr	init_anim_tile_waves
	jsr	init_anim_tile_data
	rts

init_anim_tile_waves
	move.l	level_point,a0
	move.l	a0,a2
	lea	14+(4*11)(a0),a0
	move.l	(a0),a1
	cmp.l	#-1,a1
	beq.s	.e1
.l1	move.l	4(a1),d0
	cmp.l	#-1,d0
	beq.s	.e1
	add.l	a2,d0
	move.l	d0,4(a1)
	addq.w	#8,a1
	bra.s	.l1
.e1	rts

init_anim_tile_data
	move.l	level_point,a0
	move.l	a0,a1
	lea	14+(4*12)(a0),a0
	move.l	(a0),a0
	cmp.l	#-1,a0
	beq.s	.e2
	move.w	(a0)+,d0
.l1	move.l	(a0),d1
	add.l	a1,d1
	move.l	d1,(a0)+
	dbf	d0,.l1
.e1
	move.l	a1,a0

	lea	14+(4*12)(a0),a0
	move.l	(a0),a0

	move.w	(a0)+,d0
.l2	move.l	(a0)+,a2
	move.l	14(a2),d1
	add.l	a1,d1
	move.l	d1,14(a2)
	move.l	18(a2),d1
	add.l	a1,d1
	move.l	d1,18(a2)
	dbf	d0,.l2
.e2	rts

tune_num	dc.w	0

init_music	move.w	tune_num(pc),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.tab(pc,d1.w),a0

	cmp.w	#1,d0
	ble.s	.s1
	subq.w	#1,d0

.s1	jmp	(a0)

.tab	dc.l	no_music
	dc.l	init_it
	dc.l	music
	dc.l	music
	dc.l	music
	dc.l	music
	dc.l	music
	dc.l	music

play_music	tst.w	demo_mode
	bmi.s	.s1

	move.w	tune_num(pc),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.tab(pc,d1.w),a0
	jmp	(a0)

.s1	rts

.tab	dc.l	no_music
	dc.l	play_it
	dc.l	music+8	; boss
	dc.l	music+8	; comp
	dc.l	music+8	; game over
	dc.l	music+8	; name
	dc.l	music+8	; continue
	dc.l	music+8	; end of game

stop_music	move.w	tune_num(pc),d0
	move.w	d0,d1
	add.w	d1,d1
	add.w	d1,d1
	move.l	.tab(pc,d1.w),a0
	jsr	(a0)
	clr.w	tune_num
	rts

.tab	dc.l	no_music
	dc.l	stop_it
	dc.l	music+4
	dc.l	music+4
	dc.l	music+4
	dc.l	music+4
	dc.l	music+4
	dc.l	music+4

no_music	jsr	silence
	rts

init_it	move.l	level_point,a0
	lea	12+2+(4*5)(a0),a0
	move.l	(a0),a0
	jsr	(a0)
	rts

play_it	move.l	level_point,a0
	lea	12+2+(4*5)(a0),a0
	move.l	(a0),a0
	addq.w	#8,a0
	jsr	(a0)
	rts

stop_it	move.l	level_point,a0
	lea	12+2+(4*5)(a0),a0
	move.l	(a0),a0
	addq.w	#4,a0
	jsr	(a0)
	rts

set_volume	move.l	d0,-(sp)
	move.w	#%10011100101,d0	; -6db master
	bsr.s	.do_micro
	move.l	(sp)+,d0
	rts

.do_micro	move.w	sr,-(sp)
	move.w	#$2700,sr
	move.w	#%11111111111,$fffff8924.w
	move.w	d0,$fffff8922.w
.l1	cmp.w	#%11111111111,$fffff8924.w
	beq.s	.l1
	move.w	(sp)+,sr
.l2	cmp.w	#%11111111111,$fffff8924.w
	beq.s	.l2
	rts

	section	data

music	incbin	main.mus
	even
ready_gfx	incbin	ready.dat
	even
game_over_gfx	incbin	gameover.dat
	even

player_die_anim_cnt
	dc.w	0
player_die_anim
	dc.w	0,1,2,3,4,5,6
	dc.w	-1
player_die_anim_pos
	dc.l	0

original_level1_pal
	ds.w	16*4

	DC.W	0,$888,$88,$88,$880,$880,$880,$888
	DC.W	$888,$888,$888,$800,$880,$888,$888,$888

	DC.W	0,$111,$11,$11,$180,$110,$110,$111
	DC.W	$111,$111,$111,$100,$110,$111,$111,$111

	DC.W	0,$999,$99,$99,$980,$990,$990,$999
	DC.W	$999,$999,$999,$900,$990,$999,$999,$991

	DC.W	0,$222,$22,$22,$280,$220,$220,$222
	DC.W	$222,$222,$222,$200,$220,$222,$222,$221

	DC.W	0,$AAA,$AA,$AA,$A80,$A20,$AA0,$AAA
	DC.W	$A22,$AAA,$AAA,$200,$A20,$AA2,$AAA,$AA1

	DC.W	0,$333,$33,$33,$380,$320,$330,$333
	DC.W	$A22,$333,$333,$200,$320,$332,$333,$331

	DC.W	0,$BBB,$BB,$3B,$B80,$B20,$BB0,$BBB
	DC.W	$A22,$BBB,$BBB,$200,$B20,$BB2,$BBB,$BB1

	DC.W	0,$444,$44,$34,$480,$420,$440,$444
	DC.W	$A22,$444,$444,$200,$420,$442,$444,$441

	DC.W	0,$CCC,$CC,$3C,$C80,$C20,$C40,$CC4
	DC.W	$A22,$C44,$CCC,$200,$420,$C42,$CC4,$CC1

	DC.W	0,$555,$55,$35,$580,$520,$540,$554
	DC.W	$A22,$C44,$555,$200,$420,$542,$554,$551

	DC.W	0,$DDD,$DD,$35,$D80,$D20,$D40,$DD4
	DC.W	$A22,$C44,$DDD,$200,$420,$D42,$DD4,$DD1

	DC.W	0,$666,$66,$35,$680,$620,$640,$664
	DC.W	$A22,$C44,$666,$200,$420,$D42,$664,$661

	DC.W	0,$EEE,$EE,$35,$680,$E20,$E40,$EE4
	DC.W	$A22,$C44,$E66,$200,$420,$D42,$E64,$E61

	DC.W	0,$777,$77,$35,$680,$720,$740,$774
	DC.W	$A22,$C44,$E66,$200,$420,$D42,$764,$761

	DC.W	0,$FFF,$77,$35,$680,$F20,$F40,$FF4
	DC.W	$A22,$C44,$E66,$200,$420,$D42,$764,$F61

	DC.W	0,$FFF,$77,$35,$680,$F20,$F40,$FF4
	DC.W	$A22,$C44,$E66,$200,$420,$D42,$764,$F61

level1_boss_pal	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$880,$888,$888,$888
	DC.W	$888,$888,$888,$880
	DC.W	$880,$888,$888,$888
	DC.W	0,$111,$11,$11
	DC.W	$180,$111,$111,$111
	DC.W	$111,$111,$111,$110
	DC.W	$110,$111,$111,$111
	DC.W	0,$999,$99,$99
	DC.W	$980,$999,$999,$999
	DC.W	$999,$999,$999,$910
	DC.W	$990,$999,$999,$999
	DC.W	0,$222,$22,$22
	DC.W	$280,$229,$222,$222
	DC.W	$222,$222,$222,$210
	DC.W	$220,$229,$222,$222
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A80,$AA9,$AAA,$AAA
	DC.W	$A22,$AAA,$AAA,$A10
	DC.W	$A20,$AA9,$AAA,$AAA
	DC.W	0,$333,$33,$33
	DC.W	$380,$3A9,$33A,$333
	DC.W	$A22,$333,$333,$A10
	DC.W	$320,$339,$333,$333
	DC.W	0,$BBB,$BB,$3B
	DC.W	$B80,$BA9,$BBA,$BBB
	DC.W	$A22,$BBB,$BBB,$A10
	DC.W	$B20,$3B9,$BBB,$BB3
	DC.W	0,$444,$44,$34
	DC.W	$480,$4A9,$44A,$44B
	DC.W	$A22,$444,$444,$A10
	DC.W	$420,$349,$44B,$443
	DC.W	0,$CCC,$CC,$3C
	DC.W	$C80,$CA9,$C4A,$CCB
	DC.W	$A22,$C44,$CCC,$A10
	DC.W	$C20,$349,$CCB,$CC3
	DC.W	0,$555,$55,$35
	DC.W	$580,$5A9,$54A,$55B
	DC.W	$A22,$C44,$555,$A10
	DC.W	$C20,$349,$55B,$553
	DC.W	0,$DDD,$DD,$35
	DC.W	$D80,$DA9,$D4A,$DDB
	DC.W	$A22,$C44,$DDD,$A10
	DC.W	$C20,$349,$D5B,$DD3
	DC.W	0,$666,$66,$35
	DC.W	$680,$6A9,$64A,$66B
	DC.W	$A22,$C44,$666,$A10
	DC.W	$C20,$349,$65B,$D63
	DC.W	0,$EEE,$EE,$35
	DC.W	$680,$6A9,$E4A,$EEB
	DC.W	$A22,$C44,$E66,$A10
	DC.W	$C20,$349,$E5B,$D63
	DC.W	0,$777,$77,$35
	DC.W	$680,$6A9,$74A,$77B
	DC.W	$A22,$C44,$E66,$A10
	DC.W	$C20,$349,$75B,$D63
	DC.W	0,$FFF,$77,$35
	DC.W	$680,$6A9,$F4A,$FFB
	DC.W	$A22,$C44,$E66,$A10
	DC.W	$C20,$349,$F5B,$D63
	DC.W	0,$FFF,$77,$35
	DC.W	$680,$6A9,$F4A,$FFB
	DC.W	$A22,$C44,$E66,$A10
	DC.W	$C20,$349,$F5B,$D63

original_level2_pal
	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$880,$880,$880,$888
	DC.W	$888,$888,$888,$880
	DC.W	$888,$888,$888,$888
	DC.W	0,$111,$11,$11
	DC.W	$180,$110,$110,$111
	DC.W	$111,$111,$111,$110
	DC.W	$111,$111,$111,$111
	DC.W	0,$999,$99,$99
	DC.W	$980,$990,$990,$999
	DC.W	$999,$999,$999,$910
	DC.W	$999,$999,$999,$991
	DC.W	0,$222,$22,$22
	DC.W	$280,$220,$220,$222
	DC.W	$222,$222,$222,$210
	DC.W	$222,$222,$222,$221
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A80,$A20,$AA0,$AAA
	DC.W	$A22,$AAA,$AAA,$A10
	DC.W	$AA2,$AAA,$AA2,$AA1
	DC.W	0,$333,$33,$33
	DC.W	$380,$320,$330,$333
	DC.W	$A22,$333,$333,$310
	DC.W	$332,$333,$332,$331
	DC.W	0,$BBB,$BB,$3B
	DC.W	$B80,$B20,$BB0,$BBB
	DC.W	$A22,$BBB,$BBB,$310
	DC.W	$BB2,$BB3,$BB2,$3B1
	DC.W	0,$444,$44,$34
	DC.W	$480,$420,$440,$44B
	DC.W	$A22,$444,$444,$310
	DC.W	$4B2,$443,$442,$341
	DC.W	0,$CCC,$CC,$3C
	DC.W	$C80,$C20,$C40,$CCB
	DC.W	$A22,$C44,$CCC,$310
	DC.W	$CB2,$CC3,$4C2,$341
	DC.W	0,$555,$55,$35
	DC.W	$580,$520,$540,$55B
	DC.W	$A22,$C44,$555,$310
	DC.W	$CB2,$553,$452,$341
	DC.W	0,$DDD,$DD,$35
	DC.W	$D80,$D20,$D40,$DDB
	DC.W	$A22,$C44,$DDD,$310
	DC.W	$CB2,$D53,$4D2,$341
	DC.W	0,$666,$66,$35
	DC.W	$680,$620,$640,$66B
	DC.W	$A22,$C44,$666,$310
	DC.W	$CB2,$D53,$4D2,$341
	DC.W	0,$EEE,$EE,$35
	DC.W	$680,$E20,$E40,$EEB
	DC.W	$A22,$C44,$E66,$310
	DC.W	$CB2,$D53,$4D2,$341
	DC.W	0,$777,$77,$35
	DC.W	$680,$720,$740,$77B
	DC.W	$A22,$C44,$E66,$310
	DC.W	$CB2,$D53,$4D2,$341
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$F7B
	DC.W	$A22,$C44,$E66,$310
	DC.W	$CB2,$D53,$4D2,$341
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$F7B
	DC.W	$A22,$C44,$E66,$310
	DC.W	$CB2,$D53,$4D2,$341

level2_boss_pal	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$880,$880,$880,$888
	DC.W	$888,$888,$888,$880
	DC.W	$888,$888,$888,$888
	DC.W	0,$111,$11,$11
	DC.W	$180,$110,$110,$111
	DC.W	$111,$111,$111,$110
	DC.W	$111,$111,$111,$111
	DC.W	0,$999,$99,$99
	DC.W	$980,$990,$990,$999
	DC.W	$999,$999,$999,$910
	DC.W	$999,$999,$999,$999
	DC.W	0,$222,$22,$22
	DC.W	$280,$220,$220,$222
	DC.W	$222,$222,$222,$210
	DC.W	$222,$222,$222,$222
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A80,$A20,$AA0,$AAA
	DC.W	$A22,$AAA,$AAA,$A10
	DC.W	$AA2,$AAA,$AAA,$AA2
	DC.W	0,$333,$33,$33
	DC.W	$380,$320,$330,$333
	DC.W	$A22,$333,$333,$310
	DC.W	$332,$333,$333,$332
	DC.W	0,$BBB,$BB,$3B
	DC.W	$B80,$B20,$BB0,$BBB
	DC.W	$A22,$BBB,$BBB,$310
	DC.W	$BB2,$BB3,$BBB,$B32
	DC.W	0,$444,$44,$34
	DC.W	$480,$420,$440,$44B
	DC.W	$A22,$444,$444,$310
	DC.W	$4B2,$443,$4BB,$B32
	DC.W	0,$CCC,$CC,$3C
	DC.W	$C80,$C20,$C40,$CCB
	DC.W	$A22,$C44,$CCC,$310
	DC.W	$CB2,$CC3,$CBB,$B32
	DC.W	0,$555,$55,$35
	DC.W	$580,$520,$540,$55B
	DC.W	$A22,$C44,$555,$310
	DC.W	$CB2,$553,$5BB,$B32
	DC.W	0,$DDD,$DD,$35
	DC.W	$D80,$D20,$D40,$DDB
	DC.W	$A22,$C44,$DDD,$310
	DC.W	$CB2,$D53,$DBB,$B32
	DC.W	0,$666,$66,$35
	DC.W	$680,$620,$640,$66B
	DC.W	$A22,$C44,$666,$310
	DC.W	$CB2,$D53,$6BB,$B32
	DC.W	0,$EEE,$EE,$35
	DC.W	$680,$E20,$E40,$EEB
	DC.W	$A22,$C44,$E66,$310
	DC.W	$CB2,$D53,$EBB,$B32
	DC.W	0,$777,$77,$35
	DC.W	$680,$720,$740,$77B
	DC.W	$A22,$C44,$E66,$310
	DC.W	$CB2,$D53,$7BB,$B32
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$F7B
	DC.W	$A22,$C44,$E66,$310
	DC.W	$CB2,$D53,$FBB,$B32
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$F7B
	DC.W	$A22,$C44,$E66,$310
	DC.W	$CB2,$D53,$FBB,$B32

original_level3_pal
	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$800,$888,$880,$880
	DC.W	$888,$888,$888,$880
	DC.W	$888,$888,$888,$888
	DC.W	0,$111,$11,$11
	DC.W	$100,$118,$110,$110
	DC.W	$111,$111,$111,$180
	DC.W	$111,$111,$111,$111
	DC.W	0,$999,$99,$99
	DC.W	$900,$998,$990,$990
	DC.W	$999,$999,$999,$980
	DC.W	$999,$999,$999,$999
	DC.W	0,$222,$22,$22
	DC.W	$200,$228,$220,$220
	DC.W	$299,$222,$222,$280
	DC.W	$222,$222,$222,$222
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A00,$AA8,$AA0,$AA0
	DC.W	$299,$AAA,$AAA,$A80
	DC.W	$AAA,$AAA,$AAA,$AAA
	DC.W	0,$333,$33,$33
	DC.W	$300,$3A8,$330,$330
	DC.W	$299,$333,$333,$380
	DC.W	$33A,$333,$333,$333
	DC.W	0,$BBB,$BB,$3B
	DC.W	$B00,$BA8,$BB0,$BB0
	DC.W	$299,$BBB,$BBB,$B80
	DC.W	$33A,$BB3,$BBB,$BBB
	DC.W	0,$444,$44,$34
	DC.W	$400,$4A8,$440,$440
	DC.W	$299,$444,$444,$480
	DC.W	$33A,$443,$444,$444
	DC.W	0,$CCC,$CC,$3C
	DC.W	$C00,$CA8,$C40,$CC0
	DC.W	$299,$C44,$CCC,$C80
	DC.W	$33A,$443,$CC4,$CCC
	DC.W	0,$555,$55,$35
	DC.W	$500,$5A8,$540,$550
	DC.W	$299,$C44,$555,$C80
	DC.W	$33A,$443,$554,$555
	DC.W	0,$DDD,$DD,$35
	DC.W	$D00,$DA8,$D40,$DD0
	DC.W	$299,$C44,$DDD,$C80
	DC.W	$33A,$443,$554,$DDD
	DC.W	0,$666,$66,$35
	DC.W	$600,$6A8,$640,$6D0
	DC.W	$299,$C44,$666,$C80
	DC.W	$33A,$443,$554,$66D
	DC.W	0,$EEE,$EE,$35
	DC.W	$E00,$EA8,$E40,$ED0
	DC.W	$299,$C44,$666,$C80
	DC.W	$33A,$443,$554,$6ED
	DC.W	0,$777,$77,$35
	DC.W	$E00,$EA8,$740,$7D0
	DC.W	$299,$C44,$666,$C80
	DC.W	$33A,$443,$554,$6ED
	DC.W	0,$7F7,$77,$35
	DC.W	$E00,$EA8,$F40,$7D0
	DC.W	$299,$C44,$666,$C80
	DC.W	$33A,$443,$554,$6ED
	DC.W	0,$7F7,$77,$35
	DC.W	$E00,$EA8,$F40,$7D0
	DC.W	$299,$C44,$666,$C80
	DC.W	$33A,$443,$554,$6ED

original_level4_pal
	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$880,$880,$880,$888
	DC.W	$888,$888,$888,$888
	DC.W	$888,$888,$888,$888
	DC.W	0,$111,$11,$11
	DC.W	$180,$110,$110,$111
	DC.W	$111,$111,$111,$111
	DC.W	$811,$111,$111,$111
	DC.W	0,$999,$99,$99
	DC.W	$980,$990,$990,$999
	DC.W	$999,$999,$999,$911
	DC.W	$899,$999,$999,$999
	DC.W	0,$222,$22,$22
	DC.W	$280,$220,$220,$222
	DC.W	$222,$222,$222,$211
	DC.W	$829,$229,$222,$222
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A80,$A20,$AA0,$AAA
	DC.W	$A22,$AAA,$AAA,$A11
	DC.W	$8A9,$AA9,$AA2,$AAA
	DC.W	0,$333,$33,$33
	DC.W	$380,$320,$330,$33A
	DC.W	$A22,$333,$333,$311
	DC.W	$8A9,$A39,$332,$333
	DC.W	0,$BBB,$BB,$3B
	DC.W	$B80,$B20,$BB0,$BBA
	DC.W	$A22,$BBB,$BBB,$B11
	DC.W	$8A9,$AB9,$BB2,$BB3
	DC.W	0,$444,$44,$34
	DC.W	$480,$420,$440,$44A
	DC.W	$A22,$444,$444,$411
	DC.W	$8A9,$AB9,$B42,$B43
	DC.W	0,$CCC,$CC,$3C
	DC.W	$C80,$C20,$C40,$CCA
	DC.W	$A22,$C44,$CCC,$411
	DC.W	$8A9,$AB9,$BC2,$BC3
	DC.W	0,$555,$55,$35
	DC.W	$580,$520,$540,$55A
	DC.W	$A22,$C44,$555,$411
	DC.W	$8A9,$AB9,$B52,$B53
	DC.W	0,$DDD,$DD,$35
	DC.W	$D80,$D20,$D40,$DDA
	DC.W	$A22,$C44,$DDD,$411
	DC.W	$8A9,$AB9,$B52,$BD3
	DC.W	0,$666,$66,$35
	DC.W	$680,$620,$640,$66A
	DC.W	$A22,$C44,$666,$411
	DC.W	$8A9,$AB9,$B52,$B63
	DC.W	0,$EEE,$EE,$35
	DC.W	$680,$E20,$E40,$EEA
	DC.W	$A22,$C44,$E66,$411
	DC.W	$8A9,$AB9,$B52,$B63
	DC.W	0,$777,$77,$35
	DC.W	$680,$720,$740,$77A
	DC.W	$A22,$C44,$E66,$411
	DC.W	$8A9,$AB9,$B52,$B63
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$F7A
	DC.W	$A22,$C44,$E66,$411
	DC.W	$8A9,$AB9,$B52,$B63
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$F7A
	DC.W	$A22,$C44,$E66,$411
	DC.W	$8A9,$AB9,$B52,$B63

level4_boss_pal	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$880,$880,$880,$888
	DC.W	$888,$888,$888,$888
	DC.W	$808,$888,$888,$888
	DC.W	0,$111,$11,$11
	DC.W	$180,$110,$110,$111
	DC.W	$111,$111,$111,$111
	DC.W	$101,$111,$111,$111
	DC.W	0,$999,$99,$99
	DC.W	$980,$990,$990,$999
	DC.W	$999,$999,$999,$911
	DC.W	$909,$999,$999,$999
	DC.W	0,$222,$22,$22
	DC.W	$280,$220,$220,$222
	DC.W	$222,$222,$222,$211
	DC.W	$202,$222,$222,$229
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A80,$A20,$AA0,$AAA
	DC.W	$A22,$AAA,$AAA,$A11
	DC.W	$A02,$AAA,$AAA,$AA9
	DC.W	0,$333,$33,$33
	DC.W	$380,$320,$330,$33A
	DC.W	$A22,$333,$333,$311
	DC.W	$302,$3AA,$333,$339
	DC.W	0,$BBB,$BB,$3B
	DC.W	$B80,$B20,$BB0,$BBA
	DC.W	$A22,$BBB,$BBB,$B11
	DC.W	$B02,$BAA,$BBB,$BB9
	DC.W	0,$444,$44,$34
	DC.W	$480,$420,$440,$44A
	DC.W	$A22,$444,$444,$B11
	DC.W	$402,$4AA,$444,$449
	DC.W	0,$CCC,$CC,$3C
	DC.W	$C80,$C20,$C40,$CCA
	DC.W	$A22,$C44,$CCC,$B11
	DC.W	$C02,$CAA,$CCC,$CC9
	DC.W	0,$555,$55,$35
	DC.W	$580,$520,$540,$55A
	DC.W	$A22,$C44,$555,$B11
	DC.W	$502,$5AA,$555,$5C9
	DC.W	0,$DDD,$DD,$35
	DC.W	$D80,$D20,$D40,$DDA
	DC.W	$A22,$C44,$DDD,$B11
	DC.W	$D02,$DAA,$D55,$DC9
	DC.W	0,$666,$66,$35
	DC.W	$680,$620,$640,$66A
	DC.W	$A22,$C44,$666,$B11
	DC.W	$D02,$6AA,$655,$6C9
	DC.W	0,$EEE,$EE,$35
	DC.W	$680,$E20,$E40,$EEA
	DC.W	$A22,$C44,$E66,$B11
	DC.W	$D02,$6AA,$E55,$EC9
	DC.W	0,$777,$77,$35
	DC.W	$680,$720,$740,$77A
	DC.W	$A22,$C44,$E66,$B11
	DC.W	$D02,$6AA,$755,$EC9
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$F7A
	DC.W	$A22,$C44,$E66,$B11
	DC.W	$D02,$6AA,$F55,$EC9
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$F7A
	DC.W	$A22,$C44,$E66,$B11
	DC.W	$D02,$6AA,$F55,$EC9

original_level5_pal
	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$800,$888,$888,$888
	DC.W	$888,$888,$888,$888
	DC.W	$888,$888,$888,$888
	DC.W	0,$111,$11,$11
	DC.W	$100,$111,$111,$111
	DC.W	$111,$111,$111,$111
	DC.W	$111,$111,$111,$111
	DC.W	0,$999,$99,$99
	DC.W	$900,$991,$999,$999
	DC.W	$999,$999,$999,$919
	DC.W	$999,$999,$999,$999
	DC.W	0,$222,$22,$22
	DC.W	$200,$221,$229,$222
	DC.W	$222,$222,$222,$219
	DC.W	$222,$222,$222,$222
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A00,$AA1,$AA9,$AAA
	DC.W	$A22,$AAA,$AAA,$A19
	DC.W	$AAA,$AAA,$AAA,$AAA
	DC.W	0,$333,$33,$A3
	DC.W	$300,$3A1,$339,$333
	DC.W	$A22,$333,$333,$319
	DC.W	$333,$333,$333,$333
	DC.W	0,$BBB,$BB,$AB
	DC.W	$B00,$BA1,$BB9,$BBB
	DC.W	$A22,$BBB,$BBB,$319
	DC.W	$B33,$BBB,$BB3,$BBB
	DC.W	0,$444,$44,$A4
	DC.W	$400,$4A1,$449,$44B
	DC.W	$A22,$444,$444,$319
	DC.W	$433,$444,$BB3,$444
	DC.W	0,$CCC,$CC,$AC
	DC.W	$C00,$CA1,$CC9,$CCB
	DC.W	$A22,$C44,$CCC,$319
	DC.W	$C33,$CC4,$BB3,$CC4
	DC.W	0,$555,$55,$AC
	DC.W	$500,$5A1,$559,$55B
	DC.W	$A22,$C44,$555,$319
	DC.W	$533,$554,$BB3,$C54
	DC.W	0,$DDD,$DD,$AC
	DC.W	$D00,$DA1,$D59,$DDB
	DC.W	$A22,$C44,$DDD,$319
	DC.W	$533,$DD4,$BB3,$C54
	DC.W	0,$666,$66,$AC
	DC.W	$600,$6A1,$659,$66B
	DC.W	$A22,$C44,$666,$319
	DC.W	$533,$6D4,$BB3,$C54
	DC.W	0,$EEE,$EE,$AC
	DC.W	$E00,$EA1,$E59,$EEB
	DC.W	$A22,$C44,$E66,$319
	DC.W	$533,$ED4,$BB3,$C54
	DC.W	0,$777,$E7,$AC
	DC.W	$E00,$7A1,$759,$77B
	DC.W	$A22,$C44,$E66,$319
	DC.W	$533,$7D4,$BB3,$C54
	DC.W	0,$FFF,$E7,$AC
	DC.W	$E00,$7A1,$F59,$F7B
	DC.W	$A22,$C44,$E66,$319
	DC.W	$533,$7D4,$BB3,$C54
	DC.W	0,$FFF,$E7,$AC
	DC.W	$E00,$7A1,$F59,$F7B
	DC.W	$A22,$C44,$E66,$319
	DC.W	$533,$7D4,$BB3,$C54

level5_boss_pal	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$800,$888,$888,$888
	DC.W	$888,$888,$888,$888
	DC.W	$888,$888,$88,$88
	DC.W	0,$111,$11,$11
	DC.W	$100,$111,$111,$111
	DC.W	$111,$111,$111,$111
	DC.W	$111,$111,$11,$11
	DC.W	0,$999,$99,$99
	DC.W	$900,$991,$999,$999
	DC.W	$999,$999,$999,$919
	DC.W	$999,$999,$99,$99
	DC.W	0,$222,$22,$22
	DC.W	$200,$221,$229,$222
	DC.W	$222,$222,$222,$219
	DC.W	$222,$222,$22,$22
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A00,$AA1,$AA9,$AAA
	DC.W	$A22,$AAA,$AAA,$A19
	DC.W	$AAA,$AAA,$AA,$AA
	DC.W	0,$333,$33,$33
	DC.W	$300,$3A1,$339,$333
	DC.W	$A22,$333,$333,$319
	DC.W	$333,$333,$33,$33
	DC.W	0,$BBB,$BB,$3B
	DC.W	$B00,$BA1,$BB9,$BBB
	DC.W	$A22,$BBB,$BBB,$319
	DC.W	$B33,$BBB,$BB,$BB
	DC.W	0,$444,$44,$34
	DC.W	$400,$4A1,$449,$44B
	DC.W	$A22,$444,$444,$319
	DC.W	$433,$444,$BB,$44
	DC.W	0,$CCC,$CC,$3C
	DC.W	$C00,$CA1,$CC9,$CCB
	DC.W	$A22,$C44,$CCC,$319
	DC.W	$C33,$CC4,$BB,$CC
	DC.W	0,$555,$55,$35
	DC.W	$500,$5A1,$559,$55B
	DC.W	$A22,$C44,$555,$319
	DC.W	$533,$554,$BB,$55
	DC.W	0,$DDD,$DD,$35
	DC.W	$D00,$DA1,$D59,$DDB
	DC.W	$A22,$C44,$DDD,$319
	DC.W	$533,$DD4,$BB,$55
	DC.W	0,$666,$66,$35
	DC.W	$600,$6A1,$659,$66B
	DC.W	$A22,$C44,$666,$319
	DC.W	$533,$6D4,$BB,$55
	DC.W	0,$EEE,$EE,$35
	DC.W	$600,$EA1,$E59,$EEB
	DC.W	$A22,$C44,$E66,$319
	DC.W	$533,$ED4,$BB,$55
	DC.W	0,$777,$EE,$35
	DC.W	$600,$7A1,$759,$77B
	DC.W	$A22,$C44,$E66,$319
	DC.W	$533,$7D4,$BB,$55
	DC.W	0,$FFF,$EE,$35
	DC.W	$600,$7A1,$F59,$F7B
	DC.W	$A22,$C44,$E66,$319
	DC.W	$533,$7D4,$BB,$55
	DC.W	0,$FFF,$EE,$35
	DC.W	$600,$7A1,$F59,$F7B
	DC.W	$A22,$C44,$E66,$319
	DC.W	$533,$7D4,$BB,$55

original_level6_pal
	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$880,$880,$880,$888
	DC.W	$888,$888,$888,$880
	DC.W	$888,$888,$888,$888
	DC.W	0,$111,$11,$11
	DC.W	$180,$110,$110,$111
	DC.W	$111,$111,$111,$110
	DC.W	$118,$111,$811,$181
	DC.W	0,$999,$99,$99
	DC.W	$980,$990,$990,$999
	DC.W	$999,$999,$999,$990
	DC.W	$998,$999,$899,$989
	DC.W	0,$222,$22,$22
	DC.W	$280,$220,$220,$222
	DC.W	$222,$222,$222,$220
	DC.W	$228,$229,$822,$282
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A80,$A20,$AA0,$AAA
	DC.W	$A22,$AAA,$AAA,$AA0
	DC.W	$AA8,$AA9,$8AA,$A8A
	DC.W	0,$333,$33,$33
	DC.W	$380,$320,$330,$333
	DC.W	$322,$333,$333,$AA0
	DC.W	$338,$339,$833,$383
	DC.W	0,$BBB,$BB,$3B
	DC.W	$B80,$B20,$BB0,$BBB
	DC.W	$322,$BBB,$BBB,$AA0
	DC.W	$BB8,$BB9,$8BB,$B8B
	DC.W	0,$444,$44,$34
	DC.W	$480,$420,$440,$44B
	DC.W	$322,$444,$444,$AA0
	DC.W	$448,$449,$844,$484
	DC.W	0,$CCC,$CC,$3C
	DC.W	$C80,$C20,$C40,$CCB
	DC.W	$322,$C44,$CCC,$AA0
	DC.W	$448,$CC9,$8CC,$C8C
	DC.W	0,$555,$55,$35
	DC.W	$580,$520,$540,$55B
	DC.W	$322,$C44,$555,$AA0
	DC.W	$448,$559,$85C,$585
	DC.W	0,$DDD,$DD,$35
	DC.W	$D80,$D20,$D40,$DDB
	DC.W	$322,$C44,$DDD,$AA0
	DC.W	$448,$5D9,$85C,$D8D
	DC.W	0,$666,$66,$35
	DC.W	$680,$620,$640,$66B
	DC.W	$322,$C44,$666,$AA0
	DC.W	$448,$5D9,$85C,$686
	DC.W	0,$EEE,$EE,$35
	DC.W	$680,$E20,$E40,$EEB
	DC.W	$322,$C44,$E66,$AA0
	DC.W	$448,$5D9,$85C,$E8E
	DC.W	0,$777,$77,$35
	DC.W	$680,$720,$740,$77B
	DC.W	$322,$C44,$E66,$AA0
	DC.W	$448,$5D9,$85C,$787
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$FFB
	DC.W	$322,$C44,$E66,$AA0
	DC.W	$448,$5D9,$85C,$F87
	DC.W	0,$FF7,$77,$35
	DC.W	$680,$F20,$F40,$FFB
	DC.W	$322,$C44,$E66,$AA0
	DC.W	$448,$5D9,$85C,$F87

original_level7_pal
	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$880,$880,$880,$888
	DC.W	$888,$888,$888,$880
	DC.W	$880,$888,$888,$888
	DC.W	0,$111,$11,$11
	DC.W	$180,$110,$110,$111
	DC.W	$111,$111,$111,$180
	DC.W	$110,$111,$111,$111
	DC.W	0,$999,$99,$99
	DC.W	$980,$990,$990,$999
	DC.W	$999,$999,$999,$980
	DC.W	$910,$999,$999,$991
	DC.W	0,$222,$22,$22
	DC.W	$280,$220,$220,$222
	DC.W	$222,$222,$222,$280
	DC.W	$210,$222,$222,$221
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A80,$A20,$AA0,$AAA
	DC.W	$AAA,$AAA,$AAA,$A80
	DC.W	$A10,$AAA,$AAA,$AA1
	DC.W	0,$333,$33,$33
	DC.W	$380,$320,$330,$333
	DC.W	$AAA,$333,$333,$A80
	DC.W	$310,$333,$333,$331
	DC.W	0,$BBB,$BB,$3B
	DC.W	$B80,$B20,$BB0,$BB3
	DC.W	$AAA,$BBB,$BBB,$A80
	DC.W	$B10,$3B3,$BBB,$BB1
	DC.W	0,$444,$44,$34
	DC.W	$480,$420,$440,$443
	DC.W	$AAA,$444,$444,$A80
	DC.W	$B10,$343,$444,$4B1
	DC.W	0,$CCC,$CC,$3C
	DC.W	$C80,$C20,$C40,$CC3
	DC.W	$AAA,$444,$CCC,$A80
	DC.W	$B10,$343,$CCC,$CB1
	DC.W	0,$555,$55,$35
	DC.W	$580,$520,$540,$553
	DC.W	$AAA,$444,$555,$A80
	DC.W	$B10,$343,$C5C,$5B1
	DC.W	0,$DDD,$DD,$35
	DC.W	$D80,$D20,$D40,$DD3
	DC.W	$AAA,$444,$DDD,$A80
	DC.W	$B10,$343,$C5C,$DB1
	DC.W	0,$666,$66,$35
	DC.W	$680,$620,$640,$663
	DC.W	$AAA,$444,$666,$A80
	DC.W	$B10,$343,$C5C,$DB1
	DC.W	0,$EEE,$EE,$35
	DC.W	$680,$E20,$E40,$EE3
	DC.W	$AAA,$444,$666,$A80
	DC.W	$B10,$343,$C5C,$DB1
	DC.W	0,$777,$77,$35
	DC.W	$680,$720,$740,$773
	DC.W	$AAA,$444,$666,$A80
	DC.W	$B10,$343,$C5C,$DB1
	DC.W	0,$7F7,$77,$35
	DC.W	$680,$F20,$F40,$F73
	DC.W	$AAA,$444,$666,$A80
	DC.W	$B10,$343,$C5C,$DB1
	DC.W	0,$7F7,$77,$35
	DC.W	$680,$F20,$F40,$F73
	DC.W	$AAA,$444,$666,$A80
	DC.W	$B10,$343,$C5C,$DB1

original_level8_pal
	ds.w	16*4

	DC.W	0,$888,$88,$88
	DC.W	$880,$888,$888,$888
	DC.W	$888,$888,$888,$888
	DC.W	$888,$888,$888,$800
	DC.W	0,$111,$11,$11
	DC.W	$180,$111,$111,$111
	DC.W	$111,$111,$111,$811
	DC.W	$111,$111,$111,$100
	DC.W	0,$999,$99,$99
	DC.W	$980,$999,$999,$999
	DC.W	$999,$999,$999,$899
	DC.W	$999,$999,$999,$900
	DC.W	0,$222,$22,$22
	DC.W	$280,$229,$222,$222
	DC.W	$222,$222,$222,$822
	DC.W	$229,$222,$222,$200
	DC.W	0,$AAA,$AA,$AA
	DC.W	$A80,$AA9,$AA2,$AAA
	DC.W	$22A,$AAA,$AAA,$8AA
	DC.W	$AA9,$AAA,$AAA,$A00
	DC.W	0,$333,$33,$33
	DC.W	$380,$339,$332,$333
	DC.W	$22A,$333,$333,$833
	DC.W	$339,$33A,$333,$300
	DC.W	0,$BBB,$BB,$BB
	DC.W	$B80,$B39,$BB2,$BBB
	DC.W	$22A,$BBB,$BBB,$8BB
	DC.W	$339,$BBA,$BBB,$B00
	DC.W	0,$444,$44,$B4
	DC.W	$480,$439,$442,$444
	DC.W	$22A,$444,$444,$844
	DC.W	$339,$44A,$44B,$400
	DC.W	0,$CCC,$CC,$BC
	DC.W	$C80,$C39,$CC2,$CCC
	DC.W	$22A,$444,$CCC,$8CC
	DC.W	$339,$44A,$CCB,$C00
	DC.W	0,$555,$55,$BC
	DC.W	$580,$539,$552,$55C
	DC.W	$22A,$444,$555,$85C
	DC.W	$339,$44A,$55B,$500
	DC.W	0,$DDD,$DD,$BC
	DC.W	$D80,$D39,$D52,$DDC
	DC.W	$22A,$444,$DDD,$85C
	DC.W	$339,$44A,$5DB,$500
	DC.W	0,$666,$66,$BC
	DC.W	$680,$639,$652,$66C
	DC.W	$22A,$444,$DDD,$85C
	DC.W	$339,$44A,$5DB,$500
	DC.W	0,$EEE,$E6,$BC
	DC.W	$E80,$E39,$E52,$EEC
	DC.W	$22A,$444,$DDD,$85C
	DC.W	$339,$44A,$5DB,$500
	DC.W	0,$777,$76,$BC
	DC.W	$780,$739,$752,$77C
	DC.W	$22A,$444,$DDD,$85C
	DC.W	$339,$44A,$5DB,$500
	DC.W	0,$FFF,$76,$BC
	DC.W	$780,$F39,$F52,$F7C
	DC.W	$22A,$444,$DDD,$85C
	DC.W	$339,$44A,$5DB,$500
	DC.W	0,$FFF,$76,$BC
	DC.W	$780,$F39,$F52,$F7C
	DC.W	$22A,$444,$DDD,$85C
	DC.W	$339,$44A,$5DB,$500

pal_pos	dc.l	pal

pal	ds.w	(16+9)*4

	ds.w	16

	DC.W	$888,$888,$888,$888,$888,$800,$008,$008,$888	*

	ds.w	16

	dc.w	$111,$111,$111,$111,$111,$100,$001,$001,$111	*

	ds.w	16

	dc.w	$999,$999,$999,$919,$999,$900,$009,$009,$999	*

	ds.w	16

	dc.w	$222,$222,$222,$212,$222,$200,$002,$002,$222	*

	ds.w	16

	dc.w	$AAA,$AAA,$AAA,$21A,$AAA,$A00,$00A,$002,$222	*

	ds.w	16

	dc.w	$333,$333,$333,$213,$333,$300,$003,$002,$222	*

	ds.w	16

	dc.w	$BBB,$BBB,$BBB,$21B,$333,$B00,$00B,$002,$222	*

	ds.w	16

	dc.w	$444,$444,$444,$214,$333,$400,$004,$002,$222	*

	ds.w	16

	DC.W	$CCC,$C4C,$CCC,$214,$333,$C00,$00C,$002,$222	*

	ds.w	16

	dc.w	$555,$545,$555,$214,$333,$500,$005,$002,$222	*	

	ds.w	16

	dc.w	$DDD,$54D,$555,$214,$333,$D00,$00D,$002,$222	*

	ds.w	16

	dc.w	$666,$546,$555,$214,$333,$600,$006,$002,$222	*

	ds.w	16

	DC.W	$EEE,$54E,$555,$214,$333,$E00,$00E,$002,$222	*

	ds.w	16

	dc.w	$777,$547,$555,$214,$333,$700,$007,$002,$222	*

	ds.w	16

	dc.w	$777,$547,$555,$214,$333,$700,$007,$002,$222	*

pal_end	ds.w	16
	
	dc.w	$777,$547,$555,$214,$333,$700,$007,$002,$222	*

star_data	DC.W	$EA,4
	dc.w	$110-24,$94
	DC.W	$E4,$3D
	dc.w	$30,$85
	DC.W	$4B,$1F
	dc.w	$7A,$72
	DC.W	$EB,$5A
	dc.w	$41-24,$95
	DC.W	$AD,$79
	dc.w	$EE,$4F

	DC.W	$E9,$Ac
	dc.w	$C7,$69
	DC.W	$D,$3F
	dc.w	$75,$77
	DC.W	$42,$AF
	dc.w	$AA,$1B
	DC.W	$114,$22
	dc.w	$E5,$2C
	DC.W	$FC,$99
	dc.w	$28,$88

	DC.W	$CB,$81
	dc.w	$53,$A6
	DC.W	$1A,$26
	dc.w	$E9,9
	DC.W	$DE,$10
	dc.w	$1D,$1A
	DC.W	$F4,$66
	dc.w	$B9,$7A
	DC.W	$2A,$45
	dc.w	$92,$91

status_panel	ds.b	160
	incbin	status.dat
	ds.b	160*3
	even
;tiles	ds.b	512
;	incbin	level1.tle
;	incbin	boss.tle
;	even

;
; map layout:-
;
; header
; 0-3 - $16011975 - map i.d. (my data of birth)
; 4-5 - columns-1 - number of columns in the map (inc. map end column)
;
; each tile is then made up thus:
; tile number.w
;   tile flag.w - this is now either 0 or 4 for routine look-up table
;          x1.w (top left)
;          y1.w
;          x2.w (bottom right)
;          y2.w
;
; the tiles that are actially map (not blank) the x coordinates
; are set to the maximum coord (320) the y coords are set
; corretcly so I just copy the data straight into the buffer and
; then decrease all the x coords within the map buffer.
;

;map	incbin	level1.map
;map_end	even


map_pos	dc.l	0
map_end_pos	dc.l	0
map_buff_pos	dc.l	map_buff+(12*6)
	ifeq	final
screen1	dc.l	screen_ram
screen2	dc.l	screen_ram+(376*64)+(376*200)+(376*64)
	else
screen1	dc.l	(1024000*2)-(((376*64)+(376*200)+(376*64))*2)
screen2	dc.l	(1024000*2)-((376*64)+(376*200)+(376*64))
	endc
old_star_pos1	dc.l	old_star1
old_star_pos2	dc.l	old_star2
plr_speed	dc.w	2*2

;
; animation of player for intro when game starts
;
intro_tab	rept	32
	dc.w	4	; extra for music
	endr

	dc.w	4,4,4,4	;4,4,4,4
	dc.w	4,4,4,4	;4,4,4,4
	dc.w	4,4,4,4	;4,4,4,4

	dc.w	3,3,3,3	;3,3,3,3
	dc.w	3,3,3,3	;3,3,3,3

	dc.w	1,1,1,1	;1,1,1,1
	dc.w	1,1,1,1	;1,1,1,1

	ds.w	18/2

	dc.w	1,1,1,1	;1,1,1,1
	dc.w	1,1,1,1	;1,1,1,1

	dc.w	2

	dc.w	-1
intro_pos	dc.l	intro_tab

intro_x_tab
x	set	-48
	rept	32
	dc.w	x	; extra for music
	endr

x	set	-48
	rept	100/2
	dc.w	x
x	set	x+(3*2)
	endr

	dcb.w	64/2,x

	rept	116/2
	dc.w	x
x	set	x-(2*2)
	endr

	dc.w	-1



intro_x_pos	dc.l	intro_x_tab

;
; player's vertical movement table
;
plr_gfx_tab	ds.w	6
	dc.w	1,1,1,1,1,1
plr_gfx	dc.w	2
	dc.w	3,3,3,3,3,3
	dc.w	4,4,4,4,4,4
plr_gfx_end	dc.w	4
plr_gfx_pos	dc.l	plr_gfx

****************************
*** player's sprite data ***
****************************

*-------- r9 sprites --------*

player_sprites	dc.l	$16011975	; header - sprite i.d.
	dc.w	5-1	; number of sprites-1

x	set	0	; data block for each sprite
	rept	5
	dc.l	.data+x	; address of mask 
	dc.l	.data+56+x	; address sprite data
	dc.w	32	; width in pixels - 0 if no collision required
	dc.w	16*2	; width in multiples of 16
	dc.w	14	; height
	dc.w	4-1	; number of planes-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+280
	endr

.data	incbin	r9.dat	; the sprite data itself
	even

*-------- player's death sprites --------*

player_die_sprites
	dc.l	$16011975	; header - sprite i.d.
	dc.w	7-1	; number of sprites-1

x	set	0	; data block for each sprite
	dc.l	.data+x	; address of mask 
	dc.l	.data+(4*30)+x	; address sprite data
	dc.w	32	; width in pixels - 0 if no collision required
	dc.w	16*2	; width in multiples of 16
	dc.w	30	; height
	dc.w	1-1	; number of planes-1

	dc.w	4
	dc.w	0,0,0
	ds.w	4

x	set	x+600

	rept	6
	dc.l	.data+x	; address of mask 
	dc.l	.data+(4*30)+x	; address sprite data
	dc.w	32	; width in pixels - 0 if no collision required
	dc.w	16*2	; width in multiples of 16
	dc.w	30	; height
	dc.w	2-1	; number of planes-1

	dc.w	0
	dc.w	2,0,0
	ds.w	4

x	set	x+600
	endr

.data	incbin	playdie.dat	; the sprite data itself
	even

*-------- player's missiles sprites --------*

beam_sprite1	dc.l	$16011975
	dc.w	1-1

	dc.l	.data
	dc.l	.data+8
	dc.w	14
	dc.w	16*1
	dc.w	4
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

.data	

	DC.L	$FE615330,$5330FE61
	DC.L	$1160198,0
	DC.L	$A4CFA800,0
	DC.L	$A4CFA800,0
	DC.L	$1160198,0

beam_sprite2	dc.l	$16011975
	dc.w	2-1

x	set	0
	rept	2
	dc.l	.data+x
	dc.l	.data+((2*2)*12)+x
	dc.w	32
	dc.w	16*2
	dc.w	12
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+240
	endr

.data	incbin	beam2.dat
	even

beam_sprite3	dc.l	$16011975
	dc.w	2-1

x	set	0
	rept	2
	dc.l	.data+x
	dc.l	.data+((2*3)*14)+x
	dc.w	48
	dc.w	16*3
	dc.w	14
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+420
	endr

.data	incbin	beam3.dat
	even

beam_sprite4	dc.l	$16011975
	dc.w	2-1

x	set	0
	rept	2
	dc.l	.data+x
	dc.l	.data+((2*4)*14)+x
	dc.w	64
	dc.w	16*4
	dc.w	14
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+560
	endr

.data	incbin	beam4.dat
	even

beam_sprite5	dc.l	$16011975
	dc.w	2-1

x	set	0
	rept	2
	dc.l	.data+x
	dc.l	.data+((2*5)*16)+x
	dc.w	80
	dc.w	16*5
	dc.w	16
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+800
	endr

.data	incbin	beam5.dat
	even

*-------- player's add-on weapon sprites --------*

circle_laser	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+((2*4)*32)+x
	dc.w	64
	dc.w	16*4
	dc.w	32
	dc.w	3-1

	dc.w	0
	dc.w	2,2,0
	ds.w	4

x	set	x+1280
	endr

.data	incbin	circle.dat
	even

snake_laser	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+((2*2)*4)+x
	dc.w	32
	dc.w	16*2
	dc.w	4
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+80
	endr

.data	DC.L	$F83F00E1,$E0000000
	DC.L	0,$FFC0FF01
	DC.L	$7C00000,0
	DC.L	$FF1E0000,0
	DC.L	$3F1FC0,0
	DC.L	$FFFF00,0
	DC.L	$FFC0FFFF,0
	DC.L	$FF07FFF8,0
	DC.L	$3F003F,0
	DC.L	$FE00FE,0
	DC.L	$F83F00E1,$E0000000
	DC.L	0,$FFC0FF01
	DC.L	$7C0,$7C00000
	DC.L	$FF1E,$FF1E0000
	DC.L	$1FC0003F,$1FFF0000
	DC.L	$FF0700F8,$FFF80000
	DC.L	$3F0000,$FFFF0000
	DC.L	$FF0000,$FFF80000
	DC.L	0,$3F0000
	DC.L	0,$FE0000
	DC.L	$8700FC1F,7
	DC.L	0,$80FF03FF
	DC.L	$78FF0000,0
	DC.L	$3E00000,0
	DC.L	$FF0000FF,0
	DC.L	$FC0003F8,0
	DC.L	$E0FF1FFF,0
	DC.L	$3FFFFFF,0
	DC.L	$7F007F00,0
	DC.L	$FC00FC00,0
	DC.L	$8700FC1F,7
	DC.L	0,$80FF03FF
	DC.L	$78FF,$78FF0000
	DC.L	$3E0,$3E00000
	DC.L	$E0FF1F00,$1FFF0000
	DC.L	$3F8FC00,$FFF80000
	DC.L	$FF000000,$1FFF0000
	DC.L	$FC000000,$FFFF0000
	DC.L	0,$7F000000
	DC.L	0,$FC000000

*-------- player's force sprites --------*

force_low_sprites
	dc.l	$16011975
	dc.w	6-1

x	set	0
	rept	6
	dc.l	.data+x
	dc.l	.data+((2*2)*16)+x
	dc.w	20
	dc.w	16*2
	dc.w	16
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+320
	endr

.data	incbin	force1.dat
	even

force_med_sprites1
	dc.l	$16011975
	dc.w	6-1

x	set	0
	rept	6
	dc.l	.data+x
	dc.l	.data+((2*2)*22)+x
	dc.w	26
	dc.w	16*2
	dc.w	22
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((2*2)*22)+((8*2)*22)
	endr

.data	incbin	force2.dat
	even

force_med_sprites2
	dc.l	$16011975
	dc.w	6-1

x	set	0
	rept	6
	dc.l	.data+x
	dc.l	.data+((2*2)*22)+x
	dc.w	26
	dc.w	16*2
	dc.w	22
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((2*2)*22)+((8*2)*22)
	endr

.data	incbin	force3.dat
	even

force_high_sprites1
	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+((2*2)*28)+x
	dc.w	32
	dc.w	16*2
	dc.w	28
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((2*2)*28)+((8*2)*28)
	endr

.data	incbin	force4.dat
	even

force_high_sprites2
	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+((2*2)*28)+x
	dc.w	32
	dc.w	16*2
	dc.w	28
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((2*2)*28)+((8*2)*28)
	endr

.data	incbin	force5.dat
	even

force_high_sprites3
	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+((2*2)*32)+x
	dc.w	32
	dc.w	16*2
	dc.w	32
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((2*2)*32)+((8*2)*32)
	endr

.data	incbin	force6.dat
	even

*-------- player's pod sprites --------*


pod_sprites	dc.l	$16011975
	dc.w	12-1

x	set	0
	rept	12
	dc.l	.data+x
	dc.l	.data+(2*14)+x
	dc.w	16
	dc.w	16*1
	dc.w	14
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((2*14)+(8*14))
	endr

.data	incbin	orb.dat
	even

*-------- player's 'power-up' & 'jet booster' sprites --------*

power_sprites	dc.l	$16011975
	dc.w	8-1

x	set	0
	rept	8
	dc.l	.data+x
	dc.l	.data+((2*2)*32)+x
	dc.w	32
	dc.w	16*2
	dc.w	32
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+640
	endr

.data	incbin	powerup.dat
	even

boost_sprites	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+((2*2)*32)+x
	dc.w	32
	dc.w	16*2
	dc.w	32
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+640
	endr

.data	incbin	boost.dat
	even

*-------- force's beam sprites --------*

force_beam_sprite1
	dc.l	$16011975
	dc.w	1-1

	dc.l	.data
	dc.l	.data+(2*4)
	dc.w	12
	dc.w	16*1
	dc.w	4
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

.data	DC.L	$901FE00F,$E00F101F
	DC.L	$6606F80,0
	DC.L	$B301FC0,0
	DC.L	$B301FC0,0
	DC.L	$660EF80,0

force_diag_beam_sprite1
	dc.l	$16011975
	dc.w	1-1

	dc.l	.data
	dc.l	.data+(2*6)
	dc.w	6
	dc.w	16*1
	dc.w	6
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

.data	DC.L	$FF1FF00F,$100FE01F
	DC.L	$E0FF9FFF,$600080
	DC.L	0,$6300FC0
	DC.L	0,$B30EFC0
	DC.L	0,$B601F80
	DC.L	0,$6001F00
	DC.L	0,$6000
	DC.L	0

force_diag_beam_sprite2
	dc.l	$16011975
	dc.w	1-1

	dc.l	.data
	dc.l	.data+(2*6)
	dc.w	6
	dc.w	16*1
	dc.w	6
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

.data	DC.L	$9FFFE0FF,$E01F100F
	DC.L	$F00FFF1F,$6000
	DC.L	0,$6001F00
	DC.L	0,$B601F80
	DC.L	0,$B30EFC0
	DC.L	0,$6300FC0
	DC.L	0,$600080
	DC.L	0


force_vertical_beam_sprite1
	dc.l	$16011975
	dc.w	1-1

	dc.l	.data
	dc.l	.data+(2*12)
	dc.w	4
	dc.w	16*1
	dc.w	12
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

.data	DC.L	$9FFF0FFF,$FFF0FFF
	DC.L	$FFF0FFF,$FFF0FFF
	DC.L	$9FFF6FFF,$6FFF7FFF
	DC.L	$60000000,0
	DC.L	$F0000000,0
	DC.L	$90006000,0
	DC.L	$F000,0
	DC.L	$6000F000,0
	DC.L	$F000F000,0
	DC.L	$9000F000,0
	DC.L	$6000F000,0
	DC.L	$6000,0
	DC.L	$9000,0
	DC.L	$9000,0
	DC.L	$8000,0

force_vertical_beam_sprite2
	dc.l	$16011975
	dc.w	1-1

	dc.l	.data
	dc.l	.data+(2*12)
	dc.w	4
	dc.w	16*1
	dc.w	12
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

.data	DC.L	$7FFF6FFF,$6FFF9FFF
	DC.L	$FFF0FFF,$FFF0FFF
	DC.L	$FFF0FFF,$FFF9FFF
	DC.L	$8000,0
	DC.L	$9000,0
	DC.L	$9000,0
	DC.L	$6000,0
	DC.L	$6000F000,0
	DC.L	$9000F000,0
	DC.L	$F000F000,0
	DC.L	$6000F000,0
	DC.L	$F000,0
	DC.L	$90006000,0
	DC.L	$F0000000,0
	DC.L	$60000000,0

homing_sprites	dc.l	$16011975
	dc.w	7-1

x	set	0
	rept	7
	dc.l	.data
	dc.l	.data+(2*16)+x
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+160
	endr

.data	incbin	home.dat
	even

gun_turret_sprites1
	dc.l	$16011975
	dc.w	6-1

x	set	0
	rept	6
	dc.l	x
	dc.l	(2*16)+x
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+160
	endr

.data	incbin	turret1.dat
	even

gun_turret_sprites2
	dc.l	$16011975
	dc.w	6-1

x	set	0
	rept	6
	dc.l	x
	dc.l	(2*16)+x
	dc.w	16
	dc.w	16
	dc.w	16
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+160
	endr

.data	incbin	turret2.dat
	even

blue_baddie_die_sprites1
	dc.l	$16011975
	dc.w	8-1

x	set	0
	rept	8
	dc.l	.data+x
	dc.l	.data+((2*2)*32)+x
	dc.w	32
	dc.w	16*2
	dc.w	32
	dc.w	3-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+640
	endr

.data	incbin	b_bdie1.dat
	even

baddie_die_sprites1
	dc.l	$16011975
	dc.w	8-1

x	set	0
	rept	8
	dc.l	.data+x
	dc.l	.data+((2*2)*32)+x
	dc.w	32
	dc.w	16*2
	dc.w	32
	dc.w	3-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+640
	endr

.data	incbin	bdie1.dat
	even

baddie_die_sprites2
	dc.l	$16011975
	dc.w	6-1

x	set	0
	rept	6
	dc.l	.data+x
	dc.l	.data+((2*2)*32)+x
	dc.w	32
	dc.w	16*2
	dc.w	32
	dc.w	3-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+640
	endr

.data	incbin	bdie2.dat
	even

pickup_sprites	dc.l	$16011975
	dc.w	5-1

x	set	0

	dc.l	.data+x
	dc.l	.data+((2*2)*18)+x
	dc.w	24
	dc.w	16*2
	dc.w	18
	dc.w	4-1
	dc.w	0
	dc.w	2,2,2
	ds.w	4
x	set	x+360

	dc.l	.data+x
	dc.l	.data+((2*2)*18)+x
	dc.w	24
	dc.w	16*2
	dc.w	18
	dc.w	3-1
	dc.w	0
	dc.w	2,4,0
	ds.w	4
x	set	x+360

	dc.l	.data+x
	dc.l	.data+((2*2)*18)+x
	dc.w	24
	dc.w	16*2
	dc.w	18
	dc.w	4-1
	dc.w	0
	dc.w	2,2,2
	ds.w	4
x	set	x+360

	dc.l	.data+x
	dc.l	.data+((2*2)*18)+x
	dc.w	24
	dc.w	16*2
	dc.w	18
	dc.w	3-1
	dc.w	0
	dc.w	2,4,0
	ds.w	4
x	set	x+360

	dc.l	.data+x
	dc.l	.data+((2*2)*24)+x
	dc.w	24
	dc.w	16*2
	dc.w	24
	dc.w	3-1
	dc.w	0
	dc.w	2,4,0
	ds.w	4

.data	incbin	pickups.dat
	even

boss_tail_sprites1
	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+((2*1)*12)+x
	dc.w	16
	dc.w	16
	dc.w	12
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4
x	set	x+((2*12)+(8*12))
	endr

.data	incbin	tail.dat
	even

boss_tail_sprites2
	dc.l	$16011975
	dc.w	7-1

x	set	0
	rept	7
	dc.l	.data+x
	dc.l	.data+((2*1)*13)+x
	dc.w	16
	dc.w	16
	dc.w	13
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4
x	set	x+((2*13)+(8*13))
	endr

.data	incbin	tailend.dat
	even

big_die_sprites
	dc.l	$16011975
	dc.w	11-1

x	set	0
	rept	11
	dc.l	.data+x
	dc.l	.data+x+(2*4)*60)
	dc.w	64
	dc.w	16*4
	dc.w	60
	dc.w	3-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+2400
	endr

.data	incbin	bigdie.dat
	even

blue_big_die_sprites
	dc.l	$16011975
	dc.w	11-1

x	set	0
	rept	11
	dc.l	.data+x
	dc.l	.data+x+(2*4)*60)
	dc.w	64
	dc.w	16*4
	dc.w	60
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+2400
	endr

.data	incbin	b_big.dat
	even

bullet_sprites
	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+x+(2*6)
	dc.w	7
	dc.w	16
	dc.w	6
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+(2*6)+(8*6)
	endr

.data	DC.L	$C7FF83FF,$1FF01FF
	DC.L	$83FFC7FF,$10003800
	DC.L	$38000000,$38007C00
	DC.L	$7C000000,$10007C00
	DC.L	$FE000000,$3800
	DC.L	$FE000000,0
	DC.L	$7C000000,0
	DC.L	$38000000,$C7FF83FF
	DC.L	$1FF01FF,$83FFC7FF
	DC.L	0,$38000000
	DC.L	$7000,$7C000000
	DC.L	$6000F800,$FE000000
	DC.L	$6000F800,$FE000000
	DC.L	$7000,$7C000000
	DC.L	0,$38000000
	DC.L	$C7FF83FF,$1FF01FF
	DC.L	$83FFC7FF,0
	DC.L	$38000000,0
	DC.L	$7C000000,$3800
	DC.L	$FE000000,$10007C00
	DC.L	$FE000000,$38007C00
	DC.L	$7C000000,$10003800
	DC.L	$38000000,$C7FF83FF
	DC.L	$1FF01FF,$83FFC7FF
	DC.L	0,$38000000
	DC.L	$1C00,$7C000000
	DC.L	$C003E00,$FE000000
	DC.L	$C003E00,$FE000000
	DC.L	$1C00,$7C000000
	DC.L	0,$38000000

big_shot_sprite1
	dc.l	$16011975
	dc.w	2-1

x	set	0
	rept	2
	dc.l	.data+x
	dc.l	.data+((2*4)*16)+x
	dc.w	16*4
	dc.w	16*4
	dc.w	16
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+640
	endr

.data	incbin	bigshot1.dat
	even

big_shot_sprite2
	dc.l	$16011975
	dc.w	1-1

x	set	0
	rept	1
	dc.l	.data+x
	dc.l	.data+((2*4)*10)+x
	dc.w	16*1
	dc.w	16*1
	dc.w	10
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((8*10)+80)
	endr

.data	incbin	bigshot2.dat
	even

bounce_sprites	dc.l	$16011975
	dc.w	3-1

x	set	0
	dc.l	.data+x
	dc.l	.data+((2*2)*3)+x
	dc.w	16	;7
	dc.w	16*1
	dc.w	3
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((8*3)+(2*3))

	rept	2
	dc.l	.data+x
	dc.l	.data+((2*2)*3)+x
	dc.w	16	;8
	dc.w	16*1
	dc.w	16
	dc.w	2-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((8*16)+(2*16))
	endr

.data	incbin	bounce.dat
	even

trace_sprites	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+(2*14)+x
	dc.w	14
	dc.w	16
	dc.w	14
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((8*14)+(2*14))
	endr

.data	incbin	trace.dat
	even

rocket_sprites
	dc.l	$16011975
	dc.w	16-1

x	set	0
	rept	16
	dc.l	.data+x
	dc.l	.data+(2*16)+x
	dc.w	16
	dc.w	16*1
	dc.w	16
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+((2*16)+(8*16))
	endr

.data	incbin	rocket.dat
	even
*** level 2 baddies ***
sperm_sprites
	dc.l	$16011975
	dc.w	3-1

x	set	0
	rept	3
	dc.l	.data+x
	dc.l	.data+((2*1)*9)+x
	dc.w	16
	dc.w	16
	dc.w	9
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+(((2*1)*9)+((8*1)*9))
	endr

.data	incbin	sperm.dat
	even

spin_laser
	dc.l	$16011975
	dc.w	4-1

x	set	0
	rept	4
	dc.l	.data+x
	dc.l	.data+((2*3)*4)+x
	dc.w	48
	dc.w	48
	dc.w	4
	dc.w	4-1

	dc.w	0
	dc.w	2,2,2
	ds.w	4

x	set	x+(((2*3)*4)+((8*3)*4))
	endr

.data	incbin	spin_lsr.dat
	even

paused_gfx	incbin	paused.dat
	even
old_paused_pos1	dc.l	old_paused_gfx1
demo_mode_gfx	incbin	demomode.dat
	even
old_demo_pos1	dc.l	old_demo_gfx1
old_demo_pos2	dc.l	old_demo_gfx2


**************************
*** sound effects data ***
**************************

count_sfx	incbin	count.sam
count_sfx_end	even
beam_sfx1	incbin	beam1.sam
beam_sfx1_end	even
beam_sfx2	incbin	beam2.sam
beam_sfx2_end	even
power_sfx	incbin	powerup.sam
power_sfx_end	even
player_die_sfx	incbin	playdie.sam
player_die_sfx_end
	even
attach_sfx	incbin	attach.sam
attach_sfx_end	even

accept_sfx	incbin	accept.sam
accept_sfx_end	even
select_sfx	incbin	select.sam
select_sfx_end	even
circle_sfx	incbin	circle.sam
circle_sfx_end	even
bad_die_sfx1	incbin	bad_die1.sam
bad_die_sfx1_end
	even
bad_die_sfx2	incbin	bad_die2.sam
bad_die_sfx2_end
	even
pickup_sfx	incbin	pickup.sam
pickup_sfx_end	even
weak_sfx	incbin	weak.sam
weak_sfx_end	even
bounce_sfx	incbin	bounce.sam
bounce_sfx_end	even
trace_sfx	incbin	trace.sam
trace_sfx_end	even
scene_sfx	incbin	scene.sam
scene_sfx_end	even
duct_sfx	incbin	duct.sam
duct_sfx_end	even

demo_buff_pos	dc.l	demo_buff
demo_buff	incbin	demomode.tab
demo_buff_end	even

coin_flash	DC.L	$70007,$170017
	DC.L	$270027,$370037
	DC.L	$470047,$570057
	DC.L	$670067,$770077
	DC.L	$1760176,$2750275
	DC.L	$3740374,$4730473
	DC.L	$5720572,$6710671
	DC.L	$7700770,$7610761
	DC.L	$7520752,$7430743
	DC.L	$7340734,$7250725
	DC.L	$7160716,$7070707
	DC.L	$7060706,$7050705
	DC.L	$7040704,$7030703
	DC.L	$7020702,$7010701
	DC.L	$7000700,$7100710
	DC.L	$7200720,$7300730
	DC.L	$7400740,$7500750
	DC.L	$7600760,$7700770
	DC.L	$6700670,$5700570
	DC.L	$4700470,$3700370
	DC.L	$2700270,$1700170
	DC.L	$700070,$710071
	DC.L	$720072,$730073
	DC.L	$740074,$750075
	DC.L	$760076,$1770177
	DC.L	$2760276,$3750375
	DC.L	$4740474,$5730573
	DC.L	$6720672,$7710771
	DC.L	$7700770,$6700670
	DC.L	$5700570,$4700470
	DC.L	$3700370,$2700270
	DC.L	$1700170,$710071
	DC.L	$720072,$730073
	DC.L	$740074,$750075
	DC.L	$760076,$770077
	DC.L	$670067,$570057
	DC.L	$470047,$370037
	DC.L	$270027,$170017
	dc.l	-1

coin_flash_pos	dc.l	coin_flash

cont_pal	ds.w	4
	DC.W	0,$88,$888,$88
	DC.W	0,$11,$111,$11
	DC.W	0,$99,$999,$99
	DC.W	0,$22,$222,$22
	DC.W	0,$AA,$AAA,$aa
	DC.W	0,$33,$333,$33
	DC.W	0,$BB,$BBB,$bb
	DC.W	0,$44,$444,$44
	DC.W	0,$CC,$CCC,$cc
	DC.W	0,$55,$555,$55
	DC.W	0,$5D,$DDD,$5d
	DC.W	0,$56,$666,$56
	DC.W	0,$5E,$EEE,$5e
	DC.W	0,$57,$777,$57
cont_pal_end	DC.W	0,$57,$777,$57

font	DC.L	0,0,0,0,$C021C02,$18063008,$108040,$80400000,$36003600,$6C000000,0,0,$3C004200,$BD00A100,$A100BD00,$42003C00,0,0,0,0,0,0,0,0,0,0,0,0,$18001800,$30000000,0,0
	DC.L	$1C002000,$6000E000,$E0006000,$20001C00,$70000800,$C000E00,$E000C00,$8007000,0,0,0,0,$10001000,$1000FE00,$10001000,$10000000,0,0,$18001800,$30000000,0,$7C00
	DC.L	0,0,0,0,$3000,$30000000,$3000600,$C001800,$30006000,$C0000000,$FE01C221,$82418241,$82418641,$FE010000,$10081008,$10081008,$10081008,$10080000,$FE010201,$201FE01
	DC.L	$80408040,$FE010000,$FE010201,$201FE01,$2010201,$FE010000,$84428442,$84428442,$FE010402,$4020000,$FE018040,$8040FE01,$2010201,$FE010000,$FE018040,$8040FE01
	DC.L	$82418241,$FE010000,$FE010201,$2010201,$2010201,$2010000,$7C028241,$8241FE01,$82418241,$FE010000,$FE018241,$8241FE01,$2010201,$FE010000,$18001800,0,$18001800,0
	DC.L	$18001800,0,$18001800,$30000000,$4001800,$60008000,$60001800,$4000000,$6C12FE01,$FE017C02,$38041008,0,$80006000,$18000400,$18006000,$80000000,$7C02C621,$C6210C02
	DC.L	$18040000,$18040000,$E0008000,$DC009600,$F5001500,$15000600,$3E016211,$C2218241,$FE018241,$82410000,$FC028241,$8241FC02,$82418241,$FC020000,$7C02C621,$80408040
	DC.L	$8040C621,$7C020000,$F8048C42,$86418241,$86418C42,$F8040000,$FE018040,$8040F804,$80408040,$FE010000,$FE018040,$8040F804,$80408040,$80400000,$7C02C621,$80408E41
	DC.L	$8641C621,$7C020000,$82418241,$8241FE01,$82418241,$82410000,$78043008,$30083008,$30083008,$78040000,$2010201,$2010201,$8241C621,$7C020000,$82418442,$9844B048
	dc.l	$F0089844,$86410000,$80408040,$80408040,$80408040,$FE010000,$8241C621,$EE11BA45,$92498241,$82410000,$C221E211,$F209BA45,$9E418E41,$86410000,$7C02C621,$82418241
	DC.L	$8241C621,$7C020000,$FC028641,$82418641,$FC028040,$80400000,$7C02C621,$82419249,$8A45C621,$7C020000,$FC028641,$82418641,$FC029844,$86410000,$7E01C221,$8040FE01
	DC.L	$2018241,$FE010000,$FC023008,$30083008,$30083008,$30080000,$82418241,$82418241,$82418641,$FC020000,$86418E41,$9C42B844,$F008E010,$C0200000,$82419249,$9249B249
	DC.L	$BA45BA45,$CC220000,$C221E412,$78043804,$3C024E21,$86410000,$8641CC22,$78043008,$20102010,$20100000,$FE010E01,$1C023804,$7008E010,$FE010000
cheat_text	DC.B	"SELECT NEXT STAGE: 1-8",-1
	even

stage_score_tab	dc.l	stage1_score_text+6
	dc.l	stage2_score_text+6
	dc.l	stage3_score_text+6
	dc.l	stage4_score_text+6
	dc.l	stage5_score_text+6
	dc.l	stage6_score_text+6
	dc.l	stage7_score_text+6
	dc.l	stage8_score_text+6
stage_num	dc.b	"012345678"
	even
position_text	dc.b	"10"
	dc.b	"9 "
	dc.b	"8 "
	dc.b	"7 "
	dc.b	"6 "
	dc.b	"5 "
	dc.b	"4 "
	dc.b	"3 "
	dc.b	"2 "
	dc.b	"1 "
	even

;		 0123456789012345678901234567890123456789


stage_comp_text	dc.b	2,(8*2)+1,"S T A G E",2,(8*1)+1
comp_stage_score
	dc.b	" ",2,(8*1)+1,"C L E A R E D",1,3
	dc.b	2,(8*5),"STAGE SCORE",0
; column 1 drawn first
; only draw stage scores for stages that have obtained a score!
; draw stages 1-4 first (column 1) 5-8 next
; change space at end of 'stage_report_scores' to 0 to stop text print
; for unobtained stages
; draw total scores at very end
stage_report_text
	dc.b	1,3+1
	dc.b	2,(8*1),"STAGE SCORE",0
	even
	
stage_report_scores1
	dc.b	1,5+1
	DC.B	2,(8*1),"1ST STAGE ",2,(8*0)+1
stage1_score_text
	dc.b	"      ",1,2
	DC.B	2,(8*1),"2ND STAGE ",2,(8*0)+1
stage2_score_text
	dc.b	"      ",1,2
	DC.B	2,(8*1),"3RD STAGE ",2,(8*0)+1
stage3_score_text
	dc.b	"      ",1,2
	DC.B	2,(8*1),"4TH STAGE ",2,(8*0)+1
stage4_score_text
	dc.b	"      ",0
	even

stage_report_scores2
	dc.b	1,5+1
	DC.B	2,(8*11),"5TH STAGE ",2,(8*0)+1
stage5_score_text
	dc.b	"      ",1,2
	DC.B	2,(8*11),"6TH STAGE ",2,(8*0)+1
stage6_score_text
	dc.b	"      ",1,2
	DC.B	2,(8*11),"7TH STAGE ",2,(8*0)+1
stage7_score_text
	dc.b	"      ",1,2
	DC.B	2,(8*11),"8TH STAGE ",2,(8*0)+1
stage8_score_text
	dc.b	"      ",0
	even
total_score_text
	dc.b	1,14+1
	DC.B	2,(8*1),"TOTAL ",2,(8*2)+1
total	dc.b	"      ",0
	even

enter_name_text	dc.b	1,17+1
	DC.B	2,(8*3)+1,"ENTER YOUR INITIALS.",1,2
	DC.B	2,(8*6)+1,"NO."
hi_score_position_text
	dc.b	"    _ _ _ _ _ _ _",0
	even
;		 0123456789012345678901234567890123456789
cont_text	dc.b	1,2+1
	dc.b	2,(8*8),"CONTINUE",1,16
; number here!
	dc.b	2,(8*6),"PUSH FIRE BUTTON",1,2	; <- flash!
	dc.b	2,(8*7)+1,"CREDIT",2,(8*1),"0",0
	even
text_num9	dc.b	1,6+1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*9),"0000",0
	even
text_num8	dc.b	1,6+1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*9),"0000",0
	even
text_num7	dc.b	1,6+1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*10)+1,"0",1,1
	dc.b	2,(8*10),"0",1,1
	dc.b	2,(8*9)+1,"0",1,1
	dc.b	2,(8*9)+1,"0",1,1
	dc.b	2,(8*9)+1,"0",0
	even
text_num6	dc.b	1,6+1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",1,1
	dc.b	2,(8*8)+1,"0",1,1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*9),"0000",0
	even
text_num5	dc.b	1,6+1
	dc.b	2,(8*9),"00000",1,1
	dc.b	2,(8*8)+1,"0",1,1
	dc.b	2,(8*8)+1,"0",1,1
	dc.b	2,(8*8)+1,"0",1,1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*9),"0000",0
	even
text_num4	dc.b	1,6+1
	dc.b	2,(8*10),"00",1,1
	dc.b	2,(8*9)+1,"0 0",1,1
	dc.b	2,(8*9),"0",2,(8*1),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*1)+1,"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*1)+1,"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*1)+1,"0",1,1
	dc.b	2,(8*8)+1,"000000",1,1
	dc.b	2,(8*10)+1,"0",1,1
	dc.b	2,(8*10)+1,"0",0
	even
text_num3	dc.b	1,6+1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*10),"00",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*9),"0000",0
	even
text_num2	dc.b	1,6+1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*11),"0",1,1
	dc.b	2,(8*9)+1,"000",1,1
	dc.b	2,(8*9),"0",1,1
	dc.b	2,(8*8)+1,"0",1,1
	dc.b	2,(8*8)+1,"0",1,1
	dc.b	2,(8*8)+1,"000000",0
	even
text_num1	dc.b	1,6+1
	dc.b	2,(8*10),"0",1,1
	dc.b	2,(8*9)+1,"00",1,1
	dc.b	2,(8*10),"0",1,1
	dc.b	2,(8*10),"0",1,1
	dc.b	2,(8*10),"0",1,1
	dc.b	2,(8*10),"0",1,1
	dc.b	2,(8*10),"0",1,1
	dc.b	2,(8*10),"0",1,1
	dc.b	2,(8*9)+1,"000",0
	even
text_num0	dc.b	1,6+1
	dc.b	2,(8*9),"0000",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*8)+1,"0",2,(8*2),"0",1,1
	dc.b	2,(8*9),"0000",0
	even
text_num_pos	dc.l	text_num_tab
text_num_tab	dc.l	text_num9,text_num8,text_num7,text_num6
	dc.l	text_num5,text_num4,text_num3,text_num2
	dc.l	text_num1,text_num0,-1

name_font_tab	dc.l	name_font
	dc.w	"  "

x	set	8*2
y	set	"A"
	rept	26
	dc.l	name_font+x
	dc.w	y
x	set	x+(8*2)
y	set	y+1
	endr

	dc.l	name_font+x
	dc.w	" !"
x	set	x+(8*2)
	dc.l	name_font+x
	dc.w	" ?"
x	set	x+(8*2)
	dc.l	name_font+x
	dc.w	" ."
x	set	x+(8*2)
	dc.l	name_font+x
	dc.w	" ,"
x	set	x+(8*2)
	dc.l	name_font+x
	dc.w	-1	; del
x	set	x+(8*2)
	dc.l	name_font+x
	dc.w	-2	; end
name_font_tab_end

name_font	DC.L	0,0
	DC.L	0,$FCFE0000
	DC.L	$3E3F6273,$C2E382C3
	DC.L	$FEFF82C3,$82C30000
	DC.L	$FCFE82C3,$82C3FCFE
	DC.L	$82C382C3,$FCFE0000
	DC.L	$7C7EC6E7,$80C080C0
	DC.L	$80C0C6E7,$7C7E0000
	DC.L	$F8FC8CCE,$86C782C3
	DC.L	$86C78CCE,$F8FC0000
	DC.L	$FEFF80C0,$80C0F8FC
	DC.L	$80C080C0,$FEFF0000
	DC.L	$FEFF80C0,$80C0F8FC
	DC.L	$80C080C0,$80C00000
	DC.L	$7C7EC6E7,$80C08ECF
	DC.L	$86C7C6E7,$7C7E0000
	DC.L	$82C382C3,$82C3FEFF
	DC.L	$82C382C3,$82C30000
	DC.L	$787C3038,$30383038
	DC.L	$30383038,$787C0000
	DC.L	$2030203,$2030203
	DC.L	$82C3C6E7,$7C7E0000
	DC.L	$82C384C6,$98DCB0F8
	DC.L	$F0F898DC,$86C70000
	DC.L	$80C080C0,$80C080C0
	DC.L	$80C080C0,$FEFF0000
	DC.L	$82C3C6E7,$EEFFBAFF
	DC.L	$92DB82C3,$82C30000
	DC.L	$C2E3E2F3,$F2FBBAFF
	DC.L	$9EDF8ECF,$86C70000
	DC.L	$7C7EC6E7,$82C382C3
	DC.L	$82C3C6E7,$7C7E0000
	DC.L	$FCFE86C7,$82C386C7
	DC.L	$FCFE80C0,$80C00000
	DC.L	$7C7EC6E7,$82C392DB
	DC.L	$8ACFC6E7,$7C7E0000
	DC.L	$FCFE86C7,$82C386C7
	DC.L	$FCFE98DC,$86C78080
	DC.L	$7E7FC2E3,$80C0FEFF
	DC.L	$20382C3,$FEFF0000
	DC.L	$FCFE3038,$30383038
	DC.L	$30383038,$30380000
	DC.L	$82C382C3,$82C382C3
	DC.L	$82C386C7,$FCFE0000
	DC.L	$86C78ECF,$9CDEB8FC
	DC.L	$F0F8E0F0,$C0E00000
	DC.L	$82C392DB,$92DBB2FB
	DC.L	$BAFFBAFF,$CCEE0000
	DC.L	$C2E3E4F6,$787C383C
	DC.L	$3C3E4E6F,$86C70000
	DC.L	$86C7CCEE,$787C3038
	DC.L	$20302030,$20300000
	DC.L	$FEFF0E0F,$1C1E383C
	DC.L	$7078E0F0,$FEFF0000
	DC.L	$C0E1C1E,$181E3038
	DC.L	$1080C0,$80C00000
	DC.L	$7C7EC6E7,$C6E70C0E
	DC.L	$181C0000,$181C0000
	DC.L	0,0
	DC.L	$3030,$30300000
	DC.L	0,0
	DC.L	$18181818,$30300000
	DC.L	$102030,$7E7FFEFF
	DC.L	$7E7F2030,$100000
	DC.L	$E0E08080,$DCDC9696
	DC.L	$F5F51515,$15150606
name_buff_pos	dc.l	name_buff
char_tab_pos	dc.l	char_tab
stage_score_pos	dc.l	stage1_score

*** enemy attack waves ***

level_data	incbin	b:\stage4.dat
	even

baddie_wave_tab_pos
	dc.l	0

*** important game data ***
game_info
hi_name_table	ds.b	7*10
hi_score_table	ds.b	4*10
cheat_flag	ds.w	1	; -1=cheating!
hi_score_flag	ds.w	1	; -1=acheved hiscore!
hi_score_pos	ds.w	1	; for hi score flash (0=1 9=10)
num_credits	ds.w	1	; number of credits added
error_flag	ds.w	1	; forced/unforced_error
complete_flag	ds.w	1	; game completed - turn letters gold!
demo_mode	ds.w	1
set_lives	ds.w	1

soldphys	ds.l	1
soldpal	ds.w	16
soldrez	ds.b	1
soldhz	ds.b	1
sold_stack	ds.l	1
old_errors	ds.b	56
old_boot_ints	ds.b	12

difficulty	ds.w	1	; 1=hard, 6=normal, 20=easy?
diff_num	ds.w	1
stage	dc.w	4
game_init_flag	ds.w	1
level_load	ds.w	1	;0=part+stage/1=part/2=stage
*** important game data end ***

game_end

	section	bss

bss_start	ds.l	250
stack	ds.l	1	; the stack!

palbuff	ds.w	16
stat_palbuff	ds.w	9

oldphys	ds.l	1
oldpal	ds.w	16
oldrez	ds.b	1
oldhz	ds.b	1
old_stack	ds.l	1

;blank_status	ds.b	160*9
old_paused_gfx1	ds.b	(8*5)*7
old_demo_gfx1	ds.b	(8*7)*7
old_demo_gfx2	ds.b	(8*7)*7
demo_mode_cnt	ds.w	1
demo_mode_ind	ds.w	1
char_tab	ds.l	7
name_buff	ds.b	7
name_buff_end
	even
stage1_score	ds.l	1
stage2_score	ds.l	1
stage3_score	ds.l	1
stage4_score	ds.l	1
stage5_score	ds.l	1
stage6_score	ds.l	1
stage7_score	ds.l	1
stage8_score	ds.l	1
total_score	ds.l	1
hi_score	ds.l	1
lives	ds.w	1	; make 0 in final?


*******************************************
*** preshifted gfx for software sprites ***
*******************************************

snake_sprites_gfx
	ds.b	((24*4)*16)*4

turret_sprites_gfx1
	ds.b	((16*16)*16)*6

turret_sprites_gfx2
	ds.b	((16*16)*16)*6

homing_sprites_gfx
	ds.b	((16*16)*16)*7

beam_sprite1_gfx
	ds.b	(8*4)*16

force_beam_sprite1_gfx
	ds.b	(8*4)*16

force_vertical_beam_sprite1_gfx
	ds.b	(8*12)*16

force_vertical_beam_sprite2_gfx
	ds.b	(8*12)*16

force_diag_beam_sprite1_gfx
	ds.b	(8*6)*16

force_diag_beam_sprite2_gfx
	ds.b	(8*6)*16

boss_tail_sprites1_gfx
	ds.b	((16*12)*16)*4

boss_tail_sprites2_gfx
	ds.b	((16*13)*16)*7

big_shot_sprites2_gfx
	ds.b	(16*10)*16

bullet_sprites_gfx
	ds.b	((16*6)*16)*4

trace_sprites_gfx
	ds.b	((16*14)*16)*4

bounce_sprites_gfx1
	ds.b	(8*3)*16

bounce_sprites_gfx2
	ds.b	(8*16)*16

bounce_sprites_gfx3
	ds.b	(8*16)*16

rocket_sprites_gfx
	ds.b	((16*16)*16)*16

sperm_sprites_gfx
	ds.b	((16*9)*16)*3

***********************
*** data structures ***
***********************

player_struct	ds.b	sprite_size
force_struct	ds.b	sprite_size
power_struct	ds.b	sprite_size
boost_struct	ds.b	sprite_size
pod_struct1	ds.b	sprite_size
pod_struct2	ds.b	sprite_size
pickup_struct	ds.b	sprite_size*num_pickup
beam_struct	ds.b	sprite_size*num_beams
baddie_struct	ds.b	sprite_size*num_baddies
bullet_struct	ds.b	sprite_size*num_bullets
anim_tile_struct
	ds.b	anim_tile_size*num_anim_tiles

*************************************
*** buffer for map co-ord storage ***
*************************************

;	ds.b	12*12	; tile size*num tiles in column

map_buff	ds.b	((12*12)*8)*2

**********************************
*** variables+old data storage ***
**********************************

old_star1	rept	num_stars
	ds.l	3
	endr
old_star2	rept	num_stars
	ds.l	3
	endr

calculated_stars
	rept	num_stars
	ds.w	1	; bit to check
	ds.l	1	; screen address
	ds.w	1	; pixel to plot
	endr


blank_num	ds.b	8*4

bounce_coord1	ds.b	4
bounce_coord2	ds.b	8
bounce_coord3	ds.b	8

bounce_coord_cnt
	ds.w	1

player_1_cnt	ds.w	1
player_1_ind	ds.w	1

score_pos	ds.l	1
name_pos	ds.l	1
seed	ds.l	1

beam_type	ds.l	1
weapon_cnt	ds.w	1
old_blit	ds.w	1
circle_inc	ds.w	1
; 1=low,2=med,3=high
force_power	ds.w	1
; 0=beams,1=circle laser,2=bounce
weapon_type	ds.w	1
explode_cnt	ds.w	1
big_animate_cnt	ds.w	1
grey_animate_cnt
	ds.w	1
walk_animate_cnt
	ds.w	1
animate_cnt	ds.w	1
extra_life_inc	ds.w	1
restart_point	ds.w	1
tile_offset	ds.w	1
level_offset	ds.l	1

fade_rout	ds.w	1
fade_speed	ds.w	1

pod_move_table1	ds.l	4
pod_move_table2	ds.l	4
bullet_cnt	ds.w	1
bullet_cnt2	ds.w	1
blank	ds.b	4*10
map_cnt	ds.w	1
map_add	ds.w	1
fade_cnt	ds.w	1
pop	ds.l	1
pop_flag1	ds.w	1
pop_flag2	ds.w	1
pop_flag3	ds.w	1
scroll_skew	ds.w	1
num_offset	ds.w	1
count_loop	ds.w	1
count_loop2	ds.w	1
count_buff	ds.w	6
dec_buff	ds.w	6
time	ds.w	1
loop_val1	ds.w	1
loop_val2	ds.w	1
scroll_offset	ds.w	1
word_inc	ds.w	1
vbl_count	ds.w	1
scroll_cnt	ds.w	1
scroll_pause	ds.w	1
force_height_store
	ds.w	1
force_width_store
	ds.w	1
pod_cnt1	ds.w	1
pod_cnt2	ds.w	1
pick_pod_cnt	ds.w	1
power_cnt	ds.w	1
force_cnt	ds.w	1
big_beam_cnt	ds.w	1
speed_up_cnt	ds.w	1
boss_weak_cnt	ds.w	1
boss_weak_anim_cnt
	ds.w	1
chain_react_cnt	ds.w	1
chain_kill_cnt	ds.w	1
boss_explode_cnt
	ds.w	1
mouth_cnt	ds.w	1
fade_out_play_area_cnt
	ds.w	1
boss_chain_react_cnt1
	ds.w	1
boss_chain_react_cnt2
	ds.w	1
bullet_animate_cnt
	ds.w	1
gun_column_x1	ds.w	1
gun_column_x2	ds.w	1
gun_column_x3	ds.w	1
gun_column_x4	ds.w	1
homing_cnt	ds.w	1
big_shot_cnt1	ds.w	1
big_shot_cnt2	ds.w	1
big_shot_cnt3	ds.w	1
boss_shot_dec	ds.w	1
rocket_cnt	ds.w	1
rocket_cnt2	ds.w	1
bounce_fire_cnt3
	ds.w	1
bounce_fire_cnt2
	ds.w	1
bounce_fire_cnt1
	ds.w	1
level4_cnt	ds.w	1
motor_cnt	ds.w	1
bit_cnt	ds.w	1
lv5_boss_index	ds.w	1
prop_text_pos	ds.l	1
old_ints	ds.b	25

*********************
*** various flags ***
*********************

attach_sfx_flag
	ds.b	1
attached_flag	ds.b	1
force_front_rear_flag
	ds.b	1
player_dead	ds.b	1
intro_flag	ds.b	1
line_flag	ds.b	1
fire_flag	ds.b	1
ship_flag	ds.b	1
star_flag	ds.b	1
music_flag	ds.b	1
fade_flag	ds.b	1
background_flag
	ds.b	1
space_pressed_flag
	ds.b	1
space_released_flag
	ds.b	1
release_flag	ds.b	1
attach_x_flag	ds.b	1
attach_y_flag	ds.b	1
enter_name_flag	ds.b	1
force_dir	ds.b	1
force_x_flag	ds.b	1
force_y_flag	ds.b	1
;force_x_correct_flag
;	ds.b	1
;force_y_correct_flag
;	ds.b	1
force_start_x_flag
	ds.b	1
force_start_y_flag
	ds.b	1
big_beam_flag	ds.b	1
circle_laser_flag
	ds.b	1
force_offset_flag
	ds.b	1
continue_flag	ds.b	1
pause_adjust	ds.b	1
scroll_flag	ds.b	1
map_end_flag	ds.b	1
cheat_key_flag	ds.b	1
boss_tune_flag	ds.b	1
speed_up_flag	ds.b	1
stage_clear_flag
	ds.b	1
chain_react_flag
	ds.b	1
boss_weak_flag1	ds.b	1
fade_out_play_area_flag
	ds.b	1
escape_flag	ds.b	1
demo_fade_flag	ds.b	1
homing_flag	ds.b	1
circular_flag	ds.b	1
big_shot_flag	ds.b	1
bounce_coord_flag1
	ds.b	1
bounce_coord_flag2
	ds.b	1
bounce_coord_flag3
	ds.b	1
bounce_flag	ds.b	1
bounce_fx_flag	ds.b	1
trace_flag	ds.b	1
trace_fx_flag	ds.b	1
intro_done	ds.b	1
joy1_flag	ds.b	1
joy1_status	ds.b	1
joy2_flag	ds.b	1
joy2_status	ds.b	1
kbuff	ds.b	1
fire_hit	ds.b	1
paused_flag	ds.b	1
draw_score_flag	ds.b	1
force_bit	ds.b	1
detach_flag	ds.b	1
	even
back_scrn	ds.b	((376*64)*2)+(376*200)
	ds.b	256
screen_ram
bss_end 	end

