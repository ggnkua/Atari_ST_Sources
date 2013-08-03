** KillThings
** (C) 1996 Digi Tallis
** version 0.9a                                 9/7/96
**                                              (yes, that long ago!)

** bit of a problem.. keys 'esc' to '=' respond as a joystick..
** a bit strange. still has to be got around..

** Texture's are ALWAYS 80 pixels in width!
** the maximum size for a wall is 80 pixels.
** FORCE this size in the level creater.
**      (this was a note to me, the coder, but it applies to you too!)

** all walls are SOLID! No windows or anything!
** you want to do windows? use a door with a switch that can't
** be reached! Tacky, but it works! (welcome to TacksVille USA...)


********************
* thanks to 
*       Scott Stringer in New Zealand for the optimisation pointers
*       Anthony Jacques for Falcon pointers
*       all on stos@cs.man.ac.uk for their ideas and testing..

YES                     equ     1       ;define some boolean!!
NO                      equ     0

RUN_FROM_DESKTOP        equ     0       ;0 = no. 1 = yes
MAP_DRAW_3D             equ     0       ;0 = 3d, 1 = map
PROCESSOR_CHECK         equ     1       ;0 = yes, 1 = NO!
GENST_ESCAPE_KEY        equ     97      ;UNDO
					;needed cos UP registers
					;as the 'escape' key!
MOUSPEED                equ     1       ;good numba.. =]
IMAGE_BANK_WIDTH        equ     80-16
IMAGE_BANK_HEIGHT       equ     50

LOOK_AHEAD_DEPTH        equ     20
MAX_NUMBER_3D_POINTS    equ     200     ;THIS NEEDS TO BE HUGE!!
MAX_NUM_WALL_LINES      equ     200     ;how many walls ??
					;want a huge map with millions of
					;walls? whack this up..
MAP_DRAW_DIVISION       equ     2       ;divide by four
					;its using lsr.l not divu..
TEXTURE_X_SIZE          equ     80      ;makes life easier!
					;a HELL of a lot easier!!
ROTATION_STEP_VALUE     equ     8       ;just for now..
MAP_TRANSLATION_VALUE   equ     8       ;testing stuff really..

MAX_MAP_X_SIZE          equ     500
MAX_MAP_Z_SIZE          equ     500     ;a big square!!
					;want a HUGE map? increase these.

MAX_WALL_SIZE           equ     80
THREE_D_VIEW_WIDTH      equ     100     ;dont' mess around with these.
THREE_D_VIEW_DEPTH      equ     100     ;if you do, you'll need to recalc
					;the 3d table. And I've lost the
					;stos proggy that does it...
					;good luck.. =]

LOOK_BEHIND             equ     10
TEXTURE_STRIP_HEIGHT    equ     IMAGE_BANK_HEIGHT+(LOOK_BEHIND*2)
STRIP_FADE_VALUE        equ     4       ;how many fades are there?
					;see the example textures.pi1
					;for hints on how this works
MAX_NUM_TEXTURES        equ     50      ;only this many textures!
MAX_NUM_TEXTURE_STRIPS  equ     50      ;only this many t-strips!


;-------------------------
MAX_NUM_ALIENS          equ     5
MAX_ALIEN_EYESIGHT_LEN  equ     2000    ;how far can it see?
MAX_NUM_ALIEN_TYPES     equ     10
ALIEN_A_FR_WALK_START   equ     0
ALIEN_A_FR_WALK_END     equ     5
ALIEN_A_FR_FIRE_START   equ     6
ALIEN_A_FR_FIRE_END     equ     11
ALIEN_A_FR_DYING        equ     12
MAX_NUM_ALIEN_A_FR      equ     ALIEN_A_FR_DYING
NUM_DEATH_FRAMES        equ     4


;-------------------------
MAX_NUM_BULLETS         equ     10
MAX_BULLET_DISTANCE     equ     200     ;2 seconds worth..


;-------------------------
CIRCLE_COLLISION_SIZE   equ     40      ;thats from 0,0 to size,size..
BULLET_COLLISION_SIZE   equ     20      ;nice small square.. =]
					;should really be a circle, but
					;I couldn't be bothered..

SLOW_BULL_SPD           equ     2
JUST_FIRED              equ     1       ;allows monsters to shoot monsters


;-------------------------
MAX_NUM_EXPLOSIONS      equ     5
MAX_NUM_EXPLO_TYPES     equ     2
MAX_NUM_EXPLO_A_FR      equ     4       ;thats it!


;-------------------------
MAX_NUM_WEAPONS         equ     6       ;GUN_0 to GUN_5
					;MUST MATCH!!!!
MAX_NUM_PICKUPS         equ     5       ;how many per level?
MAX_PICKUPS_ANIM_FR     equ     4       ;four frames of anim per pickup!
MAX_NUM_PICKUP_TYPES    equ     11      ;how many types are there?
					;MUST be same as number of pickups!
PICKUP_COLLISION_SIZE   equ     20      ;this is the size around the player!
MAX_PICKUP_VALUE        equ     99      ;how much of this pickup?!
P_AMMO_GUN_0            equ     0       ;pistol
P_AMMO_GUN_1            equ     1       ;shotgun
P_AMMO_GUN_2            equ     2       ;chaingun
P_AMMO_GUN_3            equ     3       ;rocket
P_AMMO_GUN_4            equ     4       ;plasma
P_AMMO_GUN_5            equ     5       ;BFG
P_RED_KEY               equ     6
P_YELLOW_KEY            equ     7
P_BLUE_KEY              equ     8
P_HEALTH_SMALL          equ     9       ;health by a small amount
P_HEALTH_LARGE          equ     10      ;BIG booster!
P_NOTHING               equ     11


;-----------------------
MAX_NUM_DOORS           equ     5
MAX_DOOR_ANIM_FRAMES    equ     4       ;ie 4 frames to open/close door..
DOOR_OPEN               equ     0
DOOR_OPENING            equ     1
DOOR_CLOSED             equ     2
DOOR_CLOSING            equ     3       ;should cover about every state!
DOOR_TYPE_RED_KEY       equ     0
DOOR_TYPE_YELLOW_KEY    equ     1
DOOR_TYPE_BLUE_KEY      equ     2
DOOR_TYPE_NO_KEY_1      equ     3
DOOR_TYPE_NO_KEY_2      equ     4
DOOR_TYPE_NO_KEY_3      equ     5       ;allows different graphics!
DOOR_TYPE_HIDDEN_1      equ     6
DOOR_TYPE_HIDDEN_2      equ     7
DOOR_TYPE_HIDDEN_3      equ     8       ;see above comment!
DOOR_TYPE_LAST          equ     9       ;this should ALWAYS be last!!
MAX_NUM_DOOR_TYPES      equ     DOOR_TYPE_LAST  ;for easy code!

;-------------------------
SWITCH_INVIS            equ     0
SWITCH_VIS              equ     1
SWITCH_ON               equ     0
SWITCH_OFF              equ     1
SWITCH_TYPE_LIGHT       equ     0
SWITCH_TYPE_FACE        equ     1
SWITCH_TYPE_LAST        equ     2
MAX_NUM_SWITCH_TYPES    equ     SWITCH_TYPE_LAST
SWITCH_COLLISION_SIZE   equ     80      ;all switches are 40 wide
					;if both pnts inside zone..
					;the it collides..
;-------------------------
MAX_NUM_TELEPORTS       equ     10
TELEPORT_TYPE_NORMAL    equ     0
TELEPORT_TYPE_EXIT      equ     1       ;ie, the level end!


;-------------------------
MAX_NUM_VISIBLE_OBJECTS equ     30      ;max_aliens+max_bullets
					;+max_num_explosions
					;+(max_num_doors*2)
MAX_OBJECT_SIZE         equ     40      ;makes life a LOT faster
					;if our max monster width is
					;40 pix wide...

***********************************************************************
*********** Ok, enough messing around, lets get on with something *****                                                          
***********************************************************************
sup     clr.l   -(sp)
	move.w  #$20,-(sp)
	trap    #1
	add.l   #6,sp
	move.l  d0,savesp       
	lea     my_stack,sp     ;whack the stack in free space

;get original stuff, so we can return!
	jsr     get_original_run_mode
	jsr     get_original_screen_base
	jsr     get_original_palette
	bsr     screen_in

;set up the vbls and so on..
	bsr     save_othershit
	bsr     new_vecs        

;lets speed things up!!
	jsr     change_texture_line_data_to_mults
		;mult em all up.. takes out lots of mulus!
	jsr     convert_x3d_to_x2d_to_mults_of_4
		;speeds things up by a fraction..
	jsr     change_texture_shrink_table_to_offsets
		;do the above to speed things up!!
	jsr     mult_texture_data_by_16
		;do above to speed things RIGHT up!
	jsr     create_ceiling_and_floor_bank
		;create a temp ceiling and floor..

*********
	IFNE    RUN_FROM_DESKTOP
	jsr     intro_menu
	ENDC
*********

;go call that main_loop!!
	jsr     main_menu       ;GO GAME!!!

quit_all
	bsr     bang_um_back
	bsr     pal_out
	bsr     screen_out

usr     move.l  savesp,-(sp)
	move.w  #$20,-(sp)
	trap    #1
	add.l   #6,sp
	clr.w   -(sp)
	trap    #1

****** error trapping shit... *******************
bomb_trap       
	rept    8
	addq    #4,error_number
	endr
bailout 
	bsr     bang_um_back    ;kill interrupts...
	bsr     screen_out      ;back to medium!
;       bsr     flipper
	move.w  #$777,$ff8240
	move.w  #$700,$ff825e
	
	pea     gurumes(pc)     ;'guru'
	move.w  #9,-(sp)
	trap    #1
	add.l   #6,sp

	lea     error_messages(pc),a0   ;error text
	add     error_number(pc),a0
	move.l  (a0),a0 
	move.l  a0,-(sp)
	move.w  #9,-(sp)
	trap    #1              ;print it
	add.l   #6,sp

	pea     butmes(pc)
	move.w  #9,-(sp)
	trap    #1
	add.l   #6,sp
.wait
	cmp.b   #57,$fffffc02.w
	bne.s   .wait           ;wait for that space bar..
	bra     quit_all        ;QUIT!
error_number    dc.w    0
old_bomb_trap   ds.l    8
error_messages  dc.l    bailmes,trcerr,priverr,trpverr
		dc.l    chkerr,diverr,illerr,addrerr,buserr
new_bomb_trap
	dc.l    bomb_trap,bomb_trap+6,bomb_trap+12,bomb_trap+18
	dc.l    bomb_trap+24,bomb_trap+30,bomb_trap+36,bomb_trap+42
	even
gurumes dc.b    27,69
	dc.b    "GURU! got a big ",0
butmes  dc.b    13,10,"whack space.. ",0
bailmes dc.b    "bailout keys pressed",0
buserr  dc.b    "bus error",0
addrerr dc.b    "address error",0
illerr  dc.b    "illegal instruction",0
diverr  dc.b    "division by zero",0
chkerr  dc.b    "CHK instruction",0
trpverr dc.b    "TRAPV instruction",0
priverr dc.b    "privilege violation",0
trcerr  dc.b    "trace cockup",0
	even
********* Code from here on in..

get_original_palette
	lea     old_palette,a0
	lea     $ff8240,a1
	rept    8
	move.l  (a1)+,(a0)+
	endr
	rts

get_original_run_mode
	move.w  #4,-(sp)
	trap    #14
	add.l   #2,sp
	move.w  d0,old_screen_res
	rts

get_original_screen_base
	move.w  #2,-(sp)        ;2 gets physic..
	trap    #14
	add.l   #2,sp
	move.l  d0,old_physic_screen
;       move.l  d0,physic       ;don't pick memory at random!

	move.w  #3,-(sp)        ;3 gets logic??
	trap    #14
	add.l   #2,sp
	move.l  d0,old_logic_screen
;       move.l  d0,work         ;don't pick memory at random!

	move.l  work,d0         ;ok, get the screens on 256byte bounds
	lsr.l   #8,d0
	lsl.l   #8,d0
	move.l  d0,work
	move.l  physic,d0
	lsr.l   #8,d0
	lsl.l   #8,d0
	move.l  d0,physic
	rts

screen_in       
	move.w  #0,-(sp)
	move.l  physic,-(sp)
	move.l  physic,-(sp)
	move.w  #$5,-(sp)
	trap    #14
	add.l   #12,sp
	rts

screen_out      
	move.w  old_screen_res,-(sp)            ;0
	move.l  old_logic_screen,-(sp)          ;#-1
	move.l  old_physic_screen,-(sp)         ;#-1
	move.w  #$5,-(sp)
	trap    #14
	add.l   #12,sp
	rts

put_pal_in      
	lea     $ff8240,a1
	rept    8
	move.l  (a0)+,(a1)+
	endr
	rts

pal_out 
	IFEQ    RUN_FROM_DESKTOP
	move.l  #gempal,-(sp)           ;shove the dev pal!
	ENDC
	IFNE    RUN_FROM_DESKTOP
	move.l  #old_palette,-(sp)      ;shove the old pal
	ENDC

	move.w  #$6,-(sp)
	trap    #14
	add.l   #6,sp
	rts

clear_workscreen
	move.l  work,a0
	move.l  #200-1,d7
.down_loop
	move.l  #16-1,d6
	add.l   #16,a0          ;get across..
.across_loop
	move.l  #0,(a0)
	move.l  #0,4(a0)        ;clear 16 pix
	
	add.l   #8,a0   ;get across
	dbf     d6,.across_loop

	add.l   #16,a0  ;get across
	dbf     d7,.down_loop
	rts

flipper 
	move.l  work,d0
	move.l  physic,work
	move.l  d0,physic

	move    #$8201,a0
	lsr.l   #8,d0
	movep   d0,(a0)
	rts

save_othershit
	move.l  $70.w,old_vbl           ;the vbl table
;       move.l  $120.w,old_hbl          ;the hbl!
	move.b  $fffffa1b,old_a1b       
	move.b  $fffffa21,old_a21
	move.b  $fffffa07,old_a07
	move.b  $fffffa09,old_a09
	move.b  $fffffa13,old_a13
	move.b  $fffffa15,old_a15
	move.b  $fffffa17,old_a17
	move.l  $118.w,old_key
	movem.l $8.w,d0-d7
	movem.l d0-d7,old_bomb_trap
	rts

bang_um_back
	move.w  #$2700,sr               ;put the old vectors back
	move.l  old_vbl,$70.w
;       move.l  old_hbl,$120.w          ;store hbl, just in case we might
					;possibly want to play with it..
	move.b  old_a1b,$fffffa1b.w
	move.b  old_a21,$fffffa21.w
	move.b  old_a07,$fffffa07.w
	move.b  old_a09,$fffffa09.w
	move.b  old_a13,$fffffa13.w
	move.b  old_a15,$fffffa15.w
	move.b  old_a17,$fffffa17.w
	move.l  old_key,$118.w
	movem.l old_bomb_trap(pc),d0-d7
	movem.l d0-d7,$8.w
	move.w  #$2300,sr
	rts

new_vecs
	move.w  #$2700,sr               ;tell everything to shut up
	move.l  #vbl,$70.w              ;vbl
;       move.l  #hbl,$120.w             ;hbl..
	move.b  #1,$fffffa07
	move.b  #1,$fffffa13.w
	clr.b   $fffffa1b.w
	clr.b   $fffffa09.w
	clr.b   $fffffa15.w
	bset    #6,$fffffa09.w
	bset    #6,$fffffa15.w
	move.b  #$40,$fffffa17.w
	move.l  #keyrout,$118.w         ;constantly running! EEK!!
	movem.l new_bomb_trap(pc),d0-d7
	movem.l d0-d7,$8.w
	move.w  #$2300,sr               ;start em up again
	rts

wait_vbl
	IFEQ    PROCESSOR_CHECK
	move.w  #$302,$ff8240
	ENDC
	move.b  vbl_flag,d7
.check
	cmp.b   vbl_flag,d7
	beq.s   .check
	clr.b   vbl_flag

	IFEQ    PROCESSOR_CHECK
	move.w  #$000,$ff8240
	ENDC
	rts

lock_raster
	move.w  #$2700,sr
	move.w  #$100,d1
	lea $ffff8209.w,a3
test_rast                               ; sync
	tst.b   (a3)
	beq.s   test_rast
	moveq   #0,d0
	move.b  (a3),d0
	lea     jump_rast,a3
	add.l   d0,a3
	jmp     (a3)
jump_rast                               ; 77 nops
	rept 77
	nop
	endr
	move.w  #$2300,sr
	rts

vbl     
	cmpi.b  #GENST_ESCAPE_KEY,key           ;compare for ESCAPE
	bne.s   .no_space
	move.b  #0,key          ;clear it....
	lea     quit_all,a0
	jmp     (a0)
.no_space
;       clr.b   $fffffa1b.w             ;stop b
;       move.b  #199,$fffffa21          ;timer b count
;       move.b  #8,$fffffa1b.w          ;start b
;       bsr     lock_raster     ;ya gots time ya knows...
	addq.b  #1,vbl_flag     ;set it so other routs can go NOW!
	
	rte

hbl                     
	bclr    #0,$fffffa0f.w
	rte

**********************************************
* still doing general housekeeping and stuff..
**********************************************
mouse_stick_control
	move.b  key,d2
	cmp.b   #15,d2
	bhi     .no_joymove
.joy_up
	btst    #0,d2           ;Joystick up
	beq.s   .joy_down
;       move    #-MOUSPEED,d0
;       bsr     change_y
	move.l  #0,joystick_down
	move.l  #1,joystick_up          ;moved it UP!!!
.joy_down
	btst    #1,d2
	beq.s   .joy_left
;       move    #MOUSPEED,d0
;       bsr     change_y
	move.l  #0,joystick_up
	move.l  #1,joystick_down        ;moved it DOWN!!
.joy_left
	btst    #2,d2
	beq.s   .joy_right
;       move    #-MOUSPEED,d0
;       bsr     change_x
	move.l  #0,joystick_right
	move.l  #1,joystick_left        ;we've pushed LEFT!
.joy_right
	btst    #3,d2
	beq.s   .joy_fire
;       move    #MOUSPEED,d0
;       bsr     change_x
	move.l  #0,joystick_left
	move.l  #1,joystick_right       ;moved RIGHT!!!
.joy_fire
	cmp.b   #0,button
	beq.s   .no_joymove
.button_checks
	cmp.b   #3,button
	bne.s   .next
	move.l  #1,left_mouse
	move.l  #1,right_mouse
	bra.s   .no_joymove
.next
	cmp.b   #2,button
	bne.s   .next_2
	move.l  #1,left_mouse
	bra.s   .no_joymove
.next_2
	cmp.b   #1,button
	bne.s   .no_joymove
	move.l  #1,right_mouse
.no_joymove
	rts

keyrout
	movem.l d0-d1,-(a7)
scan_again
	move.b  $fffffc02.w,d0  ;d0 = kybd data code
	cmp.b   #$f6,d0         ;If d0 < $f6 it's joy/key code
	blo.s   joy_keycode
	cmp.b   #$f8,d0         ;If d0 < $f8 do nothing
	blo.s   endkeyrout
	cmp.b   #$fc,d0         ;If d0 > $fc do nothing
	bhs.s   endkeyrout
mouse_button_check
	and     #3,d0           ;else get mouse button data
	move.b  d0,button
	move.l  #delta_x,$118.w ;set to get mouse dx
	bra.s   endkeyrout
delta_x
	movem.l d0-d1,-(a7)
	move.b  $fffffc02.w,d0  ;d0 = kybd data code
	ext     d0
	bsr.s   change_x
	move.l  #delta_y,$118.w ;set to get mouse dy
	bra.s   endkeyrout
delta_y
	movem.l d0-d1,-(a7)
	move.b  $fffffc02.w,d0  ;d0 = kybd data code
	ext     d0
	bsr.s   change_y
	move.l  #keyrout,$118.w ;set back to normal
	bra.s   endkeyrout
joy_keycode
	move.b  d0,key          ;Joystick/Key code
endkeyrout
	btst    #4,$fffffa01.w
	beq.s   keyrout
	movem.l (a7)+,d0-d1
	rte
change_x
	muls    #MOUSPEED,d0
	move.l  mouse_x,d1      ;use a temp so everything doesn't change
	add.l   d0,d1           ;in mid flight! That usually screws
	cmp.l   #0,d1           ;it up a right treat!
	bgt.s   .no_stop_at_left
	moveq.l #1,d1
.no_stop_at_left
	cmp.l   #320,d1
	blt.s   .no_stop_at_right
	move.l  #319,d1
.no_stop_at_right
	move.l  d1,mouse_x
	rts
change_y
	muls    #MOUSPEED,d0
	move.l  mouse_y,d1
	add.l   d0,d1
	cmp.l   #0,d1
	bgt.s   .no_stop_at_top
	moveq.l #1,d1
.no_stop_at_top
	cmp.l   #180,d1
	blt.s   .no_stop_at_bot
	move.l  #179,d1
.no_stop_at_bot
	move.l  d1,mouse_y
	rts

**********************************************************
* game code!!!! FINALLY!!!
**********************************************************
	opt     o+,w-

intro_menu
	jsr     wait_vbl        ;wait for a blank screen..
	move.l  #intro_menu_text,menu_text_pointer
	move.l  #intro_menu_options,menu_options_pointer
	move.l  #0,menu_current_op_select
	move.l  #0,menu_old_op_select
.check_loop
	jsr     clear_full_work_screen
	jsr     flipper
	jsr     wait_vbl        ;wait for a blank screen..
	lea     menu_pal,a0
	jsr     put_pal_in

	jsr     loop_until_menu_option_select

.op_1
	cmp.l   #0,menu_current_op_select
	bgt     .op_2
		bra     .quit_all
.op_2

.end_ops
	bra     .check_loop
.quit_all
	rts



main_menu
	jsr     wait_vbl        ;wait for a blank screen..
	move.l  #main_menu_text,menu_text_pointer
	move.l  #main_menu_options,menu_options_pointer
	move.l  #0,menu_current_op_select
	move.l  #0,menu_old_op_select
.check_loop
	jsr     clear_full_work_screen
	jsr     flipper
	jsr     wait_vbl        ;wait for a blank screen..
	lea     menu_pal,a0
	jsr     put_pal_in

	jsr     loop_until_menu_option_select

.op_1
	cmp.l   #0,menu_current_op_select
	bgt     .op_2
		;right, create the game screens
	move.l  #MAP_DRAW_3D,map_or_3d_drawing_mode     ;set 3d mode!

	;put all black palette in here..
	jsr     clear_workscreen
	jsr     copy_scorecard_background_to_work
	jsr     flipper
	jsr     clear_workscreen
	jsr     copy_scorecard_background_to_work
		;shove the game palette in
	lea     game_pal,a0
	jsr     put_pal_in

	jsr     wait_vbl
	jsr     main_game_loop  
	bra     .end_ops
.op_2
	cmp.l   #1,menu_current_op_select
	bgt     .op_3
		bra     .quit_all
		;QUIT back to gem! Temporary!!!!
.op_3   

.end_ops
	bra     .check_loop
.quit_all
	rts

main_game_loop
	jsr     print_vbl_counter

	jsr     wait_vbl
	jsr     mouse_stick_control

;now do all the alien move, world rotation etc code..
	jsr     rotate_player_look_at_point
	jsr     rotate_player_fire_at_point
	jsr     change_rotation_and_translation_values_according_to_player

;lets check for those keys dude!
	jsr     check_tab_for_map
	jsr     check_fire_button
	jsr     check_weapon_change_keys
	jsr     check_space_for_door

;ok, rotate the world and such like!
	jsr     translate_static_world_into_rotated
	jsr     rotate_static_3d_world_into_rotated_3d_world

;control aliens, bullets, animation and stuff!
	jsr     control_aliens
	jsr     control_bullets
	jsr     control_explosions
	jsr     player_collided_with_pickup
