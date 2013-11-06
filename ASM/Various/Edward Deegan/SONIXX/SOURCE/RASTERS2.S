* Routine to load several songs and then play them in order
* Adapted by Edward Deegan (VOBRIEN) 1990
*
sing    move.l  4(a7),a3                * base page
        move.l  #mystack,a7
        move.l  $c(a3),d0               * text len
        add.l   $14(a3),d0              * data len
        add.l   $1c(a3),d0              * BSS len
        add.l   #$100,d0                * basepage
        move.l  d0,-(sp)
        move.l  a3,-(sp)
        clr.w   -(sp)
        move.w  #$4a,-(sp)
        trap    #1                      * release memory
        add.l   #12,sp
set_rez:        move.w  #4,-(sp)        * Find resolution...
                trap    #14
                addq.l  #2,sp           * Correct the stack
                cmp.b   #$00,D0         * Low rez already?
                beq     i
                cmp.b   #$02,D0         * Hi-Rez?
                beq     hi_rez
                
                move.w  #$00,-(sp)      * Set low resolution
                move.l  #-1,-(sp)
                move.l  #-1,-(sp)       * Leave screens alone
                move.w  #5,-(sp)        * Function number!
                trap    #14
                add.l   #12,sp
                jmp     i
hi_rez:         move.l  #sorry,-(sp)    * Print message
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp
                move.w  #$08,-(sp)
                trap    #1
                addq.l  #2,sp
                clr.l   -(sp)
                trap    #1              * Exit demo....
i:              clr.l   -(sp)
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  D0,save_stack
                move.b  #$00,$484       * Disable key click/repeat
                move.l  #hertzp,-(sp)
                move.w  #$09,-(sp)
                trap    #1
                addq.l  #6,sp
i1:             move.w  #$08,-(sp)
                trap    #1
                addq.l  #2,sp
                cmp.b   #$31,D0 
                beq     i2
                cmp.b   #$32,D0
                beq     set60
                jmp     i1
set60:          move.b  #$00,$FF820A
                jmp     i3
i2:             move.b  #$2,$FF820A
i3:             move.l  save_stack,-(sp)
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp

intro:  move.l  #35000,-(sp)            * Space for title screen
        move.w  #$48,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  D0,pic_pntr
        move.l  #title1,A4              * A4 = Name
        move.l  pic_pntr,A5             * A5 = Address
        move.l  #35000,A6               * Read past end of file...
        jsr     open
        move.w  #2,-(sp)
        trap    #14
        addq.l  #2,sp                   * Get Phys_Base
        move.l  D0,physic
        move.l  pic_pntr,A1
        move.l  A1,-(sp)
        move.w  #6,-(sp)                * Set palette
        trap    #14
        addq.l  #6,sp
        clr.l   D1
        move.l  pic_pntr,A1
        add.l   #32,A1
        move.l  physic,A2
d_loop: move.l  (A1)+,(A2)+
        addq.l  #$01,D1
        cmp.l   #8001,D1
        beq     nextp
        jmp     d_loop

nextp:  move.l  #title2,A4
        move.l  pic_pntr,A5
        move.l  #35000,A6
        jsr     open
        move.w  #$08,-(sp)
        trap    #1
        addq.l  #2,sp           * Wait for a keypress
        move.l  pic_pntr,A1
        move.l  A1,-(sp)
        move.w  #6,-(sp)                * Set palette
        trap    #14
        addq.l  #6,sp
        clr.l   D1
        move.l  pic_pntr,A1
        add.l   #32,A1
        move.l  physic,A2
d_loop2 move.l  (A1)+,(A2)+
        addq.l  #$01,D1
        cmp.l   #8001,D1
        beq     ready
        jmp     d_loop2
