**********************************************************************
*  hide1.s    19.1.86  Version 3.0                                   *
*  House with hidden-line algorithm                                  *
*                                                                    *
**********************************************************************
          .globl    main,xoffs,yoffs,zoffs,offx,offy,offz
          .globl    viewx,viewy,viewz
          .globl    wlinxy,mouse_off,setrotdp,inp_chan,pointrot
          .text

main:
          jsr       apinit       * Announce program
          jsr       grafhand     * Get screen handler
          jsr       openwork     * Display
          jsr       mouse_off    * Turn off mouse
          jsr       getreso      * what resolution ?
          jsr       setcocli     * Prepare clip window

          move.l    #houspla,worldpla * Address of surface array

          jsr       makewrld     * Create world system
          jsr       wrldset      * Pass world parameters

          jsr       setrotdp     * initialize observer ref. point
          jsr       clwork
          jsr       pagedown     * Display logical page
          jsr       clwork
          jsr       inp_chan     * Input and change parameters

mainlop1:
          jsr       pointrot     * rotate about observer ref. point
          jsr       pers         * Perspective transformation
          jsr       hideit
          jsr       surfdraw

          jsr       pageup       * Display physical page
          jsr       inp_chan     * Input new parameters
          jsr       clwork
          jsr       pointrot     * Rotate around rotation ref. point
          jsr       pers         * Transform new points
          jsr       hideit
          jsr       surfdraw
          jsr       pagedown     * Display this logical page
          jsr       inp_chan     * Input and change parameters
          jsr       clwork       * erase physical page
          jmp       mainlop1     * to main loop

mainend:  move.l    physbase,logbase

          jsr       pageup       * switch to normal display page
          rts                    * back to link file, and end

********************************************************************
*  Input and change parameters such as angle increments and        *
*  Z-coordinate of the projection plane                            *
********************************************************************

inp_chan: jsr       inkey        * Sense keyboard, keyboard code in
          cmp.b     #'D',d0
          bne       inpwait
          jsr       scrdmp       * Make harcopy

inpwait:  swap      d0           * Test D0 for
          cmp.b     #$4d,d0      * Cursor-right
          bne       inp1
          addq.w    #1,ywplus    * if yes, then add one to
          bra       inpend1      * Y-angle increment and continue

inp1:     cmp.b     #$4b,d0      * Cursor-left, if yes
          bne       inp2         * then subtract one from
          subq.w    #1,ywplus    * Y-angle increment
          bra       inpend1

inp2:     cmp.b     #$50,d0      * Cursor-down, if yes
          bne       inp3
          addq.w    #1,xwplus    * then add one to X-angle increment
          bra       inpend1

inp3:     cmp.b     #$48,d0      * Cursor-up
          bne       inp3a
          subq.w    #1,xwplus    * subtract one
          bra       inpend1

inp3a:    cmp.b     #$61,d0      * Undo key
          bne       inp3b
          subq.w    #1,zwplus
          bra       inpend1

inp3b:    cmp.b     #$62,d0      * Help key
          bne       inp4
          addq.w    #1,zwplus
          bra       inpend1

inp4:     cmp.b     #$4e,d0      * + key on keypad
          bne       inp5         * if yes then subtract 25 from
          sub.w     #25,dist     * location of projection plane
          bra       inpend1      * (Z-coordinate)
inp5:     cmp.b     #$4a,d0      * - key on keypad
          bne       inp6         *
          add.w     #25,dist     * if yes then add 25
          bra       inpend1

inp6:     cmp.b     #$66,d0      * * key on keypad
          bne       inp7         * if yes, subtract 15 from the
          sub.w     #15,rotdpz   * rotation point Z-coordinate
          bra       inpend1      * Make change

inp7:     cmp.b     #$65,d0      * / key of keypad
          bne       inp10
          add.w     #15,rotdpz   * Add 15
          bra       inpend1

inp10:    cmp.b     #$44,d0      * F10 pressed ?
          bne       inpend1
          addq.l    #4,a7        * if yes, jump to
          bra       mainend      * program end

inpend1:  move.w    hyangle,d1    * Rotation angle about Y-axis
          add.w     ywplus,d1    * add increment
          cmp.w     #360,d1      * if larger than 360, subtract 360
          bge       inpend2
          cmp.w     #-360,d1     * if smaller than 360
          ble       inpend3      * add 360
          bra       inpend4
inpend2:  sub.w     #360,d1
          bra       inpend4
inpend3:  add.w     #360,d1

