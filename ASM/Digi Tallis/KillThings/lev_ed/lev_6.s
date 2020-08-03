** KillThings level editor
** (C) 1996 Digi Tallis
**      distributed into the public domain after development stopped..
**      it's up to you guys/gals..
**
** this assembles under GenST 2 and upwards
**
** includes new windowing system. Gu-E 2.0a
**      full 68k version.
**      looks slightly like 95, but doesn't work the same. 
**      this needs some work on it before it is complete.. =]

* I'll endevour to comment most of it, and provide pointers as to what I
* wanted to do (so you can just turn them into code if you wish..)
* heck, I might as well make it as easy for you as possible, after all, I
* do some bloody strange code now and again..
* all the pointers and so on are at the end of the file..


**************************************************************************
** OK, lets go with the defines                                         **
**************************************************************************
YES                     equ     1       ;define some boolean!!
NO                      equ     0

RUN_FROM_DESKTOP        equ     0       ;0 = no. 1 = yes
					;tells assembler whether to define
					;memory for the two screens etc...
PROCESSOR_CHECK         equ     1       ;0 = yes, 1 = NO!
					;fairly obvious..
GENST_ESCAPE_KEY        equ     97      ;UNDO
MOUSPEED                equ     1       ;good numba.. =]

** defines for the KillThings based bits..
IMAGE_BANK_HEIGHT       equ     50
TEXTURE_X_SIZE          equ     80      ;makes life easier!
					;a HELL of a lot easier!!

MAX_NUMBER_3D_POINTS    equ     200     ;THIS NEEDS TO BE HUGE!!
MAX_NUM_WALL_LINES      equ     200     ;how many walls ??

MAX_MAP_X_SIZE          equ     500
MAX_MAP_Z_SIZE          equ     500     ;a big square!!

LOOK_BEHIND             equ     10      ;I honestly can't remember what
					;this is....sorry...
TEXTURE_STRIP_HEIGHT    equ     IMAGE_BANK_HEIGHT+(LOOK_BEHIND*2)
MAX_NUM_TEXTURES        equ     50      ;only this many textures!
MAX_NUM_TEXTURE_STRIPS  equ     50      ;only this many t-strips!

MAX_NUM_ALIENS          equ     5       ;in the game at any one time
MAX_NUM_ALIEN_TYPES     equ     10
ALIEN_A_FR_WALK_START   equ     0       ;animation for walking..
ALIEN_A_FR_WALK_END     equ     5      
ALIEN_A_FR_FIRE_START   equ     6
ALIEN_A_FR_FIRE_END     equ     11
ALIEN_A_FR_DYING        equ     12
MAX_NUM_ALIEN_A_FR      equ     ALIEN_A_FR_DYING
NUM_DEATH_FRAMES        equ     4

MAX_NUM_BULLETS         equ     10      ;thats in the game at any one time
MAX_BULLET_DISTANCE     equ     200     ;2 seconds worth..

MAX_NUM_EXPLOSIONS      equ     5       ;thats anywhere in the game at once
MAX_NUM_EXPLO_TYPES     equ     2       ;can have different explosions..
MAX_NUM_EXPLO_A_FR      equ     4       ;thats it!

MAX_NUM_WEAPONS         equ     6       ;GUN_0 to GUN_5
					;MUST MATCH!!!!
SLOW_BULL_SPD           equ     5       ;slowes bullet speed
MAX_NUM_PICKUPS         equ     5       ;how many per level?
MAX_PICKUPS_ANIM_FR     equ     4       ;four frames of anim per pickup!
MAX_NUM_PICKUP_TYPES    equ     11      ;how many types are there?
					;MUST be same as number of pickups!
MAX_PICKUP_VALUE        equ     99      ;how much of this pickup?!
P_AMMO_GUN_0            equ     0       ;pistol
P_AMMO_GUN_1            equ     1       ;shotgun
P_AMMO_GUN_2            equ     2       ;chaingun
P_AMMO_GUN_3            equ     3       ;rocket
P_AMMO_GUN_4            equ     4       ;plasma
P_AMMO_GUN_5            equ     5       ;BFG            ;ok, so its Doom! =]
P_RED_KEY               equ     6
P_YELLOW_KEY            equ     7
P_BLUE_KEY              equ     8
P_HEALTH_SMALL          equ     9       ;health by a small amount
P_HEALTH_LARGE          equ     10      ;BIG booster!
P_NOTHING               equ     11

MAX_NUM_DOORS           equ     5
MAX_DOOR_ANIM_FRAMES    equ     4       ;ie 4 frames to open/close door..
DOOR_OPEN               equ     0
DOOR_OPENING            equ     1
DOOR_CLOSED             equ     2
DOOR_CLOSING            equ     3       ;should cover about every state!
DOOR_TYPE_RED_KEY       equ     0
DOOR_TYPE_YELLOW_KEY    equ     1
DOOR_TYPE_BLUE_KEY      equ     2
DOOR_TYPE_NO_KEY_1      equ     3       ;doors that don't need a key!
DOOR_TYPE_NO_KEY_2      equ     4
DOOR_TYPE_NO_KEY_3      equ     5       ;allows different graphics!
DOOR_TYPE_HIDDEN_1      equ     6       ;secret doors that look like walls..
DOOR_TYPE_HIDDEN_2      equ     7       ;allows secret sections.. =]
DOOR_TYPE_HIDDEN_3      equ     8
DOOR_TYPE_LAST          equ     9       ;this should ALWAYS be last!!
MAX_NUM_DOOR_TYPES      equ     DOOR_TYPE_LAST  ;for easy code!

SWITCH_INVIS            equ     0       ;you can't see the switch!
SWITCH_VIS              equ     1       ;you can see the switch!
SWITCH_ON               equ     0
SWITCH_OFF              equ     1
SWITCH_TYPE_LIGHT       equ     0       ;ie red light etc..
SWITCH_TYPE_FACE        equ     1       ;grinning skull or whatever
SWITCH_TYPE_LAST        equ     2
MAX_NUM_SWITCH_TYPES    equ     SWITCH_TYPE_LAST
SWITCH_COLLISION_SIZE   equ     80      ;all switches are 40 wide
					;if both pnts inside zone..

MAX_NUM_TELEPORTS       equ     10
TELEPORT_TYPE_NORMAL    equ     0
TELEPORT_TYPE_EXIT      equ     1       ;ie, the level end!


**************************************************************************                                 
** Right then, lets set things like interrupts up..                     **
**************************************************************************
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

;clear some screens
	jsr     clear_workscreen
	jsr     flipper
	jsr     wait_vbl
	lea     gue_window_pal,a0
	jsr     put_pal_in

	jsr     gue_draw_everything
	jsr     flipper
go_wow_amazing
	jsr     gue_control_loop

quit_all                                ;had enough, stop doing things!
	bsr     bang_um_back
	bsr     pal_out
	bsr     screen_out

usr     move.l  savesp,-(sp)
	move.w  #$20,-(sp)
	trap    #1
	add.l   #6,sp
	clr.w   -(sp)
	trap    #1              ;return to desktop!

**************************************************************************
** error trapping code. stops bad stuff breaking machine.               **
**************************************************************************
bomb_trap       
	rept    8
	addq    #4,error_number
	endr
bailout 
	bsr     bang_um_back    ;kill interrupts...
	bsr     screen_out      ;back to medium!
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
**************************************************************************
** Bog standard, generic, useful code                                   **
**************************************************************************
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

	move.w  #3,-(sp)        ;3 gets logic??
	trap    #14
	add.l   #2,sp
	move.l  d0,old_logic_screen

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
	move.w  old_screen_res,-(sp)           
	move.l  old_logic_screen,-(sp)         
	move.l  old_physic_screen,-(sp)        
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
	move.l  #20-1,d6
.across_loop
	move.l  #0,(a0)
	move.l  #0,4(a0)        ;clear 16 pix
	
	add.l   #8,a0   ;get across
	dbf     d6,.across_loop

	dbf     d7,.down_loop
	rts

flipper                                 ;in case you were wondering, this
	move.l  work,d0                 ;flips screens..
	move.l  physic,work
	move.l  d0,physic

	move    #$8201,a0
	lsr.l   #8,d0
	movep   d0,(a0)
	rts

save_othershit
	move.l  $70.w,old_vbl           ;the vbl table
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

vbl     
	cmpi.b  #GENST_ESCAPE_KEY,key           ;compare for ESCAPE
	bne.s   .no_space
	move.b  #0,key          ;clear it....
	lea     quit_all,a0
	jmp     (a0)
.no_space
	addq.b  #1,vbl_flag     ;set it so other routs can go NOW!
	
	rte

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
	cmp.l   #315,d1
	blt.s   .no_stop_at_right
	move.l  #314,d1
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
	cmp.l   #195,d1
	blt.s   .no_stop_at_bot
	move.l  #194,d1
.no_stop_at_bot
	move.l  d1,mouse_y
	rts

**************************************************************************
** lets go with the code then..                                         **
**************************************************************************
do_nothing
	rts

draw_intro_message
	move.l  #1,d0
	jsr     gue_get_visible_window_pane

	move.l  #5,ink_colour
	move.l  gue_visible_x1,d0
	move.l  gue_visible_y1,d1       ;top left
	add.l   #1,d0
	add.l   #1,d1
	move.l  gue_visible_x2,d2
	move.l  gue_visible_y2,d3
	sub.l   #8,d2
	sub.l   #8,d3
	move.l  graphic_workscreen,a0
	lea     temp_text,a1
	jsr     print_text_varifont     

	rts

MAP_DIVIDE_VALUE        equ     2       ;thats divide by 2. 1=2, 2=4, 3=8

map_redraw_window
	movem.l d0-d7/a0-a6,-(sp)

	move.l  gue_drawing_window_number,d0
	move.l  #5,d1                           ;the ink to clear pane with!
	jsr     gue_cls_visible_window_pane

;ok, change the line draw clip points.. 
	lea     line_clip_x1,a0
	movem.l (a0),d0-d3
	lea     map_redraw_temp_store_clip,a0
	movem.l d0-d3,(a0)                      ;store em..
	
	lea     gue_visible_x1,a0
	movem.l (a0),d0-d3
		lsl.l   #3,d0
		lsl.l   #3,d1
		lsl.l   #3,d2
		lsl.l   #3,d3   ;got to mult em by 8..
	lea     line_clip_x1,a0
	movem.l d0-d3,(a0)      ;ok, changed the line draw clip window!

;right, we can get on with drawing the damned map now!
	move.l  gue_drawing_window_number,d7
	mulu    #12,d7
	lea     gue_scrollbar_x_data,a2
	lea     gue_scrollbar_y_data,a3
	add.l   d7,a2           ;get to right scrollydata
	add.l   d7,a3           ;get to right scrollydata

;ok, lets draw the sucker!
	lea     static_3d_world_points,a0
	lea     world_3d_line_data,a1
	move.l  number_3d_lines,d7
	sub.l   #1,d7                   ;get it right..
.line_loop
	movem.l (a1),d5-d6      ;point 1 to point 2

	lsl.l   #3,d5
	lsl.l   #3,d6   ;mult em by 8. access into tables..

	movem.l (a0,d5.l),d0-d1
	movem.l (a0,d6.l),d2-d3         ;coords..

	move.l  (a2),d4                 ;current x scrollvalue..
	sub.l   #1,d4   ;get it right
	mulu    #20,d4          ;mult it up..
	sub.l   d4,d1
	sub.l   d4,d3           ;move em left..
	
	move.l  (a3),d4                 ;current y scrollvalue
	sub.l   #1,d4   ;get it right
	mulu    #20,d4
	sub.l   d4,d0
	sub.l   d4,d2           ;move up down..

	lsr.l   #MAP_DIVIDE_VALUE,d0
	lsr.l   #MAP_DIVIDE_VALUE,d1
	lsr.l   #MAP_DIVIDE_VALUE,d2
	lsr.l   #MAP_DIVIDE_VALUE,d3

	move.l  gue_visible_x1,map_redraw_temp_x1
	move.l  gue_visible_x1,map_redraw_temp_x2
	move.l  gue_visible_y2,map_redraw_temp_y1
	move.l  gue_visible_y2,map_redraw_temp_y2
	sub.l   d0,map_redraw_temp_y1
	sub.l   d2,map_redraw_temp_y2
	add.l   d1,map_redraw_temp_x1
	add.l   d3,map_redraw_temp_x2

	cmp.l   #0,map_redraw_temp_x1
	blt     .skip_it
	cmp.l   #319,map_redraw_temp_x1
	bgt     .skip_it
	cmp.l   #0,map_redraw_temp_x2
	blt     .skip_it
	cmp.l   #319,map_redraw_temp_x2
	bgt     .skip_it

	cmp.l   #0,map_redraw_temp_y1
	blt     .skip_it
	cmp.l   #199,map_redraw_temp_y1
	bgt     .skip_it
	cmp.l   #0,map_redraw_temp_y2
	blt     .skip_it
	cmp.l   #199,map_redraw_temp_y2
	bgt     .skip_it

	;right, now draw the lines between each point..
	move.l  #3,ink_colour
	lea     map_redraw_temp_x1,a5
	movem.l (a5),d0-d3
	jsr     line_draw
.skip_it
	add.l   #16,a1
	dbf     d7,.line_loop

;*****************
	;ok, draw the small squares around each point.
	cmp.l   #NO,map_redraw_highlight_world_points
	beq     .no_highlight_world_points

	lea     static_3d_world_points,a0
	move.l  number_3d_world_points,d7
	sub.l   #1,d7                   ;get it right..
.point_loop
	move.l  (a0),d0
	move.l  4(a0),d1

	move.l  (a2),d4                 ;current x scrollvalue..
	sub.l   #1,d4   ;get it right
	mulu    #20,d4          ;mult it up..
	sub.l   d4,d1
	
	move.l  (a3),d4                 ;current y scrollvalue
	sub.l   #1,d4   ;get it right
	mulu    #20,d4
	sub.l   d4,d0

	lsr.l   #MAP_DIVIDE_VALUE,d0
	lsr.l   #MAP_DIVIDE_VALUE,d1

	move.l  gue_visible_x1,map_redraw_temp_x1
	move.l  gue_visible_y2,map_redraw_temp_y1
	sub.l   d0,map_redraw_temp_y1
	add.l   d1,map_redraw_temp_x1

	;right, done farting around, draw the square around the point!
	move.l  #1,ink_colour
	move.l  #2,map_redraw_small_box_size
	jsr     map_redraw_draw_little_square

	add.l   #8,a0           ;get to next point..
	dbf     d7,.point_loop
.no_highlight_world_points

;************************
	;ok, now draw the boxes around the aliens
	cmp.l   #NO,map_redraw_highlight_alien_points
	beq     .no_highlight_alien_points

	lea     static_alien_positions_and_textures,a0
	move.l  number_of_aliens_used,d7
	sub.l   #1,d7                   ;get it right..
.alien_loop
	move.l  (a0),d0
	move.l  4(a0),d1

	move.l  (a2),d4                 ;current x scrollvalue..
	sub.l   #1,d4   ;get it right
	mulu    #20,d4          ;mult it up..
	sub.l   d4,d1
	
	move.l  (a3),d4                 ;current y scrollvalue
	sub.l   #1,d4   ;get it right
	mulu    #20,d4
	sub.l   d4,d0

	lsr.l   #MAP_DIVIDE_VALUE,d0
	lsr.l   #MAP_DIVIDE_VALUE,d1

	move.l  gue_visible_x1,map_redraw_temp_x1
	move.l  gue_visible_y2,map_redraw_temp_y1
	sub.l   d0,map_redraw_temp_y1
	add.l   d1,map_redraw_temp_x1

	;right, done farting around, draw the square around the point!
	move.l  #1,ink_colour
	move.l  #2,map_redraw_small_box_size
	jsr     map_redraw_draw_little_square

	add.l   #12,a0          ;get to next point..
	dbf     d7,.alien_loop
.no_highlight_alien_points

;************************
	;ok, now draw the boxes around the pickups
	cmp.l   #NO,map_redraw_highlight_pickup_points
	beq     .no_highlight_pickup_points

	lea     pickup_static_data,a0
	move.l  #MAX_NUM_PICKUPS-1,d7
.pickup_loop
	cmp.l   #NO,12(a0)
	beq     .c_no_d

	move.l  4(a0),d0
	move.l  (a0),d1

	move.l  (a2),d4                 ;current x scrollvalue..
	sub.l   #1,d4   ;get it right
	mulu    #20,d4          ;mult it up..
	sub.l   d4,d1
	
	move.l  (a3),d4                 ;current y scrollvalue
	sub.l   #1,d4   ;get it right
	mulu    #20,d4
	sub.l   d4,d0

	lsr.l   #MAP_DIVIDE_VALUE,d0
	lsr.l   #MAP_DIVIDE_VALUE,d1

	move.l  gue_visible_x1,map_redraw_temp_x1
	move.l  gue_visible_y2,map_redraw_temp_y1
	sub.l   d0,map_redraw_temp_y1
	add.l   d1,map_redraw_temp_x1

	;right, done farting around, draw the square around the point!
	move.l  #2,ink_colour
	move.l  #2,map_redraw_small_box_size
	jsr     map_redraw_draw_little_square
.c_no_d
	lea     20(a0),a0               ;get to next point..
	dbf     d7,.pickup_loop
.no_highlight_pickup_points

;************************
	;ok, now draw the doors
	lea     static_door_data,a0
	move.l  num_doors_used,d7
	sub.l   #1,d7                   ;get it right..
.door_loop
	move.l  (a0),d1
	move.l  4(a0),d0
	move.l  8(a0),d3
	move.l  12(a0),d2

	move.l  (a2),d4                 ;current x scrollvalue..
	sub.l   #1,d4   ;get it right
	mulu    #20,d4          ;mult it up..
	sub.l   d4,d1
	sub.l   d4,d3
	
	move.l  (a3),d4                 ;current y scrollvalue
	sub.l   #1,d4   ;get it right
	mulu    #20,d4
	sub.l   d4,d0
	sub.l   d4,d2

	lsr.l   #MAP_DIVIDE_VALUE,d0
	lsr.l   #MAP_DIVIDE_VALUE,d1
	lsr.l   #MAP_DIVIDE_VALUE,d2
	lsr.l   #MAP_DIVIDE_VALUE,d3

	move.l  gue_visible_x1,map_redraw_temp_x1
	move.l  gue_visible_y2,map_redraw_temp_y1
	move.l  gue_visible_x1,map_redraw_temp_x2
	move.l  gue_visible_y2,map_redraw_temp_y2
	sub.l   d0,map_redraw_temp_y1
	add.l   d1,map_redraw_temp_x1
	sub.l   d2,map_redraw_temp_y2
	add.l   d3,map_redraw_temp_x2

	cmp.l   #0,map_redraw_temp_x1
	ble     .f_no
	cmp.l   #0,map_redraw_temp_x2
	ble     .f_no
	cmp.l   #0,map_redraw_temp_y1
	ble     .f_no
	cmp.l   #0,map_redraw_temp_y2
	ble     .f_no

	move.l  #6,ink_colour
	move.l  map_redraw_temp_x1,d0
	move.l  map_redraw_temp_y1,d1
	move.l  map_redraw_temp_x2,d2
	move.l  map_redraw_temp_y2,d3
	jsr     line_draw       


	cmp.l   #NO,map_redraw_highlight_door_points
	beq     .f_no
		move.l  #1,ink_colour
		move.l  #2,map_redraw_small_box_size
		jsr     map_redraw_draw_little_square
		move.l  map_redraw_temp_x2,map_redraw_temp_x1
		move.l  map_redraw_temp_y2,map_redraw_temp_y1
		jsr     map_redraw_draw_little_square
