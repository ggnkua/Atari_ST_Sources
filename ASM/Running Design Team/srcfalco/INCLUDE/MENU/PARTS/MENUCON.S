********* Deatil Menu **********

menu2_loop:
          	rept	KEY_DELAY
		jsr	vsync
		endr

* edge keys
		lea	detail_offsets,a6
		bsr	edge_move

		lea	detail_control,a0
		bsr	check_return_menu
		
		move.w	#edge_color,d0
		swap	d0
		move.w	#edge_color,d0
		move.l	screen_1,a0
		lea	detail_offsets,a6
		bsr	paint_edge

		jsr     swap_me
		neg.w	index

		tst.b	keytable+$01
		beq.s	menu2_loop	

		move.l	old_menu_vbl,$70.w
		bsr	restore_screen
		jsr	swap_me
		jsr	vsync
		bsr	restore_screen
		jsr	swap_me

		* detailmenu
		lea	FILEtitel2(pc),a0
		lea	fade_buffer_1,a1
		move.l	BYTEStitel2(pc),d0
		bsr	load
		* menu
		lea	FILEtitel1(pc),a0
		lea	fade_buffer_2,a1
		move.l	BYTEStitel1(pc),d0
		bsr	load

		lea	fade_buffer_2+128,a1
		bsr	save_screen		* goro
	
		clr.w	kugel_pos
	
                lea	fade_buffer_2+128,A5
		bsr     calc_fire
		lea	fade_buffer_2+128,a0
		bsr	kugel

		bsr	fade_me
		move.l	#menu1_vbl,$70.w
	
		bra	menu1_loop		* und starten

********* Sound Menu **********

menu3_loop:
          	rept	KEY_DELAY
		jsr	vsync
		endr

* edge keys
		lea	sound_offsets,a6
		bsr	edge_move

		lea	sound_control,a0
		bsr	check_return_menu
		
		move.w	#edge_color,d0
		swap	d0
		move.w	#edge_color,d0
		move.l	screen_1,a0
		lea	sound_offsets,a6
		bsr	paint_edge

		jsr     swap_me
		neg.w	index

		tst.b	keytable+$01
		beq.s	menu3_loop	

		move.l	old_menu_vbl,$70.w
		bsr	restore_screen
		jsr	swap_me
		jsr	vsync
		bsr	restore_screen
		jsr	swap_me

		* soundsmenu
		lea	FILEtitel3(pc),a0
		lea	fade_buffer_1,a1
		move.l	BYTEStitel3(pc),d0
		bsr	load
		* menu
		lea	FILEtitel1(pc),a0
		lea	fade_buffer_2,a1
		move.l	BYTEStitel1(pc),d0
		bsr	load

		lea	fade_buffer_2+128,a1
		bsr	save_screen		* goro

		clr.w	kugel_pos
		
                lea	fade_buffer_2+128,A5
		bsr     calc_fire
		lea	fade_buffer_2+128,a0
		bsr	kugel

		bsr	fade_me
		move.l	#menu1_vbl,$70.w
	
		bra	menu1_loop		* und starten

********* credits Menu **********

menu4_loop:
          	
		jsr	vsync
                
		bsr     restore_screen_texture
                jsr     transform_points_texture
                bsr     give_textures_a_chance               
                jsr     control_baby
		
		jsr     swap_me
		neg.w	index

		tst.b	keytable+$01
		beq.s	menu4_loop	

		move.l	old_menu_vbl,$70.w
		bsr	restore_screen
		jsr	swap_me
		jsr	vsync
		bsr	restore_screen
		jsr	swap_me

		* creditsmenu
		lea	FILEtitel4(pc),a0
		lea	fade_buffer_1,a1
		move.l	BYTEStitel4(pc),d0
		bsr	load
		* menu
		lea	FILEtitel1(pc),a0
		lea	fade_buffer_2,a1
		move.l	BYTEStitel1(pc),d0
		bsr	load

		lea	fade_buffer_2+128,a1
		bsr	save_screen		* goro

                lea	fade_buffer_2+128,A5
		bsr     calc_fire

		clr.w	kugel_pos
	
		lea	fade_buffer_2+128,a0
		bsr	kugel

		bsr	fade_me
		move.l	#menu1_vbl,$70.w
	
		bra	menu1_loop		* und starten


********* Menu Auswahl *************

control_baby
		lea	name_control_array,a0
		move.w	kugel_pos,d0
		mulu	#10,d0
		adda.w	d0,a0

		move.w	(a0),d0		* mode
		
		cmp.w	#0,d0
		bne.s	no_waiting

* wait to see the face 
		addq.w	#1,name_timer
		cmp.w	#50*2,name_timer
		bne	not_ready
		move.w	#3,(a0)
		clr.w	name_timer
		rts