;ok, did we teleport!?
	jsr     player_walked_onto_a_teleport
	cmp.l   #NO,player_teleport_flag
	beq     .no_teleport
		cmp.l   #-1,player_teleport_to_level
		bne     .done_this_level        ;we hit an EXIT!
.no_teleport


;ok, do some rotations..
	jsr     translate_alien_points_into_rotated_points
	jsr     rotate_alien_object_points
;now rotate the bullets and stuff!
	jsr     translate_bullet_points_into_rotated_points
	jsr     rotate_bullet_object_points
;do the explosions
	jsr     translate_explosion_points_into_rotated_points  
	jsr     rotate_explosion_points
;do the pickups
	jsr     translate_pickup_points_into_rotated_points     
	jsr     rotate_static_pickup_data_into_rotated
	jsr     control_pickups_animation
;control the doors
	jsr     translate_door_points_into_rotated_points       
	jsr     rotate_doors_from_static_into_rotated
	jsr     control_door_animation
;do the switches
	jsr     translate_switch_points_into_rotated_points     
	jsr     rotate_switch_from_static_into_rotated

;the screen stuff...
	jsr     print_health_text_on_work
	jsr     print_current_weapon_used_on_work
	jsr     print_current_weapon_ammo


;finally draw the damned world!
	cmp.l   #1,map_or_3d_drawing_mode
	beq.s   .draw_world_as_map
.draw_world_as_3d
;       jsr     clear_image_bank
	jsr     copy_ceiling_and_floor_into_image_bank
	jsr     clear_z_buffer
	jsr     draw_world_as_3d

	jsr     put_objects_into_object_drawing_buffer
	jsr     sort_object_drawing_buffer
	jsr     draw_objects_in_object_drawing_buffer

	jsr     convert_image_bank_to_4x4_offsets
	jsr     draw_image_bank_to_work_fullscreen
	move.w  #$000,$ff8240
	bra     .end_drawing_checks
.draw_world_as_map
	jsr     clear_workscreen
	jsr     draw_calced_buffer_points
	jsr     draw_the_map
	jsr     draw_player_pos_on_map
	jsr     draw_calced_alien_points
	jsr     draw_used_bullets
.end_drawing_checks
	jsr     flipper
	bra     main_game_loop
.done_this_level
	rts


*****************************************************************
** code that speeds the engine up! ie, cheats more!
*****************************************************************
change_texture_line_data_to_mults
	lea     texture_line_data,a0
	lea     texture_line_data_end,a1        ;when these two equal stop..
.loop
	move.l  (a0),d0
	mulu    #TEXTURE_STRIP_HEIGHT*(STRIP_FADE_VALUE*2),d0
	move.l  d0,(a0)+
	cmp.l   a1,a0   ;if less than..
	blt     .loop
	rts     

change_texture_shrink_table_to_offsets
	lea     texture_shrink_table,a0
	move.l  #(THREE_D_VIEW_DEPTH*TEXTURE_STRIP_HEIGHT)-1,d7
.loop
	move.l  (a0),d0
	mulu    #IMAGE_BANK_WIDTH*2,d0  ;get past all lines
	move.l  d0,(a0)
	add.l   #4,a0   ;go into the bank a few!
	dbf     d7,.loop
	rts

mult_texture_data_by_16
	lea     texture_strip_data,a0
	lea     texture_strip_data_end,a1       ;when these two equal stop..
.loop
	move.l  #0,d0   ;clear it.. speed isn't important here
	move.w  (a0),d0
	lsl.w   #4,d0           ;mulu'd by 16
	move.w  d0,(a0)
	add.l   #2,a0   ;go into textures..
	cmp.l   a1,a0   ;if less than..
	blt     .loop
	rts     

convert_x3d_to_x2d_to_mults_of_4
	lea     x3d_to_x2d_table,a0
	lea     x3d_to_x2d_table_end,a1
.loop
	move.l  (a0),d0
	lsl.l   #2,d0           ;mult by 4
	move.l  d0,(a0)+        ;shove it back in..

	cmp.l   a1,a0
	blt     .loop
	rts

****************************************************************
** create the floor, draw the world to work etc
****************************************************************
create_ceiling_and_floor_bank
	lea     ceiling_and_floor_data,a0
	lea     texture_shrink_table,a1
	lea     texture_fade_colour_data,a2

	move.l  #THREE_D_VIEW_DEPTH-1,d7
	move.l  #THREE_D_VIEW_DEPTH-1,d0
.loop
	move.l  d0,d1
	lsl.l   #2,d1   ;mulu by 4..
	move.l  (a2,d1.l),d4    ;the colour. NEEDS to be changed..
	lsr.l   #1,d4           ;divide by two..
	move.l  #5,d3           ;starting at WHICH colour!?
	add.l   d4,d3
;ok, got a colour.. now lets get a place to shove it!
	lsl.l   #4,d3   ;mult it by 16... FOR SPEED!


	move.l  d0,d1
	mulu    #TEXTURE_STRIP_HEIGHT*4,d1      ;get past all z's..
	move.l  (a1,d1.l),d2    ;pos DOWN in the bank..
;got the roof place..
	move.l  d0,d4
	mulu    #TEXTURE_STRIP_HEIGHT*4,d4      ;get past all z's
	add.l   #(TEXTURE_STRIP_HEIGHT-1)*4,d4  ;get to bottom of texture
	move.l  (a1,d4.l),d5
;got floor!

	move.l  #IMAGE_BANK_WIDTH-1,d6
.gloop
		move.w  d3,(a0,d2.l)    ;slap in the colour.
		move.w  d3,(a0,d5.l)    ;slap in the colour.
		add.l   #2,d2           ;go across one
		add.l   #2,d5           ;go across one
	dbf     d6,.gloop
	sub.l   #1,d0   ;go in by one..
	dbf     d7,.loop

	rts

copy_ceiling_and_floor_into_image_bank
	lea     image_bank,a0
	lea     ceiling_and_floor_data,a1
i       set     0
	rept    IMAGE_BANK_HEIGHT*(IMAGE_BANK_WIDTH/16) ;should be 8..
	movem.l (a1)+,d0-d7                             ;but this saves
	movem.l d0-d7,i(a0)                             ;us time..
i       set     i+32
	endr
	rts

clear_z_buffer
	lea     z_buffer,a0
	rept    IMAGE_BANK_WIDTH*2
	move.l  #THREE_D_VIEW_DEPTH*4,(a0)+
	endr
	rts

convert_image_bank_to_4x4_offsets
	;first by 256. second by 16
	;third by 256, fourth by 16. add 8 to get past pix 0-8... 
	;cos everything is already a mult of 16, we only have to 
	;mult first and third by 16.. =]

	lea     image_bank,a0
i       set     0
	rept    IMAGE_BANK_HEIGHT*(IMAGE_BANK_WIDTH/4)
		move.w  i(a0),d1        ;get the first and third
		move.w  i+4(a0),d2
		lsl.l   #4,d1   ;whay.. lets save 25% of one frame!
		lsl.l   #4,d2   ;mult em by 16.. 16*16=256.. boooyahh..
		move.w  d1,i(a0)
		move.w  d2,i+4(a0)      ;shove em back in!
i       set     i+8
	endr
	rts


draw_image_bank_to_work_fullscreen
;this routine CAN BE SPEEDED UP!
;providing we manually repeat the code in the rept below..
;and replace the loop with the rept..
;makes a HUGE rout, but quicker..
		;get first offset into d0
		;add second offset
		;move.l the two .l's into d1,d2
		;get third offset into d0
		;add fourth offset
		;or.l   the two .l's onto d1,d2
		;move.l d1,d2 sucker onto screen..
		;repeat..
	
	lea     image_bank,a0
	lea     the_4x4_plot_data,a1
	move.l  work,a2
	add.l   #16,a2  ;step across 32 pixels..
	move.l  #IMAGE_BANK_HEIGHT-1,d0         ;how many times to go down!
.loop
i       set     0
	rept    IMAGE_BANK_WIDTH/4              ;across!
		move.w  (a0)+,d1        ;1st block
		add.w   (a0)+,d1        ;add the 2nd offset on
		movem.l (a1,d1.w),d2-d3 ;two long words.
		move.w  (a0)+,d1        ;3rd block
		add.w   (a0)+,d1        ;add the 4th offset on
		or.l    8(a1,d1.w),d2   ;or the first two bitplanes
		or.l    12(a1,d1.w),d3  ;now the last two.

		movem.l d2-d3,i(a2)     ;okey, we've got a 16 pix line
		movem.l d2-d3,i+160(a2) ;that contains 4 blocks
		movem.l d2-d3,i+320(a2) ;put it onto the screen
		movem.l d2-d3,i+480(a2) ;remembering to do the 4x4!
i       set     i+8
	endr

	add.l   #160*4,a2
	dbf     d0,.loop
	rts

***********************************************************************
*** level loading stuff ***********************************************
***********************************************************************

;it goes like this...
;it can be done two ways. leave all memory allocations 
;exactly where they are, ie all over the place, and load the seperate
;bits into the right place. ugly and easy to create your own level ed..
;(which is NOT good!) in which case...the below is used

;load data\levels\'num'
;       that tells us what graphic set to load up, ie 'data\graphics\1.set
;       also tells us what map to load. ie data\maps\'whatever'

;or, we can shift all the memory allocations to a contiguous block
;somewhere, ie textures, then map, then.. etc..
;and just load one huge level file into this area..
;the level file contains everything!
;all level files will be EXACTLY the same size, cos of memory allocations
;so we always know EXACTLY how much to load in!
;if this is true, we just load in
;levels\'num' =]
;saves\  is where it shoves its game saves..
;only snag with this is that its going to take creation of a new util
;that creates the full level format in one go.. bit of a drag..
;(which, luckily for you, fellow atari fan, has been started..)

;personally, I'd recommend the latter, as you are doing less disk accessing
;(opening/closing etc)
;still, I've never trusted my disk code.. =]

***********************************************************************
*** menu stuff ********************************************************
***********************************************************************
clear_full_work_screen
	move.l  work,a0
	move.l  #(20*200)-1,d0
.loop
	move.l  #0,(a0)+
	move.l  #0,(a0)+
	dbf     d0,.loop
	rts

draw_menu_text
	move.l  menu_text_pointer,a0
	lea     menu_font,a1
	move.l  #0,d0
	move.l  #0,d1
.loop
	moveq.l #0,d2
	move.b  (a0)+,d2
	cmp.b   #0,d2
	beq     .quit_all
	sub.b   #32,d2
	mulu    #6*24,d2
	and.l   #$0000ffff,d2

	move.l  work,a2
	add.l   d0,a2   ;across
	add.l   d1,a2   ;down
	rept    24
	move.l  (a1,d2.l),(a2)+
	move.w  4(a1,d2.l),(a2)+
	add.l   #154,a2                 ;next scanline..
	add.l   #6,d2                   ;next line..
	endr

	add.l   #8,d0
	cmp.l   #160,d0
	blt     .x_ok
		move.l  #0,d0
		add.l   #25*160,d1
		cmp.l   #199*160,d1
		bge     .quit_all
.x_ok
	bra     .loop                   ;this were we loop back up..    
.quit_all
	rts

highlight_selected_option
	move.l  menu_options_pointer,a0
	move.l  (a0)+,d7                ;number of options
	
	move.l  menu_old_op_select,d0
	mulu    #12,d0
	and.l   #$0000ffff,d0   ;clear shite..
	movem.l (a0,d0.l),d0-d2 ;x,y,width..
.loop_1
	move.l  work,a1 ;work on physic.. faster then.. =]
	add.l   d0,a1
	add.l   d1,a1
	rept    24
		move.w  #0,6(a1)
		lea     160(a1),a1      ;next line
	endr

	add.l   #8,d0
	cmp.l   #160,d0
	blt     .x_ok
		move.l  #0,d0
		add.l   #25*160,d1
		cmp.l   #199*160,d1
		bge     .stop_clearing_1
.x_ok
	dbf     d2,.loop_1
.stop_clearing_1


	move.l  menu_current_op_select,d0
	mulu    #12,d0
	and.l   #$0000ffff,d0   ;clear shite..
	movem.l (a0,d0.l),d0-d2 ;x,y,width..
.loop_3
	move.l  work,a1 ;work on physic.. faster then.. =]
	add.l   d0,a1
	add.l   d1,a1
	rept    24
		move.w  #$ffff,6(a1)
		lea     160(a1),a1      ;next line
	endr
	add.l   #8,d0
	cmp.l   #160,d0
	blt     .x_ok_2
		move.l  #0,d0
		add.l   #25*160,d1
		cmp.l   #199*160,d1
		bge     .quit_all
.x_ok_2
	dbf     d2,.loop_3
.quit_all
	rts

loop_until_menu_option_select
		;read stick and go up/down the option list until
		;player smacks fire.. return the number of option!
.check_loop
	move.l  #2,d6
.wait_loop
	jsr     wait_vbl        ;good start
	dbf     d6,.wait_loop   ;slow it down!!

	jsr     mouse_stick_control             ;got to read stick!

	jsr     clear_full_work_screen
	jsr     draw_menu_text
	jsr     highlight_selected_option
	jsr     flipper         ;swap em!

	move.l  menu_options_pointer,a0
	move.l  (a0)+,d7        ;number of options!

	cmp.l   #0,button
	bgt     .quit_all       ;ok, they pressed fire!!
.check_up
	cmp.l   #0,joystick_up
	beq     .check_down
		move.l  menu_current_op_select,menu_old_op_select
		sub.l   #1,menu_current_op_select
		cmp.l   #0,menu_current_op_select
		bge     .done_checks
			move.l  #0,menu_current_op_select
			bra     .done_checks
.check_down
	cmp.l   #0,joystick_down
	beq     .done_checks
		move.l  menu_current_op_select,menu_old_op_select
		add.l   #1,menu_current_op_select
		cmp.l   menu_current_op_select,d7
		bgt     .done_checks
			move.l  d7,menu_current_op_select
.done_checks
	move.l  #0,joystick_up
	move.l  #0,joystick_down
	bra     .check_loop
.quit_all
	rts

	
	even
menu_pal        dc.w    $000,$456,$345,$234,$123,$012,$021,$030
		dc.w    $102,$777,$765,$754,$731,$710,$700,$500
menu_text_pointer       dc.l    0
menu_options_pointer    dc.l    0
menu_current_op_select  dc.l    0
menu_old_op_select      dc.l    0
menu_font       incbin  data\menufont.3bt
		even
;               dc.b    "                    "
intro_menu_text dc.b    "  KILLTHINGS V0.8E  "
		dc.b    "(C) 1996 DIGI TALLIS"
		dc.b    "                    "
		dc.b    "HELP  =  MAP/3D GAME"
		dc.b    "UNDO  =         QUIT"
		dc.b    "F1-F6 =      WEAPONS"
		dc.b    "SPACE =   OPEN DOORS"
		dc.b    "  SHOW ME THE DEMO  "
		dc.b    0
main_menu_text  dc.b    "KILLTHINGS  (C) 1996"
		dc.b    "   !DEMO VERSION!   "
		dc.b    "                    "
		dc.b    "     START GAME     "  
		dc.b    "                    "
		dc.b    "QUIT BACK TO DESKTOP"
		dc.b    0
		even
intro_menu_options
	dc.l    0
	dc.l    0,175*160,19
main_menu_options
	dc.l    1       ;number of options
	dc.l    0,75*160,19     ;x,y,width..
	dc.l    0,125*160,19


	even
***********************************************************************
*** teleport stuff ****************************************************
***********************************************************************
player_walked_onto_a_teleport
	move.l  #NO,player_teleport_flag
	lea     teleport_data,a0

	move.l  player_z_pos_in_map,d5
	move.l  player_x_pos_in_map,d6
	and.l   #$0000ffff,d5
	and.l   #$0000ffff,d6   ;clear some shite..

	move.l  #MAX_NUM_TELEPORTS-1,d7
.check_loop
	cmp.l   #NO,16(a0)      ;is this one used?
	beq     .skip_this_one
			;d5,d6=player z,x..
		cmp.l   (a0),d5
		blt     .skip_this_one
		cmp.l   8(a0),d5
		bgt     .skip_this_one
		cmp.l   4(a0),d6
		blt     .skip_this_one
		cmp.l   12(a0),d6
		bgt     .skip_this_one
		
		move.l  #YES,player_teleport_flag
		cmp.l   #TELEPORT_TYPE_EXIT,20(a0)
		beq     .its_a_level_teleport
			move.l  #-1,player_teleport_to_level
			movem.l 24(a0),d0-d1            ;teleport to x,z
			move.l  d1,player_x_pos_in_map
			move.l  d1,world_x_translation
			move.l  d0,player_z_pos_in_map
			move.l  d0,world_z_translation
			add.l   d0,d0                   ;double it..
			sub.l   d0,world_z_translation  ;get it right...
			bra     .quit_whole_rout
.its_a_level_teleport
			move.l  32(a0),player_teleport_to_level
			bra     .quit_whole_rout
.skip_this_one
	lea     36(a0),a0       ;next teleport
	dbf     d7,.check_loop
.quit_whole_rout
	rts


***********************************************************************
*** door stuff ********************************************************
***********************************************************************
translate_door_points_into_rotated_points       
	lea     static_door_data,a0
	lea     rotated_door_data,a1
	move.l  num_doors_used,d7
	sub.l   #1,d7                   ;get it right..
.loop
	move.l  4(a0),d0        ;z1
	move.l  (a0),d1         ;x1
	move.l  12(a0),d2       ;z2
	move.l  8(a0),d3        ;x2

	sub.l   world_x_translation,d0
	add.l   world_z_translation,d1
	sub.l   world_x_translation,d2
	add.l   world_z_translation,d3

	movem.l d0-d3,(a1)      ;shove em over..

	lea     28(a0),a0
	lea     20(a1),a1
	dbf     d7,.loop
	rts

rotate_doors_from_static_into_rotated
	lea     rotated_door_data,a1
	lea     sin_table,a2
	lea     cos_table,a3
	move.l  num_doors_used,d7
	sub.l   #1,d7                   ;get it right..

	move.l  current_angle_of_world_rotation,d6
	lsl.l   #2,d6                           ;mult angle by 4..
	move.l  (a2,d6.l),d5                    ;sine val of angle!
	move.l  (a3,d6.l),d6                    ;cos val of angle!
				;do this here as it saves a HELL
				;of a lot of time later..
.rot_loop
;ok, do the first point
	movem.l (a1),d0-d1      ;x,z
	movem.l (a1),d2-d3      ;x,z

;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..

	move.l  d0,(a1)
	move.l  d2,4(a1)                ;points are now rotated..

;ok, do the second point
	movem.l 8(a1),d0-d1     ;x,z
	movem.l 8(a1),d2-d3     ;x,z

;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..

	move.l  d0,8(a1)
	move.l  d2,12(a1)               ;points are now rotated..

	lea     20(a1),a1       ;step to next storage point
	dbf     d7,.rot_loop
	rts

control_door_animation
	lea     static_door_data,a0
	lea     rotated_door_data,a1
	lea     door_anim_texture_data,a2
	
	move.l  num_doors_used,d7
	sub.l   #1,d7
.do_loop
	cmp.l   #DOOR_OPENING,24(a0)    ;is this door opening!?
	bne     .check_closing
		add.l   #1,16(a0)
		cmp.l   #MAX_DOOR_ANIM_FRAMES-1,16(a0)
		ble     .its_not_doing_anything         ;its ok!
		move.l  #MAX_DOOR_ANIM_FRAMES-1,16(a0)
		move.l  #DOOR_OPEN,24(a0)               ;now open!
		bra     .its_not_doing_anything         ;its fine!
.check_closing
	cmp.l   #DOOR_CLOSING,24(a0)    ;is it closing then!?
	bne     .its_not_doing_anything
		sub.l   #1,16(a0)
		cmp.l   #0,16(a0)
		bge     .its_not_doing_anything
		move.l  #0,16(a0)
		move.l  #DOOR_CLOSED,24(a0)             ;now closed!
.its_not_doing_anything
	;this is where we get the correct texture out!
	move.l  20(a0),d0                       ;door type!
	mulu    #MAX_DOOR_ANIM_FRAMES*4,d0      ;get past door types!
	and.l   #$0000ffff,d0                   ;clear crap out
	move.l  16(a0),d1                       ;anim frame
	lsl.l   #2,d1                           ;mult by 4
	add.l   d1,d0                           ;get to correct place
	move.l  (a2,d0.l),16(a1)                ;put texture in!

	lea     28(a0),a0
	lea     20(a1),a1
	dbf     d7,.do_loop
	rts


translate_switch_points_into_rotated_points     
	lea     static_switch_position,a0
	lea     rotated_switch_position,a1
	move.l  num_doors_used,d7
	sub.l   #1,d7                   ;get it right..
.loop
	move.l  4(a0),d0        ;z1
	move.l  (a0),d1         ;x1
	move.l  12(a0),d2       ;z2
	move.l  8(a0),d3        ;x2

	sub.l   world_x_translation,d0
	add.l   world_z_translation,d1
	sub.l   world_x_translation,d2
	add.l   world_z_translation,d3

	movem.l d0-d3,(a1)      ;shove em over..

	lea     32(a0),a0
	lea     16(a1),a1
	dbf     d7,.loop
	rts

rotate_switch_from_static_into_rotated
	lea     rotated_switch_position,a1
	lea     sin_table,a2
	lea     cos_table,a3
	move.l  num_doors_used,d7
	sub.l   #1,d7                   ;get it right..

	move.l  current_angle_of_world_rotation,d6
	lsl.l   #2,d6                           ;mult angle by 4..
	move.l  (a2,d6.l),d5                    ;sine val of angle!
	move.l  (a3,d6.l),d6                    ;cos val of angle!
				;do this here as it saves a HELL
				;of a lot of time later..
.rot_loop
;ok, do the first point
	movem.l (a1),d0-d1      ;x,z
	movem.l (a1),d2-d3      ;x,z

;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..

	move.l  d0,(a1)
	move.l  d2,4(a1)                ;points are now rotated..

;ok, do the second point
	movem.l 8(a1),d0-d1     ;x,z
	movem.l 8(a1),d2-d3     ;x,z

;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..

	move.l  d0,8(a1)
	move.l  d2,12(a1)               ;points are now rotated..

	lea     16(a1),a1       ;step to next storage point
	dbf     d7,.rot_loop
	rts


***********************************************************************
*** key checking code *************************************************
***********************************************************************
check_space_for_door
	cmp.b   #57,key
	beq     .they_pressed_space
	rts
.they_pressed_space
	move.l  player_z_pos_in_map,d0
	move.l  player_x_pos_in_map,d1
	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1   ;clear some shite..
	move.l  d0,d2
	move.l  d1,d3           

	move.l  #SWITCH_COLLISION_SIZE/2,d4
	add.l   d4,d2
	sub.l   d4,d0
	bpl     .its_ok_1
		move.l  #0,d0
		move.l  #SWITCH_COLLISION_SIZE,d2
.its_ok_1
	add.l   d4,d3
	sub.l   d4,d1
	bpl     .its_ok_2
		move.l  #0,d1
		move.l  #SWITCH_COLLISION_SIZE,d3
.its_ok_2

	lea     static_door_data,a0
	lea     static_switch_position,a1
	lea     pickups_player_has,a2
	move.l  num_doors_used,d7
	sub.l   #1,d7                   ;get it right!!
.check_loop
	cmp.l   (a1),d0
	bgt     .next_check
	cmp.l   (a1),d2
	blt     .next_check
	cmp.l   4(a1),d1
	bgt     .next_check
	cmp.l   4(a1),d3
	blt     .next_check     ;oh dear, not in zone..

	cmp.l   8(a1),d0
	bgt     .next_check
	cmp.l   8(a1),d2
	blt     .next_check
	cmp.l   12(a1),d1
	bgt     .next_check
	cmp.l   12(a1),d3
	blt     .next_check     ;oh dear, not in zone..
		
		;only do it if BOTH points are within zone!
		move.l  16(a1),d6               ;door its connected to!
		mulu    #28,d6                  ;get to correct door data
		and.l   #$0000ffff,d6           ;clear shite!

