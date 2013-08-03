**************************************************************************
*
*                             PACMAN
*               (c) W.Barnes, August-September 1991.
*
**************************************************************************

        opt     O+,OW-          all optimising on, warnings off

**************************************************************************
* CONSTANTS
**************************************************************************

* system variable locations
KEYCLICK        equ     $484
H_PAL           equ     $ffff8240
H_RES           equ     $ffff8260
KB_CONTROL      equ     $fffffc00
KB_DATA         equ     $fffffc02
VBI             equ     $70

* colour numbers of objects
SPACE           equ     0
WALL            equ     10
TRACK           equ     11
ENERGIZER       equ     14
DOT             equ     15

*************************************************************************
* offsets to sprite and other data.  a6 is the index register
pacman_data     rs.w    0
pacman_x        rs.w    1
pacman_y        rs.w    1
pacman_stats    rs.w    1
pacman_dir      rs.w    1
ghost_data      rs.w    0
shadow_data     rs.w    0
shadow_x        rs.w    1
shadow_y        rs.w    1
shadow_stats    rs.w    1
shadow_dir      rs.w    1
pokey_data      rs.w    0
pokey_x         rs.w    1
pokey_y         rs.w    1
pokey_stats     rs.w    1
pokey_dir       rs.w    1
speedy_data     rs.w    0
speedy_x        rs.w    1
speedy_y        rs.w    1
speedy_stats    rs.w    1
speedy_dir      rs.w    1
bashful_data    rs.w    0
bashful_x       rs.w    1
bashful_y       rs.w    1
bashful_stats   rs.w    1
bashful_dir     rs.w    1
rnd_num         rs.w    1
old_pal         rs.w    16
old_physbase    rs.l    1
old_logbase     rs.l    1
old_ssp         rs.l    1
old_vbi         rs.l    1
j_pack_addr     rs.l    1
old_j_pack      rs.l    1
score           rs.l    1
hiscore         rs.l    1
energizer_time  rs.w    1
ghost_blue      rs.w    1
ghost_value     rs.w    1
scrn_delay      rs.w    1
fruit_type      rs.w    1
fruit_value     rs.w    1
fr_spr_off      rs.w    1
fruit_appear    rs.w    1
fruit_disappear rs.w    1
screen_num      rs.w    1
time            rs.w    1
physbase        rs.l    1
logbase         rs.l    1
backbase        rs.l    1
fruit_on        rs.b    1
num_dots_eaten  rs.b    1
ghosts_stop     rs.b    1
old_res         rs.b    1
var_length      rs.w    0
*************************************************************************

* initial values
PACMAN_START_X          equ     148
PACMAN_START_Y          equ     134
PACMAN_START_DIR        equ     0
POKEY_START_X           equ     129
POKEY_START_Y           equ     75
POKEY_START_DIR         equ     1
SHADOW_START_X          equ     148
SHADOW_START_Y          equ     62
SHADOW_START_DIR        equ     0
BASHFUL_START_X         equ     148
BASHFUL_START_Y         equ     84
BASHFUL_START_DIR       equ     2
SPEEDY_START_X          equ     166
SPEEDY_START_Y          equ     75
SPEEDY_START_DIR        equ     0

START_LIVES             equ     3
SPRITE_SPEED            equ     1

**************************************************************************
* MACROS

crawio  macro   [ascii code]
         move.w \1,-(a7)                char code, 255=inkey
         move.w #6,-(a7)                crawio()
         trap   #1                      gemdos
         addq.l #4,a7                   tidy
        endm

do_snd  macro   [label of sound data]
         pea    \1(pc)
         move.w #32,-(a7)       dosound()
         trap   #14             xbios
         addq.l #6,a7           tidy
        endm

inkey   macro
         crawio <#255>
        endm

**************************************************************************
****************************** MAIN PROGRAM ******************************
**************************************************************************
* global        a6: base address of almost all of the variables
**************************************************************************
        lea     all_data,a6     base address of all the data
* go to supervisor mode
        clr.l   -(a7)
        move.w  #32,-(a7)
        trap    #1              gemdos
        addq.l  #6,a7           tidy
        move.l  d0,old_ssp(a6)
* work out screen addresses
        move.w  #2,-(a7)        physbase()
        trap    #14             xbios
        addq.l  #2,a7           tidy
        move.l  d0,physbase(a6)
        move.l  d0,old_physbase(a6)
        move.w  #3,-(a7)        logbase()
        trap    #14             xbios
        addq.l  #2,a7           tidy
        move.l  d0,old_logbase(a6)
        move.l  #log_scr,d0     find address of second screen
        addi.l  #$ff,d0         ensure that it's on a 256 boundary
        andi.b  #$00,d0
        move.l  d0,logbase(a6)
        addi.l  #32000,d0       background screen is above the log screen
        move.l  d0,backbase(a6)
        movem.l H_PAL,d0-d7     save the old palette
        movem.l d0-d7,old_pal(a6)
        move.b  H_RES,old_res(a6) save the old screen resolution
        clr.w   -(a7)           set low resolution
        move.l  physbase(a6),-(a7)
        move.l  physbase(a6),-(a7)
        move.w  #5,-(a7)
        trap    #14                     xbios
        lea     12(a7),a7
        bsr     _black_screen
        bclr.b  #0,(KEYCLICK).w         turn off keyboard click
        move.l  (VBI).w,old_vbi(a6)
        move.l  #_new_vbi_routine,(VBI).w

        move.w  #34,-(a7)               kbdvbas(): get system vectors
        trap    #14                     xbios
        addq.l  #2,a7
        move.l  d0,a0                   address of system vectors
        lea     24(a0),a0               move to joystick vector
        move.l  a0,j_pack_addr(a6)      store the address of the vector
        move.l  (a0),old_j_pack(a6)     store the old vector
        move.l  #_joy_handler,(a0)      patch in the new one
js_loop btst.b  #1,KB_CONTROL           is keyboard ready for command
        beq.s   js_loop                 no, loop
        move.b  #$15,KB_DATA            set joy to, request packet mode

        bra     main_game

finish
        btst.b  #1,KB_CONTROL           is keyboard ready for command
        beq.s   finish                  no, loop
        move.b  #$8,KB_DATA             set mouse relative mode
        do_snd  <stop_music>
        move.l  j_pack_addr(a6),a0
        move.l  old_j_pack(a6),(a0)     put old joystick handler back
        bset.b  #0,(KEYCLICK).w         turn on keyboard click
        movem.l old_pal(a6),d0-d7       reset the old palette
        movem.l d0-d7,H_PAL
        move.l  old_vbi(a6),(VBI).w
        move.l  old_ssp(a6),a7
        move.b  old_res(a6),d0
        ext.w   d0
        move.w  d0,-(a7)                original resolution
        move.l  old_physbase(a6),-(a7)
        move.l  old_logbase(a6),-(a7)
        move.w  #5,-(a7)                setscreen()
        trap    #14                     xbios
        lea     12(a7),a7               tidy
* exit the program
        clr.w   -(a7)                   pterm0
        trap    #1                      gemdos
**************************************************************************
_new_vbi_routine
        st      vbi_done
        rte
**************************************************************************
_wait_vbi
        tst.b   vbi_done
        beq.s   _wait_vbi
        rts
**************************************************************************
_swap_screens
        move.l  logbase(a6),d0
        move.l  physbase(a6),logbase(a6)
        move.l  d0,physbase(a6)
        lsr.w   #8,d0
        move.l  d0,$ffff8200.w
        sf      vbi_done
        rts
**************************************************************************
_black_screen
        movea.l #H_PAL,a0
        moveq   #7,d0                   8 long words = 16 words to do
black_loop
        clr.l   (a0)+                   set to colour zero (black)
        dbf     d0,black_loop
        rts
**************************************************************************
_joy_handler
        sf      fire            set fire to false
        move.w  d0,-(a7)
        clr.w   d0
        move.b  1(a0),d0        F...RLDU
        add.b   d0,d0           ...RLUD.        *2 for lookup table
        scs     fire            set fire to true if bit 7 set
        add.b   d0,d0           ..RLDU..
        move.l  jlt(pc,d0.w),dxy_joy
        move.w  (a7)+,d0
        rts
*              dx,dy            the bits        impossible cases
jlt     dc.w    0,0             ..0000..
        dc.w    0,-1            ..000U..
        dc.w    0,1             ..00D0..
        dc.w    0,0             ..00DU..        *
        dc.w    -1,0            ..0L00..
        dc.w    -1,-1           ..0L0U..
        dc.w    -1,1            ..0LD0..
        dc.w    -1,0            ..0LDU..        *
        dc.w    1,0             ..R000..        *
        dc.w    1,-1            ..R00U..
        dc.w    1,1             ..R0D0..
        dc.w    1,0             ..R0DU..        *
        dc.w    0,0             ..RL00..        *
        dc.w    0,-1            ..RL0U..        *
        dc.w    0,1             ..RLD0..        *
        dc.w    0,0             ..RLDU..        *
**************************************************************************
_fade_out
        move.w  #%1110111011101110,d2
        moveq   #3,d0                   4 bit planes to do
fo_pal_loop
        moveq   #15,d1
        movea.l #H_PAL,a0
fo_col_loop
        bsr     _short_delay
        and.w   d2,(a0)+                mask out 1 bit plane, low
        dbf     d1,fo_col_loop
        rol.l   #1,d2
        dbf     d0,fo_pal_loop
        rts
**************************************************************************
_fade_in
        movea.l #H_PAL,a0
        lea     def_pal(pc),a1
        move.w  #$7,d1
fade_pal_loop
        moveq   #0,d0
fade_col_loop
        bsr     _short_delay
        move.w  0(a1,d0.w),d2
        sub.w   #$111,d2
        cmp.w   0(a0,d0.w),d2
        ble.s   fade_full
         add.w  #$111,0(a0,d0.w)        increase by one grey scale
         bra.s  f_next_reg