inpend4:  move.w    d1,hyangle

          move.w    hxangle,d1    * Treat
          add.w     xwplus,d1     * rotation angle about X-axis
          cmp.w     #360,d1       * in the same manner
          bge       inpend5
          cmp.w     #-360,d1
          ble       inpend6
          bra       inpend7
inpend5:  sub.w     #360,d1
          bra       inpend7
inpend6:  add.w     #360,d1

inpend7:  move.w    d1,hxangle    *

          move.w    hzangle,d1
          add.w     zwplus,d1
          cmp.w     #360,d1
          bge       inpend8
          cmp.w     #-360,d1
          ble       inpend9
          bra       inpend10
inpend8:  sub.w     #360,d1
          bra       inpend10
inpend9:  add.w     #360,d1

inpend10: move.w    d1,hzangle
          rts

**********************************************************************
*   Initialize the rotation reference point to [0,0,0] and the       *
*   rotation angle also to 0,0,0                                     *
**********************************************************************

setrotdp: move.w    #0,d1        * set the start rotation-
          move.w    d1,rotdpx    * datum point
          move.w    d1,rotdpy
          move.w    d1,rotdpz
          move.w    #0,hyangle    * Start rotation angle
          move.w    #0,hzangle
          move.w    #0,hxangle
          rts

************************************************************************
* Rotate the total world system around one point, the rotation         *
* reference point                                                      *
************************************************************************

pointrot: move.w    hxangle,xangle * rotate the world around the
          move.w    hyangle,yangle
          move.w    hzangle,zangle
          move.w    rotdpx,d0     * rotation reference point
          move.w    rotdpy,d1
          move.w    rotdpz,d2
          move.w    d0,xoffs      * add for inverse transformation
          move.w    d1,yoffs
          move.w    d2,zoffs
          neg.w     d0
          neg.w     d1
          neg.w     d2
          move.w    d0,offx      * subtract for transformation
          move.w    d1,offy
          move.w    d2,offz
          jsr       matinit      * Matrix initialization
          jsr       zrotate      * first rotate about Z-axis
          jsr       yrotate      * rotate 'matrix' about Y-axis
          jsr       xrotate      * then about X-axis
          jsr       rotate       * Multiply points with matrix
          rts

***********************************************************************
*  Generate world system from object data. All points, lines,         *
*  and surfaces are transferred to the world system                   *
***********************************************************************

makewrld: move.l    #housdatx,a1    * Generate world system by
          move.l    #housdaty,a2
          move.l    #housdatz,a3
          move.l    #wrldx,a4
          move.l    #wrldy,a5
          move.l    #wrldz,a6
          move.w    hnummark,d0
          ext.l     d0
          subq.l    #1,d0
makewl1:  move.w    (a1)+,(a4)+     * Copying point coordinates
          move.w    (a2)+,(a5)+     * to world system
          move.w    (a3)+,(a6)+
          dbra      d0,makewl1
          move.w    hnumline,d0     * Number of house lines
          ext.l     d0
          subq.l    #1,d0
          move.l    #houslin,a1
          move.l    #wlinxy,a2
makewl2:  move.l    (a1)+,(a2)+     * Copy all lines into
          dbra      d0,makewl2      * world system

          move.l    worldpla,a0
          move.l    #wplane,a1
          move.w    hnumsurf,d0      * Number of surfaces on house
          ext.l     d0
          subq.l    #1,d0

makewl3:  move.w    (a0)+,d1        * Copy all surface
          move.w    d1,(a1)+        * definitions into the
          ext.l     d1              * world system
          subq.l    #1,d1

makewl4:  move.l    (a0)+,(a1)+     * Copy every line of this
          dbra      d1,makewl4      * surface into the world array
          dbra      d0,makewl3      * until all surfaces are processed
          rts



***********************************************************************
*   Passing the world parameters to the link file variables           *
***********************************************************************

wrldset:  move.l    #wrldx,datx    * Pass variables for
          move.l    #wrldy,daty    * the rotation routine
          move.l    #wrldz,datz
          move.l    #viewx,pointx
          move.l    #viewy,pointy
          move.l    #viewz,pointz
          move.l    #wlinxy,linxy
          move.w    picturex,x0
          move.w    picturey,y0
          move.w    proz,zobs
          move.w    r1z1,dist
          move.l    #screenx,xplot
          move.l    #screeny,yplot
          move.w    hnumline,numline
          move.w    hnummark,nummark
          move.w    hnumsurf,numsurf
          rts