ready:  move.l  pic_pntr,-(sp)
        move.w  #$49,-(sp)              * Free the memory
        trap    #1
        addq.l  #6,sp

        move.l  #350000,-(sp)           * malloc data area
        move.w  #$48,-(sp)
        trap    #1
        addq.l  #6,sp
        move.l  d0,vobrie2
        add.l   #6850,d0
        move.l  d0,vobrie3
        add.l   #4770,D0
        move.l  d0,neworder
        add.l   #8050,d0
        move.l  d0,vobrie1
        add.l   #5530,d0
        move.l  d0,axelf
        add.l   #4670,d0
        move.l  d0,classics
        add.l   #1390,d0
        move.l  d0,mellow
        add.l   #3000,d0
        move.l  d0,counter
        add.l   #7000,d0
        move.l  d0,swingit
        add.l   #8000,d0
        move.l  d0,ditty   
        add.l   #2000,d0
        move.l  d0,vset_ptr

        pea     env_str                 * execute singsong
        pea     cmd_str
        pea     prog_nm
        move.w  #3,-(sp)
        move.w  #$4b,-(sp)
        trap    #1
        add.l   #14,sp
        add.l   #256,d0
        move.l  d0,prog_ptr

        lea     vobrie2n,a4              * load song
        move.l  vobrie2,a5
        move.l  #$10000,a6
        bsr     open
        lea     vobrie3n,a4
        move.l  vobrie3,a5
        move.l  #$10000,a6
        bsr     open
        lea     newordern,a4
        move.l  neworder,a5
        move.l  #$10000,a6
        bsr     open
        lea     vobrie1n,a4
        move.l  vobrie1,a5
        move.l  #$10000,a6
        bsr     open
        lea     axelfn,a4
        move.l  axelf,a5
        move.l  #$10000,a6
        bsr     open
        lea     classicsn,a4
        move.l  classics,a5
        move.l  #$10000,a6
        bsr     open
        lea     mellown,a4
        move.l  mellow,a5
        move.l  #$10000,a6
        bsr     open
        lea     countern,a4
        move.l  counter,a5
        move.l  #$10000,a6
        bsr     open
        lea     swingitn,a4
        move.l  swingit,a5
        move.l  #$10000,a6
        bsr     open
        lea     dittyn,a4
        move.l  ditty,a5
        move.l  #$10000,a6
        bsr     open

        lea     vset_nm,a4              * load voice set
        move.l  vset_ptr,a5
        move.l  #170000,a6
        bsr     open

        jmp     rasters
        move.l  #$00,A0
x1:     move.l  prog_ptr,a0             * play the song 
        move.l  vobrie2,12(a0)
        move.l  vset_ptr,16(a0)  
        jsr     (a0)
        jmp     rasters                 * Go and do some rasters....
x2:     move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  vobrie3,12(a0)
        jsr     (a0)
        jmp     rasters
x3:     move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  neworder,12(a0)
        jsr     (a0)
        jmp     rasters
x4:     move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  vobrie1,12(a0)
        jsr     (a0)
        jmp     rasters
x5:     move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  axelf,12(a0)
        jsr     (a0)
        jmp     rasters
x6:     move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  classics,12(a0)
        jsr     (a0)
        jmp     rasters
x7:     move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  mellow,12(a0)
        jsr     (a0)
        jmp     rasters
x8:     move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  counter,12(a0)
        jsr     (a0)
        jmp     rasters                 * Last rasters execution...
        
* \Not sure why the rest of this rubbish is needed....seems to lock up
*  if not present though........                |
*                                               |
        move.l  prog_ptr,a0                     |
        move.l  vset_ptr,16(a0)                 |
        move.l  swingit,12(a0)                  |
        jsr     (a0)                            |
        move.l  prog_ptr,a0                     |
        move.l  vset_ptr,16(a0)                 |       
        move.l  ditty,12(a0)                    |
        jsr     (a0)                           \ /
*                                               ÿ 
************************************************************************


open    clr.w   -(sp)                   * load a file
        move.l  a4,-(sp)                * a4 -> filename
        move.w  #$3d,-(sp)
        trap    #1
        addq.l  #8,sp
        tst.w   d0
        bmi     diskerr
        move.w  d0,-(sp)                * store file handle

read    move.l  a5,-(sp)                * read file to data area
        move.l  a6,-(sp)
        move.w  d0,-(sp)
        move.w  #$3f,-(sp)
        trap    #1
        add.w   #12,sp
        move.l  d0,d7                   * store length

close   move.w  #$3e,-(sp)              * close file
        trap    #1                      * handle already on stack
        addq.l  #4,sp
        move.l  d7,d0
        tst.l   d0                      * d0=bytes loaded, -ve=err
diskerr rts

*       *       *       *       *       *       *       *       *       *

* \Here the main selection routine assumes control. The raster effects
*  are generated and continual scanning of the keyboard for keys 1 - 8
*  enables the songs to be 'randomly accessed'.


