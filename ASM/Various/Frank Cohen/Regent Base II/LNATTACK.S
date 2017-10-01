
***************************************************************************
******                                                               ******
******                         Line Attack!                          ******
******                              by                               ******
******                          Kirk Stover                          ******
******                    Copyright 1989 by ST-LOG                   ******
******                                                               ******
***************************************************************************

                  text

line_A_initialise equ   $a000
line_A_putpixel   equ   $a001
line_A_getpixel   equ   $a002
line_A_line       equ   $a003

gemdos            equ   1
term              equ   0
rawconio          equ   6
conws             equ   9
setblock          equ   74

gem               equ   2

bios              equ   13
bconout           equ   3

xbios             equ   14
initmous          equ   0
dosound           equ   32
kbdvbase          equ   34

stick             equ   0
xloc              equ   2
yloc              equ   4
score             equ   6
kolor             equ   8

*---------------------

main           move.l   a7,a5                ; save stack pointer
               move.l   #mystack,a7          ; and point to our stack
               move.l   4(a5),a5             ; base page start pointer
               move.l   #$100,d0             ; length of base page
               add.l    $0c(a5),d0           ; length of text section
               add.l    $14(a5),d0           ; length of data section
               add.l    $1c(a5),d0           ; length of bss section
               move.l   d0,-(a7)             ; amount of memory to reserve
               move.l   a5,-(a7)             ; starting address of memory
               move.w   #0,-(a7)             ; dummy word
               move.w   #setblock,-(a7)      ; reserve memory
               trap     #gemdos              ; call gemdos
               add.l    #12,a7               ; restore stack
               bsr      open_gem             ; open virtual workstation
               bsr      initialise           ; do housework
               bsr      new_game             ; let's go!
               bsr      terminate            ; more housework
exit           bsr      close_gem            ; close virtual workstation
               move.w   #term,-(a7)          ; back to desktop
               trap     #gemdos              ; call gemdos

*---------------------

call_aes       move.l   #aea7b,d1            ; pointer to aes tables
               move.w   #$c8,d0              ; function code
               trap     #gem                 ; call gem
               rts                           ; return

call_vdi       move.l   #vdipb,d1            ; pointer to vdi tables
               move.w   #$73,d0              ; function code
               trap     #gem                 ; call gem
               rts                           ; return

*---------------------

open_gem       moveq.l  #0,d0                ; use D0 as zero
               move.l   d0,ap1resv           ; zero out reserved parameters
               move.l   d0,ap2resv
               move.l   d0,ap3resv
               move.l   d0,ap4resv
               move.w   #10,opcode           ; appl_init function
               move.w   d0,sintin
               move.w   #1,sintout
               move.w   d0,saddrin
               move.w   d0,saddrout
               bsr      call_aes

               move.w   intout,appl_id       ; save appl_id
               move.w   #77,opcode           ; graf_handle function
               move.w   #0,sintin
               move.w   #5,sintout
               move.w   #0,saddrin
               move.w   #0,saddrout
               bsr      call_aes
               move.w   intout,graf_handle   ; save graf_handle

               move.w   #100,contrl          ; v_opnvwk function
               move.w   #0,contrl+2
               move.w   #11,contrl+6
               move.w   graf_handle,contrl+12
               move.w   #1,intin
               move.w   #1,intin+2
               move.w   #1,intin+4
               move.w   #1,intin+6
               move.w   #1,intin+8
               move.w   #1,intin+10
               move.w   #1,intin+12
               move.w   #1,intin+14
               move.w   #1,intin+16
               move.w   #1,intin+18
               move.w   #2,intin+20
               bsr      call_vdi
               move.w   contrl+12,vdi_handle ; save vdi_handle

               cmp.w    #16,intout+26        ; are we in low-resolution?
               beq      open_gemx            ;   yes, go exit
               move.w   #52,opcode           ;   no, dia7lay form_alert
               move.w   #1,sintin
               move.w   #1,sintout
               move.w   #1,saddrin
               move.w   #0,saddrout
               move.w   #1,intin
               move.l   #res_alert,addrin
               bsr      call_aes
               move.l   #exit,(a7)           ; substitute exit address
open_gemx      rts

*---------------------

close_gem      move.w   #101,opcode          ; v_clsvwk
               move.w   #0,contrl+2
               move.w   #0,contrl+4
               move.w   #0,contrl+6
               move.w   #0,contrl+8
               move.w   vdi_handle,contrl+12
               bsr      call_vdi
               rts

*---------------------

v_clrwk        move.w   #3,contrl
               move.w   #0,contrl+2
               move.w   #0,contrl+6
               move.w   vdi_handle,contrl+12
               bsr      call_vdi
               rts

*---------------------

vst_color      move.w   #22,contrl
               move.w   #0,contrl+2
               move.w   #1,contrl+6
               move.w   vdi_handle,contrl+12
               move.w   d0,intin
               bsr      call_vdi
               rts

*---------------------

vst_effects    move.w   #106,contrl
               move.w   #0,contrl+2
               move.w   #1,contrl+6
               move.w   vdi_handle,contrl+12
               move.w   d0,intin
               bsr      call_vdi
               rts

*---------------------