fade_full
        move.w  0(a1,d0.w),0(a0,d0.w)   transfer the exact colour
f_next_reg
        addq.w  #2,d0                   next colour register
        cmpi.w  #30,d0
        ble.s   fade_col_loop
        dbf     d1,fade_pal_loop
        rts
**************************************************************************
main_game
        do_snd  <intro_song>
* title screen
* first clear the screen
        movea.l physbase(a6),a0
        move.w  #7999,d0
ts_cls_loop
        clr.l   (a0)+
        dbf     d0,ts_cls_loop
* then copy the title picture over
        movea.l physbase(a6),a0
        lea     title_screen,a1
        move.w  #1599,d0                40 lines * 40 words per line
ts_cpy_loop
        move.l  (a1)+,(a0)+
        dbf     d0,ts_cpy_loop
* now the text
        lea     instructions(pc),a3
        bsr     _print
* show the screen
        movem.l title_pal,d0-d7
        movem.l d0-d7,H_PAL
* load in the background screen (in .PC1 format)
        lea     backfile(pc),a0         address of the filename
        movea.l backbase(a6),a1         where to write to
        bsr     _load_pc1               load the picture and decompress
* wait for a key to be pressed
        bsr     _get_key_colour
**************************************************************************
start_game
* check if there is a new high score
        move.l  score(a6),d0
        cmp.l   hiscore(a6),d0          is score greater than high score?
        ble.s   no_new_high
         move.l d0,hiscore(a6)          new high score
no_new_high
        move.w  #-1,screen_num(a6)
        move.w  #START_LIVES,pacman_stats(a6)
        clr.l   score(a6)               score starts at zero
start_round
        clr.w   time(a6)                time starts at zero
        addq.w  #1,screen_num(a6)       new screen for a new round
        bsr     _draw_all_dots
        bsr     _initial_round_values
start_new_life
        do_snd  <stop_music>
        tst.w   pacman_stats(a6)        0 lives left?
        bgt.s   more_lives_left
         bsr    _game_over
         bra.s  start_game
more_lives_left
        bsr     _fade_out
        sf      fruit_on(a6)            fruit off
        clr.w   energizer_time(a6)      energizer off
        clr.b   ghosts_stop(a6)         ghosts are not stopped
        move.w  #20,ghost_value(a6)     ghost value starts at 200
        clr.w   shadow_stats(a6)        ghosts start with normal attributes
        clr.w   pokey_stats(a6)
        clr.w   speedy_stats(a6)
        clr.w   bashful_stats(a6)
        bsr     _new_status_line
        bsr     _display_score
        bsr     _display_hiscore
        bsr     _copy_background_over
**************************************************************************
        move.w  #PACMAN_START_X,pacman_x(a6)
        move.w  #PACMAN_START_Y,pacman_y(a6)
        move.w  #PACMAN_START_DIR,pacman_dir(a6)
        move.w  #POKEY_START_X,pokey_x(a6)
        move.w  #POKEY_START_Y,pokey_y(a6)
        move.w  #POKEY_START_DIR,pokey_dir(a6)
        move.w  #SHADOW_START_X,shadow_x(a6)
        move.w  #SHADOW_START_Y,shadow_y(a6)
        move.w  #SHADOW_START_DIR,shadow_dir(a6)
        move.w  #BASHFUL_START_X,bashful_x(a6)
        move.w  #BASHFUL_START_Y,bashful_y(a6)
        move.w  #BASHFUL_START_DIR,bashful_dir(a6)
        move.w  #SPEEDY_START_X,speedy_x(a6)
        move.w  #SPEEDY_START_Y,speedy_y(a6)
        move.w  #SPEEDY_START_DIR,speedy_dir(a6)
* copy new data to old data
        movea.l a6,a1                   get base of sprite data
        lea     old_spr_data,a0
        moveq   #9,d0                   40 bytes = 10 long words to do
copy_init_spr_data
        move.l  (a1)+,(a0)+
        dbf     d0,copy_init_spr_data
**************************************************************************
* initial screen
        bsr     _display_sprites
        bsr     _swap_screens
        bsr     _fade_in
        bsr     _long_delay
        bsr     _new_status_line
**************************************************************************
* The main game
**************************************************************************
game_turn
* delay to make the earlier screens slower
        bsr     _screen_delay
* Transfer sprite data to the logical screen
        bsr     _wait_vbi
        bsr     _clear_screen
* copy new data to old data
        movea.l a6,a1                   get base of sprite data
        lea     old_spr_data,a0
        moveq   #9,d0                   40 bytes = 10 long words to do
copy_spr_data
        move.l  (a1)+,(a0)+
        dbf     d0,copy_spr_data
**************************************************************************
* Actual game mechanics
**************************************************************************
* see if pacman wants to move
        movem.w pacman_data(a6),d4-d7   get x,y,stats,dir
        bsr     _check_exits            get exits in d3: ....DURL
        movem.w dxy_joy,d0-d1
        move.w  d7,d2                   save current direction in d2
        cmpi.w  #1,d0                   joystick right
        bne.s   pc_njrt
         moveq  #1,d7                   set new direction to right
         bra.s  pac_go
pc_njrt cmpi.w  #-1,d0                  joystick left
        bne.s   pc_njlt
         moveq  #0,d7                   set new direction to left
         bra.s  pac_go
pc_njlt cmpi.w  #-1,d1                  joystick up
        bne.s   pc_njup
         moveq  #2,d7                   set new direction to up
         bra.s  pac_go
pc_njup cmpi.w  #1,d1                   joystick down
        bne.s   pc_njdn
         moveq  #3,d7                   set new direction to down
         bra.s  pac_go
pc_njdn tst.b   fire                    was the fire button pressed?
        beq.s   pc_njfire
         bra.s  pac_go
pc_njfire
        cmpi.b  #$61,KB_DATA            <Undo;gt; to quit
        beq     finish
pac_go
        btst    d7,d3                   can the pacman go where he wants?
        beq.s   pac_can_go              ok, then go
        btst    d2,d3                   can he cont in original direction?
        bne.s   pac_end                 if not then don't move at all
        move.w  d2,d7                   new dir = original dir
pac_can_go
        cmpi.w  #0,d7                   going left
        bne.s   pc_nolt
         subq.w #SPRITE_SPEED,d4        subtract speed from x
         bra.s  pac_end
pc_nolt cmpi.w  #1,d7                   going right
        bne.s   pc_nort
         addq.w #SPRITE_SPEED,d4        add speed to x
         bra.s  pac_end
pc_nort cmpi.w  #2,d7                   going up
        bne.s   pc_noup
         subq.w #SPRITE_SPEED,d5        subtract speed from y
         bra.s  pac_end
pc_noup
         addq.w #SPRITE_SPEED,d5        must be going down, add speed to y
pac_end
* check if pacman ate a dot or energizer
        bsr     _check_dot_eaten
* check if pacman has gone through the tunnel
        cmpi.w  #32,d4                  if x<=48 then out left tunnel
        bgt.s   pc_no_lt_tunnel
         move.w #260,d4                 put him on the right side
         bra.s  pc_end_tunnel
pc_no_lt_tunnel
        cmpi.w  #264,d4                 if x>=264 then out right tunnel
        blt.s   pc_end_tunnel
         move.w #36,d4                  put him on the left side
pc_end_tunnel
        movem.w d4-d7,pacman_data(a6)   return altered sprite data
**************************************************************************
* move shadow
        movem.w shadow_data(a6),d4-d7   get x,y,stats,dir
* find if the monster is not in the pen
        cmpi.w  #129,d4
        blt.s   sh_int
        cmpi.w  #170,d4
        bge.s   sh_int
        cmpi.w  #75,d5
        blt.s   sh_int
        cmpi.w  #84,d5
        bge.s   sh_int
         move.w #$700,H_PAL+2           back to red
         bsr    _pen_intelligence
         bra.s  done_sh_move
sh_int  btst    #0,d6                   is Shadow just eyes
        beq.s   sh_not_i
         bsr    _eye_intelligence
         bra.s  done_sh_move
sh_not_i
        tst.w   energizer_time(a6)      is pacman energized
        beq.s   sh_chase                if not then chase him
         bsr    _shy_intelligence
         bra.s  done_sh_move
sh_chase
        bsr     _intelligence
done_sh_move
        movem.w d4-d7,shadow_data(a6)
**************************************************************************
* move bashful
        movem.w bashful_data(a6),d4-d7
* find if the monster is not in the pen
        cmpi.w  #129,d4
        blt.s   bs_int
        cmpi.w  #170,d4
        bge.s   bs_int
        cmpi.w  #75,d5
        blt.s   bs_int
        cmpi.w  #84,d5
        bge.s   bs_int
         move.w #$057,H_PAL+18          back to light blue
         bsr    _pen_intelligence
         bra.s  done_bs_move
bs_int
        btst    #0,d6
        beq.s   bs_not_i
         bsr    _eye_intelligence
         bra.s  done_bs_move
bs_not_i
        bsr     _shy_intelligence
done_bs_move
        movem.w d4-d7,bashful_data(a6)
**************************************************************************
* move Speedy
        bsr     _move_speedy
**************************************************************************
* Choice move: Speedy or Pokey
        move.w  time(a6),d0
        and.w   #$f,d0                  time mod 16
        cmpi.w  #1,d0                   every 16 times move Speedy
        bne.s   move_pokey_not_speedy
         bsr    _move_speedy
         bra.s  check_for_collision
move_pokey_not_speedy
        bsr     _move_pokey
**************************************************************************
check_for_collision
        move.w  pacman_x(a6),d4
        move.w  pacman_y(a6),d5
        lea     ghost_data(a6),a0
        moveq   #3,d6                   four ghosts to do
chk_coln_loop
        movem.w (a0),d0-d2              get ghost x,y,stats
        bsr     _check_collision
        tst.b   d3
        beq.s   done_g_coln
         move.w d2,d0
         andi.w #%11,d0
         tst.w  d0                      ghost normal? (ie d0=%00)
         bne.s  coln_n_n
          bsr   _pacman_dead
          bra   start_new_life
