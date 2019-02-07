.globl    _init                    * global functions
.globl    _do_raster
.globl    _set_source
.globl    _xor_image
.globl    _kill_sprite
.globl    _get_free
.globl    _load_sprite
.globl    _save_sprite
.globl    _wipe_out

addr           .equ      0         * these correspond directly to
word_length    .equ      4         * the C structure
byte_length    .equ      6
width          .equ      8
height         .equ      10
new_x          .equ      12
new_y          .equ      14
x              .equ      16
y              .equ      18
new            .equ      20
enable         .equ      21
plane          .equ      22
frame          .equ      23
next_frame     .equ      24
advance_frame  .equ      25
last_frame     .equ      26


.text



_set_source:                       * take pointer from stack and
move.l    4(sp), real_screen       * make it the source screen
rts



_init:                             * raster initialization routine
move.l    4(sp), raster
move.w    #2, -(sp)                * get the system screen address
trap      #14
addq.l    #2, sp
move.l    d0, real_screen

move.l    #-1, -(sp)               * get amount of free ram
move.w    #$48, -(sp)
trap      #1
addq.l    #6, sp
cmp.l     #$0001d000, d0           * if less than 116K, then abort
blt       forget_it

move.l    #$0001b000, -(sp)        * reserve 108K
move.w    #$48, -(sp)
trap      #1
addq.l    #6, sp

tst.l     d0                       * error?
bmi       forget_it

move.l    d0, alloc                * save the address so it can be
move.w    #4, n_alloc              * Free'd later and increment
*                                  * pointer to next alloc 
andi.l    #$ffff00, d0             * make sure screen is on a 256 byte
addi.l    #$100, d0                * boundary
move.l    d0, screen1

addi.l    #$00008000, d0           * make room for next screen
move.l    d0, screen2

addi.l    #$00008000, d0
move.l    d0, list

addi.l    #$800, d0                * address of sprite memory
move.l    d0, where
move.l    #$a000, size             * size is 40K

move.l    #255, d0                 * clear memory managment list
move.l    list, a0
clear_list:
     clr.l     (a0)+
     clr.l     (a0)+
     dbf       d0, clear_list

move.l    #111, d0                 * clear raster structure
move.l    raster, a0
clear_ras:
     clr.l     (a0)+
     dbf       d0, clear_ras

move.w    #420, d0                 * initialize some raster values
move.l    raster, a0
set_new_x:
     move.w    #-1, new_x(a0, d0.w)
     move.b    #-1, new(a0, d0.w)
     sub.w     #28, d0
     bpl       set_new_x
move.w    #0, d0
rts

forget_it:                         * a branch is made here if error
move.w    #-1, d0
rts




_do_raster:                        * main raster routine
move.w    4(sp), tell_gem
movem.l   d0-d7/a0-a6, -(sp)

move.w    #0, glo_error            * clear global error variable

move.l    real_screen, a0          * get address of the main screen
move.l    screen2, a1              * and copy it to the secondary
move.l    #499, d0                 * screen that it not being displayed
cpy:
     move.l    (a0)+, (a1)+        * 16 move instructions; almost twice
     move.l    (a0)+, (a1)+        * as fast as using one
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     move.l    (a0)+, (a1)+
     dbf       d0, cpy

move.l    screen1, a0              * exchange secondary screen pointers
move.l    screen2, screen1
move.l    a0, screen2

move.l    raster, a2               * address of the raster structure
move.w    #420, d5                 * start at last structure
l13:
     tst.w     new_x(a2, d5.w)     * if new_x is negative, then the
     bmi       l14                 * sprite will not be defined

     move.w    #0, loc_error       * if defining a sprite, set the local
*                                  * error variable to zero
     bsr       save_image

     move.b    #0, new(a2, d5.w)   * set these flag variables
     move.w    #-1, new_x(a2, d5.w)

     tst.w     left_over           * if there is a left-over word...
     beq       l14

     subq.w    #1, (a3)            * ...then delete it

     l14:
     sub.w     #28, d5             * loop through all sprites
     bpl       l13