no_waiting
		cmp.w	#1,d0
		bne.s	no_zoom_out

* wegzoomen
		addi.w	#16,move_zx
		cmp.w	#600,move_zx
		blt	not_ready

* neu mappen
		lea	texture_edge_info+2,a1

		bsr	set_texture

		move.w	#2,(a0)

		clr.w	dreh_x
		clr.w	dreh_y
		clr.w	dreh_z

		clr.w	name_timer

		rts
no_zoom_out
		cmp.w	#2,d0
		bne.s	no_zoom_in

* ranzoomen
		subi.w	#16,move_zx
		cmp.w	#67,move_zx
		bgt	not_ready
		
		clr.w	(a0)
		clr.b	2(a0)

		rts
no_zoom_in
		cmp.w	#3,d0
		bne.s	no_move_to_name
	
* zum n„chsten Namen scrollen init

		move.b	2(a0),d0
		addq.b	#1,d0
		cmp.b	3(a0),d0
		ble.s	next_name
		
		clr.b	2(a0)
		move.w	#4,(a0)		* and now rotate the cube
		rts

next_name	move.b	d0,2(a0)
		move.w	#5,(a0)		* do the move
		rts

no_move_to_name
		cmp.w	#4,d0
		bne.s	no_rotate

* rotate the cube

		cmp.w	#1024,dreh_x
		beq.s	not_readyx
		addq.w	#4,dreh_x		
not_readyx
		cmp.w	#1024,dreh_y
		beq.s	not_readyy
		addq.w	#4,dreh_y		
not_readyy
		cmp.w	#1024,dreh_z
		beq.s	not_readyz
		addq.w	#4,dreh_z		
not_readyz
		
		cmp.w	#1024,dreh_x
		bne.s	not_ready
		cmp.w	#1024,dreh_y
		bne.s	not_ready		
		cmp.w	#1024,dreh_z
		bne.s	not_ready

		clr.w	dreh_x
		clr.w	dreh_y
		clr.w	dreh_z
	
		clr.w	(a0)		* wait modus again

not_ready	rts

no_rotate
		cmp.w	#5,d0
		bne.s	no_movement

* zum n„chsten Namen scrollen 

		moveq	#0,d0
		move.b	2(a0),d0
		subq.b	#1,d0
		lsl.w	#2,d0
		lea	movement_1,a1
		adda.w	d0,a1

		move.w	(a1),d0
		lea	dreh_x,a2
		cmp.w	(a2),d0
		bgt.s	add_some_x
		blt.s	sub_some_x

		move.w	2(a1),d0
		cmp.w	2(a2),d0
		bgt.s	add_some_y
		blt.s	sub_some_y

		clr.w	(a0)		* wait some time again
		rts

add_some_x	addq.w	#4,(a2)
		bra.s	now_the_y
sub_some_x	subq.w	#4,(a2)

now_the_y
		move.w	2(a1),d0
		cmp.w	2(a2),d0
		bgt.s	add_some_y
		blt.s	sub_some_y
		rts

sub_some_y	subq.w	#4,2(a2)
		rts
add_some_y	addq.w	#4,2(a2)

no_movement	rts

set_texture
		moveq	#0,d0
		
		move.b	4(a0),d0		
		move.w	d0,(a1)
		
		move.b	5(a0),d0		
		move.w	d0,16(a1)

		move.b	6(a0),d0		
		move.w	d0,16*2(a1)
		
		move.b	7(a0),d0		
		move.w	d0,16*3(a1)
		
		move.b	8(a0),d0		
		move.w	d0,16*4(a1)

		move.b	9(a0),d0		
		move.w	d0,16*5(a1)
		rts

check_return_menu
* a0 = control array

		tst.b	keytable+$1c
		bne.s	return2
		tst.b	keytable+$39
		bne.s	return2
		rts

return2		
		clr.b	keytable+$1c
		clr.b	keytable+$39

		cmp.w	#0,kugel_pos
		bne.s	no_pos21

		move.l	a0,a1
		bsr	next_item
		
no_pos21
		cmp.w	#1,kugel_pos
		bne.s	no_pos22

		lea	6(a0),a1
		bsr	next_item


no_pos22
		cmp.w	#2,kugel_pos
		bne.s	no_pos23

		lea	6*2(a0),a1
		bsr	next_item


no_pos23
		cmp.w	#3,kugel_pos
		bne.s	no_pos24

		lea	6*3(a0),a1
		bsr	next_item

no_pos24	
		rts

next_item
		move.w	(a1),d0
		addq.w	#1,d0
		move.b	2(a1),d1
		cmp.b	d0,d1
		bgt.s	you
		clr.w	(a1)
		moveq	#0,d0
