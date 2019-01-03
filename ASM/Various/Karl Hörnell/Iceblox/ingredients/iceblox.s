* Iceblox Plus for Atari ST
* Version 1.0.2

******************************** Constants

.equ SPLASH_WAIT, 250
.equ CREDITS_WAIT, 250
.equ CELEBRATION_WAIT, 450

******************************** Start of program

	jsr setup_joystick

	jsr show_splash
	jsr draw_logo

	jsr draw_credits
stapr3:	jsr setup_intro_song
	jsr draw_curtain

	jsr play_intro

	jsr setup_game

stapr1:	jsr setup_level

	jsr game_loop

	tst.w lives
	bpl stapr0
	jsr game_over
	jsr draw_logo
	bra stapr3

* Next level
stapr0: jsr clear_game_screen
	addi.w #1,level
	move.w level_bcd,d0
	move.w #1,d1
	abcd d1,d0
	move.w d0,level_bcd

	cmpi.w #16,level
	bne stapr1
* 16 levels completed
	jsr show_celebration

	bra stapr1

stapr2:	jsr restore_system

* Exit program
	clr.w	-(sp)
	trap	#1

********************** Level setup routine

setup_level:
* Set level palette
	move.w level,d0
	andi.w #14,d0
	mulu.w #16,d0
	add.l #level_palettes,d0
	move.l d0,-(sp)
	move.w #6,-(sp)
	trap #14
	addq.l #6,sp

	jsr setup_ingame_song

* Randomize
	move.w #17,-(sp)
	trap #14
	addq.l #2,sp
	add.w random_pos,d0
	andi.w #255,d0
	move.w d0,random_pos

* Copy level char data
	movea.l #level_char_data_addresses,a1
	move.w level,d0
	andi.w #14,d0
	asl.w #1,d0
	move.l (a1,d0.w),a0
	movea.l #more_characters,a1
	move.w #255,d0
sele1:	move.l (a0)+,(a1)+
	dbra.w d0,sele1

* Draw top decoration
	move.w #37,d7
sele2:	movea.l #setup_char_positions,a1
	move.b (a1,d7.w),d0
	andi.w #255,d0
	movea.l #setup_char_values,a1
	move.b (a1,d7.w),d6
	movea.l #char_map,a0
	move.b d6,(a0,d0.w)
	jsr draw_character
	dbra d7,sele2
* Copy top decoration and top brick row
	move.w #15,d1
	move.l backbuffer,a0
	movea.l a0,a1
	adda.l #16,a1
sele4:	move.w #8,d0
sele3:	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbra.w d0,sele3
	adda.l #16,a0
	adda.l #16,a1
	dbra.w d1,sele4
	move.w #15,d1
sele6:	movea.l a0,a1
	adda.l #144,a1
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	suba.l #16,a0
	suba.l #136,a1
	move.w #4,d0
sele5:	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	dbra d0,sele5
	adda.l #40,a0
	dbra d1,sele6
* Side brick extension
	movea.l backbuffer,a0
	adda.l #2560,a0
	move.l a0,a1
	move.l a0,a2
	adda.l #152,a2
	adda.l #2560,a1
	move.l a1,a3
	adda.l #152,a3
	move.w #23,d0
sele7:	move.l (a0)+,(a1)+
	move.l (a0)+,(a1)+
	move.l (a2)+,(a3)+
	move.l (a2)+,(a3)+
	adda.l #152,a0
	adda.l #152,a1
	adda.l #152,a2
	adda.l #152,a3
	dbra d0,sele7
* Copy ground and brick side
	movea.l backbuffer,a0
	adda.l #5128,a0
	move.l a0,a1
	adda.l #24,a1
	move.w #23,d0
sele9:	move.w #29,d1
sele8:	move.l (a0)+,(a1)+
	dbra.w d1,sele8
	adda.l #40,a0
	adda.l #40,a1
	dbra.w d0,sele9
* Set char values for ground
	movea.l #char_map,a1
	adda.l #202,a1
	move.w #9,d0
sele14:	move.w #11,d1
sele12:	move.b #38,(a1)+
	move.b #40,(a1)+
	move.b #41,(a1)+
	dbra.w d1,sele12
	adda.l #4,a1
	move.w #11,d1
sele13:	move.b #42,(a1)+
	move.b #44,(a1)+
	move.b #45,(a1)+
	dbra.w d1,sele13
	adda.l #4,a1
	dbra.w d0,sele14
	movea.l #char_map,a1
	adda.l #202,a1
	move.w #9,d0
sele18:	move.b #39,(a1)
	adda.l #40,a1
	move.b #43,(a1)
	adda.l #40,a1
	dbra.w d0,sele18
	movea.l #char_map,a1
	adda.l #960,a1
	move.w #9,d0
sele22:	move.l #0,(a1)+
	dbra.w d0,sele22
* Draw side shadow pixels
	move.b #37,char_map+162
	move.w #162,d0
	jsr draw_character
	move.w #202,d0
	jsr draw_character
	move.w #242,d0
	jsr draw_character
* Copy ground and sides downward
	move.l backbuffer,a0
	adda.l #6400,a0
	move.l a0,a1
	adda.l #2560,a1
	move.w #5439,d0
sele10:	move.l (a0)+,(a1)+
	dbra.w d0,sele10
* Copy bottom brick row
	move.l backbuffer,a0
	adda.l #2560,a0
	move.w #319,d0
sele11:	move.l (a0)+,(a1)+
	dbra d0,sele11
* Draw random decorations
	movea.l #level_deco,a2
	movea.l #char_map,a3
	movea.l #random_table,a4
	move.w level,d0
	andi.w #14,d0
	asl.w #2,d0
	adda.w d0,a2
	move.w #3,d2
sele15: move.b (a2)+,d3
	move.b (a2)+,d4
	tst.b d4
	beq sele16
	andi.w #255,d4
	subi.w #1,d4
sele17: move.w random_pos,d7
sele19:	move.b (a4,d7.w),d0
	andi.w #3,d0
	asl.w #8,d0
	addi.w #1,d7
	andi.w #255,d7
	or.b (a4,d7.w),d0
	addi.w #1,d7
	andi.w #255,d7
	addi.w #1,d0
	move.b (a3,d0.w),d5
	cmpi.b #38,d5
	bmi sele19
	subi.w #1,d0
	move.b (a3,d0.w),d5
	addi.w #1,d0
	cmpi.b #38,d5
	bpl sele20
	move.b d3,d6
	addi.b #1,d6
	move.b d6,(a3,d0.w)
	jmp sele21
sele20:	move.b d3,(a3,d0.w)
sele21:	jsr draw_character
	move.w d7,random_pos
	dbra.w d4,sele17
sele16:	dbra.w d2,sele15
* Set up block map
sele61:	move.w #255,d0
	movea.l #block_map,a0
sele23:	move.b #1,(a0)+
	dbra.w d0,sele23
	movea.l #block_map,a0
	adda.l #17,a0
	move.w #9,d0
sele25:	move.w #11,d1
sele24:	move.b #0,(a0)+
	dbra.w d1,sele24
	adda.l #4,a0
	dbra.w d0,sele25
	move.w #63,d0
	movea.l #block_map,a0
	movea.l #block_buf,a1
sele44:	move.l (a0)+,(a1)+
	dbra.w d0,sele44
	move.b #1,block_buf+17
	movea.l #random_table,a4
	movea.l #block_buf,a1
	move.w random_pos,d1
	move.w level,d2
	andi.w #15,d2
	movea.l #level_blocks,a2
	move.b (a2,d2.w),d0
	andi.w #255,d0
	subi.w #1,d0
sele51:	addi.w #1,d1
	andi.w #255,d1
	move.w d1,random_pos
	move.b (a4,d1.w),d2
	andi.w #255,d2
	tst.b (a1,d2.w)
	bne sele51
	move.b #1,(a1,d2.w)
	dbra.w d0,sele51
* Check if map is fully accessible
	movea.l #block_buf,a1
	movea.l #block_copy,a2
	move.w #63,d0
sele53:	move.l (a1)+,(a2)+
	dbra.w d0,sele53
	movea.l #block_copy,a2
	movea.l #tmp_buf,a3
	movea.l a3,a4
	move.b #17,(a4)+
sele55:	cmpa.l a3,a4
	beq sele54
	move.b (a3)+,d2
	andi.w #255,d2
	subi.w #16,d2
	tst.b (a2,d2.w)
	bne sele56
	move.b d2,(a4)+
	move.b #1,(a2,d2.w)
sele56: addi.w #15,d2
	tst.b (a2,d2.w)
	bne sele57
	move.b d2,(a4)+
	move.b #1,(a2,d2.w)
sele57: addi.w #2,d2
	tst.b (a2,d2.w)
	bne sele58
	move.b d2,(a4)+
	move.b #1,(a2,d2.w)
sele58: addi.w #15,d2
	tst.b (a2,d2.w)
	bne sele59
	move.b d2,(a4)+
	move.b #1,(a2,d2.w)
sele59: bra sele55
sele54:	move.b #1,d1
	move.w #200,d0
sele62:	and.b (a2)+,d1
	dbra.w d0,sele62
	tst.b d1
	beq sele61

* Place frozen coins
	movea.l #random_table,a4
	move.w random_pos,d1
	movea.l #block_buf,a1
	move.w #4,d0
sele50:	addi.w #1,d1
	andi.w #255,d1
	move.b (a4,d1.w),d2
	andi.w #255,d2
	tst.b (a1,d2.w)
	bne sele50
	move.b #3,(a1,d2.w)
	dbra.w d0,sele50
* Place ordinary ice
	movea.l #level_ice,a2
	move.w level,d2
	andi.w #15,d2
	move.b (a2,d2.w),d0
	andi.w #255,d0
	subi.w #1,d0
sele52:	addi.w #1,d1
	andi.w #255,d1
	move.b (a4,d1.w),d2
	andi.w #255,d2
	tst.b (a1,d2.w)
	bne sele52
	move.b #2,(a1,d2.w)
	dbra.w d0,sele52
sele60:	move.w d1,random_pos
	move.b #0,block_buf+17

	move.l backbuffer,current_screen
	jsr draw_score
	jsr draw_music
	jsr draw_lives

* Draw level text
	move.w level_bcd,d0
	move.w d0,d1
	andi.w #15,d1
	addi.w #48,d1
	move.b d1,level_text+7
	andi.w #240,d0
	lsr.w #4,d0
	addi.w #48,d0
	move.b d0,level_text+6
	movea.l #level_text,a0
	movea.l screenbase,a1
	adda.l #12848,a1
sele27:	move.b (a0)+,d0
	tst.b d0
	beq sele26
	movea.l #char_table,a2
	andi.w #255,d0
	move.b (a2,d0.w),d1
	andi.w #255,d1
	asl.w #4,d1
	movea.l #font,a2
	add.w d1,a2
	move.l a1,a3
	move.w #7,d0
sele28:	move.w (a2)+,(a3)
	adda.l #160,a3
	dbra d0,sele28
	adda.l #8,a1
	jmp sele27
sele26:
	move.w level,d0
	cmpi.w #16,d0
	bmi sele70
	move.w #15,d0
sele70: movea.l #levflame_types,a1
	move.l #0,(a1)
	move.w #0,d2
	movea.l #level_flames,a0
	move.b (a0,d0.w),d1
	add.b d1,d2
sele30:	tst.b d1
	beq sele29
	move.b #1,(a1)+
	subi.b #1,d1
	jmp sele30
sele29: movea.l #level_sparks,a0
	move.b (a0,d0.w),d1
	add.b d1,d2
sele32:	tst.b d1
	beq sele31
	move.b #2,(a1)+
	subi.b #1,d1
	jmp sele32
sele31: move.w d2,num_flames
	move.w #0,counter
	move.w #0,cheat_mode
	move.w #0,cheat_count
	move.w #0,previous_joy

* Animate flames
sele34:	movea.l screenbase,a1
	adda.l #15440,a1
	move.w num_flames,d0
	move.w d0,d1
	subi.w #1,d1
	asl.w #3,d0
	sub.w d0,a1
	movea.l #levflame_types,a0
sele33:	move.b (a0)+,d0
	cmpi.b #1,d0
	bne sele35
	movea.l #flame_cycle,a2
	move.w counter,d2
	andi.w #15,d2
	move.b (a2,d2.w),d0
	andi.w #255,d0
	bra sele36
sele35: move.w counter,d0
	andi.w #15,d0
	addi.w #148,d0

sele36: move.l a1,a2
	move.l #spr_offset,a3
	asl.w #2,d0
	move.l (a3,d0.w),a4
	adda.l #sprite_pixels,a4
	move.w #23,d0
sele37:	addq.l #2,a4
	move.l (a4)+,(a2)+
	move.l (a4)+,(a2)+
	addq.l #2,a4
	move.l (a4)+,(a2)+
	move.l (a4)+,(a2)+
	adda.l #144,a2
	dbra.w d0,sele37
	adda.l #16,a1
	dbra.w d1,sele33

* Check cheat code
	pea super_read_keyboard
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp
	move.w previous_joy,d1
	move.b joysticks,d0
	or.b joysticks+1,d0
	or.b joysticks+2,d0
	btst #0,d0
	beq sele45
	btst #0,d1
	bne sele45
	addi.w #1,cheat_count
sele45:	move.w d0,previous_joy
	
	jsr wait_for_vblank

	addi.w #1,counter
	move.w counter,d0
	cmpi.w #250,d0
	bne sele34

	cmpi.w #5,cheat_count
	bne sele46
	move.w #1,cheat_mode
sele46:

* Copy backbuffer to screen
	movea.l backbuffer,a0
	movea.l screenbase,a1
	move.w #7999,d0
sele38:	move.l (a0)+,(a1)+
	dbra.w d0,sele38

* Draw blocks
	move.l screenbase,current_screen
	move.w #16,counter
sele40: movea.l #block_map,a0
	movea.l #block_buf,a1
	addi.w #1,counter
	move.w counter,d0
	move.b (a1,d0.w),d1
	cmp.b (a0,d0.w),d1
	beq sele43
	move.b d1,(a0,d0.w)
	jsr draw_block
	jsr wait_for_vblank
sele43:	move.w counter,d0
	cmpi.w #255,d0
	bne sele40
* Clear coin counter
	move.w #0,coins
	rts


draw_character:
	movea.l #char_map,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	asl.w #5,d1
	move.l #character_data,a0
	adda.w d1,a0
	andi.l #1023,d0
	divu.w #40,d0
	move.w d0,d1
	mulu.w #1280,d1
	move.l d1,a1
	adda.l backbuffer,a1
	swap.w d0
	move.w d0,d1
	andi.w #1,d1
	andi.w #254,d0
	asl.w #2,d0
	add.w d1,d0
	add.w d0,a1
	move.w #7,d0
drch1:	move.b (a0)+,(a1)
	move.b (a0)+,2(a1)
	move.b (a0)+,4(a1)
	move.b (a0)+,6(a1)
	adda.l #160,a1
	dbra.w d0,drch1
	rts

draw_block:
	movea.l #block_map,a0
	move.w d0,d2
	subi.w #15,d2
	move.b (a0,d2.w),block_ne
	addi.w #16,d2
	move.b (a0,d2.w),block_e
	addi.w #14,d2
	move.b (a0,d2.w),block_sw
	move.b 1(a0,d2.w),block_s
	move.b 2(a0,d2.w),block_se
	move.w d0,d2
	andi.w #240,d2
	lsr.w #2,d2
	mulu.w #20,d2
	addi.w #79,d2
	move.w d0,d3
	andi.w #15,d3
	add.w d3,d2
	add.w d3,d2
	add.w d3,d2
	move.w d2,d5
	cmpi.b #1,d1
	bne draib1
* Stationary block
	move.w #28,d1
	jsr paint_character
	addi.w #1,d2
	move.w #29,d1
	jsr paint_character
	addi.w #1,d2
	move.w #30,d1
	jsr paint_character
	addi.w #38,d2
	move.w #31,d1
	jsr paint_character
	addi.w #1,d2
	move.w #32,d1
	jsr paint_character
	addi.w #1,d2
	move.w #33,d1
	jsr paint_character
	tst.b block_s
	bne draib3
	addi.w #38,d2
	move.w #34,d1
	tst.b block_sw
	beq draib4
	move.w #37,d1
draib4:	jsr paint_character
	addi.w #1,d2
	move.w #35,d1
	jsr paint_character
	addi.w #1,d2
	move.w #36,d1
	jsr paint_character
	jmp draib3
draib1:	cmpi.b #2,d1
	bne draib2
* Plain ice
	move.w #0,d1
	jsr paint_character
	addi.w #1,d2
	move.w #1,d1
	jsr paint_character
	addi.w #1,d2
	move.w #2,d1
	jsr paint_character
	addi.w #38,d2
	move.w #3,d1
	jsr paint_character
	addi.w #1,d2
	move.w #4,d1
	jsr paint_character
	addi.w #1,d2
	move.w #5,d1
	jsr paint_character
	tst.b block_s
	bne draib3
	addi.w #38,d2
	move.w #6,d1
	tst.b block_sw
	beq draib5
	move.w #9,d1
draib5:	jsr paint_character
	addi.w #1,d2
	move.w #7,d1
	jsr paint_character
	addi.w #1,d2
	move.w #8,d1
	jsr paint_character
	jmp draib3
* Coin ice
draib2: move.w #10,d1
	jsr paint_character
	addi.w #1,d2
	move.w #11,d1
	jsr paint_character
	addi.w #1,d2
	move.w #12,d1
	jsr paint_character
	addi.w #38,d2
	move.w #13,d1
	jsr paint_character
	addi.w #1,d2
	move.w #14,d1
	jsr paint_character
	addi.w #1,d2
	move.w #15,d1
	jsr paint_character
	tst.b block_s
	bne draib3
	addi.w #38,d2
	move.w #16,d1
	tst.b block_sw
	beq draib6
	move.w #19,d1
draib6:	jsr paint_character
	addi.w #1,d2
	move.w #17,d1
	jsr paint_character
	addi.w #1,d2
	move.w #18,d1
	jsr paint_character
* Check if we should draw shadow	
draib3: tst.b block_e
	bne draib7
	move.b block_ne,d3
	tst.b d3
	beq draib8
	move.w d5,d2
	addi.w #3,d2
	cmpi.b #1,d3
	bne draib9
	move.w #37,d1
draib9: cmpi.b #2,d3
	bne draib10
	move.w #9,d1
draib10:cmpi.b #3,d3
	bne draib11
	move.w #19,d1
draib11:jsr paint_character
draib8:	move.w d5,d2
	addi.w #43,d2
	movea.l #char_map,a0
	move.b (a0,d2.w),d1
	andi.w #255,d1
	ori.w #1,d1
	jsr paint_character
	tst.b block_se
	bne draib7
	move.w d5,d2
	addi.w #83,d2
	movea.l #char_map,a0
	move.b (a0,d2.w),d1
	andi.w #255,d1
	ori.w #1,d1
	jsr paint_character
draib7:
	rts


undraw_block:
	move.w block_clear_pos,d0
	movea.l #block_buf,a0
	move.b #0,(a0,d0.w)
	move.b -17(a0,d0.w),block_nw
	move.b -16(a0,d0.w),block_n
	move.b -15(a0,d0.w),block_ne
	move.b -1(a0,d0.w),block_w
	move.b 1(a0,d0.w),block_e
	move.b 16(a0,d0.w),block_s
	move.b 17(a0,d0.w),block_se
	move.w d0,d2
	andi.w #240,d2
	lsr.w #2,d2
	mulu.w #20,d2
	addi.w #79,d2
	move.w d0,d3
	andi.w #15,d3
	add.w d3,d2
	add.w d3,d2
	add.w d3,d2
	move.w d2,d5
	movea.l #char_map,a2
	movea.l #blocktype_chars,a3
* Top row
	tst.b block_n
	bne unbl1
	move.b (a2,d2.w),d1
	andi.w #254,d1
	tst.b block_nw
	beq unbl3
	ori.w #1,d1
unbl3:	jsr paint_character
	addi.w #1,d2
	move.b (a2,d2.w),d1
	andi.w #255,d1
	jsr paint_character
	addi.w #1,d2
	move.b (a2,d2.w),d1
	andi.w #255,d1
	jsr paint_character
	bra unbl2
unbl1:	move.b block_n,d3
	andi.w #255,d3
	move.b (a3,d3.w),d6
	andi.w #255,d6
	addi.w #6,d6
	move.w d6,d1
	tst.b block_w
	beq unbl9
	addi.w #3,d1
unbl9:	jsr paint_character
	move.w d6,d1
	addi.w #1,d1
	addi.w #1,d2
	jsr paint_character
	move.w d6,d1
	addi.w #2,d1
	addi.w #1,d2
	jsr paint_character