rasters:        move.l  A1,rega1
                clr.l   -(sp)           * Superviser mode
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  D0,save_stack                
                move.l  #status_reg,A0  * Save sr register
                move.w  sr,(A0)

init:           movea.l #$FF8240,A6     * A6 --> The raster index
                movea.l #data,A5        * A5 --> Color data
                move.w  #2,-(sp)        * Get screen RAM
                trap    #14
                addq.l  #2,sp
                move.l  D0,A4           * A4 -> Screen ram address
                move.l  D0,A3           * A3 = Working copy
                add.l   #32000,A4       * A4 -> End of screen
                move.l  A4,A2           * A2 -> End of screen
                suba.l  #640,A2         * Come up a line
                move.l  A3,A4           * Repoint A4 to screen RAM
                move.w  #$2700,sr       * Disable interrupts
                move.w  #$00,$452       * Disable VBL
                move.l  #data,A5
                move.l  #data2,A6
                clr.l   D6

* \A2 = End of screen....A3 = Moveable pointer on sreen
*  A4 = Permanent screen pointer....A5 = Pointer to color data
*  A6 = pointer to color index 0

         
start:          move.l  A4,A3           * Reset A3
                move.w  #$00,$FF8240    * Set to black
                move.w  #$00,$FF8242
                move.w  status_reg,sr   * Restore status register
                move.b  $FFFC02,D0
                cmp.b   #$02,D0         * 1?
                beq     end_intro
                cmp.b   #$03,D0         * 2?
                beq     end_intro
                cmp.b   #$04,D0
                beq     end_intro
                cmp.b   #$05,D0
                beq     end_intro
                cmp.b   #$06,D0
                beq     end_intro
                cmp.b   #$07,D0
                beq     end_intro
                cmp.b   #$8,D0
                beq     end_intro
                cmp.b   #$09,D0
                beq     end_intro

                move.w  #$2700,sr       * Disable sr again
                adda.l  #320,A3         * Point to end of scanline #2
loop1:          move.b  $FF8205,temp1   * Construct pointer
                move.b  $FF8207,temp2
                move.b  $FF8209,temp3
                cmp.l   temp,A3         * End of line 1?
                beq     loop2
                jmp     loop1           * Wait for the VBL
loop2:          cmpi.w  #$99,(A5)       * End of data?
                beq     reset
                move.w  (A5),$FF8240    * Set the border color
                addq.l  #2,A5
                move.w  (A6)+,$FF8242   * And internal bar
loop3:          add.l   #320,A3         * Point to next line
                cmp.l   A2,A3           * End of screen?
                bge     start                  
loop4:          move.b  $FF8205,temp1   * Construct pointer
                move.b  $FF8207,temp2
                move.b  $FF8209,temp3          
                cmp.l   temp,A3         * End of current line?
                beq     loop5
                jmp     loop4           * Wait for end of line
loop5:          cmp.w   #$99,(A5)       * End of data?
                beq     reset
                move.w  (A5),$FF8240    * Set color
                addq.l  #2,A5
                move.w  (A6)+,$FF8242   * And internal bar
                jmp     loop3
                

reset:          move.l  #data,A5        * Repoint A5 to colors
                move.l  #data2,A6       * And A6...
                move.w  (A5)+,$FF8240  
                addq.l  #2,A5
                move.w  (A6)+,$FF8242
                addq.l  #2,A6
                addq.l  #1,D6           * Increment counter
                cmp.l   #396,D6         * Four screens scrolled?
                beq     reset3
reset2:         jmp     loop3           * Back to main routine
reset3:         clr.l   D6              * Reset counter
                cmp.w   #$00,rastflag   * Going up?
                beq     reset4          * Set to down
                move.w  #$00,rastflag
                jmp     reset5
reset4:         move.w  #$00,data_flag  * SETS TO DOWN
                move.w  #$00,data_flag2
                move.w  #$01,rastflag
                jmp     reset2          * And return
reset5:         move.w  #$99,data_flag  * SETS TO UP
                move.w  #$99,data_flag2
                jmp     reset2