vst_height     move.w   #12,contrl
               move.w   #1,contrl+2
               move.w   #0,contrl+6
               move.w   vdi_handle,contrl+12
               move.w   #0,ptsin
               move.w   d0,ptsin+2
               bsr      call_vdi
               rts

*---------------------

vg_text        move.w   #8,contrl
               move.w   #1,contrl+2
               move.w   vdi_handle,contrl+12
               move.w   d0,ptsin
               move.w   d1,ptsin+2
               clr.w    d1
               move.l   #intin,a1
               clr.w    d0
vg_text_1      move.b   (a0)+,d0
               beq      vg_text_2
               move.w   d0,(a1)+
               addq.w   #1,d1
               bra      vg_text_1
vg_text_2      move.w   d1,contrl+6
               bsr      call_vdi
               rts

*---------------------

vsf_color      move.w   #25,contrl
               move.w   #0,contrl+2
               move.w   #1,contrl+6
               move.w   vdi_handle,contrl+12
               move.w   d0,intin
               bsr      call_vdi
               rts

*---------------------

vsf_interior   move.w   #23,contrl
               move.w   #0,contrl+2
               move.w   #1,contrl+6
               move.w   vdi_handle,contrl+12
               move.w   d0,intin
               bsr      call_vdi
               rts

*---------------------

vs_color       move.w   #14,contrl
               move.w   #0,contrl+2
               move.w   #4,contrl+6
               move.w   vdi_handle,contrl+12
               move.w   #1,intin
               move.w   (a0)+,intin+2        ; a0 points to rgb value
               move.w   (a0)+,intin+4
               move.w   (a0),intin+6
               bsr      call_vdi
               rts

*---------------------

vswr_mode      move.w   #32,contrl
               move.w   #0,contrl+2
               move.w   #1,contrl+6
               move.w   vdi_handle,contrl+12
               move.w   d0,intin
               bsr      call_vdi
               rts

*---------------------

v_bar          move.w   #11,contrl
               move.w   #2,contrl+2
               move.w   #0,contrl+6
               move.w   #1,contrl+10
               move.w   vdi_handle,contrl+12
               bsr      call_vdi
               rts

*---------------------

mouse_off      move.w   #78,opcode
               move.w   #1,sintin
               move.w   #1,sintout
               move.w   #1,saddrin
               move.w   #0,saddrout
               move.w   #256,intin
               bsr      call_aes
               rts

*---------------------

save_color     move.w   #0,d3
               move.l   #old_color,a3
save_color_1   move.w   #26,contrl           ; vq_color function
               move.w   #0,contrl+2
               move.w   #2,contrl+6
               move.w   vdi_handle,contrl+12
               move.w   d3,intin
               move.w   #0,intin+2
               bsr      call_vdi
               move.w   intout+2,(a3)+
               move.w   intout+4,(a3)+
               move.w   intout+6,(a3)+
               add.w    #1,d3
               cmp.w    #5,d3
               bne      save_color_1
               rts

*---------------------

set_color      move.w   #0,d3
set_color_1    move.w   #14,contrl           ; vs_color function
               move.w   #0,contrl+2
               move.w   #4,contrl+6
               move.w   vdi_handle,contrl+12
               move.w   d3,intin
               move.w   (a3)+,intin+2
               move.w   (a3)+,intin+4
               move.w   (a3)+,intin+6
               bsr      call_vdi
               add.w    #1,d3
               cmp.w    #5,d3
               bne      set_color_1
               rts

*---------------------

initialise     bsr      mouse_off      ; turn the critter off
               bsr      save_color     ; save current color values
               move.l   #new_color,a3  ; point to our colors
               bsr      set_color      ; and use them

               move.w   #kbdvbase,-(a7) ; kbdvbase function
               trap     #xbios         ; call xbios
               addq.l   #2,a7          ; restore stack
               move.l   d0,a0          ; set a0 to returned address
               move.l   a0,save_kbdvbase ; save vector table address
               move.l   24(a0),old_joy ; save old joystick vector
               move.l   #joystick,24(a0) ; substitute our routine

               move.w   #$15,-(a7)     ; interogate mode
               move.w   #4,-(a7)       ; ikbd
               move.w   #bconout,-(a7) ; bconout function
               trap     #bios          ; call bios
               addq.l   #6,a7          ; restore stack

               move.w   #0,flagged     ; turn off joystick flag
               rts

*---------------------

terminate      move.l   #old_color,a3  ; point to saved colors
               bsr      set_color      ; and use them
               move.w   #$1a,-(a7)     ; joystick scan off mode
               move.w   #4,-(a7)       ; ikbd
               move.w   #bconout,-(a7) ; bconout function
               trap     #bios          ; call bios
               addq.l   #6,a7          ; restore stack
               move.l   save_kbdvbase,a0 ; point to vector table
               move.l   old_joy,24(a0) ; restore old joystick vector
               move.l   16(a0),-(a7)   ; mouse vector
               move.l   #mousedata,-(a7) ; mouse parameters
               move.w   #1,-(a7)       ; enable mouse, relative mode
               move.w   #initmous,-(a7) ; initmous function
               trap     #xbios         ; call xbios
               add.l    #12,a7         ; restore stack
               rts