unbl2:	addi.w #1,d2
	tst.b block_ne
	beq unbl10
	tst.b block_e
	bne unbl10
	move.b block_ne,d3
	andi.w #255,d3
	move.b (a3,d3.w),d6
	andi.w #255,d6
	addi.w #6,d6
	move.w d6,d1
	jsr paint_character
* Middle row
unbl10:	addi.w #37,d2
	move.b (a2,d2.w),d1
	andi.w #254,d1
	tst.b block_w
	beq unbl4
	ori.w #1,d1
unbl4:	jsr paint_character
	addi.w #1,d2
	move.b (a2,d2.w),d1
	andi.w #255,d1
	jsr paint_character
	addi.w #1,d2
	move.b (a2,d2.w),d1
	andi.w #255,d1
	jsr paint_character
	addi.w #1,d2
	tst.b block_e
	bne unbl5
	move.b (a2,d2.w),d1
	andi.w #255,d1
	jsr paint_character
* Bottom row
unbl5:	tst.b block_s
	bne unbl6
	addi.w #37,d2
	move.b (a2,d2.w),d1
	andi.w #254,d1
	tst.b block_w
	beq unbl7
	ori.w #1,d1
unbl7:	jsr paint_character
	addi.w #1,d2
	move.b (a2,d2.w),d1
	andi.w #255,d1
	jsr paint_character
	addi.w #1,d2
	move.b (a2,d2.w),d1
	andi.w #255,d1
	jsr paint_character
unbl6:	tst.b block_e
	bne unbl8
	tst.b block_se
	bne unbl8
	move.w d5,d2
	addi.w #83,d2
	move.b (a2,d2.w),d1
	andi.w #255,d1
	jsr paint_character
unbl8:	rts


paint_character:
	asl.w #5,d1
	move.l #character_data,a0
	adda.w d1,a0
	move.w d2,d3
	andi.l #1023,d3
	divu.w #40,d3
	move.w d3,d4
	mulu.w #1280,d4
	move.l d4,a1
	adda.l current_screen,a1
	swap.w d3
	move.w d3,d4
	andi.w #1,d4
	andi.w #254,d3
	asl.w #2,d3
	add.w d4,d3
	add.w d3,a1
	move.w #7,d3
paich1:	move.b (a0)+,(a1)
	move.b (a0)+,2(a1)
	move.b (a0)+,4(a1)
	move.b (a0)+,6(a1)
	adda.l #160,a1
	dbra.w d3,paich1
	rts


********************** Game loop

game_loop:
* Copy main screen pixels to offscreen buffers
	movea.l screenbase,a0
	movea.l backbuffer,a1
	move.w #7999,d0
glop1:	move.l (a0)+,(a1)+
	dbra.w d0,glop1
	
* Reset penguin variables
	move.w #17,pPos
	move.w #16,pBaseX
	move.w #29,pBaseY
	move.w #0,pDx
	move.w #0,pDy
	move.w #0,pDir
	move.w #0,pState
	move.w #27,pLook
	move.w #0,pBarrierHeight

* Set up restore buffers
	movea.l #restore_buf,a0
	move.w #0,(a0)+
	move.l a0,restore_pointer1
	movea.l #restore_buf2,a0
	move.w #0,(a0)+
	move.l a0,restore_pointer2

	move.w #0,counter
	move.l screenbase,current_screen

* Reset flame data
	move.w level,d0
	cmpi.w #16,d0
	bmi glop0
	move.w #15,d0
glop0:	movea.l #level_flames,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	move.w d1,max_flames
	move.b 16(a0,d0.w),d1
	andi.w #255,d1
	move.w d1,max_sparks
	move.w #0,num_flames
	move.w #0,num_sparks
	move.w #0,flame_data
	move.w #0,flame_data+18
	move.w #0,flame_data+36
	move.w #0,flame_data+54

* Start of actual loop
glop2:
* Restore pixels
	move.w counter,d0
	btst #0,d0
	bne glop30
	move.l restore_pointer1,restore_pointer
	bra glop31
glop30: move.l restore_pointer2,restore_pointer
glop31: jsr restore_pixels

* Clear sprite draw data
	movea.l #sprite_draw_data,a0
	move.w #5,d0
glopc0:	move.l #0,(a0)
	adda.l #20,a0
	dbra.w d0,glopc0

* Pete
	tst.w pState
	bne glop14
* Check if all coins collected
	cmpi.w #5,coins
	bne glop99
	move.w #0,iCounter
	move.w #1,pState
	move.w #6,new_sound
	bra glop14
* Joystick control
glop99:	tst.w pDir
	bne glop6
	pea super_read_keyboard
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp
	move.b joysticks,d0
	or.b joysticks+1,d0
	or.b joysticks+2,d0
	movea.l #block_map,a0
	move.w pPos,d1
	btst #0,d0
	beq glop7
* Joystick up
	tst.b -16(a0,d1.w)
	beq glop54
	move.b -16(a0,d1.w),d2
	andi.b #2,d2
	beq glop7
	tst.w iState
	bne glop7
	move.w #1,d0
	jsr push_ice
	bra glop6
glop54:	move.w #1,pDir
	move.w #12,pDy
	subi.w #16,pPos
	subi.w #16,pBaseY
	jmp glop10
glop7:	btst #1,d0
	beq glop8
* Joystick down
	tst.b 16(a0,d1.w)
	beq glop93
	move.b 16(a0,d1.w),d2
	andi.b #2,d2
	beq glop8
	tst.w iState
	bne glop8
	move.w #2,d0
	jsr push_ice
	bra glop6
glop93:	move.w #2,pDir
	move.w #0,pDy
	jmp glop10
glop8:	btst #2,d0
	beq glop9
* Joystick left
	tst.b -1(a0,d1.w)
	beq glop94
	move.b -1(a0,d1.w),d2
	andi.b #2,d2
	beq glop9
	tst.w iState
	bne glop9
	move.w #3,d0
	jsr push_ice
	bra glop6
glop94:	move.w #3,pDir
	move.w #18,pDx
	subi.w #1,pPos
	subi.w #24,pBaseX
	jmp glop10
glop9:	btst #3,d0
	beq glop10
* Joystick right
	tst.b 1(a0,d1.w)
	beq glop95
	move.b 1(a0,d1.w),d2
	andi.b #2,d2
	beq glop10
	tst.w iState
	bne glop10
	move.w #4,d0
	jsr push_ice
	bra glop6
glop95:	move.w #4,pDir
	move.w #0,pDx
	jmp glop10
glop10:
glop6:	move.w pDir,d0
	move.b joysticks,d1
	or.b joysticks+1,d1
	or.b joysticks+2,d1
	cmpi.w #1,d0
	bne glop50
	btst #1,d1
	beq glop50
	move.w #2,d0
glop50:	cmpi.w #2,d0
	bne glop51
	btst #0,d1
	beq glop51
	move.w #1,d0
glop51:	cmpi.w #3,d0
	bne glop52
	btst #3,d1
	beq glop52
	move.w #4,d0
glop52:	cmpi.w #4,d0
	bne glop53
	btst #2,d1
	beq glop53
	move.w #3,d0
glop53:
	cmpi.w #1,d0
	bne glop11
* Up
	subi.w #1,pDy
	cmpi.w #0,pDy
	bne glop15
	move.w #0,pDir
glop15: move.w pDy,d0
	movea.l #pete_up_cycle1,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	move.w pBaseX,d0
	btst #3,d0
	beq glop17
	addi.w #7,d1
glop17:	move.w d1,pLook
	bra glop14
glop11:	cmpi.w #2,d0
	bne glop12
* Down
	addi.w #1,pDy
	cmpi.w #12,pDy
	bne glop16
	move.w #0,pDir
	move.w #0,pDy
	addi.w #16,pBaseY
	addi.w #16,pPos
glop16:	move.w pDy,d0
	movea.l #pete_down_cycle1,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	move.w pBaseX,d0
	btst #3,d0
	beq glop18
	addi.w #7,d1
glop18:	move.w d1,pLook
	bra glop14
glop12:	cmpi.w #3,d0
	bne glop13
* Left
	subi.w #1,pDx
	cmpi.w #0,pDx
	bne glop19
	move.w #0,pDir
glop19:	move.w pDx,d1
	move.w pBaseX,d0
	btst #3,d0
	beq glop20
	addi.w #6,d1
glop20:	cmpi.w #12,d1
	bmi glop21
	subi.w #12,d1
glop21:	addi.w #12,d1
	move.w d1,pLook
	bra glop14
glop13:	cmpi.w #4,d0
	bne glop14
* Right
	addi.w #1,pDx
	cmpi.w #18,pDx
	bne glop22
	move.w #0,pDir
	move.w #0,pDx
	addi.w #24,pBaseX
	addi.w #1,pPos
glop22: move.w pDx,d1
	move.w pBaseX,d0
	btst #3,d0
	beq glop23
	addi.w #6,d1
glop23:	cmpi.w #12,d1
	bmi glop24
	subi.w #12,d1
glop24:	move.w d1,pLook
glop14: cmpi.w #1,pState
	bne glopi0
* Happy penguin
	move.w pDx,d0
	movea.l #pete_rounded_offsets,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	cmpi.w #18,d1
	bne glopi1
	addi.w #1,pPos
	move.w #0,d1
	addi.w #24,pBaseX
glopi1: move.w d1,pDx
	move.w counter,d0
	lsr.w #2,d0
	andi.w #3,d0
	move.l #happy_cycle,a0
	move.b (a0,d0.w),d3
	andi.w #255,d3
	move.w pBaseX,d1
	move.w pDx,d2
	cmpi.w #12,d2
	bmi glopi4
	addi.w #8,d1
glopi4: cmpi.w #6,d2
	bmi glopi5
	addi.w #8,d1
glopi5:	btst #3,d1
	beq glopi2
	addi.w #3,d3
glopi2:	move.w d3,pLook
	addi.w #1,iCounter
	cmpi.w #101,iCounter
	bpl glop5
	move.w #1,d0
	jsr add_score
glopi0:	cmpi.w #2,pState
	bne glopn0
* Death sequence
	move.w pDx,d0
	movea.l #pete_rounded_offsets,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	cmpi.w #18,d1
	bne glopn1
	addi.w #1,pPos
	move.w #0,d1
	addi.w #24,pBaseX
glopn1: move.w d1,pDx
	move.w counter,d0
	cmpi.w #40,d0
	bpl glopn6
	lsr.w #3,d0
	addi.w #196,d0
	move.w pBaseX,d1
	move.w pDx,d2
	cmpi.w #12,d2
	bmi glopn4
	addi.w #8,d1
glopn4: cmpi.w #6,d2
	bmi glopn5
	addi.w #8,d1
glopn5:	btst #3,d1
	beq glopn2
	addi.w #5,d0
glopn2:	move.w d0,pLook
glopn6:	cmpi.w #118,counter
	bne glopn7
	subi.w #1,lives
glopn7:	move.w counter,d0
	andi.w #254,d0
	cmpi.w #118,d0
	bne glopn8
	tst.w lives
* Game over?
	bmi glop5
	jsr draw_lives
glopn8:	cmpi.w #120,counter
	bne glopn0
	move.w #0,num_flames
	move.w #0,num_sparks
	move.w #0,flame_data
	move.w #0,flame_data+18
	move.w #0,flame_data+36
	move.w #0,flame_data+54
	move.w #0,pDx
	move.w #0,pDy
	move.w #0,pDir
	move.w #0,pState
	move.w #27,pLook
	move.w pBaseX,d1
	btst #3,d1
	beq glopn0
	addi.w #7,pLook

glopn0:
	tst.w block_clear_flag
	beq glop90
	subi.w #1,block_clear_flag
	jsr undraw_block
glop90:


* Pete
	movea.l #pete_offsets,a0
	move.w pDy,d1
	move.b (a0,d1.w),d0
	andi.w #255,d0
	add.w pBaseY,d0
	mulu.w #160,d0
	move.w pBaseX,d1
	move.w pDx,d2
	cmpi.w #12,d2
	bmi glop25
	addi.w #8,d1
glop25: cmpi.w #6,d2
	bmi glop26
	addi.w #8,d1
glop26:	andi.w #0xff0,d1
	lsr.w #1,d1
	add.w d1,d0
	add.l current_screen,d0
	move.l d0,a0
	move.w pLook,d0
	move.w #0,barrierHeight
	movea.l #block_buf,a1
	move.w pPos,d1
	tst.w pDx
	beq glop34
	move.w #5,barrierHeight
	move.l #-1,barrierAnd1
	move.l #-1,barrierAnd2
	move.l #-1,barrierAnd3
	move.w pBaseX,d2
	btst #3,d2
	bne glop37
	tst.b 16(a1,d1.w)
	beq glop38
	move.l #0,barrierAnd1
	move.l #0x00ff00ff,barrierAnd2
glop38:	tst.b 17(a1,d1.w)
	beq glop39
	move.l barrierAnd2,d2
	andi.l #0xff00ff00,d2
	move.l d2,barrierAnd2
	move.l #0,barrierAnd3
glop39:	cmpi.w #12,pDx
	bmi glop35
	move.l barrierAnd2,barrierAnd1
	move.l barrierAnd3,barrierAnd2
	move.l #-1,barrierAnd3
	bra glop35
glop37:	tst.b 16(a1,d1.w)
	beq glop40
	move.l #0,barrierAnd1
	move.l #0,barrierAnd2
glop40:	tst.b 17(a1,d1.w)
	beq glop41
	move.l #0,barrierAnd3
glop41:	cmpi.w #6,pDx
	bmi glop35
	move.l barrierAnd2,barrierAnd1
	move.l barrierAnd3,barrierAnd2
	bra glop35
glop34:	tst.w pDy
	beq glop36
	cmpi.w #8,pDy
	bmi glop35
	move.w pDy,d1
	subi.w #7,d1
	move.w d1,barrierHeight
	move.l #0,barrierAnd1
	move.l #0,barrierAnd2
	bra glop35
glop36:	tst.b 16(a1,d1.w)
	beq glop35
	move.w #5,barrierHeight
	move.l #0,barrierAnd1
	move.l #0,barrierAnd2
glop35:	movea.l #sprite_draw_data,a1
	move.l a0,(a1)+
	move.w d0,(a1)+
	move.w barrierHeight,(a1)+
	move.l barrierAnd1,(a1)+
	move.l barrierAnd2,(a1)+
	move.l barrierAnd3,(a1)+

* Ice block
	tst.w iState
	beq glopa0
	move.w iDir,d0
	tst.w d0
	bne glopa1
* Crushed
	addi.w #1,iCounter
	move.w iCounter,d1
	andi.w #248,d1
	lsr.w #3,d1
	addi.w #60,d1
	move.w iBaseX,d2
	btst #3,d2
	beq glopa3
	addi.w #5,d1
glopa3: cmpi.w #3,iType
	bne glopa4
	addi.w #10,d1
glopa4:	move.w d1,iLook
	cmpi.w #40,iCounter
	bne glopa2
	move.w #0,iState
	movea.l #block_map,a0
	move.w iPos,d1
	move.b #0,(a0,d1.w)
	move.b #0x5,d0
	cmpi.w #2,iType
	beq glopa6
	addi.w #1,coins
	move.w #4,new_sound
	move.b #0x25,d0
glopa6:	jsr add_score
	bra glopa0
* Moving ice
glopa1: tst.w iDx
	bne glopd0
	tst.w iDy
	bne glopd0
	movea.l #block_map,a0
	move.w iPos,d1
	cmpi.w #1,iDir
	bne glopd1
	tst.b -16(a0,d1.w)
	beq glopd0
	bra glopd4
glopd1: cmpi.w #2,iDir
	bne glopd2
	tst.b 16(a0,d1.w)
	beq glopd0
	bra glopd4
glopd2: cmpi.w #3,iDir
	bne glopd3
	tst.b -1(a0,d1.w)
	beq glopd0
	bra glopd4
glopd3:	tst.b 1(a0,d1.w)
	beq glopd0
* Reinstate block
glopd4: move.w #0,iState
	move.w iType,d2
	move.b d2,(a0,d1.w)
	movea.l #block_buf,a0
	move.b d2,(a0,d1.w)
	move.w iPos,block_draw_pos
	move.w #2,block_draw_flag
	move.w #2,new_sound
	bra glopa0
glopd0: cmpi.w #1,iDir
	bne glopd5
* Ice up
	subi.w #1,iDy
	cmpi.w #-1,iDy
	bne glopd8
	move.w #7,iDy
	subi.w #16,iPos
	subi.w #16,iBaseY
	bra glopd8
glopd5: cmpi.w #2,iDir
	bne glopd6
* Ice down
	addi.w #1,iDy
	cmpi.w #8,iDy
	bne glopd8
	move.w #0,iDy
	addi.w #16,iPos
	addi.w #16,iBaseY
	bra glopd8
glopd6:	cmpi.w #3,iDir
	bne glopd7
* Ice left
	subi.w #1,iDx
	cmpi.w #-1,iDx
	bne glopd8
	move.w #11,iDx
	subi.w #1,iPos
	subi.w #24,iBaseX
	bra glopd8
glopd7:
* Ice right
	addi.w #1,iDx
	cmpi.w #12,iDx
	bne glopd8
	move.w #0,iDx
	addi.w #1,iPos
	addi.w #24,iBaseX

glopd8:
* Ice look
	move.w iType,d0
	asl.w #3,d0
	addi.w #28,d0
	move.w iBaseX,d1
	andi.w #8,d1
	lsr.w #1,d1
	add.w iDx,d1
	andi.w #7,d1
	add.w d1,d0
	move.w d0,iLook

* Handle ice masking and stuff
glopa2: move.w iDy,d0
	asl.w #1,d0
	add.w iBaseY,d0
	mulu.w #160,d0
	move.w iBaseX,d1
	lsr.w #1,d1
	add.w iDx,d1
	andi.w #248,d1
	add.w d1,d0
	movea.l current_screen,a0
	add.w d0,a0
	move.w #0,barrierHeight
	movea.l #block_buf,a1
	move.w iPos,d1
	tst.w iDx
	beq glopa7
* Moving horizontally
	move.w #8,barrierHeight
	move.l #-1,barrierAnd1
	move.l #-1,barrierAnd2
	move.l #-1,barrierAnd3
	move.w iBaseX,d2
	btst #3,d2
	bne glopa8
	tst.b 16(a1,d1.w)
	beq glopb5
	move.l #0,barrierAnd1
	move.l #0x00ff00ff,barrierAnd2
glopb5:	tst.b 17(a1,d1.w)
	beq glopb1
	move.l barrierAnd2,d2
	andi.l #0xff00ff00,d2
	move.l d2,barrierAnd2
	move.l #0,barrierAnd3
glopb1:	cmpi.w #8,iDx
	bmi glopa9
	move.l barrierAnd2,barrierAnd1
	move.l barrierAnd3,barrierAnd2
	move.l #-1,barrierAnd3
	bra glopa9
glopa8:	tst.b 16(a1,d1.w)
	beq glopb2
	move.l #0,barrierAnd1
	move.l #0,barrierAnd2
glopb2:	tst.b 17(a1,d1.w)
	beq glopb3
	move.l #0,barrierAnd3
glopb3:	cmpi.w #4,iDx
	bmi glopa9
	move.l barrierAnd2,barrierAnd1
	move.l barrierAnd3,barrierAnd2
	bra glopa9
* Moving vertically
glopa7: tst.w iDy
	beq glopb4
	tst.b 32(a1,d1.w)
	beq glopa9
	cmpi.w #4,iDy
	bmi glopa9
	move.w iDy,d1
	subi.w #4,d1
	asl.w #1,d1
	move.w d1,barrierHeight
	move.l #0,barrierAnd1
	move.l #0,barrierAnd2
	bra glopa9
glopb4:	tst.b 16(a1,d1.w)
	beq glopa9
	move.w #8,barrierHeight
	move.l #0,barrierAnd1
	move.l #0,barrierAnd2
glopa9:	movea.l #sprite_draw_data+20,a1
	move.l a0,(a1)+
	move.w iLook,(a1)+
	move.w barrierHeight,(a1)+
	move.l barrierAnd1,(a1)+
	move.l barrierAnd2,(a1)+
	move.l barrierAnd3,(a1)+

* No more ice
glopa0: tst.w score_update_flag
	beq glopb0
	subi.w #1,score_update_flag
	jsr draw_score
glopb0:

	tst.w music_update_flag
	beq glopj2
	subi.w #1,music_update_flag
	jsr draw_music
glopj2:


* Check if block needs drawing
	tst.w block_draw_flag
	beq glope0
	subi.w #1,block_draw_flag
	move.w block_draw_pos,d0
	movea.l #block_map,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	jsr draw_block