.f_no
	add.l   #28,a0          ;get to next point..
	dbf     d7,.door_loop

;************************
	;ok, now draw the switches
	lea     static_switch_position,a0
	move.l  num_doors_used,d7
	sub.l   #1,d7                   ;get it right..
.switch_loop
	move.l  (a0),d1
	move.l  4(a0),d0
	move.l  8(a0),d3
	move.l  12(a0),d2

	move.l  (a2),d4                 ;current x scrollvalue..
	sub.l   #1,d4   ;get it right
	mulu    #20,d4          ;mult it up..
	sub.l   d4,d1
	sub.l   d4,d3
	
	move.l  (a3),d4                 ;current y scrollvalue
	sub.l   #1,d4   ;get it right
	mulu    #20,d4
	sub.l   d4,d0
	sub.l   d4,d2

	lsr.l   #MAP_DIVIDE_VALUE,d0
	lsr.l   #MAP_DIVIDE_VALUE,d1
	lsr.l   #MAP_DIVIDE_VALUE,d2
	lsr.l   #MAP_DIVIDE_VALUE,d3

	move.l  gue_visible_x1,map_redraw_temp_x1
	move.l  gue_visible_y2,map_redraw_temp_y1
	move.l  gue_visible_x1,map_redraw_temp_x2
	move.l  gue_visible_y2,map_redraw_temp_y2
	sub.l   d0,map_redraw_temp_y1
	add.l   d1,map_redraw_temp_x1
	sub.l   d2,map_redraw_temp_y2
	add.l   d3,map_redraw_temp_x2

	cmp.l   #0,map_redraw_temp_x1
	ble     .g_no
	cmp.l   #0,map_redraw_temp_x2
	ble     .g_no
	cmp.l   #0,map_redraw_temp_y1
	ble     .g_no
	cmp.l   #0,map_redraw_temp_y2
	ble     .g_no

	move.l  #1,ink_colour
	move.l  map_redraw_temp_x1,d0
	move.l  map_redraw_temp_y1,d1
	move.l  map_redraw_temp_x2,d2
	move.l  map_redraw_temp_y2,d3
	jsr     line_draw       

	cmp.l   #NO,map_redraw_highlight_switch_points
	beq     .g_no
		move.l  #1,ink_colour
		move.l  #2,map_redraw_small_box_size
		jsr     map_redraw_draw_little_square
		move.l  map_redraw_temp_x2,map_redraw_temp_x1
		move.l  map_redraw_temp_y2,map_redraw_temp_y1
		jsr     map_redraw_draw_little_square
.g_no
	add.l   #32,a0          ;get to next point..
	dbf     d7,.switch_loop



	lea     map_redraw_temp_store_clip,a0
	movem.l (a0),d0-d3
	lea     line_clip_x1,a0
	movem.l d0-d3,(a0)                      ;get em back..

	movem.l (sp)+,d0-d7/a0-a6
	rts

map_redraw_draw_little_square
	move.l  map_redraw_temp_x1,d0
	move.l  map_redraw_temp_y1,d1
	cmp.l   #0,d0
	ble     .c_no__
	cmp.l   #0,d1
	ble     .c_no__
		move.l  d0,d2
		move.l  d1,d3
		add.l   #1,d2
		add.l   #1,d3
		jsr     line_draw       ;just draws a point..
.c_no__
	move.l  map_redraw_temp_x1,d0   ;do the top line of the box
	move.l  map_redraw_temp_y1,d1
	move.l  map_redraw_temp_x1,d2
	move.l  map_redraw_temp_y1,d3
		sub.l   map_redraw_small_box_size,d0
		sub.l   map_redraw_small_box_size,d1
		add.l   map_redraw_small_box_size,d2
		add.l   #1,d2
		sub.l   map_redraw_small_box_size,d3
	cmp.l   #0,d0
	ble     .c_no_a
	cmp.l   #0,d1
	ble     .c_no_a
	cmp.l   #0,d2
	ble     .c_no_a
	cmp.l   #0,d3
	ble     .c_no_a
		jsr     line_draw
.c_no_a
	move.l  map_redraw_temp_x1,d0   ;do the bottom line of the box
	move.l  map_redraw_temp_y1,d1
	move.l  map_redraw_temp_x1,d2
	move.l  map_redraw_temp_y1,d3
		sub.l   map_redraw_small_box_size,d0
		add.l   map_redraw_small_box_size,d1
		add.l   map_redraw_small_box_size,d2
		add.l   #1,d2
		add.l   map_redraw_small_box_size,d3
	cmp.l   #0,d0
	ble     .c_no_b
	cmp.l   #0,d1
	ble     .c_no_b
	cmp.l   #0,d2
	ble     .c_no_b
	cmp.l   #0,d3
	ble     .c_no_b
		jsr     line_draw
.c_no_b
	move.l  map_redraw_temp_x1,d0   ;do the left line of the box
	move.l  map_redraw_temp_y1,d1
	move.l  map_redraw_temp_x1,d2
	move.l  map_redraw_temp_y1,d3
		sub.l   map_redraw_small_box_size,d0
		sub.l   map_redraw_small_box_size,d1
		sub.l   map_redraw_small_box_size,d2
		add.l   map_redraw_small_box_size,d3
		add.l   #1,d3
	cmp.l   #0,d0
	ble     .c_no_c
	cmp.l   #0,d1
	ble     .c_no_c
	cmp.l   #0,d2
	ble     .c_no_c
	cmp.l   #0,d3
	ble     .c_no_c
		jsr     line_draw
.c_no_c
	move.l  map_redraw_temp_x1,d0   ;do the right line of the box
	move.l  map_redraw_temp_y1,d1
	move.l  map_redraw_temp_x1,d2
	move.l  map_redraw_temp_y1,d3
		add.l   map_redraw_small_box_size,d0
		sub.l   map_redraw_small_box_size,d1
		add.l   map_redraw_small_box_size,d2
		add.l   map_redraw_small_box_size,d3
		add.l   #1,d3
	cmp.l   #0,d0
	ble     .c_no_d
	cmp.l   #0,d1
	ble     .c_no_d
	cmp.l   #0,d2
	ble     .c_no_d
	cmp.l   #0,d3
	ble     .c_no_d
		jsr     line_draw
.c_no_d
	rts

	even
map_redraw_highlight_world_points       dc.l    NO
map_redraw_highlight_alien_points       dc.l    YES
map_redraw_highlight_pickup_points      dc.l    YES
map_redraw_highlight_door_points        dc.l    NO
map_redraw_highlight_switch_points      dc.l    NO
map_redraw_temp_store_clip      ds.l    4
map_redraw_small_box_size       dc.l    0
map_redraw_temp_x1              dc.l    0
map_redraw_temp_y1              dc.l    0
map_redraw_temp_x2              dc.l    0
map_redraw_temp_y2              dc.l    0
	even

highlight_redraw_window
	;sets the highlight  window buttons..

.aliens
	lea     gue_button_text_1,a0
	cmp.l   #YES,map_redraw_highlight_alien_points
	beq     .set_aliens
		move.b  #'f',10(a0)
		move.b  #'f',11(a0)
		bra     .pickups
.set_aliens
		move.b  #'n',10(a0)
		move.b  #0,11(a0)
.pickups
	lea     gue_button_text_2,a0
	cmp.l   #YES,map_redraw_highlight_pickup_points
	beq     .set_pickups
		move.b  #'f',11(a0)
		move.b  #'f',12(a0)
		bra     .wall_points
.set_pickups
		move.b  #'n',11(a0)
		move.b  #0,12(a0)
.wall_points
	lea     gue_button_text_3,a0
	cmp.l   #YES,map_redraw_highlight_world_points
	beq     .set_wall_points
		move.b  #'f',15(a0)
		move.b  #'f',16(a0)
		bra     .doors
.set_wall_points
		move.b  #'n',15(a0)
		move.b  #0,16(a0)
.doors
	lea     gue_button_text_4,a0
	cmp.l   #YES,map_redraw_highlight_door_points
	beq     .set_doors
		move.b  #'f',15(a0)
		move.b  #'f',16(a0)
		bra     .switch
.set_doors
		move.b  #'n',15(a0)
		move.b  #0,16(a0)
.switch
	lea     gue_button_text_5,a0
	cmp.l   #YES,map_redraw_highlight_switch_points
	beq     .set_switch
		move.b  #'f',17(a0)
		move.b  #'f',18(a0)
		bra     .out
.set_switch
		move.b  #'n',17(a0)
		move.b  #0,18(a0)
.out
	rts

highlight_button_alien_code
	cmp.l   #YES,map_redraw_highlight_alien_points
	beq     .turn_off
.turn_on
		move.l  #YES,map_redraw_highlight_alien_points
		bra     .out
.turn_off
		move.l  #NO,map_redraw_highlight_alien_points
.out
	rts
highlight_button_pickup_code
	cmp.l   #YES,map_redraw_highlight_pickup_points
	beq     .turn_off
.turn_on
		move.l  #YES,map_redraw_highlight_pickup_points
		bra     .out
.turn_off
		move.l  #NO,map_redraw_highlight_pickup_points
.out
	rts
highlight_button_world_code
	move.l  #NO,map_redraw_highlight_door_points
	move.l  #NO,map_redraw_highlight_switch_points
	cmp.l   #YES,map_redraw_highlight_world_points
	beq     .turn_off
.turn_on
		move.l  #YES,map_redraw_highlight_world_points
		bra     .out
.turn_off
		move.l  #NO,map_redraw_highlight_world_points
.out
	rts
highlight_button_door_code
	move.l  #NO,map_redraw_highlight_world_points
	move.l  #NO,map_redraw_highlight_switch_points
	cmp.l   #YES,map_redraw_highlight_door_points
	beq     .turn_off
.turn_on
		move.l  #YES,map_redraw_highlight_door_points
		bra     .out
.turn_off
		move.l  #NO,map_redraw_highlight_door_points
.out
	rts
highlight_button_switch_code
	move.l  #NO,map_redraw_highlight_world_points
	move.l  #NO,map_redraw_highlight_door_points
	cmp.l   #YES,map_redraw_highlight_switch_points
	beq     .turn_off
.turn_on
		move.l  #YES,map_redraw_highlight_switch_points
		bra     .out
.turn_off
		move.l  #NO,map_redraw_highlight_switch_points
.out
	rts


alien_object_window_redraw
	move.l  #7,d0
	jsr     gue_get_visible_window_pane

	move.l  #5,ink_colour
	move.l  gue_visible_x1,d0
	move.l  gue_visible_y1,d1       ;top left
	add.l   #1,d0
	add.l   #4,d1
	move.l  gue_visible_x2,d2
	move.l  gue_visible_y2,d3
	sub.l   #8,d2
	sub.l   #8,d3
	move.l  graphic_workscreen,a0
	lea     alien_object_window_text,a1
	jsr     print_text_varifont     

	rts
	even
alien_object_window_text
	dc.b    "Number",13,13
	dc.b    "X position",13
	dc.b    "Z position",13,13
	dc.b    "Health",13
	dc.b    "Still/Active",13
	dc.b    "Type",13

	dc.b    0
	even

**************************************************************************
** Gu-E 2.0a    (C) 1996 Digi Tallis                                    **
**                                                                      **
** all gue functions start with 'gue_' for ease of identification       **
** all gue data also starts with 'gue_'..                               **
**                                                                      **
** as long as you set up your data right, and set up the right          **
**      routines to call upon window refresh/scrolling and button       **
**      execution you don't have to worry about anything.. =]           **
**************************************************************************
				opt     o+,w-

GUE_MAX_NUM_WINDOWS             equ     10
GUE_MAX_NUM_BUTTONS             equ     20

GUE_TITLEBAR_Y_SIZE             equ     12
GUE_TITLEBAR_BUT_SIZE           equ     6       ;button sizes...

GUE_BUTTON_TYPE_FRONT           equ     0
GUE_BUTTON_TYPE_ICONIFY         equ     1
GUE_BUTTON_TYPE_DEICONIFY       equ     2
GUE_BUTTON_TYPE_MAXIMIZE        equ     3
GUE_BUTTON_TYPE_MINIMIZE        equ     4
GUE_BUTTON_TYPE_SCROLL_LEFT     equ     5
GUE_BUTTON_TYPE_SCROLL_RIGHT    equ     6
GUE_BUTTON_TYPE_SCROLL_UP       equ     7
GUE_BUTTON_TYPE_SCROLL_DOWN     equ     8
GUE_BUTTON_TYPE_SCROLL_SLIDER   equ     9

GUE_BUTTON_STATE_DOWN           equ     0
GUE_BUTTON_STATE_UP             equ     1

GUE_SCROLLBAR_Y_WIDTH           equ     6
GUE_SCROLLBAR_X_HEIGHT          equ     6

GUE_MIN_SCROLLBAR_SLIDER_SIZE   equ     4
GUE_PROPORT_MULU_VAL            equ     1000

GUE_ICONIFIED_WIDTH             equ     49
GUE_ICONIFIED_HEIGHT            equ     11

GUE_STATUSBAR_HEIGHT            equ     11

GUE_MENUBAR_HEIGHT              equ     9       ;how tall dude!?
GUE_MAX_NUM_MENUS               equ     10
GUE_MAX_NUM_MENU_ITEMS          equ     10
GUE_MENU_ENTRY_NORMAL           equ     0       ;a menu entry
GUE_MENU_ENTRY_MENU             equ     1       ;means another menu hangs off it
GUE_MENU_ENTRY_SEPERATOR        equ     2       ;ie ~~~~~~~~

GUE_MIN_WINDOW_WIDTH            equ     50
GUE_MIN_WINDOW_HEIGHT           equ     50

GUE_MAX_NUM_EDITBOXES           equ     5
GUE_EDITBOX_HEIGHT              equ     11
GUE_MAX_EDITBOX_STRING_LENGTH   equ     255

gue_convert_number_to_string
	;takes in       d0, number, 
	;               d1, length of text buffer
	;               a0, address of text buffer
;not written, sorry
;divide number by gue_conv_num_data (shown below)
;put resulting ascii char into string
;loop around until gue_conv_num_data is equal to -1
;remove all first 0's..
;hey presto, one string..
	rts

gue_conv_num_data
	dc.l    100000000
	dc.l    10000000
	dc.l    1000000
	dc.l    100000
	dc.l    10000
	dc.l    1000
	dc.l    100
	dc.l    10
	dc.l    1
	dc.l    -1      ;our terminator indicator

gue_control_loop
	;this is the sucker that handles the works..
	;ie, does the wait vbl. control mouse etc..
	;handles mouse clicks and code calling...

	;create the z order!
	jsr     gue_create_z_drawing_order
.do_loop
	move.l  #0,left_mouse
	move.l  #0,right_mouse

	jsr     wait_vbl
	
	jsr     mouse_stick_control     ;control mouse..

	jsr     gue_clear_old_mouse_pointer
	jsr     gue_draw_mouse_pointer

	cmp.l   #1,left_mouse
	bne     .no_mouse_click
;clear the mouse off the screen
	jsr     gue_clear_old_mouse_pointer
;ok, check to see if user clicked within an open window
		move.l  old_mouse_x,d0
		move.l  old_mouse_y,d1
		jsr     gue_get_open_window_event_happened_in
		cmp.l   #-1,gue_event_window
		beq     .done_open_window_stuff

		;right, check for pull to front button (the X)
.check_bring_front      
			lea     gue_window_data,a0
			move.l  gue_event_window,d0
			mulu    #88,d0
			add.l   d0,a0   ;get to right window data..

			cmp.l   #YES,24(a0)     ;is there a titlebar?
			bne     .check_up_scrollbar
					;no, skip it all...

			move.l  16(a0),d0
			move.l  12(a0),d1
			sub.l   #3,d0
			add.l   #3,d1
			move.l  d0,d2
			move.l  d1,d3
			sub.l   #GUE_TITLEBAR_BUT_SIZE,d0
			add.l   #GUE_TITLEBAR_BUT_SIZE,d3
;okey dokey. do the checks..
			cmp.l   old_mouse_x,d0
			bgt     .check_iconise
			cmp.l   old_mouse_x,d2
			blt     .check_iconise
			cmp.l   old_mouse_y,d1
			bgt     .check_iconise
			cmp.l   old_mouse_y,d3
			blt     .check_iconise

			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
				move.l  #GUE_BUTTON_TYPE_FRONT,d4
				move.l  #GUE_BUTTON_STATE_DOWN,d5
				jsr     gue_draw_graphic_button
			move.l  gue_temp_work_window,graphic_workscreen

		;done it, bring window to front
			move.l  gue_event_window,d0
			jsr     gue_bring_window_to_front       ;pull to front..
		;ok, redraw everything
			jsr     gue_draw_everything     ;draw it all!

			bra     .no_mouse_click ;ok, done it..
.check_iconise
			sub.l   #GUE_TITLEBAR_BUT_SIZE+2,d0
			sub.l   #GUE_TITLEBAR_BUT_SIZE+2,d2

			cmp.l   old_mouse_x,d0
			bgt     .check_titlebar_move
			cmp.l   old_mouse_x,d2
			blt     .check_titlebar_move
			cmp.l   old_mouse_y,d1
			bgt     .check_titlebar_move
			cmp.l   old_mouse_y,d3
			blt     .check_titlebar_move

			move.l  #GUE_BUTTON_TYPE_ICONIFY,d4
			move.l  #GUE_BUTTON_STATE_DOWN,d5
			jsr     gue_draw_graphic_button

		;make window iconised
			move.l  #NO,56(a0)      ;make it iconised!
		;pull window immeditely behind it to front..
			lea     gue_window_z_drawing_order,a1
			move.l  4(a1),d0
			jsr     gue_bring_window_to_front
		;draw the lot..
			move.l  gue_event_window,d0
			jsr     gue_draw_transition_from_iconised_to_open
			jsr     gue_draw_everything     ;draw it all!

			bra     .no_mouse_click ;ok, done it..
.check_titlebar_move
			move.l  8(a0),d0
				add.l   #2,d0
				sub.l   #1,d1
				add.l   #1,d3
			cmp.l   old_mouse_x,d0
			bgt     .check_up_scrollbar
			cmp.l   old_mouse_x,d2
			blt     .check_up_scrollbar
			cmp.l   old_mouse_y,d1
			bgt     .check_up_scrollbar
			cmp.l   old_mouse_y,d3
			blt     .check_up_scrollbar
				;ok, loop till no mouse..

			lea     gue_transition_x1,a1
			movem.l 8(a0),d0-d3
			movem.l d0-d3,(a1)      ;shove em quickly..
			move.l  old_mouse_x,d6
			move.l  old_mouse_y,d7
.titlebar_move_loop
			sub.l   old_mouse_x,d6
			sub.l   old_mouse_y,d7  ;get difference between 
					;old and current mouse pos..
			sub.l   d6,gue_transition_x1
			sub.l   d6,gue_transition_x2
			sub.l   d7,gue_transition_y1
			sub.l   d7,gue_transition_y2

			cmp.l   #1,gue_transition_x1
			bge     .move_x1_ok
				add.l   d6,gue_transition_x1
				add.l   d6,gue_transition_x2
