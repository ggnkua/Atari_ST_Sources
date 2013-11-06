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

begn:   move.l  prog_ptr,a0             * play the song 
        move.l  vobrie2,12(a0)
        move.l  vset_ptr,16(a0)  
        jsr     (a0)
        move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  vobrie3,12(a0)
        jsr     (a0)
        move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  neworder,12(a0)
        jsr     (a0)
        move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  vobrie1,12(a0)
        jsr     (a0)
        move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  axelf,12(a0)
        jsr     (a0)

        move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  classics,12(a0)
        jsr     (a0)
        move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  mellow,12(a0)
        jsr     (a0)
        move.l  prog_ptr,A0
        move.l  vset_ptr,16(a0)
        move.l  counter,12(a0)
        jsr     (a0)
        bra     begn
        move.l  prog_ptr,a0
        move.l  vset_ptr,16(a0)
        move.l  swingit,12(a0)
        jsr     (a0)
        move.l  prog_ptr,a0
        move.l  vset_ptr,16(a0)
        move.l  ditty,12(a0)
        jsr     (a0)

        bra     begn



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

prog_ptr:       dc.l    0
song_ptr:       dc.l    0
vset_ptr:       dc.l    0
pic_pntr:       dc.l    0
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
newordern:       dc.b    'a:\musixx\neworder.mus',0
swingitn:       dc.b    'a:\musixx\swingit.mus',0
vobrie1n:       dc.b    'a:\musixx\vobrie1.mus',0
vobrie2n:       dc.b    'a:\musixx\vobrie2.mus',0
vobrie3n:       dc.b    'a:\musixx\vobrie3.mus',0
mellown:        dc.b    'a:\musixx\mellow.mus',0
countern:       dc.b    'a:\musixx\counter.mus',0
dittyn:         dc.b    'a:\musixx\ditty.mus',0
title1:         dc.b    'a:\musixx\groomin.mus',0
title2:         dc.b    'a:\musixx\groovin.mus',0

        ds.l    100                     stack space
mystack ds.w    1                       (stacks go backwards)


*       *       *       *       *       *       *       *       *       *