glope0:


* Pete shadow
	movea.l #shadowTmp,a0
	move.w #11,d0
glop60:	move.l #0,(a0)+
	dbra.w d0,glop60
	movea.l #pete_offsets,a0
	move.w pDy,d1
	move.b (a0,d1.w),d0
	andi.w #255,d0
	add.w pBaseY,d0
	addi.w #11,d0
	move.w d0,d4
	addi.w #8,d4
	andi.w #15,d4
	mulu.w #12,d4
	addi.l #shadowMask,d4
	move.l d4,a3
	mulu.w #160,d0
	move.w pBaseX,d1
	move.w pDx,d2
	btst #3,d1
	beq glop55
	addi.w #6,d2
glop55: andi.w #0xff0,d1
	cmpi.w #12,d2
	bmi glop56
	addi.w #16,d1
	subi.w #12,d2
glop56:	move.b (a0,d2.w),d3
	andi.w #255,d3
	addi.w #5,d3
	add.w d3,d1
	move.w d1,d2
	andi.w #0xff0,d2
	lsr.w #1,d2
	add.w d2,d0
	add.l current_screen,d0
	movea.l d0,a0
	move.w d1,d0
	andi.w #15,d0
	movea.l #block_buf,a1
	move.w pPos,d1
	tst.w pDx
	bne glop72
* Vertical motion
	btst #3,d0
	bne glop57
	tst.b 16(a1,d1.w)
	beq glop59
	move.l #0xffffffff,shadowTmp+12
	move.l #0xff00ff00,shadowTmp+16
glop59: tst.b 32(a1,d1.w)
	beq glop61
	move.l #0xffffffff,shadowTmp+36
	move.l #0xff00ff00,shadowTmp+40
glop61: tst.b 1(a1,d1.w)
	beq glop64
	move.l #0x00ff00ff,shadowTmp+4
	or.l #0x00ff00ff,shadowTmp+16
glop64: tst.b 17(a1,d1.w)
	beq glop65
	or.l #0x00ff00ff,shadowTmp+16
	move.l #0x00ff00ff,shadowTmp+28
	or.l #0x00ff00ff,shadowTmp+40
glop65: tst.b 33(a1,d1.w)
	beq glop66
	or.l #0x00ff00ff,shadowTmp+40
glop66:	bra glop58
glop57:	tst.b 16(a1,d1.w)
	beq glop67
	move.l #0xffffffff,shadowTmp+12
	move.l #0xffffffff,shadowTmp+16
glop67: tst.b 32(a1,d1.w)
	beq glop68
	move.l #0xffffffff,shadowTmp+36
	move.l #0xffffffff,shadowTmp+40
glop68: tst.b 1(a1,d1.w)
	beq glop69
	move.l #0xff00ff00,shadowTmp+8
	move.l #0xff00ff00,shadowTmp+20
glop69: tst.b 17(a1,d1.w)
	beq glop70
	move.l #0xff00ff00,shadowTmp+20
	move.l #0xff00ff00,shadowTmp+32
	move.l #0xff00ff00,shadowTmp+44
glop70: tst.b 33(a1,d1.w)
	beq glop71
	move.l #0xff00ff00,shadowTmp+44
glop71:	bra glop58
glop72: 
* Horizontal motion
	move.w pBaseX,d2
	btst #3,d2
	bne glop73
	cmpi.w #8,pDx
	bpl glop74
	tst.b 16(a1,d1.w)
	beq glop75
	move.l #0xffffffff,shadowTmp+12
	move.l #0xff00ff00,shadowTmp+16
glop75: tst.b 17(a1,d1.w)
	beq glop58
	or.l #0x00ff00ff,shadowTmp+16
	move.l #0xffffffff,shadowTmp+20
	bra glop58
glop74: tst.b 16(a1,d1.w)
	beq glop76
	move.l #0xff00ff00,shadowTmp+12
glop76: tst.b 17(a1,d1.w)
	beq glop77
	or.l #0x00ff00ff,shadowTmp+12
	move.l #0xffffffff,shadowTmp+16
glop77: tst.b 18(a1,d1.w)
	beq glop78
	move.l #0xffffffff,shadowTmp+20
glop78: tst.b 2(a1,d1.w)
	beq glop58
	move.l #0xffffffff,shadowTmp+8
	move.l #0xffffffff,shadowTmp+20
	bra glop58
glop73:	cmpi.w #2,pDx
	bpl glop79
	tst.b 16(a1,d1.w)
	beq glop81
	move.l #0xffffffff,shadowTmp+12
	move.l #0xffffffff,shadowTmp+16
glop81: tst.b 17(a1,d1.w)
	beq glop58
	move.l #0xffffffff,shadowTmp+20
	bra glop58
glop79: cmpi.w #14,pDx
	bpl glop80
	tst.b 16(a1,d1.w)
	beq glop82
	move.l #0xffffffff,shadowTmp+12
glop82:	tst.b 17(a1,d1.w)
	beq glop58
	move.l #0xffffffff,shadowTmp+16
	move.l #0xffffffff,shadowTmp+20
	bra glop58
glop80: tst.b 17(a1,d1.w)
	beq glop83
	move.l #0xffffffff,shadowTmp+12
	move.l #0xff00ff00,shadowTmp+16
glop83: tst.b 18(a1,d1.w)
	beq glop84
	or.l #0x00ff00ff,shadowTmp+16
	move.l #0xffffffff,shadowTmp+20
glop84: tst.b 2(a1,d1.w)
	beq glop58
	move.l #0x00ff00ff,shadowTmp+4
	move.l #0xffffffff,shadowTmp+8
	or.l #0x00ff00ff,shadowTmp+16
	move.l #0xffffffff,shadowTmp+20

glop58: movea.l #shadowTmp,a1
	movea.l #shadowMask,a2
	move.w #3,d2
glop63:	move.w #7,d1
glop62:	move.l (a1),(a2)+
	move.l 4(a1),(a2)+
	move.l 8(a1),(a2)+
	dbra.w d1,glop62
	adda.l #12,a1
	dbra.w d2,glop63
	jsr draw_shadow

* Handle flames
	tst.w pState
	bne glopg9
	movea.l #flame_data,a6
	move.w #3,d7
glopf1: tst.w (a6)
	bne glopf2
	move.w max_flames,d0
	add.w max_sparks,d0
	sub.w num_flames,d0
	sub.w num_sparks,d0
	tst.w d0
	beq glopf0
* Should add flame or spark
	move.w counter,d1
	andi.w #31,d1
	tst.w d1
	bne glopf0
* Determine which edge
	move.w #16,d2
	move.w #1,d3
	cmpi.w #148,pBaseX
	bpl glopf3
	move.w #280,d2
	move.w #12,d3
glopf3: move.w random_pos,d0
	movea.l #random_table,a0
	move.b (a0,d0.w),d1
	addi.w #1,d0
	andi.w #255,d0
	move.w d0,random_pos
	andi.w #240,d1
	movea.l #block_map,a1
	add.w d1,d3
	tst.b (a1,d3.w)
	bne glopf0
	move.w max_flames,d0
	cmp.w num_flames,d0
	beq glopg7
	addi.w #1,num_flames
	move.w #1,d0
	bra glopg8
glopg7: addi.w #1,num_sparks
	move.w #2,d0
glopg8:	move.w #1,(a6)
	move.w d0,2(a6)
	move.w d2,4(a6)
	addi.w #13,d1
	move.w d1,6(a6)
	move.l #0,8(a6)
	move.l #0,12(a6)
	move.w d3,16(a6)
	move.w #7,new_sound
glopf2:	move.w (a6),fState
	move.w 2(a6),fType
	move.w 4(a6),fBaseX
	move.w 6(a6),fBaseY
	move.w 8(a6),fDx
	move.w 10(a6),fDy
	move.w 12(a6),fDir
	move.w 14(a6),fCount
	move.w 16(a6),fPos
	addi.w #1,fCount

* Process flame states
	cmpi.w #3,fState
	bpl gloph6
* Check for ice collision
	tst.w iState
	beq gloph6
	move.w iDy,d0
	asl.w #1,d0
	add.w iBaseY,d0
	addi.w #11,d0
	move.w fDy,d1
	lsr.w #1,d1
	add.w fBaseY,d1
	sub.w d1,d0
	bmi gloph6
	cmpi.w #28,d0
	bpl gloph6
	move.w iDx,d0
	asl.w #1,d0
	add.w iBaseX,d0
	addi.w #22,d0
	move.w fDx,d1
	lsr.w #1,d1
	add.w fBaseX,d1
	sub.w d1,d0
	bmi gloph6
	cmpi.w #44,d0
	bpl gloph6
* Collided
	move.w #5,new_sound
	move.w #0,fCount
	move.w #3,fState
	move.w fDx,d0
	addi.w #8,d0
	andi.w #240,d0
	cmpi.w #48,d0
	bne gloph7
	move.w #0,d0
	addi.w #24,fBaseX
gloph7: move.w d0,fDx
	move.b #0x50,d0
	jsr add_score
gloph6:

	cmpi.w #1,fState
	bne glopf5
* Appearing
	move.w fCount,d0
	andi.w #28,d0
	lsr.w #2,d0
	addi.w #180,d0
	move.w fBaseX,d1
	andi.w #8,d1
	add.w d1,d0
	move.w d0,fLook
	cmpi.w #70,fCount
	bne gloph0
	move.w #2,fState
	bra gloph0
glopf5: cmpi.w #2,fState
	bne gloph1
* Moving around
	move.w fDir,d0
	move.w fPos,d1
	move.w fType,d2
	movea.l #block_map,a0
	cmpi.w #1,d0
	bne glopk0
* Up
	sub.w d2,fDy
	bpl glopk3
	addi.w #32,fDy
	subi.w #16,d1
	subi.w #16,fBaseY
	bra glopk3
glopk0:	cmpi.w #2,d0
	bne glopk1
* Down
	add.w d2,fDy
	cmpi.w #32,fDy
	bne glopk3
	move.w #0,fDy
	addi.w #16,d1
	addi.w #16,fBaseY
	bra glopk3
glopk1: cmpi.w #3,d0
	bne glopk2
* Left
	sub.w d2,fDx
	bpl glopk3
	addi.w #48,fDx
	subi.w #1,d1
	subi.w #24,fBaseX
	bra glopk3
glopk2: cmpi.w #4,d0
	bne glopk3
* Right
	add.w d2,fDx
	cmpi.w #48,fDx
	bne glopk3
	move.w #0,fDx
	addi.w #1,d1
	addi.w #24,fBaseX
glopk3:
	move.w d0,fDir
	move.w d1,fPos

	move.w fDx,d2
	or.w fDy,d2
	tst.w d2
	bne glopk4

* Track penguin
	move.w #0,d4
* Check horizontal proximity
	move.w pPos,d2
	andi.w #15,d2
	move.w d1,d3
	andi.w #15,d3
	addi.w #1,d3
	sub.w d2,d3
	bmi glopk6
	cmpi.w #3,d3
	bpl glopk6
	move.w pPos,d2
	andi.w #240,d2
	move.w d1,d3
	andi.w #240,d3
	cmp.w d2,d3
	beq glopk6
	cmp.w d2,d3
	bpl glopk7
	move.w #2,d4
	bra glopk8
glopk7:	move.w #1,d4
	bra glopk8
glopk6:	
* Check vertical proximity
	move.w pPos,d2
	andi.w #240,d2
	move.w d1,d3
	andi.w #240,d3
	addi.w #16,d3
	sub.w d2,d3
	bmi glopk8
	cmpi.w #48,d3
	bpl glopk8
	move.w pPos,d2
	andi.w #15,d2
	move.w d1,d3
	andi.w #15,d3
	cmp.w d2,d3
	beq glopk8
	cmp.w d2,d3
	bpl glopk9
	move.w #4,d4
	bra glopk8
glopk9:	move.w #3,d4
	bra glopk8
glopk8:	
* Test track direction validity
	movea.l #block_offsets,a1
	tst.w d4
	beq glopk5
	move.b (a1,d4.w),d2
	add.b d1,d2
	andi.w #255,d2
	tst.b (a0,d2.w)
	bne glopk5
	move.w d4,fDir
	bra glopk4
glopk5:
* Test current direction validity
	move.w fDir,d4
	tst.w d4
	beq glopl0
	move.b (a1,d4.w),d2
	add.b d1,d2
	andi.w #255,d2
	tst.b (a0,d2.w)
	beq glopk4
* Find new random direction
glopl0:	move.w #0,fDir
	move.w random_pos,d2
	addi.w #1,d2
	andi.w #255,d2
	movea.l #random_table,a2
	move.b (a2,d2.w),d4
	move.w d2,random_pos
	move.w #3,d0
glopl4:	andi.w #3,d4
	addi.w #1,d4
	move.b (a1,d4.w),d2
	add.b d1,d2
	andi.w #255,d2
	tst.b (a0,d2.w)
	beq glopl3
* Keep testing all directions
	dbra.w d0,glopl4
	bra glopk4
glopl3:	move.w d4,fDir

glopk4:
* Check for penguin collision
	tst.w cheat_mode
	bne glopm2
	move.w pDy,d1
	movea.l #pete_offsets,a0
	move.b (a0,d1.w),d0
	andi.w #255,d0
	add.w pBaseY,d0
	addi.w #10,d0
	move.w fDy,d1
	lsr.w #1,d1
	add.w fBaseY,d1
	sub.w d1,d0
	bmi glopm2
	cmpi.w #20,d0
	bpl glopm2
	move.w pDx,d0
	move.w d0,d1
	asl.w #2,d0
	add.w d1,d0
	lsr.w #2,d0
	add.w pBaseX,d0
	addi.w #16,d0
	move.w fDx,d1
	lsr.w #1,d1
	add.w fBaseX,d1
	sub.w d1,d0
	bmi glopm2
	cmpi.w #32,d0
	bpl glopm2
* Collided
	move.w #2,pState
	move.w counter,d0
	andi.w #1,d0
	move.w d0,counter
	move.w #8,new_sound
glopm2:



* Determine look
	cmpi.w #1,fType
	bne glopl6
* Flame
	tst.w fDir
	bne glopl7
* Standing still
	move.w counter,d0
	andi.w #30,d0
	lsr.w #1,d0
	movea.l #flame_cycle,a0
	move.w fBaseX,d1
	btst #3,d1
	beq glopm0
	movea.l #flame_cycle2,a0
glopm0: move.b (a0,d0.w),d1
	andi.w #255,d1
	move.w d1,fLook
	bra gloph0
glopl7:	cmpi.w #3,fDir
	bpl glopl8
* Vertical motion
	move.w fDy,d0
	lsr.w #1,d0
	movea.l #flame_cycle,a0
	move.w fBaseX,d1
	btst #3,d1
	beq glopm1
	movea.l #flame_cycle2,a0
glopm1: move.b (a0,d0.w),d1
	andi.w #255,d1
	move.w d1,fLook
	bra gloph0
glopl8:
* Horizontal motion
	move.w fDx,d0
	lsr.w #1,d0
	add.w fBaseX,d0
	andi.w #15,d0
	addi.w #80,d0
	move.w d0,fLook
	bra gloph0
* Spark
glopl6:	tst.w fDir
	bne glopl5
* Standing still
	move.w counter,d0
	andi.w #30,d0
	lsr.w #1,d0
	addi.w #148,d0
	move.w fBaseX,d1
	andi.w #8,d1
	asl.w #1,d1
	add.w d1,d0
	move.w d0,fLook
	bra gloph0
glopl5:	cmpi.w #3,fDir
	bpl glopl1
* Vertical motion
	move.w fDy,d0
	lsr.w #1,d0
	addi.w #148,d0
	move.w fBaseX,d2
	btst #3,d2
	beq glopl2
	addi.w #16,d0
glopl2:	move.w d0,fLook
	bra gloph0
glopl1:
* Horizontal motion
	move.w fDx,d0
	lsr.w #1,d0
	add.w fBaseX,d0
	andi.w #15,d0
	addi.w #132,d0
	move.w d0,fLook
	bra gloph0
gloph1:
* Score symbol
	move.w counter,d1
	andi.w #4,d1
	lsr.w #2,d1
	addi.w #114,d1
	move.w fDx,d0
	lsr.w #1,d0
	add.w fBaseX,d0
	andi.w #8,d0
	lsr.w #2,d0
	add.w d0,d1
	move.w d1,fLook
	move.w counter,d1
	andi.w #3,d1
	bne gloph2
	sub.w #1,fBaseY
gloph2: cmpi.w #70,fCount
	beq gloph5
	cmpi.w #35,fCount
	bmi gloph0
	move.w counter,d1
	andi.w #1,d1
	beq gloph0
* Blinking on/off
	bra glopf4
* Remove flame
gloph5:	cmpi.w #1,fType
	bne gloph3
	subi.w #1,num_flames
	bra gloph4
gloph3:	subi.w #1,num_sparks
gloph4:	move.w #0,fState
	bra glopf4
gloph0:

* Determine flame position and masking

	movea.l #sprite_draw_data+20,a2
glopf7:	tst.l (a2)
	beq glopf6
	adda.l #20,a2
	bra glopf7
glopf6:	move.w fDy,d0
	lsr.w #1,d0
	add.w fBaseY,d0
	mulu.w #160,d0
	move.w fDx,d1
	lsr.w #1,d1
	add.w fBaseX,d1
	lsr.w #1,d1
	andi.w #248,d1
	add.w d1,d0
	movea.l current_screen,a0
	add.w d0,a0
	move.w #0,barrierHeight
	movea.l #block_buf,a1
	move.w fPos,d1
	tst.w fDx
	beq glopf8
* Moving horizontally
	move.w #5,barrierHeight
	move.l #-1,barrierAnd1
	move.l #-1,barrierAnd2
	move.l #-1,barrierAnd3
	move.w fBaseX,d2
	btst #3,d2
	bne glopf9
	tst.b 16(a1,d1.w)
	beq glopg0
	move.l #0,barrierAnd1
	move.l #0x00ff00ff,barrierAnd2
glopg0:	tst.b 17(a1,d1.w)
	beq glopg2
	move.l barrierAnd2,d2
	andi.l #0xff00ff00,d2
	move.l d2,barrierAnd2
	move.l #0,barrierAnd3
glopg2:	cmpi.w #32,fDx
	bmi glopg3
	move.l barrierAnd2,barrierAnd1
	move.l barrierAnd3,barrierAnd2
	move.l #-1,barrierAnd3
	bra glopg3
glopf9:	tst.b 16(a1,d1.w)
	beq glopg4
	move.l #0,barrierAnd1
	move.l #0,barrierAnd2
glopg4:	tst.b 17(a1,d1.w)
	beq glopg5
	move.l #0,barrierAnd3
glopg5:	cmpi.w #16,fDx
	bmi glopg3
	move.l barrierAnd2,barrierAnd1
	move.l barrierAnd3,barrierAnd2
	bra glopg3
* Moving vertically
glopf8: tst.w fDy
	beq glopg6
	tst.b 32(a1,d1.w)
	beq glopg3
	cmpi.w #22,fDy
	bmi glopg3
	move.w fDy,d1
	subi.w #22,d1
	lsr.w #1,d1
	move.w d1,barrierHeight
	move.l #0,barrierAnd1
	move.l #0,barrierAnd2
	bra glopg3
glopg6:	tst.b 16(a1,d1.w)
	beq glopg3
	move.w #5,barrierHeight
	move.l #0,barrierAnd1
	move.l #0,barrierAnd2
glopg3:

	move.l a0,(a2)+
	move.w fLook,(a2)+
	move.w barrierHeight,(a2)+
	move.l barrierAnd1,(a2)+
	move.l barrierAnd2,(a2)+
	move.l barrierAnd3,(a2)+


glopf4: move.w fState,(a6)
	move.w fType,2(a6)
	move.w fBaseX,4(a6)
	move.w fBaseY,6(a6)
	move.w fDx,8(a6)
	move.w fDy,10(a6)
	move.w fDir,12(a6)
	move.w fCount,14(a6)
	move.w fPos,16(a6)

glopf0: adda.l #18,a6
	dbra.w d7,glopf1
* End of flames
glopg9:



* Sort and draw sprites
	move.w #0,d0
	movea.l #sprite_draw_data,a0
	movea.l #sort_table,a1
glopc2:	tst.l (a0)
	beq glopc1
	move.l (a0),(a1)+
	move.l a0,(a1)+
	addi.w #8,d0
	adda.l #20,a0
	bra glopc2
glopc1:	movea.l #sort_table,a1
	move.w #0,d1