;check to see if we've got a key for the door type!
		move.l  20(a0,d6.l),d5  ;door type
		cmp.l   #DOOR_TYPE_RED_KEY,d5
		bne     .not_red
			move.l  #P_RED_KEY,d5
			lsl.l   #2,d5           ;mult by 4
			cmp.l   #NO,(a2,d5.l)   ;do we have the key?
			beq     .next_check
			bra     .ok_switch_the_switch
.not_red
		cmp.l   #DOOR_TYPE_YELLOW_KEY,d5
		bne     .not_yellow
			move.l  #P_YELLOW_KEY,d5
			lsl.l   #2,d5           ;mult by 4
			cmp.l   #NO,(a2,d5.l)   ;do we have the key?
			beq     .next_check
			bra     .ok_switch_the_switch
.not_yellow
		cmp.l   #DOOR_TYPE_BLUE_KEY,d5
		bne     .ok_switch_the_switch
			move.l  #P_BLUE_KEY,d5
			lsl.l   #2,d5           ;mult by 4
			cmp.l   #NO,(a2,d5.l)   ;do we have the key?
			beq     .next_check

.ok_switch_the_switch
		cmp.l   #SWITCH_ON,20(a1)
		bne     .switch_is_off
		move.l  #DOOR_CLOSING,24(a0,d6.l)       ;close the door!
		move.l  #SWITCH_OFF,20(a1)      ;turn it off..
		bra     .next_check
.switch_is_off
		move.l  #DOOR_OPENING,24(a0,d6.l)       ;open the door!
		move.l  #SWITCH_ON,20(a1)       ;turn it off..
.next_check
	add.l   #32,a1
	dbf     d7,.check_loop
	rts


check_tab_for_map
	cmp.b   #98,key         ;actually this is 'HELP'
	bne.s   .quit
	add.l   #1,map_or_3d_drawing_mode
		cmp.l   #2,map_or_3d_drawing_mode
		blt.s   .quit
		move.l  #0,map_or_3d_drawing_mode
.quit
	rts

***********************************************************************
*** scorecard, font printing stuff etc ********************************
***********************************************************************
;this is all temp! it needs nice fancy gfx drawing for it!
;and then it needs all this code to be rewritten to make use of them!
copy_scorecard_background_to_work
	move.l  work,a0
	lea     scorecard_background,a1
	move.l  #200-1,d7
.loop_1
	move.l  (a1),(a0)
	move.l  4(a1),4(a0)     ;first 16 covered..
	move.l  8(a1),8(a0)
	move.l  12(a1),12(a0)   ;next 16 pix.. thats the left done..

	move.l  (a1),144(a0)
	move.l  4(a1),148(a0)   ;first 16 covered..
	move.l  8(a1),152(a0)
	move.l  12(a1),156(a0)  ;next 16 pix.. thats the right done..

	add.l   #16,a1
	add.l   #160,a0
	dbf     d7,.loop_1      
	rts

print_text_one_bitplane
		;d0=x, d1=y, a0=screen address, a1=text address
		;x=0 to 39.. y=0 to 192 (scanlines..)
	lea     one_bitplane_font_table,a2
	lea     mulu_160_table,a3
	lea     one_bitplane_text_font,a4
	lea     one_bitplane_mulu_2_table,a5    
.again
	moveq.l #0,d2   ;clear it!
	move.b  (a1)+,d2
	cmp.l   #13,d2
	beq.s   .reset_x
	cmp.l   #10,d2
	beq.s   .inc_y
	cmp.l   #0,d2
	beq.s   .quit_print

	movem.l a0/d0-d3,-(sp)  ;plink!!
	lsl.l   #3,d0           ;multiply by 8
	lsl.l   #2,d1           ;multiply by 4
	add.l   (a2,d0.l),a0    ;go across screen to right place
	add.l   (a3,d1.l),a0    ;go down the screen right amount!

	lsl.l   #2,d2           ;mulu by 4..
	move.l  (a5,d2.l),d2    ;get *32 value out.. Sneaky..

	add.l   4(a2,d0.l),d2   ;and into bank for the right frame
i       set     0
j       set     0
	rept    8
	move.w  j(a4,d2.l),d3
	or.w    d3,i(a0)
i       set     i+160
j       set     j+2
	endr
	movem.l (sp)+,a0/d0-d3  ;plonk!

	addq.l  #1,d0           ;go across screen by one...
	cmp.l   #40,d0
	blt     .again
.reset_x
	moveq.l #0,d0
.inc_y
	addq.l  #8,d1
	cmp.l   #192,d1
	blt     .again
.ok
	bra     .again
.quit_print
	rts

print_health_text_on_work
	;got to convert from number to string first..
	lea     health_text,a0
;0 = 48 ascii
	move.l  players_health,d0
	move.l  d0,d1
	divu    #10,d0
	and.l   #$0000ffff,d0   ;clear shite
	move.b  d0,(a0)
	add.b   #48,(a0)        ;got first number
	mulu    #10,d0  ;mult it back up
	and.l   #$0000ffff,d0
	sub.l   d0,d1   ;sub it
	move.b  d1,1(a0)
	add.b   #48,1(a0)       ;next char

	move.l  work,a0
	add.l   #20*160,a0
	move.l  #0,d0
i       set     0
	rept    8
	move.l  d0,i(a0)
	move.l  d0,i+4(a0)
	move.l  d0,i+8(a0)
	move.l  d0,i+12(a0)
i       set     i+160
	endr

	move.l  work,a0         ;print it!
	lea     health_text,a1
	move.l  #1,d0
	move.l  #20,d1
	jsr     print_text_one_bitplane

	rts

print_current_weapon_ammo
	;got to convert from number to string first..
	lea     current_weapon_ammo_text,a0
;0 = 48 ascii
	move.l  current_used_weapon,d6
	lsl.l   #2,d6                   ;mult by 4
	lea     pickups_player_has_values,a1
	move.l  (a1,d6.l),d0            ;get the value!
	
	move.l  d0,d1

	divu    #10,d0
	and.l   #$0000ffff,d0   ;clear shite
	move.b  d0,(a0)
	add.b   #48,(a0)        ;got first number
	mulu    #10,d0  ;mult it back up
	and.l   #$0000ffff,d0
	sub.l   d0,d1   ;sub it
	move.b  d1,1(a0)
	add.b   #48,1(a0)       ;next char

	move.l  work,a0
	add.l   #50*160,a0
	move.l  #0,d0
i       set     0
	rept    8
	move.l  d0,i(a0)
	move.l  d0,i+4(a0)
	move.l  d0,i+8(a0)
	move.l  d0,i+12(a0)
i       set     i+160
	endr

	move.l  work,a0         ;print it!
	lea     current_weapon_ammo_text,a1
	move.l  #1,d0
	move.l  #50,d1
	jsr     print_text_one_bitplane

	rts


print_vbl_counter
	;got to convert from number to string first..
	lea     vbl_text,a0
;0 = 48 ascii
	move.b  vbl_flag,(a0)
	add.b   #48,(a0)        ;got first number

	move.l  work,a0
	add.l   #0*160,a0
	move.l  #0,d0
i       set     0
	rept    8
	move.l  d0,i(a0)
	move.l  d0,i+4(a0)
	move.l  d0,i+8(a0)
	move.l  d0,i+12(a0)
i       set     i+160
	endr

	move.l  work,a0         ;print it!
	lea     vbl_text,a1
	move.l  #1,d0
	move.l  #0,d1
	jsr     print_text_one_bitplane

	rts

print_current_weapon_used_on_work
	;got to convert from number to string first..
	lea     current_weapon_text,a0
;0 = 48 ascii
	move.l  current_used_weapon,d0
	move.b  d0,(a0)
	add.b   #48,(a0)        ;got first number

	move.l  work,a0
	add.l   #40*160,a0
	move.l  #0,d0
i       set     0
	rept    8
	move.l  d0,i(a0)
	move.l  d0,i+4(a0)
	move.l  d0,i+8(a0)
	move.l  d0,i+12(a0)
i       set     i+160
	endr

	move.l  work,a0         ;print it!
	lea     current_weapon_text,a1
	move.l  #1,d0
	move.l  #40,d1
	jsr     print_text_one_bitplane

	rts


	even
health_text                     dc.b    "00",0
current_weapon_text             dc.b    "0",0
current_weapon_ammo_text        dc.b    "00",0
vbl_text                        dc.b    "0",0
	even


***********************************************************************
*** pickup handling code **********************************************
***********************************************************************
player_collided_with_pickup
	move.l  player_z_pos_in_map,d0
	move.l  player_x_pos_in_map,d1
	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1   ;clear some shite..
	move.l  d0,d2
	move.l  d1,d3           

	move.l  #PICKUP_COLLISION_SIZE/2,d4
	add.l   d4,d2
	sub.l   d4,d0
	bpl     .its_ok_1
		move.l  #0,d0
		move.l  #PICKUP_COLLISION_SIZE,d2
.its_ok_1       
	add.l   d4,d3
	sub.l   d4,d1
	bpl     .its_ok_2
		move.l  #0,d1
		move.l  #PICKUP_COLLISION_SIZE,d3
.its_ok_2

	lea     pickup_static_data,a0
	lea     pickups_player_has,a1
	lea     pickups_player_has_values,a2
	lea     pickup_values,a3
	move.l  #MAX_NUM_PICKUPS-1,d7
.check_loop
	cmp.l   #NO,12(a0)
	beq     .next_check     ;not used, then check if in zone..

	cmp.l   (a0),d0
	bgt     .next_check
	cmp.l   (a0),d2
	blt     .next_check
	cmp.l   4(a0),d1
	bgt     .next_check
	cmp.l   4(a0),d3
	blt     .next_check     ;oh dear, not in zone..

		move.l  8(a0),d4        ;the pickups type!!
					;its a number between 0-whatever..
		cmp.l   #P_HEALTH_SMALL,d4      ;is it health?
		beq     .its_a_health
		cmp.l   #P_HEALTH_LARGE,d4      ;is it health?!
		beq     .its_a_health
.its_not_a_health
		lsl.l   #2,d4           ;mult it by 4!
		cmp.l   #MAX_PICKUP_VALUE,(a2,d4.l)     ;is this max?
		beq     .next_check

		move.l  #YES,(a1,d4.l)  ;they have now got this pickup!!
		move.l  #NO,12(a0)      ;kill the pickup!!
					;dont want everlasting pickups!
		move.l  (a3,d4.l),d5
		add.l   d5,(a2,d4.l)            ;increase it!
		cmp.l   #MAX_PICKUP_VALUE,(a2,d4.l)
		blt     .next_check
		move.l  #MAX_PICKUP_VALUE,(a2,d4.l)     ;set it back!
		bra     .next_check
.its_a_health
		lsl.l   #2,d4           ;mult it by 4!
		cmp.l   #99,players_health      ;is this max?
		beq     .next_check

		move.l  #YES,(a1,d4.l)  ;they have now got this pickup!!
		move.l  #NO,12(a0)      ;kill the pickup!!
					;dont want everlasting pickups!

		move.l  (a3,d4.l),d5
		add.l   d5,players_health       ;tadah!
				;add on the right value!                
		move.l  #NO,12(a0)              ;kill the pickup
		cmp.l   #99,players_health
		blt     .next_check
		move.l  #99,players_health      ;set it right
.next_check
	lea     20(a0),a0       ;next 
	dbf     d7,.check_loop
	rts     

translate_pickup_points_into_rotated_points     
	lea     pickup_static_data,a0
	lea     pickup_rotated_data,a1
	move.l  #MAX_NUM_PICKUPS-1,d7
.loop
	move.l  4(a0),d0        ;z
	move.l  (a0),d1         ;x
	sub.l   world_x_translation,d0
	add.l   world_z_translation,d1
	move.l  d0,(a1) ;z 
	move.l  d1,4(a1)        ;x      ;copy em..

	add.l   #20,a0
	add.l   #12,a1
	dbf     d7,.loop
	rts

rotate_static_pickup_data_into_rotated
	lea     pickup_rotated_data,a1
	lea     sin_table,a2
	lea     cos_table,a3
	move.l  #MAX_NUM_PICKUPS-1,d7

	move.l  current_angle_of_world_rotation,d6
	lsl.l   #2,d6                           ;mult angle by 4..
	move.l  (a2,d6.l),d5                    ;sine val of angle!
	move.l  (a3,d6.l),d6                    ;cos val of angle!
				;do this here as it saves a HELL
				;of a lot of time later..
.rot_loop
;ok, do the first point
	movem.l (a1),d0-d1      ;x,z
	movem.l (a1),d2-d3      ;x,z

;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..

	move.l  d0,(a1)
	move.l  d2,4(a1)                ;points are now rotated..
	add.l   #12,a1          ;step to next storage point

	dbf     d7,.rot_loop
	rts

control_pickups_animation
	lea     pickup_static_data,a0
	lea     pickup_rotated_data,a1
	lea     pickup_texture_to_use_data,a2
	move.l  #MAX_NUM_PICKUPS-1,d7
.do_loop
	cmp.l   #NO,12(a0)      ;is this one used?
	beq     .next_pickup

		add.l   #1,16(a0)
		cmp.l   #MAX_PICKUPS_ANIM_FR,16(a0)
		blt     .an_fr_ok
		move.l  #0,16(a0)       ;clear it
.an_fr_ok
		move.l  16(a0),d0       ;the counter
		lsl.l   #2,d0           ;mult it by 4.. 
		move.l  8(a0),d1        ;the type..
		mulu    #MAX_PICKUPS_ANIM_FR*4,d1
		and.l   #$0000ffff,d1
		add.l   d1,d0           ;get past the data for other
					;pickups!
		move.l  (a2,d0.l),8(a1) ;what texture?!
			;hey presto, animating textures!!
.next_pickup
	add.l   #20,a0
	add.l   #12,a1
	dbf     d7,.do_loop
	rts



***********************************************************************
*** Bullet handling code **********************************************
***********************************************************************
*** To do different weapons use different textures, different powers..
*** and for the shotgun use 5 or so bullets, each with different targets
*** (on a small spread) smack the volicity up by a lot! and don't
*** use a filled in texture! (use a blank one, animate the wall collision!)

*** this code makes use of add'ing and sub'ing MAX_BULLET_DISTANCE
*** to and from the x,z.. this is to stop the 'minus = HUGE value' bug!
*** its a fudge, but it works perfectly!
*** if it works.. don't touch it! =]

request_and_fire_bullet
	;x1=d0,y1=d1,x2=d2,y2=d3,type=d4
	move.l  #NO,bullet_fired                ;NO BULLET FIRED!

	movem.l d0-d7/a0-a1,-(sp)               ;stack em all..
	lea     bullet_data_store,a0
	lea     bullet_type_lookup_table,a1

	lsl.l   #4,d4           ;mult by 4(data entries) * 4(longword).. 
	move.l  #MAX_NUM_BULLETS-1,d7
.check_loop
	cmp.l   #YES,(a0)               ;this bullet used?
	beq     .next_check
		move.l  #YES,(a0)       ;bullet used now
		movem.l (a1,d4.l),d4-d6 ;speed,power,texture
		movem.l d0-d6,4(a0)     ;x,z,x,z,speed,power,texture

		move.l  #BULLET_COLLISION_SIZE/2,d5
;divide zone by current speed..
		divu    d4,d5
		and.l   #$0000ffff,d5
;got a number of times it will have to be done before it gets out of zone
		add.l   #JUST_FIRED+1,d5
		move.l  d5,36(a0)       ;show it in!

		move.l  #MAX_BULLET_DISTANCE,32(a0)     ;set the distance..
							;its a failsafe
		move.l  #YES,bullet_fired       ;yes! we've fired one!!
		bra     .quit_whole_subroutine
					;might as well get out since
					;we've fired a bullet!!
.next_check
	lea     40(a0),a0               ;get to next bullet data
	dbf     d7,.check_loop
.quit_whole_subroutine
	movem.l (sp)+,d0-d7/a0-a1       ;unstack
	rts

control_bullets
	;move em all towards their targets by their speed
	;check for collisions with walls/objects/player etc.
	;if we've got one, set an explosion and free up the bullet
	lea     bullet_data_store,a0
	move.l  #MAX_NUM_BULLETS-1,d7
.loop
	cmp.l   #NO,(a0)                ;this bullet used?
	beq     .next_bullet            ;no its not!
	
;check bullet collision with walls
		movem.l 4(a0),d0-d1     ;x,z
		sub.l   #MAX_BULLET_DISTANCE,d0
		sub.l   #MAX_BULLET_DISTANCE,d1 ;get them correct
		jsr     circle_wall_collision_detection
		cmp.l   #NO,circle_wall_collision_flag
		beq     .no_wall_collision
			move.l  #NO,(a0)        ;bullet unused now.
			move.l  #0,32(a0)       ;set timer to zero
			move.l  #0,d2   ;the type..
			jsr     request_and_set_explosion
			bra     .next_bullet
.no_wall_collision
;now check bullet collision against doors!              
		movem.l 4(a0),d0-d1     ;x,z
		sub.l   #MAX_BULLET_DISTANCE,d0
		sub.l   #MAX_BULLET_DISTANCE,d1 ;get them correct
		jsr     circle_door_collision_detection
		cmp.l   #NO,circle_wall_collision_flag
		beq     .no_door_collision
			move.l  #NO,(a0)        ;bullet unused now.
			move.l  #0,32(a0)       ;set timer to zero
			move.l  #0,d2   ;the type..
			jsr     request_and_set_explosion
			bra     .next_bullet
.no_door_collision
	cmp.l   #JUST_FIRED,36(a0)      ;has it just been fired?
	bge     .control_bullet
;first lets check collision with player..
		movem.l 4(a0),d0-d1     ;x,z
		sub.l   #MAX_BULLET_DISTANCE,d0
		sub.l   #MAX_BULLET_DISTANCE,d1 ;get them correct
		jsr     bullet_player_collision
		cmp.l   #YES,bullet_player_collision_flag
		bne     .bullet_monster_check           ;control it!!
			move.l  #NO,(a0)        ;bullet is unused!
			move.l  #0,32(a0)       ;set timer to zero
			move.l  #0,d2   ;the type..
			jsr     request_and_set_explosion

			move.l  24(a0),d0       ;can't do sub 24(a0),
			sub.l   d0,players_health
			cmp.l   #0,players_health
			bgt     .player_health_ok
			move.l  #0,players_health
.player_health_ok
			bra     .next_bullet
;now lets check if bullet has collided with a monster..
.bullet_monster_check
		movem.l 4(a0),d0-d1     ;x,z
		sub.l   #MAX_BULLET_DISTANCE,d0
		sub.l   #MAX_BULLET_DISTANCE,d1 ;get them correct
		move.l  24(a0),bullet_monster_col_bul_power
					;how powerful is bullet?!
		jsr     bullet_monster_collision
		cmp.l   #YES,bullet_monster_collision_flag
		bne     .control_bullet         ;control it!!
			move.l  #NO,(a0)        ;bullet is unused!
			move.l  #0,32(a0)       ;set timer to zero
			move.l  #0,d2   ;the type..
			jsr     request_and_set_explosion

			bra     .next_bullet
.control_bullet
;first off all, decrease JUST_FIRED
		sub.l   #1,36(a0)       ;take down just fired..
		cmp.l   #0,36(a0)
		bge     .just_fired_ok
		move.l  #0,36(a0)       ;set it to zero..
.just_fired_ok
		movem.l 4(a0),d0-d4     ;x,z,x,z,speed
;ok, check the timer..
		sub.l   d4,32(a0)       ;decrease the length by speed
		cmp.l   #0,32(a0)       ;is it zero?
		bgt     .timer_ok
		move.l  #0,32(a0)       ;set it to zero
		move.l  #NO,(a0)        ;its now unused!
.timer_ok
		jsr     step_along_line_between_points
		move.l  step_line_x_result,4(a0)
		move.l  step_line_y_result,8(a0)        ;set new pos!
;TODO   ;check_bullets_collision with monsters etc.
	;if so then set an explosion!


;if bullet has reached its target then set explosion
.check_dest
		move.l  12(a0),d2
		move.l  16(a0),d3       ;the destination dest..
		cmp.l   step_line_x_result,d2   ;x
		bne     .next_bullet
		cmp.l   step_line_y_result,d3   ;z
		bne     .next_bullet
		move.l  #NO,(a0)                        ;bullet is now unused!
;TODO   ;set an explosion!!

.next_bullet
	lea     40(a0),a0               ;get to next bullet data
	dbf     d7,.loop
	rts

draw_used_bullets
	move.l  work,a0
	lea     point_data,a1
	lea     mulu_160_table,a2
	lea     point_across_data,a3
	lea     rotated_bullet_data_store,a4
	move.l  #MAX_NUM_BULLETS-1,d7
.loop
	cmp.l   #NO,(a4)
	beq     .no_draw
	movem.l 4(a4),d2-d3                     ;the x,z
	lsr.l   #MAP_DRAW_DIVISION,d2           ;divide em down
	lsr.l   #MAP_DRAW_DIVISION,d3
	move.l  #160,d0                         ;put the screen origin 
	move.l  #100,d1
	sub.l   d2,d0                           ;sub it...
	sub.l   d3,d1
	
	and.l   #$0000ffff,d0   ;do this to clear the second word
	and.l   #$0000ffff,d1   ;in each longword. see later for 
				;long explanation!
	cmp.l   #0+32,d0                ;not onscreen!?
	blt.s   .no_draw        ;don't plot it!
	cmp.l   #319-32,d0
	bgt.s   .no_draw
	cmp.l   #0,d1
	blt.s   .no_draw
	cmp.l   #199,d1
	bgt.s   .no_draw
***point plot!
	lsl.l   #2,d1           ;mult by 4
	move.l  (a2,d1.l),d3    ;temp_store, go down the screen..

	lsl.l   #2,d0           ;mult by 4..
	move.w  (a1,d0.l),d2    ;get point data..

	add.l   (a3,d0.l),d3    ;across screen pointer..
	or.w    d2,(a0,d3.l)            ;plop it onscreen..
.no_draw
	lea     40(a4),a4       ;skip z,x,texture
	dbf     d7,.loop
	rts

check_weapon_change_keys
	cmp.b   #59,key
	blt     .bugger_off
	cmp.b   #64,key
	bgt     .bugger_off
		;ok, pressed and F-key between F1 and F6
		move.l  #0,d0
		move.b  key,d0
		sub.l   #59,d0
		move.l  d0,current_used_weapon           
.bugger_off
	rts

check_fire_button
	;decrease the players player_timer_before_fire counter
	;when this gets to zero, he can fire his weapon!
	sub.l   #1,player_timer_before_fire
	cmp.l   #0,player_timer_before_fire
	beq     .go_check
	cmp.l   #0,player_timer_before_fire
	bgt     .too_big
	move.l  #1,player_timer_before_fire
.too_big
	rts
.go_check               ;check the button..
	cmp.l   #0,button
	bgt     .ok
	rts