move.w    #15, d6                  * d6 will loop through all priority
l19:                               * levels
move.w    #420, d5
l15:
     tst.b     enable(a2, d5.w)    * test if the sprite is enabled
     beq       l17

     cmp.b     plane(a2, d5.w), d6 * does the priority match d6?
     bne       l17

     move.w    x(a2, d5.w), d0     * check if sprite ran off screen...
     move.w    #319, d1
     sub.w     width(a2, d5.w), d1
     cmp.w     d0, d1
     bhi       l20

     move.w    d1, x(a2, d5.w)     * ...and correct
     l20:
     move.w    y(a2, d5.w), d0     * same for y position
     move.w    #199, d1
     sub.w     height(a2, d5.w), d1
     cmp.w     d0, d1
     bhi       l21

     move.w    d1, y(a2, d5.w)
     l21:
     tst.b     advance_frame(a2, d5.w)  * check for advance frame
     beq       no_advance

     addi.b    #1, next_frame(a2, d5.w) * increment frame pointer
     clr.l     d0
     move.b    last_frame(a2, d5.w), d0 * check for overflow
     cmp.b     next_frame(a2, d5.w), d0
     bge       no_advance

     move.b    #0, next_frame(a2, d5.w)
     no_advance:
     bsr       copy_image               * put image on screen

     tst.b     advance_frame(a2, d5.w)  * if advance = 1, then clear it
     bmi       l17

     move.b    #0, advance_frame(a2, d5.w)

     l17:
     subi.w    #28, d5
     bpl       l15

dbf  d6, l19

move.l    #set_screen, -(sp)       * after the sprites have been
move.w    #38, -(sp)               * displayed, tell the shifter
trap      #14                      * to use this screen
addq.l    #6, sp
movem.l   (sp)+, d0-d7/a0-a6
move.l    screen1, d0              * function returns a pointer to
*                                  * the current screen
tst.w     glo_error                * if error, then return -1
beq       no_err

move.l    #-1, d0
no_err:
rts



save_image:
move.w    new_x(a2, d5.w), x_pos   * put the structure values into
move.w    new_y(a2, d5.w), y_pos   * variables I can change
move.w    height(a2, d5.w), vert_size

bsr       get_params               * get byte and word length

clr.l     d0
clr.l     d1

move.w    vert_size, d1
move.w    byte_length(a2, d5.w), d0     * stored as byte length minus 1
addq.w    #1, d1

mulu      d1, d0
addi.l    #80, d0                  * calculate amount of memory to get
bsr       get_mem
tst.w     loc_error                * if error, abort
bne       abort

addi.l    #4, next_image

tst.b     new(a2, d5.w)
beq       add_new_frame

move.l    next_image, d0           * if new sprite, make list of pointers
subq.l    #4, d0
move.l    d0, a0
move.l    d0, addr(a2, d5.w)
addi.l    #72, d0
move.l    d0, next_image
move.w    #15, d1
qw1:
     move.l    d0, (a0)+
     dbf       d1, qw1

add_new_frame:
move.l    addr(a2, d5.w), a0
clr.l     d0
move.b    frame(a2, d5.w), d0
lsl.w     #2, d0
move.l    next_image, 0(a0, d0.w)
move.l    next_image, buffer

move.l    next_image, a0
lea       -4(a0), a3               * save word and byte length offsetted
*                                  * from sprite data
move.w    word_length(a2, d5.w), -4(a0)
move.w    byte_length(a2, d5.w), -2(a0)
move.w    -4(a0), word_size
move.w    -2(a0), byte_size

bsr       calc_screen              * get address of upper left corner
*                                  * of image to store
move.l    a0, source
move.l    buffer, destination

bsr       screen_to_buffer
bsr       align_buffer
abort:
rts



copy_image:
move.l    addr(a2, d5.w), a0       * get address of the 16 frame pointers
clr.l     d0
move.b    next_frame(a2, d5.w), d0
lsl.w     #2, d0
move.l    0(a0, d0.w), a1
move.l    a1, source               * get actual address of frame

move.w    -4(a1), word_size
move.w    -2(a1), byte_size
move.w    height(a2, d5.w), vert_size

move.w    width(a2, d5.w), d0
add.w     x(a2, d5.w), d0
move.w    d0, total_pix

move.w    x(a2, d5.w), x_pos
move.w    y(a2, d5.w), y_pos

bsr       calc_screen
move.l    a0, destination