glopc4:	move.w d1,d2
glopc5:	addi.w #8,d2
	cmp.w d2,d0
	beq glopc3
	move.l (a1,d1.w),d3
	cmp.l (a1,d2.w),d3
	blt glopc5
	move.l (a1,d2.w),(a1,d1.w)
	move.l d3,(a1,d2.w)
	move.l 4(a1,d1.w),d3
	move.l 4(a1,d2.w),4(a1,d1.w)
	move.l d3,4(a1,d2.w)
	bra glopc5
glopc3: addi.w #8,d1
	cmp.w d1,d0
	bne glopc4
	move.w d0,d6
	movea.l #sort_table+4,a6
glopc6:	move.l (a6),a1
	move.l (a1)+,a0
	move.w (a1)+,d0
	move.w (a1)+,barrierHeight
	move.l (a1)+,barrierAnd1
	move.l (a1)+,barrierAnd2
	move.l (a1)+,barrierAnd3
	jsr draw_sprite
	adda.l #8,a6
	subi.w #8,d6
	tst.w d6
	bne glopc6
glopc7:

* Save restore buffers
	move.w counter,d0
	btst #0,d0
	bne glop32
	move.l restore_pointer,restore_pointer1
	bra glop33
glop32: move.l restore_pointer,restore_pointer2
glop33:
	move.w #-1,-(sp)
	move.l current_screen,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	adda.l #12,sp

	jsr manage_sound
	tst.w music_on
	beq glopj0
	tst.w pState
	bne glopj0
	jsr play_music
	bra glopj1
glopj0:	move.b #0,sound_data+9
	move.b #0,sound_data+11
glopj1:	jsr wait_for_vblank
	jsr push_sound_data

	addi.w #1,counter
	move.w counter,d0
	btst #0,d0
	bne glop3
	move.l screenbase,current_screen
	bra glop4
glop3:	move.l backbuffer,current_screen
glop4:
* Switch music on/off
	move.b joysticks,d0
	or.b joysticks+1,d0
	or.b joysticks+2,d0
	andi.w #128,d0
	tst.w d0
	beq glopj3
	tst.w previous_joy
	bne glopj3
	move.w music_on,d1
	eori.w #1,d1
	move.w d1,music_on
	move.w #2,music_update_flag
glopj3:	move.w d0,previous_joy

	jmp glop2
* End of main game loop

glop5:	rts



add_score:
	move.b d0,score_buf+1
	movea.l #score_buf+2,a0
	movea.l #score_bcd+2,a1
	move #4,ccr
	abcd -(a0),-(a1)
	abcd -(a0),-(a1)
	move.w #2,score_update_flag
	rts


push_ice:
	move.w #2,iState
	move.w #0,iDx
	move.w #0,iDy
	move.w #0,iCounter
	move.w d0,iDir
	move.w pPos,d1
	move.w pBaseX,iBaseX
	move.w pBaseY,iBaseY
	addi.w #3,iBaseY
	cmpi.w #1,d0
	bne puic1
* Up
	subi.w #16,d1
	move.w d1,iPos
	move.b (a0,d1.w),iType+1
	andi.w #255,iType
	move.b #4,(a0,d1.w)
	subi.w #16,iBaseY
	tst.b -16(a0,d1.w)
	bne puic5
	move.b #0,(a0,d1.w)
	move.w #1,new_sound
	bra puic6
puic1:	cmpi.w #2,d0
	bne puic2
* Down
	addi.w #16,d1
	move.w d1,iPos
	move.b (a0,d1.w),iType+1
	andi.w #255,iType
	move.b #4,(a0,d1.w)
	addi.w #16,iBaseY
	tst.b 16(a0,d1.w)
	bne puic5
	move.b #0,(a0,d1.w)
	move.w #1,new_sound
	bra puic6
puic2:	cmpi.w #3,d0
	bne puic3
* Left
	subi.w #1,d1
	move.w d1,iPos
	move.b (a0,d1.w),iType+1
	andi.w #255,iType
	move.b #4,(a0,d1.w)
	subi.w #24,iBaseX
	tst.b -1(a0,d1.w)
	bne puic5
	move.b #0,(a0,d1.w)
	move.w #1,new_sound
	bra puic6
* Right
puic3:	addi.w #1,d1
	move.w d1,iPos
	move.b (a0,d1.w),iType+1
	andi.w #255,iType
	move.b #4,(a0,d1.w)
	addi.w #24,iBaseX
	tst.b 1(a0,d1.w)
	bne puic5
	move.b #0,(a0,d1.w)
	move.w #1,new_sound
	bra puic6
puic5:
* Crush block
	move.w #3,new_sound
	move.w #1,iState
	move.w #0,iDir
puic6:
	move.w #2,block_clear_flag
	move.w iPos,block_clear_pos

	rts

********************** Game loop sprite routines

* d0 has look, a0 has destination
draw_sprite:
	asl.w #1,d0
	movea.l #spr_width,a2
	move.w (a2,d0.w),tmp_width
	movea.l #spr_height,a2
	move.w (a2,d0.w),tmp_height
	asl.w #1,d0
	movea.l #spr_offset,a2
	move.l (a2,d0.w),a1
	move.l restore_pointer,a2
	adda.l #sprite_pixels,a1
	move.w tmp_height,d0
	subi.w #1,d0
	cmpi.w #1,tmp_width
	bne drsp1
drsp3:	
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	adda.l #152,a0
	dbra.w d0,drsp3
	bra drsp6
drsp1:	
	move.l barrierAnd1,d2
	eori.l #-1,d2
	move.l d2,barrierOr1
	move.l barrierAnd2,d2
	eori.l #-1,d2
	move.l d2,barrierOr2
	move.l barrierAnd3,d2
	eori.l #-1,d2
	move.l d2,barrierOr3
	add.w d0,barrierHeight
	subi.w #23,barrierHeight
	tst.w barrierHeight
	bpl drsp9
	move.w #0,barrierHeight
drsp9:	sub.w barrierHeight,d0
	cmpi.w #2,tmp_width
	bne drsp2
drsp4:	
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	adda.l #144,a0
	dbra.w d0,drsp4
	move.w barrierHeight,d0
	tst.w d0
	beq drsp6
	subi.w #1,d0
drsp7:	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l barrierOr1,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd1,d3
	or.l d3,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd1,d3
	or.l d3,d2
	move.l d2,(a0)+
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l barrierOr2,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd2,d3
	or.l d3,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd2,d3
	or.l d3,d2
	move.l d2,(a0)+
	adda.l #144,a0
	dbra.w d0,drsp7
	bra drsp6
drsp2:	
drsp5:	
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	or.l (a1)+,d2
	move.l d2,(a0)+
	adda.l #136,a0
	dbra.w d0,drsp5
	move.w barrierHeight,d0
	tst.w d0
	beq drsp6
	subi.w #1,d0
drsp8:	
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l barrierOr1,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd1,d3
	or.l d3,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd1,d3
	or.l d3,d2
	move.l d2,(a0)+
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l barrierOr2,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd2,d3
	or.l d3,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd2,d3
	or.l d3,d2
	move.l d2,(a0)+
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l barrierOr3,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd3,d3
	or.l d3,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l (a1)+,d3
	and.l barrierAnd3,d3
	or.l d3,d2
	move.l d2,(a0)+
	adda.l #136,a0
	dbra.w d0,drsp8

drsp6:	move.l a0,(a2)+
	move.w tmp_width,(a2)+
	move.w tmp_height,(a2)+
	move.l a2,restore_pointer
	rts



* d0 has look, a0 has destination
draw_shadow:
	asl.w #1,d0
	movea.l #shd_width,a2
	move.w (a2,d0.w),tmp_width
	asl.w #1,d0
	movea.l #shd_offset,a2
	move.l (a2,d0.w),a1
	move.l restore_pointer,a2
	adda.l #shadow_pixels,a1
	move.w #15,d0
	cmpi.w #1,tmp_width
	bne drsh1
drsh2:	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	adda.l #152,a0
	dbra.w d0,drsh2
	bra drsh5
drsh1:	cmpi.w #2,tmp_width
	bne drsh3
drsh4:	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l (a3)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l (a3)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	adda.l #144,a0
	adda.l #4,a3
	dbra.w d0,drsh4
	bra drsh5
drsh3:	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l (a3)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l (a3)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	move.w (a1),d1
	swap d1
	move.w (a1)+,d1
	or.l (a3)+,d1
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	move.l (a0),d2
	move.l d2,(a2)+
	and.l d1,d2
	move.l d2,(a0)+
	adda.l #136,a0
	dbra.w d0,drsh3

drsh5:	move.l a0,(a2)+
	move.w tmp_width,(a2)+
	move.w #16,(a2)+
	move.l a2,restore_pointer

	rts


restore_pixels:
	move.l restore_pointer,a0
repi12:
	move.w -(a0),d6
	tst.w d6
	beq repi1
	subi.w #1,d6
	move.w -(a0),d7
	move.l -(a0),a1
	cmpi.w #1,d7
	bne repi13
repi14:
	suba.l #152,a1
	move.l -(a0),-(a1)
	move.l -(a0),-(a1)
	dbra d6,repi14
	jmp repi12
repi13:
	cmpi.w #2,d7
	bne repi15
repi16:
	suba.l #160,a1
	suba.l #16,a0
	movem.l (a0),d0-d3
	movem.l d0-d3,(a1)
	dbra d6,repi16
	jmp repi12
repi15:
	suba.l #160,a1
	suba.l #24,a0
	movem.l (a0),d0-d5
	movem.l d0-d5,(a1)
	dbra d6,repi15
	jmp repi12
repi1:	

	move.w #0,(a0)+
	move.l a0,restore_pointer
	rts

********************** Game session setup routine

setup_game:
* Stop music
	pea sound_off
	move.w #32,-(sp)
	trap #14
	addq.l #6,sp

* Randomize
	move.w counter,random_pos

* Clear screen
	moveq.l #0,d0
	move.w #7999,d1
	move.l screenbase,a0
stga1:	move.l d0,(a0)+
	dbra.w d1,stga1

* Reset variables
	move.w #0,level
	move.w #0x01,level_bcd
	move.w #0,score_bcd
	move.w #3,lives

	rts

********************** Celebration screen

show_celebration:
	move.w #0,counter

	move.w #0,counter
shce4:	move.l #celebration_text,a0
	move.l screenbase,a1
	adda.l #4808,a1
	move.w counter,d0
	jsr draw_string_line
	addi.w #1,counter
	cmpi.w #7,counter
	bne shce4

	move.w #0,counter
shce5:	move.l #celebration_text+18,a0
	move.l screenbase,a1
	adda.l #8008,a1
	move.w counter,d0
	jsr draw_string_line
	addi.w #1,counter
	cmpi.w #7,counter
	bne shce5

	move.w #0,counter
shce6:	move.l #celebration_text+36,a0
	move.l screenbase,a1
	adda.l #9608,a1
	move.w counter,d0
	jsr draw_string_line
	addi.w #1,counter
	cmpi.w #8,counter
	bne shce6

	jsr setup_party_song

	movea.l #celebration_pixels,a0
	movea.l screenbase,a1
	adda.l #16048,a1
	move.w #79,d0
shce3:	move.w #15,d1
shce2:	move.l (a0)+,(a1)+
	dbra.w d1,shce2
	adda.l #96,a1
	dbra.w d0,shce3

	jsr clear_sprites

	move.l screenbase,a0
	adda.l #17120,a0
	move.l a0,sprites_base+4
	adda.l #1120,a0
	move.l a0,sprites_base
	adda.l #1760,a0
	move.l a0,shadows_base
	move.w #9,sprites_h
	move.w #9,sprites_h+2
	move.w #5,shadows_look
	move.w #9,shadows_h

shce0: 	move.w counter,d0
	lsr.w #2,d0
	andi.w #3,d0
	move.l #happy_cycle,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	move.w d1,sprites_look
	addi.w #168,d1
	move.w d1,sprites_look+2

	jsr draw_intro_sprites

	addi.w #1,counter
	cmpi.w #300,counter
	bpl shce7
	jsr play_music
shce7:	jsr wait_for_vblank
	jsr push_sound_data

	cmpi.w #CELEBRATION_WAIT,counter
	bne shce0

* Clear screen
	moveq.l #0,d0
	move.w #7999,d1
	move.l screenbase,a0
shce1:	move.l d0,(a0)+
	dbra.w d1,shce1

	rts


********************** Intro animation

play_intro:
* Reset jump table
	move.l #intro_jump_values,intro_jump_value
	move.l #intro_count_values,intro_count_max
	clr.w counter
	jsr clear_sprites

intro_loop:

	move.l intro_jump_value,a0
	move.l (a0),a1
	jsr (a1)

	jsr draw_intro_sprites

	jsr play_music

	jsr wait_for_vblank
	jsr push_sound_data

	jsr update_intro_counter

	pea super_read_keyboard
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp
	move.b joysticks,d0
	or.b joysticks+1,d0
	or.b joysticks+2,d0
	btst #7,d0
	beq intro_loop

intr1:	rts


intro_draw_fire_button_text:
	move.l #fire_button_text,a0
	move.l screenbase,a1
	adda.l #29448,a1
	move.w counter,d0
	jsr draw_string_line
	move.l #top_texts,top_text_pos
	rts

intro_clear_top_text:
	move.w counter,d0
	tst.w d0
	bne icltt1
	addi.l #36,top_text_pos
icltt1: move.l screenbase,a1
	adda.l #16000,a1
	asl.w #3,d0
	adda.w d0,a1
	move.l #green_pixels,a0
	adda.l #224,a0
	move.w #20,d0
	move.l #0x33333333,d2
	move.l #0xcccccccc,d3
icltt2: move.l (a0),(a1)+
	move.l 4(a0),(a1)+
	and.l d2,(a1)
	move.l (a0)+,d1
	and.l d3,d1
	or.l d1,(a1)+
	and.l d2,(a1)
	move.l (a0)+,d1
	and.l d3,d1
	or.l d1,(a1)+
	adda.l #144,a1
	dbra.w d0,icltt2
	rts

intro_draw_next_top_text:
	move.l top_text_pos,a0
	move.l screenbase,a1
	adda.l #16008,a1
	move.w counter,d0
	cmpi.w #8,d0
	bmi idntt1
	subi.w #8,d0
	adda.l #1920,a1
	adda.l #18,a0
idntt1:	jsr draw_string_line
	rts

intro_test:
	move.l screenbase,a0
	adda.l #24000,a0
	move.l a0,sprites_base
	move.w #-1,sprites_h
	move.w #0,sprites_look
	rts

intro_pete_walk_in:
	move.w counter,d0
	andi.l #0xffff,d0
	move.l screenbase,a0
	adda.l #23360,a0
	move.l a0,sprites_base
	adda.l #1760,a0
	move.l a0,shadows_base
	move.l d0,d1
	divu.w #12,d1
	move.l d1,d2
	swap d2
	andi.w #15,d2
	andi.w #255,d1
	subi.w #2,d1
	move.w d1,sprites_h
	move.w d2,sprites_look
	move.l #pete_offsets,a0
	move.b (a0,d2.w),d3
	andi.w #15,d3
	addi.w #5,d3
	cmpi.w #16,d3
	bmi inpew1
	addi.w #1,d1
inpew1: andi.w #15,d3
	move.w d3,shadows_look
	move.w d1,shadows_h
	rts

intro_first_block_in:
	move.w counter,d0
	move.l screenbase,a0
	adda.l #23840,a0
	move.l a0,sprites_base+4
	adda.l #1280,a0
	move.l a0,shadows_base+4
	move.w d0,d1
	lsr.w #3,d1
	subi.w #2,d1
	move.w d1,sprites_h+2
	move.w d0,d1
	andi.w #7,d1
	addi.w #44,d1
	move.w d1,sprites_look+2
	move.w d0,d1
	addi.w #12,d1
	move.w d1,d2
	lsr.w #3,d1
	subi.w #2,d1
	move.w d1,shadows_h+2
	andi.w #7,d2
	asl.w #1,d2
	addi.w #16,d2
	move.w d2,shadows_look+2
	move.w #27,sprites_look
	rts

intro_second_block_in:
	move.w counter,d0
	move.l screenbase,a0
	adda.l #23840,a0
	move.l a0,sprites_base+8
	adda.l #1280,a0
	move.l a0,shadows_base+8
	move.w d0,d1
	lsr.w #3,d1
	subi.w #2,d1
	move.w d1,sprites_h+4
	move.w d0,d1
	andi.w #7,d1
	addi.w #52,d1
	move.w d1,sprites_look+4
	move.w d0,d1
	addi.w #12,d1
	move.w d1,d2
	lsr.w #3,d1
	subi.w #2,d1
	move.w d1,shadows_h+4
	andi.w #7,d2
	asl.w #1,d2
	addi.w #16,d2
	move.w d2,shadows_look+4
	rts

intro_pete_push_block1:
	move.l #23,d0
	sub.w counter,d0
	move.l d0,d1
	divu.w #12,d1
	addi.w #11,d1
	move.w d1,sprites_h
	swap d1
	move.w d1,d2
	addi.w #12,d2
	move.w d2,sprites_look
	move.w sprites_h,d2
	asl.w #4,d2
	move.l #pete_offsets,a0
	move.b (a0,d1.w),d3
	andi.w #255,d3
	addi.w #5,d3
	add.w d2,d3
	move.w d3,d2
	lsr.w #4,d2
	move.w d2,shadows_h
	andi.w #15,d3
	move.w d3,shadows_look
	rts

intro_block_pushed1:
	move.w #75,d0
	sub.w counter,d0
	move.w d0,d1
	lsr.w #3,d1
	move.w d1,sprites_h+2
	move.w d0,d1
	andi.w #7,d1
	addi.w #44,d1
	move.w d1,sprites_look+2
	addi.w #12,d0
	move.w d0,d1
	lsr.w #3,d1
	move.w d1,shadows_h+2
	move.w d0,d1
	andi.w #7,d1
	asl.w #1,d1
	addi.w #16,d1
	move.w d1,shadows_look+2
	rts

intro_pete_crush_block1:
	move.l #23,d0
	sub.w counter,d0
	move.l d0,d1
	divu.w #12,d1
	addi.w #9,d1
	move.w d1,sprites_h
	swap d1
	move.w d1,d2
	addi.w #12,d2
	move.w d2,sprites_look
	move.w sprites_h,d2
	asl.w #4,d2
	move.l #pete_offsets,a0
	move.b (a0,d1.w),d3
	andi.w #255,d3
	addi.w #5,d3
	add.w d2,d3
	move.w d3,d2
	lsr.w #4,d2
	move.w d2,shadows_h
	andi.w #15,d3
	move.w d3,shadows_look
	rts

intro_crushed_block1:
	move.w counter,d0
	cmpi.w #40,d0
	bne incbl1
	move.w #-3,sprites_h+2
	rts
incbl1:	lsr.w #3,d0
	addi.w #65,d0
	move.w d0,sprites_look+2
	cmpi.w #68,d0
	bne incbl2
	move.w #-3,shadows_h+2
incbl2: rts

intro_enter_flame1:
	move.l screenbase,a0
	adda.l #23360,a0
	move.l a0,sprites_base+4
	move.w #160,d0
	sub.w counter,d0
	move.w d0,d1
	andi.w #224,d1
	lsr.w #5,d1
	addi.w #15,d1
	move.w d1,sprites_h+2
	andi.w #30,d0
	lsr.w #1,d0
	addi.w #80,d0
	move.w d0,sprites_look+2
	rts

intro_exit_flame:
	move.w counter,d0
	move.w d0,d1
	andi.w #224,d1
	lsr.w #5,d1
	addi.w #15,d1
	move.w d1,sprites_h+2
	andi.w #30,d0
	lsr.w #1,d0
	addi.w #80,d0
	move.w d0,sprites_look+2
	rts

intro_enter_flame2:
	move.w counter,d0
	move.w d0,d1
	andi.w #224,d1
	lsr.w #5,d1
	subi.w #2,d1
	move.w d1,sprites_h+2
	andi.w #30,d0
	lsr.w #1,d0
	addi.w #80,d0
	move.w d0,sprites_look+2
	rts

intro_pete_push_block2:
	move.l #23,d0
	sub.w counter,d0
	move.l d0,d1
	divu.w #12,d1
	addi.w #7,d1
	move.w d1,sprites_h
	swap d1
	move.w d1,d2
	addi.w #12,d2
	move.w d2,sprites_look
	move.w sprites_h,d2
	asl.w #4,d2
	move.l #pete_offsets,a0
	move.b (a0,d1.w),d3
	andi.w #255,d3
	addi.w #5,d3
	add.w d2,d3
	move.w d3,d2
	lsr.w #4,d2
	move.w d2,shadows_h
	andi.w #15,d3
	move.w d3,shadows_look
	move.w counter,d1
	andi.w #30,d1
	lsr.w #1,d1
	move.l #flame_cycle,a0
	move.b (a0,d1.w),d2
	andi.w #255,d2
	move.w d2,sprites_look+2
	rts