.ok
	move.l  player_x_pos_in_map,d0
	move.l  player_z_pos_in_map,d1  ;start x,z
	move.l  d0,d2
	move.l  d1,d3
	add.l   player_fire_at_x_pos,d2
	sub.l   player_fire_at_z_pos,d3 ;destination x,z..

	add.l   #MAX_BULLET_DISTANCE,d0
	add.l   #MAX_BULLET_DISTANCE,d1
	add.l   #MAX_BULLET_DISTANCE,d2
	add.l   #MAX_BULLET_DISTANCE,d3 ;get INTO the map!!!

	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1           ;clear out some gunk..
	and.l   #$0000ffff,d2
	and.l   #$0000ffff,d3           ;clear out some crap!!

	move.l  current_used_weapon,d4          ;bullet type..
	lea     weapon_holding_table,a0
	lsl.l   #2,d4
	cmp.l   #NO,(a0,d4.l)           ;do they have the weapon?
	beq     .quit                   ;no weapon = no bullet!!

	lea     pickups_player_has_values,a0
	cmp.l   #0,(a0,d4.l)    ;does player have ammo?!?!?
	beq     .quit           ;no ammo = no bullet!!

	move.l  current_used_weapon,d4
	lea     weapon_reload_timer_and_bullet_type,a0
			;got to get correct bullet type!
	lsl.l   #3,d4   ;mult by 8
	move.l  4(a0,d4.l),d4   ;the bullet type this weapon fires!
	jsr     request_and_fire_bullet
	cmp.l   #NO,bullet_fired
	beq     .quit
		;ok, lets set the reload_timer thing
		;so theres a delay before he can fire again..
		lea     weapon_reload_timer_and_bullet_type,a0
		move.l  current_used_weapon,d0
		lsl.l   #3,d0
		move.l  (a0,d0.l),player_timer_before_fire
			;has to wait this long before player can shoot!

		;right, deduct the correct ammo value, according to 
		;current_used_weapon
		lea     weapon_deduction_values,a0
		lea     pickups_player_has_values,a1
		move.l  current_used_weapon,d0
		lsl.l   #2,d0           ;mult it by 4
		move.l  (a0,d0.l),d1
		sub.l   d1,(a1,d0.l)
		cmp.l   #0,(a1,d0.l)    ;lets check it
		bgt     .quit
		move.l  #0,(a1,d0.l)    ;set it to zero!
.quit
	rts

translate_bullet_points_into_rotated_points     
	lea     bullet_data_store,a0
	lea     rotated_bullet_data_store,a1
	move.l  #MAX_NUM_BULLETS-1,d7
.loop
	move.l  (a0),(a1)               ;used status or not..
	movem.l 4(a0),d0-d1             ;source x,z
	sub.l   world_x_translation,d0
	add.l   world_z_translation,d1
		sub.l   #MAX_BULLET_DISTANCE,d0
		sub.l   #MAX_BULLET_DISTANCE,d1 ;get em RIGHT!!
	move.l  d0,4(a1)        ;z 
	move.l  d1,8(a1)        ;x      ;copy em..

	movem.l 12(a0),d0-d5    ;x,z,speed,power,texture,timer
	movem.l d0-d5,12(a1)    ;the rest..

	lea     40(a0),a0
	lea     40(a1),a1
	dbf     d7,.loop
	rts

rotate_bullet_object_points
	lea     rotated_bullet_data_store,a1
	lea     sin_table,a2
	lea     cos_table,a3
	move.l  #MAX_NUM_BULLETS-1,d7

	move.l  current_angle_of_world_rotation,d6
	lsl.l   #2,d6                           ;mult angle by 4..
	move.l  (a2,d6.l),d5                    ;sine val of angle!
	move.l  (a3,d6.l),d6                    ;cos val of angle!
				;do this here as it saves a HELL
				;of a lot of time later..
.rot_loop
;ok, do the first point
	movem.l 4(a1),d0-d1     ;x,z
	movem.l 4(a1),d2-d3     ;x,z

;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..

	move.l  d0,4(a1)
	move.l  d2,8(a1)        ;points are now rotated..
	lea     40(a1),a1       ;step to next storage point

	dbf     d7,.rot_loop
	rts


***********************************************************************
*** Collision detections! *********************************************
***********************************************************************
bullet_player_collision
	;takes in d0,d1, bullet x,z
	movem.l d0-d7,-(sp)     ;stack em...
	move.l  #NO,bullet_player_collision_flag

	move.l  d0,d2
	move.l  d1,d3
	move.l  #BULLET_COLLISION_SIZE/2,d4
	sub.l   d4,d0
	sub.l   d4,d1
	add.l   d4,d2
	add.l   d4,d3   ;just a wee bit faster..

	cmp.l   #0,d0
	bge     .its_ok_1
	move.l  #0,d0           ;set it to zero if negative
	move.l  #BULLET_COLLISION_SIZE,d2
.its_ok_1
	cmp.l   #0,d1
	bge     .its_ok_2
	move.l  #0,d1           ;set it to zero if negative
	move.l  #BULLET_COLLISION_SIZE,d3
.its_ok_2

	move.l  player_x_pos_in_map,d4
	move.l  player_z_pos_in_map,d5
	and.l   #$0000ffff,d4
	and.l   #$0000ffff,d5
	cmp.l   d4,d0
	bgt     .nope
	cmp.l   d4,d2
	blt     .nope
	cmp.l   d5,d1
	bgt     .nope
	cmp.l   d5,d3
	blt     .nope
	
	move.l  #YES,bullet_player_collision_flag
.nope
	movem.l (sp)+,d0-d7
	rts


bullet_monster_collision
	;takes in d0,d1, bullet x,z
	;if collides with a monster, KILL the monster, set an explo...
	movem.l d0-d7/a0-a1,-(sp)       ;stack em...
	move.l  #NO,bullet_monster_collision_flag

	move.l  d0,d2
	move.l  d1,d3
	move.l  #BULLET_COLLISION_SIZE/2,d4
	sub.l   d4,d0
	sub.l   d4,d1
	add.l   d4,d2
	add.l   d4,d3   ;just a wee bit faster..

	cmp.l   #0,d0
	bge     .its_ok_1
	move.l  #0,d0           ;set it to zero if negative
	move.l  #BULLET_COLLISION_SIZE,d2
.its_ok_1
	cmp.l   #0,d1
	bge     .its_ok_2
	move.l  #0,d1           ;set it to zero if negative
	move.l  #BULLET_COLLISION_SIZE,d3
.its_ok_2

	lea     alien_flags,a0
	lea     static_alien_positions_and_textures,a1
	move.l  number_of_aliens_used,d7
	subq.l  #1,d7                           ;get it right..
.check_loop
	cmp.l   #NUM_DEATH_FRAMES,(a0)  ;is it dying?
	ble     .nope           ;if it aint dead

	movem.l (a1),d4-d5
	cmp.l   d4,d0
	bgt     .nope
	cmp.l   d4,d2
	blt     .nope
	cmp.l   d5,d1
	bgt     .nope
	cmp.l   d5,d3
	blt     .nope
	
	move.l  #1,4(a0)        ;make it active!!
				;will 'fire' at other monsters!
				;whether they are active or not!!
				;boozer mode!! =]
	move.l  #YES,bullet_monster_collision_flag
	move.l  #0,20(a0)       ;set its wander timer to zero..

	move.l  bullet_monster_col_bul_power,d0
	sub.l   d0,(a0)         ;take down its health!
	cmp.l   #NUM_DEATH_FRAMES,(a0)
	bgt     .monster_health_ok
;TODO   
;add onto score!
		move.l  #NUM_DEATH_FRAMES,(a0)          ;its dead mate!!
		move.l  d5,d0
		move.l  d4,d1   ;where to set explosion 
		move.l  #0,d2   ;the type..
		jsr     request_and_set_explosion
		bra     .quit_whole_subroutine
.monster_health_ok
	add.l   #100,12(a0)     ;its ANGRY NOW!!
	move.l  #0,16(a0)       ;set it to home in!

	bra     .quit_whole_subroutine
				;if its collided with something
				;we might as well quit the checks!
.nope
	lea     40(a0),a0       ;skip to next aliens flags!
	lea     12(a1),a1       ;go to next aliens x,z texture!
	dbf     d7,.check_loop
.quit_whole_subroutine
	movem.l (sp)+,d0-d7/a0-a1
	rts

circle_door_collision_detection
	;takes in d0=x, d1=z
	move.l  #NO,circle_wall_collision_flag          ;set that flag!
	movem.l a0-a3/d0-d7,-(sp)                       ;stack regs!
				;create the small collision zone around 
				;the given x,z
	exg     d0,d1   ;swap em around!! ie z,x = x,z
			;reason? walls are z,x,z,x
			;doors are x,z,x,z..
			;checks are slightly different.. 
			;tacky! very tacky!!
	move.l  d0,d2
	move.l  d1,d3           ;store em..
	move.l  #CIRCLE_COLLISION_SIZE/2,d7
	add.l   d7,d2
	sub.l   d7,d0
	bpl     .its_ok_1
		move.l  #0,d0
		move.l  #CIRCLE_COLLISION_SIZE,d2
.its_ok_1
	add.l   d7,d3
	sub.l   d7,d1
	bpl     .its_ok_2
		move.l  #0,d1
		move.l  #CIRCLE_COLLISION_SIZE,d3
.its_ok_2
	lea     circle_wall_small_x1,a0
	movem.l d0-d3,(a0)                      ;shove em in fast..

		;ok, done small collision zone, now do big one!
	move.l  #MAX_OBJECT_SIZE,d7
	add.l   d7,d2
	sub.l   d7,d0
	bpl     .its_ok_3
		move.l  #0,d0
		move.l  #MAX_OBJECT_SIZE*2,d2
.its_ok_3
	add.l   d7,d3
	sub.l   d7,d1
	bpl     .its_ok_4
		move.l  #0,d1
		move.l  #MAX_OBJECT_SIZE*2,d3
.its_ok_4
	lea     circle_wall_wide_x1,a0
	movem.l d0-d3,(a0)              ;shove em in fast

		;lets do the checks!
	lea     static_door_data,a1
	move.l  num_doors_used,d7
	subq.l  #1,d7                           ;get it right..
.loop
	movem.l (a1),d0-d3              ;x1,z1,x2,z2

	cmp.l   circle_wall_wide_x1,d0
	blt.s   .no_draw        
	cmp.l   circle_wall_wide_x2,d0
	bgt.s   .no_draw        
	cmp.l   circle_wall_wide_z1,d1
	blt.s   .no_draw        
	cmp.l   circle_wall_wide_z2,d1          
	bgt.s   .no_draw        
	
	cmp.l   circle_wall_wide_x1,d2          
	blt.s   .no_draw        
	cmp.l   circle_wall_wide_x2,d2          
	bgt.s   .no_draw
	cmp.l   circle_wall_wide_z1,d3
	blt.s   .no_draw
	cmp.l   circle_wall_wide_z2,d3
	bgt.s   .no_draw
				;ok, draw the line, checking each pix!
	jsr     circle_wall_line_draw
	cmp.l   #YES,circle_wall_collision_flag
	bne     .no_draw
	;ok, check to see if door is open or closed..
		cmp.l   #DOOR_OPEN,24(a1)
		bne     .quit_whole_subroutine
				;its closed/closing/opening..
				;can't walk thru it!
		move.l  #NO,circle_wall_collision_flag
				;its open dude! can walk thru it!!
		bra     .quit_whole_subroutine
				;get the hell out of here
.no_draw
	lea     28(a1),a1
	dbf     d7,.loop
.quit_whole_subroutine
	movem.l (sp)+,a0-a3/d0-d7                       ;stack regs!
	rts


circle_wall_collision_detection
	;takes in d0=x, d1=z
	move.l  #NO,circle_wall_collision_flag          ;set that flag!
	movem.l a0-a3/d0-d7,-(sp)                       ;stack regs!
				;create the small collision zone around 
				;the given x,z
	move.l  d0,d2
	move.l  d1,d3           ;store em..
	move.l  #CIRCLE_COLLISION_SIZE/2,d7
	add.l   d7,d2
	sub.l   d7,d0
	bpl     .its_ok_1
		move.l  #0,d0
		move.l  #CIRCLE_COLLISION_SIZE,d2
.its_ok_1
	add.l   d7,d3
	sub.l   d7,d1
	bpl     .its_ok_2
		move.l  #0,d1
		move.l  #CIRCLE_COLLISION_SIZE,d3
.its_ok_2
	lea     circle_wall_small_x1,a0
	movem.l d0-d3,(a0)                      ;shove em in fast..

		;ok, done small collision zone, now do big one!
	move.l  #MAX_WALL_SIZE,d7
	add.l   d7,d2
	sub.l   d7,d0
	bpl     .its_ok_3
		move.l  #0,d0
		move.l  #MAX_WALL_SIZE*2,d2
.its_ok_3
	add.l   d7,d3
	sub.l   d7,d1
	bpl     .its_ok_4
		move.l  #0,d1
		move.l  #MAX_WALL_SIZE*2,d3
.its_ok_4
	lea     circle_wall_wide_x1,a0
	movem.l d0-d3,(a0)              ;shove em in fast

			;now we need to run thru the static walls
			;but first check which number is greater 
			;cos the resulting check algo depends a lot on it!
	move.l  number_3d_world_points,d7
	cmp.l   number_3d_lines,d7
	blt     .old_wall_check_method
					;use the faster method if the
					;number of points is less!!
.new_wall_check_method                                  ;THE NEW METHOD!!!
	lea     static_3d_world_points,a1
	lea     circle_wall_3d_point_lookup_table,a2
				;ok, setup a loop...
	move.l  number_3d_world_points,d7
	sub.l   #1,d7                           ;get it right
.fast_loop
				;ok, clear the current lookup table pos
	move.l  #NO,(a2)
				;right. get the 3d points z,x
	movem.l (a1)+,d0-d1
				;now check to see if they are within 
				;the large collision zone..
	cmp.l   circle_wall_wide_x1,d0
	blt.s   .not_in                 ;change this to if one point is in!
	cmp.l   circle_wall_wide_x2,d0
	bgt.s   .not_in 
	cmp.l   circle_wall_wide_z1,d1
	blt.s   .not_in 
	cmp.l   circle_wall_wide_z2,d1          
	bgt.s   .not_in 
				;hey up. if its got this far its INSIDE! 
				;set the lookup table to YES!
	move.l  #YES,(a2)
.not_in
	add.l   #4,a2                           ;step in
	dbf     d7,.fast_loop

				;brilliant, got a table full of YES/NO's..
				;now we got to run thru the walls...
	lea     world_3d_line_data,a1
	lea     circle_wall_3d_point_lookup_table,a2
	lea     static_3d_world_points,a3
				;setup a loop   
	move.l  number_3d_world_points,d7
	sub.l   #1,d7
.fast_loop_2
				;get the point to points..
	movem.l (a1),d5-d6              ;point 1 to point 2
				;check they are in window.. 
				;by looking em up in the table!!
	lsl.l   #2,d5
	lsl.l   #2,d6                   ;got to get em to mults of 4!
	cmp.l   #NO,(a2,d5.l)
	beq     .not_in_bloody_window
	cmp.l   #NO,(a2,d6.l)
	beq     .not_in_bloody_window
				;sod me. they must be in the window!
	lsl.l   #1,d5
	lsl.l   #1,d6                   ;mult em to to mults of 8..     
	movem.l (a3,d5.l),d0-d1         ;first x,z
	movem.l (a3,d6.l),d2-d3         ;second x,z
				;ok, got the points which make up the line!
				;draw the sod, checking for 'small window' 
				;collision on each point!
	jsr     circle_wall_line_draw
	cmp.l   #YES,circle_wall_collision_flag
	beq     .quit_whole_subroutine
.not_in_bloody_window
	add.l   #16,a1          ;get to next wall data store
	dbf     d7,.fast_loop_2

	bra     .quit_whole_subroutine  ;skip the OLD routine!!

.old_wall_check_method                                  ;THE OLD METHOD!!!
	lea     world_3d_line_data,a1
	lea     static_3d_world_points,a2
	move.l  number_3d_lines,d7
	subq.l  #1,d7                           ;get it right..
.loop
	movem.l (a1)+,d5-d6     ;point 1 to point 2
	move.l  (a1)+,d4        ;texture to draw in
	move.l  (a1)+,d4        ;the 'padding bit'
	lsl.l   #3,d5   ;two longwords = 8
	lsl.l   #3,d6   ;mult by 8.. step into 3d points this much..

	movem.l (a2,d5.l),d0-d1         ;first x,z
	movem.l (a2,d6.l),d2-d3         ;second x,z

	cmp.l   circle_wall_wide_x1,d0
	blt.s   .no_draw        
	cmp.l   circle_wall_wide_x2,d0
	bgt.s   .no_draw        
	cmp.l   circle_wall_wide_z1,d1
	blt.s   .no_draw        
	cmp.l   circle_wall_wide_z2,d1          
	bgt.s   .no_draw        
	
	cmp.l   circle_wall_wide_x1,d2          
	blt.s   .no_draw        
	cmp.l   circle_wall_wide_x2,d2          
	bgt.s   .no_draw
	cmp.l   circle_wall_wide_z1,d3
	blt.s   .no_draw
	cmp.l   circle_wall_wide_z2,d3
	bgt.s   .no_draw
				;ok, draw the line, checking each pix!
	jsr     circle_wall_line_draw
	cmp.l   #YES,circle_wall_collision_flag
	beq     .quit_whole_subroutine
.no_draw
	dbf     d7,.loop

.quit_whole_subroutine                                          ;QUIT IT!!
	movem.l (sp)+,a0-a3/d0-d7
	rts


circle_wall_line_draw
	;takes in d0=x1,d1=z1,d2=x2,d3=z2
	movem.l a5-a6/d0-d7,-(sp)       ;stack them!

	move.l  d2,line_draw_X2
	move.l  d3,line_draw_Y2 ;destination..

	sub.l   d0,d2                   ;dx = x2-x1
	sub.l   d1,d3                   ;dy = y2-y1

	moveq.l #0,d4                   ;c = 0
	moveq.l #0,d5                   ;m = 0
	moveq.l #0,d6                   ;d = 0
	
	move.l  #1,a5                   ;xinc = 1
	move.l  #1,a6                   ;yinc = 1

	cmp.l   #0,d2                   ;if dx < 0
	bgt.s   .next
	move.l  #-1,a5                  ;xinc = -1
	neg.l   d2                      ;dx = -dx
.next   
	cmp.l   #0,d3                   ;if dy < 0
	bgt.s   .next_2
	move.l  #-1,a6                  ;yinc = -1
	neg.l   d3                      ;dy = -dy
.next_2
	cmp.l   d3,d2                   ;if dy < dx
	bgt     .draw_2
.draw_1
	move.l  d3,d4
	add.l   d4,d4                   ;c = 2*dy

	move.l  d2,d5
	add.l   d5,d5                   ;m = 2*dx

.no_quit
	cmp.l   circle_wall_small_x1,d0
	blt.s   .no_draw
	cmp.l   circle_wall_small_x2,d0
	bgt.s   .no_draw
	cmp.l   circle_wall_small_z1,d1
	blt.s   .no_draw
	cmp.l   circle_wall_small_z2,d1
	bgt.s   .no_draw
		move.l  #YES,circle_wall_collision_flag ;set that flag!
		bra     .quit_drawing
.no_draw        
	add.l   a6,d1                   ;y = y+yinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d3                   ;if d > dy
	bgt.s   .nope
	add.l   a5,d0                   ;x = x+xinc     
	sub.l   d4,d6                   ;d = d-c
.nope
	cmp.l   line_draw_Y2,d1         ;if y <> y2
	bne     .no_quit
	bra     .quit_drawing
.draw_2
	move.l  d2,d4
	add.l   d4,d4                   ;c = 2*dx
	
	move.l  d3,d5
	add.l   d5,d5                   ;m = 2*dy
.no_quit_2      
	cmp.l   circle_wall_small_x1,d0
	blt.s   .no_draw2
	cmp.l   circle_wall_small_x2,d0
	bgt.s   .no_draw2
	cmp.l   circle_wall_small_z1,d1
	blt.s   .no_draw2
	cmp.l   circle_wall_small_z2,d1
	bgt.s   .no_draw2
		move.l  #YES,circle_wall_collision_flag ;set that flag!
		bra     .quit_drawing
.no_draw2
	add.l   a5,d0                   ;x = x+xinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d2                   ;if d > dx
	bgt.s   .nope_2
	add.l   a6,d1                   ;y = y+yinc
	sub.l   d4,d6                   ;d = d-c
.nope_2         
	cmp.l   line_draw_X2,d0         ;if x <> x2
	bne     .no_quit_2
.quit_drawing
	movem.l (sp)+,a5-a6/d0-d7       ;get them back!
	rts
	

***********************************************************************
*** Explosion code! ***************************************************
***********************************************************************
*** pretty easy..
*** set an explosion, every explosion has a set 'scale'
*** big scale = big sprites and stuff..

request_and_set_explosion
	;takes in x,z,type (d0,d1,d2)
	movem.l d0-d3/a0-a3,-(sp)               ;stack em
	lea     static_explosion_pos_data,a0
	lea     explosion_type_data,a1
	lea     explosion_anim_tables,a2
	lea     explosion_width_tables,a3

	move.l  #MAX_NUM_EXPLOSIONS-1,d3
.check_loop
	cmp.l   #YES,(a1)
	beq     .done_check
		movem.l d0-d1,(a0)      ;shove position in!
		move.l  #YES,(a1)       ;set it to used
		move.l  d2,4(a1)        ;the type
		move.l  #0,8(a1)        ;set the timer to zero
		bra     .quit_whole_routine
.done_check
	lea     16(a0),a0
	lea     12(a1),a1
	dbf     d3,.check_loop
.quit_whole_routine
	movem.l (sp)+,d0-d3/a0-a3               ;unstack em
	rts

control_explosions
;dead easy
;run thru all used xplosions, increasing timer and changing
;texture and width according to the anim tables..
	lea     static_explosion_pos_data,a0
	lea     explosion_type_data,a1
	lea     explosion_anim_tables,a2
	lea     explosion_width_tables,a3

	move.l  #MAX_NUM_EXPLOSIONS-1,d7
.do_loop
	cmp.l   #NO,(a1)
	beq     .next_explo
		movem.l 4(a1),d0-d1     ;the type, the timer
		mulu    #MAX_NUM_EXPLO_A_FR*4,d0        ;to lookup
		and.l   #$0000ffff,d0           ;clear shite out!
		lsl.l   #2,d1                   ;mult by 4..
		add.l   d1,d0                   ;a pointer into tables
		move.l  (a3,d0.l),8(a0)         ;thats the width
		move.l  (a2,d0.l),12(a1)        ;thats the texture
	
		add.l   #1,8(a1)        ;the timer
		cmp.l   #MAX_NUM_EXPLO_A_FR,8(a1)
		blt     .next_explo             ;hey up..
		move.l  #NO,(a1)                ;set it to not used!
.next_explo
	lea     16(a0),a0
	lea     12(a1),a1
	dbf     d7,.do_loop
.quit_whole_thing
	rts

translate_explosion_points_into_rotated_points  
	lea     static_explosion_pos_data,a0
	lea     rotated_explosion_pos_data,a1
	move.l  #MAX_NUM_EXPLOSIONS-1,d7
.loop
	movem.l (a0),d0-d1              ;source x,z
	sub.l   world_x_translation,d0
	add.l   world_z_translation,d1
	move.l  d0,(a1)         ;z 
	move.l  d1,4(a1)        ;x      ;copy em..

	lea     16(a0),a0
	lea     8(a1),a1
	dbf     d7,.loop
	rts

rotate_explosion_points
	lea     rotated_explosion_pos_data,a1
	lea     sin_table,a2
	lea     cos_table,a3
	move.l  #MAX_NUM_EXPLOSIONS-1,d7

	move.l  current_angle_of_world_rotation,d6
	lsl.l   #2,d6                           ;mult angle by 4..
	move.l  (a2,d6.l),d5                    ;sine val of angle!
	move.l  (a3,d6.l),d6                    ;cos val of angle!
				;do this here as it saves a HELL
				;of a lot of time later..
.rot_loop
;ok, do the first point
	movem.l (a1),d0-d1      ;x,z
	movem.l (a1),d2-d3      ;x,z

;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..

	move.l  d0,(a1)
	move.l  d2,4(a1)        ;points are now rotated..
	lea     8(a1),a1        ;step to next storage point

	dbf     d7,.rot_loop
	rts