*---------------------

joystick       tst.w    flagged        ; have we read the joystick yet?
               bne      joystick_x     ;   no, go exit
               move.b   0(a0),joy_rec  ;   yes, save new values
               move.b   1(a0),joy_rec+1
               move.b   2(a0),joy_rec+2
               move.w   #1,flagged     ; turn on indicator
joystick_x     rts

*---------------------

read_joy       move.w   #$16,-(a7)     ; interrogate joystick
               move.w   #4,-(a7)       ; ikbd
               move.w   #bconout,-(a7) ; bconout function
               trap     #bios          ; call bios
               addq.l   #6,a7          ; restore stack
read_joy_1     tst.w    flagged        ; is joystick packet available?
               beq      read_joy_1     ;   no, wait for one
               move.w   #0,flagged     ; reset flag
               lea      joy_rec,a0     ; point to joystick record
               move.b   (a0),d0        ; joystick one value
               and.w    #$80,d0        ; isolate fire button status
               move.w   d0,fire_button ; and save it
               move.b   (a0)+,d0       ; joystick one value
               and.w    #$0f,d0        ; isolate direction status
               cmp.b    #1,d0          ; valid direction?
               beq      read_joy_2     ;   yes
               cmp.b    #2,d0          ; valid direction?
               beq      read_joy_2     ;   yes
               cmp.b    #4,d0          ; valid direction?
               beq      read_joy_2     ;   yes
               cmp.b    #8,d0          ; valid direction?
               bne      read_joy_3     ;   no, leave current status unchanged
read_joy_2     move.w   d0,player1     ; save new player 1 direction
read_joy_3     move.b   (a0),d0        ; joystick two value
               and.w    #$0f,d0        ; isolate direction status
               cmp.b    #1,d0          ; valid direction?
               beq      read_joy_4     ;   yes
               cmp.b    #2,d0          ; valid direction?
               beq      read_joy_4     ;   yes
               cmp.b    #4,d0          ; valid direction?
               beq      read_joy_4     ;   yes
               cmp.b    #8,d0          ; valid direction?
               bne      read_joy_5     ;   no, leave current status unchanged
read_joy_4     move.w   d0,player2     ; save new player 2 direction
read_joy_5     move.b   (a0),d0        ; joystick two value
               and.w    #$80,d0        ; isolate fire button status
               or.b     d0,fire_button ; and logical OR with joystick 1
               rts

*---------------------

no_fire        bsr      read_joy       ; read joystick
               tst.w    fire_button    ; is fire button pressed?
               bne      no_fire        ;   yes, go try again
               rts

*---------------------

delay          move.w   #0,d1          ; enter with D0 set for number
delay_1        sub.w    #1,d1          ; of iterations
               bne      delay_1
               sub.w    #1,d0
               bpl      delay_1
               rts

*---------------------

show_score     move.l   #player1,a5    ; point to player 1
               move.w   score(a5),d0   ; move the score
               move.l   #score_one,a0  ; point to ascii conversion area
               bsr      bin_to_dec     ; and convert
               move.l   #player2,a5    ; point to player 2
               move.w   score(a5),d0   ; move the score
               move.l   #score_two,a0  ; point to ascii conversion area
               bsr      bin_to_dec     ; and convert
               move.l   #score_msg,a0  ; point to string
               bsr      write_str      ; and print it
               rts

*---------------------

bin_to_dec     addq.l   #5,a0          ; point to end of conversion area
               move.w   #4,d1          ; loop counter 5 digits - 1
bin_to_dec_1   ext.l    d0             ; extend the sign
               divs     #10,d0         ; divide by decimal ten
               swap     d0             ; use remainder
               move.b   d0,-(a0)       ; and store in string
               add.b    #'0',(a0)      ; convert to ascii
               swap     d0             ; fix register
               dbra     d1,bin_to_dec_1 ; and loop
               rts

*---------------------

pause          bsr      no_fire        ; wait for fire button to be released
pause_1        bsr      read_joy       ; read joystick
               tst.w    fire_button    ; is fire button pressed again?
               beq      pause_1        ;   no, try again
               bsr      no_fire        ;   yes, wait for release
               rts

*---------------------

flash_msg      move.l   a3,a0          ; move string1 pointer to a0
               bsr      write_str      ; and print it
               bsr      read_joy       ; read joystick
               tst.w    fire_button    ; is fire button pressed?
               bne      flash_msg_x    ;   yes, go exit
               move.w   #1,d0          ; delay for
               bsr      delay          ; a while
               bsr      read_joy       ; read joystick
               tst.w    fire_button    ; is fire button pressed?
               bne      flash_msg_x    ;   yes, go exit
               move.l   a4,a0          ; move string2 pointer to a0
               bsr      write_str      ; and print it
               move.w   #1,d0          ; delay for 
               bsr      delay          ; a while
               bra      flash_msg      ; go loop
flash_msg_x    rts

*---------------------

