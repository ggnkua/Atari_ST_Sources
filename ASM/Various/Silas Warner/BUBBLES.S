

* bubbles --- want to bitblit
getch macro
   move.w   #1,(sp)
   trap  #1          alters a0, char = d0.b
   addq.l   #2,sp
   endm
   section
_main
   link  a6,#-4            adjust for C's long
* d3-d7/a3-a5 are C registers and are preserved by calls to GEM
* d0-d2/a0-a2 are scratch
   movem.l d0-d7/a0-a5,-(sp) save all registers, may later become a subr
   jsr   _appl_init
   lea   gr4,a0
   move.l   a0,(sp)        load first, push the rest
   pea   gr3
   pea   gr2
   pea   gr1
   jsr   _graf_handle      get device handle
   add.l #12,sp            pop stack
   move.w   d0,handle      handle returned in d0
   lea   work_out,a0       open the workstation
   move.l   a0,(sp)
   pea   handle
   pea   work_in           intin setup for VDI
   jsr   _v_opnvwk
   addq.l   #8,sp
   move.w   handle,(sp)
   jsr   _v_clrwk          clear workstation
* put a sprite on the screen to begin with via direct poke
   move.l   #9,-(sp) stack xmax-1 ( 80 x 40 pixels )
   move.l   #39,-(sp)      ymax-1
   lea   screenadr,a1
   lea   frames,a0
   move.l   (a1),-(sp)     screenadr
   move.l   (a0),-(sp)     frameadr
   bsr   putsprite
   adda.l   #16,sp
* set up pxyarray   the actual bubble is a lot smaller than 80x40
   move.w   #26,x1s     iniz position
   move.w   #10,y1s
   move.w   #44,x2s
   move.w   #24,y2s
newbubble
   move.w   #151,x1d    at bottom center
   move.w   #186,y1d
   move.w   #169,x2d
   move.w   #200,y2d
oldbubble   lea   mfdb,a3  @mem form def block, dest
   move.l   a3,(sp)
   move.l   a3,-(sp)    source & dest, the same
   pea      pxyarray    x1s - y2d
   move.w   wr_mode,-(sp)
   move.w   handle,-(sp)
   jsr   _vro_cpyfm     call bit blitter
   add.l   #12,sp
* delay goes here
   move.w   #1000,d0
wait  dbra  d0,wait
* see if we can make it move.  Start by putting destination coord to source
   movem.l   x1s,d3-d6
   movem.l   d5-d6,x1s        d3 = x1s,y1s, d4 = x2s,y2s, d5 = x1d,y1d
*                                       d6  = x2d,y2d
* make a new destination --- bubbles go up
   subq.w   #1,d5
   subq.w   #1,d6          only y coord change
   movem.l  d5-d6,x1d      CCR not affected, (d4.w):0 in effect
* if we are off the screen lets start over
   ble.s   newbubble
* if we're not tired of bubbles let them float up
   move.w   #$b,-(sp)   c_conis console key status
   trap  #1
   addq.l   #2,sp
   tst.w    d0       d0.w = 0 no character, = -1 char available
   beq.s    oldbubble
* if key fall thru and go home
   bra.s   finishup
* put a sprite on the screen
putsprite
   link  a6,#-4   one local variable
   movem.l  d0-d5/a0-a2,-(sp)    stack registers used
* realxmax = -4
* frameat = 8
* screenat = 12
* ymax = 16
* xmax = 20
   movea.l  8(a6),a0    frame@
   move.l   12(a6),d3   screen@
   move.l   20(a6),d2   xmax
   move.l   16(a6),d1   ymax
   move.l   d2,d0    copy of xmax
   addq  #1,d0   xmax+1
   move.l   d0,-4(a6)
* y loop
1$
   move.l   20(a6),d2 re-iniz xmax
* x loop
2$
* calculate screen address to store each scan line
   move.w   d1,d0    y
   mulu  #40,d0   40*y
   add.l d2,d0    40*y+x
   lsl.l #2,d0    (40*y+x)*4 storing long words
   add.l d3,d0    + screen address base
   movea.l  d0,a1 save screen address
* calculate offset into sprite
* sprite(y,x)=@sprite+xmax*y+x
   move.w   d1,d0    y
   mulu  -2(a6),d0   lower 16 bits, tricky!!!
   add.l d2,d0       xmax*y+x
   lsl.l #2,d0       4*(xmax*y+x) longs - offset
   adda.l   d0,a0    frame addr + offset
   move.l   (a0),(a1)   data to screen
   movea.l  8(a6),a0    restore frame addr base
   dbra  d2,2$       inner until
   dbra  d1,1$       outter until
   movem.l (sp)+,d0-d5/a0-a2    restore regs
   unlk  a6    erase stack mark
   rts
finishup
   move.w   handle,(sp)
   jsr   _v_clsvwk          close virtual work station
   jsr   _appl_exit
   movem.l (sp)+,d0-d7/a0-a5 restore registers
   unlk  a6
   rts
   data
work_in  dc.w  1,1,1,1,1,1,1,1,1,1,2   raster coord
wr_mode  dc.w  3  replace mode
pxyarray
x1s   ds.w  1  upper left x coord of source
y1s   ds.w  1
x2s   ds.w  1  lower right x coord of source
y2s   ds.w  1
x1d   ds.w  1  upper left x coord of destination
y1d   ds.w  1
x2d   ds.w  1  lower right x coord of destination
y2d   ds.w  1
* mem form def blocks the source and destination are the same
* align to long word i.e. addr mod 4 = 0
   cnop    0,4
mfdb       dc.l  0         screen itself, following parameters ignored
pixwidth   dc.w  80
pixheight  dc.w  40
wordwidth  dc.w  5
f4mat      dc.w  0         device specific format
memplanes  dc.w  4         four planes
           ds.w  3
_contrl  ds.w  12
_intin   ds.w  256
_ptsin   ds.w  256
_intout  ds.w  256
work_out ds.w  128
_ptsout  ds.w  256
handle   ds.w  1
gr1      ds.w  1
gr2      ds.w  1
gr3      ds.w  1
gr4      ds.w  1
   xref  _appl_init,_graf_handle,_v_opnvwk,_v_pline,_v_clsvwk
   xref  _appl_exit,_v_clrwk,_vro_cpyfm,_v_hide_c
   xdef  _main,_contrl,_intin,_ptsin,_intout,_ptsout
   cnop  0,4
screenadr   dc.l  $78000
frames      dc.l  bubble
   nolist
* data generated by COLR OBJ ED  80 x 40 pixels
bubble
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00007C00,$7C007C00,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000001,$00010001,$0000FF00,$FF00FF00,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000003,$00030003,$0000FF80,$FF80FF80,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000007,$00070007,$0400FFC0,$FBC0FBC0,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$0000000F,$000F000F,$0E00FFC0,$F1C0F1C0,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$0000000F,$000F000F,$0600FFE0,$F9E0F9E0,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$0000000F,$000F000F,$0000FFE0,$FFE0FFE0,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$0000000F,$000F000F,$0000FFE0,$FFE0FFE0,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$0000000F,$000F000F,$0000FFE0,$FFE0FFE0,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000007,$00070007,$0000FFC0,$FFC0FFC0,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000003,$00030003,$0000FFC0,$FFC0FFC0,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000001,$00010001,$0000FF80,$FF80FF80,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00007E00,$7E007E00,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
 DC.L   $00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000,$00000000
   end


Download complete.  Turn off Capture File.

Download another file (Y/N)?