;its easy, you pass in x,z and a type
;the type sets up the width and texture
;timer gets set to 0 on first call, and then increases
;it gets to max_num_explo_a_fr then the explosion is deleted..
	

***********************************************************************
*** GlassObject drawing code! *****************************************
***********************************************************************
*** pretty easy, all objects that are classed as GlassObjects
***     are: Monsters, Bullets, Doors, Tables, Chairs etc..

put_objects_into_object_drawing_buffer
	move.l  #0,number_of_objects_in_buffer  ;clear it..
	lea     object_drawing_buffer,a0        ;tell me where it is!


;************ ok, lets do the aliens..
	lea     rotated_alien_positions_and_textures,a1
	move.l  number_of_aliens_used,d7
	subq.l  #1,d7                           ;get it right..
.loop_1
	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d1        ;x
	sub.l   (a1)+,d1
	move.l  #MAX_WALL_SIZE,d0                               ;z
	add.l   (a1)+,d0
						;second point!
						;ok, shove the texture in..
	move.l  (a1)+,texture_col

	move.l  d0,d2
	move.l  d1,d3
	add.l   #MAX_OBJECT_SIZE/2,d3   ;ALWAYS LOOK AT THE PLAYER!
	sub.l   #MAX_OBJECT_SIZE/2,d1   ;get it central!!
						;ok, got the 3d points.
	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1
	and.l   #$0000ffff,d2
	and.l   #$0000ffff,d3           ;clear the shite out!
						;if either of the points are 
						;within the screen, then draw!
	cmp.l   #0,d0
	blt     .not_visible_1
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d0
	bgt     .not_visible_1
	cmp.l   #0,d1
	blt     .not_visible_1
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d1
	bgt     .not_visible_1
						;ok, so first point isn't onscreen...
	cmp.l   #0,d2
	blt     .not_visible_1
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d2
	bgt     .not_visible_1
	cmp.l   #0,d3
	blt     .not_visible_1
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d3
	bgt     .not_visible_1
						;by george. its onscreen, 
						;or at least one point is..
;so shove it into this ere buffer!
;the draw rout has to take off WALL_SIZE etc, cos all the numbers
;in the buffer are positive and within the enlarged view window!

	cmp.l   #MAX_NUM_VISIBLE_OBJECTS-1,number_of_objects_in_buffer
	bge     .not_visible_1
	add.l   #1,number_of_objects_in_buffer  ;one more for list..
	movem.l d0-d3,(a0)
	add.l   #16,a0          ;step in dude
	move.l  texture_col,(a0)+               ;shove it in
.not_visible_1
	dbf     d7,.loop_1


;************ ok, lets do the bullets ******************************
	lea     rotated_bullet_data_store,a1
	move.l  #MAX_NUM_BULLETS-1,d7
.loop_2
;shove your slap in code in here!!
	cmp.l   #NO,(a1)                        ;is this bullet used?!?!
	beq     .not_visible_2                  ;skip this bullet!

	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d1        ;x
	sub.l   4(a1),d1
	move.l  #MAX_WALL_SIZE,d0                               ;z
	add.l   8(a1),d0
	move.l  28(a1),texture_col                      ;texture!!

	move.l  d0,d2
	move.l  d1,d3
;CHANGED from /2
	add.l   #MAX_OBJECT_SIZE/4,d3   ;ALWAYS LOOK AT THE PLAYER!
	sub.l   #MAX_OBJECT_SIZE/4,d1   ;get it central!!
						;ok, got the 3d points.
	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1
	and.l   #$0000ffff,d2
	and.l   #$0000ffff,d3           ;clear the shite out!

	cmp.l   #0,d0
	blt     .not_visible_2
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d0
	bgt     .not_visible_2
	cmp.l   #0,d1
	blt     .not_visible_2
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d1
	bgt     .not_visible_2
						;ok, so first point isn't onscreen...
	cmp.l   #0,d2
	blt     .not_visible_2
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d2
	bgt     .not_visible_2
	cmp.l   #0,d3
	blt     .not_visible_2
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d3
	bgt     .not_visible_2
						;by george. its onscreen, 
						;or at least one point is..
	cmp.l   #MAX_NUM_VISIBLE_OBJECTS-1,number_of_objects_in_buffer
	bge     .not_visible_2
	add.l   #1,number_of_objects_in_buffer  ;one more for list..
	movem.l d0-d3,(a0)
	add.l   #16,a0          ;step in dude
	move.l  texture_col,(a0)+       ;shove it in
.not_visible_2
	lea     40(a1),a1
	dbf     d7,.loop_2


;************ ok, lets do the explosions ******************************
	lea     rotated_explosion_pos_data,a1
	lea     static_explosion_pos_data,a2
	lea     explosion_type_data,a3
	move.l  #MAX_NUM_EXPLOSIONS-1,d7
.loop_3
;shove your slap in code in here!!
	cmp.l   #NO,(a3)                        ;is this explosion used?!?!
	beq     .not_visible_3                  ;skip this explosion!

	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d1        ;x
	sub.l   (a1),d1
	move.l  #MAX_WALL_SIZE,d0                               ;z
	add.l   4(a1),d0

	move.l  d0,d2
	move.l  d1,d3

	move.l  8(a2),d4        ;temp store, the width..
	lsr.l   #1,d4           ;divide by two!
	add.l   d4,d3   ;ALWAYS LOOK AT THE PLAYER!
	sub.l   d4,d1   ;get it central!!
						;ok, got the 3d points.
	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1
	and.l   #$0000ffff,d2
	and.l   #$0000ffff,d3           ;clear the shite out!

	cmp.l   #0,d0
	blt     .not_visible_3
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d0
	bgt     .not_visible_3
	cmp.l   #0,d1
	blt     .not_visible_3
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d1
	bgt     .not_visible_3
						;ok, so first point isn't onscreen...
	cmp.l   #0,d2
	blt     .not_visible_3
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d2
	bgt     .not_visible_3
	cmp.l   #0,d3
	blt     .not_visible_3
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d3
	bgt     .not_visible_3
						;by george. its onscreen, 
						;or at least one point is..
	cmp.l   #MAX_NUM_VISIBLE_OBJECTS-1,number_of_objects_in_buffer
	bge     .not_visible_3
	add.l   #1,number_of_objects_in_buffer  ;one more for list..
	movem.l d0-d3,(a0)
	add.l   #16,a0          ;step in dude
	move.l  12(a2),(a0)+    ;was texture col..shove it in
.not_visible_3
	lea     8(a1),a1
	lea     16(a2),a2
	lea     12(a3),a3
	dbf     d7,.loop_3


;************ ok, lets do the PICKUPS! ******************************
	lea     pickup_rotated_data,a1
	lea     pickup_static_data,a2
	move.l  #MAX_NUM_PICKUPS-1,d7
.loop_4
	cmp.l   #NO,12(a2)                      ;is this pickup used?!?!
	beq     .not_visible_4                  ;skip this pickup!

	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d1        ;x
	sub.l   (a1),d1
	move.l  #MAX_WALL_SIZE,d0                               ;z
	add.l   4(a1),d0

	move.l  d0,d2
	move.l  d1,d3

	move.l  #MAX_OBJECT_SIZE/4,d4   ;width of pickups!
	add.l   d4,d3   ;ALWAYS LOOK AT THE PLAYER!
	sub.l   d4,d1   ;get it central!!
						;ok, got the 3d points.
	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1
	and.l   #$0000ffff,d2
	and.l   #$0000ffff,d3           ;clear the shite out!

	cmp.l   #0,d0
	blt     .not_visible_4
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d0
	bgt     .not_visible_4
	cmp.l   #0,d1
	blt     .not_visible_4
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d1
	bgt     .not_visible_4
						;ok, so first point isn't onscreen...
	cmp.l   #0,d2
	blt     .not_visible_4
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d2
	bgt     .not_visible_4
	cmp.l   #0,d3
	blt     .not_visible_4
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d3
	bgt     .not_visible_4
						;by george. its onscreen, 
						;or at least one point is..
	cmp.l   #MAX_NUM_VISIBLE_OBJECTS-1,number_of_objects_in_buffer
	bge     .not_visible_4
	add.l   #1,number_of_objects_in_buffer  ;one more for list..
	movem.l d0-d3,(a0)
	add.l   #16,a0          ;step in dude
	move.l  8(a1),(a0)+     ;was texture col..shove it in
.not_visible_4
	lea     12(a1),a1
	lea     20(a2),a2
	dbf     d7,.loop_4


;************ ok, lets do the DOORS! ******************************
	lea     rotated_door_data,a1
	move.l  num_doors_used,d7
	sub.l   #1,d7                   ;get it right..
.loop_5
	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d1        ;x
	sub.l   (a1),d1
	move.l  #MAX_WALL_SIZE,d0                               ;z
	add.l   4(a1),d0
	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d3        ;x
	sub.l   8(a1),d3
	move.l  #MAX_WALL_SIZE,d2                               ;z
	add.l   12(a1),d2

	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1
	and.l   #$0000ffff,d2
	and.l   #$0000ffff,d3           ;clear the shite out!

	cmp.l   #0,d0
	blt     .not_visible_5
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d0
	bgt     .not_visible_5
	cmp.l   #0,d1
	blt     .not_visible_5
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d1
	bgt     .not_visible_5
						;ok, so first point isn't onscreen...
	cmp.l   #0,d2
	blt     .not_visible_5
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d2
	bgt     .not_visible_5
	cmp.l   #0,d3
	blt     .not_visible_5
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d3
	bgt     .not_visible_5
						;by george. its onscreen, 
						;or at least one point is..
	cmp.l   #MAX_NUM_VISIBLE_OBJECTS-1,number_of_objects_in_buffer
	bge     .not_visible_5
	add.l   #1,number_of_objects_in_buffer  ;one more for list..
	movem.l d0-d3,(a0)
	add.l   #16,a0          ;step in dude
	move.l  16(a1),(a0)+    ;was texture col..shove it in
.not_visible_5
	lea     20(a1),a1
	dbf     d7,.loop_5


;************ ok, lets do the SWITCHES ******************************
	lea     rotated_switch_position,a1
	lea     static_switch_position,a2
	lea     switch_anim_data,a3
	move.l  num_doors_used,d7
	sub.l   #1,d7                   ;get it right..
.loop_6
	cmp.l   #SWITCH_INVIS,24(a2)            ;VIS or INVIS switch?!
	beq     .not_visible_6                  ;oh dear!

	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d1        ;x
	sub.l   (a1),d1
	move.l  #MAX_WALL_SIZE,d0                               ;z
	add.l   4(a1),d0
	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d3        ;x
	sub.l   8(a1),d3
	move.l  #MAX_WALL_SIZE,d2                               ;z
	add.l   12(a1),d2

	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1
	and.l   #$0000ffff,d2
	and.l   #$0000ffff,d3           ;clear the shite out!

	cmp.l   #0,d0
	blt     .not_visible_6
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d0
	bgt     .not_visible_6
	cmp.l   #0,d1
	blt     .not_visible_6
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d1
	bgt     .not_visible_6
						;ok, so first point isn't onscreen...
	cmp.l   #0,d2
	blt     .not_visible_6
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d2
	bgt     .not_visible_6
	cmp.l   #0,d3
	blt     .not_visible_6
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d3
	bgt     .not_visible_6
						;by george. its onscreen, 
						;or at least one point is..
	cmp.l   #MAX_NUM_VISIBLE_OBJECTS-1,number_of_objects_in_buffer
	bge     .not_visible_6
	add.l   #1,number_of_objects_in_buffer  ;one more for list..
	movem.l d0-d3,(a0)
	add.l   #16,a0          ;step in dude
		move.l  28(a2),d0       ;switch type?
		move.l  20(a2),d1       ;on or off
		lsl.l   #3,d0           ;got two frames per switch.. 2 longs..
		lsl.l   #2,d1           ;mult by 4
		add.l   d1,d0
		move.l  (a3,d0.l),(a0)+ ;shove the right texture in!
.not_visible_6
	lea     16(a1),a1
	lea     32(a2),a2
	dbf     d7,.loop_6


	rts
***********************************************

sort_object_drawing_buffer
	cmp.l   #1,number_of_objects_in_buffer
	ble     .do_nothing

	move.l  number_of_objects_in_buffer,d7
	sub.l   #1,d7   ;move it right..and store it..
	move.l  d7,d6   ;outer loop
.outer_loop
	move.l  d7,d5   ;inner_looper
	sub.l   #1,d5   ;got to do one less remember! duh!!
	lea     object_drawing_buffer,a0
.inner_loop
	move.l  (a0),d0
	move.l  8(a0),d1        ;first z's..
	cmp.l   d0,d1
	blt     .first_biggest
	move.l  d1,d0                   ;d0 is the biggest val so far..
.first_biggest
	move.l  20(a0),d1
	move.l  28(a0),d2
	cmp.l   d1,d2
	blt     .first_biggest_2
	move.l  d2,d1
.first_biggest_2                        ;ok, got d0 and d1
	cmp.l   d0,d1
	blt     .no_swap_around
		movem.l (a0),d0-d4      ;stack em..
		move.l  20(a0),(a0)
		move.l  24(a0),4(a0)
		move.l  28(a0),8(a0)
		move.l  32(a0),12(a0)
		move.l  36(a0),16(a0)
		movem.l d0-d4,20(a0)    ;swap em around!
.no_swap_around
	lea     20(a0),a0               ;step into it..
	dbf     d5,.inner_loop
	dbf     d6,.outer_loop
.do_nothing
	rts

draw_objects_in_object_drawing_buffer
	lea     object_drawing_buffer,a1
	move.l  number_of_objects_in_buffer,d7
	cmp.l   #1,d7
	blt     .draw_nothing
	subq.l  #1,d7                           ;get it right..
.d3d_loop
	movem.l (a1)+,d0-d3
	move.l  (a1)+,texture_col       ;shove it in..
******************* SHRINK THE TEXTURE!! **********
	move.l  d7,-(sp)        ;stack THIS one only..
			;first of all, get the distances between points..
	move.l  d2,d4
	sub.l   d0,d4
	bpl     .no_neg_x
	move.l  d0,d4
	sub.l   d2,d4
.no_neg_x
	move.l  d3,d5
	sub.l   d1,d5
	bpl     .no_neg_y
	move.l  d1,d5
	sub.l   d3,d5
.no_neg_y
				;ok, got differences... 
				;now figure out which is the biggest..
	cmp.l   d4,d5
	blt     .first_biggest
	move.l  d5,d4
.first_biggest
		;d4 now holds the longest difference between points..
	lea     texture_line_jump_table,a4      ;got to do this!!
						;otherwise we get FUNKup.
	moveq.l #0,d5                           ;the number of pixels drawn..
	move.l  d4,d6                           ;the looper reg..
	addq.l  #1,d4                           ;so no div by zero errors!

;thanks to scotto for the optimisation of this rout!
	move.l  #MAX_OBJECT_SIZE*32,d7
	divs    d4,d7
	move.l  d7,shrink_texture_temp_store
.go_loop
	move.l  shrink_texture_temp_store,d7
				;so we got a step in d7
				;now mulu it by number of pix done (d6)
	mulu    d5,d7                           ;done it..

	lsr.l   #5,d7   ;divide by 32..
	and.l   #$0000ffff,d7                   ;clear the shite!
	lsl.l   #2,d7   ;mult by 4, faster access
	move.l  d7,(a4)+

	addq.l  #1,d5                           ;another pixel done.
		;(((objectsize*10)/maxlinsize)*(numpix done))/10..
	dbf     d6,.go_loop
	move.l  (sp)+,d7                ;unstack this register..
***************************************************
	jsr     texture_line_draw_optimised_col_zero_check
.d3d_nope
	dbf     d7,.d3d_loop
.draw_nothing
	rts


***********************************************************************
*** Alien based code! *************************************************
***********************************************************************
*** Aliens ALWAYS look at the player. The classic DOOM mode..
*** There are different visual types of alien, but they are all based
***     on the same AI rout...
*** classic doom mode, static until activated then its check for nearest
***     object and shoot at it. this starts off fights.
***     if no object nearby, go looking for one.

draw_calced_alien_points
	move.l  work,a0
	lea     point_data,a1
	lea     mulu_160_table,a2
	lea     point_across_data,a3
	lea     rotated_alien_positions_and_textures,a4
	lea     alien_flags,a5
	move.l  number_of_aliens_used,d7
	subq.l  #1,d7                           ;get it right..
.loop
	cmp.l   #0,(a5)
	beq     .no_draw        ;dead alien!

	movem.l (a4),d2-d3                      ;the x,z
	lsr.l   #MAP_DRAW_DIVISION,d2           ;divide em down
	lsr.l   #MAP_DRAW_DIVISION,d3
	move.l  #160,d0                         ;put the screen origin 
	move.l  #100,d1
	sub.l   d2,d0                           ;sub it...
	sub.l   d3,d1
	
	and.l   #$0000ffff,d0   ;do this to clear the second word
	and.l   #$0000ffff,d1   ;in each longword. see later for 
				;long explanation!
	cmp.l   #0+32,d0                ;not onscreen!?
	blt.s   .no_draw        ;don't plot it!
	cmp.l   #319-32,d0
	bgt.s   .no_draw
	cmp.l   #0,d1
	blt.s   .no_draw
	cmp.l   #199,d1
	bgt.s   .no_draw
***point plot!
	lsl.l   #2,d1           ;mult by 4
	move.l  (a2,d1.l),d3    ;temp_store, go down the screen..

	lsl.l   #2,d0           ;mult by 4..
	move.w  (a1,d0.l),d2    ;get point data..

	add.l   (a3,d0.l),d3    ;across screen pointer..
	or.w    d2,(a0,d3.l)            ;plop it onscreen..
.no_draw
	lea     40(a5),a5       ;onto next aliens flags..
	lea     12(a4),a4       ;skip z,x,texture
	dbf     d7,.loop
	rts



random_number
	move.w  random_number_seed,d0
	mulu    #9377,d0
	add.w   #9439,d0
	bclr    #15,d0
	move.w  d0,random_number_seed
	rts

control_aliens
	lea     alien_flags,a0
	lea     static_alien_positions_and_textures,a1
	lea     alien_death_animation,a2

	move.l  player_z_pos_in_map,d0
	move.l  player_x_pos_in_map,d1
					;MUST BE ABOVE ZERO!
					;otherwise line draw goes WRONG WAY!
	and.l   #$0000ffff,d0           ;a dumb coding bug, but one thats 
	and.l   #$0000ffff,d1           ;prooving f*kin impossible to 
					;get rid of!!
	move.l  d0,control_z_pos_temp
	move.l  d1,control_x_pos_temp
****ok, lets control those aliens! move em towards player if need be..
	move.l  number_of_aliens_used,d7
	subq.l  #1,d7                           ;get it right..
.loop
	cmp.l   #0,(a0)
	ble     .skip_this_alien                ;if it aint dead
				;if its dead ignore the alien..

	cmp.l   #NUM_DEATH_FRAMES,(a0)  ;is it dying?
	bgt     .control_anger_timer
		sub.l   #1,(a0)                 ;decrease its health by one
		cmp.l   #0,(a0)
		bgt     .health_ok_now
		move.l  #0,(a0)         ;dead as dead can be..
.health_ok_now
		move.l  36(a0),d0               ;the monsters type..
		mulu    #NUM_DEATH_FRAMES*4,d0  ;for fast access into table
		and.l   #$0000ffff,d0           ;clear shite..
		move.l  (a0),d1         ;get death frame..
		lsl.l   #2,d1           ;mult by 4..
		add.l   d1,d0           ;get to correct frame!
		move.l  (a2,d0.l),8(a1)         ;use THIS texture now!!
		move.l  #ALIEN_A_FR_DYING,8(a0)
		bra     .skip_this_alien        ;don't move it!
.control_anger_timer
	sub.l   #1,12(a0)                       ;decrease its anger!
	cmp.l   #0,12(a0)       ;check its anger timer..
	bgt     .anger_ok
	move.l  #0,12(a0)       ;set it anger timer to zero
	move.l  #1,16(a0)       ;set wander mode!
;get a random target, and shove a random number into wander timer?
	bra     .done_checking_anger
.anger_ok
	move.l  #0,16(a0)       ;set homein mode! its ANGRY!
.done_checking_anger

	cmp.l   #0,4(a0)
	ble     .skip_this_alien
			;if alien is 'active' then perform movement!

			;if its angry, then force home in mode.
			;if home in mode, then pick nearest object
			;otherwise go wandering..
.check_homein_or_wander
	cmp.l   #0,16(a0)       ;home in on object.
	bne     .wander_alien   
****************************************************************
.homein_alien
	movem.l (a1),d0-d1
	jsr     circle_door_collision_detection
	cmp.l   #YES,circle_wall_collision_flag
	beq     .redo_1         ;collided dude!

	movem.l (a1),d0-d1
	jsr     circle_wall_collision_detection
	cmp.l   #NO,circle_wall_collision_flag
	beq     .no_collide_with_wall
					;right, invert the destination..        
.redo_1         movem.l (a1),d0-d1              ;current pos
		movem.l 24(a0),d2-d3            ;destination.
					;figure out_distance between em
		sub.l   d0,d2
		sub.l   d1,d3   
					;subtract it from current. 
					;shove that into destination..  
		sub.l   d2,d0
		sub.l   d3,d1                   ;new positions!
		and.l   #$0000ffff,d0
		and.l   #$0000ffff,d1
		move.l  d1,24(a0)
		move.l  d0,28(a0)       ;dest!
		bra     .ok_found_nearest_object        ;hoho!!
.no_collide_with_wall
		sub.l   #1,20(a0)               ;sub wander timer
		cmp.l   #0,20(a0)
		bgt     .ok_found_nearest_object
		movem.l (a1),d0-d1      ;aliens z,x
		jsr     alien_pick_nearest_object
			;ok, got a walk-to point
		move.l  nearest_object_x,24(a0)
		move.l  nearest_object_z,28(a0)

		move.l  #50,20(a0)      ;shove in a time to walk along
				;should really use a random number..
.ok_found_nearest_object
;fire towards target
;TODO
	;aliens fire different types of bullet..
	;so we've got to store an internal alien type..
	;that then denotes what bullet the alien can fire!

	sub.l   #1,32(a0)               ;decrease timer
	cmp.l   #0,32(a0)               ;compare bullet timer
	bgt     .ok_done_firing_bullet  ;can't fire one yet!!           
		move.l  #0,32(a0)       ;clear the timer
		movem.l (a1),d0-d1      ;alien x,z
		movem.l 24(a0),d2-d3
			add.l   #MAX_BULLET_DISTANCE,d0
			add.l   #MAX_BULLET_DISTANCE,d1
			add.l   #MAX_BULLET_DISTANCE,d2
			add.l   #MAX_BULLET_DISTANCE,d3 ;get INTO the map!!!
		move.l  36(a0),d4               ;alien type
		move.l  #ALIEN_A_FR_FIRE_START,8(a0)
				;start the fire animation off!

;TODO   ;should look into a table for correct bullet type!
		jsr     request_and_fire_bullet
		cmp.l   #NO,bullet_fired                ;no bullet fired
		beq     .ok_done_firing_bullet
		move.l  #50,32(a0)              ;bullet timer!
					;can't fire until this = zero!
;TODO   ;should look into a table or correct alien bullet timer!
.ok_done_firing_bullet
;walk towards target
		movem.l (a1),d0-d1                      ;aliens z,x
		movem.l 24(a0),d2-d3
		move.l  #1,d4           ;number of times down line (velocity)

		jsr     step_along_line_between_points  ;move towards the player
		move.l  step_line_x_result,(a1)         ;moved!
		move.l  step_line_y_result,4(a1)        ;moved!
		bra     .control_animation              ;get out!
****************************************************************
.wander_alien
	movem.l (a1),d0-d1
	jsr     circle_door_collision_detection
	cmp.l   #YES,circle_wall_collision_flag
	beq     .redo_2         ;collided dude!

	movem.l (a1),d0-d1
	jsr     circle_wall_collision_detection
	cmp.l   #NO,circle_wall_collision_flag
	beq     .no_collision_with_wall
