* Macro Palette     (don't use ASM68K use Mcc!!!)
* by Robert Warnestam, 1988-04-18
* How to use from GFA basic:
* Start=loaded adrress+$1c    (+28)
* Poke start+0,mode
* Poke start+1,colors
* Poke start+2,light
* Dpoke start+4,col14        (constant color 14 on all palettes)
* Call start+6
* Mode:   0 = Start interrupt
*         1 = Change Palette (see colors&light)
*         2 = Stop interrupt
* Colors: 0 = Blue  level on x, Green level on y, Red  =light
*         1 = Blue  level on x, Red   level on y, Green=light
*         2 = Green level on x, Red   level on y, Blue =light
* Light:  0-7 
*
var    ds.b 6
mode   equ 0
colors equ 1
light  equ 2
col14  equ 4
*
* Execute in supervisor mode
   pea      super(pc)
   move     #38,-(a7)         :\Supexec
   trap     #14
   addq.l   #6,a7
   rts                        :\back to basic
*
* Which mode?
super       nop
   lea      var(pc),a6
   move.b   mode(a6),d0
   cmp.b    #0,d0             :\start interrupt?
   beq      startinterrupt
   cmp.b    #1,d0             :\change palette?
   beq      changepalette
   cmp.b    #2,d0             :\stop interrupt?
   beq      stopinterrupt
   rts
*
* Change palette
changepalette nop
   clr      d0                :\... colors
   clr      d1                :\... light
   clr      d2                :\... color at left-top (light)
   clr      d3                :\... inc at x-axis ($001,$010 or $100)
   clr      d4                :\... inc at y-axis ($001,$010 or $100)
   move.b   colors(a6),d0
   move.b   light(a6),d1
   cmp      #0,d0             :\green and blue?
   beq      greenblue
   cmp      #1,d0             :\red and blue?
   beq      redblue
redgreen   nop
   move     d1,d2             :\blue=light
   move     #$010,d3          :\x=green
   move     #$100,d4          :\y=red
   bra      setrgb
greenblue  nop
   move     d1,d2             :\red=light
   lsl      #8,d2
   move     #$001,d3          :\x=blue
   move     #$010,d4          :\y=green
   bra      setrgb
redblue    nop
   move     d1,d2             :\green=light
   lsl      #4,d2
   move     #$001,d3          :\x=blue
   move     #$100,d4          :\y=red
setrgb     nop
   lea      pal(pc),a0        :\address to 9 palettes (the last is constant)
   move     col14(a6),d5      :\constant color
   move     d2,d6             :\start with this color
   move     #7,d0             :\8 palettes
palloop    nop
   move     #0,0(a0)          :\color 0
   move     d5,28(a0)         :\color 14
   move     #$765,30(a0)      :\color 15
   addq     #2,a0             :\color 1 to 8 will change
   move     d6,d7             :\save start color
   move     #7,d1             :\8 colors to change
colloop    nop
   move     d7,(a0)+          :\set color
   add      d3,d7             :\add with x
   dbf      d1,colloop
   add.l    #14,a0            :\point to next palette
   add      d4,d6             :\add with y
   dbf      d0,palloop
   rts                        :\palette change done!
*
* Start interrupt
startinterrupt nop
   lea      myvec(pc),a0      :\table over my kbd vectors
   lea      kbd1(pc),a1       :\store my vectors
   move.l   a1,(a0)+
   lea      kbd2(pc),a1
   move.l   a1,(a0)+
   lea      kbd3(pc),a1
   move.l   a1,(a0)+
   lea      kbd4(pc),a1
   move.l   a1,(a0)+
   lea      kbd5(pc),a1
   move.l   a1,(a0)+
   lea      kbd6(pc),a1
   move.l   a1,(a0)+
   lea      kbd7(pc),a1
   move.l   a1,(a0)+
   lea      kbd8(pc),a1
   move.l   a1,(a0)+
   lea      kbd9(pc),a1
   move.l   a1,(a0)+
*
   move     #34,-(a7)
   trap     #14               :\get keboard vector table
   addq.l   #2,a7
   move.l   d0,a0             :\ into A0
   lea      kbd1vec(pc),a1    :\store area
   lea      myvec(pc),a2      :\my vectors
   move     #8,d0             :\9 vectors
getvec     nop
   move.l   (a0),(a1)+        :\save vector
   move.l   (a2)+,(a0)+       :\new vector
   dbf      d0,getvec
   lea      oldvbl(pc),a0     :\store old vbl vector
   move.l   $70,(a0)
   lea      vbl(pc),a0        :\new vbl routine
   move.l   a0,$70
   lea      mas1(pc),a0       :\save MFP mask and enable reg.
   move.b   $fffa13,(a0)
   lea      mas2(pc),a0
   move.b   $fffa15,(a0)
   lea      enab1(pc),a0
   move.b   $fffa07,(a0)
   lea      enab2(pc),a0
   move.b   $fffa09,(a0)
   lea      pal0(pc),a0
   move.l   a0,$120           :\first hbl routine into timer B vector
   move.b   #8,$fffa1b        :\timer B in count mode
   and.b    #254,$fffa07      :\disable timer B (vbl turns it on)
   or.b     #1,$fffa13        :\mask
   rts
*
* Stop interrupt
stopinterrupt nop
   move     #34,-(a7)
   trap     #14               :\get keboard vector table
   addq.l   #2,a7
   move.l   d0,a0             :\into A0
   lea      kbd1vec(pc),a1    :\saved vectors
   move     #8,d0             :\9 vectors
setvec     nop
   move.l   (a1)+,(a0)+       :\restore vector
   dbf      d0,setvec
   move.l   oldvbl(pc),$70    :\restore vbl routine
   move.b   mas1(pc),$fffa13  :\restore MFP mask and enable reg.
   move.b   mas2(pc),$fffa15
   move.b   enab1(pc),$fffa07
   move.b   enab2(pc),$fffa09
   rts
*
* Here comes 9 vectors for handling midi & keyboard
*  it will lower IPL to 5 and then jump to the old routine
*
kbd1 move   #$2500,sr
   move.l     kbd1vec(pc),-(a7)
   rts
kbd2 move   #$2500,sr
   move.l     kbd2vec(pc),-(a7)
   rts
kbd3 move   #$2500,sr
   move.l     kbd3vec(pc),-(a7)
   rts
kbd4 move   #$2500,sr
   move.l     kbd4vec(pc),-(a7)
   rts
kbd5 move   #$2500,sr
   move.l     kbd5vec(pc),-(a7)
   rts
kbd6 move   #$2500,sr
   move.l     kbd6vec(pc),-(a7)
   rts
kbd7 move   #$2500,sr
   move.l     kbd7vec(pc),-(a7)
   rts
kbd8 move   #$2500,sr
   move.l     kbd8vec(pc),-(a7)
   rts
kbd9 move   #$2500,sr
   move.l     kbd9vec(pc),-(a7)
   rts
*
* Vbl routine, enable hbl then jump to old vector
vbl move.l  a0,-(a7)
   lea      pal0(pc),a0
   move.l   a0,$120           :\first hbl routine
   move.l   (a7)+,a0
   or.b     #1,$fffa07        :\enable timer B
   move.b   #16,$fffa21       :\wait 16 lines before new palette
   move.l   oldvbl(pc),-(a7) :\jump to old vbl
   rts
*
* Here comes 9 hbl routines, one for each palette
*
pal0 movem.l a0/a1/d0,-(a7)   :\save register
   lea      pal(pc),a0        :\pointer to palettes
   move.l   #$ff8240,a1       :\video chip, color reg.
   move     #15,d0            :\16 colors
set0 move  (a0)+,(a1)+        :\set color
   dbf      d0,set0
   lea      pal1(pc),a0       :\next hbl routine
   move.l   a0,$120
   movem.l  (a7)+,a0/a1/d0    :\restore register
   move.b   #16,$fffa21      :\ at 16 lines from here
   and.b    #254,$fffa0f      :\in-service
   rte
*
pal1 movem.l a0/a1/d0,-(a7)
   lea      pal(pc),a0
   add.l    #32,a0            :\palette 2
   move.l   #$ff8240,a1
   move     #15,d0
set1 move   (a0)+,(a1)+
   dbf      d0,set1
   lea      pal2(pc),a0
   move.l   a0,$120
   movem.l  (a7)+,a0/a1/d0
   move.b   #16,$fffa21
   and.b    #254,$fffa0f
   rte
*
pal2 movem.l a0/a1/d0,-(a7)
   lea      pal(pc),a0
   add.l    #64,a0            :\palette 3
   move.l   #$ff8240,a1
   move     #15,d0
set2 move   (a0)+,(a1)+
   dbf      d0,set2
   lea      pal3(pc),a0
   move.l   a0,$120
   movem.l  (a7)+,a0/a1/d0
   move.b   #16,$fffa21
   and.b    #254,$fffa0f
   rte
*
pal3 movem.l a0/a1/d0,-(a7)
   lea      pal(pc),a0
   add.l    #96,a0            :\palette 4
   move.l   #$ff8240,a1
   move     #15,d0
set3 move   (a0)+,(a1)+
   dbf      d0,set3
   lea      pal4(pc),a0
   move.l   a0,$120
   movem.l  (a7)+,a0/a1/d0
   move.b   #16,$fffa21
   and.b    #254,$fffa0f
   rte
*
pal4 movem.l a0/a1/d0,-(a7)
   lea      pal(pc),a0
   add.l    #128,a0            :\palette 5
   move.l   #$ff8240,a1
   move     #15,d0
set4 move   (a0)+,(a1)+
   dbf      d0,set4
   lea      pal5(pc),a0
   move.l   a0,$120
   movem.l  (a7)+,a0/a1/d0
   move.b   #16,$fffa21
   and.b    #254,$fffa0f
   rte
*
pal5 movem.l a0/a1/d0,-(a7)
   lea      pal(pc),a0
   add.l    #160,a0            :\palette 6
   move.l   #$ff8240,a1
   move     #15,d0
set5 move   (a0)+,(a1)+
   dbf      d0,set5
   lea      pal6(pc),a0
   move.l   a0,$120
   movem.l  (a7)+,a0/a1/d0
   move.b   #16,$fffa21
   and.b    #254,$fffa0f
   rte
*
pal6 movem.l a0/a1/d0,-(a7)
   lea      pal(pc),a0
   add.l    #192,a0            :\palette 7
   move.l   #$ff8240,a1
   move     #15,d0
set6 move   (a0)+,(a1)+
   dbf      d0,set6
   lea      pal7(pc),a0
   move.l   a0,$120
   movem.l  (a7)+,a0/a1/d0
   move.b   #16,$fffa21
   and.b    #254,$fffa0f
   rte
*
pal7 movem.l a0/a1/d0,-(a7)
   lea      pal(pc),a0
   add.l    #224,a0            :\palette 8
   move.l   #$ff8240,a1
   move     #15,d0
set7 move   (a0)+,(a1)+
   dbf      d0,set7
   lea      pal8(pc),a0
   move.l   a0,$120
   movem.l  (a7)+,a0/a1/d0
   move.b   #16,$fffa21
   and.b    #254,$fffa0f
   rte
*
pal8 movem.l a0/a1/d0,-(a7)
   lea      pal(pc),a0
   add.l    #256,a0            :\palette 9
   move.l   #$ff8240,a1
   move     #15,d0
set8 move   (a0)+,(a1)+
   dbf      d0,set8
   movem.l  (a7)+,a0/a1/d0
   move.b   #1,$fffa21
   and.b    #254,$fffa07      :\disable hbl, vbl turns it on again
   and.b    #254,$fffa0f
   rte
*
kbd1vec    ds.l  1
kbd2vec    ds.l  1
kbd3vec    ds.l  1
kbd4vec    ds.l  1
kbd5vec    ds.l  1
kbd6vec    ds.l  1
kbd7vec    ds.l  1
kbd8vec    ds.l  1
kbd9vec    ds.l  1
myvec      ds.l  9
oldvbl     ds.l  1
mas1       ds.w  1
mas2       ds.w  1
enab1       ds.w  1
enab2       ds.w  1
pal         ds.b  256
            dc.w  $000,$000,$111,$222,$333,$444,$555,$666
            dc.w  $777,$007,$070,$700,$000,$000,$000,$765
*
   end