end_intro:      move.l  D0,std0         * Store keypress
                move.w  #$00,$FF8240
                move.l  save_stack,-(sp)
                move.w  #$20,-(sp)
                trap    #1
                addq.l  #6,sp
                move.l  rega1,A1        
                move.l  std0,D0
                cmp.b   #$02,D0         * Was 1 pressed?
                beq     x1              * If so then song 1
                cmp.b   #$03,D0         * 2?
                beq     x2
                cmp.b   #$04,D0
                beq     x3
                cmp.b   #$05,D0
                beq     x4
                cmp.b   #$06,D0
                beq     x5
                cmp.b   #$07,D0
                beq     x6
                cmp.b   #$08,D0
                beq     x7
                cmp.b   #$09,D0
                beq     x8
                jmp     x1
        
*       *       *       *       *       *       *       *       *       *

* \VARIABLES FOR RASTERS

* ---> All Variables/Strings/Storage etc...

status:         ds.w    1
temps:          ds.l    1
data:           dc.w    $0,$1,$2,$3,$4,$5,$6,$7,$6,$5
                dc.w    $4,$3,$2,$1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                dc.w    $0,$0,$0,$0,$0,$0,$0
                dc.w    $0,$1,$2,$3,$4,$5,$6,$7,$6,$5,$4,$3
                dc.w    $2,$1,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                dc.w    $0,$0,$0,$0,$0
                dc.w    $1,$2,$3,$4,$5,$6,$7,$6,$5,$4,$3,$2
                dc.w    $1,$0,$0
                dc.w    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                dc.w    $0,$0,$0,$0,$0,$0,$0,$0
data_flag:      dc.w    $99
                dc.w    $0,$99

data2:          dc.w    $0,$111,$222,$333,$444,$555,$666,$777,$666,$555
                dc.w    $444,$333,$222,$111,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                dc.w    $0,$0,$0,$0,$0,$0,$0
                dc.w    $0,$111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333
                dc.w    $222,$111,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                dc.w    $0,$0,$0,$0,$0
                dc.w    $111,$222,$333,$444,$555,$666,$777,$666,$555,$444,$333,$222
                dc.w    $111,$0,$0
                dc.w    $0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0,$0
                dc.w    $0,$0,$0,$0,$0,$0,$0,$0
data_flag2:     dc.w    $99
                dc.w    $0,$99


temp:           ds.b    1
temp1:          ds.b    1
temp2:          ds.b    1
temp3:          ds.b    1               * Storage for raster register data
save_stack:     ds.l    1
status_reg:     ds.w    1
rastflag:       ds.w    1
cushion:        ds.l    100

                EVEN
rega1:          ds.l    1
prog_ptr:       dc.l    0
song_ptr:       dc.l    0
vset_ptr:       dc.l    0
pic_pntr:       dc.l    0
std0:           ds.l    1
prog_nm:        dc.b    'a:\vobrien2.prg',0

vset_nm:        dc.b    'a:\vobrien.rsc',0
                even
env_str:        dc.b    0,0
cmd_str:        dc.b    0,0
physic:         dc.l    0
axelf:          dc.l    0
classics:       dc.l    0
neworder:       dc.l    0
swingit:        dc.l    0
vobrie1:        dc.l    0
vobrie2:        dc.l    0
vobrie3:        dc.l    0
mellow:         dc.l    0
counter:        dc.l    0
ditty:          dc.l    0

axelfn:         dc.b    'a:\musixx\axelf.mus',0
classicsn:      dc.b    'a:\musixx\classics.mus',0
newordern:      dc.b    'a:\musixx\neworder.mus',0
swingitn:       dc.b    'a:\musixx\swingit.mus',0
vobrie1n:       dc.b    'a:\musixx\vobrie1.mus',0
vobrie2n:       dc.b    'a:\musixx\vobrie2.mus',0
vobrie3n:       dc.b    'a:\musixx\vobrie3.mus',0
mellown:        dc.b    'a:\musixx\mellow.mus',0
countern:       dc.b    'a:\musixx\counter.mus',0
dittyn:         dc.b    'a:\musixx\ditty.mus',0
title1:         dc.b    'a:\musixx\groomin.mus',0
title2:         dc.b    'a:\musixx\groovin.mus',0
sorry:          dc.b    'Sorry, this demo only runs in LOW res!',0
hertzp:         dc.b    'Press "1" [50Hertz] or "2" [60Hertz]',0

                EVEN

        ds.l    100                     stack space
mystack ds.w    1                       (stacks go backwards)