coln_n_n cmpi.w #%10,d0                 ghost blue?
         bne.s  done_g_coln
          bset  #0,d2                   set stats, got the ghost
          bclr  #1,d2                   so he's not blue
          move.w d2,4(a0)               put stats back
          move.w ghost_value(a6),d0     increase the score
          ext.l d0
          add.l d0,score(a6)
          add.w d0,d0                   double the ghost value
          move.w d0,ghost_value(a6)     and put it back
          bsr   _display_score
done_g_coln
        addq.l  #8,a0                   next ghost data
        dbf     d6,chk_coln_loop
* now check if pacman has got the fruit
        tst.b   fruit_on(a6)            fruit there?
        beq.s   done_f_coln             no need to check if not
         cmpi.w #98,d5                  check y
         bne.s  done_f_coln
          cmpi.w #138,d4                check x left bound
          blt.s done_f_coln
           cmpi.w #158,d4               check x right bound
           bgt.s done_f_coln
* got the fruit
            tst.w energizer_time(a6)    only make sound if eng off
            bgt.s no_fruit_sound
            do_snd <fruit_sound>
no_fruit_sound
            moveq #0,d0
            move.w fruit_value(a6),d0
            add.l d0,score(a6)
            bsr _display_score
            sf  fruit_on(a6)            turn the fruit off
done_f_coln
**************************************************************************
* force a joystick interupt to occur
jr_loop
        btst.b  #1,KB_CONTROL   is keyboard ready for command
        beq.s   jr_loop         no, loop
        move.b  #$16,KB_DATA    request a joystick packet

        bsr     _display_sprites
        bsr     _swap_screens

        tst.b   ghosts_stop(a6)         ghosts stopped?
        beq.s   no_ghost_stop
         subq.b #1,ghosts_stop(a6)      one less frame to stop
no_ghost_stop
        tst.w   energizer_time(a6)      energizer off?
        beq.s   no_eng_dec              if so don't change
         cmpi.w #100,energizer_time(a6) last few moments of energizer?
         bgt.s  eng_no_flash
          bsr   _flash_ghosts
eng_no_flash
         subq.w #1,energizer_time(a6)   less time to chase ghosts
         bgt.s  no_eng_dec
          bsr   _energizer_off          if -1 then end of time
no_eng_dec
        addq.w  #1,time(a6)             increase time
        move.w  time(a6),d0             check the time
        cmp.w   fruit_appear(a6),d0     time to turn the fruit on?
        bne.s   no_fruit_appear
         st     fruit_on(a6)
no_fruit_appear
        cmp.w   fruit_disappear(a6),d0
        bne.s   next_game_turn
         sf     fruit_on(a6)
next_game_turn
        cmpi.b  #246,num_dots_eaten(a6) have all the dots been eaten
        beq     start_round             new round if so
        bra     game_turn               keep going with the game
**************************************************************************
_initial_round_values
        clr.b   num_dots_eaten(a6)      0 dots eaten at the start
        move.w  #2500,fruit_appear(a6)  fruit appears after x frames
        move.w  #4000,fruit_disappear(a6)
* work out speed and fruit values etc
        move.w  screen_num(a6),d0
        cmpi.w  #20,d0                  screen 20 or more?
        blt.s   not_scr20_
         move.w #7,fruit_type(a6)       keys on this screen
         clr.w  scrn_delay(a6)          0 delay, fast as possible
         move.w #10,ghost_blue(a6)      ghosts blue for only 10 frames
         bra.s  done_init_rnd
not_scr20_
        cmpi.w  #12,d0
        blt.s   not_scr12_19
         move.w #7,fruit_type(a6)
         clr.w  scrn_delay(a6)
         move.w #100,ghost_blue(a6)
         bra.s  done_init_rnd
not_scr12_19
        add.w   d0,d0                   double d0 for word offset
        move.w  fruit_codes(pc,d0.w),fruit_type(a6)
        move.w  scr_delays(pc,d0.w),scrn_delay(a6)
        move.w  blue_time(pc,d0.w),ghost_blue(a6)
done_init_rnd
        move.w  fruit_type(a6),d0
        add.w   d0,d0                   double for word offset
        move.w  fruit_vals(pc,d0.w),fruit_value(a6)
        move.w  fruit_sprite_offset(pc,d0.w),fr_spr_off(a6)
        rts
* the scoring values of each of the 8 fruits
fruit_vals
        dc.w    10,30,50,70,100,200,300,500
fruit_sprite_offset
        dc.w    0,104,208,312,416,520,624,728
* following tables contain data for screens 0-11
fruit_codes
        dc.w    0,1,2,2,3,3,4,4,5,5,6,6
scr_delays
        dc.w    8500,7000,7000,7000,3000,5000,3000,5000
        dc.w    3000,5000,3000,3000
blue_time
        dc.w    600,500,500,500,150,250,150,250,150,250,150,150
**************************************************************************
_move_speedy
         movem.w speedy_data(a6),d4-d7
* find if the monster is not in the pen
        cmpi.w  #129,d4
        blt.s   sd_int
        cmpi.w  #170,d4
        bge.s   sd_int
        cmpi.w  #75,d5
        blt.s   sd_int
        cmpi.w  #84,d5
        bge.s   sd_int
         move.w #$747,H_PAL+26                  back to pink
         bsr    _pen_intelligence
         bra.s  done_sd_move
sd_int
        move.w  d6,d0
        andi.w  #%11,d0
        tst.w   d0                              normal, not blue or eyes?
        bne.s   sd_n_be
         bsr    _less_intelligence
         bra.s  done_sd_move
sd_n_be cmpi.b  #%01,d0                         eyes?
        bne.s   sd_n_e
         bsr    _eye_intelligence
         bra.s  done_sd_move
sd_n_e  bsr     _shy_intelligence               must be blue
done_sd_move
        movem.w d4-d7,speedy_data(a6)
        rts
**************************************************************************
_move_pokey
        movem.w pokey_data(a6),d4-d7
* find if the monster is not in the pen
        cmpi.w  #129,d4
        blt.s   pk_int
        cmpi.w  #170,d4
        bge.s   pk_int
        cmpi.w  #75,d5
        blt.s   pk_int
        cmpi.w  #84,d5
        bge.s   pk_int
         move.w #$730,H_PAL+4                   back to orange
         bsr    _pen_intelligence
         bra.s  done_pk_move
pk_int
        move.w  d6,d0
        and.w   #%11,d0                         mask low two bits
        tst.w   d0                              not blue, not eyes?
        bne.s   pk_n_be
         bsr.s  _intelligence
         bra.s  done_pk_move
pk_n_be cmpi.w  #%01,d0                         eyes?
        bne.s   pk_n_e
         bsr    _eye_intelligence
         bra.s  done_pk_move
pk_n_e  bsr     _shy_intelligence               must be blue
done_pk_move
        movem.w d4-d7,pokey_data(a6)    restore altered sprite data
        rts
**************************************************************************
_check_collision
        sf      d3                      collision flag, off
        sub.w   d4,d0                   check x distance
        blt.s   cc_abs_x
cc_x_ok cmpi.w  #11,d0                  are they closer than 16 pixels?
        bge.s   checked_collision       stop checking if far away
         sub.w  d5,d1                   check y distance
         blt.s  cc_abs_y
cc_y_ok  cmpi.w #10,d1                  closer than 12 pixels?
          slt   d3                      set d3 if there was a collision
checked_collision
        rts
cc_abs_x
        neg.w   d0
        bra.s   cc_x_ok
cc_abs_y
        neg.w   d1
        bra.s   cc_y_ok
**************************************************************************
* intelligence section for Shadow and Pokey
_intelligence
        bsr     _check_exits
        bsr     no_go_back
        movem.w pacman_data(a6),d1-d2
* we now have d3: ....DURL with between 1 and 3 available directions
* eliminate some
sp_lr_choose
        move.b  d3,d0
        and.b   #%0011,d0
        tst.b   d0                      both left and right possible?
        bne.s   sp_ud_choose            if not then nothing to do
         cmp.w  d1,d4                   is pacman to the left or right?
         blt.s  sp_p_r
          bset  #1,d3                   pacman is left so don't go right
          bra.s sp_ud_choose
sp_p_r   bset   #0,d3                   pacman is right so don't go left
sp_ud_choose
        move.b  d3,d0
        and.b   #%1100,d0
        tst.b   d0                      both up and down possible?
        bne.s   sp_choose2              if not then nothing to do
         cmp.w  d2,d5                   pacman up or down?
         blt.s  sp_p_d
          bset  #3,d3                   pacman is up so don't go down

          bra.s sp_choose2
sp_p_d   bset   #2,d3                   pacman is down so don't go up
* now have a maximum of 2 directions
sp_choose2
        sub.w   d4,d1                   how far away in x dir is pacman
        blt.s   sp_abs_x                make positive
sp_ps_x sub.w   d5,d2                   how far away in y dir is pacman
        blt.s   sp_abs_y                make positive
sp_ps_y cmp.w   d1,d2
        bhi.s   sp_2
        bsr     ch_final_dir_1
        bra.s   sp_chosen
sp_2    bsr     ch_final_dir_2
sp_chosen
        rts
sp_abs_x
        neg.w   d1
        bra.s   sp_ps_x
sp_abs_y
        neg.w   d2
        bra.s   sp_ps_y
**************************************************************************
* less intelligence section for Speedy
_less_intelligence
        bsr     _check_exits
        bsr     no_go_back
* we now have d3: ....DURL with between 1 and 3 available directions
        move.w  #17,-(a7)               random()
        trap    #14                     xbios
        addq.l  #2,a7                   tidy
        move.w  d0,rnd_num(a6)