tst.w     d6                       * if priority level is zero
bne       front_of_screen          * then display sprite behind
bsr       buffer_behind_screen     * color zero
rts

front_of_screen:
bsr       buffer_to_screen
rts



set_screen:
move.l    screen1, -(sp)           * tell the shifter which screen to
move.b    1(sp), $ff8201           * display
move.b    2(sp), $ff8203
addq.l    #4, sp

cmp.w     #0, tell_gem
beq       tell_not

move.l    screen1, $44e            * tell gem where screen is

tell_not:
rts



screen_to_buffer:
move.l    #$ffff, d1           * this will be used to mask off
move.w    total_pix, d0        * the unused pixels on the right
and.w     #15, d0
beq       save_right          * if no unused, keep mask at #$ffff

swap      d1                  * change value to #$ffff0000
lsr.l     d0, d1

save_right:
move.w    d1, right_mask

move.l    destination, a1     * get destination address and copy
move.l    a1, a4              * for quicker address calculation
move.l    source, a0
move.w    vert_size, d3
l1:
     move.w    #3, d1              * four planes
     move.w    #$0, d4

     move.w    word_size, d2       * if only one word, skip this part
     beq       l4
     subq.w    #1, d2

     l3:
          move.w    (a0)+, d0
          or.w      d0, d4         * make a background mask
          move.w    d0, (a1)+
          dbf       d1, l3

     move.w    d4, (a1)+           * put background mask after four
*                                  * planes of data
     move.w    #3, d1
     move.w    #$0, d4
     dbf       d2, l3

     l4:                           * this loop will get the right edges
          move.w    (a0)+, d0      * and mask off the unused parts
          and.w     right_mask, d0
          move.w    d0, (a1)+
          or.w      d0, d4
          dbf       d1, l4

     move.w    d4, (a1)+

     adda.w    byte_size, a4
     move.l    a4, a1
     add.l     #160, source        * move to next scan line
     move.l    source, a0
     dbf       d3, l1
rts



calc_screen:
move.l    screen1, a0              * calculate the address of the
move.l    #0, d0                   * upper left corner of sprite
move.w    y_pos, d0
mulu      #160, d0
adda.l    d0, a0

move.l    #0, d0
move.w    x_pos, d0
move.l    d0, d1
and.w     #$f, d1
move.w    d1, left_shift           * the amount to shift the data to
and.w     #$fff0, d0               * kill the unused part on the left
lsr.w     #1, d0
adda.l    d0, a0
rts



get_params:
move.w    new_x(a2, d5.w), x_pos   * calculate the word and byte length
move.w    new_y(a2, d5.w), y_pos

move.l    #0, d1
move.l    #0, d0
move.w    width(a2, d5.w), d0
move.w    d0, total_pix

move.w    x_pos, d0
add.w     d0, total_pix

move.w    total_pix, d1
add.w     #$f, d1
and.w     #$fff0, d1
and.w     #$fff0, d0

sub.w     d0, d1                   * there will be an unused word...
lsr.w     #4, d1
tst.w     d1
beq       too_short

subq.w    #1, d1                   * ...so get rid of it
too_short:
move.w    d1, word_length(a2, d5.w)

addq.w    #1, d1
mulu      #10, d1                       * 8 bytes for four planes, 2
move.w    d1, byte_length(a2, d5.w)     * bytes for background mask

move.w    #0, left_over

move.w    x_pos, d0
and.w     #$fff0, d0

move.w    total_pix, d1
and.w     #$fff0, d1

sub.w     d1, d0
cmp.w     #0, d0
bmi       cant_shorten
move.w    #1, left_over                 * we can shorten by another word

cant_shorten:
rts



align_buffer:
move.l    buffer, a0               * align the sprite data on the left
move.l    a0, a1
move.w    vert_size, d3
move.w    left_shift, d4
loop1:                             * the left edges must be handled
     move.w    #4, d1              * seperatly
     loop2:
          move.w    (a0), d0
          lsl.w     d4, d0
          move.w    d0, (a0)+
          dbf       d1, loop2

     move.w    word_size, d2
     subq.w    #1, d2
     bmi       next_line

     move.w    #4, d1
     loop3:                        * this loop rotates all words right
          move.l    #0, d0         * of the leftmost word
          move.w    (a0), d0
          lsl.l     d4, d0
          move.w    d0, (a0)+

          swap      d0
          or.w      d0, -12(a0)    * if runover, it must be added to the
          dbf       d1, loop3      * word to the left, remember, 10 bytes