intro_block_pushed2:
	move.l #23,d0
	sub.w counter,d0
	move.w d0,d1
	andi.w #252,d1
	lsr.w #3,d1
	addi.w #3,d1
	move.w d1,sprites_h+4
	move.w d0,d1
	andi.w #7,d1
	addi.w #52,d1
	move.w d1,sprites_look+4
	addi.w #12,d0
	move.w d0,d1
	lsr.w #3,d1
	addi.w #3,d1
	move.w d1,shadows_h+4
	move.w d0,d1
	andi.w #7,d1
	asl.w #1,d1
	addi.w #16,d1
	move.w d1,shadows_look+4
	move.w counter,d0
	addi.w #24,d0
	lsr.w #1,d0
	andi.w #15,d0
	move.l #flame_cycle,a0
	move.b (a0,d0.w),d2
	andi.w #255,d2
	move.w d2,sprites_look+2
	rts

intro_bonus_flash:
	move.w #95,d0
	sub.w counter,d0
	move.w d0,d1
	lsr.w #3,d1
	subi.w #9,d1
	move.w d1,sprites_h+4
	move.w d0,d1
	andi.w #7,d1
	addi.w #52,d1
	move.w d1,sprites_look+4
	addi.w #12,d0
	move.w d0,d1
	lsr.w #3,d1
	subi.w #9,d1
	move.w d1,shadows_h+4
	move.w d0,d1
	andi.w #7,d1
	asl.w #1,d1
	addi.w #16,d1
	move.w d1,shadows_look+4
	lsr.w #2,d0
	move.w d0,d1
	andi.w #1,d1
	addi.w #114,d1
	move.w d1,sprites_look+2
	mulu.w #160,d0
	addi.l #20480,d0
	add.l screenbase,d0
	move.l d0,sprites_base+4
	rts

intro_bonus_flash2:
	move.w #15,d0
	sub.w counter,d0
	move.w d0,d1
	lsr.w #2,d1
	move.w d1,d2
	andi.w #1,d1
	addi.w #114,d1
	move.w d1,sprites_look+2
	mulu.w #160,d2
	addi.l #20000,d2
	add.l screenbase,d2
	move.l d2,sprites_base+4
	move.w counter,d0
	andi.w #1,d0
	asl.w #5,d0
	addi.w #3,d0
	move.w d0,sprites_h+2
	rts

intro_first_block_in2:
	move.w #47,d0
	sub.w counter,d0
	move.l screenbase,a0
	adda.l #23840,a0
	move.l a0,sprites_base+4
	move.w d0,d1
	lsr.w #3,d1
	addi.w #14,d1
	move.w d1,sprites_h+2
	move.w d0,d1
	andi.w #7,d1
	addi.w #52,d1
	move.w d1,sprites_look+2
	move.w d0,d1
	addi.w #12,d1
	move.w d1,d2
	lsr.w #3,d1
	addi.w #14,d1
	move.w d1,shadows_h+2
	andi.w #7,d2
	asl.w #1,d2
	addi.w #16,d2
	move.w d2,shadows_look+2
	rts

intro_second_block_in2:
	move.w #39,d0
	sub.w counter,d0
	move.l screenbase,a0
	move.w d0,d1
	lsr.w #3,d1
	addi.w #15,d1
	move.w d1,sprites_h+4
	move.w d0,d1
	andi.w #7,d1
	addi.w #44,d1
	move.w d1,sprites_look+4
	move.w d0,d1
	addi.w #12,d1
	move.w d1,d2
	lsr.w #3,d1
	addi.w #15,d1
	move.w d1,shadows_h+4
	andi.w #7,d2
	asl.w #1,d2
	addi.w #16,d2
	move.w d2,shadows_look+4
	rts

intro_pete_crush_block2:
	move.w counter,d0
	andi.l #255,d0
	move.l d0,d1
	divu.w #12,d1
	addi.w #7,d1
	move.w d1,sprites_h
	swap d1
	move.w d1,d2
	move.w d2,sprites_look
	move.w sprites_h,d2
	asl.w #4,d2
	move.l #pete_offsets,a0
	move.b (a0,d1.w),d3
	andi.w #255,d3
	addi.w #5,d3
	add.w d2,d3
	move.w d3,d2
	lsr.w #4,d2
	move.w d2,shadows_h
	andi.w #15,d3
	move.w d3,shadows_look
	rts

intro_crushed_block2:
	move.w counter,d0
	cmpi.w #40,d0
	bne incbl3
	move.w #-3,sprites_h+2
	rts
incbl3:	lsr.w #3,d0
	addi.w #70,d0
	move.w d0,sprites_look+2
	cmpi.w #73,d0
	bne incbl4
	move.w #-3,shadows_h+2
incbl4: rts

intro_happy_pete:
	move.w counter,d0
	lsr.w #2,d0
	andi.w #3,d0
	move.l #happy_cycle,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	addi.w #3,d1
	move.w d1,sprites_look
	rts

intro_clear_all_text:
	move.w #-3,sprites_h
	move.w #-3,shadows_h
	move.w #-3,sprites_h+4
	move.w #-3,shadows_h+4
	move.w counter,d0
	move.l screenbase,a1
	adda.l #16000,a1
	asl.w #3,d0
	adda.w d0,a1
	move.l #green_pixels,a0
	adda.l #224,a0
	move.w #60,d0
	move.l #0x33333333,d2
	move.l #0xcccccccc,d3
iclat1: move.l (a0),(a1)+
	move.l 4(a0),(a1)+
	and.l d2,(a1)
	move.l (a0)+,d1
	and.l d3,d1
	or.l d1,(a1)+
	and.l d2,(a1)
	move.l (a0)+,d1
	and.l d3,d1
	or.l d1,(a1)+
	adda.l #144,a1
	dbra.w d0,iclat1
	rts

intro_draw_higscore_headline:
	move.l #highscore_headline,a0
	move.l screenbase,a1
	adda.l #16008,a1
	move.w counter,d0
	jsr draw_string_line
	move.l #top_texts,top_text_pos
	rts

intro_draw_highscores1:
	move.l #highscore_texts,a0
	move.l screenbase,a1
	adda.l #19208,a1
	move.w counter,d0
idhs2:	cmpi.w #8,d0
	bmi idhs1
	subi.w #8,d0
	adda.l #1600,a1
	adda.l #18,a0
	jmp idhs2
idhs1:	jsr draw_string_line
	rts

intro_clear_highscores:
	move.w counter,d0
	move.l screenbase,a1
	adda.l #19200,a1
	asl.w #3,d0
	adda.w d0,a1
	move.l #green_pixels,a0
	adda.l #384,a0
	move.w #40,d0
	move.l #0x33333333,d2
	move.l #0xcccccccc,d3
iclhs1: move.l (a0),(a1)+
	move.l 4(a0),(a1)+
	and.l d2,(a1)
	move.l (a0)+,d1
	and.l d3,d1
	or.l d1,(a1)+
	and.l d2,(a1)
	move.l (a0)+,d1
	and.l d3,d1
	or.l d1,(a1)+
	adda.l #144,a1
	dbra.w d0,iclhs1
	rts

intro_draw_highscores2:
	move.l #highscore_texts+72,a0
	move.l screenbase,a1
	adda.l #19208,a1
	move.w counter,d0
idhs4:	cmpi.w #8,d0
	bmi idhs3
	subi.w #8,d0
	adda.l #1600,a1
	adda.l #18,a0
	jmp idhs4
idhs3:	jsr draw_string_line
	rts


intro_wait:
	rts

update_intro_counter:
	addi.w #1,counter
	move.w counter,d0
	move.l intro_count_max,a0
	move.w (a0),d1
	cmp.w d0,d1
	bne updinco1
	clr.w counter
	addi.l #4,intro_jump_value
	addi.l #2,intro_count_max
	move.l intro_count_max,a0
	cmp.w #-1,(a0)
	bne updinco1
* Reset jump table
	move.l #intro_jump_values,intro_jump_value
	move.l #intro_count_values,intro_count_max
updinco1:
	rts


clear_sprites:
	move.l #sprites_h,a0
	move.w #5,d0
clsp1:	move.w #-3,(a0)+
	dbra d0,clsp1
	move.l #shadows_h,a0
	move.w #2,d0
clsp2:	move.w #-3,(a0)+
	dbra d0,clsp2
	move.l #restore_buf,a0
	move.w #0,(a0)+
	move.l a0,restore_pointer
	rts

draw_intro_sprites:
* Restore pixels
	move.l restore_pointer,a0
drins12:
	move.w -(a0),d6
	tst.w d6
	beq drins1
	subi.w #1,d6
	move.w -(a0),d7
	move.l -(a0),a1
	cmpi.w #1,d7
	bne drins13
drins14:
	suba.l #152,a1
	move.l -(a0),-(a1)
	move.l -(a0),-(a1)
	dbra d6,drins14
	jmp drins12
drins13:
	cmpi.w #2,d7
	bne drins15
drins16:
	suba.l #160,a1
	suba.l #16,a0
	movem.l (a0),d0-d3
	movem.l d0-d3,(a1)
	dbra d6,drins16
	jmp drins12
drins15:
	suba.l #160,a1
	suba.l #24,a0
	movem.l (a0),d0-d5
	movem.l d0-d5,(a1)
	dbra d6,drins15
	jmp drins12
drins1:	

	move.l #restore_buf,a0
	move.w #0,(a0)+
	move.l a0,restore_pointer

* Draw shadows
	move.w #0,d7
drins2:	move.l #shadows_look,a6
	move.w (a6,d7.w),d6
	asl.w #1,d6
	move.l #shd_height,a6
	move.w (a6,d6.w),tmp_height
	move.l #shd_width,a6
	move.w (a6,d6.w),tmp_width
	move.l #shd_offset,a6
	asl.w #1,d6
	move.l (a6,d6.w),tmp_offset
	move.l #shadows_h,a6
	move.w (a6,d7.w),d4
	move.w d4,tmp_h
	cmpi.w #20,d4
	bmi drins5
	jmp drins4
drins5:	add.w tmp_width,d4
	cmpi.w #1,d4
	bpl drins3
	jmp drins4	
drins3: 
	move.w d7,d6
	asl.w #1,d6
	move.l tmp_offset,a0
	adda.l #shadow_pixels,a0
	move.l #shadows_base,a2
	move.l (a2,d6.w),a1
	move.w tmp_h,d5
* Handle partial visibility
	move.w #0,d6
	cmpi.w #-1,d5
	bne drins17
	subi.w #1,tmp_width
	move.w #0,d5
	move.w #2,d6
	adda.w d6,a0
	jmp drins20
drins17:
	cmpi.w #-2,d5
	bne drins18
	subi.w #2,tmp_width
	move.w #0,d5
	move.w #4,d6
	adda.w d6,a0
	jmp drins20
drins18:
	move.w d5,d4
	add.w tmp_width,d4
	cmpi.w #21,d4
	bne drins19
	subi.w #1,tmp_width
	move.w #2,d6
	jmp drins20
drins19:
	cmpi.w #22,d4
	bne drins20
	subi.w #2,tmp_width
	move.w #4,d6
drins20:
	asl.w #3,d5
	adda.w d5,a1

	move.l restore_pointer,a2
	move.w tmp_height,d5
	subq.w #1,d5
	cmpi.w #1,tmp_width
	bne drins6
drins9:	move.l (a1),(a2)+
	move.w (a0)+,d0
	and.w d0,(a1)+
	and.w d0,(a1)+
	move.l (a1),(a2)+
	and.w d0,(a1)+
	and.w d0,(a1)+
	adda.l #152,a1
	adda.w d6,a0
	dbra.w d5,drins9
	jmp drins8
drins6:	cmpi.w #2,tmp_width
	bne drins7
drins11:
	move.l (a1),(a2)+
	move.w (a0)+,d0
	and.w d0,(a1)+
	and.w d0,(a1)+
	move.l (a1),(a2)+
	and.w d0,(a1)+
	and.w d0,(a1)+
	move.l (a1),(a2)+
	move.w (a0)+,d0
	and.w d0,(a1)+
	and.w d0,(a1)+
	move.l (a1),(a2)+
	and.w d0,(a1)+
	and.w d0,(a1)+
	adda.l #144,a1
	adda.w d6,a0
	dbra.w d5,drins11
	jmp drins8

drins7: move.l (a1),(a2)+
	move.w (a0)+,d0
	and.w d0,(a1)+
	and.w d0,(a1)+
	move.l (a1),(a2)+
	and.w d0,(a1)+
	and.w d0,(a1)+
	move.l (a1),(a2)+
	move.w (a0)+,d0
	and.w d0,(a1)+
	and.w d0,(a1)+
	move.l (a1),(a2)+
	and.w d0,(a1)+
	and.w d0,(a1)+
	move.l (a1),(a2)+
	move.w (a0)+,d0
	and.w d0,(a1)+
	and.w d0,(a1)+
	move.l (a1),(a2)+
	and.w d0,(a1)+
	and.w d0,(a1)+
	adda.l #136,a1
	adda.w d6,a0
	dbra.w d5,drins7
	
drins8: move.l a1,(a2)+
	move.w tmp_width,(a2)+
	move.w tmp_height,(a2)+
	move.l a2,restore_pointer

drins4:	addq.w #2,d7
	cmp.w #6,d7
	beq drins10
	jmp drins2
drins10:

* Draw sprites
	move.w #0,d7

drins32:
	move.l #sprites_look,a6
	move.w (a6,d7.w),d6
	asl.w #1,d6
	move.l #spr_height,a6
	move.w (a6,d6.w),tmp_height
	move.l #spr_width,a6
	move.w (a6,d6.w),tmp_width
	move.l #spr_offset,a6
	asl.w #1,d6
	move.l (a6,d6.w),tmp_offset
	move.l #sprites_h,a6
	move.w (a6,d7.w),d4
	move.w d4,tmp_h
	cmpi.w #20,d4
	bmi drins35
	jmp drins34
drins35:
	add.w tmp_width,d4
	cmpi.w #1,d4
	bpl drins33
	jmp drins34	
drins33: 
	move.w d7,d6
	asl.w #1,d6
	move.l tmp_offset,a0
	adda.l #sprite_pixels,a0
	move.l #sprites_base,a2
	move.l (a2,d6.w),a1
	move.w tmp_h,d5
* Handle partial visibility
	move.w #0,d6
	cmpi.w #-1,d5
	bne drins47
	subi.w #1,tmp_width
	move.w #0,d5
	move.w #10,d6
	adda.w d6,a0
	jmp drins50
drins47:
	cmpi.w #-2,d5
	bne drins48
	subi.w #2,tmp_width
	move.w #0,d5
	move.w #20,d6
	adda.w d6,a0
	jmp drins50
drins48:
	move.w d5,d4
	add.w tmp_width,d4
	cmpi.w #21,d4
	bne drins49
	subi.w #1,tmp_width
	move.w #10,d6
	jmp drins50
drins49:
	cmpi.w #22,d4
	bne drins50
	subi.w #2,tmp_width
	move.w #20,d6
drins50:
	asl.w #3,d5
	adda.w d5,a1

	move.l restore_pointer,a2
	move.w tmp_height,d5
	subq.w #1,d5
	cmpi.w #1,tmp_width
	bne drins36
drins39:
	move.l (a1),(a2)+
	move.w (a0)+,d0
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.l (a1),(a2)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	adda.l #152,a1
	adda.w d6,a0
	dbra.w d5,drins39
	jmp drins38
drins36:
	cmpi.w #2,tmp_width
	bne drins37
drins41:
	move.l (a1),(a2)+
	move.w (a0)+,d0
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.l (a1),(a2)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.l (a1),(a2)+
	move.w (a0)+,d0
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.l (a1),(a2)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	adda.l #144,a1
	adda.w d6,a0
	dbra.w d5,drins41
	jmp drins38

drins37:
	move.l (a1),(a2)+
	move.w (a0)+,d0
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.l (a1),(a2)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.l (a1),(a2)+
	move.w (a0)+,d0
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.l (a1),(a2)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.l (a1),(a2)+
	move.w (a0)+,d0
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.l (a1),(a2)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	move.w (a1),d1
	and.w d0,d1
	or.w (a0)+,d1
	move.w d1,(a1)+
	adda.l #136,a1
	adda.w d6,a0
	dbra.w d5,drins37
	
drins38:
	move.l a1,(a2)+
	move.w tmp_width,(a2)+
	move.w tmp_height,(a2)+
	move.l a2,restore_pointer

drins34:
	addq.w #2,d7
	cmp.w #6,d7
	beq drins40
	jmp drins32
drins40:

	rts

********************** String drawing

draw_string_line:
* Line count 0-7 in d0
* String data in a0
* Destination in a1
	move.w d0,d3
	mulu.w #160,d3
drawst2:
	move.b (a0)+,d1
	beq drawst1
	andi.w #255,d1
	move.l #char_table,a2
	move.b (a2,d1.w),d2
	andi.w #255,d2
	asl.w #3,d2
	add.w d0,d2
	asl.w #1,d2
	move.l #font,a2
	move.w (a2,d2.w),d1
	move.w d1,d2
	lsr.w #8,d2
	or.w d2,(a1,d3)
	eori.w #0xffff,d2
	and.w d2,2(a1,d3)
	and.w d2,4(a1,d3)
	and.w d2,6(a1,d3)
	lsr.w #1,d2
	ori.w #0x8000,d2
	addi.w #160,d3
	and.w d2,(a1,d3)
	and.w d2,2(a1,d3)
	and.w d2,4(a1,d3)
	and.w d2,6(a1,d3)
	addi.w #8,d3
	move.w d1,d2
	asl.w #7,d2
	eori.w #0xffff,d2
	and.w d2,(a1,d3)
	and.w d2,2(a1,d3)
	and.w d2,4(a1,d3)
	and.w d2,6(a1,d3)
	eori.w #0xffff,d2
	asl.w #1,d2
	subi.w #160,d3
	or.w d2,(a1,d3)
	eori.w #0xffff,d2
	and.w d2,2(a1,d3)
	and.w d2,4(a1,d3)
	and.w d2,6(a1,d3)
	bra drawst2
drawst1: rts

draw_level_string:
	
	rts

********************** Music

setup_intro_song:
	move.l #song_voice1,voice1_start
	move.l #song_end1,d0
	sub.l #song_voice1,d0
	move.w d0,voice1_pos
	move.l #song_voice2,voice2_start
	move.l #song_end2,d0
	sub.l #song_voice2,d0
	move.w d0,voice2_pos
	jmp final_music_setup

setup_ingame_song:
	move.l #ingame_voice1,voice1_start
	move.l #ingame_end1,d0
	sub.l #ingame_voice1,d0
	move.w d0,voice1_pos
	move.l #ingame_voice2,voice2_start
	move.l #ingame_end2,d0
	sub.l #ingame_voice2,d0
	move.w d0,voice2_pos
	jmp final_music_setup

setup_party_song:
	move.l #party_voice1,voice1_start
	move.l #party_end1,d0
	sub.l #party_voice1,d0
	move.w d0,voice1_pos
	move.l #party_voice2,voice2_start
	move.l #party_end2,d0
	sub.l #party_voice2,d0
	move.w d0,voice2_pos
	jmp final_music_setup

final_music_setup:
	move.w #0,voice1_length
	move.w #0,voice1_count
	move.w #0,voice1_max_arpeggio
	move.w #0,voice2_length
	move.w #0,voice2_count
	move.w #0,voice2_max_arpeggio
	rts


* Music playing routine
play_music:
	move.l voice1_start,a0
	move.w voice1_pos,d0
	move.w voice1_count,d1
	cmp.w voice1_length,d1
	bne playm1
	add.w voice1_max_arpeggio,d0
	move.b (a0,d0.w),d1
	cmpi.b #255,d1
	bne playm2
* Restart song
	move.w #0,d0
	move.b (a0),d1
playm2: andi.w #255,d1
	move.w d1,voice1_length
	move.w #0,voice1_count
	move.b 1(a0,d0.w),d1
	andi.w #255,d1
	move.w d1,voice1_max_arpeggio
	move.w #0,voice1_arpeggio
	addi.w #2,d0
	move.w d0,voice1_pos
	move.w #0,d1
playm1: 
* Set volume
	move.l #envelope1,a1
	move.b (a1,d1.w),sound_data+9
	addi.w #1,d1
	move.w d1,voice1_count
* Set frequency
	move.w voice1_arpeggio,d1
	add.w d0,d1
	move.b (a0,d1.w),d2
	andi.w #255,d2
	asl.w #1,d2
	move.l #freq_table,a1
	move.b (a1,d2.w),sound_data+1
	move.b 1(a1,d2.w),sound_data+3

	move.w voice1_arpeggio,d1
	addi.w #1,d1
	cmp.w voice1_max_arpeggio,d1
	bne playm3
	move.w #0,d1