sd_lr_choose
        move.b  d3,d0
        and.b   #%0011,d0
        tst.b   d0                      both left and right possible?
        bne.s   sd_ud_choose            if not then nothing to do
         tst.w  rnd_num(a6)             50% chance
         blt.s  sd_p_r
          bset  #1,d3
          bra.s sd_ud_choose
sd_p_r   bset   #0,d3
sd_ud_choose
        ror     rnd_num(a6)             new random number
        move.b  d3,d0
        and.b   #%1100,d0
        tst.b   d0                      both up and down possible?
        bne.s   sd_choose2              if not then nothing to do
         tst.w  rnd_num(a6)             50% chance
         blt.s  sd_p_d
          bset  #3,d3
          bra.s sd_choose2
sd_p_d   bset   #2,d3
* now maximum of 2 directions
sd_choose2
        ror     rnd_num(a6)             new random number
        tst.w   rnd_num(a6)             50% chance
        blt.s   sd_ch_2
         bsr    ch_final_dir_1
         bra.s  sd_chosen
sd_ch_2 bsr     ch_final_dir_2
sd_chosen
        rts
**************************************************************************
_shy_intelligence
        bsr     _check_exits
        bsr     no_go_back
        movem.w pacman_data(a6),d1-d2
* we now have d3: ....DURL with between 1 and 3 available directions
* eliminate some
bs_lr_choose
        move.b  d3,d0
        and.b   #%0011,d0
        tst.b   d0                      both left and right possible?
        bne.s   bs_ud_choose            if not then nothing to do
         cmp.w  d1,d4                   is pacman to the left or right?
         blt.s  bs_p_r
          bset  #0,d3                   pacman is left so don't go left
          bra.s bs_ud_choose
bs_p_r   bset   #1,d3                   pacman is right so don't go right
bs_ud_choose
        move.b  d3,d0
        and.b   #%1100,d0
        tst.b   d0                      both up and down possible?
        bne.s   bs_choose2              if not then nothing to do
         cmp.w  d2,d5                   pacman up or down?
         blt.s  bs_p_d
          bset  #2,d3                   pacman is up so don't go up
          bra.s bs_choose2
bs_p_d   bset   #3,d3                   pacman is down so don't go down
* maximum of 2 directions now, go as far away from pacman as possible
bs_choose2
        cmp.w   d1,d2
        bls.s   bs_ch_2
        bsr     ch_final_dir_1
        bra.s   bs_chosen
bs_ch_2 bsr     ch_final_dir_2
bs_chosen
        rts
**************************************************************************
_pen_intelligence
        and.b   #%11111100,d6           set not blue & not eyes
        bsr     _less_intelligence      move around randomly in pen
        rts
**************************************************************************
* intelligence section for when the ghosts are eyes returning to the pen
_eye_intelligence
        bsr     _check_all_dir
        bsr.s   no_go_back
* we now have d3: ....DURL with between 1 and 3 available directions
* eliminate some
ey_lr_choose
        move.b  d3,d0
        and.b   #%0011,d0
        tst.b   d0                      both left and right possible?
        bne.s   ey_ud_choose            if not then nothing to do
         cmpi.w #150,d4                 is the pen to the left or right?
         blt.s  ey_p_r
          bset  #1,d3                   pen is left so don't go right
          bra.s ey_ud_choose
ey_p_r   bset   #0,d3                   pen is right so don't go left
ey_ud_choose
        move.b  d3,d0
        and.b   #%1100,d0
        tst.b   d0                      both up and down possible?
        bne.s   ey_choose2              if not then nothing to do
         cmpi.w #75,d5                  is the pen up or down?
         blt.s  ey_p_d
          bset  #3,d3                   pen is up so don't go down
          bra.s ey_choose2
ey_p_d   bset   #2,d3                   pen is down so don't go up
* now have a maximum of 2 directions
ey_choose2
        subi.w  #150,d1                 how far away in x dir is the pen
        blt.s   ey_abs_x                make positive
ey_x_ok subi.w  #75,d2                  how far away in y dir is the pen
        blt.s   ey_abs_y                make positive
ey_y_ok cmp.w   d1,d2
        bhi.s   ey_2
        bsr.s   ch_final_dir_1
        bra.s   ey_chosen
ey_2    bsr.s   ch_final_dir_2
ey_chosen
        rts
ey_abs_x
        neg.w   d1
        bra.s   ey_x_ok
ey_abs_y
        neg.w   d2
        bra.s   ey_y_ok
**************************************************************************
* make sure the ghost dosen't double back (applies to all of them)
no_go_back
        tst.w   d7              check current direction, left?
        bne.s   g_no_l
         ori.w  #%0010,d3       can't turn 180deg and go right
         bra.s  g_ode
g_no_l  cmpi.w  #1,d7           right?
        bne.s   g_no_r
         ori.w  #%0001,d3       can't go left
         bra.s  g_ode
g_no_r  cmpi.w  #2,d7           up?
        bne.s   g_no_u
         ori.w  #%1000,d3       can't go down
         bra.s  g_ode
g_no_u  cmpi.w  #3,d7           down?
        bne.s   g_ode
         ori.w  #%0100,d3       can't go up
g_ode   rts
**************************************************************************
* actually decide on 1 final direction in the order L,R,U,D
ch_final_dir_1
        btst    #0,d3                   left?
        bne.s   g1_nt_l
         moveq  #0,d7                   go left
         bra.s  g1_ghost_go
g1_nt_l btst    #1,d3                   right?
        bne.s   g1_nt_r
         moveq  #1,d7                   go right
         bra.s  g1_ghost_go
g1_nt_r btst    #2,d3                   up?
        bne.s   g1_nt_u
         moveq  #2,d7                   go up
         bra.s  g1_ghost_go
g1_nt_u btst    #3,d3                   down?
        bne.s   done_g1_dir
         moveq  #3,d7                   go down
g1_ghost_go
        bsr.s   move_ghost
done_g1_dir
        rts
**************************************************************************
* actually decide on 1 final direction in the order D,U,R,L
ch_final_dir_2
        btst    #3,d3                   down?
        bne.s   g2_nt_d
         moveq  #3,d7                   go down
         bra.s  g2_ghost_go
g2_nt_d btst    #2,d3                   up?
        bne.s   g2_nt_u
         moveq  #2,d7                   go up
         bra.s  g2_ghost_go
g2_nt_u btst    #1,d3                   right?
        bne.s   g2_nt_r
         moveq  #1,d7                   go right
         bra.s  g2_ghost_go
g2_nt_r btst    #0,d3                   left?
        bne.s   done_g2_dir
         moveq  #0,d7                   go left
g2_ghost_go
        bsr.s   move_ghost
done_g2_dir
        rts
**************************************************************************
* actually move the ghost in the chosen direction
move_ghost
        tst.b   ghosts_stop(a6)         are the ghosts stopped?
        bne.s   g_end_tunnel            don't move them if so
        tst.b   d7                      left (ie d7=%0000)
        bne.s   g_ng_l
         subq.w #SPRITE_SPEED,d4        x:=x-speed
         bra.s  done_g_dir
g_ng_l  cmpi.b  #1,d7                   right
        bne.s   g_ng_r
         addq.w #SPRITE_SPEED,d4        x:=x+speed
         bra.s  done_g_dir
g_ng_r  cmpi.b  #2,d7                   up
        bne.s   g_ng_u
         subq.w #SPRITE_SPEED,d5        y:=y-speed
         bra.s  done_g_dir
g_ng_u  cmpi.b  #3,d7                   down
        bne.s   done_g_dir
         addq.w #SPRITE_SPEED,d5        y:=y+speed
done_g_dir
* check if the ghost has gone through a tunnel
        cmpi.w  #32,d4                  if x<=48 then out left tunnel
        bgt.s   g_no_lt_tunnel
         move.w #263,d4                 put him on the right side
         bra.s  g_end_tunnel
g_no_lt_tunnel
        cmpi.w  #264,d4                 if x>=264 then out right tunnel
        blt.s   g_end_tunnel
         move.w #33,d4                  put him on the left side
g_end_tunnel
        rts
**************************************************************************
_pacman_dead
        do_snd  <dead_sound>            make a sad sound
        subq.w  #1,pacman_stats(a6)     pacman was got, reduce lives
        bsr     _long_delay
        rts
**************************************************************************
_energizer_on
        move.b  #8,ghosts_stop(a6)      ghosts stop for 8 frames
        move.w  ghost_blue(a6),energizer_time(a6)
        movea.l #H_PAL,a0
        move.w  #$037,2(a0)             Shadow blue
        move.w  #$037,4(a0)             Pokey blue
        move.w  #$037,18(a0)            Bashful blue
        move.w  #$037,26(a0)            Speedy blue
* all (non eye) ghosts reverse directions
        lea     shadow_stats(a6),a0
        moveq   #3,d1                   4 ghosts to do
rev_g_loop
        move.w  (a0),d0
        andi.w  #%11,d0
        tst.w   d0                      normal? (ie d0=%00)
        bne.s   no_rev
         move.w 2(a0),d0
         bsr.s  _reverse_ghost
         move.w d0,2(a0)
no_rev  ori.w   #%10,(a0)               set stats, ghosts blue & not eyes
        addq.l  #8,a0                   next ghost
        dbf     d1,rev_g_loop
        rts
_reverse_ghost
        tst.w   d0                      left? (ie d0=0)
        bne.s   gr_no_l
         moveq  #1,d0                   set right
         bra.s  reversed_ghost
gr_no_l cmpi.w  #1,d0                   right?
        bne.s   gr_no_r
         moveq  #0,d0                   set left
         bra.s  reversed_ghost
gr_no_r cmpi.w  #2,d0                   up?
        bne.s   gr_no_u
         moveq  #3,d0                   set down
         bra.s  reversed_ghost
gr_no_u moveq   #2,d0                   must be going down, set to up
reversed_ghost
        rts