*                                  * for each 16 pixels
          move.w    #4, d1
          dbf       d2, loop3
     next_line:
     add.w     byte_size, a1
     move.l    a1, a0
     dbf       d3, loop1
rts



buffer_to_screen:
movem.l   d0-d7/a0-a7, -(sp)

move.l    source, a0               * copy to allow for faster looping
move.l    a0, a4
move.l    destination, a1
move.l    a1, a3

move.w    vert_size, d7

move.w    left_shift, d4           * d6 will hold a mask to be used later
move.l    #$ffff0000, d6
lsr.l     d4, d6

loop11:
     move.w    word_size, d1

     loop12:                       * mask background one sprite width wide
          moveq.l   #0, d0
          move.w    8(a0), d0      * get background mask word
          not.l     d0
          swap      d0             * mask runover first
          lsr.l     d4, d0
          and.w     d0, 8(a1)
          and.w     d0, 10(a1)
          and.w     d0, 12(a1)
          and.w     d0, 14(a1)

          swap      d0
          or.w      d6, d0         * mask off clutter
          and.w     d0, (a1)+
          and.w     d0, (a1)+
          and.w     d0, (a1)+
          and.w     d0, (a1)+

          adda.w    #10, a0
          dbf       d1, loop12

     move.l    a3, a1              * move back to beginning of line
     move.l    a4, a0
     move.w    word_size, d2

     loop_14:
          moveq.l   #0, d0
          move.l    d0, d1
          move.l    d1, d3
          move.l    d3, d5

          move.w    (a0)+, d0
          move.w    (a0)+, d1
          move.w    (a0)+, d3
          move.w    (a0)+, d5

          swap      d0
          swap      d1
          swap      d3
          swap      d5

          lsr.l     d4, d0
          lsr.l     d4, d1
          lsr.l     d4, d3
          lsr.l     d4, d5

          or.w      d0, 8(a1)
          or.w      d1, 10(a1)
          or.w      d3, 12(a1)
          or.w      d5, 14(a1)

          swap      d0
          swap      d1
          swap      d3
          swap      d5

          or.w      d0, (a1)+
          or.w      d1, (a1)+
          or.w      d3, (a1)+
          or.w      d5, (a1)+

          addq.w    #2, a0
          dbf       d2, loop_14

     adda.w    byte_size, a4       * move to next line
     move.l    a4, a0
     adda.l    #160, a3
     move.l    a3, a1
     dbf       d7, loop11
movem.l   (sp)+, d0-d7/a0-a7
rts



buffer_behind_screen:
movem.l   d0-d7/a0-a7, -(sp)

move.l    source, a0
move.l    a0, a4
move.l    destination, a1
move.l    a1, a3

move.w    vert_size, d7
move.w    left_shift, d4
m3:
     move.w    word_size, d3
     m4:
          moveq.l   #0, d0         * get mask from screen...
          or.w      (a1), d0
          or.w      2(a1), d0
          or.w      4(a1), d0
          or.w      6(a1), d0
          swap      d0

          or.w      8(a1), d0
          or.w      10(a1), d0
          or.w      12(a1), d0
          or.w      14(a1), d0
          not.l     d0

          move.w    #3, d2
          m5:
               move.l    #0, d1
               move.w    (a0)+, d1
               swap      d1
               lsr.l     d4, d1
               and.l     d0, d1    * ...and use it on sprite data
               or.w      d1, 8(a1)

               swap      d1
               or.w      d1, (a1)+
               dbf       d2, m5
          addq.w    #2, a0
          dbf       d3, m4

     adda.w    byte_size, a4
     move.l    a4, a0
     adda.l    #160, a3
     move.l    a3, a1
     dbf       d7, m3
movem.l   (sp)+, d0-d7/a0-a7
rts




_xor_image:
move.l    screen1, destination     * take a sprite and xor it onto
*                                  * the screen
move.w    4(sp), d0
move.w    6(sp), x_pos
move.w    8(sp), y_pos

movem.l   d0-d7/a0-a7, -(sp)

move.l    raster, a2
move.w    #28, d5
mulu      d0, d5