*****************************************************************
* remove all characters from the keyboard buffer                *
*****************************************************************

clearbuf: move.w    #$b,-(a7)
          trap      #1
          addq.l    #2,a7
          tst.w     d0
          beq       clearnd
          move.w    #1,-(a7)
          trap      #1
          addq.l    #2,a7
          bra       clearbuf

clearnd:  rts


*********************************************************************
*   Sense display resolution and set coordinate origin of screen    *
*   to screen center                                                *
*********************************************************************

getreso:  move.w    #4,-(a7)        * Sense screen resolution
          trap      #14
          addq.l    #2,a7
          cmp.w     #2,d0
          bne       getr1
          move.w    #320,picturex   * Monochrome monitor
          move.w    #200,picturey
          bra       getrend
getr1:    cmp.w     #1,d0
          bne       getr2
          move.w    #320,picturex   * medium resolution (640*200)
          move.w    #100,picturey
          bra       getrend
getr2:    move.w    #160,picturex   * low resolution (320*200)
          move.w    #100,picturey
getrend:  rts

***********************************************************************
*   Hardcopy routine, called by inp_chan                              *
***********************************************************************

scrdmp:   move.w    #20,-(a7)
          trap      #14
          addq.l    #2,a7
          jsr       clearbuf
          rts

*********************************************************************
* Sets the limits of the display window for the Cohen-Sutherland    *
* clip algorithm built into the draw-line algorithm.                *
* The limits can be freely selected by the user, which makes the    *
* draw-line algorithm very flexible.                                *
*********************************************************************

setcocli: move.w    #0,clipxule
          move.w    #0,clipyule
          move.w    picturex,d1
          lsl.w     #1,d1         * times two
          subq.w    #1,d1         * minus one equal
          move.w    d1,clipxlri   * 639 for monochrome
          move.w    picturey,d1
          lsl.w     #1,d1         * times two minus one equal
          subq.w    #1,d1         * 399 for monochrome
          move.w    d1,clipylri
          rts

***********************************************************************
*   Recognition of hidden surfaces and entry of these into the        *
*   vplane array, the surface information is in the surface array     *
*   wplane, as well as in view system, viewx, viewy, viewz,           *
*   also the total number of surfaces must be passed in numsurf       *
***********************************************************************

hideit:
          move.w    numsurf,d0    * Number of surfaces as counter
          ext.l     d0
          subq.l    #1,d0
          move.l    #viewx,a1    * Store point coordinates here
          move.l    #viewy,a2
          move.l    #viewz,a3
          move.l    #wplane,a0   * Information for every surface
          move.l    #vplane,a5   * here.
          move.w    #0,surfcount  * counts the known visible surfaces.

visible:  move.w    (a0),d1      * start with first surface, number
          ext.l     d1           * of points of this surface in D1.
          move.w    2(a0),d2     * Offset of first point of this surf.
          move.w    4(a0),d3     * Offset of second point
          move.w    8(a0),d4     * Offset of third point
          subq.w    #1,d2        * for access to point arrays subtract
          subq.w    #1,d3        * one from current point offset
          subq.w    #1,d4        * multiply by two
          lsl.w     #1,d2
          lsl.w     #1,d3
          lsl.w     #1,d4        * and finally access current point
          move.w    (a1,d3.w),d6 * coordinates
          cmp.w     (a1,d4.w),d6 * comparison recognizes two points
          bne       doit1        * with same coordinates which can
          move.w    (a2,d3.w),d6 * result during construction of
          cmp.w     (a2,d4.w),d6 * rotation bodies. During recognition
          bne       doit1        * of two points in which all point
          move.w    (a3,d4.w),d6 * coordinates match (x,y,z) the
          cmp.w     (a3,d3.w),d6 * program selects a third point for
          bne       doit1        * determination of the two vectors
          move.w    12(a0),d4
          subq.w    #1,d4
          lsl.w     #1,d4