.redo_2                                 ;right, invert the destination..        
		movem.l (a1),d0-d1              ;current pos
		movem.l 24(a0),d2-d3            ;destination.
					;figure out_distance between em
		sub.l   d0,d2
		sub.l   d1,d3   
					;subtract it from current. 
					;shove that into destination..  
		sub.l   d2,d0
		sub.l   d3,d1                   ;new positions!
		movem.l d0-d1,24(a0)            ;off we go!!

		move.l  #30,20(a0)      ;make it so that the monsters
					;will be WELL clear of the wall
					;before they change direction!
.no_collision_with_wall
		sub.l   #1,20(a0)               ;sub wander timer
		cmp.l   #0,20(a0)
		bgt     .wander_timer_ok
				;get a new destination and wander timer!!
.set_new_destination
		jsr     random_number
		and.l   #80,d0
		move.l  d0,20(a0)       ;new wander time..
		add.l   #10,20(a0)      ;go forwards some.. don't flicker
;               move.l  #1,16(a0)       ;set wandering flag!
.get_new_target_x
		jsr     random_number
		and.l   #MAX_MAP_Z_SIZE,d0              ;limit it!
		move.l  d0,24(a0)       ;store it!
.get_new_target_z
		jsr     random_number
		and.l   #MAX_MAP_X_SIZE,d0              ;limit it!
		move.l  d0,28(a0)       ;store it!
.wander_timer_ok
		movem.l (a1),d0-d1                      ;aliens z,x
		movem.l 24(a0),d2-d3                    ;target z,x
		move.l  #1,d4                           ;times..
		jsr     step_along_line_between_points  ;move towards the player
		move.l  step_line_x_result,(a1)         ;moved!
		move.l  step_line_y_result,4(a1)        ;moved!
****************************************************************
.control_animation
	cmp.l   #ALIEN_A_FR_WALK_END,8(a0)
	bgt     .animation_firing
.animation_walking
	add.l   #1,8(a0)
	cmp.l   #ALIEN_A_FR_WALK_END,8(a0)
	ble     .skip_this_alien
		move.l  #ALIEN_A_FR_WALK_START,8(a0)
		bra     .skip_this_alien
.animation_firing
	add.l   #1,8(a0)
	cmp.l   #ALIEN_A_FR_FIRE_END,8(a0)
	ble     .skip_this_alien
		move.l  #ALIEN_A_FR_WALK_START,8(a0)
.skip_this_alien
	lea     40(a0),a0       ;skip to next aliens flags!
	lea     12(a1),a1       ;go to next aliens x,z texture!
	dbf     d7,.loop
	rts

control_alien_rotation_animation
	;this is the bit that works out the difference between
	;the direction the alien is facing the players facig dir
	;then gets the correct frame out of the 8 to display...
	;quite a sod of a routine really...
	
	;can use 24(a0),d0-d1 in alien flags for both wander and homein
	;I changed the code.. don't you just love easy code!!!!
	rts

alien_pick_nearest_object
;TODO
	;takes in d0=z d1=x
	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	move.l  d1,nearest_object_x     ;use these temp to detect if
	move.l  d0,nearest_object_z     ;monster is same as passed in!
		;if no objects nearby, ie within set 'focal_distance'
		;and that includes the play, then pick target
		;at random.. sort of angry wandering...

	move.l  #0,nearest_num_objects

;ok, lets create a zone around the passed in z,x
	move.l  d0,d2
	move.l  d1,d3
	move.l  #MAX_ALIEN_EYESIGHT_LEN/2,d4
	sub.l   d4,d0
	sub.l   d4,d1
	add.l   d4,d2
	add.l   d4,d3   ;just a wee bit faster..

	cmp.l   #0,d0
	bge     .its_ok_1
	move.l  #0,d0           ;set it to zero if negative
	move.l  #MAX_ALIEN_EYESIGHT_LEN,d2
.its_ok_1
	cmp.l   #0,d1
	bge     .its_ok_2
	move.l  #0,d1           ;set it to zero if negative
	move.l  #MAX_ALIEN_EYESIGHT_LEN,d3
.its_ok_2

	lea     static_alien_positions_and_textures,a0
	lea     nearest_alien_store,a1
	lea     alien_flags,a2
	move.l  number_of_aliens_used,d7
	subq.l  #1,d7
.alien_loop
	movem.l (a0),d4-d5      ;d0-d3/d7 are used.. z,x..
	cmp.l   d4,d0
	bgt     .forget_it
	cmp.l   d4,d2
	blt     .forget_it
	cmp.l   d5,d1
	bgt     .forget_it
	cmp.l   d5,d3
	blt     .forget_it

		cmp.l   nearest_object_x,d5
		beq     .forget_it
		cmp.l   nearest_object_z,d4
		beq     .forget_it      ;sod the same alien!    

		cmp.l   #0,(a2)         ;is it DEAD!?
		beq     .forget_it      ;yes! don't do this one!

	move.l  d5,(a1)+
	move.l  d4,(a1)+        ;shove it into the visible buffer..
	add.l   #1,nearest_num_objects
.forget_it
	lea     12(a0),a0
	lea     40(a2),a2
	dbf     d7,.alien_loop  

;ok, done all the aliens.. now check the player!
	
	move.l  control_z_pos_temp,d4
	move.l  control_x_pos_temp,d5
	cmp.l   d4,d0
	bgt     .forget_it_2
	cmp.l   d4,d2
	blt     .forget_it_2
	cmp.l   d5,d1
	bgt     .forget_it_2
	cmp.l   d5,d3
	blt     .forget_it_2

	move.l  d4,(a1)+
	move.l  d5,(a1)+        ;shove it into the visible buffer..
	add.l   #1,nearest_num_objects
.forget_it_2

;ok, lets see if we got any monsters..

	lea     nearest_alien_store,a1
	cmp.l   #1,nearest_num_objects
	bge     .we_got_some
		jsr     random_number
		and.l   #MAX_MAP_X_SIZE,d0
		move.l  d0,nearest_object_x
		jsr     random_number
		and.l   #MAX_MAP_Z_SIZE,d0
		move.l  d0,nearest_object_z     ;got a random point
		bra     .get_the_hell_out_of_the_rout
.we_got_some
	cmp.l   #2,nearest_num_objects
	bge     .more_than_one
		move.l  (a1)+,nearest_object_z
		move.l  (a1)+,nearest_object_x
		bra     .get_the_hell_out_of_the_rout
.more_than_one
		move.l  nearest_num_objects,d1
		sub.l   #1,d1           ;so we don't pull out pants data!
		jsr     random_number   ;result in d0?
		and.l   d1,d0           ;got a random number..
		lsl.l   #3,d0           ;mult by 8..
		move.l  (a1,d0.l),nearest_object_z
		move.l  4(a1,d0.l),nearest_object_x
.get_the_hell_out_of_the_rout
	movem.l (sp)+,d0-d7/a0-a6       ;unstack
	rts


step_along_line_between_points
			;takes in x1,z1,x2,z2,distance down the line
	movem.l a0-a6/d0-d7,-(sp)       ;stack them!

	move.l  d2,line_draw_X2
	move.l  d3,line_draw_Y2
	move.l  d4,step_line_counter                    ;the counter!

	sub.l   d0,d2                   ;dx = x2-x1
	sub.l   d1,d3                   ;dy = y2-y1

	moveq.l #0,d4                   ;c = 0
	moveq.l #0,d5                   ;m = 0
	moveq.l #0,d6                   ;d = 0
	
	move.l  #1,a5                   ;xinc = 1
	move.l  #1,a6                   ;yinc = 1

	cmp.l   #0,d2                   ;if dx < 0
	bgt.s   .next
	move.l  #-1,a5                  ;xinc = -1
	neg.l   d2                      ;dx = -dx
.next
	cmp.l   #0,d3                   ;if dy < 0
	bgt.s   .next_2
	move.l  #-1,a6                  ;yinc = -1
	neg.l   d3                      ;dy = -dy
.next_2

.start_drawer
;ok, here starts the drawer..
	cmp.l   d3,d2                   ;if dy < dx
	bgt     .draw_2
.draw_1
	move.l  d3,d4
	add.l   d4,d4                   ;c = 2*dy

	move.l  d2,d5
	add.l   d5,d5                   ;m = 2*dx

.no_quit
;your stuff here.. =]
.no_draw        
	add.l   a6,d1                   ;y = y+yinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d3                   ;if d > dy
	bgt.s   .nope
	add.l   a5,d0                   ;x = x+xinc     
	sub.l   d4,d6                   ;d = d-c
.nope
	cmp.l   line_draw_X2,d0
	bne     .next_check_1
	cmp.l   line_draw_Y2,d1
	beq     .quit_drawing
.next_check_1
;       cmp.l   line_draw_Y2,d1         ;if y <> y2
;       bne     .no_quit
	sub.l   #1,step_line_counter
	cmp.l   #0,step_line_counter
	bge     .no_quit
	bra     .quit_drawing
.draw_2
	move.l  d2,d4
	add.l   d4,d4                   ;c = 2*dx
	
	move.l  d3,d5
	add.l   d5,d5                   ;m = 2*dy
.no_quit_2      
;your stuff here..
.no_draw2
	add.l   a5,d0                   ;x = x+xinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d2                   ;if d > dx
	bgt.s   .nope_2
	add.l   a6,d1                   ;y = y+yinc
	sub.l   d4,d6                   ;d = d-c
.nope_2         
	cmp.l   line_draw_X2,d0
	bne     .next_check_2
	cmp.l   line_draw_Y2,d1
	beq     .quit_drawing
.next_check_2
;       cmp.l   line_draw_X2,d0         ;if x <> x2
;       bne     .no_quit_2
	sub.l   #1,step_line_counter
	cmp.l   #0,step_line_counter
	bge     .no_quit_2
.quit_drawing
	move.l  d0,step_line_x_result
	move.l  d1,step_line_y_result   ;so other people can use em!
	movem.l (sp)+,a0-a6/d0-d7       ;get them back!
	rts

translate_alien_points_into_rotated_points
	lea     static_alien_positions_and_textures,a0
	lea     rotated_alien_positions_and_textures,a1
	move.l  number_of_aliens_used,d7
	subq.l  #1,d7                           ;get it right..
.loop
	movem.l (a0)+,d0-d1             ;z,x
	sub.l   world_x_translation,d0
	add.l   world_z_translation,d1
	move.l  d0,(a1)+
	move.l  d1,(a1)+                        ;copy em..
	move.l  (a0)+,(a1)+             ;the texture...

	dbf     d7,.loop
	rts

rotate_alien_object_points
	lea     static_alien_positions_and_textures,a0
	lea     rotated_alien_positions_and_textures,a1
	lea     sin_table,a2
	lea     cos_table,a3
	move.l  number_of_aliens_used,d7
	subq.l  #1,d7                           ;get it right..

	move.l  current_angle_of_world_rotation,d6
	lsl.l   #2,d6                           ;mult angle by 4..
	move.l  (a2,d6.l),d5                    ;sine val of angle!
	move.l  (a3,d6.l),d6                    ;cos val of angle!
				;do this here as it saves a HELL
				;of a lot of time later..
.rot_loop
;ok, do the first point
	movem.l (a1),d0-d1      ;z,x
	movem.l (a1),d2-d3      ;z,x
;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..

	move.l  d0,(a1)
	move.l  d2,4(a1)        ;points are now rotated..
	lea     8(a0),a0        ;step to next 3d point!
	lea     8(a1),a1        ;step to next storage point

	move.l  (a1),(a1)+      ;shove the texture in..
;ok, loop it..
	dbf     d7,.rot_loop
	rts



***********************************************************************
*** All code associated with the 3d world *****************************
***********************************************************************
*** such as rotation of world points, drawing the map, drawing 3d
*** all that type of stuff.. =]

change_rotation_and_translation_values_according_to_player
	cmp.l   #0,joystick_left
	beq.s   .check_right    ;ooh, we moved left!
		sub.l   #ROTATION_STEP_VALUE,current_angle_of_world_rotation
		cmp.l   #0,current_angle_of_world_rotation
		bge     .check_right
		add.l   #359,current_angle_of_world_rotation
.check_right
	cmp.l   #0,joystick_right
	beq.s   .check_up
		add.l   #ROTATION_STEP_VALUE,current_angle_of_world_rotation
		cmp.l   #359,current_angle_of_world_rotation
		ble     .check_up
		sub.l   #359,current_angle_of_world_rotation
.check_up
	cmp.l   #0,joystick_up
	beq     .check_down
		move.l  player_look_at_x_pos,d0
		move.l  player_look_at_z_pos,d1
		add.l   d0,world_x_translation  
		add.l   d1,world_z_translation
			add.l   d0,player_x_pos_in_map
			sub.l   d1,player_z_pos_in_map
.col_check_1
	move.l  player_x_pos_in_map,d0
	move.l  player_z_pos_in_map,d1
	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1

	jsr     circle_door_collision_detection
	cmp.l   #YES,circle_wall_collision_flag
	beq     .collision_with_wall_1          ;we collided!!

	jsr     circle_wall_collision_detection
	cmp.l   #NO,circle_wall_collision_flag
	beq     .moved_stick
.collision_with_wall_1
		move.l  player_look_at_x_pos,d0
		move.l  player_look_at_z_pos,d1
		sub.l   d0,world_x_translation
		sub.l   d1,world_z_translation
			sub.l   d0,player_x_pos_in_map
			add.l   d1,player_z_pos_in_map
		bra     .col_check_1
.check_down
	cmp.l   #0,joystick_down
	beq     .moved_stick
		move.l  player_look_at_x_pos,d0         ;move it!!
		move.l  player_look_at_z_pos,d1
		sub.l   d0,world_x_translation  
		sub.l   d1,world_z_translation
			sub.l   d0,player_x_pos_in_map
			add.l   d1,player_z_pos_in_map
.col_check_2
	move.l  player_x_pos_in_map,d0                  ;a collision!?
	move.l  player_z_pos_in_map,d1
	and.l   #$0000ffff,d0
	and.l   #$0000ffff,d1

	jsr     circle_door_collision_detection
	cmp.l   #YES,circle_wall_collision_flag
	beq     .collision_with_wall_2          ;we collided!!

	jsr     circle_wall_collision_detection
	cmp.l   #NO,circle_wall_collision_flag
	beq     .moved_stick
.collision_with_wall_2
		move.l  player_look_at_x_pos,d0         ;move it back!!
		move.l  player_look_at_z_pos,d1
		add.l   d0,world_x_translation
		add.l   d1,world_z_translation
			add.l   d0,player_x_pos_in_map
			sub.l   d1,player_z_pos_in_map
		bra     .col_check_2
.moved_stick
	move.l  #0,joystick_left
	move.l  #0,joystick_right       ;might as well clear em.
	move.l  #0,joystick_up
	move.l  #0,joystick_down
	rts

rotate_player_fire_at_point
	lea     sin_table,a1
	lea     cos_table,a2
;set up the rotation point..
	move.l  #0,d1
	move.l  current_weapons_distance,d0
	move.l  #0,d3
	move.l  current_weapons_distance,d2     ;must be same as d0!
;now rotate it minus the current_rotation_value
	move.l  #359,d6
	sub.l   current_angle_of_world_rotation,d6
;that gets it opposite.. now lets rotate it!!
	lsl.l   #2,d6                           ;mult angle by 4..
	move.l  (a1,d6.l),d5                    ;sine val of angle!
	move.l  (a2,d6.l),d6                    ;cos val of angle!
;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..
;shift em up..
	move.l  d2,player_fire_at_x_pos
	move.l  d0,player_fire_at_z_pos 

rotate_player_look_at_point
	lea     sin_table,a1
	lea     cos_table,a2
;set up the rotation point..
	move.l  #0,d1
	move.l  #MAP_TRANSLATION_VALUE,d0       ;the lookat point!
	move.l  #0,d3
	move.l  #MAP_TRANSLATION_VALUE,d2
;now rotate it minus the current_rotation_value
	move.l  #359,d6
	sub.l   current_angle_of_world_rotation,d6
;that gets it opposite.. now lets rotate it!!
	lsl.l   #2,d6                           ;mult angle by 4..
	move.l  (a1,d6.l),d5                    ;sine val of angle!
	move.l  (a2,d6.l),d6                    ;cos val of angle!
;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..
;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..
;shift em up..
	move.l  d2,player_look_at_x_pos
	move.l  d0,player_look_at_z_pos 
	rts     

translate_static_world_into_rotated
	lea     static_3d_world_points,a0
	lea     rotated_3d_world_points,a1
	move.l  number_3d_world_points,d7
	subq.l  #1,d7                           ;get it right..
.loop
	movem.l (a0)+,d0-d1
	sub.l   world_x_translation,d0
	add.l   world_z_translation,d1
	move.l  d0,(a1)+
	move.l  d1,(a1)+                        ;copy em..

	dbf     d7,.loop
	rts
	even

rotate_static_3d_world_into_rotated_3d_world
	lea     static_3d_world_points,a0
	lea     rotated_3d_world_points,a1
	lea     sin_table,a2
	lea     cos_table,a3
	move.l  number_3d_world_points,d7
	subq.l  #1,d7                           ;get it right..

	move.l  current_angle_of_world_rotation,d6
	lsl.l   #2,d6                           ;mult angle by 4..
	move.l  (a2,d6.l),d5                    ;sine val of angle!
	move.l  (a3,d6.l),d6                    ;cos val of angle!
				;do this here as it saves a HELL
				;of a lot of time later..
.rot_loop
	movem.l (a1),d0-d1      ;x, z
	movem.l (a1),d2-d3      ;x, z again..
;new x = x*sin(ang) - z*cos(ang)
	muls    d5,d0           ;x*sin(ang)
	muls    d6,d1           ;z*cos(ang)
	sub.l   d1,d0           ;x - z
	lsr.l   #7,d0           ;divide by 128... to get right..

;new z = x*cos(ang) + z*sin(ang)
	muls    d6,d2           ;x*cos(ang)
	muls    d5,d3           ;z*sin(ang)
	add.l   d3,d2           ;x + z
	lsr.l   #7,d2           ;divide by 128... to get right..

	move.l  d0,(a1)
	move.l  d2,4(a1)        ;points are now rotated..

	lea     8(a0),a0        ;step to next 3d point!
	lea     8(a1),a1        ;step to next storage point
	dbf     d7,.rot_loop
	rts


texture_line_draw_optimised_col_zero_check
	movem.l a0-a6/d0-d7,-(sp)       ;stack them!
	lea     texture_line_quick_push_regs_in,a0
	movem.l (a0),a0-a6                              ;shove em in!
;               lea     image_bank,a0
;               lea     x3d_to_x2d_table,a1
;               lea     texture_shrink_table,a2
;               lea     texture_strip_data,a3
;               lea     texture_line_data,a4
;               lea     texture_fade_colour_data,a5
;               lea     z_buffer,a6
	add.l   #(IMAGE_BANK_WIDTH/2)*4,a6      ;solve DUMB problem
			;to do with see thru walls when they shouldn't be!!!

	move.l  texture_col,d7          ;what texture we using?
	mulu    #MAX_WALL_SIZE*4,d7
	add.l   d7,a4                   ;get to right data for line!

	move.l  #0,texture_data_counter         ;clear it!!

	lsl.l   #2,d0   ;to get faster access to tables!
	lsl.l   #2,d1   ;we mulu all the inputted values by four!
	lsl.l   #2,d2   ;sneaky..
	lsl.l   #2,d3
	move.l  d2,texture_line_draw_X2
	move.l  d3,texture_line_draw_Y2

	moveq.l #0,d4                   ;c = 0
	moveq.l #0,d5                   ;m = 0
	moveq.l #0,d6                   ;d = 0
	
	move.l  #4,texture_line_xinc                    ;xinc = 1
	move.l  #4,texture_line_yinc                    ;yinc = 1

	sub.l   d0,d2                   ;dx = x2-x1
	bpl     .next                   ;if dx < 0
	move.l  #-4,texture_line_xinc   ;xinc = -1
	neg.l   d2                      ;dx = -dx
.next   
	sub.l   d1,d3                   ;dy = y2-y1
	bpl     .next_2                 ;if dy < 0
	move.l  #-4,texture_line_yinc   ;yinc = -1
	neg.l   d3                      ;dy = -dy
.next_2
	cmp.l   d3,d2                   ;if dy < dx
	bgt     .draw_2
.draw_1
	move.l  d3,d4
	add.l   d4,d4                   ;c = 2*dy

	move.l  d2,d5
	add.l   d5,d5                   ;m = 2*dx

.no_quit
	;ok, sub wallsize from X and Z..
	;convert result to 3d (if onscreen!)
	;then fill the z buffer for that point..
	
	movem.l d0-d7/a1-a3,-(sp)
	
	sub.l   #MAX_WALL_SIZE*4,d0
	bmi     .nope_not_onscreen      ;faster.. just..
	cmp.l   #THREE_D_VIEW_DEPTH*4,d0
	bge     .nope_not_onscreen      ;x ain't in the buffer!

	sub.l   #MAX_WALL_SIZE*4,d1
	bmi     .nope_not_onscreen      ;just faster..
	cmp.l   #THREE_D_VIEW_WIDTH*4,d1        ;z's not inside the buffer
	bge     .nope_not_onscreen
;ok, its in the buffer.
;convert from 3d to 2d..
	move.l  d0,d2           ;STORE THE UNTOUCHED Z DEPTH!
	mulu    #THREE_D_VIEW_WIDTH,d0
	add.l   d0,d1
	move.l  (a1,d1.l),d0    ;the converted 3d x..
;ok, got the converted 3d point..
;now fill the image bank..
	sub.l   #((THREE_D_VIEW_WIDTH-IMAGE_BANK_WIDTH)/2)*4,d0
			;get it all central!
	bmi     .nope_not_onscreen      ;skip it! not onscreen!
	cmp.l   #(IMAGE_BANK_WIDTH-1)*4,d0
	bgt     .nope_not_onscreen      ;skip it! not onscreen!!

;ok, lets check against the z buffer!!
	cmp.l   (a6,d0.l),d2
	bgt     .nope_not_onscreen
	move.l  d2,(a6,d0.l)
	lsr.l   #1,d0                   ;divide it by two..
;ok, get the current strip indicator
	move.l  texture_data_counter,d7         ;D7 AINT USED!
	lea     texture_line_jump_table,a1      ;can replace a1..
	move.l  (a1,d7.l),d7                    ;get the unstretched 
						;texture strip to use
	move.l  (a4,d7.l),d7                    ;get the REAL texture
						;strip to use out of
						;the bank..
	cmp.l   #0,d7                   ;if its texture strip zero
	beq     .nope_not_onscreen      ;then IGNORE IT!!
;the untouched Z is in d2.
	add.l   (a5,d2.l),d7    ;get into the texture strip bank
				;according to the z colour!
	mulu    #TEXTURE_STRIP_HEIGHT,d2        ;get past all Z's..
	add.l   d2,a2                   ;get into the bank
	add.l   d7,a3                   ;nip into the texture bank..
	move.l  #TEXTURE_STRIP_HEIGHT-1,d6      ;d6 free..
.fill_loop
	move.l  (a2)+,d3        ;get place to put it
	move.w  (a3),d5         ;d5 free. the colour!
	cmp.w   #0,d5           ;check it..
	beq.s   .yes_its_zero
		add.l   d0,d3           ;get across bank
		move.w  d5,(a0,d3.l)    ;shove it in..
.yes_its_zero
	add.l   #STRIP_FADE_VALUE*2,a3  ;step in one..
	dbf     d6,.fill_loop
					;RIGHT, thats that done!!       
.nope_not_onscreen
	movem.l (sp)+,d0-d7/a1-a3