.move_x1_ok
			cmp.l   #319,gue_transition_x2
			ble     .move_x2_ok
				add.l   d6,gue_transition_x1
				add.l   d6,gue_transition_x2
.move_x2_ok
			cmp.l   #0,gue_transition_y1
			bge     .move_y1_ok
				add.l   d7,gue_transition_y1
				add.l   d7,gue_transition_y2
.move_y1_ok
			cmp.l   #199,gue_transition_y2
			ble     .move_y2_ok
				add.l   d7,gue_transition_y1
				add.l   d7,gue_transition_y2
.move_y2_ok
			move.l  work,a0
			move.l  physic,a1
			jsr     gue_copy_one_screen_to_another  ;copy it back

			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
			move.l  #1,ink_colour                   
			move.l  gue_transition_x1,d0
			move.l  gue_transition_y1,d1
			move.l  gue_transition_x2,d2
			move.l  gue_transition_y1,d3
			move.l  gue_transition_x1,d4
			move.l  gue_transition_y2,d5
			move.l  gue_transition_x2,d6
			move.l  gue_transition_y2,d7
			jsr     polyline
			move.l  gue_temp_work_window,graphic_workscreen

			move.l  old_mouse_x,d6
			move.l  old_mouse_y,d7
			move.l  #0,left_mouse           ;clear it..
			movem.l d0-d7/a0-a6,-(sp)       ;stack it..
			jsr     wait_vbl
			movem.l (sp)+,d0-d7/a0-a6       ;unstack it..
			jsr     mouse_stick_control     ;control mouse..
			jsr     gue_draw_mouse_pointer
		
			cmp.l   #1,left_mouse
			beq     .titlebar_move_loop     ;still down..   

		;get the data back..
			lea     gue_window_data,a0
			move.l  gue_event_window,d0
			mulu    #88,d0
			add.l   d0,a0   ;get to right window data..

			lea     gue_transition_x1,a1
			movem.l (a1),d0-d3
			movem.l d0-d3,8(a0)             ;move the window..
			jsr     gue_draw_everything     ;draw it all!
		
			bra     .no_mouse_click
.check_up_scrollbar
		cmp.l   #YES,32(a0)
		bne     .check_left_scrollbar   ;no scrolly

		;get button coords
			move.l  16(a0),d0
			move.l  12(a0),d1
				add.l   #2,d1
				sub.l   #GUE_SCROLLBAR_Y_WIDTH+2,d0
.a_chk_title            cmp.l   #YES,24(a0)
			bne     .a_chk_menubar
				add.l   #GUE_TITLEBAR_BUT_SIZE+4,d1
.a_chk_menubar          cmp.l   #YES,80(a0)
			bne     .a_done_chks
				add.l   #GUE_MENUBAR_HEIGHT+2,d1
.a_done_chks            move.l  d0,d2
			move.l  d1,d3
				add.l   #GUE_SCROLLBAR_Y_WIDTH,d2
				add.l   #GUE_SCROLLBAR_Y_WIDTH,d3
		;lets check if we pressed it..
			cmp.l   old_mouse_x,d0
			bgt     .check_down_scrollbar
			cmp.l   old_mouse_x,d2
			blt     .check_down_scrollbar
			cmp.l   old_mouse_y,d1
			bgt     .check_down_scrollbar
			cmp.l   old_mouse_y,d3
			blt     .check_down_scrollbar
		;store em quickly..
			lea     gue_transition_x1,a5    ;safe to use
			movem.l d0-d3,(a5)              ;in they go..
		;ok, pressed it, push button in..
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
				move.l  #GUE_BUTTON_TYPE_SCROLL_UP,d4
				move.l  #GUE_BUTTON_STATE_DOWN,d5
				jsr     gue_draw_graphic_button
			move.l  gue_temp_work_window,graphic_workscreen
			jsr     gue_draw_mouse_pointer
	
.scroll_up_loop
			lea     gue_scrollbar_y_data,a4
			move.l  gue_drawing_window_number,d7
			mulu    #12,d7
			add.l   d7,a4           ;get to right scrollydata
			sub.l   #1,(a4)         ;decrease current pos..
			cmp.l   #1,(a4)         ;lets check for < 0
			bge     .scroll_up_ok
				move.l  #1,(a4) ;set it to zero
.scroll_up_ok
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
			move.l  48(a0),a4
			jsr     (a4)            ;call user def'd code!
			move.l  gue_temp_work_window,graphic_workscreen

			move.l  #0,left_mouse           ;clear it..
			movem.l d0-d7/a0-a6,-(sp)       ;stack it..
			jsr     wait_vbl
			movem.l (sp)+,d0-d7/a0-a6       ;unstack it..
			jsr     mouse_stick_control     ;control mouse..
		
			cmp.l   #1,left_mouse
			beq     .scroll_up_loop ;still down..   
			
		;get coords of button back out..
			lea     gue_transition_x1,a5    ;safe to use
			movem.l (a5),d0-d3              ;out they come..
		;ok, pull button out..
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
				move.l  #GUE_BUTTON_TYPE_SCROLL_UP,d4
				move.l  #GUE_BUTTON_STATE_UP,d5
				jsr     gue_draw_graphic_button
			move.l  gue_temp_work_window,graphic_workscreen

		;ok, redraw everything
			jsr     gue_draw_everything     ;draw it all!

			bra     .no_mouse_click         ;done it..
.check_down_scrollbar
		;get button coords
			move.l  16(a0),d0
			move.l  20(a0),d1
				sub.l   #GUE_SCROLLBAR_Y_WIDTH+2,d0
				sub.l   #GUE_SCROLLBAR_Y_WIDTH+2,d1
			move.l  d0,d2
			move.l  d1,d3
				add.l   #GUE_SCROLLBAR_Y_WIDTH,d2
				add.l   #GUE_SCROLLBAR_Y_WIDTH,d3
.b_chk_status           cmp.l   #YES,72(a0)
			bne     .b_chk_x_scrolly
				sub.l   #GUE_STATUSBAR_HEIGHT+2,d1
.b_chk_x_scrolly        cmp.l   #YES,28(a0)
			bne     .b_done_chks
				sub.l   #GUE_SCROLLBAR_X_HEIGHT+1,d1
.b_done_chks
			move.l  d0,d2
			move.l  d1,d3
				add.l   #GUE_SCROLLBAR_Y_WIDTH,d2
				add.l   #GUE_SCROLLBAR_Y_WIDTH,d3
		;lets check if we pressed it..
			cmp.l   old_mouse_x,d0
			bgt     .check_left_scrollbar
			cmp.l   old_mouse_x,d2
			blt     .check_left_scrollbar
			cmp.l   old_mouse_y,d1
			bgt     .check_left_scrollbar
			cmp.l   old_mouse_y,d3
			blt     .check_left_scrollbar
		;store em quickly..
			lea     gue_transition_x1,a5    ;safe to use
			movem.l d0-d3,(a5)              ;in they go..
		;ok, pressed it, push button in..
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
				move.l  #GUE_BUTTON_TYPE_SCROLL_DOWN,d4
				move.l  #GUE_BUTTON_STATE_DOWN,d5
				jsr     gue_draw_graphic_button
			move.l  gue_temp_work_window,graphic_workscreen
			jsr     gue_draw_mouse_pointer
.scroll_down_loop
			lea     gue_scrollbar_y_data,a4
			move.l  gue_drawing_window_number,d7
			mulu    #12,d7
			add.l   d7,a4           ;get to right scrollydata
			add.l   #1,(a4)         ;decrease current pos..
			move.l  4(a4),d7
			cmp.l   (a4),d7         ;lets check for > 'len'
			bgt     .scroll_down_ok
				move.l  d7,(a4) ;set it to 'len'
.scroll_down_ok
;                       move.l  52(a0),a4
;                       jsr     (a4)            ;call user def'd code!
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
			move.l  52(a0),a4
			jsr     (a4)            ;call user def'd code!
			move.l  gue_temp_work_window,graphic_workscreen

			move.l  #0,left_mouse           ;clear it..
			movem.l d0-d7/a0-a6,-(sp)       ;stack it..
			jsr     wait_vbl
			movem.l (sp)+,d0-d7/a0-a6       ;unstack it..
			jsr     mouse_stick_control     ;control mouse..
		
			cmp.l   #1,left_mouse
			beq     .scroll_down_loop       ;still down..   
			
		;get coords of button back out..
			lea     gue_transition_x1,a5    ;safe to use
			movem.l (a5),d0-d3              ;out they come..
		;ok, pull button out..
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
				move.l  #GUE_BUTTON_TYPE_SCROLL_DOWN,d4
				move.l  #GUE_BUTTON_STATE_UP,d5
				jsr     gue_draw_graphic_button
			move.l  gue_temp_work_window,graphic_workscreen

		;ok, redraw everything
			jsr     gue_draw_everything     ;draw it all!

			bra     .no_mouse_click         ;done it..
.check_left_scrollbar
		cmp.l   #YES,28(a0)
		bne     .check_resize_gadget    ;no scrolly
			;get coords
			move.l  8(a0),d0
			move.l  20(a0),d1
				add.l   #2,d0
				sub.l   #GUE_SCROLLBAR_X_HEIGHT+2,d1
.c_chk_statusbar        cmp.l   #YES,72(a0)
			bne     .c_no_statusbar
				sub.l   #GUE_STATUSBAR_HEIGHT+2,d1
.c_no_statusbar
			move.l  d0,d2
			move.l  d1,d3
				add.l   #GUE_SCROLLBAR_X_HEIGHT,d2
				add.l   #GUE_SCROLLBAR_X_HEIGHT,d3
		;lets check if we pressed it..
			cmp.l   old_mouse_x,d0
			bgt     .check_right_scrollbar
			cmp.l   old_mouse_x,d2
			blt     .check_right_scrollbar
			cmp.l   old_mouse_y,d1
			bgt     .check_right_scrollbar
			cmp.l   old_mouse_y,d3
			blt     .check_right_scrollbar
		;store em quickly..
			lea     gue_transition_x1,a5    ;safe to use
			movem.l d0-d3,(a5)              ;in they go..
		;ok, pressed it, push button in..
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
				move.l  #GUE_BUTTON_TYPE_SCROLL_LEFT,d4
				move.l  #GUE_BUTTON_STATE_DOWN,d5
				jsr     gue_draw_graphic_button
			move.l  gue_temp_work_window,graphic_workscreen
			jsr     gue_draw_mouse_pointer
.scroll_left_loop
			lea     gue_scrollbar_x_data,a4
			move.l  gue_drawing_window_number,d7
			mulu    #12,d7
			add.l   d7,a4           ;get to right scrollydata
			sub.l   #1,(a4)         ;decrease current pos..
			cmp.l   #1,(a4)         ;lets check for < 0
			bge     .scroll_left_ok
				move.l  #1,(a4) ;set it to zero
.scroll_left_ok
;                       move.l  40(a0),a4
;                       jsr     (a4)            ;call user def'd code!
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
			move.l  40(a0),a4
			jsr     (a4)            ;call user def'd code!
			move.l  gue_temp_work_window,graphic_workscreen

			move.l  #0,left_mouse           ;clear it..
			movem.l d0-d7/a0-a6,-(sp)       ;stack it..
			jsr     wait_vbl
			movem.l (sp)+,d0-d7/a0-a6       ;unstack it..
			jsr     mouse_stick_control     ;control mouse..
		
			cmp.l   #1,left_mouse
			beq     .scroll_left_loop       ;still down..   
			
		;get coords of button back out..
			lea     gue_transition_x1,a5    ;safe to use
			movem.l (a5),d0-d3              ;out they come..
		;ok, pull button out..
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
				move.l  #GUE_BUTTON_TYPE_SCROLL_LEFT,d4
				move.l  #GUE_BUTTON_STATE_UP,d5
				jsr     gue_draw_graphic_button
			move.l  gue_temp_work_window,graphic_workscreen

		;ok, redraw everything
			jsr     gue_draw_everything     ;draw it all!

			bra     .no_mouse_click         ;done it..
.check_right_scrollbar
			;get coords
			move.l  16(a0),d0
			move.l  20(a0),d1
				sub.l   #GUE_SCROLLBAR_Y_WIDTH+2,d0
				sub.l   #GUE_SCROLLBAR_X_HEIGHT+2,d1
.d_chk_y_scrolly        cmp.l   #YES,32(a0)
			bne     .d_chk_statusbar
				sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d0
.d_chk_statusbar        cmp.l   #YES,72(a0)
			bne     .d_no_statusbar
				sub.l   #GUE_STATUSBAR_HEIGHT+2,d1
.d_no_statusbar
			move.l  d0,d2
			move.l  d1,d3
				add.l   #GUE_SCROLLBAR_X_HEIGHT,d2
				add.l   #GUE_SCROLLBAR_X_HEIGHT,d3
		;lets check if we pressed it..
			cmp.l   old_mouse_x,d0
			bgt     .check_resize_gadget
			cmp.l   old_mouse_x,d2
			blt     .check_resize_gadget
			cmp.l   old_mouse_y,d1
			bgt     .check_resize_gadget
			cmp.l   old_mouse_y,d3
			blt     .check_resize_gadget
		;store em quickly..
			lea     gue_transition_x1,a5    ;safe to use
			movem.l d0-d3,(a5)              ;in they go..
		;ok, pressed it, push button in..
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
				move.l  #GUE_BUTTON_TYPE_SCROLL_RIGHT,d4
				move.l  #GUE_BUTTON_STATE_DOWN,d5
				jsr     gue_draw_graphic_button
			move.l  gue_temp_work_window,graphic_workscreen
			jsr     gue_draw_mouse_pointer
.scroll_right_loop
			lea     gue_scrollbar_x_data,a4
			move.l  gue_drawing_window_number,d7
			mulu    #12,d7
			add.l   d7,a4           ;get to right scrollydata
			add.l   #1,(a4)         ;decrease current pos..
			move.l  4(a4),d7
			cmp.l   (a4),d7         ;lets check for > 'len'
			bgt     .scroll_right_ok
				move.l  d7,(a4) ;set it to 'len'
.scroll_right_ok
;                       move.l  44(a0),a4
;                       jsr     (a4)            ;call user def'd code!
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
			move.l  44(a0),a4
			jsr     (a4)            ;call user def'd code!
			move.l  gue_temp_work_window,graphic_workscreen

			move.l  #0,left_mouse           ;clear it..
			movem.l d0-d7/a0-a6,-(sp)       ;stack it..
			jsr     wait_vbl
			movem.l (sp)+,d0-d7/a0-a6       ;unstack it..
			jsr     mouse_stick_control     ;control mouse..
		
			cmp.l   #1,left_mouse
			beq     .scroll_right_loop      ;still down..   
			
		;get coords of button back out..
			lea     gue_transition_x1,a5    ;safe to use
			movem.l (a5),d0-d3              ;out they come..
		;ok, pull button out..
			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
				move.l  #GUE_BUTTON_TYPE_SCROLL_RIGHT,d4
				move.l  #GUE_BUTTON_STATE_UP,d5
				jsr     gue_draw_graphic_button
			move.l  gue_temp_work_window,graphic_workscreen

		;ok, redraw everything
			jsr     gue_draw_everything     ;draw it all!

			bra     .no_mouse_click         ;done it..
.check_resize_gadget
		cmp.l   #YES,72(a0)     ;is there a statusbar?!
		bne     .check_menubar

			move.l  16(a0),d0
			move.l  20(a0),d1
				sub.l   #GUE_SCROLLBAR_Y_WIDTH,d0
				sub.l   #GUE_SCROLLBAR_Y_WIDTH,d1
			move.l  16(a0),d2
			move.l  20(a0),d3

			cmp.l   old_mouse_x,d0
			bgt     .check_menubar
			cmp.l   old_mouse_x,d2
			blt     .check_menubar
			cmp.l   old_mouse_y,d1
			bgt     .check_menubar
			cmp.l   old_mouse_y,d3
			blt     .check_menubar
				;ok, loop till no mouse..

			lea     gue_transition_x1,a1
			movem.l 8(a0),d0-d3
			movem.l d0-d3,(a1)      ;shove em quickly..
			move.l  old_mouse_x,d6
			move.l  old_mouse_y,d7
.resize_loop
			sub.l   old_mouse_x,d6
			sub.l   old_mouse_y,d7  ;get difference between 
					;old and current mouse pos..
			sub.l   d6,gue_transition_x2
			sub.l   d7,gue_transition_y2

			move.l  gue_transition_x1,d4
			move.l  gue_transition_y1,d5
				add.l   #GUE_MIN_WINDOW_WIDTH,d4
				add.l   #GUE_MIN_WINDOW_HEIGHT,d5

			cmp.l   gue_transition_x2,d4
			ble     .resize_x2_ok_1
				add.l   d6,gue_transition_x2
.resize_x2_ok_1
			cmp.l   #319,gue_transition_x2
			ble     .resize_x2_ok_2
				add.l   d6,gue_transition_x2
.resize_x2_ok_2

			cmp.l   gue_transition_y2,d5
			ble     .resize_y2_ok_1
				add.l   d7,gue_transition_y2
.resize_y2_ok_1
			cmp.l   #199,gue_transition_y2
			ble     .resize_y2_ok_2
				add.l   d7,gue_transition_y2
.resize_y2_ok_2
			move.l  work,a0
			move.l  physic,a1
			jsr     gue_copy_one_screen_to_another  ;copy it back

			move.l  graphic_workscreen,gue_temp_work_window
			move.l  physic,graphic_workscreen
			move.l  #1,ink_colour                   
			move.l  gue_transition_x1,d0
			move.l  gue_transition_y1,d1
			move.l  gue_transition_x2,d2
			move.l  gue_transition_y1,d3
			move.l  gue_transition_x1,d4
			move.l  gue_transition_y2,d5
			move.l  gue_transition_x2,d6
			move.l  gue_transition_y2,d7
			jsr     polyline
			move.l  gue_temp_work_window,graphic_workscreen

			move.l  old_mouse_x,d6
			move.l  old_mouse_y,d7
			move.l  #0,left_mouse           ;clear it..
			movem.l d0-d7/a0-a6,-(sp)       ;stack it..
			jsr     wait_vbl
			movem.l (sp)+,d0-d7/a0-a6       ;unstack it..
			jsr     mouse_stick_control     ;control mouse..
			jsr     gue_draw_mouse_pointer
		
			cmp.l   #1,left_mouse
			beq     .resize_loop    ;still down..   

		;get the data back..
			lea     gue_window_data,a0
			move.l  gue_event_window,d0
			mulu    #88,d0
			add.l   d0,a0   ;get to right window data..

			lea     gue_transition_x1,a1
			movem.l (a1),d0-d3
			movem.l d0-d3,8(a0)             ;move the window..
			jsr     gue_draw_everything     ;draw it all!
		
			bra     .no_mouse_click
.check_menubar

;not written 'cos I didn't get time to write the menubar code!
;well, some of it is there, so I'll try and provide pointers as to the 
;odd logic I was going under.. =]

.check_buttons_within_windows
			move.l  gue_event_window,d0
			jsr     gue_call_code_button_clicked_upon_in_window

			bra     .no_mouse_click