**************************************************************************
_energizer_off
        movem.l d0-d1/a0-a1,-(a7)
        do_snd  <stop_music>
        movem.l (a7)+,d0-d1/a0-a1
        movea.l #H_PAL,a0
        move.w  #$700,2(a0)             restore Shadow
        bclr    #1,shadow_stats+1(a6)
        move.w  #$730,4(a0)             restore Pokey
        bclr    #1,pokey_stats+1(a6)
        move.w  #$057,18(a0)            restore Bashful
        bclr    #1,bashful_stats+1(a6)
        move.w  #$747,26(a0)            restore Speedy
        bclr    #1,speedy_stats+1(a6)
        move.w  #20,ghost_value(a6)     reset ghost value
        rts
**************************************************************************
_flash_ghosts
        movea.l #H_PAL,a0
        btst    #1,shadow_stats+1(a6)   Shadow blue?
        beq.s   sh_no_f
         eori.w #$740,2(a0)
sh_no_f btst    #1,pokey_stats+1(a6)    Pokey blue?
        beq.s   pk_no_f
         eori.w #$740,4(a0)
pk_no_f btst    #1,bashful_stats+1(a6)  Bashful blue?
        beq.s   bs_no_f
         eori.w #$740,18(a0)
bs_no_f btst    #1,speedy_stats+1(a6)   Speedy blue?
        beq.s   sd_no_f
         eori.w #$740,26(a0)
sd_no_f rts
**************************************************************************
* find all the directions that the sprite can move in
* 3530 cycles at worst
* in: d4.w=x d5.w=y
* out: d3=....DURL, where 1=wall,0=no wall
* uses: d0-1
_check_exits
        bsr.s   _check_all_dir
        cmpi.w  #148,d4                 check if sprite is above the pen
        bne.s   chkd_exits
         cmpi.w #62,d5
         bne.s  chkd_exits
          addq.w #8,d3                  can't go down if so
* d3 now contains 0000DURL
chkd_exits
        rts
**************************************************************************
_check_all_dir
        moveq   #0,d3                   directions stored in d3
        move.w  d4,d0                   x
        move.w  d5,d1
        addq.w  #1,d1                   y+1
        bsr     _point_test
        cmpi.b  #TRACK,d0
        beq.s   left_not_blocked
        addq.w  #1,d3                   ...L
left_not_blocked
        move.w  d4,d0
        addq.w  #2,d0                   x+2
        move.w  d5,d1
        addq.w  #1,d1                   y+1
        bsr     _point_test
        cmpi.b  #TRACK,d0
        beq.s   right_not_blocked
        addq.w  #2,d3                   ..R.
right_not_blocked
        move.w  d4,d0
        addq.w  #1,d0                   x+1
        move.w  d5,d1                   y
        bsr     _point_test
        cmpi.b  #TRACK,d0
        beq.s   up_not_blocked
        addq.w  #4,d3                   .U..
up_not_blocked
        move.w  d4,d0
        addq.w  #1,d0                   x+1
        move.w  d5,d1
        addq.w  #2,d1                   y+2
        bsr     _point_test
        cmpi.b  #TRACK,d0
        beq.s   down_not_blocked
        addq.w  #8,d3                   D...
down_not_blocked
        rts
**************************************************************************
* check if the pacman has eaten a dot
_check_dot_eaten
        move.w  d4,d0
        addq.w  #8,d0                   x+8
        move.w  d5,d1
        addi.w  #6,d1                   y+6
        bsr     _point_test
        cmpi.b  #DOT,d0
        beq.s   dot_eaten
        cmpi.b  #ENERGIZER,d0
        beq.s   energizer_eaten
        rts
**************************************************************************
dot_eaten
* note that its been eaten
        addq.b  #1,num_dots_eaten(a6)
* make the appropriate noise unless the energizer music is going
        tst.w   energizer_time(a6)
        bne.s   no_dot_noise
         do_snd <dot_noise>
no_dot_noise
* rub out the dot
        move.w  d4,d0
        addq.w  #8,d0                   x+8
        move.w  d5,d1
        addi.w  #6,d1                   y+6
        moveq   #SPACE,d2               colour
        bsr     _point_set
* increase the score by 10
        addq.l  #1,score(a6)
        bsr     _display_score
        rts
**************************************************************************
energizer_eaten
* note that its been eaten
        addq.b  #1,num_dots_eaten(a6)
* make the appropriate noise
        do_snd  <chase_music>
* rub out the energizer
        lea     energizer_dots(pc),a1
        cmpi.w  #156,d4                         left or right
        blt.s   eng_left
         cmpi.w #100,d5                         up or down
         blt.s  e_rt_up
          lea   252(a1),a1                      right & down
          bra.s found_eng
e_rt_up  lea    84(a1),a1                       right & up
         bra.s  found_eng
eng_left
        cmpi.w  #100,d5                         up or down
        blt.s   found_eng
         lea    168(a1),a1                      left and down
found_eng
        moveq   #21,d3                  21 dots make up 1 energizer
erase_eng_loop
        move.w  (a1)+,d0                x
        move.w  (a1)+,d1                y
        moveq   #SPACE,d2               colour
        move.w  d3,-(a7)                save loop counter as its corrupted
        bsr.s   _point_set
        move.w  (a7)+,d3                restore loop counter
        dbf     d3,erase_eng_loop
* increase the score by 50
        addi.l  #5,score(a6)
        bsr     _display_score
        bsr     _energizer_on           effects on
        rts
**************************************************************************
_draw_all_dots
        lea     all_dots(pc),a1
        moveq   #8,d5                   y coords start at 8
dot_lines
        move.w  (a1)+,d4                get num of dots (-1) in this line
each_dot
        move.w  (a1)+,d0                get x value
        move.w  d5,d1                   y value
        moveq   #DOT,d2                 colour=DOT=white
        bsr.s   _point_set
        dbf     d4,each_dot             next dot in this line
        addq.w  #6,d5                   next y value := y+6
        cmpi.w  #176,d5                 last line is y=176
        ble.s   dot_lines               back for next line
* now draw energizers
        lea     energizer_dots(pc),a1
        moveq   #83,d4                  84 dots make up 4 energizers
energizer_loop
        move.w  (a1)+,d0                x
        move.w  (a1)+,d1                y
        moveq   #ENERGIZER,d2           colour
        bsr.s   _point_set
        dbf     d4,energizer_loop
        rts
        SECTION DATA
all_dots
        dc.w    23,56,64,72,80,88,96,104,112,120,128,136,144,168,176,184
         dc.w   192,200,208,216,224,232,240,248,256
        dc.w    5,56,96,144,168,216,256
        dc.w    3,96,144,168,216
        dc.w    5,56,96,144,168,216,256
        dc.w    25,56,64,72,80,88,96,104,112,120,128,136,144,152,160,168
         dc.w   176,184,192,200,208,216,224,232,240,248,256
        dc.w    5,56,96,120,192,216,256
        dc.w    5,56,96,120,192,216,256
        dc.w    19,56,64,72,80,88,96,120,128,136,144,168,176,184,192,216
         dc.w   224,232,240,248,256
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    1,96,216
        dc.w    23,56,64,72,80,88,96,104,112,120,128,136,144,168,176,184
         dc.w   192,200,208,216,224,232,240,248,256
        dc.w    5,56,96,144,168,216,256
        dc.w    5,56,96,144,168,216,256
        dc.w    19,64,72,96,104,112,120,128,136,144,152,160,168,176,184
         dc.w   192,200,208,216,240,248
        dc.w    5,72,96,120,192,216,240
        dc.w    5,72,96,120,192,216,240
        dc.w    19,56,64,72,80,88,96,120,128,136,144,168,176,184,192,216
         dc.w   224,232,240,248,256
        dc.w    3,56,144,168,256
        dc.w    3,56,144,168,256
        dc.w    25,56,64,72,80,88,96,104,112,120,128,136,144,152,160,168
         dc.w   176,184,192,200,208,216,224,232,240,248,256
energizer_dots
        dc.w    55,18,56,18,57,18,54,19,55,19,56,19,57,19,58,19,54,20
        dc.w    55,20,56,20,57,20,58,20,54,21,55,21,56,21,57,21,58,21
        dc.w    55,22,56,22,57,22
        dc.w    255,18,256,18,257,18,254,19,255,19,256,19,257,19,258,19
        dc.w    254,20,255,20,256,20,257,20,258,20,254,21,255,21,256,21
        dc.w    257,21,258,21,255,22,256,22,257,22
        dc.w    55,138,56,138,57,138,54,139,55,139,56,139,57,139,58,139
        dc.w    54,140,55,140,56,140,57,140,58,140,54,141,55,141,56,141
        dc.w    57,141,58,141,55,142,56,142,57,142
        dc.w    255,138,256,138,257,138,254,139,255,139,256,139,257,139
        dc.w    258,139,254,140,255,140,256,140,257,140,258,140,254,141
        dc.w    255,141,256,141,257,141,258,141,255,142,256,142,257,142
        SECTION TEXT
**************************************************************************
* routine equivalent to line-a pset
* 290-298 cycles
* in:   d0=x d1=y d2=colour a4=background screen
* out:
* changes: d0-3,a0
_point_set
        ext.l   d1                      extend y value to 32 bits
        move.w  d1,d3                   copy y
        add.w   d1,d1                   *2
        add.w   d1,d1                   *4
        add.w   d3,d1                   *5
        lsl.w   #5,d1                   *5*32 = y*160
        move.w  d0,d3                   copy x
        ext.l   d3                      extend x to 32 bits
        and.w   #$fff0,d3
        asr.w   #1,d3
        add.l   d3,d1                   total offset in d1
        and.w   #$000f,d0
        movea.l backbase(a6),a0
        adda.w  d1,a0                   screen address+disp in a0
        eori.w  #$f,d0
        clr.w   d1
        bset    d0,d1
        move.w  d1,d0
        not.w   d0
        moveq   #4-1,d3