.no_draw        
	add.l   #4,texture_data_counter ;go into texture bank..
	add.l   texture_line_yinc,d1                    ;y = y+yinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d3                   ;if d > dy
	bgt.s   .nope
	add.l   texture_line_xinc,d0                    ;x = x+xinc     
	sub.l   d4,d6                   ;d = d-c
.nope
	cmp.l   texture_line_draw_Y2,d1         ;if y <> y2
	bne     .no_quit
	bra     .quit_drawing
.draw_2
	move.l  d2,d4
	add.l   d4,d4                   ;c = 2*dx
	
	move.l  d3,d5
	add.l   d5,d5                   ;m = 2*dy
.no_quit_2      
	;ok, sub wallsize from X and Z..
	;convert result to 3d (if onscreen!)
	;then fill the z buffer for that point..
	
	movem.l d0-d7/a1-a3,-(sp)

	sub.l   #MAX_WALL_SIZE*4,d0
	bmi     .nope_not_onscreen2
	cmp.l   #THREE_D_VIEW_DEPTH*4,d0
	bge     .nope_not_onscreen2     ;x ain't in the buffer!

	sub.l   #MAX_WALL_SIZE*4,d1
	bmi     .nope_not_onscreen2
	cmp.l   #THREE_D_VIEW_WIDTH*4,d1        ;z's not inside the buffer
	bge     .nope_not_onscreen2
;ok, its in the 3d view.
;convert from 3d to 2d..
	move.l  d0,d2           ;STORE THE UNTOUCHED Z DEPTH!
	mulu    #THREE_D_VIEW_WIDTH,d0
	add.l   d0,d1
	move.l  (a1,d1.l),d0    ;the converted 3d x..
;ok, got the converted 3d point..
;now fill the image bank..
	sub.l   #((THREE_D_VIEW_WIDTH-IMAGE_BANK_WIDTH)/2)*4,d0
			;get it all central!
	bmi     .nope_not_onscreen2     ;skip it! not onscreen!
	cmp.l   #(IMAGE_BANK_WIDTH-1)*4,d0
	bgt     .nope_not_onscreen2     ;skip it! not onscreen!!
;ok, lets check against the z buffer!!
	cmp.l   (a6,d0.l),d2
	bgt     .nope_not_onscreen2
	move.l  d2,(a6,d0.l)
	lsr.l   #1,d0                   ;divide it by two..
;ok, get the current strip indicator
	move.l  texture_data_counter,d7         ;D7 AINT USED!
	lea     texture_line_jump_table,a1      ;can replace a1..
	move.l  (a1,d7.l),d7                    ;get the unstretched 
						;texture strip to use
	move.l  (a4,d7.l),d7                    ;get the REAL texture
						;strip to use out of
						;the bank..
	cmp.l   #0,d7                   ;if its texture strip zero
	beq     .nope_not_onscreen2     ;then IGNORE IT!!
;the untouched Z is in d2.
	add.l   (a5,d2.l),d7    ;get into the texture strip bank
;according to the z colour!
	mulu    #TEXTURE_STRIP_HEIGHT,d2        ;get past all the Z's..
	add.l   d2,a2                   ;get into the bank
	add.l   d7,a3                   ;nip into the texture bank..
	move.l  #TEXTURE_STRIP_HEIGHT-1,d6      ;d6 free..
.fill_loop_2
	move.l  (a2)+,d3        ;get place to put it
	move.w  (a3),d5         ;d5 free. the colour!
	cmp.w   #0,d5           ;check it..
	beq.s   .yes_its_zero_2
		add.l   d0,d3           ;get across bank
		move.w  d5,(a0,d3.l)    ;shove it in..
.yes_its_zero_2
	add.l   #STRIP_FADE_VALUE*2,a3  ;step in one..
	dbf     d6,.fill_loop_2
					;RIGHT, thats that done!!       
.nope_not_onscreen2
	movem.l (sp)+,d0-d7/a1-a3

.no_draw2
	add.l   #4,texture_data_counter ;go into texture bank..

	add.l   texture_line_xinc,d0    ;x = x+xinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d2                   ;if d > dx
	bgt.s   .nope_2
	add.l   texture_line_yinc,d1    ;y = y+yinc
	sub.l   d4,d6                   ;d = d-c
.nope_2         
	cmp.l   texture_line_draw_X2,d0         ;if x <> x2
	bne     .no_quit_2
.quit_drawing
	movem.l (sp)+,a0-a6/d0-d7       ;get them back!
	rts

texture_line_draw_optimised
	movem.l a0-a6/d0-d7,-(sp)       ;stack them!
	lea     texture_line_quick_push_regs_in,a0
	movem.l (a0),a0-a6                              ;shove em in!
;               lea     image_bank,a0
;               lea     x3d_to_x2d_table,a1
;               lea     texture_shrink_table,a2
;               lea     texture_strip_data,a3
;               lea     texture_line_data,a4
;               lea     texture_fade_colour_data,a5
;               lea     z_buffer,a6
	add.l   #(IMAGE_BANK_WIDTH/2)*4,a6      ;solve DUMB problem
			;to do with see thru walls when they shouldn't be!!!

	move.l  texture_col,d7          ;what texture we using?
	mulu    #MAX_WALL_SIZE*4,d7
	add.l   d7,a4                   ;get to right data for line!

	move.l  #0,texture_data_counter         ;clear it!!

	lsl.l   #2,d0   ;to get faster access to tables!
	lsl.l   #2,d1   ;we mulu all the inputted values by four!
	lsl.l   #2,d2   ;sneaky..
	lsl.l   #2,d3
	move.l  d2,texture_line_draw_X2
	move.l  d3,texture_line_draw_Y2

	moveq.l #0,d4                   ;c = 0
	moveq.l #0,d5                   ;m = 0
	moveq.l #0,d6                   ;d = 0
	
	move.l  #4,texture_line_xinc                    ;xinc = 1
	move.l  #4,texture_line_yinc                    ;yinc = 1

	sub.l   d0,d2                   ;dx = x2-x1
	bpl     .next                   ;if dx < 0
	move.l  #-4,texture_line_xinc   ;xinc = -1
	neg.l   d2                      ;dx = -dx
.next   
	sub.l   d1,d3                   ;dy = y2-y1
	bpl     .next_2                 ;if dy < 0
	move.l  #-4,texture_line_yinc   ;yinc = -1
	neg.l   d3                      ;dy = -dy
.next_2
	cmp.l   d3,d2                   ;if dy < dx
	bgt     .draw_2
.draw_1
	move.l  d3,d4
	add.l   d4,d4                   ;c = 2*dy

	move.l  d2,d5
	add.l   d5,d5                   ;m = 2*dx

.no_quit
	;ok, sub wallsize from X and Z..
	;convert result to 3d (if onscreen!)
	;then fill the z buffer for that point..
	
	movem.l d0-d7/a1-a3,-(sp)
	
	sub.l   #MAX_WALL_SIZE*4,d0
	bmi     .nope_not_onscreen
	cmp.l   #THREE_D_VIEW_DEPTH*4,d0
	bge     .nope_not_onscreen      ;x ain't in the buffer!

	sub.l   #MAX_WALL_SIZE*4,d1
	bmi     .nope_not_onscreen
	cmp.l   #THREE_D_VIEW_WIDTH*4,d1        ;z's not inside the buffer
	bge     .nope_not_onscreen
;ok, its in the buffer.
;convert from 3d to 2d..
	move.l  d0,d2           ;STORE THE UNTOUCHED Z DEPTH!
	mulu    #THREE_D_VIEW_WIDTH,d0
	add.l   d0,d1
	move.l  (a1,d1.l),d0    ;the converted 3d x..
;ok, got the converted 3d point..
;now fill the image bank..
	sub.l   #((THREE_D_VIEW_WIDTH-IMAGE_BANK_WIDTH)/2)*4,d0
			;get it all central!
	bmi     .nope_not_onscreen      ;skip it! not onscreen!
	cmp.l   #(IMAGE_BANK_WIDTH-1)*4,d0
	bgt     .nope_not_onscreen      ;skip it! not onscreen!!

;ok, lets check against the z buffer!!
;glass textures can buffer off!!
	cmp.l   (a6,d0.l),d2
	bge     .nope_not_onscreen
	move.l  d2,(a6,d0.l)
	lsr.l   #1,d0                   ;divide it by two..
;ok, get the current strip indicator
	move.l  texture_data_counter,d7         ;D7 AINT USED!
	lea     texture_line_jump_table,a1      ;can replace a1..
	move.l  (a1,d7.l),d7                    ;get the unstretched 
						;texture strip to use
	move.l  (a4,d7.l),d7                    ;get the REAL texture
						;strip to use out of
						;the bank..
;the untouched Z is in d2.
	add.l   (a5,d2.l),d7    ;get into the texture strip bank
				;according to the z colour!
	mulu    #TEXTURE_STRIP_HEIGHT,d2        ;get past all Z's..
	add.l   d2,a2                   ;get into the bank
	add.l   d7,a3                   ;nip into the texture bank..
i       set     0
	rept    TEXTURE_STRIP_HEIGHT-1
		move.l  (a2)+,d3        ;get place to put it
		add.l   d0,d3           ;get to correct pos in bank
		move.w  i(a3),(a0,d3.l)
i       set     i+(STRIP_FADE_VALUE*2)
	endr
					;RIGHT, thats that done!!       
.nope_not_onscreen
	movem.l (sp)+,d0-d7/a1-a3

.no_draw        
	add.l   #4,texture_data_counter ;go into texture bank..
	add.l   texture_line_yinc,d1                    ;y = y+yinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d3                   ;if d > dy
	bgt.s   .nope
	add.l   texture_line_xinc,d0                    ;x = x+xinc     
	sub.l   d4,d6                   ;d = d-c
.nope
	cmp.l   texture_line_draw_Y2,d1         ;if y <> y2
	bne     .no_quit
	bra     .quit_drawing
.draw_2
	move.l  d2,d4
	add.l   d4,d4                   ;c = 2*dx
	
	move.l  d3,d5
	add.l   d5,d5                   ;m = 2*dy
.no_quit_2      
	;ok, sub wallsize from X and Z..
	;convert result to 3d (if onscreen!)
	;then fill the z buffer for that point..
	
	movem.l d0-d7/a1-a3,-(sp)

	sub.l   #MAX_WALL_SIZE*4,d0
	bmi     .nope_not_onscreen2
	cmp.l   #THREE_D_VIEW_DEPTH*4,d0
	bge     .nope_not_onscreen2     ;x ain't in the buffer!

	sub.l   #MAX_WALL_SIZE*4,d1
	bmi     .nope_not_onscreen2
	cmp.l   #THREE_D_VIEW_WIDTH*4,d1        ;z's not inside the buffer
	bge     .nope_not_onscreen2
;ok, its in the 3d view.
;convert from 3d to 2d..
	move.l  d0,d2           ;STORE THE UNTOUCHED Z DEPTH!
	mulu    #THREE_D_VIEW_WIDTH,d0
	add.l   d0,d1
	move.l  (a1,d1.l),d0    ;the converted 3d x..
;ok, got the converted 3d point..
;now fill the image bank..
	sub.l   #((THREE_D_VIEW_WIDTH-IMAGE_BANK_WIDTH)/2)*4,d0
			;get it all central!
	bmi     .nope_not_onscreen2     ;skip it! not onscreen!
	cmp.l   #(IMAGE_BANK_WIDTH-1)*4,d0
	bgt     .nope_not_onscreen2     ;skip it! not onscreen!!
;ok, lets check against the z buffer!!
;glass textures can buffer off!!
	cmp.l   (a6,d0.l),d2
	bge     .nope_not_onscreen2
	move.l  d2,(a6,d0.l)
	lsr.l   #1,d0                   ;divide it by two..
;ok, get the current strip indicator
	move.l  texture_data_counter,d7         ;D7 AINT USED!
	lea     texture_line_jump_table,a1      ;can replace a1..
	move.l  (a1,d7.l),d7                    ;get the unstretched 
						;texture strip to use
	move.l  (a4,d7.l),d7                    ;get the REAL texture
						;strip to use out of
						;the bank..
;the untouched Z is in d2.
	add.l   (a5,d2.l),d7    ;get into the texture strip bank
;according to the z colour!
	mulu    #TEXTURE_STRIP_HEIGHT,d2        ;get past all the Z's..
	add.l   d2,a2                   ;get into the bank
	add.l   d7,a3                   ;nip into the texture bank..
i       set     0
	rept    TEXTURE_STRIP_HEIGHT-1
		move.l  (a2)+,d3        ;get place to put it
		add.l   d0,d3           ;get to correct pos in bank
		move.w  i(a3),(a0,d3.l)
i       set     i+(STRIP_FADE_VALUE*2)
	endr
					;RIGHT, thats that done!!       
.nope_not_onscreen2
	movem.l (sp)+,d0-d7/a1-a3

.no_draw2
	add.l   #4,texture_data_counter ;go into texture bank..

	add.l   texture_line_xinc,d0    ;x = x+xinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d2                   ;if d > dx
	bgt.s   .nope_2
	add.l   texture_line_yinc,d1    ;y = y+yinc
	sub.l   d4,d6                   ;d = d-c
.nope_2         
	cmp.l   texture_line_draw_X2,d0         ;if x <> x2
	bne     .no_quit_2
.quit_drawing
	movem.l (sp)+,a0-a6/d0-d7       ;get them back!
	rts


draw_world_as_3d
	move.l  work,a0
	lea     world_3d_line_data,a1
	lea     rotated_3d_world_points,a2
	lea     x3d_to_x2d_table,a3             ;converter!
	move.l  number_3d_lines,d7
	subq.l  #1,d7                           ;get it right..
.d3d_loop
	movem.l (a1)+,d5-d6     ;point 1 to point 2
	move.l  (a1)+,texture_col       ;texture to draw in
	move.l  (a1)+,d4        ;the 'padding bit'
	lsl.l   #3,d5   ;two longwords = 8
	lsl.l   #3,d6   ;mult by 8.. step into 3d points this much..
;right, got offsets into the point bank..
;do checking to see if points within view window as we go..
;will cut out time if any of the points fails the checks
;instead of doing all points, then checking..
	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d1
	sub.l   (a2,d5.l),d1
	and.l   #$0000ffff,d1
	bmi     .d3d_nope       ;has minus flag been set?
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d1
	bgt     .d3d_nope

	move.l  #MAX_WALL_SIZE,d0
	add.l   4(a2,d5.l),d0           ;first point z/x
	and.l   #$0000ffff,d0
	bmi     .d3d_nope
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d0
	bgt     .d3d_nope

	move.l  #(THREE_D_VIEW_WIDTH/2)+MAX_WALL_SIZE,d3
	sub.l   (a2,d6.l),d3
	and.l   #$0000ffff,d3
	bmi     .d3d_nope
	cmp.l   #THREE_D_VIEW_WIDTH+(MAX_WALL_SIZE*2),d3
	bgt     .d3d_nope

	move.l  #MAX_WALL_SIZE,d2
	add.l   4(a2,d6.l),d2   ;second point z/x
	and.l   #$0000ffff,d2
	bmi     .d3d_nope
	cmp.l   #THREE_D_VIEW_DEPTH+(MAX_WALL_SIZE*2),d2
	bgt     .d3d_nope

;by george. its onscreen, or at least one point is..
;now draw the line between em. 
;making sure its inside our 100x100 3d window! 
******************* SHRINK THE TEXTURE!! **********
	movem.l d0-d7,-(sp)     ;stack THIS one only..
			;first of all, get the distances between points..
	move.l  d2,d4
	sub.l   d0,d4
	bpl     .no_neg_x
	move.l  d0,d4
	sub.l   d2,d4
.no_neg_x
	move.l  d3,d5
	sub.l   d1,d5
	bpl     .no_neg_y
	move.l  d1,d5
	sub.l   d3,d5
.no_neg_y
				;ok, got differences... 
				;now figure out which is the biggest..
	cmp.l   d4,d5
	blt     .first_biggest
	move.l  d5,d4
.first_biggest
		;d4 now holds the longest difference between points..
	lea     texture_line_jump_table,a4      ;got to do this!!
						;otherwise we get FUNKup.
	moveq.l #0,d5                           ;the number of pixels drawn..
	move.l  d4,d6                           ;the looper reg..
	addq.l  #1,d4                           ;so no div by zero errors!
;thanks to scotto for the optimisation of this rout!
	move.l  #MAX_WALL_SIZE*32,d7            ;shove the mult in
	divs    d4,d7                           ;divide it up..
	move.l  d7,shrink_texture_temp_store    ;store it..
.go_loop
	move.l  shrink_texture_temp_store,d7    ;divide by line len
				;so we got a step in d7
				;now mulu it by number of pix done (d6)
	mulu    d5,d7                           ;done it..

	lsr.l   #5,d7   ;divide by 32..
	and.l   #$0000ffff,d7                   ;clear the shite!
	lsl.l   #2,d7                   ;gets faster access to tables
	move.l  d7,(a4)+

	addq.l  #1,d5                           ;another pixel done.
		;(((wallsize*10)/maxlinsize)*(numpix done))/10..
	dbf     d6,.go_loop
	movem.l (sp)+,d0-d7             ;unstack this register..
***************************************************
	jsr     texture_line_draw_optimised     ;use the nippy one..
.d3d_nope
	dbf     d7,.d3d_loop
	rts



draw_calced_buffer_points
	move.l  work,a0
	lea     point_data,a1
	lea     mulu_160_table,a2
	lea     point_across_data,a3
	lea     rotated_3d_world_points,a4
	move.l  number_3d_world_points,d7
	subq.l  #1,d7                           ;get it right..
.loop
	movem.l (a4)+,d2-d3                     ;the x,z
	lsr.l   #MAP_DRAW_DIVISION,d2           ;divide em down
	lsr.l   #MAP_DRAW_DIVISION,d3
	move.l  #160,d0                         ;put the screen origin 
	move.l  #100,d1
	sub.l   d2,d0                           ;sub it...
	sub.l   d3,d1
	
	and.l   #$0000ffff,d0   ;do this to clear the second word
	and.l   #$0000ffff,d1   ;in each longword. see later for 
				;long explanation!
	cmp.l   #0+32,d0                ;not onscreen!?
	blt.s   .no_draw        ;don't plot it!
	cmp.l   #319-32,d0
	bgt.s   .no_draw
	cmp.l   #0,d1
	blt.s   .no_draw
	cmp.l   #199,d1
	bgt.s   .no_draw
***point plot!
	lsl.l   #2,d1           ;mult by 4
	move.l  (a2,d1.l),d3    ;temp_store, go down the screen..

	lsl.l   #2,d0           ;mult by 4..
	move.w  (a1,d0.l),d2    ;get point data..

	add.l   (a3,d0.l),d3    ;across screen pointer..
	or.w    d2,(a0,d3.l)            ;plop it onscreen..
.no_draw
	dbf     d7,.loop
	rts

draw_player_pos_on_map
	move.l  work,a0
	move.l  #159,d0
	move.l  #100,d1
	move.l  #162,d2
	move.l  #100,d3
	jsr     fast_line_draw_1_bitplane_no_clipping

	move.l  #160,d0
	move.l  #99,d1
	move.l  #160,d2
	move.l  #104,d3
	jsr     fast_line_draw_1_bitplane_no_clipping
	rts

draw_the_map
	move.l  work,a0 ;it gets reset in the routine..
	lea     world_3d_line_data,a1
	lea     rotated_3d_world_points,a2
	move.l  number_3d_lines,d7
	subq.l  #1,d7                           ;get it right..
.loop
	movem.l (a1)+,d5-d6     ;point 1 to point 2
	move.l  (a1)+,d4        ;texture to draw in
	move.l  (a1)+,d4        ;the 'padding bit'
	lsl.l   #3,d5   ;two longwords = 8
	lsl.l   #3,d6   ;mult by 8.. step into 3d points this much..

	movem.l (a2,d5.l),d2-d3         ;first x,z
	lsr.l   #MAP_DRAW_DIVISION,d2   ;divide em down
	lsr.l   #MAP_DRAW_DIVISION,d3   
	move.l  #160,d0                 ;put in screen origin
	move.l  #100,d1
	sub.l   d2,d0                   ;subtract divided down points
	sub.l   d3,d1                   ;dregs 0,1,6,7 used

	movem.l (a2,d6.l),d4-d5         ;second x,z
	lsr.l   #MAP_DRAW_DIVISION,d4   ;divide em down
	lsr.l   #MAP_DRAW_DIVISION,d5
	move.l  #160,d2                 ;put in screen origin
	move.l  #100,d3
	sub.l   d4,d2                   ;subtract the now divided
	sub.l   d5,d3                   ;points off..

	and.l   #$0000ffff,d0   ;do this to clear the second word
	and.l   #$0000ffff,d1   ;in each longword. reason?
	and.l   #$0000ffff,d2   ;we are getting some HUGE numbers
	and.l   #$0000ffff,d3   ;cos of the sine rout
				;and the line draw is taking AGES               
				;(it seems to hang..)
	cmp.l   #0+32,d0                ;if ONE of the points is offscreen
	blt.s   .no_draw        ;and since all our textures are
	cmp.l   #319-32,d0              ;EXACTLY 80 pix
	bgt.s   .no_draw        ;DON'T DRAW THE LINE!
	cmp.l   #0,d1           ;we can cover the funk ups with a 
	blt.s   .no_draw        ;20pix (width/height) border around
	cmp.l   #199,d1         ;the map.. copy it straight on
	bgt.s   .no_draw        ;
	cmp.l   #0+32,d2                ;and oh look, an enclosed map piccy.
	blt.s   .no_draw        ;and ooh bugger! it moves!
	cmp.l   #319-32,d2              ;god I love being sneaky.. =]
	bgt.s   .no_draw
	cmp.l   #0,d3
	blt.s   .no_draw
	cmp.l   #199,d3
	bgt.s   .no_draw

	jsr     fast_line_draw_1_bitplane_no_clipping
.no_draw
	dbf     d7,.loop
	rts



**************** line drawing
** 1 bitplane, unmasked. who cares. its quick. it does for the map..
fast_line_draw_1_bitplane_no_clipping
	movem.l a0-a6/d0-d7,-(sp)       ;stack them!
	lea     point_data,a1
	lea     mulu_160_table,a2
	lea     point_across_data,a3

	lsl.l   #2,d0   ;to get faster access to tables!
	lsl.l   #2,d1   ;we mulu all the inputted values by four!
	lsl.l   #2,d2   ;sneaky..
	lsl.l   #2,d3
	move.l  d2,line_draw_X2
	move.l  d3,line_draw_Y2

	sub.l   d0,d2                   ;dx = x2-x1
	sub.l   d1,d3                   ;dy = y2-y1

	moveq.l #0,d4                   ;c = 0
	moveq.l #0,d5                   ;m = 0
	moveq.l #0,d6                   ;d = 0
	
	move.l  #4,a5                   ;xinc = 1
	move.l  #4,a6                   ;yinc = 1

	cmp.l   #0,d2                   ;if dx < 0
	bgt.s   .next
	move.l  #-4,a5                  ;xinc = -1
	neg.l   d2                      ;dx = -dx
.next   
	cmp.l   #0,d3                   ;if dy < 0
	bgt.s   .next_2
	move.l  #-4,a6                  ;yinc = -1
	neg.l   d3                      ;dy = -dy
.next_2
	cmp.l   d3,d2                   ;if dy < dx
	bgt     .draw_2
.draw_1
	move.l  d3,d4
	add.l   d4,d4                   ;c = 2*dy

	move.l  d2,d5
	add.l   d5,d5                   ;m = 2*dx

.no_quit
;       cmp.l   line_clip_x1,d0
;       blt.s   .no_draw
;       cmp.l   line_clip_x2,d0
;       bgt.s   .no_draw
;       cmp.l   line_clip_y1,d1
;       blt.s   .no_draw
;       cmp.l   line_clip_y2,d1
;       bgt.s   .no_draw
				;*****point plot
	movem.l d2-d3,-(sp)
	move.l  (a2,d1.l),d3    ;temp_store, go down the screen..
	move.w  (a1,d0.l),d2    ;get point data..

	add.l   (a3,d0.l),d3    ;across screen pointer..
	or.w    d2,(a0,d3.l)            ;plop it onscreen..
	movem.l (sp)+,d2-d3