.done_open_window_stuff         ;now lets check iconised!!
		move.l  old_mouse_x,d0
		move.l  old_mouse_y,d1
		jsr     gue_get_closed_window_event_happened_in
		cmp.l   #-1,gue_event_window
		beq     .check_buttons_not_in_windows

		;make window visible
			move.l  gue_event_window,d0
			mulu    #88,d0
			lea     gue_window_data,a0
			move.l  #YES,56(a0,d0.l)        ;make it visible!
		;pull to front
			move.l  gue_event_window,d0
			jsr     gue_bring_window_to_front       ;pull to front..
		;draw the lot..
			move.l  gue_event_window,d0
			jsr     gue_draw_transition_from_iconised_to_open
			jsr     gue_draw_everything     ;draw it all!

			bra     .no_mouse_click ;ok, done it..
.check_buttons_not_in_windows

;not written, theres quite a lot that isn't!

.no_mouse_click

	bra     .do_loop
	rts

gue_draw_everything
	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	jsr     clear_workscreen

	move.l  work,graphic_workscreen         ;set where to draw!
	jsr     gue_draw_all_visible_buttons_not_attached_to_a_window
	jsr     gue_draw_all_iconifed_windows
	jsr     gue_draw_all_open_windows       

	move.l  work,a0
	move.l  physic,a1
	jsr     gue_copy_one_screen_to_another  ;copy it back
	move.l  physic,graphic_workscreen

	movem.l (sp)+,d0-d7/a0-a6       ;unstack em
	rts

gue_clear_old_mouse_pointer
	movem.l d0-d7/a0-a6,-(sp)       

	move.l  old_mouse_x,d0
	move.l  old_mouse_y,d1
	lea     gue_mouse_offset_table,a0
	lea     mulu_160_table,a1
	lsl.l   #2,d0
	lsl.l   #2,d1   ;mult by 4..
	move.l  (a0,d0.l),d2
	add.l   (a1,d1.l),d2

	move.l  work,a0
	move.l  physic,a1

	rept    8
		move.l  (a0,d2.l),(a1,d2.l)
		move.l  4(a0,d2.l),4(a1,d2.l)
		move.l  8(a0,d2.l),8(a1,d2.l)
		move.l  12(a0,d2.l),12(a1,d2.l)
	add.l   #160,d2
	endr
		
	movem.l (sp)+,d0-d7/a0-a6
	rts
gue_draw_mouse_pointer
	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	move.l  #1,ink_colour
	move.l  mouse_x,d0
	move.l  mouse_y,d1
	move.l  mouse_x,d2
		add.l   #80,d2
	move.l  mouse_y,d3
	move.l  physic,a0
	lea     gue_mouse_pointer_text,a1
	jsr     print_text_varifont     

	move.l  d0,old_mouse_x  ;do this here otherwise in the 
	move.l  d1,old_mouse_y  ;small amount of time between
				;exiting this rout and putting mouse_x
				;etc into old_mouse_x, mouse_x CAN
				;change! hence visual screwups!
	movem.l (sp)+,d0-d7/a0-a6
	rts

	even
gue_mouse_pointer_text  dc.b    "€",0   ;this character in the proportional
					;font, just happens to be a pointer..
	even
gue_mouse_offset_table
i       set     0
	rept    40
	dc.l    i,i,i,i,i,i,i,i,i,i,i,i,i,i,i,i
i       set     i+8
	endr
	even
	
gue_copy_one_screen_to_another
	;takes in a0,a1, address of where to copy FROM and where TO.
	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	move.l  #8000-1,d0
.loop
	move.l  (a0)+,(a1)+
	dbf     d0,.loop
	
	movem.l (sp)+,d0-d7/a0-a6       ;unstack em
	rts

gue_copy_portion_of_one_screen_to_another
	;takes in d0,d1,d2,d3   x1,y1,x2,y2
	;and a0,a1, thats SOURCE, DEST

	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	cmp.l   #304,d2
	blt     .x_ok
		move.l  #304,d2
.x_ok

	lsr.l   #4,d0
	lsr.l   #4,d2   ;divide em down by 16
	lsl.l   #3,d0
	lsl.l   #3,d2   ;mult em back by 8..

	move.l  d1,d7
	mulu    #160,d7
	add.l   d7,a0
	add.l   d7,a1   ;get down the screen..

	move.l  d3,d7
	sub.l   d1,d7   ;thats how many times down screen..
.y_loop
		move.l  d2,d6
		sub.l   d0,d6   ;how many across..
		lsr.l   #3,d6   ;divide it by 8..
		move.l  d0,d5   ;a temp pointer
.x_loop
			move.l  (a0,d5.l),(a1,d5.l)
			move.l  4(a0,d5.l),4(a1,d5.l)
			add.l   #8,d5   
		dbf     d6,.x_loop

		add.l   #160,a0
		add.l   #160,a1 ;down both screens
	dbf     d7,.y_loop

	movem.l (sp)+,d0-d7/a0-a6       ;unstack em
	rts

gue_draw_all_iconifed_windows
	lea     gue_window_data,a0
	moveq.l #0,d0
	move.l  #GUE_MAX_NUM_WINDOWS-1,d7
.loop
	cmp.l   #YES,(a0)       ;is it used?
	bne     .not_used
		cmp.l   #YES,56(a0)
		beq     .not_used
.its_iconified
		move.l  d0,d6           ;store it...

		move.l  60(a0),d0       ;x
		move.l  64(a0),d1       ;y
		move.l  d0,d2
		move.l  d1,d3
		add.l   #GUE_ICONIFIED_WIDTH,d2
		add.l   #GUE_ICONIFIED_HEIGHT,d3
		move.l  #GUE_BUTTON_STATE_UP,d4
		move.l  68(a0),d5               ;wheres the text!
		jsr     gue_draw_iconised_window
			;takes in d0,d1,d2,d3 (x1,y1,x2,y2)
			;d4 = state, UP or DOWN.. like 0,1
			;d5 = address of text to print..
		
		move.l  d6,d0           ;get it back..
.not_used
	addq.l  #1,d0   ;next window please..
	add.l   #88,a0
	dbra    d7,.loop
	rts     


gue_draw_all_open_windows
	lea     gue_window_data,a0
	lea     gue_window_z_drawing_order,a1
	add.l   #(GUE_MAX_NUM_WINDOWS-1)*4,a1   ;get to end
	move.l  #GUE_MAX_NUM_WINDOWS-1,d7       
.loop
	move.l  (a1),d0 ;the window number..
	cmp.l   #-1,d0
	beq     .not_used       ;oh dear, no window..
	move.l  d0,d6   ;store
	mulu    #88,d6  ;mult it right, gets past old win data
	

	cmp.l   #YES,(a0,d6.l)  ;is it used?
	bne     .not_used
		cmp.l   #YES,56(a0,d6.l)
		bne     .not_used
.its_visible
		jsr     gue_draw_window ;does everything!
.not_used
	sub.l   #4,a1   ;go back in z buffer..
	dbra    d7,.loop
	rts

gue_create_z_drawing_order
	lea     gue_window_data,a0
	lea     gue_window_z_drawing_order,a1
	move.l  #0,d6
	move.l  #GUE_MAX_NUM_WINDOWS-1,d7       
.loop
	cmp.l   #YES,(a0)
	bne     .skip
		move.l  d6,(a1)+
.skip
	add.l   #1,d6
	add.l   #88,a0          
	dbf     d7,.loop
	rts

	even
gue_event_window                dc.l    0       ;which win did event happen in!?
gue_window_at_front             dc.l    NO      ;yes or no.. 
gue_window_z_drawing_order
	dc.l    0,1,2,3,4,5,6,7                 ;works backwards..
	rept    GUE_MAX_NUM_WINDOWS+1   ;ie, num at front is win at front!
	dc.l    -1              ;signifies not used...
	endr
gue_temp_window_z_drawing_order_buffer
	rept    GUE_MAX_NUM_WINDOWS+1
	dc.l    -1                      ;used when we bring a window
	endr                            ;to the front..
	even
gue_temp_work_window    dc.l    0
gue_transition_x1       dc.l    0
gue_transition_y1       dc.l    0
gue_transition_x2       dc.l    0
gue_transition_y2       dc.l    0
gue_transition_x3       dc.l    0
gue_transition_y3       dc.l    0
gue_transition_x4       dc.l    0
gue_transition_y4       dc.l    0
	even

gue_draw_transition_from_iconised_to_open
	;takes in d0.. the window number
	;basically, draw the expanding line version..

	movem.l d0-d7/a0-a6,-(sp)

	lea     gue_window_data,a1
	mulu    #88,d0
	add.l   d0,a1           ;get to right window data

	movem.l 8(a1),d0-d3                     ;open window coords..

	move.l  60(a1),d4       ;x
	move.l  64(a1),d5       ;y
	move.l  d4,d6
	move.l  d5,d7
	add.l   #GUE_ICONIFIED_WIDTH,d6
	add.l   #GUE_ICONIFIED_HEIGHT,d7        ;closed window coords

	move.l  graphic_workscreen,gue_temp_work_window
	move.l  physic,graphic_workscreen

	move.l  #1,ink_colour

	lea     gue_transition_x1,a0
	movem.l d0-d7,(a0)              ;store em quickly..

	move.l  gue_transition_x1,d0
	move.l  gue_transition_y1,d1
	move.l  gue_transition_x2,d2
	move.l  gue_transition_y1,d3
	move.l  gue_transition_x1,d4
	move.l  gue_transition_y2,d5
	move.l  gue_transition_x2,d6
	move.l  gue_transition_y2,d7
	jsr     polyline

	move.l  gue_transition_x3,d0
	move.l  gue_transition_y3,d1
	move.l  gue_transition_x4,d2
	move.l  gue_transition_y3,d3
	move.l  gue_transition_x3,d4
	move.l  gue_transition_y4,d5
	move.l  gue_transition_x4,d6
	move.l  gue_transition_y4,d7
	jsr     polyline

	move.l  gue_transition_x1,d0
	move.l  gue_transition_y1,d1
	move.l  gue_transition_x3,d2
	move.l  gue_transition_y3,d3
	jsr     line_draw

	move.l  gue_transition_x2,d0
	move.l  gue_transition_y1,d1
	move.l  gue_transition_x4,d2
	move.l  gue_transition_y3,d3
	jsr     line_draw

	move.l  gue_transition_x1,d0
	move.l  gue_transition_y2,d1
	move.l  gue_transition_x3,d2
	move.l  gue_transition_y4,d3
	jsr     line_draw

	move.l  gue_transition_x2,d0
	move.l  gue_transition_y2,d1
	move.l  gue_transition_x4,d2
	move.l  gue_transition_y4,d3
	jsr     line_draw

	move.l  gue_temp_work_window,graphic_workscreen
	movem.l (sp)+,d0-d7/a0-a6
	rts

gue_get_closed_window_event_happened_in
	;takes in d0,d1 ie x,y.. 
	;uses the z drawing order and returns the number of the
	;window the x,y are in...
	;used to figure out raising of windows etc..
	move.l  #-1,gue_event_window    ;no window event at all!

	lea     gue_window_z_drawing_order,a0
	lea     gue_window_data,a1
	move.l  #GUE_MAX_NUM_WINDOWS-1,d7
.loop
	cmp.l   #-1,(a0)
	beq     .skip_it
		move.l  (a0),d6 ;window number
		mulu    #88,d6
		cmp.l   #YES,(a1,d6.l)          ;is it a used window?
		bne     .skip_it
		cmp.l   #YES,56(a1,d6.l)        ;is it visible?!
		beq     .skip_it                ;yes it is!
.its_iconised
		move.l  60(a1,d6.l),d2  ;x
		move.l  64(a1,d6.l),d3  ;y
		move.l  d2,d4
		move.l  d3,d5
		add.l   #GUE_ICONIFIED_WIDTH,d4
		add.l   #GUE_ICONIFIED_HEIGHT,d5
	
		cmp.l   d2,d0
		blt     .skip_it
		cmp.l   d4,d0
		bgt     .skip_it                
		cmp.l   d3,d1
		blt     .skip_it
		cmp.l   d5,d1
		bgt     .skip_it                

		divu    #88,d6          ;divide it down
		move.l  d6,gue_event_window     ;store it..
		bra     .quit           ;get the hell out..
.skip_it
	add.l   #4,a0
	dbf     d7,.loop
.quit
	rts

gue_get_open_window_event_happened_in
	;takes in d0,d1 ie x,y.. 
	;uses the z drawing order and returns the number of the
	;window the x,y are in...
	;used to figure out raising of windows etc..
	move.l  #-1,gue_event_window    ;no window event at all!

	lea     gue_window_z_drawing_order,a0
	lea     gue_window_data,a1
	move.l  #GUE_MAX_NUM_WINDOWS-1,d7
.loop
	cmp.l   #-1,(a0)
	beq     .skip_it
		move.l  (a0),d6 ;window number
		mulu    #88,d6
		cmp.l   #YES,(a1,d6.l)          ;is it a used window?
		bne     .skip_it
		cmp.l   #YES,56(a1,d6.l)        ;is it visible?!
		bne     .skip_it                ;no its not..
.its_visible
		cmp.l   8(a1,d6.l),d0
		blt     .skip_it
		cmp.l   16(a1,d6.l),d0
		bgt     .skip_it                
		cmp.l   12(a1,d6.l),d1
		blt     .skip_it
		cmp.l   20(a1,d6.l),d1
		bgt     .skip_it                
	
		divu    #88,d6          ;divide it down
		move.l  d6,gue_event_window     ;store it..
		bra     .quit           ;get the hell out..
.skip_it
	add.l   #4,a0
	dbf     d7,.loop
.quit
	rts

gue_is_window_at_front
	;takes in d0, the window number
	movem.l d0-d7/a0-a6,-(sp)
	lea     gue_window_z_drawing_order,a0
	move.l  #NO,gue_window_at_front
	cmp.l   (a0),d0         ;first window!
	bne     .done_check
		move.l  #YES,gue_window_at_front
.done_check
	movem.l (sp)+,d0-d7/a0-a6
	rts

gue_bring_window_to_front
	;takes in d0, the window number
	;it simply moves that to the front of the z drawing order..
	;whilst moving everything down to accomodate the change..
	;don't think this routine is perfect, it may need recoding
	movem.l d0-d7/a0-a6,-(sp)
	lea     gue_window_z_drawing_order,a0
	lea     gue_temp_window_z_drawing_order_buffer,a1
	move.l  #GUE_MAX_NUM_WINDOWS-1,d7
	move.l  d0,(a1)+
.loop
	cmp.l   (a0),d0
	beq     .skip_this
		move.l  (a0),(a1)+
.skip_this
	add.l   #4,a0
	dbf     d7,.loop

	lea     gue_window_z_drawing_order,a0
	lea     gue_temp_window_z_drawing_order_buffer,a1
	move.l  #GUE_MAX_NUM_WINDOWS-1,d7
.loop2
	move.l  (a1)+,(a0)+
	dbf     d7,.loop2       ;ok, copy em back..
	movem.l (sp)+,d0-d7/a0-a6
	rts

gue_draw_window
	;takes in d0 as the number of the window to draw..
	movem.l d0-d7/a0-a6,-(sp)       ;stack em..
	
	move.l  d0,gue_drawing_window_number

	lea     gue_window_data,a2
	mulu    #88,d0          ;get to an offset..
	add.l   d0,a2           ;step into the bank..

.draw_windowback
		;draw the solid bar
	move.l  #2,ink_colour
	move.l  8(a2),d0
	move.l  12(a2),d1       ;top left
	move.l  16(a2),d2
	move.l  12(a2),d3       ;top right
	move.l  8(a2),d4
	move.l  20(a2),d5       ;bottom left
	move.l  16(a2),d6
	move.l  20(a2),d7       ;bottom right
	jsr     polygon

		;now draw the top line of the 3d effect..               
	move.l  #1,ink_colour
	move.l  8(a2),d0
	move.l  12(a2),d1       ;top left
	move.l  16(a2),d2
	move.l  12(a2),d3       ;top right
	jsr     line_draw

		;now draw the left line of the 3d effect..              
	move.l  #1,ink_colour
	move.l  8(a2),d0
	move.l  12(a2),d1       ;top left
	move.l  8(a2),d2
	move.l  20(a2),d3       ;top right
	jsr     line_draw

		;now draw the bottom line of the 3d effect..            
	move.l  #3,ink_colour
	move.l  8(a2),d0
	move.l  20(a2),d1       ;top left
	move.l  16(a2),d2
	move.l  20(a2),d3       ;top right
	jsr     line_draw

		;now draw the right line of the 3d effect..             
	move.l  #3,ink_colour
	move.l  16(a2),d0
	move.l  12(a2),d1       ;top left
	move.l  16(a2),d2
	move.l  20(a2),d3       ;top right
	add.l   #1,d3
	jsr     line_draw

.draw_titlebar
		;check if there is a titlebar!
	cmp.l   #YES,24(a2)
	bne     .draw_menubar           ;skip the titlebar dude!

		;draw the blue bar inside it. gives a 95 feel..
	move.l  #4,ink_colour           ;red for at front..
	move.l  gue_drawing_window_number,d0
	jsr     gue_is_window_at_front
	cmp.l   #YES,gue_window_at_front
	beq     .ok_draw_titlebar_background
		move.l  #4,ink_colour           ;used to be 6.. a pinky..
.ok_draw_titlebar_background                    ;but the zorder code don't work!
	move.l  8(a2),d0
	add.l   #2,d0
	move.l  12(a2),d1       ;top left
	add.l   #2,d1
	move.l  16(a2),d2
	sub.l   #2,d2
	move.l  12(a2),d3       ;top right
	add.l   #2,d3
	move.l  8(a2),d4
	add.l   #2,d4
	move.l  12(a2),d5       ;bottom left
	add.l   #GUE_TITLEBAR_Y_SIZE-2,d5
	move.l  16(a2),d6
	sub.l   #2,d6
	move.l  12(a2),d7       ;bottom right
	add.l   #GUE_TITLEBAR_Y_SIZE-2,d7
	jsr     polygon

.draw_quit_button
		;ok, draw the quit window button..
	move.l  16(a2),d0
	move.l  12(a2),d1
	sub.l   #3,d0
	add.l   #3,d1
	move.l  d0,d2
	move.l  d1,d3
	sub.l   #GUE_TITLEBAR_BUT_SIZE,d0
	add.l   #GUE_TITLEBAR_BUT_SIZE,d3
	move.l  #GUE_BUTTON_TYPE_FRONT,d4
	move.l  #GUE_BUTTON_STATE_UP,d5
	jsr     gue_draw_graphic_button

.draw_iconify
	sub.l   #GUE_TITLEBAR_BUT_SIZE+2,d0
	sub.l   #GUE_TITLEBAR_BUT_SIZE+2,d2
	move.l  #GUE_BUTTON_TYPE_ICONIFY,d4
	move.l  #GUE_BUTTON_STATE_UP,d5
	jsr     gue_draw_graphic_button
	

.print_title
	move.l  #1,ink_colour
	move.l  8(a2),d0
	add.l   #3,d0
	move.l  12(a2),d1       ;top left
	add.l   #3,d1

	move.l  gue_titlebar_but_x1,d2  ;length of visible titlebar
	sub.l   #8,d2
	move.l  d1,d3
	move.l  graphic_workscreen,a0
	move.l  4(a2),a1
	jsr     print_text_varifont     