pset_loop
        ror.w   #1,d2
        bcc.s   pset_clr_bit
        or.w    d1,(a0)+
        dbf     d3,pset_loop
        rts
pset_clr_bit
        and.w   d0,(a0)+
        dbf     d3,pset_loop
        rts
**************************************************************************
* routine equivalent to line-a ptst
* 238-246 cycles.
* in:   d0.w=x, d1.w=y, a4=addr of background screen
* out:  d0=colour
* uses: d0-2,a0
_point_test
        move.w  d1,d2                   copy y
        add.w   d1,d1                   *2
        add.w   d1,d1                   *4
        add.w   d2,d1                   *5
        lsl.w   #5,d1                   *5*32 = y*160
        move.w  d0,d2                   copy x
        and.w   #$fff0,d2
        asr.w   #1,d2
        add.w   d2,d1                   total offset in d1
        and.w   #$000f,d0
        movea.l backbase(a6),a0
        lea     8(a0,d1.w),a0           screen address+8+disp in a0
        eori.w  #$f,d0
        clr.w   d1
        bset    d0,d1
        moveq   #0,d0                   clear d0 ready for colour
* calculate each of the 4 bit planes
        move.w  -(a0),d2                get word from the screen
        and.w   d1,d2                   mask all except wanted bit
        sne     d2
        add.b   d2,d2
        addx.w  d0,d0                   double d0 and add the bit value
        move.w  -(a0),d2                get word from the screen
        and.w   d1,d2                   mask all except wanted bit
        sne     d2
        add.b   d2,d2
        addx.w  d0,d0                   double d0 and add the bit value
        move.w  -(a0),d2                get word from the screen
        and.w   d1,d2                   mask all except wanted bit
        sne     d2
        add.b   d2,d2
        addx.w  d0,d0                   double d0 and add the bit value
        move.w  -(a0),d2                get word from the screen
        and.w   d1,d2                   mask all except wanted bit
        sne     d2
        add.b   d2,d2
        addx.w  d0,d0                   double d0 and add the bit value
* the colour value is now in d0
        rts
**************************************************************************
* Display all necessary sprites on the screen
**************************************************************************
_display_sprites
* first the fruit as everything else goes over the top of it
        tst.b   fruit_on(a6)            is the fruit visible?
        beq.s   display_pacman          don't display if not
         movea.l logbase(a6),a0         screen
         move.w fr_spr_off(a6),d0       offset
         lea    s_fruit(pc),a1          base address of fruit sprites
         adda.w d0,a1                   add the offset
         move.w #148,d4                 x position
         moveq  #98,d5                  y_position
         moveq  #12,d2                  13 lines high
         bsr    _display_sprite_16
display_pacman
        movem.w pacman_data(a6),d4-d7
        lea     s_pacman(pc),a1         a1 holds address of sprite data
        bsr.s   _sprite_direction
* then pokey
        movem.w pokey_data(a6),d4-d7
        btst    #0,d6                   is he eaten
        beq.s   pk_no_i
         lea    s_eyes(pc),a1
         bsr.s  _eyes_direction
         bra.s  display_shadow
pk_no_i lea     s_pokey(pc),a1          a1 holds address of sprite data
        bsr.s   _sprite_direction
display_shadow
        movem.w shadow_data(a6),d4-d7
        btst    #0,d6
        beq.s   sh_no_i
         lea    s_eyes(pc),a1
         bsr.s  _eyes_direction
         bra.s  display_bashful
sh_no_i lea     s_shadow(pc),a1         a1 holds address of sprite data
        bsr.s   _sprite_direction
display_bashful
        movem.w bashful_data(a6),d4-d7
        btst    #0,d6
        beq.s   bs_no_i
         lea    s_eyes(pc),a1
         bsr.s  _eyes_direction
         bra.s  display_speedy
bs_no_i lea     s_bashful(pc),a1        a1 holds address of sprite data
        bsr.s   _sprite_direction
display_speedy
        movem.w speedy_data(a6),d4-d7
        btst    #0,d6
        beq.s   sd_no_i
         lea    s_eyes(pc),a1
         bsr.s  _eyes_direction
         bra.s  finished_displaying
sd_no_i lea     s_speedy(pc),a1         a1 holds address of sprite data
        bsr.s   _sprite_direction
finished_displaying
        rts
* find correct sprite for the direction
* in: d4-d7=spite data, a1=addr of sprite
_sprite_direction
        add.w   d7,d7                   double d7 for word offset
        move.w  sprite_offset(pc,d7.w),d7 offset for correct direction
        adda.w  d7,a1
        movea.l logbase(a6),a0          screen
        moveq   #12,d2                  sprites are 13 lines high
        bsr.s   _display_sprite_16
        rts
* this small table represents 104*dir, where 0<=dir<=3
sprite_offset
        dc.w    0,104,208,312
_eyes_direction
        add.w   d7,d7                   double d7 for word offset
        move.w  eyes_offset(pc,d7.w),d7 offset for correct direction
        adda.w  d7,a1
        movea.l logbase(a6),a0
        moveq   #7,d2                   eyes are 8 lines high
        bsr.s   _display_sprite_16
        rts
* this small table represents 64*dir, where 0<=dir<=3
eyes_offset
        dc.w    0,64,128,192
**************************************************************************
* Handle one complete 16x16 sprite: calculate position, then draw
* in    d2: sprite height - 1
*       d4: sprite x co-ordinate
*       d5: sprite y co-ordinate
*       a0: pointer to base of screen
*       a1: pointer to sprite data
* uses  d1: working
*       a0: pointer to screen position of sprite
* corrupts:     d0-d7,a0-a1

_display_sprite_16
        move.w  d5,d0           * d5 by 160: first make a copy
        add.w   d5,d5           *2
        add.w   d5,d5           *4
        add.w   d0,d5           *5
        lsl.w   #5,d5           *5*32, now we have d5*160
        move.l  d4,d1           calculate x offset
        andi.w  #15,d1          find spr_x mod 16, use for rotations
        lsr.w   #1,d4           divide x by 2
        andi.b  #%11111000,d4   make sure it's a multiple of 8
        add.w   d4,d5           (sprite x offset) + (sprite y offset)
        lea     0(a0,d5.w),a0   screen base + offset in a0

* The actual sprite drawing bit
* in:   d2: height of sprite - 1
*       a0: the sprite's position in screen memory
* uses: d0: sprite mask
*       d4: sprite plane 0
*       d5: sprite plane 1
*       d6: sprite plane 2
*       d7: sprite plane 3

draw_all_16
        moveq   #0,d4           clear all 32 bits of the registers
        moveq   #0,d5
        moveq   #0,d6
        moveq   #0,d7
        movem.w (a1)+,d4-d7     read sprite block, planes 0 to 3
        ror.l   d1,d4           rotate plane 0
        ror.l   d1,d5           rotate plane 1
        ror.l   d1,d6           rotate plane 2
        ror.l   d1,d7           rotate plane 3
        move.l  d4,d0           make the mask
        or.l    d5,d0
        or.l    d6,d0
        or.l    d7,d0
        not.l   d0
        and.w   d0,(a0)         mask the background
        or.w    d4,(a0)+        combine with the sprite, bitplane 0
        and.w   d0,(a0)         mask the background
        or.w    d5,(a0)+        combine with the sprite, bitplane 1
        and.w   d0,(a0)         mask the background
        or.w    d6,(a0)+        combine with the sprite, bitplane 2
        and.w   d0,(a0)         mask the background
        or.w    d7,(a0)+        combine with the sprite, bitplane 3
        swap    d0
        swap    d4              swap high and low words so that the
        swap    d5                low words can be displayed
        swap    d6
        swap    d7
        and.w   d0,(a0)         mask the background
        or.w    d4,(a0)+        combine with the sprite, bitplane 0
        and.w   d0,(a0)         mask the background
        or.w    d5,(a0)+        combine with the sprite, bitplane 1
        and.w   d0,(a0)         mask the background
        or.w    d6,(a0)+        combine with the sprite, bitplane 2
        and.w   d0,(a0)         mask the background
        or.w    d7,(a0)+        combine with the sprite, bitplane 3
        lea     144(a0),a0      move to next line
        dbf     d2,draw_all_16  draw next line of sprite
        rts
**************************************************************************
* corrupts:     d0
_display_score
        movem.l d1-d4/a0-a1,-(a7)
        bsr     _erase_score
        clr.w   d0                      x position of the score
        move.l  score(a6),d4
        bsr.s   _write_score
        movem.l (a7)+,d1-d4/a0-a1
        rts
**************************************************************************
* corrupts:     d0-d4,a0,a1
_display_hiscore
        bsr     _erase_hiscore
        move.w  #272,d0                 x position of the high score
        move.l  hiscore(a6),d4
        bsr.s   _write_score
        rts
**************************************************************************
* changes the score display on the background screen
* this is later copied to the logical screen
* in:   d0=the x position of the score, d4=the actual score
* corrupts:     d0-d4
_write_score
* draw the new score
sc_5    cmpi.l  #100000,d4              get rid of any 100,000s
        blt.s   sc_4
         subi.l #100000,d4
         bra.s  sc_5
sc_4    moveq   #0,d3
sc_4c   cmpi.l  #10000,d4               check for 10,000s
        blt.s   sc_3
         addq.w #1,d3
         subi.l #10000,d4
         bra.s  sc_4c
sc_3    move.w  #34,d1
        move.w  d3,d2
        bsr.s   _text
        moveq   #0,d3
sc_3c   cmpi.w  #1000,d4                check for 1,000s
        blt.s   sc_2
         addq.w #1,d3
         subi.w #1000,d4
         bra.s  sc_3c
sc_2    addq.w  #7,d0
        move.w  #34,d1
        move.w  d3,d2
        bsr.s   _text
        moveq   #0,d3
sc_2c   cmpi.w  #100,d4                 check for 100s
        blt.s   sc_1
         addq.w #1,d3
         subi.w #100,d4
         bra.s  sc_2c