draw_screen    bsr      v_clrwk
               move.w   #73,opcode     ; graf_growbox
               move.w   #8,sintin
               move.w   #1,sintout
               move.w   #0,saddrin
               move.w   #0,saddrout
               move.w   #155,intin
               move.w   #96,intin+2
               move.w   #8,intin+4
               move.w   #6,intin+6
               move.w   #0,intin+8
               move.w   #0,intin+10
               move.w   #320,intin+12
               move.w   #200,intin+14
               bsr      call_aes
               lea      title_msg,a0   ; point to title string
               bsr      write_str      ; and print it
               bsr      show_score     ; print the current score

               dc.w     line_A_initialise
               move.l   a0,line_A_var  ; store line A variable pointer
               move.l   8(a0),intin_addr
               move.l   12(a0),ptsin_addr
               move.l   line_A_var,a0  ; restore line A pointer
               move.w   #000,38(a0)    ; x1 coordinate
               move.w   #009,40(a0)    ; y1 coordinate
               move.w   #319,42(a0)    ; x2 coordinate
               move.w   #009,44(a0)    ; y2 coordinate
               bsr      draw_line
               move.l   line_A_var,a0  ; restore line A pointer
               move.w   #319,38(a0)    ; x1 coordinate
               move.w   #009,40(a0)    ; y1 coordinate
               move.w   #319,42(a0)    ; x2 coordinate
               move.w   #199,44(a0)    ; y2 coordinate
               bsr      draw_line
               move.l   line_A_var,a0  ; restore line A pointer
               move.w   #000,38(a0)    ; x1 coordinate
               move.w   #199,40(a0)    ; y1 coordinate
               move.w   #319,42(a0)    ; x2 coordinate
               move.w   #199,44(a0)    ; y2 coordinate
               bsr      draw_line
               move.l   line_A_var,a0  ; restore line A pointer
               move.w   #000,38(a0)    ; x1 coordinate
               move.w   #009,40(a0)    ; y1 coordinate
               move.w   #000,42(a0)    ; x2 coordinate
               move.w   #199,44(a0)    ; y2 coordinate
               bsr      draw_line
               rts

*---------------------

draw_line      move.w   #0,24(a0)      ; draw red border
               move.w   #0,26(a0)
               move.w   #1,28(a0)
               move.w   #0,30(a0)
               move.w   #$ffff,32(a0)  ; last line
               move.w   #$ffff,34(a0)  ; line mask - solid
               move.w   #000,36(a0)    ; write mode - replace
               dc.w     line_A_line
               rts

*---------------------

draw_pixel     move.l   a5,-(a7)       ; save player pointer
               move.l   intin_addr,a3
               move.l   ptsin_addr,a4
               move.w   xloc(a5),(a4)  ; point to x position
               move.w   yloc(a5),2(a4) ; point to y position
               move.w   kolor(a5),(a3) ; color of pixel
               dc.w     line_A_putpixel
               move.l   (a7)+,a5       ; restore player pointer
               add.w    #1,points      ; add to # of pixels drawn
               rts

*---------------------

get_pixel      move.l   a5,-(a7)       ; save player pointer
               move.l   ptsin_addr,a4
               move.w   xloc(a5),(a4)  ; point to x position
               move.w   yloc(a5),2(a4) ; point to y position
               dc.w     line_A_getpixel
               move.l   (a7)+,a5       ; restore player pointer
               rts                     ; return color value in D0
 
*---------------------

write_str      move.l   a0,-(a7)       ; string pointer
               move.w   #conws,-(a7)   ; write string function
               trap     #gemdos        ; call gemdos
               addq.l   #6,a7          ; restore stack
               rts

*---------------------

shrink_box     move.l   #shrink_noise,-(a7)
               move.w   #dosound,-(a7) ; output sound string
               trap     #xbios         ; call xbios
               addq.l   #6,a7          ; restore stack
               move.w   #74,opcode     ; graf_shrinkbox
               move.w   #8,sintin
               move.w   #1,sintout
               move.w   #0,saddrin
               move.w   #0,saddrout
               bsr      call_aes
               move.w   #0,d0          ; short delay
               bsr      delay
               rts

*---------------------

grow_box       move.l   #explode_noise,-(a7)
               move.w   #dosound,-(a7) ; output sound string
               trap     #xbios         ; call xbios
               addq.l   #6,a7          ; restore stack
               move.w   #73,opcode     ; graf_growbox
               move.w   #8,sintin
               move.w   #1,sintout
               move.w   #0,saddrin
               move.w   #0,saddrout
               bsr      call_aes
               move.l   #new_color+6,a0 ; point to color 1
               bsr      vs_color       ; and restore
               rts

*---------------------

box_color      move.w   kolor(a5),d0   ; player color value
               add.w    #1,d0          ;
               mulu     #6,d0          ; calculate color offset
               move.l   #new_color,a0  ; and add to
               add.w    d0,a0          ; color table pointer
               bsr      vs_color       ; go set color
               rts

*---------------------

explode        bsr      box_color      ; set player explode color
               move.w   xloc(a5),intin ; starting x coordinate
               move.w   yloc(a5),intin+2 ; starting y coordinate
               move.w   #1,intin+4     ; starting width
               move.w   #1,intin+6     ; starting height
               move.w   xloc(a5),d0    ; current x position
               cmp.w    #29,d0         ; are we at left border?
               bgt      explode_1      ;   no
               move.w   #0,d0          ; use left border
               bra      explode_2      ; as new end x coord