.draw_menubar
	cmp.l   #YES,80(a2)
	bne     .draw_y_scrollbar
		;ok, draw the bar and the menu....
	move.l  #3,ink_colour
	move.l  8(a2),d0
	move.l  12(a2),d1       ;top left
	move.l  16(a2),d2
	move.l  12(a2),d3       ;top right
		add.l   #2,d0
		sub.l   #2,d2
	
		cmp.l   #YES,24(a2)
		bne     .draw_menubar_background
			add.l   #GUE_TITLEBAR_Y_SIZE-2,d1
.draw_menubar_background                                
	add.l   #2,d1

	move.l  d0,d4   
	move.l  d2,d6
	move.l  d1,d3
	move.l  d1,d5
		add.l   #GUE_MENUBAR_HEIGHT,d5
	move.l  d5,d7
		jsr     polygon

	lea     gue_menubar_data,a3
	lea     gue_menu_entry_data,a4
	move.l  84(a2),d7       ;what menubar_data are we using?
	mulu    #11*4,d7        ;get past all the others..
	add.l   d7,a3
	cmp.l   #YES,(a3)
	bne     .draw_y_scrollbar       ;this menubar data isn't used!
		add.l   #4,a3   ;get past used flag
		add.l   #3,d0   ;across one..
		add.l   #1,d1   ;down one too..
		move.l  #1,ink_colour
		move.l  #GUE_MAX_NUM_MENU_ITEMS-1,d7
.menu_draw_loop
		move.l  (a3)+,d6        ;which menu item does it point to?!
		mulu    #14*4,d6        ;skip shit data
		cmp.l   #YES,(a4,d6.l)  ;is the menu entry used?!
		bne     .next_menu_item
			move.l  d1,d3
			move.l  graphic_workscreen,a0
			move.l  12(a4,d6.l),a1
			jsr     print_text_varifont     

			jsr     get_varifont_text_length
			add.l   vari_text_len,d0
			add.l   #4,d0           ;leave a gap!                                           
.next_menu_item
		dbf     d7,.menu_draw_loop
	


.draw_y_scrollbar
	cmp.l   #NO,32(a2)
	beq     .draw_x_scrollbar       ;there is no y scrolly!

	move.l  16(a2),d0
	move.l  12(a2),d1
		add.l   #2,d1
	sub.l   #GUE_SCROLLBAR_Y_WIDTH+2,d0
	move.l  d0,d2
		add.l   #GUE_SCROLLBAR_Y_WIDTH,d2
	move.l  20(a2),d3
	sub.l   #2,d3

.check_titlebar
	cmp.l   #YES,24(a2)     ;is there a titlebar?
	bne     .check_x_scrolly
		add.l   #GUE_TITLEBAR_BUT_SIZE+4,d1
.check_x_scrolly
	cmp.l   #YES,28(a2)
	bne     .check_statusbar
		sub.l   #GUE_SCROLLBAR_X_HEIGHT+1,d3
.check_statusbar
	cmp.l   #YES,72(a2)
	bne     .check_menubar
		sub.l   #GUE_STATUSBAR_HEIGHT+2,d3
.check_menubar
	cmp.l   #YES,80(a2)
	bne     .done_checks
		add.l   #GUE_MENUBAR_HEIGHT+2,d1
.done_checks
	jsr     gue_draw_y_scrollbar


.draw_x_scrollbar
	cmp.l   #NO,28(a2)
	beq     .draw_statusbar ;there is no x scrolly!

	move.l  8(a2),d0
	move.l  20(a2),d1
	move.l  16(a2),d2
	move.l  20(a2),d3
		add.l   #2,d0
		sub.l   #GUE_SCROLLBAR_X_HEIGHT+2,d1
		sub.l   #2,d2
		sub.l   #2,d3

	cmp.l   #YES,32(a2)
	bne     .no_y_scrollbar
		sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d2
.no_y_scrollbar
	cmp.l   #YES,72(a2)
	bne     .no_statusbar_2
		sub.l   #GUE_STATUSBAR_HEIGHT+2,d3
		sub.l   #GUE_STATUSBAR_HEIGHT+2,d1
.no_statusbar_2
	jsr     gue_draw_x_scrollbar

.draw_statusbar
	cmp.l   #YES,72(a2)
	bne     .draw_window_pane
		move.l  #3,ink_colour
		move.l  8(a2),d0
		move.l  20(a2),d1
		move.l  16(a2),d2
		add.l   #1,d0
		sub.l   #GUE_STATUSBAR_HEIGHT+2,d1
		sub.l   #1,d2
			sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d2
		move.l  d1,d3
		jsr     line_draw

		move.l  d0,d2
		move.l  20(a2),d3
		sub.l   #2,d3
		jsr     line_draw

		move.l  #1,ink_colour
		move.l  16(a2),d0
		sub.l   #2,d0
			sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d0
		move.l  d0,d2
		jsr     line_draw

		move.l  d3,d1
		move.l  8(a2),d0
		add.l   #1,d0
		add.l   #1,d2
		jsr     line_draw

		move.l  #5,ink_colour   ;ok, draw the text now
		move.l  8(a2),d0
		move.l  20(a2),d1
		move.l  16(a2),d2
			sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d2
		move.l  20(a2),d3
		add.l   #3,d0
		sub.l   #8+2,d2
		sub.l   #GUE_STATUSBAR_HEIGHT,d1
		sub.l   #8+2,d3         ;allows text wrap messages
		move.l  graphic_workscreen,a0
		move.l  76(a2),a1
		jsr     print_text_varifont     

;ok, draw the resize gadget..
		move.l  16(a2),d0
			sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d0
		move.l  20(a2),d1
			sub.l   #2,d1
		move.l  16(a2),d2
			sub.l   #1,d2
		move.l  20(a2),d3
			sub.l   #GUE_SCROLLBAR_Y_WIDTH+2,d3

		move.l  #5,ink_colour
		jsr     line_draw

			add.l   #1,d0
			add.l   #1,d3
		move.l  #1,ink_colour
		jsr     line_draw

			add.l   #2,d0
			add.l   #2,d3
		move.l  #5,ink_colour
		jsr     line_draw

			add.l   #1,d0
			add.l   #1,d3
		move.l  #1,ink_colour
		jsr     line_draw

.draw_window_pane
	move.l  gue_drawing_window_number,d0
	jsr     gue_get_visible_window_pane

	move.l  #3,ink_colour
	move.l  gue_visible_x1,d0
	move.l  gue_visible_y1,d1
	move.l  gue_visible_x2,d2
	move.l  gue_visible_y1,d3
		sub.l   #1,d0
		sub.l   #1,d1
		add.l   #1,d2
		sub.l   #1,d3
	jsr     line_draw

	move.l  #3,ink_colour
	move.l  gue_visible_x1,d0
	move.l  gue_visible_y1,d1
	move.l  gue_visible_x1,d2
	move.l  gue_visible_y2,d3
		sub.l   #1,d0
		sub.l   #1,d1
		sub.l   #1,d2
		add.l   #1,d3
	jsr     line_draw

	move.l  #1,ink_colour
	move.l  gue_visible_x1,d0
	move.l  gue_visible_y2,d1
	move.l  gue_visible_x2,d2
	move.l  gue_visible_y2,d3
		sub.l   #1,d0
		add.l   #1,d1
		add.l   #1,d2
		add.l   #1,d3
	jsr     line_draw

	move.l  #1,ink_colour
	move.l  gue_visible_x2,d0
	move.l  gue_visible_y1,d1
	move.l  gue_visible_x2,d2
	move.l  gue_visible_y2,d3
		add.l   #1,d0
		sub.l   #1,d1
		add.l   #1,d2
		add.l   #2,d3
	jsr     line_draw

;       move.l  gue_drawing_window_number,d0
;       move.l  #6,d1   ;the ink to clear pane with!
;       jsr     gue_cls_visible_window_pane


;right, call the user defined window drawing code..
	movem.l d0-d7/a0-a6,-(sp)       ;stack em
		move.l  36(a2),a1
		jsr     (a1)
	movem.l (sp)+,d0-d7/a0-a6

;now draw all editboxes within the window
	move.l  gue_drawing_window_number,d0
	jsr     gue_draw_editboxes_associated_with_window

;ok, draw the buttons associated with the window..
	move.l  gue_drawing_window_number,d0
	jsr     gue_draw_all_visible_buttons_attached_to_a_window

;copy it to the background screen. thats always invisible.. =]
	move.l  graphic_workscreen,a0
	move.l  work,a1
	movem.l 8(a2),d0-d3
	jsr     gue_copy_portion_of_one_screen_to_another
			;takes in d0,d1,d2,d3   x1,y1,x2,y2
			;and a0,a1, thats SOURCE, DEST

;ok, quit this crazy thing..
	movem.l (sp)+,d0-d7/a0-a6       ;unstack em
	rts


	even
gue_menu_title_1        dc.b    "File",0
gue_menu_title_2        dc.b    "Edit",0
gue_standard_menu_title dc.b    "<unused>",0
	even

gue_menubar_data
	dc.l    YES
	dc.l    0,1,2,2,2,2,2,2,2,2

;the real data
	rept    GUE_MAX_NUM_MENUS
	dc.l    NO                      ;used?
	ds.l    GUE_MAX_NUM_MENU_ITEMS  ;each of these points to a
					;menu item.. 
	endr
gue_menu_entry_data
;first one
	dc.l    YES                     ;0
	dc.l    GUE_MENU_ENTRY_MENU     ;4
	dc.l    0                       ;8
	dc.l    gue_menu_title_1        ;12
	dc.l    1,1,1,1,1,1,1,1,1,1     ;16

;second one
	dc.l    YES                     ;0
	dc.l    GUE_MENU_ENTRY_MENU     ;4
	dc.l    0                       ;8
	dc.l    gue_menu_title_2        ;12
	dc.l    1,1,1,1,1,1,1,1,1,1     ;16

;the real data..
	rept    GUE_MAX_NUM_MENUS*GUE_MAX_NUM_MENU_ITEMS
	dc.l    NO                      ;menu slot used??       ;0
	dc.l    GUE_MENU_ENTRY_NORMAL   ;type of menu entry..   ;4
	dc.l    0                       ;address of code to call;8
					;if its a normal entry..
	dc.l    gue_standard_menu_title ;address of text to be  ;12
					;printed
	ds.l    GUE_MAX_NUM_MENU_ITEMS  ;each of these points to;16
					;a menu item (menu_data)
			;this way we can do recursive menus...
	endr
	even

********************
** gue edit boxes. very similar to doze
** they are always attached to a window. you can't have em floating
**      on the desktop!!
********************

gue_draw_editboxes_associated_with_window
	;takes in d0, the window number..
	movem.l d0-d7/a0-a6,-(sp)

	move.l  d0,d6                   ;move it over
	lea     gue_editbox_data,a2
	lea     gue_window_data,a3
	mulu    #88,d0          ;get to an offset..
	add.l   d0,a3           ;step into the bank..
	move.l  #GUE_MAX_NUM_EDITBOXES-1,d7
.loop
	cmp.l   #YES,(a2)               ;is it used first of all?
	bne     .skip                   ;oh dear, its not
		cmp.l   4(a2),d6        ;is it in this window
		bne     .skip           ;oh dear. bad luck..

			movem.l 8(a2),d0-d1             ;x,y
			movem.l 8(a2),d2-d3             ;for width,height
			add.l   16(a2),d2               ;width
			add.l   20(a2),d3       ;the height                     

			add.l   8(a3),d0
			add.l   12(a3),d1       
			add.l   8(a3),d2        ;add on the window coords
			add.l   12(a3),d3       ;and away we go..

			lea     gue_editbox_draw_x1,a4
			movem.l d0-d3,(a4)      ;shove em quickly

			move.l  #1,ink_colour           
			move.l  gue_editbox_draw_x1,d0
			move.l  gue_editbox_draw_y1,d1  ;top left
			move.l  gue_editbox_draw_x2,d2
			move.l  gue_editbox_draw_y1,d3  ;top right
			move.l  gue_editbox_draw_x1,d4
			move.l  gue_editbox_draw_y2,d5  ;bottom left
			move.l  gue_editbox_draw_x2,d6
			move.l  gue_editbox_draw_y2,d7  ;bottom right
			jsr     polygon                 

			move.l  #3,ink_colour
			move.l  gue_editbox_draw_x1,d0
			move.l  gue_editbox_draw_y1,d1
			move.l  gue_editbox_draw_x2,d2
			move.l  gue_editbox_draw_y1,d3
			jsr     line_draw
			move.l  gue_editbox_draw_x1,d0
			move.l  gue_editbox_draw_y1,d1
			move.l  gue_editbox_draw_x1,d2
			move.l  gue_editbox_draw_y2,d3
			jsr     line_draw

			movem.l d0-d7/a0-a6,-(sp)
				move.l  #5,ink_colour
				move.l  gue_editbox_draw_x1,d0
				move.l  gue_editbox_draw_y1,d1  ;top left
				add.l   #2,d0
				add.l   #2,d1
				move.l  gue_editbox_draw_x2,d2
				move.l  gue_editbox_draw_y2,d3
				sub.l   #8,d2
				sub.l   #8,d3
				move.l  graphic_workscreen,a0
				move.l  24(a2),a1
				jsr     print_text_varifont     
			movem.l (sp)+,d0-d7/a0-a6

	;draw the cursor 32(a2)
.skip
	lea     36(a2),a2
	dbf     d7,.loop

	movem.l (sp)+,d0-d7/a0-a6
	rts

	even
;all editbox strings are GUE_MAX_EDITBOX_STRING_LENGTH long, 
;regardless of how much of it is actually taken up. 
;because it doesn't use malloc and free, some corners have to
;be cut somewhere.. =]

gue_editbox_text_1      dc.b    "10"
			ds.b    GUE_MAX_EDITBOX_STRING_LENGTH
gue_editbox_text_2      ds.b    GUE_MAX_EDITBOX_STRING_LENGTH

gue_editbox_standard_text       dc.b    "Gu-E 2.0a",0
	even
gue_editbox_draw_x1     dc.l    0
gue_editbox_draw_y1     dc.l    0
gue_editbox_draw_x2     dc.l    0
gue_editbox_draw_y2     dc.l    0

gue_editbox_data
;the alien number in the alter alien data window
	dc.l    YES     ;is it used?                            ; 0
	dc.l    7       ;number of window it is in              ; 4
	dc.l    54      ;x in window                            ; 8
	dc.l    14      ;y in window                            ; 12
	dc.l    50      ;width of editbox                       ; 16
	dc.l    GUE_EDITBOX_HEIGHT      ;height!                ; 20
	dc.l    gue_editbox_text_1      ;the text in the editbox        ; 24
	dc.l    YES     ;editing it? yes then draw cursor       ; 28
	dc.l    0       ;cursor pos in text                     ; 32

	rept    GUE_MAX_NUM_EDITBOXES
	dc.l    NO
	ds.l    5
	dc.l    gue_editbox_standard_text
	dc.l    NO
	dc.l    0
	endr

	even

******************************************************
******************************************************

gue_cls_visible_window_pane
	;takes in d0 = window to clear
	;d1 = colour to clear it with!
	movem.l d0-d7/a0-a6,-(sp)

	jsr     gue_get_visible_window_pane

	move.l  d1,ink_colour
	move.l  gue_visible_x1,d0
	move.l  gue_visible_y1,d1
	move.l  gue_visible_x2,d2
	move.l  gue_visible_y1,d3
	move.l  gue_visible_x1,d4
	move.l  gue_visible_y2,d5
	move.l  gue_visible_x2,d6
	move.l  gue_visible_y2,d7
	jsr     polygon

	movem.l (sp)+,d0-d7/a0-a6
	rts

gue_get_visible_window_pane
	;takes in d0.. ie, get the window pane for THAT window!
	movem.l d0-d7/a0-a6,-(sp)

	lea     gue_window_data,a2
	mulu    #88,d0          ;get to an offset..
	add.l   d0,a2           ;step into the bank..

	movem.l 8(a2),d0-d3     ;x1,y1,x2,z2
	add.l   #3,d0
	add.l   #3,d1
	sub.l   #3,d2
	sub.l   #3,d3

	cmp.l   #YES,24(a2)
	bne     .no_titlebar
		add.l   #GUE_TITLEBAR_BUT_SIZE+4,d1
.no_titlebar
	cmp.l   #YES,28(a2)
	bne     .no_x_scrollbar
		sub.l   #GUE_SCROLLBAR_X_HEIGHT+2,d3
.no_x_scrollbar
	cmp.l   #YES,32(a2)
	bne     .no_y_scrollbar
		sub.l   #GUE_SCROLLBAR_Y_WIDTH+2,d2
.no_y_scrollbar
	cmp.l   #YES,72(a2)
	bne     .no_statusbar
		sub.l   #GUE_STATUSBAR_HEIGHT+2,d3
.no_statusbar
	cmp.l   #YES,80(a2)
	bne     .no_menubar
		add.l   #GUE_MENUBAR_HEIGHT+2,d1
.no_menubar

	lea     gue_visible_x1,a0
	movem.l d0-d3,(a0)

	movem.l (sp)+,d0-d7/a0-a6
	rts


gue_draw_x_scrollbar
	;takes in d0,d1,d2,d3 (x1,y1,x2,y2)

	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	lea     gue_scrollbar_but_x1,a0
	movem.l d0-d3,(a0)              ;shove em in quick..

		;ok, draw the blank button..
	move.l  #5,ink_colour
	move.l  gue_scrollbar_but_x1,d0
	move.l  gue_scrollbar_but_y1,d1 ;top left
	move.l  gue_scrollbar_but_x2,d2
	move.l  gue_scrollbar_but_y1,d3 ;top right
	move.l  gue_scrollbar_but_x1,d4
	move.l  gue_scrollbar_but_y2,d5 ;bot left
	move.l  gue_scrollbar_but_x2,d6
	move.l  gue_scrollbar_but_y2,d7 ;bot right
	jsr     polygon

		;draw the buttons
	move.l  gue_scrollbar_but_x1,d0
	move.l  gue_scrollbar_but_y1,d1 ;top left
	move.l  d0,d2
	move.l  d1,d3
	add.l   #GUE_SCROLLBAR_X_HEIGHT,d2
	add.l   #GUE_SCROLLBAR_X_HEIGHT,d3
	move.l  #GUE_BUTTON_TYPE_SCROLL_LEFT,d4
	move.l  #GUE_BUTTON_STATE_UP,d5
	jsr     gue_draw_graphic_button

	move.l  gue_scrollbar_but_x2,d0
	move.l  gue_scrollbar_but_y1,d1 ;top left
	move.l  gue_scrollbar_but_x2,d2
	move.l  gue_scrollbar_but_y2,d3
	sub.l   #GUE_SCROLLBAR_X_HEIGHT,d0
	move.l  #GUE_BUTTON_TYPE_SCROLL_RIGHT,d4
	move.l  #GUE_BUTTON_STATE_UP,d5
	jsr     gue_draw_graphic_button

	lea     gue_scrollbar_x_data,a1
	move.l  gue_drawing_window_number,d7
	mulu    #12,d7
	add.l   d7,a1