sc_1    addq.w  #7,d0
        move.w  #34,d1
        move.w  d3,d2
        bsr.s   _text
        moveq   #0,d3
sc_1c   cmpi.w  #10,d4                  check for 10s
        blt.s   sc_0
         addq.w #1,d3
         subi.w #10,d4
         bra.s  sc_1c
sc_0    addq.w  #7,d0
        move.w  #34,d1
        move.w  d3,d2
        bsr.s   _text
        moveq   #0,d3
sc_0c   tst.w   d4                      check for 1s (ie d4=0?)
        beq.s   sc_done
         addq.w #1,d3
         subq.w #1,d4
         bra.s  sc_0c
sc_done addq.w  #7,d0
        move.w  #34,d1
        move.w  d3,d2
        bsr.s   _text
        addq.w  #7,d0                   print final '0'
        move.w  #34,d1
        moveq   #0,d2
        bsr.s   _text
        rts
**************************************************************************
* routine to immitate line-a: pchar x,y,char
* in:           d0=x,d1=y,d2=num
* uses:         d0-5,a0-1
* corrupts:     d0-2/a0-1
_text
        movem.l d0/d3-d5,-(a7)                  save registers
        move.w  d0,d3                           x
        move.w  d1,d4                           y
        move.w  d2,d5                           num
        moveq   #0,d0
        lea     digits(pc),a0
        move.w  d5,d0                           number
        andi.w  #$ff,d0                         byte only
        move.w  d0,d1
        lsl.w   #3,d0                           *8
        add.w   d1,d0                           *9
        add.w   d1,d0                           *10 (offset)
        add.l   d0,a0                           digit offset
        movea.l backbase(a6),a1                 print to background screen
        move.w  d4,d0                           y
        move.w  d0,d1
        add.w   d0,d0
        add.w   d0,d0
        add.w   d1,d0
        lsl.w   #5,d0
        move.w  d3,d1                           x
        move.w  d1,d2
        andi.l  #15,d2                          d2=rotations
        lsr.w   #1,d1
        andi.b  #$f8,d1
        add.w   d1,d0
        add.l   d0,a1                           a1=screen offset
        moveq   #4,d3                           5 lines to do
draw_character
        moveq   #0,d1
        move.w  (a0)+,d1                        character line
        ror.l   d2,d1
        move.l  d1,d0
        not.l   d0                              make mask
        and.w   d0,(a1)                         mask the character
        or.w    d1,(a1)+                        plane 0
        and.w   d0,(a1)                         mask the character
        or.w    d1,(a1)+                        plane 1
        and.w   d0,(a1)                         mask the character
        or.w    d1,(a1)+                        plane 2
        and.w   d0,(a1)                         mask the character
        or.w    d1,(a1)+                        plane 3
        swap    d0
        swap    d1
        and.w   d0,(a1)                         mask the character
        or.w    d1,(a1)+                        plane 0
        and.w   d0,(a1)                         mask the character
        or.w    d1,(a1)+                        plane 1
        and.w   d0,(a1)                         mask the character
        or.w    d1,(a1)+                        plane 2
        and.w   d0,(a1)                         mask the character
        or.w    d1,(a1)+                        plane 3
        lea     144(a1),a1                      next line
        dbf     d3,draw_character
        movem.l (a7)+,d0/d3-d5
        rts
**************************************************************************
_game_over
        lea     game_over(pc),a0
        move.l  physbase(a6),a1
        adda.l  #13176,a1               position (112,82)
        moveq   #8,d0                   9 lines high
d_gmov_loop
        moveq   #6-1,d1                 6*4=24 words per line
d_gmov_wds
        movem.w (a0)+,d2-d5
        move.w  d2,d6                   make a mask
        or.w    d3,d6
        or.w    d4,d6
        or.w    d5,d6
        not.w   d6
        and.w   d6,(a1)
        or.w    d2,(a1)+
        and.w   d6,(a1)
        or.w    d3,(a1)+
        and.w   d6,(a1)
        or.w    d4,(a1)+
        and.w   d6,(a1)
        or.w    d5,(a1)+
        dbf     d1,d_gmov_wds
        lea     112(a1),a1              next screen line
        dbf     d0,d_gmov_loop
        bsr     _get_any_key
        rts
**************************************************************************
* load a compressed, low res, Degas screen
* in:           a0=addr of filename, a1=addr to write to
* uses:         d0-d2=general loop & working, d3=scan line loop
*               d4=plane loop, d5=next line start, d6=file handle
*               a0=used by fread(), a1=buffer, a2=screen
* corrupts:     d0-d6,a0-a3
_load_pc1
* first load the file to the logical screen
        move.l  a1,-(a7)                save addr
        clr.w   -(a7)                   open file for reading
        move.l  a0,-(a7)                addr of filename
        move.w  #$3d,-(a7)              f_open
        trap    #1
        addq.l  #8,a7
        move.w  d0,d6                   handle in d6
        tst.l   d0                      error if d0 negative
        bge.s   load_ok
         addq.l #8,a7                   get rid of ret addr & save addr
         bra    finish                  quit the program right now
load_ok
        move.l  logbase(a6),-(a7)       load to logbase
        move.l  #32000,-(a7)            32000 bytes max
        move.w  d6,-(a7)                handle
        move.w  #$3f,-(a7)              f_read
        trap    #1
        lea     12(a7),a7
        movea.l (a7)+,a1                restore addr
* process the file
        movea.l logbase(a6),a0
*       lea     34(a0),a0               skip over palette data etc
        moveq   #0,d3                   scan line offset, 0 to 31840
scanline_loop
        moveq   #0,d4                   plane offset, 0 to 6
plane_loop
        movea.l a1,a2                   base address of screen
        adda.l  d3,a2                   + scan line offset
        adda.l  d4,a2                   + plane offset
        move.l  a2,d5                   nextline = addr + 160
        addi.l  #160,d5
bytes_loop
        moveq   #0,d2
        move.b  (a0)+,d2
        cmpi.b  #128,d2                 check if >128,<128,=128
        bhi.s   gt_128_decompact
        beq.s   next_byte
* this section handles copying bytes exactly
copy_literal_loop
         move.b (a0)+,(a2)              move 1 byte to screen
         bsr.s  _inc_addr
         dbf    d2,copy_literal_loop
         bra.s  next_byte
* this section handles copying 1 byte repeatedly - decompacting
gt_128_decompact
        neg.b   d2
        move.b  (a0)+,d1                byte to copy in d1
copy_byte_loop
        move.b  d1,(a2)                 copy 1 byte to screen
        bsr.s   _inc_addr
        dbf     d2,copy_byte_loop
* now increase all the offsets and check if we've finished
next_byte
        cmp.l   a2,d5                   test(nextline-line)
        bgt.s   bytes_loop
        addq.w  #2,d4                   increase plane offset
        cmpi.w  #6,d4                   loop until plane>3 (ie offset >6)
        ble.s   plane_loop
        add.w   #160,d3                 increase scan line offset
        cmpi.w  #32000,d3               loop until scanline>199
        blt.s   scanline_loop
* close the file
        move.w  d6,-(a7)                handle
        move.w  #$3e,-(a7)              f_close
        trap    #1
        addq.l  #4,a7
        rts
* subroutine to increase the adrress to either the next byte or next plane
_inc_addr
        move.w  a2,d0                   copy the address
        btst    #0,d0                   is it odd?
        beq.s   inc_addr_even
         addq.l #6,a2                   it's odd so add 6+1 (=7) to it
inc_addr_even
        addq.l  #1,a2                   it's even so only add 1
        rts
**************************************************************************
* in:   a4: addr of background screen
* corrupts:     d0,a0-a2
_copy_background_over
        move.l  backbase(a6),a0
        move.l  physbase(a6),a1
        move.l  logbase(a6),a2
        move.w  #7999,d0
copy_back_loop
        move.l  (a0),(a1)+
        move.l  (a0)+,(a2)+
        dbf     d0,copy_back_loop
        rts
**************************************************************************
_new_status_line
* first clear the old one
        movea.l backbase(a6),a0
        lea     29760(a0),a0            start at line 186
        moveq   #12,d0                  13 lines to clear
clr_stat_ln
        moveq   #39,d1                  40 long words per line
clr_stat_wrd
        clr.l   (a0)+
        dbf     d1,clr_stat_wrd
        dbf     d0,clr_stat_ln
* draw pacmen to indicate lives
        cmpi.w  #2,pacman_stats(a6)     at least 2 lives?
        blt.s   dr_no_lives
         lea    s_pacman(pc),a1
         moveq  #46,d4                  x
         move.w #186,d5                 y
         moveq  #12,d2                  height
         movea.l backbase(a6),a0        screen
         bsr    _display_sprite_16
        cmpi.w  #3,pacman_stats(a6)
        blt.s   dr_no_lives             3 lives?
         lea    s_pacman(pc),a1
         moveq  #60,d4                  x
         move.w #186,d5                 y
         moveq  #12,d2                  height
         movea.l backbase(a6),a0        screen
         bsr    _display_sprite_16
dr_no_lives
* draw the required amount of fruit
* d1=screen to start at
        moveq   #0,d1                   default to screen 0 as start
        move.w  screen_num(a6),d0       what screen are we on?
        cmpi.w  #7,d0                   is it above screen 6
        blt.s   scr_less_7
         move.w d0,d1                   start 6 below current
         subq.w #6,d1                   so as to draw 7 fruits only
scr_less_7
        move.w  #252,d4                 start at x=252
        move.w  #186,d5                 y is always 186
        moveq   #12,d2                  height always 12
        move.w  screen_num(a6),d3       current screen number, stop here