explode_1      sub.w    #30,d0         ; calculate new x coord
explode_2      move.w   d0,intin+8     ; ending x coordinate
               move.w   yloc(a5),d1    ; current y position
               cmp.w    #29,d1         ; are we at top border?
               bgt      explode_3      ;   no
               move.w   #9,d1          ; use top border
               bra      explode_4      ; as new end y coord
explode_3      sub.w    #20,d1         ; calculate new y coord
explode_4      move.w   d1,intin+10    ; ending y coordinate
               cmp.w    #260,d0        ; are we at right border?
               blt      explode_5      ;   no
               sub.w    #319,d0        ; calculate ending
               neg.w    d0             ; width
               move.w   d0,intin+12    ; and save
               bra      explode_6
explode_5      move.w   #60,intin+12   ; save ending width
explode_6      cmp.w    #160,d1        ; are we at bottom border?
               blt      explode_7      ;   no
               sub.w    #200,d1        ; calculate ending
               neg.w    d1             ; height
               move.w   d1,intin+14    ; and save
               bra      explode_8
explode_7      move.w   #40,intin+14   ; save ending height
explode_8      bsr      grow_box       ; show expanding box
               move.w   #1,d0          ; and delay for
               bsr      delay          ; awhile
               rts

*---------------------

wait_loop      move.w   skill,d0       ; use skill level as delay factor
wait_loop_1    add.w    #1,d0          ; increment counter
               cmp.w    #10,d0         ; maximum reached?
               beq      wait_loop_x    ;   yes, go exit
               move.w   #1000,d1       ; enter delay loop
wait_loop_2    dbra     d1,wait_loop_2 ;
               bra      wait_loop_1    ; try again
wait_loop_x    rts

*---------------------

find_winner    move.w   points,d5      ; divide the # of points
               asr.w    #1,d5          ; by two
               cmp.w    #1,done        ; is player 1 color = done?
               bne      find_winner_1  ;   no
               move.l   #win2_msg,a3   ; player 2 is the winner
               move.l   #player2,a5    ; point to player 2
               add.w    d5,score(a5)   ; add to the score
               move.l   #player1,a5    ; point to player 1
               bra      find_winner_x  ; go explode it
find_winner_1  cmp.w    #2,done        ; is player 2 color = done?
               bne      find_winner_2  ;   no
               move.l   #win1_msg,a3   ; player 1 is the winner
               move.l   #player1,a5    ; point to player 1
               add.w    d5,score(a5)   ; add to the score
               move.l   #player2,a5    ; point to player 2
               bra      find_winner_x  ; go explode it
find_winner_2  move.l   #tie_msg,a3    ; players tied
               move.l   #player1,a5    ; point to player 1
               add.w    d5,score(a5)   ; add to the score
               bsr      explode        ; go explode it
               move.l   #player2,a5    ; point to player 2
               add.w    d5,score(a5)   ; add to the score
find_winner_x  bsr      explode        ; explode player pointed to by a5
               bsr      show_score     ; show new score
               move.l   a3,a0          ; point to winner message
               bsr      write_str      ; and print it
               move.w   #8,d0          ; delay counter
               bsr      delay          ; wait for awhile
               rts

*---------------------

skill_bar      move.w   #1,d0          ; color = white
               bsr      vsf_color      ; set fill color
               move.w   #59,ptsin      ; bar beg x coordinate
               move.w   #109,ptsin+2   ; bar beg y coordinate
               move.w   #260,ptsin+4   ; bar end x coordinate
               move.w   #121,ptsin+6   ; bar end y coordinate
               bsr      v_bar          ; draw bar
               move.w   #2,d0          ; color = blue
               bsr      vsf_color      ; set fill color
               move.w   #60,ptsin      ; bar beg x coordinate
               move.w   #110,ptsin+2   ; bar beg y coordinate
               move.w   skill,d0       ; calculate level of
               mulu     #20,d0         ; skill for bar
               add.w    #60,d0         ; indicator and use for
               move.w   d0,ptsin+4     ; bar end x coordinate
               move.w   #120,ptsin+6   ; bar end y coordinate
               bsr      v_bar          ; draw bar
               rts

*---------------------

rounds_bar     move.w   #1,d0          ; color = white
               bsr      vsf_color      ; set fill color
               move.w   #59,ptsin      ; bar beg x coordinate
               move.w   #149,ptsin+2   ; bar beg y coordinate
               move.w   #260,ptsin+4   ; bar end x coordinate
               move.w   #161,ptsin+6   ; bar end y coordinate
               bsr      v_bar          ; draw bar
               move.w   #3,d0          ; color = green
               bsr      vsf_color      ; set fill color
               move.w   #60,ptsin      ; bar beg x coordinate
               move.w   #150,ptsin+2   ; bar beg y coordinate
               move.w   rounds,d0      ; calculate number of
               mulu     #20,d0         ; rounds for bar
               add.w    #60,d0         ; indicator and use for
               move.w   d0,ptsin+4     ; bar end x coordinate
               move.w   #160,ptsin+6   ; bar end y coordinate
               bsr      v_bar          ; draw bar
               rts

*---------------------