;get distance between scroll buttons..
;subtract a minimum scroller size off that..
;divide result by length of data scrolly covers.. 4(a1)
;mult by current scrolly pos 0(a1)
;       thats where you start to draw the scrolly slider..

	move.l  gue_scrollbar_but_y1,d6
	add.l   #GUE_SCROLLBAR_Y_WIDTH+1,d6
	move.l  gue_scrollbar_but_y2,d7
	sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d7
		mulu    #GUE_PROPORT_MULU_VAL,d6
		mulu    #GUE_PROPORT_MULU_VAL,d7
	sub.l   d6,d7                   ;d7 = ok, thats the distance!
	sub.l   #GUE_MIN_SCROLLBAR_SLIDER_SIZE*GUE_PROPORT_MULU_VAL,d7
					;take off minimum
	move.l  4(a1),d6
		mulu    #GUE_PROPORT_MULU_VAL,d6        ;mulu it
	divu    d6,d7           ;divided by length of scroller
	move.l  (a1),d6
		mulu    #GUE_PROPORT_MULU_VAL,d6        ;mulu it
	mulu    d6,d7           ;mult by current scroll pos
		divu    #GUE_PROPORT_MULU_VAL,d7        ;divide it down..

;get distance between scrollbuttons
;subtract a minimum scrolly size off that
;divide result by length scrolly covers - current pos
;mulu this by amount window covers..
;add on the minimum.. hey presto...
;       thats how big scrolly is!

	move.l  gue_scrollbar_but_y1,d5
	add.l   #GUE_SCROLLBAR_Y_WIDTH+1,d5
	move.l  gue_scrollbar_but_y2,d6
	sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d6
		mulu    #GUE_PROPORT_MULU_VAL,d5
		mulu    #GUE_PROPORT_MULU_VAL,d6
	sub.l   d5,d6                   ;d6 = ok, thats the distance!
	sub.l   #GUE_MIN_SCROLLBAR_SLIDER_SIZE*GUE_PROPORT_MULU_VAL,d6  
					;take off minimum
		move.l  4(a1),d5
		move.l  (a1),d4
		mulu    #GUE_PROPORT_MULU_VAL,d5
		mulu    #GUE_PROPORT_MULU_VAL,d4
		sub.l   d4,d5           ;length - current pos
		divu    d5,d6   ;divide it to get steps..

		move.l  8(a1),d5
		mulu    #GUE_PROPORT_MULU_VAL,d5
		mulu    d5,d6           ;mult by amount window covers

		divu    #GUE_PROPORT_MULU_VAL,d6
		add.l   #GUE_MIN_SCROLLBAR_SLIDER_SIZE+1,d6
	

	move.l  gue_scrollbar_but_x1,d0
	move.l  gue_scrollbar_but_y1,d1
	add.l   #GUE_SCROLLBAR_Y_WIDTH+1,d1
	move.l  gue_scrollbar_but_x2,d2
	move.l  #GUE_BUTTON_TYPE_SCROLL_SLIDER,d4
	move.l  #GUE_BUTTON_STATE_UP,d5

;       move.l  d1,d3
;       add.l   d7,d1           ;add on pos..
;       move.l  d1,d3
;       add.l   d6,d3   ;taken out cos the proportional code don't work
	move.l  gue_scrollbar_but_y2,d3
	sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d3

;       jsr     gue_draw_graphic_button

	movem.l (sp)+,d0-d7/a0-a6       ;unstack em
	rts

gue_draw_y_scrollbar
	;takes in d0,d1,d2,d3 (x1,y1,x2,y2)

	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	lea     gue_scrollbar_but_x1,a0
	movem.l d0-d3,(a0)              ;shove em in quick..

		;ok, draw the blank button..
	move.l  #5,ink_colour
	move.l  gue_scrollbar_but_x1,d0
	move.l  gue_scrollbar_but_y1,d1 ;top left
	move.l  gue_scrollbar_but_x2,d2
	move.l  gue_scrollbar_but_y1,d3 ;top right
	move.l  gue_scrollbar_but_x1,d4
	move.l  gue_scrollbar_but_y2,d5 ;bot left
	move.l  gue_scrollbar_but_x2,d6
	move.l  gue_scrollbar_but_y2,d7 ;bot right
	jsr     polygon

		;draw the buttons
	move.l  gue_scrollbar_but_x1,d0
	move.l  gue_scrollbar_but_y1,d1 ;top left
	move.l  d0,d2
	move.l  d1,d3
	add.l   #GUE_SCROLLBAR_Y_WIDTH,d2
	add.l   #GUE_SCROLLBAR_Y_WIDTH,d3
	move.l  #GUE_BUTTON_TYPE_SCROLL_UP,d4
	move.l  #GUE_BUTTON_STATE_UP,d5
	jsr     gue_draw_graphic_button

	move.l  gue_scrollbar_but_x1,d0
	move.l  gue_scrollbar_but_y2,d1 ;top left
	move.l  d0,d2
	move.l  d1,d3
	add.l   #GUE_SCROLLBAR_Y_WIDTH,d2
	sub.l   #GUE_SCROLLBAR_Y_WIDTH,d1
	move.l  #GUE_BUTTON_TYPE_SCROLL_DOWN,d4
	move.l  #GUE_BUTTON_STATE_UP,d5
	jsr     gue_draw_graphic_button

	lea     gue_scrollbar_y_data,a1
	move.l  gue_drawing_window_number,d7
	mulu    #12,d7
	add.l   d7,a1

;get distance between scroll buttons..
;subtract a minimum scroller size off that..
;divide result by length of data scrolly covers.. 4(a1)
;mult by current scrolly pos 0(a1)
;       thats where you start to draw the scrolly slider..

	move.l  gue_scrollbar_but_y1,d6
	add.l   #GUE_SCROLLBAR_Y_WIDTH+1,d6
	move.l  gue_scrollbar_but_y2,d7
	sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d7
		mulu    #GUE_PROPORT_MULU_VAL,d6
		mulu    #GUE_PROPORT_MULU_VAL,d7
	sub.l   d6,d7                   ;d7 = ok, thats the distance!
	sub.l   #GUE_MIN_SCROLLBAR_SLIDER_SIZE*GUE_PROPORT_MULU_VAL,d7
					;take off minimum
	move.l  4(a1),d6
		mulu    #GUE_PROPORT_MULU_VAL,d6        ;mulu it
	divu    d6,d7           ;divided by length of scroller
	move.l  (a1),d6
		mulu    #GUE_PROPORT_MULU_VAL,d6        ;mulu it
	mulu    d6,d7           ;mult by current scroll pos
		divu    #GUE_PROPORT_MULU_VAL,d7        ;divide it down..

;get distance between scrollbuttons
;subtract a minimum scrolly size off that
;divide result by length scrolly covers - current pos
;mulu this by amount window covers..
;add on the minimum.. hey presto...
;       thats how big scrolly is!

	move.l  gue_scrollbar_but_y1,d5
	add.l   #GUE_SCROLLBAR_Y_WIDTH+1,d5
	move.l  gue_scrollbar_but_y2,d6
	sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d6
		mulu    #GUE_PROPORT_MULU_VAL,d5
		mulu    #GUE_PROPORT_MULU_VAL,d6
	sub.l   d5,d6                   ;d6 = ok, thats the distance!
	sub.l   #GUE_MIN_SCROLLBAR_SLIDER_SIZE*GUE_PROPORT_MULU_VAL,d6  
					;take off minimum
		move.l  4(a1),d5
		move.l  (a1),d4
		mulu    #GUE_PROPORT_MULU_VAL,d5
		mulu    #GUE_PROPORT_MULU_VAL,d4
		sub.l   d4,d5           ;length - current pos
		divu    d5,d6   ;divide it to get steps..

		move.l  8(a1),d5
		mulu    #GUE_PROPORT_MULU_VAL,d5
		mulu    d5,d6           ;mult by amount window covers

		divu    #GUE_PROPORT_MULU_VAL,d6
		add.l   #GUE_MIN_SCROLLBAR_SLIDER_SIZE+1,d6
	

	move.l  gue_scrollbar_but_x1,d0
	move.l  gue_scrollbar_but_y1,d1
	add.l   #GUE_SCROLLBAR_Y_WIDTH+1,d1
	move.l  gue_scrollbar_but_x2,d2
	move.l  #GUE_BUTTON_TYPE_SCROLL_SLIDER,d4
	move.l  #GUE_BUTTON_STATE_UP,d5

;       move.l  d1,d3
;       add.l   d7,d1           ;add on pos..
;       move.l  d1,d3
;       add.l   d6,d3   ;taken out cos the proportional code don't work
	move.l  gue_scrollbar_but_y2,d3
	sub.l   #GUE_SCROLLBAR_Y_WIDTH+1,d3

;       jsr     gue_draw_graphic_button

	movem.l (sp)+,d0-d7/a0-a6       ;unstack em
	rts



gue_draw_iconised_window
	;takes in d0,d1,d2,d3 (x1,y1,x2,y2)
	;d4 = state, UP or DOWN.. like 0,1
	;d5 = address of text to print..

	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	lea     gue_button_but_x1,a0
	movem.l d0-d5,(a0)              ;shove em in quick..

		;ok, draw the blank button..
	move.l  #2,ink_colour
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y1,d1    ;top left
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y1,d3    ;top right
	move.l  gue_button_but_x1,d4
	move.l  gue_button_but_y2,d5    ;bot left
	move.l  gue_button_but_x2,d6
	move.l  gue_button_but_y2,d7    ;bot right
	jsr     polygon

		;ok, top line of 3d
	cmp.l   #GUE_BUTTON_STATE_UP,gue_button_but_state
	beq     .button_up_1
		move.l  #3,ink_colour
		bra     .draw_but_1
.button_up_1
		move.l  #1,ink_colour
.draw_but_1
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y1,d1    ;top left
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y1,d3    ;top right
	jsr     line_draw

		;ok, left line of 3d
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y1,d1    ;top left
	move.l  gue_button_but_x1,d2
	move.l  gue_button_but_y2,d3    ;bot left
	jsr     line_draw

		;ok, bottom line of 3d
	cmp.l   #GUE_BUTTON_STATE_UP,gue_button_but_state
	beq     .button_up_2
		move.l  #1,ink_colour
		bra     .draw_but_2
.button_up_2
		move.l  #3,ink_colour
.draw_but_2
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y2,d1    ;bot left
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y2,d3    ;bot right
	add.l   #1,d2
	jsr     line_draw

		;ok, right line of 3d
	move.l  gue_button_but_x2,d0
	move.l  gue_button_but_y1,d1    ;top left
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y2,d3    ;bot left
	jsr     line_draw

.print_title
	move.l  #1000,d2
	move.l  #0,d3   ;where to wrap downwards..      
;d2,d3
	move.l  gue_button_but_text,a1
	jsr     get_varifont_text_length        ;get its len in pixels!
	move.l  vari_text_len,d2
	lsr.l   #1,d2   ;divide by two..

	move.l  gue_button_but_x2,d1
	move.l  gue_button_but_x1,d0
;       sub.l   #GUE_ICONIFIED_HEIGHT+2,d1
	sub.l   #GUE_ICONIFIED_HEIGHT,d1
	sub.l   d0,d1   ;gets len in pixels of available button
	lsr.l   #1,d1   ;divide it by two..

	add.l   d1,d0   ;step across to middle of visible button
	sub.l   d2,d0   ;go backwards....

	move.l  gue_button_but_x1,d2
	add.l   #2,d2   ;make it get past the 3d effect..
	cmp.l   d0,d2
	blt     .ok_done_center 
		move.l  gue_button_but_x1,d0
		add.l   #2,d0
.ok_done_center
	move.l  #5,ink_colour
	move.l  gue_button_but_y1,d1    ;top left
	add.l   #2,d1

	move.l  gue_button_but_x2,d2    ;length of visible titlebar
	sub.l   #2,d2
;       sub.l   #GUE_ICONIFIED_HEIGHT+6,d2
	sub.l   #GUE_ICONIFIED_HEIGHT,d2
	move.l  d1,d3
	move.l  graphic_workscreen,a0
	move.l  gue_button_but_text,a1
	jsr     print_text_varifont     


	move.l  gue_button_but_x2,d0
		sub.l   #GUE_ICONIFIED_HEIGHT-2,d0
	move.l  gue_button_but_y1,d1
		add.l   #2,d1
	move.l  gue_button_but_x2,d2
		sub.l   #2,d2
	move.l  gue_button_but_y2,d3
		sub.l   #2,d3
	move.l  #GUE_BUTTON_TYPE_DEICONIFY,d4
	move.l  gue_button_but_state,d5 
			;so when press button, this goes in too..
	jsr     gue_draw_graphic_button

;copy it to the background screen..
	move.l  graphic_workscreen,a0
	move.l  work,a1
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y1,d1
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y2,d3
	jsr     gue_copy_portion_of_one_screen_to_another

;get off this crazy thing!
	movem.l (sp)+,d0-d7/a0-a6       ;unstack em
	rts

************* Gu-E button code

gue_call_code_button_clicked_upon_in_window
	;takes in d0, the window
	movem.l d0-d7/a0-a6,-(sp)

	lea     gue_button_data,a0
	lea     gue_window_data,a1
	move.l  d0,d6           ;store it for fast checking..
	mulu    #88,d0          ;get to an offset..
	add.l   d0,a1           ;step into the bank..

	move.l  #GUE_MAX_NUM_BUTTONS-1,d7
.loop
	cmp.l   #YES,(a0)
	bne     .next           ;its not used!
		cmp.l   #YES,4(a0)
		bne     .next   ;its not visible!
		cmp.l   #YES,20(a0)
		bne     .next   ;its attached to a window!
		cmp.l   24(a0),d6
		bne     .next   ;not attached to this window

			move.l  28(a0),d0       ;x of button
			move.l  32(a0),d1       ;y of button
				add.l   8(a1),d0
				add.l   12(a1),d1       ;draw button in window!
			move.l  d0,d2           
			move.l  d1,d3
			add.l   36(a0),d2       ;width of button
			add.l   40(a0),d3       ;height of button

			cmp.l   mouse_x,d0
			bgt     .next
			cmp.l   mouse_x,d2
			blt     .next
			cmp.l   mouse_y,d1
			bgt     .next
			cmp.l   mouse_y,d3
			blt     .next           ;oh dear, not over this button

;push the button in, or pull it out..
			cmp.l   #GUE_BUTTON_STATE_UP,16(a0)
			beq     .button_down_a
				move.l  #GUE_BUTTON_STATE_UP,16(a0)
				bra     .button_ok_a
.button_down_a
				move.l  #GUE_BUTTON_STATE_DOWN,16(a0)
.button_ok_a                    
			jsr     gue_draw_everything

;right, call the user defined window drawing code..
			movem.l d0-d7/a0-a6,-(sp)       ;stack em
				move.l  44(a0),a1
				jsr     (a1)
			movem.l (sp)+,d0-d7/a0-a6

;push the button in, or pull it out..
			cmp.l   #GUE_BUTTON_STATE_UP,16(a0)
			beq     .button_down_b
				move.l  #GUE_BUTTON_STATE_UP,16(a0)
				bra     .button_ok_b
.button_down_b
				move.l  #GUE_BUTTON_STATE_DOWN,16(a0)
.button_ok_b                    
			jsr     gue_draw_everything

.next
	add.l   #48,a0          ;next button please..
	dbf     d7,.loop
	movem.l (sp)+,d0-d7/a0-a6
	rts

gue_draw_all_visible_buttons_attached_to_a_window
	;takes in d0, the window number...
	movem.l d0-d7/a0-a6,-(sp)       ;stack them..
	
	lea     gue_button_data,a0
	lea     gue_window_data,a1
	move.l  d0,d6           ;store it for fast checking..
	mulu    #88,d0          ;get to an offset..
	add.l   d0,a1           ;step into the bank..

	move.l  #GUE_MAX_NUM_BUTTONS-1,d7
.loop
	cmp.l   #YES,(a0)
	bne     .next           ;its not used!
		cmp.l   #YES,4(a0)
		bne     .next   ;its not visible!
		cmp.l   #YES,20(a0)
		bne     .next   ;its attached to a window!
		cmp.l   24(a0),d6
		bne     .next   ;not attached to this window

			move.l  28(a0),d0
			move.l  32(a0),d1
				add.l   8(a1),d0
				add.l   12(a1),d1       ;draw button in window!
			move.l  d0,d2
			move.l  d1,d3
			add.l   36(a0),d2
			add.l   40(a0),d3
			move.l  16(a0),d4       ;up or down..
			move.l  12(a0),d5       ;address of text
			move.l  8(a0),gue_button_but_clickable
			jsr     gue_draw_text_button
.next
	add.l   #48,a0          ;next button please..
	dbf     d7,.loop
	movem.l (sp)+,d0-d7/a0-a6       ;unstack them..
	rts

gue_draw_all_visible_buttons_not_attached_to_a_window
	lea     gue_button_data,a0
	move.l  #GUE_MAX_NUM_BUTTONS-1,d7
.loop
	cmp.l   #YES,(a0)
	bne     .next           ;its not used!
		cmp.l   #YES,4(a0)
		bne     .next   ;its not visible!
		cmp.l   #YES,20(a0)
		beq     .next   ;its attached to a window!

			move.l  28(a0),d0
			move.l  32(a0),d1
			move.l  d0,d2
			move.l  d1,d3
			add.l   36(a0),d2
			add.l   40(a0),d3
			move.l  16(a0),d4       ;up or down..
			move.l  12(a0),d5       ;address of text
			move.l  8(a0),gue_button_but_clickable
			jsr     gue_draw_text_button

;copy it to the background screen..
;                       move.l  graphic_workscreen,a0
;                       move.l  work,a1
;                       jsr     gue_copy_portion_of_one_screen_to_another

.next
	add.l   #48,a0          ;next button please..
	dbf     d7,.loop
	rts

gue_draw_text_button
	;takes in d0,d1,d2,d3 (x1,y1,x2,y2)
	;d4 = state, UP or DOWN.. like 0,1
	;d5 = address of text to print..
	;win_button_but_clickable, a yes or a no....

	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	lea     gue_button_but_x1,a0
	movem.l d0-d5,(a0)              ;shove em in quick..

		;ok, draw the blank button..
	move.l  #2,ink_colour
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y1,d1    ;top left
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y1,d3    ;top right
	move.l  gue_button_but_x1,d4
	move.l  gue_button_but_y2,d5    ;bot left
	move.l  gue_button_but_x2,d6
	move.l  gue_button_but_y2,d7    ;bot right
	jsr     polygon

		;ok, top line of 3d
	cmp.l   #GUE_BUTTON_STATE_UP,gue_button_but_state
	beq     .button_up_1
		move.l  #3,ink_colour
		bra     .draw_but_1
.button_up_1
		move.l  #1,ink_colour
.draw_but_1
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y1,d1    ;top left
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y1,d3    ;top right
	jsr     line_draw

		;ok, left line of 3d
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y1,d1    ;top left
	move.l  gue_button_but_x1,d2
	move.l  gue_button_but_y2,d3    ;bot left
	jsr     line_draw

		;ok, bottom line of 3d
	cmp.l   #GUE_BUTTON_STATE_UP,gue_button_but_state
	beq     .button_up_2
		move.l  #1,ink_colour
		bra     .draw_but_2
.button_up_2
		move.l  #3,ink_colour
.draw_but_2
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y2,d1    ;bot left
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y2,d3    ;bot right
	add.l   #1,d2
	jsr     line_draw

		;ok, right line of 3d
	move.l  gue_button_but_x2,d0
	move.l  gue_button_but_y1,d1    ;top left
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y2,d3    ;bot left
	jsr     line_draw