fruit_loop
        move.w  d1,d0                   d1 is the screen number
        bsr.s   _fruit_offset
        adda.l  d0,a2                   add mask offset
        lea     s_fruit(pc),a1
        lsl.w   #2,d0                   * d0 by 4, sprites have 4 planes
        adda.l  d0,a1                   add sprite offset
        movem.l d1-d5,-(a7)
        movea.l backbase(a6),a0 screen
        bsr     _display_sprite_16
        movem.l (a7)+,d1-d5
        subi.w  #16,d4                  next fruit is 16 pixels left
        addq.w  #1,d1                   next screen
        cmp.w   d3,d1                   past the current screen
        ble.s   fruit_loop              keep going until so
        rts
**************************************************************************
* in:   d0.w=screen number
* out:  d0.l=fruit offset
_fruit_offset
        cmpi.w  #12,d0                  screen 12 or more?
        blt.s   fruit_not_key
         move.w #182,d0                 keys on this screen
         bra.s  done_f_off
fruit_not_key
        add.w   d0,d0                   double d0 for word offset
        move.w  fruit_offsets(pc,d0.w),d0
done_f_off
        ext.l   d0                      make sure it's 32 bits long
        rts
fruit_offsets
        dc.w    0,26,52,52,78,78,104,104,130,130,156,156
**************************************************************************
* get rid of all 5 sprites and the score by drawing over them
* corrupts:     a2,d4,d5
_clear_screen
        lea     old_spr_data,a2
        movem.w pacman_data(a2),d4-d5
        bsr.s   _erase_sprite
        movem.w pokey_data(a2),d4-d5
        bsr.s   _erase_sprite
        movem.w shadow_data(a2),d4-d5
        bsr.s   _erase_sprite
        movem.w bashful_data(a2),d4-d5
        bsr.s   _erase_sprite
        movem.w speedy_data(a2),d4-d5
        bsr.s   _erase_sprite
        move.w  #148,d4                         erase fruit
        moveq   #98,d5
        bsr.s   _erase_sprite
* move score from background to logical screen
        bsr     _copy_score
        rts
**************************************************************************
* draw over the sprite with a square from the background.
* assume height is 13
* in: d4=x, d5=y
* uses: d0,a0,a1
* corrupts:     d0,d4,d5,a0,a1
_erase_sprite
        move.w  d5,d0           * d5 by 160: first make a copy
        add.w   d5,d5           *2
        add.w   d5,d5           *4
        add.w   d0,d5           *5
        lsl.w   #5,d5           *5*32, now we have d5*160
        lsr.w   #1,d4           divide by 2
        andi.b  #%11111000,d4   make sure it's a multiple of 8
        add.w   d4,d5           (sprite x offset) + (sprite y offset)
        movea.l logbase(a6),a1
        movea.l backbase(a6),a0
        adda.w  d5,a1
        adda.w  d5,a0
* 13 lines to do
        REPT    12
        move.l  (a0)+,(a1)+     lines 1 to 12
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        lea     144(a1),a1
        lea     144(a0),a0
        ENDR
        move.l  (a0)+,(a1)+     line 13
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        rts
**************************************************************************
* corrupts:     a0
_erase_score
* score assumed to start at (0,34) => offset = 0/2+160*34 = 5440
        movea.l backbase(a6),a0
        lea     5440(a0),a0             offset to background
erase_score_loop
        REPT    6
        clr.l   (a0)+                   clear to black
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.w   (a0)+                   clear & draw some wall
        move.w  #%0000000000000001,(a0)+
        clr.w   (a0)+
        move.w  #%0000000000000001,(a0)+
        lea     136(a0),a0      move to next line
        ENDR
        rts
**************************************************************************
* corrupts:     d0,a0
_erase_hiscore
* x=272, y=34 => offset = 272/2+34*160 = 5576
        movea.l backbase(a6),a0
        lea     5576(a0),a0             position on background screen
        moveq   #5,d0                   6 lines to do
erase_hiscore_loop
        clr.l   (a0)+                           clear to black
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        clr.l   (a0)+
        lea     136(a0),a0                      move to next line
        dbf     d0,erase_hiscore_loop
        rts
**************************************************************************
* this routine assumes the score is at (0,34)
* corrupts:     a0,a1
_copy_score
        movea.l logbase(a6),a1
        lea     5440(a1),a1
        movea.l backbase(a6),a0
        lea     5440(a0),a0
* 6 lines to do
        REPT    5
        move.l  (a0)+,(a1)+             lines 1 to 5
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        lea     136(a1),a1
        lea     136(a0),a0
        ENDR
        move.l  (a0)+,(a1)+             6th line
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        move.l  (a0)+,(a1)+
        rts
**************************************************************************
* in:           a3=addr of string to print (nul terminated)
* corrupts:     d0-d2,a0-a2
_print
        tst.b   (a3)                    NUL character for end of string
        beq.s   end_string
        moveq   #0,d0
        move.b  (a3)+,d0
        move.w  d0,-(a7)                character
        move.l  #$30002,-(a7)           b_conout to screen
        trap    #13                     bios
        addq.l  #6,a7                   tidy
        bra.s   _print
end_string
        rts
**************************************************************************
* corrupts:     d0-d3,a0-a2
_get_any_key
        inkey
        tst.b   d0                      was a character returned?
        bne.s   _get_any_key            loop until buffer is clear
        moveq   #-1,d3                  time counter
get_any_key
        addq.l  #1,d3                   increase timer
        cmpi.l  #$7fffffff,d3           have we been waiting long enough
        bne.s   no_key_snd
         do_snd <intro_song>
no_key_snd
        btst.b  #1,KB_CONTROL           is keyboard ready for command
        beq.s   get_any_key             no, loop
        move.b  #$16,KB_DATA            request a joystick packet
        tst.b   fire
        bne.s   got_a_key
        inkey
        swap    d0                      get scan code
        cmpi.b  #$61,d0                 [Undo] to end
        beq     finish
        swap    d0                      get ascii code back
        tst.b   d0                      key pressed?
        beq.s   get_any_key             try again if not
got_a_key
        rts
**************************************************************************
_get_key_colour
        inkey
        tst.b   d0                      was a character returned?
        bne.s   _get_key_colour         loop until buffer is clear
get_key_colour
        btst.b  #1,KB_CONTROL           is keyboard ready for command
        beq.s   get_key_colour          no, loop
        move.b  #$16,KB_DATA            request a joystick packet
        tst.b   fire
        bne.s   got_key_col
        addq.w  #1,H_PAL+4              cycle colours
        inkey
        swap    d0                      get scan code
        cmpi.b  #$61,d0                 [Undo] to quit
        beq     finish
        swap    d0                      get ascii code back
        tst.b   d0                      what key did we get?
        beq.s   get_key_colour          try again if nothing
got_key_col
        rts
**************************************************************************
_delay
        move.l  d0,-(a7)
        move.w  #10000,d0
delay_loop
        mulu    #1,d0
        dbf     d0,delay_loop
        move.l  (a7)+,d0
        rts
**************************************************************************
_long_delay
        movem.l d0-d7/a0-a6,-(a7)
        moveq   #17,d1
delay_loop2
        moveq   #-1,d0                  d0=$ffffffff
delay_loop1
        dbf     d0,delay_loop1
        dbf     d1,delay_loop2
        movem.l (a7)+,d0-d7/a0-a6
        rts
**************************************************************************
_short_delay
        move.l  d0,-(a7)
        move.w  #4000,d0
short_del_loop
        dbf     d0,short_del_loop
        move.l  (a7)+,d0
        rts
**************************************************************************
_screen_delay
        move.w  d0,-(a7)                save d0 so nothing is changed
        move.w  scrn_delay(a6),d0
scrn_del_loop
        dbf     d0,scrn_del_loop
        move.w  (a7)+,d0                restore d0
        rts
**************************************************************************
        SECTION DATA
def_pal         dc.w    $000,$700,$730,$750,$770,$470,$105,$701
                dc.w    $740,$367,$027,$000,$507,$747,$777,$777
title_pal       dc.w    $000,$700,$770,$769,$7d3,$7c4,$74d,$737
                dc.w    $467,$356,$345,$235,$224,$123,$113,$777
digits
                include 'A:\DIGITS09.S'
backfile        dc.b    'P_A_C_MZ.PC1',0
instructions
        dc.b    27,'Y',39,42,'*** INSTRUCTIONS ***'
        dc.b    27,'Y',41,40,'Press any key now to play'
        dc.b    27,'Y',43,43,'During the game:'
        dc.b    27,'Y',44,40,'[Undo] to exit'
        dc.b    27,'Y',45,40,'Joystick controls movement'
        dc.b    27,'Y',50,34,'Comments/advice (money!) to:'
        dc.b    27,'Y',52,36,'W.Barnes. PO Box 599, Sandy Bay,'
        dc.b    27,'Y',53,40,'Tasmania, Australia 7005'
        dc.b    27,'Y',56,42,189,' Warwick Barnes 1991',0

        EVEN
        include 'A:\SPRITES.DAT\ALL_SPRT.S'
game_over
        include 'A:\GRAPHICS\GAMEOVER.S'
stop_music      dc.b    7,$ff,8,$00,9,$00,10,$00,130,0
dead_sound      dc.b    7,$fe,8,$0c,128,140,129,0,1,10,130,1,130,0
fruit_sound     dc.b    7,$fe,8,$0c,128,160,129,0,-10,10,130,1
dot_noise       dc.b    0,$aa,1,$00,6,$00,7,$fe,8,$10,9,$00,10,$00
                dc.b    11,$6d,12,$01,13,$00,130,0
intro_song
        incbin  'A:\SOUND\PACINTRO.XBS'
chase_music
        incbin  'A:\SOUND\PACCHASE.XBS'
title_screen
        incbin  'A:\GRAPHICS\TITLESCR.IMG'
**************************************************************************
        SECTION BSS
        EVEN
all_data        ds.b    var_length
old_spr_data    ds.b    40
dxy_joy
dx_joy          ds.w    1
dy_joy          ds.w    1
vbi_done        ds.b    1
fire            ds.b    1
        EVEN
log_scr         ds.b    32255
back_scr        ds.b    32000

        END