move.l    addr(a2, d5.w), a0
move.l    (a0), a1
move.l    a1, source
move.w    -4(a1), word_size
move.w    -2(a1), byte_size
move.w    height(a2, d5.w), d7

move.l    destination, a0
clr.l     d0
move.w    y_pos, d0
mulu      #160, d0
adda.l    d0, a0

clr.l     d0
move.w    x_pos, d0
move.l    d0, d4
andi.l    #$f, d4

and.w     #$fff0, d0
lsr.w     #1, d0
adda.l    d0, a0

move.l    a0, a1
move.l    a1, a3
move.l    source, a0
move.l    a0, a4

xx1:
     move.w    word_size, d1

     xx2:
          clr.l     d0
          move.w    8(a0), d0
          swap      d0
          lsr.l     d4, d0
          eor.w     d0, 8(a1)
          eor.w     d0, 10(a1)
          eor.w     d0, 12(a1)
          eor.w     d0, 14(a1)

          swap      d0
          eor.w     d0, (a1)+
          eor.w     d0, (a1)+
          eor.w     d0, (a1)+
          eor.w     d0, (a1)+

          adda.w    #10, a0
          dbf       d1, xx2

     adda.w    byte_size, a4
     adda.l    #160, a3
     move.l    a4, a0
     move.l    a3, a1
     dbf       d7, xx1

movem.l   (sp)+, d0-d7/a0-a7
rts




get_mem:
movem.l   d1-d4/a3, -(sp)          * return the address of a memory
move.l    list, a3                 * block of requested length
move.w    #255, d1

find_freed:
     tst.w     6(a3)               * test list of 512 longwords for a
     bmi       check_size          * deallocated entry. 
     addq.l    #8, a3              * format: address(L), length(W), status(w)
     dbf       d1, find_freed

move.l    list, a3
subq.l    #8, a3
bra       find_slot

check_size:
addq.l    #8, a3
move.w    -4(a3), d3
cmp.w     d3, d0                   * does the deallocated slot have
bgt       find_freed               * enough memory?

move.l    -8(a3), d4
sub.w     d0, d3                   * if slot has more than 1K above
cmp.w     #1024, d3                * requested memory, slice slot
blt       gm3                      * into two slots

move.l    a3, -(sp)

gm4:
     tst.w     6(a3)               * find next free entry to put runover
     beq       gm5                 * memory into
     addq.l    #8, a3
     bra       gm4

gm5:
move.w    d3, 4(a3)
add.w     d3, d4
move.l    d4, (a3)
move.w    #-1, 6(a3)

move.l    (sp)+, a3
move.w    d0, -4(a3)

gm3:
subq.l    #8, a3
bra       fix_slot

find_slot:
move.w    #255, d1                 * find an empty slot
gm6:
     addq.l    #8, a3
     tst.w     6(a3)
     dbeq      d1, gm6

move.l    d0, d3
cmp.l     size, d0
blt       insert

cmp.l     #1024, size              * if Malloc'd memory block is not
blt       too_small                * large enough, get more

move.l    where, (a3)
move.w    size, 4(a3)
move.w    #-1, 6(a3)
addq.l    #8, a3

too_small:
move.l    #$0000a000, d2           * ask for 40K

move.l    #-1, -(sp)
move.w    #$48, -(sp)
trap      #1
addq.l    #6, sp

subi.l    #$00002000, d0           * make sure that there is at least 8K

tst.l     d0
bmi       set_error

cmp.l     d2, d0                   * if not 40K, get what we can
bgt       gm2
move.l    d0, d2

gm2:
move.l    d2, -(sp)
move.w    #$48, -(sp)
trap      #1
addq.l    #6, sp

move.l    d0, where

move.l    #alloc, a0
move.w    n_alloc, d1
move.l    d0, 0(a0, d1.w)          * save address of allocated memory
addq.w    #4, n_alloc

move.l    d2, size

cmp.l     d2, d3
bgt       set_error

insert:
sub.l     d3, size
move.l    where, (a3)
move.w    d3, 4(a3)
add.l     d3, where

fix_slot:
move.w    #1, 6(a3)
move.l    (a3), next_image
movem.l   (sp)+, d1-d4/a3
rts