playm3: move.w d1,voice1_arpeggio

	move.l voice2_start,a0
	move.w voice2_pos,d0
	move.w voice2_count,d1
	cmp.w voice2_length,d1
	bne playm4
	add.w voice2_max_arpeggio,d0
	move.b (a0,d0.w),d1
	cmpi.b #255,d1
	bne playm5
* Restart song
	move.w #0,d0
	move.b (a0),d1
playm5: andi.w #255,d1
	move.w d1,voice2_length
	move.w #0,voice2_count
	move.b 1(a0,d0.w),d1
	andi.w #255,d1
	move.w d1,voice2_max_arpeggio
	move.w #0,voice2_arpeggio
	addi.w #2,d0
	move.w d0,voice2_pos
	move.w #0,d1
playm4: 
* Set volume
	move.l #envelope2,a1
	move.b (a1,d1.w),sound_data+11
	addi.w #1,d1
	move.w d1,voice2_count
* Set frequency
	move.w voice2_arpeggio,d1
	add.w d0,d1
	move.b (a0,d1.w),d2
	andi.w #255,d2
	asl.w #1,d2
	move.l #freq_table,a1
	move.b (a1,d2.w),sound_data+5
	move.b 1(a1,d2.w),sound_data+7

	move.w voice2_arpeggio,d1
	addi.w #1,d1
	cmp.w voice2_max_arpeggio,d1
	bne playm6
	move.w #0,d1
playm6: move.w d1,voice2_arpeggio

	rts


push_sound_data:
	pea sound_data
	move.w #32,-(sp)
	trap #14
	addq.l #6,sp

	rts

********************** Sound effect routines

manage_sound:
	move.w new_sound,d0
	tst.w d0
	beq maso0
	move.w #0,new_sound
	cmpi.w #2,d0
	bne maso2
	cmpi.w #2,sound_type
	bpl maso0
maso2:	move.w d0,sound_type
	movea.l #sound_durations,a0
	move.b (a0,d0.w),d1
	andi.w #255,d1
	move.w d1,sound_countdown
maso0:	move.w sound_type,d0
	tst.w d0
	bne maso3
	move.b #0,sound_data+19
	rts
maso3:	asl.w #2,d0
	movea.l #sound_jumptable,a0
	move.l (a0,d0.w),a1
	jsr (a1)
	subi.w #1,sound_countdown
	tst.w sound_countdown
	bpl maso1
	move.w #0,sound_type
maso1:	rts

sound_handle_stop:
	move.w sound_countdown,d0
	move.w d0,d1
	asl.w #1,d1
	add.w d0,d1
	move.b d1,sound_data+19
	move.b #80,sound_data+15
	move.b #0,sound_data+17
	move.b #248,sound_data+13
	rts

sound_handle_slide:
	move.w sound_countdown,d0
	move.w d0,d1
	lsr.w #4,d0
	addi.w #3,d0
	move.b d0,sound_data+19
	lsr.w #2,d1
	move.b d1,sound_data+21
	move.b #220,sound_data+13
	rts

sound_handle_break:
	move.w sound_countdown,d0
	lsr.w #2,d0
	move.b d0,sound_data+19
	move.w random_pos,d0
	movea.l #random_table,a0
	move.b (a0,d0.w),d1
	addi.w #1,d0
	andi.w #255,d0
	move.w d0,random_pos
	move.b d1,sound_data+15
	andi.w #31,d1
	move.b d1,sound_data+21
	move.b #0,sound_data+17
	move.w counter,d0
	btst #0,d0
	beq soha0
	move.b #220,sound_data+13
	rts
soha0:	move.b #248,sound_data+13
	rts

sound_handle_coin:
	move.w sound_countdown,d0
	move.w d0,d1
	lsr.w #2,d0
	move.b d0,sound_data+19
	andi.w #15,d1
	asl.w #4,d1
	move.b d1,sound_data+15
	move.b #0,sound_data+17
	move.b #248,sound_data+13
	rts

sound_handle_snuff:
	move.w sound_countdown,d0
	move.w d0,d1
	lsr.w #2,d0
	move.b d0,sound_data+19
	andi.w #15,d1
	eori.w #15,d1
	asl.w #3,d1
	addi.w #128,d1
	move.b d1,sound_data+15
	move.b #1,sound_data+17
	move.b #248,sound_data+13
	rts

sound_handle_done:
	move.w sound_countdown,d0
	andi.w #7,d0
	addi.w #4,d0
	move.b d0,sound_data+19
	move.b #60,sound_data+15
	move.b #0,sound_data+17
	move.b #248,sound_data+13
	rts

sound_handle_newflame:
	move.w sound_countdown,d0
	lsr.w #2,d0
	eori.w #15,d0
	move.b d0,sound_data+19
	move.w random_pos,d0
	movea.l #random_table,a0
	move.b (a0,d0.w),d1
	addi.w #1,d0
	andi.w #255,d0
	move.w d0,random_pos
	andi.w #15,d1
	move.b d1,sound_data+21
	move.b #220,sound_data+13
	rts

sound_handle_death:
	move.w sound_countdown,d0
	move.w d0,d1
	lsr.w #2,d0
	move.b d0,sound_data+19
	eori.w #63,d1
	move.w d1,d0
	asl.w #6,d0
	move.b d0,sound_data+15
	move.w d1,d0
	lsr.w #2,d0
	move.b d0,sound_data+17
	move.b #248,sound_data+13
	rts



********************** Various in-game drawing routines

draw_score:
	movea.l current_screen,a1
	adda.l #160,a1
	move.w score_bcd,d0
	move.w d0,d1
	andi.w #15,d1
	move.w d1,tmp_buf+6
	andi.w #0xfff0,d0
	lsr.w #4,d0
	move.w d0,d1
	andi.w #15,d1
	move.w d1,tmp_buf+4
	andi.w #0xfff0,d0
	lsr.w #4,d0
	move.w d0,d1
	andi.w #15,d1
	move.w d1,tmp_buf+2
	andi.w #0xf0,d0
	lsr.w #4,d0
	move.w d0,tmp_buf
	movea.l #tmp_buf,a2
	move.w #3,d0
drasc1:	move.w (a2)+,d1
	mulu.w #140,d1
	addi.l #digit_pixels,d1
	move.l d1,a0
	move.l a1,a3
	adda.l #32,a3
	move.l a1,a4
	move.w #13,d1
drasc2:	move.w (a0)+,d2
	move.w (a3)+,d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a4)+
	move.w (a3)+,d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a4)+	
	move.w (a3)+,d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a4)+	
	move.w (a3)+,d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a4)+
	adda.l #152,a3
	adda.l #152,a4
	dbra.w d1,drasc2
	adda.l #8,a1
	dbra.w d0,drasc1
	rts

draw_music:
	movea.l current_screen,a1
	move.l a1,a2
	adda.l #208,a1
	adda.l #240,a2
	tst.w music_on
	beq dramu1
	move.l #digit_pixels+1540,a0
	bra dramu2
dramu1: move.l #digit_pixels+1680,a0
dramu2: move.w #13,d0
dramu3:	move.w (a0)+,d2
	move.w (a1)+,d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a2)+
	move.w (a1)+,d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a2)+
	move.w (a1)+,d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a2)+
	move.w (a1)+,d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a2)+
	adda.l #152,a1
	adda.l #152,a2
	dbra.w d0,dramu3
	rts

draw_lives:
	movea.l current_screen,a1
	adda.l #296,a1
	move.l a1,a2
	move.l a2,a3
	suba.l #32,a2
	move.w #13,d0
drali1:	move.l (a2)+,(a3)+
	move.l (a2)+,(a3)+
	move.l (a2)+,(a3)+
	move.l (a2)+,(a3)+
	move.l (a2)+,(a3)+
	move.l (a2)+,(a3)+
	adda.l #136,a2
	adda.l #136,a3
	dbra.w d0,drali1
	move.w lives,d0
	tst.w d0
	beq drali2
	subi.w #1,d0
drali3: movea.l #digit_pixels+1400,a0
	move.l a1,a2
	move.w #13,d1
drali4: move.w (a0)+,d2
	move.w (a2),d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a2)+
	move.w (a2),d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a2)+
	move.w (a2),d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a2)+
	move.w (a2),d3
	and.w d2,d3
	or.w (a0)+,d3
	move.w d3,(a2)+
	adda.l #152,a2
	dbra.w d1,drali4
	adda.l #8,a1
	dbra.w d0,drali3
drali2:	rts


********************** Game over handling

game_over:
	pea sound_off
	move.w #32,-(sp)
	trap #14
	addq.l #6,sp

	move.w #-1,-(sp)
	move.l screenbase,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	adda.l #12,sp

	movea.l screenbase,a0
	adda.l #12840,a0
	move.w #39,d0
gaov1:	move.w #19,d1
gaov0:	move.l #0,(a0)+
	dbra.w d1,gaov0
	adda.l #80,a0
	dbra.w d0,gaov1

	move.w #0,counter
gaov3:	move.l #gameover_text,a0
	move.l screenbase,a1
	adda.l #15368,a1
	move.w counter,d0
	jsr draw_string_line
	addi.w #1,counter
	cmpi.w #7,counter
	bne gaov3

gaov2:	jsr wait_for_vblank
	addi.w #1,counter
	cmpi.w #180,counter
	bne gaov2

* Check for highscore
	move.w score_bcd,d0
	cmp.w highscores+14,d0
	bls gaov6
	
	movea.l screenbase,a0
	adda.l #12840,a0
	move.w #39,d0
gaov9:	move.w #19,d1
gaov8:	move.l #0,(a0)+
	dbra.w d1,gaov8
	adda.l #80,a0
	dbra.w d0,gaov9

	move.w #0,counter
gaov10:	move.l #yourname_text,a0
	move.l screenbase,a1
	adda.l #14088,a1
	move.w counter,d0
	jsr draw_string_line
	addi.w #1,counter
	cmpi.w #7,counter
	bne gaov10

	move.w #0,cursor_pos
	move.b #46,highscore_texts+157
	move.b #46,highscore_texts+158
	move.b #46,highscore_texts+159

gaov11:	movea.l screenbase,a0
	adda.l #16384,a0
	move.w #10,d0
gaov14:	move.w #7,d1
gaov13:	move.l #0,(a0)+
	dbra.w d1,gaov13
	adda.l #128,a0
	dbra.w d0,gaov14

	pea super_read_keyboard
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp
	movea.l #highscore_texts+157,a0
	move.w cursor_pos,d2
	move.w previous_joy,d1
	move.b joysticks,d0
	or.b joysticks+1,d0
	or.b joysticks+2,d0
	btst #7,d0
	bne gaov15
	btst #2,d0
	beq gaov16
	btst #2,d1
	bne gaov16
	tst.w cursor_pos
	beq gaov16
	subi.w #1,cursor_pos
gaov16: btst #3,d0
	beq gaov17
	btst #3,d1
	bne gaov17
	cmpi.w #2,cursor_pos
	beq gaov17
	addi.w #1,cursor_pos
gaov17:	btst #1,d0
	beq gaov18
	btst #1,d1
	bne gaov18
	subi.b #1,(a0,d2.w)
	cmpi.b #64,(a0,d2.w)
	bne gaov19
	move.b #46,(a0,d2.w)
gaov19: cmpi.b #45,(a0,d2.w)
	bne gaov18
	move.b #90,(a0,d2.w)
gaov18: btst #0,d0
	beq gaov20
	btst #0,d1
	bne gaov20
	addi.b #1,(a0,d2.w)
	cmpi.b #91,(a0,d2.w)
	bne gaov21
	move.b #46,(a0,d2.w)
gaov21: cmpi.b #47,(a0,d2.w)
	bne gaov20
	move.b #65,(a0,d2.w)
gaov20: 
	move.w d0,previous_joy

	movea.l #char_table,a0
	movea.l screenbase,a1
	adda.l #16704,a1
	movea.l #font,a3
	move.w #6,d0
gaov22:	move.w #2,d1
	movea.l #highscore_texts+157,a2
gaov23: move.b (a2)+,d2
	andi.w #255,d2
	move.b (a0,d2.w),d3
	andi.w #255,d3
	asl.w #4,d3
	move.b (a3,d3.w),d4
	move.b d4,1(a1)
	move.b 1(a3,d3.w),d4
	move.b d4,8(a1)
	adda.l #8,a1
	dbra.w d1,gaov23
	adda.l #136,a1
	adda.l #2,a3
	dbra.w d0,gaov22


	addi.w #1,counter
	move.w counter,d0
	movea.l #cursor_colors,a0
	asl.w #1,d0
	andi.w #56,d0
	move.l (a0,d0.w),d2
	move.l 4(a0,d0.w),d3

	movea.l screenbase,a1
	adda.l #16384,a1
	move.w cursor_pos,d0
	asl.w #3,d0
	adda.w d0,a1
	movea.l #cursor_data,a0
	move.w #10,d0
gaov12:	move.l (a0)+,d1
	and.l d2,d1
	or.l d1,(a1)+
	move.l (a0)+,d1
	and.l d3,d1
	or.l d1,(a1)+
	move.l (a0)+,d1
	and.l d2,d1
	or.l d1,(a1)+
	move.l (a0)+,d1
	and.l d3,d1
	or.l d1,(a1)+
	adda.l #144,a1
	dbra.w d0,gaov12

	jsr wait_for_vblank
	bra gaov11


gaov15:	move.w score_bcd,d0
	move.w d0,d1
	move.w #3,d3
	movea.l #highscore_texts+152,a0
gaov7:	move.w d1,d2
	andi.w #15,d2
	ori.w #48,d2
	move.b d2,-(a0)
	lsr.w #4,d1
	dbra.w d3,gaov7

	move.w #7,d1
	movea.l #highscores+14,a0
	movea.l #highscores+16,a1
	movea.l #highscore_texts+130,a2
	movea.l #highscore_texts+148,a3
gaov5:	cmp.w (a0),d0
	bls gaov6
	move.w (a0),d2
	move.w (a1),(a0)
	move.w d2,(a1)
	move.w #12,d3
gaov4:	move.b (a2),d2
	move.b (a3),(a2)+
	move.b d2,(a3)+
	dbra.w d3,gaov4
	suba.l #31,a2
	suba.l #31,a3
	suba.l #2,a0
	suba.l #2,a1
	dbra.w d1,gaov5

gaov6:	rts


********************** Various setup and reset routines

draw_curtain:
	move.w #0,counter

drawc5:
 	move.w #39,d0
	move.l #curtain_base,a0
	move.l screenbase,a1
	move.l #green_pixels,a2
	move.w #0xff00,d2
drawc1: move.b (a0)+,d1
	andi.w #255,d1
	add.w counter,d1
	subi.w #14,d1
	bmi drawc4	
	cmpi.w #128,d1
	bge drawc2
	move.w d1,d3
	asl.w #3,d3
	move.w d1,d4
	addi.w #72,d4
	mulu.w #160,d4
	eori.w #0xffff,d2
	and.w d2,(a1,d4.w)
	and.w d2,2(a1,d4.w)
	and.w d2,4(a1,d4.w)
	and.w d2,6(a1,d4.w)
	eori.w #0xffff,d2
	move.w (a2,d3.w),d5
	and.w d2,d5
	or.w d5,(a1,d4.w)
	move.w 2(a2,d3.w),d5
	and.w d2,d5
	or.w d5,2(a1,d4.w)
	move.w 4(a2,d3.w),d5
	and.w d2,d5
	or.w d5,4(a1,d4.w)
	move.w 6(a2,d3.w),d5
	and.w d2,d5
	or.w d5,6(a1,d4.w)

drawc2: subi.w #31,d1
	bmi drawc4
	cmpi.w #128,d1
	bge drawc4
	move.w d1,d3
	asl.w #3,d3
	move.w d1,d4
	addi.w #72,d4
	mulu.w #160,d4
	eori.w #0xffff,d2
	and.w d2,(a1,d4.w)
	and.w d2,2(a1,d4.w)
	and.w d2,4(a1,d4.w)
	and.w d2,6(a1,d4.w)
	eori.w #0xffff,d2
	move.w (a2,d3.w),d5
	and.w d2,d5
	or.w d5,(a1,d4.w)
	move.w 2(a2,d3.w),d5
	and.w d2,d5
	or.w d5,2(a1,d4.w)
	move.w 4(a2,d3.w),d5
	and.w d2,d5
	or.w d5,4(a1,d4.w)
	move.w 6(a2,d3.w),d5
	and.w d2,d5
	or.w d5,6(a1,d4.w)

drawc4: eori.w #0xffff,d2
	cmpi.w #0xff00,d2
	bne drawc3
	adda.l #8,a1
drawc3:	
	dbra.w d0,drawc1

	jsr play_music
	jsr wait_for_vblank
	jsr push_sound_data
	addi.w #2,counter
	cmpi.w #176,counter
	bne drawc5
	

	rts


clear_game_screen:
* Adjust physical screen pointer
	move.w #-1,-(sp)
	move.l screenbase,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	adda.l #12,sp

	move.w #0,counter
clega0:
 	move.w #39,d0
	move.l #curtain_base,a0
	move.l screenbase,a1
	move.w #0xff00,d2
clega1: move.b (a0)+,d1
	andi.w #255,d1
	add.w counter,d1
	subi.w #14,d1
	bmi clega4	
	cmpi.w #200,d1
	bge clega2
	move.w d1,d3
	asl.w #3,d3
	move.w d1,d4
	mulu.w #160,d4
	and.w d2,(a1,d4.w)
	and.w d2,2(a1,d4.w)
	and.w d2,4(a1,d4.w)
	and.w d2,6(a1,d4.w)

clega2: subi.w #31,d1
	bmi clega4
	cmpi.w #200,d1
	bge clega4
	move.w d1,d3
	asl.w #3,d3
	move.w d1,d4
	mulu.w #160,d4
	and.w d2,(a1,d4.w)
	and.w d2,2(a1,d4.w)
	and.w d2,4(a1,d4.w)
	and.w d2,6(a1,d4.w)

clega4: eori.w #0xffff,d2
	cmpi.w #0xff00,d2
	bne clega3
	adda.l #8,a1
clega3:	
	dbra.w d0,clega1

	jsr wait_for_vblank
	addi.w #2,counter
	cmpi.w #256,counter
	bne clega0

	rts


draw_logo:
* Clear screen
	move.w #7999,d0
	move.l screenbase,a1
prei1:	clr.l (a1)+
	dbra d0,prei1

* Make sure physical screen pointer is correct
	move.w #-1,-(sp)
	move.l screenbase,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	adda.l #12,sp

* Change palette
	pea intro_palette
	move.w #6,-(sp)
	trap #14
	addq.l #6,sp

* Draw logo
	move.l #logo_pixels,a0
	move.l screenbase,d0
	addi.l #24,d0
	move.l d0,a1
	move.w #63,d1
prei2:	move.w #25,d2
prei3:	move.l (a0)+,(a1)+
	dbra d2,prei3
	adda.l #56,a1
	dbra d1,prei2

	rts
	

draw_credits:

* Draw credits text
	move.l screenbase,d0
	addi.l #15048,d0
	move.l d0,text_out_pos
	move.w #0,counter
	move.w #0,counter2
	move.l #credits_text,text_in_pos

prei7:	move.l text_in_pos,a0
	move.l text_out_pos,a1
	move.w counter,d0

	jsr draw_string_line

	addq.w #1,counter
	move.w counter,d0
	cmpi.w #8,d0
	bne prei7
	clr.w counter
	addi.l #1440,text_out_pos
	addi.l #18,text_in_pos
	addq.w #1,counter2
	move.w counter2,d0
	cmpi.w #7,d0
	bne prei7

* Wait 5 seconds
	move.w #CREDITS_WAIT,vblank_count
prei8:	jsr wait_for_vblank
	subi.w #1,vblank_count
	bne prei8

	rts



show_splash:
* Get screen address
	move.w    #2,-(sp)
	trap      #14
	addq.l    #2,sp
    	move.l d0,screenbase
	move.l #splash_pixels,d0
	andi.l #0xffffff00,d0
	move.l d0,backbuffer

* Save old palette
	move.w #0,counter

intro7:	move.l #splash_palette,a0
	add.w counter,a0
	move.w (a0),-(sp)
	move.w counter,d0
	lsr.w #1,d0
	move.w d0,-(sp)
	move.w #7,-(sp)
	trap #14
	addq.l #6,sp
	move.l #old_palette,a0
	add.w counter,a0
	move.w d0,(a0)
	move.w counter,d0
	add.w #2,d0
	move.w d0,counter
	cmpi.w #32,d0
	bne intro7