doit1:
          move.w    (a1,d3.w),d5   * Here the two vectors, which lie
          move.w    d5,kx          * in the surface plane, are
          sub.w     (a1,d2.w),d5   * determined by subtracting the
          move.w    d5,px          * coordinates of two points 
          move.w    (a2,d3.w),d5   * from this surface.
          move.w    d5,ky          * The direction coordinates of the
          sub.w     (a2,d2.w),d5   * vectors are stored in the
          move.w    d5,py          * variables qx,qy,qz and px,py,pz
          move.w    (a3,d3.w),d5
          move.w    d5,kz
          sub.w     (a3,d2.w),d5
          move.w    d5,pz

          move.w    (a1,d4.w),d5   * Calculate vector Q
          sub.w     (a1,d2.w),d5
          move.w    (a2,d4.w),d6
          sub.w     (a2,d2.w),d6
          move.w    (a3,d4.w),d7
          sub.w     (a3,d2.w),d7
          move.w    d5,d1          * qx
          move.w    d6,d2          * qy
          move.w    d7,d3          * qz

          muls      py,d3          * Calculate the cross product
          muls      pz,d2          * of the vertical vector for the
          sub.w     d2,d3          * current surface.
          move.w    d3,rx
          muls      pz,d1
          muls      px,d7
          sub.w     d7,d1          * The direction coordinates of the
          move.w    d1,ry          * vertical vector are stored
          muls      px,d6          * zobsorarily in rx,ry,rz
          muls      py,d5
          sub.w     d5,d6
          move.w    d6,rz

          move.w    prox,d1        * The projection center
          sub.w     kx,d1          * is used as the comparison
          move.w    proy,d2        * point for the visibility
          sub.w     ky,d2          * of a surface.
          move.w    proz,d3        * One can also use the
          sub.w     kz,d3          * observation ref. point
          muls      rx,d1          * as the comparison point. Now comes
          muls      ry,d2          * the comparison of vector R with
          muls      rz,d3          * the vector from a point on the
          add.l     d1,d2          * surface to the projection center
          add.l     d2,d3          * for creating the scalar product
          bmi       dosight        * of the two vectors.

* If the scalar product is negative, the surface is visible

          move.w    (a0),d1        * Number of lines of the surface
          ext.l     d1
          lsl.l     #2,d1          * Number of lines times 4 = space for
          addq.l    #2,d1          * lines plus 2 bytes for the number of

          add.l     d1,a0          * lines added to surface array, for
sight1:   dbra      d0,visible     * access to next surface. When all
          bra       hideend        * surfaces completed then end.

dosight:  move.w    (a0),d1        * Number of lines for this surface,
          ext.l     d1             * gives the number of words to be 
          lsl.l     #1,d1          * transmitted when multiplied by 2.

sight3:   move.w    (a0)+,(a5)+    * pass the number of lines and the
          dbra      d1,sight3      * the individual lines

          addq.w    #1,surfcount   * the number of surfaces plus one
          bra       sight1         * and process the next

hideend:  rts


********************************************************************
*  Draw visible surfaces passed in vplane                          *
********************************************************************

surfdraw:                          * Draws a number of surfaces (passed
          move.l    xplot,a4       * in surfcount) whose description
          move.l    yplot,a5

          move.l    #vplane,a6     * is in the array at address
          move.w    surfcount,d0   * vplane, and was entered by routine
          ext.l     d0             * hideit
          subq.l    #1,d0          * if no surface is entered in the
          bmi       surfend        * array, then end.
surflop1: move.w    (a6)+,d1       * Number of lines in this surface as
          ext.l     d1             * counter of lines to be drawn.
          subq.l    #1,d1

surflop2: move.l  (a6)+,d5         * First line of this surface
          subq.w  #1,d5            * Access screen array which contains
          lsl.w   #1,d5            * screen coordinates of the points.
          move.w  0(a4,d5.w),d2
          move.w  0(a5,d5.w),d3    * extract points from routine and
          swap    d5               * pass.
          subq.w  #1,d5
          lsl.w   #1,d5
          move.w  0(a4,d5.w),a2    * second point of line
          move.w  0(a5,d5.w),a3
          jsr     drawl            * Draw line until all lines of this
          dbra    d1,surflop2      * surface have been drawn and repeat
          dbra    d0,surflop1      * until all surfaces are drawn.
surfend:  rts                      * Return.



***********************************************************************
***********************************************************************
*   Here begins the variable area of the program module               *
*                                                                     *
***********************************************************************

***********************************************************************
*                                                                     *
*         Definition of the house                                     *
*                                                                     *
***********************************************************************

          .data

housdatx: .dc.w     -30,30,30,-30,30,-30,-30,30,0,0,-10,-10,10,10
          .dc.w     30,30,30,30,30,30,30,30,30,30,30,30

housdaty: .dc.w     30,30,-30,-30,30,30,-30,-30,70,70,-30,0,0,-30
          .dc.w     20,20,0,0,20,20,0,0
          .dc.w     -10,-10,-30,-30