new_game       bsr      v_clrwk        ; clear the screen
               move.w   #4,d0          ; color = red
               bsr      vst_color      ; set text color
               move.w   #5,d0          ; effects = bold and italic
               bsr      vst_effects    ; set text effects
               move.w   #60,d0         ; height = 60
               bsr      vst_height     ; set text height
               move.w   #60,d0         ; x location
               move.w   #34,d1         ; y location
               move.l   #gr_title,a0   ; title string
               bsr      vg_text        ; print graphic text
               move.w   #1,d0          ; color = white
               bsr      vst_color      ; set text color
               move.w   #0,d0          ; effects = normal
               bsr      vst_effects    ; set text effects
               move.w   #6,d0          ; height = 6
               bsr      vst_height     ; set text height
               move.w   #106,d0        ; x location 
               move.w   #56,d1         ; y location
               move.l   #gr_author,a0  ; author string
               bsr      vg_text        ; print graphic text
               move.w   #2,d0          ; color = blue
               bsr      vst_color      ; set text color
               move.w   #8,d0          ; height = 8 pixels high
               bsr      vst_height     ; set text height
               move.w   #78,d0         ; x location
               move.w   #100,d1        ; y location
               move.l   #gr_skill,a0   ; skill string
               bsr      vg_text        ; print graphic text
               move.w   #47,d0         ; x location
               move.w   #119,d1        ; y location
               move.l   #gr_minus,a0   ; - string
               bsr      vg_text        ; print graphic text
               move.w   #263,d0        ; x location
               move.w   #119,d1        ; y location
               move.l   #gr_plus,a0    ; + string
               bsr      vg_text        ; print graphic text
               move.w   #3,d0          ; color = green
               bsr      vst_color      ; set text color
               move.w   #78,d0         ; x location
               move.w   #140,d1        ; y location
               move.l   #gr_rounds,a0  ; rounds string
               bsr      vg_text        ; print graphic text
               move.w   #47,d0         ; x location
               move.w   #159,d1        ; y location
               move.l   #gr_minus,a0   ; - string
               bsr      vg_text        ; print graphic text
               move.w   #263,d0        ; x location
               move.w   #159,d1        ; y location
               move.l   #gr_plus,a0    ; + string
               bsr      vg_text        ; print graphic text
               move.w   #4,d0          ; color = red
               bsr      vst_color      ; set text color
               move.w   #90,d0         ; x location
               move.w   #180,d1        ; y location
               move.l   #gr_fire,a0    ; fire string
               bsr      vg_text        ; print graphic text
               move.w   #1,d0          ; fill = solid
               bsr      vsf_interior   ; set fill interior style
               move.w   #1,d0          ; write mode = replace
               bsr      vswr_mode      ; set write mode
               bsr      skill_bar      ; draw skill bar
               bsr      rounds_bar     ; draw rounds bar
               bsr      no_fire        ; wait for no fire button

game_level     move.w   #0,player1     ; zero out joystick status
               bsr      read_joy       ; read joystick 1
               tst.w    fire_button    ; fire button pressed?
               bne      game_init      ;   yes, initialize game
               move.w   #$ff,-(a7)     ; check keyboard for characters
               move.w   #rawconio,-(a7) ; no echo
               trap     #gemdos        ; call gemdos
               addq.l   #4,a7          ; restore stack
               swap     d0             ; check key code
               cmp.w    #$61,d0        ; is it UNDO key?
               bne      game_level_0   ;   no
               rts                     ; END OF GAME
game_level_0   move.w   #0,d0          ; wait for a 
               bsr      delay          ; little while
               move.w   player1,d0     ; use joystick 1 status
               cmp.w    #1,d0          ; joystick up?
               bne      game_level_1   ;   no
               cmp.w    #9,skill       ; maximum skill?
               beq      game_level     ;   yes
               add.w    #1,skill       ; increment skill
               bsr      skill_bar      ; redraw bar
               bra      game_level     ; loop
game_level_1   cmp.w    #2,d0          ; joystick down?
               bne      game_level_2   ;   no
               cmp.w    #1,skill       ; minimum skill?
               beq      game_level     ;   yes
               sub.w    #1,skill       ; decrement skill
               bsr      skill_bar      ; redraw bar
               bra      game_level     ; loop
game_level_2   cmp.w    #4,d0          ; joystick left?
               bne      game_level_3   ;   no
               cmp.w    #1,rounds      ; minimum rounds?
               beq      game_level     ;   yes
               sub.w    #1,rounds      ; decrement rounds
               bsr      rounds_bar     ; redraw bar
               bra      game_level     ; loop
game_level_3   cmp.w    #8,d0          ; joystick right?
               bne      game_level     ;   no
               cmp.w    #9,rounds      ; maximum rounds?
               beq      game_level     ;   yes
               add.w    #1,rounds      ; increment rounds
               bsr      rounds_bar     ; redraw bar
               bra      game_level     ; loop

game_init      move.l   #player1,a5    ; point to player 1
               move.w   #0,score(a5)   ; zero out score
               move.l   #player2,a5    ; point to player 2
               move.w   #0,score(a5)   ; zero out score
               move.b   #'0',round_no  ; reset round number