* Set low resolution mode
	move.w #0, -(sp)
	move.l #-1, -(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	add.l #12,sp

	move.w #7999,d0
	move.l screenbase,a1
	move.l #splash_pixels,a0
intro1: move.l (a0)+,(a1)+
	dbra d0,intro1

* Wait for 5 seconds or joystick press
	move.w #SPLASH_WAIT,vblank_count
* Wait for vertical blank
intro2: jsr wait_for_vblank	

	move.b joysticks,d0
	or.b joysticks+1,d0
	btst #7,d0
	bne intro3

	subi.w #1,vblank_count
	bne intro2

intro3:	rts


wait_for_vblank:
	move.w #37,-(sp)
    	trap #14
    	addq.w #2,sp
	rts

setup_joystick:
* Activate joystick
	move.l   #joy_on,-(sp)
   	move.w   #1,-(sp)
   	move.w   #25,-(sp)
   	trap   #14
   	addq.l   #8,sp 

* Turn off keyboard clicks
	pea super_key_click_off
	move.w #38,-(sp)
	trap #14
	addq.l #6,sp

* Handle joystick input
	move.w   #34,-(sp)
   	trap   #14
   	addq.l   #2,sp
	move.l   d0,ikbd_vec
	move.l   d0,a0
	move.l   24(a0),old_joy   
	move.l   #read_joy,24(a0)
	rts


* Read joystick routine
read_joy:
   	move.b 1(a0),joysticks
	move.b 2(a0),joysticks+1
   	rts


restore_system:
* Restore mouse function
	move.l   #mouse_on,-(sp)
   	move.w   #0,-(sp)
   	move.w   #25,-(sp)
   	trap   #14
   	addq.l   #8,sp

   	move.l   ikbd_vec,a0
   	move.l   old_joy,24(a0)

* Restore palette
	pea	old_palette
	move.w    #6,-(sp)
	trap      #14
	addq.l	#6,sp
* Restore physical screen address
	move.w #0,-(sp)
	move.l screenbase,-(sp)
	move.l #-1,-(sp)
	move.w #5,-(sp)
	trap #14
	adda.l #12,sp

* Turn off sound
	pea sound_off
	move.w #32,-(sp)
	trap #14
	addq.l #6,sp

	rts

*************************** Supervisor mode routines

super_key_click_off:
	bclr.b #0,0x484
	rts

* Use SPACE + WASD keys to simulate a third joystick
super_read_keyboard:
	move.b 0xffffc02,d0
	move.b #0,d1
	cmpi.b #64,d0
	bpl reke4
	cmpi.b #57,d0
	bne reke0
	move.b #128,d1
reke0:	cmpi.b #17,d0
	bne reke1
	move.b #1,d1
reke1:	cmpi.b #31,d0
	bne reke2
	move.b #2,d1
reke2:	cmpi.b #30,d0
	bne reke3
	move.b #4,d1
reke3:	cmpi.b #32,d0
	bne reke4
	move.b #8,d1
reke4:	move.b d1,joysticks+2
	rts

*************************** Data section

.align 4
intro_jump_value: dc.l 0
intro_jump_values:
	dc.l intro_draw_fire_button_text
	dc.l intro_draw_next_top_text
	dc.l intro_pete_walk_in
	dc.l intro_first_block_in
	dc.l intro_second_block_in
	dc.l intro_clear_top_text

	dc.l intro_draw_next_top_text
	dc.l intro_pete_push_block1
	dc.l intro_block_pushed1
	dc.l intro_wait
	dc.l intro_clear_top_text

	dc.l intro_draw_next_top_text
	dc.l intro_pete_crush_block1
	dc.l intro_crushed_block1
	dc.l intro_wait
	dc.l intro_clear_top_text

	dc.l intro_draw_next_top_text
	dc.l intro_enter_flame1
	dc.l intro_exit_flame
	dc.l intro_wait
	dc.l intro_clear_top_text

	dc.l intro_draw_next_top_text
	dc.l intro_enter_flame2
	dc.l intro_pete_push_block2
	dc.l intro_block_pushed2
	dc.l intro_bonus_flash
	dc.l intro_bonus_flash2
	dc.l intro_wait
	dc.l intro_clear_top_text

	dc.l intro_draw_next_top_text
	dc.l intro_first_block_in2
	dc.l intro_second_block_in2
	dc.l intro_pete_crush_block2
	dc.l intro_crushed_block2
	dc.l intro_clear_top_text

	dc.l intro_draw_next_top_text
	dc.l intro_happy_pete
	dc.l intro_clear_all_text

	dc.l intro_draw_higscore_headline
	dc.l intro_draw_highscores1
	dc.l intro_wait
	dc.l intro_clear_highscores
	dc.l intro_draw_highscores2
	dc.l intro_wait
	dc.l intro_clear_highscores
	dc.l intro_clear_top_text

	dc.l -1
intro_count_max: dc.l 0
intro_count_values:
	dc.w 8,16,181,93,65,19, 16,24,16,100,19, 16,24,41,100,19, 16,160,161,30,19
	dc.w 16,161,18,24,96,16,100,19, 16,48,36,67,41,19, 16,250,19
	dc.w 8,32,200,19,32,200,19,19
	dc.w -1

.align 8
padding_256: ds.b 256
splash_pixels: .incbin "splash.dat"
splash_palette:
	dc.w 0x0,0x777,0x600,0x477,0x030,0x060,0x006,0x770
	dc.w 0x530,0x320,0x650,0x222,0x333,0x474,0x337,0x555
screenbase: dc.l 0
backbuffer: dc.l 0
current_screen: dc.l 0

intro_palette:
	dc.w 0x0,0x777,0x600,0x177,0x141,0x060,0x006,0x770
	dc.w 0x530,0x320,0x733,0x222,0x444,0x474,0x337,0x666

level_palettes:
	dc.w 0x0,0x777,0x600,0x177,0x141,0x060,0x006,0x770
	dc.w 0x530,0x320,0x100,0x222,0x444,0x474,0x337,0x666

	dc.w 0x0,0x777,0x600,0x177,0x030,0x060,0x006,0x770
	dc.w 0x530,0x320,0x733,0x222,0x444,0x474,0x337,0x666

	dc.w 0x0,0x777,0x600,0x177,0x650,0x060,0x006,0x770
	dc.w 0x530,0x320,0x111,0x222,0x444,0x474,0x337,0x666

	dc.w 0x0,0x777,0x600,0x177,0x750,0x060,0x006,0x770
	dc.w 0x530,0x320,0x131,0x222,0x444,0x474,0x337,0x666

	dc.w 0x0,0x777,0x600,0x177,0x750,0x060,0x006,0x770
	dc.w 0x530,0x320,0x733,0x222,0x444,0x474,0x337,0x666

	dc.w 0x0,0x777,0x600,0x177,0x040,0x060,0x006,0x770
	dc.w 0x530,0x320,0x733,0x222,0x444,0x474,0x337,0x666

	dc.w 0x0,0x777,0x600,0x177,0x506,0x060,0x006,0x770
	dc.w 0x530,0x320,0x304,0x222,0x444,0x474,0x337,0x666

	dc.w 0x0,0x777,0x600,0x177,0x030,0x151,0x006,0x770
	dc.w 0x530,0x320,0x733,0x222,0x444,0x474,0x337,0x666


* Pixel data
logo_pixels: .incbin "logo.dat"
green_pixels: .incbin "greens.dat"
digit_pixels: .incbin "digits.dat"
sprite_pixels: .incbin "sprites.dat"

celebration_pixels: .incbin "celebration.dat"

character_data: .incbin "characters.dat"
more_characters:
	ds.b 1024
dirt_data: .incbin "dirt.dat"
lego_data: .incbin "lego.dat"
beach_data: .incbin "beach.dat"
forest_data: .incbin "forest.dat"
weird_data: .incbin "weird.dat"
dice_data: .incbin "dice.dat"
boxes_data: .incbin "boxes.dat"
apples_data: .incbin "apples.dat"

level_char_data_addresses:
	dc.l dirt_data,lego_data,beach_data,forest_data
	dc.l weird_data,dice_data,boxes_data,apples_data

setup_char_positions: dc.b 0,1,2,3,40,41,42,43, 80,81,82,83,84,85,120,121,122,123,124,125
	dc.b 162,163,164,165,166,167, 202,203,204,205,206,207, 242,243,244,245,246,247
setup_char_values: dc.b 20,21,22,23,24,25,26,27, 29,30,28,29,30,28,32,33,31,32,33,31
	dc.b 34,35,36,34,35,36, 38,40,41,38,40,41, 42,44,45,42,44,45

level_deco:
	dc.b 46,20,48,15,50,10,0,0
	dc.b 0,0,0,0,0,0,0,0
	dc.b 46,10,48,15,50,30,0,0
	dc.b 46,30,48,30,50,30,0,0
	dc.b 0,0,0,0,0,0,0,0
	dc.b 46,20,48,20,50,20,0,0
	dc.b 46,15,48,20,50,20,0,0
	dc.b 46,30,48,30,50,30,0,0
level_ice: dc.b 12,12,12,11, 11,11,10,10, 10,9,9,8, 8,7,7,7
level_blocks: dc.b 6,6,7,7, 8,8,9,9, 10,10,11,11, 12,12,13,13
block_offsets: dc.b 0,-16,16,-1,1,0

blocktype_chars: dc.b 0,28,0,10

pete_offsets:
	dc.b 0,1,2,3,4,6,8,10,12,13,14,15
pete_rounded_offsets:
	dc.b 0,0,0,6,6,6,6,6,6,12,12,12,12,12,12,18,18,18
pete_up_cycle1:
	dc.b 121,122,123,124,123,122,121,120,119,118,119,120
pete_up_cycle2:
	dc.b 128,129,130,131,130,129,128,127,126,125,126,127
pete_down_cycle1:
	dc.b 27,28,29,30,29,28,27,26,25,24,25,26
pete_down_cycle2:
	dc.b 34,35,36,37,36,35,34,33,32,31,32,33

flame_cycle:
	dc.b 96,97,98,99,100,101,102,103,104,103,102,101,100,99,98,97
flame_cycle2:
	dc.b 113,112,111,110,109,108,107,106,105,106,107,108,109,110,111,112
happy_cycle:
	dc.b 38,39,40,39

spr_width:
	dc.w 2,2,2,2,2,2,2,3,3,3,3,3,2,2,2,2
	dc.w 2,2,2,3,3,3,3,3,2,2,2,2,2,2,2,2
	dc.w 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.w 2,3,3,3,2,2,2,2,2,3,3,3,2,2,2,2
	dc.w 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.w 2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3
	dc.w 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.w 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.w 2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3
	dc.w 3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2
	dc.w 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.w 2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2
	dc.w 2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,1
	dc.w 1
spr_height:
	dc.w 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,24,24,24,24,24,24,24,23,24,24,24,24
	dc.w 24,24,23,24,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,12,12,12,12,24,24,24,23,24,24,24,24,24,24
	dc.w 23,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 24,24,24,24,23,23,24,24,24,24,24,23,23,23,24,24
	dc.w 24,24,24,23,24,24,24,24,24,24,24,24,24,24,24,24
	dc.w 22
spr_offset:
	dc.l 0,480,960,1440,1920,2400,2880,3360,4080,4800,5520,6240,6960,7440,7920,8400
	dc.l 8880,9360,9840,10320,11040,11760,12480,13200,13920,14400,14880,15360,15820,16300,16780,17260
	dc.l 17740,18220,18700,19160,19640,20120,20600,21080,21560,22040,22520,23000,23480,23960,24440,24920
	dc.l 25400,25880,26600,27320,28040,28520,29000,29480,29960,30440,31160,31880,32600,33080,33560,34040
	dc.l 34520,35000,35480,35960,36440,36920,37400,37880,38360,38840,39320,39800,40280,40760,41240,41720
	dc.l 42200,42680,43160,43640,44120,44600,45080,45560,46040,46520,47000,47720,48440,49160,49880,50600
	dc.l 51320,51800,52280,52760,53240,53720,54200,54680,55160,55640,56120,56600,57080,57560,58040,58520
	dc.l 59000,59480,59960,60200,60440,60680,60920,61400,61880,62360,62820,63300,63780,64260,64740,65220
	dc.l 65700,66160,66640,67120,67600,68080,68560,69040,69520,70000,70480,70960,71440,71920,72640,73360
	dc.l 74080,74800,75520,76240,76960,77440,77920,78400,78880,79360,79840,80320,80800,81280,81760,82240
	dc.l 82720,83200,83680,84160,84640,85120,85600,86080,86560,87040,87520,88000,88480,88960,89440,89920
	dc.l 90400,90880,91360,91840,92320,92780,93240,93720,94200,94680,95160,95640,96100,96560,97020,97500
	dc.l 97980,98460,98940,99420,99880,100360,100840,101320,101800,102280,102760,103240,103720,104200,104680,104920
	dc.l 105160

shadow_pixels: .incbin "shadows.dat"
shd_width:
	dc.w 2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3
	dc.w 1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2
shd_height:
	dc.w 16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16
	dc.w 16,16,16,16,16,16,16,16,16,16,16,16,16,16,16,16
shd_offset:
	dc.l 0,64,128,192,256,320,384,448,512,576,672,768,864,960,1056,1152
	dc.l 1248,1280,1312,1344,1376,1408,1440,1472,1504,1536,1568,1600,1664,1728,1792,1856

restore_buf: ds.b 4000
restore_buf2: ds.b 4000
restore_pointer: dc.l 0
restore_pointer1: dc.l 0
restore_pointer2: dc.l 0


* Sprite variables for intro
sprites_h: ds.w 6
sprites_base: ds.l 6
sprites_look: dc.w 0,0,0,0,0,0
shadows_h: ds.w 3
shadows_base: ds.l 3
shadows_look: dc.w 0,0,0
tmp_width: dc.w 0
tmp_height: dc.w 0
tmp_offset: dc.l 0
tmp_h: dc.w 0

* Font
font: .incbin "font.dat"
char_table: dc.b 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
	dc.b 0,0,0,0,0,0,0,0, 0,0,0,0,0,0,0,0
	dc.b 65,0,0,0,0,0,0,0, 66,67,64,0,37,0,36,0
	dc.b 26,27,28,29,30,31,32,33, 34,35,0,0,0,0,0,0
	dc.b 0,0,1,2,3,4,5,6,7,8,9,10,11,12,13,14
	dc.b 15,16,17,18,19,20,21,22, 23,24,25,0,0,0,0,0
	dc.b 0,38,39,40,41,42,43,44, 45,46,47,48,49,50,51,52
	dc.b 53,54,55,56,57,58,59,60, 61,62,63,0,0,0,0,0

level_flames:
	dc.b 1,2,2,3, 3,1,1,2, 2,3,3,2, 2,1,1,0
level_sparks:
	dc.b 0,0,0,0, 0,1,1,1, 1,1,1,2, 2,3,3,4
levflame_types:
	dc.b 0,0,0,0

* Joystick, mouse, palette restore data
joy_on:	dc.b 0x14,0x12
mouse_on: dc.b 0x08,0
joysticks: dc.b 0,0,0

.align 2
ikbd_vec: dc.l 0
old_joy: dc.l 0
old_palette: ds.w 16

* Counters
vblank_count: dc.w 0
counter: dc.w 0
counter2: dc.w 0

* Text data and variables
text_in_pos: dc.l 0
text_out_pos: dc.l 0

top_text_pos: dc.l 0


credits_text:
	.asciz "  Programmed by  "
	.asciz "  Karl H*rnell   "
	.asciz "                 "
	.asciz "    Music by     "
	.asciz "    M.D. Smit    "
	.asciz "                 "
	.asciz " (c) Eweguo 2018 "
fire_button_text:
	.asciz "  Fire to start  "

top_texts:
	.asciz "You control Pixel"
	.asciz "Pete, the penguin"
	.asciz " Move ice blocks "
	.asciz " by pushing them "
	.asciz "... or crush them"
	.asciz "against obstacles"
	.asciz "  Watch out for  "
	.asciz "    the flames   "
	.asciz "  You can snuff  "
	.asciz "  them with ice  "
	.asciz "Collect all five "
	.asciz "golden coins ... "
	.asciz "  ... to get to  "
	.asciz " the next level  "

highscore_headline:
	.asciz "   HIGHSCORES    "
highscore_texts:			
	.asciz " 1. 0800 ... AAA "
	.asciz " 2. 0700 ... BBB "
	.asciz " 3. 0600 ... CCC "
	.asciz " 4. 0500 ... DDD "
	.asciz " 5. 0400 ... EEE "
	.asciz " 6. 0300 ... FFF "
	.asciz " 7. 0200 ... GGG "
	.asciz " 8. 0100 ... HHH "

	.asciz " 9. 0000 ... ZZZ "

gameover_text:
	.asciz "    GAME OVER    "
yourname_text:
	.asciz "    Your name    "
celebration_text:
	.asciz " CONGRATULATIONS "
	.asciz "  Now you have   "
	.asciz " seen everything "

.align 2
highscores:
	dc.w 0x800,0x700,0x600,0x500,0x400,0x300,0x200,0x100,0
cursor_data:
	dc.w 0x1ff,0x1ff,0x1ff,0x1ff,0xff80,0xff80,0xff80,0xff80
	dc.w 0x1ff,0x1ff,0x1ff,0x1ff,0xff80,0xff80,0xff80,0xff80
	dc.w 0x180,0x180,0x180,0x180,0x180,0x180,0x180,0x180
	dc.w 0x180,0x180,0x180,0x180,0x180,0x180,0x180,0x180
	dc.w 0x180,0x180,0x180,0x180,0x180,0x180,0x180,0x180
	dc.w 0x180,0x180,0x180,0x180,0x180,0x180,0x180,0x180
	dc.w 0x180,0x180,0x180,0x180,0x180,0x180,0x180,0x180
	dc.w 0x180,0x180,0x180,0x180,0x180,0x180,0x180,0x180
	dc.w 0x180,0x180,0x180,0x180,0x180,0x180,0x180,0x180
	dc.w 0x1ff,0x1ff,0x1ff,0x1ff,0xff80,0xff80,0xff80,0xff80
	dc.w 0x1ff,0x1ff,0x1ff,0x1ff,0xff80,0xff80,0xff80,0xff80

cursor_pos: dc.w 0
cursor_colors:
	dc.w 0xffff,0x0000,0x0000,0x0000
	dc.w 0xffff,0xffff,0xffff,0xffff
	dc.w 0x0000,0x0000,0xffff,0xffff
	dc.w 0xffff,0xffff,0x0000,0xffff
	dc.w 0x0000,0x0000,0x0000,0x0000
	dc.w 0xffff,0xffff,0x0000,0xffff
	dc.w 0x0000,0x0000,0xffff,0xffff
	dc.w 0xffff,0xffff,0xffff,0xffff

level_text:
	.asciz "Level 00"

.align 2
curtain_base: dc.b 0,14,10,4,8,6,2,12, 0,14,10,4,8,6,2,12, 0,14,10,4,8,6,2,12
	dc.b 0,14,10,4,8,6,2,12, 0,14,10,4,8,6,2,12

* Game variables
level:	dc.w 0
level_bcd: dc.w 0
score_bcd: dc.w 0
lives: dc.w 0
coins: dc.w 0
music_on: dc.w 1
pX: dc.w 0
pY: dc.w 0
pBaseX: dc.w 0
pBaseY: dc.w 0
pPos: dc.w 0
pLook: dc.w 0
pDx: dc.w 0
pDy: dc.w 0
pDir: dc.w 0
pState: dc.w 0
pBarrierHeight: dc.w

block_clear_flag: dc.w 0
block_clear_pos: dc.w 0
block_draw_flag: dc.w 0
block_draw_pos: dc.w 0
score_buf: dc.b 0,0
score_update_flag: dc.w 0
music_update_flag: dc.w 0
previous_joy: dc.w 0
cheat_count: dc.w 0
cheat_mode: dc.w 0

iX: dc.w 0
iY: dc.w 0
iBaseX: dc.w 0
iBaseY: dc.w 0
iPos: dc.w 0
iLook: dc.w 0
iDx: dc.w 0
iDy: dc.w 0
iDir: dc.w 0
iState: dc.w 0
iType: dc.w 0
iCounter: dc.w 0

fState: dc.w 0
fType: dc.w 0
fBaseX: dc.w 0
fBaseY: dc.w 0
fDx: dc.w 0
fDy: dc.w 0
fDir: dc.w 0
fLook: dc.w 0
fCount: dc.w 0
fPos: dc.w 0
flame_data: ds.w 36

barrierHeight: dc.w 0
barrierAnd1: dc.l 0
barrierAnd2: dc.l 0
barrierAnd3: dc.l 0
barrierOr1: dc.l 0
barrierOr2: dc.l 0
barrierOr3: dc.l 0