set_error:
move.w    #1, loc_error
move.w    #1, glo_error
movem.l   (sp)+, d1-d4/a3
rts




free_mem:
movem.l   d1/a3, -(sp)             * this will free a used slot
move.l    list, a3                 * and allow it to be used later
move.w    #255, d1

find_loc:
     cmp.l     (a3), d0
     beq       delete_slot
     addq.l    #8, a3
     dbf       d1, find_loc
movem.l   (sp)+, d1/a3
rts

delete_slot:
move.w    #-1, 6(a3)
movem.l   (sp)+, d1/a3
rts




_kill_sprite:
move.w    4(sp), d0                * take a frame of a sprite, and 
move.w    6(sp), fram              * delete it

movem.l   d2/a0-a2, -(sp)

mulu      #28, d0
move.l    raster, a2

move.l    addr(a2, d0.w), a0
clr.l     d2
move.b    last_frame(a2, d0.w), d2

tst.w     fram
beq       kill_all                 * either kill one frame...

move.w    fram, d1
lsl.w     #2, d1
move.l    0(a0, d1.w), d0
subq.l    #4, d0
bsr       free_mem

movem.l   (sp)+, d2/a0-a2
rts

kill_all:                          * ...or kill entire sprite
move.l    #0, addr(a2, d0.w)
move.b    #0, enable(a2, d0.w)
move.b    #0, last_frame(a2, d0.w)
move.w    #-1, new_x(a2, d0.w)
move.b    #-1, new(a2, d0.w)

move.l    (a0), d0
subi.l    #72, d0
bsr       free_mem

tst.w     d2
beq       ks1

lsl.w     #2, d2
ill_all:
     move.l    0(a0, d2.w), d0
     subq.l    #4, d0
     bsr       free_mem
     subq.w    #4, d2
     bne       ill_all

ks1:
movem.l   (sp)+, d2/a0-a2
rts



_get_free:                         * from here on, the program is
move.l    #-1, -(sp)               * very straightfoward
move.w    #$48, -(sp)
trap      #1
addq.l    #6, sp

add.l     size, d0
move.l    list, a0
move.w    #255, d1
gf1:
     tst.w     6(a0)
     bmi       gf2
     addq.l    #8, a0
     dbf       d1, gf1
rts

gf2:
clr.l     a1
move.w    4(a0), a1
add.l     a1, d0
addq.l    #8, a0
dbf       d1, gf1
rts




_save_sprite:
move.l    4(sp), filename
move.l    8(sp), pal

movem.l   d0-d7/a0-a7, -(sp)

move.w    #$0, -(sp)
move.l    filename, -(sp)
move.w    #$3c, -(sp)
trap      #1
addq.l    #8, sp
tst.w     d0
bmi       ss_err
move.w    d0, handle

move.l    pal, -(sp)
move.l    #32, -(sp)
move.w    handle, -(sp)
move.w    #$40, -(sp)
trap      #1
add.l     #12, sp
tst.l     d0
bmi       ss_err