housdatz: .dc.w     60,60,60,60,-60,-60,-60,-60,60,-60,60,60,60,60
          .dc.w     40,10,10,40,-10,-40,-40,-10
          .dc.w     0,-20,-20,0

houslin:  .dc.w     1,2,2,3,3,4,4,1,2,5,5,8,8,3,8,7,7,6,6,5,6,1,7,4
          .dc.w     9,10,1,9,9,2,5,10,6,10,11,12,12,13,13,14
          .dc.w     15,16,16,17,17,18,18,15,19,20,20,21,21,22,22,19
          .dc.w     23,24,24,25,25,26,26,23

***********************************************************************
* here are the definitions of the surfaces belonging to the house     *
***********************************************************************

houspla:  .dc.w     4,1,2,2,3,3,4,4,1,4,2,5,5,8,8,3,3,2
          .dc.w     4,5,6,6,7,7,8,8,5,4,7,6,6,1,1,4,4,7
          .dc.w     4,4,3,3,8,8,7,7,4,4,2,9,9,10,10,5,5,2
          .dc.w     4,10,9,9,1,1,6,6,10,3,1,9,9,2,2,1
          .dc.w     3,5,10,10,6,6,5,4,11,12,12,13,13,14,14,11
          .dc.w     4,15,16,16,17,17,18,18,15,4,19,20,20,21,21,22,22,19
          .dc.w     4,23,24,24,25,25,26,26,23

hnummark: .dc.w     26     * Number of corner points of the house
hnumline: .dc.w     32     * Number of lines of the house
hnumsurf:  .dc.w     13    * Number of surfaces of the house

hxangle:   .dc.w     0     * Rotation angle of house about X-axis
hyangle:   .dc.w     0     *         "        "         "  Y-axis
hzangle:   .dc.w     0     *         "        "         "  Z-axis

xwplus:   .dc.w     0     * Angle increment about X-axis
ywplus:   .dc.w     0     * Angle increment about Y-axis
zwplus:   .dc.w     0     * Angle increment about Z-axis

picturex: .dc.w     0     * Definition of zero point of display
picturey: .dc.w     0     * entered by getreso


rotdpx:   .dc.w     0
rotdpy:   .dc.w     0
rotdpz:   .dc.w     0


r1z1:     .dc.w     0
normz:    .dc.w     1500

          .bss

plusrot:  .ds.l     1
first:    .ds.w     1
second:   .ds.w     1
delta1:   .ds.w     1

worldpla: .ds.l     1       * Address of surface array

          .data

plag:     .dc.b     1
          .even

          .bss

diffz:    .ds.w     1

dx:       .ds.w     1
dy:       .ds.w     1
dz:       .ds.w     1

wrldx:    .ds.w     1600    * World coordinate array
wrldy:    .ds.w     1600
wrldz:    .ds.w     1600

viewx:    .ds.w     1600    * View coordinate array
viewy:    .ds.w     1600
viewz:    .ds.w     1600

screenx:  .ds.w     1600    * Display coordinate array
screeny:  .ds.w     1600


wlinxy:   .ds.l     3200    * Line array



wplane:   .ds.l     6600    * Surface array

vplane:   .ds.l     6600    * Surface array of visible surfaces

surfcount: .ds.w     1

numsurf:   .ds.w     1

zcount:   .ds.l     1       * Sum of all Z-coordinates
zpla:     .ds.w     1       * Individual Z-coordinates of surface

sx:       .ds.w     1
sy:       .ds.w     1
sz:       .ds.w     1

px:       .ds.w     1
py:       .ds.w     1
pz:       .ds.w     1

rx:       .ds.w     1
ry:       .ds.w     1
rz:       .ds.w     1

qx:       .ds.w     1
qy:       .ds.w     1
qz:       .ds.w     1

kx:       .ds.w     1
ky:       .ds.w     1
kz:       .ds.w     1

          .data

prox:     .dc.w     0       * Coordinates of the projection center
proy:     .dc.w     0       * on the positive Z-axis
proz:     .dc.w     1500 

          .data

offx:     .dc.w     0       * Transformation during rotation
offy:     .dc.w     0       * to point [offx,offy,offz]
offz:     .dc.w     0

xoffs:    .dc.w     0       * Inverse transformation to point
yoffs:    .dc.w     0       * [xoff,yoffs,zoffs]
zoffs:    .dc.w     0


          .bss

loopc     .ds.l     1
          .end
                                                    