.print_title
	move.l  #1000,d2
	move.l  #0,d3   ;where to wrap downwards..      
	move.l  gue_button_but_text,a1
	jsr     get_varifont_text_length        ;get its len in pixels!
	move.l  vari_text_len,d2
	lsr.l   #1,d2   ;divide by two..

	move.l  gue_button_but_x2,d1
	move.l  gue_button_but_x1,d0
	sub.l   d0,d1   ;gets len in pixels of available button
	lsr.l   #1,d1   ;divide it by two..
		add.l   d1,d0   ;step across to middle of visible button
		sub.l   d2,d0   ;go backwards....

	move.l  gue_button_but_x1,d2
	add.l   #2,d2   ;make it get past the 3d effect..
	cmp.l   d0,d2
	blt     .ok_done_center 
		move.l  gue_button_but_x1,d0
		add.l   #2,d0
.ok_done_center

	move.l  #5,ink_colour
	cmp.l   #YES,gue_button_but_clickable
	beq     .can_click_1
		move.l  #3,ink_colour
.can_click_1
	move.l  gue_button_but_y1,d2    ;top left
	move.l  gue_button_but_y2,d1
	sub.l   d1,d2   ;get vert dist between points..
	lsr.l   #1,d2   ;divide it by two..
	add.l   d2,d1   ;get to vert center of button
	sub.l   #3,d1   ;go back 4 pix (font is 8 down..)

	move.l  gue_button_but_x2,d2    ;length of visible titlebar
	sub.l   #2,d2
	move.l  d1,d3
	move.l  graphic_workscreen,a0
	move.l  gue_button_but_text,a1
	jsr     print_text_varifont     


	cmp.l   #YES,gue_button_but_clickable
	beq     .can_click_2
		move.l  #3,d7
.shade_text_loop
		move.l  #2,ink_colour
		move.l  d1,d3
		jsr     line_draw
		
		add.l   #2,d1
		dbf     d7,.shade_text_loop
		move.l  #3,ink_colour
.can_click_2                            ;'grey' out the button text!

;copy it to the background screen..
	move.l  graphic_workscreen,a0
	move.l  work,a1
	move.l  gue_button_but_x1,d0
	move.l  gue_button_but_y1,d1
	move.l  gue_button_but_x2,d2
	move.l  gue_button_but_y2,d3
	jsr     gue_copy_portion_of_one_screen_to_another

;quit out!
	movem.l (sp)+,d0-d7/a0-a6       ;unstack em
	rts

gue_draw_graphic_button
	;takes in d0,d1,d2,d3 (x1,y1,x2,y2)
	;d4 = type.. ie GUE_TITLE_BUT_CLOSE, etc..
	;d5 = state, UP or DOWN.. like 0,1

	movem.l d0-d7/a0-a6,-(sp)       ;stack em

	lea     gue_titlebar_but_x1,a0
	movem.l d0-d5,(a0)              ;shove em in quick..

		;ok, draw the blank button..
	move.l  #2,ink_colour
	move.l  gue_titlebar_but_x1,d0
	move.l  gue_titlebar_but_y1,d1  ;top left
	move.l  gue_titlebar_but_x2,d2
	move.l  gue_titlebar_but_y1,d3  ;top right
	move.l  gue_titlebar_but_x1,d4
	move.l  gue_titlebar_but_y2,d5  ;bot left
	move.l  gue_titlebar_but_x2,d6
	move.l  gue_titlebar_but_y2,d7  ;bot right
	jsr     polygon

		;ok, top line of 3d
	cmp.l   #GUE_BUTTON_STATE_UP,gue_titlebar_but_state
	beq     .button_up_1
		move.l  #3,ink_colour
		bra     .draw_but_1
.button_up_1
		move.l  #1,ink_colour
.draw_but_1
	move.l  gue_titlebar_but_x1,d0
	move.l  gue_titlebar_but_y1,d1  ;top left
	move.l  gue_titlebar_but_x2,d2
	move.l  gue_titlebar_but_y1,d3  ;top right
	jsr     line_draw

		;ok, left line of 3d
	move.l  gue_titlebar_but_x1,d0
	move.l  gue_titlebar_but_y1,d1  ;top left
	move.l  gue_titlebar_but_x1,d2
	move.l  gue_titlebar_but_y2,d3  ;bot left
	jsr     line_draw

		;ok, bottom line of 3d
	cmp.l   #GUE_BUTTON_STATE_UP,gue_titlebar_but_state
	beq     .button_up_2
		move.l  #1,ink_colour
		bra     .draw_but_2
.button_up_2
		move.l  #3,ink_colour
.draw_but_2
	move.l  gue_titlebar_but_x1,d0
	move.l  gue_titlebar_but_y2,d1  ;bot left
	move.l  gue_titlebar_but_x2,d2
	move.l  gue_titlebar_but_y2,d3  ;bot right
	add.l   #1,d2
	jsr     line_draw

		;ok, right line of 3d
	move.l  gue_titlebar_but_x2,d0
	move.l  gue_titlebar_but_y1,d1  ;top left
	move.l  gue_titlebar_but_x2,d2
	move.l  gue_titlebar_but_y2,d3  ;bot left
	jsr     line_draw

.draw_type_check_start
	cmp.l   #GUE_BUTTON_TYPE_FRONT,gue_titlebar_but_type
	bne     .iconify_check
		move.l  #5,ink_colour
		move.l  gue_titlebar_but_x1,d0
		move.l  gue_titlebar_but_y1,d1
		move.l  gue_titlebar_but_x2,d2
		move.l  gue_titlebar_but_y2,d3
		add.l   #2,d0
		add.l   #2,d1
		sub.l   #1,d2
		sub.l   #1,d3
		jsr     line_draw

		move.l  gue_titlebar_but_x1,d0
		move.l  gue_titlebar_but_y2,d1
		move.l  gue_titlebar_but_x2,d2
		move.l  gue_titlebar_but_y1,d3
		add.l   #2,d0
		sub.l   #2,d1
		sub.l   #1,d2
		add.l   #1,d3
		jsr     line_draw
.iconify_check
	cmp.l   #GUE_BUTTON_TYPE_ICONIFY,gue_titlebar_but_type
	bne     .deiconify_check
		move.l  #5,ink_colour
		move.l  gue_titlebar_but_x1,d0
		move.l  gue_titlebar_but_y2,d1
		move.l  gue_titlebar_but_x2,d2
		move.l  gue_titlebar_but_y2,d3
		add.l   #2,d0
		sub.l   #2,d1
		sub.l   #1,d2
		sub.l   #2,d3
		jsr     line_draw
.deiconify_check
	cmp.l   #GUE_BUTTON_TYPE_DEICONIFY,gue_titlebar_but_type
	bne     .maximize_check
		move.l  #5,ink_colour
		move.l  gue_titlebar_but_x1,d0
		move.l  gue_titlebar_but_y1,d1
		move.l  gue_titlebar_but_x2,d2
		move.l  gue_titlebar_but_y1,d3
		add.l   #2,d0
		add.l   #2,d1
		sub.l   #1,d2
		add.l   #2,d3
		jsr     line_draw
.maximize_check

.scroll_up
	cmp.l   #GUE_BUTTON_TYPE_SCROLL_UP,gue_titlebar_but_type
	bne     .scroll_down
		move.l  #5,ink_colour
		move.l  gue_titlebar_but_x1,d0
			move.l  gue_titlebar_but_x2,d2
			sub.l   d0,d2
			lsr.l   #1,d2   ;divide by 2
			add.l   d2,d0   ;to middle..
		move.l  gue_titlebar_but_y1,d1
		move.l  gue_titlebar_but_x1,d2
		move.l  gue_titlebar_but_y2,d3
			add.l   #2,d1
			add.l   #2,d2
			sub.l   #1,d3
		jsr     line_draw

		move.l  gue_titlebar_but_x2,d2
			sub.l   #2,d2
		jsr     line_draw

		move.l  gue_titlebar_but_x1,d0
		move.l  gue_titlebar_but_y2,d1
			add.l   #2,d0
			sub.l   #2,d1
			sub.l   #1,d3
		jsr     line_draw
.scroll_down
	cmp.l   #GUE_BUTTON_TYPE_SCROLL_DOWN,gue_titlebar_but_type
	bne     .scroll_left
		move.l  #5,ink_colour
		move.l  gue_titlebar_but_x1,d0
			move.l  gue_titlebar_but_x2,d2
			sub.l   d0,d2
			lsr.l   #1,d2   ;divide by 2
			add.l   d2,d0   ;to middle..
		move.l  gue_titlebar_but_y2,d1
		move.l  gue_titlebar_but_x1,d2
		move.l  gue_titlebar_but_y1,d3
			sub.l   #2,d1
			add.l   #2,d2
			add.l   #1,d3
		jsr     line_draw

		move.l  gue_titlebar_but_x2,d2
			sub.l   #2,d2
		jsr     line_draw

		move.l  gue_titlebar_but_x1,d0
		move.l  gue_titlebar_but_y1,d1
			add.l   #2,d0
			add.l   #2,d1
			add.l   #1,d3
		jsr     line_draw
.scroll_left
	cmp.l   #GUE_BUTTON_TYPE_SCROLL_LEFT,gue_titlebar_but_type
	bne     .scroll_right
		move.l  #5,ink_colour
		move.l  gue_titlebar_but_x1,d0
			add.l   #2,d0
		move.l  gue_titlebar_but_y1,d1
			move.l  gue_titlebar_but_y2,d2
			sub.l   d1,d2
			lsr.l   #1,d2   ;divide by 2
			add.l   d2,d1   ;to middle..
		move.l  gue_titlebar_but_x2,d2
		move.l  gue_titlebar_but_y1,d3
			sub.l   #2,d2
			add.l   #1,d3
		jsr     line_draw

		move.l  gue_titlebar_but_y2,d3
			sub.l   #2,d3
		jsr     line_draw

		move.l  gue_titlebar_but_x2,d0
		move.l  gue_titlebar_but_y1,d1
			sub.l   #2,d0
			add.l   #2,d1
			add.l   #1,d3
		jsr     line_draw
.scroll_right
	cmp.l   #GUE_BUTTON_TYPE_SCROLL_RIGHT,gue_titlebar_but_type
	bne     .scroll_slider
		move.l  #5,ink_colour
		move.l  gue_titlebar_but_x2,d0
			sub.l   #2,d0
		move.l  gue_titlebar_but_y1,d1
			move.l  gue_titlebar_but_y2,d2
			sub.l   d1,d2
			lsr.l   #1,d2   ;divide by 2
			add.l   d2,d1   ;to middle..
		move.l  gue_titlebar_but_x1,d2
		move.l  gue_titlebar_but_y1,d3
			add.l   #2,d2
			add.l   #1,d3
		jsr     line_draw

		move.l  gue_titlebar_but_y2,d3
			sub.l   #2,d3
		jsr     line_draw

		move.l  gue_titlebar_but_x1,d0
		move.l  gue_titlebar_but_y1,d1
			add.l   #2,d0
			add.l   #2,d1
			add.l   #1,d3
		jsr     line_draw
.scroll_slider


	movem.l (sp)+,d0-d7/a0-a6       ;unstack em
	rts

	even
gue_button_data
************buttons for the highlight window
;the highlight aliens button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_1       ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    3               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    14              ;y of button                    ; 32
	dc.l    80              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_alien_code     ;function to call on button..   ; 44
;the highlight pickups button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_2       ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    3               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    14+14           ;y of button                    ; 32
	dc.l    80              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_pickup_code    ;function to call on button..   ; 44
;the highlight world 3d points button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_3       ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    3               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    28+14           ;y of button                    ; 32
	dc.l    80              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_world_code     ;function to call on button..   ; 44
;the highlight door points button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_4       ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    3               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    42+14           ;y of button                    ; 32
	dc.l    80              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_door_code      ;function to call on button..   ; 44
;the highlight door switch button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_5       ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    3               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    56+14           ;y of button                    ; 32
	dc.l    80              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_switch_code    ;function to call on button..   ; 44


************buttons for the add window
;the add aliens button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_6       ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    4               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    14              ;y of button                    ; 32
	dc.l    71              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    do_nothing      ;function to call on button..   ; 44
;the add pickups button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_7       ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    4               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    14+14           ;y of button                    ; 32
	dc.l    71              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    do_nothing      ;function to call on button..   ; 44
;the add world 3d points button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_8       ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    4               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    28+14           ;y of button                    ; 32
	dc.l    71              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    do_nothing      ;function to call on button..   ; 44
;the add door and switch points button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_9       ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    4               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    42+14           ;y of button                    ; 32
	dc.l    71              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    do_nothing      ;function to call on button..   ; 44

************buttons for the move window
;the move aliens button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_10      ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    5               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    14              ;y of button                    ; 32
	dc.l    70              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    do_nothing      ;function to call on button..   ; 44
;the move pickups button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_11      ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    5               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    14+14           ;y of button                    ; 32
	dc.l    70              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    do_nothing      ;function to call on button..   ; 44
;the move world 3d points button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_12      ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    5               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    28+14           ;y of button                    ; 32
	dc.l    70              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    do_nothing      ;function to call on button..   ; 44
;the move door and switch points button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_13      ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    5               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    42+14           ;y of button                    ; 32
	dc.l    70              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    do_nothing      ;function to call on button..   ; 44

************buttons for the alter window
;the alter alien button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_14      ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    6               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    14              ;y of button                    ; 32
	dc.l    61              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_alien_code     ;function to call on button..   ; 44
;the alter pickup button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_15      ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    6               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    14+14           ;y of button                    ; 32
	dc.l    61              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_pickup_code    ;function to call on button..   ; 44
;the alter wall button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_16      ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    6               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    28+14           ;y of button                    ; 32
	dc.l    61              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_world_code     ;function to call on button..   ; 44
;the alter door button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_17      ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    6               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    42+14           ;y of button                    ; 32
	dc.l    61              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_door_code      ;function to call on button..   ; 44
;the alter door switch button
	dc.l    YES             ;button slot used?              ; 0
	dc.l    YES             ;is this button visible?        ; 4
	dc.l    YES             ;can it be clicked upon         ; 8
	dc.l    gue_button_text_18      ;pointer to the text    ; 12
	dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
	dc.l    YES             ;is it attached to a window?    ; 20
	dc.l    6               ;the number of the window       ; 24
				;it is attached to!
	dc.l    4               ;x of button                    ; 28
	dc.l    56+14           ;y of button                    ; 32
	dc.l    61              ;width of button                ; 36
	dc.l    12              ;height of button               ; 40
	dc.l    highlight_button_switch_code    ;function to call on button..   ; 44


;second test button
;       dc.l    YES             ;button slot used?              ; 0
;       dc.l    YES             ;is this button visible?        ; 4
;       dc.l    YES             ;can it be clicked upon         ; 8
;       dc.l    gue_button_text_2       ;pointer to the text    ; 12
;       dc.l    GUE_BUTTON_STATE_UP     ;state, up/down         ; 16
;       dc.l    NO              ;is it attached to a window?    ; 20
;       dc.l    0               ;the number of the window       ; 24
;                               ;it is attached to!
;       dc.l    1               ;x of button                    ; 28
;       dc.l    187             ;y of button                    ; 32
;       dc.l    140             ;width of button                ; 36
;       dc.l    12              ;height of button               ; 40
;       dc.l    do_nothing      ;function to call on button..   ; 44



	rept    GUE_MAX_NUM_BUTTONS
	dc.l    NO
	ds.l    11
	endr

gue_button_but_x1               dc.l    0
gue_button_but_y1               dc.l    0
gue_button_but_x2               dc.l    0
gue_button_but_y2               dc.l    0
gue_button_but_state            dc.l    0
gue_button_but_text             dc.l    0       ;pointer..
gue_button_but_clickable        dc.l    0       ;No = grey'd out option
	even
*************** end Gu-E button code n data..

;buttons for the highlight window
gue_button_text_1       dc.b    "aliens - on",0,0
gue_button_text_2       dc.b    "pickups - on",0,0
gue_button_text_3       dc.b    "wall points - on",0,0
gue_button_text_4       dc.b    "door points - on",0,0
gue_button_text_5       dc.b    "switch points - on",0,0

;buttons for the add window
gue_button_text_6       dc.b    "aliens",0
gue_button_text_7       dc.b    "pickups",0
gue_button_text_8       dc.b    "wall points",0
gue_button_text_9       dc.b    "doors + switches",0

;buttons for the add window
gue_button_text_10      dc.b    "aliens",0
gue_button_text_11      dc.b    "pickups",0
gue_button_text_12      dc.b    "wall points",0
gue_button_text_13      dc.b    "doors + switches",0

;buttons for the alter window
gue_button_text_14      dc.b    "alien",0
gue_button_text_15      dc.b    "pickup",0
gue_button_text_16      dc.b    "wall",0
gue_button_text_17      dc.b    "door",0
gue_button_text_18      dc.b    "switch",0



temp_text       dc.b    "Hello and welcome to Gu-E 2.0a",13,13
		dc.b    "Coded for the 'KillThings' level editor.",13,13
		dc.b    "It uses the proportional font code that was "
		dc.b    "written for ",13
		dc.b    "the game entitled 'subaqua'..",13,13
		dc.b    0
		even
gue_title_1             dc.b    "Map Window",0
gue_iconified_1         dc.b    "MapWin",0
gue_statusbar_1         dc.b    "Wow...",0

gue_title_2             dc.b    "Information..",0
gue_iconified_2         dc.b    "Info",0
gue_statusbar_2         dc.b    "A StatusBar message",0

gue_title_3             dc.b    "Texture List",0
gue_iconified_3         dc.b    "T List",0
gue_statusbar_3         dc.b    "A StatusBar message",0

gue_title_4             dc.b    "Highlight..",0
gue_iconified_4         dc.b    "Highlight",0
gue_statusbar_4         dc.b    "no message",0

gue_title_5             dc.b    "Add..",0
gue_iconified_5         dc.b    "Add",0
gue_statusbar_5         dc.b    "no message",0

gue_title_6             dc.b    "Move..",0
gue_iconified_6         dc.b    "Move",0
gue_statusbar_6         dc.b    "no message",0

gue_title_7             dc.b    "Alter..",0
gue_iconified_7         dc.b    "Alter",0
gue_statusbar_7         dc.b    "no message",0

gue_title_8             dc.b    "Alien details..",0
gue_iconified_8         dc.b    "Alien",0
gue_statusbar_8         dc.b    "no message",0

gue_standard_titlebar   dc.b    "Gu-E 2.0a (C) 1996 Digi Tallis",0
gue_standard_iconified  dc.b    "Gu-E 2.0a",0
gue_standard_statusbar  dc.b    "Gu-E 2.0a reports 'OK'",0
	even

gue_visible_x1          dc.l    0
gue_visible_y1          dc.l    0
gue_visible_x2          dc.l    0
gue_visible_y2          dc.l    0

gue_scrollbar_but_x1    dc.l    0
gue_scrollbar_but_y1    dc.l    0
gue_scrollbar_but_x2    dc.l    0
gue_scrollbar_but_y2    dc.l    0

gue_titlebar_but_x1     dc.l    0
gue_titlebar_but_y1     dc.l    0
gue_titlebar_but_x2     dc.l    0
gue_titlebar_but_y2     dc.l    0
gue_titlebar_but_type   dc.l    0
gue_titlebar_but_state  dc.l    0