.no_draw        
	add.l   a6,d1                   ;y = y+yinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d3                   ;if d > dy
	bgt.s   .nope
	add.l   a5,d0                   ;x = x+xinc     
	sub.l   d4,d6                   ;d = d-c
.nope
	cmp.l   line_draw_Y2,d1         ;if y <> y2
	bne     .no_quit
	bra     .quit_drawing
.draw_2
	move.l  d2,d4
	add.l   d4,d4                   ;c = 2*dx
	
	move.l  d3,d5
	add.l   d5,d5                   ;m = 2*dy
.no_quit_2      
;       cmp.l   line_clip_x1,d0
;       blt.s   .no_draw2
;       cmp.l   line_clip_x2,d0
;       bgt.s   .no_draw2
;       cmp.l   line_clip_y1,d1
;       blt.s   .no_draw2
;       cmp.l   line_clip_y2,d1
;       bgt.s   .no_draw2
				;*****point plot
	movem.l d2-d3,-(sp)
	move.l  (a2,d1.l),d3    ;temp_store, go down the screen..
	move.w  (a1,d0.l),d2    ;get point data..

	add.l   (a3,d0.l),d3    ;across screen pointer..
	or.w    d2,(a0,d3.l)            ;plop it onscreen..
	movem.l (sp)+,d2-d3
.no_draw2
	add.l   a5,d0                   ;x = x+xinc
	add.l   d5,d6                   ;d = d+m

	cmp.l   d6,d2                   ;if d > dx
	bgt.s   .nope_2
	add.l   a6,d1                   ;y = y+yinc
	sub.l   d4,d6                   ;d = d-c
.nope_2         
	cmp.l   line_draw_X2,d0         ;if x <> x2
	bne     .no_quit_2
.quit_drawing
	movem.l (sp)+,a0-a6/d0-d7       ;get them back!
	rts




*******************************************************************
* All the data goes here...
*******************************************************************

*******************************************************************
*** teleportation stuff *******************************************
*******************************************************************
player_teleport_flag            dc.l    0
player_teleport_to_level        dc.l    0
teleport_data
	dc.l    160,480,240,540,YES,TELEPORT_TYPE_EXIT,200,520,1
			;test doofah!
	rept    MAX_NUM_TELEPORTS+1
	dc.l    0,0,0,0                 ;x1,z1,x2,z2
	dc.l    NO                      ;used or not
	dc.l    TELEPORT_TYPE_NORMAL    ;the type
	dc.l    0,0                     ;teleport to x,z
	dc.l    0                       ;teleport to level ??
	endr

*******************************************************************
*** explosion stuff! **********************************************
*******************************************************************

static_explosion_pos_data
	rept    MAX_NUM_EXPLOSIONS+1
	dc.l    0,0,2,0         ;x,z, width, texture to use..
	endr
rotated_explosion_pos_data
	rept    MAX_NUM_EXPLOSIONS+1
	dc.l    0,0             ;x,z
	endr
explosion_type_data
	rept    MAX_NUM_EXPLO_TYPES+1
	dc.l    NO,0,MAX_NUM_EXPLO_A_FR+1       ;used, type (governs textures), timer
	endr
explosion_anim_tables                   ;ie, what textures to use!
	rept    MAX_NUM_EXPLO_TYPES+1
	dc.l    0,1,2,1         ;thats max_num_explo_a_fr
	endr
explosion_width_tables
	rept    MAX_NUM_EXPLO_TYPES+1
	dc.l    40,60,80,100            ;thats max_num_explo_a_fr
	endr    

*******************************************************************
*** switch stuff! *************************************************
*******************************************************************

static_switch_position
	dc.l    180,480,220,480,0,SWITCH_OFF,SWITCH_INVIS,SWITCH_TYPE_LIGHT
	dc.l    180,480,220,480,1,SWITCH_OFF,SWITCH_INVIS,SWITCH_TYPE_LIGHT
			;got to have some test data
	rept    MAX_NUM_DOORS+1
	dc.l    0,0,0,0         ;x1,z1,x2,z2
	dc.l    0               ;which door is connected to this switch!?
	dc.l    0               ;SWITCH_ON or SWITCH_OFF!?
	dc.l    0               ;SWITCH_VIS or SWITCH_INVIS
	dc.l    0               ;switch type, governs what texture!
	endr
rotated_switch_position
	rept    MAX_NUM_DOORS+1
	dc.l    0,0,0,0         ;x1,z1,x2,z2
	endr
switch_anim_data
	rept    MAX_NUM_SWITCH_TYPES+1
	dc.l    0,1             ;ON texture, OFF texture!
	endr

*******************************************************************
*** door data, ie positions etc ***********************************
*******************************************************************

num_doors_used          dc.l    2       ;how many in this level!?!?!

static_door_data
	dc.l    160,480,200,480,0,DOOR_TYPE_RED_KEY,DOOR_CLOSED
	dc.l    240,480,200,480,0,DOOR_TYPE_RED_KEY,DOOR_CLOSED
			;got to have some test doors!
	rept    MAX_NUM_DOORS+1
	dc.l    0,0,0,0         ;x1,z1,x2,z2
	dc.l    0               ;anim frame currently on
	dc.l    0               ;door type
	dc.l    DOOR_CLOSED     ;status, ie OPEN/CLOSED/OPENING/CLOSING
	endr
rotated_door_data
	rept    MAX_NUM_DOORS+1
	dc.l    0,0,0,0         ;x1,z1,x2,z2
	dc.l    0               ;the texture to use.. controlled by anim!
	endr
door_anim_texture_data
	rept    MAX_NUM_DOOR_TYPES+1
	dc.l    3,4,5,6         ;thats MAX_DOOR_ANIM_FRAMES!
	endr                    ;goes CLOSED to OPEN

*******************************************************************
*** pickup data ***************************************************
*******************************************************************

pickup_static_data
	dc.l    50,150,P_HEALTH_SMALL,YES,0     ;a temp one..

	rept    MAX_NUM_PICKUPS+1
	dc.l    0,0                     ;x,z
	dc.l    P_RED_KEY               ;type
	dc.l    NO                      ;used or not..
	dc.l    0                       ;animation frame currently on..
	endr
pickup_rotated_data
	rept    MAX_NUM_PICKUPS+1
	dc.l    0,0,0                   ;x,z,texture
	endr
pickups_player_has
	rept    MAX_NUM_PICKUP_TYPES+1
	dc.l    YES                     ;set to NO? We ain't got it!
	endr
pickups_player_has_values
	rept    MAX_NUM_PICKUP_TYPES+1
	dc.l    MAX_PICKUP_VALUE                ;100 or something
	endr
pickup_values
	rept    MAX_NUM_PICKUP_TYPES+1
	dc.l    10      ;each type has its own value!
	endr            ;ie, small_shotgun gives 10, but big = 30
pickup_texture_to_use_data
	rept    MAX_NUM_PICKUP_TYPES+1
	dc.l    1,1,1,1         ;(MAX_PICKUPS_ANIM_FR)  
	endr                    ;ie, use THIS texture to draw with!

*******************************************************************
*** weapon data ***************************************************
*******************************************************************

weapon_deduction_values
	rept    MAX_NUM_WEAPONS+1
	dc.l    1               ;all weapons take off two from ammo!
	endr
weapon_holding_table
	rept    MAX_NUM_WEAPONS+1
	dc.l    YES             ;all weapons take off two from ammo!
	endr
weapon_reload_timer_and_bullet_type
i       set     (MAX_NUM_WEAPONS*5)+1
	rept    MAX_NUM_WEAPONS+1
	dc.l    i,0
i       set     i-5
	endr

*******************************************************************
*** All screen gfx.. ie scorecards fonts etc. *********************
*******************************************************************

scorecard_background
	rept    200             ;the background looks same regardless
	dc.l    $0f0f0f0f               ;of what side of the screen its on..
	dc.l    $f0f0f0f0       ;thats 16 pix covered
	dc.l    $0f0f0f0f
	dc.l    $f0f0f0f0       ;thats the next 16 pix covered
	endr
	even
one_bitplane_font_table
i       set     0
	rept    20
	dc.l    i,0,i,16
i       set     i+8
	endr

one_bitplane_mulu_2_table
i       set     0
	rept    255
	dc.l    i*32
i       set     i+1
	endr
	even

*******************************************************************
*** All COLLISION based data **************************************
*******************************************************************

circle_wall_3d_point_lookup_table
	ds.l    MAX_NUMBER_3D_POINTS+1  ;A BIG LOOKUP TABLE!

circle_wall_wide_x1     dc.l    0       ;these are to speed the wall
circle_wall_wide_z1     dc.l    0       ;checks up..
circle_wall_wide_x2     dc.l    0       ;only draw walls within THIS box
circle_wall_wide_z2     dc.l    0
circle_wall_small_x1    dc.l    0       ;these are the for the box
circle_wall_small_z1    dc.l    0       ;around the passed in x,z..
circle_wall_small_x2    dc.l    0
circle_wall_small_z2    dc.l    0

circle_wall_collision_flag      dc.l    0
bullet_player_collision_flag    dc.l    0
bullet_monster_collision_flag   dc.l    0
bullet_monster_col_bul_power    dc.l    0       ;used within the rout
						;ie, how much to take
						;off the monster?!

*******************************************************************
*** All BULLET based data *****************************************
*******************************************************************

bullet_fired    dc.l    0       ;0 = NO!, 1 = YES!
rotated_bullet_data_store
	rept    MAX_NUM_BULLETS+1
	dc.l    0               ;0 = unused, 1 = used!
	dc.l    0,0             ;current x,z
	dc.l    0,0             ;destination x,z
	dc.l    0               ;speed its moving!
	dc.l    0               ;power
	dc.l    0               ;texture to use..
	dc.l    0               ;a timer. its a failsafe for bullets..
				;stops some weird fuckups.. 
	dc.l    0               ;who fired it?
			;just been fired or can it collide with owt?
	endr
bullet_data_store
	rept    MAX_NUM_BULLETS+1
	dc.l    0               ;0 = unused, 1 = used!
	dc.l    0,0             ;current x,z
	dc.l    0,0             ;destination x,z
	dc.l    0               ;speed its moving!
	dc.l    0               ;power
	dc.l    0               ;texture to use..
	dc.l    0               ;a timer. its a failsafe for bullets..
				;stops some weird fuckups.. 
	dc.l    0               ;who fired it?
	endr
bullet_type_lookup_table
i       set     10
	rept    MAX_NUM_WEAPONS+1
	dc.l    i,SLOW_BULL_SPD,0,0     ;speed, power, texture and PADDING
i       set     i+5
	endr


*******************************************************************
*** All ALIEN based data ******************************************
*******************************************************************

alien_flags
	rept    MAX_NUM_ALIENS+1
	dc.l    43      ;health 0=dead..
	dc.l    0       ;0 = still, 1 = active
			;if active go towards player.. (or other target)
	dc.l    0       ;sub intelligence
			;ie, if hurt, look for hiding place
			;not sure if this used for what it says it is anymore!
	dc.l    0       ;anger time..
			;if alien's anger time has become zero
			;then go back to wandering around aimlessly
			;otherwise always run at target!
	dc.l    1       ;0 = home in object, 1 = wandering aimlessly
			;if home on object, pick nearest object
			;this will usually be the player, but if it
			;isn't you'll get the alien picking fights
			;'are you starting' etc.. typical boozer mode..
	dc.l    0       ;wander timer, used for wandering around..
			;can't use anger timer..
	dc.l    0,0     ;the 'wander to' points..
			;when not homing in, got to wander!!
	dc.l    1       ;bullet timer..
			;ie, when this is zero they can fire!
			;when they've fired, this gets set to an
			;according value.. ie 10 for shotguns etc..
			;this allows a small delay between firing!!
	dc.l    0       ;alien type
			;ie 0 for imp, 1 for human etc..
			;denotes what type of bullet they can fire..
	endr
nearest_object_x        dc.l    0
nearest_object_z        dc.l    0
nearest_num_objects     dc.l    0       ;how many 'visible' things?
nearest_alien_store     ds.l    (MAX_NUM_ALIENS+1)*2    ;monster
			ds.l    2                       ;player
number_of_aliens_used           
	dc.l    2
static_alien_positions_and_textures
	dc.l    180,40,2
	dc.l    220,120,2
			;thats z, x, texture
			;might possibly need some more..?
	ds.l    (MAX_NUM_ALIENS+1)*3
rotated_alien_positions_and_textures
	ds.l    (MAX_NUM_ALIENS+1)*5
		;thats like x,z,x2,z2,texture to draw with
alien_death_animation
	rept    MAX_NUM_ALIEN_TYPES+1   ;each monster has own death seq!
	dc.l    0,1,0,1                 ;NUM_DEATH_FRAMES = 4!
	endr
alien_rotation_graphic_data
	rept    (MAX_NUM_ALIEN_TYPES+1)*MAX_NUM_ALIEN_A_FR
	dc.l    0,0,0,0,0,0,0,0
	endr    
	even

*******************************************************************
*** All other data ************************************************
*******************************************************************

player_timer_before_fire        dc.l    0       ;how long to wait?!
current_weapons_distance        dc.l    100
current_used_weapon             dc.l    0       ;what weapon is the user
						;shooting with!?!?

world_x_translation             dc.l    70      ;same as player_x_pos
world_z_translation             dc.l    -50     ;minus player_z_pos!
player_x_pos_in_map             dc.l    70
player_z_pos_in_map             dc.l    50
control_x_pos_temp              dc.l    0
control_z_pos_temp              dc.l    0
random_number_seed              dc.l    12
step_line_counter               dc.l    0
step_line_x_result              dc.l    0
step_line_y_result              dc.l    0
shrink_texture_temp_store       dc.l    0

number_of_objects_in_buffer     dc.l    1
object_drawing_buffer           ds.l    (MAX_NUM_VISIBLE_OBJECTS+1)*5   
					;thats, x1,y1,x2,y2,texture,width
texture_line_quick_push_regs_in
	dc.l    image_bank
	dc.l    x3d_to_x2d_table
	dc.l    texture_shrink_table
	dc.l    texture_strip_data
	dc.l    texture_line_data
	dc.l    texture_fade_colour_data
	dc.l    z_buffer
	even
texture_line_jump_table ds.l    500     ;used on StretchyTexture!
line_draw_X2            dc.l    0
line_draw_Y2            dc.l    0
line_draw_xinc          dc.l    0
line_draw_yinc          dc.l    0
line_clip_x1            dc.l    0*4
line_clip_y1            dc.l    0*4
line_clip_x2            dc.l    319*4
line_clip_y2            dc.l    199*4
texture_data_counter    dc.l    0
map_or_3d_drawing_mode  dc.l    MAP_DRAW_3D     ;0 for 3d, 1 for map
player_look_at_x_pos    dc.l    0
player_look_at_z_pos    dc.l    0
player_fire_at_x_pos    dc.l    0
player_fire_at_z_pos    dc.l    0
players_health          dc.l    99
			even

*******************************************************************
*** Texture based data and stuff **********************************
*******************************************************************

texture_line_data
					;detail for first texture
	dc.l    0,0,0,1,2,3,4,4,3,2,1,0,1,1,2,2,3,3,4,4
	dc.l    4,4,3,3,2,2,1,1,0,1,2,3,4,4,3,2,1,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

					;detail for second texture
	dc.l    5,6,7,8,9,10,11,12,13,14,13,12,11,10,9,8,7,6,5,6
	dc.l    7,8,9,10,11,12,13,14,14,14,14,14,14,14,14,14,14,14,14,14
	dc.l    14,14,14,14,14,14,14,14,14,14,14,14,14,13,12,11,10,9,8,7
	dc.l    6,5,6,7,8,9,10,11,12,13,14,13,12,11,10,9,8,7,6,5
	
					;detail for third texture
	dc.l    0,0,0,0,0,0,0,0,0,15,16,17,18,19,20,21,22,23,24,25
	dc.l    25,24,23,22,21,20,19,18,17,16,15,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			;temp alien! got to make it central!    

	dc.l    5,6,7,8,9,10,11,12,13,14,14,14,14,14,14,14,14,14,14,14
	dc.l    14,14,14,14,14,14,14,14,14,14,14,13,12,11,10,9,8,7,6,5
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	dc.l    14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14,14
	dc.l    14,13,12,11,10,9,8,7,6,5,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	dc.l    14,14,14,14,14,14,14,14,14,14,14,13,12,11,10,9,8,7,6,5
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

	dc.l    14,13,12,11,10,9,8,7,6,5,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
texture_line_data_end   dc.l    0

texture_fade_colour_data
	dc.l    0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,0,2,0
	dc.l    2,0,2,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,4,2,4,2
	dc.l    4,2,4,2,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,4,6,4,6,4
	dc.l    6,4,6,4,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6

texture_line_xinc       dc.l    0
texture_line_yinc       dc.l    0
texture_line_draw_X2    dc.l    0
texture_line_draw_Y2    dc.l    0
texture_line_draw_xinc  dc.l    0
texture_line_draw_yinc  dc.l    0
texture_line_clip_x1    dc.l    0
texture_line_clip_y1    dc.l    0
texture_line_clip_x2    dc.l    319
texture_line_clip_y2    dc.l    199
texture_col             dc.l    0
		even    

************************************ includes
point_data
	rept    20
	dc.w    %1000000000000000,0
	dc.w    %0100000000000000,0
	dc.w    %0010000000000000,0
	dc.w    %0001000000000000,0
	dc.w    %0000100000000000,0
	dc.w    %0000010000000000,0
	dc.w    %0000001000000000,0
	dc.w    %0000000100000000,0
	dc.w    %0000000010000000,0
	dc.w    %0000000001000000,0
	dc.w    %0000000000100000,0
	dc.w    %0000000000010000,0
	dc.w    %0000000000001000,0
	dc.w    %0000000000000100,0
	dc.w    %0000000000000010,0
	dc.w    %0000000000000001,0
	endr
	even
point_across_data
i       set     0
	rept    20
	dc.l    i,i,i,i,i,i,i,i,i,i,i,i,i,i,i,i
i       set     i+8
	endr
	even
mulu_160_table
i       set     0
	rept    200
	dc.l    i
i       set     i+160
	endr
	even

*****************************************************************
*** All data associated with the 3d world ***********************
*****************************************************************

current_angle_of_world_rotation dc.l    0
current_world_translation_value dc.l    0
number_3d_world_points                  dc.l    36
static_3d_world_points
				;origin 0,0 = 160,100   
				;+x = right, -x = left  
				;+z = up, -z = down
	dc.l    0,0,0,80,0,160,80,160,80,240,0,240
	dc.l    0,320,40,400,120,480,200,500,280,500
	dc.l    280,420,360,420,440,420,480,380
	dc.l    480,320,480,240,560,240,560,160,480,160,480,80
	dc.l    400,0,320,0,320,80,240,80,240,0,160,0,80,0
	dc.l    160,160,160,240,240,240,320,240,400,240,400,160
	dc.l    320,160,240,160
	even
number_3d_lines                 dc.l    36
world_3d_line_data
		;ie, 3d point 1 to 3d point 2
		;then texture and a padding word..
			;attribute unknown yet.. =]
	dc.l    0,1,1,0
	dc.l    1,2,1,0
	dc.l    2,3,1,0
	dc.l    3,4,1,0
	dc.l    4,5,1,0
	dc.l    5,6,1,0
	dc.l    6,7,1,0
	dc.l    7,8,1,0
	dc.l    8,9,1,0
	dc.l    9,10,1,0
	dc.l    10,11,1,0
	dc.l    11,12,1,0
	dc.l    12,13,1,0
	dc.l    13,14,1,0
	dc.l    14,15,1,0
	dc.l    15,16,1,0
	dc.l    16,17,1,0
	dc.l    17,18,1,0
	dc.l    18,19,1,0
	dc.l    19,20,1,0
	dc.l    20,21,1,0
	dc.l    21,22,1,0
	dc.l    22,23,1,0
	dc.l    23,24,1,0
	dc.l    24,25,1,0
	dc.l    25,26,1,0
	dc.l    26,27,1,0
	dc.l    27,0,1,0

	dc.l    28,29,1,0
	dc.l    29,30,1,0
	dc.l    30,31,1,0
	dc.l    31,32,1,0
	dc.l    32,33,1,0
	dc.l    33,34,1,0
	dc.l    34,35,1,0
	dc.l    35,28,1,0
	even

rotated_3d_world_points ds.l    (MAX_NUMBER_3D_POINTS+1)*2
ceiling_and_floor_data  ds.w    IMAGE_BANK_WIDTH*(IMAGE_BANK_HEIGHT+1)
image_bank              ds.w    IMAGE_BANK_WIDTH*(IMAGE_BANK_HEIGHT+1)
z_buffer                ds.l    IMAGE_BANK_WIDTH*2
converted_offset_image_bank
			ds.l    (IMAGE_BANK_WIDTH/2)*(IMAGE_BANK_HEIGHT+1)

joystick_left   dc.l    0
joystick_right  dc.l    0
joystick_up     dc.l    0
joystick_down   dc.l    0       ;all data associated with joystick
mouse_x         dc.l    0
mouse_y         dc.l    0
right_mouse     dc.l    0       ;all data for the mouse stuff
left_mouse      dc.l    0       ;if needed at any point..
temp_counter    dc.l    0       
old_key         dc.l    0       ;address of old key rout
key             dc.l    0       ;what's been pressed!?
button          dc.l    0       ;which mouse button?
vbl_flag        dc.l    0       ;only ever add bytes like..
savesp          dc.l    0       ;save the stack?
			;000,$200,$321,$332
game_pal        dc.w    $000,$766,$544,$322,$211,$420,$310,$200
		dc.w    $100,$077,$037,$005,$003,$070,$030,$777
gempal          dc.w    $302,$777,$777,$777
old_palette     ds.w    16      ;assumes st low!

*****************************************************************
*** ok, lets reserve some screen memory *************************
*****************************************************************
	IFEQ    RUN_FROM_DESKTOP
work            dc.l    $80000  ;address of our workscreen!
physic          dc.l    $88000  ;the one thats being displayed!
	ENDC
	IFNE    RUN_FROM_DESKTOP
		ds.b    4000
screen_data     ds.b    32000*2 ;two screens
		ds.b    4000
work            dc.l    screen_data
physic          dc.l    screen_data+32000
	ENDC

old_screen_res          dc.l    0       ;the old one gets shoved in here!
old_physic_screen       dc.l    0
old_logic_screen        dc.l    0
old_vbl                 dc.l    0
old_hbl                 dc.l    0
			even
old_a1b                 dc.b    0
old_a21                 dc.b    0
old_a07                 dc.b    0
old_a09                 dc.b    0
old_a13                 dc.b    0
old_a15                 dc.b    0
old_a17                 dc.b    0
			even
stack_stuff                     ;hehehe
		ds.l    1000    ;should be enough!!!
my_stack        dc.l    0       ;go backwards yeah!?

*******************************************************************
*** All the incbins go here! **************************************
*******************************************************************
			even
the_4x4_plot_data       incbin  data\4x4dat.bin
			even
one_bitplane_text_font  incbin  data\1bitfont.fnt
			even
sin_table               incbin  data\sintable.bin
			even
cos_table               incbin  data\costable.bin
			even
x3d_to_x2d_table        incbin  data\3dbank.bin
x3d_to_x2d_table_end    dc.l    0
			even
texture_strip_data      incbin  data\textstrp.dat
			even
texture_strip_data_end  dc.l    0       ;for BIG optimisation!
texture_shrink_table    incbin  data\shrnk.tab
			even
*******************************************************************
*** All the includes go here! Ie, sprite routs etc.. **************
*******************************************************************