move.w    #-1, count
move.l    raster, a2
move.w    #0, d5
ss1:
     addq.w    #1, count
     tst.l     addr(a2, d5.w)
     beq       ss2

     move.l    addr(a2, d5.w), a3

     clr.l     d0
     move.l    (a3), a0
     move.w    -2(a0), d0
     move.w    height(a2, d5.w), d1
     addq.w    #1, d1
     mulu      d1, d0
     add.l     #80, d0

     move.w    count, tem_sprite
     move.w    #0, tem_frame
     move.w    d0, tem_size

     move.l    #tem_sprite, -(sp)
     move.l    #6, -(sp)
     move.w    handle, -(sp)
     move.w    #$40, -(sp)
     trap      #1
     add.l     #12, sp
     tst.l     d0
     bmi       ss_err

     lea       addr(a2, d5.w), a0
     move.l    a0, -(sp)
     move.l    #28, -(sp)
     move.w    handle, -(sp)
     move.w    #$40, -(sp)
     trap      #1
     add.l     #12, sp
     tst.l     d0
     bmi       ss_err

     clr.l     d0
     move.w    tem_size, d0
     move.l    (a3), a0
     subq.l    #4, a0

     move.l    a0, -(sp)
     move.l    d0, -(sp)
     move.w    handle, -(sp)
     move.w    #$40, -(sp)
     trap      #1
     add.l     #12, sp
     tst.l     d0
     bmi       ss_err

     tst.b     last_frame(a2, d5.w)
     beq       ss2

     move.w    #0, d2
     ss3:
          addq.w    #1, d2

          move.w    d2, d3
          lsl.w     #2, d3
          move.l    0(a3, d3), a0

          clr.l     d0
          move.w    -2(a0), d0
          move.w    height(a2, d5.w), d1
          addq.w    #1, d1
          mulu      d1, d0
          add.l     #80, d0

          move.w    count, tem_sprite
          move.w    d2, tem_frame
          move.w    d0, tem_size

          move.l    #tem_sprite, -(sp)
          move.l    #6, -(sp)
          move.w    handle, -(sp)
          move.w    #$40, -(sp)
          trap      #1
          add.l     #12, sp
          tst.l     d0
          bmi       ss_err

          move.l    (a3, d3), a0

          clr.l     d0
          move.w    tem_size, d0
          subq.l    #4, a0

          move.l    a0, -(sp)
          move.l    d0, -(sp)
          move.w    handle, -(sp)
          move.w    #$40, -(sp)
          trap      #1
          add.l     #12, sp
          tst.l     d0
          bmi       ss_err

          cmp.b     last_frame(a2, d5.w), d2
          bne       ss3

     ss2:
     addi.w    #28, d5
     cmp.w     #420, d5
     ble       ss1

move.w    #-1, tem_sprite
move.w    #-1, tem_frame
move.w    #-1, tem_size

move.l    #tem_sprite, -(sp)
move.l    #6, -(sp)
move.w    handle, -(sp)
move.w    #$40, -(sp)
trap      #1
add.l     #12, sp
tst.l     d0
bmi       ss_err

move.w    handle, -(sp)
move.w    #$3e, -(sp)
trap      #1
addq.l    #4, sp

movem.l   (sp)+, d0-d7/a0-a7
move.w    #0, d0
rts

ss_err:
move.w    handle, -(sp)
move.w    #$3e, -(sp)
trap      #1
addq.l    #4, sp

movem.l   (sp)+, d0-d7/a0-a7
move.w    #1, d0
rts




_load_sprite:
move.l    4(sp), filename
move.l    8(sp), pal

movem.l   d5/a2, -(sp)

move.w    #0, loc_error

move.w    #$0, -(sp)
move.l    filename, -(sp)
move.w    #$3d, -(sp)
trap      #1
addq.l    #8, sp
tst.w     d0
bmi       ls_done

move.w    d0, handle

bsr       _wipe_out
move.l    raster, -(sp)
bsr       _init
addq.l    #4, sp
tst.w     d0
bmi       ls_err

move.l    pal, -(sp)
move.l    #32, -(sp)
move.w    handle, -(sp)
move.w    #$3f, -(sp)
trap      #1
add.l     #12, sp
tst.l     d0
bmi       ls_err

move.l    pal, -(sp)
move.w    #6, -(sp)
trap      #14
addq.l    #6, sp

move.l    raster, a2

move.l    #tem_sprite, -(sp)
move.l    #6, -(sp)
move.w    handle, -(sp)
move.w    #$3f, -(sp)
trap      #1
add.l     #12, sp
tst.l     d0
bmi       ls_err