gue_window_pal          dc.w    $012            ;bckground
			dc.w    $677,$455,$233  ;3d colours
			dc.w    $300            ;window at front
			dc.w    $000            ;a solid black. 
			dc.w    $544            ;windows not at front
			dc.w    $200,$100,$077,$037     
			dc.w    $005,$003,$070,$030,$777
			even
gue_drawing_window_number       dc.l    0

gue_window_data
;the map window
	dc.l    YES             ;is this window slot used..     ; 0
	dc.l    gue_title_1     ;pointer to titlebar string..   ; 4
	dc.l    1               ;visible x1   cant be zero..    ; 8
	dc.l    0               ;visible y1                     ; 12
	dc.l    160             ;visible x2                     ; 16
	dc.l    178             ;visible y2                     ; 20
	dc.l    YES             ;title bar?                     ; 24
	dc.l    YES             ;x scrollbar?                   ; 28
	dc.l    YES             ;y scrollbar?                   ; 32
	dc.l    map_redraw_window       ;address of redraw window code  ; 36
	dc.l    map_redraw_window       ;address of LEFT xscrollcode    ; 40
	dc.l    map_redraw_window       ;address of RIGHT xscrollcode   ; 44
	dc.l    map_redraw_window       ;address of UP yscrollcode      ; 48
	dc.l    map_redraw_window       ;address of DOWN yscrollcode    ; 52
	dc.l    NO              ;visible??                      ; 56
	dc.l    1               ;iconified x1, can't be zero!   ; 60
	dc.l    188             ;iconified y1                   ; 64
	dc.l    gue_iconified_1 ;wheres the icon text!?         ; 68
	dc.l    YES             ;status bar                     ; 72
	dc.l    gue_statusbar_1 ;the text to display in it..    ; 76
	dc.l    NO              ;is there a menubar?!           ; 80
	dc.l    0               ;pointer to menu to use..       ; 84    

;information window
	dc.l    YES             ;is this window slot used..     ; 0
	dc.l    gue_title_2     ;pointer to titlebar string..   ; 4
	dc.l    60              ;x1     ;cant be zero..         ; 8
	dc.l    30              ;y1                             ; 12
	dc.l    310             ;x2                             ; 16
	dc.l    109             ;y2                             ; 20
	dc.l    YES             ;title bar?                     ; 24
	dc.l    NO              ;x scrollbar?                   ; 28
	dc.l    NO              ;y scrollbar?                   ; 32
	dc.l    draw_intro_message      ;address of redraw window code  ; 36
	dc.l    do_nothing      ;address of LEFT xscrollcode    ; 40
	dc.l    do_nothing      ;address of RIGHT xscrollcode   ; 44
	dc.l    do_nothing      ;address of UP yscrollcode      ; 48
	dc.l    do_nothing      ;address of DOWN yscrollcode    ; 52
	dc.l    NO              ;visible??                      ; 56
	dc.l    51              ;iconified x1, can't be zero!   ; 60
	dc.l    188             ;iconified y1                   ; 64
	dc.l    gue_iconified_2 ;wheres the icon text!?         ; 68
	dc.l    NO              ;status bar                     ; 72
	dc.l    gue_statusbar_2 ;the text to display in it..    ; 76
	dc.l    NO              ;is there a menubar?!           ; 80
	dc.l    0               ;pointer to menu to use..       ; 84    

;texture list window
	dc.l    YES             ;is this window slot used..     ; 0
	dc.l    gue_title_3     ;pointer to titlebar string..   ; 4
	dc.l    180             ;x1     ;cant be zero..         ; 8
	dc.l    100             ;y1                             ; 12
	dc.l    319             ;x2                             ; 16
	dc.l    190             ;y2                             ; 20
	dc.l    YES             ;title bar?                     ; 24
	dc.l    NO              ;x scrollbar?                   ; 28
	dc.l    YES             ;y scrollbar?                   ; 32
	dc.l    do_nothing      ;address of redraw window code  ; 36
	dc.l    do_nothing      ;address of LEFT xscrollcode    ; 40
	dc.l    do_nothing      ;address of RIGHT xscrollcode   ; 44
	dc.l    do_nothing      ;address of UP yscrollcode      ; 48
	dc.l    do_nothing      ;address of DOWN yscrollcode    ; 52
	dc.l    NO              ;visible??                      ; 56
	dc.l    101             ;iconified x1, can't be zero!   ; 60
	dc.l    188             ;iconified y1                   ; 64
	dc.l    gue_iconified_3 ;wheres the icon text!?         ; 68
	dc.l    YES             ;status bar                     ; 72
	dc.l    gue_statusbar_3 ;the text to display in it..    ; 76
	dc.l    NO              ;is there a menubar?!           ; 80
	dc.l    0               ;pointer to menu to use..       ; 84    

;the highlight bits in the map window
	dc.l    YES             ;is this window slot used..     ; 0
	dc.l    gue_title_4     ;pointer to titlebar string..   ; 4
	dc.l    231             ;x1     ;cant be zero..         ; 8
	dc.l    0               ;y1                             ; 12
	dc.l    319             ;x2                             ; 16
	dc.l    86              ;y2                             ; 20
	dc.l    YES             ;title bar?                     ; 24
	dc.l    NO              ;x scrollbar?                   ; 28
	dc.l    NO              ;y scrollbar?                   ; 32
	dc.l    highlight_redraw_window ;address of redraw window code  ; 36
	dc.l    do_nothing      ;address of LEFT xscrollcode    ; 40
	dc.l    do_nothing      ;address of RIGHT xscrollcode   ; 44
	dc.l    do_nothing      ;address of UP yscrollcode      ; 48
	dc.l    do_nothing      ;address of DOWN yscrollcode    ; 52
	dc.l    YES             ;visible??                      ; 56
	dc.l    151             ;iconified x1, can't be zero!   ; 60
	dc.l    188             ;iconified y1                   ; 64
	dc.l    gue_iconified_4 ;wheres the icon text!?         ; 68
	dc.l    NO              ;status bar                     ; 72
	dc.l    gue_statusbar_4 ;the text to display in it..    ; 76
	dc.l    NO              ;is there a menubar?!           ; 80
	dc.l    0               ;pointer to menu to use..       ; 84    

;the add object bits in the map window
	dc.l    YES             ;is this window slot used..     ; 0
	dc.l    gue_title_5     ;pointer to titlebar string..   ; 4
	dc.l    240             ;x1     ;cant be zero..         ; 8
	dc.l    87              ;y1                             ; 12
	dc.l    319             ;x2                             ; 16
	dc.l    87+72           ;y2                             ; 20
	dc.l    YES             ;title bar?                     ; 24
	dc.l    NO              ;x scrollbar?                   ; 28
	dc.l    NO              ;y scrollbar?                   ; 32
	dc.l    do_nothing      ;address of redraw window code  ; 36
	dc.l    do_nothing      ;address of LEFT xscrollcode    ; 40
	dc.l    do_nothing      ;address of RIGHT xscrollcode   ; 44
	dc.l    do_nothing      ;address of UP yscrollcode      ; 48
	dc.l    do_nothing      ;address of DOWN yscrollcode    ; 52
	dc.l    YES             ;visible??                      ; 56
	dc.l    201             ;iconified x1, can't be zero!   ; 60
	dc.l    188             ;iconified y1                   ; 64
	dc.l    gue_iconified_5 ;wheres the icon text!?         ; 68
	dc.l    NO              ;status bar                     ; 72
	dc.l    gue_statusbar_5 ;the text to display in it..    ; 76
	dc.l    NO              ;is there a menubar?!           ; 80
	dc.l    0               ;pointer to menu to use..       ; 84    

;the move object bits in the map window
	dc.l    YES             ;is this window slot used..     ; 0
	dc.l    gue_title_6     ;pointer to titlebar string..   ; 4
	dc.l    161             ;x1     ;cant be zero..         ; 8
	dc.l    87              ;y1                             ; 12
	dc.l    239             ;x2                             ; 16
	dc.l    87+72           ;y2                             ; 20
	dc.l    YES             ;title bar?                     ; 24
	dc.l    NO              ;x scrollbar?                   ; 28
	dc.l    NO              ;y scrollbar?                   ; 32
	dc.l    do_nothing      ;address of redraw window code  ; 36
	dc.l    do_nothing      ;address of LEFT xscrollcode    ; 40
	dc.l    do_nothing      ;address of RIGHT xscrollcode   ; 44
	dc.l    do_nothing      ;address of UP yscrollcode      ; 48
	dc.l    do_nothing      ;address of DOWN yscrollcode    ; 52
	dc.l    YES             ;visible??                      ; 56
	dc.l    251             ;iconified x1, can't be zero!   ; 60
	dc.l    188             ;iconified y1                   ; 64
	dc.l    gue_iconified_6 ;wheres the icon text!?         ; 68
	dc.l    NO              ;status bar                     ; 72
	dc.l    gue_statusbar_6 ;the text to display in it..    ; 76
	dc.l    NO              ;is there a menubar?!           ; 80
	dc.l    0               ;pointer to menu to use..       ; 84    

;the alter object window.. this pops up the relevant object window
;                               which are all set up directly below
	dc.l    YES             ;is this window slot used..     ; 0
	dc.l    gue_title_7     ;pointer to titlebar string..   ; 4
	dc.l    161             ;x1     ;cant be zero..         ; 8
	dc.l    0               ;y1                             ; 12
	dc.l    230             ;x2                             ; 16
	dc.l    86              ;y2                             ; 20
	dc.l    YES             ;title bar?                     ; 24
	dc.l    NO              ;x scrollbar?                   ; 28
	dc.l    NO              ;y scrollbar?                   ; 32
	dc.l    do_nothing      ;address of redraw window code  ; 36
	dc.l    do_nothing      ;address of LEFT xscrollcode    ; 40
	dc.l    do_nothing      ;address of RIGHT xscrollcode   ; 44
	dc.l    do_nothing      ;address of UP yscrollcode      ; 48
	dc.l    do_nothing      ;address of DOWN yscrollcode    ; 52
	dc.l    YES             ;visible??                      ; 56
	dc.l    1               ;iconified x1, can't be zero!   ; 60
	dc.l    176             ;iconified y1                   ; 64
	dc.l    gue_iconified_7 ;wheres the icon text!?         ; 68
	dc.l    NO              ;status bar                     ; 72
	dc.l    gue_statusbar_7 ;the text to display in it..    ; 76
	dc.l    NO              ;is there a menubar?!           ; 80
	dc.l    0               ;pointer to menu to use..       ; 84    

;the alien object window.. 
	dc.l    YES             ;is this window slot used..     ; 0
	dc.l    gue_title_8     ;pointer to titlebar string..   ; 4
	dc.l    21              ;x1     ;cant be zero..         ; 8
	dc.l    10              ;y1                             ; 12
	dc.l    160             ;x2                             ; 16
	dc.l    150             ;y2                             ; 20
	dc.l    YES             ;title bar?                     ; 24
	dc.l    NO              ;x scrollbar?                   ; 28
	dc.l    NO              ;y scrollbar?                   ; 32
	dc.l    alien_object_window_redraw      ;address of redraw window code  ; 36
	dc.l    do_nothing      ;address of LEFT xscrollcode    ; 40
	dc.l    do_nothing      ;address of RIGHT xscrollcode   ; 44
	dc.l    do_nothing      ;address of UP yscrollcode      ; 48
	dc.l    do_nothing      ;address of DOWN yscrollcode    ; 52
	dc.l    YES             ;visible??                      ; 56
	dc.l    51              ;iconified x1, can't be zero!   ; 60
	dc.l    176             ;iconified y1                   ; 64
	dc.l    gue_iconified_8 ;wheres the icon text!?         ; 68
	dc.l    NO              ;status bar                     ; 72
	dc.l    gue_statusbar_8 ;the text to display in it..    ; 76
	dc.l    NO              ;is there a menubar?!           ; 80
	dc.l    0               ;pointer to menu to use..       ; 84    


	rept    GUE_MAX_NUM_WINDOWS+1
	dc.l    NO      ;state, used or not
	dc.l    gue_standard_titlebar
	ds.l    14
	dc.l    gue_standard_iconified
	dc.l    NO
	dc.l    gue_standard_statusbar
	dc.l    NO
	dc.l    0       ;use zero...
	endr
	even

gue_scrollbar_y_data
	dc.l    1,500,5         ;map window
;       dc.l    1,2,5

	rept    GUE_MAX_NUM_WINDOWS+1
	dc.l    1                       ;scrollbar current scrollpos
	dc.l    2                       ;length of data to cover..
	dc.l    1                       ;amount of data window covers
	endr

gue_scrollbar_x_data
	dc.l    1,500,5         ;map window
;       dc.l    1,10,5

	rept    GUE_MAX_NUM_WINDOWS+1
	dc.l    1                       ;scrollbar current scrollpos
	dc.l    2                       ;length of data to cover..
	dc.l    1                       ;amount of data window covers
	endr
**************************************************************************
** End of Gu-E 2.0a code..                                              **
**************************************************************************


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
	dc.l    90,153,P_HEALTH_SMALL,YES,0     ;a temp one..

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
			;40=hurt, 20=pissed off
			;10=plain fucking furious!
	dc.l    0       ;0 = still, 1 = active
			;if active go towards player.. (or other target)
		;this can be used for 'freeze-bombs'!!
		;fling in a grenade, it goes off, set the alien active
		;flags to inactive, for a while.. easy!!
		;set its anger time, and decrease it.. cool..
	dc.l    0       ;sub intelligence
			;ie, if hurt, look for hiding place
			;or look for medipack, or suicide etc..
	dc.l    0       ;anger time..
			;if alien's anger time has become zero
			;then go back to wandering around aimlessly
			;otherwise always run at target!
		;wandering around aimlessly is bloody easy..
		;pick two random points, shove a random time into the
		;anger timer, when time gets to zero, pick another
		;random target.. simple..
			;if done well you could get monsters picking
			;fights with plants and other scenery! =]
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


joystick_left   dc.l    0
joystick_right  dc.l    0
joystick_up     dc.l    0
joystick_down   dc.l    0       ;all data associated with joystick
mouse_x         dc.l    0
mouse_y         dc.l    0
old_mouse_x     dc.l    0
old_mouse_y     dc.l    0
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
	include d:\graphics.s
	include d:\variprnt.s

**************************************************************************
**************************************************************************
**                                                                      **
** Ok, all my pointers and comments and stuff like that..               **
**                                                                      **
**************************************************************************
**************************************************************************
;right, thats better, echobelly's superb 'everyone's got one' is playing,
;I've got some cheese on toast, and a cup of tea..
;things just couldn't be any better.. =]
;
;Gu-E 20.a isn't finished, there are still some bits to do, but the main
;thing that I can think of at the moment is that the menu's aren't finished,
;but are instead half coded (well, datatyping exists etc..)
;       all that needs to be done is this:
;       a) write check for mouse button within the menu bar of a window
;               if it exists, then figure out what menu option the user
;               clicked on, figure out which sub-menu hangs off it, and
;               redraw the screen with the new sub-menu visible..
;               then keep looping around until the user has either selected
;               an option, or clicked somewhere else within root window..
;       b) write code that draws drop down menus taking into account the
;               seperators and possible menus hanging off options, ie.
;                       --------- ----------
;                       | file >| | open   |
;                       | edit  | | save   |
;                       | make  | | saveas |
;                       --------- | delete |
;                                 | create |
;                                 ----------
;
;the LevelEditor is meant to allow you to edit various things for the
;KillThings level format, but since the KillThings level format hasn't
;been coded yet, it is rather pointless.. oh well..
;
;the whole level editor should use windows. So the stuff related to texture
;editing and creation should be in one window, and the stuff related to 
;positioning walls and so forth, should be in another..
;
;Textures
;       textures are bloody sneaky, they aren't textures in the strictest 
;       sense of the word (ie, a small bitmap), but rather a texture is
;       made up from texture-strips. A texture strip is, as it suggests,
;       a strip of colour values (ie, 0-15)
;       At the moment, there exists a stos .bas file which runs along the top
;       of a .pi1 creating the strips and dumping them into a memory bank
;       before saving it..
;       Ideally, there should be a texture editor window where you can draw
;       a bog standard bitmap and store it in memory, then when you elect
;       to save the level file, it runs thru all the bitmaps, removes similar
;       t-strips (hence reducing the size of the final level file) and then
;       saves it. This is only a pointer of course, but since memory is
;       usually tight on the Atari platform, any memory conservation idea
;       must be cool.. no? =]
;       Oh yeah, the first t-strip in the whole t-strip bank SHOULD be nothing
;       but zeros! Makes objects with an empty surround much easier..
;
;The game map
;       the map is made up from Points and Walls. A Point is simply a 2d 
;       coordinate, except of being X,Y it is X,Z
;       A Wall is made up from two Points. All walls are solid, you cannot
;       see thru them, if you want to have transparent walls then use a door
;       and position its opening switch somewhere where the player will never
;       reach it, tacky, but it works..
;       The Points that make up a wall can be anywhere within the gamezone,
;       but bear in mind that the wall drawing routine stretches an 80 t-strip
;       texture to fit, so a bloody big wall will probably look very bad..
;
;Switches
;       switches can be placed along walls, or slightly infront of 'em, and
;       can either be visible or invisible. Invisible switches come in handy 
;       when you have a door that doesn't need a switch to be pressed, 'cos
;       you bung the switch infront of the door and make it invisible, then
;       when the player presses space to open the door, the switch opens it!
;       a fudge, but all the best things in life are fudges.. =]
;       what I had in mind for this was an 'add switch' point, which when
;       clicked would pop up a list of all types, invisible or not etc,
;       and then the user would just click within the map window twice to 
;       position both the switch points.. 
;
;Pickups
;       pickups are simply a point within the game world that when walked
;       over get picked up (providing what they will increase isn't already
;       full (ie, ammo, health etc..))
;       what I had in mind for this was, click on an 'add pickup' button, 
;       a list would appear showing all available pickup types, and then the
;       user would simply add a point into the game world by clicking within
;       the map window.
;       it goes without saying that there wouid be modify pickup and delete
;       pickup options.. =]
;
;Teleports
;       there are two types of teleport, one teleports the player to another
;       location within the game world, and the other signals that the player
;       has entered the exit.
;       teleports are always square, and based on the north/south, east/west
;       line within the game world. Why? The check for entering a teleport
;       is a hell of a lot easier.. =]
;       addition of teleports into the game world should be made possible
;       by a few simple mouse clicks, one on the 'add teleport' button,
;       one on the teleport type (level end, or normal) and then a single
;       click within the game world to position it..
;       still, what should and what will be are to different things entirely..
;
;Aliens
;       if you'll scuse the french, theres a shit load of data involved with
;       an alien. and most of it is very convoluted!
;       basically, you should be able to add an alien bu clicking 'add alien',
;       changing the predefined paramaters for the new alien, ie type, anger
;       and so on, and then position the alien within the game world.
;       if this seems a huge cop-out by not explaining all the properties an
;       alien can have, then it is slightly, but then again, I coded the alien
;       related stuff about 1 year ago, and I just can't remember what I was
;       thinking of at the time.. sorry!
;
;oh well, thats me done, have fun with the code and feel free to use Gu-E 2.0a
;for whatever purpose you desire, but just be kind enough as to give me a
;credit somewhere, its not too much to ask.. =]
;oh, and if you want to butcher stuff beyond all recognition, then go for it!
;
;gone..
;
;()rm..
;Jan '97. 
;About 1 year and 4 months after the KillThings project was started
;(christ, that long.. eeek..)