new_round      bsr      draw_screen    ; create playing screen

               move.l   #player1,a5    ; point to player 1
               move.w   #8,stick(a5)   ; default stick to right
               move.w   #119,xloc(a5)  ; beginning x coord
               move.w   #104,yloc(a5)  ; beginning y coord
               bsr      box_color      ; set color for player 1
               move.w   #99,intin      ; set coordinates for shrinkbox
               move.w   #88,intin+2
               move.w   #40,intin+4
               move.w   #32,intin+6
               move.w   #49,intin+8
               move.w   #48,intin+10
               move.w   #140,intin+12
               move.w   #112,intin+14
               bsr      shrink_box     ; draw shrinking box
               bsr      draw_pixel     ; draw the pixel

               move.w   #1,d0          ; wait for a
               bsr      delay          ; little while

               move.l   #player2,a5    ; point to player 2
               move.w   #4,stick(a5)   ; default stick to left
               move.w   #200,xloc(a5)  ; beginning x coord
               move.w   #104,yloc(a5)  ; beginning y coord
               bsr      box_color      ; set color for player 2
               move.w   #180,intin     ; set coordinates for shrinkbox
               move.w   #88,intin+2
               move.w   #40,intin+4
               move.w   #32,intin+6
               move.w   #130,intin+8
               move.w   #48,intin+10
               move.w   #140,intin+12
               move.w   #112,intin+14
               bsr      shrink_box     ; draw shrinking box
               bsr      draw_pixel     ; draw the pixel

               add.b    #1,round_no    ; increment round number
               move.w   #0,done        ; reset DONE flag
               move.w   #0,points      ; reset pixel counter
               move.w   #3,sound_count ; reset sound counter

               bsr      no_fire        ; wait for no fire button
               move.l   #round_msg,a3  ; pointer to round # string
               move.l   #fire_msg,a4   ; pointer to fire string
               bsr      flash_msg      ; go flash messages
               move.l   #game_msg,a0   ; point to game string
               bsr      write_str      ; and print it
               bsr      no_fire        ; wait for no fire button

process        bsr      read_joy       ; read joystick
               tst.w    fire_button    ; fire button pressed?
               beq      process_1      ;   no
               bsr      pause          ; go pause game
process_1      move.l   #player1,a5    ; point to player 1
               bsr      joy_direct     ; and move it
               move.l   #player2,a5    ; point to player 2
               bsr      joy_direct     ; and move it
               add.w    #1,sound_count ; increment sound delay
               cmp.w    #3,sound_count ; time for sound?
               blt      process_2      ;   no
               move.l   #move_noise,-(a7) ; point to move noise
               move.w   #dosound,-(a7) ; and output the sound
               trap     #xbios         ; call xbios
               addq.l   #6,a7          ; restore stack
               move.w   #0,sound_count ; reset delay counter
process_2      bsr      wait_loop      ; delay for skill level
               tst.w    done           ; any injuries yet?
               beq      process        ;   no, go loop
               bsr      find_winner    ; find who died
               move.w   rounds,d0      ; convert # of rounds to ascii
               add.w    #'0',d0        ; and compare with current round
               cmp.b    round_no,d0    ; maximum reached?
               bgt      new_round      ; no, let's play again
               move.l   #done_msg,a3   ; point to game over string
               move.l   #tie_msg,a4    ; default to tie game
               move.l   #player1,a5    ; point to player 1
               move.w   score(a5),d0   ; and move score
               move.l   #player2,a5    ; point to player 2
               cmp.w    score(a5),d0   ; compare the scores
               beq      process_4      ; tie game
               blt      process_3      ; player 2 wins
               move.l   #win1_msg,a4   ; point to winner 1 string
               bra      process_4      ;
process_3      move.l   #win2_msg,a4   ; point to winner 2 string
process_4      bsr      no_fire        ; wait for no fire button
               bsr      flash_msg      ; flash the messages
               bra      new_game       ; start over

*---------------------

joy_direct     move.w   stick(a5),d0   ; D0 contains joystick status
               cmp.b    #1,d0          ; is it up?
               beq      joy_up         ;   yes
               cmp.b    #2,d0          ; is it down?
               beq      joy_down       ;   yes
               cmp.b    #4,d0          ; is it left?
               beq      joy_left       ;   yes
               cmp.b    #8,d0          ; is it right?
               beq      joy_right      ;   yes
joy_direct_x   rts

joy_up         sub.w    #1,yloc(a5)    ; decrement y location
               bsr      get_pixel      ; get pixel color
               cmp.w    #0,d0          ; is it black?
               beq      joy_up_1       ;   yes
               move.w   kolor(a5),d0   ; add player color to
               add.w    d0,done        ; DONE flag
joy_up_1       bsr      draw_pixel     ; draw it
               rts

joy_down       add.w    #1,yloc(a5)    ; increment y location
               bsr      get_pixel      ; get pixel color
               cmp.w    #0,d0          ; is it black?
               beq      joy_down_1     ;   yes
               move.w   kolor(a5),d0   ; add player color to
               add.w    d0,done        ; DONE flag
joy_down_1     bsr      draw_pixel     ; draw it
               rts