ls1:
     tst.w     tem_sprite
     bmi       ls_done

     clr.l     d0
     move.w    tem_size, d0
     bsr       get_mem

     tst.w     loc_error
     bne       ls_err

     clr.l     d5
     move.w    tem_sprite, d5
     mulu      #28, d5
     lea       addr(a2, d5.w), a0

     move.l    a0, -(sp)
     move.l    #28, -(sp)
     move.w    handle, -(sp)
     move.w    #$3f, -(sp)
     trap      #1
     add.l     #12, sp
     tst.l     d0
     bmi       ls_err

     move.l    next_image, d0
     move.l    d0, a0
     move.l    d0, addr(a2, d5.w)
     addi.l    #72, d0
     move.l    d0, next_image

     move.w    #15, d1
     ls2:
          move.l    d0, (a0)+
          dbf       d1, ls2

     move.l    addr(a2, d5.w), a0
     move.l    next_image, d0
     move.l    d0, (a0)
     subq.l    #4, d0

     clr.l     d1
     move.w    tem_size, d1

     move.l    d0, -(sp)
     move.l    d1, -(sp)
     move.w    handle, -(sp)
     move.w    #$3f, -(sp)
     trap      #1
     add.l     #12, sp
     tst.l     d0
     bmi       ls_err
          
     move.l    #tem_sprite, -(sp)
     move.l    #6, -(sp)
     move.w    handle, -(sp)
     move.w    #$3f, -(sp)
     trap      #1
     add.l     #12, sp
     tst.l     d0
     bmi       ls_err

     tst.w     tem_frame
     beq       ls1

     ls3:
          tst.w     tem_sprite
          bmi       ls_done

          clr.l     d0
          move.w    tem_size, d0
          bsr       get_mem
          tst.w     loc_error
          bne       ls_err

          addq.l    #4, next_image
          move.l    addr(a2, d5.w), a0

          clr.l     d0
          move.w    tem_frame, d0
          lsl.w     #2, d0
          move.l    next_image, 0(a0, d0.w)

          move.l    next_image, d0
          subq.l    #4, d0

          clr.l     d1
          move.w    tem_size, d1

          move.l    d0, -(sp)
          move.l    d1, -(sp)
          move.w    handle, -(sp)
          move.w    #$3f, -(sp)
          trap      #1
          add.l     #12, sp
          tst.l     d0
          bmi       ls_err

          move.l    #tem_sprite, -(sp)
          move.l    #6, -(sp)
          move.w    handle, -(sp)
          move.w    #$3f, -(sp)
          trap      #1
          add.l     #12, sp
          tst.l     d0
          bmi       ls_err

          tst.w     tem_frame
          bmi       ls_done
          beq       ls1
          bra       ls3
ls_done:
move.w    handle, -(sp)
move.w    #$3e, -(sp)
trap      #1
addq.l    #4, sp

movem.l   (sp)+, d5/a2
move.l    #0, d0
rts

ls_err:
move.w    handle, -(sp)
move.w    #$3e, -(sp)
trap      #1
addq.l    #4, sp

bsr       _wipe_out
move.l    raster, -(sp)
bsr       _init
addq.l    #4, sp

movem.l   (sp)+, d5/a2
move.w    #1, d0
rts




_wipe_out:
movem.l   d0/a2, -(sp)

move.l    real_screen, screen1
move.w    #1, tell_gem

move.l    #set_screen, -(sp)
move.w    #38, -(sp)
trap      #14
addq.l    #6, sp

move.l    #alloc, a2
wo1:
     move.l    (a2), d0
     tst.l     d0
     beq       wo2

     move.l    d0, -(sp)
     move.w    #$49, -(sp)
     trap      #1
     addq.l    #6, sp

     move.l    #0, (a2)+
     bra       wo1
wo2:
movem.l    (sp)+, d0/a2
rts




.data
     
.even

next_y:        .ds.w     1
next_x:        .ds.w     1
total_pix:     .ds.w     1
x_pos:         .ds.w     1
y_pos:         .ds.w     1
byte_size:     .ds.w     1
word_size:     .ds.w     1
vert_size:     .ds.w     1
buffer:        .ds.l     1
source:        .ds.l     1
destination:   .ds.l     1
left_mask:     .ds.w     1
right_mask:    .ds.w     1
left_shift:    .ds.w     1
temp_buff:     .ds.l     1
real_screen:   .ds.l     1
screen1:       .ds.l     1
screen2:       .ds.l     1
save_lgth:     .ds.w     1
raster:        .ds.l     1
next_image:    .ds.l     1
start_buffer:  .ds.l     1
left_over:     .ds.w     1
tell_gem:      .ds.w     1
list:          .ds.l     1
where:         .ds.l     1
size:          .ds.l     1
sprite:        .ds.w     1
fram:          .ds.w     1
loc_error:     .ds.w     1
glo_error:     .ds.w     1
filename:      .ds.l     1
pal:           .ds.l     1
handle:        .ds.w     1
count:         .ds.w     1
alloc:         .ds.l     21
n_alloc:       .ds.w     1
tem_sprite:    .ds.w     1
tem_frame:     .ds.w     1
tem_size:      .ds.w     1