shadowTmp: ds.l 12
shadowMask: ds.l 96
pShadowX: dc.w 0
pShadowPos: dc.l 0
pShadowLook: dc.w 0

max_flames: dc.w 0
max_sparks: dc.w 0
num_flames: dc.w 0
num_sparks: dc.w 0

char_map: ds.b 1024
block_map: ds.b 256
block_buf: ds.b 256
block_copy: ds.b 256
block_ne: dc.b 0
block_e: dc.b 0
block_sw: dc.b 0
block_s: dc.b 0
block_se: dc.b 0
block_n: dc.b 0
block_nw: dc.b 0
block_w: dc.b 0
.align 2

sprite_draw_data: ds.l 30
		dc.l 0
sort_table: ds.l 12

tmp_buf: ds.b 256

* Sound and music data
sound_data: dc.b 0,0,1,0, 2,0,3,0, 8,0,9,0, 7,248, 4,0,5,0,10,0,6,0, 130,0
sound_off: dc.b 8,0, 9,0, 10,0, 130,0

sound_type: dc.w 0
sound_countdown: dc.w 0
new_sound: dc.w 0

sound_jumptable:
	dc.l 0
	dc.l sound_handle_slide
	dc.l sound_handle_stop
	dc.l sound_handle_break
	dc.l sound_handle_coin
	dc.l sound_handle_snuff
	dc.l sound_handle_done
	dc.l sound_handle_newflame
	dc.l sound_handle_death
sound_durations: dc.b 0,111,5,55,63,63,98,63,63

.align 4
voice1_start: dc.l 0
voice1_pos: dc.w 0
voice1_count: dc.w 0
voice1_arpeggio: dc.w 0
voice1_max_arpeggio: dc.w 0
voice1_length: dc.w 0
envelope1: dc.b 11,10,9,8,7,6,5,4,3,2,1,0
	ds.b 64
.align 4
voice2_start: dc.l 0
voice2_pos: dc.w 0
voice2_count: dc.w 0
voice2_arpeggio: dc.w 0
voice2_max_arpeggio: dc.w 0
voice2_length: dc.w 0
envelope2: dc.b 11,10,9,8,7,6,5,4,3,2,1,0
	ds.b 64

freq_table: dc.b 239,14,24,14,78,13,142,12,218,11,48,11,143,10,247,9
	 dc.b 104,9,225,8,97,8,233,7,119,7,12,7,167,6,71,6
	 dc.b 237,5,152,5,72,5,252,4,180,4,112,4,49,4,244,3
	 dc.b 188,3,134,3,83,3,36,3,247,2,204,2,164,2,126,2
	 dc.b 90,2,56,2,24,2,250,1,222,1,195,1,170,1,146,1
	 dc.b 123,1,102,1,82,1,63,1,45,1,28,1,12,1,253,0
	 dc.b 239,0,226,0,213,0,201,0,190,0,179,0,169,0,159,0
	 dc.b 151,0,142,0,134,0,127,0,119,0,113,0,106,0,100,0
	 dc.b 95,0,89,0,84,0,80,0,75,0,71,0,67,0,63,0
	 dc.b 0,0

song_voice1:			 
	 dc.b 12,1,72, 6,2,62,56, 12,2,62,56, 6,1,60, 18,2,62,56, 12,2,60,57
	 dc.b 6,2,60,57, 12,2,60,57, 6,1,53, 12,1,55, 6,1,53, 6,1,56, 6,1,58
	 dc.b 6,1,56, 12,1,55, 6,1,56, 12,1,53, 6,3,62,56,53, 12,3,62,56,53
	 dc.b 6,2,60,56, 18,2,62,56, 12,2,60,57, 6,2,60,57, 12,2,60,57, 6,1,53
	 dc.b 12,1,55, 6,1,53, 6,1,56, 6,1,58, 6,1,56, 12,1,55, 6,1,56, 12,1,53
	 dc.b 6,3,62,56,53, 12,3,62,56,53, 6,2,60,56, 18,3,62,57,53, 12,3,60,57,53
	 dc.b 6,3,60,57,53, 12,3,60,57,53, 6,3,60,57,53, 12,3,62,58,53, 6,2,61,53
	 dc.b 12,2,62,54, 3,1,57, 3,1,54, 9,1,48, 9,3,57,54,48, 12,3,57,54,48
	 dc.b 6,3,57,54,48, 12,2,54,48, 6,2,51,48, 12,1,50, 6,2,57,54, 12,3,57,54,48
	 dc.b 6,3,58,54,48, 12,3,59,54,48, 6,2,60,50, 6,1,50, 6,1,58, 6,1,50
	 dc.b 18,3,58,50,46, 12,3,58,50,46, 6,3,55,50,46, 12,3,55,50,46, 6,2,58,46
	 dc.b 12,2,58,46, 6,3,57,52,46, 18,2,58,52, 12,3,55,52,48, 6,3,55,50,48
	 dc.b 12,3,55,50,48, 6,3,55,51,50, 6,1,48, 6,1,47, 6,1,48, 6,1,52, 6,1,55
	 dc.b 6,1,52, 6,1,50, 6,1,72, 6,1,52, 12,1,48, 6,3,58,52,46, 12,3,58,52,46
	 dc.b 6,3,57,52,46, 12,2,58,46, 6,3,60,52,48, 12,2,58,52, 6,2,55,43
	 dc.b 12,2,55,43, 6,3,55,51,50, 6,1,48, 6,1,47, 6,1,48, 6,1,52, 6,1,55
	 dc.b 6,1,52, 6,1,50, 6,1,72, 6,1,52, 6,1,48, 6,1,72, 6,3,60,52,48, 12,3,58,52,48
	 dc.b 6,4,60,58,52,48, 12,4,62,58,56,50, 6,3,63,58,51, 12,3,63,58,51
	 dc.b 6,4,64,60,58,31, 18,3,67,64,55, 12,2,66,54, 6,3,67,64,55, 12,2,68,56
	 dc.b 6,2,69,57, 12,2,67,55, 6,2,66,54, 12,2,69,57, 6,2,68,56, 12,2,67,55
	 dc.b 6,2,65,53, 12,2,65,53, 6,1,56, 12,1,55, 6,2,60,56, 12,1,55, 6,1,53
	 dc.b 12,2,53,50, 6,1,50, 12,3,48,46,40, 6,3,48,46,40, 12,3,48,46,40
	 dc.b 6,3,48,46,43
song_end1:
	 dc.b 255,1,0

song_voice2:
	dc.b 18,1,72, 12,1,72, 6,1,24, 18,1,17, 12,4,41,38,36,33, 6,1,24, 18,1,12
	 dc.b 12,4,41,38,36,33, 6,1,22, 18,1,10, 12,2,38,32, 6,1,29, 18,1,22
	 dc.b 12,3,38,32,29, 6,1,29, 18,1,17, 12,3,36,33,29, 6,1,24, 18,1,12
	 dc.b 12,3,36,33,29, 6,1,29, 18,1,22, 12,2,38,32, 6,1,29, 18,1,22, 12,3,38,32,29
	 dc.b 6,1,29, 18,1,17, 12,3,36,33,29, 6,1,29, 18,1,17, 18,2,30,18, 18,2,26,14
	 dc.b 12,3,36,33,30, 6,1,14, 18,1,2, 12,3,36,30,26, 6,2,25,13, 18,2,26,14
	 dc.b 12,3,36,33,30, 6,1,14, 18,1,2, 18,3,36,30,26, 18,1,7, 12,3,38,34,31
	 dc.b 6,1,14, 18,1,2, 12,3,38,34,31, 6,1,24, 18,1,12, 12,3,40,36,34
	 dc.b 6,1,19, 18,1,7, 12,3,40,36,34, 6,1,24, 18,1,12, 12,3,40,36,34
	 dc.b 6,1,19, 18,1,7, 12,3,40,36,34, 6,1,24, 18,1,12, 12,3,40,36,34
	 dc.b 6,1,19, 18,1,7, 12,3,40,36,34, 6,1,24, 18,1,12, 12,4,36,34,31,28
	 dc.b 6,1,19, 18,1,7, 12,3,40,36,34, 6,1,24, 18,1,12, 12,4,36,34,31,28
	 dc.b 6,1,19, 18,1,7, 12,3,40,36,34, 6,1,24, 18,1,12, 12,4,36,34,31,28
	 dc.b 6,1,19, 18,1,7, 12,4,36,34,31,28, 6,1,17, 18,1,5, 12,4,41,39,36,33
	 dc.b 6,1,22, 18,1,10, 12,2,38,32, 6,1,24, 18,1,12, 12,4,36,34,31,28
	 dc.b 6,1,24
song_end2:
	 dc.b 255,1,0

ingame_voice1:
	 dc.b 12,1,72, 6,2,60,55, 6,2,60,55, 6,1,72, 6,1,56, 18,2,62,56, 12,2,60,55
	 dc.b 6,2,60,55, 12,2,60,55, 6,2,60,55, 12,2,58,55, 6,1,55, 6,1,57, 6,1,58
	 dc.b 6,1,57, 12,1,53, 6,1,57, 12,1,57, 6,2,60,56, 12,2,60,55, 6,2,60,55
	 dc.b 18,2,62,56, 18,2,60,56, 18,2,62,56, 18,2,63,58, 12,4,64,60,58,52
	 dc.b 6,3,62,58,52, 12,3,64,58,52, 6,3,60,58,52, 12,3,60,58,52, 6,3,60,58,52
	 dc.b 12,2,62,52, 6,1,60, 6,1,53, 6,1,65, 6,1,53, 6,1,65, 6,1,53, 6,1,65
	 dc.b 12,2,68,56, 6,2,69,57, 12,2,68,56, 6,2,67,55, 12,2,67,55, 6,2,65,53
	 dc.b 6,2,65,58, 6,1,72, 6,1,50, 12,3,62,58,50, 6,1,50, 12,3,62,56,50
	 dc.b 6,3,58,56,50, 12,2,57,48, 6,2,60,48, 12,2,57,48, 6,1,54, 12,2,57,50
	 dc.b 6,3,56,50,48, 12,2,55,44, 6,2,53,45, 12,2,53,45, 6,2,50,48, 6,2,48,45
	 dc.b 6,1,72, 6,3,50,48,45, 12,1,72, 6,3,62,56,48, 12,3,62,56,48, 6,3,61,56,48
	 dc.b 12,2,62,57, 6,1,48, 6,3,60,57,55, 6,1,72, 6,4,60,57,53,48, 12,1,72
	 dc.b 6,1,48, 12,1,49, 6,2,53,50, 12,3,55,50,44, 6,3,56,50,44, 12,3,55,50,44
	 dc.b 6,3,53,50,44, 12,1,72, 6,3,62,56,53, 6,3,62,56,53, 6,1,64, 6,1,65
	 dc.b 12,1,62, 6,1,60, 9,1,57, 9,1,62, 5,1,60, 4,1,62, 5,1,60, 4,1,57
	 dc.b 5,1,54, 4,1,57, 5,1,54, 4,1,50, 12,3,57,54,48, 6,3,58,50,48, 12,2,57,48
	 dc.b 6,2,55,46, 12,2,55,46, 6,3,50,46,43, 6,4,55,50,46,43, 6,1,72, 3,1,55
	 dc.b 3,1,57, 18,1,58, 12,1,57, 3,1,58, 3,1,57, 12,1,55, 6,1,57, 6,1,58
	 dc.b 6,1,58, 6,1,50, 12,1,62, 6,1,60, 12,1,58, 6,1,55, 12,1,55, 6,1,52
	 dc.b 12,1,51, 6,1,52, 6,1,48, 6,1,72, 6,3,58,52,46, 12,2,57,46, 6,1,58
	 dc.b 18,3,64,58,52, 6,3,63,58,51, 6,1,72, 6,2,62,50, 12,2,60,48, 6,1,48
	 dc.b 12,3,57,53,48, 6,3,57,53,48, 12,2,58,48, 6,4,60,57,53,48, 12,3,62,58,50
	 dc.b 6,3,64,60,52, 18,3,65,58,53, 12,3,64,58,53, 6,4,65,62,58,53, 12,1,72
	 dc.b 6,1,50, 6,2,62,58, 6,1,50, 6,1,56, 12,1,57, 6,2,60,48, 12,2,57,48
	 dc.b 6,3,62,66,48, 12,3,62,66,48, 6,1,48, 12,1,49, 6,1,50, 12,1,55
	 dc.b 6,1,57, 12,2,56,46, 6,1,57, 18,4,60,58,52,46, 6,1,61, 6,1,72, 6,1,62
	 dc.b 18,3,60,57,53, 12,1,72, 6,1,69, 12,1,69, 6,1,68, 12,1,67, 6,1,66
	 dc.b 6,2,65,53, 6,1,53, 6,1,58, 12,2,67,58, 6,2,67,55, 6,1,65, 6,1,53
	 dc.b 6,1,58, 6,1,62, 6,1,50, 6,1,58, 12,1,60, 6,1,48, 12,3,60,54,48
	 dc.b 6,3,62,54,50, 12,3,62,54,50, 6,2,57,48, 12,3,58,54,48, 6,1,57
	 dc.b 12,2,57,48, 6,2,55,48, 12,2,57,48, 6,2,60,48, 18,2,57,52, 18,3,55,52,46
	 dc.b 36,3,53,48,45
ingame_end1:
	 dc.b 255,1,0

ingame_voice2:
	 dc.b 36,1,12, 18,1,12, 12,2,36,34, 6,1,24, 18,1,12, 12,3,36,34,28, 6,1,24
	 dc.b 18,1,17, 12,3,41,36,33, 6,1,17, 18,1,5, 12,3,41,36,33, 6,1,22
	 dc.b 18,2,22,10, 12,2,38,32, 6,1,29, 18,1,22, 12,2,38,32, 6,1,31, 18,1,24
	 dc.b 12,4,36,34,31,28, 6,1,24, 18,1,12, 12,3,36,34,28, 6,1,29, 18,1,17
	 dc.b 12,4,41,39,36,33, 6,1,17, 18,1,5, 12,3,39,36,33, 6,1,22, 18,2,22,10
	 dc.b 12,4,38,34,32,29, 6,1,29, 18,1,22, 12,3,38,32,29, 6,1,29, 18,1,17
	 dc.b 18,3,36,33,29, 18,1,21, 18,1,12, 18,1,5, 12,4,41,38,36,33, 6,1,24
	 dc.b 18,1,12, 12,3,36,34,28, 6,1,24, 18,1,17, 12,4,41,38,36,33, 6,1,17
	 dc.b 18,1,5, 12,4,41,39,36,33, 6,1,22, 18,2,22,10, 12,2,38,32, 6,1,29
	 dc.b 18,1,22, 18,3,38,32,29, 18,1,17, 12,4,41,38,36,33, 6,1,29, 18,1,17
	 dc.b 18,1,26, 18,1,14, 18,1,14, 18,1,7, 6,2,38,34, 12,1,31, 18,1,19
	 dc.b 18,3,43,38,34, 18,1,19, 12,3,43,38,34, 6,1,26, 18,1,12, 12,3,40,36,34
	 dc.b 6,1,31, 18,1,19, 18,4,36,34,31,28, 18,1,12, 12,3,40,36,34, 6,1,31
	 dc.b 18,1,19, 18,3,40,36,34, 18,1,17, 12,4,41,38,36,33, 6,1,17, 18,1,5
	 dc.b 18,2,21,9, 18,2,22,10, 12,3,41,38,34, 6,1,22, 18,1,10, 12,1,38
	 dc.b 6,1,24, 18,1,17, 18,3,36,33,29, 18,1,14, 18,3,36,30,26, 18,1,7
	 dc.b 18,3,36,34,28, 18,2,24,12, 18,3,36,34,28, 18,1,17, 12,4,41,39,36,33
	 dc.b 6,1,17, 18,1,5, 18,2,21,9, 18,2,22,10, 18,3,38,34,29, 18,1,22
	 dc.b 18,2,38,34, 18,3,33,24,17, 18,3,36,33,29, 18,2,26,14, 18,3,36,30,26
	 dc.b 18,2,19,7, 18,3,43,38,34, 18,1,12, 18,3,36,34,28, 18,2,29,17
	 dc.b 12,4,41,38,36,33, 6,1,24
ingame_end2:
	 dc.b 255,1,0

party_voice1:
	 dc.b 18,3,58,72,46, 12,3,58,55,46, 6,3,57,52,48, 36,3,55,52,48, 36,4,60,58,55,48
	 dc.b 18,4,60,58,55,48, 18,3,62,58,50, 18,4,60,58,52,48, 12,3,55,52,43
	 dc.b 6,2,56,44, 18,3,57,53,45, 12,4,60,57,53,48, 6,1,61, 18,3,62,58,50
	 dc.b 18,3,60,57,48, 54,3,65,60,53, 72,1,72
party_end1:
	 dc.b 255,1,0

party_voice2:
	 dc.b 18,2,19,7, 18,3,41,38,34, 18,2,24,12, 18,3,40,36,34, 18,2,19,7
	 dc.b 18,3,40,36,34, 18,2,24,12, 18,4,36,34,31,28, 18,2,12,0, 18,2,16,4
	 dc.b 18,2,17,5, 18,4,41,38,36,33, 18,2,24,12, 18,4,41,38,36,33, 54,2,29,17
	 dc.b 72,1,72
party_end2:
	 dc.b 255,1,0

random_pos: dc.w 0
random_table:
	dc.b 0xa7,0x95,0x73,0xb4,0xdd,0x78,0xdf,0x63,0x42,0xbd,0xff,0x56,0x73,0x56,0x17,0x4
	dc.b 0xd4,0x1e,0x71,0xa9,0x9d,0x9,0x77,0x23,0xb0,0xed,0xfd,0x5e,0x42,0x8d,0x33,0x1f
	dc.b 0x97,0x65,0xfc,0xd9,0xfb,0x45,0x7b,0xae,0xed,0xb2,0x9a,0xb1,0x2c,0x53,0xd1,0x64
	dc.b 0x14,0x23,0x61,0x24,0x9c,0x6e,0x8d,0x3b,0xb6,0x5d,0x1f,0xd5,0xda,0x4e,0x8d,0x34
	dc.b 0x41,0x28,0x53,0x93,0xc2,0xfa,0x66,0xad,0xb7,0x2a,0x48,0xaf,0x2d,0xe9,0x7d,0x20
	dc.b 0x92,0xbd,0x7a,0x72,0x10,0x25,0x6f,0x33,0xc1,0xc,0xad,0x7b,0x52,0x7a,0x10,0xb8
	dc.b 0xb3,0x69,0x6d,0x70,0x47,0xf6,0x25,0xdc,0xea,0xd6,0x36,0x53,0xe3,0xd5,0xbb,0x1e
	dc.b 0xdb,0xb7,0xb4,0xcc,0xe3,0x68,0x85,0xdb,0xbd,0x92,0xdb,0x5c,0x7c,0x42,0x5a,0x1f
	dc.b 0x70,0xdf,0x98,0xe2,0x9c,0xa6,0x35,0x33,0xdd,0xff,0x6,0x11,0x84,0xcf,0x93,0xc6
	dc.b 0xf,0x6d,0xcd,0x96,0x2e,0x8c,0x3d,0xfb,0xbb,0x83,0x5e,0x42,0x15,0x58,0xaf,0x9c
	dc.b 0x30,0x4d,0x4b,0x6d,0xed,0xde,0x71,0x86,0x51,0xf9,0xcc,0xc9,0x3b,0xda,0xa4,0x22
	dc.b 0xf8,0xe1,0xd8,0x5f,0x12,0xe2,0xe0,0xa,0xf6,0x3b,0xfe,0x5,0x3,0xd7,0x5b,0x26
	dc.b 0xf5,0xf1,0x1b,0x9c,0xbb,0x58,0xf5,0xab,0xc2,0x4f,0xce,0x99,0x10,0xe5,0x5e,0xf8
	dc.b 0xc6,0xae,0x3a,0xe8,0x3,0xf5,0x19,0xee,0x15,0x8e,0x2c,0x6,0x9c,0xb8,0x73,0xbb
	dc.b 0x5,0x12,0x58,0x35,0xcc,0xdc,0xf4,0xfe,0x39,0x2c,0x93,0x18,0x2f,0x30,0xe2,0x45
	dc.b 0xe0,0x4f,0x81,0xa6,0xf9,0xbb,0xb8,0x56,0x2e,0x0,0x1b,0x46,0x76,0x4b,0x61,0x49

* m68k-atari-mint-as iceblox.s -m68000 -o iceblox.o
* m68k-atari-mint-ld iceblox.o -s -o iceblox.prg