joy_left       sub.w    #1,xloc(a5)    ; decrement x location
               bsr      get_pixel      ; get pixel color
               cmp.w    #0,d0          ; is it black?
               beq      joy_left_1     ;   yes
               move.w   kolor(a5),d0   ; add player color to 
               add.w    d0,done        ; DONE flag
joy_left_1     bsr      draw_pixel     ; draw it
               rts

joy_right      add.w    #1,xloc(a5)    ; increment x location
               bsr      get_pixel      ; get pixel color
               cmp.w    #0,d0          ; is it black?
               beq      joy_right_1    ;   yes
               move.w   kolor(a5),d0   ; add player color to
               add.w    d0,done        ; DONE flag
joy_right_1    bsr      draw_pixel     ; draw it
               rts

*---------------------

line_A_var     ds.l  1
intin_addr     ds.l  1
ptsin_addr     ds.l  1

mousedata      dc.b  0,0,1,1

save_kbdvbase  ds.l  1
old_joy        ds.l  1
joy_rec        ds.b  3
joy_work       ds.b  3
flagged        ds.w  1
fire_button    ds.w  1
done           ds.w  1
sound_count    ds.w  1
points         ds.w  1
skill          dc.w  5
rounds         dc.w  5

player1        dc.w  0,119,104,0,1     ; joystick,x,y,score,kolor
player2        dc.w  0,200,104,0,2     ; joystick,x,y,score,kolor

old_color      ds.w  3*5
new_color      dc.w  0,0,0             ; black
               dc.w  1000,1000,1000    ; white
               dc.w  0,0,1000          ; blue
               dc.w  0,1000,0          ; green
               dc.w  1000,0,0          ; red

title_msg      dc.b  27,'H'
               dc.b  27,'b','1','ONE       '
               dc.b  27,'b','4','    LINE ATTACK!    '
               dc.b  27,'b','2',' TWO      '
               dc.b  0

score_msg      dc.b  27,'Y',32,36,27,'b','1'
score_one      dc.b  '00000'
               dc.b  27,'Y',32,67,27,'b','2'
score_two      dc.b  '00000'
               dc.b  0

round_msg      dc.b  27,'Y',32,42,27,'b','4','       ROUND '
round_no       dc.b  '1      ',0

game_msg       dc.b  27,'Y',32,42,27,'b','4','    LINE ATTACK!    ',0
fire_msg       dc.b  27,'Y',32,42,27,'b','4',' Press FIRE button  ',0
win1_msg       dc.b  27,'Y',32,42,27,'b','1',' ONE is the winner! ',0
win2_msg       dc.b  27,'Y',32,42,27,'b','2',' TWO is the winner! ',0
tie_msg        dc.b  27,'Y',32,42,27,'b','4','      TIE GAME!     ',0
done_msg       dc.b  27,'Y',32,42,27,'b','4','      GAME OVER     ',0

shrink_noise   dc.b  $00,$08,$01,$02,$02,$00,$03,$00,$04,$00,$05,$00
               dc.b  $06,$00,$07,$fe,$08,$10,$09,$00,$0a,$00,$0b,$00
               dc.b  $0c,$00,$0d,$0d,$80,$08,$81,$00,$02,$20,$07,$ff
               dc.b  $ff,$00

explode_noise  dc.b  $00,$00,$01,$00,$02,$00,$03,$00,$04,$00,$05,$00
               dc.b  $06,$1f,$07,$f7,$08,$10,$09,$00,$0a,$00,$0b,$00
               dc.b  $0c,$20,$0d,$00,$ff,$00

move_noise     dc.b  $00,$00,$01,$00,$02,$00,$03,$00,$04,$00,$05,$00
               dc.b  $06,$0a,$07,$f7,$08,$10,$09,$00,$0a,$00,$0b,$80
               dc.b  $0c,$01,$0d,$00,$ff,$00

gr_title       dc.b  'LINE ATTACK!',0
gr_author      dc.b  'by Kirk Stover',0
gr_skill       dc.b  'SKILL LEVEL ',2,' ',1,0
gr_rounds      dc.b  'ROUNDS/GAME ',4,' ',3,0
gr_fire        dc.b  'FIRE to start',0
gr_plus        dc.b  '+',0
gr_minus       dc.b  '-',0

res_alert      dc.b  '[1][Low resolution only!][SORRY]',0

*---------------------

appl_id        ds.w  1
graf_handle    ds.w  1
vdi_handle     ds.w  1

aea7b          dc.l  contrl,global,intin,intout,addrin,addrout
vdipb          dc.l  contrl,intin,ptsin,intout,ptsout

contrl         ds.w  0
opcode         ds.w  1
sintin         ds.w  1
sintout        ds.w  1
saddrin        ds.w  1
saddrout       ds.l  1
               ds.w  8

global         ds.w  0
apversion      ds.w  1
apcount        ds.w  1
apid           ds.w  1
apprivate      ds.l  1
apptree        ds.l  1
ap1resv        ds.l  1
ap2resv        ds.l  1
ap3resv        ds.l  1
ap4resv        ds.l  1

intin          ds.w  128
ptsin          ds.w  128
intout         ds.w  128
ptsout         ds.w  128
addrin         ds.w  128
addrout        ds.w  128

*---------------------

               ds.w  512
mystack        ds.w  0
               ds.w  5

               end