you		move.w	d0,(a1)
		bsr	put_infos2		
		rts


check_return	
		tst.b	keytable+$1c
		bne.s	cr_2
		tst.b	keytable+$39
		beq	no_return

cr_2
		clr.b	keytable+$1c
		clr.b	keytable+$39

		cmp.w	#0,kugel_pos
		bne	no_running

		moveq	#1,d0
		move.b	d0,keytable+$1
		move.w	d0,mm_start_running

		jsr	mm_save_options

no_running		
	
		move.l	old_menu_vbl,$70.w
		jsr	vsync
		bsr	restore_screen
		jsr	swap_me
		jsr	vsync
		bsr	restore_screen
		jsr	swap_me

		cmp.w	#0,kugel_pos
		bne	no_running_no


************* running menu ***************

		* Mainmenu
		lea	FILEtitel1(pc),a0
		lea	fade_buffer_1,a1
		move.l	BYTEStitel1(pc),d0
		bsr	load
		
		* Episodemenu
		lea	FILEtitel5(pc),a0
		lea	fade_buffer_2,a1
		move.l	BYTEStitel5(pc),d0
		bsr	load

		* Epsiodenmenu vorbereiten
		lea	fade_buffer_2+128,a0
		lea	fade_buffer_2+128,a1
		adda.l	#640*191,a1 
		move.w	#49-1,d0
copy_line	move.w	#160-1,d1
copy_long	move.l	(a0)+,(a1)+
		dbra	d1,copy_long
		dbra	d0,copy_line		

		lea	fade_buffer_2+128,a0

		move.l	#$ffffffff,d2
		move.w	#191-1,d0	
white_screen	move.w	#160-1,d1
white_line	move.l	d2,(a0)+
		dbra	d1,white_line
		dbra	d0,white_screen
	
		*

		lea	fade_buffer_2+128,a1
		bsr	save_screen		* goro
			
		clr.w	kugel_pos

		bsr	fade_me
		*move.l	#menu2_vbl,$70.w
		
		addq.l	#4,sp
		bra	episode_menu



no_running_no
		cmp.w	#1,kugel_pos
		bne.s	no_detail

		* Mainmenu
		lea	FILEtitel1(pc),a0
		lea	fade_buffer_1,a1
		move.l	BYTEStitel1(pc),d0
		bsr	load
		* Detailmenu
		lea	FILEtitel2(pc),a0
		lea	fade_buffer_2,a1
		move.l	BYTEStitel2(pc),d0
		bsr	load

		lea	fade_buffer_2+128,a1
		bsr	save_screen		* goro
	
		lea	detail_control,a0
		bsr	put_infos	
		
		clr.w	kugel_pos

		bsr	fade_me
		move.l	#menu2_vbl,$70.w
		
		addq.l	#4,sp
		bra	menu2_loop		* und starten

no_detail	cmp.w	#2,kugel_pos
		bne.s	no_sound

		* Mainmenu
		lea	FILEtitel1(pc),a0
		lea	fade_buffer_1,a1
		move.l	BYTEStitel1(pc),d0
		bsr	load
		* Soundmenu
		lea	FILEtitel3(pc),a0
		lea	fade_buffer_2,a1
		move.l	BYTEStitel3(pc),d0
		bsr	load

		lea	fade_buffer_2+128,a1
		bsr	save_screen		* goro
	
		lea	sound_control,a0
		bsr	put_infos	

		clr.w	kugel_pos

		bsr	fade_me
		move.l	#menu3_vbl,$70.w
		
		addq.l	#4,sp
		bra	menu3_loop		* und starten

****** credits 

no_sound	cmp.w	#3,kugel_pos
		bne	no_return
		
		* textures
		lea	FILEtexture(pc),a0
		lea	fade_buffer_1,a1
		move.l	BYTEStexture(pc),d0
		bsr	load

		lea	fade_buffer_1+128,a1
		bsr	texture_to_buffer

		* Mainmenu
		lea	FILEtitel1(pc),a0
		lea	fade_buffer_1,a1
		move.l	BYTEStitel1(pc),d0
		bsr	load
		* Detailmenu
		lea	FILEtitel4(pc),a0
		lea	fade_buffer_2,a1
		move.l	BYTEStitel4(pc),d0
		bsr	load

		lea	fade_buffer_2+128,a1
		bsr	save_screen		* goro

		clr.w	dreh_x
		clr.w	dreh_y
		clr.w	dreh_z
		
		clr.w	kugel_pos

		lea	name_control_array,a0
		lea	texture_edge_info+2,a1
		bsr	set_texture
	
		bsr	fade_me
		move.l	#menu4_vbl,$70.w

		addq.l	#4,sp
		bra	menu4_loop		* und starten

no_return	rts
